# 🎵 Doganlar — Premium Saz Çalar App

<p align="center">
  <img src="assets/images/icon/app_icon.png" alt="Doganlar Logo" width="120" height="120" style="border-radius: 20%;" onerror="this.src='https://via.placeholder.com/120/1DB954/FFFFFF?text=Doganlar'">
</p>

<h3 align="center">Guwanç Hanmatow — Özel Premium Saz we Audio Pleýer Programmasy</h3>

<p align="center">
  <i>"Sazyň mukaddes dünýäsi we Guwanç Hanmatowyň söýülen aýdymlary indi çuňňur audio tejribesi bilen eliňizde!"</i>
</p>

<p align="center">
  <!-- Shields.io Badges -->
  <a href="https://flutter.dev/"><img src="https://img.shields.io/badge/Flutter-^3.22.0-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter"></a>
  <a href="https://dart.dev/"><img src="https://img.shields.io/badge/Dart-^3.4.0-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart"></a>
  <a href="https://riverpod.dev/"><img src="https://img.shields.io/badge/State_Management-Riverpod_2.6-00599C?style=for-the-badge&logo=riverpod&logoColor=white" alt="Riverpod"></a>
  <a href="#"><img src="https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge" alt="License"></a>
  <a href="#"><img src="https://img.shields.io/badge/Platform-Android_%7C_iOS_%7C_Windows_%7C_Linux_%7C_Web-blue?style=for-the-badge" alt="Platform"></a>
</p>

---

## 📌 Gysgaça Syn (Overview)

**Doganlar** — Türkmen pop we rep sungatynyň tanymal ýerine ýetirijisi **Guwanç Hanmatowyň** ähli albomlaryny, meşhur aýdymlaryny we saz eserlerini bir ýere jemleýän, döwrebap visual dizaýnly mobil we web audio pleýer programmasydyr. 

Programma **Kuba Prod** studiýasynyň goldawy we **Abdyrahman Döwletgulyýew** tarapyndan cross-platform (Flutter) tehnologiýasynda taýýarlandy. Ultra-modern Glassmorphism dizaýny, fona geçende päsgelsiz diňlemek (Background Playback) we Plastinka (Vinyl) stildäki animasiýaly pleýer interfeýsi bilen pökgi audio tejribesini hödürleýär.

---

## ✨ Özellikler (Features)

- 🎧 **Päsgelsiz Audio Dwigateli (Just Audio & MediaKit)**  
  Yzky fonda (Background Audio Service) we ekran gulplanan ýagdaýynda (Lockscreen Controls) aýdymlary bökdençsiz çalmak.
- 🎨 **Interaktiw Pleýer Stilleri (Vinyl & Modern Skins)**  
  Plastinka (Vinyl disc) aýlanýan retro-animasiýaly we minimalist modern dizaýnly 2 dürli pleýer görnüşi.
- 💎 **Premium Glassmorphism & UI Design**  
  Garaňky tema (Dark Mode) binasynda ýokary hilli glassmorphism efektleri hem-de dinamyk dizaýn visualy.
- 💿 **Doly Diskografiýa we Albomlar**  
  Awotryň ähli albomlary, trekler sanawy we tekje duwme bilen *"Hemmesini Çal"* (Play All) funksiýasy.
- ❤️ **Halanan Aýdymlar (Favorites Storage)**  
  Local storage (`SharedPreferences`) arkaly söýgüli aýdymlaryňyzy ýatda saklamak we aňsat dolandyrmak.
- 🎤 **Aýdym Sözleri (Lyrics Viewer)**  
  Diňlenilýän aýdymlaryň sözlerini ekranda görmek we bile diňlemek mümkinçiligi.
- 📤 **Sosial Paýlaşmak (Social Sharing)**  
  Görkezilýän aýdymy bir basmak bilen TikTok, IMO we beýleki sosial ulgamlarda dostlaryňyz bilen paýlaşmak.
- 🖥️ **Cross-Platform Goldawy**  
  Android, iOS, Windows, macOS, Linux we Web ulgamlarynda doly optimizirlenen işjeňlik.

---

## 🖼️ Ekran Görünüşleri (UI Gallery)

| 🏠 Esasy Sahypa | 🎵 Vinyl Pleýer | 💿 Albomlar | 👤 Awtor Sahypasy |
| :---: | :---: | :---: | :---: |
| <img src="https://raw.githubusercontent.com/Abdyrahmanp/doganlar_aydymy/main/assets/images/icon/app_icon.png" width="200" alt="Esasy Sahypa"/> | <img src="https://raw.githubusercontent.com/Abdyrahmanp/doganlar_aydymy/main/assets/images/icon/app_icon.png" width="200" alt="Vinyl Pleýer"/> | <img src="https://raw.githubusercontent.com/Abdyrahmanp/doganlar_aydymy/main/assets/images/icon/app_icon.png" width="200" alt="Albomlar"/> | <img src="https://raw.githubusercontent.com/Abdyrahmanp/doganlar_aydymy/main/assets/images/icon/app_icon.png" width="200" alt="Awtor Sahypasy"/> |

---

## 🛠️ Ulanylan Tehnologiýalar (Tech Stack)

### **Frontend & Architecture**
- **Framework:** [Flutter](https://flutter.dev/) (SDK ^3.4.0)
- **Language:** [Dart](https://dart.dev/)
- **State Management:** [Flutter Riverpod](https://riverpod.dev/) (`flutter_riverpod`, `riverpod_annotation`)
- **Navigation:** [GoRouter](https://pub.dev/packages/go_router)

### **Audio Engine & Backend**
- **Audio Playback:** `just_audio` & `audio_service`
- **Desktop Hardware Acceleration:** `just_audio_media_kit` & `media_kit` (Linux/Windows C-native dynamic libraries integration)

### **UI, Animations & Utilities**
- **Design System:** `glassmorphism`, `flutter_animate`, `palette_generator`, `google_fonts`
- **Data Models & Serialization:** `freezed`, `json_annotation`, `build_runner`
- **Local Storage:** `shared_preferences`
- **Utilities:** `share_plus`, `url_launcher`, `cupertino_icons`

---

## 🚀 Gurnamak we Işletmek (Installation & Setup)

Taslamany öz ýerli (local) kompýuteriňizde işletmek üçin aşakdaky adımlary ýerine ýetiriň:

### **Talap edilýän programmalar:**
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.22.0 ýa-da ulrak)
- [Git](https://git-scm.com/)
- Android Studio / VS Code

### **1. Repozitoriýany klonlaň**
```bash
git clone https://github.com/Abdyrahmanp/doganlar_aydymy.git
cd doganlar_aydymy
```

### **2. Bağımlılıklary ýükleň**
```bash
flutter pub get
```

### **3. Kody generasiýa ediň (Freezed & Riverpod)**
```bash
dart run build_runner build --delete-conflicting-outputs
```

### **4. Programmany işlediň**
```bash
# Android / iOS / Desktop üçin:
flutter run

# Web platformasynda işletmek üçin:
flutter run -d chrome
```

---

## 💻 Ulanyş Mümkinçilikleri (Usage Code Example)

Audio servis pleýerini Riverpod arkaly dolandyrmak üçin mysal kod:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/providers/player_provider.dart';

class PlayPauseButton extends ConsumerWidget {
  const PlayPauseButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlaying = ref.watch(playerIsPlayingProvider);
    final playerNotifier = ref.read(playerProvider.notifier);

    return IconButton(
      iconSize: 64,
      icon: Icon(
        isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
        color: Theme.of(context).primaryColor,
      ),
      onPressed: () {
        if (isPlaying) {
          playerNotifier.pause();
        } else {
          playerNotifier.play();
        }
      },
    );
  }
}
```

---

## 👤 Awtor we Prodýuser Malumatlary (Author & Credits)

| Rol | Ady / Unwany | Habarlaşmak / Linkler |
| :--- | :--- | :--- |
| 🎤 **Aýdymçy / Awtor** | **Guwanç Hanmatow** | 🎵 TikTok: [@guwanchanmatow](https://www.tiktok.com/@guwanchanmatow)<br>📞 IMO: `+99365237526` |
| 🎬 **Prodýuser Studiýasy** | **Kuba Prod** | 🎧 Türkmen Pop & Rep Önümçiligi |
| 💻 **Programma Üpçünçiligi** | **Abdyrahman Döwletgulyýew** | ✉️ Email: `abdyrahmandevoloper@gmail.com`<br>🐙 GitHub: [@Abdyrahmanp](https://github.com/Abdyrahmanp) |

---

## 🤝 Katkıda Bulunma (Contributing)

Taslama öz goşantlaryňyzy goşmak isleýän bolsaňyz, uly hoşallyk bilen kabul edýäris!

1. Repozitoriýany **Fork** ediň.
2. Täze funksiýa üçin bir şaha (branch) dörediň: `git checkout -b feature/taze-ayratynlyk`
3. Üýtgeşmeleriňizi **Commit** ediň: `git commit -m 'feat: Täze aýratynlyk goşuldy'`
4. Şahaňyza **Push** ediň: `git push origin feature/taze-ayratynlyk`
5. **Pull Request (PR)** açyň.

---

## 📄 Lisenziýa (License)

Bu taslama **MIT Lisenziýasy** astynda paýlaşylýar. Goşmaça malumat üçin [LICENSE](LICENSE) faýlyna serediň.

<p align="center">
  <b>Developed with ❤️ for Turkmen Music by Abdyrahman Döwletgulyýew</b>
</p>
