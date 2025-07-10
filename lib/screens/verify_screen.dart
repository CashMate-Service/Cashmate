import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../widgets/progress_indicator_widget.dart';
import '../utils/app_colors.dart';
import 'details_screen.dart';
import 'package:localstorage/localstorage.dart';


class VerifyScreen extends StatefulWidget {
  final String phoneNumber;
  
  const VerifyScreen({super.key, required this.phoneNumber});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  String otpCode = '';
  bool isButtonEnabled = false;
  bool isLoading = false;
  String errorMessage = '';
   
  List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  List<bool> _isActive = List.generate(6, (index) => false);
  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 6; i++) {
      _focusNodes[i].addListener(() {
        setState(() {
          _isActive[i] = _focusNodes[i].hasFocus;
        });
      });
    }
  }

  @override
  void dispose() {
    for (int i = 0; i < 6; i++) {
      _focusNodes[i].dispose();
      _controllers[i].dispose();
    }
    super.dispose();
  }

  void onOtpChange(String code) {
    setState(() {
      otpCode = code;
      isButtonEnabled = code.length == 6;
    });
  }

  Future<void> verifyOtp() async {
    if (!isButtonEnabled) return;

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8085/api/v1/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': widget.phoneNumber,
          'otp': otpCode,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
          await initLocalStorage();
        

      localStorage.setItem('accessToken', responseData['data']['token']['accessToken']);
localStorage.setItem('phoneNumber', widget.phoneNumber);

    

        // Navigate to details screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DetailsScreen(),
          ),
        );
      } else {
        setState(() {
          errorMessage = responseData['message'] ?? 'OTP verification failed';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred. Please try again.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 32),
                      // Logo
                      Image.network(
                        'https://www.cashmateonline.com/wp-content/uploads/2023/10/Cashmate-logo.jpg',
                        width: 190,
                        height: 189,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 16),
                      // Progress Indicator
                      const ProgressIndicatorWidget(
                        currentStep: 2,
                        stepNames: ['Mobile', 'Verify', 'Details'],
                        stepIcons: [
                          Icons.phone,
                          Icons.check_circle,
                          Icons.description,
                        ],
                      ),
                      const SizedBox(height: 32),
                      // OTP Card
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              const Text(
                                'Verify Your Number',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'We\'ve sent a 6-digit verification\ncode to',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textMuted,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.phoneNumber,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Enter Verification Code',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: List.generate(6, (index) {
                                  return Container(
                                    width: 40,
                                    height: 45,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: _isActive[index] || _controllers[index].text.isNotEmpty 
                                            ? AppColors.primary
                                            : Colors.grey.shade300,
                                        width: 0.5,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: RawKeyboardListener(
                                      focusNode: FocusNode(),
                                      onKey: (RawKeyEvent event) {
                                        if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
                                          if (_controllers[index].text.isEmpty && index > 0) {
                                            _focusNodes[index - 1].requestFocus();
                                            _controllers[index - 1].clear();
                                            String newOtp = '';
                                            for (int i = 0; i < 6; i++) {
                                              newOtp += _controllers[i].text;
                                            }
                                            onOtpChange(newOtp);
                                          }
                                        }
                                      },
                                      child: TextField(
                                        controller: _controllers[index],
                                        focusNode: _focusNodes[index],
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                          LengthLimitingTextInputFormatter(1),
                                        ],
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black,
                                        ),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        onChanged: (value) {
                                          if (value.length == 1 && index < 5) {
                                            _focusNodes[index + 1].requestFocus();
                                          }
                                          String newOtp = '';
                                          for (int i = 0; i < 6; i++) {
                                            newOtp += _controllers[i].text;
                                          }
                                          onOtpChange(newOtp);
                                        },
                                        onTap: () {
                                          _controllers[index].selection = TextSelection.fromPosition(
                                            TextPosition(offset: _controllers[index].text.length),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              if (errorMessage.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: Text(
                                    errorMessage,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 32),
                              // Verify OTP Button
                              SizedBox(
                                width: double.infinity,
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: isButtonEnabled && !isLoading
                                      ? verifyOtp
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isButtonEnabled && !isLoading
                                        ? AppColors.primary
                                        : Colors.grey.shade300,
                                    foregroundColor: isButtonEnabled && !isLoading
                                        ? Colors.white
                                        : Colors.black54,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'Verify OTP',
                                          style: TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Footer Links
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      'Change Number',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                  const Text(
                                    'Resend OTP in 6s',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}