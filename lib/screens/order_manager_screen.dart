import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/colors.dart';
import '../widgets/shared_taskbars.dart';
import '../widgets/shared_top_bars.dart';

class OrderManagerScreen extends StatelessWidget {
  const OrderManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1024),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildFilterTabs(),
                  const SizedBox(height: 48),
                  _buildOrderGrid(context),
                ],
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

  PreferredSizeWidget _buildAppBar() {
    return const ProviderAppBar();
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Orders',
          style: TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.w900,
            color: Color(0xFF181C22),
            letterSpacing: -2.0,
            height: 1.1,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Manage your upcoming journeys and guest experiences from your editorial dashboard.',
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFF3F4752),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTabs() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildTab(label: 'Pending (4)', isActive: true),
        _buildTab(label: 'Confirmed', isActive: false),
        _buildTab(label: 'Completed', isActive: false),
      ],
    );
  }

  Widget _buildTab({required String label, required bool isActive}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF0078C7) : const Color(0xFFF0F4FC),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : const Color(0xFF3F4752),
          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildOrderGrid(BuildContext context) {
    // Using LayoutBuilder to simulate grid on larger screens
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 768) {
          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildStandardOrderCard(
                    context: context,
                    title: 'Azure Horizon Bay Resort',
                    price: '\,240.00',
                    guestName: 'Marcus Thorne',
                    dates: 'Oct 24 - Oct 28, 2023',
                    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBy065BfM9D94tZJ6kyHrNXqCundQbnvk6KjoHaqio6mQlce79jpaE2IC9f8Ua6t3mHH_J0BdZprVjmQRQUaCG8lmHxWGdKHHlUs2g_aBsy9oX97sXy2Dg7L8FCJ7P7l1CKcqsybuJ5vMwjm6JXiXP62qO11Hu9KFqqK1V0LIGcH54c-i2e8jiBeqiFZGV3cZCzXQ932GpxvODBXn9FXlNnZ12itgisP9DgW7d3QUUpW9spaXJtOmowzM5yz3d63kNpjIqhrz5pb0c',
                  )),
                  const SizedBox(width: 32),
                  Expanded(child: _buildStandardOrderCard(
                    context: context,
                    title: 'Serene Alpine Lodge',
                    price: '\.50',
                    guestName: 'Elena Rodriguez',
                    dates: 'Nov 02 - Nov 05, 2023',
                    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuA9uerUVfiZOAw5rVKQmL_lIbVXucXyzRiUyyEVmCAP_2Qc3fOJaVCDCkzfPnmMsr7xLIiuUN5TUt85uwBI_5jugO8XgqAfj6bXt5x-IaoEUVq3Mc0RlBMKjRGm-o4Pgaa5nheeEvTA2vsdy_BsjGxULFzqbpMRAswc-aSGiHNb1fuI3JHnvZI2r1QhL_UO6-4sxjxnJ3uzRutun0zDDLF0PL_2R8r6005ukVPiSASq32XUnj7hsVe-Ip8AReLgV8j9lfl-4CbguYY',
                  )),
                ],
              ),
              const SizedBox(height: 32),
              _buildPremiumOrderCard(context, true),
            ],
          );
        } else {
          return Column(
            children: [
              _buildStandardOrderCard(
                context: context,
                title: 'Azure Horizon Bay Resort',
                price: '\,240.00',
                guestName: 'Marcus Thorne',
                dates: 'Oct 24 - Oct 28, 2023',
                imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBy065BfM9D94tZJ6kyHrNXqCundQbnvk6KjoHaqio6mQlce79jpaE2IC9f8Ua6t3mHH_J0BdZprVjmQRQUaCG8lmHxWGdKHHlUs2g_aBsy9oX97sXy2Dg7L8FCJ7P7l1CKcqsybuJ5vMwjm6JXiXP62qO11Hu9KFqqK1V0LIGcH54c-i2e8jiBeqiFZGV3cZCzXQ932GpxvODBXn9FXlNnZ12itgisP9DgW7d3QUUpW9spaXJtOmowzM5yz3d63kNpjIqhrz5pb0c',
              ),
              const SizedBox(height: 32),
              _buildStandardOrderCard(
                context: context,
                title: 'Serene Alpine Lodge',
                price: '\.50',
                guestName: 'Elena Rodriguez',
                dates: 'Nov 02 - Nov 05, 2023',
                imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuA9uerUVfiZOAw5rVKQmL_lIbVXucXyzRiUyyEVmCAP_2Qc3fOJaVCDCkzfPnmMsr7xLIiuUN5TUt85uwBI_5jugO8XgqAfj6bXt5x-IaoEUVq3Mc0RlBMKjRGm-o4Pgaa5nheeEvTA2vsdy_BsjGxULFzqbpMRAswc-aSGiHNb1fuI3JHnvZI2r1QhL_UO6-4sxjxnJ3uzRutun0zDDLF0PL_2R8r6005ukVPiSASq32XUnj7hsVe-Ip8AReLgV8j9lfl-4CbguYY',
              ),
              const SizedBox(height: 32),
              _buildPremiumOrderCard(context, false),
            ],
          );
        }
      },
    );
  }

  Widget _buildStandardOrderCard({
    required BuildContext context,
    required String title,
    required String price,
    required String guestName,
    required String dates,
    required String imageUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF005F9F).withOpacity(0.06),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFDBD0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('PENDING', style: TextStyle(color: Color(0xFF390C00), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    ),
                    const SizedBox(height: 8),
                    Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF181C22), letterSpacing: -0.5)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(price, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF005F9F), letterSpacing: -1.0)),
                  const Text('TOTAL PRICE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 1.5, color: Color(0xFF3F4752))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFDFE2EB)),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE5E8F0),
                  image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(guestName, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF181C22))),
                    const SizedBox(height: 2),
                    Text(dates, style: const TextStyle(fontSize: 14, color: Color(0xFF3F4752))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: TripwiseButtonStyles.primaryElevated(
                    radius: 12,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Accept', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => context.push('/direct_messaging'),
                style: TripwiseButtonStyles.surfaceElevated(
                  radius: 12,
                  backgroundColor: TripwiseColors.surfaceContainerLow,
                  foregroundColor: TripwiseColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                ),
                child: const Icon(Icons.chat_bubble),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPremiumOrderCard(BuildContext context, bool isWide) {
    Widget content = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF005F9F).withOpacity(0.06),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Flex(
        direction: isWide ? Axis.horizontal : Axis.vertical,
        children: [
          Container(
            height: isWide ? null : 200,
            width: isWide ? 300 : double.infinity,
            constraints: isWide ? const BoxConstraints(minHeight: 280) : null,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuB8baGRHs7qLqughKG-CClHI5DU9CIcwb9r7oqeH9euIiuV2Uz09_COLkO-JCesm-bkGxQFTPZRance6Hm8J41W2u2uPYH1uwcT8dbIszhywMJ7VsaSs_PjGcAk8cvU30gwsb_01hfrXevSCTwIlH7UqBoWMBf5s0lpd7ik_tOnxfNAbQy-_3xJtXWQ0HO-PvuLzDKZdWE_V7TQ4l56PIhcGkVn1GLRFuRRaQC71AXWTX8qM-vUxncWhvEzl4o-YCNT-3ZvlqY0UYM'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [const Color(0xFF181C22).withOpacity(0.6), Colors.transparent],
                ),
              ),
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0078C7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('PREMIUM BOOKING', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              ),
            ),
          ),
          Expanded(
            flex: isWide ? 1 : 0,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFDBD0),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text('PENDING APPROVAL', style: TextStyle(color: Color(0xFF390C00), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                            ),
                            const SizedBox(height: 12),
                            const Text('Royal Oasis Spa & Villa', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF181C22), letterSpacing: -1.0)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Text('\,120.00', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF005F9F), letterSpacing: -1.0)),
                          Text('LUXURY CLASS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 1.5, color: Color(0xFF3F4752))),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Flex(
                    direction: isWide ? Axis.horizontal : Axis.vertical,
                    crossAxisAlignment: isWide ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAG4gVpx5fHzjXb1hCTyaSaQYNyfWFQqFS1zgyYA0Lv43TZYN88HimgLIR5fQVK8F6DNaQbt2naRF_--avabDJyND6IS4mSm-u-D6BhJf0l4aN4g3lQCerylv38AWYJniFVRtvaZskxTccgDdRSrkWJNSqofjVG2Iz2Ljyx60cAwePQ8f8ULD5eQh_CgfuLQajBCVt64MoCFtRz2bHYWT_xLIsOvuzNvrelGyJtA3bNInyA6Gnf4gke5gZp77-wb007PhKX_PfKpdM'), fit: BoxFit.cover),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Sarah Jenkins', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text('Primary Guest', style: TextStyle(fontSize: 12, color: Color(0xFF3F4752))),
                            ],
                          ),
                        ],
                      ),
                      if (isWide)
                        Container(height: 32, width: 1, color: const Color(0xFFBFC7D4).withOpacity(0.3), margin: const EdgeInsets.symmetric(horizontal: 32)),
                      if (!isWide) const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Dec 15 - Dec 22', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('7 Nights Stay', style: TextStyle(fontSize: 12, color: Color(0xFF3F4752))),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: TripwiseButtonStyles.primaryElevated(
                            radius: 12,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                          ),
                          child: const Text('Accept Reservation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () => context.push('/direct_messaging'),
                        style: TripwiseButtonStyles.surfaceElevated(
                          radius: 12,
                          backgroundColor: TripwiseColors.surfaceContainerLow,
                          foregroundColor: TripwiseColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.contact_support),
                            SizedBox(width: 8),
                            Text('Contact', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
    return content;
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF005F9F).withOpacity(0.08),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      ),
      clipBehavior: Clip.antiAlias,
      child: BottomNavigationBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF005F9F),
        unselectedItemColor: const Color(0xFF3F4752),
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5),
        unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5),
        currentIndex: 2, // Orders
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/provider_dashboard');
              break;
            case 1:
              context.go('/provider_listings');
              break;
            case 2:
              context.go('/order_manager');
              break;
            case 3:
              context.go('/provider_finance');
              break;
          }
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Listings',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFD1E4FF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.receipt_long, color: Color(0xFF005F9F)),
            ),
            label: 'Orders',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.payments_outlined),
            label: 'Finance',
          ),
        ],
      ),
    );
  }
}
