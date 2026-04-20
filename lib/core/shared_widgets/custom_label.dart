import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomLabel extends StatelessWidget {
  final String english;
  final String vietnamese;

  const CustomLabel({
    super.key,
    required this.english,
    required this.vietnamese,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Row(
        children: [
          Text(
            english,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textLight,
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '- $vietnamese',
            style: const TextStyle(color: AppColors.slate400, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
