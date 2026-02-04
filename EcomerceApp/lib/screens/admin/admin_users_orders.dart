import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/app_models.dart';
import '../user/login_screen.dart';
import '../user/profile_settings_screens.dart';
import '../user/edit_profile_payment_screens.dart';
import 'admin_auth_screen.dart';

class OrdersManagementScreen extends StatefulWidget {
  const OrdersManagementScreen({super.key});

  @override
  State<OrdersManagementScreen> createState() => _OrdersManagementScreenState();
}

class _OrdersManagementScreenState extends State<OrdersManagementScreen> {
  late Future<List<dynamic>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    setState(() {
      _ordersFuture = ApiService.getOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Orders")),
      body: FutureBuilder<List<dynamic>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final orders = snapshot.data ?? [];
          if (orders.isEmpty) return const Center(child: Text("No Orders Found"));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final orderId = order['_id'];
              final user = order['user'] != null ? order['user']['name'] : 'Unknown';
              final total = order['totalPrice'] ?? 0;
              String currentStatus = order['status'] ?? 'Pending';
              // Capitalize first letter to match dropdown values
              currentStatus = currentStatus[0].toUpperCase() + currentStatus.substring(1);

              return Card(
                child: ExpansionTile(
                  title: Text("Order #$orderId"),
                  subtitle: Text("User: $user • \$$total"),
                  children: [
                    ListTile(
                      title: const Text("Update Status"),
                      trailing: DropdownButton<String>(
                        value: currentStatus,
                        items: const [
                           DropdownMenuItem(value: "Pending", child: Text("Pending")),
                           DropdownMenuItem(value: "Processing", child: Text("Processing")),
                           DropdownMenuItem(value: "Shipped", child: Text("Shipped")),
                           DropdownMenuItem(value: "Delivered", child: Text("Delivered")),
                        ],
                        onChanged: (val) async {
                          if (val != null) {
                            try {
                              await ApiService.updateOrderStatus(orderId, val);
                              _loadOrders();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  late Future<List<User>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    setState(() {
      _usersFuture = ApiService.getUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Users")),
      body: FutureBuilder<List<User>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final users = snapshot.data ?? [];
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?')
                ),
                title: Text(user.name),
                subtitle: Text("${user.email} • Role: ${user.isAdmin ? 'Admin' : 'User'}"),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'toggle_role', 
                      child: Text(user.isAdmin ? "Make Regular User" : "Make Admin")
                    ),
                    const PopupMenuItem(
                      value: 'delete', 
                      child: Text("Delete User", style: TextStyle(color: Colors.red))
                    ),
                  ],
                  onSelected: (val) async {
                    if (val == 'delete') {
                      try {
                        await ApiService.deleteUser(user.id);
                        if (!mounted) return;
                        _loadUsers();
                      } catch (e) {
                         if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                      }
                    } else if (val == 'toggle_role') {
                      try {
                         // Send new role to backend
                         await ApiService.updateUserRole(user.id, user.isAdmin ? 'user' : 'admin');
                         if (!mounted) return;
                         _loadUsers();
                      } catch (e) {
                         if (!mounted) return;
                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                      }
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  late Future<List<Category>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() {
    setState(() {
      _categoriesFuture = ApiService.getCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Categories")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddCategoryDialog();
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Category>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final categories = snapshot.data ?? [];
          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return ListTile(
                leading: const Icon(Icons.category),
                title: Text(cat.name),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    try {
                      await ApiService.deleteCategory(cat.id);
                      _loadCategories();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Category"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(hintText: "Category Name")),
            const SizedBox(height: 10),
            TextField(controller: descController, decoration: const InputDecoration(hintText: "Description")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && descController.text.isNotEmpty) {
                try {
                  await ApiService.createCategory(nameController.text, descController.text);
                  if (!mounted) return;
                  Navigator.pop(context);
                  _loadCategories();
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Profile")),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 50),
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.blue,
              backgroundImage: (ApiService.currentUser?.image.isNotEmpty ?? false)
                  ? NetworkImage(ApiService.currentUser!.image)
                  : null,
              child: (ApiService.currentUser?.image.isEmpty ?? true)
                  ? const Icon(Icons.shield, size: 60, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 20),
            Text(ApiService.currentUser?.name ?? "Super Admin", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(ApiService.currentUser?.email ?? "admin@shopease.com", style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                );
                setState(() {}); // Refresh image on return
              },
              icon: const Icon(Icons.edit, size: 16),
              label: const Text("Edit Admin Profile"),
            ),
            const SizedBox(height: 32),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
                setState(() {});
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () {
                 ApiService.currentUser = null;
                 Navigator.pushAndRemoveUntil(
                   context,
                   MaterialPageRoute(builder: (context) => const LoginScreen()),
                   (route) => false,
                 );
              },
            ),
          ],
        ),
      ),
    );
  }
}
