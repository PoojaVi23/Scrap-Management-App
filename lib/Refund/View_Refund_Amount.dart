import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:scrapapp/AppClass/AppDrawer.dart';
import 'package:scrapapp/AppClass/appBar.dart';
import 'package:scrapapp/Payment/Edit_payment_detail.dart';
import 'package:scrapapp/Refund/Edit_refund_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class View_Refund_Amount extends StatefulWidget {
  final String? sale_order_id;
  final String? bidder_id;
  final String? refundId;
  final String? paymentType;
  final String? date1;
  final String? amount;
  final String? totalPayment;
  final String? totalEmd;
  final String? totalAmountIncludingEmd;
  final String? note;
  final String? referenceNo;
  final String? rvNo;
  final String? date2;
  final String? typeOfTransfer;
  final String? nfa;
  View_Refund_Amount({
    required this.sale_order_id,
    required this.bidder_id,
    required this.refundId,
    required this.paymentType,
    required this.date1,
    required this.amount,
    required this.totalPayment,
    required this.totalEmd,
    required this.totalAmountIncludingEmd,
    required this.note,
    required this.referenceNo,
    required this.rvNo,
    required this.date2,
    required this.typeOfTransfer,
    required this.nfa,

  });
  @override
  State<View_Refund_Amount> createState() => _View_Refund_AmountState();
}

class _View_Refund_AmountState extends State<View_Refund_Amount> {

  String? username = '';
 String uuid = '';

  String? password = '';
  String? loginType = '';
  String? userType = '';

  String paymentType='';

  String date1='';

  String amount='';

  String totalPayment='';

  String totalEmd='';

  String totalAmountIncludingEmd='';

  String note='';

  String referenceNo='';

  String rvNo='';

  String date2='';

  String typeOfTransfer='';
  String nfa = '';


  @override
  void initState() {
    super.initState();
    checkLogin().then((_){
      setState(() {});
    });
    getData();
  }

  getData(){
    paymentType = widget.paymentType ?? 'Unknown';
    date1 = widget.date1 ?? 'N/A';
    amount = widget.amount ?? '0.00';
    totalPayment = widget.totalPayment ?? '';
    totalEmd = widget.totalEmd ?? '';
    totalAmountIncludingEmd = widget.totalAmountIncludingEmd ?? '';
    note = widget.note ?? 'No note';
    referenceNo = widget.referenceNo ?? 'N/A';
    rvNo = widget.rvNo ?? 'N/A';
    date2 = widget.date2 ?? 'N/A';
    typeOfTransfer = widget.typeOfTransfer ?? 'Unknown';
    print(widget.nfa);
    nfa = widget.nfa ?? 'N/A';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(currentPage: 6),
      appBar: CustomAppBar(),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        color: Colors.grey[100],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Refund",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Material(
                elevation: 2,
                color: Colors.white,
                shape: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueGrey[400]!)
                ),
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Spacer(),
                      Column(
                        children: [
                          SizedBox(height: 8,),
                          Text(
                            "VIEW REFUND DETAILS",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8,),
                        ],
                      ),
                      Spacer(),
                      // IconButton(
                      //   icon: Icon(
                      //     Icons.edit,
                      //     size: 30,
                      //     color: Colors.indigo[800],
                      //   ),
                      //   onPressed: () {
                      //     print(nfa);
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //         builder: (context) => Edit_refund_detail(
                      //             sale_order_id: widget.sale_order_id,
                      //             nfa: nfa,
                      //             date2: date2,
                      //             date1: date1,
                      //             rvNo: rvNo,
                      //             referenceNo: referenceNo,
                      //             note: note,
                      //             totalAmountIncludingEmd: totalAmountIncludingEmd,
                      //             totalEmd: totalEmd,
                      //             totalPayment: totalPayment,
                      //             amount: amount,
                      //             refundId:widget.refundId,
                      //             paymentType: paymentType,
                      //             typeOfTransfer: typeOfTransfer,
                      //         ),
                      //       ),
                      //     );
                      //   },
                      // ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  if( paymentType== "Refund Amount") ...[
                    buildDisplay("Payment Type", paymentType),
                    buildDisplay("Amount", amount),
                    // buildDisplay("Total Payment", totalPayment),
                    buildDisplay("NFA No.", nfa),
                    buildDisplay("Date", date1 ),
                    // buildDisplay("RV Date", date2),
                  ]else if (paymentType == "Refund EMD" || paymentType =="Refund CMD") ...[
                    buildDisplay("Payment Type", paymentType),
                    buildDisplay("Amount", amount),
                    // buildDisplay("Total EMD", totalEmd),
                    // buildDisplay("Total Amount Including EMD",totalAmountIncludingEmd),
                    buildDisplay("NFA No.", nfa),
                    buildDisplay("Date", date1),
                    // buildDisplay("RV Date", date2),
                  ]else if(paymentType == "Penalty") ...[
                    buildDisplay("Payment Type", paymentType),
                    buildDisplay("Amount", amount),
                    buildDisplay("Date", date1),
                    // buildDisplay("Total EMD", totalEmd),
                    // buildDisplay("Total Amount Including EMD",totalAmountIncludingEmd),
                    // buildDisplay("RV Date", date2),
                  ] else if(paymentType == "Refund All") ...[
                    buildDisplay("Payment Type", paymentType),
                    buildDisplay("Amount", amount),
                    buildDisplay("NFA No.", nfa),
                    buildDisplay("Date", date1),
                    // buildDisplay("Total EMD", totalEmd),
                    // buildDisplay("Total Amount Including EMD",totalAmountIncludingEmd),
                    // buildDisplay("RV Date", date2),
                  ] else ...[
                    buildDisplay("Payment Type", paymentType),
                    buildDisplay("Amount", amount),
                    // buildDisplay("Total Payment", totalPayment),
                    // buildDisplay("Total EMD", totalEmd),
                    // buildDisplay("Total Amount Including EMD",totalAmountIncludingEmd),
                    buildDisplay("Ref/RV No.", referenceNo),
                    // buildDisplay("RV No.", rvNo),
                    buildDisplay("Date", date1),
                    // buildDisplay("RV Date", date2),
                    // buildDisplay("Type Of Transfer", typeOfTransfer),
                    buildDisplay("Remark", note),

                  ],
                  SizedBox(height: 40,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("Back"),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.indigo[800],
                              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDisplay(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0 , horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey[400]!,
                  width: 1.5,
                ),
                color: Colors.white,
              ),
              child: Text(
                value,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
