import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rainfall_app/models/user_model.dart';
import 'package:rainfall_app/utils/config.dart';

class AuthService {
  // In-memory token storage to authorize requests
  static String? token;
  static UserModel? _currentUser;

  /// Returns the current logged-in user profile, if any
  Future<UserModel?> getCurrentUser() async {
    return _currentUser;
  }

  /// Sends a one-time password (OTP) to the user's mobile number.
  Future<void> sendOtp(String phone) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/auth/send-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone.trim()}),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to send OTP: ${response.body}');
    }
  }

  /// Verifies the OTP token and returns the User Model.
  Future<UserModel?> verifyOtp(String phone, String verificationToken) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/auth/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone': phone.trim(),
        'token': verificationToken.trim(),
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      token = responseData['token'];
      
      final userData = responseData['user'];
      
      // Parse UserRole enum
      UserRole role;
      switch (userData['role']) {
        case 'block':
          role = UserRole.block;
          break;
        case 'district':
          role = UserRole.district;
          break;
        case 'state':
          role = UserRole.state;
          break;
        case 'field':
        default:
          role = UserRole.field;
      }

      final user = UserModel(
        id: userData['id'],
        name: userData['name'],
        role: role,
        phone: userData['phone'],
        assignedAreaId: userData['assigned_area_id'],
        assignedAreaName: userData['assigned_area_name'],
      );

      _currentUser = user;
      return user;
    }
    
    return null;
  }

  /// Logs the user out of the app
  Future<void> logout() async {
    token = null;
    _currentUser = null;
  }
}
