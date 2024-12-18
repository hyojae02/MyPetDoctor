import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PetMapScreen extends StatefulWidget {
  const PetMapScreen({Key? key}) : super(key: key);

  @override
  _PetMapScreenState createState() => _PetMapScreenState();
}

class _PetMapScreenState extends State<PetMapScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Position? _currentPosition;
  Map<String, dynamic>? _selectedClinic;

  final String _googleApiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enable location services')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')),
        );
        return;
      }
    }

    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          14.0,
        ),
      );

      _fetchNearbyPetClinics();
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  Future<void> _fetchNearbyPetClinics() async {
    if (_currentPosition == null) return;

    final url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${_currentPosition!.latitude},${_currentPosition!.longitude}&radius=3000&type=veterinary_care&language=ko&key=$_googleApiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null) {
          final results = data['results'] as List;

          setState(() {
            _markers.clear();
          });

          for (var place in results) {
            final geometry = place['geometry']['location'];
            final lat = geometry['lat'];
            final lng = geometry['lng'];
            final name = place['name'];
            final address = place['vicinity'];

            if (name.contains('동물병원') || name.contains('동물의료센터')) {
              setState(() {
                _markers.add(
                  Marker(
                    markerId: MarkerId(place['place_id']),
                    position: LatLng(lat, lng),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueYellow, // 파란색 마커
                    ),
                    onTap: () {
                      setState(() {
                        _selectedClinic = {
                          'name': name,
                          'address': address,
                          'lat': lat,
                          'lng': lng,
                        };
                      });
                      _showClinicInfo();
                    },
                  ),
                );
              });
            }
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Found ${_markers.length} Pet Hospitals'),
              backgroundColor: Colors.grey[700],
            ),
          );
        }
      }
    } catch (e) {
      print("API call error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to fetch Pet Hospitals'),
          backgroundColor: Colors.grey[700],
        ),
      );
    }
  }

  void _showClinicInfo() {
    if (_selectedClinic == null) return;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  _selectedClinic!['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Address: ${_selectedClinic!['address']}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _launchGoogleMaps(
                  _selectedClinic!['lat'],
                  _selectedClinic!['lng'],
                ),
                icon: const Icon(Icons.directions),
                label: const Text('Get Directions'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  side: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _launchGoogleMaps(double lat, double lng) async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch directions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Hospital'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          zoom: 14.0,
        ),
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
          _getCurrentLocation();
        },
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        child: const Icon(Icons.my_location),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
    );
  }
}