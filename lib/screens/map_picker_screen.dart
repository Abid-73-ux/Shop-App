import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/location_service.dart';

class MapPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;
  final String? initialAddress;

  const MapPickerScreen({
    Key? key,
    this.initialLocation,
    this.initialAddress,
  }) : super(key: key);

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  final LocationService _locationService = LocationService();
  GoogleMapController? _mapController;

  // Default fallback (e.g. Islamabad, Pakistan) if GPS is not yet acquired
  static const LatLng _defaultLocation = LatLng(33.6844, 73.0479);

  LatLng _currentPinLocation = _defaultLocation;
  String _currentAddress = 'Detecting address...';
  bool _isGeocoding = false;
  bool _isLocatingUser = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _currentPinLocation = widget.initialLocation!;
      if (widget.initialAddress != null && widget.initialAddress!.isNotEmpty) {
        _currentAddress = widget.initialAddress!;
      } else {
        _reverseGeocode(_currentPinLocation);
      }
    } else {
      _fetchInitialLocation();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _fetchInitialLocation() async {
    setState(() => _isLocatingUser = true);
    try {
      final loc = await _locationService.getCurrentLocation();
      if (loc != null && mounted) {
        _currentPinLocation = loc;
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(loc, 16.5),
        );
        _reverseGeocode(loc);
      }
    } catch (_) {
      // If GPS fails, resolve default location
      if (mounted) {
        _reverseGeocode(_currentPinLocation);
      }
    } finally {
      if (mounted) {
        setState(() => _isLocatingUser = false);
      }
    }
  }

  void _onCameraMove(CameraPosition position) {
    _currentPinLocation = position.target;
  }

  void _onCameraIdle() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      _reverseGeocode(_currentPinLocation);
    });
  }

  Future<void> _reverseGeocode(LatLng location) async {
    if (!mounted) return;
    setState(() => _isGeocoding = true);

    try {
      final address = await _locationService.getAddressFromLatLng(location);
      if (mounted) {
        setState(() {
          _currentAddress = address ??
              '${location.latitude.toStringAsFixed(5)}, ${location.longitude.toStringAsFixed(5)}';
          _isGeocoding = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentAddress =
              '${location.latitude.toStringAsFixed(5)}, ${location.longitude.toStringAsFixed(5)}';
          _isGeocoding = false;
        });
      }
    }
  }

  Future<void> _goToCurrentLocation() async {
    setState(() => _isLocatingUser = true);
    try {
      final loc = await _locationService.getCurrentLocation();
      if (loc != null && mounted) {
        _currentPinLocation = loc;
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(loc, 17.0),
        );
        _reverseGeocode(loc);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Location error: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLocatingUser = false);
      }
    }
  }

  void _confirmSelection() {
    Navigator.of(context).pop({
      'address': _currentAddress,
      'location': _currentPinLocation,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Delivery Location',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPinLocation,
              zoom: 16.0,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              if (widget.initialLocation != null) {
                _mapController?.animateCamera(
                  CameraUpdate.newLatLngZoom(widget.initialLocation!, 16.5),
                );
              }
            },
            onCameraMove: _onCameraMove,
            onCameraIdle: _onCameraIdle,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: true,
            mapToolbarEnabled: false,
          ),

          // Center Pin Marker (Fixed on map center)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Delivery here',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Icon(
                    Icons.location_on,
                    size: 46,
                    color: Colors.redAccent,
                  ),
                ],
              ),
            ),
          ),

          // Top helper badge
          Positioned(
            top: 16,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: Colors.green.shade700),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Drag map to align pin at your doorstep',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Floating Action Button to Locate Me
          Positioned(
            right: 16,
            bottom: 230,
            child: FloatingActionButton(
              heroTag: 'map_locate_me',
              mini: true,
              backgroundColor: Colors.white,
              foregroundColor: Colors.green.shade700,
              elevation: 4,
              onPressed: _isLocatingUser ? null : _goToCurrentLocation,
              child: _isLocatingUser
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.green.shade700,
                      ),
                    )
                  : const Icon(Icons.my_location),
            ),
          ),

          // Bottom Address Card & Confirmation
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.location_on,
                            color: Colors.green.shade700,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Delivery Address',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              if (_isGeocoding)
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Fetching address details...',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                )
                              else
                                Text(
                                  _currentAddress,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _isGeocoding ? null : _confirmSelection,
                        child: const Text(
                          'Confirm Delivery Address',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
