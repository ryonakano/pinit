/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

/**
 * A class to store data in a single desktop file.
 *
 * The properties in this class correspond the key names in a desktop file.
 * A typical example of a desktop file that this class expects looks like this:
 *
 * {{{
 * [Desktop Entry]
 * Name=SuperTux
 * Comment=A jump-and-run game starring Tux the Penguin
 * Exec=/home/ryonakano/Downloads/SuperTux-v0.6.3.glibc2.29-x86_64.AppImage
 * Icon=/home/ryonakano/Downloads/supertux2.svg
 * Categories=Video;Audio;Graphics;AudioVideo;Game;
 * StartupWMClass=supertux
 * Type=Application
 * Terminal=true
 * }}}
 */
public class DesktopFile : GLib.Object {
    /**
     * The filename of a desktop file.
     */
    public string file_name { get; construct; }
    /**
     * "Name" section in the desktop file.
     */
    public string app_name { get; construct; }
    /**
     * "Comment" section in the desktop file.
     */
    public string comment { get; construct; }
    /**
     * "Exec" section in the desktop file.
     */
    public string exec_file { get; construct; }
    /**
     * "Icon" section in the desktop file.
     */
    public string icon_file { get; construct; }
    /**
     * "Categories" section in the desktop file.
     */
    public string categories { get; construct; }
    /**
     * "StartupWMClass" section in the desktop file.
     */
    public string startup_wm_class { get; construct; }
    /**
     * "Terminal" section in the desktop file.
     */
    public bool is_cli { get; construct; }

    /**
     * Whether this is a backup file.
     *
     * This property doesn't appear in the desktop file; used internally in this app.
     */
    public bool is_backup { get; construct; }

    /**
     * The constructor.
     */
    public DesktopFile (
        string file_name = "",
        string app_name = "",
        string comment = "",
        string exec_file = "",
        string icon_file = "",
        string categories = "",
        string startup_wm_class = "",
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
            startup_wm_class: startup_wm_class,
            is_cli: is_cli,
            is_backup: is_backup
        );
    }
}
