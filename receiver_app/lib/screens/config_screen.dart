import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'orders_screen.dart';

/// Diisi sekali oleh pemilik UMKM (atau kamu, saat setup) dengan kode toko
/// yang sama seperti yang ditanam di web pemesanan mereka.
class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final _tokoIdCtrl = TextEditingController();
  final _tokoNamaCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _simpan() async {
    if (_tokoIdCtrl.text.trim().isEmpty || _tokoNamaCtrl.text.trim().isEmpty) {
      return;
    }
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tokoId', _tokoIdCtrl.text.trim());
    await prefs.setString('tokoNama', _tokoNamaCtrl.text.trim());
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const OrdersScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setup Toko')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Masukkan kode toko yang sama dengan yang tertanam di web '
              'pemesanan toko ini. Kode ini yang menghubungkan HP ini '
              'dengan pesanan dari web-nya.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _tokoNamaCtrl,
              decoration: const InputDecoration(
                labelText: 'Nama Toko',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tokoIdCtrl,
              decoration: const InputDecoration(
                labelText: 'Kode Toko (tokoId)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _loading ? null : _simpan,
              child: const Text('Simpan & Mulai'),
            ),
          ],
        ),
      ),
    );
  }
}
