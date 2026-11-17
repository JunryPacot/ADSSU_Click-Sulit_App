class ReportModel {
  final String id;
  final String itemId;
  final String itemTitle;
  final String reportedByUserId;
  final String reportedByUserName;
  final String sellerId;
  final String sellerName;
  final String reason;
  final String details;
  final String status; // 'pending', 'resolved_removed', 'resolved_warned', 'dismissed'
  final DateTime createdAt;

  const ReportModel({
    required this.id,
    required this.itemId,
    required this.itemTitle,
    required this.reportedByUserId,
    required this.reportedByUserName,
    required this.sellerId,
    required this.sellerName,
    required this.reason,
    required this.details,
    this.status = 'pending',
    required this.createdAt,
  });

  ReportModel copyWith({
    String? id,
    String? itemId,
    String? itemTitle,
    String? reportedByUserId,
    String? reportedByUserName,
    String? sellerId,
    String? sellerName,
    String? reason,
    String? details,
    String? status,
    DateTime? createdAt,
  }) {
    return ReportModel(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      itemTitle: itemTitle ?? this.itemTitle,
      reportedByUserId: reportedByUserId ?? this.reportedByUserId,
      reportedByUserName: reportedByUserName ?? this.reportedByUserName,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      reason: reason ?? this.reason,
      details: details ?? this.details,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'itemTitle': itemTitle,
      'reportedByUserId': reportedByUserId,
      'reportedByUserName': reportedByUserName,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'reason': reason,
      'details': details,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ReportModel.fromMap(Map<String, dynamic> map, String docId) {
    return ReportModel(
      id: docId,
      itemId: map['itemId'] ?? '',
      itemTitle: map['itemTitle'] ?? '',
      reportedByUserId: map['reportedByUserId'] ?? '',
      reportedByUserName: map['reportedByUserName'] ?? '',
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      reason: map['reason'] ?? '',
      details: map['details'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
