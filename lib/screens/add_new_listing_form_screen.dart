import 'package:flutter/material.dart';

class AddNewListingFormScreen extends StatefulWidget {
  const AddNewListingFormScreen({super.key});

  @override
  State<AddNewListingFormScreen> createState() => _AddNewListingFormScreenState();
}

class _AddNewListingFormScreenState extends State<AddNewListingFormScreen> {
  int _roomsCount = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 24, bottom: 120),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1024), // max-w-5xl
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 768) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 5, child: _buildLeftColumn()),
                        const SizedBox(width: 24), // gap-grid-gutter
                        Expanded(flex: 7, child: _buildRightColumn()),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        _buildLeftColumn(),
                        const SizedBox(height: 24),
                        _buildRightColumn(),
                      ],
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white.withOpacity(0.8),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      title: const Text(
        'Add Listing',
        style: TextStyle(
          color: Color(0xFF0F172A), // slate-900 equivalent
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF1D4ED8)),
        onPressed: () {},
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 24),
          child: TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFF2F3F9), // surface-container-low
              foregroundColor: const Color(0xFF004779), // primary
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            child: const Text('Save Draft', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: const Color(0xFFDBEAFE).withOpacity(0.2), // border-blue-100/20 approx
          height: 1.0,
        ),
      ),
    );
  }

  Widget _buildLeftColumn() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF005F9F).withOpacity(0.04),
                blurRadius: 40,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Property Photos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF191C20))),
              const SizedBox(height: 16),
              const Text('High-quality photos increase your listing visibility by 60%.', style: TextStyle(fontSize: 14, color: Color(0xFF414750))),
              const SizedBox(height: 24),
              _buildPhotoUploadGrid(),
              const SizedBox(height: 24),
              Row(
                children: const [
                  Icon(Icons.info, color: Color(0xFF004779), size: 14),
                  SizedBox(width: 8),
                  Text('MIN. 5 PHOTOS RECOMMENDED', style: TextStyle(color: Color(0xFF004779), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF005F9F), // primary-container
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF005F9F).withOpacity(0.04),
                blurRadius: 40,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Pro Tip', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFB9D8FF))), // on-primary-container
              SizedBox(height: 8),
              Text(
                "Listings with clear descriptions of local amenities often convert better. Don't forget to mention that nearby hidden cafe!",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xCCB9D8FF), // slightly opaque to match html
                  height: 1.5, 
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoUploadGrid() {
    return Column(
      children: [
        Container(
          height: 160,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF2F3F9), // surface-container-low
            borderRadius: BorderRadius.circular(12),
            // We use simple border as drawing dashed requires CustomPaint
            border: Border.all(color: const Color(0xFFC1C7D2), width: 2), 
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.add_a_photo, color: Color(0xFF717781), size: 36),
              SizedBox(height: 8),
              Text('UPLOAD MAIN IMAGE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF717781), letterSpacing: 1.0)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F3F9),
                    borderRadius: BorderRadius.circular(12),
                    image: const DecorationImage(
                      image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBd_ldhuk0qs8dyrx9CRPuuAGY-Usi_sTl9xqExmLH1wXfxrYX0uiO-Sz9aE5zryErEIpt711zGNZaBEVNfPkkGGL0FwIRmKjHVqkkU3MXCxLug5S_60PKXYtEokpe3UJudqlh5w78QbLyR0OsPQ_VkRwUAWBI4ugtrghUyt1IDrDSm_WRuAjm3ACBWy4pLm6UvonzJhwSWI7Pxb4dtCeZ3XU_Sg5wMIjpGzXNm826hRyOy9YIn45Ha2jVx3MoXYNKJApqshDVUT2h7'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(Color(0x33000000), BlendMode.darken),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F3F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFC1C7D2), width: 2),
                  ),
                  child: const Center(
                    child: Icon(Icons.add, color: Color(0xFF717781)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRightColumn() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF005F9F).withOpacity(0.04),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField('PROPERTY NAME', 'e.g. Sunset Peak Luxury Villa'),
          const SizedBox(height: 32),
          _buildAddressField(),
          const SizedBox(height: 32),
          _buildTextAreaField('DESCRIPTION', 'Tell travelers what makes your space unique...'),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(child: _buildRoomsCounter()),
              const SizedBox(width: 16),
              Expanded(child: _buildPriceField()),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFE1E2E8)),
          const SizedBox(height: 16),
          _buildAmenitiesSection(),
          const SizedBox(height: 24),
          _buildPublishAction(),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF414750), letterSpacing: 0.5)),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFC1C7D2)),
            filled: true,
            fillColor: const Color(0xFFF2F3F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ADDRESS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF414750), letterSpacing: 0.5)),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: 'Enter street address, city, and zip',
            hintStyle: const TextStyle(color: Color(0xFFC1C7D2)),
            prefixIcon: const Icon(Icons.location_on, color: Color(0xFF717781)),
            filled: true,
            fillColor: const Color(0xFFF2F3F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 192, // h-48
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFE6E8EE),
            borderRadius: BorderRadius.circular(12),
            image: const DecorationImage(
              image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuDu8TcBFOOaPCsJ51hAyCBUmFOzpvEgFco6-wsjDpP4eJLYMdPnnH-_SsvqTwXsAOsA91d8YKozf358nokFMQXur4CdEwKk7enDAlpr8wDLYSM3QyvStuaXEXcl0wXpy0uujdDY2-J3vd7Qs01W1Vjy_vaTIubyTWc9QGjF5gg-yFw6OACZ2oWVFN541i_pNMfOqINzPfGLN_r-v-NGxDRghd75bhXspS7Zk9Dqy-p6nh8HfsCft-6WImpXNw1pA69p9RxFPIylrNQ9'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                 color: Colors.white,
                 borderRadius: BorderRadius.circular(24),
                 boxShadow: [
                   BoxShadow(
                     color: Colors.black.withOpacity(0.1),
                     blurRadius: 4,
                     offset: const Offset(0, 2),
                   ),
                 ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.location_on, color: Color(0xFF004779), size: 16),
                  SizedBox(width: 8),
                  Text('Pin Location', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextAreaField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF414750), letterSpacing: 0.5)),
        const SizedBox(height: 8),
        TextField(
          maxLines: 4,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFC1C7D2)),
            filled: true,
            fillColor: const Color(0xFFF2F3F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildRoomsCounter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('NUMBER OF ROOMS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF414750), letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F3F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  if (_roomsCount > 1) {
                    setState(() {
                      _roomsCount--;
                    });
                  }
                },
                icon: const Icon(Icons.remove, color: Color(0xFF191C20)),
              ),
              Expanded(
                child: Text(
                  _roomsCount.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF191C20)),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _roomsCount++;
                  });
                },
                icon: const Icon(Icons.add, color: Color(0xFF191C20)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('PRICE PER NIGHT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF414750), letterSpacing: 0.5)),
        const SizedBox(height: 8),
        TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '0.00',
            hintStyle: const TextStyle(color: Color(0xFFC1C7D2)),
            prefixIcon: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Text('\$', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF414750))),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            filled: true,
            fillColor: const Color(0xFFF2F3F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildAmenitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ESSENTIAL AMENITIES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF414750), letterSpacing: 0.5)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildAmenityChip(Icons.wifi, 'WiFi'),
            _buildAmenityChip(Icons.pool, 'Pool'),
            _buildAmenityChip(Icons.ac_unit, 'A/C'),
            _buildAmenityChip(Icons.local_parking, 'Parking'),
          ],
        ),
      ],
    );
  }

  Widget _buildAmenityChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE1E2E8)), // surface-container-highest
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF191C20)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF191C20))),
        ],
      ),
    );
  }

  Widget _buildPublishAction() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5E1F), // secondary-container
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
              elevation: 8,
              shadowColor: const Color(0xFFFF5E1F).withOpacity(0.3),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('Publish Listing', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(width: 12),
                Icon(Icons.rocket_launch, size: 24),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text('By publishing, you agree to Tripwise Service Provider Terms.', style: TextStyle(fontSize: 12, color: Color(0xFF717781))),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF005F9F).withOpacity(0.06),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)), // rounded-t-[2.5rem]
      ),
      clipBehavior: Clip.antiAlias,
      child: BottomNavigationBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFEA580C), // orange-600 approx
        unselectedItemColor: const Color(0xFF94A3B8), // slate-400
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        unselectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        currentIndex: 1, // Listings
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'DASHBOARD',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.domain),
            label: 'LISTINGS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'ORDERS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payments),
            label: 'FINANCE',
          ),
        ],
      ),
    );
  }
}
