import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/location_service.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  final String deliveryAddress;

  const OrderTrackingScreen({
    Key? key,
    required this.orderId,
    required this.deliveryAddress,
  }) : super(key: key);

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  late GoogleMapController _mapController;
  final LocationService _locationService = LocationService();
  
  LatLng? _currentLocation;
  LatLng? _deliveryLocation;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  
  bool _isLoading = true;
  String? _errorMessage;
  String _orderStatus = 'Processing'; // Processing, Packed, Out for Delivery, Delivered

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      // Get current location
      final currentLoc = await _locationService.getCurrentLocation();
      if (currentLoc != null) {
        setState(() => _currentLocation = currentLoc);
      }

      // Get delivery location from address
      final deliveryLoc =
          await _locationService.getLatLngFromAddress(widget.deliveryAddress);
      if (deliveryLoc != null) {
        setState(() => _deliveryLocation = deliveryLoc);
      } else {
        // Default to current location if address can't be resolved
        setState(() => _deliveryLocation = currentLoc);
      }

      // Update markers
      _updateMarkers();

      setState(() => _isLoading = false);

      // Simulate order status updates
      _simulateDeliveryUpdates();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _updateMarkers() {
    final markers = <Marker>{};

    if (_currentLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current'),
          position: _currentLocation!,
          infoWindow: const InfoWindow(title: 'Current Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue),
        ),
      );
    }

    if (_deliveryLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('delivery'),
          position: _deliveryLocation!,
          infoWindow: const InfoWindow(title: 'Delivery Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen),
        ),
      );
    }

    setState(() => _markers = markers);

    // Add polyline between markers
    if (_currentLocation != null && _deliveryLocation != null) {
      setState(() {
        _polylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            points: [_currentLocation!, _deliveryLocation!],
            color: Colors.blue,
            width: 5,
          ),
        };
      });
    }
  }

  void _simulateDeliveryUpdates() {
    // Simulate status updates
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _orderStatus = 'Packed');
      }
    });

    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        setState(() => _orderStatus = 'Out for Delivery');
      }
    });

    Future.delayed(const Duration(seconds: 9), () {
      if (mounted) {
        setState(() => _orderStatus = 'Delivered');
      }
    });
  }

  void _moveToCurrentLocation() async {
    if (_currentLocation != null && _mapController != null) {
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation!, 15),
      );
    }
  }

  void _moveToDeliveryLocation() async {
    if (_deliveryLocation != null && _mapController != null) {
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(_deliveryLocation!, 15),
      );
    }
  }

  void _showBothLocations() async {
    if (_currentLocation != null && _deliveryLocation != null) {
      final bounds = LatLngBounds(
        southwest: LatLng(
          _currentLocation!.latitude < _deliveryLocation!.latitude
              ? _currentLocation!.latitude
              : _deliveryLocation!.latitude,
          _currentLocation!.longitude < _deliveryLocation!.longitude
              ? _currentLocation!.longitude
              : _deliveryLocation!.longitude,
        ),
        northeast: LatLng(
          _currentLocation!.latitude > _deliveryLocation!.latitude
              ? _currentLocation!.latitude
              : _deliveryLocation!.latitude,
          _currentLocation!.longitude > _deliveryLocation!.longitude
              ? _currentLocation!.longitude
              : _deliveryLocation!.longitude,
        ),
      );

      _mapController.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 100),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Order Tracking'),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor().withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _getStatusColor()),
                ),
                child: Text(
                  _orderStatus,
                  style: TextStyle(
                    color: _getStatusColor(),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation(Colors.green.shade600),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading map...',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        'Error: $_errorMessage',
                        style: TextStyle(color: Colors.red.shade600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            )
          : Column(
              children: [
                // Google Map
                Expanded(
                  flex: 3,
                  child: GoogleMap(
                    onMapCreated: (controller) {
                      _mapController = controller;
                      if (_currentLocation != null) {
                        _mapController.animateCamera(
                          CameraUpdate.newLatLngZoom(
                              _currentLocation!, 14),
                        );
                      }
                    },
                    initialCameraPosition: CameraPosition(
                      target: _currentLocation ??
                          const LatLng(37.7749, -122.4194),
                      zoom: 14,
                    ),
                    markers: _markers,
                    polylines: _polylines,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                  ),
                ),

                // Map Controls
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.location_on),
                          onPressed: _moveToCurrentLocation,
                          tooltip: 'Current Location',
                        ),
                        const Divider(height: 1),
                        IconButton(
                          icon: const Icon(Icons.location_searching),
                          onPressed: _moveToDeliveryLocation,
                          tooltip: 'Delivery Location',
                        ),
                        const Divider(height: 1),
                        IconButton(
                          icon: const Icon(Icons.fit_screen),
                          onPressed: _showBothLocations,
                          tooltip: 'Show Both',
                        ),
                      ],
                    ),
                  ),
                ),

                // Order Details
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Order ID
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Order ID',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                              ),
                              Text(
                                widget.orderId,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Status Timeline
                          _buildStatusTimeline(context),
                          const SizedBox(height: 20),

                          // Delivery Address
                          Text(
                            'Delivery Address',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.green.shade300),
                            ),
                            child: Text(
                              widget.deliveryAddress,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.green.shade700,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Contact Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Contacting delivery partner...'),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.call),
                              label: const Text('Contact Delivery Partner'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.green.shade600,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12),
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

  Widget _buildStatusTimeline(BuildContext context) {
    final statuses = [
      'Processing',
      'Packed',
      'Out for Delivery',
      'Delivered'
    ];
    final currentIndex = statuses.indexOf(_orderStatus);

    return Column(
      children: List.generate(statuses.length, (index) {
        final isCompleted = index <= currentIndex;
        final isCurrentStatus = index == currentIndex;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.green.shade600 : Colors.grey,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: isCompleted
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 18,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statuses[index],
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            fontWeight: isCurrentStatus
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isCompleted
                                ? Colors.black
                                : Colors.grey,
                          ),
                    ),
                    if (isCurrentStatus)
                      Text(
                        'In progress',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              color: Colors.green.shade600,
                            ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Color _getStatusColor() {
    switch (_orderStatus) {
      case 'Processing':
        return Colors.orange;
      case 'Packed':
        return Colors.blue;
      case 'Out for Delivery':
        return Colors.purple;
      case 'Delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
