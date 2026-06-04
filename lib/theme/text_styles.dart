import 'package:flutter/material.dart';
import 'package:rainfall_app/theme/app_colors.dart';

/// Centralized text styles for consistent typography across the app.
class AppTextStyles {

  static const TextStyle heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  static const TextStyle subheading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: AppColors.textDark,
  );

  static const TextStyle bodyLight = TextStyle(
    fontSize: 14,
    color: AppColors.textLight,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.textLight,
  );

  static const TextStyle metricValue = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  static const TextStyle metricLabel = TextStyle(
    fontSize: 13,
    color: AppColors.textLight,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}
