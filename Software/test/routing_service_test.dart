import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:campus_companion/services/routing_service.dart';

void main() {
  group('RoutingService Tests', () {
    test('should format distance correctly', () {
      expect(RoutingService.formatDistance(500), '500 m');
      expect(RoutingService.formatDistance(1500), '1.5 km');
      expect(RoutingService.formatDistance(2000), '2.0 km');
    });

    test('should format duration correctly', () {
      expect(RoutingService.formatDuration(120), '2 min');
      expect(RoutingService.formatDuration(3600), '1h 0m');
      expect(RoutingService.formatDuration(3900), '1h 5m');
    });

    test('should create campus route between two points', () async {
      final start = LatLng(9.57451, 77.67424); // 1st Block
      final end = LatLng(9.57453, 77.67873);   // Library
      
      final route = await RoutingService.getRoute(
        start: start,
        end: end,
        profile: 'foot-walking',
      );

      expect(route, isNotNull);
      expect(route!.routePoints.length, greaterThan(2));
      expect(route.distance, greaterThan(0));
      expect(route.duration, greaterThan(0));
      expect(route.instructions.isNotEmpty, true);
    });

    test('should handle multiple routes', () async {
      final start = LatLng(9.57451, 77.67424); // 1st Block
      final end = LatLng(9.57453, 77.67873);   // Library
      
      final routes = await RoutingService.getMultipleRoutes(
        start: start,
        end: end,
      );

      expect(routes.isNotEmpty, true);
      expect(routes.first.routePoints.length, greaterThan(1));
    });
  });
}
