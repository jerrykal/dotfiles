package tunnel

import (
	"context"
	"errors"
	"os"
	"testing"
	"time"
)

func TestEditValidation(t *testing.T) {
	s := &Store{Dir: t.TempDir()}
	now := time.Now()
	// PID = our own pid makes Alive() true, so tunnel 2 counts as running.
	must := func(err error) {
		t.Helper()
		if err != nil {
			t.Fatal(err)
		}
	}
	must(s.Save(Tunnel{ID: 1, Host: "devbox", LocalPort: 5432, RemotePort: 5432, State: StateConnected, Created: now, Since: now}))
	must(s.Save(Tunnel{ID: 2, Host: "staging", LocalPort: 6379, RemotePort: 6379, State: StateConnected, PID: os.Getpid(), Created: now, Since: now}))

	ctx := context.Background()
	if _, err := s.Edit(ctx, 99, "devbox", 1, 1); err == nil {
		t.Error("expected error for unknown id")
	}
	if _, err := s.Edit(ctx, 1, "devbox", 5432, 5432); !errors.Is(err, ErrUnchanged) {
		t.Errorf("unchanged: got %v", err)
	}
	if _, err := s.Edit(ctx, 1, " ", 5432, 5432); err == nil {
		t.Error("expected error for empty host")
	}
	if _, err := s.Edit(ctx, 1, "devbox", 0, 5432); err == nil {
		t.Error("expected error for bad port")
	}
	var exists ErrExists
	if _, err := s.Edit(ctx, 1, "staging", 6379, 6379); !errors.As(err, &exists) || exists.ID != 2 {
		t.Errorf("duplicate: got %v", err)
	}
	// Editing a tunnel onto its own config is "unchanged", not "exists".
	if _, err := s.Edit(ctx, 2, "staging", 6379, 6379); !errors.Is(err, ErrUnchanged) {
		t.Errorf("self: got %v", err)
	}
	// None of the above may have touched the files.
	if got, err := s.Load(1); err != nil || got.Host != "devbox" || got.LocalPort != 5432 {
		t.Errorf("tunnel 1 modified: %+v %v", got, err)
	}
}

func TestPruneKeepsFailedAndStarting(t *testing.T) {
	s := &Store{Dir: t.TempDir()}
	now := time.Now()
	must := func(err error) {
		t.Helper()
		if err != nil {
			t.Fatal(err)
		}
	}
	// All supervisors are dead (PID 0). Failed entries stay however old;
	// a fresh connecting entry is kept for its launcher; a dead connected
	// tunnel and a stale connecting one are pruned.
	must(s.Save(Tunnel{ID: 1, Host: "a", LocalPort: 1, RemotePort: 1, State: StateFailed, Error: "boom", Since: now.Add(-time.Hour)}))
	must(s.Save(Tunnel{ID: 2, Host: "b", LocalPort: 2, RemotePort: 2, State: StateConnecting, Since: now}))
	must(s.Save(Tunnel{ID: 3, Host: "c", LocalPort: 3, RemotePort: 3, State: StateConnected, Since: now}))
	must(s.Save(Tunnel{ID: 4, Host: "d", LocalPort: 4, RemotePort: 4, State: StateConnecting, Since: now.Add(-time.Hour)}))
	ts, err := s.List()
	must(err)
	live := s.Prune(ts)
	if len(live) != 2 || live[0].ID != 1 || live[0].State != StateFailed || live[1].ID != 2 || live[1].State != StateStopped {
		t.Fatalf("live = %+v", live)
	}
	for _, id := range []int{3, 4} {
		if _, err := s.Load(id); err == nil {
			t.Errorf("tunnel %d not pruned", id)
		}
	}
	// A failed entry is found by Find, so Start would retry it rather than
	// create a duplicate.
	if f, ok := s.Find("a", 1, 1); !ok || f.ID != 1 {
		t.Errorf("Find failed entry: %+v %v", f, ok)
	}
}
