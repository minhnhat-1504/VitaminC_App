import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/shared_widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  _buildSlide(
                    title: "Học thông minh với SRS",
                    desc: "Ghi nhớ từ vựng lâu hơn gấp 10 lần nhờ thuật toán lặp lại ngắt quãng.",
                    icon: Icons.psychology,
                  ),
                  _buildSlide(
                    title: "Chatbot AI đồng hành",
                    desc: "Luyện tập giao tiếp mọi lúc mọi nơi với trợ lý ảo thông minh.",
                    icon: Icons.chat_bubble_outline,
                  ),
                  _buildSlide(
                    title: "Theo dõi tiến độ",
                    desc: "Duy trì Streak và chinh phục bảng xếp hạng cùng bạn bè.",
                    icon: Icons.leaderboard,
                  ),
                ],
              ),
            ),
            
            // Chỉ báo trang (Dots)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) => _buildDot(index)),
            ),
            
            // Nút điều khiển
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: CustomPrimaryButton(
                text: _currentPage == 2 ? 'Bắt đầu' : 'Tiếp theo',
                onPressed: () {
                  if (_currentPage < 2) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  } else {
                    context.go('/login');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide({required String title, required String desc, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 100, color: AppColors.primary),
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textLight),
          ),
          const SizedBox(height: 16),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? AppColors.primary : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}