import os
import re
import json
import time
import hashlib
import urllib.request
import urllib.parse
from PIL import Image
import io

SEED_FILE = 'lib/core/database/seed_data.dart'
OUTPUT_DIR = 'assets/images/recipes'

os.makedirs(OUTPUT_DIR, exist_ok=True)

with open(SEED_FILE, 'r', encoding='utf-8') as f:
    content = f.read()

# Extract recipes
matches = re.findall(
    r"\{\s*'id':\s*'([^']+)',\s*'title':\s*'([^']+)',\s*'description':\s*'([^']*)',\s*'chef_name':\s*'([^']*)',\s*'cuisine':\s*'([^']*)',\s*'image_url':\s*'([^']+)'",
    content
)

print(f"Found {len(matches)} recipes in {SEED_FILE}")

# Query enhancer map for specific traditional dishes to get the most accurate search terms
SEARCH_TERMS = {
    'Akki Rotti': 'Akki Rotti Karnataka food',
    'Kotte Kadubu': 'Kotte Kadubu Karnataka',
    'Halasina Kadubu': 'Jackfruit idli kadubu Karnataka',
    'Halasina Hannina Idli': 'Jackfruit steamed cake idli',
    'Kesuvina Pathrode': 'Patra colocasia leaves roll',
    'Kanile Palya': 'Bamboo shoot curry Karnataka',
    'Kanile Curry': 'Bamboo shoot curry Indian',
    'Huli Avalakki': 'Gojju Avalakki Poha Karnataka',
    'Malnad Chicken Curry': 'Karnataka style chicken curry',
    'Malnad Chicken Sukka': 'Kori Sukka chicken Karnataka',
    'Malnad Mutton Curry': 'Karnataka mutton curry',
    'Malnad Fish Curry': 'Mangalore fish curry',
    'Kayi Kadubu': 'Modak sweet coconut dumpling',
    'Tambli': 'Tambli Karnataka yogurt curry',
    'Ginger Tambli': 'Shunti Tambli Karnataka',
    'Curry Leaves Tambli': 'Karibevu Tambli Karnataka',
    'Brahmi Tambli': 'Ondelaga Tambli Karnataka',
    'Majjige Huli': 'Majjige Huli buttermilk curry',
    'Soppina Palya': 'Greens stir fry Karnataka Keerai',
    'Bassaru': 'Bassaru Karnataka dill lentil rasam',
    'Huruli Saaru': 'Horse gram rasam Karnataka',
    'Horse Gram Palya': 'Horse gram stir fry Usli',
    'Jackfruit Palya': 'Raw jackfruit subzi Kathal dry',
    'Raw Jackfruit Curry': 'Kathal curry jackfruit Indian',
    'Jackfruit Payasa': 'Jackfruit payasam kheer',
    'Halasina Hannina Mulka': 'Jackfruit fritters sweet Karnataka',
    'Bamboo Shoot Fry': 'Bamboo shoot fry dry Karnataka',
    'Bamboo Shoot Sambar': 'Bamboo shoot sambar',
    'Malnad Style Vegetable Sambar': 'Karnataka Udupi sambar vegetable',
    'Malnad Style Rasam': 'Mysore Rasam Karnataka',
    'Mango Gojju': 'Mavinkayi Gojju sweet sour mango curry',
    'Pineapple Gojju': 'Pineapple Gojju Karnataka curry',
    'Appe Midi Pickle': 'Appe Midi tender mango pickle Karnataka',
    'Ragi Mudde': 'Ragi Mudde finger millet ball Karnataka',
    'Ragi Rotti': 'Ragi Rotti Karnataka',
    'Rice Kadubu': 'Undrallu rice dumplings savory',
    'Thambittu': 'Thambittu Karnataka sweet roasted gram',
    'Nuchinunde': 'Nuchinunde steamed lentil dumplings',
    'Shavige Bath': 'Shavige Bath vermicelli upma Karnataka',
    'Malnad Coconut Rice': 'Coconut rice Karnataka style',
    'Malnad Puliyogare': 'Karnataka Puliyogare tamarind rice',
    'Avarekalu Saaru': 'Avarekalu Saaru field beans curry',
    'Malnad Vegetable Kurma': 'Udupi vegetable kurma',
    'Sabsige Soppu Palya': 'Dill leaves stir fry Karnataka',
    'Menthya Soppu Palya': 'Methi leaves stir fry Karnataka',
    'Kadubu with Coconut Chutney': 'Steamed rice cake coconut chutney',
    'Kadale Chutney': 'Roasted gram chutney Karnataka',
    'Coconut Chutney (Malnad Style)': 'Fresh green coconut chutney',
    'Malnad Lemon Pickle': 'South Indian spicy lemon pickle',
}

def search_wikimedia(query):
    try:
        url = f'https://commons.wikimedia.org/w/api.php?action=query&generator=search&gsrnamespace=6&gsrsearch={urllib.parse.quote(query)}&gsrlimit=5&prop=imageinfo&iiprop=url|mime|size&format=json'
        req = urllib.request.Request(url, headers={'User-Agent': 'CookMateFoodApp/1.0 (contact@cookmate.local)'})
        with urllib.request.urlopen(req, timeout=6) as res:
            data = json.loads(res.read().decode('utf-8'))
            pages = data.get('query', {}).get('pages', {})
            urls = []
            for p in pages.values():
                info = p.get('imageinfo', [])
                if info:
                    img_url = info[0].get('url', '')
                    mime = info[0].get('mime', '')
                    # only jpg/png/webp
                    if mime.startswith('image/') and not mime.endswith('svg+xml') and not mime.endswith('gif'):
                        urls.append(img_url)
            return urls
    except Exception as e:
        return []

def download_image(url):
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'CookMateFoodApp/1.0 (contact@cookmate.local)'})
        with urllib.request.urlopen(req, timeout=10) as res:
            data = res.read()
            if len(data) > 5000:
                img = Image.open(io.BytesIO(data))
                img = img.convert('RGB')
                return img
    except Exception as e:
        pass
    return None

def process_and_save_image(img, target_path, width=800, height=600):
    # Crop to 4:3 landscape ratio and resize
    target_ratio = width / height
    img_ratio = img.width / img.height

    if img_ratio > target_ratio:
        # Image is wider: crop left and right
        new_width = int(img.height * target_ratio)
        left = (img.width - new_width) // 2
        img = img.crop((left, 0, left + new_width, img.height))
    else:
        # Image is taller: crop top and bottom
        new_height = int(img.width / target_ratio)
        top = (img.height - new_height) // 2
        img = img.crop((0, top, img.width, top + new_height))

    img = img.resize((width, height), Image.Resampling.LANCZOS)
    img.save(target_path, 'JPEG', quality=85, optimize=True)

used_hashes = set()
recipe_results = []

for idx, (rid, title, desc, chef, cuisine, img_url) in enumerate(matches):
    filename = os.path.basename(img_url)
    target_path = os.path.join(OUTPUT_DIR, filename)

    query = SEARCH_TERMS.get(title, f"{title} {cuisine} food")
    print(f"[{idx+1}/200] Sourcing image for '{title}' (query: '{query}')...")

    img_urls = search_wikimedia(query)
    if not img_urls:
        # Fallback queries
        img_urls = search_wikimedia(f"{title} Indian dish")
    if not img_urls:
        img_urls = search_wikimedia(title)

    saved = False
    for candidate_url in img_urls:
        downloaded = download_image(candidate_url)
        if downloaded:
            # Check unique hash after temporary processing
            buf = io.BytesIO()
            # Crop to 4:3
            target_ratio = 800 / 600
            img_ratio = downloaded.width / downloaded.height
            if img_ratio > target_ratio:
                new_width = int(downloaded.height * target_ratio)
                left = (downloaded.width - new_width) // 2
                cropped = downloaded.crop((left, 0, left + new_width, downloaded.height))
            else:
                new_height = int(downloaded.width / target_ratio)
                top = (downloaded.height - new_height) // 2
                cropped = downloaded.crop((0, top, downloaded.width, top + new_height))
            cropped = cropped.resize((800, 600), Image.Resampling.LANCZOS)
            cropped.save(buf, 'JPEG', quality=85, optimize=True)
            data_bytes = buf.getvalue()
            h = hashlib.md5(data_bytes).hexdigest()

            if h not in used_hashes:
                used_hashes.add(h)
                with open(target_path, 'wb') as fp:
                    fp.write(data_bytes)
                print(f"  ✓ Saved unique image ({len(data_bytes)} bytes, hash: {h[:8]}) -> {filename}")
                saved = True
                recipe_results.append((rid, title, filename, h, True))
                break

    if not saved:
        print(f"  ⚠ Needs specialized image synthesis or fallback for '{title}'")
        recipe_results.append((rid, title, filename, None, False))

    time.sleep(0.1)

print("\n--- Summary of First Pass ---")
print(f"Total recipes: {len(matches)}")
print(f"Successfully sourced unique images: {len([r for r in recipe_results if r[4]])}")
print(f"Remaining needed: {len([r for r in recipe_results if not r[4]])}")
