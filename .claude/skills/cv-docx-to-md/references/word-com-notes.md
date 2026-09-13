# Word COM automation notes

Shared caveats for any script in this repo that edits `Jay Freeman CV.docx` via
Word COM automation (`New-Object -ComObject Word.Application`). Referenced by both
the `cv-docx-to-md` and `cv-md-to-docx` skills — keep this the single copy.

## Requirements

- Microsoft Word must be installed locally (this is Windows-only, PowerShell-only tooling).
- The target `.docx` must be closed in Word before a script opens it via COM — an
  already-open file will conflict with the automation session.
- Always release the COM object and quit Word in a `finally` block
  (`$word.Quit()` then `[System.Runtime.InteropServices.Marshal]::ReleaseComObject($word)`),
  even on error, or Word processes accumulate in the background.

## Word's 255-character Find/Replace limit

`Find.Text` and `Find.Replacement.Text` are each capped at 255 characters — this is
a hard COM limitation, not a bug. CV bullets routinely exceed that. The safe pattern:

- Use `Find` only to **locate** a paragraph. The anchor text passed to `Find` must
  itself be under 255 chars — a short, unique substring of the paragraph (its first
  sentence, or a distinctive phrase) is enough; the full paragraph text is often too
  long for CV bullets and will be rejected. Since the resulting `Paragraph` object
  spans the whole paragraph regardless of how much of it the anchor matched, a
  short anchor still lets you replace or insert-after the entire paragraph.
- Do the actual text change via the **Range API directly** (`Range.Text = "..."`),
  which has no such length limit.

## Preserving bullet/list formatting when inserting new paragraphs

`Range.InsertParagraphAfter()` followed by setting the new paragraph's text does
**not** reliably carry over list numbering (`ListFormat.ListType` can come back as
`0`/no-list on the new paragraph even though the anchor paragraph was a bullet).

The reliable technique: exclude the paragraph's trailing paragraph-mark character,
then set text containing embedded carriage returns (`` `r ``) directly on that range:

```powershell
$paraRange = $paragraph.Range
$textOnlyRange = $doc.Range($paraRange.Start, $paraRange.End - 1)  # exclude trailing ¶
$textOnlyRange.Text = $originalText + "`r" + $newBullet1 + "`r" + $newBullet2
```

Word splits one paragraph into several this way, and every resulting paragraph
inherits the original paragraph's style and list formatting — because it's a split
of one paragraph's own formatting context, not an independently inserted one.

## Verification workflow (always do this, in order)

1. Copy the real `.docx` to a disposable test copy first; never run an edit script
   against the real file untested.
2. Run the script against the test copy.
3. Extract text (`cv-docx-to-md.ps1`) and grep for the expected wording.
4. Spot-check formatting survived, e.g. compare `Paragraph.Range.ListFormat.ListType`
   between an edited paragraph and an untouched neighbor — they should match.
5. Only once 3–4 pass, run against the real file (after taking a `.bak` backup of it).
6. Delete the disposable test copy and any scratch extraction files when done.
