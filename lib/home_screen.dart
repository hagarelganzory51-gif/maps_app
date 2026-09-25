import 'package:flutter/material.dart';
import 'package:maps_app/models/place_model.dart';

import 'controllers/map_controller.dart';
import 'screens/history_screen.dart';
import 'widgets/location_button.dart';
import 'widgets/map_widget.dart';
import 'widgets/search_bar.dart';
import 'widgets/suggestions_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MapController mapController =
      MapController();

  final TextEditingController searchController =
      TextEditingController();

  bool isSelectingPlace = false;

  @override
  void initState() {
    super.initState();

    mapController.initialize();

    searchController.addListener(
      onSearchChanged,
    );

    mapController.addListener(
      refreshScreen,
    );
  }

  void refreshScreen() {
    if (mounted) {
      setState(() {});
    }
  }

  void onSearchChanged() {
    if (isSelectingPlace) {
      return;
    }

    mapController.searchPlaces(
      searchController.text,
    );
  }

    Future<void> selectPlace(
    PlaceModel place,
    ) async {
    isSelectingPlace = true;

    final result =
        await mapController.selectPlace(
      place,
    );

    if (result != null) {
      searchController.text = result.name;
    }

    mapController.clearSuggestions();

    isSelectingPlace = false;
  }

  void openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return HistoryScreen(
            onPlaceSelected: (place) async {
              isSelectingPlace = true;

              await mapController
                  .selectHistoryPlace(place);

              searchController.text =
                  place.name;

              mapController.clearSuggestions();

              isSelectingPlace = false;
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    searchController.removeListener(
      onSearchChanged,
    );

    searchController.dispose();

    mapController.removeListener(
      refreshScreen,
    );

    mapController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'history_button',
            onPressed: openHistory,
            child: const Icon(
              Icons.history,
            ),
          ),

          const SizedBox(height: 12),

          LocationButton(
            isLoading:
                mapController.isGettingLocation,
            onPressed:
                mapController.getCurrentLocation,
          ),
        ],
      ),

      body: Stack(
        children: [
          MapWidget(
            currentLocation:
                mapController.currentLocation,
            markers:
                mapController.markers,
            polylines:
                mapController.polylines,
            onMapCreated:
                mapController.setController,
          ),

          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Column(
              children: [
                SearchBarWidget(
                  controller:
                      searchController,
                  isSearching:
                      mapController.isSearching,
                  onSearch: () {
                    mapController.searchPlaces(
                      searchController.text,
                    );
                  },
                ),

                if (mapController
                    .suggestions
                    .isNotEmpty)
                  const SizedBox(
                    height: 8,
                  ),

                if (mapController
                    .suggestions
                    .isNotEmpty)
                  SuggestionsList(
                    suggestions:
                        mapController.suggestions,
                    onSelected:
                        selectPlace,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}