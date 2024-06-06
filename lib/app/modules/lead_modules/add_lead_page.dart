import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:wside/app/models/lead.dart';
import 'package:wside/app/models/account.dart'; // Hesap modelini import edin
import 'package:wside/app/models/system_user.dart'; // Kullanıcı modelini import edin
import 'package:wside/app/services/lead_service.dart'; // Servis sınıfını import edin

class AddLeadPage extends StatefulWidget {
  AddLeadPage({Key? key}) : super(key: key);

  @override
  _AddLeadPageState createState() => _AddLeadPageState();
}

class _AddLeadPageState extends State<AddLeadPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedStatus;
  String? _selectedAccountId;
  String? _selectedOwnerId;
  final LeadService _leadService = LeadService();

  List<String> _statusOptions = ['New', 'Contacted', 'Qualified', 'Lost'];

  Stream<List<Account>> _getAccountsStream() {
    return FirebaseFirestore.instance
        .collection('accounts')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Account.fromMap(doc)).toList());
  }

  Stream<List<SystemUser>> _getUsersStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => SystemUser.fromDoc(doc)).toList());
  }

  Future<void> _saveLead(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      Lead newLead = Lead(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        status: _selectedStatus!,
        accountId: _selectedAccountId!,
        ownerId: _selectedOwnerId!,
        description: _descriptionController.text,
        createdAt: Timestamp.now(),
      );

      try {
        await _leadService.addLead(newLead);
        Get.snackbar('Success','Lead added successfully');
        Navigator.of(context).pop();
      } catch (e) {
        Get.snackbar('Failed','Failed to add lead');

      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Lead')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              double width = constraints.maxWidth > 600
                  ? constraints.maxWidth / 2
                  : constraints.maxWidth * 0.8;
              return SizedBox(
                width: width,
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
                        controller: _descriptionController,
                        decoration: InputDecoration(labelText: 'Description'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Status'),
                        items: _statusOptions.map((String status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          setState(() {
                            _selectedStatus = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a status';
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
                      StreamBuilder<List<SystemUser>>(
                        stream: _getUsersStream(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return CircularProgressIndicator();
                          }
                          return DropdownButtonFormField<String>(
                            decoration: InputDecoration(labelText: 'Owner'),
                            items: snapshot.data!
                                .map((user) => DropdownMenuItem<String>(
                                      value: user.userId,
                                      child: Text(user.name.toString()),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedOwnerId = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select an owner';
                              }
                              return null;
                            },
                          );
                        },
                      ),
                      SizedBox(height: 20.0),
                      ElevatedButton(
                        onPressed: () => _saveLead(context),
                        child: Text('Save'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
