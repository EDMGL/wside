import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wside/app/modules/auth_module/views/create_user_page.dart';
import 'package:wside/app/modules/home_page_modules/controllers/admin_home_page_controller.dart';
import 'package:wside/app/modules/profile_modules/profiles.dart';
import 'package:wside/app/services/auth_service.dart';
import 'package:wside/app/widgets/menu_item.dart';
import 'package:wside/app/utils/constants.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AdminHomeController controller = Get.put(AdminHomeController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: menuColor,
        title: Row(
          children: [
            const SizedBox(width: 20),
            Image.asset('assets/logo-wside.png', scale: 16),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.co_present_sharp, color: Colors.white),
            onPressed: () {
              Get.to( ProfilePage());
            },
          ),
          IconButton(
            icon: const Icon(Icons.group_add, color: Colors.white),
            onPressed: () {
              Get.to( CreateUserPage());
            },
          ),
          IconButton(onPressed: ()async{
            await AuthService().signOut();
          }, icon:const Icon(Icons.power_settings_new_outlined, color: Colors.white))
          ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            // Web
            return Row(
              children: [
                Container(
                  width: 250,
                  color: menuColor,
                  child: ListView(
                    children: [
                      MenuItem(
                        controller: controller,
                        title: 'Accounts',
                        icon: Icons.business,
                      ),
                      MenuItem(
                        controller: controller,
                        title: 'Contacts',
                        icon: Icons.contacts,
                      ),
                      MenuItem(
                        controller: controller,
                        title: 'Leads',
                        icon: Icons.account_tree_rounded,
                      ),
                      MenuItem(
                        controller: controller,
                        title: 'Opportunuties',
                        icon: Icons.trending_up,
                      ),
                      MenuItem(
                        controller: controller,
                        title: 'Quotes',
                        icon: Icons.assignment_outlined,
                      ),
                      MenuItem(
                        controller: controller,
                        title: 'Orders',
                        icon: Icons.shopping_cart_checkout,
                      ),
                      MenuItem(
                        controller: controller,
                        title: 'Sales Services',
                        icon: Icons.attach_file_rounded,
                      ),
                      MenuItem(
                        controller: controller,
                        title: 'Actions',
                        icon: Icons.pending_actions_rounded,
                      ),
                      MenuItem(
                        controller: controller,
                        title: 'Activities',
                        icon: Icons.local_activity,
                      ),
                       MenuItem(
                        controller: controller,
                        title: 'Reports',
                        icon: Icons.dashboard,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Obx(() => controller.getSelectedPageWidget()),
                  ),
                ),
              ],
            );
          } else {
            // Mobil
            return Column(
              children: [
                Container(
                  height: 80,
                  color: menuColor,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      MenuItem(
                        controller: controller,
                        title: 'Accounts',
                        icon: Icons.business,
                      ),
                      MenuItem(
                        controller: controller,
                        title: 'Contacts',
                        icon: Icons.contacts,
                      ),
                      MenuItem(
                        controller: controller,
                        title: 'Leads',
                        icon: Icons.account_tree_rounded,
                      ),
                      MenuItem(
                        controller: controller,
                        title: 'Opportunuties',
                        icon: Icons.trending_up,
                      ),
                      MenuItem(
                        controller: controller,
                        title: 'Quotes',
                        icon: Icons.assignment_outlined,
                      ),
                      MenuItem(
                        controller: controller,
                        title: 'Orders',
                        icon: Icons.shopping_cart_checkout,
                      ),
                      MenuItem(
                        controller: controller,
                        title: 'Sales Services',
                        icon: Icons.attach_file_rounded,
                      ),
                      MenuItem(
                        controller: controller,
                        title: 'Actions',
                        icon: Icons.pending_actions_rounded,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Obx(() => controller.getSelectedPageWidget()),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
