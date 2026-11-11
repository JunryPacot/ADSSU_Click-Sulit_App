import 'package:firebase_database/firebase_database.dart';
import '../models/request_model.dart';
import '../services/firebase_service.dart';
import 'request_repository.dart';

class RtdbRequestRepository implements RequestRepository {
  DatabaseReference get _ref => FirebaseService().database.ref('requests');

  @override
  Stream<List<RequestModel>> streamUserRequests(String userId) {
    if (!FirebaseService().isInitialized) return Stream.value([]);
    return _ref.onValue.map((event) {
      final val = event.snapshot.value;
      if (val == null) return <RequestModel>[];
      final requests = <RequestModel>[];
      if (val is Map) {
        val.forEach((key, map) {
          if (map is Map) {
            try {
              final m = <String, dynamic>{};
              map.forEach((k, v) {
                if (k != null) m[k.toString()] = v;
              });
              final req = RequestModel.fromMap(m, key.toString());
              if (req.buyerId == userId || req.sellerId == userId) {
                requests.add(req);
              }
            } catch (_) {}
          }
        });
      }
      requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return requests;
    });
  }

  @override
  Future<void> createRequest(RequestModel request) async {
    if (!FirebaseService().isInitialized) return;
    final data = request.toMap();
    data.removeWhere((k, v) => v == null);
    await _ref.child(request.id).set(data);
  }

  @override
  Future<void> updateRequestStatus(String requestId, String status) async {
    if (!FirebaseService().isInitialized) return;
    await _ref.child(requestId).update({'status': status});
  }

  @override
  Future<void> completeTransaction(String requestId) async {
    if (!FirebaseService().isInitialized) return;
    await _ref.child(requestId).update({
      'status': 'completed',
      'completedAt': DateTime.now().toIso8601String(),
    });
  }
}
