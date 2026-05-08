import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/shared_widgets/custom_app_bar.dart';
import '../controllers/study_controller.dart';
import '../../data/srs_engine.dart';

class FlashcardScreen extends ConsumerStatefulWidget {
  final String? deckId;
  const FlashcardScreen({super.key, this.deckId});

  @override
  ConsumerState<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends ConsumerState<FlashcardScreen> {
  bool isFlipped = false;

  @override
  void initState() {
    super.initState();
    // Tải thẻ ôn tập của bộ hiện tại
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(studyControllerProvider.notifier).loadDueCards(deckId: widget.deckId);
    });
  }

  void _reviewCard(ReviewQuality quality) {
    ref.read(studyControllerProvider.notifier).processReview(quality);
    setState(() {
      isFlipped = false; // Reset lật thẻ
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(studyControllerProvider);

    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (state.errorMessage != null) {
      return Scaffold(body: Center(child: Text('Lỗi: ${state.errorMessage}')));
    }

    if (state.dueCards.isEmpty) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'Review Complete', showBackButton: true),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline, size: 80, color: AppColors.success),
              const SizedBox(height: 24),
              const Text('🎉 Bộ từ này hôm nay không có từ nào cần ôn!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  ref.read(studyControllerProvider.notifier).loadDueCards(deckId: widget.deckId, forceStudy: true);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: const Text('Học lại toàn bộ (Cram mode)', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Trở về thư viện', style: TextStyle(color: AppColors.textLight)),
              )
            ],
          ),
        ),
      );
    }

    if (state.isFinished) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'Review Complete', showBackButton: true),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.stars, size: 100, color: AppColors.secondary),
              const SizedBox(height: 24),
              const Text('Tuyệt vời! Bạn đã hoàn thành phiên học.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  context.pushReplacement('/study-summary');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Xem tổng kết bài học', style: TextStyle(fontSize: 16, color: Colors.white)),
              )
            ],
          ),
        ),
      );
    }

    final currentWord = state.dueCards[state.currentIndex];
    final progress = (state.currentIndex + 1) / state.dueCards.length;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Now Learning: IELTS Vocab',
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
                        text: currentWord.meaning,
                        subtext: 'Tap to flip back\n${currentWord.example ?? ''}',
                        isBack: true,
                      )
                    : _buildCardContent(
                        key: const ValueKey(false),
                        text: currentWord.word,
                        subtext: 'Tap to view meaning',
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
                        _buildSRSButton('Hard', AppColors.warning, () => _reviewCard(ReviewQuality.hard)),
                        _buildSRSButton('Good', AppColors.primary, () => _reviewCard(ReviewQuality.good)),
                        _buildSRSButton('Easy', AppColors.success, () => _reviewCard(ReviewQuality.easy)),
                      ],
                    ),
                  )
                : const Center(
                    child: Text(
                      'Think carefully before flipping the card!',
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

  Widget _buildSRSButton(String label, Color color, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onTap,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
