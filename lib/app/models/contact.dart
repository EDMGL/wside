import 'package:cloud_firestore/cloud_firestore.dart';

class Contact {
  String? id;
  String name;
  String? mail;
  String? accountId;
  String? phone; // Yeni eklenen özellik
  String? address; // Yeni eklenen özellik
  String? position; // Yeni eklenen özellik

  Contact({
    this.id,
    required this.name,
    this.accountId,
    this.mail,
    this.phone, // Yeni eklenen özellik
    this.address, // Yeni eklenen özellik
    this.position, // Yeni eklenen özellik
  });

  factory Contact.fromMap(DocumentSnapshot doc) {
    return Contact(
      id: doc.id,
      name: doc['name'],
      accountId: doc['accountId'],
      mail: doc['mail'],
      phone: doc['phone'], // Yeni eklenen özellik
      address: doc['address'], // Yeni eklenen özellik
      position: doc['position'], // Yeni eklenen özellik
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'accountId': accountId,
      'mail': mail,
      'phone': phone, // Yeni eklenen özellik
      'address': address, // Yeni eklenen özellik
      'position': position, // Yeni eklenen özellik
    };
  }
}
