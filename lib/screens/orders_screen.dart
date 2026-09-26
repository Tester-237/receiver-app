import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import '../models/order.dart';
import '../services/firestore_service.dart';
import '../services/printer_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _firestore = FirestoreService();
  final _printer = PrinterService();
  String _tokoId = '';
  String _tokoNama = '';
  bool _autoPrint = true;
  final Set<String> _sedangDicetak = {};

  @override
  void initState() {
    super.initState();
    _muatKonfigurasi();
  }

  Future<void> _muatKonfigurasi() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _tokoId = prefs.getString('tokoId') ?? '';
      _tokoNama = prefs.getString('tokoNama') ?? '';
    });
  }

  Future<void> _pilihPrinter() async {
    final devices = await _printer.daftarPrinterTerpasang();
    if (!mounted) return;
    if (devices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Belum ada printer yang di-pairing lewat Bluetooth HP.'),
      ));
      return;
    }
    showModalBottomSheet(
      context: context,
      builder: (_) => ListView(
        shrinkWrap: true,
        children: devices
            .map((d) => ListTile(
                  title: Text(d.name ?? 'Tanpa nama'),
                  subtitle: Text(d.address),
                  onTap: () async {
                    Navigator.pop(context);
                    await _printer.sambungkan(d);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Tersambung ke ${d.name}'),
                    ));
                  },
                ))
            .toList(),
      ),
    );
  }

  Future<void> _cetak(TokoOrder order) async {
    if (_sedangDicetak.contains(order.id)) return;
    _sedangDicetak.add(order.id);
    try {
      if (!await _printer.isTersambung()) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Printer belum tersambung. Pilih printer dulu.'),
        ));
        return;
      }
      await _printer.cetakPesanan(order);
      await _firestore.tandaiSelesai(order.id);
    } finally {
      _sedangDicetak.remove(order.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_tokoId.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(_tokoNama),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Pilih Printer',
            onPressed: _pilihPrinter,
          ),
          Row(
            children: [
              const Text('Auto', style: TextStyle(fontSize: 12)),
              Switch(
                value: _autoPrint,
                onChanged: (v) => setState(() => _autoPrint = v),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<TokoOrder>>(
        stream: _firestore.ordersBaru(_tokoId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final orders = snapshot.data!;
          if (orders.isEmpty) {
            return const Center(child: Text('Belum ada pesanan baru.'));
          }
          // Auto-cetak pesanan yang baru masuk kalau mode auto aktif.
          if (_autoPrint) {
            for (final o in orders) {
              _cetak(o);
            }
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, i) {
              final o = orders[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Meja ${o.meja} — ${o.nama}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      ...o.items.map((it) => Text('${it.qty}x ${it.nama}')),
                      const SizedBox(height: 6),
                      Text('Total: Rp${o.total}',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.print),
                          label: const Text('Cetak Manual'),
                          onPressed: () => _cetak(o),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
