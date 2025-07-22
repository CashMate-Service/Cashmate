// user_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiConstants {
  static const String baseUrl = "https://cash.imvj.one/api/v1";
  static const String userProfileEndpoint = "/users/me";
}

class UserService {
  final http.Client client;

  UserService({required this.client});

  Future<UserProfileResponse> getUserProfile() async {
    try {
      final response = await client.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.userProfileEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          // Add any required headers like authorization token here
          // 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return UserProfileResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load user profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load user profile: $e');
    }
  }
}

class UserProfileResponse {
  final bool success;
  final int status;
  final String message;
  final UserData data;

  UserProfileResponse({
    required this.success,
    required this.status,
    required this.message,
    required this.data,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    return UserProfileResponse(
      success: json['success'],
      status: json['status'],
      message: json['message'],
      data: UserData.fromJson(json['data']),
    );
  }
}

class UserData {
  final User user;

  UserData({required this.user});

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      user: User.fromJson(json['user']),
    );
  }
}

class User {
  final String? fullname;
  final String? email;
  final String phoneNumber;
  final String? gender;
  final String? dateOfBirth;
  final String? pancardNumber;
  final String? pinCode;
  final String? maritalStatus;

  User({
    this.fullname,
    this.email,
    required this.phoneNumber,
    this.gender,
    this.dateOfBirth,
    this.pancardNumber,
    this.pinCode,
    this.maritalStatus,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      fullname: json['fullname'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      gender: json['gender'],
      dateOfBirth: json['dateOfBirth'],
      pancardNumber: json['pancardNumber'],
      pinCode: json['pinCode'],
      maritalStatus: json['maritalStatus'],
    );
  }
}