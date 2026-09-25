import 'package:flutter/material.dart';

import '../models/place_model.dart';

class SuggestionsList extends StatelessWidget {
  final List<PlaceModel> suggestions;
  final Function(PlaceModel) onSelected;

  const SuggestionsList({
    super.key,
    required this.suggestions,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) {
      return const SizedBox();
    }

    return Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(20),
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final PlaceModel place =
              suggestions[index];

          return ListTile(
            leading: const Icon(
              Icons.location_on,
            ),
            title: Text(
              place.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              onSelected(place);
            },
          );
        },
      ),
    );
  }
}