import 'package:flutter/material.dart';

import '../constants/colors.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  static const List<FaqItem> _faqs = [
    FaqItem(
      question: 'Làm sao để đặt chuyến đi?',
      answer:
          'Vào Home, chọn dịch vụ bạn muốn, bấm Book Now, kiểm tra thông tin ở Checkout rồi bấm Complete Booking.',
    ),
    FaqItem(
      question: 'Tôi có thể hủy booking ở đâu?',
      answer:
          'Bạn mở My Trips, chọn booking cần hủy hoặc vào Service Detail của dịch vụ đã đặt rồi bấm Cancel. Trạng thái sẽ chuyển sang Cancelled.',
    ),
    FaqItem(
      question: 'Vì sao booking không thấy trong Upcoming?',
      answer:
          'Hãy kéo xuống để refresh My Trips. Nếu booking đã hủy thì sẽ nằm ở tab Cancelled, nếu hoàn tất thì ở tab Completed.',
    ),
    FaqItem(
      question: 'Trip Wise hỗ trợ phương thức thanh toán nào?',
      answer:
          'Hiện tại ứng dụng hỗ trợ Card, Wallet và PayPal (tùy theo dữ liệu khả dụng ở màn Checkout).',
    ),
    FaqItem(
      question: 'Làm sao cập nhật thông tin profile?',
      answer:
          'Trong màn Profile, bạn bấm vào avatar hoặc các mục thông tin để chỉnh sửa rồi lưu lại.',
    ),
    FaqItem(
      question: 'Làm sao liên hệ hỗ trợ?',
      answer:
          'Bạn vào Profile > Help Center và gửi thông tin qua kênh hỗ trợ nội bộ hoặc email hỗ trợ của hệ thống.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TripwiseColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Help Center',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        children: [
          Text(
            'Câu hỏi thường gặp',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Các câu trả lời được chuẩn bị sẵn để bạn tra cứu nhanh.',
            style: TextStyle(
              color: TripwiseColors.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          ..._faqs.map(
            (faq) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _FaqTile(item: faq),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.item});

  final FaqItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TripwiseColors.outlineVariant),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          iconColor: TripwiseColors.primary,
          collapsedIconColor: TripwiseColors.onSurfaceVariant,
          title: Text(
            item.question,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: TripwiseColors.onSurface,
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                item.answer,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: TripwiseColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FaqItem {
  const FaqItem({required this.question, required this.answer});

  final String question;
  final String answer;
}
