import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vitaminc/core/constants/app_colors.dart';
import 'package:vitaminc/core/shared_widgets/custom_app_bar.dart';
import 'package:vitaminc/features/library/presentation/controllers/deck_detail_controller.dart';
import 'package:vitaminc/features/library/presentation/controllers/library_controller.dart';

class DeckDetailScreen extends ConsumerWidget {
  final String deckId;

  const DeckDetailScreen({super.key, required this.deckId});

  void _showEditDeckDialog(BuildContext context, WidgetRef ref, dynamic deck) {
    final titleController = TextEditingController(text: deck.title);
    final descController = TextEditingController(text: deck.description);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sửa Bộ Thẻ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Tên bộ thẻ')),
            const SizedBox(height: 10),
            TextField(controller: descController, decoration: const InputDecoration(labelText: 'Mô tả')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              final updated = deck.copyWith(
                title: titleController.text.trim(),
                description: descController.text.trim(),
              );
              ref.read(libraryControllerProvider.notifier).updateDeck(updated).then((_) {
                final error = ref.read(libraryControllerProvider).errorMessage;
                if (error != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                } else if (context.mounted) {
                  Navigator.pop(ctx);
                }
              });
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showEditVocabDialog(BuildContext context, WidgetRef ref, dynamic vocab, String deckId) {
    final wordController = TextEditingController(text: vocab.word);
    final meaningController = TextEditingController(text: vocab.meaning);
    final exampleController = TextEditingController(text: vocab.example ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sửa Từ Vựng'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: wordController, decoration: const InputDecoration(labelText: 'Từ vựng (Tiếng Anh)')),
              const SizedBox(height: 10),
              TextField(controller: meaningController, decoration: const InputDecoration(labelText: 'Nghĩa (Tiếng Việt)')),
              const SizedBox(height: 10),
              TextField(controller: exampleController, decoration: const InputDecoration(labelText: 'Ví dụ')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              final word = wordController.text.trim();
              final meaning = meaningController.text.trim();
              if (word.isEmpty || meaning.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập đủ từ và nghĩa!')));
                return;
              }
              final updated = vocab.copyWith(
                word: word,
                meaning: meaning,
                example: exampleController.text.trim().isEmpty ? null : exampleController.text.trim(),
              );
              ref.read(deckDetailControllerProvider(deckId).notifier).updateVocab(updated);
              Navigator.pop(ctx);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deckDetailControllerProvider(deckId));
    final controller = ref.read(deckDetailControllerProvider(deckId).notifier);

    // Lấy thông tin bộ thẻ từ LibraryController để hiển thị Title
    final libraryState = ref.watch(libraryControllerProvider);
    final deck = libraryState.decks.firstWhere(
      (d) => d.id == deckId,
      // Nếu không tìm thấy, tạo một model rỗng để tránh lỗi null
      orElse: () => throw Exception('Không tìm thấy bộ thẻ'),
    );

    return Scaffold(
      appBar: CustomAppBar(
        title: deck.title,
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.primary),
            onPressed: () => _showEditDeckDialog(context, ref, deck),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.vocabs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_open, size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      const Text('Bộ thẻ này đang trống!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('Hãy nhấn dấu + để thêm từ vựng nhé', style: TextStyle(color: AppColors.textLight)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 100, top: 16, left: 16, right: 16),
                  itemCount: state.vocabs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final vocab = state.vocabs[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Text(
                          vocab.word,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(vocab.meaning, style: TextStyle(color: Colors.grey.shade700, fontSize: 15)),
                            if (vocab.example != null && vocab.example!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text('Ví dụ: ${vocab.example}', style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                            ]
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                              onPressed: () => _showEditVocabDialog(context, ref, vocab, deckId),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Xóa từ vựng này?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                        onPressed: () {
                                          controller.deleteVocab(vocab.id);
                                          Navigator.pop(ctx);
                                        },
                                        child: const Text('Xóa', style: TextStyle(color: Colors.white)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () async {
          // Sang trang thêm từ, chờ nó quay lại thì reload
          await context.push('/add-vocab', extra: deckId);
          ref.read(deckDetailControllerProvider(deckId).notifier).loadVocabs();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: state.vocabs.isEmpty
                ? null
                : () {
                    context.push('/study', extra: deckId);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text(
              'BẮT ĐẦU HỌC',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),
            ),
          ),
        ),
      ),
    );
  }
}
