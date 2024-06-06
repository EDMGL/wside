import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  String? id;
  String name;
  String description;
  String status;
  double price;
  String quoteId;
  String accountId;
  String submittedBy; // Yeni alan
  Timestamp createdAt;

  Order({
    this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.price,
    required this.quoteId,
    required this.accountId,
    required this.submittedBy, // Yeni alan
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status,
      'price': price,
      'quoteId': quoteId,
      'accountId': accountId,
      'submittedBy': submittedBy, // Yeni alan
      'createdAt': createdAt,
    };
  }

  factory Order.fromMap(DocumentSnapshot doc) {
    return Order(
      id: doc['id'],
      name: doc['name'],
      description: doc['description'],
      status: doc['status'],
      price: doc['price'],
      quoteId: doc['quoteId'],
      accountId: doc['accountId'],
      submittedBy: doc['submittedBy'], // Yeni alan
      createdAt: doc['createdAt'],
    );
  }
}
