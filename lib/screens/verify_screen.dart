import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../widgets/progress_indicator_widget.dart';
import '../utils/app_colors.dart';
import 'details_screen.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  String otpCode = '';
  bool isButtonEnabled = false;

  void onOtpChange(String code) {
    setState(() {
      otpCode = code;
      isButtonEnabled = code.length == 6;
    });
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
                              const Text(
                                '+91 7654876546',
                                style: TextStyle(
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

                              PinCodeTextField(
                                appContext: context,
                                length: 6,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                animationType: AnimationType.fade,
                                cursorColor: AppColors.primary,
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                                pinTheme: PinTheme(
                                  shape: PinCodeFieldShape.box,
                                  borderRadius: BorderRadius.circular(8),
                                  fieldHeight: 45,
                                  fieldWidth: 40,
                                  borderWidth: 0.1,
                                  activeColor: AppColors.primary,
                                  selectedColor: AppColors.primary,
                                  inactiveColor: Colors.grey.shade300,
                                  activeFillColor: Colors
                                      .transparent, // Added to keep background transparent
                                  selectedFillColor: Colors
                                      .transparent, // Added to keep background transparent
                                  inactiveFillColor: Colors
                                      .transparent, // Added to keep background transparent
                                ),
                                onChanged: onOtpChange,
                              ),
                              const SizedBox(height: 32),

                              // Verify OTP Button
                              SizedBox(
                                width: double.infinity,
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: isButtonEnabled
                                      ? () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const DetailsScreen(),
                                            ),
                                          );
                                        }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isButtonEnabled
                                        ? AppColors.primary
                                        : Colors.grey.shade300,
                                    foregroundColor: isButtonEnabled
                                        ? Colors.white
                                        : Colors.black54,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(
                                          context); // ✅ Navigates back to the mobile entry screen
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
