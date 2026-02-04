import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_product_management.dart';
import 'admin_users_orders.dart';
import 'admin_auth_screen.dart';
import '../../services/api_service.dart';
import '../user/login_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late Future<Map<String, dynamic>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    setState(() {
      _statsFuture = ApiService.getDashboardStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
               Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminProfileScreen()),
                );
            },
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: const Center(
                child: Text("Admin Panel", style: TextStyle(color: Colors.white, fontSize: 24)),
              ),
            ),
            ListTile(title: const Text("Dashboard"), onTap: () => Navigator.pop(context)),
            ListTile(title: const Text("Products"), onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductManagementScreen()));
            }),
            ListTile(title: const Text("Orders"), onTap: () {
               Navigator.push(context, MaterialPageRoute(builder: (context) => const OrdersManagementScreen()));
            }),
            ListTile(title: const Text("Users"), onTap: () {
               Navigator.push(context, MaterialPageRoute(builder: (context) => const UsersManagementScreen()));
            }),
            ListTile(title: const Text("Categories"), onTap: () {
               Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageCategoriesScreen()));
            }),
            ListTile(title: const Text("Logout"), onTap: () {
               ApiService.currentUser = null;
               Navigator.pushAndRemoveUntil(
                 context, 
                 MaterialPageRoute(builder: (context) => const LoginScreen()),
                 (route) => false,
               );
            }),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadStats(),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _statsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            final stats = snapshot.data ?? {};
            final recentOrders = (stats['recentOrders'] as List?) ?? [];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Cards
                  Row(
                    children: [
                      _buildSummaryCard(context, "Total Sales", "\$${stats['totalSales'] ?? 0}", Colors.blue),
                      const SizedBox(width: 16),
                      _buildSummaryCard(context, "Total Orders", "${stats['totalOrders'] ?? 0}", Colors.orange),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildSummaryCard(context, "Products", "${stats['totalProducts'] ?? 0}", Colors.green),
                      const SizedBox(width: 16),
                      _buildSummaryCard(context, "Users", "${stats['totalUsers'] ?? 0}", Colors.purple),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    "Recent Orders",
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (recentOrders.isEmpty)
                    const Center(child: Text("No Recent Orders"))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recentOrders.length,
                      itemBuilder: (context, index) {
                        final order = recentOrders[index];
                        final user = order['userId'] != null ? order['userId']['name'] : 'Unknown';
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(child: Text("${index + 1}")),
                            title: Text("Order #${order['_id'].toString().substring(order['_id'].toString().length - 4)}"),
                            subtitle: Text("$user • \$${order['totalPrice']}"),
                            trailing: Text(
                              order['status'] ?? 'Pending',
                              style: TextStyle(
                                color: order['status'] == 'Delivered' ? Colors.green : Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(value, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
