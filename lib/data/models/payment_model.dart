class PaymentModel {
  final String id;
  final String userId;
  final String userName;
  final String userCollege;
  final String paymentType; // 'membership' or 'boost'
  final double amount;
  final String referenceNumber;
  final String? relatedItemId;
  final String? relatedItemTitle;
  final String? boostDuration;
  final String status; // 'pending', 'approved', 'rejected'
  final String? rejectionReason;
  final DateTime createdAt;

  const PaymentModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userCollege,
    required this.paymentType,
    required this.amount,
    required this.referenceNumber,
    this.relatedItemId,
    this.relatedItemTitle,
    this.boostDuration,
    this.status = 'pending',
    this.rejectionReason,
    required this.createdAt,
  });

  PaymentModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userCollege,
    String? paymentType,
    double? amount,
    String? referenceNumber,
    String? relatedItemId,
    String? relatedItemTitle,
    String? boostDuration,
    String? status,
    String? rejectionReason,
    DateTime? createdAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userCollege: userCollege ?? this.userCollege,
      paymentType: paymentType ?? this.paymentType,
      amount: amount ?? this.amount,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      relatedItemId: relatedItemId ?? this.relatedItemId,
      relatedItemTitle: relatedItemTitle ?? this.relatedItemTitle,
      boostDuration: boostDuration ?? this.boostDuration,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'userId': userId,
      'userName': userName,
      'userCollege': userCollege,
      'paymentType': paymentType,
      'amount': amount,
      'referenceNumber': referenceNumber,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
    if (relatedItemId != null && relatedItemId!.isNotEmpty) map['relatedItemId'] = relatedItemId;
    if (relatedItemTitle != null && relatedItemTitle!.isNotEmpty) map['relatedItemTitle'] = relatedItemTitle;
    if (boostDuration != null && boostDuration!.isNotEmpty) map['boostDuration'] = boostDuration;
    if (rejectionReason != null && rejectionReason!.isNotEmpty) map['rejectionReason'] = rejectionReason;
    return map;
  }

  factory PaymentModel.fromMap(Map<String, dynamic> map, String docId) {
    return PaymentModel(
      id: docId,
      userId: map['userId']?.toString() ?? '',
      userName: map['userName']?.toString() ?? '',
      userCollege: map['userCollege']?.toString() ?? '',
      paymentType: map['paymentType']?.toString() ?? 'membership',
      amount: (map['amount'] is num) ? (map['amount'] as num).toDouble() : (double.tryParse(map['amount']?.toString() ?? '') ?? 0.0),
      referenceNumber: map['referenceNumber']?.toString() ?? '',
      relatedItemId: map['relatedItemId']?.toString(),
      relatedItemTitle: map['relatedItemTitle']?.toString(),
      boostDuration: map['boostDuration']?.toString(),
      status: map['status']?.toString() ?? 'pending',
      rejectionReason: map['rejectionReason']?.toString(),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
