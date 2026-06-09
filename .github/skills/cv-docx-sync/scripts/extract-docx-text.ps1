param(
    [Parameter(Mandatory = $true)]
    [string]$DocxPath,

    [Parameter(Mandatory = $false)]
    [string]$OutputPath
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $DocxPath)) {
    throw "DOCX file not found: $DocxPath"
}

$resolvedDocxPath = (Resolve-Path -LiteralPath $DocxPath).Path
$docxDirectory = Split-Path -Path $resolvedDocxPath -Parent
$tempRoot = Join-Path $docxDirectory (".tmp_docx_extract_" + [Guid]::NewGuid().ToString('N'))

try {
    New-Item -ItemType Directory -Path $tempRoot | Out-Null

    $zipPath = Join-Path $tempRoot 'input.zip'
    $unzippedPath = Join-Path $tempRoot 'unzipped'
    Copy-Item -LiteralPath $resolvedDocxPath -Destination $zipPath
    Expand-Archive -Path $zipPath -DestinationPath $unzippedPath -Force

    $documentXmlPath = Join-Path $unzippedPath 'word/document.xml'
    if (-not (Test-Path -LiteralPath $documentXmlPath)) {
        throw "word/document.xml not found in DOCX: $resolvedDocxPath"
    }

    $xml = Get-Content -LiteralPath $documentXmlPath -Raw
    $plain = $xml -replace '<w:tab/>', "`t"
    $plain = $plain -replace '</w:p>', "`n"
    $plain = $plain -replace '<[^>]+>', ''
    $plain = $plain -replace '&amp;', '&'
    $plain = $plain -replace '&lt;', '<'
    $plain = $plain -replace '&gt;', '>'
    $plain = $plain -replace '&#x2013;', '-'
    $plain = $plain -replace '&#x2014;', '-'
    $plain = $plain -replace '&#x2019;', "'"
    $plain = $plain -replace '&#xA0;', ' '

    if ($OutputPath) {
        Set-Content -LiteralPath $OutputPath -Value $plain -Encoding UTF8
    }

    $plain
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}
