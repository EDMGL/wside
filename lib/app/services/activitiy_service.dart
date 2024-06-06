import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wside/app/models/activity.dart';

class ActivityService {
  final CollectionReference _activitiesCollection =
      FirebaseFirestore.instance.collection('activities');

  // Yeni bir aktivite eklemek için metod
  Future<void> addActivity(Activity activity) async {
    try {
      await _activitiesCollection.add(activity.toMap());
    } catch (e) {
      throw Exception('Failed to add activity: $e');
    }
  }

  // Bir aktiviteyi güncellemek için metod
  Future<void> updateActivity(Activity activity) async {
    try {
      await _activitiesCollection.doc(activity.id).update(activity.toMap());
    } catch (e) {
      throw Exception('Failed to update activity: $e');
    }
  }

  // Bir aktiviteyi silmek için metod
  Future<void> deleteActivity(String activityId) async {
    try {
      await _activitiesCollection.doc(activityId).delete();
    } catch (e) {
      throw Exception('Failed to delete activity: $e');
    }
  }

  // Tüm aktiviteleri almak için metod
  Stream<List<Activity>> getActivities() {
    return _activitiesCollection.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Activity.fromMap(doc))
        .toList());
  }

  // Belirli bir duyum veya fırsata ait aktiviteleri almak için metod
  Stream<List<Activity>> getActivitiesByLeadOrOpportunity(
      {String? leadId, String? opportunityId}) {
    Query query = _activitiesCollection;

    if (leadId != null && leadId.isNotEmpty) {
      query = query.where('leadId', isEqualTo: leadId);
    }

    if (opportunityId != null && opportunityId.isNotEmpty) {
      query = query.where('opportunityId', isEqualTo: opportunityId);
    }

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Activity.fromMap(doc))
        .toList());
  }
}
