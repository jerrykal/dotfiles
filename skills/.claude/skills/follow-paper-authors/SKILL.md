---
name: follow-paper-authors
description: "Follow an academic paper's authors on x.com, verifying each identity first."
argument-hint: "<paper url>"
disable-model-invocation: true
model: sonnet
effort: medium
allowed-tools: Bash(playwright-cli:*)
---

# Follow paper authors on x.com

Invoke the `playwright-cli` skill before driving the browser.

## 1. Build the roster

Fetch the paper's landing page and extract every listed author into a roster: name + affiliation. Affiliations often live only on the PDF's first page — fetch it when the landing page lacks them; mark truly unavailable ones `unknown` rather than guessing.

Done when the roster has one entry per author listed on the paper.

## 2. Open the x session

The x.com login lives in a persistent profile (sensitive — contains auth tokens; never copy or commit it):

```bash
playwright-cli -s=x open https://x.com/home --profile="$HOME/.local/share/playwright-cli/profiles/x"
```

Done when the home timeline renders logged in. A sign-in wall means the login expired: stop and ask the user to re-login by rerunning `open` with `--headed` (credentials never pass through you).

## 3. Sweep the roster

x.com pages produce huge snapshots — reach for `find`, element-scoped snapshots, or `--depth` instead of full-page `snapshot`.

For each roster entry:

**Search.** Open the People tab: `playwright-cli -s=x goto "https://x.com/search?q=<name>%20<affiliation-keyword>&f=user"`. If nothing relevant surfaces, retry with name + a distinctive keyword from the paper's title, then name alone.

**Verdict.** Open the best candidate's profile and corroborate it against the roster entry and the paper. Evidence that counts:

- bio or display name ties to the affiliation or the paper's field
- profile link resolves to a homepage / Scholar / GitHub page identifying the author
- posts (especially pinned) about the paper or its research area

`match` requires at least one corroboration beyond the name — a bare name match is `ambiguous`. Multiple uncorroborated candidates: `ambiguous`. Nothing plausible after the retries: `not-found`.

**Follow.** Only on `match`. The follow button's text is the state: "Following @handle" → record `already-following` and move on; "Follow @handle" → click it and confirm the text flips to "Following". Pause a few seconds between follows — bursts trip X's spam heuristics.

Done when every roster entry carries a verdict and an action.

## 4. Report and close

`playwright-cli -s=x close`, then report one row per author: name · affiliation · handle (or —) · outcome (`followed` / `already-following` / `ambiguous` / `not-found`), with a one-line reason for every non-follow.
