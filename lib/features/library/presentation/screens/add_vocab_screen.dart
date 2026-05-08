import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/shared_widgets/custom_app_bar.dart';
import '../../../../core/shared_widgets/custom_text_field.dart';
import '../../../../core/shared_widgets/custom_button.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vitaminc/features/library/data/models/vocab_model.dart';
import 'package:vitaminc/features/library/presentation/library_providers.dart';

class AddVocabScreen extends ConsumerStatefulWidget {
  final String deckId;
  const AddVocabScreen({super.key, required this.deckId});

  @override
  ConsumerState<AddVocabScreen> createState() => _AddVocabScreenState();
}

class _AddVocabScreenState extends ConsumerState<AddVocabScreen> {
  final _wordController = TextEditingController();
  final _meaningController = TextEditingController();
  final _exampleController = TextEditingController();
  bool isPublic = false;
  bool _isLoading = false;

  Future<void> _saveVocab() async {
    final word = _wordController.text.trim();
    final meaning = _meaningController.text.trim();
    final example = _exampleController.text.trim();

    if (word.isEmpty || meaning.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập từ vựng và nghĩa!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final libraryService = ref.read(libraryServiceProvider);
      final newVocab = VocabModel(
        id: '', // Service sẽ tự tạo ID
        deckId: widget.deckId,
        word: word,
        meaning: meaning,
        example: example.isEmpty ? null : example,
        nextReview: Timestamp.now(),
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );

      await libraryService.addVocab(newVocab);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã thêm từ vựng thành công!')),
        );
        context.pop(); // Trở về màn hình trước
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _wordController.dispose();
    _meaningController.dispose();
    _exampleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Add new vocabulary',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              controller: _wordController,
              hintText: 'Vocabulary (English)...',
              prefixIcon: Icons.abc,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _meaningController,
              hintText: 'Meaning (Vietnamese)...',
              prefixIcon: Icons.g_translate,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _exampleController,
              hintText: 'Example sentence...',
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
                    'Add Image',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.mic, color: AppColors.primary),
                  label: const Text(
                    'Record Audio',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Nút gạt chia sẻ
            SwitchListTile(
              title: const Text(
                'Share publicly',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Allow others to find this word',
                style: TextStyle(color: AppColors.textLight),
              ),
              activeColor: AppColors.primary,
              value: isPublic,
              onChanged: (val) => setState(() => isPublic = val),
            ),
            const SizedBox(height: 32),

            // Nút Lưu chuẩn của Team
            _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : CustomPrimaryButton(
                    text: 'SAVE VOCABULARY',
                    onPressed: _saveVocab,
                  ),
          ],
        ),
      ),
    );
  }
}
