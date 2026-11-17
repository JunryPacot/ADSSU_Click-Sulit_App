class UserModel {
  final String id;
  final String name;
  final String email;
  final String college;
  final String studentId;
  final bool isVerified;
  final bool isSellerMember;
  final double rating;
  final int totalReviews;
  final int dealsCompleted;
  final int itemsSavedCount;
  final String? profilePhoto;
  final String bio;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.college,
    required this.studentId,
    this.isVerified = false,
    this.isSellerMember = false,
    this.rating = 5.0,
    this.totalReviews = 0,
    this.dealsCompleted = 0,
    this.itemsSavedCount = 0,
    this.profilePhoto,
    this.bio = 'ADSSU Student',
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? college,
    String? studentId,
    bool? isVerified,
    bool? isSellerMember,
    double? rating,
    int? totalReviews,
    int? dealsCompleted,
    int? itemsSavedCount,
    String? profilePhoto,
    String? bio,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      college: college ?? this.college,
      studentId: studentId ?? this.studentId,
      isVerified: isVerified ?? this.isVerified,
      isSellerMember: isSellerMember ?? this.isSellerMember,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      dealsCompleted: dealsCompleted ?? this.dealsCompleted,
      itemsSavedCount: itemsSavedCount ?? this.itemsSavedCount,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      bio: bio ?? this.bio,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'email': email,
      'college': college,
      'studentId': studentId,
      'isVerified': isVerified,
      'isSellerMember': isSellerMember,
      'rating': rating,
      'totalReviews': totalReviews,
      'dealsCompleted': dealsCompleted,
      'itemsSavedCount': itemsSavedCount,
      'bio': bio,
    };
    if (profilePhoto != null && profilePhoto!.isNotEmpty) map['profilePhoto'] = profilePhoto;
    return map;
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    return UserModel(
      id: docId,
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      college: map['college']?.toString() ?? '',
      studentId: map['studentId']?.toString() ?? '',
      isVerified: map['isVerified'] == true || map['isVerified']?.toString() == 'true',
      isSellerMember: map['isSellerMember'] == true || map['isSellerMember']?.toString() == 'true',
      rating: (map['rating'] is num) ? (map['rating'] as num).toDouble() : (double.tryParse(map['rating']?.toString() ?? '') ?? 5.0),
      totalReviews: (map['totalReviews'] is num) ? (map['totalReviews'] as num).toInt() : (int.tryParse(map['totalReviews']?.toString() ?? '') ?? 0),
      dealsCompleted: (map['dealsCompleted'] is num) ? (map['dealsCompleted'] as num).toInt() : (int.tryParse(map['dealsCompleted']?.toString() ?? '') ?? 0),
      itemsSavedCount: (map['itemsSavedCount'] is num) ? (map['itemsSavedCount'] as num).toInt() : (int.tryParse(map['itemsSavedCount']?.toString() ?? '') ?? 0),
      profilePhoto: map['profilePhoto']?.toString(),
      bio: map['bio']?.toString() ?? 'ADSSU Student',
    );
  }

  static const UserModel guest = UserModel(
    id: 'user_guest',
    name: 'Adssunian',
    email: '',
    college: 'Agusan del Sur State University',
    studentId: '',
    isVerified: false,
    isSellerMember: false,
  );
}
