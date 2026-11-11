import 'package:firebase_database/firebase_database.dart';
import '../models/payment_model.dart';
import '../services/firebase_service.dart';
import 'payment_repository.dart';

class RtdbPaymentRepository implements PaymentRepository {
  DatabaseReference get _ref => FirebaseService().database.ref('payments');

  @override
  Stream<List<PaymentModel>> streamPayments() {
    if (!FirebaseService().isInitialized) return Stream.value([]);
    return _ref.onValue.map((event) {
      final val = event.snapshot.value;
      if (val == null) return <PaymentModel>[];
      final payments = <PaymentModel>[];
      if (val is Map) {
        val.forEach((key, map) {
          if (map is Map) {
            try {
              final m = <String, dynamic>{};
              map.forEach((k, v) {
                if (k != null) m[k.toString()] = v;
              });
              payments.add(PaymentModel.fromMap(m, key.toString()));
            } catch (_) {}
          }
        });
      }
      payments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return payments;
    });
  }

  @override
  Future<void> submitPayment(PaymentModel payment) async {
    if (!FirebaseService().isInitialized) return;
    final data = payment.toMap();
    data.removeWhere((k, v) => v == null);
    await _ref.child(payment.id).set(data);
  }

  @override
  Future<void> approvePayment(String paymentId) async {
    if (!FirebaseService().isInitialized) return;
    await _ref.child(paymentId).update({
      'status': 'approved',
      'approvedAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> rejectPayment(String paymentId, String reason) async {
    if (!FirebaseService().isInitialized) return;
    await _ref.child(paymentId).update({
      'status': 'rejected',
      'rejectionReason': reason,
      'rejectedAt': DateTime.now().toIso8601String(),
    });
  }
}
