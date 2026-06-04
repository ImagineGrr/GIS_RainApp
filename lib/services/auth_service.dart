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

      // Self-healing / Auto-provisioning step:
      // If profile doesn't exist, check if it matches one of our default test users and insert it.
      String cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
      // If it has country code prefix 91, strip it for matching mock data keys
      if (cleanPhone.startsWith('91') && cleanPhone.length > 10) {
        cleanPhone = cleanPhone.substring(2);
      }

      UserModel? templateUser;
      // Match by phone number in our MockData.users template
      for (var u in MockData.users.values) {
        if (u.phone == cleanPhone) {
          templateUser = u;
          break;
        }
      }

      // Default fallback if a completely new random phone number is used
      final name = templateUser?.name ?? 'Operator $cleanPhone';
      final role = templateUser?.role ?? UserRole.field;
      final areaId = templateUser?.assignedAreaId ?? 'RP001';
      final areaName = templateUser?.assignedAreaName ?? 'Khora Village';

      // Insert new profile record
      await client.from('profiles').insert({
        'id': userId,
        'name': name,
        'phone': phone,
        'role': role.name,
        'assigned_area_id': areaId,
        'assigned_area_name': areaName,
      });

      return UserModel(
        id: userId,
        name: name,
        role: role,
        phone: phone,
        assignedAreaId: areaId,
        assignedAreaName: areaName,
      );
    } catch (e) {
      print('Error fetching or creating profile: $e');
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
