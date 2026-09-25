---
name: mermaid-link
description: Mermaid diagrams — deliver each one as a mermaid.live link. Use whenever you draw a Mermaid diagram, or the user asks to see, render, or share one.
---

The terminal shows Mermaid as raw source, so every diagram reaches the user as a mermaid.live link that renders it.

1. Pipe the diagram through this skill's `mermaid-link` script with a quoted heredoc:

   ```sh
   <skill-directory>/mermaid-link <<'EOF'
   flowchart LR
     A --> B
   EOF
   ```

2. Exit 65 means the diagram doesn't parse: fix it from the stderr message and rerun. The step is done when it prints a URL. Any other failure is the tool's, not the diagram's: show the user its stderr and deliver the diagram as a fenced `mermaid` block instead.
3. Reply with the link as a markdown link, `[<what the diagram shows>](<url>)`: the terminal wraps a bare URL this long and breaks the click. Keep the Mermaid source out of the reply; the link is the diagram. A diagram you also write into a file (README, PR, doc) still gets its link, as the preview.

The link encodes the source, so every revision yields a new one. After revising a diagram, reply with the latest link only, so the user never opens a stale one.

`--edit` returns the live-editor link instead: offer it when the user wants to tweak the diagram themselves.
