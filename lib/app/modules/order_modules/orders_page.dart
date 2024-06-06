import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:wside/app/models/order.dart' as myOrder; // myOrder prefix'i ekleyin
import 'package:wside/app/modules/order_modules/order_detail.dart';
import 'package:wside/app/services/order_service.dart'; // OrderService'i import edin

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  Stream<List<myOrder.Order>> _getOrdersStream() {
    return FirebaseFirestore.instance.collection('orders').snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => myOrder.Order.fromMap(doc)).toList());
  }

  Future<void> _deleteOrder(BuildContext context, String orderId) async {
    final OrderService _orderService = OrderService();
    try {
      await _orderService.deleteOrder(orderId);
      Get.snackbar('Success', 'Order deleted successfully');
    } catch (e) {
      Get.snackbar('Failed', 'Failed to delete order');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Orders')),
      body: StreamBuilder<List<myOrder.Order>>(
        stream: _getOrdersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No orders available.'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              myOrder.Order order = snapshot.data![index];
              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text(
                    order.name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(order.description),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteOrder(context, order.id!),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.75,
                            child: OrderDetailPage(order: order),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
