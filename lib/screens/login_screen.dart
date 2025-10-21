import 'dart:io';
import 'package:flutter/foundation.dart'; // Add this for kIsWeb
import 'package:infinz/screens/details_screen.dart';
import 'package:infinz/screens/main_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:localstorage/localstorage.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/progress_indicator_widget.dart';
import '../utils/app_colors.dart';
import 'verify_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isValidPhoneNumber = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_validatePhoneNumber);
  }

  void _validatePhoneNumber() {
    setState(() {
      _isValidPhoneNumber = _phoneController.text.length == 10 &&
          RegExp(r'^[0-9]+$').hasMatch(_phoneController.text);
    });
  }

  Future<void> _sendOtp() async {
    if (!_isValidPhoneNumber) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(
            'https://backend.infinz.seabed2crest.com/api/v1/auth/send-otp/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'phoneNumber': _phoneController.text,
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  VerifyScreen(phoneNumber: _phoneController.text),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to send OTP: ${response.body}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Image.asset(
              'assets/image/Cashmate-logo.png',
              width: 190,
              height: 120,
              fit: BoxFit.contain,
            ),
            const ProgressIndicatorWidget(
              currentStep: 1,
              stepNames: const ['Mobile', 'Verify', 'Details'],
              stepIcons: const [
                Icons.phone,
                Icons.check_circle,
                Icons.description,
              ],
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Login or Sign Up',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Enter your mobile number to get started',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Mobile Number',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          height: 48,
                          width: 70,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Center(
                            child: Text(
                              'IN +91',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              maxLength: 10,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.5,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter your number',
                                hintStyle: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 10,
                                    right: 8,
                                    bottom: 2,
                                  ),
                                  child: Icon(
                                    Icons.phone,
                                    size: 20,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                border: InputBorder.none,
                                counterText: '',
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                isDense: true,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _isValidPhoneNumber
                              ? Colors.indigoAccent
                              : AppColors.secondary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ElevatedButton(
                          onPressed: _isValidPhoneNumber && !_isLoading
                              ? _sendOtp
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Send OTP',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        fontStyle: FontStyle.normal,
                                        color: Colors.white,
                                      ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.grey.shade300,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.grey.shade300,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const SizedBox(height: 16),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(
                              text: 'By continuing, you agree to our '),
                          TextSpan(
                            text: 'Terms and Conditions',
                            style: const TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                final Uri url = Uri.parse(
                                    'https://www.seabed2crest.com/privacy-policy');
                                try {
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(
                                      url,
                                      mode: LaunchMode.inAppWebView,
                                    );
                                  } else {
                                    await launchUrl(
                                      url,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Could not open the link. Please check your browser app.'),
                                    ),
                                  );
                                }
                              },
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: const TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                final Uri url = Uri.parse(
                                    'https://www.seabed2crest.com/privacy-policy');
                                try {
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(
                                      url,
                                      mode: LaunchMode.inAppWebView,
                                    );
                                  } else {
                                    await launchUrl(
                                      url,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Could not open the link. Please check your browser app.'),
                                    ),
                                  );
                                }
                              },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: kIsWeb
            ? Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: content,
                ),
              )
            : content,
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.removeListener(_validatePhoneNumber);
    _phoneController.dispose();
    super.dispose();
  }
}
