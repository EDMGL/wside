import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wside/app/models/account.dart'; // Hesap modelini doğru yoldan import ettiğinizden emin olun

class AccountService {
  final CollectionReference _accountCollection = FirebaseFirestore.instance.collection('accounts');

  Future<void> addAccount(Account account) async {
    try {
      await _accountCollection.add(account.toMap());
    } catch (e) {
      throw Exception('Error adding account: $e');
    }
  }

  Future<List<Account>> getAccounts() async {
    try {
      QuerySnapshot querySnapshot = await _accountCollection.get();
      return querySnapshot.docs.map((doc) => Account.fromMap(doc)).toList();
    } catch (e) {
      throw Exception('Error getting accounts: $e');
    }
  }

  Future<void> updateAccount(Account account) async {
    try {
      await _accountCollection.doc(account.id).update(account.toMap());
    } catch (e) {
      throw Exception('Error updating account: $e');
    }
  }

  Future<void> deleteAccount(String id) async {
    try {
      await _accountCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Error deleting account: $e');
    }
  }
}
