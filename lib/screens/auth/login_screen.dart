import 'package:flutter/material.dart';
import 'package:rainfall_app/theme/app_colors.dart';
import 'package:rainfall_app/models/user_model.dart';
import 'package:rainfall_app/services/auth_service.dart';
import 'package:rainfall_app/services/database_service.dart';

import 'package:rainfall_app/screens/field/navigation_screen.dart';
import 'package:rainfall_app/screens/block/block_navigation_screen.dart';
import 'package:rainfall_app/screens/district/district_navigation_screen.dart';
import 'package:rainfall_app/screens/state/state_navigation_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final authService = AuthService();
  final dbService = DatabaseService();
  
  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  
  bool isOtpSent = false;
  bool isLoading = false;
  String? errorMessage;

  // Quick testing login shortcuts
  final List<Map<String, String>> quickLogins = [
    {'label': 'Field Operator', 'phone': '9876543210'},
    {'label': 'Block Officer', 'phone': '9876543211'},
    {'label': 'District Officer', 'phone': '9876543212'},
    {'label': 'State Admin', 'phone': '9876543213'},
  ];

  @override
  void initState() {
    super.initState();
    _checkExistingSession();
  }

  void _checkExistingSession() async {
    setState(() => isLoading = true);
    final user = await authService.getCurrentUser();
    if (user != null) {
      await dbService.syncMetadataFromDatabase();
      if (mounted) {
        _navigateToRole(user);
      }
    } else {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _sendOtp() async {
    if (phoneController.text.trim().isEmpty) {
      setState(() => errorMessage = 'Please enter a mobile number');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await authService.sendOtp(phoneController.text.trim());
      setState(() {
        isOtpSent = true;
        isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent successfully!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to send OTP. Please check the number.';
      });
    }
  }

  void _verifyOtp() async {
    if (otpController.text.trim().length < 6) {
      setState(() => errorMessage = 'Please enter a valid 6-digit OTP code');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final user = await authService.verifyOtp(
        phoneController.text.trim(),
        otpController.text.trim(),
      );

      if (user != null) {
        // Fetch all database hierarchy tables and reports on successful login
        await dbService.syncMetadataFromDatabase();
        if (mounted) {
          _navigateToRole(user);
        }
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Invalid OTP code. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Authentication failed. Please try again.';
      });
    }
  }

  void _navigateToRole(UserModel user) {
    Widget destination;
    switch (user.role) {
      case UserRole.field:
        destination = FieldNavigationScreen(user: user);
        break;
      case UserRole.block:
        destination = BlockNavigationScreen(user: user);
        break;
      case UserRole.district:
        destination = DistrictNavigationScreen(user: user);
        break;
      case UserRole.state:
        destination = StateNavigationScreen(user: user);
        break;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              // App Icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(
                    Icons.water_drop,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Title
              const Center(
                child: Text(
                  'Rainfall Monitor',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Chhattisgarh State Monitoring System',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Animated Transition between Phone input and OTP verification
              AnimatedCrossFade(
                firstChild: _buildPhoneInputForm(),
                secondChild: _buildOtpVerificationForm(),
                crossFadeState: isOtpSent ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),

              // Error message display
              if (errorMessage != null) ...[
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(
                      color: AppColors.red,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : (isOtpSent ? _verifyOtp : _sendOtp),
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(isOtpSent ? 'Verify & Sign In' : 'Send OTP Code'),
                ),
              ),

              // Show Back Button if in OTP verification step
              if (isOtpSent && !isLoading) ...[
                const SizedBox(height: 12),
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        isOtpSent = false;
                        otpController.clear();
                        errorMessage = null;
                      });
                    },
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: const Text('Change Phone Number'),
                  ),
                ),
              ],

              const SizedBox(height: 40),

              // Quick Login Section
              const Center(
                child: Text(
                  'DEVELOPER QUICK LOGIN (SANDBOX)',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Quick login buttons
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.8,
                children: quickLogins.map((login) {
                  return OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    onPressed: isLoading ? null : () async {
                      phoneController.text = login['phone']!;
                      setState(() {
                        isLoading = true;
                        errorMessage = null;
                      });
                      
                      try {
                        await authService.sendOtp(login['phone']!);
                        setState(() {
                          isOtpSent = true;
                          isLoading = false;
                          otpController.text = '123456'; // Auto fill Sandbox testing OTP
                        });
                      } catch (e) {
                        setState(() {
                          isLoading = false;
                          errorMessage = 'Quick login failed. Make sure testing numbers are set.';
                        });
                      }
                    },
                    child: Text(
                      login['label']!,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneInputForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Registered Mobile Number',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: 'Enter 10-digit mobile number',
            prefixIcon: const Icon(Icons.phone_android, color: AppColors.primary),
            hintStyle: TextStyle(color: Colors.grey.shade400),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpVerificationForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verification Code sent to ${phoneController.text}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: InputDecoration(
            hintText: 'Enter 6-digit OTP code',
            prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
            hintStyle: TextStyle(color: Colors.grey.shade400),
            counterText: '',
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    phoneController.dispose();
    otpController.dispose();
    super.dispose();
  }
}
