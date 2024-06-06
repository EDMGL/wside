import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wside/app/modules/accouts_modules/accounts_page.dart';
import 'package:wside/app/modules/actions_modules/actions_page.dart';
import 'package:wside/app/modules/activities_modules/activities_page.dart';
import 'package:wside/app/modules/contacts_module/contacts_page.dart';
import 'package:wside/app/modules/lead_modules/leads_page.dart';
import 'package:wside/app/modules/opportunity_modules/opportunities_page.dart';
import 'package:wside/app/modules/order_modules/orders_page.dart';
import 'package:wside/app/modules/post_sales/post_sales_page.dart';
import 'package:wside/app/modules/quotes_module.dart/quotes_page.dart';
import 'package:wside/app/modules/reports_modules/report_page.dart';

class AdminHomeController extends GetxController {
  var isMenuOpen = true.obs; // Menü açık mı kapalı mı kontrolü için
  var selectedMenuItem = 'Accounts'.obs; // Başlangıç değeri olarak 'Accounts'

  // Menü öğelerine tıklandığında çağrılacak fonksiyon
  void toggleMenu() {
    isMenuOpen.value = !isMenuOpen.value; // Menü durumunu değiştir
  }

  Widget getSelectedPageWidget() {
    // Seçilen menü öğesine göre içerik widget'ını döndür
    switch (selectedMenuItem.value) {
      case 'Accounts':
        return AccountsPage(); 
      case 'Contacts':
        return ContactsPage();
        // Örnek bir sayfa widget'ı
      case 'Leads':
        return LeadsPage();
      case 'Opportunuties':
        return OpportunitiesPage();
      case 'Quotes':
        return QuotesPage();
      case 'Orders':
        return OrdersPage();
      case 'Sales Services':
        return  PostSalesPage();      
      case 'Actions':
        return  ActionsPage();
         case 'Activities':
        return  ActivitiesPage();
           case 'Reports':
        return  ReportPage();
      // Diğer durumlar...
      default:
        return const Text('Bir sayfa seçin');
    }
  }
}
