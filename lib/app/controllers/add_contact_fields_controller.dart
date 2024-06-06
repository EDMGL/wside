// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wside/app/models/account.dart';

class AddContactFieldsController extends GetxController {
  TextEditingController nameController = TextEditingController();
  TextEditingController customerId = TextEditingController();
  TextEditingController mailController = TextEditingController();

  RxList<Account> customersList = RxList<Account>();
  RxString selectedCustomerId = ''.obs;



  @override
  void onInit() {
    super.onInit();
    fetchCustomers();
  }

  void fetchCustomers() async {
    // Firestore koleksiyonundan müşteri verilerini çekme
    try {
      var collection = FirebaseFirestore.instance.collection('customers');
      var snapshot = await collection.get();
      var customers = snapshot.docs.map((doc) => Account.fromMap(doc)).toList();
      customersList.assignAll(customers);
    } catch (e) {
      print(e); // Hata yönetimi
    }
  }





}
