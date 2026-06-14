import os
import re
import urllib.request
import time
from duckduckgo_search import DDGS

MD_FILE = r"C:\Users\JALAL\Desktop\NutriCare\food_images_download_list.md"
ASSETS_DIR = r"C:\Users\JALAL\Desktop\NutriCare\assets\images"
DART_FILE = r"C:\Users\JALAL\Desktop\NutriCare\lib\core\utils\food_details_enricher.dart"

def sanitize(name):
    s = name.lower()
    # Handle specific names like "Moi Moi" -> "moimoi" to match the user's jfif
    if name == "Ekuru (White Moi Moi)": return "ekuru"
    if name == "Akara (Bean Cakes)": return "akara"
    s = re.sub(r'\s+', '_', s)
    s = re.sub(r'[^a-z0-9_]', '', s)
    return s

def main():
    if not os.path.exists(ASSETS_DIR):
        os.makedirs(ASSETS_DIR)

    with open(MD_FILE, 'r', encoding='utf-8') as f:
        md_content = f.read()

    # Find all dishes: - [ ] **Dish Name**
    pattern = re.compile(r'- \[( |x)\] \*\*(.*?)\*\*')
    matches = pattern.findall(md_content)

    existing_files = {f.split('.')[0]: f for f in os.listdir(ASSETS_DIR)}
    
    ddgs = DDGS()
    download_count = 0
    
    dish_to_asset = {}

    for state, dish_name in matches:
        sanitized = sanitize(dish_name)
        
        # Check if we already have it (either exact match or we have an override)
        filename = None
        if sanitized in existing_files:
            filename = existing_files[sanitized]
        # Some custom mappings for the user's jfif files
        elif 'amala' in sanitized and 'ewedu' in sanitized: filename = 'amala_and_ewedu.jfif'
        elif 'efo_riro' in sanitized: filename = 'efo_riro.jfif'
        elif 'gbegiri' in sanitized: filename = 'gbegiri_soup.jfif'
        elif 'ofada' in sanitized: filename = 'ofada_rice.jfif'
        elif 'ayamase' in sanitized: filename = 'ayamase_stew_sauce.jfif'
        elif 'iyan' in sanitized or 'pounded' in sanitized: filename = 'iyan.jfif'
        elif 'dodo' in sanitized: filename = 'dodo.jfif'
        elif 'boli' in sanitized: filename = 'boli.jfif'
        elif 'ikokore' in sanitized: filename = 'ikokore.jfif'
        elif 'moimoi' in sanitized or 'moi_moi' in sanitized: filename = 'moimoi.jfif'
        elif 'ila_alase' in sanitized: filename = 'ila_alasepo.jpg'
        
        if not filename:
            print(f"Downloading image for {dish_name}...")
            query = f"{dish_name} food"
            try:
                results = ddgs.images(query, max_results=1)
                if results:
                    img_url = results[0]['image']
                    ext = img_url.split('.')[-1][:4].split('?')[0]
                    if ext not in ['jpg', 'jpeg', 'png', 'webp']:
                        ext = 'jpg'
                    filename = f"{sanitized}.{ext}"
                    filepath = os.path.join(ASSETS_DIR, filename)
                    
                    req = urllib.request.Request(img_url, headers={'User-Agent': 'Mozilla/5.0'})
                    with urllib.request.urlopen(req, timeout=10) as response, open(filepath, 'wb') as out_file:
                        data = response.read()
                        out_file.write(data)
                    
                    print(f" -> Saved {filename}")
                    download_count += 1
                    time.sleep(1)  # Be polite to duckduckgo
                    
                    # Update MD
                    md_content = md_content.replace(f"- [ ] **{dish_name}**", f"- [x] **{dish_name}**")
                else:
                    print(f" -> No results found for {dish_name}")
            except Exception as e:
                print(f" -> Failed: {e}")
        else:
            # Already exists, just mark it done in MD
            md_content = md_content.replace(f"- [ ] **{dish_name}**", f"- [x] **{dish_name}**")
            
        if filename:
            dish_to_asset[dish_name] = f"assets/images/{filename}"

    with open(MD_FILE, 'w', encoding='utf-8') as f:
        f.write(md_content)

    print(f"Finished downloading {download_count} new images.")

    # Now let's generate the dart mapping!
    with open(DART_FILE, 'r', encoding='utf-8') as f:
        dart_content = f.read()

    # Replace getAuthenticFoodImageUrl body
    map_code = "  static const Map<String, String> _imageMap = {\n"
    for dish, asset in dish_to_asset.items():
        # Escape single quotes
        dish_esc = dish.replace("'", "\\'")
        map_code += f"    '{dish_esc}': '{asset}',\n"
    map_code += "  };\n\n"
    
    new_method = map_code + """  static String getAuthenticFoodImageUrl(String foodName) {
    if (_imageMap.containsKey(foodName)) {
      return _imageMap[foodName]!;
    }
    // Fallback logic for unmapped names
    final lowerName = foodName.toLowerCase();
    for (var entry in _imageMap.entries) {
      if (lowerName.contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    return 'assets/images/efo_riro.jfif';
  }"""

    # We need to replace the existing getAuthenticFoodImageUrl method
    pattern = re.compile(r'  static String getAuthenticFoodImageUrl\(String foodName\) \{.*?(?=  static Widget buildFoodImage)', re.DOTALL)
    dart_content = pattern.sub(new_method + '\n\n', dart_content)

    with open(DART_FILE, 'w', encoding='utf-8') as f:
        f.write(dart_content)
    
    print("Updated food_details_enricher.dart with perfect mappings!")

if __name__ == '__main__':
    main()
