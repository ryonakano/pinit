# Pin It!
Add portable apps like raw executable files, AppImage files, etc. into the app launcher of your desktop environment.

![Files View](data/screenshots/screenshot-files-view.png)

![Edit View](data/screenshots/screenshot-edit-view.png)

Other features include:

- Edit or delete created app entries without opening the file manager
- Syntax error detection
- Automatically save everything―your data in editing, last open view, and preferences

The original idea of the app is inspired from https://github.com/alexkdeveloper/dfc.

## Installation
### For Users
You can download the app from Flathub, which should make this app available for all Linux distribution:

[<img src="https://flathub.org/assets/badges/flathub-badge-en.svg" width="160" alt="Download on Flathub">](https://flathub.org/apps/details/com.github.ryonakano.pinit)

### For Developers
You'll need the following dependencies to build:

* libgee-0.8-dev
* libgtk4-dev
* libadwaita-1-dev
* meson (>= 0.57.0)
* valac

Run `meson build` to configure the build environment. Change to the build directory and run `ninja` to build

    meson build --prefix=/usr
    cd build
    ninja

To install, use `ninja install`, then execute with `com.github.ryonakano.pinit`

    ninja install
    com.github.ryonakano.pinit
