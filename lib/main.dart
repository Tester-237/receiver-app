import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/config_screen.dart';
import 'screens/orders_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const PenerimaPesananApp());
}

class PenerimaPesananApp extends StatelessWidget {
  const PenerimaPesananApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Penerima Pesanan',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF24402E),
      ),
      home: const _StartGate(),
    );
  }
}

/// Cek apakah toko sudah dikonfigurasi sebelumnya; kalau sudah, langsung
/// masuk ke daftar pesanan, kalau belum, minta setup dulu.
class _StartGate extends StatelessWidget {
  const _StartGate();

  Future<bool> _sudahDikonfigurasi() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getString('tokoId') ?? '').isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _sudahDikonfigurasi(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return snapshot.data! ? const OrdersScreen() : const ConfigScreen();
      },
    );
  }
}
