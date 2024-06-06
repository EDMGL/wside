import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wside/app/models/activity.dart';
import 'package:wside/app/models/account.dart';
import 'package:wside/app/models/contact.dart';
import 'package:wside/app/models/system_user.dart'; // SystemUser modelini import edin
import 'package:wside/app/services/account_service.dart';
import 'package:wside/app/services/activitiy_service.dart';
import 'package:wside/app/services/contact_service.dart';
import 'package:wside/app/services/user_service.dart';

class AddActivityPage extends StatefulWidget {
  @override
  _AddActivityPageState createState() => _AddActivityPageState();
}

class _AddActivityPageState extends State<AddActivityPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final ActivityService _activityService = ActivityService();
  final AccountService _accountService = AccountService();
  final ContactService _contactService = ContactService();
  final UserService _userService = UserService(); // UserService'i ekleyin
  bool _isLoading = false;
  String? _selectedType;
  String? _selectedAccountId;
  String? _selectedContactId;
  String? _selectedUserId; // Seçilen kullanıcı ID'si

  List<String> _typeOptions = ['Call', 'Email', 'Meeting'];

  Future<void> _addActivity() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      Activity newActivity = Activity(
        type: _selectedType!,
        description: _descriptionController.text,
        accountId: _selectedAccountId!,
        contactId: _selectedContactId!,
        userId: _selectedUserId!, // Seçilen kullanıcı ID'si
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );

      try {
        await _activityService.addActivity(newActivity);
        Get.snackbar('Success', 'Activity added successfully', snackPosition: SnackPosition.BOTTOM);
        Navigator.of(context).pop();
      } catch (e) {
        Get.snackbar('Error', 'Failed to add activity: $e', snackPosition: SnackPosition.BOTTOM);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FutureBuilder<List<Account>>(
                future: _accountService.getAccounts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text('No accounts available to select.');
                  }
                  return DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Account'),
                    items: snapshot.data!.map((account) {
                      return DropdownMenuItem<String>(
                        value: account.id,
                        child: Text(account.name),
                      );
                    }).toList(),
                    value: _selectedAccountId,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedAccountId = value;
                        _selectedContactId = null; // Reset selected contact
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
              if (_selectedAccountId != null)
                FutureBuilder<List<Contact>>(
                  future: _contactService.getContacts(_selectedAccountId!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Text('No contacts available for selected account.');
                    }
                    return DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Contact'),
                      items: snapshot.data!.map((contact) {
                        return DropdownMenuItem<String>(
                          value: contact.id,
                          child: Text(contact.name),
                        );
                      }).toList(),
                      value: _selectedContactId,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedContactId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a contact';
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
              FutureBuilder<List<SystemUser>>(
                future: _userService.getUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text('No users available to select.');
                  }
                  return DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'User'),
                    items: snapshot.data!.map((user) {
                      return DropdownMenuItem<String>(
                        value: user.userId,
                        child: Text(user.name ?? ''),
                      );
                    }).toList(),
                    value: _selectedUserId,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedUserId = value;
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
              SizedBox(height: 20.0),
              _isLoading ? CircularProgressIndicator() : Container(),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _addActivity,
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
