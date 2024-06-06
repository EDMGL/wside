import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wside/app/models/lead.dart';

class LeadService {
  final CollectionReference _leadCollection = FirebaseFirestore.instance.collection('leads');

  Future<void> addLead(Lead lead) async {
    try {
         DocumentReference docRef = await _leadCollection.add(lead.toMap());
    String leadId = docRef.id;
    await docRef.update({'id': leadId});
    } catch (e) {
      print(e);
    }
 
  }

  Future<void> updateLead(Lead lead) async {
    try {
      
    await _leadCollection.doc(lead.id).update(lead.toMap());
    } catch (e) {
      print(e);
    }
  }
  
  Future<void> deleteLead(String leadId) async {
    try {
      await _leadCollection.doc(leadId).delete();
    } catch (e) {
      print(e);
    }
    
  }
}
