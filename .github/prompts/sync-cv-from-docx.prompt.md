---
name: Sync CV From DOCX
description: Sync a Markdown CV from a DOCX source using the cv-docx-sync skill with safe defaults.
argument-hint: DOCX path -> Markdown path (optional: selective|strict) (optional: contact-only|skills-only|career-only|full)
agent: agent
---

Use the [cv-docx-sync skill](../skills/cv-docx-sync/SKILL.md) to synchronize a Markdown CV from a DOCX source.

Inputs:
- Parse arguments in this format: `<docx path> -> <markdown path> [mode] [scope]`
- If mode is omitted, default to `selective`.
- If scope is omitted, default to `full`.

Execution rules:
1. Validate that both files exist.
2. Run `pwsh -File ./.github/skills/cv-docx-sync/scripts/extract-docx-text.ps1 -DocxPath "<docx path>"` and use its output for comparison.
3. Run the skill workflow exactly as written.
4. In `selective` mode:
   - Apply only factual deltas (contact info, dates, titles, skills, certifications, achievements).
   - Preserve richer Markdown layout and style.
5. In `strict` mode:
   - Ask for explicit user confirmation before applying broad synchronization edits.
6. If DOCX extraction leaves ambiguous values:
   - Keep current Markdown value unless DOCX is explicit.
   - List each ambiguity in the final summary.
7. Token-saving rules:
   - Do not quote unchanged content.
   - Do not print raw extracted DOCX text unless the user asks.
   - Keep final response to a maximum of 8 bullets.

Output format:
- `Mode used`
- `Files compared`
- `Changes applied` (bullet list)
- `Ambiguities` (or `None`)
- `Next recommended action` (single short line)
