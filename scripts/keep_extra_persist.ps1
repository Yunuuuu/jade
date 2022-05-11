# \"$bucketsdir\\jade\\scripts\\keep_extra_persist.ps1\"
param(
    [string]$extra_persist = $(throw "Parameter missing: -extra_persist extra_persist"),
    [string]$name = $(Split-Path -Path $extra_persist -Leaf)
)

function is_directory([String] $path) {
    return (Test-Path $path) -and (Get-Item $path) -is [System.IO.DirectoryInfo]
}

function ensure($dir) { if (!(test-path $dir)) { new-item -type directory $dir > $null }; resolve-path $dir }
function fullpath($path) {
    # should be ~ rooted
    $executionContext.sessionState.path.getUnresolvedProviderPathFromPSPath($path)
}

write-host "Persisting $extra_persist"

$source = $extra_persist.TrimEnd("/").TrimEnd("\\")

$source = fullpath "$source"
$target = fullpath "$persist_dir\$name"

# if we have had persist data in the store, just create link and go
if (Test-Path $target) {
    # if there is also a source data, rename it (to keep a original backup)
    if (Test-Path $source) {
        Move-Item -Force $source "$source.original"
    }
    # we don't have persist data in the store, move the source to target, then create link
} elseif (Test-Path $source) {
    # ensure target parent folder exist
    ensure (Split-Path -Path $target) | Out-Null
    Move-Item $source $target
    # we don't have neither source nor target data! we need to create an empty target,
    # but we can't make a judgement that the data should be a file or directory...
    # so we create a directory by default. to avoid this, use pre_install
    # to create the source file before persisting (DON'T use post_install)
} else {
    # new-item -type File $target
    $target = New-Object System.IO.DirectoryInfo($target)
    ensure $target | Out-Null
}

# create link
if (is_directory $target) {
    # target is a directory, create junction
    New-Item -Path $source -ItemType Junction -Target $target | Out-Null
    attrib $source +R /L
} else {
    # target is a file, create hard link
    New-Item -Path $source -ItemType HardLink -Target $target | Out-Null
}
