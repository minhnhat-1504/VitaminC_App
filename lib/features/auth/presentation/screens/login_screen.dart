import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
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
      final passwordRegex = RegExp(
        r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[\W_]).*$',
      );
      if (!passwordRegex.hasMatch(password)) {
        _showError(
          "Mật khẩu phải gồm chữ hoa, chữ thường, số và ký tự đặc biệt",
        );
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
    final resetEmailController = TextEditingController(
      text: _emailController.text,
    );
    bool isSending = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text(
                'Quên mật khẩu?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Nhập email của bạn để nhận link đặt lại mật khẩu.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: resetEmailController,
                    hintText: 'Nhập địa chỉ email',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSending
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text(
                    'Hủy',
                    style: TextStyle(color: Colors.grey),
                  ),
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
                            await FirebaseAuth.instance.sendPasswordResetEmail(
                              email: email,
                            );
                            if (mounted) {
                              Navigator.pop(dialogContext);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Link đặt lại mật khẩu đã được gửi đến email của bạn. Hãy kiểm tra hộp thư (kể cả Spam).',
                                  ),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isSending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Gửi link',
                          style: TextStyle(color: Colors.white),
                        ),
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
            : CustomScrollView(
                physics: const ClampingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
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
                              const SizedBox(height: 16),
                              AnimatedCrossFade(
                                duration: const Duration(milliseconds: 300),
                                crossFadeState: isLogin
                                    ? CrossFadeState.showFirst
                                    : CrossFadeState.showSecond,
                                alignment: Alignment.topCenter,
                                firstChild: _buildLoginForm(),
                                secondChild: RegisterForm(
                                  nameController: _nameController,
                                  emailController: _emailController,
                                  passwordController: _passwordController,
                                  submitButton: _buildSubmitButton(
                                    "Đăng ký",
                                    _handleEmailAuth,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
                          _buildSocialSection(),
                          const Spacer(),
                          const SizedBox(height: 16),
                          _buildFooter(),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLabel('Địa chỉ Email'),
        CustomTextField(
          controller: _emailController,
          hintText: 'Nhập địa chỉ email',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildLabel('Mật khẩu'),
        CustomTextField(
          controller: _passwordController,
          hintText: 'Nhập mật khẩu',
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
        _buildSubmitButton("Đăng nhập", _handleEmailAuth),
      ],
    );
  }

  // --- HELPER WIDGETS ---
  Widget _buildSubmitButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 52,
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.85, end: 1.0).animate(animation),
                  child: child,
                ),
              );
            },
            child: CircleAvatar(
              key: ValueKey<bool>(isLogin),
              radius: 30,
              backgroundColor: const Color(0xFFBAE6FD),
              child: Icon(
                isLogin ? Icons.school : Icons.person_add_alt_1_rounded,
                size: 40,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              isLogin ? 'Chào mừng trở lại' : 'Tạo tài khoản',
              key: ValueKey<String>(isLogin ? 'login_title' : 'register_title'),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textLight,
              ),
            ),
          ),
          const SizedBox(height: 2),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              isLogin ? 'Đăng nhập để tiếp tục' : 'Bắt đầu hành trình của bạn',
              key: ValueKey<String>(isLogin ? 'login_sub' : 'register_sub'),
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialSection() {
    return Column(
      children: [
        const Text(
          "HOẶC TIẾP TỤC VỚI",
          style: TextStyle(
            fontSize: 11,
            color: Color(0xFF94A3B8),
            letterSpacing: 1.2,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
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
          height: 52,
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
    return const Column(
      children: [
        Text(
          "Bằng cách tiếp tục, bạn đồng ý với",
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Điều khoản dịch vụ",
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              " và ",
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            ),
            Text(
              "Chính sách bảo mật",
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
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
