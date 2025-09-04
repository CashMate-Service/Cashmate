import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/app_colors.dart';
// import '../widgets/bottom_navigation_widget.dart';
import 'package:localstorage/localstorage.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> loanRequests = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchLoanRequests();
  }

  final token = localStorage.getItem('accessToken');

  Future<void> fetchLoanRequests() async {
    try {
      final response = await http.get(
        Uri.parse('https://backend.infinz.seabed2crest.com/api/v1/loan/request'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          if (mounted) {
            setState(() {
              loanRequests = data['data']['loanRequests'];
              isLoading = false;
            });
          }
        } else { 
          if (mounted) {
          setState(() {
            errorMessage = data['message'] ?? 'Failed to load loan requests';
            isLoading = false;
          });
          }
        }
      } else {
        if (mounted) {
        setState(() {
          errorMessage = 'Failed to load loan requests: ${response.statusCode}';
          isLoading = false;
        });
        }
      }
    } catch (e) {
      if (mounted) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
        isLoading = false;
      });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // const SizedBox(height: 1),
            // Logo
            Image.asset(
              'assets/image/Cashmate-logo.png',
              width: width * 0.51,
              fit: BoxFit.contain,
              height: 110,
              // fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            const Text(
              'Make Smart Financial Decisions',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Loan Suggestions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 32),
            // Loan Details Card
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildLoanList(),
              ),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: const BottomNavigationWidget(currentIndex: 1),
    );
  }

  Widget _buildLoanList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          errorMessage,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (loanRequests.isEmpty) {
      return const Center(
        child: Text('No Requests Found'),
      );
    }

    return ListView.builder(
      itemCount: loanRequests.length,
      itemBuilder: (context, index) {
        final loan = loanRequests[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Amount',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(loan['status']),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      loan['status'].toString().toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                ' ${loan['desiredAmount']}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              _buildDetailRow('Full Name:', loan['fullName']),
              const SizedBox(height: 12),
              _buildDetailRow('Status:', loan['status']),
              const SizedBox(height: 12),
              _buildDetailRow('Applied On:', _formatDate(loan['createdAt'])),
              // const SizedBox(height: 12),
              // _buildDetailRow('Employment Type:', loan['employmentType']),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return AppColors.primary;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textMuted,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
