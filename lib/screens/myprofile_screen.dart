import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';



class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _pancardController = TextEditingController();
  final _pinCodeController = TextEditingController();
  final _maritalStatusController = TextEditingController();



  String gender = '';
  bool isLoading = true;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final token = localStorage.getItem('accessToken');
      final response = await http.get(
        Uri.parse('http://localhost:8085/api/v1/users/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final user = data['data']['user'];
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
    } catch (e) {
      _showSnackbar('Failed to fetch user data');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

 Future<void> _updateUserData() async {
  try {
    final token = localStorage.getItem('accessToken');
    final response = await http.put(
      Uri.parse('http://localhost:8085/api/v1/users/me'),
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
// <-- added
}),

    );

    if (response.statusCode == 200) {
      _showSnackbar('Profile updated successfully');
      setState(() {
        isEditing = false;
      });
    } else {
      _showSnackbar('Failed to update profile');
    }
  } catch (e) {
    _showSnackbar('Error while updating profile');
  }
}

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

Widget buildInfoRow(String label, TextEditingController controller) {
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade400),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13)),
        isEditing
            ? SizedBox(
                width: 150,
                child: TextField(
                  controller: controller,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                  ),
                  textAlign: TextAlign.right,
                ),
              )
            : Text(
                controller.text,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Image.network(
                  'https://www.cashmateonline.com/wp-content/uploads/2023/10/Cashmate-logo.jpg',
                  width: 120,
                  height: 60,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 8),
              const Text('Start your Loan Journey Today',
                  style: TextStyle(fontSize: 13)),
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'My Profile',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Profile Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF5C93B6),
                                Color(0xFF003366),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _fullNameController.text.isNotEmpty
                                ? _fullNameController.text[0].toUpperCase()
                                : '',
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: const Color(0xFF5189A3),
                            child: const Icon(Icons.edit,
                                size: 14, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(_fullNameController.text,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                    Text(
                      gender.isNotEmpty
                          ? gender[0].toUpperCase() + gender.substring(1)
                          : '',
                      style:
                          const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Personal Info Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Personal Information',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                        GestureDetector(
                          onTap: () {
                            if (isEditing) {
                              _updateUserData();
                            } else {
                              setState(() {
                                isEditing = true;
                              });
                            }
                          },
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: const Color(0xFF5189A3),
                            child: Icon(
                              isEditing ? Icons.save : Icons.edit,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  buildInfoRow('Full Name', _fullNameController),
buildInfoRow('Email ID', _emailController),
buildInfoRow('Phone Number', _phoneController),
buildInfoRow('DOB', _dobController),
buildInfoRow('Pan Card', _pancardController),
buildInfoRow('Pin Code', _pinCodeController),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
