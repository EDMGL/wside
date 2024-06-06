// ignore_for_file: no_leading_underscores_for_local_identifiers, prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:wside/app/models/account.dart';
import 'package:wside/app/modules/accouts_modules/accounts_detail_page.dart';
import 'package:wside/app/modules/accouts_modules/add_accounts_page.dart';
import 'package:wside/app/services/account_service.dart'; // AccountService'i import edin

class AccountsPage extends StatelessWidget {
  const AccountsPage({super.key});

  Stream<List<Account>> _getAccountsStream() {
    return FirebaseFirestore.instance
        .collection('accounts')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Account.fromMap(doc)).toList());
  }

  Future<void> _deleteAccount(BuildContext context, String accountId) async {
    final AccountService _accountService = AccountService();
    try {
      await _accountService.deleteAccount(accountId);
         Get.snackbar('Success','Account deleted successfully');
    } catch (e) {
               Get.snackbar('Failed','Failed to delete account');

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Accounts')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5, // Modalın genişliği
                  child: AddAccountsPage(), // AddAccountPage içeriğini dialog içinde göster
                ),
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
      body: StreamBuilder<List<Account>>(
        stream: _getAccountsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No accounts available.'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Account account = snapshot.data![index];
              return Card(
                child: ListTile(
                  title: Text(account.name,style: TextStyle(fontWeight: FontWeight.bold),),
                  subtitle: Text(account.email),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.delete,color: Colors.red,),
                        onPressed: () => _deleteAccount(context, account.id!),
                      ),
                    ],
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.75,
                            child: AccountDetailPage(account: account),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
