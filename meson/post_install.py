#!/usr/bin/env python3

import os
import subprocess

icon_cache_dir = os.path.join(os.environ['MESON_INSTALL_PREFIX'], 'share', 'icons', 'hicolor')

if not os.environ.get('DESTDIR'):
    print('Updating desktop icon cache…')
    subprocess.call(['gtk-update-icon-cache', '-qtf', icon_cache_dir])
