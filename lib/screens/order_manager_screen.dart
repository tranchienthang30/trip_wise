import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/colors.dart';
import '../constants/icons.dart';
import '../models/provider_order.dart';
import '../services/orders_api.dart';
import '../utils/tripwise_image_provider.dart';
import '../widgets/shared_taskbars.dart';
import '../widgets/shared_top_bars.dart';

class OrderManagerScreen extends StatefulWidget {
  const OrderManagerScreen({super.key});

  @override
  State<OrderManagerScreen> createState() => _OrderManagerScreenState();
}

class _OrderManagerScreenState extends State<OrderManagerScreen> {
  final OrdersApi _ordersApi = OrdersApi();
  final TextEditingController _ticketCodeController = TextEditingController();
  String _selectedStatus = 'pending';
  _OrderSortOption _selectedSort = _OrderSortOption.dateDesc;
  ProviderOrdersResponse? _data;
  bool _isLoading = true;
  String? _error;
  String? _acceptingOrderId;
  String? _rejectingOrderId;

  static const List<_OrderTab> _tabs = [
    _OrderTab(
      status: 'pending',
      label: 'Pending',
      icon: TripwiseIcons.pending,
    ),
    _OrderTab(
      status: 'confirmed',
      label: 'Confirmed',
      icon: TripwiseIcons.confirmed,
    ),
    _OrderTab(
      status: 'completed',
      label: 'Completed',
      icon: TripwiseIcons.completed,
    ),
    _OrderTab(
      status: 'cancelled',
      label: 'Cancelled',
      icon: TripwiseIcons.cancelled,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  void dispose() {
    _ticketCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _ordersApi.fetchOrders(
        status: _selectedStatus,
        sort: _selectedSort.value,
      );
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

  Future<void> _selectStatus(String status) async {
    if (_selectedStatus == status) return;
    setState(() => _selectedStatus = status);
    await _loadOrders();
  }

  Future<void> _selectSort(_OrderSortOption sort) async {
    if (_selectedSort == sort) return;
    setState(() => _selectedSort = sort);
    await _loadOrders();
  }

  Future<void> _acceptOrder(ProviderOrder order) async {
    setState(() => _acceptingOrderId = order.id);

    try {
      await _ordersApi.acceptOrder(order.id);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Accepted ${order.bookingId}')));
      await _loadOrders();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not accept order: $error')));
    } finally {
      if (mounted) {
        setState(() => _acceptingOrderId = null);
      }
    }
  }

  Future<void> _rejectOrder(ProviderOrder order) async {
    setState(() => _rejectingOrderId = order.id);

    try {
      await _ordersApi.rejectOrder(order.id);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Rejected ${order.bookingId}')));
      await _loadOrders();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not reject order: $error')));
    } finally {
      if (mounted) {
        setState(() => _rejectingOrderId = null);
      }
    }
  }

  Future<void> _lookupTicket() async {
    final code = _ticketCodeController.text.trim();
    if (code.isEmpty) return;

    try {
      final order = await _ordersApi.lookupTicket(code);
      if (!mounted) return;
      _showTicketDialog(order);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: TripwiseColors.error,
        ),
      );
    }
  }

  void _showTicketDialog(ProviderOrder order) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(order.ticketCode.isEmpty ? 'Ticket found' : order.ticketCode),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(order.title, style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text('${order.serviceType.toUpperCase()} - ${order.statusLabel}'),
            const SizedBox(height: 6),
            Text(order.dates),
            const SizedBox(height: 6),
            Text('Guest: ${order.guestName}'),
            const SizedBox(height: 6),
            Text('Total: ${order.displayPrice}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: const ProviderAppBar(),
      body: RefreshIndicator(
        onRefresh: _loadOrders,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: TripwiseInsets.screenWithBottomAction,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1024),
              child: Padding(
                padding: EdgeInsets.zero,
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildToolbar(),
                      const SizedBox(height: 48),
                      _buildBody(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const ProviderTaskbar(
        currentTab: ProviderTaskbarTab.orders,
      ),
    );
  }

  Widget _buildToolbar() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [_buildFilterTabs(), _buildSortMenu(), _buildTicketLookup()],
    );
  }

  Widget _buildTicketLookup() {
    return SizedBox(
      width: 320,
      child: TextField(
        controller: _ticketCodeController,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => _lookupTicket(),
        decoration: InputDecoration(
          hintText: 'Check e-ticket code',
          prefixIcon: const Icon(Icons.confirmation_number_rounded),
          suffixIcon: IconButton(
            onPressed: _lookupTicket,
            icon: const Icon(Icons.search_rounded),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDFE2EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDFE2EB)),
          ),
        ),
      ),
    );
  }

  Widget _buildSortMenu() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDFE2EB)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<_OrderSortOption>(
          value: _selectedSort,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          onChanged: (sort) {
            if (sort != null) _selectSort(sort);
          },
          items: _OrderSortOption.values.map((sort) {
            return DropdownMenuItem<_OrderSortOption>(
              value: sort,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(sort.icon, size: 18, color: const Color(0xFF005F9F)),
                  const SizedBox(width: 8),
                  Text(
                    sort.label,
                    style: const TextStyle(
                      color: Color(0xFF181C22),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    final counts = _data?.counts;

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 12.0;
        final tileWidth = (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: _tabs.map((tab) {
            final count = counts?.valueFor(tab.status) ?? 0;
            return SizedBox(
              width: tileWidth,
              child: _buildTab(
                icon: tab.icon,
                label: '${tab.label} ($count)',
                isActive: _selectedStatus == tab.status,
                onTap: () => _selectStatus(tab.status),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildTab({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 52,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF0078C7) : const Color(0xFFF0F4FC),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? Colors.white : const Color(0xFF3F4752),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isActive ? Colors.white : const Color(0xFF3F4752),
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _data == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 80),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null && _data == null) {
      return _buildMessageState(
        icon: Icons.cloud_off_rounded,
        title: 'Unable to load orders',
        subtitle: _error!,
        actionLabel: 'Retry',
        onAction: _loadOrders,
      );
    }

    final orders = _data?.orders ?? const <ProviderOrder>[];
    if (orders.isEmpty) {
      return _buildMessageState(
        icon: Icons.receipt_long_rounded,
        title: 'No orders found',
        subtitle:
            'There are no ${_selectedStatus.replaceAll('_', ' ')} orders right now.',
        actionLabel: 'Refresh',
        onAction: _loadOrders,
      );
    }

    return Stack(
      children: [
        _buildOrderGrid(orders),
        if (_isLoading)
          const Positioned(
            top: 0,
            right: 0,
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      ],
    );
  }

  Widget _buildMessageState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 64),
        child: Column(
          children: [
            Icon(icon, size: 44, color: const Color(0xFF3F4752)),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF181C22),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF3F4752)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onAction,
              style: TripwiseButtonStyles.primaryElevated(radius: 12),
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderGrid(List<ProviderOrder> orders) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 768) {
          return Wrap(
            spacing: 32,
            runSpacing: 32,
            children: orders.map((order) {
              return SizedBox(
                width: order.isPremium
                    ? constraints.maxWidth
                    : (constraints.maxWidth - 32) / 2,
                child: order.isPremium
                    ? _buildPremiumOrderCard(order, true)
                    : _buildStandardOrderCard(order),
              );
            }).toList(),
          );
        }

        return Column(
          children: [
            for (int i = 0; i < orders.length; i++) ...[
              if (i > 0) const SizedBox(height: 32),
              orders[i].isPremium
                  ? _buildPremiumOrderCard(orders[i], false)
                  : _buildStandardOrderCard(orders[i]),
            ],
          ],
        );
      },
    );
  }

  Widget _buildStandardOrderCard(ProviderOrder order) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderHeader(order, titleSize: 24, priceSize: 24),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFDFE2EB)),
          const SizedBox(height: 16),
          _buildGuestRow(order),
          const SizedBox(height: 24),
          _buildActions(order, isPremium: false),
        ],
      ),
    );
  }

  Widget _buildPremiumOrderCard(ProviderOrder order, bool isWide) {
    return Container(
      decoration: _cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Flex(
        direction: isWide ? Axis.horizontal : Axis.vertical,
        children: [
          Container(
            height: isWide ? null : 200,
            width: isWide ? 300 : double.infinity,
            constraints: isWide ? const BoxConstraints(minHeight: 280) : null,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(order.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    const Color(0xFF181C22).withValues(alpha: 0.6),
                    Colors.transparent,
                  ],
                ),
              ),
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.all(24),
              child: _buildStatusPill('PREMIUM BOOKING', isPremium: true),
            ),
          ),
          if (isWide)
            Expanded(child: _buildPremiumOrderDetails(order, isWide: true))
          else
            _buildPremiumOrderDetails(order, isWide: false),
        ],
      ),
    );
  }

  Widget _buildPremiumOrderDetails(
    ProviderOrder order, {
    required bool isWide,
  }) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOrderHeader(order, titleSize: 32, priceSize: 32),
          const SizedBox(height: 32),
          Flex(
            direction: isWide ? Axis.horizontal : Axis.vertical,
            crossAxisAlignment: isWide
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildGuestRow(order, compact: true),
              if (isWide)
                Container(
                  height: 32,
                  width: 1,
                  color: const Color(0xFFBFC7D4).withValues(alpha: 0.3),
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                ),
              if (!isWide) const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.dates,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    _buildStayLabel(order),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF3F4752),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildActions(order, isPremium: true),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF005F9F).withValues(alpha: 0.06),
          blurRadius: 40,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  Widget _buildOrderHeader(
    ProviderOrder order, {
    required double titleSize,
    required double priceSize,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusPill(order.statusLabel),
              const SizedBox(height: 8),
              Text(
                order.title,
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF181C22),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${order.bookingId} • ${order.serviceType.toUpperCase()}',
                style: const TextStyle(
                  color: Color(0xFF3F4752),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              order.displayPrice,
              style: TextStyle(
                fontSize: priceSize,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF005F9F),
                letterSpacing: -1,
              ),
            ),
            const Text(
              'TOTAL PRICE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.5,
                color: Color(0xFF3F4752),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusPill(String label, {bool isPremium = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isPremium ? const Color(0xFF0078C7) : _statusColor(label),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isPremium ? Colors.white : _statusTextColor(label),
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Color _statusColor(String label) {
    switch (label) {
      case 'CONFIRMED':
        return const Color(0xFFD1E4FF);
      case 'COMPLETED':
        return const Color(0xFFD8F3DC);
      case 'CANCELLED':
      case 'REJECTED':
        return const Color(0xFFFFDAD6);
      case 'PENDING':
      default:
        return const Color(0xFFFFDBD0);
    }
  }

  Color _statusTextColor(String label) {
    switch (label) {
      case 'CONFIRMED':
        return const Color(0xFF003B63);
      case 'COMPLETED':
        return const Color(0xFF123D22);
      case 'CANCELLED':
      case 'REJECTED':
        return const Color(0xFF410002);
      case 'PENDING':
      default:
        return const Color(0xFF390C00);
    }
  }

  Widget _buildGuestRow(ProviderOrder order, {bool compact = false}) {
    final avatarProvider = tripwiseImageProvider(order.guestAvatarUrl);
    final guestDetails = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          order.guestName,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: compact ? 14 : 16,
            color: const Color(0xFF181C22),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          compact ? 'Primary Guest' : order.dates,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14, color: Color(0xFF3F4752)),
        ),
        if (!compact) ...[
          const SizedBox(height: 2),
          Text(
            _buildStayLabel(order),
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Color(0xFF3F4752)),
          ),
        ],
      ],
    );

    return Row(
      mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
      children: [
        Container(
          width: compact ? 40 : 48,
          height: compact ? 40 : 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFE5E8F0),
            image: avatarProvider == null
                ? null
                : DecorationImage(
                    image: avatarProvider,
                    fit: BoxFit.cover,
                  ),
          ),
          child: avatarProvider == null
              ? const Icon(Icons.person_rounded, color: Color(0xFF3F4752))
              : null,
        ),
        const SizedBox(width: 16),
        if (compact)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: guestDetails,
          )
        else
          Expanded(child: guestDetails),
      ],
    );
  }

  String _buildStayLabel(ProviderOrder order) {
    final nights = order.nights == null ? null : '${order.nights} nights';
    final guests = order.guests == null ? null : '${order.guests} guests';
    return [nights, guests, order.roomType].whereType<String>().join(' • ');
  }

  Widget _buildActions(ProviderOrder order, {required bool isPremium}) {
    final isAccepting = _acceptingOrderId == order.id;
    final isRejecting = _rejectingOrderId == order.id;
    final isUpdating = isAccepting || isRejecting;
    final canAccept = order.isPending && !isUpdating;
    final canReject = order.isPending && !isUpdating;
    final contactButton = ElevatedButton.icon(
      onPressed: () => context.push(
        '/direct_messaging?mode=provider&orderId=${Uri.encodeQueryComponent(order.id)}',
      ),
      style: TripwiseButtonStyles.surfaceElevated(
        radius: 12,
        backgroundColor: TripwiseColors.surfaceContainerLow,
        foregroundColor: TripwiseColors.primary,
        padding: EdgeInsets.symmetric(
          vertical: isPremium ? 20 : 16,
          horizontal: isPremium ? 28 : 20,
        ),
      ),
      icon: const Icon(Icons.chat_bubble_rounded, size: 18),
      label: const Text(
        'Contact',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );

    if (!order.isPending) {
      return SizedBox(width: double.infinity, child: contactButton);
    }

    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: canAccept ? () => _acceptOrder(order) : null,
            style: TripwiseButtonStyles.primaryElevated(
              radius: 12,
              padding: EdgeInsets.symmetric(vertical: isPremium ? 20 : 16),
            ),
            child: isAccepting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Accept',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: canReject ? () => _rejectOrder(order) : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: TripwiseColors.error,
              side: const BorderSide(color: TripwiseColors.error),
              padding: EdgeInsets.symmetric(vertical: isPremium ? 20 : 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isRejecting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Reject',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        contactButton,
      ],
    );
  }
}

class _OrderTab {
  const _OrderTab({
    required this.status,
    required this.label,
    required this.icon,
  });

  final String status;
  final String label;
  final IconData icon;
}

enum _OrderSortOption {
  dateDesc('date_desc', 'Date newest', Icons.calendar_month_rounded),
  dateAsc('date_asc', 'Date oldest', Icons.event_available_rounded),
  priceDesc('price_desc', 'Price high', Icons.trending_up_rounded),
  priceAsc('price_asc', 'Price low', Icons.trending_down_rounded);

  const _OrderSortOption(this.value, this.label, this.icon);

  final String value;
  final String label;
  final IconData icon;
}
