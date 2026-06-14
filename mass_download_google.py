import os
import re
import urllib.request
import urllib.error
import time
import json

API_KEY = "AIzaSyDxqCBE90JMsFsPqMP7tsgdk2mzREdbgFg"
CX = "e7db6f9091caa43b5"

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

def search_google_images(query):
    url = f"https://www.googleapis.com/customsearch/v1?q={urllib.parse.quote(query)}&cx={CX}&key={API_KEY}&searchType=image&num=1"
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    try:
        with urllib.request.urlopen(req, timeout=10) as response:
            data = json.loads(response.read().decode())
            if 'items' in data and len(data['items']) > 0:
                return data['items'][0]['link']
    except Exception as e:
        print(f"Error fetching from Google API: {e}")
    return None

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
        
        if state == ' ' and not filename:  # It's unchecked and no local override found
            print(f"Downloading image for {dish_name}...")
            query = f"{dish_name} Nigerian authentic food"
            if 'Foreign Dishes' in md_content[max(0, md_content.find(dish_name)-1000):md_content.find(dish_name)]:
                query = f"{dish_name} high quality food"

            img_url = search_google_images(query)
            if img_url:
                ext = img_url.split('.')[-1][:4].split('?')[0]
                if ext.lower() not in ['jpg', 'jpeg', 'png', 'webp', 'jfif']:
                    ext = 'jpg'
                filename = f"{sanitized}.{ext}"
                filepath = os.path.join(ASSETS_DIR, filename)
                
                try:
                    req = urllib.request.Request(img_url, headers={'User-Agent': 'Mozilla/5.0'})
                    with urllib.request.urlopen(req, timeout=10) as response, open(filepath, 'wb') as out_file:
                        data = response.read()
                        out_file.write(data)
                    
                    print(f" -> Saved {filename}")
                    download_count += 1
                    
                    md_content = md_content.replace(f"- [ ] **{dish_name}**", f"- [x] **{dish_name}**")
                except Exception as e:
                    print(f" -> Failed to download image from {img_url}: {e}")
            else:
                print(f" -> No image found or API error for {dish_name}")
                
            time.sleep(0.5)
            
        if filename:
            dish_to_asset[dish_name] = f"assets/images/{filename}"

    with open(MD_FILE, 'w', encoding='utf-8') as f:
        f.write(md_content)

    print(f"Finished downloading {download_count} new images.")

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
