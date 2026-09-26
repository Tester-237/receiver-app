class OrderItem {
  final String nama;
  final int qty;
  final int harga;

  OrderItem({required this.nama, required this.qty, required this.harga});

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      nama: map['nama'] ?? '',
      qty: (map['qty'] ?? 0) as int,
      harga: (map['harga'] ?? 0) as int,
    );
  }

  int get subtotal => qty * harga;
}

class TokoOrder {
  final String id;
  final String tokoId;
  final String tokoNama;
  final String meja;
  final String nama;
  final List<OrderItem> items;
  final int total;
  final String status; // 'baru' | 'dicetak'

  TokoOrder({
    required this.id,
    required this.tokoId,
    required this.tokoNama,
    required this.meja,
    required this.nama,
    required this.items,
    required this.total,
    required this.status,
  });

  factory TokoOrder.fromFirestore(String id, Map<String, dynamic> data) {
    final rawItems = (data['items'] as List<dynamic>? ?? []);
    return TokoOrder(
      id: id,
      tokoId: data['tokoId'] ?? '',
      tokoNama: data['tokoNama'] ?? '',
      meja: data['meja'] ?? '-',
      nama: data['nama'] ?? '-',
      items: rawItems
          .map((e) => OrderItem.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      total: (data['total'] ?? 0) as int,
      status: data['status'] ?? 'baru',
    );
  }
}
