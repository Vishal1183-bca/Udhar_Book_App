import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../services/database_helper.dart';
import 'add_customer_screen.dart';
import 'customer_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DatabaseHelper _storage = DatabaseHelper();
  List<Customer> customers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    setState(() => isLoading = true);
    customers = await _storage.getCustomers();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Udhar Book', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : customers.isEmpty
              ? _buildEmptyState()
              : _buildCustomerList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCustomerScreen()),
          );
          _loadCustomers();
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Add Customer'),
        backgroundColor: Colors.blue[600],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No customers yet',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first customer to get started',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customer = customers[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: customer.balance > 0 ? Colors.red[100] : Colors.green[100],
              child: Icon(
                Icons.person,
                color: customer.balance > 0 ? Colors.red[600] : Colors.green[600],
              ),
            ),
            title: Text(
              customer.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(customer.mobile),
                const SizedBox(height: 4),
                Text(
                  'Balance: ₹${customer.balance.abs().toStringAsFixed(2)}',
                  style: TextStyle(
                    color: customer.balance > 0 ? Colors.red[600] : Colors.green[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            trailing: Icon(
              customer.balance > 0 ? Icons.arrow_upward : Icons.check_circle,
              color: customer.balance > 0 ? Colors.red[600] : Colors.green[600],
            ),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CustomerDetailScreen(customer: customer),
                ),
              );
              _loadCustomers();
            },
          ),
        );
      },
    );
  }
}