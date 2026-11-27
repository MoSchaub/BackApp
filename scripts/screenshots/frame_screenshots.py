#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 Moritz Schaub <moritz@pfaender.net>
#
# SPDX-License-Identifier: AGPL-3.0-or-later
"""Put raw simulator screenshots into simple phone frames, three in a row on a black background.

Usage: frame_screenshots.py <screenshot dir> <output dir>

Expects the PNGs written by the ReadmeScreenshots UI test and writes
images/overview.jpeg and images/recipeManagement.jpeg style composites.
Needs Pillow (pip install pillow).
"""
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

# output image name -> the three screenshots shown in it
COMPOSITES = {
    "overview.jpeg": ["1_recipeList", "2_recipeDetail", "3_schedule"],
    "recipeManagement.jpeg": ["4_editRecipe", "5_stepDetail", "6_ingredientDetail"],
}

SCALE = 2                       # render at 2x for sharp images on retina screens
CANVAS = (1000 * SCALE, 700 * SCALE)
PHONE_HEIGHT = 560 * SCALE      # outer height of a phone frame
BEZEL = 11 * SCALE              # frame thickness around the screen
SCREEN_RADIUS = 34 * SCALE
FRAME_COLOR = (44, 44, 46)
EDGE_COLOR = (78, 78, 82)


def rounded_mask(size, radius):
    mask = Image.new("L", size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, size[0] - 1, size[1] - 1), radius, fill=255)
    return mask


def framed_phone(screenshot: Image.Image) -> Image.Image:
    screen_h = PHONE_HEIGHT - 2 * BEZEL
    screen_w = round(screen_h * screenshot.width / screenshot.height)
    screen = screenshot.convert("RGB").resize((screen_w, screen_h), Image.LANCZOS)

    phone_size = (screen_w + 2 * BEZEL, PHONE_HEIGHT)
    phone = Image.new("RGBA", phone_size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(phone)
    outer_radius = SCREEN_RADIUS + BEZEL
    draw.rounded_rectangle((0, 0, phone_size[0] - 1, phone_size[1] - 1), outer_radius,
                           fill=FRAME_COLOR, outline=EDGE_COLOR, width=2 * SCALE)
    phone.paste(screen, (BEZEL, BEZEL), rounded_mask(screen.size, SCREEN_RADIUS))
    return phone


def composite(screenshots):
    canvas = Image.new("RGB", CANVAS, (0, 0, 0))
    phones = [framed_phone(s) for s in screenshots]
    slot = CANVAS[0] // len(phones)
    for i, phone in enumerate(phones):
        x = slot * i + (slot - phone.width) // 2
        y = (CANVAS[1] - phone.height) // 2
        # soft glow like in the original mockups
        glow = Image.new("RGBA", CANVAS, (0, 0, 0, 0))
        ImageDraw.Draw(glow).rounded_rectangle(
            (x - 6 * SCALE, y - 6 * SCALE, x + phone.width + 6 * SCALE, y + phone.height + 6 * SCALE),
            SCREEN_RADIUS + BEZEL, fill=(90, 90, 90, 255))
        glow = glow.filter(ImageFilter.GaussianBlur(14 * SCALE))
        canvas.paste(glow, (0, 0), glow)
        canvas.paste(phone, (x, y), phone)
    return canvas


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    source, target = Path(sys.argv[1]), Path(sys.argv[2])
    target.mkdir(parents=True, exist_ok=True)
    for output, names in COMPOSITES.items():
        missing = [n for n in names if not (source / f"{n}.png").exists()]
        if missing:
            sys.exit(f"missing screenshots in {source}: {', '.join(missing)}")
        image = composite([Image.open(source / f"{n}.png") for n in names])
        image.save(target / output, quality=88, optimize=True)
        print(f"wrote {target / output}")


if __name__ == "__main__":
    main()
