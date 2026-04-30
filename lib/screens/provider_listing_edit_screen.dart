import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/colors.dart';

class ProviderListingEditScreen extends StatefulWidget {
  final String? listingId;
  final String? listingTitle;

  const ProviderListingEditScreen({
    super.key,
    this.listingId,
    this.listingTitle,
  });

  @override
  State<ProviderListingEditScreen> createState() =>
      _ProviderListingEditScreenState();
}

class _ProviderListingEditScreenState extends State<ProviderListingEditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _priceController;
  String _selectedCategory = 'Hotel';
  String _selectedStatus = 'Active';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.listingTitle ?? '');
    _descriptionController =
        TextEditingController(text: 'Luxury accommodation with premium amenities...');
    _locationController = TextEditingController(text: 'Santorini, Greece');
    _priceController = TextEditingController(text: '\$299');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _priceController.dispose();
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
          'Edit Listing',
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: TripwiseColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: TripwiseColors.outlineVariant.withOpacity(0.3),
                  ),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuDnhdr7bJmb0ybErSXUx4ND_1wUpmS_drgRpercFQ5YIulRwSjxVJu8PPmEfyToZ4lf0IR3Iidpws9Dm_fhiC-qz15bGe4isMcCKQ97if_PnctpSyOruNVJNTLAQ1MCHydlL7NTBSC1DK4AK0Wj5cDmPbDXEC-dyoOOQpRh90NYvpgfrILTLcwG1o6ko9TjENoCD63Nufvw3PTOuN75RrJjWRWShl0-O2VIquZAFVTqn7lMvGHZC0RrsgeSNCSO1e-Xi_vIeqSuRcA',
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: FloatingActionButton.small(
                        backgroundColor: TripwiseColors.primary,
                        onPressed: () {},
                        child: Icon(
                          Icons.camera_alt,
                          color: TripwiseColors.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Listing Details',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 12),

              // Title Input
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

              // Category Dropdown
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

              // Location Input
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

              // Price Input
              TextField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Price per night',
                  hintText: 'Enter price',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Description Input
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
              const SizedBox(height: 24),

              // Status Section
              Text(
                'Status',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 12),

              // Status Dropdown
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: InputDecoration(
                  labelText: 'Listing Status',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                items: ['Active', 'Inactive', 'Pending Review']
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TripwiseColors.primary,
                    foregroundColor: TripwiseColors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Listing updated successfully!')),
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Delete Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: TripwiseColors.error,
                    side: BorderSide(color: TripwiseColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('Delete Listing?'),
                        content: const Text(
                          'Are you sure you want to delete this listing? This action cannot be undone.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Listing deleted successfully!'),
                                ),
                              );
                            },
                            child: Text(
                              'Delete',
                              style: TextStyle(color: TripwiseColors.error),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text(
                    'Delete Listing',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
