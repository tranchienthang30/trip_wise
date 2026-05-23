import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/colors.dart';
import '../models/admin_provider_payout.dart';
import '../services/admin_api.dart';
import '../services/auth_session_store.dart';

class AdminProviderPayoutsScreen extends StatefulWidget {
  const AdminProviderPayoutsScreen({super.key});

  @override
  State<AdminProviderPayoutsScreen> createState() =>
      _AdminProviderPayoutsScreenState();
}

class _AdminProviderPayoutsScreenState
    extends State<AdminProviderPayoutsScreen> {
  final AdminApi _api = AdminApi();
  final Set<String> _payingProviderIds = {};

  String _period = 'monthly';
  AdminProviderPayoutsResponse? _data;
  bool _isLoading = true;
  bool _isProcessingAll = false;
  bool _isSeedingTest = false;
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
      final data = await _api.fetchProviderPayouts(period: _period);
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

  Future<void> _pay(AdminProviderPayoutSummary provider) async {
    if (_payingProviderIds.contains(provider.providerId)) return;
    setState(() => _payingProviderIds.add(provider.providerId));
    try {
      await _api.payProvider(providerId: provider.providerId, period: _period);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Paid ${provider.displayProviderNetAmount} to ${provider.providerName}.',
          ),
          backgroundColor: TripwiseColors.primary,
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
        setState(() => _payingProviderIds.remove(provider.providerId));
      }
    }
  }

  Future<void> _processAllPayouts() async {
    final providers = _data?.providers ?? const <AdminProviderPayoutSummary>[];
    if (_isProcessingAll || providers.isEmpty) return;

    setState(() => _isProcessingAll = true);
    var successCount = 0;

    try {
      for (final provider in providers) {
        await _api.payProvider(
          providerId: provider.providerId,
          period: _period,
        );
        successCount += 1;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Processed payouts for $successCount provider(s).'),
          backgroundColor: TripwiseColors.primary,
        ),
      );
      await _load();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            successCount > 0
                ? 'Processed $successCount provider(s), then failed: $error'
                : error.toString(),
          ),
          backgroundColor: TripwiseColors.error,
        ),
      );
      await _load();
    } finally {
      if (mounted) setState(() => _isProcessingAll = false);
    }
  }

  Future<void> _seedTestEscrow() async {
    if (_isSeedingTest) return;

    setState(() => _isSeedingTest = true);
    try {
      final result = await _api.createTestEscrow(
        email: 'thang3@gmail.com',
        amount: 100000,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Created test escrow ${result['providerNetAmount'] ?? ''} for thang3@gmail.com.',
          ),
          backgroundColor: TripwiseColors.primary,
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
      if (mounted) setState(() => _isSeedingTest = false);
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
        actions: [
          IconButton(
            onPressed: () => context.go('/admin_provider_approvals'),
            tooltip: 'Provider applications',
            icon: const Icon(
              Icons.verified_user_rounded,
              color: TripwiseColors.primary,
            ),
          ),
          IconButton(
            onPressed: () => context.go('/admin_listing_approvals'),
            tooltip: 'Listing approvals',
            icon: const Icon(
              Icons.hotel_rounded,
              color: TripwiseColors.primary,
            ),
          ),
          IconButton(
            onPressed: _isLoading ? null : _load,
            tooltip: 'Refresh',
            icon: const Icon(
              Icons.refresh_rounded,
              color: TripwiseColors.primary,
            ),
          ),
          IconButton(
            onPressed: _signOut,
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout_rounded, color: TripwiseColors.error),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Text(
              'Provider escrow payouts',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              'User payments stay in the admin wallet until you release the net amount to each provider.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: TripwiseColors.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: 'weekly', label: Text('Weekly')),
                ButtonSegment(value: 'monthly', label: Text('Monthly')),
              ],
              selected: {_period},
              onSelectionChanged: (selection) async {
                setState(() => _period = selection.first);
                await _load();
              },
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
              _ProcessNowButton(
                isProcessing: _isProcessingAll,
                enabled: data.providers.isNotEmpty,
                onPressed: _processAllPayouts,
              ),
              const SizedBox(height: 10),
              _SeedTestButton(
                isLoading: _isSeedingTest,
                onPressed: _seedTestEscrow,
              ),
              const SizedBox(height: 14),
              if (data.providers.isEmpty)
                const _EmptyPayouts()
              else
                ...data.providers.map(
                  (provider) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ProviderPayoutTile(
                      provider: provider,
                      isPaying: _payingProviderIds.contains(
                        provider.providerId,
                      ),
                      onPay: () => _pay(provider),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProcessNowButton extends StatelessWidget {
  const _ProcessNowButton({
    required this.isProcessing,
    required this.enabled,
    required this.onPressed,
  });

  final bool isProcessing;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: enabled && !isProcessing ? onPressed : null,
        style: TripwiseButtonStyles.accentElevated(
          radius: 8,
          elevation: 0,
          disabledBackgroundColor: TripwiseColors.surfaceContainerHigh,
          disabledForegroundColor: TripwiseColors.onSurfaceVariant,
        ),
        icon: isProcessing
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: TripwiseColors.onSecondary,
                ),
              )
            : const Icon(Icons.flash_on_rounded),
        label: Text(isProcessing ? 'Processing payouts...' : 'Xu ly tien ngay'),
      ),
    );
  }
}

class _SeedTestButton extends StatelessWidget {
  const _SeedTestButton({required this.isLoading, required this.onPressed});

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add_card_rounded),
        label: Text(isLoading ? 'Dang nap test...' : 'Nap test thang3'),
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
          _Line(label: 'Gross held', value: data.totals.displayGrossAmount),
          _Line(
            label: 'App commission (${data.commissionLabel})',
            value: data.totals.displayCommissionAmount,
          ),
          _Line(
            label: 'Net to providers',
            value: data.totals.displayProviderNetAmount,
          ),
          _Line(label: 'Bookings', value: '${data.totals.bookingCount}'),
        ],
      ),
    );
  }
}

class _ProviderPayoutTile extends StatelessWidget {
  const _ProviderPayoutTile({
    required this.provider,
    required this.isPaying,
    required this.onPay,
  });

  final AdminProviderPayoutSummary provider;
  final bool isPaying;
  final VoidCallback onPay;

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
            label: 'Provider receives',
            value: provider.displayProviderNetAmount,
          ),
          _Line(label: 'Bookings', value: '${provider.bookingCount}'),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isPaying ? null : onPay,
              style: TripwiseButtonStyles.primaryElevated(
                radius: 8,
                elevation: 0,
              ),
              icon: isPaying
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: TripwiseColors.onPrimary,
                      ),
                    )
                  : const Icon(Icons.payments_rounded),
              label: const Text('Pay Provider'),
            ),
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
          'No held provider payouts for this period.',
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
