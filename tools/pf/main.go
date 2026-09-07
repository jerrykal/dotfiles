package main

import (
	"os"
	"runtime/debug"

	"github.com/jerrykal/dotfiles/tools/pf/internal/cli"
)

func main() {
	if cli.Version == "dev" {
		if info, ok := debug.ReadBuildInfo(); ok {
			for _, s := range info.Settings {
				if s.Key == "vcs.revision" && len(s.Value) >= 7 {
					cli.Version = s.Value[:7]
				}
			}
		}
	}
	if err := cli.New().Execute(); err != nil {
		cli.Fail(err)
		os.Exit(1)
	}
}
