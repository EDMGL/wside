import 'package:cloud_firestore/cloud_firestore.dart';

class PostSales {
  String? id;
  String orderId;
  String type;
  String description;
  String status;
  String priority;
  String assignedTo;
  String assignedToEmail; // Assigned user's email
  Timestamp createdAt;

  PostSales({
    this.id,
    required this.orderId,
    required this.type,
    required this.description,
    required this.status,
    required this.priority,
    required this.assignedTo,
    required this.assignedToEmail,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'type': type,
      'description': description,
      'status': status,
      'priority': priority,
      'assignedTo': assignedTo,
      'assignedToEmail': assignedToEmail,
      'createdAt': createdAt,
    };
  }

  factory PostSales.fromMap(DocumentSnapshot doc) {
    return PostSales(
      id: doc.id,
      orderId: doc['orderId'],
      type: doc['type'],
      description: doc['description'],
      status: doc['status'],
      priority: doc['priority'],
      assignedTo: doc['assignedTo'],
      assignedToEmail: doc['assignedToEmail'],
      createdAt: doc['createdAt'],
    );
  }
}
