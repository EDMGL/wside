import 'package:cloud_firestore/cloud_firestore.dart';

class Lead {
  String? id;
  String name;
  String email;
  String phone;
  String status;
  String accountId; // Account ID
  String ownerId; // Owner ID
  String description; // Description
  Timestamp? createdAt;

  Lead({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.status,
    required this.accountId,
    required this.ownerId,
    required this.description,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'status': status,
      'accountId': accountId, // Account ID
      'ownerId': ownerId, // Owner ID
      'description': description, // Description
      'createdAt': createdAt,
    };
  }

  factory Lead.fromMap(DocumentSnapshot doc) {
    return Lead(
      id: doc.id,
      name: doc['name'],
      email: doc['email'],
      phone: doc['phone'],
      status: doc['status'],
      accountId: doc['accountId'], // Account ID
      ownerId: doc['ownerId'], // Owner ID
      description: doc['description'], // Description
      createdAt: doc['createdAt'],
    );
  }
}
