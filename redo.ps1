param(
    [Parameter(Mandatory=$true)]
    [string]$Path
)

if (-not (Test-Path $Path)) {
    Write-Error "Target file not found: $Path"
    exit
}

Clear-Host
Write-Host "CMA Password Obfuscator initializing..." -ForegroundColor Cyan
Start-Sleep -Milliseconds 500

$chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+-="
$random = New-Object System.Random

$lines = Get-Content $Path
$changed = $false
$inCMA = $false

for ($i = 0; $i -lt $lines.Count; $i++) {

    # CMA başlığı bulundu
    if ($lines[$i] -match "^\s*CMA\s*$") {
        $inCMA = $true
        continue
    }

    # CMA altındayız ve Password satırı bulundu
    if ($inCMA -and $lines[$i] -match "(?i)Password\s*:\s*(.+)") {
        $length = $Matches[1].Length
        $newPass = -join (1..$length | ForEach-Object {
            $chars[$random.Next(0, $chars.Length)]
        })

        $lines[$i] = ($lines[$i] -replace "(?i)(Password\s*:\s*).+", "`$1$newPass")
        $changed = $true

        # Tek CMA password’u değiştirildikten sonra çıkıyoruz
        break
    }
}

if ($changed) {
    Set-Content -Path $Path -Value $lines
    Write-Host "Cannot find the file." -ForegroundColor Green
} else {
    Write-Host "" -ForegroundColor Yellow
}

[System.Console]::ReadKey($true)
