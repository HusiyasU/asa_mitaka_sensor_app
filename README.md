# ⚔️ Asa Mitaka Sensor App — Chainsaw Man
> Flutter Application dengan 3 Sensor — Tema Dark Manga

---

## 🎭 Tentang Aplikasi

Aplikasi Flutter bertema **Asa Mitaka** dari Chainsaw Man dengan desain gelap (dark theme) khas manga. Menampilkan data dari **3 sensor perangkat** secara real-time dengan visualisasi yang stylish.

---

## 📱 Fitur & Sensor

### 1. ⚔️ ACCELEROMETER — "War Sense"
- Deteksi gerakan & gravitasi pada 3 sumbu (X, Y, Z)
- Visualisasi bola yang bergerak mengikuti kemiringan device
- Trail graph pergerakan
- Satuan: m/s²

### 2. 🌀 GYROSCOPE — "War Spear"  
- Deteksi rotasi & orientasi device
- Visualisasi 3D cube yang berotasi secara real-time
- Dial indicator untuk Pitch, Roll, dan Yaw
- Satuan: rad/s

### 3. 👁️ PROXIMITY — "Battlefield Radar"
- Deteksi jarak objek (dekat/jauh)
- Radar sweep animation
- History graph jarak
- Status: Aman / Waspada / Bahaya

---

## 🎨 Desain

- **Color Palette**: Dark (#080808, #0D0D0D) + Gold (#E8C547) + Red (#D64045) + Teal (#4ECDC4)
- **Style**: Manga/cyberpunk dark theme
- **Animasi**: Pulse, radar sweep, 3D rotation, trail effects
- **Karakter**: Asa Mitaka + Yoru (War Devil) quotes

---

## 🚀 Setup & Instalasi

### Prerequisites
```
Flutter SDK >= 3.10.0
Dart SDK >= 3.0.0
Android Studio / VS Code
```

### Langkah Install

```bash
# Clone atau buat project baru
flutter create asa_mitaka_sensor_app
cd asa_mitaka_sensor_app

# Copy semua file dari folder lib/ ke project Anda
# Ganti main.dart dan tambahkan folder screens/

# Install dependencies
flutter pub get

# Jalankan di emulator atau device
flutter run
```

---

## 📦 Mengaktifkan Sensor Nyata

File ini menggunakan **simulasi sensor** untuk demo. Untuk device nyata:

### 1. Tambah dependency di `pubspec.yaml`:
```yaml
dependencies:
  sensors_plus: ^4.0.2
```

### 2. Di `accelerometer_screen.dart`, ganti kode simulasi dengan:
```dart
import 'package:sensors_plus/sensors_plus.dart';

accelerometerEventStream().listen((AccelerometerEvent event) {
  setState(() {
    x = event.x;
    y = event.y;
    z = event.z;
  });
});
```

### 3. Di `gyroscope_screen.dart`:
```dart
gyroscopeEventStream().listen((GyroscopeEvent event) {
  setState(() {
    rx = event.x;
    ry = event.y;
    rz = event.z;
  });
});
```

### 4. Di `proximity_screen.dart`:
```dart
proximityEventStream().listen((ProximityEvent event) {
  setState(() {
    _distance = event.proximity;
    _isNear = event.proximity < 5;
  });
});
```

### 5. Android permissions di `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-feature android:name="android.hardware.sensor.accelerometer"/>
<uses-feature android:name="android.hardware.sensor.gyroscope"/>
<uses-feature android:name="android.hardware.sensor.proximity"/>
```

---

## 📁 Struktur Project

```
lib/
├── main.dart                    # Entry point & theme
└── screens/
    ├── home_screen.dart         # Dashboard utama
    ├── accelerometer_screen.dart # Sensor 1: Accelerometer
    ├── gyroscope_screen.dart    # Sensor 2: Gyroscope
    └── proximity_screen.dart   # Sensor 3: Proximity
```

---

## 🖤 Quotes dari Asa Mitaka

> *"I'll survive no matter what it takes."*

> *"Gerakan terdeteksi — Asa siaga penuh!"*

> *"Yoru bergerak... waspada terhadap sekelilingmu."*

---

**Made with ❤️ + ⚔️ — Chainsaw Man Fan App**
