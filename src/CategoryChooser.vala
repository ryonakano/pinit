/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2022 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class CategoryChooser : Gtk.Grid {
    /*
     * List Categories of the app and highlight ones listed in the desktop file.
     */

    /*
     * A signal emitted when selected categories are changed.
     */
    public signal void toggled ();

    /*
     * Set/get selected categories.
     */
    public string selected {
        /*
         * Reflect the selected categories in the UI into the desktop file.
         */
        owned get {
            string _selected = "";

            /*
             * Each category has a button as an interface.
             * If a button is active, that means that category is selected,
             * so we add the name of that category in the Categories section
             * in the desktop file.
             */
            foreach (var toggle in toggles) {
                if (toggle.active) {
                    _selected += "%s;".printf (toggle.category);
                }
            }

            return _selected;
        }

        /*
         * Read the listed categories the Categories section of the desktop file,
         * and reflect them in the UI.
         */
        set {
            string[] categories = value.split (";");

            foreach (var toggle in toggles) {
                // Clear the current selection
                toggle.active = false;

                foreach (var category in categories) {
                    if (toggle.category == category) {
                        /*
                         * Detected the key name of the toggle button listed in the Categories section of the desktop file!
                         */
                        toggle.active = true;

                        /*
                         * We find the category matching, so no longer need the rest loop.
                         */
                        continue;
                    }
                }
            }
        }
    }

    /*
     * Store all of the toggle buttons in this section.
     */
    private Gee.ArrayList<ToggleButton> toggles;

    /*
     * Store translatable label texts of the toggle buttons, whose keys are
     * the category name listed in the Categories section of the desktop file.
     */
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

        /*
         * Set translatable label texts of the toggle buttons
         * where the key name is the one used in the desktop file
         * as the category name.
         */
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
            /*
             * Create and append a button for each category
             */
            var toggle = new ToggleButton (entry.key, entry.value);
            toggle.toggled.connect (() => {
                /*
                 * When the button toggled, highlight/unhighlight it
                 * depends on if it's currently highlight or not.
                 */
                if (toggle.active) {
                    toggle.get_style_context ().add_class ("accent");
                } else {
                    toggle.get_style_context ().remove_class ("accent");
                }

                /*
                 * The selected buttons are changed, so emit the signal.
                 */
                toggled ();
            });
            toggles.add (toggle);

            /*
             * Tweak which row to append the button
             */
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
        /*
         * We want to preserve the category key name in each toggle button,
         * so extends the original Gtk.ToggleButton.
         */

        public string category { get; construct; }

        /*
         * `category` is the key name.
         * `label` is a translatable label text of the toggle button.
         */
        public ToggleButton (string category, string label) {
            Object (
                category: category,
                label: label,
                hexpand: true
            );
        }
    }
}
