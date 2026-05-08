import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/shared_widgets/custom_app_bar.dart';
import '../controllers/library_controller.dart';
import '../../data/models/deck_model.dart';
import 'package:vitaminc/features/library/presentation/screens/add_vocab_screen.dart';

class DeckListScreen extends ConsumerWidget {
  const DeckListScreen({super.key});

  void _showEditDeckDialog(BuildContext context, WidgetRef ref, DeckModel deck, {bool isNew = false}) {
    final titleController = TextEditingController(text: deck.title);
    final descController = TextEditingController(text: deck.description);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(isNew ? 'New Deck Created' : 'Edit Deck'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Deck Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          if (!isNew)
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
          ElevatedButton(
            onPressed: () {
              final updated = deck.copyWith(
                title: titleController.text.trim(),
                description: descController.text.trim(),
              );
              ref.read(libraryControllerProvider.notifier).updateDeck(updated).then((_) {
                final error = ref.read(libraryControllerProvider).errorMessage;
                if (error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                } else {
                  Navigator.pop(ctx);
                }
              });
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddDeckDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create New Deck'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Deck Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              if (title.isNotEmpty) {
                final newDeck = await ref.read(libraryControllerProvider.notifier).addDeck(title, descController.text.trim());
                
                if (!context.mounted) return;
                
                final error = ref.read(libraryControllerProvider).errorMessage;
                if (error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                } else if (newDeck != null) {
                  Navigator.pop(ctx); // Đóng Dialog
                  // Chuyển luôn sang trang chi tiết để thêm từ
                  context.push('/deck-detail', extra: newDeck.id);
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(libraryControllerProvider);
    final controller = ref.read(libraryControllerProvider.notifier);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'My Library',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload, color: AppColors.primary),
            tooltip: 'Import Excel',
            onPressed: () async {
              final newDeck = await controller.importExcel();
              if (context.mounted) {
                final currentState = ref.read(libraryControllerProvider);
                if (currentState.errorMessage == null && newDeck != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Import dữ liệu thành công!')),
                  );
                  // Hiện form cho người dùng sửa tên bộ thẻ vừa import
                  _showEditDeckDialog(context, ref, newDeck, isNew: true);
                } else if (currentState.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi: ${currentState.errorMessage}')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(libraryControllerProvider.notifier).loadDecks(),
        child: state.isLoading && state.decks.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : state.decks.isEmpty
                ? const Center(child: Text('Bạn chưa có Bộ thẻ nào. Bấm dấu + hoặc Import Excel nhé!'))
                : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: state.decks.length,
                    itemBuilder: (context, index) {
                      final deck = state.decks[index];
                      final dueCount = state.dueCardsCount[deck.id] ?? 0;
                      final totalCount = state.totalCardsCount[deck.id] ?? 0;
                      
                      final isEmpty = totalCount == 0;
                      final isFinished = dueCount == 0 && !isEmpty;

                      return GestureDetector(
                        onTap: () {
                          context.push('/deck-detail', extra: deck.id);
                        },
                        onLongPress: () {
                          _showEditDeckDialog(context, ref, deck);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isFinished ? Colors.white : AppColors.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isFinished ? Colors.grey.withOpacity(0.2) : AppColors.primary.withOpacity(0.5),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isEmpty ? Icons.hourglass_empty 
                                              : (isFinished ? Icons.check_circle : Icons.style), 
                                      size: 40, 
                                      color: isEmpty ? Colors.grey : AppColors.primary,
                                    ),
                                    const SizedBox(height: 12),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                      child: Text(
                                        deck.title,
                                        style: TextStyle(
                                          fontSize: 20, // To rõ và dễ nhìn hơn
                                          fontWeight: FontWeight.w800, // Đậm nét hơn
                                          color: isEmpty ? Colors.grey.shade700 : AppColors.slate900,
                                          letterSpacing: 0.5,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isEmpty ? Colors.grey.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        isEmpty ? 'Chưa có thẻ' : (isFinished ? 'Đã học xong' : '$dueCount thẻ cần học'),
                                        style: TextStyle(
                                          color: isEmpty ? Colors.grey.shade600 : AppColors.primary, 
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                  onPressed: () {
                                    // Xác nhận xóa
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Xóa bộ thẻ?'),
                                        content: const Text('Tất cả từ vựng trong bộ này cũng sẽ bị xóa.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx),
                                            child: const Text('Hủy'),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                            onPressed: () {
                                              controller.deleteDeck(deck.id);
                                              Navigator.pop(ctx);
                                            },
                                            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddDeckDialog(context, ref),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
