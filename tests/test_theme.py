"""Exercise real Matugen generation, persistence and failure safety without a GUI."""
import importlib.util
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('rice_theme', ROOT / 'scripts/rice-theme.py')
theme = importlib.util.module_from_spec(spec)
spec.loader.exec_module(theme)


class ThemeTests(unittest.TestCase):
    @unittest.skipUnless(shutil.which('matugen'), 'Matugen is required for the integration test')
    def test_generation_and_failed_image_preserves_previous_theme(self):
        with tempfile.TemporaryDirectory(prefix='rice-test-') as temp:
            directory = Path(temp)
            state = directory / 'state'
            # A space, quote and dollar sign in a path must not enter a shell.
            image = directory / "a '$ wallpaper.png"
            shutil.copyfile(ROOT / 'assets/default-wallpaper.png', image)
            theme.apply(image, state, 'JetBrainsMono Nerd Font', 11, reload=False)
            current = (state / 'current').resolve()
            palette = json.loads((current / 'palette.json').read_text())
            self.assertTrue(all(v.startswith('#') for v in palette.values()))
            for filename in ['hyprland.lua', 'rofi.rasi', 'waybar.css', 'gtk.css', 'qt.colors', 'foot.ini', 'mako.conf']:
                self.assertTrue((current / filename).is_file(), filename)
            image.unlink()
            theme.apply(current / 'wallpaper', state, 'JetBrainsMono Nerd Font', 11, reload=False)
            current = (state / 'current').resolve()
            bad_image = directory / 'bad.png'
            bad_image.write_text('not an image')
            with self.assertRaises((ValueError, subprocess.CalledProcessError)):
                theme.apply(bad_image, state, 'JetBrainsMono Nerd Font', 11, reload=False)
            self.assertEqual((state / 'current').resolve(), current)

    def test_reject_non_color_values(self):
        with self.assertRaises(ValueError):
            theme.normalize_color('#123456; malicious content')

    def test_font_is_plain_text(self):
        p = {k: '#123456' for k in theme.KEYS}
        with self.assertRaises(ValueError):
            theme.render(p, 'bad\nfont', 11)
