import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/colors.dart';
import '../models/wallet_overview.dart';
import '../services/wallet_api.dart';
import '../widgets/wallet_transaction_tile.dart';

class WalletTransactionsScreen extends StatefulWidget {
  const WalletTransactionsScreen({super.key});

  @override
  State<WalletTransactionsScreen> createState() =>
      _WalletTransactionsScreenState();
}

class _WalletTransactionsScreenState extends State<WalletTransactionsScreen> {
  static const _pageSize = 10;

  final WalletApi _api = WalletApi();
  final ScrollController _scroll = ScrollController();
  final List<WalletTransaction> _items = [];

  int _offset = 0;
  int _total = 0;
  bool _hasMore = true;
  bool _loading = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _loadMore();
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final remaining =
        _scroll.position.maxScrollExtent - _scroll.position.pixels;
    if (remaining < 400 && _hasMore && !_loading && _error == null) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await _api.fetchTransactions(
        limit: _pageSize,
        offset: _offset,
      );
      if (!mounted) return;
      setState(() {
        _items.addAll(page.items);
        _offset = page.nextOffset;
        _hasMore = page.hasMore;
        _total = page.total;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: TripwiseColors.surface,
      appBar: AppBar(
        backgroundColor: TripwiseColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: TripwiseColors.primary,
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Transactions',
          style: TextStyle(
            color: TripwiseColors.primary,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView.separated(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        itemCount: _items.length + 2,
        separatorBuilder: (_, i) => SizedBox(height: i == 0 ? 16 : 8),
        itemBuilder: (context, i) {
          if (i == 0) {
            return Text(
              _total > 0 ? 'All activity ($_total)' : 'All activity',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            );
          }
          if (i <= _items.length) {
            return WalletTransactionTile(transaction: _items[i - 1]);
          }
          return _buildFooter(context);
        },
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Text(
              "Couldn't load more transactions",
              style: textTheme.bodyMedium?.copyWith(
                color: TripwiseColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _loadMore,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (!_hasMore && _items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: Text(
            'No transactions yet.',
            style: textTheme.bodyMedium?.copyWith(
              color: TripwiseColors.onSurfaceVariant,
            ),
          ),
        ),
      );
    }
    if (!_hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            "You're all caught up",
            style: textTheme.bodySmall?.copyWith(
              color: TripwiseColors.onSurfaceVariant,
            ),
          ),
        ),
      );
    }
    return const SizedBox(height: 8);
  }
}
