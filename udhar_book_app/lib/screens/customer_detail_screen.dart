import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/customer.dart';
import '../models/transaction.dart';
import '../services/database_helper.dart';
import '../services/sms_service.dart';

class CustomerDetailScreen extends StatefulWidget {
  final Customer customer;

  const CustomerDetailScreen({super.key, required this.customer});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  final DatabaseHelper _storage = DatabaseHelper();
  final _itemController = TextEditingController();
  final _amountController = TextEditingController();
  List<Transaction> transactions = [];
  Customer? currentCustomer;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    currentCustomer = widget.customer;
    _loadTransactions();
  }

  @override
  void dispose() {
    _itemController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    setState(() => isLoading = true);
    transactions = await _storage.getCustomerTransactions(widget.customer.id!);
    currentCustomer = await _storage.getCustomer(widget.customer.id!);
    setState(() => isLoading = false);
  }

  Future<void> _addTransaction(TransactionType type) async {
    if (_itemController.text.trim().isEmpty || _amountController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid amount')),
      );
      return;
    }

    final transaction = Transaction(
      customerId: widget.customer.id!,
      itemName: _itemController.text.trim(),
      amount: amount,
      type: type,
    );

    await _storage.insertTransaction(transaction);

    double newBalance = currentCustomer!.balance;
    if (type == TransactionType.credit) {
      newBalance += amount;  // Customer bought items - owes more
    } else if (type == TransactionType.debit) {
      newBalance -= amount;  // Customer made payment - owes less
    }
    
    // Don't let balance go negative (customer can't owe negative amount)
    if (newBalance < 0) newBalance = 0;

    await _storage.updateCustomerBalance(widget.customer.id!, newBalance);
    currentCustomer = currentCustomer!.copyWith(balance: newBalance);

    await SmsService.sendTransactionSms(currentCustomer!, transaction);

    _itemController.clear();
    _amountController.clear();
    _loadTransactions();

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction added successfully!')),
      );
    }
  }

  void _showAddTransactionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Transaction'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _itemController,
              decoration: const InputDecoration(
                labelText: 'Item Name / Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
                prefixText: '₹ ',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _addTransaction(TransactionType.credit),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[600]),
            child: const Text('Buy Item (Credit)', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () => _addTransaction(TransactionType.debit),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[600]),
            child: const Text('Make Payment', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showClearBalanceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Balance'),
        content: Text(
          'Clear pending amount of ₹${currentCustomer!.balance.toStringAsFixed(2)}?\n\nThis will mark all pending payments as completed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _clearBalance(),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[600]),
            child: const Text('Clear Balance', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _clearBalance() async {
    if (currentCustomer!.balance <= 0) return;

    final transaction = Transaction(
      customerId: widget.customer.id!,
      itemName: 'Balance Cleared',
      amount: currentCustomer!.balance,
      type: TransactionType.payment,
    );

    await _storage.insertTransaction(transaction);
    await _storage.updateCustomerBalance(widget.customer.id!, 0.0);
    currentCustomer = currentCustomer!.copyWith(balance: 0.0);

    await SmsService.sendTransactionSms(currentCustomer!, transaction);

    _loadTransactions();

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Balance cleared successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.customer.name),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildCustomerInfo(),
                Expanded(child: _buildTransactionList()),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransactionDialog,
        backgroundColor: Colors.blue[600],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: currentCustomer!.balance > 0 ? Colors.red[100] : Colors.green[100],
                child: Icon(
                  Icons.person,
                  size: 30,
                  color: currentCustomer!.balance > 0 ? Colors.red[600] : Colors.green[600],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentCustomer!.name,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(currentCustomer!.mobile, style: TextStyle(color: Colors.grey[600])),
                    Text(currentCustomer!.email, style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: currentCustomer!.balance > 0 ? Colors.red[50] : Colors.green[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      currentCustomer!.balance > 0 ? Icons.arrow_upward : Icons.check_circle,
                      color: currentCustomer!.balance > 0 ? Colors.red[600] : Colors.green[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      currentCustomer!.balance > 0 ? 'To Receive: ₹${currentCustomer!.balance.toStringAsFixed(2)}' : 'All Clear',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: currentCustomer!.balance > 0 ? Colors.red[600] : Colors.green[600],
                      ),
                    ),
                  ],
                ),
                if (currentCustomer!.balance > 0) ...[
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _showClearBalanceDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Clear All Pending'),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    if (transactions.isEmpty) {
      return const Center(
        child: Text('No transactions yet', style: TextStyle(fontSize: 16, color: Colors.grey)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final isCredit = transaction.type == TransactionType.credit;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isCredit ? Colors.red[100] : Colors.green[100],
              child: Icon(
                isCredit ? Icons.shopping_cart : Icons.payment,
                color: isCredit ? Colors.red[600] : Colors.green[600],
              ),
            ),
            title: Text(transaction.itemName, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(DateFormat('dd MMM yyyy, hh:mm a').format(transaction.date)),
            trailing: Text(
              '₹${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isCredit ? Colors.red[600] : Colors.green[600],
              ),
            ),
          ),
        );
      },
    );
  }
}