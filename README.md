# Pin It!
Pin any apps into the launcher. Inspired from https://github.com/alexkdeveloper/dfc

![Welcome View](data/screenshot-welcome-view.png)

Add portable apps like raw executable files, AppImage files, etc. into Applications Menu easily. Edit or delete them without opening a file manager.

![Files View](data/screenshot-files-view.png)

Are you still using your text editor to create/edit your customized desktop files? Possibly you open Files and press Ctrl + H to show the hidden destination folder? Say goodbye to that life! Hit the "Edit File" in this app and it's done. All entries you created are there and you can edit or delete them.

![Edit View](data/screenshot-edit-view.png)

You surely created a desktop entry but it won't be shown in Applications Menu? Ah, you found a tiny syntax error after a couple of hours in struggle! That's too bad. Pin It! prevent saving destkop entries with any syntax error, so you will never need to waste your time.

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
