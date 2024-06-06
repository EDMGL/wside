// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wside/app/models/post_sales.dart';
import 'package:wside/app/modules/post_sales/post_sales_detail_page.dart';

class ActionsPage extends StatelessWidget {
  const ActionsPage({Key? key}) : super(key: key);

  Stream<List<PostSales>> _getUserPostSales() {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return FirebaseFirestore.instance
        .collection('postSales')
        .where('assignedTo', isEqualTo: currentUser?.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => PostSales.fromMap(doc)).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Actions')),
      body: StreamBuilder<List<PostSales>>(
        stream: _getUserPostSales(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No post sales assigned to you.'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              PostSales postSales = snapshot.data![index];
              return ListTile(
                title: Text(postSales.type),
                subtitle: Text(postSales.description),
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
              );
            },
          );
        },
      ),
    );
  }
}
