import '../models/review_model.dart';

abstract class ReviewRepository {
  Stream<List<ReviewModel>> streamReviewsForUser(String targetUserId);
  Future<void> submitReview(ReviewModel review);
}

