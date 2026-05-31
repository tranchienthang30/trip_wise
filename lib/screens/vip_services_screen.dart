import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/colors.dart';
import '../models/provider_vip.dart';
import '../services/provider_vip_api.dart';
import '../widgets/shared_taskbars.dart';
import '../widgets/shared_top_bars.dart';

class VipServicesScreen extends StatefulWidget {
  const VipServicesScreen({super.key});

  @override
  State<VipServicesScreen> createState() => _VipServicesScreenState();
}

class _VipServicesScreenState extends State<VipServicesScreen> {
  final ProviderVipApi _api = ProviderVipApi();

  ProviderVipData? _data;
  Object? _error;
  bool _isUpdatingAutoRenew = false;
  bool? _autoRenewOverride;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _error = null;
      _data = null;
      _autoRenewOverride = null;
    });
    try {
      final data = await _api.fetchVipServices();
      if (!mounted) return;
      setState(() => _data = data);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 100),
          child: _buildBody(context),
        ),
      ),
      bottomNavigationBar: const ProviderTaskbar(
        currentTab: ProviderTaskbarTab.vip,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return const ProviderAppBar();
  }

  ProviderVipPlan? _findPlan(List<ProviderVipPlan> plans, String id) {
    for (final plan in plans) {
      if (plan.id == id) return plan;
    }
    return null;
  }

  Widget _buildBody(BuildContext context) {
    final data = _data;
    if (data == null && _error == null) {
      return const Padding(
        padding: EdgeInsets.only(top: 180),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (data == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          TripwiseSpacing.xl,
          180,
          TripwiseSpacing.xl,
          TripwiseSpacing.xxl,
        ),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.cloud_off_rounded, size: 48),
              const SizedBox(height: 12),
              const Text(
                "Couldn't load VIP services",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                _error.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF3F4752)),
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final elite = _findPlan(data.plans, 'elite');
    if (elite?.isCurrent ?? false) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          TripwiseSpacing.xl,
          36,
          TripwiseSpacing.xl,
          TripwiseSpacing.xxl,
        ),
        child: _buildCurrentEliteView(context, elite!, data.subscription),
      );
    }

    return Column(
      children: [
        _buildHeroSection(data.hero),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            TripwiseSpacing.xl,
            48,
            TripwiseSpacing.xl,
            TripwiseSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUpgradePlanSection(context, data.plans),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _updateAutoRenew(bool value) async {
    if (_isUpdatingAutoRenew) return;
    setState(() {
      _autoRenewOverride = value;
      _isUpdatingAutoRenew = true;
    });
    try {
      final data = await _api.updateAutoRenew(value);
      if (!mounted) return;
      setState(() {
        _data = data;
        _autoRenewOverride = data.subscription.autoRenew;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value ? 'VIP auto-renew is now on.' : 'VIP auto-renew is now off.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      final currentValue = _data?.subscription.autoRenew;
      setState(() => _autoRenewOverride = currentValue);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _isUpdatingAutoRenew = false);
      }
    }
  }

  Widget _buildCurrentEliteView(
    BuildContext context,
    ProviderVipPlan plan,
    ProviderVipSubscription subscription,
  ) {
    final stats = plan.stats;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (subscription.expiresSoon) ...[
          _buildExpiryWarning(subscription),
          const SizedBox(height: 16),
        ],
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0B5E98).withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: -18,
                right: -10,
                child: Icon(
                  Icons.workspace_premium_rounded,
                  size: 118,
                  color: const Color(0xFF006EB6).withOpacity(0.08),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F4FF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          size: 18,
                          color: TripwiseColors.primary,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'ELITE ACTIVE',
                          style: TextStyle(
                            color: TripwiseColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Your VIP benefits are live',
                    style: TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    plan.description,
                    style: const TextStyle(
                      color: Color(0xFF4B5563),
                      fontSize: 15,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSubscriptionStatus(subscription),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _eliteSummaryTile(
                          Icons.trending_up_rounded,
                          'Search Priority',
                          'Your listings are boosted in Planner results.',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _eliteSummaryTile(
                          Icons.savings_rounded,
                          '8% Commission',
                          'Reduced platform fee is already applied.',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildAutoRenewCard(subscription),
        const SizedBox(height: 24),
        if (stats.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stats.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.55,
            ),
            itemBuilder: (context, index) {
              final stat = stats[index];
              return _currentEliteStat(stat.value, stat.label);
            },
          ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF101820),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Next best actions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              _eliteActionRow(
                Icons.inventory_2_rounded,
                'Keep listings updated',
                'Fresh pricing and photos help your boosted placement convert.',
              ),
              const SizedBox(height: 14),
              _eliteActionRow(
                Icons.account_balance_wallet_rounded,
                'Track VIP earnings',
                'Review revenue, payouts, and recent transactions in Finance.',
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.go('/provider_listings'),
                      icon: const Icon(Icons.list_alt_rounded),
                      label: const Text('Listings'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withOpacity(0.3)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/provider_finance'),
                      icon: const Icon(Icons.payments_rounded),
                      label: const Text('Finance'),
                      style: TripwiseButtonStyles.primaryElevated(
                        radius: 12,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpiryWarning(ProviderVipSubscription subscription) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFC2410C)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              subscription.autoRenew
                  ? 'Your Elite plan renews tomorrow. Keep enough wallet balance for automatic renewal.'
                  : 'Your Elite plan expires tomorrow. Turn on auto-renew to keep VIP benefits active.',
              style: const TextStyle(
                color: Color(0xFF9A3412),
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionStatus(ProviderVipSubscription subscription) {
    final expiresAt = subscription.expiresAt;
    final expiryLabel = expiresAt == null
        ? 'No expiry date'
        : "${expiresAt.day.toString().padLeft(2, '0')}/${expiresAt.month.toString().padLeft(2, '0')}/${expiresAt.year}";
    final remaining = subscription.daysRemaining;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE6F4FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.event_available_rounded,
              color: TripwiseColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Expires on $expiryLabel',
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  remaining == null ? 'Active subscription' : '$remaining days remaining',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoRenewCard(ProviderVipSubscription subscription) {
    final autoRenew = _autoRenewOverride ?? subscription.autoRenew;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F7FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              autoRenew
                  ? Icons.autorenew_rounded
                  : Icons.pause_circle_outline_rounded,
              color: TripwiseColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Auto-renew Elite plan',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Renew monthly from wallet balance when this period ends.',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _autoRenewToggle(
            value: autoRenew,
            isLoading: _isUpdatingAutoRenew,
            onChanged: _updateAutoRenew,
          ),
        ],
      ),
    );
  }

  Widget _eliteSummaryTile(IconData icon, String title, String body) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F7FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: TripwiseColors.primary),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: const TextStyle(
              color: Color(0xFF4B5563),
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _currentEliteStat(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: TripwiseColors.primary,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _eliteActionRow(IconData icon, String title, String body) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFFBEE1FF), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                body,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.68),
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection(ProviderVipHero hero) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 40, 24, 0),
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: NetworkImage(hero.imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              const Color(0xFF181C22).withOpacity(0.8),
              const Color(0xFF181C22).withOpacity(0.2),
              Colors.transparent,
            ],
          ),
        ),
        padding: const EdgeInsets.all(32),
        alignment: Alignment.bottomLeft,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF0078C7),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                hero.badge,
                style: TextStyle(
                  color: Color(0xFFD1E4FF),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              hero.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.w900,
                height: 1.1,
                letterSpacing: -1.0,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              hero.description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
                fontWeight: FontWeight.w300,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradePlanSection(
    BuildContext context,
    List<ProviderVipPlan> plans,
  ) {
    final standard = _findPlan(plans, 'standard');
    final elite = _findPlan(plans, 'elite');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upgrade Your Plan',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Color(0xFF181C22),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Select the tier that fits your growth ambitions.',
          style: TextStyle(fontSize: 16, color: Color(0xFF3F4752)),
        ),
        const SizedBox(height: 32),
        if (standard != null) _buildStandardPlan(standard),
        if (standard != null && elite != null) const SizedBox(height: 24),
        if (elite != null) _buildElitePlan(context, elite),
      ],
    );
  }

  Widget _buildStandardPlan(ProviderVipPlan plan) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            plan.name,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF181C22),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            plan.description,
            style: TextStyle(fontSize: 14, color: Color(0xFF3F4752)),
          ),
          const SizedBox(height: 24),
          for (final feature in plan.features) ...[
            _checkItem(feature),
            const SizedBox(height: 16),
          ],
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFBFC7D4)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              plan.ctaLabel,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF181C22),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _checkItem(String text) {
    return Row(
      children: [
        const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF005F9F),
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF181C22),
          ),
        ),
      ],
    );
  }

  Widget _buildElitePlan(BuildContext context, ProviderVipPlan plan) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF181C22),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Icon(
              Icons.workspace_premium_rounded,
              size: 120,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFAB3500)),
                  const SizedBox(width: 12),
                  Text(
                    plan.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFAB3500),
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                plan.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  for (final stat in plan.stats.take(2))
                    Expanded(child: _eliteStat(stat.value, stat.label)),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  for (final stat in plan.stats.skip(2).take(2))
                    Expanded(child: _eliteStat(stat.value, stat.label)),
                ],
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Starting at',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          plan.priceLabel,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          plan.priceUnit,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: plan.ctaRoute == null
                            ? null
                            : () => context.push(plan.ctaRoute!),
                        style: TripwiseButtonStyles.primaryElevated(
                          radius: 12,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          plan.ctaLabel,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _eliteStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Color(0xFFFFDBD0),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _autoRenewToggle({
    required bool value,
    required bool isLoading,
    required ValueChanged<bool> onChanged,
  }) {
    return InkWell(
      onTap: isLoading ? null : () => onChanged(!value),
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 66,
        height: 40,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: value ? TripwiseColors.primary : const Color(0xFFCBD5E1),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        value ? Icons.check_rounded : Icons.close_rounded,
                        color: value
                            ? TripwiseColors.primary
                            : const Color(0xFF64748B),
                        size: 18,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
