import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wside/app/models/post_sales.dart';

class PostSalesService {
  final CollectionReference _collection = FirebaseFirestore.instance.collection('postSales');

  Future<void> addPostSales(PostSales postSales) async {
    DocumentReference docRef = await _collection.add(postSales.toMap());
    await docRef.update({'id': docRef.id});
  }

  Future<void> updatePostSales(PostSales postSales) async {
    await _collection.doc(postSales.id).update(postSales.toMap());
  }

  Future<void> deletePostSales(String postSalesId) async {
    await _collection.doc(postSalesId).delete();
  }
}
