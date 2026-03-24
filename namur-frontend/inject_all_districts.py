import os
import json

base_dir = r"d:\Downloads\Namur-Frontend-main (1)\namur-frontend\assets\translations"

# Karnataka Districts translations
translations = {
    "en-US.json": {
        "bagalkote": "Bagalkote", "bengaluru": "Bengaluru", "bengaluru rural": "Bengaluru Rural", "bengaluru urban": "Bengaluru Urban", "belagavi": "Belagavi", "ballari": "Ballari", "bidar": "Bidar", "chamarajanagara": "Chamarajanagara", "chikkaballapura": "Chikkaballapura", "chikkamagaluru": "Chikkamagaluru", "chitradurga": "Chitradurga", "dakshina kannada": "Dakshina Kannada", "davanagere": "Davanagere", "dharwad": "Dharwad", "gadag": "Gadag", "kalaburagi": "Kalaburagi", "hassan": "Hassan", "haveri": "Haveri", "kodagu": "Kodagu", "kolar": "Kolar", "koppal": "Koppal", "mandya": "Mandya", "mysuru": "Mysuru", "raichur": "Raichur", "ramanagara": "Ramanagara", "shivamogga": "Shivamogga", "tumakuru": "Tumakuru", "udupi": "Udupi", "uttara kannada": "Uttara Kannada", "vijayapura": "Vijayapura", "yadgir": "Yadgir", "gorakhpur": "Gorakhpur"
    },
    "kn-IN.json": {
        "bagalkote": "ಬಾಗಲಕೋಟೆ", "bengaluru": "ಬೆಂಗಳೂರು", "bengaluru rural": "ಬೆಂಗಳೂರು ಗ್ರಾಮಾಂತರ", "bengaluru urban": "ಬೆಂಗಳೂರು ನಗರ", "belagavi": "ಬೆಳಗಾವಿ", "ballari": "ಬಳ್ಳಾರಿ", "bidar": "ಬೀದರ್", "chamarajanagara": "ಚಾಮರಾಜನಗರ", "chikkaballapura": "ಚಿಕ್ಕಬಳ್ಳಾಪುರ", "chikkamagaluru": "ಚಿಕ್ಕಮಗಳೂರು", "chitradurga": "ಚಿತ್ರದುರ್ಗ", "dakshina kannada": "ದಕ್ಷಿಣ ಕನ್ನಡ", "davanagere": "ದಾವಣಗೆರೆ", "dharwad": "ಧಾರವಾಡ", "gadag": "ಗದಗ", "kalaburagi": "ಕಲಬುರಗಿ", "hassan": "ಹಾಸನ", "haveri": "ಹಾವೇರಿ", "kodagu": "ಕೊಡಗು", "kolar": "ಕೋಲಾರ", "koppal": "ಕೊಪ್ಪಳ", "mandya": "ಮಂಡ್ಯ", "mysuru": "ಮೈಸೂರು", "raichur": "ರಾಯಚೂರು", "ramanagara": "ರಾಮನಗರ", "shivamogga": "ಶಿವಮೊಗ್ಗ", "tumakuru": "ತುಮಕೂರು", "udupi": "ಉಡುಪಿ", "uttara kannada": "ಉತ್ತರ ಕನ್ನಡ", "vijayapura": "ವಿಜಯಪುರ", "yadgir": "ಯಾದಗಿರಿ", "gorakhpur": "ಗೋರಖ್ಪುರ"
    },
    "hi-IN.json": {
        "bagalkote": "बागलकोट", "bengaluru": "बेंगलुरु", "bengaluru rural": "बेंगलुरु ग्रामीण", "bengaluru urban": "बेंगलुरु शहरी", "belagavi": "बेलगावी", "ballari": "बल्लारी", "bidar": "बीदर", "chamarajanagara": "चामराजनगर", "chikkaballapura": "चिक्कबल्लापुर", "chikkamagaluru": "चिक्कमगलुरु", "chitradurga": "चित्रदुर्ग", "dakshina kannada": "दक्षिण कन्नड़", "davanagere": "दावणगेरे", "dharwad": "धारवाड़", "gadag": "गदग", "kalaburagi": "कलबुर्गी", "hassan": "हासन", "haveri": "हावेरी", "kodagu": "कोडागु", "kolar": "कोलार", "koppal": "कोप्पल", "mandya": "मंड्या", "mysuru": "मैसूरु", "raichur": "रायचूर", "ramanagara": "रामनगर", "shivamogga": "शिवमोग्गा", "tumakuru": "तुमकुरु", "udupi": "उडुपी", "uttara kannada": "उत्तर कन्नड़", "vijayapura": "विजयपुरा", "yadgir": "यादगीर", "gorakhpur": "गोरखपुर"
    },
    "mr-IN.json": {
        "bagalkote": "बागलकोट", "bengaluru": "बेंगळुरू", "bengaluru rural": "बेंगळुरू ग्रामीण", "bengaluru urban": "बेंगळुरू शहरी", "belagavi": "बेळगाव", "ballari": "बळ्ळारी", "bidar": "बीदर", "chamarajanagara": "चामराजनगर", "chikkaballapura": "चिक्कबळ्ळापूर", "chikkamagaluru": "चिक्कमगळूरु", "chitradurga": "चित्रदुर्ग", "dakshina kannada": "दक्षिण कन्नड", "davanagere": "दावणगेरे", "dharwad": "धारवाड", "gadag": "गदग", "kalaburagi": "कलबुर्गी", "hassan": "हासन", "haveri": "हावेरी", "kodagu": "कोडागू", "kolar": "कोलार", "koppal": "कोप्पळ", "mandya": "मंड्या", "mysuru": "मैसूरु", "raichur": "रायचूर", "ramanagara": "रामनगर", "shivamogga": "शिवमोग्गा", "tumakuru": "तुमकुर", "udupi": "उडुपी", "uttara kannada": "उत्तर कन्नड", "vijayapura": "विजापूर", "yadgir": "यादगीर", "gorakhpur": "गोरखपूर"
    },
    "te-IN.json": {
        "bagalkote": "బాగల్‌కోట్", "bengaluru": "బెంగళూరు", "bengaluru rural": "బెంగళూరు గ్రామీణ", "bengaluru urban": "బెంగళూరు పట్టణ", "belagavi": "బెలగావి", "ballari": "బళ్ళారి", "bidar": "బీదర్", "chamarajanagara": "చామరాజనగర", "chikkaballapura": "చిక్కబళ్ళాపూర్", "chikkamagaluru": "చిక్కమగళూరు", "chitradurga": "చిత్రదుర్గ", "dakshina kannada": "దక్షిణ కన్నడ", "davanagere": "దావణగెరె", "dharwad": "ధార్వాడ్", "gadag": "గదగ్", "kalaburagi": "కలబురగి", "hassan": "హాసన్", "haveri": "హవేరి", "kodagu": "కొడగు", "kolar": "కోలార్", "koppal": "కొప్పల్", "mandya": "మండ్య", "mysuru": "మైసూరు", "raichur": "రాయచూర్", "ramanagara": "రామనగర్", "shivamogga": "శివమొగ్గ", "tumakuru": "తుమకూరు", "udupi": "ఉడిపి", "uttara kannada": "ఉత్తర కన్నడ", "vijayapura": "విజయపుర", "yadgir": "యాదగిరి", "gorakhpur": "గోరఖ్‌పూర్"
    },
    "ta-IN.json": {
        "bagalkote": "பாகல்கோட்", "bengaluru": "பெங்களூரு", "bengaluru rural": "பெங்களூரு ஊரகம்", "bengaluru urban": "பெங்களூரு நகர்ப்புறம்", "belagavi": "பெலகாவி", "ballari": "பள்ளாரி", "bidar": "பீதர்", "chamarajanagara": "சாமராஜநகர", "chikkaballapura": "சிக்கபல்லாபூர்", "chikkamagaluru": "சிக்கமகளூரு", "chitradurga": "சித்ரதுர்கா", "dakshina kannada": "தட்சிண கன்னடா", "davanagere": "தாவணகெரே", "dharwad": "தார்வாட்", "gadag": "கடக்", "kalaburagi": "கலபுர்கி", "hassan": "ஹாசன்", "haveri": "ஹவேரி", "kodagu": "குடகு", "kolar": "கோலார்", "koppal": "கொப்பல்", "mandya": "மண்டியா", "mysuru": "மைசூரு", "raichur": "ராயச்சூர்", "ramanagara": "ராமநகரா", "shivamogga": "சிவமொக்கா", "tumakuru": "துமகூரு", "udupi": "உடுப்பி", "uttara kannada": "உத்தர கன்னடா", "vijayapura": "விஜயபுரா", "yadgir": "யாதகிரி", "gorakhpur": "கோரக்பூர்"
    },
    "ml-IN.json": {
        "bagalkote": "ബാഗൽകോട്ട്", "bengaluru": "ബെംഗളൂരു", "bengaluru rural": "ബെംഗളൂരു റൂറൽ", "bengaluru urban": "ബെംഗളൂരു അർബൻ", "belagavi": "ബെലഗാവി", "ballari": "ബെല്ലാരി", "bidar": "ബീദർ", "chamarajanagara": "ചാമരാജ നഗര", "chikkaballapura": "ചിക്കബെല്ലാപ്പൂർ", "chikkamagaluru": "ചിക്കമംഗ്ളൂരു", "chitradurga": "ചിത്രദുർഗ", "dakshina kannada": "ദക്ഷിണ കന്നഡ", "davanagere": "ദാവണഗരെ", "dharwad": "ധാർവാഡ്", "gadag": "ഗദഗ്", "kalaburagi": "കൽബുർഗി", "hassan": "ഹാസൻ", "haveri": "ഹാവേരി", "kodagu": "കൊടക്", "kolar": "കോലാർ", "koppal": "കൊപ്പാൽ", "mandya": "മാണ്ഡ്യ", "mysuru": "മൈസൂരു", "raichur": "റായ്ച്ചൂർ", "ramanagara": "രാമനഗര", "shivamogga": "ശിവമൊഗ്ഗ", "tumakuru": "തുമക്കൂർ", "udupi": "ഉഡുപ്പി", "uttara kannada": "ഉത്തര കന്നഡ", "vijayapura": "വിജയപുര", "yadgir": "യാദ്ഗിരി", "gorakhpur": "ഗോരഖ്പൂർ"
    },
    "bn-IN.json": {
        "bagalkote": "বাগালকোট", "bengaluru": "বেঙ্গালুরু", "bengaluru rural": "বেঙ্গালুরু গ্রামীণ", "bengaluru urban": "বেঙ্গালুরু শহুরে", "belagavi": "বেলাগাভি", "ballari": "বল্লারি", "bidar": "বিদার", "chamarajanagara": "চামরাজনগর", "chikkaballapura": "চিক্কাবল্লাপুর", "chikkamagaluru": "চিক্কামাগালুরু", "chitradurga": "চিত্রদুর্গ", "dakshina kannada": "দক্ষিন কন্নড়", "davanagere": "দাভাঙ্গেরে", "dharwad": "ধারওয়াড়", "gadag": "গাদাগ", "kalaburagi": "কালাবুর্গি", "hassan": "হাসান", "haveri": "হাভেরি", "kodagu": "কোদাগু", "kolar": "কোলার", "koppal": "কোপ্পাল", "mandya": "মাণ্ড্য", "mysuru": "মহীশূর", "raichur": "রাইচুর", "ramanagara": "রামানগরা", "shivamogga": "শিবমোগ্গা", "tumakuru": "তুমাকুরু", "udupi": "উড়ুপি", "uttara kannada": "উত্তর কন্নড়", "vijayapura": "বিজয়পুরা", "yadgir": "যাদগিরি", "gorakhpur": "গোরক্ষপুর"
    }
}

for filename, trans in translations.items():
    filepath = os.path.join(base_dir, filename)
    if os.path.exists(filepath):
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        # Merge new translations
        for key, value in trans.items():
            data[key] = value
            
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
            
print("Generated translations for 30 Karnataka districts across 8 languages.")
