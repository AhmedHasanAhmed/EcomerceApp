import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';
import '../../models/app_models.dart';
import 'home_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> cartItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    if (ApiService.currentUser == null) {
      setState(() {
        isLoading = false;
        cartItems = [];
      });
      return;
    }

    try {
      final items = await ApiService.getCart(ApiService.currentUser!.id);
      setState(() {
        cartItems = items;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to load cart: $e")));
    }
  }

  Future<void> _updateQuantity(String productId, int newQty) async {
    if (ApiService.currentUser == null) return;
    try {
      if (newQty < 1) {
        await ApiService.removeCartItem(ApiService.currentUser!.id, productId);
      } else {
        await ApiService.updateCartItem(ApiService.currentUser!.id, productId, newQty);
      }
      _loadCart(); // Refresh
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Update failed: $e")));
    }
  }

  double get totalPrice => cartItems.fold(0, (sum, item) => sum + (item.product.price * item.qty));

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (ApiService.currentUser == null) return const Scaffold(body: Center(child: Text("Please Login to view Cart")));

    return Scaffold(
      appBar: AppBar(title: const Text("My Cart")),
      body: cartItems.isEmpty
          ? const Center(child: Text("Your cart is empty"))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: item.product.imageUrl.isNotEmpty
                                    ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(item.product.imageUrl, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.broken_image)))
                                    : const Icon(Icons.image, color: Colors.grey),
                                ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "\$${item.product.price}",
                                      style: TextStyle(color: Theme.of(context).primaryColor),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    onPressed: () => _updateQuantity(item.product.id, item.qty - 1),
                                  ),
                                  Text("${item.qty}"),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: () => _updateQuantity(item.product.id, item.qty + 1),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Total:", style: TextStyle(fontSize: 18)),
                            Text(
                              "\$${totalPrice.toStringAsFixed(2)}",
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => CheckoutScreen(total: totalPrice)),
                            );
                          },
                          child: const Text("CHECKOUT"),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class CheckoutScreen extends StatefulWidget {
  final double total;
  const CheckoutScreen({super.key, required this.total});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _selectedPayment = 0;
  final _addressController = TextEditingController(text: "123 Main Street, New York, NY 10001");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Delivery Address
            const Text("Delivery Address", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.location_on, color: Colors.blue),
                title: const Text("Current Location"),
                subtitle: Text(_addressController.text),
                trailing: TextButton(
                  onPressed: () => _showEditAddressDialog(),
                  child: const Text("Edit"),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Payment Method
            const Text("Payment Method", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            // _buildPaymentOption(0, "Credit Card", Icons.credit_card),
            // _buildPaymentOption(1, "PayPal", Icons.account_balance_wallet),
            // _buildPaymentOption(2, "Cash on Delivery", Icons.money),
            _buildPaymentOption(3, "Balance (Wallet) - Only Accepted", Icons.account_balance),
            const SizedBox(height: 24),

            // Order Summary
            const Text("Order Summary", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Subtotal"),
                Text("\$${widget.total.toStringAsFixed(2)}"),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Delivery Fee"),
                Text("\$5.00"),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text(
                  "\$${(widget.total + 5).toStringAsFixed(2)}",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).primaryColor),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (ApiService.currentUser == null) return;
                  
                  final paymentMethod = "Balance";
                  final totalWithShipping = widget.total + 5.0;

                  if (ApiService.currentUser!.balance < totalWithShipping) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Your balance is not enough. Please add more funds.")),
                    );
                    return;
                  }

                  try {
                    await ApiService.createOrder(ApiService.currentUser!.id, {
                      "shippingAddress": _addressController.text,
                      "paymentMethod": paymentMethod,
                      "shippingPrice": 5,
                      "taxPrice": 0,
                    });
                    
                    if (!mounted) return;

                    // Dynamic balance update locally
                    if (paymentMethod == "Balance") {
                      final current = ApiService.currentUser!;
                      ApiService.currentUser = User(
                        id: current.id,
                        name: current.name,
                        email: current.email,
                        isAdmin: current.isAdmin,
                        token: current.token,
                        balance: current.balance - totalWithShipping,
                      );
                    }
                    
                    _showSuccessDialog();
                  } catch (e) {
                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Order Failed: $e")));
                  }
                },
                child: const Text("CONFIRM ORDER"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditAddressDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Delivery Address"),
        content: TextField(
          controller: _addressController,
          maxLines: 3,
          decoration: const InputDecoration(hintText: "Enter full address"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Order Confirmed!"),
        content: const Text("Your order has been placed successfully."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(int index, String title, IconData icon) {
    return RadioListTile(
      value: index,
      groupValue: _selectedPayment,
      onChanged: (value) {
        setState(() {
          _selectedPayment = value!;
        });
      },
      title: Row(
        children: [
          Icon(icon, color: _selectedPayment == index ? Theme.of(context).primaryColor : Colors.grey),
          const SizedBox(width: 12),
          Text(title),
        ],
      ),
      activeColor: Theme.of(context).primaryColor,
      contentPadding: EdgeInsets.zero,
    );
  }
}
