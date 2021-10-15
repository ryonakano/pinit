/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class DesktopFile : GLib.Object {
    public string file_name { get; construct; }
    public string app_name { get; construct; }
    public string comment { get; construct; }
    public string exec_file { get; construct; }
    public string icon_file { get; construct; }
    public string categories { get; construct; }
    public bool is_cli { get; construct; }

    public DesktopFile (
        string file_name = "",
        string app_name = "",
        string comment = "",
        string exec_file = "",
        string icon_file = "",
        string categories = "",
        bool is_cli = false
    ) {
        Object (
            file_name: file_name,
            app_name: app_name,
            comment: comment,
            exec_file: exec_file,
            icon_file: icon_file,
            categories: categories,
            is_cli: is_cli
        );
    }
}
