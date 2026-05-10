import 'package:flutter/material.dart';
import '../constants/colors.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  String searchQuery = '';

  final List<FAQItem> faqs = [
    FAQItem(
      category: 'Account & Profile',
      questions: [
        'How do I reset my password?',
        'How to update my profile information?',
        'Can I delete my account?',
        'How to link social media accounts?',
      ],
    ),
    FAQItem(
      category: 'Booking & Payments',
      questions: [
        'How do I book a trip?',
        'What payment methods do you accept?',
        'Can I modify my booking?',
        'What is your cancellation policy?',
      ],
    ),
    FAQItem(
      category: 'Trips & Travel',
      questions: [
        'How do I add items to my trip?',
        'Can I share my trip with others?',
        'How to plan a multi-city trip?',
        'What documents do I need to travel?',
      ],
    ),
    FAQItem(
      category: 'Become a Provider',
      questions: [
        'How do I become a provider?',
        'What are the requirements?',
        'How much can I earn?',
        'How do I receive payments?',
      ],
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: TripwiseColors.outlineVariant),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                onChanged: (value) {
                  setState(() => searchQuery = value);
                },
                decoration: InputDecoration(
                  hintText: 'Search help articles...',
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.search,
                    color: TripwiseColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Popular Topics
            Text(
              'Popular Topics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildTopicCard('Getting Started', Icons.play_arrow),
                _buildTopicCard('Booking Help', Icons.calendar_today),
                _buildTopicCard('Payment Issues', Icons.credit_card),
                _buildTopicCard('Account Settings', Icons.settings),
              ],
            ),
            const SizedBox(height: 32),

            // FAQs by Category
            Text(
              'Frequently Asked Questions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              itemCount: faqs.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return _buildFAQCategory(faqs[index]);
              },
            ),
            const SizedBox(height: 32),

            // Contact Support
            Container(
              decoration: BoxDecoration(
                color: TripwiseColors.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.support_agent,
                    size: 40,
                    color: TripwiseColors.onPrimaryContainer,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Still Need Help?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: TripwiseColors.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Contact our support team and we\'ll help you within 24 hours',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: TripwiseColors.onPrimaryContainer.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.mail),
                    label: const Text('Contact Support'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Additional Resources
            Text(
              'Additional Resources',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 16),
            _buildResourceItem('Privacy Policy', Icons.privacy_tip),
            const SizedBox(height: 12),
            _buildResourceItem('Terms of Service', Icons.description),
            const SizedBox(height: 12),
            _buildResourceItem('Community Guidelines', Icons.groups),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicCard(String title, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: TripwiseColors.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 32,
                  color: TripwiseColors.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: TripwiseColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFAQCategory(FAQItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.category,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: TripwiseColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        ...item.questions.map(
          (question) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildFAQItem(question),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildFAQItem(String question) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: TripwiseColors.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    question,
                    style: TextStyle(
                      fontSize: 12,
                      color: TripwiseColors.onSurface,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: TripwiseColors.outlineVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResourceItem(String title, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: TripwiseColors.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          child: Row(
            children: [
              Icon(
                icon,
                color: TripwiseColors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: TripwiseColors.onSurface,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: TripwiseColors.outlineVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FAQItem {
  final String category;
  final List<String> questions;

  FAQItem({
    required this.category,
    required this.questions,
  });
}
