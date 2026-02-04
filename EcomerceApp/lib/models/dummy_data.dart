class Category {
  final String id;
  final String name;
  final String icon; // Using string to simulate asset path or icon name

  Category({required this.id, required this.name, required this.icon});
}

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final double rating;
  final String categoryId;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.rating,
    required this.categoryId,
  });
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

// Dummy Data
final List<Category> dummyCategories = [
  Category(id: 'c1', name: 'Electronics', icon: 'assets/icons/electronics.png'),
  Category(id: 'c2', name: 'Fashion', icon: 'assets/icons/fashion.png'),
  Category(id: 'c3', name: 'Home', icon: 'assets/icons/home.png'),
  Category(id: 'c4', name: 'Beauty', icon: 'assets/icons/beauty.png'),
  Category(id: 'c5', name: 'Sports', icon: 'assets/icons/sports.png'),
];

final List<Product> dummyProducts = [
  Product(
    id: 'p1',
    name: 'Wireless Headphones',
    description: 'High quality wireless headphones with noise cancellation.',
    price: 99.99,
    imageUrl: 'https://via.placeholder.com/300', // Placeholder
    rating: 4.5,
    categoryId: 'c1',
  ),
  Product(
    id: 'p2',
    name: 'Smart Watch',
    description: 'Track your fitness and notifications.',
    price: 149.99,
    imageUrl: 'https://via.placeholder.com/300',
    rating: 4.2,
    categoryId: 'c1',
  ),
  Product(
    id: 'p3',
    name: 'Running Shoes',
    description: 'Comfortable shoes for daily running.',
    price: 79.99,
    imageUrl: 'https://via.placeholder.com/300',
    rating: 4.8,
    categoryId: 'c2',
  ),
  Product(
    id: 'p4',
    name: 'Cotton T-Shirt',
    description: '100% Cotton, breathable and soft.',
    price: 19.99,
    imageUrl: 'https://via.placeholder.com/300',
    rating: 4.0,
    categoryId: 'c2',
  ),
];
