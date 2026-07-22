- My interactive shell is fish.
- When reporting information to me, be extremely concise and sacrifice grammar for the sake of concision.
- Don't retro-add docstrings, comments, or type annotations to code you aren't otherwise changing. In code you do write, comment only where the logic isn't self-evident.
- When working with Python, invoke the relevant /astral:<skill> for uv, ty, and ruff to ensure best practices are followed.
- When designing frontend, prefer dark theme over light theme unless user stated otherwise.
- Prefer the `LSP` tool over `Grep`/`Glob` for semantic code queries where a language server is available. Use `Grep`/`Glob` for plain-text search, non-code files, or when no LSP server is running. `LSP` operations:
  - `goToDefinition` — where a symbol is defined
  - `findReferences` — all references to a symbol
  - `goToImplementation` — implementations of an interface/abstract method
  - `hover` — type/signature/doc info for a symbol
  - `documentSymbol`/`workspaceSymbol` — locate symbols in a file / across the workspace
  - `prepareCallHierarchy`/`incomingCalls`/`outgoingCalls` — callers and callees of a function

@~/.claude/CLAUDE.local.md
