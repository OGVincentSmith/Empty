param(
    [Parameter(Mandatory=$true)]
    [string]$Path
)

if (-not (Test-Path $Path)) {
    Write-Error "Dosya bulunamadı: $Path"
    Start-Sleep -Seconds 5
    exit
}

$size = (Get-Item $Path).Length

$fs = [System.IO.File]::Create($Path)
$fs.SetLength($size)
$fs.Close()

Write-Host "Unlocked: $Path"
