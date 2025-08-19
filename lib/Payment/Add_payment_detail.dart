// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:scrapapp/AppClass/AppDrawer.dart';
// import 'package:scrapapp/AppClass/appBar.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import '../URL_CONSTANT.dart';
// import 'package:intl/intl.dart'; // Add this package for date formatting
//
//
// class Add_payment_detail extends StatefulWidget {
//   @override
//   _Add_payment_detailState createState() => _Add_payment_detailState();
// }
//
// class _Add_payment_detailState extends State<Add_payment_detail> {
//   final TextEditingController dateController1 = TextEditingController();
//   final TextEditingController amountController = TextEditingController();
//   final TextEditingController refNoController = TextEditingController();
//   final TextEditingController typeTransController = TextEditingController();
//
//   String? username = '';
//  String uuid = '';
//   String? password = '';
//   String? loginType = '';
//   String? userType = '';
//   String? selectedOrderId;
//   String? selectedPaymentType;
//   bool isLoading = false;
//   Map<String , String> PaymentType = {
//     'Select' : 'Select',
//     'Received Payment':'P',
//     'Received EMD':'E',
//     'Received CMD':'C',
//   };
//   Map<String,String> dropDownMap= {
//     'Select' : 'Select',
//   };
//
//   void clearFields(){
//     selectedOrderId = null;
//     selectedPaymentType = null;
//     dateController1.clear();
//     amountController.clear();
//     refNoController.clear();
//     typeTransController.clear();
//   }
//
//   @override
//   void initState(){
//     super.initState();
//     checkLogin().then((_){
//       setState(() {});
//     });
//     fetchDropDwonKeyValuePair();
//   }
//
//   Future<void> checkLogin() async {
//      final prefs = await SharedPreferences.getInstance();
//     username = prefs.getString("username");
//     uuid = prefs.getString("uuid")!;
//     uuid = prefs.getString("uuid")!;
//     password = prefs.getString("password");
//     loginType = prefs.getString("loginType");
//     userType = prefs.getString("userType");
//   }
//
//   Future<void> addPaymentDetails() async {
//     try {
//       setState(() {
//         isLoading = true;
//       });
//       await checkLogin();
//       final url = Uri.parse("${URL}add_payment_toSaleOrder");
//       var response = await http.post(
//         url,
//         headers: {"Accept": "application/json"},
//         body: {
//         'user_id': username,
// 'uuid':uuid,
//           'user_pass': password,
//           'sale_order_id_pay':selectedOrderId ?? '',
//           'payment_type': selectedPaymentType ?? '',
//           'pay_date': dateController1.text,
//           'amt':amountController.text,
//           'pay_ref_no':refNoController.text,
//           'typeoftransfer':typeTransController.text,
//         },
//       );
//       if (response.statusCode == 200) {
//         final jsonData = json.decode(response.body);
//         setState(() {
//           ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text("${jsonData['msg']}")));
//           clearFields();
//           Navigator.pop(context);
//         });
//       } else {
//         Fluttertoast.showToast(
//             msg: 'Unable to insert data.',
//             toastLength: Toast.LENGTH_SHORT,
//             gravity: ToastGravity.BOTTOM,
//             timeInSecForIosWeb: 1,
//             backgroundColor: Colors.red,
//             textColor: Colors.yellow
//         );
//       }
//     } catch (e) {
//       Fluttertoast.showToast(
//           msg: 'Server Exception : $e',
//           toastLength: Toast.LENGTH_SHORT,
//           gravity: ToastGravity.BOTTOM,
//           timeInSecForIosWeb: 1,
//           backgroundColor: Colors.red,
//           textColor: Colors.yellow
//       );
//     }
//     finally{
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   Future<void> fetchDropDwonKeyValuePair() async {
//     try {
//       setState(() {
//         isLoading = true;
//       });
//       await checkLogin();
//       final url = Uri.parse("${URL}fetch_payment_data");
//       var response = await http.post(
//         url,
//         headers: {"Accept": "application/json"},
//         body: {
//         'user_id': username,
// 'uuid':uuid,
//           'user_pass': password,
//         },
//       );
//       if (response.statusCode == 200) {
//         setState(() {
//           var jsonData = json.decode(response.body);
//           // Extract the relevant data
//           List<Map<String, dynamic>> keyValuePair = List<Map<String, dynamic>>.from(jsonData['saleOrder_paymentList']);
//           for (var keyValue in keyValuePair) {
//             // Example key-value pairs of sale_order_code and vendor_name
//             var saleOrderCode = keyValue['sale_order_code'] ?? "N/A";
//             var saleOrderId = keyValue['sale_order_id']?? "N/A";
//
//             // You can store these key-value pairs in a map if needed
//             dropDownMap[saleOrderCode] = saleOrderId;
//           }
//           print(dropDownMap);
//         });
//       } else {
//         print("Unable to fetch data.");
//       }
//     } catch (e) {
//       print("Server Exception: $e");
//     }finally{
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
//     DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2101),
//     );
//     if (picked != null) {
//       String formattedDate = DateFormat('dd-MM-yyyy').format(picked);
//       controller.text = formattedDate;
//     }
//   }
//
//   showLoading(){
//     return Container(
//       height: double.infinity,
//       width: double.infinity,
//       color: Colors.transparent,
//       child: Center(child: CircularProgressIndicator(),),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AbsorbPointer(
//       absorbing: isLoading,
//       child: StatefulBuilder(builder: (BuildContext context , StateSetter SetState) {
//         return Scaffold(
//           drawer: AppDrawer(currentPage: 4),
//           appBar: CustomAppBar(),
//           body:
//           Stack(
//             children: [
//               isLoading ?
//               showLoading()
//               :Container(
//               padding: const EdgeInsets.symmetric(vertical: 4.0),
//               color: Colors.grey[100],
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Text(
//                       "Payment",
//                       style: TextStyle(
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87,
//                         letterSpacing: 1.5,
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Material(
//                       elevation: 2,
//                       color: Colors.white,
//                       shape: OutlineInputBorder(
//                           borderSide: BorderSide(color: Colors.blueGrey[400]!)
//                       ),
//                       child: Container(
//                         child: Column(
//                           children: [
//                             SizedBox(height: 8,),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Text(
//                                   "ADD PAYMENT DETAILS",
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     color: Colors.black54,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: 8,),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 16),
//                   Expanded(
//                     child: ListView(
//                       children: [
//                         buildDropdown("Order ID", dropDownMap, (value) {
//                           setState(() {
//                             selectedOrderId = value;
//                             print(value);
//                           });
//                         }),
//                         buildDropdownPayment("Payment Type", PaymentType, (value) {
//                           setState(() {
//                             selectedPaymentType = value;
//                           });
//                         }),
//                         buildTextField("Date", dateController1, true, context), // Modified here for DatePicker
//                         buildTextField("Amount", amountController, false, context),
//                         buildTextField("Reference No.", refNoController, false, context),
//                         buildTextField("Type Of Transfer", typeTransController, false, context),
//                         SizedBox(height: 180),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               ElevatedButton(
//                                 onPressed: () {
//                                   clearFields();
//                                   Navigator.of(context).pop();
//                                 },
//                                 child: Text("Back"),
//                                 style: ElevatedButton.styleFrom(
//                                   foregroundColor: Colors.white,
//                                   backgroundColor: Colors.indigo[800],
//                                   padding: EdgeInsets.symmetric(
//                                       horizontal: 50, vertical: 12),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                 ),
//                               ),
//                               ElevatedButton(
//                                 onPressed: () {
//                                   addPaymentDetails();
//                                 },
//                                 child: Text("Add"),
//                                 style: ElevatedButton.styleFrom(
//                                   foregroundColor: Colors.white,
//                                   backgroundColor: Colors.indigo[800],
//                                   padding: EdgeInsets.symmetric(
//                                       horizontal: 50, vertical: 12),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         SizedBox(height: 16),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ]),
//         );
//       }),
//     );
//   }
//
//   Widget buildDropdown(String label, Map<String,String> options, ValueChanged<String?> onChanged) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0 , horizontal: 8.0),
//       child: Row(
//         children: [
//           Expanded(
//             flex: 3,
//             child: Text(
//               label,
//               style: TextStyle(
//                 color: Colors.black54,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 7,
//             child: DropdownButtonFormField<String>(
//               isExpanded: true,
//               decoration: InputDecoration(
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               value: selectedOrderId ?? options.keys.first,
//               items: options.entries.map((option) {
//                 return DropdownMenuItem<String>(
//                   value: option.value,
//                   child: Text(option.key),
//                 );
//               }).toList(),
//               onChanged: onChanged,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget buildDropdownPayment(String label, Map<String, String> options, ValueChanged<String?> onChanged) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0 , horizontal: 8.0),
//       child: Row(
//         children: [
//           Expanded(
//             flex: 3,
//             child: Text(
//               label,
//               style: TextStyle(
//                 color: Colors.black54,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 7,
//             child: DropdownButtonFormField<String>(
//               isExpanded: true,
//               decoration: InputDecoration(
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               value: selectedPaymentType ?? options.keys.first,
//               items: options.entries.map((entry) {
//                 return DropdownMenuItem<String>(
//                   value: entry.value,
//                   child: Text(entry.key),
//                 );
//               }).toList(),
//               onChanged: onChanged,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget buildTextField(String labelText, TextEditingController controller, bool isDateField, BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
//       child: Row(
//         children: [
//           Expanded(
//             flex: 3,
//             child: Text(
//               labelText,
//               style: TextStyle(
//                 color: Colors.black54,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 7,
//             child: GestureDetector(
//               onTap: isDateField ? () => _selectDate(context, controller) : null,
//               child: AbsorbPointer(
//                 absorbing: isDateField,
//                 child: TextFormField(
//                   controller: controller,
//                   decoration: InputDecoration(
//                     suffixIcon: isDateField
//                         ? IconButton(
//                       icon: Icon(Icons.calendar_today),
//                       onPressed: () => _selectDate(context, controller),
//                     )
//                         : null,
//                     contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }}
