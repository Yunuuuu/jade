# & \"$bucketsdir\\jade\\scripts\\unlinking.ps1\"
param([string]$source = $(throw "Parameter missing: -source source"))

$source = $source.TrimEnd("/").TrimEnd("\\")

# if we have had persist data in the store, just create link and go
if (Test-Path $source) {
    write-host "Unlinking $source"
    $source = (Get-Item -Path $source -Force)
    if ($source.LinkType) {
        $source_path = $source.FullName
        # directory (junction)
        if ($source -is [System.IO.DirectoryInfo]) {
            # remove read-only attribute on the link
            attrib -R /L $source_path
            # remove the junction
            Remove-Item -Path $source_path -Recurse -Force -ErrorAction SilentlyContinue
        } else {
            # remove the hard link
            Remove-Item -Path $source_path -Force -ErrorAction SilentlyContinue
        }
    }
}
