import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:wside/app/models/campaign.dart';
import 'package:wside/app/models/order.dart' as myOrder; // myOrder prefix
import 'package:wside/app/models/account.dart';
import 'package:wside/app/models/system_user.dart';
import 'package:wside/app/modules/accouts_modules/accounts_detail_page.dart';
import 'package:wside/app/services/campaign_service.dart';
import 'package:wside/app/services/order_service.dart'; // OrderService'i import edin

class CampaignDetailPage extends StatefulWidget {
  final Campaign campaign;

  CampaignDetailPage({required this.campaign, Key? key}) : super(key: key);

  @override
  _CampaignDetailPageState createState() => _CampaignDetailPageState();
}

class _CampaignDetailPageState extends State<CampaignDetailPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  String? _selectedType;
  final CampaignService _campaignService = CampaignService();
  final OrderService _orderService = OrderService(); // OrderService'i ekleyin
  bool _isLoading = false;
  bool _isEditing = false;

  List<String> _typeOptions = ['Account', 'Product'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.campaign.name);
    _descriptionController = TextEditingController(text: widget.campaign.description);
    _selectedType = widget.campaign.type;
  }

  Future<void> _saveCampaign(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      Campaign updatedCampaign = Campaign(
        id: widget.campaign.id,
        name: _nameController.text,
        description: _descriptionController.text,
        type: _selectedType!,
        referenceId: widget.campaign.referenceId,
        createdAt: widget.campaign.createdAt,
      );

      try {
        await _campaignService.updateCampaign(updatedCampaign);
        Get.snackbar('Success', 'Campaign updated successfully');
        setState(() {
          _isEditing = false;
        });
      } catch (e) {
        Get.snackbar('Failed', 'Failed to update campaign');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Stream<List<myOrder.Order>> _getOrdersStream() {
    if (_selectedType == 'Account') {
      return FirebaseFirestore.instance
          .collection('orders')
          .where('accountId', isEqualTo: widget.campaign.referenceId)
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => myOrder.Order.fromMap(doc)).toList());
    } else {
      return FirebaseFirestore.instance
          .collection('orders')
          .where('productId', isEqualTo: widget.campaign.referenceId)
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => myOrder.Order.fromMap(doc)).toList());
    }
  }

  Future<DocumentSnapshot> _getTargetDocument() async {
    if (_selectedType == 'Account') {
      return await FirebaseFirestore.instance.collection('accounts').doc(widget.campaign.referenceId).get();
    } else {
      return await FirebaseFirestore.instance.collection('products').doc(widget.campaign.referenceId).get();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Campaign Detail'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveCampaign(context);
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
                          : Text('Name: ${widget.campaign.name}', style: TextStyle(fontSize: 16)),
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
                          : Text('Description: ${widget.campaign.description}', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      title: _isEditing
                          ? DropdownButtonFormField<String>(
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
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a type';
                                }
                                return null;
                              },
                            )
                          : Text('Type: ${widget.campaign.type}', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  FutureBuilder<DocumentSnapshot>(
                    future: _getTargetDocument(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return Text('No target found.', style: TextStyle(fontSize: 16));
                      }
                      var target = snapshot.data!.data() as Map<String, dynamic>;
                      return Text(
                        _selectedType == 'Account' ? 'Account: ${target['name']}' : 'Product: ${target['name']}',
                        style: TextStyle(fontSize: 16, color: Colors.blue, decoration: TextDecoration.underline),
                      );
                    },
                  ),
                  SizedBox(height: 20.0),
                  _isLoading ? CircularProgressIndicator() : Container(),
                  SizedBox(height: 20.0),
                  Text('Orders:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10.0),
                  StreamBuilder<List<myOrder.Order>>(
                    stream: _getOrdersStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Text('No orders found.', style: TextStyle(fontSize: 16));
                      }
                      return Column(
                        children: snapshot.data!.map((order) {
                          return ListTile(
                            title: Text(order.name, style: TextStyle(fontSize: 16)),
                            subtitle: Text('Price: ${order.price}', style: TextStyle(fontSize: 14)),
                          );
                        }).toList(),
                      );
                    },
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
