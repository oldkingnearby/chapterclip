param(
    [ValidateSet("debug", "release", "profile")]
    [string]$Mode = "debug",

    [string]$UpdateBaseUrl = ""
)

$ErrorActionPreference = "Stop"

$projectDir = Split-Path -Parent $PSScriptRoot
Set-Location $projectDir

$flutter = Get-Command "flutter" -ErrorAction SilentlyContinue
if (-not $flutter) {
    throw "Flutter is not available on PATH. Install Flutter and run 'flutter doctor' first."
}

$buildArgs = @("build", "apk", "--$Mode")
if ($UpdateBaseUrl.Trim()) {
    $buildArgs += "--dart-define=CHAPTERCLIP_UPDATE_BASE_URL=$($UpdateBaseUrl.Trim())"
}

& $flutter.Source @buildArgs

if ($LASTEXITCODE -ne 0) {
    throw "Android build failed with exit code $LASTEXITCODE"
}
