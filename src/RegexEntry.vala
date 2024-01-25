/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

// A text entry with syntax detection using regex.
public class RegexEntry : Gtk.Entry {
    // The syntax pattern that text in the entry should follow
    public GLib.Regex pattern { get; construct; }

    // True to treat syntax errors as fatal
    public bool is_strict { get; construct; }

    // Whether text in the entry matches `pattern`.
    public bool is_valid { get; private set; default = false; }

    public class RegexEntry (GLib.Regex pattern, bool is_strict = true) {
        Object (
            pattern: pattern,
            is_strict: is_strict
        );
    }

    construct {
        // Check syntax errors and update style when text in the entry changed
        buffer.notify["text"].connect (() => {
            if (buffer.text == "") {
                remove_css_class ("success");
                remove_css_class ("warning");
                remove_css_class ("error");
                is_valid = false;

                return;
            }

            // Text matches, OK
            if (pattern.match (buffer.text)) {
                remove_css_class ("warning");
                remove_css_class ("error");
                add_css_class ("success");
                is_valid = true;

                return;
            }

            // Text doesn't match the syntax but not fatal
            if (!is_strict) {
                remove_css_class ("success");
                remove_css_class ("error");
                add_css_class ("warning");
                is_valid = true;

                return;
            }

            // Text doesn't match the syntax, not OK
            remove_css_class ("success");
            remove_css_class ("warning");
            add_css_class ("error");
            is_valid = false;
        });
    }
}
