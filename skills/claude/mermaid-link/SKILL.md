---
name: mermaid-link
description: Mermaid diagrams — deliver each one as its source followed by a mermaid.live link. Use whenever you draw a Mermaid diagram, or the user asks to see, render, or share one.
---

The terminal shows Mermaid as raw source, so every diagram reaches the user as its source followed by a mermaid.live link that renders it.

1. Pipe the diagram through this skill's `mermaid-link` script with a quoted heredoc:

   ```sh
   <skill-directory>/mermaid-link <<'EOF'
   flowchart LR
     A --> B
   EOF
   ```

2. Exit 65 means the diagram doesn't parse: fix it from the stderr message and rerun. The step is done when it prints a URL. Any other failure is the tool's, not the diagram's: show the user its stderr and deliver the fenced `mermaid` block alone.
3. Reply with the diagram as a fenced `mermaid` block, then its link directly below as a markdown link, `[<what the diagram shows>](<url>)`: the terminal wraps a bare URL this long and breaks the click. This layout holds whichever skill asked for the diagram. A diagram you also write into a file (README, PR, doc) still gets its link, as the preview.

The link encodes the source, so every revision yields a new one. After revising a diagram, reply with the revised source and its new link only, so the user never opens a stale one.

`--edit` returns the live-editor link instead: offer it when the user wants to tweak the diagram themselves.
