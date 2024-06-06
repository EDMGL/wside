import 'package:cloud_firestore/cloud_firestore.dart';

class Account {
  String? id;
  String name;
  String email;
  String phone;
  String? address;
  String? description; // Şirketin açıklaması
  String? industry; // Endüstri alanı
  String? segment; // Segment alanı
  Timestamp? createdAt; // Hesap oluşturulma tarihi

  Account({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.address,
    this.description,
    this.industry,
    this.segment,
    this.createdAt,
  });

  // Firestore'dan veri çekmek ve veri göndermek için Map dönüşüm metodları
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'description': description,
      'industry': industry,
      'segment': segment,
      'createdAt': createdAt,
    };
  }

  factory Account.fromMap(DocumentSnapshot doc) {
    return Account(
      id: doc.id,
      name: doc['name'],
      email: doc['email'],
      phone: doc['phone'],
      address: doc['address'],
      description: doc['description'],
      industry: doc['industry'],
      segment: doc['segment'],
      createdAt: doc['createdAt'],
    );
  }
}
