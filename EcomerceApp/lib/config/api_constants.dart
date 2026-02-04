class ApiConstants {
  static const bool _isProduction = false;
  
  static const String _localUrl = 'http://localhost:8000/api';
  static const String _prodUrl = 'https://your-app-name.onrender.com/api'; // Change this later

  static const String baseUrl = _isProduction ? _prodUrl : _localUrl; 
  
  static const String login = '$baseUrl/user/login';
  static const String register = '$baseUrl/user/register';
  static const String products = '$baseUrl/products';
  static const String categories = '$baseUrl/categories';
  static const String cart = '$baseUrl/cart';
  static const String orders = '$baseUrl/orders';
  static const String stats = '$baseUrl/stats';
}
