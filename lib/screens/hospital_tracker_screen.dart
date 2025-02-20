import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HospitalTrackerScreen extends StatefulWidget {
  const HospitalTrackerScreen({super.key});

  @override
  State<HospitalTrackerScreen> createState() => _HospitalTrackerScreenState();
}

class _HospitalTrackerScreenState extends State<HospitalTrackerScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  List<Map<String, dynamic>> _hospitals = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
    });

    _searchNearbyHospitals();
  }

  Future<void> _searchNearbyHospitals() async {
    if (_currentPosition == null) return;

    final response = await http.get(Uri.parse(
        'https://nominatim.openstreetmap.org/search.php?q=hospital&format=jsonv2' +
            '&lat=${_currentPosition!.latitude}&lon=${_currentPosition!.longitude}&radius=5000'));

    if (response.statusCode == 200) {
      final List<dynamic> results = json.decode(response.body);
      setState(() {
        _hospitals = results.map((e) => e as Map<String, dynamic>).toList();
        _markers = _hospitals.map((hospital) {
          return Marker(
            markerId: MarkerId(hospital['place_id'].toString()),
            position: LatLng(
              double.parse(hospital['lat']),
              double.parse(hospital['lon']),
            ),
            infoWindow: InfoWindow(
              title: hospital['display_name'],
            ),
          );
        }).toSet();

        // Add current location marker
        _markers.add(Marker(
          markerId: const MarkerId('current_location'),
          position:
              LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          infoWindow: const InfoWindow(title: 'Your Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPosition == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hospital Tracker'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                ),
                zoom: 14,
              ),
              markers: _markers,
              onMapCreated: (controller) => _mapController = controller,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          ),
          Container(
            height: 200,
            child: ListView.builder(
              itemCount: _hospitals.length,
              itemBuilder: (context, index) {
                final hospital = _hospitals[index];
                return ListTile(
                  title: Text(hospital['display_name']),
                  onTap: () {
                    _mapController?.animateCamera(
                      CameraUpdate.newLatLng(
                        LatLng(
                          double.parse(hospital['lat']),
                          double.parse(hospital['lon']),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
