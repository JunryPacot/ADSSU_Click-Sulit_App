import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/request_model.dart';
import '../services/firebase_service.dart';
import 'request_repository.dart';

class FirebaseRequestRepository implements RequestRepository {
  final FirebaseFirestore? _customFirestore;

  FirebaseRequestRepository({FirebaseFirestore? firestore})
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
  Stream<List<RequestModel>> streamUserRequests(String userId) {
    final fs = _firestore;
    if (fs == null) return Stream.value([]);
    return fs
        .collection('requests')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => RequestModel.fromMap(doc.data(), doc.id))
          .where((r) => r.buyerId == userId || r.sellerId == userId)
          .toList();
    });
  }

  @override
  Future<void> createRequest(RequestModel request) async {
    final fs = _firestore;
    if (fs == null) return;
    await fs.collection('requests').doc(request.id).set(request.toMap());
  }

  @override
  Future<void> updateRequestStatus(String requestId, String status) async {
    final fs = _firestore;
    if (fs == null) return;
    await fs.collection('requests').doc(requestId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> completeTransaction(String requestId) async {
    final fs = _firestore;
    if (fs == null) return;
    final doc = await fs.collection('requests').doc(requestId).get();
    if (!doc.exists || doc.data() == null) return;

    final data = doc.data()!;
    final price = (data['itemPrice'] as num?)?.toDouble() ?? 0.0;
    final commission = price * 0.03;
    final sellerEarnings = price - commission;

    await fs.collection('requests').doc(requestId).update({
      'status': 'completed',
      'commissionAmount': commission,
      'sellerEarnings': sellerEarnings,
      'completedAt': FieldValue.serverTimestamp(),
    });

    final itemId = data['itemId'];
    if (itemId != null) {
      await fs.collection('items').doc(itemId.toString()).update({
        'status': 'completed',
      });
    }
  }
}
