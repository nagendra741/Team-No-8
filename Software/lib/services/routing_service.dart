import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/foundation.dart';
import '../utils/campus_constants.dart';

class RoutingService {
  static final Dio _dio = Dio();
  
  // Google Directions API endpoint
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/directions/json';
  
  /// Get route between two points using Google Directions API
  static Future<RouteResult?> getRoute({
    required LatLng start,
    required LatLng end,
  }) async {
    try {
      String requestUrl = _baseUrl;
      final Map<String, dynamic> queryParams = {
        'origin': '${start.latitude},${start.longitude}',
        'destination': '${end.latitude},${end.longitude}',
        'mode': 'walking',
        'key': CampusConstants.googleMapsApiKey,
      };

      // Handle CORS for Web
      if (kIsWeb) {
        // Use corsproxy.io which is often more reliable for Google Maps API
        final queryString = Uri(queryParameters: queryParams).query;
        final targetUrl = '$_baseUrl?$queryString';
        requestUrl = 'https://corsproxy.io/?${Uri.encodeComponent(targetUrl)}';
        queryParams.clear();
      }

      final response = await _dio.get(
        requestUrl,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200) {
        return _parseGoogleResponse(response.data);
      }
    } catch (e) {
      debugPrint('Error getting Google route: $e');
    }

    // 2. Try OSRM (Open Source Routing Machine) as Fallback
    // OSRM is free and often has easier CORS policies for web
    try {
      debugPrint('Attempting OSRM Fallback...');
      return await _getOSRMRoute(start, end);
    } catch (e) {
      debugPrint('Error getting OSRM route: $e');
    }

    // 3. Final Fallback: Direct Line
    debugPrint('Using Final Fallback: Direct Line');
    return _getDirectRoute(start, end);
  }

  /// Get route using OSRM (Open Source Routing Machine)
  static Future<RouteResult?> _getOSRMRoute(LatLng start, LatLng end) async {
    // OSRM uses lon,lat format
    final url = 'http://router.project-osrm.org/route/v1/walking/'
        '${start.longitude},${start.latitude};${end.longitude},${end.latitude}'
        '?overview=full&geometries=polyline';

    final response = await _dio.get(url);

    if (response.statusCode == 200) {
      final data = response.data;
      if (data['code'] != 'Ok') throw Exception('OSRM Error: ${data['code']}');

      final routes = data['routes'] as List;
      if (routes.isEmpty) throw Exception('No OSRM route found');

      final route = routes[0];
      final geometry = route['geometry'] as String;
      final distance = (route['distance'] as num).toDouble();
      final duration = (route['duration'] as num).toDouble();

      return RouteResult(
        routePoints: _decodePolyline(geometry),
        distance: distance,
        duration: duration,
        instructions: [
          RouteInstruction(
            instruction: 'Follow path (OSRM)',
            distance: distance,
            duration: duration,
          ),
        ],
      );
    }
    return null;
  }

  /// Fallback: Creates a straight line route when API fails
  static RouteResult _getDirectRoute(LatLng start, LatLng end) {
    final distance = const Distance().as(LengthUnit.Meter, start, end);
    // Estimate walking time: 1.4 m/s (approx 5 km/h)
    final duration = distance / 1.4; 

    return RouteResult(
      routePoints: [start, end],
      distance: distance,
      duration: duration,
      instructions: [
        RouteInstruction(
          instruction: 'Walk straight to destination (Direct Line)',
          distance: distance,
          duration: duration,
        ),
      ],
    );
  }

  /// Parse the Google Directions API response
  static RouteResult _parseGoogleResponse(Map<String, dynamic> data) {
    try {
      if (data['status'] != 'OK') {
        throw Exception('Google API Error: ${data['status']} - ${data['error_message'] ?? ''}');
      }

      final routes = data['routes'] as List;
      if (routes.isEmpty) {
        throw Exception('No route found');
      }

      final route = routes[0] as Map<String, dynamic>;
      final legs = route['legs'] as List;
      final leg = legs[0] as Map<String, dynamic>;

      // Extract distance and duration
      final distanceText = leg['distance']['text'];
      final distanceValue = (leg['distance']['value'] as num).toDouble(); // meters
      
      final durationText = leg['duration']['text'];
      final durationValue = (leg['duration']['value'] as num).toDouble(); // seconds

      // Decode the overview polyline for the full route shape
      final overviewPolyline = route['overview_polyline']['points'] as String;
      final List<LatLng> routePoints = _decodePolyline(overviewPolyline);

      // Extract instructions from steps
      final steps = leg['steps'] as List;
      final List<RouteInstruction> instructions = [];
      
      for (final step in steps) {
        instructions.add(RouteInstruction(
          instruction: _stripHtmlTags(step['html_instructions'] as String),
          distance: (step['distance']['value'] as num).toDouble(),
          duration: (step['duration']['value'] as num).toDouble(),
        ));
      }

      return RouteResult(
        routePoints: routePoints,
        distance: distanceValue,
        duration: durationValue,
        instructions: instructions,
      );
    } catch (e) {
      debugPrint('Error parsing Google route response: $e');
      throw Exception('Failed to parse route data');
    }
  }

  /// Decodes an encoded polyline string into a list of LatLng points.
  /// Algorithm from Google Maps Platform documentation.
  static List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  static String _stripHtmlTags(String htmlString) {
    return htmlString.replaceAll(RegExp(r'<[^>]*>'), '');
  }
}

/// Route result data class
class RouteResult {
  final List<LatLng> routePoints;
  final double distance; // in meters
  final double duration; // in seconds
  final List<RouteInstruction> instructions;

  RouteResult({
    required this.routePoints,
    required this.distance,
    required this.duration,
    required this.instructions,
  });
}

/// Route instruction data class
class RouteInstruction {
  final String instruction;
  final double distance; // in meters
  final double duration; // in seconds

  RouteInstruction({
    required this.instruction,
    required this.distance,
    required this.duration,
  });
}
