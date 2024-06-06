import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wside/app/models/opportunity.dart';


class OpportunityService {
  final CollectionReference _opportunityCollection = FirebaseFirestore.instance.collection('opportunities');

  Future<void> addOpportunity(Opportunity opportunity) async {
    try {
       DocumentReference docRef = await _opportunityCollection.add(opportunity.toMap());
    String opportunityId = docRef.id;
    await docRef.update({'id': opportunityId});
    } catch (e) {
      
    }
   
  }

  Future<void> updateOpportunity(Opportunity opportunity) async {
    
    try {
          await _opportunityCollection.doc(opportunity.id).update(opportunity.toMap());

    } catch (e) {
      
    }
  }

  Future<void> deleteOpportunity(String opportunityId) async {
    try {
          await _opportunityCollection.doc(opportunityId).delete();

    } catch (e) {
      
    }
  }
}
