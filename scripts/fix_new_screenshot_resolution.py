from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageOps


ROOT = Path("/Users/robertengel/GIT/Slipless")
OUTPUT_DIR = ROOT / "AppStoreScreenshots/6.5-inch-fixed"
FILES = [
    "Screenshot 2026-03-15 at 10.44.35.png",
    "Screenshot 2026-03-15 at 10.47.52.png",
    "Screenshot 2026-03-15 at 10.49.23.png",
    "Screenshot 2026-03-15 at 10.56.46.png",
    "Screenshot 2026-03-15 at 10.58.23.png",
]

CANVAS_SIZE = (1284, 2778)
INNER_MAX = (1120, 2400)
CORNER_RADIUS = 40
SHADOW_OFFSET = 18


def build_asset(source_name: str, destination_name: str) -> None:
    source = Image.open(ROOT / source_name).convert("RGBA")

    background = ImageOps.fit(source, CANVAS_SIZE, method=Image.Resampling.LANCZOS)
    background = background.filter(ImageFilter.GaussianBlur(28))
    background = Image.blend(background, Image.new("RGBA", CANVAS_SIZE, (8, 12, 20, 255)), 0.28)

    foreground = source.copy()
    foreground.thumbnail(INNER_MAX, Image.Resampling.LANCZOS)

    mask = Image.new("L", foreground.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        (0, 0, foreground.size[0], foreground.size[1]),
        radius=CORNER_RADIUS,
        fill=255,
    )

    shadow = Image.new("RGBA", CANVAS_SIZE, (0, 0, 0, 0))
    shadow_box = (
        (CANVAS_SIZE[0] - foreground.size[0]) // 2,
        (CANVAS_SIZE[1] - foreground.size[1]) // 2 + SHADOW_OFFSET,
        (CANVAS_SIZE[0] + foreground.size[0]) // 2,
        (CANVAS_SIZE[1] + foreground.size[1]) // 2 + SHADOW_OFFSET,
    )
    ImageDraw.Draw(shadow).rounded_rectangle(shadow_box, radius=CORNER_RADIUS, fill=(0, 0, 0, 90))
    shadow = shadow.filter(ImageFilter.GaussianBlur(24))

    result = Image.alpha_composite(background, shadow)

    x = (CANVAS_SIZE[0] - foreground.size[0]) // 2
    y = (CANVAS_SIZE[1] - foreground.size[1]) // 2
    result.paste(foreground, (x, y), mask)

    output_path = OUTPUT_DIR / destination_name
    result.save(output_path)
    print(f"{output_path.name}: {result.size[0]}x{result.size[1]}")


def main() -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    for index, filename in enumerate(FILES, start=1):
        build_asset(filename, f"Slipless-fixed-{index}.png")


if __name__ == "__main__":
    main()