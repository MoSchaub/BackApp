#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 Moritz Schaub <moritz@pfaender.net>
#
# SPDX-License-Identifier: AGPL-3.0-or-later
"""Compose raw simulator screenshots into App Store Connect marketing screenshots.

Reads   build/appstore-screenshots/raw/<device>/<lang>/<screen>.png
Writes  build/appstore-screenshots/final/<lang>/<device>/<screen>.png

style.mode "plain" (default, like the current App Store listing) outputs the
full-screen capture; "framed" adds a device frame, background and captions.
Every output has exactly the pixel size App Store Connect expects for that
display class (see config.json) and is saved as RGB PNG without alpha channel.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent.parent


def hex_color(value: str) -> tuple[int, int, int]:
    value = value.lstrip("#")
    return tuple(int(value[i:i + 2], 16) for i in (0, 2, 4))  # type: ignore[return-value]


def load_font(candidates: list[str], size: int) -> ImageFont.FreeTypeFont:
    for path in candidates:
        if Path(path).exists():
            font = ImageFont.truetype(path, size)
            # San Francisco is a variable font: pick the bold instance if available
            try:
                font.set_variation_by_name("Bold")
            except (OSError, ValueError, AttributeError):
                pass
            return font
    return ImageFont.load_default(size)


def gradient(size: tuple[int, int], top: str, bottom: str) -> Image.Image:
    width, height = size
    top_rgb, bottom_rgb = hex_color(top), hex_color(bottom)
    column = Image.new("RGB", (1, height))
    for y in range(height):
        t = y / max(height - 1, 1)
        column.putpixel((0, y), tuple(round(a + (b - a) * t) for a, b in zip(top_rgb, bottom_rgb)))
    return column.resize((width, height))


def fit_text(draw: ImageDraw.ImageDraw, text: str, fonts: list[str], max_width: int,
             start_size: int, min_size: int) -> tuple[ImageFont.FreeTypeFont, list[str]]:
    """Largest font size where the text fits in at most two lines."""
    size = start_size
    while True:
        font = load_font(fonts, size)
        lines = wrap(draw, text, font, max_width)
        if (len(lines) <= 2 and all(draw.textlength(l, font=font) <= max_width for l in lines)) \
                or size <= min_size:
            return font, lines
        size -= 2


def wrap(draw: ImageDraw.ImageDraw, text: str, font: ImageFont.FreeTypeFont, max_width: int) -> list[str]:
    lines: list[str] = []
    current = ""
    for word in text.split():
        candidate = f"{current} {word}".strip()
        if draw.textlength(candidate, font=font) <= max_width or not current:
            current = candidate
        else:
            lines.append(current)
            current = word
    if current:
        lines.append(current)
    return lines


def draw_lines(draw: ImageDraw.ImageDraw, lines: list[str], font: ImageFont.FreeTypeFont,
               center_x: int, top: int, color: tuple[int, int, int], spacing: float = 1.15) -> int:
    ascent, descent = font.getmetrics()
    line_height = round((ascent + descent) * spacing)
    y = top
    for line in lines:
        draw.text((center_x, y), line, font=font, fill=color, anchor="ma")
        y += line_height
    return y


def rounded_mask(size: tuple[int, int], radius: int) -> Image.Image:
    # draw at 3x and downsample for smooth anti-aliased corners
    scale = 3
    big = Image.new("L", (size[0] * scale, size[1] * scale), 0)
    ImageDraw.Draw(big).rounded_rectangle((0, 0, big.width - 1, big.height - 1),
                                          radius=radius * scale, fill=255)
    return big.resize(size, Image.LANCZOS)


def compose(raw: Image.Image, canvas_size: tuple[int, int], device: dict, style: dict,
            caption: str, subtitle: str) -> Image.Image:
    width, height = canvas_size
    canvas = gradient(canvas_size, style["background_top"], style["background_bottom"])
    draw = ImageDraw.Draw(canvas)
    fonts = style["fonts"]

    # --- captions -----------------------------------------------------------
    unit = min(width, height * 0.6)
    margin_x = round(width * 0.08)
    caption_font, caption_lines = fit_text(draw, caption, fonts, width - 2 * margin_x,
                                           round(unit * 0.085), round(unit * 0.05))
    y = draw_lines(draw, caption_lines, caption_font, width // 2, round(height * 0.045),
                   hex_color(style["caption_color"]))
    if subtitle:
        subtitle_font, subtitle_lines = fit_text(draw, subtitle, fonts, width - 2 * margin_x,
                                                 round(unit * 0.045), round(unit * 0.03))
        y = draw_lines(draw, subtitle_lines, subtitle_font, width // 2, y + round(height * 0.008),
                       hex_color(style["subtitle_color"]))
    text_bottom = y + round(height * 0.03)

    # --- device -------------------------------------------------------------
    raw = raw.convert("RGB")
    available_w = width * 0.86
    available_h = height - text_bottom - height * 0.035
    bezel_ratio = device.get("bezel", 0.03)
    # device outer size = screen * (1 + 2 * bezel)
    scale = min(available_w / (raw.width * (1 + 2 * bezel_ratio)),
                available_h / (raw.height + 2 * bezel_ratio * raw.width))
    screen_w, screen_h = round(raw.width * scale), round(raw.height * scale)
    bezel = round(screen_w * bezel_ratio)
    device_w, device_h = screen_w + 2 * bezel, screen_h + 2 * bezel
    left = (width - device_w) // 2
    top = text_bottom + max(0, round((available_h - device_h) / 2))

    screen_radius = round(screen_w * device.get("screen_corner_radius", 0.1))
    device_radius = screen_radius + bezel

    # soft shadow
    shadow = Image.new("L", canvas_size, 0)
    ImageDraw.Draw(shadow).rounded_rectangle(
        (left, top + bezel, left + device_w, top + device_h + bezel), radius=device_radius, fill=140)
    shadow = shadow.filter(ImageFilter.GaussianBlur(bezel * 1.5))
    canvas.paste(Image.new("RGB", canvas_size, (0, 0, 0)), (0, 0), shadow)

    # bezel with a thin highlight edge
    body = Image.new("RGB", (device_w, device_h), hex_color(style["bezel_highlight"]))
    inner = Image.new("RGB", (device_w, device_h), hex_color(style["bezel_color"]))
    edge = max(2, bezel // 6)
    inner_mask = Image.new("L", (device_w, device_h), 0)
    inner_mask.paste(rounded_mask((device_w - 2 * edge, device_h - 2 * edge), device_radius - edge),
                     (edge, edge))
    body.paste(inner, (0, 0), inner_mask)
    canvas.paste(body, (left, top), rounded_mask((device_w, device_h), device_radius))

    # screen
    screen = raw.resize((screen_w, screen_h), Image.LANCZOS)
    canvas.paste(screen, (left + bezel, top + bezel), rounded_mask((screen_w, screen_h), screen_radius))

    return canvas


def plain(raw: Image.Image, canvas_size: tuple[int, int]) -> Image.Image:
    """Full-screen screenshot without frame or caption (style of the current App Store listing).

    The raw capture is scaled to the target width. If the aspect ratio differs (e.g. a
    fallback device was captured), the bottom is cropped or padded with the colour of the
    capture's last row so the status bar and navigation bar always stay intact.
    """
    width, height = canvas_size
    raw = raw.convert("RGB")
    scaled = raw.resize((width, round(raw.height * width / raw.width)), Image.LANCZOS)
    if scaled.height >= height:
        return scaled.crop((0, 0, width, height))
    bottom_row = scaled.crop((0, scaled.height - 1, width, scaled.height)).resize((1, 1), Image.BOX)
    canvas = Image.new("RGB", canvas_size, bottom_row.getpixel((0, 0)))
    canvas.paste(scaled, (0, 0))
    return canvas


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--config", type=Path, default=HERE / "config.json")
    parser.add_argument("--raw", type=Path, default=ROOT / "build" / "appstore-screenshots" / "raw")
    parser.add_argument("--out", type=Path, default=ROOT / "build" / "appstore-screenshots" / "final")
    parser.add_argument("--devices", nargs="*", help="only these device keys")
    parser.add_argument("--mode", choices=["plain", "framed"],
                        help="override style.mode from config.json")
    parser.add_argument("--languages", nargs="*", help="only these languages")
    args = parser.parse_args()

    config = json.loads(args.config.read_text())
    style = config["style"]
    mode = args.mode or style.get("mode", "plain")
    languages = args.languages or config["languages"]
    devices = {k: v for k, v in config["devices"].items() if not args.devices or k in args.devices}

    written, missing = 0, []
    for key, device in devices.items():
        size = tuple(device["size"])
        if device.get("orientation") == "landscape":
            size = (max(size), min(size))
        source_key = key if (args.raw / key).is_dir() else device.get("fallback")
        if not source_key or not (args.raw / source_key).is_dir():
            missing.append(f"{key}: no raw screenshots in {args.raw / key}")
            continue
        if source_key != key:
            print(f"note: {key} uses raw screenshots of {source_key} (no dedicated simulator capture)")

        for lang in languages:
            for screen in config["screens"]:
                raw_path = args.raw / source_key / lang / f"{screen['id']}.png"
                if not raw_path.exists():
                    missing.append(str(raw_path))
                    continue
                if mode == "framed":
                    image = compose(Image.open(raw_path), size, device, style,
                                    screen["caption"].get(lang, screen["caption"].get("en", "")),
                                    screen.get("subtitle", {}).get(lang, ""))
                else:
                    image = plain(Image.open(raw_path), size)
                assert image.size == size and image.mode == "RGB"
                out_path = args.out / lang / key / f"{screen['id']}.png"
                out_path.parent.mkdir(parents=True, exist_ok=True)
                image.save(out_path, "PNG")
                written += 1

    print(f"wrote {written} screenshots to {args.out}")
    for item in missing:
        print(f"missing: {item}", file=sys.stderr)
    return 0 if written else 1


if __name__ == "__main__":
    sys.exit(main())
