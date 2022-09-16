/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2022 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class DesktopFile : GLib.Object {
    /*
     * A class to store data in a single desktop file.
     *
     * The properties in this class correspond the key names in a desktop file.
     * A typical example of a desktop file expecting in this app looks like this:
     *
     * ```
     * [Desktop Entry]
     * Name[en]=SuperTux
     * Comment[en]=A jump-and-run game starring Tux the Penguin
     * Exec=/home/ryonakano/Downloads/SuperTux-v0.6.3.glibc2.29-x86_64.AppImage
     * Icon=/home/ryonakano/Downloads/supertux2.svg
     * Categories=Video;Audio;Graphics;AudioVideo;Game;
     * StartupWMClass=supertux
     * Type=Application
     * Terminal=false
     * ```
     */

    // The filename of a desktop file
    public string file_name { get; construct; }
    // "Name" section in the desktop file in your locale
    public string app_name { get; construct; }
    // "Comment" section in the desktop file in your locale
    public string comment { get; construct; }
    // "Exec" section in the desktop file
    public string exec_file { get; construct; }
    // "Icon" section in the desktop file
    public string icon_file { get; construct; }
    // "Categories" section in the desktop file
    public string categories { get; construct; }
    // "Terminal" section in the desktop file
    public bool is_cli { get; construct; }

    // This property don't appear in the desktop file; used internally in this app
    public bool is_backup { get; construct; }

    /*
     * Set values of the properties from the passed args and it's ready;
     * we can read these properties or perform related operations through DesktopFileOperator.
     */
    public DesktopFile (
        string file_name = "",
        string app_name = "",
        string comment = "",
        string exec_file = "",
        string icon_file = "",
        string categories = "",
        bool is_cli = false,
        bool is_backup = false
    ) {
        Object (
            file_name: file_name,
            app_name: app_name,
            comment: comment,
            exec_file: exec_file,
            icon_file: icon_file,
            categories: categories,
            is_cli: is_cli,
            is_backup: is_backup
        );
    }
}
