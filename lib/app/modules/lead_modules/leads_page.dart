import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:wside/app/models/lead.dart';
import 'package:wside/app/models/account.dart';
import 'package:wside/app/modules/lead_modules/add_lead_page.dart';
import 'package:wside/app/modules/lead_modules/lead_detail_page.dart';
import 'package:wside/app/services/lead_service.dart'; // LeadService'i import edin

class LeadsPage extends StatelessWidget {
  const LeadsPage({super.key});

  Stream<List<Lead>> _getLeadsStream() {
    return FirebaseFirestore.instance
        .collection('leads')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Lead.fromMap(doc)).toList());
  }

  Future<void> _deleteLead(BuildContext context, String leadId) async {
    final LeadService _leadService = LeadService();
    try {
      await _leadService.deleteLead(leadId);
      Get.snackbar('Success', 'Lead deleted successfully');
      
    } catch (e) {
      Get.snackbar('Failed', 'Failed to delete lead');
      
    }
  }

  Future<Account?> _getAccount(String accountId) async {
    final DocumentSnapshot doc = await FirebaseFirestore.instance.collection('accounts').doc(accountId).get();
    if (doc.exists) {
      return Account.fromMap(doc);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Leads')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5, // Modalın genişliği
                  child: AddLeadPage(), // AddLeadPage içeriğini dialog içinde göster
                ),
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
      body: StreamBuilder<List<Lead>>(
        stream: _getLeadsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No leads available.'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Lead lead = snapshot.data![index];
              return FutureBuilder<Account?>(
                future: _getAccount(lead.accountId),
                builder: (context, accountSnapshot) {
                  if (accountSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  String title = lead.name;
                  if (accountSnapshot.hasData) {
                    title = '${accountSnapshot.data!.name}: ${lead.name}';
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
                          Text('Email: ${lead.email}', style: TextStyle(color: Colors.grey[700])),
                          SizedBox(height: 5),
                          Text('Phone: ${lead.phone}', style: TextStyle(color: Colors.grey[600])),
                          SizedBox(height: 5),
                          Text('Status: ${lead.status}', style: TextStyle(color: Colors.grey[600])),
                      
                          
                          SizedBox(height: 5),
                          Text('Description: ${lead.description}', style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteLead(context, lead.id!),
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.75,
                                child: LeadDetailPage(lead: lead),
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
