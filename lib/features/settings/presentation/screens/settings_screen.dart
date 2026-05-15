import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/shared_widgets/custom_app_bar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../library/presentation/controllers/library_controller.dart';
import '../../study/presentation/controllers/study_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showUpdateNameDialog(BuildContext context, WidgetRef ref, String currentName, String currentPhotoUrl) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Đổi tên hiển thị"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Nhập tên mới"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                final userService = ref.read(userServiceProvider);
                await userService.updateUserProfile(
                  displayName: newName,
                  photoUrl: currentPhotoUrl, // Giữ nguyên avatar hiện tại
                );
                // Refresh dữ liệu user
                ref.invalidate(currentUserProvider);
                if (context.mounted) Navigator.pop(context);
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
                  onTap: () => _showUpdateNameDialog(context, ref, user.displayName, user.photoUrl),
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          backgroundImage: user.photoUrl.isNotEmpty 
                            ? NetworkImage(user.photoUrl) 
                            : null,
                          child: user.photoUrl.isEmpty 
                            ? const Icon(Icons.person, size: 50, color: AppColors.primary) 
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
                          child: const Icon(Icons.edit, color: Colors.white, size: 18),
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
                      user.displayName.isNotEmpty ? user.displayName : "Người dùng VitaminC",
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textLight),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: TextStyle(fontSize: 14, color: AppColors.slate500),
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
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text("Đăng xuất", style: TextStyle(color: Colors.red)),
                onTap: () async {
                  // Xóa cache (trạng thái) của các màn hình/tính năng
                  ref.invalidate(libraryControllerProvider);
                  ref.invalidate(studyControllerProvider);
                  // TODO: ref.invalidate(localDbProvider); khi Member 3 tạo xong Local DB

                  // Thực hiện đăng xuất
                  await ref.read(authRepositoryProvider).signOut();
                },
              ),
            ],
          ),
    );
  }
}
