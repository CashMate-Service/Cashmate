import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/bottom_navigation_widget.dart';
import '../utils/app_colors.dart';
import 'thank_you_screen.dart';

class EmploymentScreen extends StatefulWidget {
  const EmploymentScreen({super.key});

  @override
  State<EmploymentScreen> createState() => _EmploymentScreenState();
}

class _EmploymentScreenState extends State<EmploymentScreen> {
  final TextEditingController _monthlyIncomeController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _companyCodeController = TextEditingController();

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
                    height: 120,
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
                const SizedBox(height: 32),
                const Text(
                  'Employment Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Income and Employment',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 24),
                // Form Fields
                CustomTextField(
                  label: 'Net Monthly Salary/Income',
                  placeholder: 'Enter Monthly Salary/Income',
                  controller: _monthlyIncomeController,
                  keyboardType: TextInputType.number,
                  isRequired: true,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 12, top: 12),
                    child: Text('₹', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  label: 'Company/Business Name',
                  placeholder: 'Enter Company/Business Name',
                  controller: _companyNameController,
                  isRequired: true,
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  label: 'Company Code',
                  placeholder: '',
                  controller: _companyCodeController,
                  isRequired: true,
                ),
                const SizedBox(height: 64),
                CustomButton(
                  text: 'Submit',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ThankYouScreen(),
                      ),
                    );
                  },
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
    _monthlyIncomeController.dispose();
    _companyNameController.dispose();
    _companyCodeController.dispose();
    super.dispose();
  }
}