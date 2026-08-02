# Regenerates the connection-help deliverables in ..\ from the source in this folder.
#
#   powershell -ExecutionPolicy Bypass -File build.ps1
#
# Inputs : connection-help.source.html  (the file to edit)
#          xplane-network-tab.png       (inlined as a data URI at build time)
# Outputs: ..\index.html                          self-contained page, nothing external
#          ..\Remote-Panel-2-Connection-Help.pdf  rendered via headless Edge, if present
#
# The page is named index.html so GitHub Pages serves it at the bare /docs/ URL.

$ErrorActionPreference = 'Stop'
$src = $PSScriptRoot
$out = Split-Path $src -Parent

$body = [IO.File]::ReadAllText("$src\connection-help.source.html")
$b64  = [Convert]::ToBase64String([IO.File]::ReadAllBytes("$src\xplane-network-tab.png"))
$body = $body.Replace('__SCREENSHOT__', "data:image/png;base64,$b64")

if ($body -match '__SCREENSHOT__') { throw "screenshot placeholder was not substituted" }

# The source omits the document scaffolding so it can also be published as-is
# to a host that supplies its own; add it plus a minimal reset for standalone use.
$head = @'
<!DOCTYPE html>
<html lang="en">
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="description" content="Fixing a Remote Panel 2 connection to the X-Plane ExtPlane plugin.">
<style>
  *, *::before, *::after { box-sizing: border-box; }
  body { margin: 0; }
  img { max-width: 100%; }
</style>
'@

$htmlPath = Join-Path $out 'index.html'
[IO.File]::WriteAllText($htmlPath, ($head + $body + "`n</html>`n"), (New-Object Text.UTF8Encoding $false))
"{0,-40} {1,9:N0} bytes" -f (Split-Path $htmlPath -Leaf), (Get-Item $htmlPath).Length

$edge = @(
    "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
    "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe",
    "$env:ProgramFiles\Google\Chrome\Application\chrome.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $edge) {
    Write-Warning "No Edge/Chrome found - skipping PDF. Open the HTML and print to PDF instead."
    return
}

$pdfPath = Join-Path $out 'Remote-Panel-2-Connection-Help.pdf'
if (Test-Path $pdfPath) { Remove-Item -LiteralPath $pdfPath -Force }
$uri = 'file:///' + ($htmlPath -replace '\\', '/')

# Edge logs harmless warnings to stderr, which would otherwise be promoted to a
# terminating error here. Judge success by whether the PDF actually appeared.
$prev = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
& $edge --headless=new --disable-gpu --no-pdf-header-footer --print-to-pdf="$pdfPath" $uri 2>&1 | Out-Null
$ErrorActionPreference = $prev

if (-not (Test-Path $pdfPath)) { throw "Edge did not produce $pdfPath" }
"{0,-40} {1,9:N0} bytes" -f (Split-Path $pdfPath -Leaf), (Get-Item $pdfPath).Length
