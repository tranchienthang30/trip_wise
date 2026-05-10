import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/colors.dart';

class PlanNewTripFormScreen extends StatefulWidget {
  const PlanNewTripFormScreen({super.key});

  @override
  State<PlanNewTripFormScreen> createState() => _PlanNewTripFormScreenState();
}

class _PlanNewTripFormScreenState extends State<PlanNewTripFormScreen> {
  bool _inviteFriends = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 768),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFBFC7D4).withOpacity(0.15)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF005F9F).withOpacity(0.03),
                      blurRadius: 40,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Trip Details',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF005F9F),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                      label: 'Trip Name',
                      hint: 'e.g., Adventure in Tokyo',
                      icon: Icons.edit_square,
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                      label: 'Destination',
                      hint: 'Search a city, country...',
                      icon: Icons.location_on,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: 'Start Date',
                            hint: 'YYYY-MM-DD',
                            icon: Icons.calendar_today,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _buildTextField(
                            label: 'End Date',
                            hint: 'YYYY-MM-DD',
                            icon: Icons.event,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildInviteFriendsToggle(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildStickyBottomCTA(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFF0F4FC),
      elevation: 0,
      scrolledUnderElevation: 10,
      shadowColor: const Color(0xFF005F9F).withOpacity(0.06),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF005F9F)),
        onPressed: () => context.go('/trip_planner_dashboard'),
      ),
      title: const Text(
        'Plan Trip',
        style: TextStyle(
          color: Color(0xFF005F9F),
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 24),
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFE5E8F0),
            image: DecorationImage(
              image: NetworkImage(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuBpZ1nmipSL8DAqMkExIj56K-RKYJFzmPYXVkJP_dXtAnrbFfy_-qD1kibK5hBEDawc95DuqXOFP5jGXm561076rNIvhnvtFGQ4ozqPBRuZB1jhSvgYpl5AZLkzeaCUAmeTO91O0_VcgsGUa7QH80QJT2iDwWD9oCOI07Q-IttToCER48Hxqw9_F78Tl2sWopN7n5sJiPt2C9Yblti5TMI-ZEhizdTMR9Ce61Nw8gkP9WtAivvPjwfprLy27mRStWIp68XlIWJSgbvl',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({required String label, required String hint, required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF3F4752),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4FC),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            style: const TextStyle(fontSize: 18, color: Color(0xFF181C22)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: const Color(0xFF707884).withOpacity(0.6), fontSize: 18),
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Icon(icon, color: const Color(0xFF005F9F).withOpacity(0.6)),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInviteFriendsToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFD1E4FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.group_add, color: Color(0xFF005F9F)),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Invite Friends',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF181C22)),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Collaborate on this itinerary',
                    style: TextStyle(fontSize: 14, color: Color(0xFF3F4752)),
                  ),
                ],
              ),
            ],
          ),
          Switch(
            value: _inviteFriends,
            onChanged: (value) {
              setState(() {
                _inviteFriends = value;
              });
            },
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF005F9F),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFDFE2EB),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyBottomCTA() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FF).withOpacity(0.9),
        border: Border(
          top: BorderSide(
            color: const Color(0xFFBFC7D4).withOpacity(0.1),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF005F9F).withOpacity(0.06),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 768),
                child: Row(
                  children: [
                    // Cancel button is hidden on mobile in HTML but let's show it on wider screens. 
                    // To keep it simple, we'll just show it.
                    Expanded(
                      flex: 1,
                      child: TextButton(
                        onPressed: () => context.go('/trip_planner_dashboard'),
                        style: TripwiseButtonStyles.text(
                          radius: 12,
                          backgroundColor: TripwiseColors.surfaceContainerLow,
                          foregroundColor: TripwiseColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                        ),
                        child: const Text('Cancel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () => context.go('/trip_planner_dashboard'),
                        style: TripwiseButtonStyles.primaryElevated(
                          radius: 12,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text('Create Trip', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
