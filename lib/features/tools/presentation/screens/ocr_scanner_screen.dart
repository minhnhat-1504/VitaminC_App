import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/shared_widgets/custom_app_bar.dart';
import '../../../library/presentation/library_providers.dart';
import '../../../library/data/models/deck_model.dart';

class OcrScannerScreen extends ConsumerStatefulWidget {
  const OcrScannerScreen({super.key});

  @override
  ConsumerState<OcrScannerScreen> createState() => _OcrScannerScreenState();
}

class _OcrScannerScreenState extends ConsumerState<OcrScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer();

  File? _imageFile;
  bool _isProcessing = false;
  String? _errorMessage;

  // Kích thước ảnh gốc (từ file thật)
  double _imageWidth = 0;
  double _imageHeight = 0;

  // Danh sách các element (từng từ) đã nhận diện
  List<TextElement> _elements = [];

  // ─── CHỤP ẢNH ───

  Future<void> _captureImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
      );
      if (pickedFile == null) return;

      setState(() {
        _imageFile = File(pickedFile.path);
        _elements = [];
        _errorMessage = null;
        _isProcessing = true;
      });

      // Đọc kích thước ảnh gốc
      final bytes = await _imageFile!.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      _imageWidth = frame.image.width.toDouble();
      _imageHeight = frame.image.height.toDouble();
      frame.image.dispose();

      // Nhận diện chữ
      final inputImage = InputImage.fromFile(_imageFile!);
      final recognized = await _textRecognizer.processImage(inputImage);

      // Thu thập tất cả elements (từng từ) từ mọi block → line
      final List<TextElement> allElements = [];
      for (final block in recognized.blocks) {
        for (final line in block.lines) {
          allElements.addAll(line.elements);
        }
      }

      setState(() {
        _elements = allElements;
        _isProcessing = false;
        if (allElements.isEmpty) {
          _errorMessage =
              'Không tìm thấy chữ nào trong ảnh.\nThử chụp lại rõ hơn nhé!';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể chụp ảnh. Kiểm tra quyền Camera.';
        _isProcessing = false;
      });
    }
  }

  // ─── CHỌN ẢNH TỪ THƯ VIỆN ───

  Future<void> _pickFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
      );
      if (pickedFile == null) return;

      setState(() {
        _imageFile = File(pickedFile.path);
        _elements = [];
        _errorMessage = null;
        _isProcessing = true;
      });

      final bytes = await _imageFile!.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      _imageWidth = frame.image.width.toDouble();
      _imageHeight = frame.image.height.toDouble();
      frame.image.dispose();

      final inputImage = InputImage.fromFile(_imageFile!);
      final recognized = await _textRecognizer.processImage(inputImage);

      final List<TextElement> allElements = [];
      for (final block in recognized.blocks) {
        for (final line in block.lines) {
          allElements.addAll(line.elements);
        }
      }

      setState(() {
        _elements = allElements;
        _isProcessing = false;
        if (allElements.isEmpty) {
          _errorMessage =
              'Không tìm thấy chữ nào trong ảnh.\nThử chọn ảnh khác nhé!';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể mở thư viện ảnh.';
        _isProcessing = false;
      });
    }
  }

  // ─── KHI USER TAP VÀO MỘT ELEMENT ───

  void _onElementTapped(TextElement element) {
    // Lọc sạch: bỏ ký tự đặc biệt đầu/cuối
    final word = element.text.replaceAll(RegExp(r'^[^\w]+|[^\w]+$'), '');
    if (word.isEmpty) return;
    _showDeckPickerDialog(word);
  }

  // ─── CHỌN BỘ THẺ ───

  Future<void> _showDeckPickerDialog(String word) async {
    try {
      final libraryService = ref.read(libraryServiceProvider);
      final decks = await libraryService.getDecks();

      if (!mounted) return;

      if (decks.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bạn chưa có Bộ thẻ nào. Hãy tạo một Bộ thẻ trước!'),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }

      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => _DeckPickerSheet(
          word: word,
          decks: decks,
          onDeckSelected: (deck) {
            Navigator.pop(ctx);
            context.push(
              '/add-vocab',
              extra: {'deckId': deck.id, 'word': word},
            );
          },
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi tải danh sách bộ thẻ: $e')));
      }
    }
  }

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }

  // ──────────────────────────────────────────────
  // BUILD UI
  // ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: const CustomAppBar(
        title: 'Quét từ vựng (OCR)',
        showBackButton: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: _imageFile == null
                ? _buildPlaceholder()
                : _buildImageOverlay(),
          ),
          _buildActionBar(),
        ],
      ),
    );
  }

  // ─── PLACEHOLDER ───

  Widget _buildPlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.document_scanner_outlined,
                size: 56,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Chụp ảnh tài liệu để quét từ vựng',
              style: GoogleFonts.lexend(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Chạm vào từ trên ảnh để thêm nhanh\nvào bộ thẻ của bạn',
              style: GoogleFonts.lexend(
                fontSize: 14,
                color: AppColors.slate400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ─── ẢNH + OVERLAY TỪNG ELEMENT ───

  Widget _buildImageOverlay() {
    if (_isProcessing) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text('Đang nhận diện chữ...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 56,
                color: AppColors.warning,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  color: AppColors.slate500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: _captureImage,
                icon: const Icon(Icons.refresh),
                label: const Text('Chụp lại'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Gợi ý
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: AppColors.primary.withValues(alpha: 0.08),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.touch_app, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Chạm vào từ trên ảnh để thêm vào bộ thẻ',
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),

        // Ảnh + overlay (có thể zoom)
        Expanded(
          child: InteractiveViewer(
            minScale: 0.8,
            maxScale: 4.0,
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (_imageWidth == 0 || _imageHeight == 0) {
                    return const SizedBox.shrink();
                  }

                  // Tính kích thước ảnh hiển thị (BoxFit.contain)
                  final imageAspect = _imageWidth / _imageHeight;
                  final containerAspect =
                      constraints.maxWidth / constraints.maxHeight;

                  double displayW, displayH;
                  if (imageAspect > containerAspect) {
                    displayW = constraints.maxWidth;
                    displayH = displayW / imageAspect;
                  } else {
                    displayH = constraints.maxHeight;
                    displayW = displayH * imageAspect;
                  }

                  final scaleX = displayW / _imageWidth;
                  final scaleY = displayH / _imageHeight;

                  return SizedBox(
                    width: displayW,
                    height: displayH,
                    child: Stack(
                      children: [
                        // Ảnh nền (vừa khít SizedBox)
                        Positioned.fill(
                          child: Image.file(_imageFile!, fit: BoxFit.fill),
                        ),

                        // Overlay từng element (từ)
                        ..._elements.map((el) {
                          final r = el.boundingBox;
                          return Positioned(
                            left: r.left * scaleX,
                            top: r.top * scaleY,
                            width: r.width * scaleX,
                            height: r.height * scaleY,
                            child: GestureDetector(
                              onTap: () => _onElementTapped(el),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.15,
                                  ),
                                  border: Border.all(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.5,
                                    ),
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── THANH NÚT ───

  Widget _buildActionBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _captureImage,
              icon: const Icon(Icons.camera_alt_rounded, size: 22),
              label: Text(
                'Chụp ảnh',
                style: GoogleFonts.lexend(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _pickFromGallery,
              icon: const Icon(Icons.photo_library_rounded, size: 22),
              label: Text(
                'Thư viện',
                style: GoogleFonts.lexend(fontWeight: FontWeight.w700),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                foregroundColor: AppColors.textLight,
                side: const BorderSide(color: AppColors.slate300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// BOTTOM SHEET: CHỌN BỘ THẺ (DECK)
// ──────────────────────────────────────────────

class _DeckPickerSheet extends StatelessWidget {
  final String word;
  final List<DeckModel> decks;
  final ValueChanged<DeckModel> onDeckSelected;

  const _DeckPickerSheet({
    required this.word,
    required this.decks,
    required this.onDeckSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.slate300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Thêm "$word" vào bộ thẻ:',
            style: GoogleFonts.lexend(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 16),

          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.35,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: decks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, index) {
                final deck = decks[index];
                return ListTile(
                  onTap: () => onDeckSelected(deck),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.slate200),
                  ),
                  tileColor: const Color(0xFFF8FAFC),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.folder_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  title: Text(
                    deck.title,
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: deck.description.isNotEmpty
                      ? Text(
                          deck.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.lexend(
                            fontSize: 12,
                            color: AppColors.slate400,
                          ),
                        )
                      : null,
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.slate400,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
