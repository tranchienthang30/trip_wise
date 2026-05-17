import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/colors.dart';
import '../services/provider_listings_api.dart';
import '../widgets/shared_taskbars.dart';
import '../widgets/shared_top_bars.dart';

class AddNewListingFormScreen extends StatefulWidget {
  const AddNewListingFormScreen({super.key});

  @override
  State<AddNewListingFormScreen> createState() =>
      _AddNewListingFormScreenState();
}

class _AddNewListingFormScreenState extends State<AddNewListingFormScreen> {
  final ProviderListingsApi _api = ProviderListingsApi();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController(
    text: '200',
  );
  final TextEditingController _bedroomsController = TextEditingController(
    text: '1',
  );
  final TextEditingController _bathroomsController = TextEditingController(
    text: '1',
  );
  final TextEditingController _maxGuestsController = TextEditingController(
    text: '2',
  );

  bool _isSubmitting = false;
  int _roomsCount = 1;
  String _category = 'Hotel';
  final Set<String> _amenities = {'WiFi', 'Pool'};

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _maxGuestsController.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    if (_isSubmitting) return;

    final title = _titleController.text.trim();
    final location = _locationController.text.trim();
    if (title.isEmpty || location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Property name and location are required.'),
          backgroundColor: TripwiseColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final listing = await _api.createListing(
        title: title,
        category: _category,
        location: location,
        description: _descriptionController.text.trim(),
        roomsCount: _roomsCount,
        maxGuests: _safeInt(_maxGuestsController.text, 2),
        bedrooms: _safeInt(_bedroomsController.text, 1),
        bathrooms: _safeInt(_bathroomsController.text, 1),
        pricePerNight: _safeDouble(_priceController.text, 200),
        amenities: _amenities.toList(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Listing published successfully.'),
          backgroundColor: TripwiseColors.primary,
        ),
      );
      context.go(
        '/provider_listing_edit?id=${listing.id}&title=${Uri.encodeComponent(listing.title)}',
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: TripwiseColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TripwiseColors.surface,
      appBar: const ProviderAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create New Listing',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'Publish a new property for travelers in a few steps.',
              style: TextStyle(color: TripwiseColors.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            _buildSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    controller: _titleController,
                    label: 'Property Name',
                    hint: 'e.g. Sunset Peak Luxury Villa',
                  ),
                  const SizedBox(height: 14),
                  _buildDropdown(),
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: _locationController,
                    label: 'Location',
                    hint: 'City, country or full address',
                    icon: Icons.location_on,
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    hint: 'Tell travelers what makes your space unique...',
                    maxLines: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rooms & Pricing',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: _buildRoomsCounter()),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTextField(
                          controller: _priceController,
                          label: 'Price per night (USD)',
                          hint: '200',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _bedroomsController,
                          label: 'Bedrooms',
                          hint: '1',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTextField(
                          controller: _bathroomsController,
                          label: 'Bathrooms',
                          hint: '1',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTextField(
                          controller: _maxGuestsController,
                          label: 'Max guests',
                          hint: '2',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Essential Amenities',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _amenityChip('WiFi', Icons.wifi),
                      _amenityChip('Pool', Icons.pool),
                      _amenityChip('Parking', Icons.local_parking),
                      _amenityChip('A/C', Icons.ac_unit),
                      _amenityChip('Breakfast', Icons.free_breakfast),
                      _amenityChip('Gym', Icons.fitness_center),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _publish,
                style: TripwiseButtonStyles.primaryElevated(
                  radius: 14,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: TripwiseColors.onPrimary,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Publish Listing',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.rocket_launch, size: 20),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'By publishing, you agree to Tripwise Service Provider Terms.',
              style: TextStyle(
                fontSize: 12,
                color: TripwiseColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const ProviderTaskbar(
        currentTab: ProviderTaskbarTab.listings,
      ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon == null ? null : Icon(icon),
            filled: true,
            fillColor: TripwiseColors.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown() {
    const categories = ['Hotel', 'Apartment', 'Villa', 'Resort', 'Hostel'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Category', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: categories.contains(_category) ? _category : categories.first,
          decoration: InputDecoration(
            filled: true,
            fillColor: TripwiseColors.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
          ),
          items: categories
              .map(
                (value) => DropdownMenuItem(value: value, child: Text(value)),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _category = value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildRoomsCounter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Number of Rooms',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: TripwiseColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  if (_roomsCount > 1) {
                    setState(() => _roomsCount--);
                  }
                },
                icon: const Icon(Icons.remove),
              ),
              Expanded(
                child: Text(
                  '$_roomsCount',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _roomsCount++),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _amenityChip(String label, IconData icon) {
    final selected = _amenities.contains(label);
    return FilterChip(
      selected: selected,
      onSelected: (on) {
        setState(() {
          if (on) {
            _amenities.add(label);
          } else {
            _amenities.remove(label);
          }
        });
      },
      avatar: Icon(
        icon,
        size: 16,
        color: selected ? TripwiseColors.onPrimary : null,
      ),
      label: Text(label),
      selectedColor: TripwiseColors.primary,
      checkmarkColor: TripwiseColors.onPrimary,
      labelStyle: TextStyle(
        color: selected ? TripwiseColors.onPrimary : TripwiseColors.onSurface,
        fontWeight: FontWeight.w600,
      ),
      backgroundColor: TripwiseColors.surfaceContainerLow,
      side: BorderSide(
        color: selected
            ? TripwiseColors.primary
            : TripwiseColors.outlineVariant,
      ),
    );
  }

  int _safeInt(String raw, int fallback) {
    final v = int.tryParse(raw.trim());
    if (v == null || v <= 0) return fallback;
    return v;
  }

  double _safeDouble(String raw, double fallback) {
    final v = double.tryParse(raw.trim());
    if (v == null || v <= 0) return fallback;
    return v;
  }
}
