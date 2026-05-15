import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../controllers/library_controller.dart';
import '../library_providers.dart';
import '../../data/models/deck_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

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
                  Navigator.pop(ctx);
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
    final userAsync = ref.watch(currentUserProvider);
    final isAdmin = userAsync.value?.role == 'admin';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.backgroundLight,
          elevation: 0,
          title: const Text(
            'Thư viện',
            style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
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
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.slate500,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Cá nhân'),
              Tab(text: 'Mẫu (Cộng đồng)'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPersonalDecks(context, ref, state, controller, isAdmin),
            _buildGlobalDecks(context, ref),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primary,
          onPressed: () => _showAddDeckDialog(context, ref),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildPersonalDecks(BuildContext context, WidgetRef ref, LibraryState state, LibraryController controller, bool isAdmin) {
    return RefreshIndicator(
      onRefresh: () => controller.loadDecks(),
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
                        onTap: () => context.push('/deck-detail', extra: deck.id),
                        onLongPress: () => _showEditDeckDialog(context, ref, deck),
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
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
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
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Xóa bộ thẻ?'),
                                        content: const Text('Tất cả từ vựng trong bộ này cũng sẽ bị xóa.'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
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
                              if (isAdmin && !isEmpty)
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  child: IconButton(
                                    icon: const Icon(Icons.public, color: AppColors.primary, size: 20),
                                    tooltip: 'Xuất bản thành Bộ thẻ Mẫu',
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Xuất bản bộ thẻ?'),
                                          content: const Text('Đưa bộ thẻ này lên kho mẫu chung cho tất cả người dùng?'),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
                                            ElevatedButton(
                                              onPressed: () async {
                                                Navigator.pop(ctx);
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Đang xuất bản...')),
                                                );
                                                try {
                                                  await ref.read(globalDeckServiceProvider).publishToGlobal(deck);
                                                  ref.invalidate(globalDecksProvider);
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(content: Text('Xuất bản thành công!')),
                                                    );
                                                  }
                                                } catch (e) {
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text('Lỗi: $e')),
                                                    );
                                                  }
                                                }
                                              },
                                              child: const Text('Xuất bản'),
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
    );
  }

  Widget _buildGlobalDecks(BuildContext context, WidgetRef ref) {
    final globalDecksAsync = ref.watch(globalDecksProvider);

    return globalDecksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Lỗi tải bộ thẻ mẫu: $e')),
      data: (decks) {
        if (decks.isEmpty) {
          return const Center(child: Text('Chưa có bộ thẻ mẫu nào từ Admin.'));
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(globalDecksProvider),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: decks.length,
            itemBuilder: (context, index) {
              final deck = decks[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.backgroundLight,
                    child: Icon(Icons.public, color: AppColors.primary),
                  ),
                  title: Text(deck.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: deck.description.isNotEmpty ? Text(deck.description) : null,
                  trailing: IconButton(
                    icon: const Icon(Icons.download, color: AppColors.primary),
                    tooltip: 'Tải về máy',
                    onPressed: () async {
                      // Hiển thị loading dialog có nền trắng rõ ràng
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (ctx) => const AlertDialog(
                          content: Row(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(width: 20),
                              Text('Đang tải bộ thẻ...'),
                            ],
                          ),
                        ),
                      );
                      try {
                        await ref.read(globalDeckServiceProvider).cloneToPersonal(deck);
                        ref.invalidate(libraryControllerProvider);
                        if (context.mounted) {
                          // Dùng rootNavigator để chắc chắn chỉ pop dialog, không pop màn hình
                          Navigator.of(context, rootNavigator: true).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã tải bộ thẻ về Thư viện cá nhân!')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          Navigator.of(context, rootNavigator: true).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Lỗi: $e')),
                          );
                        }
                      }
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
