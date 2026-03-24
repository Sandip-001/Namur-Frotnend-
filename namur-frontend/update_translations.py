import os
import json

base_dir = r"d:\Downloads\Namur-Frontend-main (1)\namur-frontend\assets\translations"

translations = {
    "en-US.json": {"animal": "Animal", "food": "Food", "machinery": "Machinery", "market": "Market"},
    "bn-IN.json": {"animal": "প্রাণী", "food": "খাদ্য", "machinery": "যন্ত্রপাতি", "market": "বাজার"},
    "hi-IN.json": {"animal": "पशु", "food": "भोजन", "machinery": "मशीनरी", "market": "बाज़ार"},
    "kn-IN.json": {"animal": "ಪ್ರಾಣಿ", "food": "ಆಹಾರ", "machinery": "ಯಂತ್ರೋಪಕರಣ", "market": "ಮಾರುಕಟ್ಟೆ"},
    "ml-IN.json": {"animal": "മൃഗം", "food": "ഭക്ഷണം", "machinery": "യന്ത്രങ്ങൾ", "market": "മാർക്കറ്റ്"},
    "mr-IN.json": {"animal": "प्राणी", "food": "अन्न", "machinery": "यंत्रसामग्री", "market": "बाजार"},
    "ta-IN.json": {"animal": "விலங்கு", "food": "உணவு", "machinery": "இயந்திரங்கள்", "market": "சந்தை"},
    "te-IN.json": {"animal": "జంతువు", "food": "ఆహారం", "machinery": "యంత్రాలు", "market": "మార్కెట్"}
}

for filename, trans in translations.items():
    filepath = os.path.join(base_dir, filename)
    if os.path.exists(filepath):
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
        data.update(trans)
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
            
print("Translations updated successfully")
