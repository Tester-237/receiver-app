import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import '../models/order.dart';

/// Membungkus paket blue_thermal_printer supaya sisa app tidak perlu tahu
/// detail Bluetooth/ESC-POS-nya.
class PrinterService {
  final BlueThermalPrinter _printer = BlueThermalPrinter.instance;

  Future<List<BluetoothDevice>> daftarPrinterTerpasang() {
    return _printer.getBondedDevices();
  }

  Future<bool> isTersambung() async {
    return await _printer.isConnected ?? false;
  }

  Future<void> sambungkan(BluetoothDevice device) async {
    await _printer.connect(device);
  }

  Future<void> putuskan() async {
    await _printer.disconnect();
  }

  /// Cetak 1 struk pesanan ke kertas kecil (biasanya 58mm).
  Future<void> cetakPesanan(TokoOrder order) async {
    _printer.printCustom(order.tokoNama, 3, 1); // besar, tengah
    _printer.printNewLine();
    _printer.printLeftRight('Meja', order.meja, 1);
    _printer.printLeftRight('Nama', order.nama, 1);
    _printer.printCustom('--------------------------------', 1, 1);

    for (final item in order.items) {
      _printer.printLeftRight(
        '${item.qty}x ${item.nama}',
        _rupiah(item.subtotal),
        1,
      );
    }

    _printer.printCustom('--------------------------------', 1, 1);
    _printer.printLeftRight('TOTAL', _rupiah(order.total), 2);
    _printer.printNewLine();
    _printer.printNewLine();
    _printer.paperCut();
  }

  String _rupiah(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final posFromEnd = s.length - i;
      buf.write(s[i]);
      if (posFromEnd > 1 && posFromEnd % 3 == 1) buf.write('.');
    }
    return 'Rp$buf';
  }
}
