---
name: Sync CV From DOCX
description: Sync a Markdown CV from a DOCX source using the cv-docx-sync skill with safe defaults.
argument-hint: DOCX path -> Markdown path (optional: selective|strict)
agent: agent
---

Use the [cv-docx-sync skill](../skills/cv-docx-sync/SKILL.md) to synchronize a Markdown CV from a DOCX source.

Inputs:
- Parse arguments in this format: `<docx path> -> <markdown path> [mode]`
- If mode is omitted, default to `selective`.

Execution rules:
1. Validate that both files exist.
2. Run the skill workflow exactly as written.
3. In `selective` mode:
   - Apply only factual deltas (contact info, dates, titles, skills, certifications, achievements).
   - Preserve richer Markdown layout and style.
4. In `strict` mode:
   - Ask for explicit user confirmation before applying broad synchronization edits.
5. If DOCX extraction leaves ambiguous values:
   - Keep current Markdown value unless DOCX is explicit.
   - List each ambiguity in the final summary.

Output format:
- `Mode used`
- `Files compared`
- `Changes applied` (bullet list)
- `Ambiguities` (or `None`)
- `Next recommended action` (single short line)
