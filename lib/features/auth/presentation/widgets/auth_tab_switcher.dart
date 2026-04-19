import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AuthTabSwitcher extends StatelessWidget {
  final bool isLoginActive;
  final VoidCallback onTabChanged;

  const AuthTabSwitcher({
    super.key,
    required this.isLoginActive,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: isLoginActive
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              _buildTabButton(
                "Login",
                "Đăng nhập",
                isLoginActive,
                onTabChanged,
              ),
              _buildTabButton(
                "Sign Up",
                "Đăng ký",
                !isLoginActive,
                onTabChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(
    String en,
    String vi,
    bool active,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: active ? null : onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 50,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                en,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: active ? AppColors.primary : const Color(0xFF94A3B8),
                ),
              ),
              Text(
                vi,
                style: TextStyle(
                  fontSize: 10,
                  color: active ? AppColors.primary : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
