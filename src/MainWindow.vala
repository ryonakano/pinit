/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class MainWindow : Hdy.Window {
    private uint configure_id;

    private WelcomeView welcome_view;
    private FilesView files_view;
    private EditView edit_view;
    private Hdy.Deck deck;
    private Gtk.ToolButton home_button;
    private Hdy.HeaderBar header_bar;

    private enum Views {
        WELCOME_VIEW,
        EDIT_VIEW,
        FILES_VIEW;
    }

    public MainWindow () {
        Object (
            title: "Pin It!",
            resizable: false
        );
    }

    construct {
        Hdy.init ();

        var cssprovider = new Gtk.CssProvider ();
        cssprovider.load_from_resource ("/com/github/ryonakano/pinit/Application.css");
        Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (),
                                                    cssprovider,
                                                    Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

#if !FOR_PANTHEON
        var extra_cssprovider = new Gtk.CssProvider ();
        extra_cssprovider.load_from_resource ("/com/github/ryonakano/pinit/Extra.css");
        Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (),
                                                    extra_cssprovider,
                                                    Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
#endif

        welcome_view = new WelcomeView ();
        files_view = new FilesView ();
        edit_view = new EditView ();

        deck = new Hdy.Deck () {
            can_swipe_back = true,
            transition_type = Hdy.DeckTransitionType.SLIDE
        };
        deck.add (welcome_view);
        deck.add (files_view);
        deck.add (edit_view);

        var overlay = new Gtk.Overlay ();
        overlay.add (deck);

        var toast = new Granite.Widgets.Toast (_("Saved changes!"));
        overlay.add_overlay (toast);

        var home_image = new Gtk.Image.from_icon_name ("go-home", Gtk.IconSize.SMALL_TOOLBAR);
        home_button = new Gtk.ToolButton (home_image, null) {
            tooltip_markup = Granite.markup_accel_tooltip ({"<Alt>Home"}, _("Create new or edit"))
        };

        var preferences_grid = new Gtk.Grid () {
            margin = 12,
            column_spacing = 6,
            row_spacing = 6
        };
        preferences_grid.attach (new StyleSwitcher (), 0, 0);

        var preferences_button = new Gtk.ToolButton (
            new Gtk.Image.from_icon_name ("open-menu", Gtk.IconSize.LARGE_TOOLBAR), null
        ) {
            tooltip_text = _("Preferences")
        };

        var preferences_popover = new Gtk.Popover (preferences_button);
        preferences_popover.add (preferences_grid);

        preferences_button.clicked.connect (() => {
            preferences_popover.show_all ();
        });

        header_bar = new Hdy.HeaderBar () {
            show_close_button = true,
            has_subtitle = false,
        };
        header_bar.pack_start (home_button);
        header_bar.pack_end (preferences_button);

        unowned var header_bar_style = header_bar.get_style_context ();
        header_bar_style.add_class (Gtk.STYLE_CLASS_FLAT);
        header_bar_style.add_class (Granite.STYLE_CLASS_DEFAULT_DECORATION);

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.add (header_bar);
        main_box.add (overlay);

        add (main_box);
        set_visible_view ();
        show_all ();

        home_button.clicked.connect (() => {
            show_welcome_view ();
        });

        DesktopFileOperator.get_default ().file_updated.connect (() => {
            show_welcome_view ();
            toast.send_notification ();
        });

        key_press_event.connect ((key) => {
            if (Gdk.ModifierType.CONTROL_MASK in key.state && key.keyval == Gdk.Key.q) {
                destroy ();
            }

            if (Gdk.ModifierType.MOD1_MASK in key.state && key.keyval == Gdk.Key.Home) {
                show_welcome_view ();
            }

            return false;
        });

        deck.notify["transition-running"].connect (() => {
            if (!deck.transition_running && deck.visible_child == welcome_view) {
                show_welcome_view ();
            }
        });

        destroy.connect (() => {
            Application.settings.set_enum ("last-view", (int) get_visible_view ());
        });
    }

    public void show_welcome_view () {
        header_bar.title = "Pin It!";
        home_button.sensitive = false;
        deck.visible_child = welcome_view;
    }

    public void show_files_view () {
        files_view.update_list ();
        header_bar.title = _("Edit a desktop file");
        home_button.sensitive = true;
        deck.reorder_child_after (files_view, welcome_view);
        deck.visible_child = files_view;
    }

    public void show_edit_view (DesktopFile desktop_file) {
        edit_view.set_desktop_file (desktop_file);
        set_header_file_info (desktop_file);
        home_button.sensitive = true;
        deck.reorder_child_after (edit_view, welcome_view);
        deck.visible_child = edit_view;
    }

    private void set_header_file_info (DesktopFile desktop_file) {
        if (desktop_file.file_name != "") {
            header_bar.title = _("Editing “%s”").printf (desktop_file.app_name);
        } else {
            header_bar.title = _("Untitled desktop file");
        }
    }

    private Views get_visible_view () {
        if (deck.visible_child == files_view) {
            return Views.FILES_VIEW;
        } else if (deck.visible_child == edit_view) {
            return Views.EDIT_VIEW;
        } else {
            return Views.WELCOME_VIEW;
        }
    }

    private void set_visible_view () {
        unowned var last_view = (Views) Application.settings.get_enum ("last-view");
        switch (last_view) {
            case Views.FILES_VIEW:
                show_files_view ();
                break;
            case Views.EDIT_VIEW:
                show_edit_view (new DesktopFile ());
                break;
            case Views.WELCOME_VIEW:
            default:
                show_welcome_view ();
                break;
        }
    }

    protected override bool configure_event (Gdk.EventConfigure event) {
        if (configure_id != 0) {
            Source.remove (configure_id);
        }

        configure_id = Timeout.add (100, () => {
            configure_id = 0;
            int x, y;
            get_position (out x, out y);
            Application.settings.set ("window-position", "(ii)", x, y);

            return false;
        });

        return base.configure_event (event);
    }
}
