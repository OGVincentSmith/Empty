param(
    [Parameter(Mandatory=$true)]
    [string]$RootPath
)

if (-not (Test-Path $RootPath)) {
    Write-Error "Target folder not found: $RootPath"
    exit
}

Clear-Host
Write-Host "Initializing Credential Sanitization Module..." -ForegroundColor Cyan
Start-Sleep -Milliseconds 800

$files = Get-ChildItem -Path $RootPath -Recurse -Filter "şifreler.md" -File -ErrorAction SilentlyContinue

if ($files.Count -eq 0) {
    Write-Host "No şifreler.md files found." -ForegroundColor Yellow
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

    Write-Progress -Activity "Scanning directories..." `
                   -Status "Processing: $($file.FullName)" `
                   -PercentComplete $percent

    $lines = Get-Content $file.FullName

    for ($i = 0; $i -lt $lines.Count; $i++) {

        if ($lines[$i] -match "^\s*Password:\s*(.+)$") {

            $length = $Matches[1].Length
            $newPass = -join (1..$length | ForEach-Object {
                $chars[$random.Next(0, $chars.Length)]
            })

            $lines[$i] = "Password: $newPass"
        }

        elseif ($i -gt 0 -and $lines[$i-1] -match "^\s*DHL\s*$" -and $lines[$i] -match "^\S+$") {

            $length = $lines[$i].Length
            $newPass = -join (1..$length | ForEach-Object {
                $chars[$random.Next(0, $chars.Length)]
            })

            $lines[$i] = $newPass
        }
    }

    Set-Content -Path $file.FullName -Value $lines
    $modifiedCount++
}

Write-Progress -Activity "Scanning directories..." -Completed

Write-Host "Pst can't be fixed"
