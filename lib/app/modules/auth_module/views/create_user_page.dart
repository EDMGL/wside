// create_user_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wside/app/modules/auth_module/controllers/create_user_controller.dart';

// ignore: use_key_in_widget_constructors
class CreateUserPage extends StatelessWidget {
  final CreateUserController controller = Get.put(CreateUserController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kullanıcı Oluştur')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: MediaQuery.of(context).size.width/2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextField(
                  onChanged: (value) => controller.name.value = value,
                  decoration:const InputDecoration(labelText: 'İsim'),
                  keyboardType: TextInputType.name,
                ),
                TextField(
                  onChanged: (value) => controller.email.value = value,
                  decoration:const InputDecoration(labelText: 'E-posta'),
                  keyboardType: TextInputType.emailAddress,
                ),
                TextField(
                  onChanged: (value) => controller.password.value = value,
                  decoration:const InputDecoration(labelText: 'Şifre'),
                  obscureText: true,
                ),
                 DropdownButtonFormField<String>(
                value: null,
                hint: const Text('Select Type'),
                onChanged: (value) {
                  controller.selectedType.value = value!;
                },
                items: controller.types.map((role) {
                  return DropdownMenuItem<String>(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
              ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    controller.createUser();
                    Navigator.pop(context);
                  },
                  child:const Text('Kullanıcı Oluştur'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}