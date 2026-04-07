import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as latlong;
import '../../services/location_service.dart';
import '../../services/routing_service.dart';
import '../../utils/campus_constants.dart';

class GPSPage extends StatefulWidget {
  const GPSPage({Key? key}) : super(key: key);

  @override
  State<GPSPage> createState() => _GPSPageState();
}

class _GPSPageState extends State<GPSPage> {
  final Completer<GoogleMapController> _controller = Completer();
  final LocationService _locationService = LocationService();
  
  // State
  latlong.LatLng? _currentLocation;
  latlong.LatLng? _destination;
  String? _destinationName;
  bool _isRouting = false;
  bool _isLoading = false;
  bool _isFullScreen = false;
  String _routeInfo = '';
  
  // Map Assets
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  Set<Circle> _mapCircles = {}; // Renamed from _circles
  StreamSubscription<latlong.LatLng>? _locationSubscription;

  // Constants
  static final CameraPosition _kCampusCenter = CameraPosition(
    target: LatLng(
      CampusConstants.campusCenter.latitude,
      CampusConstants.campusCenter.longitude,
    ),
    zoom: 16.5,
  );

  @override
  void initState() {
    super.initState();
    _initLocationService();
    _updateMarkers(); // Show building markers immediately
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  // --- Location & Map Logic ---

  Future<void> _initLocationService() async {
    // Don't show loading overlay for background location updates
    // just update the marker when available
    
    final hasPermission = await _locationService.requestPermission();
    if (!hasPermission) {
      _showSnackBar('Location permission denied. Map centered on Campus.');
      return;
    }

    final location = await _locationService.getCurrentLocation();
    if (location != null && mounted) {
      _updateUserLocation(location);
      // Optional: Auto-center on user if they are near campus?
      // For now, let's keep the map stable at campus center unless user asks.
    }

    _locationSubscription = _locationService.getLocationStream().listen((location) {
      if (mounted) _updateUserLocation(location);
    });
  }

  void _updateUserLocation(latlong.LatLng location) {
    setState(() {
      _currentLocation = location;
      _updateMarkers();
    });
  }

  void _updateMarkers() {
    Set<Marker> newMarkers = {};

    // 1. Campus Buildings
    CampusConstants.buildings.forEach((name, location) {
      newMarkers.add(
        Marker(
          markerId: MarkerId(name),
          position: LatLng(location.latitude, location.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
          onTap: () => _showBuildingDetails(name, location),
        ),
      );
    });

    // 2. User Location
    if (_currentLocation != null) {
      // Add a Blue Circle for better visibility
      _mapCircles = {
        Circle(
          circleId: const CircleId('user_accuracy'),
          center: LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
          radius: 20, // 20 meters radius
          fillColor: Colors.blue.withOpacity(0.2),
          strokeColor: Colors.blue,
          strokeWidth: 2,
        ),
      };

      newMarkers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
          // Try explicit hue value for Blue (240.0)
          icon: BitmapDescriptor.defaultMarkerWithHue(240.0),
          zIndex: 10,
          infoWindow: const InfoWindow(title: 'You are here'),
        ),
      );
    } else {
      _mapCircles = {};
    }

    // 3. Destination
    if (_destination != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: LatLng(_destination!.latitude, _destination!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          zIndex: 5,
        ),
      );
    }

    setState(() => _markers = newMarkers);
  }

  Future<void> _moveCamera(latlong.LatLng location, {double zoom = 17.0}) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(location.latitude, location.longitude),
        zoom: zoom,
      ),
    ));
  }

  // --- Navigation Logic ---

  Future<void> _startNavigation() async {
    // 1. Check if user is far from campus (Testing from home?)
    if (_currentLocation != null) {
      final distanceToCampus = const latlong.Distance().as(
        latlong.LengthUnit.Kilometer,
        _currentLocation!,
        latlong.LatLng(CampusConstants.campusCenter.latitude, CampusConstants.campusCenter.longitude),
      );

      if (distanceToCampus > 2.0) {
        // User is > 2km away. Offer simulation.
        bool? simulate = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Far from Campus'),
            content: const Text('You appear to be far from campus. Would you like to simulate your location at the Main Gate for testing?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No, use GPS'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Yes, Simulate'),
              ),
            ],
          ),
        );

        if (simulate == true) {
          // Set location to Main Gate (approx)
          _updateUserLocation(latlong.LatLng(9.57426, 77.67612)); // Using Admin Block/Main area
        }
      }
    }

    if (_currentLocation == null) {
      _showSnackBar('Waiting for your location...');
      return;
    }

    if (_destination == null) return;

    setState(() => _isLoading = true);

    try {
      final route = await RoutingService.getRoute(
        start: _currentLocation!,
        end: _destination!,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (route != null) {
            _isRouting = true;
            _routeInfo = '${(route.distance / 1000).toStringAsFixed(2)} km • ${(route.duration / 60).toStringAsFixed(0)} min';
            
            _polylines = {
              Polyline(
                polylineId: const PolylineId('route'),
                points: route.routePoints.map((p) => LatLng(p.latitude, p.longitude)).toList(),
                color: const Color(0xFF1E40AF),
                width: 6,
                jointType: JointType.round,
                startCap: Cap.roundCap,
                endCap: Cap.roundCap,
              ),
            };
            
            _fitBounds(route.routePoints);
          } else {
            _showSnackBar('Could not find a walking route.');
          }
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error calculating route.');
    }
  }

  void _stopNavigation() {
    setState(() {
      _isRouting = false;
      _polylines = {};
      _destination = null;
      _destinationName = null;
      _routeInfo = '';
      _updateMarkers();
    });
  }

  Future<void> _fitBounds(List<latlong.LatLng> points) async {
    if (points.isEmpty) return;
    
    // Calculate center of the route
    double sumLat = 0;
    double sumLng = 0;
    for (var p in points) {
      sumLat += p.latitude;
      sumLng += p.longitude;
    }
    final centerLat = sumLat / points.length;
    final centerLng = sumLng / points.length;

    final GoogleMapController controller = await _controller.future;
    
    // Use a fixed zoom level for walking navigation (safer than bounds on web)
    // Zoom 18 is good for detailed campus walking paths
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(centerLat, centerLng),
        zoom: 18.0,
        tilt: 45.0, // Add tilt for 3D effect
        bearing: 0,
      ),
    ));
  }

  // --- UI Methods ---

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _showBuildingDetails(String name, latlong.LatLng location) {
    setState(() {
      _destination = location;
      _destinationName = name;
      _updateMarkers();
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E40AF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.business, color: Color(0xFF1E40AF), size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Campus Building',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _startNavigation();
                        },
                        icon: const Icon(Icons.directions),
                        label: const Text('Navigate Here'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E40AF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSearchSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 12),
                    Text(
                      'Search Locations',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
              
              // List
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: CampusConstants.buildings.length,
                  itemBuilder: (context, index) {
                    final name = CampusConstants.buildings.keys.elementAt(index);
                    final location = CampusConstants.buildings.values.elementAt(index);
                    return ListTile(
                      leading: const Icon(Icons.place, color: Color(0xFF1E40AF)),
                      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
                      onTap: () {
                        Navigator.pop(context);
                        _moveCamera(location);
                        _showBuildingDetails(name, location);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _isFullScreen
          ? null
          : AppBar(
              title: const Text('Campus Map'),
              backgroundColor: const Color(0xFF1E40AF),
              foregroundColor: Colors.white,
              elevation: 4,
              centerTitle: true,
            ),
      body: Stack(
        children: [
          // 1. Map Layer
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _kCampusCenter,
            onMapCreated: (controller) => _controller.complete(controller),
            markers: _markers,
            polylines: _polylines,
            circles: _mapCircles, // Added circles
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            padding: EdgeInsets.only(
              top: _isFullScreen ? 0 : 100,
              bottom: 20,
            ),
            onTap: (pos) {
              // Simulation mode: tap to teleport
              if (!_isRouting) {
                _updateUserLocation(latlong.LatLng(pos.latitude, pos.longitude));
                _showSnackBar('Location updated (Simulation)');
              }
            },
          ),

          // 2. Search Bar (Only when not routing)
          if (!_isRouting && !_isFullScreen)
            Positioned(
              top: 110, // Below AppBar
              left: 16,
              right: 16,
              child: Card(
                elevation: 6,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: InkWell(
                  onTap: _showSearchSheet,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Color(0xFF1E40AF)),
                        const SizedBox(width: 12),
                        Text(
                          'Where to?',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.list, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // 3. Routing Info Card
          if (_isRouting)
            Positioned(
              top: _isFullScreen ? 40 : 110,
              left: 16,
              right: 16,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: const Color(0xFF1E40AF),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.directions_walk, color: Colors.white, size: 32),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _destinationName ?? 'Destination',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _routeInfo,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _stopNavigation,
                        icon: const Icon(Icons.close, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 4. Control Buttons (Right Side)
          Positioned(
            right: 16,
            bottom: 30,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Full Screen Toggle
                FloatingActionButton.small(
                  heroTag: 'fullscreen',
                  onPressed: () => setState(() => _isFullScreen = !_isFullScreen),
                  backgroundColor: Colors.white,
                  child: Icon(
                    _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Center Campus
                FloatingActionButton.small(
                  heroTag: 'center_campus',
                  onPressed: () => _moveCamera(latlong.LatLng(
                    CampusConstants.campusCenter.latitude,
                    CampusConstants.campusCenter.longitude,
                  )),
                  backgroundColor: Colors.white,
                  tooltip: 'Center on Campus',
                  child: const Icon(Icons.school, color: Colors.black87),
                ),
                const SizedBox(height: 12),

                // Simulate Location (For Testing)
                FloatingActionButton.small(
                  heroTag: 'simulate_location',
                  onPressed: () {
                    // Toggle Simulation
                    _updateUserLocation(latlong.LatLng(9.57426, 77.67612)); // Admin Block
                    _showSnackBar('Simulated Location: Admin Block');
                    _moveCamera(latlong.LatLng(9.57426, 77.67612));
                  },
                  backgroundColor: Colors.orange[100],
                  tooltip: 'Simulate Location (Test)',
                  child: const Icon(Icons.person_pin_circle, color: Colors.deepOrange),
                ),
                const SizedBox(height: 12),

                // My Location
                FloatingActionButton(
                  heroTag: 'my_location',
                  onPressed: () async {
                    _initLocationService();
                    if (_currentLocation != null) {
                      _moveCamera(_currentLocation!);
                    }
                  },
                  backgroundColor: const Color(0xFF1E40AF),
                  tooltip: 'My Real Location',
                  child: const Icon(Icons.my_location, color: Colors.white),
                ),
              ],
            ),
          ),

          // 5. Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black12,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
