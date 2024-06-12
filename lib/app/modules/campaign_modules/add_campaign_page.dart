import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:wside/app/models/campaign.dart';
import 'package:wside/app/services/campaign_service.dart';

class AddCampaignPage extends StatefulWidget {
  AddCampaignPage({Key? key}) : super(key: key);

  @override
  _AddCampaignPageState createState() => _AddCampaignPageState();
}

class _AddCampaignPageState extends State<AddCampaignPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedType;
  String? _selectedReferenceId;
  final CampaignService _campaignService = CampaignService();

  List<String> _typeOptions = ['account', 'product'];

  Stream<List<dynamic>> _getReferenceStream() {
    if (_selectedType == 'account') {
      return FirebaseFirestore.instance
          .collection('accounts')
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => {'id': doc.id, 'name': doc['name']}).toList());
    } else {
      return FirebaseFirestore.instance
          .collection('products')
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => {'id': doc.id, 'name': doc['name']}).toList());
    }
  }

  Future<void> _saveCampaign(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      Campaign newCampaign = Campaign(
        id: '',
        name: _nameController.text,
        description: _descriptionController.text,
        type: _selectedType!,
        referenceId: _selectedReferenceId!,
        createdAt: Timestamp.now(),
      );

      try {
        await _campaignService.addCampaign(newCampaign);
        Get.snackbar('Success', 'Campaign added successfully');
        Navigator.of(context).pop();
      } catch (e) {
        Get.snackbar('Failed', 'Failed to add campaign');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Campaign')),
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
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Campaign Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a campaign name';
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
                    decoration: InputDecoration(labelText: 'Type'),
                    value: _selectedType,
                    items: _typeOptions.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        _selectedType = value;
                        _selectedReferenceId = null; // Clear the selected reference ID when type changes
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a type';
                      }
                      return null;
                    },
                  ),
                  StreamBuilder<List<dynamic>>(
                    stream: _getReferenceStream(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return CircularProgressIndicator();
                      }
                      return DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: _selectedType == 'account' ? 'Account' : 'Product'),
                        value: _selectedReferenceId,
                        items: snapshot.data!.map((reference) {
                          return DropdownMenuItem<String>(
                            value: reference['id'],
                            child: Text(reference['name']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedReferenceId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a ${_selectedType == 'account' ? 'account' : 'product'}';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () => _saveCampaign(context),
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
