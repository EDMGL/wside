import 'package:cloud_firestore/cloud_firestore.dart';

class Quote {
  String? id;
  String name;
  String description;
  String status;
  double price; // Fiyat alanı
  String opportunityId; // Opportunity ID
  String accountId; // Account ID
  Timestamp? createdAt;
  String submittedBy; // Teklif veren kişi

  Quote({
    this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.price,
    required this.opportunityId,
    required this.accountId,
    required this.submittedBy,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status,
      'price': price,
      'opportunityId': opportunityId,
      'accountId': accountId,
      'createdAt': createdAt,
      'submittedBy': submittedBy,
    };
  }

  factory Quote.fromMap(DocumentSnapshot doc) {
    return Quote(
      id: doc.id,
      name: doc['name'],
      description: doc['description'],
      status: doc['status'],
      price: (doc['price'] is int) ? (doc['price'] as int).toDouble() : doc['price'],
      opportunityId: doc['opportunityId'],
      accountId: doc['accountId'],
      createdAt: doc['createdAt'],
      submittedBy: doc['submittedBy'],
    );
  }
}
