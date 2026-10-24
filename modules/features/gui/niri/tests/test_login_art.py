import gzip
import importlib.util
import json
import tempfile
import unittest
from pathlib import Path


path = Path(__file__).resolve().parents[1] / "assets" / "login-art.py"
spec = importlib.util.spec_from_file_location("login_art", path)
login_art = importlib.util.module_from_spec(spec)
spec.loader.exec_module(login_art)


class LoginArtTests(unittest.TestCase):
    def test_palette_matches_ly_rendering(self):
        colors = login_art.palette()
        self.assertEqual(sorted(colors), list(range(16, 256)))
        self.assertEqual(colors[16], (0, 0, 0))
        self.assertEqual(colors[231], (255, 255, 255))
        self.assertEqual(colors[59], (95, 95, 95))
        self.assertEqual(colors[232], (8, 8, 8))
        self.assertEqual(colors[255], (238, 238, 238))

    def test_black_and_white_map_to_exact_colors(self):
        nearest = login_art.quantizer()
        self.assertEqual(nearest((0, 0, 0)), 16)
        self.assertEqual(nearest((255, 255, 255)), 231)
        self.assertEqual(nearest((9, 9, 9)), 232)

    def test_movie_pairs_rows_into_half_blocks(self):
        black, white = (0, 0, 0), (255, 255, 255)
        pixels = [
            [white, black, white],
            [black, black, white],
            [black, white, black],
            [black, white, white],
        ]
        dur = login_art.movie(pixels)["DurMovie"]
        self.assertEqual((dur["columns"], dur["lines"]), (3, 2))
        self.assertEqual(dur["formatVersion"], 7)
        self.assertEqual(dur["colorFormat"], "256")
        (frame,) = dur["frames"]
        self.assertEqual(set(frame), {"frameNumber", "delay", "contents", "colorMap"})
        self.assertEqual(frame["contents"], ["\u2580\u2580\u2580"] * 2)
        # colorMap is indexed by column, then line, then [foreground, background].
        self.assertEqual(frame["colorMap"][0], [[231, 16], [16, 16]])
        self.assertEqual(frame["colorMap"][1], [[16, 16], [231, 231]])
        self.assertEqual(frame["colorMap"][2], [[231, 231], [16, 231]])

    def test_odd_row_count_is_rejected(self):
        with self.assertRaises(ValueError):
            login_art.movie([[(0, 0, 0)]])

    def test_write_produces_gzipped_json_with_float_timing(self):
        document = login_art.movie([[(0, 0, 0)], [(0, 0, 0)]])
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / "art.dur"
            login_art.write(document, output)
            text = gzip.decompress(output.read_bytes()).decode()
        self.assertEqual(json.loads(text), document)
        # Ly reads framerate and delay as JSON floats, so they must keep a decimal point.
        self.assertIn('"framerate": 1.0', text)
        self.assertIn('"delay": 0.0', text)


if __name__ == "__main__":
    unittest.main()
