import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/colors.dart';
import '../models/provider_listing.dart';
import '../services/provider_listing_draft_store.dart';
import '../services/provider_listings_api.dart';
import '../widgets/shared_taskbars.dart';
import '../widgets/shared_top_bars.dart';

class ProviderListingEditScreen extends StatefulWidget {
  const ProviderListingEditScreen({
    super.key,
    this.listingId,
    this.listingTitle,
  });

  final String? listingId;
  final String? listingTitle;

  @override
  State<ProviderListingEditScreen> createState() =>
      _ProviderListingEditScreenState();
}

class _ProviderListingEditScreenState extends State<ProviderListingEditScreen> {
  final ProviderListingsApi _api = ProviderListingsApi();
  final ImagePicker _imagePicker = ImagePicker();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _roomTypeController = TextEditingController();
  final TextEditingController _bedroomsController = TextEditingController();
  final TextEditingController _bathroomsController = TextEditingController();
  final TextEditingController _maxGuestsController = TextEditingController();
  final TextEditingController _amenitiesController = TextEditingController();

  ProviderListingDetail? _detail;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isDeleting = false;
  bool _isPickingImage = false;
  String? _error;

  String _selectedCategory = 'Hotel';
  XFile? _listingImage;
  Uint8List? _listingImageBytes;
  String? _listingImageFileName;
  String? _listingImageMimeType;

  int? get _listingId => int.tryParse(widget.listingId ?? '');
  bool get _isCreateDraft => _listingId == null;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.listingTitle ?? '';
    if (_isCreateDraft) {
      _loadDraft();
      return;
    }
    _load();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _roomTypeController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _maxGuestsController.dispose();
    _amenitiesController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final id = _listingId;
    if (id == null) {
      setState(() {
        _error = 'Missing listing id.';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final detail = await _api.fetchDetail(id);
      if (!mounted) return;
      setState(() {
        _detail = detail;
        _titleController.text = detail.title;
        _descriptionController.text = detail.description;
        _locationController.text = detail.location;
        _priceController.text = _formatNumber(detail.pricePerNight);
        _roomTypeController.text = detail.roomType;
        _bedroomsController.text = '${detail.bedrooms}';
        _bathroomsController.text = '${detail.bathrooms}';
        _maxGuestsController.text = '${detail.maxGuests}';
        _amenitiesController.text = detail.amenities.join(', ');
        _selectedCategory = detail.category;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  void _loadDraft() {
    final draft = ProviderListingDraftStore.current;
    if (draft == null) {
      setState(() {
        _error = 'No draft found. Please submit from Add Listing first.';
        _isLoading = false;
      });
      return;
    }
    setState(() {
      _titleController.text = draft.title;
      _descriptionController.text = draft.description;
      _locationController.text = draft.location;
      _priceController.text = _formatNumber(draft.pricePerNight);
      _roomTypeController.text = '${draft.category} Suite';
      _bedroomsController.text = '${draft.bedrooms}';
      _bathroomsController.text = '${draft.bathrooms}';
      _maxGuestsController.text = '${draft.maxGuests}';
      _amenitiesController.text = draft.amenities.join(', ');
      _selectedCategory = draft.category;
      _listingImageBytes = draft.imageBytes;
      _listingImageFileName = draft.imageFileName;
      _listingImageMimeType = draft.imageMimeType;
      _isLoading = false;
      _error = null;
    });
  }

  Future<void> _save() async {
    final id = _listingId;
    if (_isSaving) return;

    final maxGuests = _readPositiveInt(_maxGuestsController, 'Max guests');
    final bedrooms = _readPositiveInt(_bedroomsController, 'Bedrooms');
    final bathrooms = _readPositiveInt(_bathroomsController, 'Bathrooms');
    final pricePerNight = _readPositiveMoney(_priceController, 'Price per night');
    if (maxGuests == null ||
        bedrooms == null ||
        bathrooms == null ||
        pricePerNight == null) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      final amenities = _amenitiesController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      final imageUpload = _listingImageBytes == null
          ? null
          : {
              'fileName':
                  _listingImageFileName ??
                  _listingImage?.name ??
                  'listing-image.jpg',
              'mimeType':
                  _listingImageMimeType ??
                  _inferMimeType(_listingImage?.name ?? 'listing-image.jpg'),
              'dataBase64': base64Encode(_listingImageBytes!),
            };

      final detail = id == null
          ? await _api.createListing(
              roomsCount: ProviderListingDraftStore.current?.roomsCount ?? 1,
              title: _titleController.text.trim(),
              category: _selectedCategory,
              location: _locationController.text.trim(),
              description: _descriptionController.text.trim(),
              maxGuests: maxGuests,
              bedrooms: bedrooms,
              bathrooms: bathrooms,
              pricePerNight: pricePerNight,
              amenities: amenities,
              imageUpload: imageUpload,
            )
          : await _api.updateListing(
              id: id,
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim(),
              location: _locationController.text.trim(),
              category: _selectedCategory,
              roomType: _roomTypeController.text.trim(),
              pricePerNight: pricePerNight,
              bedrooms: bedrooms,
              bathrooms: bathrooms,
              maxGuests: maxGuests,
              amenities: amenities,
              imageUpload: imageUpload,
            );
      if (!mounted) return;
      setState(() => _detail = detail);
      ProviderListingDraftStore.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Listing updated successfully.'),
          backgroundColor: TripwiseColors.primary,
        ),
      );
      context.go('/provider_listings');
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: TripwiseColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
      final cropped = await _cropListingImage(file.path);
      if (cropped == null) return;
      final croppedXFile = XFile(
        cropped.path,
        name: 'listing-cover.jpg',
        mimeType: 'image/jpeg',
      );
      final bytes = await croppedXFile.readAsBytes();
      if (!mounted) return;
      setState(() {
        _listingImage = croppedXFile;
        _listingImageBytes = bytes;
        _listingImageFileName = croppedXFile.name;
        _listingImageMimeType = _inferMimeType(croppedXFile.name);
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

  Future<CroppedFile?> _cropListingImage(String sourcePath) {
    return ImageCropper().cropImage(
      sourcePath: sourcePath,
      maxWidth: 1600,
      maxHeight: 900,
      aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 85,
      uiSettings: [
        AndroidUiSettings(
          toolbarColor: Colors.transparent,
          toolbarWidgetColor: TripwiseColors.primary,
          activeControlsWidgetColor: TripwiseColors.primary,
          statusBarLight: true,
          navBarLight: true,
          initAspectRatio: CropAspectRatioPreset.ratio16x9,
          lockAspectRatio: true,
          hideBottomControls: false,
          showCropGrid: true,
          cropGridColumnCount: 2,
          cropGridRowCount: 2,
          cropGridColor: TripwiseColors.primary,
          aspectRatioPresets: const [CropAspectRatioPreset.ratio16x9],
        ),
        IOSUiSettings(
          minimumAspectRatio: 16 / 9,
          aspectRatioLockEnabled: true,
          aspectRatioPickerButtonHidden: true,
          aspectRatioPresets: const [CropAspectRatioPreset.ratio16x9],
          hidesNavigationBar: true,
        ),
      ],
    );
  }

  Future<void> _delete() async {
    final id = _listingId;
    if (id == null || _isDeleting) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Listing?'),
          content: const Text(
            'Are you sure you want to delete this listing? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(color: TripwiseColors.error),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);
    try {
      await _api.deleteListing(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Listing deleted successfully.'),
          backgroundColor: TripwiseColors.primary,
        ),
      );
      context.go('/provider_listings');
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: TripwiseColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = _detail;
    return Scaffold(
      backgroundColor: TripwiseColors.surface,
      appBar: ProviderAppBar(
        backRoute: '/provider_listings',
        onBack: () {
          if (context.canPop()) {
            context.pop();
            return;
          }
          context.go('/provider_listings');
        },
      ),
      body: _isLoading && detail == null
          ? const Center(child: CircularProgressIndicator())
          : _error != null && detail == null
          ? _buildErrorState()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_error != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: TripwiseColors.errorContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _error!,
                        style: const TextStyle(
                          color: TripwiseColors.onErrorContainer,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  _buildImage(detail),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _titleController,
                    label: 'Listing Title',
                  ),
                  const SizedBox(height: 12),
                  _buildCategoryField(),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _locationController,
                    label: 'Location',
                    icon: Icons.location_on_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _priceController,
                    label: 'Price per night',
                    icon: Icons.attach_money_rounded,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _roomTypeController,
                    label: 'Room Type',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _bedroomsController,
                          label: 'Bedrooms',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTextField(
                          controller: _bathroomsController,
                          label: 'Bathrooms',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTextField(
                          controller: _maxGuestsController,
                          label: 'Max guests',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _amenitiesController,
                    label: 'Amenities (comma separated)',
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: TripwiseButtonStyles.primaryElevated(
                        radius: 12,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _isSaving ? null : _save,
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: TripwiseColors.onPrimary,
                              ),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                    ),
                  ),
                  if (!_isCreateDraft) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: TripwiseButtonStyles.destructiveOutlined(
                          radius: 12,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: _isDeleting ? null : _delete,
                        child: _isDeleting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text(
                                'Delete Listing',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
      bottomNavigationBar: const ProviderTaskbar(
        currentTab: ProviderTaskbarTab.listings,
      ),
    );
  }

  Widget _buildImage(ProviderListingDetail? detail) {
    final imageUrl = detail?.imageUrl ?? '';
    final localBytes = _listingImageBytes;
    return Container(
      height: 170,
      decoration: BoxDecoration(
        color: TripwiseColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: TripwiseColors.outlineVariant,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (localBytes != null)
              Image.memory(localBytes, fit: BoxFit.cover)
            else if (imageUrl.isEmpty)
              const Center(child: Icon(Icons.image_rounded, size: 44))
            else if (imageUrl.startsWith('data:image'))
              Builder(
                builder: (context) {
                  final commaIdx = imageUrl.indexOf(',');
                  if (commaIdx <= 0) {
                    return const Center(
                      child: Icon(Icons.image_not_supported_rounded),
                    );
                  }
                  try {
                    final bytes = base64Decode(imageUrl.substring(commaIdx + 1));
                    return Image.memory(bytes, fit: BoxFit.cover);
                  } catch (_) {
                    return const Center(
                      child: Icon(Icons.image_not_supported_rounded),
                    );
                  }
                },
              )
            else
              Image.network(
                imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Center(child: Icon(Icons.image_not_supported_rounded)),
              ),
            Positioned(
              right: 10,
              bottom: 10,
              child: ElevatedButton.icon(
                onPressed: _isPickingImage ? null : _pickListingImage,
                style: TripwiseButtonStyles.surfaceElevated(
                  radius: 8,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  elevation: 0,
                ),
                icon: _isPickingImage
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.photo_camera_rounded, size: 16),
                label: Text(localBytes == null ? 'Change photo' : 'Selected'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon == null ? null : Icon(icon),
        filled: true,
        fillColor: TripwiseColors.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: TripwiseColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: TripwiseColors.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildCategoryField() {
    const options = ['Hotel', 'Apartment', 'Villa', 'Resort', 'Hostel'];
    final selected = options.contains(_selectedCategory)
        ? _selectedCategory
        : options.first;

    return DropdownButtonFormField<String>(
      initialValue: selected,
      decoration: InputDecoration(
        labelText: 'Category',
        filled: true,
        fillColor: TripwiseColors.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: TripwiseColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: TripwiseColors.primary),
        ),
      ),
      items: options
          .map(
            (category) =>
                DropdownMenuItem(value: category, child: Text(category)),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedCategory = value);
        }
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 46),
            const SizedBox(height: 12),
            const Text(
              "Couldn't load listing",
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: TripwiseColors.onSurfaceVariant),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: _load,
              style: TripwiseButtonStyles.primaryElevated(radius: 12),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  int? _readPositiveInt(TextEditingController controller, String label) {
    final text = controller.text.trim();
    final value = int.tryParse(text);
    if (value == null || value <= 0) {
      _showValidationError('$label must be a whole number greater than 0.');
      return null;
    }
    return value;
  }

  double? _readPositiveMoney(TextEditingController controller, String label) {
    final text = controller.text.trim();
    final value = double.tryParse(text);
    if (value == null || value <= 0) {
      _showValidationError('$label must be a number greater than 0.');
      return null;
    }
    return value;
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: TripwiseColors.error,
      ),
    );
  }

  String _formatNumber(num value) {
    if (value % 1 == 0) return value.toStringAsFixed(0);
    return value.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }

  String _inferMimeType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
}
