param([switch]$CheckOnly)

$ErrorActionPreference = 'Stop'
$projectDir = Split-Path -Parent $PSScriptRoot
$recordDir = Join-Path $projectDir 'build\recordings'
$adbPath = Join-Path $env:LOCALAPPDATA 'Android\Sdk\platform-tools\adb.exe'
$scrcpyPath = Join-Path $env:LOCALAPPDATA 'Temp\dajare-recording-tools\scrcpy-win64-v4.1\scrcpy.exe'

try {
    if (-not (Test-Path -LiteralPath $scrcpyPath)) {
        $installed = Get-Command scrcpy.exe -ErrorAction SilentlyContinue
        if ($installed) { $scrcpyPath = $installed.Source }
        else { throw 'scrcpy was not found. Please ask to restore the recording tool.' }
    }
    if (-not (Test-Path -LiteralPath $adbPath)) {
        throw 'Android SDK adb.exe was not found.'
    }
    $env:ADB = $adbPath
    $devices = & $adbPath devices
    if ($LASTEXITCODE -ne 0) { throw 'Could not connect to Android.' }
    $emulators = @($devices | Where-Object { $_ -match '^emulator-\d+\s+device\s*$' })
    if ($emulators.Count -ne 1) {
        throw 'Please start exactly one Android emulator, wait for it to finish booting, then retry.'
    }
    $serial = ($emulators[0] -split '\s+')[0]
    if ($CheckOnly) {
        Write-Host "Ready: $serial"
        Write-Host "Recorder: $scrcpyPath"
        Write-Host "Output folder: $recordDir"
        exit 0
    }

    New-Item -ItemType Directory -Force -Path $recordDir | Out-Null
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss-fff'
    $video = Join-Path $recordDir "dajare-test-$stamp.mp4"
    $log = Join-Path $recordDir "dajare-test-$stamp.log"
    Write-Host 'Starting video + app audio recording...'
    Write-Host 'Turn Sound ON inside the app to record BGM.'
    Write-Host 'STOP: close the separate Dajare Recording preview window.'
    Write-Host 'Keep this console open until the saved path appears.'
    $arguments = @(
        '-s', $serial,
        '--no-control', '--no-audio-playback',
        '--audio-source=playback', '--audio-dup', '--audio-codec=aac',
        '--require-audio', '--max-size=1280',
        '--window-title="Dajare Recording - CLOSE THIS WINDOW TO STOP"',
        "--record=`"$video`""
    )
    $process = Start-Process -FilePath $scrcpyPath -ArgumentList $arguments -PassThru -Wait -WindowStyle Normal -RedirectStandardError $log
    $logText = if (Test-Path -LiteralPath $log) { Get-Content -LiteralPath $log -Raw } else { '' }
    if ($process.ExitCode -ne 0 -or -not (Test-Path -LiteralPath $video)) {
        Write-Host $logText
        throw "Recording did not finish successfully. Log: $log"
    }
    Write-Host ''
    Write-Host 'Recording finished.' -ForegroundColor Green
    Write-Host "Saved to: $video" -ForegroundColor Cyan
    Write-Host ''
    $choice = Read-Host 'Press Enter to show the file in Explorer, or type Q to exit'
    if ($choice -ne 'q') {
        Start-Process explorer.exe -ArgumentList "/select,`"$video`""
    }
} catch {
    Write-Host ''
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}
