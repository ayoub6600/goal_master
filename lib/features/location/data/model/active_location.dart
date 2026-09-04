/// Where the customer is shopping from.
///
/// Coordinates and the resolved Goal Master zone always travel together. That
/// pairing is the whole reason this type exists: before it, location was two
/// loose doubles in SharedPreferences, so every consumer that needed a zone
/// re-derived one for itself — and the booking flow, unable to derive one at
/// all, gave up and asked the customer to pick a region by hand.
///
/// The zone is resolved on the SERVER, never here. Boundaries are business
/// data; a device that works them out locally will disagree with the backend
/// the first time a zone is redrawn, and the customer sees pitches they cannot
/// book.
class ActiveLocation {
  final int id;
  final double latitude;
  final double longitude;

  /// Null means a real place we do not serve yet.
  ///
  /// Deliberately nullable rather than defaulted to "all zones": widening the
  /// search would show pitches in another city and hide the fact that Goal
  /// Master has not reached this customer's area.
  final int? zoneId;
  final String? zoneName;

  final String? formattedAddress;
  final String? city;
  final String? label;

  /// current_location | map | saved_location
  final String source;

  final bool isSaved;

  const ActiveLocation({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.source,
    this.zoneId,
    this.zoneName,
    this.formattedAddress,
    this.city,
    this.label,
    this.isSaved = false,
  });

  bool get isServiceable => zoneId != null && zoneId! > 0;

  /// What the location chip shows: the most specific name we actually have.
  String get displayName {
    for (final candidate in [label, zoneName, city, formattedAddress]) {
      if (candidate != null && candidate.trim().isNotEmpty) return candidate.trim();
    }
    return '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
  }

  static ActiveLocation? maybeFrom(dynamic json) {
    if (json is! Map) return null;

    final id = _toInt(json['id']);
    final lat = _toDouble(json['latitude']);
    final lng = _toDouble(json['longitude']);
    if (lat == null || lng == null) return null;

    return ActiveLocation(
      id: id ?? 0,
      latitude: lat,
      longitude: lng,
      zoneId: _toInt(json['zone_id']),
      zoneName: json['zone_name']?.toString(),
      formattedAddress: json['formatted_address']?.toString(),
      city: json['city']?.toString(),
      label: json['label']?.toString(),
      source: json['source']?.toString() ?? 'map',
      isSaved: json['is_saved'] == true || json['is_saved'] == 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'latitude': latitude,
        'longitude': longitude,
        'zone_id': zoneId,
        'zone_name': zoneName,
        'formatted_address': formattedAddress,
        'city': city,
        'label': label,
        'source': source,
        'is_saved': isSaved,
      };

  @override
  bool operator ==(Object other) =>
      other is ActiveLocation &&
      other.id == id &&
      other.latitude == latitude &&
      other.longitude == longitude &&
      other.zoneId == zoneId;

  @override
  int get hashCode => Object.hash(id, latitude, longitude, zoneId);

  @override
  String toString() =>
      'ActiveLocation(#$id, $latitude/$longitude, zone=$zoneId "$zoneName", $source)';
}

int? _toInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is double) return v.toInt();
  return int.tryParse(v.toString());
}

double? _toDouble(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  return double.tryParse(v.toString());
}
