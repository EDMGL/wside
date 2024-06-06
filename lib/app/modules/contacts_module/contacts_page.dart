// ignore_for_file: no_leading_underscores_for_local_identifiers, prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:wside/app/models/contact.dart';
import 'package:wside/app/services/contact_service.dart'; // ContactService'i import edin
import 'package:wside/app/modules/contacts_module/add_contact_page.dart'; // AddContactPage'i import edin
import 'package:wside/app/modules/contacts_module/contact_detail_page.dart'; // ContactDetailPage'i import edin

class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key});

  Stream<List<Contact>> _getContactsStream() {
    return FirebaseFirestore.instance
        .collection('contacts')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Contact.fromMap(doc)).toList());
  }

  Future<void> _deleteContact(BuildContext context, String contactId) async {
    final ContactService _contactService = ContactService();
    try {
      await _contactService.deleteContact(contactId);
     Get.snackbar('Success', 'Contact deleted successfully');
    } catch (e) {
       Get.snackbar('Failed', 'Failed to delete contact');
     
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Contacts')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5, // Modalın genişliği
                  child: AddContactPage(), // AddContactPage içeriğini dialog içinde göster
                ),
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
      body: StreamBuilder<List<Contact>>(
        stream: _getContactsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No contacts available.'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Contact contact = snapshot.data![index];
              return Card(
                child: ListTile(
                  title: Text(contact.name),
                  subtitle: Text(contact.mail ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.delete,color: Colors.red,),
                        onPressed: () => _deleteContact(context, contact.id!),
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
                            child: ContactDetailPage(contact: contact),
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
