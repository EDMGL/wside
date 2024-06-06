// ignore_for_file: prefer_const_constructors_in_immutables, library_private_types_in_public_api, prefer_final_fields, prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:wside/app/models/account.dart'; // Hesap modelini doğru yoldan import ettiğinizden emin olun
import 'package:wside/app/services/account_service.dart'; // Servis sınıfını import edin

class AddAccountsPage extends StatefulWidget {
  AddAccountsPage({Key? key}) : super(key: key);

  @override
  _AddAccountsPageState createState() => _AddAccountsPageState();
}

class _AddAccountsPageState extends State<AddAccountsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final AccountService _accountService = AccountService();
  bool _isLoading = false;

  // Dropdown options
  List<String> _industries = [
    'Agriculture', 'Automotive', 'Banking', 'Construction', 'Education',
    'Energy', 'Entertainment', 'Finance', 'Healthcare', 'Hospitality',
    'Insurance', 'Manufacturing', 'Media', 'Retail', 'Technology',
    'Telecommunications', 'Transportation', 'Utilities', 'Real Estate', 'Other'
  ];
  
  List<String> _segments = ['A', 'B', 'C'];
  
  String? _selectedIndustry;
  String? _selectedSegment;

  Future<void> _saveAccount(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      Account newAccount = Account(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        description: _descriptionController.text,
        industry: _selectedIndustry,
        segment: _selectedSegment,
        createdAt: Timestamp.now(),
      );

      try {
        await _accountService.addAccount(newAccount);
        Get.snackbar('Success', 'Account added successfully');
        Navigator.of(context).pop();
      } catch (e) {
        Get.snackbar('Error', 'Failed to add account');
        
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Account')),
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
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email';
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
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: 'Description'),
                  ),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Industry'),
                    items: _industries.map((String industry) {
                      return DropdownMenuItem<String>(
                        value: industry,
                        child: Text(industry),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedIndustry = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select an industry';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Segment'),
                    items: _segments.map((String segment) {
                      return DropdownMenuItem<String>(
                        value: segment,
                        child: Text(segment),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSegment = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a segment';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20.0),
                  _isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () => _saveAccount(context),
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
