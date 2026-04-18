import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';

final navIndexProvider = StateProvider<int>((ref) => 0);

class MainBottomNavBar extends ConsumerWidget {
  const MainBottomNavBar({super.key});

  // Hàm tính toán vị trí tab hiện tại dựa vào đường dẫn (URL) thực tế của app
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/library')) return 1;
    if (location.startsWith('/social')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0; // Mặc định
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = _calculateSelectedIndex(context);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (newIndex) {
        // Vẫn cập nhật Provider để đồng bộ state chung
        ref.read(navIndexProvider.notifier).state = newIndex;

        switch (newIndex) {
          case 0:
            context.go('/home');
            break;
          case 1:
            context.go('/library');
            break;
          case 2:
            context.go('/social');
            break;
          case 3:
            context.go('/settings');
            break;
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: const Color(0xFF94A3B8),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.grid_view_rounded),
          label: 'Library',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.groups_rounded),
          label: 'Social',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    );
  }
}
