import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../AppClass/AppDrawer.dart';
import '../AppClass/appBar.dart';
import '../URL_CONSTANT.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:file_picker/file_picker.dart';


class Buyer_DomInterForm extends StatefulWidget {
  final String? details;

  Buyer_DomInterForm({required this.details});

  @override
  _Buyer_DomInterFormState createState() => _Buyer_DomInterFormState();
}

class _Buyer_DomInterFormState extends State<Buyer_DomInterForm> {
  final TextEditingController countryController = TextEditingController();
  final TextEditingController gstNoController = TextEditingController();
  final TextEditingController buyerNameController = TextEditingController();
  final TextEditingController contactPersonController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();
  final TextEditingController panController = TextEditingController();
  final TextEditingController finYearController = TextEditingController();


  List<TextEditingController> phoneControllers = [];
  List<TextEditingController> emailControllers = [];

  //Variables for user details
  String? username = '';
 String uuid = '';
  String? password = '';
  String? loginType = '';
  String? userType = '';

  bool isActive = false;
  bool iscpcb = false;
  bool isspcb = false;

  PlatformFile? selectedFileCPCB;
  PlatformFile? selectedFileSPCB;

  DateTime? selectedCPCBDate;
  DateTime? selectedSPCBDate;


  @override
  void initState() {
    super.initState();
    checkLogin();
    financialYears = generateFinancialYears();
    finYearController.text = financialYears[1];
    phoneControllers.add(TextEditingController());
    emailControllers.add(TextEditingController());
    // Fetch data from API and populate controllers if needed
  }

  //Fetching user details from sharedpreferences
  Future<void> checkLogin() async {
     final prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username");
    uuid = prefs.getString("uuid")!;
    uuid = prefs.getString("uuid")!;
    password = prefs.getString("password");
    loginType = prefs.getString("loginType");
    userType = prefs.getString("userType");
  }


  Future<void> fetchGstDetails() async {
    try {
      await checkLogin(); // Ensure login is valid
      final url = Uri.parse("${URL}gst_data");
      var response = await http.post(
        url,
        headers: {"Accept": "application/json"},
        body: {
          'user_id': username,
          'uuid':uuid,
          'user_pass': password,
          'gstin':  '27AAAAP0267H2ZN',
          //          'gstin':  gstNoController.text,
          'fy': finYearController.text ?? '',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // Extract primary address and format it
        if (jsonData.containsKey('addresses') && jsonData['addresses'] is List) {
          final addresses = jsonData['addresses'] as List;
          if (addresses.isNotEmpty) {
            final primaryAddress = addresses[0]; // First address

            final formattedAddress = [
              primaryAddress['building'] ?? '',
              primaryAddress['buildingName'] ?? '',
              primaryAddress['floor'] ?? '',
              primaryAddress['street'] ?? '',
              primaryAddress['locality'] ?? '',
              primaryAddress['district'] ?? '',
              primaryAddress['state'] ?? '',
              primaryAddress['zip'] ?? ''
            ].where((element) => element.isNotEmpty).join(', ');


            // Update state variables
            setState(() {
              addressController.text = formattedAddress;
              stateController.text = primaryAddress['state'] ?? '';
              cityController.text = primaryAddress['locality'] ?? primaryAddress['district'] ?? '';
              pinCodeController.text = primaryAddress['zip'] ?? '';
            });

          }
        }

        // Print other details like PAN
        setState(() {
          panController.text = jsonData['pan'] ?? '';
        });
      } else {
        print("Error: ${response.statusCode} - ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Exception: $e");
      Fluttertoast.showToast(
        msg: 'Server Exception: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.yellow,
      );
    }
  }

  Future<void> adddomesticDetails() async {

    // if (countryController.text.isEmpty ||
    //     gstNoController.text.isEmpty ||
    //     finYearController.text.isEmpty ||
    //     buyerNameController.text.isEmpty ||
    //     contactPersonController.text.isEmpty ||
    //     addressController.text.isEmpty ||
    //     pinCodeController.text.isEmpty ||
    //     stateController.text.isEmpty ||
    //     cityController.text.isEmpty
    // ) {
    //   // Print an error message or show a toast to the user
    //   Fluttertoast.showToast(
    //     msg: "Please fill all required fields.",
    //     fontSize: 16.0,
    //   );
    //   return; // Exit the function without making the API call
    // }

    await checkLogin();
    final url = Uri.parse('${URL}bidder_save');

    final Map<String, String> body = {
      'user_id': username.toString(),
      'user_pass': password.toString(),
      'bidder_name': buyerNameController.text ?? '',
      'con_person': contactPersonController.text ?? '',
      'address': addressController.text ?? '',
      'country': countryController.text ?? '',
      'state': stateController.text ?? '',
      'city': cityController.text ?? '',
      'pin_code': pinCodeController.text ?? '',
      'pan': panController.text ?? '',
      'tan': gstNoController.text ?? '',
      'type_of_company': selectedCompanyType,
      'nature_of_activity': selectedNatureofactivityType,
      'CPCB_SPCB': (iscpcb && isspcb).toString() == false ? 'no' :'yes',
      'cpcb_exp_date':selectedCPCBDate.toString() ?? '',
      'spcb_exp_date': selectedFileSPCB.toString() ?? '',
      'formType': widget.details ==  'Add Domestic Details' ? 'domestic' : 'internation',
      'is_active': isActive == true ? 'Y' : 'N',
      'tan':'',
      'phone[]]': phoneControllers.map((controller) => controller.text).join(','),
      'email[]': emailControllers.map((controller) => controller.text).join(','),

    };

    final request = http.MultipartRequest('POST', url)..fields.addAll(body);

    if (selectedFileSPCB != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'spcb_files',
          selectedFileSPCB!.bytes!,
          filename: selectedFileSPCB!.name,
        ),
      );
    }if (selectedFileCPCB != null){
      request.files.add(
        http.MultipartFile.fromBytes(
          'cpcb_files',
          selectedFileCPCB!.bytes!,
          filename: selectedFileCPCB!.name,
        ),
      );

    } else {
      print('Invalid file selected or file properties are null.');
    }

    try {
      final response = await request.send();

      // Log status code and headers
      print('Status Code: ${response.statusCode}');
      print('Headers: ${response.headers}');

      final responseString = await response.stream.bytesToString();
      print('Response Body: $responseString');

      if (response.statusCode == 200) {
        // Decode the JSON response
        final responseData = json.decode(responseString);

        // Extract the message and display in a toast
        String message = responseData['msg'] ?? "Vendor saved successfully!";
        Fluttertoast.showToast(
          msg: message,
        );
      } else {
        // Log and display error details
        print('Request failed with status: ${response.statusCode}');
        Fluttertoast.showToast(
          msg: "Something went wrong: ${response.statusCode}",
        );
      }
    } catch (e) {
      print('An error occurred: $e');
      Fluttertoast.showToast(
        msg: "An error occurred: $e",
      );
    }

  }


  Future<void> _pickAttachment(String type) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.path != null) {
        PlatformFile file = result.files.single;

        // Create a File object from PlatformFile path
        File pickedFile = File(file.path!);

        // Read file bytes
        Uint8List fileBytes = await pickedFile.readAsBytes();

        setState(() {
          if (type == 'SPCB') {
            selectedFileSPCB = PlatformFile(
              path: file.path,
              name: file.name,
              bytes: fileBytes,
              size: file.size,
            );
          } else if (type == 'CPCB') {
            selectedFileCPCB = PlatformFile(
              path: file.path,
              name: file.name,
              bytes: fileBytes,
              size: file.size,
            );
          }
        });
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  void _removefile(String type) {
    setState(() {
      if (type == 'SPCB') {
        selectedFileSPCB = null;
      } else if (type == 'CPCB') {
        selectedFileCPCB = null;
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Material(
                      elevation: 2,
                      color: Colors.white,
                      shape: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blueGrey[400]!)
                      ),
                      child: Container(
                        child: Column(
                          children: [
                            SizedBox(height: 8,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("${widget.details}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8,),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildTextField("Country *", countryController),
                  _buildTextField("GST NO *", gstNoController),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      onPressed : (){
                        fetchGstDetails();
                      },
                      child : Text("Verify"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo[800],
                        foregroundColor:  Colors.white,
                      ),
                    ),
                  ),
                  _buildDropdownField('Fin yr *', financialYears, finYearController.text, (newValue) {
                    setState(() {
                      finYearController.text = newValue!;
                    });
                  }),
                  _buildTextField("Buyer Name *", buyerNameController),
                  _buildTextField("Contact Person *", contactPersonController),
                  _buildTextField("Address *", addressController),
                  _buildTextField("State *", stateController),
                  _buildTextField("City *", cityController),
                  _buildTextField("Pin Code *", pinCodeController),
                  _buildTextField("PAN", panController),
                  _buildDropdownField('Type of Company', companyTypes, selectedCompanyType, updateSelectedCompanyType),
                  _buildDropdownField('Nature of Activity', natureofactivityTypes, selectedNatureofactivityType, updateSelectedNatureofactivityType),

                  _buildPhoneSection(),
                  _buildEmailSection(),
                  CheckboxListTile(
                    value: isActive,
                    title: Text("Is Active",style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),),
                    onChanged: (value) {
                      setState(() => isActive = value!);
                    },
                  ),
                  CheckboxListTile(
                    value: iscpcb,
                    title: Text("CPCB",style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),),
                    onChanged: (value) {
                      setState(() => iscpcb = value!);
                    },
                  ),
                  if (iscpcb)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFilePickerField(
                          'CPCB Certificate',
                          selectedFileCPCB?.name ?? '',
                              () => _pickAttachment('CPCB'),
                              () => _removefile('CPCB'),
                        ),
                        SizedBox(height: 5,),
                        buildFieldWithDatePicker(
                          'CPCB Exp Date',
                          selectedCPCBDate,
                              (DateTime? selectedDate) {
                            setState(() {
                              selectedCPCBDate = selectedDate!;
                            });
                          },
                        ),

                      ],
                    ),
                  CheckboxListTile(
                    value: isspcb,
                    title: Text("SPCB",style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),),
                    onChanged: (value) {
                      setState(() => isspcb = value!);
                    },
                  ),
                  if (isspcb)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFilePickerField(
                          'SPCB Certificate',
                          selectedFileSPCB?.name ?? '',
                              () => _pickAttachment('SPCB'),
                              () => _removefile('SPCB'),
                        ),
                        buildFieldWithDatePicker(
                          'SPCB Exp Date',
                          selectedSPCBDate,
                              (DateTime? selectedDate) {
                            setState(() {
                              selectedSPCBDate = selectedDate!;
                            });
                          },
                        ),
                      ],
                    ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        await adddomesticDetails(); // Wait for the async function to complete
                      },
                      child: Text("Submit",style: TextStyle(color: Colors.white),),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.indigo[800],
                        padding: EdgeInsets.symmetric(
                            horizontal: 50, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(String labelText, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        children: [
          Container(
            width: 120, // Fixed width for the label, adjust as needed
            child: Text(
              labelText,
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildPhoneSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...phoneControllers.map((controller) {
          int index = phoneControllers.indexOf(controller);
          return Row(
            children: [
              Expanded(child: _buildTextField("Phone", controller)),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    phoneControllers.removeAt(index);
                  });
                },
              ),

            ],
          );
        }),
        Align(
          alignment: Alignment.bottomRight,
          child: IconButton(
            onPressed: () {
              setState(() {
                phoneControllers.add(TextEditingController());
              });
            },
            icon: Icon(Icons.add, color: Colors.white, size: 18), // Icon with custom size and color
            style: IconButton.styleFrom(
              backgroundColor: Colors.blueAccent, // Button background color
              padding: EdgeInsets.all(8), // Compact padding
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50), // Rounded corners
              ),
              elevation: 1, // Minimal shadow
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...emailControllers.map((controller) {
          int index = emailControllers.indexOf(controller);
          return Row(
            children: [
              Expanded(child: _buildTextField("Email *", controller)),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    emailControllers.removeAt(index);
                  });
                },
              ),
            ],

          );
        }),
        Align(alignment: Alignment.bottomRight,
          child:  IconButton(
            onPressed: () {
              setState(() {
                emailControllers.add(TextEditingController());
              });
            },
            icon: Icon(Icons.add, color: Colors.white, size: 18), // Icon with custom size and color
            style: IconButton.styleFrom(
              backgroundColor: Colors.blueAccent, // Button background color
              padding: EdgeInsets.all(8), // Compact padding
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50), // Rounded corners
              ),
              elevation: 1, // Minimal shadow
            ),
          ),)
      ],
    );
  }


  Widget _buildFilePickerField(
      String label,
      String? fileName,
      VoidCallback onUploadPressed,
      VoidCallback onDeletePressed,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 150,
            child: Text(
              '$label',
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 40,
              child: ElevatedButton(
                onPressed: onUploadPressed,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(
                      Icons.upload_file,
                      size: 22.0,
                      color: Colors.black,
                    ),
                    Expanded(
                      child: Text(
                        fileName != null && fileName.isNotEmpty
                            ? fileName
                            : 'Upload File',
                      ),
                    ),
                    if (fileName != null && fileName.isNotEmpty)
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: onDeletePressed,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget buildFieldWithDatePicker(String label, DateTime? selectedDate, Function(DateTime?) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        SizedBox(width: 8.0),
        TextButton(
          onPressed: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(), // Default to today's date if null
              firstDate: DateTime(2000),
              lastDate: DateTime.now().add(Duration(days: 365)),
            );
            if (picked != null && picked != selectedDate) {
              onChanged(picked);
            }
          },
          child: Text(
            selectedDate != null
                ? "${selectedDate.toLocal()}".split(' ')[0]
                : 'Select Date', // Show "Select Date" if no date is selected
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    );
  }

  // Generate financial years dynamically
  List<String> generateFinancialYears() {
    int currentYear = DateTime.now().year;
    int currentYears = DateTime.now().year % 100;

    List<String> years = [];
    for (int i = 0; i < 5; i++) {
      String yearLabel = '${currentYear - i}-${currentYears - i + 1}';
      years.add(yearLabel);
    }
    return years;
  }


  List<String> financialYears = [];

  String selectedCompanyType = 'Type of Company'; // Initial selected value
  List<String> companyTypes = [
    'Type of Company',
    'Individual',
    'Sole Proprietorship',
    'Partnership',
    'Private Ltd.',
    'Trust',
    'Public Ltd.',
  ];

  List<String> natureofactivityTypes = [
    'Nature of Company',
    'Trading',
    'Manufacturing',
    'Both',
  ];

  String selectedNatureofactivityType ='Nature of Company';

  void updateSelectedNatureofactivityType(String? newValue) {
    setState(() {
      selectedNatureofactivityType = newValue ?? 'Nature of Company';
    });
  }

  void updateSelectedCompanyType(String? newValue) {
    setState(() {
      selectedCompanyType = newValue ?? 'Type of Company';
    });
  }

  Widget _buildDropdownField(
      String label, List<String> items, String selectedValue, void Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        children: [
          Container(
            width: 120, // Fixed width for the label, adjust as needed
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
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              value: selectedValue,
              icon: Icon(Icons.arrow_drop_down),
              iconSize: 24,
              elevation: 16,
              style: TextStyle(color: Colors.black),
              onChanged: onChanged,
              items: items.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }


}
