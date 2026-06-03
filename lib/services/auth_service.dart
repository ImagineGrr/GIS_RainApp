import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rainfall_app/models/user_model.dart';
import 'package:rainfall_app/utils/mock_data.dart';

class AuthService {
  static final client = Supabase.instance.client;

  /// Returns the current logged-in user profile, if any
  Future<UserModel?> getCurrentUser() async {
    final user = client.auth.currentUser;
    if (user == null || user.phone == null) return null;
    return await _getOrCreateProfile(user.id, user.phone!);
  }

  /// Sends a one-time password (OTP) to the user's mobile number.
  Future<void> sendOtp(String phone) async {
    // Format phone to E.164 if it isn't already (e.g. +91...)
    String formattedPhone = phone.trim();
    if (!formattedPhone.startsWith('+')) {
      formattedPhone = '+91$formattedPhone'; // Default to Indian country code
    }
    
    await client.auth.signInWithOtp(
      phone: formattedPhone,
    );
  }

  /// Verifies the OTP token and returns the User Model.
  Future<UserModel?> verifyOtp(String phone, String token) async {
    String formattedPhone = phone.trim();
    if (!formattedPhone.startsWith('+')) {
      formattedPhone = '+91$formattedPhone';
    }

    final response = await client.auth.verifyOTP(
      phone: formattedPhone,
      token: token.trim(),
      type: OtpType.sms,
    );

    if (response.user != null) {
      return await _getOrCreateProfile(response.user!.id, formattedPhone);
    }
    
    return null;
  }

  /// Fetches the profile from the database, or automatically creates it for test users
  Future<UserModel?> _getOrCreateProfile(String userId, String phone) async {
    try {
      final response = await client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        return _mapProfileToUser(response);
      }

      // No profile exists for this authenticated user.
      // Since self-signup is disabled, we sign them out immediately.
      print('Unauthorized login attempt: Profile not found for user $userId ($phone)');
      await logout();
      return null;
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }

  /// Maps Supabase profiles table row to Flutter UserModel
  UserModel _mapProfileToUser(Map<String, dynamic> data) {
    final roleStr = data['role'] as String;
    UserRole role;
    switch (roleStr) {
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

    return UserModel(
      id: data['id'] as String,
      name: data['name'] as String,
      role: role,
      phone: data['phone'] as String,
      assignedAreaId: data['assigned_area_id'] as String,
      assignedAreaName: data['assigned_area_name'] as String,
    );
  }

  /// Logs the user out of Supabase
  Future<void> logout() async {
    await client.auth.signOut();
  }
}
