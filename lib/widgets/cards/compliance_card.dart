import 'package:flutter/material.dart';
import 'package:rainfall_app/theme/app_colors.dart';

/// Card showing reporting compliance with a progress bar.
class ComplianceCard extends StatelessWidget {

  final int reported;
  final int total;
  final String label;

  const ComplianceCard({
    super.key,
    required this.reported,
    required this.total,
    this.label = 'stations reported',
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (reported / total) : 0.0;
    final percentText = '${(percentage * 100).toStringAsFixed(0)}%';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "TODAY'S COMPLIANCE",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  percentText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '$reported / $total',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage >= 0.8
                    ? AppColors.green
                    : percentage >= 0.5
                        ? AppColors.yellow
                        : AppColors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
