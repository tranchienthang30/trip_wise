import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/colors.dart';
import '../services/provider_listing_draft_store.dart';
import '../widgets/shared_taskbars.dart';
import '../widgets/shared_top_bars.dart';

class AddNewListingFormScreen extends StatefulWidget {
  const AddNewListingFormScreen({super.key});

  @override
  State<AddNewListingFormScreen> createState() =>
      _AddNewListingFormScreenState();
}

class _AddNewListingFormScreenState extends State<AddNewListingFormScreen> {
  final ImagePicker _imagePicker = ImagePicker();

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
  bool _isPickingImage = false;
  int _roomsCount = 1;
  String _category = 'Hotel';
  final Set<String> _amenities = {'WiFi', 'Pool'};
  XFile? _listingImage;
  Uint8List? _listingImageBytes;

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

    if (_listingImage == null || _listingImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a listing photo before publishing.'),
          backgroundColor: TripwiseColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      ProviderListingDraftStore.save(
        ProviderListingDraftData(
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
          imageFileName: _listingImage!.name,
          imageMimeType: _inferMimeType(_listingImage!.name),
          imageBytes: _listingImageBytes!,
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Draft prepared. Continue to Save Changes to persist.'),
          backgroundColor: TripwiseColors.primary,
        ),
      );
      await context.push('/provider_listing_edit?mode=create');
      if (!mounted) return;
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

  Future<void> _pickListingImage() async {
    if (_isPickingImage) return;

    setState(() => _isPickingImage = true);
    try {
      final file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1600,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _listingImage = file;
        _listingImageBytes = bytes;
      });
    } catch (error) {
      if (!mounted) return;
      final message = error is MissingPluginException
          ? 'Image picker is not ready yet. Please fully restart the app.'
          : error.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: TripwiseColors.error),
      );
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TripwiseColors.surface,
      appBar: const ProviderAppBar(),
      body: SingleChildScrollView(
<<<<<<< HEAD
        padding: TripwiseInsets.screen,
=======
        padding: const EdgeInsets.all(16),
>>>>>>> 31ec7c5 (Fix UI provider listing)
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    controller: _titleController,
                    label: 'Property Name',
                    hint: 'e.g. Sunset Peak Luxury Villa',
                  ),
                  const SizedBox(height: 10),
                  _buildDropdown(),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: _locationController,
                    label: 'Location',
                    hint: 'City, country or full address',
                    icon: Icons.location_on_rounded,
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    hint: 'Tell travelers what makes your space unique...',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 10),
                  _buildImagePicker(),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rooms & Pricing',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
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
                  const SizedBox(height: 10),
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
            const SizedBox(height: 12),
            _buildSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Essential Amenities',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _amenityChip('WiFi', Icons.wifi_rounded),
                      _amenityChip('Pool', Icons.pool_rounded),
                      _amenityChip('Parking', Icons.local_parking_rounded),
                      _amenityChip('A/C', Icons.ac_unit_rounded),
                      _amenityChip('Breakfast', Icons.free_breakfast_rounded),
                      _amenityChip('Gym', Icons.fitness_center_rounded),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _publish,
                style: TripwiseButtonStyles.primaryElevated(
                  radius: 14,
                  padding: const EdgeInsets.symmetric(vertical: 13),
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
                            'Submit for Review',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.rocket_launch_rounded, size: 20),
                        ],
                      ),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
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
        const SizedBox(height: 6),
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
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    final bytes = _listingImageBytes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Listing Photo',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Material(
          color: TripwiseColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: _isPickingImage ? null : _pickListingImage,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: TripwiseColors.outlineVariant),
              ),
              clipBehavior: Clip.antiAlias,
              child: bytes == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _isPickingImage
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.add_photo_alternate_rounded,
                                size: 36,
                                color: TripwiseColors.primary,
                              ),
                        const SizedBox(height: 6),
                        const Text(
                          'Add a clear cover photo',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'JPG, PNG, or WEBP up to 5MB',
                          style: TextStyle(
                            color: TripwiseColors.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    )
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.memory(bytes, fit: BoxFit.cover),
                        Positioned(
                          right: 10,
                          bottom: 10,
                          child: ElevatedButton.icon(
                            onPressed: _isPickingImage
                                ? null
                                : _pickListingImage,
                            style: TripwiseButtonStyles.surfaceElevated(
                              radius: 8,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 9,
                              ),
                              elevation: 0,
                            ),
                            icon: const Icon(
                              Icons.photo_camera_rounded,
                              size: 16,
                            ),
                            label: const Text('Change'),
                          ),
                        ),
                      ],
                    ),
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
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: categories.contains(_category)
              ? _category
              : categories.first,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: TripwiseColors.onSurface,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: TripwiseColors.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
          items: categories
              .map(
                (value) => DropdownMenuItem(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
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
        const SizedBox(height: 6),
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
<<<<<<< HEAD
                icon: const Icon(Icons.remove_rounded),
=======
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 36,
                  height: 36,
                ),
                icon: const Icon(Icons.remove, size: 18),
>>>>>>> 31ec7c5 (Fix UI provider listing)
              ),
              Expanded(
                child: Text(
                  '$_roomsCount',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _roomsCount++),
<<<<<<< HEAD
                icon: const Icon(Icons.add_rounded),
=======
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 36,
                  height: 36,
                ),
                icon: const Icon(Icons.add, size: 18),
>>>>>>> 31ec7c5 (Fix UI provider listing)
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
      showCheckmark: false,
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

  String _inferMimeType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
}
