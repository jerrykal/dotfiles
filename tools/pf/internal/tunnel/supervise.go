package tunnel

import (
	"bufio"
	"errors"
	"fmt"
	"io"
	"os"
	"os/exec"
	"os/signal"
	"strings"
	"sync"
	"syscall"
	"time"
)

const (
	backoffMin = time.Second
	backoffMax = 30 * time.Second
)

// Supervise is the body of `pf _supervise <id>`. It runs ssh for the tunnel,
// marks it connected once the control socket answers, and reconnects with
// exponential backoff after a drop. SIGTERM stops it and removes the entry;
// SIGHUP forces an immediate reconnect. It returns once the tunnel is torn
// down, or with an error if the very first attempt fails.
func (s *Store) Supervise(id int) error {
	t, err := s.Load(id)
	if err != nil {
		return err
	}
	t.PID = os.Getpid()
	if err := s.Save(t); err != nil {
		return err
	}

	logf, err := os.OpenFile(s.LogPath(id), os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0o644)
	if err != nil {
		return err
	}
	defer logf.Close()
	log := &logger{w: logf}

	sigs := make(chan os.Signal, 4)
	signal.Notify(sigs, syscall.SIGTERM, syscall.SIGINT, syscall.SIGHUP)

	everConnected := false
	backoff := backoffMin
	sock := s.SocketPath(id)

	for {
		os.Remove(sock)
		if everConnected {
			t.State = StateReconnecting
		} else {
			t.State = StateConnecting
		}
		t.Since = time.Now()
		t.SSHPID = 0
		_ = s.Save(t)
		log.printf("connecting to %s", t.Host)

		cmd := exec.Command("ssh", sshArgs(t, sock)...)
		cmd.Stdin = nil
		cmd.Stdout = logf
		stderr, err := cmd.StderrPipe()
		if err != nil {
			return err
		}
		if err := cmd.Start(); err != nil {
			t.State, t.Error = StateFailed, err.Error()
			_ = s.Save(t)
			return err
		}
		t.SSHPID = cmd.Process.Pid
		_ = s.Save(t)
		log.reset()
		stderrDone := make(chan struct{})
		go func() { log.copy(stderr); close(stderrDone) }()

		done := make(chan error, 1)
		go func() { done <- cmd.Wait() }()
		check := time.NewTicker(300 * time.Millisecond)

		connected := false
		var exitErr error
		restart := false
	wait:
		for {
			select {
			case exitErr = <-done:
				break wait
			case sig := <-sigs:
				stopSSH(cmd, done)
				if sig == syscall.SIGHUP {
					log.printf("restart requested")
					restart = true
					break wait
				}
				log.printf("stopping")
				s.controlExit(t)
				s.Remove(id)
				return nil
			case <-check.C:
				if !connected && s.controlOK(t) {
					connected, everConnected = true, true
					backoff = backoffMin
					t.State, t.Since, t.Error = StateConnected, time.Now(), ""
					_ = s.Save(t)
					log.printf("connected: %s -> %s", t.LocalAddr(), t.RemoteAddr())
				}
			}
		}
		check.Stop()
		<-stderrDone

		reason := log.last()
		if reason == "" && exitErr != nil {
			reason = exitErr.Error()
		}
		detail := ""
		if reason != "" {
			detail = " (" + reason + ")"
		}
		if restart {
			t.Reconnects++
			backoff = backoffMin
			continue
		}
		if !everConnected {
			if reason == "" {
				reason = "ssh exited before the tunnel came up"
			}
			t.State, t.Error = StateFailed, reason
			_ = s.Save(t)
			log.printf("failed: %s", reason)
			return errors.New(reason)
		}
		t.State, t.Since, t.Error, t.SSHPID = StateReconnecting, time.Now(), reason, 0
		t.Reconnects++
		_ = s.Save(t)
		log.printf("ssh exited%s; retrying in %s", detail, backoff)

		select {
		case <-time.After(backoff):
		case sig := <-sigs:
			if sig != syscall.SIGHUP {
				log.printf("stopping")
				s.Remove(id)
				return nil
			}
			backoff = backoffMin
			continue
		}
		if backoff *= 2; backoff > backoffMax {
			backoff = backoffMax
		}
	}
}

// extraSSHArgs returns options from $PF_SSH_ARGS, e.g. "-F ~/alt/config" or
// "-o IdentityAgent=...", inserted before every ssh invocation's own options.
func extraSSHArgs() []string {
	return strings.Fields(os.Getenv("PF_SSH_ARGS"))
}

func sshArgs(t Tunnel, sock string) []string {
	return append(extraSSHArgs(),
		"-N",
		"-o", "BatchMode=yes",
		"-o", "ExitOnForwardFailure=yes",
		"-o", "ConnectTimeout=15",
		"-o", "ServerAliveInterval=30",
		"-o", "ServerAliveCountMax=3",
		"-o", "ControlMaster=yes",
		"-o", "ControlPath="+sock,
		"-o", "ControlPersist=no",
		"-L", fmt.Sprintf("127.0.0.1:%d:127.0.0.1:%d", t.LocalPort, t.RemotePort),
		t.Host,
	)
}

func stopSSH(cmd *exec.Cmd, done <-chan error) {
	_ = cmd.Process.Signal(syscall.SIGTERM)
	select {
	case <-done:
	case <-time.After(3 * time.Second):
		_ = cmd.Process.Kill()
		<-done
	}
}

// logger writes timestamped lines and remembers the last non-empty one.
type logger struct {
	mu   sync.Mutex
	w    io.Writer
	tail string
}

func (l *logger) printf(format string, args ...any) {
	l.mu.Lock()
	defer l.mu.Unlock()
	fmt.Fprintf(l.w, "%s pf: %s\n", time.Now().Format("15:04:05"), fmt.Sprintf(format, args...))
}

func (l *logger) copy(r io.Reader) {
	sc := bufio.NewScanner(r)
	for sc.Scan() {
		line := strings.TrimSpace(sc.Text())
		if line == "" {
			continue
		}
		l.mu.Lock()
		l.tail = line
		fmt.Fprintf(l.w, "%s %s\n", time.Now().Format("15:04:05"), line)
		l.mu.Unlock()
	}
}

func (l *logger) reset() {
	l.mu.Lock()
	l.tail = ""
	l.mu.Unlock()
}

func (l *logger) last() string {
	l.mu.Lock()
	defer l.mu.Unlock()
	return l.tail
}
