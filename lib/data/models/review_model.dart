class ReviewModel {
  final String id;
  final String reviewerId;
  final String reviewerName;
  final String targetUserId;
  final String itemTitle;
  final double rating;
  final String comment;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.reviewerId,
    required this.reviewerName,
    required this.targetUserId,
    required this.itemTitle,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'reviewerId': reviewerId,
      'reviewerName': reviewerName,
      'targetUserId': targetUserId,
      'itemTitle': itemTitle,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map, String docId) {
    return ReviewModel(
      id: docId,
      reviewerId: map['reviewerId'] ?? '',
      reviewerName: map['reviewerName'] ?? '',
      targetUserId: map['targetUserId'] ?? '',
      itemTitle: map['itemTitle'] ?? '',
      rating: (map['rating'] is num) ? (map['rating'] as num).toDouble() : 5.0,
      comment: map['comment'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
