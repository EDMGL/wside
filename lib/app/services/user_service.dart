import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wside/app/models/system_user.dart';

class UserService {
  final CollectionReference _usersCollection = FirebaseFirestore.instance.collection('users');

  Future<List<SystemUser>> getUsers() async {
    QuerySnapshot querySnapshot = await _usersCollection.get();
    return querySnapshot.docs.map((doc) => SystemUser.fromDoc(doc)).toList();
  }
}
