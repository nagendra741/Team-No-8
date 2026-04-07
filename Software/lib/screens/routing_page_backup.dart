import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/custom_cursor.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:math';

class RoutingPage extends StatefulWidget {
  const RoutingPage({super.key});

  @override
  State<RoutingPage> createState() => _RoutingPageState();
}

class _RoutingPageState extends State<RoutingPage> with TickerProviderStateMixin {
  final Location location = Location();
  final MapController _mapController = MapController();
  final TextEditingController _destinationController = TextEditingController();
  
  LatLng? _currentPosition;
  LatLng? _destination;
  List<LatLng> routePoints = [];
  double? distance;
  String? duration;
  String? _selectedVehicle;
  String? _selectedBlock;
  double _zoomLevel = 15.0;
  bool _isFullScreen = false;
  bool _isSearching = false;
  
  List<Map<String, dynamic>> _searchResults = [];
  Timer? _locationUpdateTimer;

  final List<String> _vehicleTypes = ['Walking', '2-Wheeler', '4-Wheeler'];
  
  final Map<String, LatLng> collegeBlocks = {
    "1st Block": const LatLng(9.57451, 77.67424),
    "4th Block": const LatLng(9.57552, 77.67585),
    "5th Block": const LatLng(9.57398, 77.67574),
    "6th Block": const LatLng(9.57246, 77.67586),
    "7th Block": const LatLng(9.57407, 77.67387),
    "8th Block": const LatLng(9.57479, 77.67534),
    "9th Block": const LatLng(9.57447, 77.67464),
    "10th Block": const LatLng(9.57404, 77.67483),
    "11th Block": const LatLng(9.573, 77.67548),
    "Staff Quarters": const LatLng(9.57499, 77.67974),
    "Ground": const LatLng(9.57585, 77.67602),
    "Temple": const LatLng(9.57621, 77.67967),
    "Library": const LatLng(9.57453, 77.67873),
    "Hospital": const LatLng(9.57394, 77.68306),
  };

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initLocation();
    _initAnimations();
    _destinationController.addListener(_onSearchTextChanged);
    _startLocationUpdateTimer();
  }

  void _initLocation() async {
    await _fetchLocation();
    _startLiveLocationUpdates();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _destinationController.dispose();
    _locationUpdateTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    try {
      final LocationData loc = await location.getLocation();
      setState(() {
        _currentPosition = LatLng(loc.latitude!, loc.longitude!);
      });
    } catch (e) {
      debugPrint("Error fetching location: $e");
    }
  }

  void _startLiveLocationUpdates() {
    location.onLocationChanged.listen((LocationData loc) {
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(loc.latitude!, loc.longitude!);
        });
      }
    });
  }

  void _startLocationUpdateTimer() {
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _fetchLocation();
    });
  }

  Future<void> _fetchRoute() async {
    if (_currentPosition == null || _destination == null) {
      _showErrorDialog("Please set both current location and destination");
      return;
    }

    // Always use direct path routing for reliability
    _createDirectPathRoute();
  }

  void _createDirectPathRoute() {
    if (_currentPosition == null || _destination == null) return;

    // Calculate straight-line distance using Haversine formula
    final straightDistance = _calculateStraightLineDistance(
      _currentPosition!,
      _destination!,
    );

    setState(() {
      // Create a simple straight line between points
      routePoints = [_currentPosition!, _destination!];
      distance = straightDistance;
      duration = _calculateDuration(distance!);
    });

    // Center map to show both points
    final bounds = _calculateBounds([_currentPosition!, _destination!]);
    _mapController.fitCamera(CameraFit.bounds(bounds: bounds));
    _animationController.forward();

    // Show success message
    _showSuccessDialog("Route calculated! Distance: ${distance!.toStringAsFixed(2)} km");
  }

  double _calculateStraightLineDistance(LatLng point1, LatLng point2) {
    // Haversine formula for calculating distance between two points
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double lat1Rad = point1.latitude * (pi / 180);
    final double lat2Rad = point2.latitude * (pi / 180);
    final double deltaLatRad = (point2.latitude - point1.latitude) * (pi / 180);
    final double deltaLngRad = (point2.longitude - point1.longitude) * (pi / 180);

    final double a = (sin(deltaLatRad / 2) * sin(deltaLatRad / 2)) +
        (cos(lat1Rad) * cos(lat2Rad) * sin(deltaLngRad / 2) * sin(deltaLngRad / 2));
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  LatLngBounds _calculateBounds(List<LatLng> points) {
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      minLat = min(minLat, point.latitude);
      maxLat = max(maxLat, point.latitude);
      minLng = min(minLng, point.longitude);
      maxLng = max(maxLng, point.longitude);
    }

    return LatLngBounds(
      LatLng(minLat, minLng),
      LatLng(maxLat, maxLng),
    );
  }

  String _calculateDuration(double distanceInKm) {
    double speed = 5.0; // Default walking speed
    switch (_selectedVehicle) {
      case '2-Wheeler':
        speed = 40.0;
        break;
      case '4-Wheeler':
        speed = 60.0;
        break;
    }

    final timeInHours = distanceInKm / speed;
    final hours = timeInHours.floor();
    final minutes = ((timeInHours - hours) * 60).round();

    if (hours == 0) return "$minutes minutes";
    if (minutes == 0) return "$hours hours";
    return "$hours hours $minutes minutes";
  }

  void _showErrorDialog(String message) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
            ),
            const SizedBox(width: 8),
            Text(
              "Error",
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.green,
            ),
            const SizedBox(width: 8),
            Text(
              "Route Found",
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
      SystemChrome.setEnabledSystemUIMode(
        _isFullScreen ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
      );
    });
  }

  void _zoomIn() {
    setState(() {
      _zoomLevel += 1;
      _mapController.move(_mapController.camera.center, _zoomLevel);
    });
  }

  void _zoomOut() {
    setState(() {
      _zoomLevel -= 1;
      _mapController.move(_mapController.camera.center, _zoomLevel);
    });
  }

  void _moveToLiveLocation() {
    if (_currentPosition != null) {
      _mapController.move(_currentPosition!, _zoomLevel);
    }
  }

  Future<void> _fetchSearchSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/search?format=json&q=$query&countrycodes=IN',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          _searchResults = data.map((item) => item as Map<String, dynamic>).toList();
          _isSearching = false;
        });
      } else {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  void _onSearchTextChanged() => _fetchSearchSuggestions(_destinationController.text);

  void _onSearchResultSelected(Map<String, dynamic> result) {
    setState(() {
      _destination = LatLng(
        double.parse(result['lat']),
        double.parse(result['lon']),
      );
      _destinationController.text = result['display_name'];
      _searchResults = [];
    });
    _fetchRoute();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: _isFullScreen ? null : _buildModernAppBar(theme),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode ? [
              const Color(0xFF0A0E27),
              const Color(0xFF1A1B3A),
              const Color(0xFF2D1B69),
            ] : [
              const Color(0xFF667EEA),
              const Color(0xFF764BA2),
              const Color(0xFFF093FB),
            ],
          ),
        ),
        child: Column(
          children: [
            if (!_isFullScreen) _buildControls(),
            _buildMap(),
            if (!_isFullScreen) _buildMapControls(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar(ThemeData theme) {
    final isDarkMode = theme.brightness == Brightness.dark;
    final iconColor = isDarkMode ? Colors.white : Colors.black87;
    final containerColor = isDarkMode
        ? Colors.white.withOpacity(0.2)
        : Colors.white.withOpacity(0.9);
    final borderColor = isDarkMode
        ? Colors.white.withOpacity(0.3)
        : Colors.black.withOpacity(0.1);

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: isDarkMode
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      leading: CustomCursor(
        child: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: containerColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: borderColor,
                width: 1,
              ),
              boxShadow: isDarkMode ? null : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back_rounded,
              color: iconColor,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDarkMode
              ? Colors.white.withOpacity(0.15)
              : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
          boxShadow: isDarkMode ? null : [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.navigation_rounded,
              color: iconColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'GPS Routing',
              style: TextStyle(
                color: iconColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      centerTitle: true,
      actions: [
        CustomCursor(
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: containerColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: borderColor,
                  width: 1,
                ),
                boxShadow: isDarkMode ? null : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                _isFullScreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
                color: iconColor,
                size: 20,
              ),
            ),
            onPressed: _toggleFullScreen,
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildControls() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSearchCard(),
          const SizedBox(height: 16),
          _buildBlockSelector(),
          if (distance != null && duration != null) _buildRouteInfo(),
        ],
      ),
    );
  }

  Widget _buildSearchCard() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withOpacity(0.15)
            : Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.3)
              : Colors.black.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.1 : 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
          children: [
            TextField(
              controller: _destinationController,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                labelText: "Enter Destination",
                labelStyle: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDarkMode ? Colors.white30 : Colors.black26,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDarkMode ? Colors.white30 : Colors.black26,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.blue,
                    width: 2,
                  ),
                ),
                suffixIcon: _isSearching
                    ? const CircularProgressIndicator()
                    : Icon(
                        Icons.search,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
              ),
            ),
            if (_searchResults.isNotEmpty) _buildSearchResults(),
            const SizedBox(height: 10),
            _buildVehicleSelector(),
            const SizedBox(height: 10),
            _buildFindRouteButton(),
          ],
        ),
    );
  }

  Widget _buildSearchResults() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListView.builder(
        itemCount: _searchResults.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(_searchResults[index]['display_name']),
          onTap: () => _onSearchResultSelected(_searchResults[index]),
        ),
      ),
    );
  }

  Widget _buildVehicleSelector() {
    return DropdownButtonFormField<String>(
      value: _selectedVehicle,
      hint: const Text("Select Vehicle"),
      items: _vehicleTypes.map((String vehicle) {
        return DropdownMenuItem<String>(
          value: vehicle,
          child: Text(vehicle),
        );
      }).toList(),
      onChanged: (newVehicle) {
        setState(() => _selectedVehicle = newVehicle);
        if (_destination != null) _fetchRoute();
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildFindRouteButton() {
    return ElevatedButton(
      onPressed: () {
        if (_destinationController.text.isEmpty) return;
        _fetchRoute();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade800,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: const Text("Find Route", style: TextStyle(color: Colors.white)),
    );
  }

  Widget _buildBlockSelector() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: DropdownButton<String>(
          hint: const Text("Select a Block"),
          value: _selectedBlock,
          isExpanded: true,
          items: collegeBlocks.keys.map((String block) {
            return DropdownMenuItem<String>(
              value: block,
              child: Text(block),
            );
          }).toList(),
          onChanged: (newBlock) {
            setState(() {
              _selectedBlock = newBlock;
              _destination = collegeBlocks[newBlock];
            });
            _fetchRoute();
          },
        ),
      ),
    );
  }

  Widget _buildRouteInfo() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Text("Distance: ${distance!.toStringAsFixed(2)} km",
                  style: const TextStyle(fontSize: 16)),
              Text("Duration: $duration",
                  style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMap() {
    return Expanded(
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _currentPosition ?? const LatLng(20.5937, 78.9629),
          initialZoom: _zoomLevel,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a', 'b', 'c'],
          ),
          if (_currentPosition != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _currentPosition!,
                  width: 30,
                  height: 30,
                  child: const Icon(Icons.my_location, color: Colors.blue),
                ),
              ],
            ),
          if (routePoints.isNotEmpty)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: routePoints,
                  color: Colors.blue.shade800,
                  strokeWidth: 5.0,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMapControls() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.zoom_in, color: Colors.blue.shade800),
            onPressed: _zoomIn,
          ),
          IconButton(
            icon: Icon(Icons.zoom_out, color: Colors.blue.shade800),
            onPressed: _zoomOut,
          ),
          IconButton(
            icon: Icon(Icons.my_location, color: Colors.blue.shade800),
            onPressed: _moveToLiveLocation,
          ),
        ],
      ),
    );
  }
}