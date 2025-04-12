# & \"$bucketsdir\\jade\\scripts\\unlinking.ps1\"
param([string]$source = $(throw "Parameter missing: -source source"))

$source = $source.TrimEnd("/").TrimEnd("\")

if (Test-Path $source) {
    $sourceItem = Get-Item -LiteralPath $source -Force
    if ($sourceItem.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
        Write-Host "Unlinking $source"
        
        # Remove ReadOnly if set
        if ($sourceItem.Attributes -band [System.IO.FileAttributes]::ReadOnly) {
            $sourceItem.Attributes = $sourceItem.Attributes -band -bnot [System.IO.FileAttributes]::ReadOnly
        }

        Remove-Item -LiteralPath $source -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Successfully unlinked: $source"
    } else {
        Write-Host "Not a symbolic link or junction: $source"
    }
} else {
    Write-Host "Path not found: $source"
}
