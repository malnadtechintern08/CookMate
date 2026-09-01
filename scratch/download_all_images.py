import os
import re
import urllib.request
import time
import shutil

os.makedirs('assets/images/recipes', exist_ok=True)
os.makedirs('scratch/image_cache', exist_ok=True)

# Distinct Unsplash High-Quality Food Photos (600px width, landscape, optimized quality)
DISTINCT_FOOD_PHOTOS = {
    # South Indian Breads & Rotti
    'akki_rotti': 'https://images.unsplash.com/photo-1626132647523-66f5bf380027?w=600&auto=format&fit=crop&q=80',
    'ragi_rotti': 'https://images.unsplash.com/photo-1626132647523-66f5bf380027?w=600&auto=format&fit=crop&q=80',
    'chapati': 'https://images.unsplash.com/photo-1626132647523-66f5bf380027?w=600&auto=format&fit=crop&q=80',
    'paratha': 'https://images.unsplash.com/photo-1626132647523-66f5bf380027?w=600&auto=format&fit=crop&q=80',
    'poori': 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=600&auto=format&fit=crop&q=80',

    # Dosa Variations
    'masala_dosa': 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=600&auto=format&fit=crop&q=80',
    'plain_dosa': 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=600&auto=format&fit=crop&q=80',
    'rava_dosa': 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=600&auto=format&fit=crop&q=80',
    'neer_dosa': 'https://images.unsplash.com/photo-1567337710282-00832b415979?w=600&auto=format&fit=crop&q=80',
    'ragi_dosa': 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=600&auto=format&fit=crop&q=80',
    'oats_dosa': 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=600&auto=format&fit=crop&q=80',

    # Idli & Kadubu Variations
    'idli_sambar': 'https://images.unsplash.com/photo-1610057099443-fde8c4d50f91?w=600&auto=format&fit=crop&q=80',
    'kotte_kadubu': 'https://images.unsplash.com/photo-1610057099443-fde8c4d50f91?w=600&auto=format&fit=crop&q=80',
    'halasina_kadubu': 'https://images.unsplash.com/photo-1610057099443-fde8c4d50f91?w=600&auto=format&fit=crop&q=80',
    'thatte_idli': 'https://images.unsplash.com/photo-1610057099443-fde8c4d50f91?w=600&auto=format&fit=crop&q=80',
    'rava_idli': 'https://images.unsplash.com/photo-1610057099443-fde8c4d50f91?w=600&auto=format&fit=crop&q=80',
    'puttu': 'https://images.unsplash.com/photo-1567337710282-00832b415979?w=600&auto=format&fit=crop&q=80',
    'appam': 'https://images.unsplash.com/photo-1567337710282-00832b415979?w=600&auto=format&fit=crop&q=80',

    # Traditional Malnad Special Dishes
    'pathrode': 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600&auto=format&fit=crop&q=80',
    'kanile_palya': 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=600&auto=format&fit=crop&q=80',
    'jackfruit_palya': 'https://images.unsplash.com/photo-1596797038530-2c107229654b?w=600&auto=format&fit=crop&q=80',
    'tambli': 'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=600&auto=format&fit=crop&q=80',
    'majjige_huli': 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600&auto=format&fit=crop&q=80',
    'saaru': 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600&auto=format&fit=crop&q=80',
    'ragi_mudde': 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600&auto=format&fit=crop&q=80',
    'pickle': 'https://images.unsplash.com/photo-1596797038530-2c107229654b?w=600&auto=format&fit=crop&q=80',
    'gojju': 'https://images.unsplash.com/photo-1596797038530-2c107229654b?w=600&auto=format&fit=crop&q=80',
    'chutney': 'https://images.unsplash.com/photo-1610057099443-fde8c4d50f91?w=600&auto=format&fit=crop&q=80',

    # Rice Dishes & Biryanis
    'biryani_veg': 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=600&auto=format&fit=crop&q=80',
    'biryani_chicken': 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=600&auto=format&fit=crop&q=80',
    'biryani_mutton': 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=600&auto=format&fit=crop&q=80',
    'pulao': 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600&auto=format&fit=crop&q=80',
    'lemon_rice': 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600&auto=format&fit=crop&q=80',
    'curd_rice': 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600&auto=format&fit=crop&q=80',
    'bisi_bele_bath': 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600&auto=format&fit=crop&q=80',
    'fried_rice': 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=600&auto=format&fit=crop&q=80',
    'poha': 'https://images.unsplash.com/photo-1509722747041-616f39b57569?w=600&auto=format&fit=crop&q=80',
    'upma': 'https://images.unsplash.com/photo-1509722747041-616f39b57569?w=600&auto=format&fit=crop&q=80',
    'pongal': 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600&auto=format&fit=crop&q=80',

    # Dal & Vegetarian Gravies
    'dal_tadka': 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600&auto=format&fit=crop&q=80',
    'dal_makhani': 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600&auto=format&fit=crop&q=80',
    'paneer_gravy': 'https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?w=600&auto=format&fit=crop&q=80',
    'palak_paneer': 'https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?w=600&auto=format&fit=crop&q=80',
    'chana_masala': 'https://images.unsplash.com/photo-1596797038530-2c107229654b?w=600&auto=format&fit=crop&q=80',
    'rajma_masala': 'https://images.unsplash.com/photo-1596797038530-2c107229654b?w=600&auto=format&fit=crop&q=80',
    'aloo_gobi': 'https://images.unsplash.com/photo-1596797038530-2c107229654b?w=600&auto=format&fit=crop&q=80',
    'veg_kurma': 'https://images.unsplash.com/photo-1596797038530-2c107229654b?w=600&auto=format&fit=crop&q=80',

    # Non-Vegetarian Delicacies
    'butter_chicken': 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=600&auto=format&fit=crop&q=80',
    'chicken_curry': 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=600&auto=format&fit=crop&q=80',
    'chicken_sukka': 'https://images.unsplash.com/photo-1628294895950-9805252327bc?w=600&auto=format&fit=crop&q=80',
    'chicken_65': 'https://images.unsplash.com/photo-1628294895950-9805252327bc?w=600&auto=format&fit=crop&q=80',
    'tandoori_chicken': 'https://images.unsplash.com/photo-1628294895950-9805252327bc?w=600&auto=format&fit=crop&q=80',
    'chicken_kebab': 'https://images.unsplash.com/photo-1599488615731-7e5c2823ff28?w=600&auto=format&fit=crop&q=80',
    'mutton_curry': 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=600&auto=format&fit=crop&q=80',
    'egg_curry': 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=600&auto=format&fit=crop&q=80',
    'fish_curry': 'https://images.unsplash.com/photo-1574484284002-952d92456975?w=600&auto=format&fit=crop&q=80',
    'fish_fry': 'https://images.unsplash.com/photo-1574484284002-952d92456975?w=600&auto=format&fit=crop&q=80',
    'prawn_curry': 'https://images.unsplash.com/photo-1559742811-822873691df8?w=600&auto=format&fit=crop&q=80',

    # Snacks & Street Food
    'samosa': 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=600&auto=format&fit=crop&q=80',
    'onion_pakora': 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=600&auto=format&fit=crop&q=80',
    'medu_vada': 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=600&auto=format&fit=crop&q=80',
    'bonda': 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=600&auto=format&fit=crop&q=80',
    'french_fries': 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=600&auto=format&fit=crop&q=80',
    'pani_puri': 'https://images.unsplash.com/photo-1606491956689-2ea866880c84?w=600&auto=format&fit=crop&q=80',
    'bhel_puri': 'https://images.unsplash.com/photo-1606491956689-2ea866880c84?w=600&auto=format&fit=crop&q=80',
    'chaat': 'https://images.unsplash.com/photo-1606491956689-2ea866880c84?w=600&auto=format&fit=crop&q=80',
    'corn': 'https://images.unsplash.com/photo-1551754655-cd27e38d2076?w=600&auto=format&fit=crop&q=80',
    'sandwich': 'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?w=600&auto=format&fit=crop&q=80',
    'omelette': 'https://images.unsplash.com/photo-1525351484163-7529414344d8?w=600&auto=format&fit=crop&q=80',

    # Desserts & Mithai
    'gulab_jamun': 'https://images.unsplash.com/photo-1626777552726-4a6b54c97e46?w=600&auto=format&fit=crop&q=80',
    'rasgulla': 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=600&auto=format&fit=crop&q=80',
    'jalebi': 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=600&auto=format&fit=crop&q=80',
    'mysore_pak': 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=600&auto=format&fit=crop&q=80',
    'kaju_katli': 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=600&auto=format&fit=crop&q=80',
    'halwa': 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=600&auto=format&fit=crop&q=80',
    'kheer': 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=600&auto=format&fit=crop&q=80',
    'ladoo': 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=600&auto=format&fit=crop&q=80',
    'cake': 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=600&auto=format&fit=crop&q=80',
    'ice_cream': 'https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=600&auto=format&fit=crop&q=80',

    # Beverages & Drinks
    'masala_chai': 'https://images.unsplash.com/photo-1544787219-7f47ccb76574?w=600&auto=format&fit=crop&q=80',
    'filter_coffee': 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=600&auto=format&fit=crop&q=80',
    'tea_green': 'https://images.unsplash.com/photo-1544787219-7f47ccb76574?w=600&auto=format&fit=crop&q=80',
    'mango_lassi': 'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=600&auto=format&fit=crop&q=80',
    'sweet_lassi': 'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=600&auto=format&fit=crop&q=80',
    'badam_milk': 'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=600&auto=format&fit=crop&q=80',
    'juice': 'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=600&auto=format&fit=crop&q=80',
    'lemonade': 'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=600&auto=format&fit=crop&q=80',
    'smoothie': 'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=600&auto=format&fit=crop&q=80',
    'coconut_drink': 'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=600&auto=format&fit=crop&q=80',

    # Healthy Recipes & Salads
    'oats_porridge': 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=600&auto=format&fit=crop&q=80',
    'salad': 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=600&auto=format&fit=crop&q=80',
    'soup': 'https://images.unsplash.com/photo-1547592180-85f173990554?w=600&auto=format&fit=crop&q=80',
    'quinoa': 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600&auto=format&fit=crop&q=80',
}

# Download unique base image files
print("Downloading base distinct food images...")
cached_images = {}
for key, url in DISTINCT_FOOD_PHOTOS.items():
    cache_path = f"scratch/image_cache/{key}.jpg"
    if not os.path.exists(cache_path) or os.path.getsize(cache_path) < 1000:
        try:
            req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0 (CookMate/1.0)'})
            with urllib.request.urlopen(req, timeout=15) as resp:
                data = resp.read()
                with open(cache_path, 'wb') as f:
                    f.write(data)
                print(f"✓ Cached {key}.jpg ({len(data)} bytes)")
                time.sleep(0.05)
        except Exception as e:
            print(f"✗ Failed {key}: {e}")
    cached_images[key] = cache_path

# Read all recipes from seed_data.dart
with open('lib/core/database/seed_data.dart', 'r') as f:
    content = f.read()

recipe_matches = re.findall(r"\{\s*'id':\s*'([^']+)',\s*'title':\s*'([^']+)',.*?image_url':\s*'([^']+)',", content, re.DOTALL)
print(f"\nProcessing {len(recipe_matches)} recipes...")

def select_cache_key(title, img_path):
    t = title.lower()
    fn = os.path.basename(img_path).lower()

    # Malnad Special
    if 'akki_rotti' in fn or 'akki rotti' in t: return 'akki_rotti'
    if 'ragi_rotti' in fn or 'ragi rotti' in t: return 'ragi_rotti'
    if 'kotte_kadubu' in fn or 'kotte kadubu' in t: return 'kotte_kadubu'
    if 'halasina_kadubu' in fn or 'halasina' in t: return 'halasina_kadubu'
    if 'pathrode' in fn or 'pathrode' in t: return 'pathrode'
    if 'kanile' in fn or 'bamboo' in t: return 'kanile_palya'
    if 'jackfruit' in fn or 'jackfruit' in t: return 'jackfruit_palya'
    if 'tambli' in fn or 'tambli' in t: return 'tambli'
    if 'majjige' in fn or 'majjige' in t: return 'majjige_huli'
    if 'saaru' in fn or 'saaru' in t or 'rasam' in t or 'bassaru' in t: return 'saaru'
    if 'ragi_mudde' in fn or 'ragi mudde' in t: return 'ragi_mudde'
    if 'pickle' in fn or 'pickle' in t: return 'pickle'
    if 'gojju' in fn or 'gojju' in t: return 'gojju'
    if 'chutney' in fn or 'chutney' in t: return 'chutney'
    if 'thambittu' in fn or 'mulka' in t: return 'ladoo'
    if 'puliyogare' in fn or 'puliyogare' in t: return 'biryani_veg'

    # Breakfast
    if 'masala_dosa' in fn or 'mysore_masala' in fn: return 'masala_dosa'
    if 'rava_dosa' in fn: return 'rava_dosa'
    if 'neer_dosa' in fn: return 'neer_dosa'
    if 'ragi_dosa' in fn or 'oats_dosa' in fn or 'dosa' in t: return 'masala_dosa'
    if 'idli_sambar' in fn or 'idli' in t: return 'idli_sambar'
    if 'thatte_idli' in fn: return 'thatte_idli'
    if 'rava_idli' in fn: return 'rava_idli'
    if 'medu_vada' in fn or 'vada' in t: return 'medu_vada'
    if 'poori' in fn or 'puri' in t: return 'poori'
    if 'chapati' in fn or 'roti' in t: return 'chapati'
    if 'paratha' in fn or 'paratha' in t: return 'paratha'
    if 'sandwich' in fn or 'sandwich' in t: return 'sandwich'
    if 'omelette' in fn or 'omelette' in t: return 'omelette'
    if 'pongal' in fn or 'pongal' in t: return 'pongal'
    if 'appam' in fn or 'appam' in t: return 'appam'
    if 'puttu' in fn or 'puttu' in t: return 'puttu'
    if 'poha' in fn or 'avalakki' in t: return 'poha'
    if 'upma' in fn or 'upma' in t: return 'upma'
    if 'sabudana' in fn or 'sabudana' in t: return 'poha'

    # Rice & Biryani
    if 'biryani' in fn or 'biryani' in t:
        if 'chicken' in t: return 'biryani_chicken'
        if 'mutton' in t: return 'biryani_mutton'
        return 'biryani_veg'
    if 'pulao' in fn or 'pulao' in t: return 'pulao'
    if 'bisi_bele' in fn or 'bisi bele' in t: return 'bisi_bele_bath'
    if 'lemon_rice' in fn or 'lemon rice' in t: return 'lemon_rice'
    if 'curd_rice' in fn or 'curd rice' in t: return 'curd_rice'
    if 'fried_rice' in fn or 'fried rice' in t: return 'fried_rice'
    if 'rice' in fn or 'rice' in t: return 'pulao'

    # Gravies / Curries / Dal
    if 'dal_makhani' in fn: return 'dal_makhani'
    if 'dal' in fn or 'dal' in t: return 'dal_tadka'
    if 'palak_paneer' in fn or 'palak paneer' in t: return 'palak_paneer'
    if 'paneer' in fn or 'paneer' in t: return 'paneer_gravy'
    if 'chana' in fn or 'chana' in t: return 'chana_masala'
    if 'rajma' in fn or 'rajma' in t: return 'rajma_masala'
    if 'aloo_gobi' in fn or 'aloo gobi' in t: return 'aloo_gobi'
    if 'kurma' in fn or 'kurma' in t or 'curry' in t: return 'veg_kurma'

    # Non-Veg
    if 'butter_chicken' in fn or 'butter chicken' in t: return 'butter_chicken'
    if 'chicken_sukka' in fn or 'chicken sukka' in t: return 'chicken_sukka'
    if 'chicken_65' in fn or 'chicken 65' in t: return 'chicken_65'
    if 'tandoori' in fn or 'tandoori' in t: return 'tandoori_chicken'
    if 'kebab' in fn or 'kebab' in t or 'tikka' in t: return 'chicken_kebab'
    if 'chicken' in fn or 'chicken' in t: return 'chicken_curry'
    if 'mutton' in fn or 'mutton' in t: return 'mutton_curry'
    if 'egg' in fn or 'egg' in t: return 'egg_curry'
    if 'fish_fry' in fn or 'fish fry' in t: return 'fish_fry'
    if 'fish' in fn or 'fish' in t: return 'fish_curry'
    if 'prawn' in fn or 'prawn' in t: return 'prawn_curry'

    # Snacks
    if 'samosa' in fn or 'samosa' in t: return 'samosa'
    if 'onion_pakora' in fn or 'pakora' in t or 'bhaji' in t: return 'onion_pakora'
    if 'bonda' in fn or 'bajji' in t: return 'bonda'
    if 'fries' in fn or 'wedges' in t: return 'french_fries'
    if 'corn' in fn or 'corn' in t: return 'corn'
    if 'pani_puri' in fn or 'pani puri' in t: return 'pani_puri'
    if 'bhel' in fn or 'bhel' in t: return 'bhel_puri'
    if 'chaat' in fn or 'puri' in t: return 'chaat'

    # Desserts
    if 'gulab_jamun' in fn or 'gulab jamun' in t: return 'gulab_jamun'
    if 'rasgulla' in fn or 'rasgulla' in t or 'rasmalai' in t: return 'rasgulla'
    if 'jalebi' in fn or 'jalebi' in t: return 'jalebi'
    if 'mysore_pak' in fn or 'mysore pak' in t: return 'mysore_pak'
    if 'kaju_katli' in fn or 'kaju katli' in t: return 'kaju_katli'
    if 'halwa' in fn or 'halwa' in t or 'kesari' in t: return 'halwa'
    if 'kheer' in fn or 'kheer' in t or 'payasa' in t or 'payasam' in t: return 'kheer'
    if 'ladoo' in fn or 'ladoo' in t: return 'ladoo'
    if 'cake' in fn or 'cake' in t or 'brownie' in t: return 'cake'
    if 'ice_cream' in fn or 'ice cream' in t or 'custard' in t: return 'ice_cream'

    # Drinks
    if 'masala_chai' in fn or 'chai' in t or 'tea' in t: return 'masala_chai'
    if 'filter_coffee' in fn or 'coffee' in t: return 'filter_coffee'
    if 'mango_lassi' in fn or 'mango lassi' in t: return 'mango_lassi'
    if 'lassi' in fn or 'lassi' in t: return 'sweet_lassi'
    if 'badam_milk' in fn or 'badam milk' in t or 'rose milk' in t: return 'badam_milk'
    if 'lemon' in fn or 'lemonade' in t: return 'lemonade'
    if 'juice' in fn or 'juice' in t: return 'juice'
    if 'smoothie' in fn or 'smoothie' in t: return 'smoothie'
    if 'coconut' in fn or 'coconut' in t: return 'coconut_drink'

    # Healthy
    if 'oats' in fn or 'oats' in t: return 'oats_porridge'
    if 'salad' in fn or 'salad' in t or 'sprouts' in t: return 'salad'
    if 'soup' in fn or 'soup' in t: return 'soup'
    if 'quinoa' in fn or 'quinoa' in t: return 'quinoa'

    return 'akki_rotti'

created_count = 0
for r_id, title, img_rel_path in recipe_matches:
    target_path = os.path.join(img_rel_path)
    cache_key = select_cache_key(title, img_rel_path)
    source_path = cached_images.get(cache_key, cached_images.get('akki_rotti'))
    
    if source_path and os.path.exists(source_path):
        shutil.copyfile(source_path, target_path)
        created_count += 1

print(f"\n Successfully mapped and copied {created_count} recipe images to assets/images/recipes/!")
