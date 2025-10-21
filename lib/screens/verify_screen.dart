import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:another_telephony/telephony.dart';
import 'dart:convert';

import 'package:localstorage/localstorage.dart';
import '../widgets/progress_indicator_widget.dart';
import '../utils/app_colors.dart';
import 'main_screen.dart';
import 'details_screen.dart';

class VerifyScreen extends StatefulWidget {
  final String phoneNumber;

  const VerifyScreen({super.key, required this.phoneNumber});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final Telephony telephony = Telephony.instance;
  String otpCode = '';
  bool isButtonEnabled = false;
  bool isLoading = false;
  String errorMessage = '';

  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<bool> _isActive = List.generate(6, (_) => false);

  bool hasStartedListening = false;
  int resendSeconds = 6; // 6-second countdown

  @override
  void initState() {
    super.initState();
    _initFocusListeners();
    startResendTimer(); // start countdown when screen loads
  }

  void _initFocusListeners() {
    for (int i = 0; i < _focusNodes.length; i++) {
      _focusNodes[i].addListener(() {
        setState(() {
          _isActive[i] = _focusNodes[i].hasFocus;
        });
      });
    }
  }

  void _startListeningSms() async {
    final Telephony telephony = Telephony.instance;

    bool? permissionsGranted = await telephony.requestPhoneAndSmsPermissions;

    if (permissionsGranted ?? false) {
      print("✅ SMS permission granted");

      telephony.listenIncomingSms(
        onNewMessage: (SmsMessage message) {
          print("📩 Incoming SMS: ${message.body}");

          final otpRegex = RegExp(r'\b\d{6}\b');
          final match = otpRegex.firstMatch(message.body ?? '');

          if (match != null) {
            final otpCode = match.group(0);
            print("✅ OTP extracted: $otpCode");
            _fillOtp(otpCode!);
            verifyOtp();
          } else {
            print("❌ OTP not found in message");
          }
        },
        listenInBackground: false,
      );
    } else {
      print("❌ Required permissions not granted");
    }
  }

  void _fillOtp(String otp) {
    for (int i = 0; i < 6; i++) {
      _controllers[i].text = otp[i];
    }
    if (mounted) {
      setState(() {
        otpCode = otp;
        isButtonEnabled = true;
      });
    }
  }

  @override
  void dispose() {
    for (var node in _focusNodes) node.dispose();
    for (var controller in _controllers) controller.dispose();
    super.dispose();
  }

  void onOtpChange(String code) {
    if (mounted) {
      setState(() {
        otpCode = code;
        isButtonEnabled = code.length == 6;
      });
    }
  }

  Future<void> verifyOtp() async {
    if (!isButtonEnabled) return;
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });
    }

    try {
      final response = await http.post(
        Uri.parse('https://backend.infinz.seabed2crest.com/api/v1/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': widget.phoneNumber,
          'otp': otpCode,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        await initLocalStorage();
        localStorage.setItem(
            'accessToken', data['data']['token']['accessToken']);
        localStorage.setItem('phoneNumber', widget.phoneNumber);

        final hasName = data['data']['user']['fullName'] != null;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) =>
                hasName ? const MainScreen() : const DetailsScreen(),
          ),
          (Route<dynamic> route) => false,
        );
      } else {
        if (mounted) {
          setState(() {
            errorMessage = data['message'] ?? 'OTP verification failed';
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          errorMessage = 'An error occurred. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> resendOtp() async {
    setState(() {
      resendSeconds = 6; // disable resend for 6 seconds after pressing
    });
    startResendTimer();

    try {
      final response = await http.post(
        Uri.parse('https://backend.infinz.seabed2crest.com/api/v1/auth/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': widget.phoneNumber}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP resent successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Failed to resend OTP')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error resending OTP')),
      );
    }
  }

  void startResendTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (resendSeconds > 0) {
        if (mounted) {
          setState(() {
            resendSeconds--;
          });
        }
        return true;
      }
      return false;
    });
  }

  Widget _buildOtpField(int index) {
    return Container(
      width: 40,
      height: 45,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (event) {
          if (event is RawKeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace &&
              _controllers[index].text.isEmpty &&
              index > 0) {
            _focusNodes[index - 1].requestFocus();
            _controllers[index - 1].clear();
            onOtpChange(_controllers.map((c) => c.text).join());
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
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
          decoration: const InputDecoration(border: InputBorder.none),
          onChanged: (value) {
            if (value.length == 1 && index < 5) {
              _focusNodes[index + 1].requestFocus();
            }
            onOtpChange(_controllers.map((c) => c.text).join());
          },
        ),
      ),
    );
  }

  Widget _buildOtpForm() {
    return Container(
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'We\'ve sent a 6-digit verification\ncode to',
              style: TextStyle(fontSize: 14, color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.phoneNumber,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Enter Verification Code',
                  style: TextStyle(fontSize: 14, color: Colors.black)),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, _buildOtpField),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: isButtonEnabled && !isLoading ? verifyOtp : null,
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
                    : const Text('Verify OTP', style: TextStyle(fontSize: 14)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text('Change Number',
                      style: TextStyle(color: Colors.blue)),
                ),
                resendSeconds > 0
                    ? Text(
                        'Resend OTP in ${resendSeconds}s',
                        style: const TextStyle(color: AppColors.textMuted),
                      )
                    : GestureDetector(
                        onTap: resendOtp,
                        child: const Text(
                          'Resend OTP',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
              ],
            ),
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              Image.asset(
                'assets/image/Cashmate-logo.png',
                width: 190,
                height: 189,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
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
              _buildOtpForm(),
            ],
          ),
        ),
      ),
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
}
