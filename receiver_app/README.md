# Sistem Penerima Pesanan UMKM

Terdiri dari 3 bagian:
1. `pesan-umkm-firebase.html` — web pemesanan (1 file per toko, kamu duplikat & ganti `TOKO_ID` untuk tiap UMKM baru)
2. Project Flutter ini — 1 aplikasi Android yang sama, dipakai semua toko (tinggal beda kode konfigurasi)
3. Firebase — penghubung real-time antara keduanya + tempat hosting web-nya

Kamu cukup setup Firebase **sekali**. Setelahnya, tiap UMKM baru cuma butuh: duplikat file web + install app + isi kode toko.

---

## 1. Buat project Firebase (sekali saja)

1. Buka https://console.firebase.google.com → **Add project** → ikuti langkahnya (gratis).
2. Di sidebar, buka **Build → Firestore Database** → **Create database** → pilih mode **production**.
3. Buka tab **Rules**, tempel isi file `firestore.rules` dari folder ini, lalu **Publish**.
4. Di **Project settings → General**, scroll ke "Your apps" → klik ikon web `</>` → daftarkan app web → salin `firebaseConfig` yang muncul.

## 2. Sambungkan web pemesanan

1. Buka `pesan-umkm-firebase.html`.
2. Tempel `firebaseConfig` dari langkah 1 ke bagian yang ditandai `ISI_DARI_FIREBASE_CONSOLE`.
3. Ganti `TOKO_ID` & `TOKO_NAMA` — ini kode unik yang menghubungkan web ke HP toko tsb.
4. Install Firebase CLI (`npm install -g firebase-tools`) → `firebase login` → `firebase init hosting` di folder berisi file html ini → `firebase deploy`.
   Setiap UMKM baru = duplikat file ini dengan `TOKO_ID` baru, deploy ke folder/hosting target berbeda (atau subdomain berbeda).

## 3. Build aplikasi Android (sekali saja, dipakai semua toko)

Butuh [Flutter SDK](https://docs.flutter.dev/get-started/install) terpasang di komputer kamu.

```bash
cd receiver_app
flutter pub get
dart pub global activate flutterfire_cli
flutterfire configure   # pilih project Firebase yang sama seperti di atas
flutter run              # tes di HP/emulator dulu
```

`flutterfire configure` otomatis mengisi `lib/firebase_options.dart` — jangan diisi manual.

### Pairing printer Bluetooth
Sebelum buka app, pairing dulu printer struk ke HP lewat menu Bluetooth bawaan Android (seperti pairing headset). Setelah itu di dalam app tinggal tekan ikon printer di pojok kanan atas untuk memilihnya.

### Build APK untuk dibagikan / upload ke Play Store
```bash
flutter build appbundle   # untuk upload ke Play Store (.aab)
# atau
flutter build apk         # untuk share langsung / tes manual (.apk)
```

## 4. Ke Play Store

Ini bagian yang perlu kamu lakukan sendiri di luar sini:
1. Bikin akun **Google Play Console** (bayar sekali ~$25).
2. Buat aplikasi baru, isi listing (judul, deskripsi, screenshot, ikon).
3. Upload file `.aab` hasil `flutter build appbundle`.
4. Isi kebijakan privasi (wajib) — jelaskan bahwa app membaca data pesanan dari Firestore dan mengakses Bluetooth untuk cetak.
5. Submit untuk review (biasanya beberapa hari).

## Cara pakai tiap ada UMKM baru
1. Tentukan `TOKO_ID` unik, misal `bu-sari-warteg`.
2. Duplikat `pesan-umkm-firebase.html`, ganti `TOKO_ID` & `TOKO_NAMA`, deploy web-nya.
3. Di HP toko itu, install app dari Play Store → buka → isi Nama Toko & Kode Toko (`TOKO_ID` yang sama) → selesai.

## Keterbatasan versi ini (perlu ditingkatkan sebelum skala besar)
- Aturan Firestore masih terbuka (siapa pun yang tahu `tokoId` bisa baca pesanan toko itu). Untuk banyak toko dengan data sensitif, tambahkan Firebase Authentication.
- Belum ada halaman riwayat pesanan / laporan penjualan di app.
- Format struk masih teks polos — bisa dipercantik sesuai jenis printer (logo, dsb) lewat command ESC/POS tambahan.
