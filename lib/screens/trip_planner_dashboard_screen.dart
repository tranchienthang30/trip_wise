import 'package:flutter/material.dart';

class TripPlannerDashboardScreen extends StatelessWidget {
  const TripPlannerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FF).withOpacity(0.9),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF005F9F)),
          onPressed: () {},
        ),
        title: const Text(
          'Voyage',
          style: TextStyle(
              color: Color(0xFF005F9F),
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD1E4FF), width: 2),
                image: const DecorationImage(
                  image: NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuA5DAnB3-2pZxgQf-tM5tZJfq5_lrz5ICs6xPs6d7ZW1DUqsjwKCBZwNOvS3JDsNfcu8YmBOjZlmcLQhEu3dXf7ikTLqOQVL3JwODTMx0LpKwe3RcztE4pYwaA2S86HB7I2uj_dTL_QJO7Hox8wLm8t8WBJuVxOlgO9NYUrrB3BpdvYiF4y8FukRdRPbND8qJN5UzvWcXa-TBz7CIG9IyPEsRGise4qrMNgsd1PgeAJFbDtmCwuCnXiR5hOUqJrmSkPWOOIvCyHLpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Plans',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w800,
                color: Color(0xFF181C22),
                letterSpacing: -1.0,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your upcoming journeys and past adventures curated in one place.',
              style: TextStyle(fontSize: 18, color: Color(0xFF3F4752)),
            ),
            const SizedBox(height: 24),
            _buildSearchBar(),
            const SizedBox(height: 32),
            _buildCards(context),
            const SizedBox(height: 100), // padding for fab/bottom nav
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFFF5E1F),
        onPressed: () {},
        icon: const Icon(Icons.add, color: Colors.white, size: 28),
        label: const Text(
          'Create New Trip',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE5E8F0),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: const TextField(
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: Color(0xFF3F4752)),
          hintText: 'Search hotels, flights, or attractions',
          hintStyle: TextStyle(color: Color(0xFFBFC7D4)),
          border: InputBorder.none,
          suffixIcon: Icon(Icons.mic, color: Color(0xFF3F4752)),
        ),
      ),
    );
  }

  Widget _buildCards(BuildContext context) {
    // using a column for mobile-first layout 
    return Column(
      children: [
        _buildTripCard(
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuAtd4rG6jbMlvqj0CuXDXckWUi-pj5sTdmlJPfRO4SLB_9A3_PsnLBbAsR4fRQzIUJB14dJg0RDMNPxOa0LeXdmMgoYVwC07jF8Wh9Q8qkji0BkjhzmQZ1UrTJTv24RzbVove60hfORAhdQ0Eo4lWFx6OErXIEpF_3i2XmSEifD2Jrqr2jI2hesQeS3mvsaGARVKYkPmtRnYAPekzD_dz7IwcrT0pUYoPItMbAmsY-F7Eex3BiHJL_fPCYN37Ns1Bp8p5kTXVH5TOE',
          status: 'Upcoming',
          statusColor: const Color(0xFF005F9F),
          statusBg: Colors.white.withOpacity(0.9),
          title: 'Summer in Bali',
          dates: 'Aug 12 - Aug 24, 2024',
          avatars: [
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCS-pP84zAFVkbYoOzicPznMikv2nZaa1L1CEfeb09HSar6Xm42sZwvHvCbj3PqCiJ8xrJxDGv-rCiJoB5yN8ELVPuyUWVLxaQu9rTk7M7STyOywhF2xAG760Gh-7ZkrumqYNPXTf4lCMV-RRJsDzdRItnROKJrcG8TzrCPEek2Kytl19HDUnAX5gKZTxumCMB94SlHGbFB-nICgnSthxdnPso6m-Uku9aLgRg3hEyXoLNCIOOXh2GTD5iXnV6m5O-XelUUEcK6LNg',
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCtgmmTOnmBfSrExNnVSbEZ4j9wuMQDsajWTCbTyBjlWN_G3yj-ZnWcxJJbhOkDYJvBvzk6M7lYcfkcMxR-keTPBqdTSjOXl0uGbn209v5pBf05sJL2cVF89W_pPlrnyUrBi6BWNrcwYHsK0rS7kesXU3xA9MZZyZiAAPxaYSrhzFpQ_d80A2hD9IqIHDeWpAra3JsK0mQp9oj_SXT8PGB6-UNwifEFZikKtgQ0bA3coghQqZjlt1vPXXMbVeYZlAw24GIyXqEh3-g'
          ],
          hasMore: true,
        ),
        const SizedBox(height: 24),
        _buildTripCard(
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuC9aOEbMD1vS_f3Xead13joL4Eu0_-ETCpIK6ej8QjajItJ70QmOr6rpTH7V-V_tto-2hxMVJmlQJNPf5NPF2ARC-xg9Q5ny-XwawoJYR-9wk18hXui_T1bFDa3mxl5IglR84Sl3EqC23SnnSkDhDtrVnEGdzMvRA23O2JDIxEkypMqnFt1KNUVp3YGjCdU665J_0ORFY1p5HDpVsr-PpSdKbarBPKMnKP9g6PCmknNO7iujTeuxDZ6oQ3Dq4hi_X2Al1JkvrwZGrk',
          status: 'Dreaming',
          statusColor: const Color(0xFF005F9F),
          statusBg: Colors.white.withOpacity(0.9),
          title: 'Winter in Tokyo',
          dates: 'Dec 15 - Dec 30, 2024',
          avatars: [
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCZpR6ZOQr16POQL1Tvtc8CoHt-VrcwSiKWYEjOJxwKZgBWQ2YgBKNz-9wSHbjDbvRmZc2T7myjxsR2LbuIKU7UQIdc5Dke5B8njB0qhAesWvRlGzsDTQVbb928lVURn2KqtVpJGRQOo_okRM-N608-4GViRmMWFJCvFK_z3fQzWwAdgPj5ve2hFal7ghPNe6RWV2DeL_tgrX-32UR-hQhTxoEd8mPcRQDFZAlnTmg-amc3IPcwexibfPThyIkTibAOZlkNUU7fYRE',
          ],
        ),
        const SizedBox(height: 24),
        _buildTripCard(
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuDvq_UmHkKWggLrqMcQTyyIss5_hwV1Cc3TByustuY3azVeGju-nVy9oLoEfpMLUQoyzQFUP_xUws-5bGheo7PhS0syGzxIiTT-b69Wd8vJ8F6xdTFGxnZvQ8RK6IR8TOajLTb9KR1ryQKnzFz1S35UDscjLxO-OY8ko8shxE5PxRkaXrWq8iFaTLeMrZbAJ1WeEq_QmxtpQRjtJrl4RhdpcCsDHmMtL_9ZlvW7uCDOM6plxv3QpQLE17640BLHT8oESVfsW-9UAGw',
          status: 'Completed',
          statusColor: const Color(0xFF64748B), // slate-500
          statusBg: const Color(0xFFF1F5F9).withOpacity(0.9),
          title: 'Spring in Paris',
          dates: 'Apr 05 - Apr 12, 2023',
          avatars: [
            'https://lh3.googleusercontent.com/aida-public/AB6AXuC0meq4hwqB8AEyYqlfGUOqIS7IS2HFZdx8l-NcGUjUZ3d1KV9Q8gE81Iz3l4ZTXFIVOXOhvx3i8eIjz1ZfgSF_TQy2y_Qvorso6Ntil-eAhZhwSJ15rBPbGwmyA-QsL_Lz3_OnSKRRlE8Agn7798oKc6f3nbghgmjhloRqpSGe8tNOfkJyFNoWgOa9Vu0rhKFbMt-XxPF8PFtBQvOcYrEHkKJ1MIXBkxYLbYve5uc9IPkHgAG5vt5GN4epWPl0xTGGWaXbLy47W9g',
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCi1LIvTyGQtpnSbeKecGsSbcMZj-Rt51oJq-qfArZCaoTYHDo866tgOYJ9BPDBfw1KPeVBrTt1A4RVzvKqMDYo5Xe6-LI5zkpHOvZRwJtMG6SOGifqu4WN1XS7QSphwiXqZudUAHrbpwBNUO3Udt-ESLvIb0oe4to1mQ1-fJ2WsBV26KPB_l9E5xzRbQsQG2YIIE5XHPQbhNxDV6fahLlcUXUsQWXI7fgH9THvjba2d3823P1KRSl3YB-nUpT--9KbSKww_6NZSFU',
          ],
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(48),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4FC).withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFBFC7D4), // outline-variant
              style: BorderStyle.solid, // Using solid instead of dashed as default
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFD1E4FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add_location_alt, color: Color(0xFF005F9F), size: 32),
              ),
              const SizedBox(height: 16),
              const Text(
                'Plan a New Adventure',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF181C22)),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ready for your next getaway? Start mapping out your journey.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF3F4752)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTripCard({
    required String imageUrl,
    required String status,
    required Color statusColor,
    required Color statusBg,
    required String title,
    required String dates,
    required List<String> avatars,
    bool hasMore = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.network(
                imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(height: 200, color: Colors.grey[200]),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF181C22),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Color(0xFF3F4752)),
                    const SizedBox(width: 8),
                    Text(
                      dates,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF3F4752), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        for (int i = 0; i < avatars.length; i++)
                          Align(
                            widthFactor: 0.7,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 14,
                                backgroundImage: NetworkImage(avatars[i]),
                              ),
                            ),
                          ),
                        if (hasMore)
                          Align(
                            widthFactor: 0.7,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 14,
                                backgroundColor: const Color(0xFF9DCAFF),
                                child: const Text(
                                  '+3',
                                  style: TextStyle(color: Color(0xFF00497C), fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5E1F),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        elevation: 0,
                      ),
                      onPressed: () {},
                      child: const Text('View Timeline', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
      ),
      child: BottomNavigationBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFEA580C), // orange-600
        unselectedItemColor: const Color(0xFF94A3B8), // slate-400
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'EXPLORE',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.travel_explore),
            label: 'TRIPS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'SAVED',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'PROFILE',
          ),
        ],
      ),
    );
  }
}
