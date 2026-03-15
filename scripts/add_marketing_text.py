
import os
from PIL import Image, ImageDraw, ImageFont

def add_text_to_images():
    # --- Konfiguracija ---
    input_dir = "AppStoreScreenshots/6.5-inch/"
    output_dir = "AppStoreScreenshots/marketing_output/"
    font_path = "/System/Library/Fonts/HelveticaNeue.ttc"  # Uobičajena putanja na macOS-u
    font_size = 90
    text_color = "white"
    outline_color = "black"

    # Tekstovi za svaku sliku (1 do 5)
    marketing_texts = [
        "Vratite kontrolu nad svojim navikama.",
        "Pratite svoj napredak i slavite svaki uspeh.",
        "Zabeležite posrnuća i iskušenja bez osuđivanja.",
        "Upoznajte svoje okidače i prevaziđite ih.",
        "Diskretna podrška koja je uvek tu za vas."
    ]

    # --- Logika skripte ---
    # Kreiraj izlazni direktorijum ako ne postoji
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    # Učitaj font
    try:
        font = ImageFont.truetype(font_path, font_size)
    except IOError:
        print(f"Font nije pronađen na putanji: {font_path}")
        print("Pokušavam sa podrazumevanim fontom. Izgled teksta može varirati.")
        try:
            font = ImageFont.load_default()
        except IOError:
            print("Nije moguće učitati ni podrazumevani font. Prekidam izvršavanje.")
            return

    # Obradi svaku sliku
    for i in range(1, 6):
        # Definiši putanje
        input_image_path = os.path.join(input_dir, f"Slipless-6_5-{i}.png")
        output_image_path = os.path.join(output_dir, f"Slipless-Marketing-{i}.png")

        if not os.path.exists(input_image_path):
            print(f"Slika nije pronađena: {input_image_path}")
            continue

        # Otvori sliku
        with Image.open(input_image_path).convert("RGBA") as base:
            # Pripremi crtež
            txt_layer = Image.new("RGBA", base.size, (255, 255, 255, 0))
            d = ImageDraw.Draw(txt_layer)

            # Pozicija teksta
            image_width, image_height = base.size
            text = marketing_texts[i-1]
            
            # Računanje pozicije teksta
            try:
                # PIL/Pillow verzije 10.0.0+ koriste getbbox
                text_bbox = d.textbbox((0, 0), text, font=font)
                text_width = text_bbox[2] - text_bbox[0]
            except AttributeError:
                # Starije verzije koriste textsize
                text_width, _ = d.textsize(text, font=font)


            x = (image_width - text_width) / 2
            y = 100  # Fiksna margina sa vrha

            # Dodaj ivicu (outline) tekstu
            d.text((x-2, y-2), text, font=font, fill=outline_color)
            d.text((x+2, y-2), text, font=font, fill=outline_color)
            d.text((x-2, y+2), text, font=font, fill=outline_color)
            d.text((x+2, y+2), text, font=font, fill=outline_color)

            # Dodaj glavni tekst
            d.text((x, y), text, font=font, fill=text_color)

            # Spoji slojeve i sačuvaj
            out = Image.alpha_composite(base, txt_layer)
            out.convert("RGB").save(output_image_path, "PNG")
            print(f"Sačuvana slika: {output_image_path}")

if __name__ == "__main__":
    add_text_to_images()
