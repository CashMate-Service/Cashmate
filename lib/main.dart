import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/details_screen.dart';
import 'utils/app_colors.dart';
import 'package:localstorage/localstorage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const CashMateApp());
}

class CashMateApp extends StatelessWidget {
  const CashMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus(); // Dismiss keyboard globally
      },
      behavior: HitTestBehavior.opaque, // Detect taps on empty spaces
      child: MaterialApp(
        title: 'Cash Mate - Instant Loan Application',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: Colors.white,
          textTheme: GoogleFonts.interTextTheme(),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await initLocalStorage();
    final token = localStorage.getItem('accessToken');

    if (token != null) {
      print('Token found: $token');
      try {
        final response = await http.get(
          Uri.parse('https://cash.imvj.one/api/v1/users/me'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final user = data['data']['user'];

          final isProfileComplete = user['fullname'] != null &&
              user['dateOfBirth'] != null &&
              user['gender'] != null &&
              user['pancardNumber'] != null &&
              user['email'] != null &&
              user['pinCode'] != null &&
              user['phoneNumber'] != null;

          await Future.delayed(const Duration(seconds: 1));

          if (!mounted) return;

          if (isProfileComplete) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MainScreen()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const DetailsScreen()),
            );
          }
          return;
        }
      } catch (e) {
        // Handle fetch errors (e.g., network, token expired)
      }
    }

    // Fallback to login
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/image/Cashmate-logo.jpg', // Replace with your actual logo
          width: 200,
          height: 200,
        ),
      ),
    );
  }
}
