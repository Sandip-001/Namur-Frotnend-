import os
import json

base_dir = r"d:\Downloads\Namur-Frontend-main (1)\namur-frontend\assets\translations"

translations = {
    "en-US.json": {"clouds": "Clouds", "clear": "Clear", "rain": "Rain", "drizzle": "Drizzle", "thunderstorm": "Thunderstorm", "snow": "Snow", "bengaluru": "Bengaluru"},
    "bn-IN.json": {"clouds": "মেঘ", "clear": "পরিষ্কার", "rain": "বৃষ্টি", "drizzle": "গুঁড়ি গুঁড়ি বৃষ্টি", "thunderstorm": "বজ্রঝড়", "snow": "তুষার", "bengaluru": "বেঙ্গালুরু"},
    "hi-IN.json": {"clouds": "बादल", "clear": "साफ़", "rain": "बारिश", "drizzle": "बूंदाबांदी", "thunderstorm": "आंधी", "snow": "बर्फ", "bengaluru": "बेंगलुरु"},
    "kn-IN.json": {"clouds": "ಮೋಡಗಳು", "clear": "ಸ್ಪಷ್ಟ", "rain": "ಮಳೆ", "drizzle": "ತುಂತುರು ಮಳೆ", "thunderstorm": "ಗುಡುಗು", "snow": "ಹಿಮ", "bengaluru": "ಬೆಂಗಳೂರು"},
    "ml-IN.json": {"clouds": "മേഘങ്ങൾ", "clear": "വ്യക്തം", "rain": "മഴ", "drizzle": "ചാറ്റൽമഴ", "thunderstorm": "ഇടിമിന്നൽ", "snow": "മഞ്ഞ്", "bengaluru": "ബെംഗളൂരു"},
    "mr-IN.json": {"clouds": "ढग", "clear": "स्वच्छ", "rain": "पाऊस", "drizzle": "रिमझिम पाऊस", "thunderstorm": "वादळ", "snow": "बर्फ", "bengaluru": "बेंगळुरू"},
    "ta-IN.json": {"clouds": "மேகங்கள்", "clear": "தெளிவான", "rain": "மழை", "drizzle": "தூறல்", "thunderstorm": "இடியுடன் கூடிய மழை", "snow": "பனி", "bengaluru": "பெங்களூரு"},
    "te-IN.json": {"clouds": "మేఘాలు", "clear": "స్పష్టమైన", "rain": "వర్షం", "drizzle": "చినుకులు", "thunderstorm": "ఉరుములు", "snow": "మంచు", "bengaluru": "బెంగళూరు"}
}

for filename, trans in translations.items():
    filepath = os.path.join(base_dir, filename)
    if os.path.exists(filepath):
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
        data.update(trans)
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
            
print("Weather translations updated successfully")
