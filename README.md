# WIP notice
Loading of settings seem to work, but this plugin is still lacking documentation and finishing touches. Therefore it is considered as WIP.

# vim-configer

This plugin allows to specific settings on a per buffer basis. Kind of like local vimrc, but the settings are stored within a global or project specific vimscript file.
This file will be sourced by vim automatically, but the settings won't be applied until a buffer name or filepath match a regular expression, which is specified for each setting on creation.

## Example

Makefile rules have to be indented via tabs instead of spaces. Therefore following `noexpandtab` should be applied to all makefiles.
To register this setting for all makefiles, call `ConfigerEditConfig <file-/buffer-name glob>`.
E.g. `ConfigerEditConfig makefile`.

A new buffer will be created, where the respective settings for makefile can be entered.

```
setlocal noexpandtab
```

After saving the buffer, configer will write the settings to the respective global/project-config and applies `noexpandtab` everytime a `makefile`-buffer is read or created.

Notive: When invoking `ConfigerEditConfig makefile` again, the previously entered settings can be edited.

# Commands (so far)

- **ConfigerEditConfig** Expects a file-glob as argument. Edit an existing settings-block or creates one.
- **ConfigerDeleteConfig** Expects a file-glob as argument. Should delete the settings-block of the given glob from the global config file.
- **ConfigerReloadConfig** Reloads the global config file.

# Internal working

The buffer matching file-glob will be encoded to a function name and the given settings will be placed within the functions body.
When the global configuration is loaded, the file-glob are transformed to autocmds which invoke the respective setting-functions.
As autocmds and functions can be unloaded by Vim, whole buffer settings can be cleared and reapplied on need without any leftover settings.
