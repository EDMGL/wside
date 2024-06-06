import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wside/app/models/activity.dart';
import 'package:wside/app/modules/activities_modules/add_activity_page.dart';
import 'package:wside/app/services/activitiy_service.dart';


class ActivitiesPage extends StatelessWidget {
  final ActivityService _activityService = ActivityService();

  Stream<List<Activity>> _getActivitiesStream() {
    return _activityService.getActivities();
  }

  Future<void> _deleteActivity(BuildContext context, String activityId) async {
    try {
      await _activityService.deleteActivity(activityId);
      Get.snackbar('Success', 'Activity deleted successfully', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete activity: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Activities')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AddActivityPage(); // AddActivityPage modal olarak açılacak
            },
          );
        },
        child: Icon(Icons.add),
      ),
      body: StreamBuilder<List<Activity>>(
        stream: _getActivitiesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No activities available.'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Activity activity = snapshot.data![index];
              return Card(
                child: ListTile(
                  title: Text(activity.description),
                  subtitle: Text('Type: ${activity.type}\nUser ID: ${activity.userId}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteActivity(context, activity.id!),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
