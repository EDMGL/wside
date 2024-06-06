import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wside/app/controllers/global_controller.dart';
import 'package:wside/app/modules/auth_module/views/login_page.dart';
import 'package:wside/app/modules/home_page_modules/views/admin_home_page.dart';

class Wrapper extends StatelessWidget {
  final GlobalController globalController = Get.put(GlobalController());

  Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => globalController.firebaseUser.value != null
        ? const AdminHomePage()
        : LoginPage());
  }
}
