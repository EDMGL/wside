// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wside/app/modules/auth_module/controllers/login_controller.dart';

class LoginPage extends StatelessWidget {
  final LoginController controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              double width = constraints.maxWidth > 600
                  ? constraints.maxWidth / 3
                  : constraints.maxWidth * 0.8;
              return SizedBox(
                width: width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/wside_logo.png'),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: TextField(
                          onChanged: (value) => controller.email.value = value,
                          decoration: const InputDecoration(
                            labelText: 'E-posta',
                            border: InputBorder.none,
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: TextField(
                          onChanged: (value) => controller.password.value = value,
                          decoration: const InputDecoration(
                            labelText: 'Şifre',
                            border: InputBorder.none,
                          ),
                          obscureText: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        controller.signIn();
                      },
                      child: const Text('Giriş Yap'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
