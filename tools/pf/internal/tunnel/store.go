package tunnel

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"sort"
	"strconv"
	"strings"
	"syscall"
	"time"
)

// Store is the on-disk state directory shared by the CLI, the TUI and the
// supervisors.
type Store struct{ Dir string }

// DefaultStore returns the store under $XDG_STATE_HOME/pf (or $PF_STATE_DIR),
// creating it.
func DefaultStore() (*Store, error) {
	if dir := os.Getenv("PF_STATE_DIR"); dir != "" {
		if err := os.MkdirAll(dir, 0o755); err != nil {
			return nil, err
		}
		return &Store{Dir: dir}, nil
	}
	base := os.Getenv("XDG_STATE_HOME")
	if base == "" {
		home, err := os.UserHomeDir()
		if err != nil {
			return nil, err
		}
		base = filepath.Join(home, ".local", "state")
	}
	s := &Store{Dir: filepath.Join(base, "pf")}
	if err := os.MkdirAll(s.Dir, 0o755); err != nil {
		return nil, err
	}
	return s, nil
}

func (s *Store) path(id int, ext string) string {
	return filepath.Join(s.Dir, strconv.Itoa(id)+ext)
}

// StatePath, LogPath and SocketPath name the per-tunnel files.
func (s *Store) StatePath(id int) string  { return s.path(id, ".json") }
func (s *Store) LogPath(id int) string    { return s.path(id, ".log") }
func (s *Store) SocketPath(id int) string { return s.path(id, ".sock") }

// Load reads one tunnel's state file.
func (s *Store) Load(id int) (Tunnel, error) {
	data, err := os.ReadFile(s.StatePath(id))
	if errors.Is(err, os.ErrNotExist) {
		return Tunnel{}, fmt.Errorf("no tunnel with id %d", id)
	}
	if err != nil {
		return Tunnel{}, err
	}
	var t Tunnel
	if err := json.Unmarshal(data, &t); err != nil {
		return Tunnel{}, fmt.Errorf("%s: %w", s.StatePath(id), err)
	}
	return t, nil
}

// Save atomically writes a tunnel's state file.
func (s *Store) Save(t Tunnel) error {
	data, err := json.MarshalIndent(t, "", "  ")
	if err != nil {
		return err
	}
	tmp := s.StatePath(t.ID) + ".tmp"
	if err := os.WriteFile(tmp, data, 0o644); err != nil {
		return err
	}
	return os.Rename(tmp, s.StatePath(t.ID))
}

// Remove deletes every file belonging to a tunnel.
func (s *Store) Remove(id int) {
	for _, ext := range []string{".json", ".json.tmp", ".log", ".sock"} {
		os.Remove(s.path(id, ext))
	}
}

// List returns all tunnels sorted by id, with State resolved against the
// live supervisor. Entries whose supervisor is gone are reported as stopped;
// call Prune to drop them.
func (s *Store) List() ([]Tunnel, error) {
	entries, err := os.ReadDir(s.Dir)
	if err != nil {
		return nil, err
	}
	var out []Tunnel
	for _, e := range entries {
		name := e.Name()
		if !strings.HasSuffix(name, ".json") {
			continue
		}
		id, err := strconv.Atoi(strings.TrimSuffix(name, ".json"))
		if err != nil {
			continue
		}
		t, err := s.Load(id)
		if err != nil {
			continue
		}
		if t.State == StateFailed || !t.Alive() {
			t.State = StateStopped
		}
		out = append(out, t)
	}
	sort.Slice(out, func(i, j int) bool { return out[i].ID < out[j].ID })
	return out, nil
}

// Prune removes stopped entries, making sure any orphaned ssh master is told
// to exit first.
func (s *Store) Prune(ts []Tunnel) []Tunnel {
	live := ts[:0]
	for _, t := range ts {
		if t.State != StateStopped {
			live = append(live, t)
			continue
		}
		s.controlExit(t)
		s.Remove(t.ID)
	}
	return live
}

// NextID returns one more than the highest id in use.
func (s *Store) NextID() int {
	entries, _ := os.ReadDir(s.Dir)
	highest := 0
	for _, e := range entries {
		base, ok := strings.CutSuffix(e.Name(), ".json")
		if n, err := strconv.Atoi(base); ok && err == nil && n > highest {
			highest = n
		}
	}
	return highest + 1
}

// Find returns the running tunnel matching host and ports, if any.
func (s *Store) Find(host string, local, remote int) (Tunnel, bool) {
	ts, _ := s.List()
	for _, t := range ts {
		if t.Host == host && t.LocalPort == local && t.RemotePort == remote && t.State != StateStopped {
			return t, true
		}
	}
	return Tunnel{}, false
}

// TailLog returns up to n trailing lines of a tunnel's log.
func (s *Store) TailLog(id, n int) []string {
	data, err := os.ReadFile(s.LogPath(id))
	if err != nil || len(data) == 0 {
		return nil
	}
	lines := strings.Split(strings.TrimRight(string(data), "\n"), "\n")
	if len(lines) > n {
		lines = lines[len(lines)-n:]
	}
	return lines
}

// Close stops a tunnel and removes its files.
func (s *Store) Close(id int) error {
	t, err := s.Load(id)
	if err != nil {
		return err
	}
	if t.Alive() {
		_ = syscall.Kill(t.PID, syscall.SIGTERM)
		deadline := time.Now().Add(5 * time.Second)
		for t.Alive() && time.Now().Before(deadline) {
			time.Sleep(50 * time.Millisecond)
		}
		if t.Alive() {
			_ = syscall.Kill(t.PID, syscall.SIGKILL)
		}
	}
	s.controlExit(t)
	s.Remove(id)
	return nil
}

// Restart asks the supervisor to drop and re-establish the ssh session now.
func (s *Store) Restart(id int) error {
	t, err := s.Load(id)
	if err != nil {
		return err
	}
	if !t.Alive() {
		return fmt.Errorf("tunnel %d is not running", id)
	}
	return syscall.Kill(t.PID, syscall.SIGHUP)
}

// controlOK asks the ssh master on the control socket whether it is up.
func (s *Store) controlOK(t Tunnel) bool {
	sock := s.SocketPath(t.ID)
	if fi, err := os.Stat(sock); err != nil || fi.Mode()&os.ModeSocket == 0 {
		return false
	}
	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()
	args := append(extraSSHArgs(), "-S", sock, "-O", "check", "-o", "BatchMode=yes", t.Host)
	return exec.CommandContext(ctx, "ssh", args...).Run() == nil
}

// controlExit tells any ssh master still listening on the socket to quit.
func (s *Store) controlExit(t Tunnel) {
	sock := s.SocketPath(t.ID)
	if _, err := os.Stat(sock); err != nil {
		return
	}
	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()
	args := append(extraSSHArgs(), "-S", sock, "-O", "exit", "-o", "BatchMode=yes", t.Host)
	_ = exec.CommandContext(ctx, "ssh", args...).Run()
}
