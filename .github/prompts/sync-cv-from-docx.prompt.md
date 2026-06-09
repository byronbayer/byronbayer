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

Execution:
1. Run the skill workflow exactly as written.
2. Do not restate or override the skill's rules in this prompt.
