import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wside/app/models/campaign.dart';

class CampaignService {
  final CollectionReference _campaignCollection = FirebaseFirestore.instance.collection('campaigns');

  Future<void> addCampaign(Campaign campaign) {
    return _campaignCollection.add(campaign.toMap());
  }

  Future<void> updateCampaign(Campaign campaign) {
    return _campaignCollection.doc(campaign.id).update(campaign.toMap());
  }

  Future<void> deleteCampaign(String id) {
    return _campaignCollection.doc(id).delete();
  }

  Stream<List<Campaign>> getCampaigns() {
    return _campaignCollection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Campaign.fromFirestore(doc)).toList());
  }
}
