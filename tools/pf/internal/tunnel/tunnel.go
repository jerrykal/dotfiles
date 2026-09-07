// Package tunnel manages SSH local port forwards. Each forward is owned by a
// detached supervisor process (`pf _supervise <id>`) that runs ssh, watches
// it, reconnects with backoff, and keeps <state-dir>/<id>.json up to date.
package tunnel

import (
	"fmt"
	"syscall"
	"time"
)

// State is the lifecycle phase of a tunnel as reported by its supervisor.
type State string

const (
	StateConnecting   State = "connecting"   // first attempt in progress
	StateConnected    State = "connected"    // control socket answered
	StateReconnecting State = "reconnecting" // ssh exited after a successful connection; retrying
	StateFailed       State = "failed"       // first attempt failed; kept for inspection until closed, retried or edited
	StateStopped      State = "stopped"      // supervisor is gone; entry is stale
)

// Tunnel is one managed port forward.
type Tunnel struct {
	ID         int       `json:"id"`
	Host       string    `json:"host"`
	LocalPort  int       `json:"local_port"`
	RemotePort int       `json:"remote_port"`
	Created    time.Time `json:"created"`
	PID        int       `json:"pid,omitempty"`     // supervisor pid
	SSHPID     int       `json:"ssh_pid,omitempty"` // current ssh child pid
	State      State     `json:"state"`
	Since      time.Time `json:"since"` // last state change
	Reconnects int       `json:"reconnects"`
	Error      string    `json:"error,omitempty"` // last ssh stderr line
}

// LocalAddr is the address clients connect to.
func (t Tunnel) LocalAddr() string { return fmt.Sprintf("127.0.0.1:%d", t.LocalPort) }

// RemoteAddr is the forward target as seen from the ssh host.
func (t Tunnel) RemoteAddr() string { return fmt.Sprintf("%s:%d", t.Host, t.RemotePort) }

// Alive reports whether the supervisor process still exists.
func (t Tunnel) Alive() bool { return pidAlive(t.PID) }

// Age is how long the tunnel has been in its current state.
func (t Tunnel) Age() time.Duration {
	if t.Since.IsZero() {
		return 0
	}
	return time.Since(t.Since)
}

func pidAlive(pid int) bool {
	if pid <= 0 {
		return false
	}
	err := syscall.Kill(pid, 0)
	return err == nil || err == syscall.EPERM
}

// ValidPort reports whether p is a usable TCP port.
func ValidPort(p int) bool { return p >= 1 && p <= 65535 }

// ErrExists is returned by Start when an equivalent tunnel is already running.
type ErrExists struct{ ID int }

func (e ErrExists) Error() string { return fmt.Sprintf("tunnel already exists as id %d", e.ID) }

// ErrPortInUse is returned by Start when the local port is already bound.
type ErrPortInUse struct{ Port int }

func (e ErrPortInUse) Error() string { return fmt.Sprintf("local port %d is already in use", e.Port) }
