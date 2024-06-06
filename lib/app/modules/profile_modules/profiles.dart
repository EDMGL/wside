import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:wside/app/models/system_user.dart';
import 'package:wside/app/services/user_service.dart';

class GlobalController extends GetxController {
  var firebaseUser = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(FirebaseAuth.instance.authStateChanges());
  }
}

class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final GlobalController _globalController = Get.put(GlobalController());
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _genderController;
  late TextEditingController _passwordController;
  bool _isLoading = false;
  bool _isEditing = false;
  SystemUser? _user;

  @override
  void initState() {
    super.initState();
    _globalController.firebaseUser.listen((user) {
      if (user != null) {
        _loadUserData(user.uid);
      }
    });
  }

  Future<void> _loadUserData(String userId) async {
    setState(() {
      _isLoading = true;
    });
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      _user = SystemUser.fromDoc(userDoc);
      _nameController = TextEditingController(text: _user!.name);
      _emailController = TextEditingController(text: _user!.email);
      _genderController = TextEditingController(text: _user!.gender);
      _passwordController = TextEditingController(text: _user!.password);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to load user data: $e', snackPosition: SnackPosition.BOTTOM);
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveUserProfile(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      SystemUser updatedUser = SystemUser(
        userId: _user!.userId,
        name: _nameController.text,
        email: _emailController.text,
        gender: _genderController.text,
        password: _passwordController.text,
        profilePicture: _user!.profilePicture,
        birthDate: _user!.birthDate,
        signedDate: _user!.signedDate,
        createdBy: _user!.createdBy,
        roleType: _user!.roleType,
      );

      try {
        await FirebaseFirestore.instance.collection('users').doc(_user!.userId).update(updatedUser.toMap());
        Get.snackbar('Success', 'Profile updated successfully', snackPosition: SnackPosition.BOTTOM);
        setState(() {
          _isEditing = false;
        });
      } catch (e) {
        Get.snackbar('Error', 'Failed to update profile: $e', snackPosition: SnackPosition.BOTTOM);
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
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveUserProfile(context);
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                            : Text('Name: ${_user?.name ?? ''}', style: TextStyle(fontSize: 16)),
                        _isEditing
                            ? TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(labelText: 'Email'),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter an email';
                                  }
                                  return null;
                                },
                              )
                            : Text('Email: ${_user?.email ?? ''}', style: TextStyle(fontSize: 16)),
                        _isEditing
                            ? TextFormField(
                                controller: _genderController,
                                decoration: InputDecoration(labelText: 'Gender'),
                              )
                            : Text('Gender: ${_user?.gender ?? ''}', style: TextStyle(fontSize: 16)),
                        _isEditing
                            ? TextFormField(
                                controller: _passwordController,
                                decoration: InputDecoration(labelText: 'Password'),
                                obscureText: true,
                              )
                            : Text('Password: ${_user?.password ?? ''}', style: TextStyle(fontSize: 16)),
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

extension on SystemUser {
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'profilePicture': profilePicture,
      'email': email,
      'gender': gender,
      'password': password,
      'birthDate': birthDate,
      'signedDate': signedDate,
      'createdBy': createdBy,
      'roleType': roleType,
    };
  }
}
