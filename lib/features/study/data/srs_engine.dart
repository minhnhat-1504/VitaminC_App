import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vitaminc/features/library/data/models/vocab_model.dart';

enum ReviewQuality {
  hard, // 1
  good, // 2
  easy, // 3
}

class SrsEngine {
  /// Hàm xử lý logic lặp ngắt quãng SM-2
  /// Dựa trên đánh giá độ khó [ReviewQuality], tính toán ngày ôn tập tiếp theo
  /// 
  /// Input: [VocabModel] thẻ hiện tại, [ReviewQuality] kết quả review
  /// Output: [VocabModel] bản sao mới được cập nhật (Immutable)
  VocabModel processReview(VocabModel currentCard, ReviewQuality quality) {
    int repetition = currentCard.repetition;
    double easinessFactor = currentCard.easinessFactor;
    int interval = currentCard.interval;

    switch (quality) {
      case ReviewQuality.hard:
        // Nếu chọn Hard: Reset số lần lặp và khoảng cách ôn tập
        repetition = 0;
        interval = 1;
        // Giảm nhẹ EF, thấp nhất là 1.3 để không bị lặp quá nhiều
        easinessFactor = (easinessFactor - 0.2).clamp(1.3, 5.0);
        break;

      case ReviewQuality.good:
        // Nếu chọn Good: Tăng số lần lặp, giữ nguyên độ khó EF
        repetition += 1;
        interval = _calculateInterval(repetition, interval, easinessFactor);
        break;

      case ReviewQuality.easy:
        // Nếu chọn Easy: Tăng số lần lặp, giảm độ khó thẻ bằng cách tăng EF
        repetition += 1;
        easinessFactor += 0.15;
        interval = _calculateInterval(repetition, interval, easinessFactor);
        break;
    }

    // Tính toán nextReview = hiện tại + số ngày (interval)
    final nextReviewDate = DateTime.now().add(Duration(days: interval));

    // Trả về bản sao mới bằng copyWith (tuân thủ nguyên tắc không mutate trực tiếp object cũ)
    return currentCard.copyWith(
      repetition: repetition,
      easinessFactor: easinessFactor,
      interval: interval,
      nextReview: Timestamp.fromDate(nextReviewDate),
      updatedAt: Timestamp.now(),
    );
  }

  /// Helper method tính toán khoảng cách số ngày ôn tập (Interval)
  int _calculateInterval(int rep, int currentInterval, double ef) {
    if (rep == 1) return 1; // Lần lặp đầu tiên -> mai học lại
    if (rep == 2) return 6; // Lần lặp thứ 2 -> 6 ngày sau học lại
    // Từ lần lặp > 2 -> Nhân khoảng cách trước đó với Hệ số dễ (EF)
    return (currentInterval * ef).round();
  }
}
