import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LatLng currentLocation = const LatLng(
    30.0444,
    31.2357,
  );

  GoogleMapController? mapController;

  Set<Marker> markers = {};

  final TextEditingController searchController =
      TextEditingController();

  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    Position position =
        await Geolocator.getCurrentPosition();

    setState(() {
      currentLocation = LatLng(
        position.latitude,
        position.longitude,
      );
    });

    if (mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newLatLng(
          currentLocation,
        ),
      );
    }
  }

  Future<void> searchPlace() async {
    final String place =
        searchController.text.trim();

    if (place.isEmpty) {
      return;
    }

    setState(() {
      isSearching = true;
    });

    final Uri url = Uri.parse(
      'https://nominatim.openstreetmap.org/search'
      '?q=${Uri.encodeComponent(place)}'
      '&format=json'
      '&limit=1',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'maps_app/1.0',
        },
      );

    

      if (response.statusCode != 200) {
        showMessage('erroe');
        return;
      }

      final List data = jsonDecode(response.body);

      if (data.isEmpty) {
        showMessage('erroe');
        return;
      }

      final double lat =
          double.parse(data[0]['lat']);

      final double lon =
          double.parse(data[0]['lon']);

      final LatLng searchedLocation =
          LatLng(lat, lon);

      setState(() {
        markers = {
          Marker(
            markerId:
                 MarkerId('searched_place'),
            position: searchedLocation,
            icon: BitmapDescriptor
                .defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
          ),
        };
      });

      if (mapController != null) {
        await mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            searchedLocation,
            15,
          ),
        );
      }
    } catch (e) {
   
      showMessage('erroe: $e');
    } finally {
      if (mounted) {
        setState(() {
          isSearching = false;
        });
      }
    }
  }

  void showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: currentLocation,
              zoom: 14,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: markers,
            onMapCreated: (controller) {
              mapController = controller;
            },
          ),

          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: TextField(
              controller: searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (value) {
                searchPlace();
              },
              decoration: InputDecoration(
                hintText: 'Search for a place',
                prefixIcon:  Icon(
                  Icons.search,
                ),
                suffixIcon: isSearching
                    ?  Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}