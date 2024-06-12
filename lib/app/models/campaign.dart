import 'package:cloud_firestore/cloud_firestore.dart';

class Campaign {
  String id;
  String name;
  String description;
  String type; // 'account' veya 'product'
  String referenceId; // Account ID veya Product ID
  Timestamp createdAt;

  Campaign({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.referenceId,
    required this.createdAt,
  });

  factory Campaign.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Campaign(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      type: data['type'] ?? '',
      referenceId: data['referenceId'] ?? '',
      createdAt: doc['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'type': type,
      'referenceId': referenceId,
      'createdAt': createdAt,
    };
  }
}
