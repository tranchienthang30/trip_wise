import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../models/wallet_overview.dart';
import '../utils/currency.dart';

// Brand palette has no green; matches the HTML mock for the credit indicator.
const Color kCreditGreenBg = Color(0xFFD7F4DD);
const Color kCreditGreenFg = Color(0xFF1F8A3A);

class WalletTransactionTile extends StatelessWidget {
  const WalletTransactionTile({super.key, required this.transaction});

  final WalletTransaction transaction;

  ({IconData icon, Color bg, Color fg}) _methodVisual() {
    switch (transaction.method) {
      case 'TOPUP':
        return (
          icon: Icons.add_circle_rounded,
          bg: kCreditGreenBg,
          fg: kCreditGreenFg,
        );
      case 'WITHDRAW':
        return (
          icon: Icons.north_east_rounded,
          bg: TripwiseColors.secondaryFixed,
          fg: TripwiseColors.secondary,
        );
      case 'VNPAY':
      case 'CREDIT_CARD':
        return (
          icon: Icons.credit_card_rounded,
          bg: TripwiseColors.primaryFixed,
          fg: TripwiseColors.primary,
        );
      case 'MOMO':
        return (
          icon: Icons.account_balance_wallet_rounded,
          bg: TripwiseColors.tertiaryFixed,
          fg: TripwiseColors.tertiary,
        );
      case 'WALLET':
        return (
          icon: Icons.account_balance_wallet_rounded,
          bg: TripwiseColors.secondaryFixed,
          fg: TripwiseColors.secondary,
        );
      case 'PAYLATER':
        return (
          icon: Icons.schedule_rounded,
          bg: TripwiseColors.secondaryFixed,
          fg: TripwiseColors.secondary,
        );
      default:
        return (
          icon: Icons.receipt_long_rounded,
          bg: TripwiseColors.surfaceContainerHigh,
          fg: TripwiseColors.onSurfaceVariant,
        );
    }
  }

  ({String label, Color? bg, Color fg}) _statusVisual() {
    switch (transaction.status) {
      case 'SUCCESS':
        return (label: 'Completed', bg: kCreditGreenBg, fg: kCreditGreenFg);
      case 'PENDING':
        return (
          label: 'Pending',
          bg: TripwiseColors.secondaryFixed,
          fg: TripwiseColors.secondary,
        );
      case 'FAILED':
        return (
          label: 'Failed',
          bg: TripwiseColors.errorContainer,
          fg: TripwiseColors.error,
        );
      default:
        return (
          label: transaction.status,
          bg: null,
          fg: TripwiseColors.onSurfaceVariant,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final visual = _methodVisual();
    final status = _statusVisual();
    final isCredit = transaction.amountVnd > 0;
    final sign = transaction.amountVnd < 0 ? '-' : '+';
    final amountText = '$sign${formatVnd(transaction.amountVnd.abs())}';
    return Container(
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: visual.bg,
              shape: BoxShape.circle,
            ),
            child: Icon(visual.icon, color: visual.fg, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  transaction.subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: TripwiseColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amountText,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: isCredit ? kCreditGreenFg : TripwiseColors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              if (status.bg != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: status.bg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    status.label,
                    style: textTheme.labelSmall?.copyWith(
                      color: status.fg,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
              else
                Text(
                  status.label,
                  style: textTheme.labelSmall?.copyWith(
                    color: status.fg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
