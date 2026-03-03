param(
    [Parameter(Mandatory=$true)]
    [string]$Path
)

if (-not (Test-Path $Path)) {
    Write-Error "Target folder not found: $Path"
    exit
}


Clear-Host
Write-Host "Deep Credential Sanitizer v2.0 initializing..." -ForegroundColor Cyan
Start-Sleep -Milliseconds 800

$files = Get-ChildItem -Path $Path -Recurse -Include *.md -File -ErrorAction SilentlyContinue

if (!$files) {
    Write-Host "No .md files found." -ForegroundColor Yellow
    exit
}

$chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+-="
$random = New-Object System.Random

$total = $files.Count
$current = 0
$modifiedCount = 0

foreach ($file in $files) {

    $current++
    $percent = [int](($current / $total) * 100)

    Write-Progress -Activity "Scanning markdown files..." `
                   -Status $file.FullName `
                   -PercentComplete $percent

    $lines = Get-Content $file.FullName
    $changed = $false

    for ($i = 0; $i -lt $lines.Count; $i++) {

        # Password içeren tüm satırlar
        if ($lines[$i] -match "(?i)password\s*:\s*(.+)") {

            $length = $Matches[1].Length
            $newPass = -join (1..$length | ForEach-Object {
                $chars[$random.Next(0, $chars.Length)]
            })

            $lines[$i] = ($lines[$i] -replace "(?i)(password\s*:\s*).+", "`$1$newPass")
            $changed = $true
        }

        # DHL gibi tek başına şifre satırı
        elseif ($i -gt 0 -and $lines[$i-1] -match "^\s*DHL\s*$" -and $lines[$i] -match "^\S+$") {

            $length = $lines[$i].Length
            $newPass = -join (1..$length | ForEach-Object {
                $chars[$random.Next(0, $chars.Length)]
            })

            $lines[$i] = $newPass
            $changed = $true
        }
    }
    if ($changed) {
        Copy-Item $file.FullName "$($file.FullName).bak" -Force
        Set-Content -Path $file.FullName -Value $lines
        $modifiedCount++
    }
}

Write-Progress -Activity "Scanning markdown files..." -Completed
[System.Console]::ReadKey($true)
Write-Host ""
Write-Host "Sanitization complete." -ForegroundColor Green
Write-Host "$modifiedCount file(s) modified." -ForegroundColor Cyan
