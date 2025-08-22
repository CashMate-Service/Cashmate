import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:localstorage/localstorage.dart';

import '../utils/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'thank_you_screen.dart'; // Add this import

class EmploymentScreen extends StatefulWidget {
  const EmploymentScreen({super.key});

  @override
  State<EmploymentScreen> createState() => _EmploymentScreenState();
}

class _EmploymentScreenState extends State<EmploymentScreen> {
  final TextEditingController _desiredLoanAmountController =
      TextEditingController();
  final TextEditingController _monthlyIncomeController =
      TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _companyCodeController = TextEditingController();

  String selectedLoanRange = '1 to 2 Lakhs';
  String selectedEmploymentType = '';
  bool _agreedToTerms = false;
  bool _isUploading = false;
  bool _isLoading = true;
  bool _isSubmitting = false;

  // NEW: dropdown states for income and payment mode
  final List<String> _incomeRanges = const [
    '15 to 20K',
    '20 to 25K',
    '25 to 30K',
    '30 to 40K',
    '40K above',
  ];
  String _selectedIncomeRange = '15 to 20K';

  final List<String> _paymentModes = const [
    'bank account',
    'cash in hand',
  ];
  String _selectedPaymentMode = 'bank account';

  PlatformFile? _selectedFile;

  @override
  void initState() {
    super.initState();
    _loadWithDelay();
  }

  Future<void> _loadWithDelay() async {
    await Future.delayed(const Duration(seconds: 2));
    await _fetchEmployeeDetails();
  }

  Future<void> _fetchEmployeeDetails() async {
    try {
      await initLocalStorage();
      final token = localStorage.getItem('accessToken');
      final response = await http.get(
        Uri.parse('https://backend.infinz.seabed2crest.com/api/v1/employment-details'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body['data'];
        if (mounted) {
          setState(() {
            selectedEmploymentType = data['employmentType'] ?? '';
            
            // Handle income range dropdown
            final netIncomeStr = data['netMonthlyIncome']?.toString() ?? '';
            if (_incomeRanges.contains(netIncomeStr)) {
              _selectedIncomeRange = netIncomeStr;
            } else {
              _selectedIncomeRange = _incomeRanges.first;
            }
            
            // Handle payment mode dropdown
            final paymentModeStr = data['paymentMode']?.toString() ?? '';
            if (_paymentModes.contains(paymentModeStr)) {
              _selectedPaymentMode = paymentModeStr;
            } else {
              _selectedPaymentMode = _paymentModes.first;
            }
            
            _companyNameController.text = data['companyOrBusinessName'] ?? '';
            _companyCodeController.text = data['companyPinCode'] ?? '';
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _validateForm() {
    if (selectedLoanRange.isEmpty ||
        selectedEmploymentType.isEmpty ||
        (selectedEmploymentType == 'salaried' &&
            (_selectedIncomeRange.isEmpty ||
                _companyNameController.text.trim().isEmpty ||
                _companyCodeController.text.trim().isEmpty ||
                _selectedPaymentMode.isEmpty ||
                _selectedFile == null))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return false;
    }
    return true;
  }

  Future<void> _submitForm() async {
    if (!_validateForm() || !_agreedToTerms) {
      if (!_agreedToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please agree to the Terms and Conditions')),
        );
      }
      return;
    }

    setState(() => _isSubmitting = true);

    final token = localStorage.getItem('accessToken');

    final Map<String, dynamic> body = {
      "employmentType": selectedEmploymentType,
      "desiredAmount": selectedLoanRange
    };

    if (selectedEmploymentType == 'salaried') {
      body.addAll({
        "netMonthlyIncome": _selectedIncomeRange,
        "companyOrBusinessName": _companyNameController.text.trim(),
        "companyPinCode": _companyCodeController.text.trim(),
        "paymentMode": _selectedPaymentMode,
        "salarySlipDocument": "http://example.com/documents/salary-slip.pdf",
      });
    }

    try {
      final response = await http.post(
        Uri.parse('https://backend.infinz.seabed2crest.com/api/v1/loan/request'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ThankYouScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit form')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _pickDocument() async {
    setState(() => _isUploading = true);
    try {
      final result = await FilePicker.platform.pickFiles(
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
        setState(() => _selectedFile = file);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting file: $e')),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: Lottie.asset('assets/lottie/Money.json',
                    width: 200, height: 200))
            : SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Center(
                      child: Image.asset(
                        'assets/image/Cashmate-logo.png',
                        width: 190,
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Center(
                      child: Text(
                        'Start Your Loan Journey Today',
                        style:
                            TextStyle(fontSize: 14, color: AppColors.textMuted),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // CustomTextField(
                    //   label: 'Desired Loan Amount',
                    //   placeholder: 'Enter desired amount',
                    //   controller: _desiredLoanAmountController,
                    //   keyboardType: TextInputType.number,
                    //   isRequired: true,
                    //   prefixIcon: const Padding(
                    //     padding: EdgeInsets.only(left: 12, top: 12),
                    //     child: Text('₹', style: TextStyle(fontSize: 16)),
                    //   ),
                    // ),
                    // const SizedBox(height: 20),

                    // const Text(
                    //   'Desired Loan Amount *',
                    //   style:
                    //       TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    // ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedLoanRange.isNotEmpty
                          ? selectedLoanRange
                          : '1 to 2 Lakhs',
                      decoration: const InputDecoration(
                        labelText: 'Desired Amount *',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        '1 to 2 Lakhs',
                        '2 to 3 Lakhs',
                        '4 to 6 lakhs',
                        '6 to 10 Lakhs',
                        'Above 10 Lakhs'
                      ]
                          .map((range) => DropdownMenuItem(
                                value: range,
                                child: Text(range),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedLoanRange = value ?? '';
                        });
                      },
                    ),

                    const SizedBox(height: 24),
                    DropdownButtonFormField<String>(
                      value: selectedEmploymentType.isNotEmpty
                          ? selectedEmploymentType
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'Employment Type *',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        'salaried',
                        'self-employed',
                        'business-owner',
                        'unemployed',
                        'other'
                      ]
                          .map((e) => DropdownMenuItem(
                              value: e, child: Text(_toTitleCase(e))))
                          .toList(),
                      onChanged: (value) {
                        setState(() => selectedEmploymentType = value ?? '');
                      },
                    ),

                    const SizedBox(height: 24),

                                          if (selectedEmploymentType == 'salaried') ...[
                        DropdownButtonFormField<String>(
                          value: _selectedIncomeRange.isNotEmpty
                              ? _selectedIncomeRange
                              : null,
                          decoration: const InputDecoration(
                            labelText: 'Net Monthly Income *',
                            border: OutlineInputBorder(),
                          ),
                          items: _incomeRanges
                              .map((range) => DropdownMenuItem(
                                    value: range,
                                    child: Text(range),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() => _selectedIncomeRange = value ?? '');
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedPaymentMode.isNotEmpty
                              ? _selectedPaymentMode
                              : null,
                          decoration: const InputDecoration(
                            labelText: 'Payment Mode *',
                            border: OutlineInputBorder(),
                          ),
                          items: _paymentModes
                              .map((mode) => DropdownMenuItem(
                                    value: mode,
                                    child: Text(mode),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() => _selectedPaymentMode = value ?? '');
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Company/Business Name',
                          placeholder: 'Enter company name',
                          controller: _companyNameController,
                          isRequired: true,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Company PinCode',
                          placeholder: 'Enter pin code',
                          controller: _companyCodeController,
                          isRequired: true,
                        ),
                        const SizedBox(height: 20),
                        InkWell(
                          onTap: _isUploading ? null : _pickDocument,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[100],
                            ),
                            child: Column(
                              children: [
                                _isUploading
                                    ? const CircularProgressIndicator()
                                    : const Icon(Icons.upload_file,
                                        size: 40, color: Colors.grey),
                                const SizedBox(height: 8),
                                Text(
                                  _isUploading
                                      ? 'Uploading...'
                                      : 'Upload Salary Slip/Bank Statement',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'PDF, JPG, PNG (MAX 5MB)',
                                  style:
                                      TextStyle(fontSize: 12, color: Colors.grey),
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
                                          onPressed: () => setState(
                                              () => _selectedFile = null),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _agreedToTerms,
                          onChanged: (value) =>
                              setState(() => _agreedToTerms = value ?? false),
                        ),
                        Expanded(
                          child: Text(
                            'I agree to the Terms and Conditions and confirm that the information provided is accurate.',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[800]),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    _isSubmitting
                        ? Center(
                            child: Image.asset('assets/image/Cashmate-logo.png',
                                width: 100, height: 100))
                        : CustomButton(
                            text: 'Submit',
                            onPressed: _submitForm,
                          ),
                  ],
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _desiredLoanAmountController.dispose();
    _monthlyIncomeController.dispose();
    _companyNameController.dispose();
    _companyCodeController.dispose();
    super.dispose();
  }

  static String _toTitleCase(String str) {
    return str.isEmpty
        ? str
        : str[0].toUpperCase() + str.substring(1).replaceAll('-', ' ');
  }
}
