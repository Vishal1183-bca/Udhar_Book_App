import '../models/customer.dart';
import '../models/transaction.dart';

class SimpleStorage {
  static final SimpleStorage _instance = SimpleStorage._internal();
  factory SimpleStorage() => _instance;
  SimpleStorage._internal();

  final List<Customer> _customers = [];
  final List<Transaction> _transactions = [];
  int _nextCustomerId = 1;
  int _nextTransactionId = 1;

  Future<int> insertCustomer(Customer customer) async {
    final newCustomer = customer.copyWith(id: _nextCustomerId++);
    _customers.add(newCustomer);
    return newCustomer.id!;
  }

  Future<List<Customer>> getCustomers() async {
    return List.from(_customers);
  }

  Future<Customer?> getCustomer(int id) async {
    try {
      return _customers.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateCustomerBalance(int customerId, double newBalance) async {
    final index = _customers.indexWhere((c) => c.id == customerId);
    if (index != -1) {
      _customers[index] = _customers[index].copyWith(balance: newBalance);
    }
  }

  Future<int> insertTransaction(Transaction transaction) async {
    final newTransaction = Transaction(
      id: _nextTransactionId++,
      customerId: transaction.customerId,
      itemName: transaction.itemName,
      amount: transaction.amount,
      type: transaction.type,
      date: transaction.date,
      description: transaction.description,
    );
    _transactions.add(newTransaction);
    return newTransaction.id!;
  }

  Future<List<Transaction>> getCustomerTransactions(int customerId) async {
    return _transactions
        .where((t) => t.customerId == customerId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<List<Transaction>> getAllTransactions() async {
    return List.from(_transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
  }
}