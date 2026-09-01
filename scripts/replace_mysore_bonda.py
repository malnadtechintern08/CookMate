import os
from PIL import Image

uploaded_img_path = '/Users/apple/.gemini/antigravity-ide/brain/1196ce16-d2d9-46db-8f5c-d704a94140e5/.user_uploaded/media_1788255515166.jpg'
target_img_path = 'assets/images/recipes/mysore_bonda.jpg'

if not os.path.exists(uploaded_img_path):
    # Try alternate temp storage path
    uploaded_img_path = '/Users/apple/.gemini/antigravity-ide/brain/1196ce16-d2d9-46db-8f5c-d704a94140e5/.tempmediaStorage/media_1788255512607.jpg'

print(f"Reading uploaded image from: {uploaded_img_path}")
img = Image.open(uploaded_img_path).convert('RGB')
print(f"Original image size: {img.size}")

# The user image is vertical (portrait).
# Let's crop around the center focus (the golden Mysore bondas and coconut chutney)
# Target landscape 800x600 (aspect ratio 4:3 = 1.333)
target_w, target_h = 800, 600
target_ratio = target_w / target_h

# Since the original image is tall (portrait), we want to crop the central/lower portion where the plate with the bondas and chutney is located
img_ratio = img.width / img.height

if img_ratio < target_ratio:
    # Image is taller than target
    crop_height = int(img.width / target_ratio)
    # The bondas and plate are in the middle/lower portion of the image
    # Let's align slightly towards center/bottom
    top = int((img.height - crop_height) * 0.55)
    # ensure bounds
    top = max(0, min(img.height - crop_height, top))
    bottom = top + crop_height
    cropped = img.crop((0, top, img.width, bottom))
else:
    crop_width = int(img.height * target_ratio)
    left = (img.width - crop_width) // 2
    cropped = img.crop((left, 0, left + crop_width, img.height))

resized = cropped.resize((target_w, target_h), Image.Resampling.LANCZOS)
resized.save(target_img_path, 'JPEG', quality=90, optimize=True)
print(f"Successfully replaced {target_img_path} with {target_w}x{target_h} high quality photo!")
