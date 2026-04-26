import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/colors.dart';

class ProfileRegistrationScreen extends StatefulWidget {
  const ProfileRegistrationScreen({super.key});

  @override
  State<ProfileRegistrationScreen> createState() =>
      _ProfileRegistrationScreenState();
}

class _ProfileRegistrationScreenState extends State<ProfileRegistrationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TripwiseColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            Icons.search,
            color: TripwiseColors.primary,
          ),
        ),
        centerTitle: true,
        title: Text(
          'Tripwise',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: TripwiseColors.primary,
                fontWeight: FontWeight.w900,
              ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: TripwiseColors.primaryContainer,
              backgroundImage: const NetworkImage(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuCj0DhjFAIlxKtcA8YX2bJTP-FgPiYR3lLWz9n4GS4QVmTNm8PhceGldIC1t_Y2OrLAdhusqbykiLCBCH_-0Jnu3Ouj2PngPlH90R221kLWQ3ra2FfIfcjeVAGtOsB1pj6oTK1_Wr5IFe27vL9pfmWcX0nHBzrisjmb52VV9HwuDiS1V4JO5nSZaGwOxnh5m4ZJBIuOC7TYcaEfRVZX1LKMyW0GnFHQ3Fc6kdWkCiz16AMmXDYJn3k1P9lnIpRLxVywss3OoNf6eiY',
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header Section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar with Edit Button
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              TripwiseColors.primary,
                              TripwiseColors.secondaryContainer,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(3),
                        child: CircleAvatar(
                          radius: 64,
                          backgroundColor: TripwiseColors.surface,
                          backgroundImage: const NetworkImage(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuBhv0_R2Kft9YTmuR-C94GhNxNwkR6L9jdJSMcazVF-k8nE-UBRVPndsznphfjT0boM-9a0XYvnzeFhIl7PpRdl2JNxQJybYo8V6iiV2AyYVb_kG4RXxRanWRJPdiMLB0Uoex3F0UU13VYrolQL6kzHAOmqlUv8hb0ySWGYtYm77qGVPkssKoEcDq7u3D_qbPXTchOyc16h9dtxQFF30mABEJgmjO0aZXODrzdYa9MOXNMLzCnrENzNogoTP3nbOd53Vg5bjT8pxwg',
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: TripwiseColors.secondaryContainer,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.edit,
                            color: TripwiseColors.onSecondary,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Name and Status
                  Text(
                    'Alex Thompson',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Premium Voyager • 12 Countries',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: TripwiseColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Become a Provider Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: TripwiseColors.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: TripwiseColors.primaryContainer.withOpacity(0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Become a Provider',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: TripwiseColors.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Share your local expertise and earn while you travel. Join our global network of elite trip planners.',
                      style: TextStyle(
                        fontSize: 13,
                        color: TripwiseColors.onPrimaryContainer.withOpacity(0.8),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TripwiseColors.secondaryContainer,
                        foregroundColor: TripwiseColors.onSecondary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Start Registration'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Identity Verification Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Header
                  Row(
                    children: [
                      Icon(
                        Icons.description,
                        color: TripwiseColors.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Identity Verification',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Upload Areas
                  Row(
                    children: [
                      Expanded(
                        child: _buildUploadArea(
                          icon: Icons.cloud_upload,
                          title: 'Passport or ID',
                          subtitle: 'JPG, PNG or PDF',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildUploadArea(
                          icon: Icons.account_balance,
                          title: 'Proof of Address',
                          subtitle: 'Recent utility bill',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Menu Items Section
            Container(
              decoration: BoxDecoration(
                color: TripwiseColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildMenuItemButton(
                    icon: Icons.security,
                    label: 'Security & Privacy',
                    onTap: () {
                      context.push('/security_privacy');
                    },
                  ),
                  Divider(
                    height: 1,
                    color: TripwiseColors.surfaceContainer,
                  ),
                  _buildMenuItemButton(
                    icon: Icons.notifications_active,
                    label: 'Notifications',
                    onTap: () {
                      context.push('/notifications');
                    },
                  ),
                  Divider(
                    height: 1,
                    color: TripwiseColors.surfaceContainer,
                  ),
                  _buildMenuItemButton(
                    icon: Icons.help,
                    label: 'Help Center',
                    onTap: () {
                      context.push('/help_center');
                    },
                  ),
                  Divider(
                    height: 1,
                    color: TripwiseColors.surfaceContainer,
                  ),
                  _buildMenuItemButton(
                    icon: Icons.logout,
                    label: 'Sign Out',
                    isDestructive: true,
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildUploadArea({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: TripwiseColors.outlineVariant,
          width: 2,
          strokeAlign: BorderSide.strokeAlignCenter,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 40,
                  color: TripwiseColors.outlineVariant,
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: TripwiseColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: TripwiseColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItemButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: isDestructive
                      ? TripwiseColors.error.withOpacity(0.1)
                      : TripwiseColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(
                  icon,
                  size: 20,
                  color: isDestructive ? TripwiseColors.error : TripwiseColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDestructive ? TripwiseColors.error : TripwiseColors.onSurface,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: TripwiseColors.outlineVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: 4,
      onTap: (index) {},
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.travel_explore),
          label: 'My Trips',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.event_note),
          label: 'Planner',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.account_balance_wallet),
          label: 'Wallet',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
