import 'package:flutter/material.dart';

import '../models/place_model.dart';
import '../services/storage_services.dart';

class HistoryScreen extends StatefulWidget {
  final Future<void> Function(PlaceModel) onPlaceSelected;

  const HistoryScreen({
    super.key,
    required this.onPlaceSelected,
  });

  @override
  State<HistoryScreen> createState() =>
      _HistoryScreenState();
}

class _HistoryScreenState
    extends State<HistoryScreen> {
  final StorageService storageService =
      StorageService();

  List<PlaceModel> places = [];

  @override
  void initState() {
    super.initState();

    loadPlaces();
  }

  void loadPlaces() {
    places = storageService.getPlaces();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> deletePlace(int index) async {
    await storageService.deletePlace(index);

    loadPlaces();
  }

  Future<void> deleteAll() async {
    await storageService.clearPlaces();

    loadPlaces();
  }

  Future<void> selectPlace(
    PlaceModel place,
  ) async {
    await widget.onPlaceSelected(place);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Search History',
        ),
        actions: [
          if (places.isNotEmpty)
            IconButton(
              onPressed: deleteAll,
              icon: const Icon(
                Icons.delete_sweep,
              ),
            ),
        ],
      ),
      body: places.isEmpty
          ? const Center(
              child: Text(
                'No search history',
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: places.length,
              separatorBuilder: (
                context,
                index,
              ) =>
                  const SizedBox(height: 8),
              itemBuilder: (
                context,
                index,
              ) {
                final PlaceModel place =
                    places[index];

                return Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.location_on,
                    ),
                    title: Text(
                      place.name,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${place.latitude.toStringAsFixed(5)}, '
                      '${place.longitude.toStringAsFixed(5)}',
                    ),
                    trailing: IconButton(
                      onPressed: () {
                        deletePlace(index);
                      },
                      icon: const Icon(
                        Icons.delete,
                      ),
                    ),
                    onTap: () {
                      selectPlace(place);
                    },
                  ),
                );
              },
            ),
    );
  }
}