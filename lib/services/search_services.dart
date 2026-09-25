import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/place_model.dart';

class SearchService {
  static const String apiKey =
      String.fromEnvironment('GOOGLE_MAPS_API_KEY');

  Future<List<PlaceModel>> getSuggestions(
    String input,
  ) async {
    if (input.trim().isEmpty) {
      return [];
    }

    debugPrint(
      'API KEY EXISTS: ${apiKey.isNotEmpty}',
    );

    final Uri url = Uri.parse(
      'https://places.googleapis.com/v1/places:autocomplete',
    );

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': apiKey,
        'X-Goog-FieldMask':
            'suggestions.placePrediction.placeId,'
            'suggestions.placePrediction.text',
      },
      body: jsonEncode({
        'input': input,
      }),
    );

    debugPrint(
      'Autocomplete status: ${response.statusCode}',
    );

    debugPrint(
      'Autocomplete response: ${response.body}',
    );

    if (response.statusCode != 200) {
      return [];
    }

    final Map<String, dynamic> data =
        jsonDecode(response.body);

    final List suggestions =
        data['suggestions'] ?? [];

    return suggestions
        .where(
          (item) =>
              item['placePrediction'] != null,
        )
        .map((item) {
          final prediction =
              item['placePrediction'];

          return PlaceModel(
            name: prediction['text']['text'],
            latitude: 0,
            longitude: 0,
            placeId: prediction['placeId'],
          );
        })
        .toList();
  }

  Future<PlaceModel?> getPlaceDetails(
    String placeId,
  ) async {
    final Uri url = Uri.parse(
      'https://places.googleapis.com/v1/places/$placeId',
    );

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': apiKey,
        'X-Goog-FieldMask':
            'id,displayName,location',
      },
    );

    debugPrint(
      'Place details status: ${response.statusCode}',
    );

    debugPrint(
      'Place details response: ${response.body}',
    );

    if (response.statusCode != 200) {
      return null;
    }

    final Map<String, dynamic> data =
        jsonDecode(response.body);

    final location = data['location'];

    if (location == null) {
      return null;
    }

    return PlaceModel(
      name: data['displayName']['text'],
      latitude: location['latitude'],
      longitude: location['longitude'],
      placeId: data['id'],
    );
  }
}