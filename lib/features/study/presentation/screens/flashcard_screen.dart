import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/shared_widgets/custom_app_bar.dart';
import '../controllers/study_controller.dart';
import '../../data/srs_engine.dart';
import '../../../tools/data/tts_service.dart';
import '../widgets/swipe_overlay.dart';

class FlashcardScreen extends ConsumerStatefulWidget {
  final String? deckId;
  const FlashcardScreen({super.key, this.deckId});

  @override
  ConsumerState<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends ConsumerState<FlashcardScreen> {
  /// Controller điều khiển CardSwiper từ bên ngoài
  final CardSwiperController _swiperController = CardSwiperController();

  /// Theo dõi trạng thái lật (flip) của từng thẻ theo index
  final Set<int> _flippedIndices = {};

  /// Theo dõi xem thẻ trên cùng đã lật xem nghĩa ít nhất 1 lần chưa (mở khóa vuốt)
  bool _hasFlippedOnce = false;

  /// Hỗ trợ chống spam snackbar
  DateTime? _lastSnackbarTime;

  @override
  void initState() {
    super.initState();
    // Tải thẻ ôn tập của bộ hiện tại
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(studyControllerProvider.notifier)
          .loadDueCards(deckId: widget.deckId);
    });
  }

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  /// Xử lý đánh giá thẻ — Giữ nguyên 100% logic SRS cũ
  /// Chỉ thay đổi cách trigger (từ nút bấm → sự kiện vuốt)
  void _reviewCard(ReviewQuality quality) {
    ref.read(studyControllerProvider.notifier).processReview(quality);
    // Reset trạng thái flip cho thẻ tiếp theo (không reset _flippedIndices để thẻ cũ giữ nguyên mặt)
    setState(() {
      _hasFlippedOnce = false;
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
        appBar: const CustomAppBar(
          title: 'Hoàn thành ôn tập',
          showBackButton: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 80,
                color: AppColors.success,
              ),
              const SizedBox(height: 24),
              const Text(
                '🎉 Bộ từ này hôm nay không có từ nào cần ôn!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(studyControllerProvider.notifier)
                      .loadDueCards(deckId: widget.deckId, forceStudy: true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text(
                  'Học lại toàn bộ',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text(
                  'Trở về thư viện',
                  style: TextStyle(color: AppColors.textLight),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state.isFinished) {
      return Scaffold(
        appBar: const CustomAppBar(
          title: 'Hoàn thành ôn tập',
          showBackButton: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.stars, size: 100, color: AppColors.secondary),
              const SizedBox(height: 24),
              const Text(
                'Tuyệt vời! Bạn đã hoàn thành phiên học.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  context.pushReplacement('/study-summary');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Xem tổng kết bài học',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final progress = state.currentIndex / state.dueCards.length;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Đang học từ vựng',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // ========== Thanh tiến độ ==========
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: progress),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor: AppColors.textLight.withOpacity(0.2),
                  color: AppColors.primary,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(8),
                );
              },
            ),
          ),

          // ========== CardSwiper (Tinder-style) ==========
          Expanded(
            child: Listener(
              onPointerMove: (event) {
                if (!_hasFlippedOnce) {
                  if (event.delta.dx.abs() > 2 || event.delta.dy.abs() > 2) {
                    _showFlipRequirementSnackBar();
                  }
                }
              },
              child: CardSwiper(
                isDisabled: !_hasFlippedOnce,
                controller: _swiperController,
                cardsCount: state.dueCards.length,
                numberOfCardsDisplayed: min(3, state.dueCards.length),
                isLoop: false,
                duration: const Duration(milliseconds: 500),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                // Cho phép vuốt 3 hướng: trái (Hard), phải (Easy), lên (Good)
                allowedSwipeDirection: const AllowedSwipeDirection.only(
                  left: true,
                  right: true,
                  up: true,
                  down: false,
                ),
                onSwipe: _onSwipe,
                onEnd: () {
                  // Khi hết thẻ, CardSwiper gọi onEnd
                  // StudyController đã đánh dấu isFinished trong processReview()
                },
                cardBuilder:
                    (context, index, percentThresholdX, percentThresholdY) {
                      if (index < 0 || index >= state.dueCards.length) {
                        return const SizedBox.shrink();
                      }
                      final card = state.dueCards[index];
                      return _buildSwipeCard(
                        card,
                        index,
                        percentThresholdX.toDouble(),
                        percentThresholdY.toDouble(),
                      );
                    },
              ),
            ),
          ),

          // ========== Hướng dẫn vuốt + Trạng thái ==========
          _buildSwipeGuide(),
        ],
      ),
    );
  }

  /// Xử lý sự kiện khi user vuốt thẻ
  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    if (!_hasFlippedOnce) {
      _showFlipRequirementSnackBar();
      return false; // Chặn vuốt
    }

    // ========== Map hướng vuốt → ReviewQuality ==========
    HapticFeedback.lightImpact(); // Phản hồi rung nhẹ khi vuốt thành công
    switch (direction) {
      case CardSwiperDirection.left:
        _reviewCard(ReviewQuality.hard);
        break;
      case CardSwiperDirection.right:
        _reviewCard(ReviewQuality.easy);
        break;
      case CardSwiperDirection.top:
        _reviewCard(ReviewQuality.good);
        break;
      default:
        return false; // Không cho vuốt xuống
    }
    return true; // Cho phép vuốt — thẻ bay ra
  }

  /// Hiển thị thông báo yêu cầu lật thẻ trước khi vuốt
  void _showFlipRequirementSnackBar() {
    final now = DateTime.now();
    if (_lastSnackbarTime != null &&
        now.difference(_lastSnackbarTime!).inMilliseconds < 1500) {
      return; // Tránh spam
    }
    _lastSnackbarTime = now;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.touch_app, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text('Hãy chạm vào thẻ để xem nghĩa trước khi vuốt!'),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.slate700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  /// Build widget thẻ Flashcard có khả năng flip và overlay feedback
  Widget _buildSwipeCard(
    dynamic card,
    int index,
    double percentThresholdX,
    double percentThresholdY,
  ) {
    // Chỉ thẻ đầu tiên (top card) mới hiện overlay và cho phép flip
    final isTopCard =
        (index == (ref.read(studyControllerProvider).currentIndex));
    final isFlipped = _flippedIndices.contains(index);

    return GestureDetector(
      key: ValueKey(card.id),
      onTap: isTopCard
          ? () {
              setState(() {
                if (isFlipped) {
                  _flippedIndices.remove(index);
                } else {
                  _flippedIndices.add(index);
                }
                _hasFlippedOnce = true; // Đã lật ít nhất 1 lần -> Mở khóa vuốt
              });
            }
          : null,
      child: Stack(
        children: [
          // ===== Card Content (Flip animation) =====
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            switchInCurve: Curves.easeInOutCubic,
            switchOutCurve: Curves.easeInOutCubic,
            transitionBuilder: (Widget child, Animation<double> animation) {
              final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);
              return AnimatedBuilder(
                animation: rotateAnim,
                child: child,
                builder: (context, widget) {
                  final isUnder = (ValueKey(isFlipped) != widget!.key);
                  var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.006;
                  tilt *= isUnder ? -1.0 : 1.0;
                  final value = isUnder
                      ? min(rotateAnim.value, pi / 2)
                      : rotateAnim.value;
                  // Dynamic shadow khi card đang giữa chừng flip
                  final flipProgress = (animation.value - 0.5).abs();
                  return Transform(
                    transform: Matrix4.rotationY(value)..setEntry(3, 0, tilt),
                    alignment: Alignment.center,
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              0.06 + (1 - flipProgress) * 0.12,
                            ),
                            blurRadius: 20 + (1 - flipProgress) * 16,
                            offset: Offset(0, 10 + (1 - flipProgress) * 8),
                          ),
                        ],
                      ),
                      child: widget,
                    ),
                  );
                },
              );
            },
            child: isFlipped
                ? _buildCardContent(
                    key: const ValueKey(true),
                    text: card.meaning,
                    subtext: card.example ?? '',
                    isBack: true,
                    onSpeak: () =>
                        ref.read(ttsServiceProvider).speak(card.word),
                  )
                : _buildCardContent(
                    key: const ValueKey(false),
                    text: card.word,
                    subtext: 'Chạm để xem nghĩa',
                    onSpeak: () =>
                        ref.read(ttsServiceProvider).speak(card.word),
                  ),
          ),

          // ===== Overlay phản hồi hình ảnh (chỉ hiện trên top card + đã lật ít nhất 1 lần) =====
          if (isTopCard && _hasFlippedOnce)
            SwipeOverlay(
              percentThresholdX: percentThresholdX,
              percentThresholdY: percentThresholdY,
            ),

          // ===== Indicator nhắc nhở lật thẻ — pulse animation =====
          if (isTopCard && !_hasFlippedOnce)
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.6, end: 1.0),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    return Opacity(opacity: value, child: child);
                  },
                  // onEnd restarts the animation by toggling
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.slate900.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.touch_app, color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Chạm để lật thẻ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Build nội dung bên trong thẻ (mặt trước hoặc mặt sau)
  Widget _buildCardContent({
    required Key key,
    required String text,
    required String subtext,
    bool isBack = false,
    VoidCallback? onSpeak,
  }) {
    return Container(
      key: key,
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isBack
              ? AppColors.primary.withValues(alpha: 0.5)
              : AppColors.slate200,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
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
                  if (subtext.isNotEmpty)
                    Text(
                      subtext,
                      style: TextStyle(
                        fontSize: 15,
                        color: isBack
                            ? AppColors.slate600
                            : AppColors.textLight,
                        fontStyle: isBack ? FontStyle.italic : FontStyle.normal,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ),
          if (onSpeak != null)
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.volume_up_rounded, size: 32),
                color: isBack ? AppColors.primary : AppColors.textLight,
                onPressed: onSpeak,
              ),
            ),
          // Label mặt trước/mặt sau
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isBack
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.slate100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isBack ? '🔤 Nghĩa' : '🇬🇧 Từ vựng',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isBack ? AppColors.primary : AppColors.slate500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build thanh hướng dẫn vuốt ở dưới cùng
  Widget _buildSwipeGuide() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _hasFlippedOnce
            ? Row(
                key: const ValueKey('swipe-guide'),
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Hướng dẫn vuốt trái
                  _buildGuideItem(
                    icon: Icons.arrow_back_rounded,
                    label: 'Khó',
                    color: AppColors.error,
                  ),
                  // Hướng dẫn vuốt lên
                  _buildGuideItem(
                    icon: Icons.arrow_upward_rounded,
                    label: 'Tốt',
                    color: AppColors.primary,
                  ),
                  // Hướng dẫn vuốt phải
                  _buildGuideItem(
                    icon: Icons.arrow_forward_rounded,
                    label: 'Dễ',
                    color: AppColors.success,
                  ),
                ],
              )
            : const Center(
                key: ValueKey('flip-hint'),
                child: Text(
                  'Hãy suy nghĩ kỹ trước khi lật thẻ!',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
      ),
    );
  }

  /// Build từng mục hướng dẫn vuốt (icon + label)
  Widget _buildGuideItem({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
