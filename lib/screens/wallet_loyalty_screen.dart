import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../constants/colors.dart';
import '../models/wallet_overview.dart';
import '../services/wallet_api.dart';
import '../utils/currency.dart';
import '../widgets/shared_taskbars.dart';
import '../widgets/shared_top_bars.dart';
import '../widgets/wallet_transaction_tile.dart';

void _showWalletFlowNotice(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
}

String _titleCase(String value) {
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1).toLowerCase();
}

class WalletLoyaltyScreen extends StatefulWidget {
  const WalletLoyaltyScreen({super.key});

  @override
  State<WalletLoyaltyScreen> createState() => _WalletLoyaltyScreenState();
}

class _WalletLoyaltyScreenState extends State<WalletLoyaltyScreen> {
  final WalletApi _api = WalletApi();

  WalletOverview? _data;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _error = null;
      _data = null;
    });
    try {
      final data = await _api.fetchWallet();
      if (!mounted) return;
      setState(() => _data = data);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  Future<void> _openAddPayment() async {
    await context.push('/add_payment');
    if (!mounted) return;
    await _load();
  }

  Future<void> _openMoneySheet({required bool isTopUp}) async {
    final data = _data;
    if (data == null) return;
    final card = data.defaultCard;
    if (card == null) {
      _showWalletFlowNotice(context, 'Add a payment card first.');
      return;
    }
    final available = isTopUp ? card.balance : data.balance;

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: TripwiseColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _MoneySheet(
        title: isTopUp ? 'Top up wallet' : 'Withdraw funds',
        actionLabel: isTopUp ? 'Top up' : 'Withdraw',
        cardLabel: '${card.brand} •• ${card.last4}',
        availableLabel: isTopUp
            ? '${formatVnd(card.balance)} on card'
            : '${formatVnd(data.balance)} in wallet',
        available: available,
        onSubmit: (amount) async {
          try {
            final updated = isTopUp
                ? await _api.topUp(amount: amount, cardId: card.id)
                : await _api.withdraw(amount: amount, cardId: card.id);
            if (!mounted) return null;
            setState(() => _data = updated);
            return null;
          } on WalletApiException catch (e) {
            return e.message;
          } catch (_) {
            return 'Something went wrong. Please try again.';
          }
        },
      ),
    );

    if (ok == true && mounted) {
      _showWalletFlowNotice(
        context,
        isTopUp ? 'Top-up successful.' : 'Withdrawal successful.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TripwiseColors.surface,
      appBar: const PlannerAppBar(),
      body: SafeArea(
        top: false,
        child: _buildBody(),
      ),
      bottomNavigationBar: const PlannerTaskbar(
        currentTab: PlannerTaskbarTab.wallet,
      ),
    );
  }

  Widget _buildBody() {
    if (_data == null && _error == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_data == null) {
      return _ErrorView(error: _error, onRetry: _load);
    }
    final data = _data!;
    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderSection(userName: data.user?.name),
            const SizedBox(height: 24),
            _PrimaryWalletCard(
              balance: formatVnd(data.balance),
              onTopUp: () => _openMoneySheet(isTopUp: true),
              onWithdraw: () => _openMoneySheet(isTopUp: false),
            ),
            const SizedBox(height: 12),
            _FundingCardChip(
              card: data.defaultCard,
              onAddCard: _openAddPayment,
            ),
            const SizedBox(height: 24),
            _LoyaltyPointsCard(
              points: data.loyaltyPoints,
              pointsValueVnd: data.pointsValueVnd,
              tier: data.tier,
            ),
            const SizedBox(height: 24),
            _TransactionsSection(
              transactions: data.transactions,
              onSeeAll: () => context.push('/wallet_transactions'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});

  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: TripwiseColors.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              "Couldn't load your wallet",
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              error?.toString() ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: TripwiseColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({this.userName});

  final String? userName;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (userName != null && userName!.isNotEmpty) ...[
          Text(
            'Hi, $userName 👋',
            style: textTheme.labelLarge?.copyWith(
              color: TripwiseColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Text(
          'Wallet & Loyalty',
          style: textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Manage your travel funds and rewards points in one place.',
          style: textTheme.bodyLarge?.copyWith(
            color: TripwiseColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _PrimaryWalletCard extends StatelessWidget {
  const _PrimaryWalletCard({
    required this.balance,
    required this.onTopUp,
    required this.onWithdraw,
  });

  final String balance;
  final VoidCallback onTopUp;
  final VoidCallback onWithdraw;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: TripwiseColors.primaryContainer,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: TripwiseColors.primary.withOpacity(0.18),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: TripwiseColors.secondaryContainer.withOpacity(0.20),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'AVAILABLE BALANCE',
                      style: textTheme.labelMedium?.copyWith(
                        color: Colors.white.withOpacity(0.85),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white.withOpacity(0.85),
                      size: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  balance,
                  style: textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(height: 32),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ElevatedButton.icon(
                      onPressed: onTopUp,
                      style: TripwiseButtonStyles.primaryElevated(
                        radius: 14,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      icon: const Icon(Icons.add_circle_rounded, size: 20),
                      label: const Text('Top-up'),
                    ),
                    OutlinedButton.icon(
                      onPressed: onWithdraw,
                      style: TripwiseButtonStyles.outlined(
                        radius: 14,
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.white.withOpacity(0.10),
                        borderColor: Colors.white.withOpacity(0.30),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      icon: const Icon(Icons.payments_rounded, size: 20),
                      label: const Text('Withdraw'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FundingCardChip extends StatelessWidget {
  const _FundingCardChip({required this.card, required this.onAddCard});

  final WalletCard? card;
  final VoidCallback onAddCard;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.credit_card_rounded,
            size: 20,
            color: TripwiseColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: card == null
                ? Text(
                    'No payment card yet',
                    style: textTheme.bodyMedium?.copyWith(
                      color: TripwiseColors.onSurfaceVariant,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${card!.brand} •• ${card!.last4}',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '${formatVnd(card!.balance)} available on card',
                        style: textTheme.bodySmall?.copyWith(
                          color: TripwiseColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
          ),
          TextButton(
            onPressed: onAddCard,
            style: TripwiseButtonStyles.text(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              card == null ? 'Add card' : 'Add new',
              style: textTheme.labelLarge?.copyWith(
                color: TripwiseColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoyaltyPointsCard extends StatelessWidget {
  const _LoyaltyPointsCard({
    required this.points,
    required this.pointsValueVnd,
    required this.tier,
  });

  final int points;
  final double pointsValueVnd;
  final WalletTier tier;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final progress = tier.progress; // already clamped to 0..1 in the model
    final hasNext = tier.next != null;
    return Container(
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: TripwiseColors.primary.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TRIP POINTS · ${tier.current}',
                style: textTheme.labelMedium?.copyWith(
                  color: TripwiseColors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const Icon(
                Icons.stars_rounded,
                color: TripwiseColors.secondary,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            formatInt(points),
            style: textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            '≈ ${formatVnd(pointsValueVnd)} value',
            style: textTheme.bodySmall?.copyWith(
              color: TripwiseColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 8,
              child: Stack(
                children: [
                  Container(color: TripwiseColors.surfaceContainerHigh),
                  FractionallySizedBox(
                    widthFactor: progress == 0 ? 0.001 : progress,
                    child: Container(color: TripwiseColors.secondary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (hasNext && tier.pointsToNext != null)
            RichText(
              text: TextSpan(
                style: textTheme.bodySmall?.copyWith(
                  color: TripwiseColors.onSurfaceVariant,
                ),
                children: [
                  TextSpan(
                    text: '${formatInt(tier.pointsToNext!)} points away from ',
                  ),
                  TextSpan(
                    text: '${_titleCase(tier.next!)} Tier',
                    style: const TextStyle(
                      color: TripwiseColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            )
          else
            Text(
              "You're at our top tier — enjoy the perks!",
              style: textTheme.bodySmall?.copyWith(
                color: TripwiseColors.onSurfaceVariant,
              ),
            ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => _showWalletFlowNotice(
                context,
                'Rewards catalog will be available here soon.',
              ),
              style: TripwiseButtonStyles.text(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Explore Rewards',
                    style: textTheme.labelLarge?.copyWith(
                      color: TripwiseColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: TripwiseColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionsSection extends StatelessWidget {
  const _TransactionsSection({
    required this.transactions,
    required this.onSeeAll,
  });

  final List<WalletTransaction> transactions;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style:
                  textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            TextButton(
              onPressed: onSeeAll,
              child: Text(
                'SEE ALL',
                style: textTheme.labelMedium?.copyWith(
                  color: TripwiseColors.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: TripwiseColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(8),
          child: transactions.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  child: Center(
                    child: Text(
                      'No transactions yet.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: TripwiseColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              : Column(
                  children: [
                    for (int i = 0; i < transactions.length; i++) ...[
                      if (i > 0) const SizedBox(height: 4),
                      WalletTransactionTile(transaction: transactions[i]),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

/// Bottom sheet that collects an amount and runs [onSubmit]. [onSubmit]
/// returns null on success (sheet pops with true) or an error string.
class _MoneySheet extends StatefulWidget {
  const _MoneySheet({
    required this.title,
    required this.actionLabel,
    required this.cardLabel,
    required this.availableLabel,
    required this.available,
    required this.onSubmit,
  });

  final String title;
  final String actionLabel;
  final String cardLabel;
  final String availableLabel;
  final double available;
  final Future<String?> Function(double amount) onSubmit;

  @override
  State<_MoneySheet> createState() => _MoneySheetState();
}

class _MoneySheetState extends State<_MoneySheet> {
  final TextEditingController _controller = TextEditingController();
  static const List<int> _presets = [100000, 200000, 500000, 1000000];

  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final raw = _controller.text.trim().replaceAll(',', '');
    final amount = double.tryParse(raw);
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Enter a valid amount.');
      return;
    }
    if (amount > widget.available) {
      setState(() => _error = 'Amount exceeds ${widget.availableLabel}.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    final err = await widget.onSubmit(amount);
    if (!mounted) return;
    if (err != null) {
      setState(() {
        _submitting = false;
        _error = err;
      });
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: TripwiseColors.outlineVariant,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.title,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            '${widget.cardLabel} · ${widget.availableLabel}',
            style: textTheme.bodySmall?.copyWith(
              color: TripwiseColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
            decoration: InputDecoration(
              prefixText: '₫ ',
              hintText: '0',
              filled: true,
              fillColor: TripwiseColors.surfaceContainerLow,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final p in _presets)
                ActionChip(
                  label: Text(formatVnd(p.toDouble())),
                  onPressed: _submitting
                      ? null
                      : () => setState(() {
                            _controller.text = p.toString();
                            _error = null;
                          }),
                ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: textTheme.bodySmall?.copyWith(
                color: TripwiseColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: TripwiseButtonStyles.primaryElevated(
                radius: 16,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(widget.actionLabel),
            ),
          ),
        ],
      ),
    );
  }
}
