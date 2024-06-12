import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:wside/app/models/products.dart';

class ProductService {
  final CollectionReference productsCollection = FirebaseFirestore.instance.collection('products');

  Future<void> addProduct(Product product) async {
    try {
      DocumentReference docRef = productsCollection.doc();
      product.id = docRef.id; // id alanını otomatik olarak ayarlayın
      await docRef.set(product.toMap());
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await productsCollection.doc(product.id).update(product.toMap());
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await productsCollection.doc(productId).delete();
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  Stream<List<Product>> getProducts() {
    return productsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromFirestore(doc);
      }).toList();
    });
  }

  Future<Product> getProductById(String productId) async {
    try {
      DocumentSnapshot doc = await productsCollection.doc(productId).get();
      return Product.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get product: $e');
    }
  }
}
