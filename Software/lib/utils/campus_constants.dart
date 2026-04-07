import 'package:latlong2/latlong.dart';
import 'api_keys.dart';

class CampusConstants {
  // Google Maps API Key
  static const String googleMapsApiKey = ApiKeys.googleMapsApiKey;

  static final Map<String, LatLng> buildings = {
    '1st Block': const LatLng(9.57451, 77.67424),
    '4th Block': const LatLng(9.57552, 77.67585),
    '5th Block': const LatLng(9.57398, 77.67574),
    '6th Block': const LatLng(9.57246, 77.67586),
    '7th Block': const LatLng(9.57407, 77.67387),
    '8th Block': const LatLng(9.57479, 77.67534),
    '9th Block': const LatLng(9.57447, 77.67464),
    '10th Block': const LatLng(9.57404, 77.67483),
    '11th Block': const LatLng(9.573, 77.67548),
    'Staff Quarters': const LatLng(9.57499, 77.67974),
    'Ground': const LatLng(9.57585, 77.67602),
    'Temple': const LatLng(9.57621, 77.67967),
    'MH1': const LatLng(9.57426, 77.67612),
    'MH3': const LatLng(9.57141, 77.6753),
    'MH4': const LatLng(9.57363, 77.67812),
    'MH6': const LatLng(9.57422, 77.67779),
    'Ladies Hostel': const LatLng(9.57589, 77.68157),
    'Admin Block': const LatLng(9.57426, 77.67612),
    'Mani Mandapam': const LatLng(9.57504, 77.67668),
    'Library': const LatLng(9.57453, 77.67873),
    'Polytec': const LatLng(9.57374, 77.67093),
    'IRC': const LatLng(9.57418, 77.67878),
    'Swimming Pool': const LatLng(9.57664, 77.67949),
    'K.S. Auditorium': const LatLng(9.57505, 77.67732),
    'Hospital': const LatLng(9.57394, 77.68306),
  };

  static const LatLng campusCenter = LatLng(9.57451, 77.67424);
}
