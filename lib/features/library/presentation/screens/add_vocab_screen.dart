import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/shared_widgets/custom_app_bar.dart';
import '../../../../core/shared_widgets/custom_text_field.dart';
import '../../../../core/shared_widgets/custom_button.dart';

class AddVocabScreen extends StatefulWidget {
  const AddVocabScreen({super.key});

  @override
  State<AddVocabScreen> createState() => _AddVocabScreenState();
}

class _AddVocabScreenState extends State<AddVocabScreen> {
  bool isPublic = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Thêm từ vựng mới',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomTextField(
              hintText: 'Từ vựng (Tiếng Anh)...',
              prefixIcon: Icons.abc,
            ),
            const SizedBox(height: 16),
            const CustomTextField(
              hintText: 'Nghĩa (Tiếng Việt)...',
              prefixIcon: Icons.g_translate,
            ),
            const SizedBox(height: 16),
            const CustomTextField(
              hintText: 'Câu ví dụ...',
              prefixIcon: Icons.notes,
            ),
            const SizedBox(height: 24),

            // Cụm nút thêm Media
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.camera_alt, color: AppColors.primary),
                  label: const Text(
                    'Thêm ảnh',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.mic, color: AppColors.primary),
                  label: const Text(
                    'Thu âm',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Nút gạt chia sẻ
            SwitchListTile(
              title: const Text(
                'Chia sẻ công khai',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Cho phép người khác tìm thấy từ này',
                style: TextStyle(color: AppColors.textLight),
              ),
              activeColor: AppColors.primary,
              value: isPublic,
              onChanged: (val) => setState(() => isPublic = val),
            ),
            const SizedBox(height: 32),

            // Nút Lưu chuẩn của Team
            CustomPrimaryButton(
              text: 'LƯU TỪ VỰNG',
              onPressed: () {
                // Xử lý lưu và quay lại
                // context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
