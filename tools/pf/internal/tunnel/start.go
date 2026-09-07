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

// StartTimeout bounds how long Start waits for the first connection.
const StartTimeout = 20 * time.Second

// Start spawns a supervisor for a new tunnel and waits until it is connected
// or its first attempt fails. On failure the entry is removed and the ssh
// error is returned.
func (s *Store) Start(ctx context.Context, host string, local, remote int) (Tunnel, error) {
	host = strings.TrimSpace(host)
	if host == "" {
		return Tunnel{}, errors.New("host is required")
	}
	if !ValidPort(local) {
		return Tunnel{}, fmt.Errorf("invalid local port %d", local)
	}
	if !ValidPort(remote) {
		return Tunnel{}, fmt.Errorf("invalid remote port %d", remote)
	}
	if existing, ok := s.Find(host, local, remote); ok {
		return existing, ErrExists{ID: existing.ID}
	}
	if !localPortFree(local) {
		return Tunnel{}, ErrPortInUse{Port: local}
	}

	now := time.Now()
	t := Tunnel{
		ID: s.NextID(), Host: host, LocalPort: local, RemotePort: remote,
		Created: now, Since: now, State: StateConnecting,
	}
	if err := s.Save(t); err != nil {
		return Tunnel{}, err
	}
	if err := s.spawnSupervisor(t.ID); err != nil {
		s.Remove(t.ID)
		return Tunnel{}, err
	}

	ctx, cancel := context.WithTimeout(ctx, StartTimeout)
	defer cancel()
	tick := time.NewTicker(150 * time.Millisecond)
	defer tick.Stop()
	for {
		select {
		case <-ctx.Done():
			cur, _ := s.Load(t.ID)
			if cur.Alive() {
				_ = syscall.Kill(cur.PID, syscall.SIGTERM)
			}
			s.controlExit(cur)
			s.Remove(t.ID)
			reason := cur.Error
			if reason == "" {
				reason = "timed out waiting for the connection"
			}
			return Tunnel{}, errors.New(reason)
		case <-tick.C:
			cur, err := s.Load(t.ID)
			if err != nil {
				return Tunnel{}, errors.New("supervisor exited unexpectedly")
			}
			switch {
			case cur.State == StateConnected:
				return cur, nil
			case cur.State == StateFailed:
				s.Remove(t.ID)
				reason := cur.Error
				if reason == "" {
					reason = "ssh exited before the tunnel came up"
				}
				return Tunnel{}, errors.New(reason)
			case cur.PID != 0 && !cur.Alive():
				s.Remove(t.ID)
				return Tunnel{}, errors.New("supervisor exited unexpectedly")
			}
		}
	}
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
	return cmd.Process.Release()
}

func localPortFree(port int) bool {
	l, err := net.Listen("tcp", fmt.Sprintf("127.0.0.1:%d", port))
	if err != nil {
		return false
	}
	l.Close()
	return true
}
