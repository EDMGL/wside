// create_user_controller.dart
import 'package:get/get.dart';
import 'package:wside/app/controllers/global_controller.dart';
import 'package:wside/app/services/auth_service.dart';

class CreateUserController extends GetxController {
  final AuthService authService = Get.put(AuthService());
  final GlobalController globalController = Get.put(GlobalController());
  RxString email = ''.obs;
  RxString password = ''.obs;
  RxString name = ''.obs;
    final selectedType = 'Admin'.obs; // Başlangıçta bir rol seçimi yapın
  final List<String> types = ['Admin', 'Employee', 'Others'];


  void createUser() async {
    authService.createUser(email: email.toString(), password: password.toString(), name: name.toString(),roleType: selectedType.toString(),currentUser:globalController.firebaseUser.value!);
  }
}