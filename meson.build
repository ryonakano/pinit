project(
    'com.github.ryonakano.pinit',
    'vala', 'c',
    version: '2.1.0',
    meson_version: '>=0.58.0'
)

app_name = 'Pin It!'
app_id = meson.project_name()
app_version = meson.project_version()
if get_option('development')
    app_name += ' (Development)'
    app_id += '.Devel'

    vcs_tag = run_command('git', 'rev-parse', '--short', 'HEAD', check: false).stdout().strip()
    if vcs_tag == ''
        version_suffix = '-devel'
    else
        version_suffix = '-@0@'.format(vcs_tag)
    endif

    app_version += version_suffix
endif

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
