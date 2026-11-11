import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment_model.dart';
import '../services/firebase_service.dart';
import 'payment_repository.dart';

class FirebasePaymentRepository implements PaymentRepository {
  final FirebaseFirestore? _customFirestore;

  FirebasePaymentRepository({FirebaseFirestore? firestore})
      : _customFirestore = firestore;

  FirebaseFirestore? get _firestore {
    if (_customFirestore != null) return _customFirestore;
    if (FirebaseService().isInitialized) {
      try {
        return FirebaseFirestore.instance;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  @override
  Stream<List<PaymentModel>> streamPayments() {
    final fs = _firestore;
    if (fs == null) return Stream.value([]);
    return fs
        .collection('payments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PaymentModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  @override
  Future<void> submitPayment(PaymentModel payment) async {
    final fs = _firestore;
    if (fs == null) return;
    await fs.collection('payments').doc(payment.id).set(payment.toMap());
  }

  @override
  Future<void> approvePayment(String paymentId) async {
    final fs = _firestore;
    if (fs == null) return;

    final doc = await fs.collection('payments').doc(paymentId).get();
    if (!doc.exists || doc.data() == null) return;

    final data = doc.data()!;
    await fs.collection('payments').doc(paymentId).update({
      'status': 'approved',
      'reviewedAt': FieldValue.serverTimestamp(),
    });

    final userId = data['userId'];
    final paymentType = data['paymentType'];

    if (userId != null && paymentType == 'membership') {
      await fs.collection('users').doc(userId.toString()).update({
        'isSellerMember': true,
      });
    } else if (paymentType == 'boost') {
      final itemId = data['relatedItemId'];
      if (itemId != null) {
        await fs.collection('items').doc(itemId.toString()).update({
          'isFeatured': true,
        });
      }
    }
  }

  @override
  Future<void> rejectPayment(String paymentId, String reason) async {
    final fs = _firestore;
    if (fs == null) return;
    await fs.collection('payments').doc(paymentId).update({
      'status': 'rejected',
      'rejectionReason': reason,
      'reviewedAt': FieldValue.serverTimestamp(),
    });
  }
}
