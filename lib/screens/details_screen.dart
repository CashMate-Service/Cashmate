import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/bottom_navigation_widget.dart';
import '../utils/app_colors.dart';
import 'employment_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/show_snackbar.dart';

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
  final TextEditingController _loanAmountController = TextEditingController();

  String selectedGender = '';
  String selectedEmploymentType = '';
  String? phoneNumber;
  bool isLoading = true;
  bool isSubmitting = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }
      final token=localStorage.getItem('accessToken');

  Future<void> _fetchUserData() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8085/api/v1/users/me'),
 headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final user = data['data']['user'];
          setState(() {
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
          });
        }
      }
    } catch (e) {
      showSnackbar(context, 'Failed to fetch user data');
    } finally {
      setState(() {
        isLoading = false;
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
    if (value == null || value.isEmpty) {
      return 'Full name is required';
    }
    if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
      return 'Only letters and spaces are allowed';
    }
    return null;
  }

  String? _validateDOB(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date of birth is required';
    }
    try {
      final dob = DateFormat('dd/MM/yyyy').parse(value);
      final now = DateTime.now();
      final age = now.year - dob.year;
      if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
        if (age - 1 < 18) {
          return 'You must be at least 18 years old';
        }
      } else if (age < 18) {
        return 'You must be at least 18 years old';
      }
      if (dob.isAfter(now)) {
        return 'Date cannot be in the future';
      }
    } catch (e) {
      return 'Invalid date format (DD/MM/YYYY)';
    }
    return null;
  }

  String? _validatePanCard(String? value) {
    if (value == null || value.isEmpty) {
      return 'PAN card number is required';
    }
    if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(value.toUpperCase())) {
      return 'Invalid PAN card format (e.g., ABCDE1234F)';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Invalid email format';
    }
    return null;
  }

  String? _validatePincode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Pincode is required';
    }
    if (!RegExp(r'^[1-9][0-9]{5}$').hasMatch(value)) {
      return 'Invalid Indian pincode (6 digits, no leading zero)';
    }
    return null;
  }

  String? _validateLoanAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Loan amount is required';
    }
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Invalid number';
    }
    if (amount < 1000) {
      return 'Minimum amount is ₹1000';
    }
    if (amount > 1000000) {
      return 'Maximum amount is ₹10,00,000';
    }
    return null;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedGender.isEmpty) {
      showSnackbar(context, 'Please select gender');
      return;
    }

    if (selectedEmploymentType.isEmpty) {
      showSnackbar(context, 'Please select employment type');
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final dob = DateFormat('dd/MM/yyyy').parse(_dobController.text);
      final formattedDob = DateFormat('yyyy-MM-dd').format(dob);

      final response = await http.post(
        Uri.parse('http://localhost:8085/api/v1/loan/request'),
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
          "employmentType": selectedEmploymentType.toLowerCase(),
          "desiredAmount": double.parse(_loanAmountController.text),
          "phoneNumber": phoneNumber,
        }),
      );

      final responseData = json.decode(response.body);
      if (response.statusCode == 200 && responseData['success'] == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const EmploymentScreen(),
          ),
        );
      } else {
        showSnackbar(context, responseData['message'] ?? 'Submission failed');
      }
    } catch (e) {
      showSnackbar(context, 'An error occurred. Please try again.');
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  Center(
                    child: Image.network(
                      'https://www.cashmateonline.com/wp-content/uploads/2023/10/Cashmate-logo.jpg',
                      width: 120,
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'Start Your Loan Journey Today',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Instant Loan Application',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Gender *',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedGender.isEmpty ? null : selectedGender,
                                  hint: const Padding(
                                    padding: EdgeInsets.only(left: 12),
                                    child: Text('Select Gender'),
                                  ),
                                  items: ['Male', 'Female', 'Other']
                                      .map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value.toLowerCase(),
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 12),
                                        child: Text(value),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedGender = newValue ?? '';
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Pancard',
                          placeholder: 'Enter pancard number (e.g., ABCDE1234F)',
                          controller: _pancardController,
                          validator: _validatePanCard,
                          isRequired: true,
                          textCapitalization: TextCapitalization.characters,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Email Address',
                          placeholder: 'Enter your email',
                          controller: _emailController,
                          validator: _validateEmail,
                          keyboardType: TextInputType.emailAddress,
                          isRequired: true,
                          suffixIcon: const Icon(Icons.email, size: 20),
                          readOnly: _emailController.text.isNotEmpty,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Pincode',
                          placeholder: 'Enter 6 digit pincode',
                          controller: _pincodeController,
                          validator: _validatePincode,
                          keyboardType: TextInputType.number,
                          isRequired: true,
                          suffixIcon: const Icon(Icons.location_on, size: 20),
                        ),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Employment Type *',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedEmploymentType.isEmpty ? null : selectedEmploymentType,
                                  hint: const Padding(
                                    padding: EdgeInsets.only(left: 12),
                                    child: Text('Select employment type'),
                                  ),
                                  items: ['Salaried', 'Self Employed', 'Business']
                                      .map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value.toLowerCase().replaceAll(' ', '_'),
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 12),
                                        child: Text(value),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedEmploymentType = newValue ?? '';
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Desired Loan Amount',
                          placeholder: 'Enter your desired loan amount (₹1000-₹10,00,000)',
                          controller: _loanAmountController,
                          validator: _validateLoanAmount,
                          keyboardType: TextInputType.number,
                          isRequired: true,
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(left: 12, top: 12),
                            child: Text('₹', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                        const SizedBox(height: 32),
               CustomButton(
  text: 'Continue',
  onPressed: () => _submitForm(),
  isLoading: isSubmitting,
),

                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavigationWidget(currentIndex: 0),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _dobController.dispose();
    _pancardController.dispose();
    _emailController.dispose();
    _pincodeController.dispose();
    _loanAmountController.dispose();
    super.dispose();
  }
}