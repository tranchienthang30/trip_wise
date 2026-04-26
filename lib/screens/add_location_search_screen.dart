import 'package:flutter/material.dart';

class AddLocationSearchScreen extends StatefulWidget {
  const AddLocationSearchScreen({super.key});

  @override
  State<AddLocationSearchScreen> createState() => _AddLocationSearchScreenState();
}

class _AddLocationSearchScreenState extends State<AddLocationSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 24, bottom: 96),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 896), // max-w-4xl
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 32), // space-y-8 approx
                  _buildRecentSearches(),
                  const SizedBox(height: 24), // space-y-6 internal
                  _buildPopularNearYou(),
                  const SizedBox(height: 32),
                  _buildTopSuggestions(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF0F4FC).withOpacity(0.8), // bg-[#f0f4fc]/80
      elevation: 0, // No shadow in flutter app bar unless using scrolledUnderElevation or Custom widget. Let's add slight shadow via container or keep it flat per strict instruction. We will use a bottom border.
      scrolledUnderElevation: 0,
      centerTitle: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF005F9F).withOpacity(0.06), // shadow-[0px_10px_40px_rgba(0,95,159,0.06)]
                blurRadius: 40,
                offset: const Offset(0, 10),
              )
            ]
          ),
          height: 1.0,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF005F9F)),
        onPressed: () {},
      ),
      title: const Text(
        'Location Search',
        style: TextStyle(
          color: Color(0xFF005F9F),
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 24),
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFE5E8F0), // surface-container-high
            image: DecorationImage(
              image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuDV_9RDDqhpsGOfMNdl9cl9UcrWGoJvw23RaLzu-MbMj-8tTcf_jnYxmBixYzlGp1pAVyWGAynWHPuf4NhsiAfWXnGq0rs4aWNjt2Bdn9x-OS5d68kHudQ2r9TcuKBDlhCb52yE1edOZE8r2faSz1JVUflVh10w3awNPvhc9WZmwdV9StQp10l6SsLR0HgheXaMtbPOs6qwHZ30Y2DMSbyuQW71M9xRELJrdVQD9d7Eg5w3pJ2LlmFH5BQ2F4GqZQaWqYj10qHbRuoF'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFDFE2EB), // surface-container-highest
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF005F9F).withOpacity(0.06),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search hotels, flights, or attractions',
          hintStyle: const TextStyle(color: Color(0xFF3F4752), fontSize: 16), // text-on-surface-variant
          prefixIcon: const Icon(Icons.search, color: Color(0xFF3F4752)),
          suffixIcon: IconButton(
            icon: const Icon(Icons.mic, color: Color(0xFF3F4752)),
            onPressed: () {},
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(vertical: 20), // py-4
        ),
        style: const TextStyle(fontSize: 16, color: Color(0xFF181C22)),
      ),
    );
  }

  Widget _buildRecentSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Searches',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF181C22)), // text-headline-sm
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              _buildRecentSearchChip('history', 'Tokyo, Japan'),
              const SizedBox(width: 12),
              _buildRecentSearchChip('history', 'Santorini Villas'),
              const SizedBox(width: 12),
              _buildRecentSearchChip('history', 'Flights to NYC'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentSearchChip(String iconName, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // px-4 py-2
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FC), // bg-surface-container-low
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.history, size: 18, color: Color(0xFF3F4752)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF181C22))), // text-label-md
        ],
      ),
    );
  }

  Widget _buildPopularNearYou() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Popular Near You',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF181C22)),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none, // Allow shadow to flow out
          child: Row(
            children: [
              _buildPopularChip(Icons.local_cafe, 'Artisan Coffee'),
              const SizedBox(width: 12),
              _buildPopularChip(Icons.museum, 'Local Museums'),
              const SizedBox(width: 12),
              _buildPopularChip(Icons.park, 'City Parks'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPopularChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white, // bg-surface-container-lowest
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFBFC7D4).withOpacity(0.15)), // border-outline-variant/15
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF005F9F).withOpacity(0.06),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF005F9F)), // text-primary
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF005F9F))),
        ],
      ),
    );
  }

  Widget _buildTopSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top Suggestions',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF181C22)),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            double cardWidth = constraints.maxWidth;
            bool isMultiColumn = cardWidth > 600;
            
            if (isMultiColumn) {
               return GridView.count(
                 crossAxisCount: 2,
                 crossAxisSpacing: 16,
                 mainAxisSpacing: 16,
                 childAspectRatio: 2.5, // Approx ratio
                 shrinkWrap: true,
                 physics: const NeverScrollableScrollPhysics(),
                 children: [
                   _buildResultCard(
                     'https://lh3.googleusercontent.com/aida-public/AB6AXuA1M7zFh9UWZyvBCmbjjJxYAKRiP3cENUU_FHI8uy6t1wtl2UPgeR19clBpSmlsVKrZeqSpLRlLN6Bu-mX-bcig0YSR5P5UBVpagWNkyWamofcjNsLoUUydP6ghmmXeZ5YmqFq1pGVNXGCxrJt2jmK3R_C7kI1Hh8nS0vgUBgA7VgnYwl23D2x1Pmz48JItmkFWIe2wjv8NKrrKTwRDWxmYoFB8fyKKKAClamK42rC11FzRfm2wQRQVH6DQ_5_hqgrpQSbVutcdtLpm',
                     Icons.location_on, 'Destination', 'Kyoto, Japan', '4.9', '� Popular destination', isStar: true
                   ),
                   _buildResultCard(
                     'https://lh3.googleusercontent.com/aida-public/AB6AXuAj4fQOg8QZm-lNaPr5XoLHIgYy9eZfF9CDmNczQHt2ieKYHBb2DydyAG0K61lDhHkZUprnwhMcx_0nuaaItitGsJ9uKLOIBUaHbvO6PQRPXgII62-Rj3glJOaq0GlsOmfeHBSFLgEep9KjQKD6YhibjYzIjEMrEk7Usw8BXb-byo_g29VcTigpnNnnp1SN2IgJI4V_PO4eEcqhL9L3r7oODH_z9v3-iQyM3BUhBAc9iux66F6UvvmBooE18I5QtyivPRlR6o1bYlxA',
                     Icons.hotel, 'Hotel', 'The Azure Resort & Spa', '4.8', '� 2.5 km away', isStar: true
                   ),
                   _buildResultCard(
                     'https://lh3.googleusercontent.com/aida-public/AB6AXuD4gDufpT0H5jujA2CitqU49MIy9olSAZFCdVxcKrM0KPTUIjRkdzzWKoE-QtSjApP0oWNaXDS86mqvbVuKKJ889U5INx2IEpC2EM9Onx3EE9ZmPsKiMNNyMiXrAH_cZu2c3ZVf8PAB_69FN6m27N5aYTH9KJrdqyV-WNZLE4wmQs4vhEr95HSNXJ8KGTCWzNC92SJ1nG4AZPAC0l7TL59cB3gwVbDiEx6S25RDLxCn_T1aFwQBKQP72vnZf4OgveQiRbjaACN6NERj',
                     Icons.flight, 'Flight', 'JFK to LHR (Direct)', 'From \$', '� Departs tomorrow', isStar: false
                   ),
                   _buildResultCard(
                     'https://lh3.googleusercontent.com/aida-public/AB6AXuAKQ9_e9K5U9_Iz0lNVKaf30n449Wm2vJQoafMjrzMbpJ-iSiHp9ovmJS9Vf27aW5ifaMNaffQKtop701vKLIv5BHdurJAqvoXj5EAVe3YHQLB54N8Hv_s4i95OXslj32XlPFr7mWgeEsrkBhfD9KOtDI1nt0OEqVymr6yFZpt1JfHN5DBhOYN-v8bhOGrVIitvFMMNIrWSUzZ4o2p7vpCjrWJEOKbT7ktSUHmEV5l83hBuRY5hI9vPpn2wqWdVXKCAo7XonfrAkMVP',
                     Icons.attractions, 'Attraction', 'Museum of Modern Art', '4.7', '� Open now', isStar: true
                   ),
                 ],
               );
            } else {
               return Column(
                 children: [
                   _buildResultCard( // Kyoto
                     'https://lh3.googleusercontent.com/aida-public/AB6AXuA1M7zFh9UWZyvBCmbjjJxYAKRiP3cENUU_FHI8uy6t1wtl2UPgeR19clBpSmlsVKrZeqSpLRlLN6Bu-mX-bcig0YSR5P5UBVpagWNkyWamofcjNsLoUUydP6ghmmXeZ5YmqFq1pGVNXGCxrJt2jmK3R_C7kI1Hh8nS0vgUBgA7VgnYwl23D2x1Pmz48JItmkFWIe2wjv8NKrrKTwRDWxmYoFB8fyKKKAClamK42rC11FzRfm2wQRQVH6DQ_5_hqgrpQSbVutcdtLpm',
                     Icons.location_on, 'Destination', 'Kyoto, Japan', '4.9', '� Popular destination', isStar: true, isListView: true
                   ),
                   const SizedBox(height: 16),
                   _buildResultCard( // Hotel
                     'https://lh3.googleusercontent.com/aida-public/AB6AXuAj4fQOg8QZm-lNaPr5XoLHIgYy9eZfF9CDmNczQHt2ieKYHBb2DydyAG0K61lDhHkZUprnwhMcx_0nuaaItitGsJ9uKLOIBUaHbvO6PQRPXgII62-Rj3glJOaq0GlsOmfeHBSFLgEep9KjQKD6YhibjYzIjEMrEk7Usw8BXb-byo_g29VcTigpnNnnp1SN2IgJI4V_PO4eEcqhL9L3r7oODH_z9v3-iQyM3BUhBAc9iux66F6UvvmBooE18I5QtyivPRlR6o1bYlxA',
                     Icons.hotel, 'Hotel', 'The Azure Resort & Spa', '4.8', '� 2.5 km away', isStar: true, isListView: true
                   ),
                   const SizedBox(height: 16),
                   _buildResultCard( // Flight
                     'https://lh3.googleusercontent.com/aida-public/AB6AXuD4gDufpT0H5jujA2CitqU49MIy9olSAZFCdVxcKrM0KPTUIjRkdzzWKoE-QtSjApP0oWNaXDS86mqvbVuKKJ889U5INx2IEpC2EM9Onx3EE9ZmPsKiMNNyMiXrAH_cZu2c3ZVf8PAB_69FN6m27N5aYTH9KJrdqyV-WNZLE4wmQs4vhEr95HSNXJ8KGTCWzNC92SJ1nG4AZPAC0l7TL59cB3gwVbDiEx6S25RDLxCn_T1aFwQBKQP72vnZf4OgveQiRbjaACN6NERj',
                     Icons.flight, 'Flight', 'JFK to LHR (Direct)', 'From \$', ' Departs tomorrow', isStar: false, isListView: true
                   ),
                   const SizedBox(height: 16),
                   _buildResultCard( // Museum
                     'https://lh3.googleusercontent.com/aida-public/AB6AXuAKQ9_e9K5U9_Iz0lNVKaf30n449Wm2vJQoafMjrzMbpJ-iSiHp9ovmJS9Vf27aW5ifaMNaffQKtop701vKLIv5BHdurJAqvoXj5EAVe3YHQLB54N8Hv_s4i95OXslj32XlPFr7mWgeEsrkBhfD9KOtDI1nt0OEqVymr6yFZpt1JfHN5DBhOYN-v8bhOGrVIitvFMMNIrWSUzZ4o2p7vpCjrWJEOKbT7ktSUHmEV5l83hBuRY5hI9vPpn2wqWdVXKCAo7XonfrAkMVP',
                     Icons.attractions, 'Attraction', 'Museum of Modern Art', '4.7', '� Open now', isStar: true, isListView: true
                   ),
                 ],
               );
            }
          }
        ),
      ],
    );
  }

  Widget _buildResultCard(String imageUrl, IconData icon, String type, String title, String value, String subtitle, {required bool isStar, bool isListView = false}) {
    return Container(
      height: isListView ? 120 : null,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF005F9F).withOpacity(0.06),
            blurRadius: 40,
            offset: const Offset(0, 10),
          )
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          SizedBox(
            width: isListView ? 120 : 140, // approx 1/3
            height: double.infinity,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 14, color: const Color(0xFF3F4752)),
                      const SizedBox(width: 4),
                      Text(type, style: const TextStyle(fontSize: 12, color: Color(0xFF3F4752))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF181C22)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (isStar) ...[
                        const Icon(Icons.star, size: 14, color: Color(0xFFFF5E1F)),
                        const SizedBox(width: 4),
                        Text(value, style: const TextStyle(fontSize: 12, color: Color(0xFFFF5E1F))),
                      ] else ...[
                        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF005F9F))),
                      ],
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          subtitle,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF3F4752)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
