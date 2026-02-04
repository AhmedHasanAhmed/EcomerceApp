import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' hide Category;
import '../config/api_constants.dart';
import '../models/app_models.dart';

class ApiService {
  // Headers
  static Map<String, String> get headers => {
    "Content-Type": "application/json",
  };

  static final ValueNotifier<int> cartCount = ValueNotifier(0);

  // Auth
  static Future<User> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiConstants.register),
      headers: headers,
      body: jsonEncode({"name": name, "email": email, "password": password}),
    );
    final data = _handleResponse(response);
    return User.fromJson(data); // Assuming response returns user object directly or in 'user' key
  }

  static Future<User> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiConstants.login),
      headers: headers,
      body: jsonEncode({"email": email, "password": password}),
    );
    final data = _handleResponse(response);
    final user = User.fromJson(data.containsKey('user') ? data['user'] : data);
    currentUser = user;
    return user;
  }

  // Wishlist
  static Future<void> toggleWishlist(String userId, String productId) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/user/$userId/wishlist/$productId'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['wishlist'] != null && currentUser != null) {
        final List<String> newWishlist = List<String>.from(data['wishlist'].map((x) => x.toString()));
        currentUser = User(
          id: currentUser!.id,
          name: currentUser!.name,
          email: currentUser!.email,
          isAdmin: currentUser!.isAdmin,
          token: currentUser!.token,
          balance: currentUser!.balance,
          wishlist: newWishlist,
        );
      }
    }
  }

  static Future<List<Product>> getWishlist(String userId) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/user/$userId/wishlist'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load wishlist');
    }
  }

  // Products
  static Future<List<Product>> getProducts() async {
    final response = await http.get(Uri.parse(ApiConstants.products));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  static Future<List<Product>> searchProducts(String query) async {
    final response = await http.get(Uri.parse('${ApiConstants.products}/query?query=${Uri.encodeComponent(query)}'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search products');
    }
  }

  static Future<Product> createProduct(Map<String, dynamic> productData) async {
     final response = await http.post(
      Uri.parse(ApiConstants.products),
      headers: headers,
      body: jsonEncode(productData),
    );
    final data = _handleResponse(response);
    return Product.fromJson(data);
  }

  static Future<Product> updateProduct(String id, Map<String, dynamic> productData) async {
     final response = await http.put(
      Uri.parse('${ApiConstants.products}/$id'),
      headers: headers,
      body: jsonEncode(productData),
    );
    final data = _handleResponse(response);
    return Product.fromJson(data);
  }
  
  static Future<void> deleteProduct(String id) async {
    final response = await http.delete(
      Uri.parse('${ApiConstants.products}/$id'),
      headers: headers,
    );
    _handleResponse(response);
  }

  // Categories
  static Future<List<Category>> getCategories() async {
     final response = await http.get(Uri.parse(ApiConstants.categories));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Category.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  // State
  static User? currentUser;

  // Generic Response Handler
  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }

  // Cart
  static Future<Map<String, dynamic>> addToCart(String userId, String productId, int qty) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.cart}/add'),
      headers: headers,
      body: jsonEncode({"userId": userId, "productId": productId, "qty": qty}),
    );
    final data = _handleResponse(response);
    
    // Sync cart count
    await getCart(userId);
    
    return data;
  }

  static Future<List<CartItem>> getCart(String userId) async {
    final response = await http.get(Uri.parse('${ApiConstants.cart}/$userId'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<CartItem> items = [];
      if (data is Map && data.containsKey('items')) {
         items = (data['items'] as List).map((i) => CartItem.fromJson(i)).toList();
      } else if (data is List) {
         items = data.map((i) => CartItem.fromJson(i)).toList();
      }

      // Update global count
      int total = 0;
      for (var item in items) {
        total += item.qty;
      }
      cartCount.value = total;

      return items;
    } else {
       if (response.statusCode == 404) {
         cartCount.value = 0;
         return [];
       }
       throw Exception('Failed to load cart');
    }
  }

  static Future<void> updateCartItem(String userId, String productId, int qty) async {
    await http.put(
      Uri.parse('${ApiConstants.cart}/$userId/$productId'),
      headers: headers,
      body: jsonEncode({"qty": qty}),
    );
    await getCart(userId);
  }

  static Future<void> removeCartItem(String userId, String productId) async {
    await http.delete(
      Uri.parse('${ApiConstants.cart}/$userId/$productId'),
      headers: headers,
    );
    await getCart(userId);
  }

  // Orders
  static Future<void> createOrder(String userId, Map<String, dynamic> orderData) async {
     await http.post(
       Uri.parse(ApiConstants.orders),
       headers: headers,
       body: jsonEncode({ ...orderData, "userId": userId }),
     );
     // Reset cart count after successful order
     cartCount.value = 0;
  }

  static Future<List<dynamic>> getOrders() async {
    final response = await http.get(Uri.parse(ApiConstants.orders));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load orders');
    }
  }

  static Future<List<dynamic>> getUserOrders(String userId) async {
    final response = await http.get(Uri.parse('${ApiConstants.orders}/user/$userId'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user orders');
    }
  }

  static Future<void> updateOrderStatus(String orderId, String status) async {
    await http.put(
      Uri.parse('${ApiConstants.orders}/$orderId/status'),
      headers: headers,
      body: jsonEncode({"status": status}),
    );
  }

  // Users
  static Future<List<User>> getUsers() async {
    final response = await http.get(Uri.parse('${ApiConstants.baseUrl}/user/getUsers'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  static Future<void> deleteUser(String userId) async {
    await http.delete(Uri.parse('${ApiConstants.baseUrl}/user/$userId'));
  }

  static Future<void> updateUserRole(String userId, String role) async {
    await http.put(
      Uri.parse('${ApiConstants.baseUrl}/user/$userId/role'),
      headers: headers,
      body: jsonEncode({"role": role}),
    );
  }

  static Future<User> updateUserProfile(String userId, String name, String email, [String? image]) async {
    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/user/$userId/profile'),
      headers: headers,
      body: jsonEncode({
        "name": name, 
        "email": email,
        if (image != null) "image": image,
      }),
    );
    
    if (response.statusCode == 200) {
      final user = User.fromJson(jsonDecode(response.body));
      currentUser = user; // Update current user
      return user;
    } else {
      throw Exception('Failed to update profile: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> addPayment(String userId, double amount) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/user/$userId/payment'),
      headers: headers,
      body: jsonEncode({"amount": amount}),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add payment');
    }
  }

  // Categories Extra
  static Future<Category> createCategory(String name, String description) async {
    final response = await http.post(
      Uri.parse(ApiConstants.categories),
      headers: headers,
      body: jsonEncode({"name": name, "description": description}),
    );
    final data = _handleResponse(response);
    return Category.fromJson(data);
  }

  static Future<void> deleteCategory(String id) async {
    await http.delete(Uri.parse('${ApiConstants.categories}/$id'));
  }

  // Stats
  static Future<Map<String, dynamic>> getDashboardStats() async {
    final response = await http.get(Uri.parse(ApiConstants.stats));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load stats');
    }
  }
}
