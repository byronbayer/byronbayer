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
   - Run [extract-docx-text.ps1](./scripts/extract-docx-text.ps1).
   - Example: `pwsh -File ./.github/skills/cv-docx-sync/scripts/extract-docx-text.ps1 -DocxPath "<docx path>"`
3. Read the full Markdown CV.
4. Limit analysis to requested scope (or full if omitted).
5. Compare and identify factual deltas:
   - Contact details (email, phone, location, profile links)
   - Date ranges and role titles
   - Skills and technology lists
   - Certifications and career entries
   - Company website URLs for any new career history companies
6. Decide edit strategy:
   - If markdown has richer structure, prefer selective updates.
   - If markdown is stale across many sections, use strict synchronization.
7. Apply minimal edits to Markdown (small patches, no broad reformatting), plus link normalization rules:
   - Career history company names must be hyperlinked when a website is known or can be confidently identified.
   - For new career entries, convert plain company names to links in the heading line.
   - If multiple companies are present in one role heading, format each as a separate link joined by ` | ` (example: `[Cloud Direct](https://www.clouddirect.net/) | [Drop Table](https://www.droptable.io/)`).
   - Render all hyperlinks in the output Markdown using HTML anchors so they open in a new tab: `<a href="URL" target="_blank" rel="noopener noreferrer">Label</a>`.
   - If an existing Markdown link does not open in a new tab, convert it to the HTML anchor format above.
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
   - if a new company is found but no trustworthy website can be identified, keep the company name unlinked and flag it as an ambiguity
- Large mismatch:
  - if more than 30% of sections differ, propose a full rebaseline pass

## Quality Checks
- No accidental deletion of major sections.
- Dates, companies, and role names remain consistent and in chronological order.
- Contact block reflects DOCX source.
- All hyperlinks use HTML anchor format with `target="_blank"` and `rel="noopener noreferrer"`.
- New career-history company names are linked when website URLs are known.
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
