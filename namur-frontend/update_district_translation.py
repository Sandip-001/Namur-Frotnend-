import os
import json

base_dir = r"d:\Downloads\Namur-Frontend-main (1)\namur-frontend\assets\translations"

translations = {
    "en-US.json": {"gorakhpur": "Gorakhpur"},
    "bn-IN.json": {"gorakhpur": "গোরক্ষপুর"},
    "hi-IN.json": {"gorakhpur": "गोरखपुर"},
    "kn-IN.json": {"gorakhpur": "ಗೋರಖ್ಪುರ"},
    "ml-IN.json": {"gorakhpur": "ഗോരഖ്പൂർ"},
    "mr-IN.json": {"gorakhpur": "गोरखपूर"},
    "ta-IN.json": {"gorakhpur": "கோரக்பூர்"},
    "te-IN.json": {"gorakhpur": "గోరఖ్‌పూర్"}
}

for filename, trans in translations.items():
    filepath = os.path.join(base_dir, filename)
    if os.path.exists(filepath):
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
        data.update(trans) # this handles the "gorakhpur" key
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
            
print("District translation for Gorakhpur updated successfully.")
