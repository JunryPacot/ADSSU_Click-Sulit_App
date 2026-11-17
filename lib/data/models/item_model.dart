class ItemModel {
  final String id;
  final String title;
  final String description;
  final double price; // 0.0 for EXCHANGE / DONATE
  final String category;
  final String type; // SELL, EXCHANGE, DONATE
  final String condition;
  final String sellerId;
  final String sellerName;
  final String sellerCollege;
  final double sellerRating;
  final bool isFeatured;
  final bool isSaved;
  final String? exchangeFor;
  final String? meetUpPreference;
  final DateTime createdAt;
  final String status; // 'active', 'reserved', 'completed'
  final String? imageUrl;
  final List<String> images;
  final int quantity; // Available inventory number

  const ItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.type,
    required this.condition,
    required this.sellerId,
    required this.sellerName,
    required this.sellerCollege,
    this.sellerRating = 5.0,
    this.isFeatured = false,
    this.isSaved = false,
    this.exchangeFor,
    this.meetUpPreference,
    required this.createdAt,
    this.status = 'active',
    this.imageUrl,
    this.images = const [],
    this.quantity = 1,
  });

  ItemModel copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? category,
    String? type,
    String? condition,
    String? sellerId,
    String? sellerName,
    String? sellerCollege,
    double? sellerRating,
    bool? isFeatured,
    bool? isSaved,
    String? exchangeFor,
    String? meetUpPreference,
    DateTime? createdAt,
    String? status,
    String? imageUrl,
    List<String>? images,
    int? quantity,
  }) {
    return ItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      type: type ?? this.type,
      condition: condition ?? this.condition,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerCollege: sellerCollege ?? this.sellerCollege,
      sellerRating: sellerRating ?? this.sellerRating,
      isFeatured: isFeatured ?? this.isFeatured,
      isSaved: isSaved ?? this.isSaved,
      exchangeFor: exchangeFor ?? this.exchangeFor,
      meetUpPreference: meetUpPreference ?? this.meetUpPreference,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      images: images ?? this.images,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'price': price,
      'category': category,
      'type': type,
      'condition': condition,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerCollege': sellerCollege,
      'sellerRating': sellerRating,
      'isFeatured': isFeatured,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'quantity': quantity,
    };
    if (exchangeFor != null && exchangeFor!.trim().isNotEmpty) {
      map['exchangeFor'] = exchangeFor;
    }
    if (meetUpPreference != null && meetUpPreference!.trim().isNotEmpty) {
      map['meetUpPreference'] = meetUpPreference;
    }
    if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      map['imageUrl'] = imageUrl;
    }
    if (images.isNotEmpty) {
      map['images'] = images;
    }
    return map;
  }

  factory ItemModel.fromMap(Map<String, dynamic> map, String docId, {bool isSaved = false}) {
    List<String> parsedImages = [];
    if (map['images'] is List) {
      parsedImages = (map['images'] as List).map((e) => e.toString()).toList();
    }
    final rawImg = map['imageUrl']?.toString();
    if (rawImg != null && rawImg.isNotEmpty && !parsedImages.contains(rawImg)) {
      parsedImages.insert(0, rawImg);
    }

    final parsedQty = (map['quantity'] is num)
        ? (map['quantity'] as num).toInt()
        : (int.tryParse(map['quantity']?.toString() ?? '1') ?? 1);

    return ItemModel(
      id: docId,
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      price: (map['price'] is num) ? (map['price'] as num).toDouble() : (double.tryParse(map['price']?.toString() ?? '') ?? 0.0),
      category: map['category']?.toString() ?? '',
      type: map['type']?.toString() ?? 'SELL',
      condition: map['condition']?.toString() ?? 'Good',
      sellerId: map['sellerId']?.toString() ?? '',
      sellerName: map['sellerName']?.toString() ?? '',
      sellerCollege: map['sellerCollege']?.toString() ?? '',
      sellerRating: (map['sellerRating'] is num) ? (map['sellerRating'] as num).toDouble() : 5.0,
      isFeatured: map['isFeatured'] == true || map['isFeatured']?.toString() == 'true',
      isSaved: isSaved,
      exchangeFor: map['exchangeFor']?.toString(),
      meetUpPreference: map['meetUpPreference']?.toString(),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      status: map['status']?.toString() ?? 'active',
      imageUrl: rawImg,
      images: parsedImages,
      quantity: parsedQty,
    );
  }
}
