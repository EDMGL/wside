import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:wside/app/models/opportunity.dart';
import 'package:wside/app/models/account.dart';
import 'package:wside/app/models/lead.dart';
import 'package:wside/app/models/products.dart';
import 'package:wside/app/models/quote.dart';

import 'package:wside/app/models/system_user.dart';
import 'package:wside/app/modules/accouts_modules/accounts_detail_page.dart';
import 'package:wside/app/modules/lead_modules/lead_detail_page.dart';
import 'package:wside/app/services/opportunity_service.dart';
import 'package:wside/app/services/quote_service.dart';

class OpportunityDetailPage extends StatefulWidget {
  final Opportunity opportunity;

  const OpportunityDetailPage({required this.opportunity, Key? key}) : super(key: key);

  @override
  _OpportunityDetailPageState createState() => _OpportunityDetailPageState();
}

class _OpportunityDetailPageState extends State<OpportunityDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final _quoteFormKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _estimatedRevenueController;
  late TextEditingController _endDateController;
  String? _selectedStatus;
  String? _selectedSubmittedBy;
  String? _selectedProductId;
  final OpportunityService _opportunityService = OpportunityService();
  final QuoteService _quoteService = QuoteService();
  bool _isLoading = false;
  bool _isEditing = false;

  final List<String> _statusOptions = ['New', 'In Progress', 'Won', 'Lost'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.opportunity.name);
    _descriptionController = TextEditingController(text: widget.opportunity.description);
    _priceController = TextEditingController();
    _estimatedRevenueController = TextEditingController(text: widget.opportunity.estimatedRevenue.toString());
    _endDateController = TextEditingController(text: widget.opportunity.endDate != null ? widget.opportunity.endDate!.toDate().toString().split(' ')[0] : '');
    _selectedStatus = widget.opportunity.status;
    _selectedProductId = widget.opportunity.productId;
  }

  Future<void> _saveOpportunity() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      Opportunity updatedOpportunity = Opportunity(
        id: widget.opportunity.id,
        name: _nameController.text,
        description: _descriptionController.text,
        status: _selectedStatus!,
        leadId: widget.opportunity.leadId,
        accountId: widget.opportunity.accountId,
        productId: _selectedProductId!,
        estimatedRevenue: double.parse(_estimatedRevenueController.text),
        endDate: Timestamp.fromDate(DateTime.parse(_endDateController.text)),
        createdAt: widget.opportunity.createdAt,
      );

      try {
        await _opportunityService.updateOpportunity(updatedOpportunity);
        Get.snackbar('Success', 'Opportunity updated successfully', snackPosition: SnackPosition.BOTTOM);

        if (_selectedStatus == 'Won') {
          _showQuoteForm();
        }

        setState(() {
          _isEditing = false;
        });
      } catch (e) {
        Get.snackbar('Error', 'Failed to update opportunity: $e', snackPosition: SnackPosition.BOTTOM);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _proceedToQuote() async {
    if (_quoteFormKey.currentState!.validate()) {
      Quote newQuote = Quote(
        name: widget.opportunity.name,
        description: 'Generated from Opportunity: ${widget.opportunity.name}',
        status: 'Draft',
        price: double.parse(_priceController.text),
        opportunityId: widget.opportunity.id!,
        accountId: widget.opportunity.accountId,
        createdAt: Timestamp.now(),
        submittedBy: _selectedSubmittedBy!,
      );

      try {
        await _quoteService.addQuote(newQuote);
        Get.snackbar('Success', 'Quote created successfully', snackPosition: SnackPosition.BOTTOM);
      } catch (e) {
        Get.snackbar('Error', 'Failed to create quote: $e', snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  void _showQuoteForm() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _quoteFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Enter Quote Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a price';
                      }
                      return null;
                    },
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('users').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return CircularProgressIndicator();
                      var users = snapshot.data!.docs.map((doc) => SystemUser.fromDoc(doc)).toList();
                      return DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Submitted By'),
                        items: users.map((user) {
                          return DropdownMenuItem<String>(
                            value: user.userId,
                            child: Text(user.name ?? ''),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSubmittedBy = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a user';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _proceedToQuote();
                      Navigator.of(context).pop();
                    },
                    child: Text('Create Quote'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<DocumentSnapshot?> _getLead() async {
    if (widget.opportunity.leadId == null || widget.opportunity.leadId!.isEmpty) {
      return null;
    }
    return await FirebaseFirestore.instance.collection('leads').doc(widget.opportunity.leadId).get();
  }

  Future<DocumentSnapshot?> _getAccount() async {
    if (widget.opportunity.accountId == null || widget.opportunity.accountId.isEmpty) {
      return null;
    }
    return await FirebaseFirestore.instance.collection('accounts').doc(widget.opportunity.accountId).get();
  }

  Stream<List<Product>> _getProductsStream() {
    return FirebaseFirestore.instance
        .collection('products')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.opportunity.name),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveOpportunity();
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
                  Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      title: _isEditing
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
                          : Text('Name: ${widget.opportunity.name}', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      title: _isEditing
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
                          : Text('Description: ${widget.opportunity.description}', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      title: _isEditing
                          ? TextFormField(
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
                            )
                          : Text('Estimated Revenue: ${widget.opportunity.estimatedRevenue}', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      title: _isEditing
                          ? TextFormField(
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
                            )
                          : Text('End Date: ${widget.opportunity.endDate != null ? widget.opportunity.endDate!.toDate().toString().split(' ')[0] : ''}', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      title: _isEditing
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
                          : Text('Status: ${widget.opportunity.status}', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  StreamBuilder<List<Product>>(
                    stream: _getProductsStream(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return CircularProgressIndicator();
                      }
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: ListTile(
                          title: _isEditing
                              ? DropdownButtonFormField<String>(
                                  decoration: InputDecoration(labelText: 'Product'),
                                  value: _selectedProductId,
                                  items: snapshot.data!
                                      .map((product) => DropdownMenuItem<String>(
                                            value: product.id,
                                            child: Text(product.name),
                                          ))
                                      .toList(),
                                  onChanged: (String? value) {
                                    setState(() {
                                      _selectedProductId = value;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Please select a product';
                                    }
                                    return null;
                                  },
                                )
                              : Text('Product: ${snapshot.data!.firstWhere((product) => product.id == widget.opportunity.productId).name}', style: TextStyle(fontSize: 16)),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 20.0),
                  FutureBuilder<DocumentSnapshot?>(
                    future: _getLead(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      if (!snapshot.hasData || snapshot.data == null || !snapshot.data!.exists) {
                        return Text('Lead: No lead for this opportunity', style: TextStyle(fontSize: 16));
                      }
                      Lead lead = Lead.fromMap(snapshot.data!);
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: ListTile(
                          title: Text('Lead: ${lead.name}', style: TextStyle(fontSize: 16, color: Colors.blue, decoration: TextDecoration.underline)),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.75,
                                    child: LeadDetailPage(lead: lead),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 20.0),
                  FutureBuilder<DocumentSnapshot?>(
                    future: _getAccount(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      if (!snapshot.hasData || snapshot.data == null || !snapshot.data!.exists) {
                        return Text('No associated account found.', style: TextStyle(fontSize: 16));
                      }
                      Account account = Account.fromMap(snapshot.data!);
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: ListTile(
                          title: Text('Account: ${account.name}', style: TextStyle(fontSize: 16, color: Colors.blue, decoration: TextDecoration.underline)),
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
                  ),
                  SizedBox(height: 20.0),
                  _isLoading ? CircularProgressIndicator() : Container(),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: _showQuoteForm,
                    child: Text('Proceed to Quote'),
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
