import 'package:firebase_database/firebase_database.dart';
import '../models/review_model.dart';
import '../services/firebase_service.dart';
import 'review_repository.dart';

class RtdbReviewRepository implements ReviewRepository {
  DatabaseReference get _ref => FirebaseService().database.ref('reviews');

  @override
  Stream<List<ReviewModel>> streamReviewsForUser(String targetUserId) {
    if (!FirebaseService().isInitialized) return Stream.value([]);
    return _ref.onValue.map((event) {
      final val = event.snapshot.value;
      if (val == null) return <ReviewModel>[];
      final reviews = <ReviewModel>[];
      if (val is Map) {
        val.forEach((key, map) {
          if (map is Map) {
            try {
              final m = Map<String, dynamic>.from(map);
              final rev = ReviewModel.fromMap(m, key.toString());
              if (rev.targetUserId == targetUserId) {
                reviews.add(rev);
              }
            } catch (_) {}
          }
        });
      }
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return reviews;
    });
  }

  @override
  Future<void> submitReview(ReviewModel review) async {
    if (!FirebaseService().isInitialized) return;
    await _ref.child(review.id).set(review.toMap());
  }
}

