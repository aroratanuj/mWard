import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../../config/mock_config.dart';

class MockLocationService {
  // Simulate network delay
  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: MockConfig.mockApiDelay));
  }

  // Get current location
  Future<Position> getCurrentLocation({
    LocationAccuracy desiredAccuracy = LocationAccuracy.high,
    bool forceAndroidLocationManager = false,
  }) async {
    await _simulateDelay();

    // In mock mode, return Shimla coordinates
    debugPrint('Mock: Returning current location (Shimla)');

    return Position(
      latitude: MockConfig.mockLatitude,
      longitude: MockConfig.mockLongitude,
      timestamp: DateTime.now(),
      accuracy: MockConfig.defaultLocationAccuracy,
      altitude: 2200.0, // Shimla altitude
      altitudeAccuracy: 10.0,
      heading: 0.0,
      headingAccuracy: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
    );
  }

  // Get last known location
  Future<Position?> getLastKnownLocation() async {
    await _simulateDelay();

    return Position(
      latitude: MockConfig.mockLatitude,
      longitude: MockConfig.mockLongitude,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      accuracy: MockConfig.defaultLocationAccuracy,
      altitude: 2200.0,
      altitudeAccuracy: 10.0,
      heading: 0.0,
      headingAccuracy: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
    );
  }

  // Check location permission
  Future<LocationPermission> checkPermission() async {
    await _simulateDelay();

    // In mock mode, always return granted
    debugPrint('Mock: Location permission check: granted');
    return LocationPermission.always;
  }

  // Request location permission
  Future<LocationPermission> requestPermission() async {
    await _simulateDelay();

    // In mock mode, always grant permission
    debugPrint('Mock: Location permission requested: granted');
    return LocationPermission.always;
  }

  // Check if location service is enabled
  Future<bool> isLocationServiceEnabled() async {
    await _simulateDelay();

    // In mock mode, always return true
    debugPrint('Mock: Location service enabled: true');
    return true;
  }

  // Open location settings
  Future<bool> openLocationSettings() async {
    await _simulateDelay();

    debugPrint('Mock: Open location settings');
    return true;
  }

  // Open app settings
  Future<bool> openAppSettings() async {
    await _simulateDelay();

    debugPrint('Mock: Open app settings');
    return true;
  }

  // Get location accuracy
  Future<LocationAccuracy> getLocationAccuracy() async {
    await _simulateDelay();

    return LocationAccuracy.high;
  }

  // Get distance between two points
  double distanceBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    // Simple implementation - in real app, use Geolocator.distanceBetween
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  // Get bearing between two points
  double bearingBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    // Simple implementation - in real app, use Geolocator.bearingBetween
    return Geolocator.bearingBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  // Geocode location (coordinates to address)
  Future<String> geocodeLocation(double latitude, double longitude) async {
    await _simulateDelay();

    // In mock mode, return Shimla address
    debugPrint('Mock: Geocoding coordinates to address');
    return MockConfig.mockAddress;
  }

  // Reverse geocode (address to coordinates)
  Future<Position> reverseGeocode(String address) async {
    await _simulateDelay();

    // In mock mode, return Shimla coordinates
    debugPrint('Mock: Reverse geocoding address to coordinates');

    return Position(
      latitude: MockConfig.mockLatitude,
      longitude: MockConfig.mockLongitude,
      timestamp: DateTime.now(),
      accuracy: MockConfig.defaultLocationAccuracy,
      altitude: 2200.0,
      altitudeAccuracy: 10.0,
      heading: 0.0,
      headingAccuracy: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
    );
  }

  // Stream location updates
  Stream<Position> getLocationStream({
    LocationAccuracy? accuracy,
    int distanceFilter = 0,
    bool forceAndroidLocationManager = false,
    int interval = 1000,
  }) {
    // In mock mode, return a stream with periodic updates
    return Stream.periodic(
      const Duration(seconds: 5),
      (_) => Position(
        latitude: MockConfig.mockLatitude + (DateTime.now().millisecond % 100) / 10000,
        longitude: MockConfig.mockLongitude + (DateTime.now().millisecond % 100) / 10000,
        timestamp: DateTime.now(),
        accuracy: MockConfig.defaultLocationAccuracy,
        altitude: 2200.0,
        altitudeAccuracy: 10.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      ),
    );
  }
}
