import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vitaminc/core/constants/app_colors.dart';
import 'package:vitaminc/core/shared_widgets/custom_button.dart';
import 'package:vitaminc/features/auth/presentation/providers/auth_provider.dart';
import 'package:vitaminc/features/social/presentation/providers/quest_provider.dart';

class LuckySpinScreen extends ConsumerStatefulWidget {
  const LuckySpinScreen({super.key});

  @override
  ConsumerState<LuckySpinScreen> createState() => _LuckySpinScreenState();
}

class _LuckySpinScreenState extends ConsumerState<LuckySpinScreen> {
  final StreamController<int> _selected = StreamController<int>();
  bool _isSpinning = false;
  bool _hasSpun = false;
  int _selectedIndex = 0;

  final List<String> _items = [
    '+10 XP',
    '+50 XP',
    '+100 XP',
    'Huy hiệu',
    '+20 XP',
    'Thử lại nhé',
  ];

  final List<Color> _colors = [
    AppColors.primary,
    AppColors.warning,
    AppColors.success,
    AppColors.gold,
    AppColors.slate600,
    AppColors.error,
  ];

  // Tỉ lệ % trúng thưởng tương ứng với các phần tử trong _items
  final List<int> _weights = [
    40, // +10 XP (40%)
    10, // +50 XP (10%)
    4, // +100 XP (4%)
    1, // Huy hiệu May mắn (1%)
    20, // +20 XP (20%)
    25, // Thử lại nhé (25%)
  ];

  @override
  void dispose() {
    _selected.close();
    super.dispose();
  }

  int _getWeightedRandomIndex() {
    int totalWeight = _weights.fold(0, (sum, weight) => sum + weight);
    int randomValue = Random().nextInt(totalWeight);
    int currentWeight = 0;

    for (int i = 0; i < _weights.length; i++) {
      currentWeight += _weights[i];
      if (randomValue < currentWeight) {
        return i;
      }
    }
    return 0; // Trả về an toàn nếu có lỗi
  }

  void _spinWheel() {
    if (_isSpinning || _hasSpun) return;

    setState(() {
      _isSpinning = true;
      _selectedIndex = _getWeightedRandomIndex();
    });

    _selected.add(_selectedIndex);
  }

  void _onSpinComplete() async {
    final reward = _items[_selectedIndex];

    // Process reward
    int xpToAdd = 0;
    if (reward == '+10 XP') xpToAdd = 10;
    if (reward == '+20 XP') xpToAdd = 20;
    if (reward == '+50 XP') xpToAdd = 50;
    if (reward == '+100 XP') xpToAdd = 100;

    final user = ref.read(authStateProvider).value;

    if (xpToAdd > 0 && user != null) {
      try {
        await ref.read(userServiceProvider).addXP(user.uid, xpToAdd);

        // Cập nhật nhiệm vụ hàng ngày (Quay vòng quay)
        await ref
            .read(questServiceProvider)
            .updateQuestProgress(user.uid, 'daily_spin', 1);

        if (mounted) {
          // Buộc refresh lại provider để đảm bảo UI nhận XP mới nhất
          ref.invalidate(currentUserProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Chúc mừng! Bạn nhận được $xpToAdd XP'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Có lỗi xảy ra: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } else {
      // Cập nhật nhiệm vụ hàng ngày ngay cả khi không trúng XP (Try again / Badge)
      if (user != null) {
        await ref
            .read(questServiceProvider)
            .updateQuestProgress(user.uid, 'daily_spin', 1);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              reward == 'Thử lại nhé'
                  ? 'Chúc bạn may mắn lần sau!'
                  : 'Chúc mừng! Bạn nhận được $reward',
            ),
            backgroundColor: reward == 'Thử lại nhé'
                ? AppColors.slate600
                : AppColors.gold,
          ),
        );
      }
    }

    setState(() {
      _isSpinning = false;
      _hasSpun = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Vòng Quay May Mắn',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Phần thưởng cho sự nỗ lực của bạn!',
              style: TextStyle(color: AppColors.slate500),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 300,
              child: FortuneWheel(
                selected: _selected.stream,
                animateFirst: false,
                items: [
                  for (int i = 0; i < _items.length; i++)
                    FortuneItem(
                      child: Text(
                        _items[i],
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      style: FortuneItemStyle(
                        color: _colors[i],
                        borderColor: AppColors.slate800,
                        borderWidth: 2,
                      ),
                    ),
                ],
                onAnimationEnd: _onSpinComplete,
              ),
            ),
            const SizedBox(height: 32),
            CustomPrimaryButton(
              text: _hasSpun
                  ? 'Đóng'
                  : (_isSpinning ? 'Đang quay...' : 'Quay ngay'),
              onPressed: () {
                if (_hasSpun) {
                  Navigator.of(context).pop();
                } else if (!_isSpinning) {
                  _spinWheel();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
