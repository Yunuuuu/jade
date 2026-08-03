# Personal Scoop Bucket

How do I install these manifests?
---------------------------------

To add this bucket:
```powershell
scoop bucket add jade https://github.com/Yunuuuu/jade
```

For users with network restrictions, an alternative option is to use gitee for installation.
```powershell
scoop bucket add jade https://gitee.com/yunyunp/jade
```

Install apps from this bucket:
```powershell
scoop install jade/<manifest>
```

Purge behavior
--------------

Many manifests in this bucket remove default user-data locations when an app is
uninstalled with Scoop's purge mode, for example:

```powershell
scoop uninstall -p <app>
```

This is a zap-like deep cleanup for known unportable data created outside
Scoop. It can delete profile, config, cache, credential, log, state, or updater
directories under `%APPDATA%`, `%LOCALAPPDATA%`, `%USERPROFILE%`,
`%PROGRAMDATA%`, and other common app data locations. Data already covered by
Scoop `persist` is handled by Scoop itself. Back up any data you want to keep
before purging.
