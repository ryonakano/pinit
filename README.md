# Pin It!
Add portable apps like raw executable files, AppImage files, etc. into the app launcher of your desktop environment.

![Welcome View](data/screenshots/pantheon/screenshot-welcome-view.png)

![Edit View](data/screenshots/pantheon/screenshot-edit-view.png)

Other features include:

- Edit or delete created app entries without opening the file manager
- Syntax error detection
- Automatically save everything―your data in editing, last open view, and preferences

The app idea is inspired from https://github.com/alexkdeveloper/dfc.

## Installation
### For Users
On elementary OS? Click the button to get Pin It! on AppCenter:

[![Get it on AppCenter](https://appcenter.elementary.io/badge.svg)](https://appcenter.elementary.io/com.github.ryonakano.pinit)

You can also download the app from Flathub, in case you're using another distribution. This version is tweaked to work well and look good on other desktop environment.

[<img src="https://flathub.org/assets/badges/flathub-badge-en.svg" width="160" alt="Download on Flathub">](https://flathub.org/apps/details/com.github.ryonakano.pinit)

### For Developers
You'll need the following dependencies to build:

* libgtk-3.0-dev
* libgranite-dev (>= 6.0.0)
* libhandy-1-dev
* meson (>= 0.57.0)
* valac

Run `meson build` to configure the build environment. Change to the build directory and run `ninja` to build

    meson build --prefix=/usr
    cd build
    ninja

To install, use `ninja install`, then execute with `com.github.ryonakano.pinit`

    ninja install
    com.github.ryonakano.pinit

## Contributing
There are many ways you can contribute, even if you don't know how to code.

### Reporting Bugs or Suggesting Improvements
Simply [create a new issue](https://github.com/ryonakano/pinit/issues/new) describing your problem and how to reproduce or your suggestion. If you are not used to do, [this section](https://docs.elementary.io/contributor-guide/feedback/reporting-issues) is for you.

### Writing Some Code
We follow [the coding style of elementary OS](https://docs.elementary.io/develop/writing-apps/code-style) and [its Human Interface Guidelines](https://docs.elementary.io/hig/). Try to respect them.

### Translating This App
I accept translations through Pull Requests. If you're not sure how to do, [the guideline I made](po/README.md) might be helpful.
