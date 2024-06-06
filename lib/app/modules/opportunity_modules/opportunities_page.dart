import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:wside/app/models/opportunity.dart';
import 'package:wside/app/modules/opportunity_modules/add_opportunity_page.dart';
import 'package:wside/app/modules/opportunity_modules/opportunity_detail_page.dart';
import 'package:wside/app/services/opportunity_service.dart'; // OpportunityService'i import edin

class OpportunitiesPage extends StatelessWidget {
  const OpportunitiesPage({super.key});

  Stream<List<Opportunity>> _getOpportunitiesStream() {
    return FirebaseFirestore.instance
        .collection('opportunities')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Opportunity.fromMap(doc)).toList());
  }

  Future<void> _deleteOpportunity(BuildContext context, String opportunityId) async {
    final OpportunityService _opportunityService = OpportunityService();
    try {
      await _opportunityService.deleteOpportunity(opportunityId);
      Get.snackbar('Success', 'Opportunity deleted successfully', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete opportunity: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Opportunities')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5, // Modalın genişliği
                  child: AddOpportunityPage(), // AddOpportunityPage içeriğini dialog içinde göster
                ),
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
      body: StreamBuilder<List<Opportunity>>(
        stream: _getOpportunitiesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No opportunities available.'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Opportunity opportunity = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(
                    opportunity.name,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(opportunity.description, style: TextStyle(fontSize: 16)),
                      Text('Status: ${opportunity.status}', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      Text('Estimated Revenue: ${opportunity.estimatedRevenue}', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteOpportunity(context, opportunity.id!),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.75,
                            child: OpportunityDetailPage(opportunity: opportunity),
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
      ),
    );
  }
}
