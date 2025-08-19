import 'dart:async';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:scrapapp/AppClass/AppDrawer.dart';
import 'package:scrapapp/AppClass/appBar.dart';
import 'package:scrapapp/DashBoard/saleOrderList.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../URL_CONSTANT.dart';
import 'dart:math' as math;

class DashBoard extends StatefulWidget {
  final int currentPage;

  DashBoard({required this.currentPage});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  String? username;
  String uuid = '';
  String? password;
  String? loginType;
  String? userType;
  String? saleOrders;
  String? totalSaleOrder;
  String? activeSaleOrder;
  String? closedSaleOrder;

  String? buyerCount;
  String? auctionCmp;
  List<int> saleOrder = [];
  String? curr_year;
  List<dynamic> graph = [];



  final Location _location = Location();
  LocationData? _previousLocation;

  @override
  void initState() {
    super.initState();
    checkLogin();
    fetchDashBoardData();
    getLastSixMonths();

  }


  @override
  void dispose() {
    super.dispose();
  }

  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username");
    uuid = prefs.getString("uuid")!;
    uuid = prefs.getString("uuid")!;
    password = prefs.getString("password");
    loginType = prefs.getString("loginType");
    userType = prefs.getString("userType");
  }

  Future<void> fetchDashBoardData() async {
    try {
      await checkLogin();
      final url = Uri.parse("${URL}Dashboard");
      var response = await http.post(
        url,
        headers: {"Accept": "application/json"},
        body: {
          'user_id': username,
          'uuid':uuid,
          'user_pass': password,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          totalSaleOrder = jsonData['saleorder']['total_sale_order']['sale_cnt'];
          closedSaleOrder = jsonData['saleorder']['done_sale_order']['sale_cnt'];
          activeSaleOrder = jsonData['saleorder']['active_sale_order']['sale_cnt'];

          buyerCount = jsonData['bidders']['bidder_cnt'];
          auctionCmp = jsonData['auction_company']['auc_cnt'];
          graph = jsonData['six_month_data'];
          print(graph);
        });
      } else {
        _handleError("Unable to fetch data: ${response.statusCode}");
      }
    } catch (e) {
      _handleError("Server Exception: $e");
    }
  }

  void _handleError(String message) {
    print(message);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(currentPage: widget.currentPage),
      appBar: CustomAppBar(),
      body: OrientationBuilder(
        builder: (context, orientation) {
          final isPortrait = orientation == Orientation.portrait;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _buildGraph(context),
                  ),
                  _buildSummaryCards(context, isPortrait),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  Widget _buildGraph(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    List<String> lastSixMonths = getLastSixMonths();

    // Determine dynamic max Y value
    double maxY = (graph.isNotEmpty)
        ? graph.map((e) => int.tryParse(e['cnt'].toString()) ?? 0).reduce(math.max).toDouble()
        : 100; // Default if graph is empty

    double stepSize = (maxY / 5).ceilToDouble(); // Creates 5 steps on Y-axis

    return Container(
      width: screenWidth,
      height: screenHeight * 0.35,
      padding: EdgeInsets.all(16.0),
      decoration: _boxDecoration(),
      child: Column(
        children: [
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY + stepSize, // Add buffer
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: stepSize, // Dynamic step size
                      getTitlesWidget: (value, meta) => SideTitleWidget(
                        axisSide: meta.axisSide,
                        space: 10,
                        child: Text(
                          value.toStringAsFixed(0),
                          style: TextStyle(fontSize: 12, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      reservedSize: 50,
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value >= 0 && value < lastSixMonths.length) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(lastSixMonths[value.toInt()], style: TextStyle(fontSize: 12)),
                          );
                        }
                        return SideTitleWidget(axisSide: meta.axisSide, child: Text(''));
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: true),
                barGroups: _buildBarGroups(),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: stepSize, // Dynamic interval for Y-grid lines
                ),
              ),
            ),
          ),
          _buildGraphLegend(),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, bool isPortrait) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Column(
      children: [
        if (isPortrait) ...[
          Column(
            children: [
              SizedBox(height: 20,),
              Row(
                children: [
                  Expanded(child: _buildCard("$activeSaleOrder", "Active Sale Order", Colors.blue)),
                  Expanded(child: _buildCard("$totalSaleOrder", "Total Sale Order", Colors.green)),
                  // Expanded(child: _buildCard("$closedSaleOrder", "Closed  Sale Order", Colors.green)),
                ],
              ),
              SizedBox(height: 20,),
              Row(
                children: [
                  Expanded(child: _buildCard("$auctionCmp", "Vendors", Colors.deepPurple)),
                  Expanded(child: _buildCard("$buyerCount", "Buyers", Colors.pink)),
                ],
              ),

            ],
          )
        ] else
          Row(
            children: [
              Expanded(child: _buildCard("$saleOrders", "Active Sale Order", Colors.blue)),
              Expanded(child: _buildCard("$saleOrders", "Total Sale Order", Colors.green)),
              Expanded(child: _buildCard("$auctionCmp", "Auction Company", Colors.deepPurple)),
              Expanded(child: _buildCard("$buyerCount", "Buyer", Colors.pink)),
            ],
          ),
      ],
    );
  }

  Widget _buildCard(String value, String label, Color color) {
    return Container(
      margin: EdgeInsets.all(8.0),
      padding: EdgeInsets.all(16.0),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: color)),
          Text(label),
        ],
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8.0),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 2,
          blurRadius: 5,
          offset: Offset(0, 3),
        ),
      ],
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return List.generate(graph.length, (index) {
      int count = int.tryParse(graph[index]['cnt'].toString()) ?? 0;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: count.toDouble(),
            color: Colors.green,
            width: 30,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }

  List<String> getLastSixMonths() {
    DateTime now = DateTime.now();
    List<String> reverseMonths = [];

    for (int i = 0; i < graph.length; i++) {
      DateTime date = DateTime(now.year, now.month - i, 1);
      String month = "${_getMonthName(date.month)}";
      reverseMonths.add("$month");
    }

    List<String> months = reverseMonths.reversed.toList();



    if (months.contains("Dec") && months.contains("Jan")) {
      curr_year = "${now.year - 1}-${now.year}";
    } else {
      curr_year = "${now.year}";
    }


    return months;

  }
  String _getMonthName(int month) {
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return monthNames[month - 1];
  }

  Widget _buildGraphLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 10, height: 10, color: Colors.green),
        SizedBox(width: 4),
        Text("Active SO ($curr_year)"),
      ],
    );
  }
}