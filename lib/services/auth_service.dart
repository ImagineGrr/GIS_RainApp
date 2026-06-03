import 'package:rainfall_app/models/user_model.dart';
import 'package:rainfall_app/utils/mock_data.dart';

class AuthService {
  /// Simulates a login request. 
  /// In a real app, this would verify credentials against Supabase/Firebase.
  Future<UserModel?> login(String username, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    
    // MVP: For demo purposes, we accept any password and check if username matches mock users.
    if (MockData.users.containsKey(username)) {
      return MockData.users[username];
    }
    
    return null; // Login failed
  }

  /// Logs the user out
  Future<void> logout() async {
    // Clear local secure storage / Hive box here
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
