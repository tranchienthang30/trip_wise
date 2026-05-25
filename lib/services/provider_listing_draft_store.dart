import 'dart:typed_data';

class ProviderListingDraftData {
  ProviderListingDraftData({
    required this.title,
    required this.category,
    required this.location,
    required this.description,
    required this.roomsCount,
    required this.maxGuests,
    required this.bedrooms,
    required this.bathrooms,
    required this.pricePerNight,
    required this.amenities,
    required this.imageFileName,
    required this.imageMimeType,
    required this.imageBytes,
  });

  final String title;
  final String category;
  final String location;
  final String description;
  final int roomsCount;
  final int maxGuests;
  final int bedrooms;
  final int bathrooms;
  final double pricePerNight;
  final List<String> amenities;
  final String imageFileName;
  final String imageMimeType;
  final Uint8List imageBytes;
}

class ProviderListingDraftStore {
  ProviderListingDraftStore._();

  static ProviderListingDraftData? _draft;

  static ProviderListingDraftData? get current => _draft;

  static void save(ProviderListingDraftData draft) {
    _draft = draft;
  }

  static void clear() {
    _draft = null;
  }
}
