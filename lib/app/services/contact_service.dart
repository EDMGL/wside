import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wside/app/models/contact.dart';

class ContactService {
  final CollectionReference _contactCollection = FirebaseFirestore.instance.collection('contacts');

  Future<void> addContact(Contact contact) async {
    try {
      await _contactCollection.add(contact.toMap());
    } catch (e) {
      throw Exception('Error adding contact: $e');
    }
  }

  Future<List<Contact>> getContacts(String s) async {
    try {
      QuerySnapshot querySnapshot = await _contactCollection.get();
      return querySnapshot.docs.map((doc) => Contact.fromMap(doc)).toList();
    } catch (e) {
      throw Exception('Error getting contacts: $e');
    }
  }

  Future<void> updateContact(Contact contact) async {
    try {
      await _contactCollection.doc(contact.id).update(contact.toMap());
    } catch (e) {
      throw Exception('Error updating contact: $e');
    }
  }

  Future<void> deleteContact(String id) async {
    try {
      await _contactCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Error deleting contact: $e');
    }
  }
}
