import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapWidget extends StatefulWidget {
  final LatLng currentLocation;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final Function(GoogleMapController) onMapCreated;

  const MapWidget({
    super.key,
    required this.currentLocation,
    required this.markers,
    required this.polylines,
    required this.onMapCreated,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  @override
  Widget build(BuildContext context) {
   

    return GoogleMap(
      key: ValueKey(
        'map_${widget.polylines.length}',
      ),
      initialCameraPosition: CameraPosition(
        target: widget.currentLocation,
        zoom: 14,
      ),
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      markers: widget.markers,
      polylines: widget.polylines,
      onMapCreated: widget.onMapCreated,
    );
  }
}