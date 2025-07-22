import 'package:Cashmate/screens/main_screen.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../utils/app_colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


import '../utils/show_snackbar.dart';
import 'package:lottie/lottie.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _pancardController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  String selectedGender = '';
  String? phoneNumber;
  bool isLoading = true;
  bool isSubmitting = false;
  bool showPhoneField = false;
  bool showVerifyButton = false;
  bool showOtpField = false;
  bool isPhoneVerified = false;
  bool isVerifyingOtp = false;
  bool isSendingOtp = false;
  String? verifiedPhoneNumber;
  String otpError = '';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _startWithSplash();
    _phoneController.addListener(_onPhoneChanged);
  }

  void _onPhoneChanged() {
    setState(() {
      showVerifyButton = _phoneController.text.length == 10 &&
          RegExp(r'^[0-9]+').hasMatch(_phoneController.text);
      showOtpField = false;
      otpError = '';
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _dobController.dispose();
    _pancardController.dispose();
    _emailController.dispose();
    _pincodeController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _startWithSplash() async {
    await Future.wait([
      Future.delayed(const Duration(seconds: 3)), // Show Lottie at least 2s
      _fetchUserData(),
    ]);
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchUserData() async {
    try {
      final token = localStorage.getItem('accessToken');
      final response = await http.get(
        Uri.parse('https://cash.imvj.one/api/v1/users/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final user = data['data']['user'];
          _fullNameController.text = user['fullname'] ?? '';
          if (user['dateOfBirth'] != null) {
            final dob = DateTime.parse(user['dateOfBirth']);
            _dobController.text = DateFormat('dd/MM/yyyy').format(dob);
          }
          selectedGender = user['gender']?.toLowerCase() ?? '';
          _pancardController.text = user['pancardNumber'] ?? '';
          _emailController.text = user['email'] ?? '';
          _pincodeController.text = user['pinCode'] ?? '';
          phoneNumber = user['phoneNumber'];
          // Show phone field if email exists and phoneNumber is null
          showPhoneField = _emailController.text.isNotEmpty &&
              (phoneNumber == null || phoneNumber!.isEmpty);
        }
      }
    } catch (e) {
      showSnackbar(context, 'Failed to fetch user data');
    }
  }

  Future<void> _sendOtp() async {
    setState(() {
      isSendingOtp = true;
    });
    try {
      final token = localStorage.getItem('accessToken');
      final response = await http.post(
        Uri.parse('https://cash.imvj.one/api/v1/users/change-phone/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(<String, String>{
          'phoneNumber': _phoneController.text,
        }),
      );
      if (response.statusCode == 200) {
        setState(() {
          showOtpField = true;
          otpError = '';
        });
        showSnackbar(context, 'OTP sent to your number');
      } else {
        showSnackbar(context, 'Oops! That phone number is already taken');
      }
    } catch (e) {
      showSnackbar(context, 'Error sending OTP: $e');
    } finally {
      setState(() {
        isSendingOtp = false;
      });
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length != 6) {
      setState(() {
        otpError = 'Enter 6 digit OTP';
      });
      return;
    }
    setState(() {
      isVerifyingOtp = true;
    });
    try {
      final token = localStorage.getItem('accessToken');
      final response = await http.put(
        Uri.parse('https://cash.imvj.one/api/v1/users/change-phone/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({
          'phoneNumber': _phoneController.text,
          'otp': _otpController.text,
        }),
      );
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 && responseData['success'] == true) {
        setState(() {
          isPhoneVerified = true;
          verifiedPhoneNumber = _phoneController.text;
          showOtpField = false;
        });
        showSnackbar(context, 'Phone number verified!');
      } else {
        setState(() {
          otpError = responseData['message'] ?? 'OTP verification failed';
        });
      }
    } catch (e) {
      setState(() {
        otpError = 'An error occurred. Please try again.';
      });
    } finally {
      setState(() {
        isVerifyingOtp = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  String? _validateFullName(String? value) {
    if (value == null || value.isEmpty) return 'Full name is required';
    if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
      return 'Only letters and spaces allowed';
    }
    return null;
  }

  String? _validateDOB(String? value) {
  if (value == null || value.isEmpty) return 'Date of birth is required';
  try {
    final dob = DateFormat('dd/MM/yyyy').parse(value);
    final now = DateTime.now();
    final age = now.year - dob.year;

    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      if (age - 1 < 21) return 'You must be at least 21 years old';
    } else if (age < 21) return 'You must be at least 21 years old';

    if (dob.isAfter(now)) return 'Date cannot be in the future';
  } catch (e) {
    return 'Invalid date format (DD/MM/YYYY)';
  }
  return null;
}

  String? _validatePanCard(String? value) {
    if (value == null || value.isEmpty) return 'PAN card number is required';
    if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(value.toUpperCase())) {
      return 'Invalid PAN card format (e.g., ABCDE1234F)';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Invalid email format';
    }
    return null;
  }

  String? _validatePincode(String? value) {
    if (value == null || value.isEmpty) return 'Pincode is required';
    if (!RegExp(r'^[1-9][0-9]{5}$').hasMatch(value)) {
      return 'Invalid Indian pincode';
    }
    return null;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (showPhoneField &&
        (!isPhoneVerified || verifiedPhoneNumber != _phoneController.text)) {
      showSnackbar(context, 'Please verify your phone number');
      return;
    }
    setState(() => isSubmitting = true);

    try {
      final token = localStorage.getItem('accessToken');
      final dob = DateFormat('dd/MM/yyyy').parse(_dobController.text);
      final formattedDob = DateFormat('yyyy-MM-dd').format(dob);
      final phoneToSubmit =
          showPhoneField ? _phoneController.text : phoneNumber;

      final response = await http.put(
        Uri.parse('https://cash.imvj.one/api/v1/users/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          "fullName": _fullNameController.text,
          "dateOfBirth": formattedDob,
          "gender": selectedGender.toLowerCase(),
          "pancardNumber": _pancardController.text.toUpperCase(),
          "email": _emailController.text,
          "pinCode": _pincodeController.text,
          "phoneNumber": phoneToSubmit,
        }),
      );

      final responseData = json.decode(response.body);
      if (response.statusCode == 200 && responseData['success'] == true) {
        if (mounted) {
          showSnackbar(context, 'Submitted successfully!');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const MainScreen(),
            ),
          );
        }
      } else {
        showSnackbar(context, responseData['message'] ?? 'Submission failed');
      }
    } catch (e) {
      showSnackbar(context, 'An error occurred. Please try again.');
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Lottie.asset(
            'assets/lottie/Money.json',
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Image.asset(
                  'assets/image/Cashmate-logo.jpg',
                  height: 120,
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  label: 'Full Name',
                  placeholder: 'Enter your full name',
                  controller: _fullNameController,
                  validator: _validateFullName,
                  isRequired: true,
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: CustomTextField(
                      label: 'Date of Birth',
                      placeholder: 'Select date of birth',
                      controller: _dobController,
                      validator: _validateDOB,
                      isRequired: true,
                      suffixIcon: const Icon(Icons.calendar_today, size: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedGender.isNotEmpty ? selectedGender : null,
                  decoration: const InputDecoration(
                    labelText: 'Gender *',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Male', 'Female', 'Other']
                      .map((e) => DropdownMenuItem(
                            value: e.toLowerCase(),
                            child: Text(e),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => selectedGender = value ?? '');
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your gender';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'PAN Card',
                  placeholder: 'ABCDE1234F',
                  controller: _pancardController,
                  validator: _validatePanCard,
                  isRequired: true,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Email',
                  placeholder: 'Enter email',
                  controller: _emailController,
                  validator: _validateEmail,
                  isRequired: true,
                ),
                const SizedBox(height: 16),
                if (showPhoneField) ...[
                  CustomTextField(
                    label: 'Phone Number',
                    placeholder: 'Enter phone number',
                    controller: _phoneController,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Phone number is required';
                      if (!RegExp(r'^[0-9]{10}').hasMatch(value))
                        return 'Enter valid 10 digit number';
                      return null;
                    },
                    isRequired: true,
                    keyboardType: TextInputType.number,
                    suffixIcon: isPhoneVerified
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                  ),
                  if (!isPhoneVerified && showVerifyButton)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: isSendingOtp ? null : _sendOtp,
                          child: isSendingOtp
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Verify'),
                        ),
                      ),
                    ),
                  if (showOtpField && !isPhoneVerified)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextField(
                            label: 'Enter OTP',
                            placeholder: '6 digit code',
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            isRequired: true,
                          ),
                          if (otpError.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(otpError,
                                  style: const TextStyle(color: Colors.red)),
                            ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: isVerifyingOtp ? null : _verifyOtp,
                              child: isVerifyingOtp
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2))
                                  : const Text('Verify OTP'),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Pincode',
                  placeholder: 'Enter pincode',
                  controller: _pincodeController,
                  validator: _validatePincode,
                  isRequired: true,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Continue',
                  onPressed: _submitForm,
                  isLoading: isSubmitting,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
