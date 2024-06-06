import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GlobalController extends GetxController {
  var firebaseUser = Rx<User?>(null);

  // GlobalController'ın başlatılması
  @override
  void onInit() {
    super.onInit();
    // FirebaseAuth'ın authStateChanges stream'ini dinleyerek kullanıcı durumunu güncelle
    firebaseUser.bindStream(FirebaseAuth.instance.authStateChanges());
  }
}
