/*
 * Copyright 2021 Ryo Nakano
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class CategoryChooser : Gtk.Grid {
    public signal void toggled ();

    private string _selected;
    public string selected {
        get {
            _selected = "";
            foreach (var toggle in toggles) {
                if (toggle.active) {
                    _selected += "%s;".printf (toggle.label);
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

    private const string CSS_DATA = """
.toggle {
    margin-right: 6px;
    background: #d4d4d4;
    color: #1a1a1a;
    transition: 1s;
}
.toggle:checked {
    margin-right: 6px;
    background: #206b00;
    color: #fafafa;
    transition: 1s;
}
    """;

    private Gee.ArrayList<ToggleButton> toggles;
    private Gee.HashMap<string, string> categories;

    public CategoryChooser () {
        Object (
            expand: true
        );
    }

    construct {
        var cssprovider = new Gtk.CssProvider ();
        try {
            cssprovider.load_from_data (CSS_DATA, -1);
            Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (),
                                                        cssprovider,
                                                        Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        } catch (Error e) {
            warning (e.message);
        }

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
