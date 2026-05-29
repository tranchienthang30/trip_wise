import 'package:flutter/material.dart';

import '../constants/colors.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  static const List<FaqItem> _faqs = [
    FaqItem(
      question: 'How do I make a booking?',
      answer:
          'Go to Home, choose the service you want, tap Book Now, review the checkout details, then tap Complete Booking.',
    ),
    FaqItem(
      question: 'Where can I request a cancellation?',
      answer:
          'Open My Trips, choose the booking you want to cancel, or open the booked service detail page and tap Cancel. The request is sent to admin for review before a refund is issued.',
    ),
    FaqItem(
      question: 'Why is my booking not showing in Upcoming?',
      answer:
          'Pull down to refresh My Trips. Cancelled bookings appear in the Cancelled tab, and finished bookings appear in Completed.',
    ),
    FaqItem(
      question: 'Which payment methods does Tripwise support?',
      answer:
          'The app currently supports card, wallet, and PayPal options when they are available on the checkout screen.',
    ),
    FaqItem(
      question: 'How do I update my profile?',
      answer:
          'Open Profile, tap your avatar or the information fields you want to edit, then save your changes.',
    ),
    FaqItem(
      question: 'How do I contact support?',
      answer:
          'Go to Profile > Help Center and use the available in-app support channel or support email.',
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
          icon: const Icon(Icons.arrow_back_rounded),
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
        padding: TripwiseInsets.screen,
        children: [
          Text(
            'Frequently Asked Questions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
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
