import 'package:flutter/material.dart';
import 'package:rainfall_app/theme/app_colors.dart';
import 'package:rainfall_app/utils/helpers.dart';

/// Shared header widget used across all role dashboards.
class AppHeader extends StatelessWidget {

  final String userName;
  final String roleLabel;
  final VoidCallback? onNotificationTap;

  const AppHeader({
    super.key,
    required this.userName,
    required this.roleLabel,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              getGreeting(),
              style: const TextStyle(
                color: AppColors.textLight,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              userName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                roleLabel,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: onNotificationTap,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.notifications_none,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
