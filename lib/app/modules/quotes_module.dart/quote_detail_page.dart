import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:wside/app/models/products.dart';
import 'package:wside/app/models/quote.dart' as myQuote; // myQuote prefix'i ekleyin
import 'package:wside/app/models/order.dart' as myOrder; // myOrder prefix'i ekleyin
import 'package:wside/app/models/account.dart';
import 'package:wside/app/models/opportunity.dart'; // Opportunity modelini import edin

import 'package:wside/app/models/system_user.dart'; // SystemUser modelini import edin
import 'package:wside/app/modules/accouts_modules/accounts_detail_page.dart';
import 'package:wside/app/services/quote_service.dart';
import 'package:wside/app/services/order_service.dart'; // OrderService'i import edin
import 'package:wside/app/services/opportunity_service.dart'; // OpportunityService'i import edin

class QuoteDetailPage extends StatefulWidget {
  final myQuote.Quote quote;

  QuoteDetailPage({required this.quote, Key? key}) : super(key: key);

  @override
  _QuoteDetailPageState createState() => _QuoteDetailPageState();
}

class _QuoteDetailPageState extends State<QuoteDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final _quoteFormKey = GlobalKey<FormState>(); // Yeni GlobalKey oluştur
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController; // Fiyat alanı
  String? _selectedStatus;
  String? _selectedSubmittedBy; // Teklif veren kişi
  final QuoteService _quoteService = QuoteService();
  final OrderService _orderService = OrderService(); // OrderService'i ekleyin
  final OpportunityService _opportunityService = OpportunityService(); // OpportunityService'i ekleyin
  bool _isLoading = false;
  bool _isEditing = false;

  List<String> _statusOptions = ['Draft', 'Sent', 'Accepted', 'Rejected'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.quote.name);
    _descriptionController = TextEditingController(text: widget.quote.description);
    _priceController = TextEditingController(text: widget.quote.price.toString()); // Fiyat alanı
    _selectedStatus = widget.quote.status;
    _selectedSubmittedBy = widget.quote.submittedBy; // Initial submitted by user ID
  }

  Future<void> _saveQuote(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      myQuote.Quote updatedQuote = myQuote.Quote(
        id: widget.quote.id,
        name: _nameController.text,
        description: _descriptionController.text,
        status: _selectedStatus!,
        price: double.parse(_priceController.text), // Fiyat alanı
        opportunityId: widget.quote.opportunityId,
        accountId: widget.quote.accountId,
        submittedBy: _selectedSubmittedBy!, // Teklif veren kişi
        createdAt: widget.quote.createdAt,
      );

      try {
        await _quoteService.updateQuote(updatedQuote);
        Get.snackbar(
          'Success',
          'Quote updated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );

        if (_selectedStatus == 'Accepted') {
          _showOrderForm(context); // Order formunu göster
        }

        setState(() {
          _isEditing = false;
        });
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to update quote: $e',
          snackPosition: SnackPosition.BOTTOM,
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _proceedToOrder(BuildContext context) async {
    myOrder.Order newOrder = myOrder.Order(
      name: widget.quote.name,
      description: 'Generated from Quote: ${widget.quote.name}',
      status: 'Draft',
      price: double.parse(_priceController.text),
      quoteId: widget.quote.id!,
      accountId: widget.quote.accountId,
      submittedBy: widget.quote.submittedBy, // submittedBy alanı ekleniyor
      createdAt: Timestamp.now(),
    );

    try {
      await _orderService.addOrder(newOrder);
      Get.snackbar('Success', 'Order created successfully', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to create order: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _showOrderForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _quoteFormKey, // Yeni form anahtarını kullan
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Enter Order Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _proceedToOrder(context);
                      Navigator.of(context).pop();
                    },
                    child: Text('Create Order'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<DocumentSnapshot> _getAccount() async {
    return await FirebaseFirestore.instance.collection('accounts').doc(widget.quote.accountId).get();
  }

  Future<String?> _getUserName(String userId) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      return SystemUser.fromDoc(userDoc).name;
    }
    return null;
  }

  Future<Product?> _getProductFromOpportunity(String opportunityId) async {
    DocumentSnapshot opportunityDoc = await FirebaseFirestore.instance.collection('opportunities').doc(opportunityId).get();
    if (opportunityDoc.exists) {
      Opportunity opportunity = Opportunity.fromMap(opportunityDoc);
      if (opportunity.productId != null && opportunity.productId!.isNotEmpty) {
        DocumentSnapshot productDoc = await FirebaseFirestore.instance.collection('products').doc(opportunity.productId).get();
        if (productDoc.exists) {
          return Product.fromFirestore(productDoc);
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quote.name),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveQuote(context);
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
                          : Text('Name: ${widget.quote.name}', style: TextStyle(fontSize: 16)),
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
                          : Text('Description: ${widget.quote.description}', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      title: _isEditing
                          ? TextFormField(
                              controller: _priceController,
                              decoration: InputDecoration(labelText: 'Price'),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a price';
                                }
                                return null;
                              },
                            )
                          : Text('Price: ${widget.quote.price}', style: TextStyle(fontSize: 16)),
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
                          : Text('Status: ${widget.quote.status}', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  FutureBuilder<DocumentSnapshot>(
                    future: _getAccount(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return Text('No associated account found.', style: TextStyle(fontSize: 16));
                      }
                      Account account = Account.fromMap(snapshot.data!);
                      return GestureDetector(
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
                        child: Text(
                          'Account: ${account.name}',
                          style: TextStyle(fontSize: 16, color: Colors.blue, decoration: TextDecoration.underline),
                        ),
                      );
                    },
                  ),
                  _isEditing
                      ? StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance.collection('users').snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return CircularProgressIndicator();
                            var users = snapshot.data!.docs.map((doc) => SystemUser.fromDoc(doc)).toList();
                            return DropdownButtonFormField<String>(
                              decoration: InputDecoration(labelText: 'Submitted By'),
                              value: _selectedSubmittedBy,
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
                        )
                      : FutureBuilder<String?>(
                          future: _getUserName(widget.quote.submittedBy),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            }
                            if (!snapshot.hasData) {
                              return Text('Submitted By: No user', style: TextStyle(fontSize: 16));
                            }
                            return Text('Submitted By: ${snapshot.data}', style: TextStyle(fontSize: 16));
                          },
                        ),
                  SizedBox(height: 20.0),
                  FutureBuilder<Product?>(
                    future: _getProductFromOpportunity(widget.quote.opportunityId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      if (!snapshot.hasData) {
                        return Text('No associated product found.', style: TextStyle(fontSize: 16));
                      }
                      Product? product = snapshot.data;
                      return Text(
                        'Product: ${product?.name ?? 'N/A'}',
                        style: TextStyle(fontSize: 16, color: Colors.blue, decoration: TextDecoration.underline),
                      );
                    },
                  ),
                  SizedBox(height: 20.0),
                  _isLoading ? CircularProgressIndicator() : Container(),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () => _showOrderForm(context),
                    child: Text('Proceed to Order'),
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
