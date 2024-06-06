import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:wside/app/models/quote.dart' as myQuote; // myQuote prefix'i ekleyin
import 'package:wside/app/services/quote_service.dart'; // QuoteService'i import edin
import 'package:wside/app/modules/quotes_module.dart/quote_detail_page.dart'; // QuoteDetailPage'i import edin

class QuotesPage extends StatelessWidget {
  const QuotesPage({super.key});

  Stream<List<myQuote.Quote>> _getQuotesStream() {
    return FirebaseFirestore.instance
        .collection('quotes')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => myQuote.Quote.fromMap(doc)).toList());
  }

  Future<void> _deleteQuote(BuildContext context, String quoteId) async {
    final QuoteService _quoteService = QuoteService();
    try {
      await _quoteService.deleteQuote(quoteId);
      Get.snackbar(
        'Success',
        'Quote deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete quote: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quotes')),
      body: StreamBuilder<List<myQuote.Quote>>(
        stream: _getQuotesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No quotes available.'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              myQuote.Quote quote = snapshot.data![index];
              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text(
                    quote.name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(quote.description),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteQuote(context, quote.id!),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.75,
                            child: QuoteDetailPage(quote: quote),
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
