class Customer {
  final int? id;
  final String name;
  final String mobile;
  final String email;
  final double balance;
  final DateTime createdAt;

  Customer({
    this.id,
    required this.name,
    required this.mobile,
    required this.email,
    this.balance = 0.0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'email': email,
      'balance': balance,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      name: map['name'],
      mobile: map['mobile'],
      email: map['email'],
      balance: map['balance']?.toDouble() ?? 0.0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }

  Customer copyWith({
    int? id,
    String? name,
    String? mobile,
    String? email,
    double? balance,
    DateTime? createdAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}