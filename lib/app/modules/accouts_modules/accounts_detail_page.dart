// ignore_for_file: prefer_const_constructors_in_immutables, library_private_types_in_public_api, prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:wside/app/models/account.dart';
import 'package:wside/app/models/contact.dart'; // Contact modelini import edin
import 'package:wside/app/modules/contacts_module/contact_detail_page.dart';
import 'package:wside/app/services/account_service.dart'; // Servis sınıfını import edin

class AccountDetailPage extends StatefulWidget {
  final Account account;

  AccountDetailPage({required this.account, Key? key}) : super(key: key);

  @override
  _AccountDetailPageState createState() => _AccountDetailPageState();
}

class _AccountDetailPageState extends State<AccountDetailPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _descriptionController;
  late TextEditingController _industryController;
  late TextEditingController _segmentController;
  final AccountService _accountService = AccountService();
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account.name);
    _emailController = TextEditingController(text: widget.account.email);
    _phoneController = TextEditingController(text: widget.account.phone);
    _addressController = TextEditingController(text: widget.account.address);
    _descriptionController = TextEditingController(text: widget.account.description);
    _industryController = TextEditingController(text: widget.account.industry);
    _segmentController = TextEditingController(text: widget.account.segment);
  }

  Future<void> _saveAccount(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      Account updatedAccount = Account(
        id: widget.account.id,
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        description: _descriptionController.text,
        industry: _industryController.text,
        segment: _segmentController.text,
        createdAt: widget.account.createdAt,
      );

      try {
        await _accountService.updateAccount(updatedAccount);
        Get.snackbar('Success','Account updated successfully');
        setState(() {
          _isEditing = false;
        });
      } catch (e) {
   Get.snackbar('Error','Failed to updated');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Stream<List<Contact>> _getContactsStream() {
    return FirebaseFirestore.instance
        .collection('contacts')
        .where('accountId', isEqualTo: widget.account.id)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Contact.fromMap(doc)).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.account.name),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveAccount(context);
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
                  _buildTextField(
                      'Email',
                      _emailController,
                      _isEditing,
                      'Please enter an email'),
                  _buildTextField('Phone', _phoneController, _isEditing, 'Please enter a phone number'),
                  _buildTextField('Address', _addressController, _isEditing),
                  _buildTextField('Description', _descriptionController, _isEditing),
                  _buildTextField('Industry', _industryController, _isEditing),
                  _buildTextField('Segment', _segmentController, _isEditing),
                  SizedBox(height: 20.0),
                  Text('Contacts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  StreamBuilder<List<Contact>>(
                    stream: _getContactsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Text('No contacts associated with this account.');
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          Contact contact = snapshot.data![index];
                          return Card(
                            child: ListTile(
                              title: Text(contact.name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(contact.mail ?? 'No email'),
                                  Text(contact.phone ?? 'No phone'),
                                ],
                              ),
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => ContactDetailPage(contact: contact)));
                              },
                            ),
                          );
                        },
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
