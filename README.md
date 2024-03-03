<div align="center">
  <img src="data/icons/64/com.github.ryonakano.pinit.svg">
  <h1>Pin It!</h1>
  <p>Pin portable apps to the launcher</p>
</div>

![Overview of the app](data/screenshots/overview.png)

Pin shortcuts for portable apps like raw executable files, AppImage files, etc. to the app launcher on your desktop.

Other features include:

- Edit or delete created app entries without opening the file manager
- Automatically add execution permission to the file you select

The original idea of the app is inspired from https://github.com/alexkdeveloper/dfc.

## Installation
### For Users
You can download the app from Flathub, which should make this app available for all Linux distribution:

[<img src="https://flathub.org/assets/badges/flathub-badge-en.svg" width="160" alt="Download on Flathub">](https://flathub.org/apps/details/com.github.ryonakano.pinit)

### For Developers
You'll need the following dependencies to build:

* libadwaita-1-dev (>= 1.4.0)
* libgee-0.8-dev
* libglib2.0-dev (>= 2.74)
* libgtk-4-dev (>= 4.10)
* meson (>= 0.57.0)
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
