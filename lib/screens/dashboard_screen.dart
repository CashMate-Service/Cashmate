import 'dart:convert';
import 'package:infinz/screens/employment_screen.dart';
import 'package:infinz/utils/app_colors.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';

class LoanHomeScreen extends StatefulWidget {
  const LoanHomeScreen({super.key});

  @override
  State<LoanHomeScreen> createState() => _LoanHomeScreenState();
}

class _LoanHomeScreenState extends State<LoanHomeScreen> {
  Map<String, dynamic>? pendingLoanRequest;
  List<Map<String, dynamic>> completedLoanRequests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLoanRequests();
  }

  Future<void> _fetchLoanRequests() async {
    const url = 'https://backend.infinz.seabed2crest.com/api/v1/users/home';
    final token = localStorage.getItem('accessToken');
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final data = json['data'];
        if (mounted) {
          setState(() {
            pendingLoanRequest = data['pendingLoanRequest'];
            completedLoanRequests = List<Map<String, dynamic>>.from(
              data['completedLoanRequests'] ?? [],
            );
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load loan data');
      }
    } catch (e) {
      debugPrint('Error fetching loan data: $e');
      setState(() => isLoading = false);
    }
  }

  void _showDisclaimerModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.indigoAccent,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.white,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Important Disclaimer',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Before proceeding, please understand:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '• Infinz provides loan suggestions and financial advice only\n'
                        '• We are not a lender or financial institution\n'
                        '• Final loan approval depends on lender criteria\n'
                        '• Terms and conditions may vary by lender',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Loan Terms:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: const Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Loan Amount:',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                ),
                                Text(
                                  '₹10,000 - ₹5,00,000',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Interest Rate:',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                ),
                                Text(
                                  '12% - 24% p.a.',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Tenure:',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                ),
                                Text(
                                  '6 - 60 months',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Processing Fee:',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                ),
                                Text(
                                  'Up to 3% of loan amount',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '*Terms may vary based on your profile and lender policies.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.grey),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            minimumSize: const Size.fromHeight(48),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _showLoanFormModal();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigoAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            minimumSize: const Size.fromHeight(48),
                          ),
                          child: const Text(
                            'Continue',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLoanFormModal() {
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.white,
      useRootNavigator: true,
      context: context,
      builder: (context) => const SafeArea(child: EmploymentScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;

    Widget content = isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            children: [
              Center(
                child: Image.asset(
                  'assets/image/Cashmate-logo.png',
                  width: kIsWeb ? width * 0.1 : width * 0.5,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Disclaimer: Infinz provides loan suggestions only and is not a lender or financial institution.",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  height: 1.5,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 20),
              if (pendingLoanRequest == null)
                ElevatedButton(
                  onPressed: _showDisclaimerModal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigoAccent,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Get Financial Advice',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward,
                          size: 18, color: Colors.white),
                    ],
                  ),
                ),
              if (pendingLoanRequest != null) ...[
                const SizedBox(height: 16),
                Text(
                  '',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildLoanCard(pendingLoanRequest!),
              ],
              const SizedBox(height: 32),
              Text(
                'Recent Requests',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (completedLoanRequests.isEmpty)
                const Text(
                  'No Requests found',
                  style: TextStyle(color: Colors.grey),
                )
              else
                ...completedLoanRequests
                    .map((req) => _buildLoanCard(req))
                    .toList(),
            ],
          );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: kIsWeb
            ? Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: content,
                ),
              )
            : content,
      ),
    );
  }

  Widget _buildLoanCard(Map<String, dynamic> req) {
    final amount = req['desiredAmount'] ?? 0;
    final date =
        req['createdAt'] != null ? DateTime.tryParse(req['createdAt']) : null;
    final dateFormatted =
        date != null ? DateFormat.yMMMd().format(date) : 'Date unavailable';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$amount',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: req['status'] == 'completed'
                      ? Colors.green.shade50
                      : const Color(0xFFFFF4CC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _capitalize(req['status'] ?? 'unknown'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: req['status'] == 'completed'
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                dateFormatted,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          )
        ],
      ),
    );
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}
