#!/usr/bin/env human

# System Settings

remove default icons on launcher bar

## Display:

- scale: 1.62

## Software & Update:

- automatically update: Never

## Language:

```shell
gsettings set org.gnome.desktop.interface gtk-im-module "gtk-im-context-simple"

gsettings set org.gnome.desktop.input-sources current     "uint32 0"
gsettings set org.gnome.desktop.input-sources sources     "[('xkb', 'us'), ('fcitx', 'googlepinyin')]"
gsettings set org.gnome.desktop.input-sources xkb-options "@as []"
```

- add chinese support
- input method: fcitx
- dates format: English (US)
- Apply
- logout & login
- fcitx/skin: geek-dark

# Unity Tweak Tool

## Launcher:

- auto hide: on
- icon size: 36

## Search:

- show more suggestions: close
- show recently used: close
- enable search: close

## Panel:

- transpanrency: max
- opaque panel for maximized windows: open
- date & time: 24h
- show my name: open

## Switcher:

- display show desktop icon: close
- switch between minimized windows: close
- automatically expose window: close

## Web Apps:

- integration prompts: close
- preauthorized domains: close all

## Workspace Settings:

- switcher: open
- workspaces: 2x2

## Window snapping:

- eight direction

## Security:

- printing: open
- user switching: open
