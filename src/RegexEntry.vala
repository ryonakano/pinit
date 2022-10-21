/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2022 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class RegexEntry : Gtk.Entry {
    /*
     * A text entry that has syntax error detection using regex.
     * Syntax errors are told 
     */

    // The pattern used to detect syntax errors
    public GLib.Regex pattern { get; construct; }

    /*
     * Whether `this` entry treats syntax errors as fatal.
     * If this value is set to `true`, `this` notifies syntax errors as warnings
     * and don't block saving the desktop file currently open.
     */
    public bool is_strict { get; construct; }

    /*
     * Whether texts in `this` entry match `pattern`.
     * This value is set automatically when texts in `this` changed and should not be overwritten manually.
     * If this value is set to `false`, block saving the desktop file currently open.
     */
    public bool is_valid { get; private set; default = false; }

    public class RegexEntry (GLib.Regex pattern, bool is_strict = true) {
        Object (
            pattern: pattern,
            is_strict: is_strict
        );
    }

    construct {
        // Check syntax errors and update style when texts in `this` entry changed
        buffer.notify["text"].connect (() => {
            if (buffer.text == "") {
                get_style_context ().remove_class ("success");
                get_style_context ().remove_class ("warning");
                get_style_context ().remove_class ("error");
                is_valid = false;

                return;
            }

            if (pattern.match (buffer.text)) {
                /*
                 * Texts in `this` entry match `pattern`,
                 * so add "success" style and unblock saving.
                 */
                get_style_context ().remove_class ("warning");
                get_style_context ().remove_class ("error");
                get_style_context ().add_class ("success");
                is_valid = true;

                return;
            }

            if (!is_strict) {
                /*
                 * Texts in `this` entry don't match `pattern` but `is_strict` is set not to treat it as fatal,
                 * so add "warning" style and unblock saving.
                 */
                get_style_context ().remove_class ("success");
                get_style_context ().remove_class ("error");
                get_style_context ().add_class ("warning");
                is_valid = true;

                return;
            }

            /*
             * Texts in `this` entry don't match `pattern` and `is_strict` is set to treat it as fatal,
             * so add "error" style and block saving.
             */
            get_style_context ().remove_class ("success");
            get_style_context ().remove_class ("warning");
            get_style_context ().add_class ("error");
            is_valid = false;
        });
    }
}
