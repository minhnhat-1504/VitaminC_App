import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/shared_widgets/custom_label.dart';
import '../../../../core/shared_widgets/custom_text_field.dart';
import '../widgets/auth_tab_switcher.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLogin = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    AuthTabSwitcher(
                      isLoginActive: isLogin,
                      onTabChanged: () => setState(() => isLogin = !isLogin),
                    ),
                    const SizedBox(height: 32),

                    Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        // Giữ khung layout ổn định
                        Opacity(
                          opacity: 0,
                          child: IgnorePointer(child: _buildLoginForm()),
                        ),

                        // FORM LOGIN
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 250),
                          opacity: isLogin ? 1.0 : 0.0,
                          child: IgnorePointer(
                            ignoring: !isLogin,
                            child: _buildLoginForm(),
                          ),
                        ),

                        // FORM REGISTER
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 250),
                          opacity: isLogin ? 0.0 : 1.0,
                          child: IgnorePointer(
                            ignoring: isLogin,
                            child: RegisterForm(
                              emailController: _emailController,
                              passwordController: _passwordController,
                              submitButton: _buildSubmitButton(
                                "Sign Up Now\nĐăng ký ngay",
                                () => context.go('/home'),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                    _buildSocialSection(),
                    const SizedBox(height: 32),
                    _buildFooter(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CustomLabel(
          english: 'Email Address',
          vietnamese: 'Địa chỉ Email',
        ),
        CustomTextField(
          controller: _emailController,
          hintText: 'name@example.com',
          prefixIcon: Icons.email_outlined,
        ),
        const SizedBox(height: 24),
        const CustomLabel(english: 'Password', vietnamese: 'Mật khẩu'),
        CustomTextField(
          controller: _passwordController,
          hintText: '••••••••',
          prefixIcon: Icons.lock_outline,
          isPassword: true,
        ),

        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 40),
            ),
            child: const Text(
              'Quên mật khẩu?',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),
        _buildSubmitButton(
          "Login Now\nĐăng nhập ngay",
          () => context.go('/home'),
        ),
      ],
    );
  }

  // --- HELPER WIDGETS ---
  Widget _buildSubmitButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: const Color(0xFFBAE6FD),
            child: Icon(
              isLogin ? Icons.school : Icons.person_add_alt_1_rounded,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isLogin ? 'Welcome Back' : 'Create Account',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textLight,
            ),
          ),
          Text(
            isLogin
                ? 'Chào mừng bạn quay trở lại'
                : 'Bắt đầu hành trình của bạn',
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialSection() {
    return Column(
      children: [
        const Text(
          "OR CONTINUE WITH",
          style: TextStyle(
            fontSize: 11,
            color: Color(0xFF94A3B8),
            letterSpacing: 1.2,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            _buildSocialBtn("Google", Icons.g_mobiledata),
            const SizedBox(width: 16),
            _buildSocialBtn("Facebook", Icons.facebook),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialBtn(String label, IconData icon) {
    return Expanded(
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          "By continuing, you agree to English Master's",
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Terms of Service",
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              " & ",
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            ),
            Text(
              "Privacy Policy",
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          "Bằng cách tiếp tục, bạn đồng ý với Điều khoản dịch vụ\nvà Chính sách bảo mật",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFFCBD5E1),
            fontSize: 11,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
