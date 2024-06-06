import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wside/app/models/post_sales.dart';
import 'package:wside/app/modules/post_sales/add_post_sales.dart';
import 'package:wside/app/modules/post_sales/post_sales_detail_page.dart';
import 'package:wside/app/services/post_sales_service.dart';
import 'package:get/get.dart';

class PostSalesPage extends StatelessWidget {
  const PostSalesPage({super.key});

  Stream<List<PostSales>> _getPostSalesStream() {
    return FirebaseFirestore.instance
        .collection('postSales')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => PostSales.fromMap(doc)).toList());
  }

  Future<void> _deletePostSales(BuildContext context, String postSalesId) async {
    final PostSalesService _postSalesService = PostSalesService();
    try {
      await _postSalesService.deletePostSales(postSalesId);
      Get.snackbar(
        'Success',
        'PostSales deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete post sales: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Color _getCardColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red[200]!;
      case 'Medium':
        return Colors.orange[200]!;
      case 'Low':
        return Colors.green[200]!;
      default:
        return Colors.grey[200]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Post Sales')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: AddPostSalesPage(),
                ),
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
      body: StreamBuilder<List<PostSales>>(
        stream: _getPostSalesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No post sales available.'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              PostSales postSales = snapshot.data![index];
              return Card(
                color: _getCardColor(postSales.priority),
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: ListTile(
                  title: Text(postSales.type, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(postSales.description),
                      SizedBox(height: 5),
                      Text('Assigned to: ${postSales.assignedTo}', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text('Email: ${postSales.assignedToEmail}', style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deletePostSales(context, postSales.id!),
                      ),
                    ],
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.75,
                            child: PostSalesDetailPage(postSales: postSales),
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
