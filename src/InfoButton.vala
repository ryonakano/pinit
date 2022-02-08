/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class InfoButton : Gtk.MenuButton {
    public InfoButton () {
        Object (
            image: new Gtk.Image.from_icon_name ("dialog-information-symbolic", Gtk.IconSize.BUTTON),
            margin_start: 6,
            tooltip_text: _("Recommendations for naming")
        );
    }

    construct {
        var label = new Gtk.Label (
            _("Only use alphabets, numbers, and underscores, and none begins with numbers.") + "\n" +
            _("Use at least one period to make sure to be separated into at least two elements.")
        ) {
            halign = Gtk.Align.START
        };

        var detailed_label = new Gtk.Label (
            _("For more info, see %s.").printf (
            "<a href=\"https://dbus.freedesktop.org/doc/dbus-specification.html#message-protocol-names-bus\">%s</a>").printf (
            _("the file naming specification by freedesktop.org")
        )) {
            use_markup = true,
            halign = Gtk.Align.START
        };

        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6) {
            margin = 12
        };
        box.pack_start (label);
        box.pack_start (detailed_label);

        var popover = new Gtk.Popover (null);
        popover.add (box);

        this.popover = popover;

        toggled.connect (() => {
            popover.show_all ();
        });
    }
}
