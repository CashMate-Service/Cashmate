import 'package:Cashmate/screens/main_screen.dart';
import 'package:flutter/material.dart';
import '../widgets/bottom_navigation_widget.dart';
import '../utils/app_colors.dart';
import 'history_screen.dart';
import 'dart:async';

class ThankYouScreen extends StatefulWidget {
  const ThankYouScreen({super.key});

  @override
  State<ThankYouScreen> createState() => _ThankYouScreenState();
}

class _ThankYouScreenState extends State<ThankYouScreen> {
  int _countdown = 30;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    startCountdown();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        _timer.cancel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MainScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Logo
            Image.asset(
              'assets/image/Cashmate-logo.jpg',
              width: 140,
              height: 120,
              fit: BoxFit.contain,
            ),
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Success Icon
                      const Icon(
                        Icons.check_circle,
                        size: 80,
                        color: AppColors.success,
                      ),
                      const SizedBox(height: 32),
                      // Thank You Message
                      const Text(
                        'Thank You !',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Your loan application has been submitted successfully. Our team will review your application and get back to you shortly.',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textMuted,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'You will be redirected to the history page in $_countdown seconds',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Thank you for choosing Cash Mate for your financial needs.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Footer
            // Padding(
            //   padding: const EdgeInsets.only(
            //     left: 32.0,
            //     right: 32.0,
            //     bottom: 32.0,
            //     top: 16.0,
            //   ),
            //   child: Column(
            //     children: [
            //       const Text(
            //         'Stay connected with us',
            //         style: TextStyle(
            //           fontSize: 12,
            //           color: AppColors.textMuted,
            //         ),
            //         textAlign: TextAlign.center,
            //       ),
            //       const SizedBox(height: 4),
            //       const Text(
            //         'Follow us on social media for updates',
            //         style: TextStyle(
            //           fontSize: 12,
            //           color: AppColors.textMuted,
            //         ),
            //         textAlign: TextAlign.center,
            //       ),
            //       const SizedBox(height: 24),
            //       // Social Media Icons
            //       Row(
            //         mainAxisAlignment: MainAxisAlignment.center,
            //         children: [
            //           Container(
            //             width: 40,
            //             height: 40,
            //             decoration: BoxDecoration(
            //               color: Colors.grey.shade100,
            //               shape: BoxShape.circle,
            //             ),
            //             child: const Icon(
            //               FontAwesomeIcons.instagram,
            //               size: 20,
            //               color: Colors.grey,
            //             ),
            //           ),
            //           const SizedBox(width: 24),
            //           Container(
            //             width: 40,
            //             height: 40,
            //             decoration: BoxDecoration(
            //               color: Colors.grey.shade100,
            //               shape: BoxShape.circle,
            //             ),
            //             child: const Icon(
            //               FontAwesomeIcons.facebook,
            //               size: 20,
            //               color: Colors.grey,
            //             ),
            //           ),
            //         ],
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainScreen()),
              );
            },
            child: const Text(
              'Go to Home',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
      // bottomNavigationBar: const BottomNavigationWidget(currentIndex: 0),
    );
  }
}