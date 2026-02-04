import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/app_models.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    setState(() {
      _productsFuture = ApiService.getProducts();
    });
  }

  Future<void> _deleteProduct(String id) async {
    try {
      await ApiService.deleteProduct(id);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Product Deleted")));
      _loadProducts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to delete: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Products")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductScreen()),
          ).then((_) => _loadProducts());
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final products = snapshot.data ?? [];
          if (products.isEmpty) return const Center(child: Text("No Products Found"));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey[200],
                    child: product.imageUrl.isNotEmpty
                        ? Image.network(product.imageUrl, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.broken_image))
                        : const Icon(Icons.image, color: Colors.grey),
                  ),
                  title: Text(product.name),
                  subtitle: Text("\$${product.price}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AddProductScreen(product: product)),
                          ).then((_) => _loadProducts());
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteProduct(product.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AddProductScreen extends StatefulWidget {
  final Product? product;
  const AddProductScreen({super.key, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  final _imageUrlController = TextEditingController(); // Basic URL input for now
  String? _selectedCategory;
  late Future<List<Category>> _categoriesFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = ApiService.getCategories();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _priceController.text = widget.product!.price.toString();
      _descController.text = widget.product!.description;
      _imageUrlController.text = widget.product!.imageUrl;
      _selectedCategory = widget.product!.categoryId;
    }
  }

  Future<void> _saveProduct() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty) return;
    
    setState(() => _isLoading = true);
    
    final productData = {
      "name": _nameController.text,
      "price": double.tryParse(_priceController.text) ?? 0,
      "description": _descController.text,
      "category": _selectedCategory,
      "image": _imageUrlController.text,
      "countInStock": int.tryParse("10") ?? 10
    };

    try {
      if (widget.product != null) {
        await ApiService.updateProduct(widget.product!.id, productData);
      } else {
        await ApiService.createProduct(productData);
      }
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.product == null ? "Product Added" : "Product Updated")),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.product == null ? "Add Product" : "Edit Product")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Image Input (URL for simplicity)
             TextFormField(
              controller: _imageUrlController,
              decoration: const InputDecoration(labelText: "Image URL", prefixIcon: Icon(Icons.link)),
            ),
            const SizedBox(height: 24),
            
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Product Name"),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: "Price"), 
              keyboardType: TextInputType.number
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<Category>>(
              future: _categoriesFuture,
              builder: (context, snapshot) {
                 if (!snapshot.hasData) return const CircularProgressIndicator();
                 final categories = snapshot.data!;
                 // Validate that _selectedCategory exists in the list
                 final validValue = categories.any((c) => c.id == _selectedCategory) ? _selectedCategory : null;
                 
                 return DropdownButtonFormField<String>(
                  value: validValue,
                  decoration: const InputDecoration(labelText: "Category"),
                  items: categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val),
                );
              }
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(labelText: "Description"),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProduct,
                child: _isLoading 
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : Text(widget.product == null ? "SAVE PRODUCT" : "UPDATE PRODUCT"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
