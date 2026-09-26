// File ini SENGAJA berupa placeholder.
//
// Jangan diisi manual. Setelah kamu membuat project Firebase (lihat
// README.md), jalankan perintah berikut di dalam folder project ini:
//
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// Perintah itu akan MENIMPA file ini secara otomatis dengan konfigurasi
// project Firebase kamu (apiKey, projectId, dsb) untuk Android/iOS/Web.

import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    throw UnsupportedError(
      'firebase_options.dart belum di-generate. Jalankan "flutterfire configure" '
      'di root project ini terlebih dahulu (lihat README.md).',
    );
  }
}
