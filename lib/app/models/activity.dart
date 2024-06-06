import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  String? id;
  String type;
  String description;
  String accountId;
  String contactId;
  String userId;
  Timestamp createdAt;
  Timestamp updatedAt;

  Activity({
    this.id,
    required this.type,
    required this.description,
    required this.accountId,
    required this.contactId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'description': description,
      'accountId': accountId,
      'contactId': contactId,
      'userId': userId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory Activity.fromMap(DocumentSnapshot doc) {
    return Activity(
      id: doc.id,
      type: doc['type'],
      description: doc['description'],
      accountId: doc['accountId'],
      contactId: doc['contactId'],
      userId: doc['userId'],
      createdAt: doc['createdAt'],
      updatedAt: doc['updatedAt'],
    );
  }
}
