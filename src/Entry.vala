/*
 * Copyright 2021 Ryo Nakano
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Entry : Gtk.Entry {
    construct {
        expand = true;

        notify["text"].connect (() => {
            if (text == "") {
                set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, null);
            } else {
                set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "edit-clear-symbolic");
            }
        });

        icon_press.connect ((pos, event) => {
            if (pos == Gtk.EntryIconPosition.SECONDARY) {
                text = "";
            }
        });    
    }
}
