package tunnel

import (
	"context"
	"errors"
	"fmt"
	"net"
	"os"
	"os/exec"
	"strconv"
	"strings"
	"syscall"
	"time"
)

// StartTimeout bounds how long a launch waits for the first connection.
const StartTimeout = 20 * time.Second

// ErrUnchanged is returned by Edit when the new values equal the current ones.
var ErrUnchanged = errors.New("nothing to change")

// Start spawns a supervisor for a new tunnel and waits until it is connected
// or its first attempt fails. On failure the entry is kept in StateFailed
// (and returned alongside the error) so its log can be inspected; running
// Start again with the same arguments retries it.
func (s *Store) Start(ctx context.Context, host string, local, remote int) (Tunnel, error) {
	host, err := validate(host, local, remote)
	if err != nil {
		return Tunnel{}, err
	}
	if existing, ok := s.Find(host, local, remote); ok {
		if existing.State == StateFailed {
			return s.Retry(ctx, existing.ID)
		}
		return existing, ErrExists{ID: existing.ID}
	}
	if !localPortFree(local) {
		return Tunnel{}, ErrPortInUse{Port: local}
	}
	return s.launch(ctx, newTunnel(s.NextID(), host, local, remote, time.Now()))
}

// Retry relaunches a failed tunnel under the same id, keeping its log.
func (s *Store) Retry(ctx context.Context, id int) (Tunnel, error) {
	old, err := s.Load(id)
	if err != nil {
		return Tunnel{}, err
	}
	if old.Alive() {
		return old, fmt.Errorf("tunnel %d is running; use restart", id)
	}
	s.Logf(id, "retrying")
	t := newTunnel(id, old.Host, old.LocalPort, old.RemotePort, time.Now())
	t.Created = old.Created
	return s.launch(ctx, t)
}

// Edit reconfigures an existing tunnel in place: its ssh session is torn
// down and a new one is started under the same id with the new host and
// ports. If the tunnel was running and the new configuration fails to come
// up, the previous one is brought back; a failed tunnel simply keeps the new
// configuration and its new error. Returns ErrUnchanged when nothing differs.
func (s *Store) Edit(ctx context.Context, id int, host string, local, remote int) (Tunnel, error) {
	old, err := s.Load(id)
	if err != nil {
		return Tunnel{}, err
	}
	host, err = validate(host, local, remote)
	if err != nil {
		return Tunnel{}, err
	}
	if host == old.Host && local == old.LocalPort && remote == old.RemotePort {
		return old, ErrUnchanged
	}
	if existing, ok := s.Find(host, local, remote); ok && existing.ID != id {
		if existing.State != StateFailed {
			return existing, ErrExists{ID: existing.ID}
		}
		s.Remove(existing.ID) // this edit supersedes that stale failure
	}

	wasUp := old.Alive()
	// The supervisor is told to stop and the files are recreated; keep the
	// log so the history survives the edit.
	prevLog, _ := os.ReadFile(s.LogPath(id))
	s.stop(old)
	s.Remove(id)
	_ = os.WriteFile(s.LogPath(id), prevLog, 0o644)
	s.Logf(id, "edited: %s -> %s becomes 127.0.0.1:%d -> %s:%d", old.LocalAddr(), old.RemoteAddr(), local, host, remote)

	t := newTunnel(id, host, local, remote, time.Now())
	t.Created = old.Created
	t, err = s.launch(ctx, t)
	if err != nil && wasUp {
		return s.restore(ctx, old, err)
	}
	return t, err
}

// restore relaunches old after a failed Edit and wraps cause with the result.
func (s *Store) restore(ctx context.Context, old Tunnel, cause error) (Tunnel, error) {
	s.Logf(old.ID, "edit failed: %v; restoring %s -> %s", cause, old.LocalAddr(), old.RemoteAddr())
	t := newTunnel(old.ID, old.Host, old.LocalPort, old.RemotePort, time.Now())
	t.Created = old.Created
	t, err := s.launch(ctx, t)
	if err != nil {
		return t, fmt.Errorf("%w; restoring the previous tunnel also failed: %v", cause, err)
	}
	return t, fmt.Errorf("%w (previous tunnel restored)", cause)
}

func newTunnel(id int, host string, local, remote int, now time.Time) Tunnel {
	return Tunnel{
		ID: id, Host: host, LocalPort: local, RemotePort: remote,
		Created: now, Since: now, State: StateConnecting,
	}
}

func validate(host string, local, remote int) (string, error) {
	host = strings.TrimSpace(host)
	if host == "" {
		return "", errors.New("host is required")
	}
	if !ValidPort(local) {
		return "", fmt.Errorf("invalid local port %d", local)
	}
	if !ValidPort(remote) {
		return "", fmt.Errorf("invalid remote port %d", remote)
	}
	return host, nil
}

// launch saves t, spawns its supervisor and waits until it is connected or
// its first attempt fails. On failure the entry is saved in StateFailed with
// the reason and returned together with the error.
func (s *Store) launch(ctx context.Context, t Tunnel) (Tunnel, error) {
	if !localPortFree(t.LocalPort) {
		return s.fail(t, ErrPortInUse{Port: t.LocalPort})
	}
	if err := s.Save(t); err != nil {
		return Tunnel{}, err
	}
	if err := s.spawnSupervisor(t.ID); err != nil {
		return s.fail(t, err)
	}

	ctx, cancel := context.WithTimeout(ctx, StartTimeout)
	defer cancel()
	tick := time.NewTicker(150 * time.Millisecond)
	defer tick.Stop()
	for {
		select {
		case <-ctx.Done():
			cur, err := s.Load(t.ID)
			if err != nil {
				cur = t
			}
			s.stop(cur)
			reason := cur.Error
			if reason == "" {
				reason = "timed out waiting for the connection"
			}
			return s.fail(cur, errors.New(reason))
		case <-tick.C:
			cur, err := s.Load(t.ID)
			if err != nil {
				return s.fail(t, errors.New("supervisor exited unexpectedly"))
			}
			switch {
			case cur.State == StateConnected:
				return cur, nil
			case cur.State == StateFailed:
				reason := cur.Error
				if reason == "" {
					reason = "ssh exited before the tunnel came up"
				}
				return cur, errors.New(reason)
			case cur.PID != 0 && !cur.Alive():
				return s.fail(cur, errors.New("supervisor exited unexpectedly"))
			}
		}
	}
}

// fail records err on t as a failed first attempt and returns both.
func (s *Store) fail(t Tunnel, err error) (Tunnel, error) {
	t.State, t.Error, t.PID, t.SSHPID = StateFailed, err.Error(), 0, 0
	s.Logf(t.ID, "failed: %v", err)
	if serr := s.Save(t); serr != nil {
		return t, fmt.Errorf("%w (and could not record it: %v)", err, serr)
	}
	return t, err
}

// spawnSupervisor re-executes this binary as a detached `_supervise` process.
func (s *Store) spawnSupervisor(id int) error {
	exe, err := os.Executable()
	if err != nil {
		return err
	}
	logf, err := os.OpenFile(s.LogPath(id), os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0o644)
	if err != nil {
		return err
	}
	defer logf.Close()

	cmd := exec.Command(exe, "_supervise", strconv.Itoa(id))
	cmd.Dir = "/"
	cmd.Stdin = nil
	cmd.Stdout = logf
	cmd.Stderr = logf
	cmd.Env = append(os.Environ(), "PF_STATE_DIR="+s.Dir)
	cmd.SysProcAttr = &syscall.SysProcAttr{Setsid: true}
	if err := cmd.Start(); err != nil {
		return fmt.Errorf("start supervisor: %w", err)
	}
	// Reap the child when it exits. A long-lived parent such as the TUI
	// would otherwise leave a zombie that still looks alive to kill(2), and
	// Close/Edit would wait out their whole kill deadline on it.
	go func() { _ = cmd.Wait() }()
	return nil
}

func localPortFree(port int) bool {
	l, err := net.Listen("tcp", fmt.Sprintf("127.0.0.1:%d", port))
	if err != nil {
		return false
	}
	l.Close()
	return true
}
