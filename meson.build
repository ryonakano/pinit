project(
    'com.github.ryonakano.pinit',
    'vala', 'c',
    version: '2.0.0',
    meson_version: '>=0.56.0'
)

gnome = import('gnome')
i18n = import('i18n')

add_project_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language: 'c'
)

config_data = configuration_data()
config_data.set_quoted('LOCALEDIR', get_option('prefix') / get_option('localedir'))
config_data.set_quoted('GETTEXT_PACKAGE', meson.project_name())
config_data.set_quoted('VERSION', meson.project_version())
config_data.set_quoted('RDNN_NAME', meson.project_name())
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
    'src' / 'Views' / 'EditView.vala',
    'src' / 'Views' / 'FilesView.vala',
    'src' / 'Application.vala',
    'src' / 'CategoryChooser.vala',
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
        dependency('gtk4'),
        dependency('libadwaita-1'),
        dependency('pango'),
        meson.get_compiler('vala').find_library('posix')
    ],
    install: true
)

subdir('data')
subdir('po')

meson.add_install_script('meson' / 'post_install.py')
