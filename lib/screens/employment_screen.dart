import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/bottom_navigation_widget.dart';
import '../utils/app_colors.dart';
import 'thank_you_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class EmploymentScreen extends StatefulWidget {
  const EmploymentScreen({super.key});

  @override
  State<EmploymentScreen> createState() => _EmploymentScreenState();
}

class _EmploymentScreenState extends State<EmploymentScreen> {
  final TextEditingController _monthlyIncomeController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _companyCodeController = TextEditingController();

  bool _agreedToTerms = false;
  PlatformFile? _selectedFile;
  bool _isUploading = false;

  Future<void> _pickDocument() async {
    setState(() => _isUploading = true);
    
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.size > 5 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File size exceeds 5MB limit')),
          );
          return;
        }
        
        setState(() {
          _selectedFile = file;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting file: ${e.toString()}')),
      );
    } finally {
      setState(() => _isUploading = false);
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
                Center(
                  child: Image.network(
                    'https://www.cashmateonline.com/wp-content/uploads/2023/10/Cashmate-logo.jpg',
                    width: 120,
                   height: 60,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => 
                      const Icon(Icons.business, size: 80),
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
                const Text(
                  'Employment Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Shadowed Container for the form section
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Income and Employment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Salary Input
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextField(
                            label: 'Net Monthly Salary/Income',
                            placeholder: 'Enter your monthly income',
                            controller: _monthlyIncomeController,
                            keyboardType: TextInputType.number,
                            isRequired: true,
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(left: 12, top: 12),
                              child: Text('₹', style: TextStyle(fontSize: 16)),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Minimum income required: ₹15,000',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Company Name
                      CustomTextField(
                        label: 'Company/Business Name',
                        placeholder: 'Enter company/business name',
                        controller: _companyNameController,
                        isRequired: true,
                      ),
                      const SizedBox(height: 24),

                      // Company Code
                      CustomTextField(
                        label: 'Company Code',
                        placeholder: 'Enter company code',
                        controller: _companyCodeController,
                        isRequired: true,
                      ),
                      const SizedBox(height: 32),

                      // File Upload Section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[100],
                        ),
                        child: InkWell(
                          onTap: _isUploading ? null : _pickDocument,
                          child: Column(
                            children: [
                              _isUploading
                                  ? const CircularProgressIndicator()
                                  : const Icon(Icons.upload_file, size: 40, color: Colors.grey),
                              const SizedBox(height: 8),
                              Text(
                                _isUploading ? 'Uploading...' : 'Upload Salary Slip/Bank Statement',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'PDF, JPG, PNG (MAX 5MB)',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              if (_selectedFile != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          _selectedFile!.name,
                                          style: const TextStyle(
                                            fontSize: 12, 
                                            color: Colors.green,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          maxLines: 1,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close, size: 16),
                                        onPressed: () => setState(() {
                                          _selectedFile = null;
                                        }),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Terms Checkbox
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _agreedToTerms,
                            onChanged: (value) {
                              setState(() {
                                _agreedToTerms = value ?? false;
                              });
                            },
                          ),
                          Expanded(
                            child: Text(
                              'I agree to the Terms and Conditions and confirm that the information provided is accurate.',
                              style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Submit Button
                      CustomButton(
                        text: 'Submit',
                        onPressed: () {
                          if (!_agreedToTerms) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please agree to the Terms and Conditions')),
                            );
                            return;
                          }

                          if (_selectedFile == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please upload required documents')),
                            );
                            return;
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ThankYouScreen()),
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
    _monthlyIncomeController.dispose();
    _companyNameController.dispose();
    _companyCodeController.dispose();
    super.dispose();
  }
}