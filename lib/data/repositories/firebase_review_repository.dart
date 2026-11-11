import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';
import '../services/firebase_service.dart';
import 'review_repository.dart';

class FirebaseReviewRepository implements ReviewRepository {
  final FirebaseFirestore? _customFirestore;

  FirebaseReviewRepository({FirebaseFirestore? firestore})
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
  Stream<List<ReviewModel>> streamReviewsForUser(String targetUserId) {
    final fs = _firestore;
    if (fs == null) return Stream.value([]);
    return fs
        .collection('reviews')
        .where('targetUserId', isEqualTo: targetUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReviewModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  @override
  Future<void> submitReview(ReviewModel review) async {
    final fs = _firestore;
    if (fs == null) return;
    await fs.collection('reviews').doc(review.id).set(review.toMap());

    // Update target user's aggregated rating
    final reviewsSnap = await fs
        .collection('reviews')
        .where('targetUserId', isEqualTo: review.targetUserId)
        .get();

    if (reviewsSnap.docs.isNotEmpty) {
      final total = reviewsSnap.docs.length;
      final sum = reviewsSnap.docs.fold<double>(
        0.0,
        (prev, doc) => prev + ((doc.data()['rating'] as num?)?.toDouble() ?? 5.0),
      );
      final avg = sum / total;

      await fs.collection('users').doc(review.targetUserId).update({
        'rating': double.parse(avg.toStringAsFixed(1)),
        'totalReviews': total,
      });
    }
  }
}
