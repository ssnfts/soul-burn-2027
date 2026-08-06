"""
make_vray_material_lab_icons.py
===============================
Generates the BMP toolbar icons for the vrayMaterialLab tool:

  - vrayMaterialLab / vrayMaterialLabUI   (violet #8B5CF6) shaded material ball
  - vrayMaterialLabAudit                  (cyan   #06B6D4) material ball + loupe
  - vrayMaterialLabTestRig                (indigo #6366F1) material ball + strips

Each tool -> 2 sizes (16, 24) x 2 states (_a active, _i inactive)
          x 2 themes (Icons / IconsDark)  =  8 files per tool, 32 total.

Output directories (the ones the installer ships):
  SB2027/UI_ln/Icons/
  SB2027/UI_ln/IconsDark/

The BMP binary layout is identical to the rest of the pack (24-bit, pixel
offset 54, img_size = rows*stride + 2, xppm = yppm = 2834, 2-byte GDI tail);
Max will not render icons that deviate from it. The writer here is the same
one used by make_smart_icons.py.

Usage:
    python SB2027/tools/make_vray_material_lab_icons.py
"""

import io
import math
import os
import struct

from PIL import Image, ImageDraw

# ---------------------------------------------------------------------------
# BMP writer (matches the existing SoulBurn icon binary exactly)
# ---------------------------------------------------------------------------


def clamp(v: float) -> int:
    return max(0, min(255, int(v)))


def _patch_bmp_header(data: bytes, width: int, height: int) -> bytes:
    stride = ((width * 3 + 3) // 4) * 4
    pixel_bytes = height * stride
    img_size_field = pixel_bytes + 2
    file_size = 54 + img_size_field

    ba = bytearray(data)
    struct.pack_into("<I", ba, 2, file_size)
    struct.pack_into("<I", ba, 34, img_size_field)
    struct.pack_into("<i", ba, 38, 2834)
    struct.pack_into("<i", ba, 42, 2834)
    ba += b"\x00\x00"
    return bytes(ba)


def save_bmp_exact(img: Image.Image, path: str) -> int:
    buf = io.BytesIO()
    img.save(buf, "BMP")
    raw = _patch_bmp_header(buf.getvalue(), img.width, img.height)
    os.makedirs(os.path.dirname(os.path.abspath(path)), exist_ok=True)
    with open(path, "wb") as f:
        f.write(raw)
    return len(raw)


# ---------------------------------------------------------------------------
# Background
# ---------------------------------------------------------------------------


def _make_background(size: int, base_colour: tuple, inactive: bool, dark: bool) -> Image.Image:
    r, g, b = base_colour
    mul = 1.25 if dark else 1.0

    img = Image.new("RGB", (size, size))
    draw = ImageDraw.Draw(img)

    for y in range(size):
        t = y / max(size - 1, 1)
        factor = (0.51 + (1.0 - t) * 0.09) * mul
        draw.line([(0, y), (size, y)],
                  fill=(clamp(r * factor), clamp(g * factor), clamp(b * factor)))

    if inactive:
        pixels = img.load()
        for y in range(size):
            for x in range(size):
                pr, pg, pb = pixels[x, y]
                grey = int(0.299 * pr + 0.587 * pg + 0.114 * pb)
                pixels[x, y] = (
                    int(pr * 0.3 + grey * 0.7),
                    int(pg * 0.3 + grey * 0.7),
                    int(pb * 0.3 + grey * 0.7),
                )

    return img


# ---------------------------------------------------------------------------
# Glyphs
# ---------------------------------------------------------------------------


def _white(inactive: bool) -> tuple:
    return (180, 180, 180) if inactive else (255, 255, 255)


def _material_ball(draw, size, inactive, cx, cy, r, lw):
    """A shaded sphere with a specular dot and a stretched highlight streak -
    the anisotropic material ball this tool exists to build."""
    white = _white(inactive)
    draw.ellipse([cx - r, cy - r, cx + r, cy + r], outline=white, width=lw)

    # Specular dot, upper-left, where a key light would land. Kept small so it
    # stays a highlight rather than swallowing the ball at 16 px.
    sx, sy = cx - int(r * 0.38), cy - int(r * 0.38)
    sr = max(0, int(r * 0.16))
    draw.ellipse([sx - sr, sy - sr, sx + sr, sy + sr], fill=white)

    # Stretched highlight below it: the anisotropic streak.
    if r >= 5:
        y = cy + int(r * 0.42)
        half = int(r * 0.42)
        draw.line([(cx - half, y), (cx + half, y)], fill=white, width=1)


def draw_lab(draw: ImageDraw.ImageDraw, size: int, inactive: bool) -> None:
    """Material ball alone."""
    lw = max(1, size // 12)
    _material_ball(draw, size, inactive, size // 2, size // 2,
                   int(size * 0.34), lw)


def draw_audit(draw: ImageDraw.ImageDraw, size: int, inactive: bool) -> None:
    """Material ball inspected through a loupe."""
    white = _white(inactive)
    lw = max(1, size // 16)
    _material_ball(draw, size, inactive, int(size * 0.36), int(size * 0.36),
                   int(size * 0.24), lw)

    # Loupe in the lower-right, clear of the ball so both read at 16 px.
    lr = max(3, int(size * 0.2))
    lx, ly = int(size * 0.62), int(size * 0.6)
    glw = max(1, size // 14)
    draw.ellipse([lx - lr, ly - lr, lx + lr, ly + lr], outline=white, width=glw)
    ang = math.radians(45)
    draw.line([(lx + int(math.cos(ang) * lr), ly + int(math.sin(ang) * lr)),
               (lx + int(math.cos(ang) * (lr + size * 0.2)),
                ly + int(math.sin(ang) * (lr + size * 0.2)))],
              fill=white, width=max(1, glw + 1))


def draw_testrig(draw: ImageDraw.ImageDraw, size: int, inactive: bool) -> None:
    """Material ball flanked by two strip lights - the evaluation rig."""
    white = _white(inactive)
    lw = max(1, size // 16)
    _material_ball(draw, size, inactive, size // 2, size // 2,
                   int(size * 0.26), lw)

    bar_w = max(1, size // 10)
    pad = max(1, size // 10)
    top = int(size * 0.2)
    bot = int(size * 0.8)
    # Bright key card on the left, dark negative fill (outline) on the right -
    # the bright/dark pair a metal has to be judged against.
    draw.rectangle([pad, top, pad + bar_w, bot], fill=white)
    draw.rectangle([size - pad - bar_w, top, size - pad - 1, bot],
                   outline=white, width=1)


# ---------------------------------------------------------------------------
# Compose + emit
# ---------------------------------------------------------------------------


def make_icon(size, base_colour, draw_fn, inactive=False, dark=False) -> Image.Image:
    img = _make_background(size, base_colour, inactive, dark)
    draw_fn(ImageDraw.Draw(img), size, inactive)
    return img


TOOLS = [
    ("vrayMaterialLab",        (139, 92, 246), draw_lab),      # violet #8B5CF6
    ("vrayMaterialLabUI",      (139, 92, 246), draw_lab),
    ("vrayMaterialLabAudit",   (6, 182, 212),  draw_audit),    # cyan   #06B6D4
    ("vrayMaterialLabTestRig", (99, 102, 241), draw_testrig),  # indigo #6366F1
]

_HERE = os.path.dirname(os.path.abspath(__file__))
_SB = os.path.normpath(os.path.join(_HERE, ".."))          # SB2027/

ICONS_DIR = os.path.join(_SB, "UI_ln", "Icons")
ICONS_DARK_DIR = os.path.join(_SB, "UI_ln", "IconsDark")

EXPECTED = {16: 824, 24: 1784}


def main() -> None:
    generated = []

    for tool_name, colour, draw_fn in TOOLS:
        for size in (16, 24):
            for inactive in (False, True):
                for dark in (False, True):
                    state = "i" if inactive else "a"
                    theme_dir = ICONS_DARK_DIR if dark else ICONS_DIR
                    fname = f"SoulburnScripts_{tool_name}_{size}{state}.bmp"
                    fpath = os.path.join(theme_dir, fname)

                    img = make_icon(size, colour, draw_fn,
                                    inactive=inactive, dark=dark)
                    nbytes = save_bmp_exact(img, fpath)
                    generated.append((fpath, size, nbytes))
                    print(f"  OK  {os.path.relpath(fpath, _SB)}  ({nbytes} bytes)")

    print(f"\n  Generated {len(generated)} BMP files.")

    errors = [f"{p}: expected {EXPECTED[s]}, got {n}"
              for p, s, n in generated if n != EXPECTED[s]]
    if errors:
        print("\n  SIZE MISMATCHES:")
        for e in errors:
            print("    FAIL:", e)
        raise SystemExit(1)
    print("  All file sizes match expected (16x16->824 B, 24x24->1784 B) PASS")


if __name__ == "__main__":
    main()
