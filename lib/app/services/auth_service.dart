import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:get/get.dart';

class AuthService extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUser({
    required String email,
    required String password,
    required String name,
    String? roleType,
    required User currentUser,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      //firestore'a eklenecek kısmı yapalım
      _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'roleType': roleType ??
            'user', // Eğer roleType belirtilmemişse varsayılan olarak 'user' atayın
        'signedDate': Timestamp.now(),
        'profilePicture': null,
        'gender': null,
        'birthDate': null,
        'createdBy': currentUser.uid,
        'password': password,
        'userId': userCredential.user!.uid,
      });
      Get.snackbar("Başarılı", "Kullanıcı oluşturuldu.");
  
    } catch (e) {
      Get.snackbar("Hata", "Kullanıcı oluşturulamadı: $e");
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      Get.snackbar("Hata", "Giriş yapılamadı: $e");
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
