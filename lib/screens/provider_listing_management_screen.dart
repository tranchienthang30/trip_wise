import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/colors.dart';

class ProviderListingManagementScreen extends StatefulWidget {
  const ProviderListingManagementScreen({super.key});

  @override
  State<ProviderListingManagementScreen> createState() =>
      _ProviderListingManagementScreenState();
}

class _ProviderListingManagementScreenState
    extends State<ProviderListingManagementScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TripwiseColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: TripwiseColors.primaryFixed,
            backgroundImage: const NetworkImage(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuBaszrIEZvetULMLtB4tGcayxtAiexPhLYVbVFR6IEPCOIXRLJpZzksMaf692woplhhlPAKnn5KaSkQbxtMSMmQF98rKS4m9WFG3pxEmLoHhVr2pRwShaZOIB11tl30K8z6Rrs08ECf0KPACkwUfZv5FJHN3wFJnFAahMaUNVlh1g1F60132JmcIEEPjecY7be3nn6f90BMysvWRRUC5MqdN1O-LypaVFCKjBTUtV0A5CnBBWi-UKvZLOCvb1elu0MgPd-h-dNilNE',
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Tripwise Business',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications,
              color: TripwiseColors.primary,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Text(
                'Your Properties',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search your listings...',
                  prefixIcon: Icon(
                    Icons.search,
                    color: TripwiseColors.onSurfaceVariant.withOpacity(0.6),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: TripwiseColors.surfaceContainerLow,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Featured Listing
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildFeaturedListingCard(context),
            ),

            const SizedBox(height: 24),

            // Other Listings Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildSmallListingCard(
                    id: '2',
                    title: 'Skyline Villa',
                    location: 'Dubai, UAE',
                    imageUrl:
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuCeSRBZpEm6COdw47xML03qawIbNIuCnCmTdpZAIc_I903eUMd-CY-tSV2R42wvsdze6yrkC1KMb5oPNdf6p1p-LodN_KOTAvFa2WDVXJ6oexvZvl2LESdd-UxiptJOzNz7_WcjMMEbcaSW6wTr35AqtWRswIiMgNKRR3F79Bs5UHss-rwm3Yl1uPTkJeEg1I51y-7jnSczM_yQ1mbbVr9ArTUqA_2VOqDtrBxhboDjEur_idx6dUOo2A6Eoe8BiCwm8v8nTVCzdzw',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSmallHorizontalCard(
                          id: '3',
                          title: 'Emerald Peak Lodge',
                          location: 'Aspen, Colorado',
                          status: 'Inactive',
                          imageUrl:
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuCjgNBEaizFqkyIyTky527euXwCAAhTdeTxgWfTOdctL1Bp8QFUraua3PkMeXmk1CTz8xxGECdYWH44SY6oTt_3KPBKjsgvrYuTRpX1502wbrXgcpi_AjrI67PzBusi9uCbk4eoWhljhDMkDpvXlSXYDQIry8nHv7SsCrg9WauNeK0RKo563BkwHx-ip4h2UtyyghW_P8zS7lwcnDnVKY4eNLTFmZzs0rFduTIHIPp_1BJykRgj5AKCO6WR0a6He3n22SMLlMOnNdc',
                          isActive: false,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSmallHorizontalCard(
                          id: '4',
                          title: 'Rustic Oak Manor',
                          location: 'Cotswolds, UK',
                          status: 'Active',
                          imageUrl:
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuC5iciP3Kb45FJD115sApvepsPrvWZCYguXkbrwYfuYScL2kUtQnPRIy_PbyEqsVr5U1O62dHvvjiVj-svmwQ-wNJT-B9ygiCFoPqdf_6pFAvqu6svG75m2kngUXyVYnMkBeL_hebaN9b6G9tE2FJNZrn-N8YlkTkwjiajmhwvP2UOYdfNqGFPD6KiUsAqpgKNworZN2RFBsmqnTqQ6pzCJ0POkZ3tRg1lHHeqJf2RQUBZM5Wq2c8WsCFkit5qu7wX51fG-O0NIcEs',
                          isActive: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Empty State / Call to Action
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: TripwiseColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: TripwiseColors.outlineVariant.withOpacity(0.3),
                    strokeAlign: BorderSide.strokeAlignCenter,
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                child: Column(
                  children: [
                    Icon(
                      Icons.add_business,
                      size: 48,
                      color: TripwiseColors.primary.withOpacity(0.4),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Expand your reach',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'List more services to attract high-value Tripwise travelers worldwide.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: TripwiseColors.onSurfaceVariant.withOpacity(0.8),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/add_new_listing_form');
        },
        backgroundColor: TripwiseColors.secondaryContainer,
        icon: const Icon(Icons.add),
        label: const Text('Add Listing'),
      ),
      bottomNavigationBar: _buildProviderBottomNavBar(),
    );
  }

  Widget _buildFeaturedListingCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: TripwiseColors.primary.withOpacity(0.06),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Image
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuDnhdr7bJmb0ybErSXUx4ND_1wUpmS_drgRpercFQ5YIulRwSjxVJu8PPmEfyToZ4lf0IR3Iidpws9Dm_fhiC-qz15bGe4isMcCKQ97if_PnctpSyOruNVJNTLAQ1MCHydlL7NTBSC1DK4AK0Wj5cDmPbDXEC-dyoOOQpRh90NYvpgfrILTLcwG1o6ko9TjENoCD63Nufvw3PTOuN75RrJjWRWShl0-O2VIquZAFVTqn7lMvGHZC0RrsgeSNCSO1e-Xi_vIeqSuRcA',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  decoration: BoxDecoration(
                    color: TripwiseColors.primary.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: TripwiseColors.onPrimary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Active',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: TripwiseColors.onPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Azure Horizon Bay Resort',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Santorini, Greece • Premium',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: TripwiseColors.onSurfaceVariant.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.push(
                          '/provider_listing_edit?id=1&title=Azure Horizon Bay Resort',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TripwiseColors.surfaceContainerHigh,
                        foregroundColor: TripwiseColors.onSurface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit Listing'),
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

  Widget _buildSmallListingCard({
    required String id,
    required String title,
    required String location,
    required String imageUrl,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  location,
                  style: TextStyle(
                    fontSize: 12,
                    color: TripwiseColors.onSurfaceVariant.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.push('/provider_listing_edit?id=$id&title=$title');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TripwiseColors.surfaceContainerLow,
                      foregroundColor: TripwiseColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallHorizontalCard({
    required String id,
    required String title,
    required String location,
    required String status,
    required String imageUrl,
    required bool isActive,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  imageUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: isActive
                        ? TripwiseColors.primary.withOpacity(0.9)
                        : TripwiseColors.outlineVariant.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: isActive
                          ? TripwiseColors.onPrimary
                          : TripwiseColors.onSurface,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  location,
                  style: TextStyle(
                    fontSize: 11,
                    color: TripwiseColors.onSurfaceVariant.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          context.push('/provider_listing_edit?id=$id&title=$title');
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: TripwiseColors.primary,
                          side: const BorderSide(color: TripwiseColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Edit',
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          context.push('/provider_analytics?id=$id&title=$title');
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: TripwiseColors.onSurfaceVariant,
                          side: const BorderSide(color: TripwiseColors.outlineVariant),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Analytics',
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
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

  Widget _buildProviderBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: 1,
      selectedItemColor: TripwiseColors.secondaryContainer,
      unselectedItemColor: TripwiseColors.onSurfaceVariant,
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
        BottomNavigationBarItem(
          icon: const Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.inventory_2),
          label: 'Listings',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.receipt_long),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.payment),
          label: 'Finance',
        ),
      ],
    );
  }
}
