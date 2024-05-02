project(
    'com.github.ryonakano.pinit',
    'vala', 'c',
    version: '2.1.0',
    meson_version: '>=0.58.0'
)

gnome = import('gnome')
i18n = import('i18n')

add_project_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language: 'c'
)

subdir('data')
subdir('po')
subdir('src')

gnome.post_install(
    glib_compile_schemas: true,
    gtk_update_icon_cache: true
)
