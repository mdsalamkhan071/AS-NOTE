AS NOTS - Flutter Android App

इस शुरुआती संस्करण में:
- नोट बनाना, खोलना, एडिट करना और डिलीट करना
- नोट्स सर्च करना
- नोट्स फोन में ऑफलाइन सेव होना (SharedPreferences)
- Login/Cloud Sync नहीं है; ऐप डेटा इसी डिवाइस पर रहेगा।

GitHub पर सेटअप:
1. GitHub में नया repository बनाएं: as-nots
2. इस ZIP की सभी फाइलें repository के root में upload करें। .github फोल्डर भी शामिल करें।
3. GitHub Actions टैब खोलें और "Build AS NOTS Android" workflow चुनें।
4. Run workflow दबाएं।
5. Build पूरा होने पर Actions run खोलें -> Artifacts -> as-nots-release-apk डाउनलोड करें।

स्थानीय build:
flutter pub get
flutter build apk --release

Package ID:
com.asnots.as_nots

Package ID (पहली Play Store upload के बाद इसे बदलना नहीं): com.asnots.as_nots\n\nPlay Store के लिए:
- Play Console developer account बनाएं और one-time registration fee भरें।
- Play Console में नया app बनाएं।
- Release के लिए AAB बनाएं:
  flutter build appbundle --release
- build/app/outputs/bundle/release/app-release.aab अपलोड करें।
- App icon, screenshots, description, privacy policy, Data safety और content rating भरें।
- पहले Internal testing में test करें, फिर production review के लिए भेजें।

महत्वपूर्ण:
यह starter app है। Play Store पर भेजने से पहले अपने नाम, icon, screenshots और privacy policy को अंतिम करें।
SharedPreferences डेटा का cloud backup/sync नहीं करता। App uninstall करने पर notes मिट सकते हैं।
