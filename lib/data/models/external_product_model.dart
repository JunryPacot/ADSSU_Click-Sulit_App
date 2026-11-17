class ExternalProductModel {
  final int id;
  final String title;
  final String description;
  final double price; // Original USD price
  final double discountPercentage;
  final double rating;
  final int stock;
  final String brand;
  final String category;
  final String thumbnail;
  final List<String> images;
  final bool isSavedLocally;

  const ExternalProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.discountPercentage = 0.0,
    this.rating = 4.5,
    this.stock = 10,
    this.brand = 'Generic',
    required this.category,
    required this.thumbnail,
    this.images = const [],
    this.isSavedLocally = false,
  });

  /// Approximate PHP price conversion (1 USD ≈ 58.00 PHP)
  double get pricePhp => price * 58.0;

  String get formattedPricePhp => '₱${pricePhp.toStringAsFixed(2)}';

  ExternalProductModel copyWith({
    int? id,
    String? title,
    String? description,
    double? price,
    double? discountPercentage,
    double? rating,
    int? stock,
    String? brand,
    String? category,
    String? thumbnail,
    List<String>? images,
    bool? isSavedLocally,
  }) {
    return ExternalProductModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      rating: rating ?? this.rating,
      stock: stock ?? this.stock,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      thumbnail: thumbnail ?? this.thumbnail,
      images: images ?? this.images,
      isSavedLocally: isSavedLocally ?? this.isSavedLocally,
    );
  }

  factory ExternalProductModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedImages = [];
    if (json['images'] is List) {
      parsedImages = (json['images'] as List).map((e) => e.toString()).toList();
    }

    final rawPrice = json['price'];
    final double parsedPrice = (rawPrice is num)
        ? rawPrice.toDouble()
        : (double.tryParse(rawPrice?.toString() ?? '0') ?? 0.0);

    final rawRating = json['rating'];
    final double parsedRating = (rawRating is num)
        ? rawRating.toDouble()
        : (rawRating is Map && rawRating['rate'] is num)
            ? (rawRating['rate'] as num).toDouble()
            : (double.tryParse(rawRating?.toString() ?? '4.5') ?? 4.5);

    return ExternalProductModel(
      id: (json['id'] is num) ? (json['id'] as num).toInt() : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      title: json['title']?.toString() ?? 'Product',
      description: json['description']?.toString() ?? '',
      price: parsedPrice,
      discountPercentage: (json['discountPercentage'] is num)
          ? (json['discountPercentage'] as num).toDouble()
          : 0.0,
      rating: parsedRating,
      stock: (json['stock'] is num) ? (json['stock'] as num).toInt() : 10,
      brand: json['brand']?.toString() ?? 'Official Brand',
      category: json['category']?.toString() ?? 'General',
      thumbnail: json['thumbnail']?.toString() ?? (json['image']?.toString() ?? ''),
      images: parsedImages,
      isSavedLocally: json['isSavedLocally'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'discountPercentage': discountPercentage,
      'rating': rating,
      'stock': stock,
      'brand': brand,
      'category': category,
      'thumbnail': thumbnail,
      'images': images,
      'isSavedLocally': isSavedLocally,
    };
  }
}
