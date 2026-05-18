import 'package:flutter/material.dart';

import '../constants/colors.dart';

class SecurityPrivacyScreen extends StatelessWidget {
  const SecurityPrivacyScreen({super.key});

  static const List<_PolicyItem> _securityItems = [
    _PolicyItem(
      title: 'Two-Factor Authentication',
      description: 'Bật xác thực 2 lớp để tăng bảo mật đăng nhập.',
      status: 'Enabled',
      enabled: true,
    ),
    _PolicyItem(
      title: 'Login Alerts',
      description: 'Gửi cảnh báo khi tài khoản đăng nhập từ thiết bị mới.',
      status: 'Enabled',
      enabled: true,
    ),
    _PolicyItem(
      title: 'Session Timeout',
      description: 'Tự động đăng xuất sau 30 phút không hoạt động.',
      status: 'Enabled',
      enabled: true,
    ),
  ];

  static const List<_PolicyItem> _privacyItems = [
    _PolicyItem(
      title: 'Profile Visibility',
      description: 'Thông tin profile chỉ hiển thị cho người dùng đã đăng nhập.',
      status: 'Private',
      enabled: true,
    ),
    _PolicyItem(
      title: 'Activity Status',
      description: 'Không hiển thị trạng thái online với người dùng khác.',
      status: 'Hidden',
      enabled: false,
    ),
    _PolicyItem(
      title: 'Direct Messages',
      description: 'Chỉ nhận tin nhắn từ người đã kết nối hoặc đã đặt dịch vụ.',
      status: 'Limited',
      enabled: true,
    ),
  ];

  static const List<_PolicyItem> _dataItems = [
    _PolicyItem(
      title: 'Data Retention',
      description: 'Dữ liệu booking được lưu để hỗ trợ lịch sử chuyến đi và đối soát.',
      status: 'Standard',
      enabled: true,
    ),
    _PolicyItem(
      title: 'Marketing Personalization',
      description: 'Tắt cá nhân hóa quảng cáo và ưu tiên gợi ý mặc định.',
      status: 'Disabled',
      enabled: false,
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
          'Security & Privacy',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        children: [
          const _SectionTitle(
            icon: Icons.lock_outline,
            title: 'Security Settings',
          ),
          const SizedBox(height: 12),
          ..._securityItems.map((item) => _PolicyTile(item: item)),
          const SizedBox(height: 24),
          const _SectionTitle(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Settings',
          ),
          const SizedBox(height: 12),
          ..._privacyItems.map((item) => _PolicyTile(item: item)),
          const SizedBox(height: 24),
          const _SectionTitle(
            icon: Icons.storage_outlined,
            title: 'Data & Permissions',
          ),
          const SizedBox(height: 12),
          ..._dataItems.map((item) => _PolicyTile(item: item)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: TripwiseColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Demo Mobile 2526II_INT3306_1',
              style: TextStyle(
                fontSize: 12,
                color: TripwiseColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: TripwiseColors.primaryFixed,
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: TripwiseColors.primary, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}

class _PolicyTile extends StatelessWidget {
  const _PolicyTile({required this.item});

  final _PolicyItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TripwiseColors.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: TripwiseColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: TripwiseColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _StatusChip(label: item.status, enabled: item.enabled),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.enabled});

  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: enabled
            ? TripwiseColors.primaryFixed
            : TripwiseColors.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: enabled
              ? TripwiseColors.onPrimaryFixedVariant
              : TripwiseColors.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _PolicyItem {
  const _PolicyItem({
    required this.title,
    required this.description,
    required this.status,
    required this.enabled,
  });

  final String title;
  final String description;
  final String status;
  final bool enabled;
}
