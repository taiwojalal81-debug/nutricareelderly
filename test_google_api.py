import urllib.request
import urllib.parse
import urllib.error
import json

API_KEY = "AIzaSyDxqCBE90JMsFsPqMP7tsgdk2mzREdbgFg"
CX = "e7db6f9091caa43b5"

def test_api():
    query = "Mosa Sweet Plantain Puff authentic food"
    url = f"https://www.googleapis.com/customsearch/v1?q={urllib.parse.quote(query)}&cx={CX}&key={API_KEY}&searchType=image&num=1"
    
    print(f"Testing URL: {url.replace(API_KEY, 'HIDDEN')}")
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    
    try:
        with urllib.request.urlopen(req, timeout=10) as response:
            data = json.loads(response.read().decode())
            print("SUCCESS! Response data:")
            print(json.dumps(data, indent=2)[:500] + "...\n")
            if 'items' in data and len(data['items']) > 0:
                print(f"Image found: {data['items'][0]['link']}")
            else:
                print("No items found.")
    except urllib.error.HTTPError as e:
        print(f"HTTP Error {e.code}: {e.reason}")
        error_body = e.read().decode()
        print("Error Body:")
        print(error_body)
    except Exception as e:
        print(f"Other Error: {e}")

if __name__ == '__main__':
    test_api()
