import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Widget hiển thị lớp phủ phản hồi hình ảnh khi người dùng kéo thẻ flashcard.
///
/// - Kéo sang **phải**: phủ xanh lá + chữ "EASY"
/// - Kéo sang **trái**: phủ đỏ + chữ "HARD"
/// - Kéo **lên trên**: phủ xanh dương + chữ "GOOD"
///
/// Opacity tăng dần theo phần trăm ngưỡng (threshold) để tạo hiệu ứng
/// trực quan mượt mà, giúp người dùng cảm nhận "xúc giác" khi vuốt.
class SwipeOverlay extends StatelessWidget {
  /// Phần trăm ngưỡng ngang: -1.0 (trái) đến 1.0 (phải)
  final double percentThresholdX;

  /// Phần trăm ngưỡng dọc: -1.0 (lên) đến 1.0 (xuống)
  final double percentThresholdY;

  const SwipeOverlay({
    super.key,
    required this.percentThresholdX,
    required this.percentThresholdY,
  });

  @override
  Widget build(BuildContext context) {
    // Xác định hướng kéo chính (ngang hay dọc) dựa trên giá trị tuyệt đối
    final absX = percentThresholdX.abs();
    final absY = percentThresholdY.abs();

    // Chưa kéo đủ ngưỡng hiển thị → ẩn overlay
    if (absX < 0.1 && absY < 0.1) return const SizedBox.shrink();

    // Xác định loại đánh giá dựa trên hướng vuốt chiếm ưu thế
    final _SwipeType swipeType;
    final double intensity;

    if (absY > absX && percentThresholdY < -0.1) {
      // Kéo lên trên → GOOD
      swipeType = _SwipeType.good;
      intensity = absY.clamp(0.0, 1.0);
    } else if (absX >= absY && percentThresholdX > 0.1) {
      // Kéo sang phải → EASY
      swipeType = _SwipeType.easy;
      intensity = absX.clamp(0.0, 1.0);
    } else if (absX >= absY && percentThresholdX < -0.1) {
      // Kéo sang trái → HARD
      swipeType = _SwipeType.hard;
      intensity = absX.clamp(0.0, 1.0);
    } else {
      return const SizedBox.shrink();
    }

    // Cấu hình hiệu ứng theo loại đánh giá
    final Color overlayColor;
    final String label;
    final double rotationAngle;
    final Alignment labelAlignment;

    switch (swipeType) {
      case _SwipeType.easy:
        overlayColor = AppColors.success;
        label = 'EASY';
        rotationAngle = -0.3;
        labelAlignment = Alignment.topLeft;
        break;
      case _SwipeType.hard:
        overlayColor = AppColors.error;
        label = 'HARD';
        rotationAngle = 0.3;
        labelAlignment = Alignment.topRight;
        break;
      case _SwipeType.good:
        overlayColor = AppColors.primary;
        label = 'GOOD';
        rotationAngle = 0.0;
        labelAlignment = Alignment.topCenter;
        break;
    }

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: overlayColor.withValues(alpha: intensity * 0.25),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Align(
          alignment: labelAlignment,
          child: Padding(
            padding: const EdgeInsets.only(top: 40, left: 24, right: 24),
            child: Transform.rotate(
              angle: rotationAngle,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: overlayColor.withValues(alpha: min(intensity * 1.5, 1.0)),
                    width: 4,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: overlayColor.withValues(alpha: intensity * 0.15),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: overlayColor.withValues(alpha: min(intensity * 1.5, 1.0)),
                    letterSpacing: 4,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Enum nội bộ phân loại hướng vuốt
enum _SwipeType { easy, hard, good }
