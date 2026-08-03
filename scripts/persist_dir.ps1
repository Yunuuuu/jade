# & "$bucketsdir\jade\scripts\persist_dir.ps1" 'data' 'cache'
param(
    [string]$SourceDir = $dir,
    [string]$PersistDir = $persist_dir,
    [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
    [string[]]$Items = @()
)

function Ensure-Directory([string]$Path) {
    if (!(Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Ensure-ParentDirectory([string]$Path) {
    $parent = Split-Path -Parent $Path
    if ($parent) {
        Ensure-Directory $parent
    }
}

Ensure-Directory $PersistDir

foreach ($item in $Items) {
    $persistItem = Join-Path $PersistDir $item
    if (Test-Path -LiteralPath $persistItem) {
        continue
    }

    Ensure-ParentDirectory $persistItem

    $sourceItem = Join-Path $SourceDir $item
    if (Test-Path -LiteralPath $sourceItem) {
        Move-Item -LiteralPath $sourceItem -Destination $persistItem
    } else {
        New-Item -ItemType Directory -Path $persistItem | Out-Null
    }
}
