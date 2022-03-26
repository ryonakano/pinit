/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2022 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class WelcomeView : Gtk.Grid {
    public WelcomeView () {
        Object (
            //  title: "Pin It!",
            //  description: _("Pin any apps into the launcher")
        );
    }

    construct {
        // The background color of this widget is rgb(255, 255, 255) by default.
        // Remove this class so that the background color of the headerbar and the welcome view matches
        //  get_style_context ().remove_class (Granite.STYLE_CLASS_VIEW);

        //  Icon new_icon;
        //  Icon edt_icon;
        //  try {
        //      new_icon = Icon.new_for_string ("document-new");
        //      edt_icon = Icon.new_for_string ("document-edit");
        //  } catch (Error e) {
        //      warning (e.message);
        //  }

        //  append_button (new_icon, _("New Entry"), _("Create a new app entry."));
        //  append_button (edt_icon, _("Edit Entry"), _("Edit an existing app entry."));

        //  activated.connect ((i) => {
        //      unowned var window = ((Application) GLib.Application.get_default ()).window;

        //      if (i == 0) {
        //          window.show_edit_view (DesktopFileOperator.get_default ().create_new ());
        //      } else {
        //          window.show_files_view ();
        //      }
        //  });
    }
}
