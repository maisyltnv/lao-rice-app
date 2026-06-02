#!/usr/bin/env python3
"""Rasterize brand launcher icons (brown tile + Lucide Wheat)."""

from __future__ import annotations

import math
import re
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
BRAND = ROOT / "assets" / "brand"
SIZE = 1024
PRIMARY = (0x7C, 0x5C, 0x1E)
WHITE = (0xFF, 0xFF, 0xFF)
CORNER_RADIUS = 224

# Lucide Wheat paths (24×24 viewBox)
WHEAT_PATHS = [
    "M2 22 16 8",
    "M3.47 12.53 5 11l1.53 1.53a3.5 3.5 0 0 1 0 4.94L5 19l-1.53-1.53a3.5 3.5 0 0 1 0-4.94Z",
    "M7.47 8.53 9 7l1.53 1.53a3.5 3.5 0 0 1 0 4.94L9 15l-1.53-1.53a3.5 3.5 0 0 1 0-4.94Z",
    "M11.47 4.53 13 3l1.53 1.53a3.5 3.5 0 0 1 0 4.94L13 11l-1.53-1.53a3.5 3.5 0 0 1 0-4.94Z",
    "M20 2h2v2a4 4 0 0 1-4 4h-2V6a4 4 0 0 1 4-4Z",
    "M11.47 17.47 13 19l-1.53 1.53a3.5 3.5 0 0 1-4.94 0L5 19l1.53-1.53a3.5 3.5 0 0 1 4.94 0Z",
    "M15.47 13.47 17 15l-1.53 1.53a3.5 3.5 0 0 1-4.94 0L9 15l1.53-1.53a3.5 3.5 0 0 1 4.94 0Z",
    "M19.47 9.47 21 11l-1.53 1.53a3.5 3.5 0 0 1-4.94 0L13 11l1.53-1.53a3.5 3.5 0 0 1 4.94 0Z",
]

# Match web: icon ~50% of 1024 tile → scale 24 → ~640
ICON_SCALE = 640 / 24
ICON_OFFSET = (SIZE - 640) / 2
STROKE = max(8, int(2 * ICON_SCALE * 0.9))


def _tokenize(path: str) -> list[str]:
    return re.findall(
        r"[a-zA-Z]|-?\d*\.?\d+(?:e[-+]?\d+)?",
        path.replace(",", " "),
    )


def _parse_path(path: str) -> list[tuple[float, float]]:
    tokens = _tokenize(path)
    i = 0
    x = y = 0.0
    start_x = start_y = 0.0
    points: list[tuple[float, float]] = []

    def read_num() -> float:
        nonlocal i
        v = float(tokens[i])
        i += 1
        return v

    while i < len(tokens):
        cmd = tokens[i]
        i += 1
        rel = cmd.islower()
        cmd_up = cmd.upper()

        if cmd_up == "M":
            x, y = read_num(), read_num()
            start_x, start_y = x, y
            points.append((x, y))
        elif cmd_up == "L":
            x, y = read_num(), read_num()
            if rel:
                x += points[-1][0] if points else 0
                y += points[-1][1] if points else 0
            points.append((x, y))
        elif cmd_up == "H":
            x = read_num()
            if rel:
                x += points[-1][0]
            points.append((x, points[-1][1]))
        elif cmd_up == "V":
            y = read_num()
            if rel:
                y += points[-1][1]
            points.append((points[-1][0], y))
        elif cmd_up == "Z":
            points.append((start_x, start_y))
        elif cmd_up == "A":
            rx, ry = read_num(), read_num()
            _rot = read_num()
            large = int(read_num())
            sweep = int(read_num())
            x2, y2 = read_num(), read_num()
            if rel:
                x2 += points[-1][0]
                y2 += points[-1][1]
            # Approximate arc as line to end (good enough at launcher size)
            x, y = x2, y2
            points.append((x, y))
        else:
            # Skip unknown / complex (e.g. cubic) by consuming pairs until next cmd
            while i < len(tokens) and not tokens[i].isalpha():
                if i + 1 < len(tokens) and not tokens[i + 1].isalpha():
                    x, y = read_num(), read_num()
                    if rel and points:
                        x += points[-1][0]
                        y += points[-1][1]
                    points.append((x, y))
                else:
                    break

    return points


def _map_point(x: float, y: float) -> tuple[float, float]:
    return (
        ICON_OFFSET + x * ICON_SCALE,
        ICON_OFFSET + y * ICON_SCALE,
    )


def _rounded_rect_mask(size: int, radius: int) -> Image.Image:
    mask = Image.new("L", (size, size), 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle((0, 0, size - 1, size - 1), radius=radius, fill=255)
    return mask


def _draw_wheat(draw: ImageDraw.ImageDraw) -> None:
    for path in WHEAT_PATHS:
        pts = _parse_path(path)
        if len(pts) < 2:
            continue
        mapped = [_map_point(x, y) for x, y in pts]
        draw.line(mapped, fill=WHITE, width=STROKE, joint="curve")


def _compose(*, background: tuple[int, int, int] | None) -> Image.Image:
    if background is None:
        im = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    else:
        im = Image.new("RGBA", (SIZE, SIZE), background + (255,))

    draw = ImageDraw.Draw(im)
    _draw_wheat(draw)

    if background is not None:
        mask = _rounded_rect_mask(SIZE, CORNER_RADIUS)
        out = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
        brown = Image.new("RGBA", (SIZE, SIZE), background + (255,))
        out.paste(brown, mask=mask)
        out = Image.alpha_composite(out, im)
        return out

    return im


def main() -> None:
    BRAND.mkdir(parents=True, exist_ok=True)
    icon = _compose(background=PRIMARY)
    icon_rgb = icon.convert("RGB")
    icon_rgb.save(BRAND / "app_icon.png", "PNG")

    fg = _compose(background=None)
    fg.save(BRAND / "app_icon_foreground.png", "PNG")

    px = icon_rgb.getpixel((64, 64))
    print(f"app_icon.png corner pixel (brown expected): {px}")
    print(f"Saved {BRAND / 'app_icon.png'} and app_icon_foreground.png")


if __name__ == "__main__":
    main()
