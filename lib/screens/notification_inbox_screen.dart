import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/colors.dart';
import '../models/notification_feed.dart';
import '../services/notifications_api.dart';
import '../widgets/notification_tile.dart';

class NotificationInboxScreen extends StatefulWidget {
  const NotificationInboxScreen({super.key});

  @override
  State<NotificationInboxScreen> createState() =>
      _NotificationInboxScreenState();
}

class _NotificationInboxScreenState extends State<NotificationInboxScreen> {
  static const _pageSize = 12;
  static const _timeRefreshInterval = Duration(seconds: 60);

  final NotificationApi _api = NotificationApi();
  final ScrollController _scroll = ScrollController();
  final List<AppNotification> _items = [];

  String? _cursor;
  int _total = 0;
  int _unreadCount = 0;
  bool _hasMore = true;
  bool _loading = false;
  bool _markingAll = false;
  Object? _error;
  Timer? _timeTicker;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _loadMore();
    // Rebuild every minute so client-side `timeLabel` ("Just now" → "1m ago")
    // stays current without a full feed refetch.
    _timeTicker = Timer.periodic(_timeRefreshInterval, (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timeTicker?.cancel();
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
      final page = await _api.fetchFeed(limit: _pageSize, before: _cursor);
      if (!mounted) return;
      setState(() {
        _items.addAll(page.items);
        _cursor = page.nextCursor;
        _hasMore = page.hasMore;
        _total = page.total;
        _unreadCount = page.unreadCount;
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

  Future<void> _refresh() async {
    setState(() {
      _items.clear();
      _cursor = null;
      _hasMore = true;
      _error = null;
    });
    await _loadMore();
  }

  Future<void> _markAllRead() async {
    if (_markingAll || _unreadCount == 0) return;
    setState(() => _markingAll = true);
    try {
      final summary = await _api.markAllRead();
      if (!mounted) return;
      setState(() {
        for (var i = 0; i < _items.length; i++) {
          _items[i] = _items[i].copyWith(read: true);
        }
        _unreadCount = summary.unreadCount;
        _markingAll = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _markingAll = false);
      _showError(e);
    }
  }

  Future<void> _onTapNotification(int index) async {
    final n = _items[index];
    if (!n.read) {
      final wasUnread = n;
      setState(() {
        _items[index] = n.copyWith(read: true);
        if (_unreadCount > 0) _unreadCount -= 1;
      });
      // Optimistic; reconcile on failure so client/server don't drift.
      unawaited(_markReadSilently(n.id, wasUnread));
    }
    final route = n.actionRoute;
    // Same `startsWith('/')` safety net as handleDeepLink in main.dart: the
    // server must only emit in-app GoRouter paths. Use `go` (not `push`) so
    // inbox-tap deep-links behave like tray-tap deep-links — replace, not
    // stack.
    if (route != null && route.startsWith('/') && mounted) {
      context.go(route);
    }
  }

  Future<void> _markReadSilently(String id, AppNotification previous) async {
    try {
      await _api.markRead(id);
    } catch (_) {
      if (!mounted) return;
      // Roll back: the server didn't accept the read, so don't lie to the user.
      final idx = _items.indexWhere((n) => n.id == id);
      if (idx >= 0) {
        setState(() {
          _items[idx] = previous;
          _unreadCount += 1;
        });
      }
    }
  }

  void _showError(Object e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString()),
        backgroundColor: TripwiseColors.error,
      ),
    );
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
          // Defense-in-depth: a cold-start notification tap lands here with
          // an empty stack (router uses `go`), so pop() would throw.
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: TripwiseColors.primary,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markingAll ? null : _markAllRead,
              style: TripwiseButtonStyles.text(),
              child: const Text('Mark all read'),
            ),
          IconButton(
            tooltip: 'Notification settings',
            icon: const Icon(
              Icons.settings_rounded,
              color: TripwiseColors.primary,
            ),
            onPressed: () => context.push('/notifications'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView.separated(
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: TripwiseInsets.screen,
          itemCount: _items.length + 2,
          separatorBuilder: (_, i) => SizedBox(height: i == 0 ? 14 : 8),
          itemBuilder: (context, i) {
            if (i == 0) {
              return Text(
                _total > 0
                    ? 'All notifications ($_total) • $_unreadCount unread'
                    : 'All notifications',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              );
            }
            if (i <= _items.length) {
              final idx = i - 1;
              return NotificationTile(
                notification: _items[idx],
                onTap: () => _onTapNotification(idx),
              );
            }
            return _buildFooter(context);
          },
        ),
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
              "Couldn't load notifications",
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
        padding: const EdgeInsets.symmetric(vertical: 64),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.notifications_off_rounded,
                size: 44,
                color: TripwiseColors.onSurfaceVariant.withOpacity(0.6),
              ),
              const SizedBox(height: 12),
              Text(
                "You're all caught up",
                style: textTheme.bodyMedium?.copyWith(
                  color: TripwiseColors.onSurfaceVariant,
                ),
              ),
            ],
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
