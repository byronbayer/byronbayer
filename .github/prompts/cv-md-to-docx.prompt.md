---
name: CV Markdown to DOCX
description: Insert or replace bulleted CV achievements directly in the DOCX using the cv-md-to-docx skill, so it matches the Markdown CV.
argument-hint: DOCX path plus the edit(s) to make (e.g. "add these two bullets after the ColX Managed DevOps Pool line")
agent: agent
---

Use the [cv-md-to-docx skill](../../.claude/skills/cv-md-to-docx/SKILL.md) to insert or replace bulleted paragraphs directly in a DOCX CV.

Inputs:
- The target DOCX path.
- One or more edits: each either an anchor paragraph's text plus new bullet(s) to insert after it, or an anchor paragraph's text plus its full replacement text.

Execution:
1. Run the skill workflow exactly as written, including its test-copy-first verification steps before touching the real DOCX.
2. Do not restate or override the skill's rules in this prompt.
