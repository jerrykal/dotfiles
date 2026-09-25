---
name: mermaid-link
description: Invoke before writing any ```mermaid block, in a reply or a file — flowchart, sequence, state, or any Mermaid diagram — or when the user asks to see, render, or share one.
---

The terminal shows Mermaid as raw source, so every diagram reaches the user as its source followed by a mermaid.live link that renders it.

1. Pipe the diagram through this skill's `mermaid-link` script with a quoted heredoc:

   ```sh
   <skill-directory>/mermaid-link <<'EOF'
   flowchart LR
     A --> B
   EOF
   ```

2. Exit 65 means the diagram doesn't parse: fix it from the stderr message and rerun. Exit 64 or 66 means the call was malformed (no heredoc, empty diagram): fix the call and rerun. The step is done when it prints a URL; a "syntax unchecked" warning beside it means the diagram type couldn't be checked locally, so pass that on to the user. Any other failure is the tool's, not the diagram's: show the user its stderr and deliver the fenced `mermaid` block alone.
3. Reply with the diagram as a fenced `mermaid` block, then its link directly below as a markdown link, `[<what the diagram shows>](<url>)`: the terminal wraps a bare URL this long and breaks the click. This layout holds whichever skill asked for the diagram.

The link encodes the source, so every revision yields a new one. After revising a diagram, reply with the revised source and its new link only, so the user never opens a stale one.

**A diagram you write into a file (README, PR, doc, commit message) goes there as the fenced block alone**, since a link in a file goes stale on the diagram's next edit; its link goes in your reply, as the preview.

`--edit` returns the live-editor link instead: offer it when the user wants to tweak the diagram themselves.
