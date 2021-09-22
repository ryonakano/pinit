# Pin It!
![Welcome View](data/screenshot-1.png)

![Edit View](data/screenshot-2.png)

Pin any apps into the launcher. Inspired from https://github.com/alexkdeveloper/dfc

## Installation
### For Users
On elementary OS? Click the button to get Pin It! on AppCenter:

[![Get it on AppCenter](https://appcenter.elementary.io/badge.svg)](https://appcenter.elementary.io/com.github.ryonakano.pinit)

### For Developers
You'll need the following dependencies to build:

* libgtk-3.0-dev
* libgranite-dev (>= 6.0.0)
* meson (>=0.49.0)
* valac

Run `meson build` to configure the build environment. Change to the build directory and run `ninja` to build

    meson build --prefix=/usr
    cd build
    ninja

To install, use `ninja install`, then execute with `com.github.ryonakano.pinit`

    ninja install
    com.github.ryonakano.pinit
