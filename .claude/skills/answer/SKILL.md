---
name: answer
description: Present pending questions from the most recent assistant message via AskUserQuestion for structured bulk-response.
allowed-tools: AskUserQuestion
model: haiku
disable-model-invocation: true
---

# Answer

Extract pending questions from the most recent assistant message in the conversation and surface them through the `AskUserQuestion` tool so the user can answer them in a structured way.

## Workflow

### 1. Locate the source message

Scan backwards through the conversation history. Take the **most recent assistant message** (the one immediately before the `/answer` invocation, ignoring this skill invocation itself).

- If there is no prior assistant message: say "No prior assistant message to extract questions from." and stop.
- If the most recent assistant message contains no questions: say "No pending questions in the most recent assistant message." and stop.

### 2. Extract questions

Identify every question the assistant asked the user that has not yet been answered. Capture both:

- Direct interrogatives (sentences ending with "?")
- Implicit asks ("Let me know which approach you prefer.", "Tell me X and Y.", "Pick one of the following.")

For each, record:

- **question** — concise rephrasing that preserves the meaning (one sentence, ends with "?")
- **context** — one short line of surrounding detail that helps the user choose (omit if the question stands alone)
- **options** — 2–4 plausible discrete answers extracted from the assistant's wording (e.g. choices the assistant listed). For genuinely open-ended questions, supply 2–3 sensible defaults; the user can always pick "Other" to type a custom answer.

Preserve the order in which the questions appeared.

### 3. Present via AskUserQuestion

Call `AskUserQuestion` with up to **4 questions per call**. If more than 4 were extracted, batch them across sequential calls (ask 4, wait for answers, ask the next batch).

Per question:

- `header` — ≤12 characters (e.g. "Database", "Style", "Auth method")
- `question` — the rephrased text from step 2
- `options` — 2–4 entries, each with `label` (1–5 words) and `description` (the trade-off / what happens if chosen). If the assistant clearly recommended one, put it first and append "(Recommended)" to its label.
- `multiSelect: true` only when the question's answers are not mutually exclusive (e.g. "which features do you want enabled?")

Do **not** add an "Other" option yourself — the harness adds it automatically.

### 4. Acknowledge and continue

After answers come back, briefly restate what was chosen (one line per question, no preamble) and then proceed with whatever the assistant was waiting on. If the assistant's prior turn was purely a question batch with no follow-up implied, end the turn after the summary.

## Rules

- Do not fabricate questions the assistant didn't ask.
- Do not re-ask questions the user has already answered later in the conversation.
- Do not call any tool other than `AskUserQuestion`.
- Keep option `label`s concise; put trade-offs in `description`.
- If the assistant asked exactly one question, still use `AskUserQuestion` (don't just inline-ask in prose) — the point of `/answer` is the structured UI.
