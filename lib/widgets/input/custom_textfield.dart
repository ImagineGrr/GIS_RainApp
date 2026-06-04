import 'package:flutter/material.dart';

import 'package:rainfall_app/theme/app_colors.dart';

class CustomTextField extends StatelessWidget {

  final String hintText;

  final IconData icon;

  final TextEditingController controller;

  final TextInputType keyboardType;

  final int maxLines;

  const CustomTextField({
    super.key,

    required this.hintText,
    required this.icon,
    required this.controller,

    this.keyboardType =
        TextInputType.text,

    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {

    return TextField(

      controller: controller,

      keyboardType: keyboardType,

      maxLines: maxLines,

      decoration: InputDecoration(

        hintText: hintText,

        prefixIcon: Icon(
          icon,
          color: AppColors.primary,
        ),

        filled: true,
        fillColor: Colors.white,

        contentPadding:
            const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 16,
        ),

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(18),

          borderSide: BorderSide.none,
        ),

        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(18),

          borderSide:
              BorderSide.none,
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(18),

          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
      ),
    );
  }
}