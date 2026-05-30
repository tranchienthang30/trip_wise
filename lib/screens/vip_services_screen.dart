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

}
