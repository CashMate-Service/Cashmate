import 'dart:convert';
import 'package:infinz/screens/employment_screen.dart';
import 'package:infinz/utils/app_colors.dart';
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                children: [
                  Center(
                    child: Image.asset(
                      'assets/image/Cashmate-logo.png',
                      width: width * 0.5,
                      fit: BoxFit.contain,
                    ),
                  ),
                  // const SizedBox(height: 24),
                    //  const SizedBox(height: 20),
                    const Text(
                  "Disclaimer: Infinz provides financial advices only and is not a lender or financial institution. ",
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
                      onPressed: _showLoanFormModal,
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
                      'Financial Advices',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildLoanCard(pendingLoanRequest!),
                  ],
                  const SizedBox(height: 32),
                  Text(
                    'Recent Financial Advices Given',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (completedLoanRequests.isEmpty)
                    const Text(
                      'No Advices found',
                      style: TextStyle(color: Colors.grey),
                    )
                  else
                    ...completedLoanRequests
                        .map((req) => _buildLoanCard(req))
                        .toList(),
                        
                ],
              ),
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
          // Text(
          //   'Request ID :  ${req['_id']}',
          //   style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          // ),
          // const SizedBox(height: 6),
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
