import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/shared_widgets/custom_app_bar.dart';
import '../../data/speech_service.dart';

class PronunciationScreen extends ConsumerStatefulWidget {
  const PronunciationScreen({super.key});

  @override
  ConsumerState<PronunciationScreen> createState() =>
      _PronunciationScreenState();
}

class _PronunciationScreenState extends ConsumerState<PronunciationScreen>
    with SingleTickerProviderStateMixin {
  // ─── Dữ liệu mẫu cho các bài luyện tập ───
  static const List<Map<String, String>> _exercises = [
    {
      'phrase': 'Hello, how are you?',
      'translation': '"Xin chào, bạn có khỏe không?"',
      'tip': "Emphasize the 'h' sound",
      'unit': 'UNIT 1 - GREETINGS',
    },
    {
      'phrase': 'The check, please',
      'translation': '"Cho tôi hóa đơn"',
      'tip': "Emphasize the 'ch' sound",
      'unit': 'UNIT 3 - DINING',
    },
    {
      'phrase': 'Where is the nearest station?',
      'translation': '"Ga gần nhất ở đâu?"',
      'tip': "Focus on 'nearest' pronunciation",
      'unit': 'UNIT 5 - TRAVEL',
    },
  ];

  int _currentExercise = 0;

  late final AnimationController _waveController;

  bool _isRecording = false;
  double _score = 0;
  String _recognizedText = '';
  PronunciationResult? _result;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  double _s(double value, double scale) => value * scale;

  // ─── Lấy thông tin bài tập hiện tại ───
  Map<String, String> get _currentData => _exercises[_currentExercise];
  String get _unitTitle => _currentData['unit']!;
  String get _phrase => _currentData['phrase']!;
  String get _translation => _currentData['translation']!;
  String get _tipText => _currentData['tip']!;
  double get _progress => (_currentExercise + 1) / _exercises.length;

  // ──────────────────────────────────────────────
  // LOGIC GHI ÂM & CHẤM ĐIỂM
  // ──────────────────────────────────────────────

  Future<void> _toggleRecording() async {
    final speechService = ref.read(speechServiceProvider);

    if (_isRecording) {
      // === DỪNG GHI ÂM ===
      final text = await speechService.stopListening();
      _waveController.stop();

      // Chấm điểm phát âm bằng thuật toán Levenshtein
      final result = speechService.assessPronunciation(
        referenceText: _phrase,
        recognizedText: text,
      );

      setState(() {
        _isRecording = false;
        _recognizedText = text;
        _score = result.accuracyScore;
        _result = result;
      });

      debugPrint('>>> Reference : $_phrase');
      debugPrint('>>> Recognized: $text');
      debugPrint('>>> Score     : ${result.accuracyScore}%');
      return;
    }

    // === BẮT ĐẦU GHI ÂM ===
    try {
      final ready = await speechService.initialize();
      if (!ready) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể truy cập Microphone hoặc thiết bị không hỗ trợ nhận diện giọng nói.'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      setState(() {
        _isRecording = true;
        _score = 0;
        _recognizedText = '';
        _result = null;
      });
      _waveController.repeat();

      await speechService.startListening(
        onResult: (text, isFinal) {
          if (mounted) {
            setState(() {
              _recognizedText = text;
            });

            // Khi nhận được kết quả cuối cùng → tự động dừng và chấm điểm
            if (isFinal) {
              _waveController.stop();
              final result = speechService.assessPronunciation(
                referenceText: _phrase,
                recognizedText: text,
              );
              setState(() {
                _isRecording = false;
                _score = result.accuracyScore;
                _result = result;
              });
            }
          }
        },
        localeId: 'en_US',
      );
    } catch (e) {
      debugPrint('>>> Lỗi khi bật mic: $e');
      setState(() {
        _isRecording = false;
      });
      _waveController.stop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lỗi khởi tạo. Vui lòng thử lại.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _reset() {
    final speechService = ref.read(speechServiceProvider);
    speechService.cancelListening();

    setState(() {
      _isRecording = false;
      _score = 0;
      _recognizedText = '';
      _result = null;
    });
    _waveController.stop();
  }

  void _nextExercise() {
    _reset();
    setState(() {
      _currentExercise = (_currentExercise + 1) % _exercises.length;
    });
  }

  Color get _scoreColor {
    if (_isRecording || _score == 0) return AppColors.slate400;
    return _score >= 80 ? AppColors.success : AppColors.error;
  }

  String get _scoreLabel {
    if (_isRecording) return 'RECORDING';
    if (_score == 0 && _recognizedText.isEmpty) return 'READY';
    if (_score == 0 && _recognizedText.isNotEmpty) return 'NO MATCH';
    return _score >= 80 ? 'GOOD JOB!' : 'TRY AGAIN';
  }

  // ──────────────────────────────────────────────
  // BUILD UI
  // ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final uiScale = (screenSize.width / 390).clamp(0.88, 1.0);
    final ringSize = _s(190, uiScale);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: CustomAppBar(
        title: _unitTitle,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  _s(20, uiScale),
                  _s(12, uiScale),
                  _s(20, uiScale),
                  _s(24, uiScale),
                ),
                child: Column(
                  children: [
                    SizedBox(height: _s(8, uiScale)),
                    _buildProgressBar(uiScale),
                    SizedBox(height: _s(16, uiScale)),
                    _buildPhraseSection(uiScale),
                    SizedBox(height: _s(12, uiScale)),
                    Text(
                      _translation,
                      style: GoogleFonts.lexend(
                        fontSize: _s(16, uiScale),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    SizedBox(height: _s(14, uiScale)),
                    _buildTipPill(uiScale),
                    SizedBox(height: _s(24, uiScale)),
                    _buildScoreRing(ringSize, uiScale),
                    SizedBox(height: _s(10, uiScale)),
                    // Hiển thị câu user đã đọc (recognized text)
                    if (_recognizedText.isNotEmpty && !_isRecording)
                      _buildRecognizedTextBox(uiScale),
                    SizedBox(height: _s(12, uiScale)),
                    _buildWaveform(uiScale),
                    SizedBox(height: _s(18, uiScale)),
                    _buildBottomCard(uiScale),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(double uiScale) {
    return SizedBox(
      width: _s(160, uiScale),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: LinearProgressIndicator(
          value: _progress,
          minHeight: _s(6, uiScale),
          backgroundColor: AppColors.slate200,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );
  }

  // ─── HIỂN THỊ CÂU MẪU VỚI MÀU SẮC ĐÚNG/SAI ───
  Widget _buildPhraseSection(double uiScale) {
    // Nếu chưa có kết quả → hiển thị toàn bộ câu mẫu màu mặc định
    if (_result == null) {
      final words = _phrase.split(RegExp(r'\s+'));
      return Wrap(
        spacing: _s(8, uiScale),
        runSpacing: _s(10, uiScale),
        alignment: WrapAlignment.center,
        children: words.map((word) {
          return _wordChip(
            text: word,
            uiScale: uiScale,
            background: const Color(0xFFE0F2FE),
            border: const Color(0xFF93C5FD),
            textColor: const Color(0xFF1D4ED8),
          );
        }).toList(),
      );
    }

    // Có kết quả → tô màu xanh/đỏ từng từ
    return Wrap(
      spacing: _s(8, uiScale),
      runSpacing: _s(10, uiScale),
      alignment: WrapAlignment.center,
      children: _result!.wordResults.map((wordResult) {
        final isCorrect = wordResult.isCorrect;
        final bg = isCorrect
            ? const Color(0xFFE7F7EE)
            : const Color(0xFFFFE4E6);
        final textColor = isCorrect
            ? const Color(0xFF16A34A)
            : const Color(0xFFEF4444);

        Widget content = Text(
          wordResult.word,
          style: GoogleFonts.lexend(
            fontSize: _s(26, uiScale),
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        );

        // Gạch chân lượn sóng cho từ sai
        if (!isCorrect) {
          content = CustomPaint(
            foregroundPainter: _WavyUnderlinePainter(
              color: const Color(0xFFEF4444),
              strokeWidth: _s(2.0, uiScale),
            ),
            child: Padding(
              padding: EdgeInsets.only(bottom: _s(2, uiScale)),
              child: content,
            ),
          );
        }

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: _s(4, uiScale),
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(_s(6, uiScale)),
          ),
          child: content,
        );
      }).toList(),
    );
  }

  Widget _wordChip({
    required String text,
    required double uiScale,
    required Color background,
    required Color border,
    required Color textColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _s(4, uiScale),
        vertical: _s(0, uiScale),
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(_s(6, uiScale)),
      ),
      child: Text(
        text,
        style: GoogleFonts.lexend(
          fontSize: _s(26, uiScale),
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildTipPill(double uiScale) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _s(14, uiScale),
        vertical: _s(8, uiScale),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FA),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_outline,
            size: _s(16, uiScale),
            color: const Color(0xFF64748B),
          ),
          SizedBox(width: _s(8, uiScale)),
          Text(
            _tipText,
            style: GoogleFonts.lexend(
              fontSize: _s(12.5, uiScale),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreRing(double size, double uiScale) {
    final percent = (_score / 100).clamp(0.0, 1.0);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: percent),
      duration: const Duration(milliseconds: 1400),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final animatedScore = (value * 100).toStringAsFixed(0);
        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: value,
                strokeWidth: _s(10, uiScale),
                backgroundColor: const Color(0xFFE5E7EB),
                valueColor: AlwaysStoppedAnimation<Color>(_scoreColor),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$animatedScore%',
                  style: GoogleFonts.lexend(
                    fontSize: _s(32, uiScale),
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111827),
                  ),
                ),
                SizedBox(height: _s(4, uiScale)),
                Text(
                  _scoreLabel,
                  style: GoogleFonts.lexend(
                    fontSize: _s(14, uiScale),
                    fontWeight: FontWeight.w700,
                    color: _scoreColor,
                  ),
                ),
              ],
            ),
            Positioned(
              top: _s(8, uiScale),
              right: _s(18, uiScale),
              child: SizedBox(
                width: _s(24, uiScale),
                height: _s(24, uiScale),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    if (percent > 0) ...[
                      _buildSmallStar(-math.pi / 2, value / percent, uiScale),
                      _buildSmallStar(-math.pi / 6, value / percent, uiScale),
                      _buildSmallStar(
                        -5 * math.pi / 6,
                        value / percent,
                        uiScale,
                      ),
                      _buildSmallStar(math.pi / 5, value / percent, uiScale),
                      _buildSmallStar(
                        4 * math.pi / 5,
                        value / percent,
                        uiScale,
                      ),
                    ],
                    Transform.scale(
                      scale: percent > 0
                          ? Curves.elasticOut.transform(
                              (value / percent).clamp(0.0, 1.0),
                            )
                          : 0.0,
                      child: Icon(
                        Icons.star,
                        color: const Color(0xFFFACC15),
                        size: _s(24, uiScale),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSmallStar(double angle, double progress, double uiScale) {
    final p = progress.clamp(0.0, 1.0);
    // Ngôi sao nhỏ văng ra xa một đoạn 32px nhanh rồi chậm dần
    final double distance = _s(32, uiScale) * Curves.easeOutQuint.transform(p);
    // Nhỏ dần và mờ dần khi càng ra xa
    final double scale = (1.0 - p).clamp(0.0, 1.0);
    final double opacity = (1.0 - p).clamp(0.0, 1.0);

    return Transform.translate(
      offset: Offset(math.cos(angle) * distance, math.sin(angle) * distance),
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: opacity,
          child: Icon(
            Icons.star,
            color: const Color(0xFFFDE047),
            size: _s(12, uiScale),
          ),
        ),
      ),
    );
  }

  // ─── Ô hiển thị câu user đã đọc ───
  Widget _buildRecognizedTextBox(double uiScale) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: _s(16, uiScale),
        vertical: _s(12, uiScale),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_s(12, uiScale)),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Text(
            'You said:',
            style: GoogleFonts.lexend(
              fontSize: _s(11, uiScale),
              fontWeight: FontWeight.w600,
              color: AppColors.slate400,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: _s(4, uiScale)),
          Text(
            _recognizedText.isEmpty ? '(không nhận diện được)' : _recognizedText,
            textAlign: TextAlign.center,
            style: GoogleFonts.lexend(
              fontSize: _s(15, uiScale),
              fontWeight: FontWeight.w600,
              color: _recognizedText.isEmpty
                  ? AppColors.slate400
                  : AppColors.slate700,
              fontStyle: _recognizedText.isEmpty
                  ? FontStyle.italic
                  : FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveform(double uiScale) {
    return GestureDetector(
      onTap: _toggleRecording,
      child: Column(
        children: [
          SizedBox(
            height: _s(60, uiScale),
            width: double.infinity,
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _WaveformPainter(
                    progress: _waveController.value,
                    isRecording: _isRecording,
                  ),
                );
              },
            ),
          ),
          SizedBox(height: _s(6, uiScale)),
          Text(
            _isRecording
                ? 'Recording... tap to stop'
                : 'Tap waveform to record',
            style: GoogleFonts.lexend(
              fontSize: _s(12, uiScale),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCard(double uiScale) {
    return Container(
      padding: EdgeInsets.all(_s(16, uiScale)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_s(20, uiScale)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: _s(18, uiScale),
            offset: Offset(0, _s(8, uiScale)),
          ),
        ],
      ),
      child: Column(
        children: [
          OutlinedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.volume_up_rounded, size: _s(20, uiScale)),
            label: Text(
              'Listen to Native',
              style: GoogleFonts.lexend(fontWeight: FontWeight.w700),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: Size.fromHeight(_s(50, uiScale)),
              foregroundColor: const Color(0xFF334155),
              backgroundColor: const Color(0xFFF1F5F9),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_s(14, uiScale)),
              ),
            ),
          ),
          SizedBox(height: _s(12, uiScale)),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _reset,
                  icon: Icon(Icons.refresh_rounded, size: _s(20, uiScale)),
                  label: Text(
                    'Retry',
                    style: GoogleFonts.lexend(fontWeight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size.fromHeight(_s(52, uiScale)),
                    foregroundColor: const Color(0xFF334155),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(_s(14, uiScale)),
                    ),
                  ),
                ),
              ),
              SizedBox(width: _s(12, uiScale)),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _nextExercise,
                  icon: Icon(
                    Icons.arrow_forward_rounded,
                    size: _s(20, uiScale),
                  ),
                  label: Text(
                    'Next',
                    style: GoogleFonts.lexend(fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size.fromHeight(_s(52, uiScale)),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(_s(14, uiScale)),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// CUSTOM PAINTERS
// ──────────────────────────────────────────────

class _WaveformPainter extends CustomPainter {
  final double progress;
  final bool isRecording;

  _WaveformPainter({required this.progress, required this.isRecording});

  @override
  void paint(Canvas canvas, Size size) {
    const barCount = 26;
    const spacing = 4.0;
    final totalSpacing = spacing * (barCount - 1);
    final barWidth = (size.width - totalSpacing) / barCount;
    final centerY = size.height / 2;
    final mid = (barCount - 1) / 2;

    for (int i = 0; i < barCount; i++) {
      final x = i * (barWidth + spacing);
      final distance = (i - mid).abs() / mid;
      final centerBoost = math.pow(1 - distance, 1.4).toDouble();

      final base = math.sin((progress * 2 * math.pi * 1.4) + (i * 0.45)).abs();
      final intensity = isRecording
          ? (0.25 + base * 0.75) * (0.4 + (centerBoost * 0.6))
          : 0.16 + (centerBoost * 0.22);
      final barHeight = size.height * (0.2 + intensity * 0.8);
      final top = centerY - (barHeight / 2);

      final isRight = i > (barCount / 2);
      final color = isRight ? const Color(0xFFEF4444) : const Color(0xFF60A5FA);
      final paint = Paint()
        ..color = color.withValues(alpha: isRecording ? 0.9 : 0.45);

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, top, barWidth, barHeight),
        const Radius.circular(999),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isRecording != isRecording;
  }
}

class _WavyUnderlinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _WavyUnderlinePainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final amplitude = strokeWidth * 1.6;
    final waveLength = strokeWidth * 4.2;
    // Bắt đầu vẽ từ cạnh trái, nhích lên một chút so với viền dưới
    final y = size.height - strokeWidth * 2.0;

    path.moveTo(0, y);

    for (double x = 0; x <= size.width; x += waveLength) {
      // Vẽ đường lượn sóng
      path.quadraticBezierTo(
        x + waveLength / 2,
        y + amplitude,
        x + waveLength,
        y,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavyUnderlinePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}
