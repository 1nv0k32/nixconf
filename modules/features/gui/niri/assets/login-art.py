import argparse
import gzip
import json
from pathlib import Path

# Ly paints each cell's foreground over the top half and background over the bottom half.
HALF_BLOCK = "\u2580"


def palette():
    """RGB values Ly renders for 256-color indices 16-255.

    Indices 0-15 map to terminal defaults and bold styling, so they are never used.
    """
    levels = [0] + [step * 40 + 55 for step in range(1, 6)]
    colors = {}
    for index in range(16, 232):
        cube = index - 16
        colors[index] = (levels[cube // 36 % 6], levels[cube // 6 % 6], levels[cube % 6])
    for index in range(232, 256):
        gray = 8 + 10 * (index - 232)
        colors[index] = (gray, gray, gray)
    return colors


def quantizer():
    colors = palette()
    cache = {}

    def nearest(rgb):
        if rgb not in cache:
            cache[rgb] = min(
                colors,
                key=lambda index: sum((a - b) ** 2 for a, b in zip(colors[index], rgb)),
            )
        return cache[rgb]

    return nearest


def movie(pixels):
    """Builds a single-frame durdraw v7 movie from rows of RGB tuples (even row count)."""
    if not pixels or len(pixels) % 2:
        raise ValueError("pixel rows must be a non-empty, even count")
    width = len(pixels[0])
    lines = len(pixels) // 2
    nearest = quantizer()
    color_map = [
        [[nearest(pixels[2 * y][x]), nearest(pixels[2 * y + 1][x])] for y in range(lines)]
        for x in range(width)
    ]
    return {
        "DurMovie": {
            "formatVersion": 7,
            "colorFormat": "256",
            "encoding": "utf-8",
            "framerate": 1.0,
            "columns": width,
            "lines": lines,
            "frames": [
                {
                    "frameNumber": 1,
                    "delay": 0.0,
                    "contents": [HALF_BLOCK * width] * lines,
                    "colorMap": color_map,
                }
            ],
        }
    }


def write(document, output):
    with open(output, "wb") as raw, gzip.GzipFile(fileobj=raw, mode="wb", mtime=0) as file:
        file.write(json.dumps(document, ensure_ascii=False).encode())


def main():
    from PIL import Image

    parser = argparse.ArgumentParser()
    parser.add_argument("--image", type=Path, required=True)
    parser.add_argument("--columns", type=int, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()

    with Image.open(args.image) as image:
        image = image.convert("RGB")
        rows = max(2, round(args.columns * image.height / image.width / 2) * 2)
        image = image.resize((args.columns, rows), Image.Resampling.BOX)
        data = list(image.getdata())
    pixels = [data[row * args.columns : (row + 1) * args.columns] for row in range(rows)]
    write(movie(pixels), args.output)


if __name__ == "__main__":
    main()
