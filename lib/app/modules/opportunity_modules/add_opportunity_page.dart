import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:wside/app/models/opportunity.dart';
import 'package:wside/app/models/account.dart';
import 'package:wside/app/models/lead.dart';
import 'package:wside/app/models/products.dart';

import 'package:wside/app/services/opportunity_service.dart';

class AddOpportunityPage extends StatefulWidget {
  final Lead? lead;

  AddOpportunityPage({Key? key, this.lead}) : super(key: key);

  @override
  _AddOpportunityPageState createState() => _AddOpportunityPageState();
}

class _AddOpportunityPageState extends State<AddOpportunityPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _estimatedRevenueController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  String? _selectedStatus;
  String? _selectedAccountId;
  String? _selectedProductId;
  final OpportunityService _opportunityService = OpportunityService();

  List<String> _statusOptions = ['New', 'In Progress', 'Won', 'Lost'];

  @override
  void initState() {
    super.initState();
    if (widget.lead != null) {
      _nameController.text = widget.lead!.name;
      _selectedAccountId = widget.lead!.accountId;
    }
  }

  Stream<List<Account>> _getAccountsStream() {
    return FirebaseFirestore.instance
        .collection('accounts')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Account.fromMap(doc)).toList());
  }

  Stream<List<Product>> _getProductsStream() {
    return FirebaseFirestore.instance
        .collection('products')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  Future<void> _saveOpportunity(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      Opportunity newOpportunity = Opportunity(
        accountId: _selectedAccountId!,
        name: _nameController.text,
        description: _descriptionController.text,
        status: _selectedStatus!,
        leadId: widget.lead?.id ?? '',
        productId: _selectedProductId!,
        estimatedRevenue: double.parse(_estimatedRevenueController.text),
        endDate: Timestamp.fromDate(DateTime.parse(_endDateController.text)),
        createdAt: Timestamp.now(),
      );

      try {
        await _opportunityService.addOpportunity(newOpportunity);
        Get.snackbar('Success','Opportunity added successfully');
        Navigator.of(context).pop();
      } catch (e) {
        Get.snackbar('Error','Failed to add opportunity');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Opportunity')),
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
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: 'Description'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
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
                  if (widget.lead == null) // Lead yoksa Account seçimini göster
                    StreamBuilder<List<Account>>(
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
                    ),
                  StreamBuilder<List<Product>>(
                    stream: _getProductsStream(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return CircularProgressIndicator();
                      }
                      return DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Product'),
                        value: _selectedProductId,
                        items: snapshot.data!
                            .map((product) => DropdownMenuItem<String>(
                                  value: product.id,
                                  child: Text(product.name),
                                ))
                            .toList(),
                        onChanged: (value) {
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
                      );
                    },
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () => _saveOpportunity(context),
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
