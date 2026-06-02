#!/usr/bin/env python3
"""Copy master logo into app + web assets and favicon sizes."""

from __future__ import annotations

import shutil
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
WEB = ROOT.parent / "lao-rice-web"
BRAND = ROOT / "assets" / "brand"
WEB_PUBLIC = WEB / "public"

# Default master (override with argv)
DEFAULT_MASTER = (
    ROOT.parent
    / ".cursor"
    / "projects"
    / "Users-k2211022-Documents-myProjects-lao-rice-app"
    / "assets"
    / "ChatGPT_Image_Jun_2__2026__08_19_18_PM-19553f9f-8187-4a54-8ce1-7b1c6a16793a.png"
)


def _save_resized(im: Image.Image, path: Path, size: int) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    out = im.resize((size, size), Image.Resampling.LANCZOS)
    if path.suffix.lower() == ".png":
        out.save(path, "PNG", optimize=True)
    else:
        out.save(path, "PNG", optimize=True)


def main(master: Path) -> None:
    im = Image.open(master).convert("RGBA")
    if im.size != (1024, 1024):
        im = im.resize((1024, 1024), Image.Resampling.LANCZOS)

    BRAND.mkdir(parents=True, exist_ok=True)
    im.save(BRAND / "logo.png", "PNG", optimize=True)
    shutil.copy(BRAND / "logo.png", BRAND / "app_icon.png")
    shutil.copy(BRAND / "logo.png", BRAND / "app_icon_foreground.png")

    WEB_PUBLIC.mkdir(parents=True, exist_ok=True)
    im.save(WEB_PUBLIC / "logo.png", "PNG", optimize=True)
    _save_resized(im, WEB_PUBLIC / "apple-icon.png", 180)
    _save_resized(im, WEB_PUBLIC / "icon-light-32x32.png", 32)
    _save_resized(im, WEB_PUBLIC / "icon-dark-32x32.png", 32)
    _save_resized(im, WEB_PUBLIC / "icon-192.png", 192)
    _save_resized(im, WEB_PUBLIC / "icon-512.png", 512)

    print(f"Synced brand assets from {master}")


if __name__ == "__main__":
    import sys

    src = Path(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_MASTER
    if not src.is_file():
        raise SystemExit(f"Master logo not found: {src}")
    main(src)
