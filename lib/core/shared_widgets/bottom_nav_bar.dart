import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';

final navIndexProvider = StateProvider<int>((ref) => 0);

class MainBottomNavBar extends ConsumerWidget {
  const MainBottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(navIndexProvider);

    return BottomNavigationBar(
      currentIndex: index,
      onTap: (newIndex) {
        ref.read(navIndexProvider.notifier).state = newIndex;
        switch (newIndex) {
          case 0: context.go('/home'); break;
          case 1: context.go('/library'); break;
          case 2: context.go('/social'); break;
          case 3: context.go('/settings'); break;
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: const Color(0xFF94A3B8), // Đổi từ Colors.slate thành mã Hex
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Library'),
        BottomNavigationBarItem(icon: Icon(Icons.groups_rounded), label: 'Social'),
        BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
      ],
    );
  }
}