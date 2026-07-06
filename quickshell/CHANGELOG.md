# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - 2026-05-15

First stable release of quickshell — a modular, customizable desktop shell
configuration built with QuickShell and QtQuick for Wayland compositors.

### Added

- Modular shell architecture with a clean separation between `components/`,
  `modules/`, and `services/`
- Bar / status bar module with workspace indicators, system tray, and clock
- Control Center with audio, network, Bluetooth, and power profile controls
- Dashboard overlay with at-a-glance system information
- Application launcher integration
- Notification system with configurable popup width, visibility limit, and timeout
- OSD (On-Screen Display) for volume and brightness changes
- pywal integration for dynamic theme generation from wallpaper colours
- `shell.json` user configuration API for appearance, font, and module settings
- Services layer for audio (PipeWire / wireplumber / pamixer / playerctl),
  network (NetworkManager), Bluetooth (bluez), and battery / power profiles (upower)
- Wayland screenshot support via grim and slurp
- Display brightness control via brightnessctl
- `setup.sh` — automated dependency checking, QuickShell availability validation,
  and pywal verification
- `reload-quickshell.sh` — safe shell restart helper without full session reload

### Requirements

- QuickShell v0.2 or later
- Qt 6.10 or later
- Sway

---

<!-- New releases go above this line -->
