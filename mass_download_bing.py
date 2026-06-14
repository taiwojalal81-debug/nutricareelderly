import os
import re
import shutil
import time
from bing_image_downloader import downloader

MD_FILE = r"C:\Users\JALAL\Desktop\NutriCare\food_images_download_list.md"
ASSETS_DIR = r"C:\Users\JALAL\Desktop\NutriCare\assets\images"
DART_FILE = r"C:\Users\JALAL\Desktop\NutriCare\lib\core\utils\food_details_enricher.dart"

def sanitize(name):
    s = name.lower()
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

    pattern = re.compile(r'- \[( |x)\] \*\*(.*?)\*\*')
    matches = pattern.findall(md_content)

    existing_files = {f.split('.')[0]: f for f in os.listdir(ASSETS_DIR)}
    download_count = 0
    dish_to_asset = {}

    for state, dish_name in matches:
        sanitized = sanitize(dish_name)
        
        filename = None
        if sanitized in existing_files:
            filename = existing_files[sanitized]
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
        
        if state == ' ':  # It's unchecked
            print(f"Downloading image for {dish_name}...")
            query = f"{dish_name} Nigerian authentic food"
            if 'Foreign' in md_content[md_content.find(dish_name)-200:md_content.find(dish_name)]:
                query = f"{dish_name} food"
                
            try:
                downloader.download(query, limit=1, output_dir='temp_images', adult_filter_off=True, force_replace=True, timeout=10, verbose=False)
                
                # Check what was downloaded
                query_dir = os.path.join('temp_images', query)
                if os.path.exists(query_dir):
                    downloaded_files = os.listdir(query_dir)
                    if downloaded_files:
                        img_file = downloaded_files[0]
                        ext = img_file.split('.')[-1]
                        filename = f"{sanitized}.{ext}"
                        dest_path = os.path.join(ASSETS_DIR, filename)
                        
                        shutil.copy(os.path.join(query_dir, img_file), dest_path)
                        print(f" -> Saved {filename}")
                        download_count += 1
                        
                        md_content = md_content.replace(f"- [ ] **{dish_name}**", f"- [x] **{dish_name}**")
                    shutil.rmtree(query_dir)
            except Exception as e:
                print(f" -> Failed: {e}")
                
            time.sleep(1) # slight delay to avoid blocks
            
        if filename:
            dish_to_asset[dish_name] = f"assets/images/{filename}"

    with open(MD_FILE, 'w', encoding='utf-8') as f:
        f.write(md_content)

    print(f"Finished downloading {download_count} new images.")
    if os.path.exists('temp_images'):
        shutil.rmtree('temp_images')

    with open(DART_FILE, 'r', encoding='utf-8') as f:
        dart_content = f.read()

    map_code = "  static const Map<String, String> _imageMap = {\n"
    for dish, asset in dish_to_asset.items():
        dish_esc = dish.replace("'", "\\'")
        map_code += f"    '{dish_esc}': '{asset}',\n"
    map_code += "  };\n\n"
    
    new_method = map_code + """  static String getAuthenticFoodImageUrl(String foodName) {
    if (_imageMap.containsKey(foodName)) {
      return _imageMap[foodName]!;
    }
    final lowerName = foodName.toLowerCase();
    for (var entry in _imageMap.entries) {
      if (lowerName.contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    return 'assets/images/efo_riro.jfif';
  }"""

    pattern = re.compile(r'  static String getAuthenticFoodImageUrl\(String foodName\) \{.*?(?=  static Widget buildFoodImage)', re.DOTALL)
    if pattern.search(dart_content):
        dart_content = pattern.sub(new_method + '\n\n', dart_content)
        with open(DART_FILE, 'w', encoding='utf-8') as f:
            f.write(dart_content)
        print("Updated food_details_enricher.dart with perfect mappings!")
    else:
        print("Pattern not found in food_details_enricher.dart")

if __name__ == '__main__':
    main()
