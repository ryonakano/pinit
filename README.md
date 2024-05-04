# Pin It!
![App window in the light mode](data/screenshots/gnome/screenshot-light.png#gh-light-mode-only)

![App window in the dark mode](data/screenshots/gnome/screenshot-dark.png#gh-dark-mode-only)

Pin shortcuts for portable apps like raw executable files, AppImage files, etc. to the app launcher on your desktop.

Other features include:

- Edit or delete created app entries without opening the file manager
- Automatically add execution permission to the file you select

## Installation
### From Flathub (Recommended)
You can download the app from Flathub, which should make this app available for all Linux distribution:

[<img src="https://flathub.org/assets/badges/flathub-badge-en.svg" width="160" alt="Download on Flathub">](https://flathub.org/apps/com.github.ryonakano.pinit)

### From Source Code (Flatpak)
You'll need `flatpak` and `flatpak-builder` commands installed on your system.

Run `flatpak remote-add` to add Flathub remote for dependencies:

```
flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
```

To build and install, use `flatpak-builder`, then execute with `flatpak run`:

```
flatpak-builder builddir --user --install --force-clean --install-deps-from=flathub build-aux/flathub/com.github.ryonakano.pinit.Devel.yml
flatpak run com.github.ryonakano.pinit.Devel
```

### From Source Code (Native)
You'll need the following dependencies to build:

* blueprint-compiler
* libadwaita-1-dev (>= 1.5.0)
* libgee-0.8-dev
* libglib2.0-dev (>= 2.74)
* libgtk-4-dev (>= 4.10)
* meson (>= 0.58.0)
* valac

Run `meson setup` to configure the build environment and run `meson compile` to build:

```bash
meson setup builddir --prefix=/usr
meson compile -C builddir
```

To install, use `meson install`, then execute with `com.github.ryonakano.pinit`:

```bash
meson install -C builddir
com.github.ryonakano.pinit
```

## Contributing
Please refer to [the contribution guideline](CONTRIBUTING.md) if you would like to:

- submit bug reports / feature requests
- propose coding changes
- translate the project

## Get Support
Need help in use of the app? Refer to [the discussions page](https://github.com/ryonakano/pinit/discussions) to search for existing discussions or [start a new discussion](https://github.com/ryonakano/pinit/discussions/new/choose) if none is relevant.

## History
The original idea of the app is inspired from [Desktopius by Alex K](https://github.com/alexkdeveloper/dfc).
