class User {
  final String id;
  final String name;
  final String email;
  final bool isAdmin;
  final String? token;
  final double balance;
  final List<String> wishlist;

  User({
    required this.id, 
    required this.name, 
    required this.email, 
    this.isAdmin = false, 
    this.token,
    this.balance = 0.0,
    this.wishlist = const [],
    this.image = "",
  });

  final String image;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      isAdmin: json['role'] == 'admin' || (json['isAdmin'] ?? false),
      token: json['token'],
      balance: (json['balance'] ?? 0).toDouble(),
      wishlist: json['wishlist'] != null ? List<String>.from(json['wishlist'].map((x) => x is Map ? x['_id'] : x.toString())) : [],
      image: json['image'] ?? "",
    );
  }
}

class Category {
  final String id;
  final String name;
  final String? icon;

  Category({required this.id, required this.name, this.icon});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'],
    );
  }
}

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl; // Assuming single image for now, or use first of array
  final double rating;
  final String categoryId;
  final int countInStock;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.rating = 0.0,
    required this.categoryId,
    this.countInStock = 0,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    String img = '';
    if (json['image'] is String) {
      img = json['image'];
    } else if (json['images'] is List && (json['images'] as List).isNotEmpty) {
      img = (json['images'] as List).first;
    }

    return Product(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unknown',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: img,
      rating: (json['rating'] ?? 0).toDouble(),
      categoryId: json['categoryId'] is Map 
          ? json['categoryId']['_id'] 
          : (json['categoryId'] ?? (json['category'] is Map ? json['category']['_id'] : (json['category'] ?? ''))),
      countInStock: json['countInStock'] ?? 0,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'image': imageUrl,
      'category': categoryId,
      'countInStock': countInStock,
    };
  }
}

class CartItem {
  final Product product;
  int qty;

  CartItem({required this.product, this.qty = 1});
  
  // Back-end uses 'productId' for the populated product object and 'qty' for quantity
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: json['productId'] != null 
          ? Product.fromJson(json['productId']) 
          : Product(id: '', name: 'Unknown Product', description: '', price: 0.0, imageUrl: '', categoryId: ''),
      qty: json['qty'] ?? 1,
    );
  }
}
