import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import '../models/order.dart';

class PrinterService {
  Future<List<BluetoothInfo>> daftarPrinterTerpasang() {
    return PrintBluetoothThermal.pairedBluetooths;
  }

  Future<bool> isTersambung() {
    return PrintBluetoothThermal.connectionStatus;
  }

  Future<bool> sambungkan(BluetoothInfo device) {
    return PrintBluetoothThermal.connect(macPrinterAddress: device.macAdress);
  }

  Future<void> putuskan() {
    return PrintBluetoothThermal.disconnect();
  }

  Future<void> cetakPesanan(TokoOrder order) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    bytes += generator.text(
      order.tokoNama,
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(text: 'Meja', width: 6),
      PosColumn(text: order.meja, width: 6, styles: const PosStyles(align: PosAlign.right)),
    ]);
    bytes += generator.row([
      PosColumn(text: 'Nama', width: 6),
      PosColumn(text: order.nama, width: 6, styles: const PosStyles(align: PosAlign.right)),
    ]);
    bytes += generator.hr();

    for (final item in order.items) {
      bytes += generator.row([
        PosColumn(text: '${item.qty}x ${item.nama}', width: 8),
        PosColumn(text: _rupiah(item.subtotal), width: 4, styles: const PosStyles(align: PosAlign.right)),
      ]);
    }

    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(text: 'TOTAL', width: 6, styles: const PosStyles(bold: true)),
      PosColumn(text: _rupiah(order.total), width: 6, styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]);
    bytes += generator.feed(2);
    bytes += generator.cut();

    await PrintBluetoothThermal.writeBytes(bytes);
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
