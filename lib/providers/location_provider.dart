import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class Ambulance {
  final String id;
  final double latitude;
  final double longitude;
  final double distanceInKm;
  final String vehicleType;
  final String driverName;
  final double rating;
  final int estimatedTimeInMinutes;

  Ambulance({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.distanceInKm,
    required this.vehicleType,
    required this.driverName,
    required this.rating,
    required this.estimatedTimeInMinutes,
  });
}

class LocationProvider with ChangeNotifier {
  Position? _currentLocation;
  List<Ambulance> _nearbyAmbulances = [];
  final Random _random = Random();

  Position? get currentLocation => _currentLocation;
  List<Ambulance> get nearbyAmbulances => _nearbyAmbulances;

  Future<bool> getCurrentLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      // Check if location services are enabled
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled
        return false;
      }

      // Check location permissions
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied
          return false;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        // Permissions are permanently denied
        return false;
      }

      // Get current location
      _currentLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      ).timeout(const Duration(seconds: 10));
      
      _generateFixedAmbulances();
      notifyListeners();
      return true;
    } catch (e) {
      print('Error getting location: $e');
      return false;
    }
  }

  void useDefaultLocation() {
    // Default location (San Francisco)
    _currentLocation = Position(
      latitude: 37.7749, 
      longitude: -122.4194,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );
    _generateFixedAmbulances();
    notifyListeners();
  }

  void _generateFixedAmbulances() {
    if (_currentLocation == null) return;

    _nearbyAmbulances = [];
    
    // Fixed offsets for 5 ambulances around the user
    final offsets = [
      [0.005, 0.003],   // Northeast
      [-0.003, 0.004],  // Northwest
      [0.004, -0.005],  // Southeast
      [-0.005, -0.002], // Southwest
      [0.001, 0.007],   // North-northeast
    ];
    
    final ambulanceTypes = ['Basic Life Support', 'Advanced Life Support', 'Patient Transport'];
    final driverNames = ['John D.', 'Sarah M.', 'Michael K.', 'Emma R.', 'David L.'];
    
    for (int i = 0; i < 5; i++) {
      final ambulanceLat = _currentLocation!.latitude + offsets[i][0];
      final ambulanceLng = _currentLocation!.longitude + offsets[i][1];
      
      // Calculate approximate distance in km
      final distance = Geolocator.distanceBetween(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
        ambulanceLat,
        ambulanceLng,
      ) / 1000; // Convert meters to kilometers
      
      _nearbyAmbulances.add(
        Ambulance(
          id: 'AMB${100 + i}',
          latitude: ambulanceLat,
          longitude: ambulanceLng,
          distanceInKm: distance,
          vehicleType: ambulanceTypes[i % ambulanceTypes.length],
          driverName: driverNames[i % driverNames.length],
          rating: 3.5 + (i % 15) / 10, // Rating between 3.5 and 5.0
          estimatedTimeInMinutes: (distance * 3).round() + 2, // Rough estimate based on distance
        ),
      );
    }
    
    // Sort by distance
    _nearbyAmbulances.sort((a, b) => a.distanceInKm.compareTo(b.distanceInKm));
    
    notifyListeners();
  }
}

