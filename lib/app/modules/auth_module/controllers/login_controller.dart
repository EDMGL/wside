import 'package:get/get.dart';
import 'package:wside/app/services/auth_service.dart';

class LoginController extends GetxController {
  final AuthService authService = Get.put(AuthService());
  RxString email = ''.obs;
  RxString password = ''.obs;

  void signIn() async {
    if (email.isNotEmpty && password.isNotEmpty) {
      await authService.signIn(email.value, password.value);
    } else {
      Get.snackbar('Hata', 'E-posta ve şifre boş bırakılamaz');
    }
  }
}