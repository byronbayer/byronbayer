param(
    [Parameter(Mandatory = $true)]
    [string]$DocxPath,

    [Parameter(Mandatory = $true)]
    [string]$OperationsJsonPath
)

# Applies paragraph-level edits to a DOCX via Word COM automation, preserving the
# document's existing styles/formatting (bullet lists included). Each operation locates
# an existing paragraph by exact text using Word's Find (search-only - Word's
# Find/Replace text fields cap at 255 chars, too short for full CV bullets), then either
# inserts new paragraph(s) immediately after it or replaces its text in place using the
# Range API directly, which has no such length limit.
#
# Operations JSON shape (array), e.g.:
# [
#   { "find": "<exact existing paragraph text>", "action": "InsertAfter", "text": ["new bullet 1", "new bullet 2"] },
#   { "find": "<exact existing paragraph text>", "action": "Replace", "text": "replacement bullet text" }
# ]

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $DocxPath)) {
    throw "DOCX file not found: $DocxPath"
}
if (-not (Test-Path -LiteralPath $OperationsJsonPath)) {
    throw "Operations JSON file not found: $OperationsJsonPath"
}

$resolvedDocxPath = (Resolve-Path -LiteralPath $DocxPath).Path
$operations = @(Get-Content -LiteralPath $OperationsJsonPath -Raw | ConvertFrom-Json)

$wdFindContinue = 1

function Set-ParagraphText {
    param($Doc, $Paragraph, [string]$NewText)
    $paraRange = $Paragraph.Range
    # Exclude the trailing paragraph-mark character so the paragraph mark (and its
    # formatting/list numbering) survives the text swap.
    $textOnlyRange = $Doc.Range($paraRange.Start, $paraRange.End - 1)
    $textOnlyRange.Text = $NewText
}

$word = New-Object -ComObject Word.Application
$word.Visible = $false
$doc = $null

try {
    $doc = $word.Documents.Open($resolvedDocxPath)

    foreach ($op in $operations) {
        $findLength = ([string]$op.find).Length
        if ($findLength -gt 255) {
            throw "Find text exceeds Word's 255-char Find limit: $($op.find)"
        }

        $searchRange = $doc.Content
        $find = $searchRange.Find
        $find.ClearFormatting()
        $find.Forward = $true
        $find.Wrap = $wdFindContinue
        $find.Format = $false
        $find.MatchCase = $false
        $find.MatchWildcards = $false
        $find.MatchWholeWord = $false
        $find.Text = $op.find
        $find.Replacement.Text = ''

        $found = $find.Execute()
        if (-not $found) {
            throw "No paragraph found matching find text: $($op.find)"
        }

        $paragraph = $searchRange.Paragraphs.Item(1)

        if ($op.action -eq 'InsertAfter') {
            # Embed carriage returns in the paragraph's own text range (rather than
            # InsertParagraphAfter + set text on the new paragraph) so Word splits this
            # one paragraph into several, all inheriting its list/bullet formatting.
            $newTexts = @($op.text)
            $combinedText = ([string]$op.find) + "`r" + ($newTexts -join "`r")
            Set-ParagraphText -Doc $doc -Paragraph $paragraph -NewText $combinedText
        }
        elseif ($op.action -eq 'Replace') {
            Set-ParagraphText -Doc $doc -Paragraph $paragraph -NewText ([string]$op.text)
        }
        else {
            throw "Unknown action: $($op.action)"
        }
    }

    $doc.Save()
}
finally {
    if ($doc) {
        $doc.Close()
    }
    $word.Quit()
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($word) | Out-Null
}
