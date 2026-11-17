class RequestModel {
  final String id;
  final String itemId;
  final String itemTitle;
  final double itemPrice;
  final String itemType; // SELL, EXCHANGE, DONATE
  final String buyerId;
  final String buyerName;
  final String buyerCollege;
  final String sellerId;
  final String sellerName;
  final String? offeredItemId;
  final String? offeredItemTitle;
  final String meetUpBuilding;
  final String exactLocation;
  final bool hasLocationPhoto;
  final String status; // 'pending', 'accepted', 'declined', 'completed', 'cancelled'
  final DateTime createdAt;
  final double commissionAmount; // 3% for SELL
  final double sellerEarnings; // 97% for SELL

  const RequestModel({
    required this.id,
    required this.itemId,
    required this.itemTitle,
    required this.itemPrice,
    required this.itemType,
    required this.buyerId,
    required this.buyerName,
    required this.buyerCollege,
    required this.sellerId,
    required this.sellerName,
    this.offeredItemId,
    this.offeredItemTitle,
    required this.meetUpBuilding,
    required this.exactLocation,
    this.hasLocationPhoto = false,
    this.status = 'pending',
    required this.createdAt,
    this.commissionAmount = 0.0,
    this.sellerEarnings = 0.0,
  });

  RequestModel copyWith({
    String? id,
    String? itemId,
    String? itemTitle,
    double? itemPrice,
    String? itemType,
    String? buyerId,
    String? buyerName,
    String? buyerCollege,
    String? sellerId,
    String? sellerName,
    String? offeredItemId,
    String? offeredItemTitle,
    String? meetUpBuilding,
    String? exactLocation,
    bool? hasLocationPhoto,
    String? status,
    DateTime? createdAt,
    double? commissionAmount,
    double? sellerEarnings,
  }) {
    return RequestModel(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      itemTitle: itemTitle ?? this.itemTitle,
      itemPrice: itemPrice ?? this.itemPrice,
      itemType: itemType ?? this.itemType,
      buyerId: buyerId ?? this.buyerId,
      buyerName: buyerName ?? this.buyerName,
      buyerCollege: buyerCollege ?? this.buyerCollege,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      offeredItemId: offeredItemId ?? this.offeredItemId,
      offeredItemTitle: offeredItemTitle ?? this.offeredItemTitle,
      meetUpBuilding: meetUpBuilding ?? this.meetUpBuilding,
      exactLocation: exactLocation ?? this.exactLocation,
      hasLocationPhoto: hasLocationPhoto ?? this.hasLocationPhoto,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      commissionAmount: commissionAmount ?? this.commissionAmount,
      sellerEarnings: sellerEarnings ?? this.sellerEarnings,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'itemId': itemId,
      'itemTitle': itemTitle,
      'itemPrice': itemPrice,
      'itemType': itemType,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'buyerCollege': buyerCollege,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'meetUpBuilding': meetUpBuilding,
      'exactLocation': exactLocation,
      'hasLocationPhoto': hasLocationPhoto,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'commissionAmount': commissionAmount,
      'sellerEarnings': sellerEarnings,
    };
    if (offeredItemId != null && offeredItemId!.isNotEmpty) map['offeredItemId'] = offeredItemId;
    if (offeredItemTitle != null && offeredItemTitle!.isNotEmpty) map['offeredItemTitle'] = offeredItemTitle;
    return map;
  }

  factory RequestModel.fromMap(Map<String, dynamic> map, String docId) {
    return RequestModel(
      id: docId,
      itemId: map['itemId']?.toString() ?? '',
      itemTitle: map['itemTitle']?.toString() ?? '',
      itemPrice: (map['itemPrice'] is num) ? (map['itemPrice'] as num).toDouble() : (double.tryParse(map['itemPrice']?.toString() ?? '') ?? 0.0),
      itemType: map['itemType']?.toString() ?? 'SELL',
      buyerId: map['buyerId']?.toString() ?? '',
      buyerName: map['buyerName']?.toString() ?? '',
      buyerCollege: map['buyerCollege']?.toString() ?? '',
      sellerId: map['sellerId']?.toString() ?? '',
      sellerName: map['sellerName']?.toString() ?? '',
      offeredItemId: map['offeredItemId']?.toString(),
      offeredItemTitle: map['offeredItemTitle']?.toString(),
      meetUpBuilding: map['meetUpBuilding']?.toString() ?? '',
      exactLocation: map['exactLocation']?.toString() ?? '',
      hasLocationPhoto: map['hasLocationPhoto'] == true || map['hasLocationPhoto']?.toString() == 'true',
      status: map['status']?.toString() ?? 'pending',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      commissionAmount: (map['commissionAmount'] is num)
          ? (map['commissionAmount'] as num).toDouble()
          : (double.tryParse(map['commissionAmount']?.toString() ?? '') ?? 0.0),
      sellerEarnings: (map['sellerEarnings'] is num)
          ? (map['sellerEarnings'] as num).toDouble()
          : (double.tryParse(map['sellerEarnings']?.toString() ?? '') ?? 0.0),
    );
  }
}
