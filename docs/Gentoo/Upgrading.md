# Upgrading my Gentoo system

```
eix --installed-from-overlay hyproverlay '-*' --format '<category>/<name>::hyproverlay ~*\n' | sudo tee /etc/portage/package.accept_keywords/hyprland
```
