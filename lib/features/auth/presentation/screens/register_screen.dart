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
        _buildLabel("Full Name", "Họ và tên"),
        CustomTextField(
          controller: nameController,
          hintText: 'Your full name',
          prefixIcon: Icons.person_outline,
        ),
        const SizedBox(height: 24),

        // 2. Ô nhập Email
        _buildLabel("Email Address", "Địa chỉ Email"),
        CustomTextField(
          controller: emailController, 
          hintText: 'name@example.com', 
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 24),

        // 3. Ô nhập Mật khẩu
        _buildLabel("Create Password", "Tạo mật khẩu"),
        CustomTextField(
          controller: passwordController, 
          hintText: '••••••••', 
          prefixIcon: Icons.lock_outline, 
          isPassword: true,
        ),
        
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              // Bạn có thể thêm logic chuyển sang tab Login ở đây nếu cần
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero, 
              minimumSize: const Size(0, 40),
            ),
            child: const Text(
              'Đã có tài khoản?', 
              style: TextStyle(
                color: AppColors.primary, 
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8), 
        
        // Nút bấm được truyền từ LoginScreen
        submitButton,
      ],
    );
  }

  Widget _buildLabel(String en, String vi) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Row(
        children: [
          Text(
            en, 
            style: const TextStyle(
              fontWeight: FontWeight.bold, 
              color: AppColors.textLight, 
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            "- $vi", 
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
          ),
        ],
      ),
    );
  }
}