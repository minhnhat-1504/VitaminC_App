import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/shared_widgets/custom_app_bar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:vitaminc/features/library/presentation/controllers/library_controller.dart';
import 'package:vitaminc/features/study/presentation/controllers/study_controller.dart';
import 'package:vitaminc/core/services/local_db_provider.dart';
import 'package:vitaminc/core/services/notification_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showUpdateNameDialog(
    BuildContext context,
    WidgetRef ref,
    String currentName,
    String currentPhotoUrl,
  ) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Đổi tên hiển thị"),
        content: TextField(
          controller: controller,
          maxLength: 20,
          decoration: const InputDecoration(
            hintText: "Nhập tên mới",
            counterStyle: TextStyle(fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                if (newName.length > 20) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Tên hiển thị không được vượt quá 20 ký tự',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                // Đóng dialog ngay lập tức để tránh trì hoãn giao diện
                Navigator.pop(dialogContext);

                try {
                  final userService = ref.read(userServiceProvider);
                  await userService.updateUserProfile(
                    displayName: newName,
                    photoUrl: currentPhotoUrl, // Giữ nguyên avatar hiện tại
                  );
                  // Refresh dữ liệu user
                  ref.invalidate(currentUserProvider);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Lỗi cập nhật tên: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text("Lưu"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.value;

    return Scaffold(
      appBar: const CustomAppBar(title: "Hồ sơ cá nhân"),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: GestureDetector(
                    onTap: () => _showUpdateNameDialog(
                      context,
                      ref,
                      user.displayName,
                      user.photoUrl,
                    ),
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.2),
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            backgroundImage: user.photoUrl.isNotEmpty
                                ? NetworkImage(user.photoUrl)
                                : null,
                            child: user.photoUrl.isEmpty
                                ? const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: AppColors.primary,
                                  )
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      Text(
                        user.displayName.isNotEmpty
                            ? user.displayName
                            : "Người dùng VitaminC",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.slate500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                ListTile(
                  leading: const Icon(Icons.dark_mode),
                  title: const Text("Chế độ tối"),
                  trailing: Switch(value: false, onChanged: (val) {}),
                ),
                const ListTile(
                  leading: Icon(Icons.notifications),
                  title: Text("Thông báo nhắc học"),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                ),
                ListTile(
                  leading: const Icon(Icons.mic_rounded),
                  title: const Text('Kiểm thử phát âm'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push('/pronunciation'),
                ),
                ListTile(
                  leading: const Icon(Icons.chat_bubble_outline),
                  title: const Text('Trợ lý AI (Chatbot)'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push('/chatbot'),
                ),
                ListTile(
                  leading: const Icon(Icons.document_scanner_outlined),
                  title: const Text('Quét từ vựng (OCR)'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push('/ocr'),
                ),
                ListTile(
                  leading: const Icon(Icons.sync, color: Colors.blue),
                  title: const Text(
                    'Test Đồng bộ Local DB (Task 1)',
                    style: TextStyle(color: Colors.blue),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.blue,
                  ),
                  onTap: () async {
                    try {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đang đồng bộ...')),
                      );
                      await ref
                          .read(localDbServiceProvider)
                          .syncVocabsFromFirestore(user.uid);

                      final count = ref
                          .read(localDbServiceProvider)
                          .getLocalDueCards()
                          .length;
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Đồng bộ thành công! Số thẻ Local: $count',
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Lỗi đồng bộ: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.notifications_active, color: Colors.orange),
                  title: const Text(
                    'Test Thông báo Deep Link (15s)',
                    style: TextStyle(color: Colors.orange),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.orange,
                  ),
                  onTap: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã hẹn giờ! Hãy bấm nút Home thoát app ngay, đợi 15 giây!'),
                        duration: Duration(seconds: 5),
                      ),
                    );
                    await NotificationService().scheduleTestNotification();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    "Đăng xuất",
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () async {
                    // Xóa cache (trạng thái) của các màn hình/tính năng
                    ref.invalidate(libraryControllerProvider);
                    ref.invalidate(studyControllerProvider);
                    ref.invalidate(currentUserProvider);

                    // Xóa Local DB
                    await ref.read(localDbServiceProvider).clearAllData();

                    // Thực hiện đăng xuất
                    await ref.read(authRepositoryProvider).signOut();
                  },
                ),
              ],
            ),
    );
  }
}
