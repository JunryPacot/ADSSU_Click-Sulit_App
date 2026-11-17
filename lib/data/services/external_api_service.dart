import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/external_product_model.dart';

/// Service responsible for fetching product data from an external REST API.
/// Fulfills Laboratory Exercise 4 Task 1:
/// - Send HTTP request using fetch()/http
/// - Retrieve and process API response
/// - Handle network errors, timeouts, and unsuccessful responses
/// - Support category filtering and search queries
class ExternalApiService {
  static final ExternalApiService _instance = ExternalApiService._internal();
  factory ExternalApiService() => _instance;
  ExternalApiService._internal();

  // Primary API: DummyJSON Products
  static const String _primaryUrl = 'https://dummyjson.com/products';
  // Fallback API: FakeStore API
  static const String _fallbackUrl = 'https://fakestoreapi.com/products';

  /// Fetches products from external API with comprehensive error and timeout handling.
  Future<List<ExternalProductModel>> fetchProducts({
    String? search,
    String? category,
  }) async {
    Uri uri;

    if (search != null && search.trim().isNotEmpty) {
      uri = Uri.parse('$_primaryUrl/search?q=${Uri.encodeComponent(search.trim())}');
    } else if (category != null && category.trim().isNotEmpty && category.toLowerCase() != 'all') {
      uri = Uri.parse('$_primaryUrl/category/${Uri.encodeComponent(category.trim().toLowerCase())}');
    } else {
      uri = Uri.parse('$_primaryUrl?limit=30');
    }

    try {
      debugPrint('[ExternalApiService] Sending GET request to: $uri');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data['products'] is List) {
          final list = (data['products'] as List)
              .map((item) => ExternalProductModel.fromJson(Map<String, dynamic>.from(item as Map)))
              .toList();
          debugPrint('[ExternalApiService] Successfully retrieved ${list.length} products.');
          return list;
        } else if (data is List) {
          final list = data
              .map((item) => ExternalProductModel.fromJson(Map<String, dynamic>.from(item as Map)))
              .toList();
          return list;
        }
        return [];
      } else {
        throw HttpException(
          'External API returned status code ${response.statusCode}: ${response.reasonPhrase ?? 'Unknown error'}',
          uri: uri,
        );
      }
    } on SocketException catch (e) {
      debugPrint('[ExternalApiService] SocketException (No connection): $e');
      throw Exception('Network error: Unable to connect to external servers. Please check your internet connection.');
    } on TimeoutException catch (e) {
      debugPrint('[ExternalApiService] TimeoutException: $e');
      throw Exception('Request timed out: External server is taking too long to respond. Please try again.');
    } on FormatException catch (e) {
      debugPrint('[ExternalApiService] FormatException: $e');
      throw Exception('Data processing error: Received invalid JSON response from server.');
    } catch (e) {
      debugPrint('[ExternalApiService] Unexpected error: $e');
      // Attempt fallback to FakeStore API if primary endpoint fails
      try {
        return await _fetchFallback();
      } catch (_) {
        throw Exception('Failed to load marketplace products: ${e.toString().replaceAll("Exception: ", "")}');
      }
    }
  }

  /// Fallback fetcher from secondary public REST API
  Future<List<ExternalProductModel>> _fetchFallback() async {
    debugPrint('[ExternalApiService] Attempting fallback to FakeStoreAPI...');
    final response = await http.get(Uri.parse(_fallbackUrl)).timeout(const Duration(seconds: 8));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data
          .map((item) => ExternalProductModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    }
    throw Exception('Both primary and secondary external product APIs failed.');
  }

  /// Returns available external product categories
  List<String> getAvailableCategories() {
    return [
      'All',
      'Smartphones',
      'Laptops',
      'Accessories',
      'Groceries',
      'Furniture',
      'Tops',
      'Sunglasses',
    ];
  }
}
