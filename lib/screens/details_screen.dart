import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/bottom_navigation_widget.dart';
import '../utils/app_colors.dart';
import 'employment_screen.dart';

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
              primary: AppColors.primary, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
            dialogBackgroundColor: Colors.white, // Background color
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                // Logo
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

                // 📦 Box with shadow for the form
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
                            keyboardType: TextInputType.datetime,
                            isRequired: true,
                            suffixIcon: const Icon(Icons.calendar_today, size: 20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Gender Dropdown
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
                                    value: value,
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
                        placeholder: 'Enter pancard number',
                        controller: _pancardController,
                        isRequired: true,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Email Address',
                        placeholder: 'Enter your email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        isRequired: true,
                        suffixIcon: const Icon(Icons.email, size: 20),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Pincode',
                        placeholder: 'Enter 6 digit pincode',
                        controller: _pincodeController,
                        keyboardType: TextInputType.number,
                        isRequired: true,
                        suffixIcon: const Icon(Icons.location_on, size: 20),
                      ),
                      const SizedBox(height: 16),
                      // Employment Type Dropdown
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
                                    value: value,
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
                        placeholder: 'Enter your desired loan amount',
                        controller: _loanAmountController,
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
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EmploymentScreen(),
                            ),
                          );
                        },
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