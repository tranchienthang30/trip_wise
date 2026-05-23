import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/colors.dart';
import '../models/provider_application.dart';
import '../services/admin_api.dart';
import '../services/auth_session_store.dart';
import '../utils/tripwise_image_provider.dart';

class AdminProviderApprovalsScreen extends StatefulWidget {
  const AdminProviderApprovalsScreen({super.key});

  @override
  State<AdminProviderApprovalsScreen> createState() =>
      _AdminProviderApprovalsScreenState();
}

class _AdminProviderApprovalsScreenState
    extends State<AdminProviderApprovalsScreen> {
  final AdminApi _api = AdminApi();
  final Set<String> _reviewingIds = {};

  ProviderApplicationsResponse? _data;
  ProviderApplicationStatus _status = ProviderApplicationStatus.pending;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _api.fetchProviderApplications(status: _status);
      if (!mounted) return;
      setState(() {
        _data = data;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _changeStatus(ProviderApplicationStatus status) async {
    if (_status == status) return;
    setState(() => _status = status);
    await _loadApplications();
  }

  Future<void> _reviewApplication(
    ProviderApplication application,
    ProviderApplicationStatus decision,
  ) async {
    if (_reviewingIds.contains(application.userId)) return;

    setState(() => _reviewingIds.add(application.userId));

    try {
      final reviewed = await _api.reviewProviderApplication(
        userId: application.userId,
        decision: decision,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              decision == ProviderApplicationStatus.approved
                  ? '${reviewed.applicantName} is now a provider.'
                  : '${reviewed.applicantName} was rejected.',
            ),
            backgroundColor: decision == ProviderApplicationStatus.approved
                ? TripwiseColors.primary
                : TripwiseColors.error,
          ),
        );
      await _loadApplications();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(error.toString()),
            backgroundColor: TripwiseColors.error,
          ),
        );
    } finally {
      if (mounted) {
        setState(() => _reviewingIds.remove(application.userId));
      }
    }
  }

  Future<void> _signOut() async {
    await AuthSessionStore.instance.logout();
    if (!mounted) return;
    context.go('/register');
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    final applications = data?.applications ?? const <ProviderApplication>[];

    return Scaffold(
      backgroundColor: TripwiseColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        title: Text(
          'TRIP WISE ADMIN',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: TripwiseColors.primary,
                fontWeight: FontWeight.w900,
              ),
        ),
        actions: [
          IconButton(
            onPressed: () => context.go('/admin_provider_payouts'),
            tooltip: 'Provider payouts',
            icon: const Icon(
              Icons.payments_rounded,
              color: TripwiseColors.primary,
            ),
          ),
          IconButton(
            onPressed: _isLoading ? null : _loadApplications,
            tooltip: 'Refresh',
            icon: const Icon(
              Icons.refresh_rounded,
              color: TripwiseColors.primary,
            ),
          ),
          IconButton(
            onPressed: _signOut,
            tooltip: 'Sign out',
            icon: const Icon(
              Icons.logout_rounded,
              color: TripwiseColors.error,
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadApplications,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            _buildHeader(context, data?.counts),
            const SizedBox(height: 16),
            _buildStatusTabs(data?.counts),
            const SizedBox(height: 16),
            if (_isLoading && data == null)
              const Padding(
                padding: EdgeInsets.only(top: 120),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null && data == null)
              _ErrorState(message: _error!, onRetry: _loadApplications)
            else if (applications.isEmpty)
              _EmptyState(status: _status)
            else
              ...applications.map(
                (application) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ProviderApplicationTile(
                    application: application,
                    isReviewing: _reviewingIds.contains(application.userId),
                    onApprove: () => _reviewApplication(
                      application,
                      ProviderApplicationStatus.approved,
                    ),
                    onReject: () => _reviewApplication(
                      application,
                      ProviderApplicationStatus.rejected,
                    ),
                  ),
                ),
              ),
            if (_error != null && data != null) ...[
              const SizedBox(height: 4),
              _InlineError(message: _error!, onRetry: _loadApplications),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ProviderApplicationCounts? counts,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Provider applications',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Only users who submitted provider registration appear here.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: TripwiseColors.onSurfaceVariant,
                height: 1.4,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _MetricPill(
              icon: Icons.hourglass_top_rounded,
              label: 'Pending',
              value: counts?.pending ?? 0,
            ),
            _MetricPill(
              icon: Icons.verified_rounded,
              label: 'Approved',
              value: counts?.approved ?? 0,
            ),
            _MetricPill(
              icon: Icons.block_rounded,
              label: 'Rejected',
              value: counts?.rejected ?? 0,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusTabs(ProviderApplicationCounts? counts) {
    const statuses = [
      ProviderApplicationStatus.pending,
      ProviderApplicationStatus.approved,
      ProviderApplicationStatus.rejected,
      ProviderApplicationStatus.all,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<ProviderApplicationStatus>(
        showSelectedIcon: false,
        segments: statuses
            .map(
              (status) => ButtonSegment(
                value: status,
                icon: Icon(_statusIcon(status)),
                label: Text(
                  '${providerApplicationStatusLabel(status)} (${counts?.countFor(status) ?? 0})',
                ),
              ),
            )
            .toList(),
        selected: {_status},
        onSelectionChanged: (selection) => _changeStatus(selection.first),
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.selected)
                ? TripwiseColors.onPrimary
                : TripwiseColors.primary;
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.selected)
                ? TripwiseColors.primary
                : TripwiseColors.surfaceContainerLowest;
          }),
          side: WidgetStateProperty.all(
            const BorderSide(color: TripwiseColors.outlineVariant),
          ),
        ),
      ),
    );
  }

  IconData _statusIcon(ProviderApplicationStatus status) {
    switch (status) {
      case ProviderApplicationStatus.pending:
        return Icons.hourglass_top_rounded;
      case ProviderApplicationStatus.approved:
        return Icons.verified_rounded;
      case ProviderApplicationStatus.rejected:
        return Icons.block_rounded;
      case ProviderApplicationStatus.all:
        return Icons.list_alt_rounded;
    }
  }
}

class _ProviderApplicationTile extends StatelessWidget {
  const _ProviderApplicationTile({
    required this.application,
    required this.isReviewing,
    required this.onApprove,
    required this.onReject,
  });

  final ProviderApplication application;
  final bool isReviewing;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final avatarProvider = tripwiseImageProvider(application.image);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: TripwiseColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: TripwiseColors.primaryFixed,
                backgroundImage: avatarProvider,
                child: avatarProvider == null
                    ? Text(
                        application.initials.toUpperCase(),
                        style: const TextStyle(
                          color: TripwiseColors.onPrimaryFixedVariant,
                          fontWeight: FontWeight.w900,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.applicantName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      application.contactLabel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: TripwiseColors.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _StatusBadge(status: application.status),
                        _SmallBadge(label: application.role),
                        _SmallBadge(label: application.experienceLabel),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _InfoRow(
            icon: Icons.workspace_premium_rounded,
            label: 'Specialty',
            value: application.specialty,
          ),
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.event_available_rounded,
            label: 'Submitted',
            value: application.submittedAt ?? 'Not recorded',
          ),
          if (application.rejectionReason != null) ...[
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.info_outline_rounded,
              label: 'Reason',
              value: application.rejectionReason!,
            ),
          ],
          const SizedBox(height: 12),
          Text(
            application.bio.isEmpty ? 'No bio provided.' : application.bio,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: TripwiseColors.onSurfaceVariant,
                  height: 1.45,
                ),
          ),
          if (application.isPending) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isReviewing ? null : onReject,
                    style: TripwiseButtonStyles.destructiveOutlined(
                      radius: 8,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isReviewing ? null : onApprove,
                    style: TripwiseButtonStyles.primaryElevated(
                      radius: 8,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    icon: isReviewing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: TripwiseColors.onPrimary,
                            ),
                          )
                        : const Icon(Icons.verified_rounded, size: 18),
                    label: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: TripwiseColors.primary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: TripwiseColors.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: TripwiseColors.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: TripwiseColors.primary),
          const SizedBox(width: 8),
          Text(
            '$label: $value',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final ProviderApplicationStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color, textColor) = switch (status) {
      ProviderApplicationStatus.approved => (
          'Approved',
          TripwiseColors.primaryFixed,
          TripwiseColors.onPrimaryFixedVariant,
        ),
      ProviderApplicationStatus.rejected => (
          'Rejected',
          TripwiseColors.errorContainer,
          TripwiseColors.onErrorContainer,
        ),
      ProviderApplicationStatus.pending ||
      ProviderApplicationStatus.all => (
          'Pending',
          TripwiseColors.surfaceContainerHigh,
          TripwiseColors.onSurfaceVariant,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SmallBadge extends StatelessWidget {
  const _SmallBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: TripwiseColors.outlineVariant),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: TripwiseColors.onSurfaceVariant,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 96),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 44,
            color: TripwiseColors.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          const Text(
            "Couldn't load applications",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: TripwiseColors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            style: TripwiseButtonStyles.primaryElevated(radius: 8),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.status});

  final ProviderApplicationStatus status;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 96),
      child: Center(
        child: Text(
          status == ProviderApplicationStatus.pending
              ? 'No pending provider applications.'
              : 'No applications in this view.',
          style: const TextStyle(
            color: TripwiseColors.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TripwiseColors.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: TripwiseColors.onErrorContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: TripwiseColors.onErrorContainer,
                fontSize: 12,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TripwiseButtonStyles.text(
              foregroundColor: TripwiseColors.onErrorContainer,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
