import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class RouteService {
  static const String apiKey =
      String.fromEnvironment('GOOGLE_MAPS_API_KEY');

  Future<List<LatLng>> getRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final Uri url = Uri.parse(
      'https://routes.googleapis.com/directions/v2:computeRoutes',
    );

    final response = await http.post(
      
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': apiKey,
        'X-Goog-FieldMask':
            'routes.polyline.encodedPolyline',
      },
      body: jsonEncode({
        'origin': {
          'location': {
            'latLng': {
              'latitude': origin.latitude,
              'longitude': origin.longitude,
            },
          },
        },
        'destination': {
          'location': {
            'latLng': {
              'latitude': destination.latitude,
              'longitude': destination.longitude,
            },
          },
        },
        'travelMode': 'DRIVE',
        'routingPreference': 'TRAFFIC_AWARE',
        'computeAlternativeRoutes': false,
        'languageCode': 'en',
        'units': 'METRIC',
      }),
    );
   

    if (response.statusCode != 200) {
      return [];
    }

    final Map<String, dynamic> data =
        jsonDecode(response.body);

    final List routes = data['routes'] ?? [];

    if (routes.isEmpty) {
      return [];
    }

    final String encodedPolyline =
        routes[0]['polyline']['encodedPolyline'];

    return _decodePolyline(encodedPolyline);
  }

  List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> points = [];

    int index = 0;
    int latitude = 0;
    int longitude = 0;

    while (index < encoded.length) {
      int shift = 0;
      int result = 0;

      while (true) {
        final int byte =
            encoded.codeUnitAt(index++) - 63;

        result |= (byte & 0x1f) << shift;
        shift += 5;

        if (byte < 0x20) {
          break;
        }
      }

      final int latitudeChange =
          (result & 1) != 0
              ? ~(result >> 1)
              : (result >> 1);

      latitude += latitudeChange;

      shift = 0;
      result = 0;

      while (true) {
        final int byte =
            encoded.codeUnitAt(index++) - 63;

        result |= (byte & 0x1f) << shift;
        shift += 5;

        if (byte < 0x20) {
          break;
        }
      }

      final int longitudeChange =
          (result & 1) != 0
              ? ~(result >> 1)
              : (result >> 1);

      longitude += longitudeChange;

      points.add(
        LatLng(
          latitude / 100000.0,
          longitude / 100000.0,
        ),
      );
    }

    return points;
  }
}