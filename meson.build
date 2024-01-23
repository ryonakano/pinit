project(
    'com.github.ryonakano.pinit',
    'vala', 'c',
    version: '2.0.2',
    meson_version: '>=0.57.0'
)

gnome = import('gnome')
i18n = import('i18n')

add_project_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language: 'c'
)

config_data = configuration_data()
config_data.set_quoted('LOCALEDIR', get_option('prefix') / get_option('localedir'))
config_data.set_quoted('PROJECT_NAME', meson.project_name())
config_data.set_quoted('PROJECT_VERSION', meson.project_version())
config_file = configure_file(
    input: 'src' / 'Config.vala.in',
    output: '@BASENAME@',
    configuration: config_data
)

asresources = gnome.compile_resources(
    'as-resources',
    'data' / 'pinit.gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)

sources = files(
    'src' / 'Backend' / 'DesktopFile.vala',
    'src' / 'Backend' / 'DesktopFileOperator.vala',
    'src' / 'Backend' / 'ExternalAppLauncher.vala',
    'src' / 'Views' / 'EditView.vala',
    'src' / 'Views' / 'FilesView.vala',
    'src' / 'Application.vala',
    'src' / 'CategoryChooser.vala',
    'src' / 'DialogResponse.vala',
    'src' / 'MainWindow.vala',
    'src' / 'RegexEntry.vala'
)

executable(
    meson.project_name(),
    asresources,
    config_file,
    sources,
    dependencies: [
        dependency('gee-0.8'),
        dependency('gio-unix-2.0'),
        dependency('gtk4', version: '>= 4.10'),
        dependency('libadwaita-1', version: '>= 1.2.0'),
        dependency('pango'),
        meson.get_compiler('vala').find_library('posix')
    ],
    install: true
)

subdir('data')
subdir('po')

gnome.post_install(
    glib_compile_schemas: true,
    gtk_update_icon_cache: true
)
