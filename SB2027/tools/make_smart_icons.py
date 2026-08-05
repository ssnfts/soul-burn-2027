"""
make_smart_icons.py
===================
Generates 16 BMP icon files for the SoulBurn Scripts pack:
  - smartLighting / smartLightingUI     (amber  #F59E0B)
  - uninstallSoulburn / uninstallSoulburnUI  (red  #EF4444)

Each tool → 2 sizes (16, 24) × 2 states (_a active, _i inactive)
         × 2 themes (Icons / IconsDark)  =  16 files per tool × 2 tools

Output directories (relative to workspace root, two levels up from this file):
  UI_ln/Icons/
  UI_ln/IconsDark/

BMP format matched exactly to existing SoulBurn icons:
  - 24-bit uncompressed  (BITMAPINFOHEADER, compression=0)
  - Pixel offset  = 54  (14 BMP + 40 DIB header, no colour table)
  - img_size field = rows * stride + 2  (Windows GDI trailing 0x0000 word)
  - xppm = yppm = 2834  (≈72 dpi in pixels-per-metre)
  - 2-byte 0x0000 terminator appended after pixel data
  - File sizes: 16×16 → 824 bytes,  24×24 → 1784 bytes
"""

import os
import struct
from PIL import Image, ImageDraw

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def clamp(v: float) -> int:
    return max(0, min(255, int(v)))


def _patch_bmp_header(data: bytes, width: int, height: int) -> bytes:
    """
    Re-write the BMP/DIB header fields that Pillow sets differently from
    the existing SoulBurn icons, then append the 2-byte GDI terminator.

    Existing icon spec (verified by binary inspection):
        img_size  = (rows * stride) + 2   where stride = ceil(W*3/4)*4
        xppm      = 2834
        yppm      = 2834
        trailing  2 bytes = 0x00 0x00
    """
    stride = ((width * 3 + 3) // 4) * 4   # 4-byte-aligned row width
    pixel_bytes = height * stride          # pure pixel area
    img_size_field = pixel_bytes + 2       # +2 for GDI terminator word
    file_size = 54 + img_size_field        # header (54) + pixel area + 2

    # Convert to mutable bytearray; Pillow gives us exactly 54 + pixel_bytes
    ba = bytearray(data)

    # Patch file size  (bytes 2-5)
    struct.pack_into("<I", ba, 2, file_size)
    # Patch img_size   (bytes 34-37 inside DIB header)
    struct.pack_into("<I", ba, 34, img_size_field)
    # Patch xppm       (bytes 38-41)
    struct.pack_into("<i", ba, 38, 2834)
    # Patch yppm       (bytes 42-45)
    struct.pack_into("<i", ba, 42, 2834)

    # Append the 2-byte GDI null terminator
    ba += b"\x00\x00"

    return bytes(ba)


# ---------------------------------------------------------------------------
# Background builder
# ---------------------------------------------------------------------------

def _make_background(size: int, base_colour: tuple, inactive: bool, dark: bool) -> Image.Image:
    """
    Build the gradient background for one icon:
      - Vertical gradient, top ~10 % lighter than bottom
      - Dark theme: background luminosity boosted ×1.25
      - Inactive: desaturated (70 % grey blend)
    """
    r, g, b = base_colour
    mul = 1.25 if dark else 1.0

    img = Image.new("RGB", (size, size))
    draw = ImageDraw.Draw(img)

    for y in range(size):
        t = y / max(size - 1, 1)          # 0 = top, 1 = bottom
        factor = (0.51 + (1.0 - t) * 0.09) * mul   # top ≈ 0.60, bottom ≈ 0.51
        br = clamp(r * factor)
        bg = clamp(g * factor)
        bb = clamp(b * factor)
        for x in range(size):
            draw.point((x, y), fill=(br, bg, bb))

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
# Glyph: Smart Lighting  (3-point lighting triangle + key-light sun)
# ---------------------------------------------------------------------------

def draw_lighting(draw: ImageDraw.ImageDraw, size: int, inactive: bool) -> None:
    """
    ASCII-art stage lighting concept:
      •  A solid circle at the top apex  →  key light / sun
      •  Triangle outline connecting key (top-centre), fill (bottom-left),
         and rim (bottom-right)  →  the classic 3-point lighting triangle
      •  Open circles at the two lower corners  →  fill & rim light positions

    The layout is tightly padded so the glyph fills ~70 % of the canvas.
    """
    s = size
    white = (255, 255, 255) if not inactive else (180, 180, 180)
    lw = max(1, s // 16)          # line thickness scales with icon size

    pad = max(2, s // 5)          # outer padding
    top = (s // 2, pad)           # apex: key light
    bl  = (pad,     s - pad)      # bottom-left: fill light
    br  = (s - pad, s - pad)      # bottom-right: rim light

    # Triangle edges
    draw.line([top, bl], fill=white, width=lw)
    draw.line([top, br], fill=white, width=lw)
    draw.line([bl,  br], fill=white, width=lw)

    # Solid circle at apex (key / sun)
    kr = max(1, s // 8)
    cx, cy = top
    draw.ellipse([cx - kr, cy - kr, cx + kr, cy + kr], fill=white)

    # Open circles at fill & rim positions (spotlight "heads")
    dr = max(1, s // 10)
    for pt in (bl, br):
        px, py = pt
        draw.ellipse(
            [px - dr, py - dr, px + dr, py + dr],
            outline=white,
            width=lw,
        )

    # Short beam rays from apex circle outward (only for 24px — enough room)
    if size >= 24:
        ray_len = max(2, s // 8)
        import math
        for angle_deg in (-30, 0, 30):
            rad = math.radians(angle_deg - 90)   # -90 so 0° points up
            ex = int(cx + math.cos(rad) * (kr + ray_len))
            ey = int(cy + math.sin(rad) * (kr + ray_len))
            # start just outside the circle
            sx = int(cx + math.cos(rad) * (kr + 1))
            sy = int(cy + math.sin(rad) * (kr + 1))
            draw.line([(sx, sy), (ex, ey)], fill=white, width=lw)


# ---------------------------------------------------------------------------
# Glyph: Uninstall SoulBurn  (bold X)
# ---------------------------------------------------------------------------

def draw_uninstall(draw: ImageDraw.ImageDraw, size: int, inactive: bool) -> None:
    """
    A clean, bold × glyph that reads instantly as 'remove / delete'.
    Line width is intentionally thick (size/6) so it's legible at 16 px.
    The X is drawn as two anti-crossed diagonals with rounded cap style
    (Pillow uses flat caps; bold width approximates the hand-crafted look).

    Extra detail at 24 px: a thin rounded square border frames the X,
    making it resemble a classic 'delete button' badge.
    """
    white = (255, 255, 255) if not inactive else (180, 180, 180)
    lw  = max(2, size // 6)       # bold stroke
    pad = size // 4               # inset from edges

    # Primary × strokes
    draw.line([(pad, pad), (size - pad, size - pad)], fill=white, width=lw)
    draw.line([(size - pad, pad), (pad, size - pad)], fill=white, width=lw)

    # Framing circle at 24 px (badge border)
    if size >= 24:
        border_lw = max(1, size // 12)
        inset = border_lw          # keep border inside the canvas
        draw.ellipse(
            [inset, inset, size - inset - 1, size - inset - 1],
            outline=white,
            width=border_lw,
        )


# ---------------------------------------------------------------------------
# Icon composer
# ---------------------------------------------------------------------------

def make_icon(
    size: int,
    base_colour: tuple,
    draw_fn,
    inactive: bool = False,
    dark: bool = False,
) -> Image.Image:
    """Compose background + glyph into a finished icon image."""
    img  = _make_background(size, base_colour, inactive, dark)
    draw = ImageDraw.Draw(img)
    draw_fn(draw, size, inactive)
    return img


# ---------------------------------------------------------------------------
# BMP serialiser — matches existing SoulBurn icon binary exactly
# ---------------------------------------------------------------------------

def save_bmp_exact(img: Image.Image, path: str) -> int:
    """
    Save *img* as a 24-bit BMP at *path* with the exact binary layout of
    the existing SoulBurn icons (img_size + 2, xppm=yppm=2834, 2-byte tail).
    Returns the file size in bytes.
    """
    import io
    buf = io.BytesIO()
    img.save(buf, "BMP")
    raw = _patch_bmp_header(buf.getvalue(), img.width, img.height)
    os.makedirs(os.path.dirname(os.path.abspath(path)), exist_ok=True)
    with open(path, "wb") as f:
        f.write(raw)
    return len(raw)


# ---------------------------------------------------------------------------
# Main: generate all 16 files
# ---------------------------------------------------------------------------

# Tool definitions: (name, base_colour_RGB, draw_function)
TOOLS = [
    ("smartLighting",       (245, 158, 11), draw_lighting),    # amber  #F59E0B
    ("smartLightingUI",     (245, 158, 11), draw_lighting),
    ("uninstallSoulburn",   (239,  68, 68), draw_uninstall),   # red    #EF4444
    ("uninstallSoulburnUI", (239,  68, 68), draw_uninstall),
]

# Workspace root is two levels above this script (SB2027/tools/ → ../../)
_HERE  = os.path.dirname(os.path.abspath(__file__))
_ROOT  = os.path.normpath(os.path.join(_HERE, "..", ".."))

ICONS_DIR      = os.path.join(_ROOT, "UI_ln", "Icons")
ICONS_DARK_DIR = os.path.join(_ROOT, "UI_ln", "IconsDark")


def main() -> None:
    generated = []

    for tool_name, colour, draw_fn in TOOLS:
        for size in (16, 24):
            for inactive in (False, True):
                for dark in (False, True):
                    state     = "i" if inactive else "a"
                    theme_dir = ICONS_DARK_DIR if dark else ICONS_DIR
                    fname     = f"SoulburnScripts_{tool_name}_{size}{state}.bmp"
                    fpath     = os.path.join(theme_dir, fname)

                    img      = make_icon(size, colour, draw_fn, inactive=inactive, dark=dark)
                    nbytes   = save_bmp_exact(img, fpath)
                    rel_path = os.path.relpath(fpath, _ROOT)
                    generated.append((rel_path, nbytes))
                    print(f"  OK  {rel_path}  ({nbytes} bytes)")

    print()
    print(f"  Generated {len(generated)} BMP files.")

    # Validate expected file sizes
    # Filename: SoulburnScripts_{name}_{size}{state}.bmp
    # The last underscore segment before .bmp is always "{size}{state}", e.g. "16a", "24i"
    expected = {16: 824, 24: 1784}
    def _px(path_str):
        tag = os.path.basename(path_str)[:-4].rsplit('_', 1)[-1]  # e.g. "16a"
        return int(tag[:-1])                                       # 16 or 24
    errors = [
        f"{p}: expected {expected[_px(p)]}, got {n}"
        for p, n in generated
        if n != expected[_px(p)]
    ]
    if errors:
        print("\n  SIZE MISMATCHES:")
        for e in errors:
            print("    FAIL:", e)
    else:
        print("  All file sizes match expected (16x16->824 B, 24x24->1784 B) PASS")


if __name__ == "__main__":
    main()
