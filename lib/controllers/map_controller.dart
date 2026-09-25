import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/place_model.dart';
import '../services/location_services.dart';
import '../services/route_services.dart';
import '../services/search_services.dart';
import '../services/storage_services.dart';

class MapController extends ChangeNotifier {
  static const LatLng defaultLocation = LatLng(
    30.0444,
    31.2357,
  );

  final LocationService locationService =
      LocationService();

  final SearchService searchService =
      SearchService();

  final RouteService routeService =
      RouteService();

  final StorageService storageService =
      StorageService();

  GoogleMapController? controller;

  LatLng currentLocation = defaultLocation;

  Set<Marker> markers = {};

  Set<Polyline> polylines = {};

  List<PlaceModel> suggestions = [];

  bool isSearching = false;

  bool isGettingLocation = false;

  void setController(
    GoogleMapController controller,
  ) {
    this.controller = controller;
  }

  Future<void> initialize() async {
    await storageService.init();
    await getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    if (isGettingLocation) {
      return;
    }

    isGettingLocation = true;
    notifyListeners();

    try {
      final Position? position =
          await locationService.getCurrentLocation();

      if (position == null) {
        return;
      }

      currentLocation = LatLng(
        position.latitude,
        position.longitude,
      );

      notifyListeners();

      await moveCamera(
        currentLocation,
        zoom: 15,
      );
    } finally {
      isGettingLocation = false;
      notifyListeners();
    }
  }

  Future<void> searchPlaces(
    String input,
  ) async {
    if (input.trim().isEmpty) {
      suggestions = [];
      notifyListeners();
      return;
    }

    isSearching = true;
    notifyListeners();

    try {
      suggestions =
          await searchService.getSuggestions(
        input,
      );
    } finally {
      isSearching = false;
      notifyListeners();
    }
  }

  Future<PlaceModel?> selectPlace(
    PlaceModel suggestion,
  ) async {
    if (suggestion.placeId == null) {
      return null;
    }

    isSearching = true;
    suggestions = [];
    notifyListeners();

    try {
      final PlaceModel? place =
          await searchService.getPlaceDetails(
        suggestion.placeId!,
      );

      if (place == null) {
        return null;
      }

      await showPlace(
        place,
        saveToHistory: true,
      );

      return place;
    } finally {
      isSearching = false;
      notifyListeners();
    }
  }

  Future<void> selectHistoryPlace(
    PlaceModel place,
  ) async {
    await showPlace(
      place,
      saveToHistory: false,
    );
  }

  Future<void> showPlace(
    PlaceModel place, {
    required bool saveToHistory,
  }) async {
    final LatLng location = LatLng(
      place.latitude,
      place.longitude,
    );

    addMarker(
      location: location,
      name: place.name,
    );

    final List<LatLng> route =
        await routeService.getRoute(
      origin: currentLocation,
      destination: location,
    );

    if (route.isNotEmpty) {
     

      polylines = {
        Polyline(
          polylineId: const PolylineId('route'),
          points: route,
          width: 8,
          color: Colors.blue,
        ),
      };

    
    } else {
      polylines = {};
    }

    await moveCamera(
      location,
      zoom: 15,
    );

    if (saveToHistory) {
      await storageService.savePlace(
        place,
      );
    }

    notifyListeners();
  }

  void addMarker({
    required LatLng location,
    required String name,
  }) {
    markers = {
      Marker(
        markerId:
            const MarkerId('searched_place'),
        position: location,
        infoWindow: InfoWindow(
          title: name,
        ),
      ),
    };

    notifyListeners();
  }

  Future<void> moveCamera(
    LatLng location, {
    double zoom = 15,
  }) async {
    if (controller == null) {
      return;
    }

    await controller!.animateCamera(
      CameraUpdate.newLatLngZoom(
        location,
        zoom,
      ),
    );
  }

  void clearSuggestions() {
    suggestions = [];
    notifyListeners();
  }

  @override
  void dispose() {
    controller = null;
    super.dispose();
  }
}