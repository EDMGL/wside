// ignore_for_file: prefer_final_fields, prefer_const_constructors_in_immutables, library_private_types_in_public_api, library_prefixes, prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:wside/app/models/order.dart' as myOrder; // myOrder prefix'i ekleyin
import 'package:wside/app/models/account.dart';
import 'package:wside/app/models/system_user.dart';
import 'package:wside/app/modules/accouts_modules/accounts_detail_page.dart';
import 'package:wside/app/services/order_service.dart'; // OrderService'i import edin

class OrderDetailPage extends StatefulWidget {
  final myOrder.Order order;

  OrderDetailPage({required this.order, Key? key}) : super(key: key);

  @override
  _OrderDetailPageState createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController; // Fiyat alanı
  String? _selectedStatus;
  String? _selectedSubmittedBy;
  final OrderService _orderService = OrderService();
  bool _isLoading = false;
  bool _isEditing = false;

  List<String> _statusOptions = ['Draft', 'Confirmed', 'Shipped', 'Delivered'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.order.name);
    _descriptionController = TextEditingController(text: widget.order.description);
    _priceController = TextEditingController(text: widget.order.price.toString()); // Fiyat alanı
    _selectedStatus = widget.order.status;
    _selectedSubmittedBy = widget.order.submittedBy;
  }

  Future<void> _saveOrder(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      myOrder.Order updatedOrder = myOrder.Order(
        submittedBy: _selectedSubmittedBy!,
        id: widget.order.id,
        name: _nameController.text,
        description: _descriptionController.text,
        status: _selectedStatus!,
        price: double.parse(_priceController.text), // Fiyat alanı
        quoteId: widget.order.quoteId,
        accountId: widget.order.accountId,
        createdAt: widget.order.createdAt,
      );

      try {
        await _orderService.updateOrder(updatedOrder);
        Get.snackbar('Success', 'Order updated successfully');

        setState(() {
          _isEditing = false;
        });
      } catch (e) {
        Get.snackbar('Failed', 'Failed to update order');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<DocumentSnapshot> _getAccount() async {
    return await FirebaseFirestore.instance.collection('accounts').doc(widget.order.accountId).get();
  }

  Stream<List<SystemUser>> _getUsersStream() {
    return FirebaseFirestore.instance.collection('users').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => SystemUser.fromDoc(doc)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Detail'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveOrder(context);
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
                          : Text('Name: ${widget.order.name}', style: TextStyle(fontSize: 16)),
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
                          : Text('Description: ${widget.order.description}', style: TextStyle(fontSize: 16)),
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
                          : Text('Price: ${widget.order.price}', style: TextStyle(fontSize: 16)),
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
                          : Text('Status: ${widget.order.status}', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      title: _isEditing
                          ? StreamBuilder<List<SystemUser>>(
                              stream: _getUsersStream(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return CircularProgressIndicator();
                                }
                                return DropdownButtonFormField<String>(
                                  decoration: InputDecoration(labelText: 'Submitted By'),
                                  value: _selectedSubmittedBy,
                                  items: snapshot.data!.map((user) {
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
                              future: _getUserName(widget.order.submittedBy),
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

  Future<String?> _getUserName(String userId) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      return SystemUser.fromDoc(userDoc).name;
    }
    return null;
  }
}
