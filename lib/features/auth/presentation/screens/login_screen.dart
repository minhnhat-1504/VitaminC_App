import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/shared_widgets/custom_label.dart';
import '../../../../core/shared_widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_tab_switcher.dart';
import 'register_screen.dart';
import 'package:vitaminc/core/utils/app_exception_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool isLogin = true;
  bool isLoading = false; // Trạng thái chờ xử lý backend

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController(); // Dùng cho form đăng ký

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // --- XỬ LÝ LOGIC AUTH ---

  Future<void> _handleEmailAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    // Kiểm tra tính hợp lệ cơ bản
    if (email.isEmpty || password.isEmpty || (!isLogin && name.isEmpty)) {
      _showError("Vui lòng điền đầy đủ thông tin");
      return;
    }

    // Ràng buộc mật khẩu (chỉ áp dụng khi Đăng ký)
    if (!isLogin) {
      if (password.length < 8) {
        _showError("Mật khẩu phải có ít nhất 8 ký tự");
        return;
      }
      final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[\W_]).*$');
      if (!passwordRegex.hasMatch(password)) {
        _showError("Mật khẩu phải gồm chữ hoa, chữ thường, số và ký tự đặc biệt");
        return;
      }
    }

    setState(() => isLoading = true);

    try {
      final authRepo = ref.read(authRepositoryProvider);
      if (isLogin) {
        // Gọi hàm đăng nhập từ Repository
        await authRepo.signInEmail(email, password);
      } else {
        // Gọi hàm đăng ký tài khoản mới
        await authRepo.signUpEmail(email, password, name);
      }
      // Lưu ý: Không cần context.go('/home') ở đây vì routerProvider
      // sẽ tự động nhận diện trạng thái User != null và redirect.
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showError(dynamic error) {
    if (!mounted) return;
    final message = AppExceptionHandler.handleException(
      error,
      'Đã xảy ra lỗi',
    ).message;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController(text: _emailController.text);
    bool isSending = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text('Quên mật khẩu?', style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Nhập email của bạn để nhận link đặt lại mật khẩu.', style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: resetEmailController,
                    hintText: 'name@example.com',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSending ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: isSending
                      ? null
                      : () async {
                          final email = resetEmailController.text.trim();
                          if (email.isEmpty) {
                            _showError('Vui lòng nhập email');
                            return;
                          }

                          setDialogState(() => isSending = true);

                          try {
                            await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                            if (mounted) {
                              Navigator.pop(dialogContext);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Link đặt lại mật khẩu đã được gửi đến email của bạn. Hãy kiểm tra hộp thư (kể cả Spam).'),
                                  backgroundColor: AppColors.success,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          } catch (e) {
                            _showError(e);
                          } finally {
                            if (mounted) {
                              setDialogState(() => isSending = false);
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: isSending
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Gửi link', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : SingleChildScrollView(
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
                            onTabChanged: () =>
                                setState(() => isLogin = !isLogin),
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
                              // FORM REGISTER
                              AnimatedOpacity(
                                duration: const Duration(milliseconds: 250),
                                opacity: isLogin ? 0.0 : 1.0,
                                child: IgnorePointer(
                                  ignoring: isLogin,
                                  child: RegisterForm(
                                    nameController:
                                        _nameController, // <--- THÊM DÒNG NÀY
                                    emailController: _emailController,
                                    passwordController: _passwordController,
                                    submitButton: _buildSubmitButton(
                                      "Sign Up Now\nĐăng ký ngay",
                                      _handleEmailAuth,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 0),
                          _buildSocialSection(),
                          const SizedBox(height: 20),
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
          keyboardType: TextInputType.emailAddress,
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
            onPressed: _showForgotPasswordDialog,
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
        _buildSubmitButton("Login Now\nĐăng nhập ngay", _handleEmailAuth),
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
          const SizedBox(height: 4),
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
            _buildSocialBtn("Google", Icons.g_mobiledata, () async {
              try {
                await ref.read(authRepositoryProvider).signInWithGoogle();
              } catch (e) {
                _showError(e);
              }
            }),
            const SizedBox(width: 16),
            _buildSocialBtn("Facebook", Icons.facebook, () async {
              try {
                await ref.read(authRepositoryProvider).signInWithFacebook();
              } catch (e) {
                _showError(e);
              }
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialBtn(String label, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
              Icon(
                icon,
                size: 28,
                color: label == "Facebook" ? Colors.blue : Colors.redAccent,
              ),
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
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const Text(
          "By continuing, you agree to English Master's",
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        ),
        const Row(
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
        const SizedBox(height: 8),
        const Text(
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
