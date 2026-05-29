DateTime? _parseIsoDateOnly(String? iso) {
  if (iso == null || iso.length < 10) return null;
  final y = int.tryParse(iso.substring(0, 4));
  final m = int.tryParse(iso.substring(5, 7));
  final d = int.tryParse(iso.substring(8, 10));
  if (y == null || m == null || d == null) return null;
  if (m < 1 || m > 12 || d < 1 || d > 31) return null;
  return DateTime(y, m, d);
}

class TripCompanion {
  TripCompanion({required this.name, required this.image});

  final String name;
  final String? image;

  factory TripCompanion.fromJson(Map<String, dynamic> json) => TripCompanion(
        name: json['name'] as String? ?? '',
        image: json['image'] as String?,
      );
}

class TripItem {
  TripItem({
    required this.time,
    required this.title,
    required this.location,
    required this.category,
    required this.activityId,
    required this.companions,
  });

  final String time;
  final String title;
  final String location;
  final String category;
  final int? activityId;
  final List<TripCompanion> companions;

  factory TripItem.fromJson(Map<String, dynamic> json) => TripItem(
        time: json['time'] as String? ?? '',
        title: json['title'] as String? ?? '',
        location: json['location'] as String? ?? '',
        category: json['category'] as String? ?? 'SIGHTSEEING',
        activityId: (json['activityId'] as num?)?.toInt(),
        companions: ((json['companions'] as List<dynamic>?) ?? const [])
            .map((e) => TripCompanion.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class TripDay {
  TripDay({required this.dayIndex, required this.date, required this.items});

  final int dayIndex;
  final String? date;
  final List<TripItem> items;

  factory TripDay.fromJson(Map<String, dynamic> json) => TripDay(
        dayIndex: (json['dayIndex'] as num?)?.toInt() ?? 0,
        date: json['date'] as String?,
        items: ((json['items'] as List<dynamic>?) ?? const [])
            .map((e) => TripItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class Trip {
  Trip({
    required this.id,
    required this.title,
    required this.destination,
    required this.status,
    required this.statusLabel,
    required this.coverImage,
    required this.mapImage,
    required this.startDate,
    required this.endDate,
    required this.days,
  });

  final String id;
  final String title;
  final String? destination;
  final String status;
  final String statusLabel;
  final String? coverImage;
  final String? mapImage;
  final String? startDate;
  final String? endDate;
  final List<TripDay> days;

  String get resolvedStatus {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = _parseIsoDateOnly(startDate);
    final end = _parseIsoDateOnly(endDate);
    final raw = status.toUpperCase();

    if (start != null && end != null) {
      if (today.isBefore(start)) return 'UPCOMING';
      if (today.isAfter(end)) return 'COMPLETED';
      return 'ONGOING';
    }
    if (start != null) {
      return today.isBefore(start) ? 'UPCOMING' : 'ONGOING';
    }
    if (end != null) {
      return today.isAfter(end) ? 'COMPLETED' : 'ONGOING';
    }
    if (raw == 'UPCOMING' || raw == 'ONGOING' || raw == 'COMPLETED') return raw;
    return 'UPCOMING';
  }

  factory Trip.fromJson(Map<String, dynamic> json) => Trip(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        destination: json['destination'] as String?,
        status: json['status'] as String? ?? 'UPCOMING',
        statusLabel: json['statusLabel'] as String? ?? 'TRIP',
        coverImage: json['coverImage'] as String?,
        mapImage: json['mapImage'] as String?,
        startDate: json['startDate'] as String?,
        endDate: json['endDate'] as String?,
        days: ((json['days'] as List<dynamic>?) ?? const [])
            .map((e) => TripDay.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class TripsResponse {
  TripsResponse({required this.trips});

  final List<Trip> trips;

  /// The screen shows one trip — prefer the ONGOING one, else the first.
  Trip? get current {
    if (trips.isEmpty) return null;
    for (final t in trips) {
      if (t.resolvedStatus == 'ONGOING') return t;
    }
    return trips.first;
  }

  factory TripsResponse.fromJson(Map<String, dynamic> json) => TripsResponse(
        trips: ((json['trips'] as List<dynamic>?) ?? const [])
            .map((e) => Trip.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
