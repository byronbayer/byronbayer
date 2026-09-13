---
name: cv-md-to-docx
description: 'Insert or replace bulleted achievement paragraphs directly in a DOCX CV via Word COM automation, preserving bullet/list formatting. Use for adding a new CV bullet, updating an existing bullet, or otherwise editing DOCX career-history content to match the Markdown CV.'
argument-hint: 'Provide the DOCX path and the edits to make (e.g. "add these two bullets after the ColX Managed DevOps Pool line").'
user-invocable: true
disable-model-invocation: true
---

# CV Markdown to DOCX Editor

Insert new bulleted paragraphs into a DOCX CV, or replace an existing paragraph's
text in place, using Word COM automation — without hand-editing the binary file or
losing its existing bullet/list formatting.

See [word-com-notes.md](../cv-docx-to-md/references/word-com-notes.md) (shared with
the `cv-docx-to-md` skill) for the Word COM caveats this workflow depends on: the
255-character Find/Replace limit, the technique for preserving bullet formatting on
inserted paragraphs, and the required test-then-apply verification workflow.

## When to Use
- A CV bullet needs to be added, reworded, or replaced directly in the `.docx` file.
- The equivalent Markdown CV has already been (or will be) updated with the same
  wording, and the DOCX needs to match it exactly.

## Inputs
- Target DOCX path.
- One or more edits, each either:
  - an anchor paragraph's exact existing text plus one or more new bullet(s) to
    insert immediately after it, or
  - an anchor paragraph's exact existing text plus its full replacement text.

For a paragraph longer than 255 characters, `find` cannot be the full paragraph
text — Word's Find pattern itself is capped at 255 characters (see the shared
reference). Use the shortest substring that uniquely identifies the paragraph
instead (e.g. its first sentence or a distinctive phrase); the script still
operates on the whole paragraph regardless of how much of it `find` matched, so
`Replace` still replaces the entire paragraph and `InsertAfter` still inserts after
the whole paragraph, not just the matched substring.

## Procedure
1. Confirm the target DOCX exists and is closed in Word (COM automation will
   conflict with an already-open file — see the shared reference).
2. Write the edits as an operations JSON file (do not invent one inline in
   PowerShell — keep it as a reviewable artifact):
   ```json
   [
     { "find": "<exact existing paragraph text>", "action": "InsertAfter", "text": ["new bullet 1", "new bullet 2"] },
     { "find": "<exact existing paragraph text>", "action": "Replace", "text": "replacement bullet text" }
   ]
   ```
   Save it under [scripts/operations/](../../../scripts/operations/) (the repo's
   common `scripts/` folder, not this skill directory) with a descriptive filename
   (e.g. `add-ai-infra-bullets.json`) so it's a durable record of the change, not a
   throwaway scratch file.
3. Back up the real DOCX (a `.bak` copy) before running anything against it.
4. Test first: copy the DOCX to a disposable file and run
   [cv-md-to-docx.ps1](../../../scripts/cv-md-to-docx.ps1) against the copy:
   `pwsh -File ./scripts/cv-md-to-docx.ps1 -DocxPath "<test copy path>" -OperationsJsonPath "<ops.json path>"`
5. Verify the test copy using
   [cv-docx-to-md.ps1](../../../scripts/cv-docx-to-md.ps1) (reused from
   the `cv-docx-to-md` skill — don't duplicate it) to confirm the new/changed text
   landed correctly, and spot-check bullet formatting survived (see the shared
   reference's verification workflow).
6. Only once verified, run the same command against the real DOCX.
7. Re-verify the real file the same way, then delete the disposable test copy and
   any scratch extraction output. Keep the `.bak` until the change is confirmed good.
8. If a Markdown CV exists alongside the DOCX, either make the matching edit there
   directly or run the [cv-docx-to-md](../cv-docx-to-md/SKILL.md) skill afterward so
   both files stay in sync.

## Quality Checks
- `find` text for each operation matches an existing paragraph exactly (case- and
  whitespace-trimmed) and is under 255 characters.
- Inserted/replaced paragraphs have the same `Style` and `ListFormat.ListType` as
  their neighboring paragraphs (no lost bullet formatting).
- No duplicated sections or paragraphs introduced.
- The real DOCX was only edited after a successful test-copy run.

## Example Prompts
- `/cv-md-to-docx Add two bullets after the "Managed DevOps Pool" line in Jay Freeman CV.docx`
- `/cv-md-to-docx Replace the "Set up Azure monitoring" bullet under Allica Bank with this new wording: ...`

## Completion Criteria
- The real DOCX contains exactly the intended text changes, with formatting matched.
- The operations JSON used is saved under the repo's `scripts/operations/` for future reference.
- Test copies and scratch files are cleaned up; the `.bak` backup is left in place
  until the user confirms the change.
