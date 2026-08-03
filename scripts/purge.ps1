# & "$bucketsdir\jade\scripts\purge.ps1" (Join-Path $env:APPDATA 'example')
param(
    [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
    [string[]]$Paths = @()
)

foreach ($path in $Paths) {
    if ([string]::IsNullOrWhiteSpace($path)) {
        continue
    }

    if (Test-Path -LiteralPath $path) {
        Write-Host "Purging data: $path"
        Remove-Item -LiteralPath $path -Recurse -Force
    }
}
