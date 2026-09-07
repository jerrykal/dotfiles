package tunnel

import (
	"bufio"
	"os"
	"path/filepath"
	"sort"
	"strings"
)

// SSHHosts returns concrete Host aliases from ~/.ssh/config and its includes,
// for completion. Patterns containing wildcards or negations are skipped.
func SSHHosts() []string {
	home, err := os.UserHomeDir()
	if err != nil {
		return nil
	}
	seen := map[string]bool{}
	var hosts []string
	walkSSHConfig(filepath.Join(home, ".ssh", "config"), home, seen, &hosts, 0)
	sort.Strings(hosts)
	return hosts
}

func walkSSHConfig(path, home string, seen map[string]bool, hosts *[]string, depth int) {
	if depth > 8 {
		return
	}
	f, err := os.Open(path)
	if err != nil {
		return
	}
	defer f.Close()
	sc := bufio.NewScanner(f)
	for sc.Scan() {
		fields := strings.Fields(sc.Text())
		if len(fields) < 2 || strings.HasPrefix(fields[0], "#") {
			continue
		}
		switch strings.ToLower(fields[0]) {
		case "host":
			for _, h := range fields[1:] {
				if strings.ContainsAny(h, "*?!") || seen[h] {
					continue
				}
				seen[h] = true
				*hosts = append(*hosts, h)
			}
		case "include":
			for _, pat := range fields[1:] {
				if strings.HasPrefix(pat, "~/") {
					pat = filepath.Join(home, pat[2:])
				} else if !filepath.IsAbs(pat) {
					pat = filepath.Join(home, ".ssh", pat)
				}
				matches, _ := filepath.Glob(pat)
				for _, m := range matches {
					walkSSHConfig(m, home, seen, hosts, depth+1)
				}
			}
		}
	}
}
