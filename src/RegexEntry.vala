/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2022 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class RegexEntry : Gtk.Entry {
    public GLib.Regex pattern { get; construct; }
    public bool is_strict { get; construct; }
    public bool is_valid { get; private set; default = false; }

    public class RegexEntry (GLib.Regex pattern, bool is_strict = true) {
        Object (
            pattern: pattern,
            is_strict: is_strict
        );
    }

    construct {
        buffer.notify["text"].connect (() => {
            if (buffer.text == "") {
                get_style_context ().remove_class ("success");
                get_style_context ().remove_class ("warning");
                get_style_context ().remove_class ("error");
                is_valid = false;
            } else if (pattern.match (buffer.text)) {
                get_style_context ().remove_class ("warning");
                get_style_context ().remove_class ("error");
                get_style_context ().add_class ("success");
                is_valid = true;
            } else if (!is_strict) {
                get_style_context ().remove_class ("success");
                get_style_context ().remove_class ("error");
                get_style_context ().add_class ("warning");
                is_valid = true;
            } else {
                get_style_context ().remove_class ("success");
                get_style_context ().remove_class ("warning");
                get_style_context ().add_class ("error");
                is_valid = false;
            }
        });
    }
}
