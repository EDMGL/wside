// ignore_for_file: unused_field, library_private_types_in_public_api, prefer_const_constructors, use_build_context_synchronously, no_leading_underscores_for_local_identifiers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // GetX paketini import edin
import 'package:wside/app/models/post_sales.dart';
import 'package:wside/app/models/order.dart' as myOrder;
import 'package:wside/app/models/system_user.dart'; // SystemUser modelini ekleyin
import 'package:wside/app/services/post_sales_service.dart';
import 'package:wside/app/services/user_service.dart'; // UserService'i import edin

class AddPostSalesPage extends StatefulWidget {
  AddPostSalesPage({Key? key}) : super(key: key);

  @override
  _AddPostSalesPageState createState() => _AddPostSalesPageState();
}

class _AddPostSalesPageState extends State<AddPostSalesPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final PostSalesService _postSalesService = PostSalesService();
  final UserService _userService = UserService(); // UserService'i başlatın
  String? _selectedType;
  String? _selectedStatus = 'New'; // Varsayılan durum
  String? _selectedPriority;
  String? _selectedOrderId;
  String? _selectedUserId; // Seçilen kullanıcı ID'si
  String? _selectedUserEmail; // Seçilen kullanıcı email'i

  List<String> _typeOptions = ['Complaint', 'Fault', 'Suggestion', 'Request'];
  List<String> _statusOptions = ['New', 'In Progress', 'Completed'];
  List<String> _priorityOptions = ['Low', 'Medium', 'High'];

  Future<List<myOrder.Order>> _getOrders() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('orders').get();
    return querySnapshot.docs.map((doc) => myOrder.Order.fromMap(doc)).toList();
  }

  Future<void> _savePostSales(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      if (_selectedOrderId == null) {
        Get.snackbar('Error', 'Order ID is required', snackPosition: SnackPosition.BOTTOM);
        return;
      }
      if (_selectedUserId == null) {
        Get.snackbar('Error', 'User ID is required', snackPosition: SnackPosition.BOTTOM);
        return;
      }

      PostSales newPostSales = PostSales(
        orderId: _selectedOrderId!,
        type: _selectedType!,
        description: _descriptionController.text,
        status: _selectedStatus!,
        priority: _selectedPriority!,
        assignedTo: _selectedUserId!, // Atanan kullanıcı ID'si
        assignedToEmail: _selectedUserEmail!,
        createdAt: Timestamp.now(),
      );

      try {
        await _postSalesService.addPostSales(newPostSales);
        Get.snackbar('Success', 'PostSales added successfully', snackPosition: SnackPosition.BOTTOM);
        Navigator.of(context).pop();
      } catch (e) {
        Get.snackbar('Error', 'Failed to add post sales: $e', snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Post Sales')),
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
                  FutureBuilder<List<myOrder.Order>>(
                    future: _getOrders(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Text('No orders available to select.');
                      }
                      return DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Order'),
                        items: snapshot.data!.map((myOrder.Order order) {
                          return DropdownMenuItem<String>(
                            value: order.id,
                            child: Text(order.name),
                          );
                        }).toList(),
                        value: _selectedOrderId,
                        onChanged: (String? value) {
                          setState(() {
                            _selectedOrderId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select an order';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  FutureBuilder<List<SystemUser>>(
                    future: _userService.getUsers(), // UserService kullanarak kullanıcıları alın
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Text('No users available to select.');
                      }
                      return DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Assign To User'),
                        items: snapshot.data!.map((SystemUser user) {
                          return DropdownMenuItem<String>(
                            value: user.userId,
                            child: Text('${user.name} (${user.email})'),
                          );
                        }).toList(),
                        value: _selectedUserId,
                        onChanged: (String? value) {
                          var selectedUser = snapshot.data!.firstWhere((user) => user.userId == value);
                          setState(() {
                            _selectedUserId = value;
                            _selectedUserEmail = selectedUser.email;
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
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Type'),
                    items: _typeOptions.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    value: _selectedType,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedType = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a type';
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
                    value: _selectedStatus,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    },
                  ),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Priority'),
                    items: _priorityOptions.map((String priority) {
                      return DropdownMenuItem<String>(
                        value: priority,
                        child: Text(priority),
                      );
                    }).toList(),
                    value: _selectedPriority,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedPriority = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a priority';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () => _savePostSales(context),
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
