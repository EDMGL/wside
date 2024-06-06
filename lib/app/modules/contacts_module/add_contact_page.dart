// ignore_for_file: prefer_const_constructors_in_immutables, library_private_types_in_public_api, prefer_final_fields, prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:wside/app/models/contact.dart';
import 'package:wside/app/models/account.dart'; // Hesap modelini import edin
import 'package:wside/app/services/contact_service.dart'; // İlgili servis sınıfını import edin

class AddContactPage extends StatefulWidget {
  AddContactPage({Key? key}) : super(key: key);

  @override
  _AddContactPageState createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController(); // Yeni telefon alanı
  final TextEditingController _addressController = TextEditingController(); // Yeni adres alanı
  String? _selectedPosition; // Seçilen pozisyon
  String? _selectedAccountId;
  final ContactService _contactService = ContactService();

  // Dropdown options for positions
  List<String> _positions = [
    'Manager', 'Sales Representative', 'Engineer', 'Consultant', 'Director',
    'Vice President', 'President', 'CEO', 'CFO', 'COO',
    'CTO', 'Developer', 'Analyst', 'Designer', 'Technician',
    'Specialist', 'Coordinator', 'Assistant', 'Supervisor', 'Executive'
  ];

  Stream<List<Account>> _getAccountsStream() {
    return FirebaseFirestore.instance
        .collection('accounts')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Account.fromMap(doc)).toList());
  }

  Future<void> _saveContact(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      Contact newContact = Contact(
        name: _nameController.text,
        mail: _mailController.text,
        phone: _phoneController.text, // Yeni telefon alanı
        address: _addressController.text, // Yeni adres alanı
        position: _selectedPosition, // Yeni pozisyon alanı
        accountId: _selectedAccountId,
      );

      try {
        await _contactService.addContact(newContact);
        Get.snackbar('Success', 'Contact added successfully');
        Navigator.of(context).pop();
      } catch (e) {
       Get.snackbar('Failed', 'Failed to add contact');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Contact')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _mailController,
                    decoration: InputDecoration(labelText: 'Mail'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a mail';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(labelText: 'Phone'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a phone number';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(labelText: 'Address'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an address';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Position'),
                    items: _positions.map((String position) {
                      return DropdownMenuItem<String>(
                        value: position,
                        child: Text(position),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPosition = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a position';
                      }
                      return null;
                    },
                  ),
                  StreamBuilder<List<Account>>(
                    stream: _getAccountsStream(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return CircularProgressIndicator();
                      }
                      return DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Account'),
                        items: snapshot.data!
                            .map((account) => DropdownMenuItem<String>(
                                  value: account.id,
                                  child: Text(account.name),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedAccountId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select an account';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () => _saveContact(context),
                    child: Text('Save'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
