// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:localstorage/localstorage.dart';
// import 'package:file_picker/file_picker.dart';

// class MyProfileScreen extends StatefulWidget {
//   const MyProfileScreen({super.key});

//   @override
//   State<MyProfileScreen> createState() => _MyProfileScreenState();
// }

// class _MyProfileScreenState extends State<MyProfileScreen> with SingleTickerProviderStateMixin {
//   final _fullNameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _dobController = TextEditingController();
//   final _pancardController = TextEditingController();
//   final _pinCodeController = TextEditingController();
//   final _maritalStatusController = TextEditingController();
  
//   // Employment details controllers
//   final _netMonthlyIncomeController = TextEditingController();
//   final _companyNameController = TextEditingController();
//   final _companyPinCodeController = TextEditingController();
//   String _salarySlipDocument = '';

//   String gender = '';
//   bool isLoading = true;
//   bool isPersonalInfoEditing = false;
//   bool isEmploymentInfoEditing = false;
//   bool hasEmploymentData = false;
  
//   late TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     _fetchUserData();
//   }

//   Future<void> _fetchUserData() async {
//     try {
//       final token = localStorage.getItem('accessToken');
      
//       // Fetch personal info
//       final personalResponse = await http.get(
//         Uri.parse('https://cash.imvj.one/api/v1/users/me'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );

//       if (personalResponse.statusCode == 200) {
//         final personalData = json.decode(personalResponse.body);
//         if (personalData['success'] == true) {
//           final user = personalData['data']['user'];
//           setState(() {
//             _fullNameController.text = user['fullname'] ?? '';
//             _emailController.text = user['email'] ?? '';
//             _phoneController.text = user['phoneNumber'] ?? '';
//             _pancardController.text = user['pancardNumber'] ?? '';
//             _pinCodeController.text = user['pinCode'] ?? '';
//             _maritalStatusController.text = user['maritalStatus'] ?? '';
//             gender = user['gender']?.toLowerCase() ?? '';
//             if (user['dateOfBirth'] != null) {
//               final dobParsed = DateTime.parse(user['dateOfBirth']);
//               _dobController.text = DateFormat('dd/MM/yyyy').format(dobParsed);
//             }
//           });
//         }
//       }
      
//       // Fetch employment info
//       final employmentResponse = await http.get(
//         Uri.parse('https://cash.imvj.one/api/v1/employment-details/'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );

//       if (employmentResponse.statusCode == 200) {
//         final employmentData = json.decode(employmentResponse.body);
//         if (employmentData['success'] == true && employmentData['data'] != null) {
//           setState(() {
//             hasEmploymentData = true;
//             _netMonthlyIncomeController.text = employmentData['data']['netMonthlyIncome']?.toString() ?? '';
//             _companyNameController.text = employmentData['data']['companyOrBusinessName'] ?? '';
//             _companyPinCodeController.text = employmentData['data']['companyPinCode'] ?? '';
//             _salarySlipDocument = employmentData['data']['salarySlipDocument'] ?? '';
//           });
//         }
//       }
//     } catch (e) {
//       _showSnackbar('Failed to fetch user data');
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   Future<void> _updatePersonalInfo() async {
//     try {
//       final token = localStorage.getItem('accessToken');
//       final response = await http.put(
//         Uri.parse('https://cash.imvj.one/api/v1/users/me'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: json.encode({
//           'fullName': _fullNameController.text,
//           'email': _emailController.text,
//           'pancardNumber': _pancardController.text,
//           'pinCode': _pinCodeController.text,
//           'dateOfBirth': DateFormat('yyyy-MM-dd').format(
//             DateFormat('dd/MM/yyyy').parse(_dobController.text),
//           ),
//           'gender': gender,
//         }),
//       );

//       if (response.statusCode == 200) {
//         _showSnackbar('Profile updated successfully');
//         setState(() {
//           isPersonalInfoEditing = false;
//         });
//       } else {
//         _showSnackbar('Failed to update profile');
//       }
//     } catch (e) {
//       _showSnackbar('Error while updating profile');
//     }
//   }

//   Future<void> _updateEmploymentInfo() async {
//     try {
//       final token = localStorage.getItem('accessToken');
//       final url = Uri.parse('https://cash.imvj.one/api/v1/employment-details/');
      
//       final response =  await http.put(
//               url,
//               headers: {
//                 'Content-Type': 'application/json',
//                 'Authorization': 'Bearer $token',
//               },
//               body: json.encode({
//                 'netMonthlyIncome': int.tryParse(_netMonthlyIncomeController.text) ?? 0,
//                 'companyOrBusinessName': _companyNameController.text,
//                 'companyPinCode': _companyPinCodeController.text,
//                 'salarySlipDocument': _salarySlipDocument,
//               }),
//             );

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         _showSnackbar('Employment details updated successfully');
//         setState(() {
//           isEmploymentInfoEditing = false;
//           hasEmploymentData = true;
//         });
//       } else {
//         _showSnackbar('Failed to update employment details');
//       }
//     } catch (e) {
//       _showSnackbar('Error while updating employment details');
//     }
//   }

//   Future<void> _pickSalarySlip() async {
//     try {
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
//       );

//       if (result != null) {
//         setState(() {
//           _salarySlipDocument = result.files.single.name;
//         });
//       }
//     } catch (e) {
//       _showSnackbar('Error picking file');
//     }
//   }

//   void _showSnackbar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
//   }

//   Widget buildInfoRow(String label, TextEditingController controller, {bool isNumber = false}) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey.shade400),
//         borderRadius: BorderRadius.circular(6),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label, style: const TextStyle(fontSize: 13)),
//           SizedBox(
//             width: 150,
//             child: TextField(
//               controller: controller,
//               keyboardType: isNumber ? TextInputType.number : TextInputType.text,
//               style: const TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w600,
//               ),
//               decoration: const InputDecoration(
//                 isDense: true,
//                 contentPadding: EdgeInsets.zero,
//                 border: InputBorder.none,
//               ),
//               textAlign: TextAlign.right,
//               enabled: _tabController.index == 0 ? isPersonalInfoEditing : isEmploymentInfoEditing,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPersonalInfoTab() {
//     return Column(
//       children: [
//         Stack(
//           children: [
//             Container(
//               width: 60,
//               height: 60,
//               decoration: const BoxDecoration(
//                 shape: BoxShape.circle,
//                 gradient: LinearGradient(
//                   colors: [
//                     Color(0xFF5C93B6),
//                     Color(0xFF003366),
//                   ],
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                 ),
//               ),
//               alignment: Alignment.center,
//               child: Text(
//                 _fullNameController.text.isNotEmpty
//                     ? _fullNameController.text[0].toUpperCase()
//                     : '',
//                 style: const TextStyle(
//                   fontSize: 24,
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             Positioned(
//               right: 0,
//               bottom: 0,
//               child: CircleAvatar(
//                 radius: 12,
//                 backgroundColor: const Color(0xFF5189A3),
//                 child: const Icon(Icons.edit,
//                     size: 14, color: Colors.white),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         Text(_fullNameController.text,
//             style: const TextStyle(
//                 fontWeight: FontWeight.w600, fontSize: 15)),
//         Text(
//           gender.isNotEmpty
//               ? gender[0].toUpperCase() + gender.substring(1)
//               : '',
//           style: const TextStyle(color: Colors.grey, fontSize: 13),
//         ),
//         const SizedBox(height: 16),
//         buildInfoRow('Full Name', _fullNameController),
//         buildInfoRow('Email ID', _emailController),
//         buildInfoRow('Phone Number', _phoneController, isNumber: true),
//         buildInfoRow('DOB', _dobController),
//         buildInfoRow('Pan Card', _pancardController),
//         buildInfoRow('Pin Code', _pinCodeController, isNumber: true),
//       ],
//     );
//   }

//  Widget _buildEmploymentInfoTab() {
//   return Stack(
//     children: [
//       Column(
//         children: [
//           const SizedBox(height: 40), // Space for the edit button
//           buildInfoRow('Net Monthly Income', _netMonthlyIncomeController, isNumber: true),
//           buildInfoRow('Company/Business Name', _companyNameController),
//           buildInfoRow('Company Pin Code', _companyPinCodeController, isNumber: true),
//           Container(
//             margin: const EdgeInsets.only(bottom: 8),
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey.shade400),
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text('Salary Slip Document', style: TextStyle(fontSize: 13)),
//                 if (isEmploymentInfoEditing)
//                   TextButton(
//                     onPressed: _pickSalarySlip,
//                     child: const Text('Upload', style: TextStyle(fontSize: 13)),
//                   )
//                 else
//                   Row(
//                     children: [
//                       if (_salarySlipDocument.isNotEmpty)
//                         IconButton(
//                           icon: const Icon(Icons.visibility, size: 20, color: Color(0xFF003366)),
//                           onPressed: () {
//                             // Show dialog with the document URL
//                             showDialog(
//                               context: context,
//                               builder: (context) => AlertDialog(
//                                 title: const Text('Salary Slip Document'),
//                                 content: Text(_salarySlipDocument),
//                                 actions: [
//                                   TextButton(
//                                     onPressed: () => Navigator.pop(context),
//                                     child: const Text('Close'),
//                                   ),
//                                   TextButton(
//                                     onPressed: () {
//                                       // Open the URL in browser
//                                       // You'll need to import 'url_launcher' package
//                                       // launchUrl(Uri.parse(_salarySlipDocument));
//                                       Navigator.pop(context);
//                                     },
//                                     child: const Text('Open'),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           },
//                         )
//                       else
//                         const Text(
//                           'Not uploaded',
//                           style: TextStyle(
//                             fontSize: 13,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                     ],
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       if (!isEmploymentInfoEditing)
//         Positioned(
//           top: 0,
//           right: 0,
//           child: IconButton(
//             icon: const Icon(Icons.edit, color: Color(0xFF003366)),
//             onPressed: () {
//               setState(() {
//                 isEmploymentInfoEditing = true;
//               });
//             },
//           ),
//         ),
//     ],
//   );
// }

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Center(
//                 child: Image.network(
//                   'http://www.cashmateonline.com/wp-content/uploads/2023/10/Cashmate-logo.jpg',
//                   width: 120,
//                   height: 60,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               const Text('Start your Loan Journey Today',
//                   style: TextStyle(fontSize: 13)),
//               const SizedBox(height: 24),
//               const Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   'My Profile',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 12),

//               // Tab Bar
//               Container(
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey.shade300),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Column(
//                   children: [
//                     TabBar(
//                       controller: _tabController,
//                       labelColor: const Color(0xFF003366),
//                       unselectedLabelColor: Colors.grey,
//                       indicator: const UnderlineTabIndicator(
//                         borderSide: BorderSide(
//                           width: 2.0,
//                           color: Color(0xFF003366),
//                         ),
//                       ),
//                       tabs: const [
//                         Tab(text: 'Personal Information'),
//                         Tab(text: 'Employment Information'),
//                       ],
//                     ),
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       child: SizedBox(
//                         height: 400,
//                         child: TabBarView(
//                           controller: _tabController,
//                           children: [
//                             _buildPersonalInfoTab(),
//                             _buildEmploymentInfoTab(),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 16),

//               // Edit/Save button - shows different buttons based on active tab
//               if (_tabController.index == 0)
//                 ElevatedButton(
//                   onPressed: () {
//                     if (isPersonalInfoEditing) {
//                       _updatePersonalInfo();
//                     } else {
//                       setState(() {
//                         isPersonalInfoEditing = true;
//                       });
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF003366),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     minimumSize: const Size(double.infinity, 50),
//                   ),
//                   child: Text(
//                     isPersonalInfoEditing ? 'Save Personal Info' : 'Edit Personal Info',
//                     style: const TextStyle(color: Colors.white),
//                   ),
//                 )
//               else
//                 ElevatedButton(
//                   onPressed: () {
//                     if (isEmploymentInfoEditing) {
//                       _updateEmploymentInfo();
//                     } else {
//                       setState(() {
//                         isEmploymentInfoEditing = true;
//                       });
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF003366),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     minimumSize: const Size(double.infinity, 50),
//                   ),
//                   child: Text(
//                     isEmploymentInfoEditing ? 'Save Employment Info' : 'Edit Employment Info',
//                     style: const TextStyle(color: Colors.white),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _fullNameController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     _dobController.dispose();
//     _pancardController.dispose();
//     _pinCodeController.dispose();
//     _maritalStatusController.dispose();
//     _netMonthlyIncomeController.dispose();
//     _companyNameController.dispose();
//     _companyPinCodeController.dispose();
//     super.dispose();
//   }
// }