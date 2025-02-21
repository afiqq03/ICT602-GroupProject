import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class HospitalsScreen extends StatefulWidget {
  final Position? currentPosition;
  
  const HospitalsScreen({
    super.key,
    required this.currentPosition,
  });

  @override
  State<HospitalsScreen> createState() => _HospitalsScreenState();
}

class _HospitalsScreenState extends State<HospitalsScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  List<Map<String, dynamic>> _sortedHospitals = [];
  bool _isLoading = true;

  // Hospital data
  final List<Map<String, dynamic>> hospitals = [
    {
      'name': 'Hospital Batu Gajah',
      'latitude': 4.47981,
      'longitude': 101.03471,
      'type': 'Hospital',
      'distance': 0.0,
    },
    {
      'name': 'Hospital Kampar',
      'latitude': 4.31276,
      'longitude': 101.16021,
      'type': 'Hospital',
      'distance': 0.0,
    },
    {
      'name': 'Hospital Pemaisuri Bainun Ipoh',
      'latitude': 4.60397,
      'longitude': 101.09096,
      'type': 'Hospital',
      'distance': 0.0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    _findNearestHospitals();
    _loadHospitalMarkers();
    setState(() => _isLoading = false);
  }

  void _findNearestHospitals() {
    if (widget.currentPosition == null) {
      _sortedHospitals = List.from(hospitals);
      return;
    }

    _sortedHospitals = List.from(hospitals);
    
    for (var hospital in _sortedHospitals) {
      double distance = Geolocator.distanceBetween(
        widget.currentPosition!.latitude,
        widget.currentPosition!.longitude,
        hospital['latitude'] as double,
        hospital['longitude'] as double,
      ) / 1000;
      hospital['distance'] = distance;
    }

    _sortedHospitals.sort((a, b) => 
      (a['distance'] as double).compareTo(b['distance'] as double)
    );
  }

  void _showHospitalInfo(Map<String, dynamic> hospital) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hospital['name'],
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Type: ${hospital['type']}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              'Distance: ${hospital['distance'].toStringAsFixed(1)} km',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showDirections(hospital);
                  },
                  icon: const Icon(Icons.directions),
                  label: const Text('Get Directions'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _loadHospitalMarkers() {
    setState(() {
      _markers.clear();
      
      // Add current location marker
      if (widget.currentPosition != null) {
        _markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: LatLng(
              widget.currentPosition!.latitude,
              widget.currentPosition!.longitude,
            ),
            infoWindow: const InfoWindow(title: 'Your Location'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          ),
        );
      }

      // Add markers for all hospitals with onTap handler
      for (final hospital in hospitals) {
        final marker = Marker(
          markerId: MarkerId(hospital['name']),
          position: LatLng(hospital['latitude'], hospital['longitude']),
          infoWindow: InfoWindow(
            title: hospital['name'],
            snippet: '${hospital['type']} - Click for more info',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            hospital['type'] == 'Hospital' 
                ? BitmapDescriptor.hueRed 
                : BitmapDescriptor.hueBlue,
          ),
          onTap: () {
            // Find the hospital with distance info
            final hospitalWithDistance = _sortedHospitals.firstWhere(
              (h) => h['name'] == hospital['name'],
              orElse: () => hospital,
            );
            _showHospitalInfo(hospitalWithDistance);
          },
        );
        _markers.add(marker);
      }
    });
  }

  Future<void> _showDirections(Map<String, dynamic> hospital) async {
    if (widget.currentPosition == null) return;

    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&origin=${widget.currentPosition!.latitude},${widget.currentPosition!.longitude}&destination=${hospital['latitude']},${hospital['longitude']}&travelmode=driving'
    );
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch maps')),
        );
      }
    }
  }

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
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: widget.currentPosition != null
                        ? LatLng(
                            widget.currentPosition!.latitude,
                            widget.currentPosition!.longitude,
                          )
                        : const LatLng(4.5975, 101.0901), // Default to Ipoh
                    zoom: 12,
                  ),
                  markers: _markers,
                  onMapCreated: (controller) {
                    _mapController = controller;
                    _loadHospitalMarkers();
                  },
                ),
                // Add My Location Button
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
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Nearby Hospitals',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (_sortedHospitals.isEmpty)
                    const Center(
                      child: Text('No hospitals found nearby'),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: _sortedHospitals.length,
                        itemBuilder: (context, index) {
                          final hospital = _sortedHospitals[index];
                          return ListTile(
                            title: Text(hospital['name']),
                            subtitle: Text(
                              '${hospital['type']} • ${hospital['distance'].toStringAsFixed(1)} km away'
                            ),
                            leading: Icon(
                              Icons.local_hospital,
                              color: hospital['type'] == 'Hospital' 
                                  ? Colors.red 
                                  : Colors.blue,
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.directions),
                              onPressed: () => _showDirections(hospital),
                            ),
                            onTap: () {
                              _mapController?.animateCamera(
                                CameraUpdate.newLatLng(
                                  LatLng(hospital['latitude'], hospital['longitude']),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}