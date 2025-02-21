import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  final Position? currentPosition;
  
  const MapScreen({
    super.key,
    required this.currentPosition,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;

  void _centerOnCurrentLocation() {
    if (widget.currentPosition != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(
            widget.currentPosition!.latitude,
            widget.currentPosition!.longitude,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentPosition == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(
              widget.currentPosition!.latitude,
              widget.currentPosition!.longitude,
            ),
            zoom: 15,
          ),
          onMapCreated: (controller) => _mapController = controller,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          markers: {
            Marker(
              markerId: const MarkerId('current_location'),
              position: LatLng(
                widget.currentPosition!.latitude,
                widget.currentPosition!.longitude,
              ),
              infoWindow: const InfoWindow(title: 'Your Location'),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            ),
          },
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: _centerOnCurrentLocation,
            backgroundColor: Colors.white,
            child: const Icon(Icons.my_location, color: Colors.blue),
          ),
        ),
      ],
    );
  }
}