import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/shared_widgets/custom_text_field.dart';

class RegisterForm extends StatelessWidget {
  final TextEditingController nameController; // Thêm controller cho Tên
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final Widget submitButton;

  const RegisterForm({
    super.key,
    required this.nameController, // Yêu cầu truyền nameController
    required this.emailController,
    required this.passwordController,
    required this.submitButton,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Thêm ô nhập Họ và Tên
        _buildLabel("Họ và tên"),
        CustomTextField(
          controller: nameController,
          hintText: 'Nhập họ và tên',
          prefixIcon: Icons.person_outline,
        ),
        const SizedBox(height: 16),

        // 2. Ô nhập Email
        _buildLabel("Địa chỉ Email"),
        CustomTextField(
          controller: emailController,
          hintText: 'Nhập địa chỉ email',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),

        // 3. Ô nhập Mật khẩu
        _buildLabel("Tạo mật khẩu"),
        CustomTextField(
          controller: passwordController,
          hintText: 'Nhập mật khẩu',
          prefixIcon: Icons.lock_outline,
          isPassword: true,
        ),

        const SizedBox(height: 24),

        // Nút bấm được truyền từ LoginScreen
        submitButton,
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
