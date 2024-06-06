import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wside/app/models/order.dart' as myOrder;



class OrderService {
  final CollectionReference _orderCollection = FirebaseFirestore.instance.collection('orders');

  Future<void> addOrder(myOrder.Order order) async {
    DocumentReference docRef = await _orderCollection.add(order.toMap());
    String orderId = docRef.id; // Firestore tarafından oluşturulan id
    await docRef.update({'id': orderId}); // Firestore'da id alanını güncelle
  }

  Future<void> updateOrder(myOrder.Order order) async {
    await _orderCollection.doc(order.id).update(order.toMap());
  }

  Future<void> deleteOrder(String orderId) async {
    await _orderCollection.doc(orderId).delete();
  }
}

