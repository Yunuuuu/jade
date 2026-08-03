# Repository Instructions

## Scoop Manifest Formatting

These rules apply to Scoop manifests in `bucket/*.json` and `deprecated/*.json`.
Do not apply them to non-manifest JSON files such as `.markdownlint.json`.

Run the Scoop formatter after changing manifests:

```powershell
.\bin\formatjson.ps1
```

For `deprecated/*.json`, call Scoop's formatter directly with `-Dir deprecated`.

Use 4 spaces for manifest indentation. PowerShell script lines inside manifest
script fields must also use 4-space indentation levels, with no tabs. This
applies to `pre_install`, `post_install`, `pre_uninstall`, `post_uninstall`,
and nested `script` arrays such as `installer.script`, `uninstaller.script`, and
`checkver.script`. Do not reindent prose-only fields such as `notes` just
because they contain aligned text.

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
