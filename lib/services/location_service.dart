import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();

  factory LocationService() {
    return _instance;
  }

  LocationService._internal();

  /// Request location permissions
  Future<bool> requestLocationPermissions() async {
    try {
      final permission = await Geolocator.requestPermission();
      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (e) {
      return false;
    }
  }

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Get current location
  Future<LatLng?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      final isEnabled = await isLocationServiceEnabled();
      if (!isEnabled) {
        throw Exception('Location services are disabled');
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get position with fallback to last known position
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 12),
        );
      } catch (_) {
        position = await Geolocator.getLastKnownPosition();
      }

      if (position != null) {
        return LatLng(position.latitude, position.longitude);
      }
      throw Exception('Could not fetch GPS location. Please ensure GPS is turned on.');
    } catch (e) {
      rethrow;
    }
  }

  /// Get formatted address from LatLng
  Future<String?> getAddressFromLatLng(LatLng location) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final parts = <String>[];

        void addPart(String? text) {
          if (text != null && text.trim().isNotEmpty) {
            final trimmed = text.trim();
            if (!parts.any((p) => p.toLowerCase() == trimmed.toLowerCase())) {
              parts.add(trimmed);
            }
          }
        }

        // Add street or name
        if (place.street != null && place.street!.trim().isNotEmpty) {
          addPart(place.street);
        } else if (place.name != null && place.name!.trim().isNotEmpty) {
          addPart(place.name);
        }

        addPart(place.subLocality);
        addPart(place.locality);
        addPart(place.subAdministrativeArea);
        addPart(place.administrativeArea);
        addPart(place.country);

        if (parts.isNotEmpty) {
          return parts.join(', ');
        }
      }
      return '${location.latitude.toStringAsFixed(5)}, ${location.longitude.toStringAsFixed(5)}';
    } catch (e) {
      // Fallback to formatted coordinates string if offline or reverse geocode fails
      return '${location.latitude.toStringAsFixed(5)}, ${location.longitude.toStringAsFixed(5)}';
    }
  }

  /// Get LatLng from address
  Future<LatLng?> getLatLngFromAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final location = locations[0];
        return LatLng(location.latitude, location.longitude);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Format address for display
  String formatAddress(LatLng location) {
    return '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}';
  }
}
