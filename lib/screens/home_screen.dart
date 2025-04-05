import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import './../providers/location_provider.dart';
import './../widgets/ambulance_info_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  bool _isLoading = true;
  Set<Marker> _markers = {};
  Ambulance? _selectedAmbulance;

  @override
  void initState() {
    super.initState();
    _initializeLocationAndMarkers();
  }

  Future<void> _initializeLocationAndMarkers() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      final success = await locationProvider.getCurrentLocation();
      
      if (!success && mounted) {
        // If we couldn't get location, show an error and use default location
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not access location. Using default location.'),
            backgroundColor: Colors.orange,
          ),
        );
        locationProvider.useDefaultLocation();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _updateMarkers();
        });
        _animateToCurrentLocation();
      }
    }
  }

  void _updateMarkers() {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    final currentLocation = locationProvider.currentLocation;
    final ambulances = locationProvider.nearbyAmbulances;
    
    if (currentLocation == null) return;
    
    final Set<Marker> markers = {};
    
    // Add user marker
    markers.add(
      Marker(
        markerId: const MarkerId('user_location'),
        position: LatLng(currentLocation.latitude, currentLocation.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Your Location'),
      ),
    );
    
    // Add ambulance markers
    for (var ambulance in ambulances) {
      markers.add(
        Marker(
          markerId: MarkerId('ambulance_${ambulance.id}'),
          position: LatLng(ambulance.latitude, ambulance.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: 'Ambulance ${ambulance.id}',
            snippet: '${ambulance.distanceInKm.toStringAsFixed(1)} km away',
          ),
          onTap: () {
            setState(() {
              _selectedAmbulance = ambulance;
            });
          },
        ),
      );
    }
    
    setState(() {
      _markers = markers;
    });
  }

  Future<void> _animateToCurrentLocation() async {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    final currentLocation = locationProvider.currentLocation;
    
    if (currentLocation == null || !_controller.isCompleted) return;
    
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(currentLocation.latitude, currentLocation.longitude),
          zoom: 15,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    final currentLocation = locationProvider.currentLocation;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ambuclear',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _initializeLocationAndMarkers,
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading map...'),
                ],
              ),
            )
          : Stack(
              children: [
                GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                    target: currentLocation != null 
                      ? LatLng(currentLocation.latitude, currentLocation.longitude)
                      : const LatLng(37.42796133580664, -122.085749655962), // Default to Google HQ
                    zoom: 15,
                  ),
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                ),
                if (_selectedAmbulance != null)
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: AmbulanceInfoCard(
                      ambulance: _selectedAmbulance!,
                      onClose: () {
                        setState(() {
                          _selectedAmbulance = null;
                        });
                      },
                      onRequest: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Ambulance requested successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        setState(() {
                          _selectedAmbulance = null;
                        });
                      },
                    ),
                  ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        onPressed: _animateToCurrentLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}

