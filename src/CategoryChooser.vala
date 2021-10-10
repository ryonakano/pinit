/*
 * Copyright 2021 Ryo Nakano
 * SPDX-License-Identifier: GPL-3.0-or-later
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
                    if (toggle.label == category) {
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
            expand: true
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

        foreach (var entry in categories.entries) {
            var toggle = new ToggleButton (entry.key, entry.value);
            toggle.toggled.connect (() => {
                toggled ();
            });
            toggles.add (toggle);
            add (toggle);
        }
    }

    public class ToggleButton : Gtk.ToggleButton {
        public string category { get; construct; }

        public ToggleButton (string category, string label) {
            Object (
                category: category,
                label: label
            );
        }
    }
}
