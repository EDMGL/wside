import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:wside/app/models/campaign.dart';
import 'package:wside/app/models/account.dart';
import 'package:wside/app/models/products.dart';
import 'package:wside/app/modules/campaign_modules/add_campaign_page.dart';
import 'package:wside/app/modules/campaign_modules/campaign_detail_page.dart';
import 'package:wside/app/services/campaign_service.dart';

class CampaignsPage extends StatelessWidget {
  const CampaignsPage({super.key});

  Stream<List<Campaign>> _getCampaignsStream() {
    return FirebaseFirestore.instance
        .collection('campaigns')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Campaign.fromFirestore(doc)).toList());
  }

  Future<void> _deleteCampaign(BuildContext context, String campaignId) async {
    final CampaignService _campaignService = CampaignService();
    try {
      await _campaignService.deleteCampaign(campaignId);
      Get.snackbar('Success', 'Campaign deleted successfully');
    } catch (e) {
      Get.snackbar('Failed', 'Failed to delete campaign');
    }
  }

  Future<dynamic> _getReference(String referenceId, String type) async {
    final DocumentSnapshot doc;
    if (type == 'account') {
      doc = await FirebaseFirestore.instance.collection('accounts').doc(referenceId).get();
      if (doc.exists) {
        return Account.fromMap(doc);
      }
    } else {
      doc = await FirebaseFirestore.instance.collection('products').doc(referenceId).get();
      if (doc.exists) {
        return Product.fromFirestore(doc);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Campaigns')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: AddCampaignPage(),
                ),
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
      body: StreamBuilder<List<Campaign>>(
        stream: _getCampaignsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No campaigns available.'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Campaign campaign = snapshot.data![index];
              return FutureBuilder<dynamic>(
                future: _getReference(campaign.referenceId, campaign.type),
                builder: (context, referenceSnapshot) {
                  if (referenceSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  String title = campaign.name;
                  if (referenceSnapshot.hasData) {
                    title = campaign.type == 'account'
                        ? '${(referenceSnapshot.data as Account).name}: ${campaign.name}'
                        : '${(referenceSnapshot.data as Product).name}: ${campaign.name}';
                  }
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 5),
                          Text('Description: ${campaign.description}', style: TextStyle(color: Colors.grey[600])),
                          SizedBox(height: 5),
                          Text('Type: ${campaign.type}', style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteCampaign(context, campaign.id),
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.75,
                                child: CampaignDetailPage(campaign: campaign),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
