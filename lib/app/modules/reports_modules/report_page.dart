import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({Key? key}) : super(key: key);

  Future<Map<String, dynamic>> _getData() async {
    // Kullanıcı verilerini al
    QuerySnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').get();
    Map<String, String> userNames = {};
    for (var doc in userSnapshot.docs) {
      userNames[doc.id] = doc['name'];
    }

    // En çok duyuma sahip çalışan verilerini al
    QuerySnapshot leadSnapshot = await FirebaseFirestore.instance.collection('leads').get();
    Map<String, int> leadCounts = {};
    for (var doc in leadSnapshot.docs) {
      String userId = doc['ownerId'];
      if (leadCounts.containsKey(userId)) {
        leadCounts[userId] = leadCounts[userId]! + 1;
      } else {
        leadCounts[userId] = 1;
      }
    }

    List<ChartData> leadData = leadCounts.entries
        .map((entry) => ChartData(userName: userNames[entry.key] ?? 'Unknown', count: entry.value))
        .toList();

    // En çok aktiviteye sahip çalışan verilerini al
    QuerySnapshot activitySnapshot = await FirebaseFirestore.instance.collection('activities').get();
    Map<String, int> activityCounts = {};
    for (var doc in activitySnapshot.docs) {
      String userId = doc['userId'];
      if (activityCounts.containsKey(userId)) {
        activityCounts[userId] = activityCounts[userId]! + 1;
      } else {
        activityCounts[userId] = 1;
      }
    }

    List<ChartData> activityData = activityCounts.entries
        .map((entry) => ChartData(userName: userNames[entry.key] ?? 'Unknown', count: entry.value))
        .toList();

    // En çok satış yapan çalışan verilerini al
    QuerySnapshot orderSnapshot = await FirebaseFirestore.instance.collection('orders').get();
    Map<String, double> salesCounts = {};
    Map<String, int> orderCounts = {};
    for (var doc in orderSnapshot.docs) {
      String userId = doc['submittedBy'];
      double price = doc['price'];
      if (salesCounts.containsKey(userId)) {
        salesCounts[userId] = salesCounts[userId]! + price;
      } else {
        salesCounts[userId] = price;
      }
      if (orderCounts.containsKey(userId)) {
        orderCounts[userId] = orderCounts[userId]! + 1;
      } else {
        orderCounts[userId] = 1;
      }
    }

    List<ChartData> salesData = salesCounts.entries
        .map((entry) => ChartData(userName: userNames[entry.key] ?? 'Unknown', count: entry.value.toInt()))
        .toList();

    List<ChartData> orderData = orderCounts.entries
        .map((entry) => ChartData(userName: userNames[entry.key] ?? 'Unknown', count: entry.value))
        .toList();

    // En çok gelire sahip hesaplar
    QuerySnapshot accountSnapshot = await FirebaseFirestore.instance.collection('accounts').get();
    Map<String, String> accountNames = {};
    for (var doc in accountSnapshot.docs) {
      accountNames[doc.id] = doc['name'];
    }

    Map<String, double> accountRevenue = {};
    for (var doc in orderSnapshot.docs) {
      String accountId = doc['accountId'];
      double price = doc['price'];
      if (accountRevenue.containsKey(accountId)) {
        accountRevenue[accountId] = accountRevenue[accountId]! + price;
      } else {
        accountRevenue[accountId] = price;
      }
    }

    List<ChartData> accountRevenueData = accountRevenue.entries
        .map((entry) => ChartData(userName: accountNames[entry.key] ?? 'Unknown', count: entry.value.toInt()))
        .toList();

    // En çok sipariş veren hesaplar
    Map<String, int> accountOrderCounts = {};
    for (var doc in orderSnapshot.docs) {
      String accountId = doc['accountId'];
      if (accountOrderCounts.containsKey(accountId)) {
        accountOrderCounts[accountId] = accountOrderCounts[accountId]! + 1;
      } else {
        accountOrderCounts[accountId] = 1;
      }
    }

    List<ChartData> accountOrderData = accountOrderCounts.entries
        .map((entry) => ChartData(userName: accountNames[entry.key] ?? 'Unknown', count: entry.value))
        .toList();

    return {
      'seriesList': [
        charts.Series<ChartData, String>(
          id: 'Leads',
          domainFn: (ChartData data, _) => data.userName,
          measureFn: (ChartData data, _) => data.count,
          data: leadData,
        ),
        charts.Series<ChartData, String>(
          id: 'Activities',
          domainFn: (ChartData data, _) => data.userName,
          measureFn: (ChartData data, _) => data.count,
          data: activityData,
        ),
        charts.Series<ChartData, String>(
          id: 'Sales',
          domainFn: (ChartData data, _) => data.userName,
          measureFn: (ChartData data, _) => data.count,
          data: salesData,
        ),
        charts.Series<ChartData, String>(
          id: 'Orders',
          domainFn: (ChartData data, _) => data.userName,
          measureFn: (ChartData data, _) => data.count,
          data: orderData,
        ),
        charts.Series<ChartData, String>(
          id: 'AccountRevenue',
          domainFn: (ChartData data, _) => data.userName,
          measureFn: (ChartData data, _) => data.count,
          data: accountRevenueData,
        ),
        charts.Series<ChartData, String>(
          id: 'AccountOrders',
          domainFn: (ChartData data, _) => data.userName,
          measureFn: (ChartData data, _) => data.count,
          data: accountOrderData,
        ),
      ],
      'totalLeads': leadSnapshot.size,
      'totalAccounts': accountSnapshot.size,
      'totalContacts': userSnapshot.size,
      'totalOpportunities': leadSnapshot.size, // Örnek olarak aynı değer
      'totalQuotes': salesCounts.length,
      'totalOrders': orderSnapshot.size,
      // ignore: avoid_types_as_parameter_names
      'totalRevenue': salesCounts.values.fold(0, (sum, element) => sum + element.toInt()),
    };
  }

  Widget _buildMetricCard(String title, int value) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value.toString(),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCardDouble(String title, double value) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value.toStringAsFixed(2),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reports')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          var data = snapshot.data!;
          var seriesList = data['seriesList'] as List<charts.Series<ChartData, String>>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildMetricCard('Total Leads', data['totalLeads']),
                    _buildMetricCard('Total Accounts', data['totalAccounts']),
                    _buildMetricCard('Total Contacts', data['totalContacts']),
                    _buildMetricCard('Total Opportunities', data['totalOpportunities']),
                    _buildMetricCard('Total Quotes', data['totalQuotes']),
                    _buildMetricCard('Total Orders', data['totalOrders']),
                    _buildMetricCardDouble('Total Revenue', data['totalRevenue']),
                  ],
                ),
                SizedBox(height: 20),
                Text('Top Leads by Employee', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Expanded(
                  child: charts.BarChart(
                    seriesList.where((series) => series.id == 'Leads').toList(),
                    animate: true,
                    vertical: false,
                  ),
                ),
                SizedBox(height: 16.0),
                Text('Top Activities by Employee', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Expanded(
                  child: charts.BarChart(
                    seriesList.where((series) => series.id == 'Activities').toList(),
                    animate: true,
                    vertical: false,
                  ),
                ),
                SizedBox(height: 16.0),
                Text('Top Sales by Employee', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Expanded(
                  child: charts.BarChart(
                    seriesList.where((series) => series.id == 'Sales').toList(),
                    animate: true,
                    vertical: false,
                  ),
                ),
                SizedBox(height: 16.0),
                Text('Top Orders by Employee', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Expanded(
                  child: charts.BarChart(
                    seriesList.where((series) => series.id == 'Orders').toList(),
                    animate: true,
                    vertical: false,
                  ),
                ),
                SizedBox(height: 16.0),
                Text('Top Revenue by Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Expanded(
                  child: charts.BarChart(
                    seriesList.where((series) => series.id == 'AccountRevenue').toList(),
                    animate: true,
                    vertical: false,
                  ),
                ),
                SizedBox(height: 16.0),
                Text('Top Orders by Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Expanded(
                  child: charts.BarChart(
                    seriesList.where((series) => series.id == 'AccountOrders').toList(),
                    animate: true,
                    vertical: false,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ChartData {
  final String userName;
  final int count;

  ChartData({required this.userName, required this.count});
}
