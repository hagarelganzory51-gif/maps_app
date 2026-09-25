class PlaceModel {
  final String name;
  final double latitude;
  final double longitude;
  final String? placeId;

  PlaceModel({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.placeId,
  });
}