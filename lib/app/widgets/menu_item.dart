import 'package:flutter/material.dart';
import 'package:wside/app/modules/home_page_modules/controllers/admin_home_page_controller.dart';

class MenuItem extends StatelessWidget {
  final AdminHomeController controller;
  final String title;
  final IconData icon;

  const MenuItem({
    Key? key,
    required this.controller,
    required this.icon,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250, // Genişliği sınırlayın
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        onTap: () {
          controller.selectedMenuItem.value = title; // Menü öğesini seç
        },
        tileColor: controller.selectedMenuItem.value == title
            ? Colors.blueGrey
            : Colors.transparent,
      ),
    );
  }
}
