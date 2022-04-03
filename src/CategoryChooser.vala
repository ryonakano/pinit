/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2022 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class CategoryChooser : Gtk.Grid {
    public signal void toggled ();

    public string selected {
        owned get {
            string _selected = "";
            foreach (var toggle in toggles) {
                if (toggle.active) {
                    _selected += "%s;".printf (toggle.category);
                }
            }

            return _selected;
        }

        set {
            string[] categories = value.split (";");
            foreach (var toggle in toggles) {
                toggle.active = false;

                foreach (var category in categories) {
                    if (toggle.category == category) {
                        toggle.active = true;
                        continue;
                    }
                }
            }
        }
    }

    private Gee.ArrayList<ToggleButton> toggles;
    private Gee.HashMap<string, string> categories;

    public CategoryChooser () {
        Object (
            column_spacing: 6,
            row_spacing: 6
        );
    }

    construct {
        toggles = new Gee.ArrayList<ToggleButton> ();
        categories = new Gee.HashMap<string, string> ();

        categories.set ("AudioVideo", _("Audio & Video"));
        categories.set ("Audio", _("Audio"));
        categories.set ("Video", _("Video"));
        categories.set ("Development", _("Development"));
        categories.set ("Education", _("Education"));
        categories.set ("Game", _("Game"));
        categories.set ("Graphics", _("Graphics"));
        categories.set ("Network", _("Network"));
        categories.set ("Office", _("Office"));
        categories.set ("Science", _("Science"));
        categories.set ("Settings", _("Settings"));
        categories.set ("System", _("System"));
        categories.set ("Utility", _("Utility"));

        int i = 0;
        int j = 0;
        foreach (var entry in categories.entries) {
            var toggle = new ToggleButton (entry.key, entry.value);
            toggle.toggled.connect (() => {
                if (toggle.active) {
                    toggle.get_style_context ().add_class ("accent");
                } else {
                    toggle.get_style_context ().remove_class ("accent");
                }

                toggled ();
            });
            toggles.add (toggle);

            if (i % 7 == 0) {
                // attach in the next row
                j++;
                i = 0;
            }

            attach (toggle, i, j, 1, 1);
            i++;
        }
    }

    public class ToggleButton : Gtk.ToggleButton {
        public string category { get; construct; }

        public ToggleButton (string category, string label) {
            Object (
                category: category,
                label: label,
                hexpand: true
            );
        }
    }
}
