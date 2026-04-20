import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/dummy_data.dart';
import '../../../../../core/shared_widgets/custom_app_bar.dart';
import '../../../../../core/shared_widgets/srs_button.dart';

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  bool isFlipped = false;
  int currentIndex = 0;

  void _nextCard() {
    if (currentIndex < DummyData.vocabularies.length - 1) {
      setState(() {
        isFlipped = false;
        currentIndex++;
      });
    } else {
      // Đã hết thẻ, chuyển sang màn hình tổng kết
      context.push('/study-summary');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentWord = DummyData.vocabularies[currentIndex];
    final progress = (currentIndex + 1) / DummyData.vocabularies.length;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Đang học: IELTS Vocab',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Thanh tiến độ
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.textLight.withOpacity(0.2),
              color: AppColors.primary,
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
            ),
          ),

          // Flashcard 3D
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isFlipped = !isFlipped),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  final rotateAnim = Tween(
                    begin: pi,
                    end: 0.0,
                  ).animate(animation);
                  return AnimatedBuilder(
                    animation: rotateAnim,
                    child: child,
                    builder: (context, widget) {
                      final isUnder = (ValueKey(isFlipped) != widget!.key);
                      var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;
                      tilt *= isUnder ? -1.0 : 1.0;
                      final value = isUnder
                          ? min(rotateAnim.value, pi / 2)
                          : rotateAnim.value;
                      return Transform(
                        transform: Matrix4.rotationY(value)
                          ..setEntry(3, 0, tilt),
                        alignment: Alignment.center,
                        child: widget,
                      );
                    },
                  );
                },
                child: isFlipped
                    ? _buildCardContent(
                        key: const ValueKey(true),
                        text: currentWord['meaning'],
                        subtext: 'Chạm để lật lại',
                        isBack: true,
                      )
                    : _buildCardContent(
                        key: const ValueKey(false),
                        text: currentWord['word'],
                        subtext: '(${currentWord['type']}) - Chạm để xem nghĩa',
                      ),
              ),
            ),
          ),

          // Khung nút đánh giá SRS (Chỉ hiện khi lật mặt sau)
          SizedBox(
            height: 100, // Chiều cao cố định để Layout không bị giật
            child: isFlipped
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SrsButton(
                          label: 'Khó',
                          color: AppColors.warning,
                          onPressed: _nextCard,
                        ),
                        SrsButton(
                          label: 'Tốt',
                          color: AppColors.primary,
                          onPressed: _nextCard,
                        ),
                        SrsButton(
                          label: 'Dễ',
                          color: AppColors.success,
                          onPressed: _nextCard,
                        ),
                      ],
                    ),
                  )
                : const Center(
                    child: Text(
                      'Hãy suy nghĩ kỹ trước khi lật thẻ!',
                      style: TextStyle(color: AppColors.textLight),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardContent({
    required Key key,
    required String text,
    required String subtext,
    bool isBack = false,
  }) {
    return Container(
      key: key,
      margin: const EdgeInsets.all(32),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isBack
              ? AppColors.primary.withOpacity(0.5)
              : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isBack ? AppColors.primary : AppColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              subtext,
              style: const TextStyle(fontSize: 16, color: AppColors.textLight),
            ),
          ],
        ),
      ),
    );
  }
}
