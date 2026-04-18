import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/dummy_data.dart';
import '../../../../../core/shared_widgets/custom_app_bar.dart';

class DeckListScreen extends StatelessWidget {
  const DeckListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Giả sử DummyData có list decks
    final decks = DummyData.decks;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Thư viện của tôi',
        showBackButton: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.9,
          ),
          itemCount: decks.length,
          itemBuilder: (context, index) {
            final deck = decks[index];
            return GestureDetector(
              onTap: () {
                // Chuyển sang màn hình lật thẻ của bộ này
                context.push('/study');
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.style, size: 48, color: AppColors.primary),
                    const SizedBox(height: 12),
                    Text(
                      deck['title'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${deck['count']} từ vựng',
                      style: const TextStyle(color: AppColors.textLight),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          // Điều hướng sang form thêm từ mới
          context.push('/add-vocab');
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
