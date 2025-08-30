enum TransactionType { credit, debit, payment }

class Transaction {
  final int? id;
  final int customerId;
  final String itemName;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final String? description;

  Transaction({
    this.id,
    required this.customerId,
    required this.itemName,
    required this.amount,
    required this.type,
    DateTime? date,
    this.description,
  }) : date = date ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'item_name': itemName,
      'amount': amount,
      'type': type.name,
      'date': date.millisecondsSinceEpoch,
      'description': description,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      customerId: map['customer_id'],
      itemName: map['item_name'],
      amount: map['amount']?.toDouble() ?? 0.0,
      type: TransactionType.values.firstWhere((e) => e.name == map['type']),
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      description: map['description'],
    );
  }
}