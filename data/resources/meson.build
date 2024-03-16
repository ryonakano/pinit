blueprints = custom_target('blueprints',
    input: files(
        'gtk' / 'help-overlay.blp'
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

asresources = gnome.compile_resources(
    'as-resources',
    'pinit.gresource.xml',
    dependencies: blueprints,
    c_name: 'as'
)
