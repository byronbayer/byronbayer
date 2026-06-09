---
name: cv-docx-sync
description: 'Read a DOCX CV and update a Markdown CV with accurate details. Use for CV maintenance, resume synchronization, profile updates, and keeping .md files aligned to .docx source content.'
argument-hint: 'Provide DOCX path and Markdown path (for example: Jay Freeman CV.docx -> Jay Freeman.md).'
user-invocable: true
disable-model-invocation: true
---

# CV DOCX to Markdown Sync

Synchronize a Markdown CV with a DOCX source while preserving existing Markdown structure, formatting, and richer sections.

## When to Use
- A DOCX CV is treated as the source of truth and a Markdown CV must be updated.
- Contact details, dates, roles, skills, or achievements may have changed in the DOCX.
- You want minimal, reviewable edits instead of rewriting the full Markdown file.

## Inputs
- Source DOCX path.
- Target Markdown path.
- Optional sync mode:
  - strict: markdown must mirror docx content closely
  - selective: only update factual deltas and keep markdown enhancements
- Optional scope (default: full):
   - contact-only
   - skills-only
   - career-only
   - full

## Procedure
1. Validate inputs and confirm both files exist.
2. Extract DOCX text safely:
   - Treat DOCX as a zip package.
   - Read `word/document.xml` and convert to rough plain text for comparison.
3. Read the full Markdown CV.
4. Limit analysis to requested scope (or full if omitted).
5. Compare and identify factual deltas:
   - Contact details (email, phone, location, profile links)
   - Date ranges and role titles
   - Skills and technology lists
   - Certifications and career entries
6. Decide edit strategy:
   - If markdown has richer structure, prefer selective updates.
   - If markdown is stale across many sections, use strict synchronization.
7. Apply minimal edits to Markdown (small patches, no broad reformatting).
8. Validate output:
   - Ensure changed facts now match DOCX.
   - Check Markdown readability and section integrity.
9. Report compactly:
   - Max 8 bullets total.
   - Only changed fields/sections.
   - Call out ambiguities only.

## Decision Points
- Source precedence:
  - default to DOCX for factual data
  - preserve Markdown-only formatting and presentation enhancements unless strict mode is requested
- Conflicts:
  - if DOCX has placeholders (for example, "LinkedIn" without URL), keep literal values and flag for user confirmation
- Large mismatch:
  - if more than 30% of sections differ, propose a full rebaseline pass

## Quality Checks
- No accidental deletion of major sections.
- Dates, companies, and role names remain consistent and in chronological order.
- Contact block reflects DOCX source.
- Table formatting and bullet structure still render correctly.
- Only intended files are modified.

## Example Prompts
- `/cv-docx-sync Jay Freeman CV.docx -> Jay Freeman.md`
- `/cv-docx-sync Sync my resume markdown from resume.docx using selective mode`
- `/cv-docx-sync Update profile details and skills from cv.docx into README-based CV`

## Completion Criteria
- Markdown file updated with factual DOCX deltas.
- Changes are minimal and reviewable.
- Any ambiguous fields are explicitly listed for follow-up.
- Response excludes unchanged content.
