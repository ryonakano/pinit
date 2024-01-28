/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

/**
 * List Categories of the app.
 *
 * There are {@link Adw.SwitchRow} for each category and {@link Adw.SwitchRow.active} represents
 * whether the corresponding category is listed in the desktop file.
 */
public class CategoryChooser : Adw.ExpanderRow {
    /**
     * A signal emitted when selected categories are changed.
     */
    public signal void toggled ();

    /**
     * Set/get selected categories.
     */
    public string selected {
        // Reflect the selected categories in the UI to the desktop file.
        owned get {
            string _selected = "";

            /*
             * Each category has a switch row.
             * If the switch row is activated, that means that category is selected,
             * so we add the name of that category in the Categories section
             * in the desktop file.
             */
            foreach (var item in row_items) {
                if (item.row.active) {
                    _selected += "%s;".printf (item.category);
                }
            }

            return _selected;
        }

        /*
         * Read the listed categories in the Categories section of the desktop file,
         * and reflect them to the UI.
         */
        set {
            string[] categories = value.split (";");

            foreach (var item in row_items) {
                // Clear the current selection
                item.row.active = false;

                foreach (var category in categories) {
                    // The category is in the desktop file
                    if (item.category == category) {
                        item.row.active = true;
                        // We find the category matching, so no longer need the rest of the loop.
                        continue;
                    }
                }
            }
        }
    }

    /**
     * Stores all of the switch rows in this expander row.
     */
    private Gee.ArrayList<RowItem> row_items;

    /**
     * key: Category name in desktop files
     * value: Translatable button labels for each key
     */
    private Gee.HashMap<string, string> categories;

    public CategoryChooser () {
    }

    construct {
        title = _("Categories");
        subtitle = _("Categories applicable to the app. (You can select more than one.)");

        row_items = new Gee.ArrayList<RowItem> ();
        categories = new Gee.HashMap<string, string> ();

        // See https://specifications.freedesktop.org/menu-spec/menu-spec-1.0.html#category-registry
        categories.set ("AudioVideo", _("Sound & Video"));
        categories.set ("Audio", _("Audio"));
        categories.set ("Video", _("Video"));
        categories.set ("Development", _("Programming"));
        categories.set ("Education", _("Education"));
        categories.set ("Game", _("Games"));
        categories.set ("Graphics", _("Graphics"));
        categories.set ("Network", _("Internet"));
        categories.set ("Office", _("Office"));
        categories.set ("Science", _("Science"));
        categories.set ("Settings", _("Settings"));
        categories.set ("System", _("System Tools"));
        categories.set ("Utility", _("Accessories"));

        // Create and append a switch row for each category
        foreach (var entry in categories.entries) {
            var item = new RowItem (entry.key, entry.value);
            item.row.activated.connect (() => {
                toggled ();
            });
            row_items.add (item);
            add_row (item.row);
        }
    }

    private class RowItem : Object {
        /*
         * We want to preserve the category key name in each switch row,
         * so wrap Adw.SwitchRow.
         */

        public string category { get; construct; }
        public string label { get; construct; }

        public Adw.SwitchRow row { get; construct; }

        public RowItem (string category, string label) {
            Object (
                category: category,
                label: label
            );
        }

        construct {
            row = new Adw.SwitchRow () {
                title = label
            };
        }
    }
}
