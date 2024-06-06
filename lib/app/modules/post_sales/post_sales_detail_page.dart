import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wside/app/models/post_sales.dart';
import 'package:wside/app/models/system_user.dart';
import 'package:wside/app/services/post_sales_service.dart';
import 'package:wside/app/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostSalesDetailPage extends StatefulWidget {
  final PostSales postSales;

  PostSalesDetailPage({required this.postSales, Key? key}) : super(key: key);

  @override
  _PostSalesDetailPageState createState() => _PostSalesDetailPageState();
}

class _PostSalesDetailPageState extends State<PostSalesDetailPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  String? _selectedType;
  String? _selectedStatus;
  String? _selectedPriority;
  String? _assignedTo;
  String? _assignedToEmail;
  final PostSalesService _postSalesService = PostSalesService();
  final UserService _userService = UserService();
  bool _isEditing = false;
  bool _isLoading = false;

  List<String> _typeOptions = ['Complaint', 'Fault', 'Suggestion', 'Request'];
  List<String> _statusOptions = ['New', 'In Progress', 'Completed'];
  List<String> _priorityOptions = ['Low', 'Medium', 'High'];

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.postSales.description);
    _selectedType = widget.postSales.type;
    _selectedStatus = widget.postSales.status;
    _selectedPriority = widget.postSales.priority;
    _assignedTo = widget.postSales.assignedTo;
    _assignedToEmail = widget.postSales.assignedToEmail;
  }

  Future<void> _savePostSales(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      PostSales updatedPostSales = PostSales(
        id: widget.postSales.id,
        orderId: widget.postSales.orderId,
        type: _selectedType!,
        description: _descriptionController.text,
        status: _selectedStatus!,
        priority: _selectedPriority!,
        assignedTo: _assignedTo!,
        assignedToEmail: _assignedToEmail!,
        createdAt: widget.postSales.createdAt,
      );

      try {
        await _postSalesService.updatePostSales(updatedPostSales);
        Get.snackbar(
          'Success',
          'PostSales updated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        setState(() {
          _isEditing = false;
        });
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to update post sales: $e',
          snackPosition: SnackPosition.BOTTOM,
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<List<Map<String, String>>> _getUsers() async {
    List<SystemUser> users = await _userService.getUsers();
    return users.map((user) {
      return {
        'id': user.userId ?? '',
        'name': user.name ?? '',
        'email': user.email ?? '',
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Sales Detail'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _savePostSales(context);
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
                          ? DropdownButtonFormField<String>(
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
                            )
                          : Text('Type: ${widget.postSales.type}', style: TextStyle(fontSize: 16)),
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
                          : Text('Description: ${widget.postSales.description}', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      title: _isEditing
                          ? DropdownButtonFormField<String>(
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
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a status';
                                }
                                return null;
                              },
                            )
                          : Text('Status: ${widget.postSales.status}', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      title: _isEditing
                          ? DropdownButtonFormField<String>(
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
                            )
                          : Text('Priority: ${widget.postSales.priority}', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      title: _isEditing
                          ? FutureBuilder<List<Map<String, String>>>(
                              future: _getUsers(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return CircularProgressIndicator();
                                }
                                return DropdownButtonFormField<String>(
                                  decoration: InputDecoration(labelText: 'Assigned To'),
                                  value: _assignedTo,
                                  items: snapshot.data!.map((user) {
                                    return DropdownMenuItem<String>(
                                      value: user['id'],
                                      child: Text('${user['name']} (${user['email']})'),
                                    );
                                  }).toList(),
                                  onChanged: (String? value) {
                                    var selectedUser = snapshot.data!.firstWhere((user) => user['id'] == value);
                                    setState(() {
                                      _assignedTo = value;
                                      _assignedToEmail = selectedUser['email'];
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
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Assigned To: ${widget.postSales.assignedTo}', style: TextStyle(fontSize: 16)),
                                Text('Email: ${widget.postSales.assignedToEmail}', style: TextStyle(fontSize: 16)),
                              ],
                            ),
                    ),
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
}
