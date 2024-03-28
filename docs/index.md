Pin It! allows you to easily create shortcut entry of your favorite portable apps to the app launcher.
It respects [Desktop Entry Specification by freedesktop.org](https://specifications.freedesktop.org/desktop-entry-spec/desktop-entry-spec-latest.html).

Here are the descriptions of what each field in the app does and which key in the specification it corresponds.

## Required Fields
### App Name
![screenshot of the app name field](images/app-name.png)

The name of your app.

The text you specified would be shown in the launcher or dock.

- Key name in Desktop Entry Specification: `Name`

### Exec File
![screenshot of the exec name field](images/exec-file.png)

The command/app launched when you click the app entry in the launcher. Specify in an absolute path or an app's alias name.

You can use the right button to navigate and select your app instead of specifying the path manually.

- Key name in Desktop Entry Specification: `Exec`

## Optional Fields
### Icon File
![screenshot of the icon file field](images/icon-file.png)

The icon branding the app. Specify in an absolute path or an icon's alias name.

You can use the right button to navigate and select your favorite icon. ICO, PNG, SVG, and XMP files are supported.

The icon you specified would be shown in the app launcher or dock.

- Key name in Desktop Entry Specification: `Icon`

### Generic Name
![screenshot of the generic name field](images/generic-name.png)

Generic name of the app, for example "Web Browser" or "Mail Client". This text is used in some desktop environment like KDE.

<!-- TODO Screenshot -->

- Key name in Desktop Entry Specification: `GenericName`

### Comment
![screenshot of the comment field](images/comment.png)

Descibes the app. May appear as a tooltip when you hover over the app entry in the launcher/dock.

- Key name in Desktop Entry Specification: `Comment`

### Categories
![screenshot of the categories field](images/categories.png)

Categories applicable to the app. App launchers that groups follows this selection.

- Key name in Desktop Entry Specification: `Categories`

### Keywords
![screenshot of the keywords field](images/keywords.png)

Words that can be used to search your app in the app launcher.

- Key name in Desktop Entry Specification: `Keywords`

## Advanced Configurations
### Startup WM Class
![screenshot of the startup WM class field](images/startup-wm-class.png)

Associate the app with a window that has this ID. Use this if a different or duplicated icon appears in the dock when the app launches. This often happens when your app is a wrapper.

- Key name in Desktop Entry Specification: `StartupWMClass`

### Run in Terminal
![screenshot of the run in terminal switch](images/run-in-terminal.png)

Whether the program runs in a terminal window.

- Key name in Desktop Entry Specification: `Treminal`
