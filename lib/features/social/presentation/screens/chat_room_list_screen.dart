import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/chat_service.dart';
import '../providers/social_providers.dart';
import '../../../../core/shared_widgets/empty_state_widget.dart';
import '../../../../core/shared_widgets/shimmer_loading.dart';

class ChatRoomListScreen extends ConsumerStatefulWidget {
  const ChatRoomListScreen({super.key});

  @override
  ConsumerState<ChatRoomListScreen> createState() => _ChatRoomListScreenState();
}

class _ChatRoomListScreenState extends ConsumerState<ChatRoomListScreen> {
  final TextEditingController _roomNameController = TextEditingController();
  final TextEditingController _joinCodeController = TextEditingController();

  void _showCreateRoomDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Tạo phòng mới', style: GoogleFonts.lexend(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: _roomNameController,
          decoration: const InputDecoration(
            hintText: 'Tên phòng (VD: TOEIC 900+)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = _roomNameController.text.trim();
              if (name.isEmpty) return;
              
              final uid = ref.read(currentUserProvider).value?.uid;
              if (uid == null) return;
              
              Navigator.pop(dialogContext); // Đóng popup tạo phòng
              
              try {
                final roomId = await ref.read(chatServiceProvider).createGroupRoom(name, uid);
                if (mounted) {
                  context.push('/social/chat/$roomId?name=${Uri.encodeComponent(name)}');
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            },
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
  }

  void _showJoinRoomDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Tham gia phòng', style: GoogleFonts.lexend(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: _joinCodeController,
          decoration: const InputDecoration(
            hintText: 'Nhập mã phòng (VD: A7X9BQ)',
          ),
          textCapitalization: TextCapitalization.characters,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final code = _joinCodeController.text.trim().toUpperCase();
              if (code.isEmpty) return;
              
              final uid = ref.read(currentUserProvider).value?.uid;
              if (uid == null) return;
              
              Navigator.pop(dialogContext);
              
              try {
                final roomId = await ref.read(chatServiceProvider).joinRoomByCode(code, uid);
                if (mounted) {
                  // Gọi ra ngoài danh sách, nó sẽ tự update nhờ StreamBuilder
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tham gia phòng thành công!')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            },
            child: const Text('Tham gia'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider).value;
    if (currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: StreamBuilder<List<ChatRoom>>(
        stream: ref.read(chatServiceProvider).getUserRooms(currentUser.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ShimmerLoadingList();
          }

          final rooms = snapshot.data ?? [];
          
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Danh sách phòng',
                      style: GoogleFonts.lexend(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.slate700,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.help_outline_rounded, color: AppColors.primary),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Row(
                              children: [
                                const Icon(Icons.info_outline_rounded, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text('Hướng dẫn', style: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 18)),
                              ],
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('• Rời phòng: Vuốt khung phòng chat từ phải sang trái.', style: GoogleFonts.lexend(height: 1.5)),
                                const SizedBox(height: 12),
                                Text('• Lấy mã phòng: Chạm trực tiếp vào nút mã (VD: Mã: B7X2) để tự động copy mã, sau đó gửi cho bạn bè.', style: GoogleFonts.lexend(height: 1.5)),
                                const SizedBox(height: 12),
                                Text('• Nhấn nút (+) ở góc dưới để tạo phòng, hoặc nút mũi tên để nhập mã tham gia phòng có sẵn.', style: GoogleFonts.lexend(height: 1.5)),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Đã hiểu', style: GoogleFonts.lexend()),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: rooms.isEmpty
                    ? const EmptyStateWidget(
                        title: 'Chưa tham gia phòng nào',
                        message: 'Hãy bấm dấu (+) để tạo phòng mới\nhoặc dùng mũi tên để nhập mã phòng nhé!',
                        icon: Icons.forum_outlined,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: rooms.length,
                        itemBuilder: (context, index) {
                          final room = rooms[index];
              return Dismissible(
                key: ValueKey(room.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.logout_rounded, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Rời phòng?', style: GoogleFonts.lexend(fontWeight: FontWeight.bold)),
                      content: Text('Bạn có chắc chắn muốn rời khỏi phòng "${room.name}" không?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Hủy'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                          child: const Text('Rời đi', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (direction) async {
                  try {
                    await ref.read(chatServiceProvider).leaveRoom(room.id, currentUser.uid);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Đã rời khỏi phòng ${room.name}')),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  }
                },
                child: Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.slate200),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.groups_rounded, color: AppColors.primary),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          room.name,
                          style: GoogleFonts.lexend(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: room.joinCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã copy mã phòng!')),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.slate100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Mã: ${room.joinCode}',
                            style: GoogleFonts.lexend(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.slate600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      room.lastMessage.isEmpty ? 'Chưa có tin nhắn' : room.lastMessage,
                      style: GoogleFonts.lexend(color: AppColors.slate500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  onTap: () {
                    context.push('/social/chat/${room.id}?name=${Uri.encodeComponent(room.name)}');
                  },
                ),
              ));
            },
          ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'join',
            onPressed: _showJoinRoomDialog,
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
            child: const Icon(Icons.login_rounded),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'create',
            onPressed: _showCreateRoomDialog,
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}
