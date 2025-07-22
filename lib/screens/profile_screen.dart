import 'dart:convert';
import 'package:Cashmate/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:file_picker/file_picker.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen>
    with SingleTickerProviderStateMixin {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _pancardController = TextEditingController();
  final _pinCodeController = TextEditingController();
  final _maritalStatusController = TextEditingController();

  // Employment details controllers
  final _netMonthlyIncomeController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _companyPinCodeController = TextEditingController();
  String _salarySlipDocument = '';

  String gender = '';
  bool isLoading = true;
  bool isPersonalInfoEditing = false;
  bool isEmploymentInfoEditing = false;
  bool hasEmploymentData = false;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final token = localStorage.getItem('accessToken');

      // Fetch personal info
      final personalResponse = await http.get(
        Uri.parse('https://cash.imvj.one/api/v1/users/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (personalResponse.statusCode == 200) {
        final personalData = json.decode(personalResponse.body);
        if (personalData['success'] == true) {
          final user = personalData['data']['user'];
          setState(() {
            _fullNameController.text = user['fullname'] ?? '';
            _emailController.text = user['email'] ?? '';
            _phoneController.text = user['phoneNumber'] ?? '';
            _pancardController.text = user['pancardNumber'] ?? '';
            _pinCodeController.text = user['pinCode'] ?? '';
            _maritalStatusController.text = user['maritalStatus'] ?? '';
            gender = user['gender']?.toLowerCase() ?? '';
            if (user['dateOfBirth'] != null) {
              final dobParsed = DateTime.parse(user['dateOfBirth']);
              _dobController.text = DateFormat('dd/MM/yyyy').format(dobParsed);
            }
          });
        }
      }

      // Fetch employment info
      final employmentResponse = await http.get(
        Uri.parse('https://cash.imvj.one/api/v1/employment-details/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (employmentResponse.statusCode == 200) {
        final employmentData = json.decode(employmentResponse.body);
        if (employmentData['success'] == true &&
            employmentData['data'] != null) {
          setState(() {
            hasEmploymentData = true;
            _netMonthlyIncomeController.text =
                employmentData['data']['netMonthlyIncome']?.toString() ?? '';
            _companyNameController.text =
                employmentData['data']['companyOrBusinessName'] ?? '';
            _companyPinCodeController.text =
                employmentData['data']['companyPinCode'] ?? '';
            _salarySlipDocument =
                employmentData['data']['salarySlipDocument'] ?? '';
          });
        }
      }
    } catch (e) {
      _showSnackbar('Failed to fetch user data');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updatePersonalInfo() async {
    try {
      final token = localStorage.getItem('accessToken');
      final response = await http.put(
        Uri.parse('https://cash.imvj.one/api/v1/users/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'fullName': _fullNameController.text,
          'email': _emailController.text,
          'pancardNumber': _pancardController.text,
          'pinCode': _pinCodeController.text,
          'dateOfBirth': DateFormat('yyyy-MM-dd').format(
            DateFormat('dd/MM/yyyy').parse(_dobController.text),
          ),
          'gender': gender,
        }),
      );

      if (response.statusCode == 200) {
        _showSnackbar('Profile updated successfully');
        setState(() {
          isPersonalInfoEditing = false;
        });
      } else {
        _showSnackbar('Failed to update profile');
      }
    } catch (e) {
      _showSnackbar('Error while updating profile');
    }
  }

   Future<void> _updateEmploymentInfo() async {
    try {
      final token = localStorage.getItem('accessToken');
      final url =
          Uri.parse('https://cash.imvj.one/api/v1/employment-details/');

      final response = hasEmploymentData
          ? await http.put(
              url,
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
              body: json.encode({
                'netMonthlyIncome':
                    int.tryParse(_netMonthlyIncomeController.text) ?? 0,
                'companyOrBusinessName': _companyNameController.text,
                'companyPinCode': _companyPinCodeController.text,
                'salarySlipDocument': _salarySlipDocument,
              }),
            )
          : await http.post(
              url,
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
              body: json.encode({
                'netMonthlyIncome':
                    int.tryParse(_netMonthlyIncomeController.text) ?? 0,
                'companyOrBusinessName': _companyNameController.text,
                'companyPinCode': _companyPinCodeController.text,
                'salarySlipDocument': _salarySlipDocument,
              }),
            );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackbar('Employment details updated successfully');
        setState(() {
          isEmploymentInfoEditing = false;
          hasEmploymentData = true;
        });
      } else {
        print(response);
        _showSnackbar('Failed to update employment details');
      }
    } catch (e) {
      _showSnackbar('Error while updating employment details');
    }
  }

  Future<void> _pickSalarySlip() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
      );

      if (result != null) {
        setState(() {
          _salarySlipDocument = result.files.single.name;
        });
      }
    } catch (e) {
      _showSnackbar('Error picking file');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _modernInfoTile({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    bool isNumber = false,
    bool enabled = false,
    double fontSize = 13,
    EdgeInsetsGeometry margin = const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
    void Function(String)? onChanged,
  }) {
    return Card(
      margin: margin,
      color: Colors.white, // white background
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(color: Colors.black), // black border
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF003366), size: fontSize + 2),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                keyboardType: isNumber ? TextInputType.number : TextInputType.text,
                style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: TextStyle(fontSize: fontSize - 1, color: Colors.grey[700]),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modernProfileHeader(double screenWidth) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 8),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFF5C93B6),
                child: Text(
                  _fullNameController.text.isNotEmpty
                      ? _fullNameController.text[0].toUpperCase()
                      : '',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Positioned(
              //   bottom: 0,
              //   right: 0,
              //   child: GestureDetector(
              //     onTap: () {},
              //     child: Container(
              //       decoration: BoxDecoration(
              //         color: Colors.white,
              //         shape: BoxShape.circle,
              //         boxShadow: [
              //           BoxShadow(
              //             color: Colors.black.withOpacity(0.08),
              //             blurRadius: 2,
              //           ),
              //         ],
              //       ),
              //       padding: const EdgeInsets.all(2),
              //       child: const Icon(Icons.edit, size: 14, color: Color(0xFF003366)),
              //     ),
              //   ),
              // ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _fullNameController.text,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  gender.isNotEmpty
                      ? gender[0].toUpperCase() + gender.substring(1)
                      : '',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Replace the logout IconButton with a TextButton.icon
          TextButton.icon(
            onPressed: () async {
              localStorage.clear();
              if (!mounted) return;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            icon: const Icon(Icons.logout, color: Color(0xFF003366), size: 20),
            label: const Text(
              'Logout',
              style: TextStyle(
                color: Color(0xFF003366),
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF003366),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              minimumSize: Size(0, 36),
            ),
          ),
        ],
      ),
    );
  }

  Widget _modernTabBar(double screenWidth) {
    // Custom indicator for pill effect, expands to half the TabBar width
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF003366),
        indicator: BoxDecoration(
          color: const Color(0xFF003366),
          borderRadius: BorderRadius.circular(20),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: [
          SizedBox(
            width: screenWidth * 0.5 * 0.9, // half of tab bar, minus margin
            child: const Tab(text: 'Personal'),
          ),
          SizedBox(
            width: screenWidth * 0.5 * 0.9,
            child: const Tab(text: 'Employment'),
          ),
        ],
      ),
    );
  }

  Widget _modernPersonalInfoTab(double screenWidth) {
    const fontSize = 13.0;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _modernInfoTile(
            icon: Icons.person,
            label: 'Full Name',
            controller: _fullNameController,
            enabled: false,
            fontSize: fontSize,
            margin: EdgeInsets.only(top: 0, bottom: 6), // No top margin for first card
          ),
          _modernInfoTile(
            icon: Icons.email,
            label: 'Email',
            controller: _emailController,
            enabled: false,
            fontSize: fontSize,
          ),
          _modernInfoTile(
            icon: Icons.phone,
            label: 'Phone Number',
            controller: _phoneController,
            isNumber: true,
            enabled: false,
            fontSize: fontSize,
          ),
          _modernInfoTile(
            icon: Icons.cake,
            label: 'DOB',
            controller: _dobController,
            enabled: false,
            fontSize: fontSize,
          ),
          _modernInfoTile(
            icon: Icons.credit_card,
            label: 'Pan Card',
            controller: _pancardController,
            enabled: false,
            fontSize: fontSize,
          ),
          _modernInfoTile(
            icon: Icons.pin,
            label: 'Pin Code',
            controller: _pinCodeController,
            isNumber: true,
            enabled: false,
            fontSize: fontSize,
          ),
          // No edit/save button for personal info
        ],
      ),
    );
  }

  Widget _modernEmploymentInfoTab(double screenWidth) {
    final fontSize = 13.0;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _modernInfoTile(
            icon: Icons.monetization_on,
            label: 'Net Monthly Income',
            controller: _netMonthlyIncomeController,
            isNumber: true,
            enabled: isEmploymentInfoEditing,
            fontSize: fontSize,
          ),
          _modernInfoTile(
            icon: Icons.business,
            label: 'Company/Business Name',
            controller: _companyNameController,
            enabled: isEmploymentInfoEditing,
            fontSize: fontSize,
          ),
          _modernInfoTile(
            icon: Icons.location_on,
            label: 'Company Pin Code',
            controller: _companyPinCodeController,
            isNumber: true,
            enabled: isEmploymentInfoEditing,
            fontSize: fontSize,
          ),
          Card(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
            elevation: 1.5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.file_present, color: Color(0xFF003366), size: 15),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _salarySlipDocument.isNotEmpty
                          ? _salarySlipDocument
                          : 'No document uploaded',
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                        color: _salarySlipDocument.isNotEmpty
                            ? Colors.black
                            : Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isEmploymentInfoEditing)
                    TextButton.icon(
                      onPressed: _pickSalarySlip,
                      icon: const Icon(Icons.upload_file, size: 15),
                      label: const Text('Upload', style: TextStyle(fontSize: 12)),
                    )
                  else if (_salarySlipDocument.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.visibility, color: Color(0xFF003366), size: 15),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Salary Slip Document'),
                            content: Text(_salarySlipDocument),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              icon: Icon(isEmploymentInfoEditing ? Icons.save : Icons.edit, size: 16, color: Colors.white,),
              label: Text(
                isEmploymentInfoEditing ? 'Save' : 'Edit',
                style: const TextStyle(fontSize: 13, color: Colors.white), // white text
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003366), // blue button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                minimumSize: const Size(0, 32),
              ),
              onPressed: () {
                if (isEmploymentInfoEditing) {
                  _updateEmploymentInfo();
                } else {
                  setState(() {
                    isEmploymentInfoEditing = true;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : LayoutBuilder(
                builder: (context, constraints) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: [
                        // Add logo at the top
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Image.asset(
                              'assets/image/Cashmate-logo.jpg',
                              width: isSmallScreen ? screenWidth * 0.9 : 240,
                              height: isSmallScreen ? 80 : 100,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        _modernProfileHeader(screenWidth),
                        _modernTabBar(screenWidth),
                        // Removed SizedBox(height: 8),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _modernPersonalInfoTab(screenWidth),
                              _modernEmploymentInfoTab(screenWidth),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _pancardController.dispose();
    _pinCodeController.dispose();
    _maritalStatusController.dispose();
    _netMonthlyIncomeController.dispose();
    _companyNameController.dispose();
    _companyPinCodeController.dispose();
    super.dispose();
  }
}
