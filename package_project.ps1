$ErrorActionPreference = 'Stop'
$projectRoot = $PSScriptRoot
$archivePath = Join-Path (Split-Path $projectRoot -Parent) 'ITP107_FinalsLabExam_BSIT3B_Malana.zip'
if (Test-Path -LiteralPath $archivePath) { throw "Archive already exists: $archivePath. Rename it before packaging again." }
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$stream = [System.IO.File]::Open($archivePath, [System.IO.FileMode]::CreateNew)
$zip = [System.IO.Compression.ZipArchive]::new($stream, [System.IO.Compression.ZipArchiveMode]::Create)
try {
  Get-ChildItem -LiteralPath $projectRoot -Recurse -File -Force | ForEach-Object {
    $relative = $_.FullName.Substring($projectRoot.Length + 1).Replace('\', '/')
    if ($_.Extension -eq '.zip') { return }
    if ($relative -match '(^|/)(build|\.dart_tool|\.git|\.idea|\.gradle|ephemeral|\.plugin_symlinks)(/|$)' -or $relative -match '(^|/)(local\.properties|\.flutter-plugins.*|.*\.iml)$') { return }
    [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $_.FullName, "post_reader_favorites/$relative") | Out-Null
  }
} finally { $zip.Dispose(); $stream.Dispose() }
Write-Output $archivePath
