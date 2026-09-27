import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order.dart';

/// Semua akses Firestore terpusat di sini, supaya kalau nanti mau ganti
/// struktur data atau tambah keamanan (auth per toko), cukup ubah di 1 file.
class FirestoreService {
  final _db = FirebaseFirestore.instance;

  /// Stream pesanan yang masih 'baru' untuk 1 toko tertentu.
  Stream<List<TokoOrder>> ordersBaru(String tokoId) {
    return _db
        .collection('orders')
        .where('tokoId', isEqualTo: tokoId)
        .where('status', isEqualTo: 'baru')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => TokoOrder.fromFirestore(d.id, d.data()))
            .toList());
  }

  /// Tandai pesanan sudah dicetak, supaya tidak muncul/cetak dobel.
  Future<void> tandaiSelesai(String orderId) {
    return _db.collection('orders').doc(orderId).update({'status': 'dicetak'});
  }
}
