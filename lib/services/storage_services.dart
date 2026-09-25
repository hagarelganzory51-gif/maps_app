import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/place_model.dart';

class StorageService {
  static const String boxName = 'places_box';
  static const String placesKey = 'places';

  Future<void> init() async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox(boxName);
    }
  }

  Future<void> savePlace(PlaceModel place) async {
    final box = Hive.box(boxName);

    final List<String> places =
        List<String>.from(
      box.get(
        placesKey,
        defaultValue: <String>[],
      ),
    );

    final Map<String, dynamic> placeData = {
      'name': place.name,
      'latitude': place.latitude,
      'longitude': place.longitude,
      'placeId': place.placeId,
    };

    places.add(jsonEncode(placeData));

    await box.put(
      placesKey,
      places,
    );
  }

  List<PlaceModel> getPlaces() {
    final box = Hive.box(boxName);

    final List<String> places =
        List<String>.from(
      box.get(
        placesKey,
        defaultValue: <String>[],
      ),
    );

    return places.map((place) {
      final Map<String, dynamic> data =
          jsonDecode(place);

      return PlaceModel(
        name: data['name'],
        latitude:
            (data['latitude'] as num).toDouble(),
        longitude:
            (data['longitude'] as num).toDouble(),
        placeId: data['placeId'],
      );
    }).toList();
  }

  Future<void> deletePlace(int index) async {
    final box = Hive.box(boxName);

    final List<String> places =
        List<String>.from(
      box.get(
        placesKey,
        defaultValue: <String>[],
      ),
    );

    if (index < 0 || index >= places.length) {
      return;
    }

    places.removeAt(index);

    await box.put(
      placesKey,
      places,
    );
  }

  Future<void> clearPlaces() async {
    final box = Hive.box(boxName);

    await box.delete(placesKey);
  }
}