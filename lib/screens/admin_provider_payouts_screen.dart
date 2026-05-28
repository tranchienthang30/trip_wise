import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../models/admin_provider_payout.dart';
import '../services/admin_api.dart';
import '../widgets/shared_taskbars.dart';

class AdminProviderPayoutsScreen extends StatefulWidget {
  const AdminProviderPayoutsScreen({super.key});

  @override
  State<AdminProviderPayoutsScreen> createState() =>
      _AdminProviderPayoutsScreenState();
}

class _AdminProviderPayoutsScreenState
    extends State<AdminProviderPayoutsScreen> {
  final AdminApi _api = AdminApi();
  final Set<String> _reviewingProviderIds = {};

  AdminProviderPayoutsResponse? _data;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _api.fetchProviderPayouts();
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

  Future<void> _review(
    AdminProviderPayoutSummary provider, {
    required bool approve,
  }) async {
    if (_reviewingProviderIds.contains(provider.providerId)) return;
    setState(() => _reviewingProviderIds.add(provider.providerId));
    try {
      await _api.reviewProviderPayout(
        providerId: provider.providerId,
        approve: approve,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${approve ? 'Accepted' : 'Rejected'} ${provider.displayProviderNetAmount} request from ${provider.providerName}.',
          ),
          backgroundColor: approve
              ? TripwiseColors.primary
              : TripwiseColors.error,
        ),
      );
      await _load();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: TripwiseColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _reviewingProviderIds.remove(provider.providerId));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    return Scaffold(
      backgroundColor: TripwiseColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'ADMIN PAYOUTS',
          style: TextStyle(
            color: TripwiseColors.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: TripwiseInsets.screen,
          children: [
            Text(
              'Provider payout requests',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              'Review payout amounts requested by providers and accept or reject each request.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: TripwiseColors.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading && data == null)
              const Padding(
                padding: EdgeInsets.only(top: 120),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null && data == null)
              _ErrorBlock(message: _error!, onRetry: _load)
            else if (data != null) ...[
              _SummaryCard(data: data),
              const SizedBox(height: 14),
              if (data.providers.isEmpty)
                const _EmptyPayouts()
              else
                ...data.providers.map(
                  (provider) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ProviderPayoutTile(
                      provider: provider,
                      isReviewing: _reviewingProviderIds.contains(
                        provider.providerId,
                      ),
                      onAccept: () => _review(provider, approve: true),
                      onReject: () => _review(provider, approve: false),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: const AdminTaskbar(
        currentTab: AdminTaskbarTab.payouts,
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.data});

  final AdminProviderPayoutsResponse data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: TripwiseColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Line(label: 'Admin wallet', value: data.adminWallet.displayBalance),
          _Line(label: 'Requested gross', value: data.totals.displayGrossAmount),
          _Line(
            label: 'App commission (${data.commissionLabel})',
            value: data.totals.displayCommissionAmount,
          ),
          _Line(
            label: 'Requested amount',
            value: data.totals.displayProviderNetAmount,
          ),
          _Line(label: 'Requests', value: '${data.totals.bookingCount}'),
        ],
      ),
    );
  }
}

class _ProviderPayoutTile extends StatelessWidget {
  const _ProviderPayoutTile({
    required this.provider,
    required this.isReviewing,
    required this.onAccept,
    required this.onReject,
  });

  final AdminProviderPayoutSummary provider;
  final bool isReviewing;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: TripwiseColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            provider.providerName,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          _Line(label: 'Gross', value: provider.displayGrossAmount),
          _Line(label: 'Commission', value: provider.displayCommissionAmount),
          _Line(
            label: 'Requested amount',
            value: provider.displayProviderNetAmount,
          ),
          _Line(label: 'Requests', value: '${provider.bookingCount}'),
          if (provider.requestedAt != null)
            _Line(label: 'First requested', value: provider.requestedAt!),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isReviewing ? null : onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: TripwiseColors.error,
                    side: const BorderSide(color: TripwiseColors.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size.fromHeight(44),
                  ),
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('Reject'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isReviewing ? null : onAccept,
                  style: TripwiseButtonStyles.primaryElevated(
                    radius: 8,
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
                      : const Icon(Icons.check_rounded),
                  label: const Text('Accept'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: TripwiseColors.onSurfaceVariant),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _EmptyPayouts extends StatelessWidget {
  const _EmptyPayouts();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 90),
      child: Center(
        child: Text(
          'No provider payout requests are waiting for review.',
          style: TextStyle(
            color: TripwiseColors.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ErrorBlock extends StatelessWidget {
  const _ErrorBlock({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 90),
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    );
  }
}
