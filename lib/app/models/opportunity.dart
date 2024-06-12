import 'package:cloud_firestore/cloud_firestore.dart';

class Opportunity {
  String? id;
  String name;
  String description;
  String status;
  String? leadId; // Lead ID optional
  String accountId; // Account ID
  String productId; // Product ID
  double estimatedRevenue; // Estimated Revenue
  Timestamp? endDate; // End Date
  Timestamp? createdAt;

  Opportunity({
    this.id,
    required this.name,
    required this.description,
    required this.status,
    this.leadId,
    required this.accountId,
    required this.productId,
    required this.estimatedRevenue,
    this.endDate,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status,
      'leadId': leadId,
      'accountId': accountId,
      'productId': productId,
      'estimatedRevenue': estimatedRevenue,
      'endDate': endDate,
      'createdAt': createdAt,
    };
  }

  factory Opportunity.fromMap(DocumentSnapshot doc) {
    return Opportunity(
      id: doc.id,
      name: doc['name'],
      description: doc['description'],
      status: doc['status'],
      leadId: doc['leadId'],
      accountId: doc['accountId'],
      productId: doc['productId'],
      estimatedRevenue: (doc['estimatedRevenue'] as num).toDouble(), // Convert to double
      endDate: doc['endDate'],
      createdAt: doc['createdAt'],
    );
  }
}
