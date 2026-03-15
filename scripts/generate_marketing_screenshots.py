from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont


ROOT = Path("/Users/robertengel/GIT/Slipless")
SOURCE_DIR = ROOT / "AppStoreScreenshots/6.5-inch"
OUTPUT_DIR = ROOT / "AppStoreScreenshots/6.5-inch-ads"

SHOTS = [
    ("Slipless-6_5-1.png", "Quit one habit", "Private, calm, focused"),
    ("Slipless-6_5-2.png", "Handle cravings", "Urges, slips, check-ins"),
    ("Slipless-6_5-3.png", "See real progress", "Streaks, savings, milestones"),
    ("Slipless-6_5-4.png", "Keep the full picture", "Edit history and learn"),
    ("Slipless-6_5-5.png", "Built for privacy", "Face ID, Stealth Mode, local data"),
]

REGULAR_FONT_CANDIDATES = [
    "/System/Library/Fonts/SFNS.ttf",
    "/System/Library/Fonts/Helvetica.ttc",
    "/System/Library/Fonts/Supplemental/Arial.ttf",
]

BOLD_FONT_CANDIDATES = [
    "/System/Library/Fonts/SFNSRounded.ttf",
    "/System/Library/Fonts/Helvetica.ttc",
    "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
]


def load_font(candidates: list[str], size: int) -> ImageFont.FreeTypeFont:
    for candidate in candidates:
        try:
            return ImageFont.truetype(candidate, size=size)
        except OSError:
            continue
    return ImageFont.load_default()


def wrap_text(text: str, font: ImageFont.ImageFont, max_width: int) -> list[str]:
    measure = ImageDraw.Draw(Image.new("RGBA", (10, 10)))
    lines: list[str] = []
    current = ""

    for word in text.split():
        attempt = word if not current else f"{current} {word}"
        bbox = measure.textbbox((0, 0), attempt, font=font)
        if bbox[2] - bbox[0] <= max_width:
            current = attempt
        else:
            if current:
                lines.append(current)
            current = word

    if current:
        lines.append(current)

    return lines[:2]


def render_shot(filename: str, headline: str, subheadline: str, brand_font, headline_font, sub_font) -> None:
    image = Image.open(SOURCE_DIR / filename).convert("RGBA")
    width, _ = image.size

    overlay = Image.new("RGBA", image.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)

    panel_left = 54
    panel_top = 62
    panel_right = width - 54
    panel_bottom = 510
    radius = 42

    crop = image.crop((panel_left, panel_top, panel_right, panel_bottom)).filter(ImageFilter.GaussianBlur(10))
    crop = Image.alpha_composite(crop, Image.new("RGBA", crop.size, (8, 14, 24, 110)))

    mask = Image.new("L", crop.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, crop.size[0], crop.size[1]), radius=radius, fill=255)
    overlay.paste(crop, (panel_left, panel_top), mask)

    glow = Image.new("RGBA", image.size, (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow)
    glow_draw.ellipse((width - 320, -120, width + 80, 260), fill=(158, 205, 255, 34))
    glow_draw.ellipse((-140, 380, 180, 720), fill=(186, 237, 255, 18))
    glow = glow.filter(ImageFilter.GaussianBlur(28))
    overlay = Image.alpha_composite(glow, overlay)
    draw = ImageDraw.Draw(overlay)

    draw.rounded_rectangle(
        (panel_left, panel_top, panel_right, panel_bottom),
        radius=radius,
        outline=(255, 255, 255, 42),
        width=1,
    )

    brand_y = panel_top + 38
    text_left = panel_left + 42
    draw.text((text_left, brand_y), "SLIPLESS", font=brand_font, fill=(215, 231, 248, 190))

    accent_top = brand_y + 16
    draw.rounded_rectangle((panel_right - 150, accent_top, panel_right - 42, accent_top + 8), radius=4, fill=(255, 255, 255, 170))

    headline_y = brand_y + 64
    draw.text((text_left, headline_y), headline, font=headline_font, fill=(255, 255, 255, 255))

    sub_y = headline_y + 110
    max_width = panel_right - text_left - 42
    lines = wrap_text(subheadline, sub_font, max_width)

    current_y = sub_y
    for line in lines:
        draw.text((text_left, current_y), line, font=sub_font, fill=(220, 229, 240, 235))
        current_y += 50

    final = Image.alpha_composite(image, overlay)
    final.save(OUTPUT_DIR / filename)


def main() -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    brand_font = load_font(BOLD_FONT_CANDIDATES, 30)
    headline_font = load_font(BOLD_FONT_CANDIDATES, 70)
    sub_font = load_font(REGULAR_FONT_CANDIDATES, 36)

    for shot in SHOTS:
        render_shot(*shot, brand_font, headline_font, sub_font)

    for path in sorted(OUTPUT_DIR.glob("*.png")):
        with Image.open(path) as image:
            print(f"{path.name}: {image.size[0]}x{image.size[1]}")


if __name__ == "__main__":
    main()