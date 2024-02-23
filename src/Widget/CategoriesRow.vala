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
public class Widget.CategoriesRow : Adw.ExpanderRow {
    /**
     * A signal emitted when categories are changed.
     */
    public signal void categories_changed ();

    /**
     * Categories of the app.
     */
    public string[] categories {
        owned get {
            string[] _categories = {};

            /*
             * Each category has a switch row.
             * If the switch row is activated, that means that category is selected,
             * so we add the name of that category in the Categories section
             * in the desktop file.
             */
            foreach (var item in row_items) {
                if (item.row.active) {
                    _categories += item.category;
                }
            }

            return _categories;
        }

        /*
         * Read the listed categories in the Categories section of the desktop file,
         * and reflect them to the UI.
         */
        set {
            foreach (var item in row_items) {
                // Clear the current selection
                item.row.active = false;

                foreach (var category in value) {
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
    private Gee.HashMap<string, string> categories_table;

    public CategoriesRow () {
    }

    construct {
        title = _("Categories");
        subtitle = _("Categories applicable to the app. (You can select more than one.)");

        row_items = new Gee.ArrayList<RowItem> ();
        categories_table = new Gee.HashMap<string, string> ();

        // See https://specifications.freedesktop.org/menu-spec/menu-spec-1.0.html#category-registry
        categories_table.set ("AudioVideo", _("Sound & Video"));
        categories_table.set ("Audio", _("Audio"));
        categories_table.set ("Video", _("Video"));
        categories_table.set ("Development", _("Programming"));
        categories_table.set ("Education", _("Education"));
        categories_table.set ("Game", _("Games"));
        categories_table.set ("Graphics", _("Graphics"));
        categories_table.set ("Network", _("Internet"));
        categories_table.set ("Office", _("Office"));
        categories_table.set ("Science", _("Science"));
        categories_table.set ("Settings", _("Settings"));
        categories_table.set ("System", _("System Tools"));
        categories_table.set ("Utility", _("Accessories"));

        // Create and append a switch row for each category
        foreach (var entry in categories_table.entries) {
            var item = new RowItem (entry.key, entry.value);
            item.row.notify["active"].connect (() => {
                categories_changed ();
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
