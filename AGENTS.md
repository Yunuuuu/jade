# Repository Instructions

## Scoop Manifest Formatting

These rules apply to Scoop manifests in `bucket/*.json` and `deprecated/*.json`.
Do not apply them to non-manifest JSON files such as `.markdownlint.json`.

Run the Scoop formatter after changing manifests:

```powershell
.\bin\formatjson.ps1
```

For `deprecated/*.json`, call Scoop's formatter directly with `-Dir deprecated`.

Use 4 spaces for JSON indentation in every manifest. PowerShell script lines
inside manifest script fields must also use 4-space indentation levels, with no
tabs. This applies to `pre_install`, `post_install`, `pre_uninstall`,
`post_uninstall`, and nested `script` arrays such as `installer.script`,
`uninstaller.script`, and `checkver.script`. Do not reindent prose-only fields
such as `notes` just because they contain aligned text.

### Key Order

Order non-`architecture` keys by the effective manifest phase at the same
object level:

```text
$schema, ##, _comment,
version, description, homepage, license,
notes, suggest, depends,
cookie,
url, hash,
extract_dir, extract_to, innosetup,
pre_install, installer,
bin, shortcuts, psmodule,
env_add_path, env_set, persist,
post_install,
pre_uninstall, uninstaller, post_uninstall,
checkver, autoupdate
```

Nested manifest-like objects use the same phase order unless a narrower order is
listed below.

### Architecture Placement

`architecture` is a wrapper for architecture-specific manifest fields. Do not
place it by a fixed top-level slot such as "before extract_dir" or "after hash".

When deciding where an `architecture` object belongs in its parent object,
derive its position from the nested fields:

1. Inspect the child objects under architecture names such as `64bit`, `32bit`,
   `arm64`, or custom architecture names.
2. Find the earliest recognized key used by those child objects.
3. Place the `architecture` wrapper where that key would appear in the parent
   object.
4. If the parent also has that exact direct key, keep the direct key first, then
   `architecture`.
5. Keep architecture name order unchanged.

Examples:

```text
url/hash in architecture children, no direct parent url:
architecture, extract_dir, pre_install

url/hash in architecture children, with direct parent url:
url, architecture, hash, extract_dir

pre_install/bin in architecture children:
url, hash, extract_dir, architecture, installer

only bin/shortcuts in architecture children:
installer, architecture, env_add_path

autoupdate architecture children with url plus direct parent hash:
architecture, hash
```

Inside each architecture child, use this order:

```text
cookie,
url, hash,
extract_dir, extract_to, innosetup,
pre_install, installer,
bin, shortcuts, psmodule,
env_add_path, env_set, persist,
post_install,
pre_uninstall, uninstaller, post_uninstall,
checkver
```

### Autoupdate

Inside `autoupdate`, order non-`architecture` keys as follows. If
`autoupdate.architecture` is present, place it dynamically using the same nested
field rule described above.

```text
url, hash,
extract_dir, extract_to,
installer,
bin, shortcuts, psmodule,
env_add_path, env_set, persist,
license, notes
```

Inside `autoupdate.architecture.<arch>`, use this order:

```text
url, hash,
extract_dir, extract_to,
installer,
bin, shortcuts, psmodule,
env_add_path, env_set, persist,
license, notes
```

### Other Nested Objects

Use these orders for specialized nested objects:

```text
installer: _comment, file, args, keep, script
uninstaller: file, args, script
checkver: github, sourceforge, url, useragent, script, jsonpath, jp, xpath, regex, re, reverse, replace
hash extraction: url, mode, jsonpath, jp, xpath, regex, find, type
license: identifier, url
psmodule: name
```

### Persist Initialization

Every manifest with `persist` must initialize persisted items from
`installer.script` before Scoop links persisted data.

Use these helpers for the common initialization logic:

```powershell
& "$bucketsdir\jade\scripts\persist_file.ps1" 'config.json' 'settings.json'
& "$bucketsdir\jade\scripts\persist_dir.ps1" 'data' 'cache'
```

The helpers accept any number of persisted item paths as positional arguments.
Pass items directly as positional arguments; do not create `@(...)` arrays only
to pass item lists to these helpers. For long item lists, split the command over
multiple script lines with PowerShell line continuation.

Both helpers must ensure `$persist_dir` exists. For each persisted file, if the
target file in `$persist_dir` does not exist, `persist_file.ps1` must move the
package copy from `$dir` when present; otherwise it must create an empty file in
`$persist_dir`. For each persisted directory, if the target directory in
`$persist_dir` does not exist, `persist_dir.ps1` must move the package copy from
`$dir` when present; otherwise it must create the directory in `$persist_dir`.

### Default Data Purge

Do not copy or move data from default user-data locations outside Scoop into
`$persist_dir`. Treat Scoop purge as a zap-like deep cleanup of data created by
this package, but do not manually purge paths already made portable through
Scoop `persist`; Scoop purge handles persisted data itself.

Some apps can only be made partially portable. If the app still automatically
creates unportable data outside Scoop, especially under `%APPDATA%` or
`%LOCALAPPDATA%`, remove those known app-created locations from
`post_uninstall` guarded by Scoop's `$purge` behavior. Purge paths may include
default profile, config, cache, credential, log, state, or updater directories.

Avoid broad parent directories unless they are removed only when empty. Do not
purge user-created documents, download folders, project workspaces, libraries,
or other paths that are not clearly app-created by this package.

Use this helper for common purge cleanup:

```powershell
if ($purge) {
    & "$bucketsdir\jade\scripts\purge.ps1" (Join-Path $env:APPDATA 'Example')
}
```

`purge.ps1` accepts any number of positional paths and removes them directly.
It must not check `$purge` internally; callers must invoke it only from an
`if ($purge)` block. Pass paths directly as positional arguments; do not create
`@(...)` arrays only for the helper path list.

When purging nested app data can leave empty vendor or XDG parent directories,
remove those parents with:

```powershell
if ($purge) {
    & "$bucketsdir\jade\scripts\purge_empty_dir.ps1" (Join-Path $env:APPDATA 'Vendor')
}
```

`purge_empty_dir.ps1` follows the same caller-guarded `$purge` rule and must
remove only existing empty directories.
