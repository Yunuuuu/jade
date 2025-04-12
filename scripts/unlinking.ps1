# & \"$bucketsdir\\jade\\scripts\\unlinking.ps1\"
param([string]$source = $(throw "Parameter missing: -source source"))

$source = $source.TrimEnd("/").TrimEnd("\\")

if (Test-Path $source) {
    $source = Get-Item -Path $source
    # Remove the Link
    if ($source.LinkType) {
        write-host "Unlinking $source"
        # directory (junction)
        if ($source -is [System.IO.DirectoryInfo]) {
            # remove read-only attribute on the link
            attrib -R /L $source
            # remove the junction
            Remove-Item -Path $source -Recurse -Force -ErrorAction SilentlyContinue
        } else {
            # remove the hard link
            Remove-Item -Path $source -Force -ErrorAction SilentlyContinue
        }
    }
}
