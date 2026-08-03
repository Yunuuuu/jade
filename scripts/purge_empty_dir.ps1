# & "$bucketsdir\jade\scripts\purge_empty_dir.ps1" (Join-Path $env:APPDATA 'Example')
param(
    [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
    [string[]]$Paths = @()
)

foreach ($path in $Paths) {
    if ([string]::IsNullOrWhiteSpace($path)) {
        continue
    }

    if ((Test-Path -LiteralPath $path -PathType Container) -and
        ($null -eq (Get-ChildItem -LiteralPath $path -Force | Select-Object -First 1))) {
        Write-Host "Removing empty directory: $path"
        Remove-Item -LiteralPath $path -Force
    }
}
