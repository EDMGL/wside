// ignore_for_file: unused_field, library_private_types_in_public_api, prefer_const_constructors, use_build_context_synchronously, no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:wside/app/models/account.dart';
import 'package:wside/app/models/lead.dart';
import 'package:wside/app/models/opportunity.dart';
import 'package:wside/app/models/system_user.dart';
import 'package:wside/app/modules/accouts_modules/accounts_detail_page.dart';
import 'package:wside/app/services/lead_service.dart';
import 'package:wside/app/services/opportunity_service.dart'; // OpportunityService'i import edin

class LeadDetailPage extends StatefulWidget {
  final Lead lead;

  const LeadDetailPage({required this.lead, Key? key}) : super(key: key);

  @override
  _LeadDetailPageState createState() => _LeadDetailPageState();
}

class _LeadDetailPageState extends State<LeadDetailPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _statusController;
  late TextEditingController _descriptionController;
  late TextEditingController _estimatedRevenueController;
  late TextEditingController _endDateController;
  String? _selectedAccountId;
  String? _selectedOwnerId;
  String? _selectedStatus;
  final LeadService _leadService = LeadService();
  final OpportunityService _opportunityService = OpportunityService(); // OpportunityService'i ekleyin
  bool _isLoading = false;
  bool _isEditing = false;

  final List<String> _statusOptions = ['New', 'Contacted', 'Qualified', 'Lost'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.lead.name);
    _emailController = TextEditingController(text: widget.lead.email);
    _phoneController = TextEditingController(text: widget.lead.phone);
    _statusController = TextEditingController(text: widget.lead.status);
    _descriptionController = TextEditingController(text: widget.lead.description);
    _estimatedRevenueController = TextEditingController(); // Yeni eklenen estimatedRevenue için
    _endDateController = TextEditingController(); // Yeni eklenen endDate için
    _selectedAccountId = widget.lead.accountId;
    _selectedOwnerId = widget.lead.ownerId;
    _selectedStatus = widget.lead.status;
  }

  Future<void> _saveLead(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      Lead updatedLead = Lead(
        id: widget.lead.id,
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        status: _selectedStatus!,
        accountId: _selectedAccountId!,
        ownerId: _selectedOwnerId!,
        description: _descriptionController.text,
        createdAt: widget.lead.createdAt,
      );

      try {
        await _leadService.updateLead(updatedLead);
        Get.snackbar('Success', 'Lead updated successfully');
        

        if (_selectedStatus == 'Qualified') {
          await _showOpportunityForm(context);
        }

        setState(() {
          _isEditing = false;
        });
      } catch (e) {
         Get.snackbar('Failed', 'Failed to update lead');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _proceedToOpportunity(BuildContext context, double estimatedRevenue, String endDate) async {
    if (_formKey.currentState!.validate()) {
      Opportunity newOpportunity = Opportunity(
        accountId: widget.lead.accountId,
        name: widget.lead.name,
        description: 'Generated from Lead: ${widget.lead.name}',
        status: 'New',
        leadId: widget.lead.id,
        estimatedRevenue: estimatedRevenue,
        endDate: Timestamp.fromDate(DateTime.parse(endDate)),
        createdAt: Timestamp.now(),
      );

      try {
        await _opportunityService.addOpportunity(newOpportunity);
            Get.snackbar('Success', 'Opportunity created successfully', snackPosition: SnackPosition.BOTTOM);

      } catch (e) {
        Get.snackbar('Error', 'Failed to create opportunity: $e', snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  Future<void> _showOpportunityForm(BuildContext context) async {
    final _estimatedRevenueController = TextEditingController();
    final _endDateController = TextEditingController();
    final _popupFormKey = GlobalKey<FormState>();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _popupFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Enter Opportunity Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _estimatedRevenueController,
                    decoration: InputDecoration(labelText: 'Estimated Revenue'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an estimated revenue';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _endDateController,
                    decoration: InputDecoration(labelText: 'End Date (YYYY-MM-DD)'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an end date';
                      }
                      if (DateTime.tryParse(value) == null) {
                        return 'Please enter a valid date';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_popupFormKey.currentState!.validate()) {
                        _proceedToOpportunity(
                          context,
                          double.parse(_estimatedRevenueController.text),
                          _endDateController.text,
                        );
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text('Create Opportunity'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lead.name),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveLead(context);
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
                  _isEditing
                      ? TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(labelText: 'Name'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a name';
                            }
                            return null;
                          },
                        )
                      : Text('Name: ${widget.lead.name}', style: TextStyle(fontSize: 16)),
                  _isEditing
                      ? TextFormField(
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
                        )
                      : Text('Email: ${widget.lead.email}', style: TextStyle(fontSize: 16)),
                  _isEditing
                      ? TextFormField(
                          controller: _phoneController,
                          decoration: InputDecoration(labelText: 'Phone'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a phone number';
                            }
                            return null;
                          },
                        )
                      : Text('Phone: ${widget.lead.phone}', style: TextStyle(fontSize: 16)),
                  _isEditing
                      ? TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(labelText: 'Description'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        )
                      : Text('Description: ${widget.lead.description}', style: TextStyle(fontSize: 16)),
                  _isEditing
                      ? DropdownButtonFormField<String>(
                          decoration: InputDecoration(labelText: 'Status'),
                          value: _selectedStatus,
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
                        )
                      : Text('Status: ${widget.lead.status}', style: TextStyle(fontSize: 16)),
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
                      : Card(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                            title: FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance.collection('accounts').doc(widget.lead.accountId).get(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                }
                                if (!snapshot.hasData || !snapshot.data!.exists) {
                                  return Text('Account: No account', style: TextStyle(fontSize: 16));
                                }
                                return Text('Account: ${snapshot.data!['name']}', style: TextStyle(fontSize: 16, ));
                              },
                            ),
                            onTap: () async {
                              DocumentSnapshot accountDoc = await FirebaseFirestore.instance.collection('accounts').doc(widget.lead.accountId).get();
                              Account account = Account.fromMap(accountDoc);
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
                        ),
                  _isEditing
                      ? StreamBuilder<List<SystemUser>>(
                          stream: _getUsersStream(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return CircularProgressIndicator();
                            }
                            return DropdownButtonFormField<String>(
                              decoration: InputDecoration(labelText: 'Owner'),
                              value: _selectedOwnerId,
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
                        )
                      : FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance.collection('users').doc(widget.lead.ownerId).get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            }
                            if (!snapshot.hasData || !snapshot.data!.exists) {
                              return Text('Owner: No owner', style: TextStyle(fontSize: 16));
                            }
                            return Text('Owner: ${snapshot.data!['name']}', style: TextStyle(fontSize: 16, color: Colors.blue, decoration: TextDecoration.underline));
                          },
                        ),
                  SizedBox(height: 20.0),
                  _isLoading ? CircularProgressIndicator() : Container(),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: _isEditing ? null : () => _showOpportunityForm(context),
                    child: Text('Proceed to Opportunity'),
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
