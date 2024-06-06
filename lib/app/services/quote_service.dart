// ignore_for_file: library_prefixes

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wside/app/models/quote.dart' as myQuote;

class QuoteService {
  final CollectionReference _quoteCollection = FirebaseFirestore.instance.collection('quotes');

  Future<void> addQuote(myQuote.Quote quote) async {
    try {
     DocumentReference docRef = await _quoteCollection.add(quote.toMap());
    String quoteId = docRef.id;
    await docRef.update({'id': quoteId});
    } catch (e) {
      throw Exception('Error adding quote: $e');
    }
  }

  Future<List<myQuote.Quote>> getQuotes() async {
    try {
      QuerySnapshot querySnapshot = await _quoteCollection.get();
      return querySnapshot.docs.map((doc) => myQuote.Quote.fromMap(doc)).toList();
    } catch (e) {
      throw Exception('Error getting quotes: $e');
    }
  }

  Future<void> updateQuote(myQuote.Quote quote) async {
    try {
 DocumentReference docRef = await _quoteCollection.add(quote.toMap());
    String quoteId = docRef.id;
    await docRef.update({'id': quoteId});    } catch (e) {
      throw Exception('Error updating quote: $e');
    }
  }

  Future<void> deleteQuote(String id) async {
    try {
      await _quoteCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Error deleting quote: $e');
    }
  }
}
