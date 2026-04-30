import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/colors.dart';

class ProviderListingAddScreen extends StatefulWidget {
  const ProviderListingAddScreen({super.key});

  @override
  State<ProviderListingAddScreen> createState() =>
      _ProviderListingAddScreenState();
}

class _ProviderListingAddScreenState extends State<ProviderListingAddScreen> {
  int _currentStep = 0;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _priceController;
  late TextEditingController _bedroomsController;
  late TextEditingController _bathroomsController;
  late TextEditingController _guestsController;

  String _selectedCategory = 'Hotel';
  List<String> _amenities = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _locationController = TextEditingController();
    _priceController = TextEditingController();
    _bedroomsController = TextEditingController();
    _bathroomsController = TextEditingController();
    _guestsController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _guestsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TripwiseColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Add New Listing',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.swap_horiz_rounded,
              color: TripwiseColors.primary,
            ),
            tooltip: 'Back to Planner',
            onPressed: () => context.go('/trip_planner_dashboard'),
          ),
        ],
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 2) {
            setState(() {
              _currentStep += 1;
            });
          } else {
            _submitListing();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() {
              _currentStep -= 1;
            });
          }
        },
        steps: [
          // Step 1: Basic Information
          Step(
            title: const Text('Basic Information'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Listing Title',
                    hintText: 'Enter your listing title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  items: ['Hotel', 'Apartment', 'Villa', 'Resort', 'Hostel']
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: 'Location',
                    hintText: 'Enter location',
                    prefixIcon: const Icon(Icons.location_on),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Describe your listing...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  maxLines: 4,
                ),
              ],
            ),
            isActive: _currentStep >= 0,
          ),

          // Step 2: Pricing & Details
          Step(
            title: const Text('Pricing & Details'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: 'Price per night',
                    hintText: 'Enter price (e.g., 299)',
                    prefixIcon: const Icon(Icons.attach_money),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _bedroomsController,
                        decoration: InputDecoration(
                          labelText: 'Bedrooms',
                          hintText: '0',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _bathroomsController,
                        decoration: InputDecoration(
                          labelText: 'Bathrooms',
                          hintText: '0',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _guestsController,
                        decoration: InputDecoration(
                          labelText: 'Max Guests',
                          hintText: '0',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Amenities',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    'WiFi',
                    'Pool',
                    'Gym',
                    'Parking',
                    'Kitchen',
                    'AC',
                  ]
                      .map((amenity) => FilterChip(
                            label: Text(amenity),
                            selected: _amenities.contains(amenity),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _amenities.add(amenity);
                                } else {
                                  _amenities.remove(amenity);
                                }
                              });
                            },
                          ))
                      .toList(),
                ),
              ],
            ),
            isActive: _currentStep >= 1,
          ),

          // Step 3: Review
          Step(
            title: const Text('Review'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildReviewSection(
                  title: 'Title',
                  value: _titleController.text,
                ),
                _buildReviewSection(
                  title: 'Category',
                  value: _selectedCategory,
                ),
                _buildReviewSection(
                  title: 'Location',
                  value: _locationController.text,
                ),
                _buildReviewSection(
                  title: 'Price per night',
                  value: '\$${_priceController.text}',
                ),
                _buildReviewSection(
                  title: 'Bedrooms',
                  value: _bedroomsController.text,
                ),
                _buildReviewSection(
                  title: 'Bathrooms',
                  value: _bathroomsController.text,
                ),
                _buildReviewSection(
                  title: 'Max Guests',
                  value: _guestsController.text,
                ),
                _buildReviewSection(
                  title: 'Amenities',
                  value: _amenities.isEmpty ? 'None selected' : _amenities.join(', '),
                ),
              ],
            ),
            isActive: _currentStep >= 2,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSection({required String title, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: TripwiseColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Divider(
            color: TripwiseColors.outlineVariant.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  void _submitListing() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Listing created successfully!')),
    );
    Navigator.of(context).pop();
  }
}
