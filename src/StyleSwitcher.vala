/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2022 Ryo Nakano <ryonakaknock3@gmail.com>
 * 
 * Some code inspired from elementary/switchboard-plug-pantheon-shell, src/Views/Appearance.vala
 */

public class StyleSwitcher : Gtk.Box {
    private Adw.StyleManager style_manager;

    private StyleButton light_style_button;
    private StyleButton dark_style_button;
    private StyleButton system_style_button;

    public StyleSwitcher () {
        Object (
            orientation: Gtk.Orientation.VERTICAL,
            spacing: 6
        );
    }

    construct {
        style_manager = Adw.StyleManager.get_default ();

        var style_label = new Gtk.Label (_("Style:")) {
            halign = Gtk.Align.START
        };

        var buttons_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        buttons_box.get_style_context ().add_class ("linked");

        light_style_button = new StyleButton ("display-brightness-symbolic", _("Light"));
        light_style_button.toggled.connect (() => {
            set_app_style (Adw.ColorScheme.FORCE_LIGHT);
        });
        buttons_box.append (light_style_button);

        dark_style_button = new StyleButton ("weather-clear-night-symbolic", _("Dark"), light_style_button);
        dark_style_button.toggled.connect (() => {
            set_app_style (Adw.ColorScheme.FORCE_DARK);
        });
        buttons_box.append (dark_style_button);

        if (style_manager.system_supports_color_schemes) {
            system_style_button = new StyleButton ("emblem-system-symbolic", _("System"), light_style_button);
            system_style_button.toggled.connect (() => {
                set_app_style (Adw.ColorScheme.PREFER_LIGHT);
            });
            buttons_box.append (system_style_button);
        }

        construct_app_style ();

        append (style_label);
        append (buttons_box);
    }

    private void set_app_style (Adw.ColorScheme color_scheme) {
        Application.settings.set_enum ("color-scheme", color_scheme);
        style_manager.color_scheme = color_scheme;
    }

    private void construct_app_style () {
        switch (Application.settings.get_enum ("color-scheme")) {
            case Adw.ColorScheme.PREFER_LIGHT:
                system_style_button.active = true;
                break;
            case Adw.ColorScheme.FORCE_DARK:
                dark_style_button.active = true;
                break;
            case Adw.ColorScheme.FORCE_LIGHT:
                light_style_button.active = true;
                break;
        }
    }

    private class StyleButton : Gtk.ToggleButton {
        public new string icon_name { get; construct; }
        public string label_text { get; construct; }

        public StyleButton (string icon_name, string label_text, Gtk.ToggleButton? group = null) {
            Object (
                icon_name: icon_name,
                label_text: label_text,
                group: group
            );
        }

        construct {
            var button_content = new Gtk.Box (Gtk.Orientation.VERTICAL, 3);
            button_content.append (new Gtk.Image.from_icon_name (icon_name));
            button_content.append (new Gtk.Label (label_text));

            child = button_content;
            can_focus = false;
        }
    }
}
