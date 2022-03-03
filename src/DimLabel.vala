/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2022 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class DimLabel : Gtk.Label {
    public DimLabel (string label) {
        Object (label: label);
    }

    construct {
        halign = Gtk.Align.START;
        margin_bottom = 6;
        get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);
    }
}
