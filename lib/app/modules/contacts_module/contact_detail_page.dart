// ignore_for_file: prefer_const_constructors_in_immutables, library_private_types_in_public_api, prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:wside/app/models/contact.dart';
import 'package:wside/app/modules/accouts_modules/accounts_detail_page.dart';
import 'package:wside/app/services/contact_service.dart'; // Servis sınıfını import edin
import 'package:wside/app/models/account.dart'; // Hesap modelini import edin

class ContactDetailPage extends StatefulWidget {
  final Contact contact;

  ContactDetailPage({required this.contact, Key? key}) : super(key: key);

  @override
  _ContactDetailPageState createState() => _ContactDetailPageState();
}

class _ContactDetailPageState extends State<ContactDetailPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _mailController;
  late TextEditingController _phoneController; // Yeni telefon alanı
  late TextEditingController _addressController; // Yeni adres alanı
  late TextEditingController _positionController; // Yeni pozisyon alanı
  String? _selectedAccountId;
  final ContactService _contactService = ContactService();
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact.name);
    _mailController = TextEditingController(text: widget.contact.mail);
    _phoneController = TextEditingController(text: widget.contact.phone); // Yeni telefon alanı
    _addressController = TextEditingController(text: widget.contact.address); // Yeni adres alanı
    _positionController = TextEditingController(text: widget.contact.position); // Yeni pozisyon alanı
    _selectedAccountId = widget.contact.accountId;
  }

  Future<void> _saveContact(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      Contact updatedContact = Contact(
        id: widget.contact.id,
        name: _nameController.text,
        mail: _mailController.text,
        phone: _phoneController.text, // Yeni telefon alanı
        address: _addressController.text, // Yeni adres alanı
        position: _positionController.text, // Yeni pozisyon alanı
        accountId: _selectedAccountId,
      );

      try {
        await _contactService.updateContact(updatedContact);
        Get.snackbar('Success', 'Contact updated successfully');
        setState(() {
          _isEditing = false;
        });
      } catch (e) {
        Get.snackbar('Failed', 'Failed to update contact');
        
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Stream<List<Account>> _getAccountsStream() {
    return FirebaseFirestore.instance
        .collection('accounts')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Account.fromMap(doc)).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contact.name),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveContact(context);
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.75,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField('Name', _nameController, _isEditing, 'Please enter a name'),
                  _buildTextField('Mail', _mailController, _isEditing, 'Please enter a mail'),
                  _buildTextField('Phone', _phoneController, _isEditing, 'Please enter a phone number'),
                  _buildTextField('Address', _addressController, _isEditing, 'Please enter an address'),
                  _buildTextField('Position', _positionController, _isEditing, 'Please enter a position'),
                  SizedBox(height: 20.0),
                  _isEditing
                      ? StreamBuilder<List<Account>>(
                          stream: _getAccountsStream(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return CircularProgressIndicator();
                            }
                            return DropdownButtonFormField<String>(
                              decoration: InputDecoration(labelText: 'Account'),
                              value: _selectedAccountId,
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
                        )
                      : FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance.collection('accounts').doc(widget.contact.accountId).get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            }
                            if (!snapshot.hasData || !snapshot.data!.exists) {
                              return Text('Account: No account', style: TextStyle(fontSize: 16));
                            }
                            Account account = Account.fromMap(snapshot.data!);
                            return Card(
                              child: ListTile(
                                title: Text('Account: ${account.name}', style: TextStyle(fontSize: 16)),
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => AccountDetailPage(account: account)));
                                },
                              ),
                            );
                          },
                        ),
                  SizedBox(height: 20.0),
                  _isLoading ? CircularProgressIndicator() : Container(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, bool isEditing, [String? validationMessage]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isEditing
            ? TextFormField(
                controller: controller,
                decoration: InputDecoration(labelText: label),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return validationMessage;
                  }
                  return null;
                },
              )
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Text('$label: ${controller.text}', style: TextStyle(fontSize: 16)),
              ),
        SizedBox(height: 5),
      ],
    );
  }
}
