blueprints = custom_target('blueprints',
    input: files(
        'gtk/help-overlay.blp'
    ),
    output: '.',
    command: [
        find_program('blueprint-compiler'),
        'batch-compile',
        '@OUTPUT@',
        '@CURRENT_SOURCE_DIR@',
        '@INPUT@'
    ]
)

gresource_conf = configuration_data()
gresource_conf.set('APP_ID', app_id)
gresource_file_in = configure_file(
    input: 'pinit.gresource.xml.in',
    output: '@0@.gresource.xml'.format(app_id),
    configuration: gresource_conf
)

asresources = gnome.compile_resources(
    'as-resources',
    gresource_file_in,
    dependencies: blueprints,
    c_name: 'as'
)
