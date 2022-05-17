import 'package:google_maps_flutter/google_maps_flutter.dart';

class FirebaseLocationData {
  final LatLng location;
  final String name;
  final double percentage;
  final String firebaseId;

  const FirebaseLocationData({
    required this.location,
    required this.name,
    required this.percentage,
    required this.firebaseId,
  });
  factory FirebaseLocationData.fromJson(Map<String, dynamic> json) =>
      FirebaseLocationData(
          location: LatLng(
            double.parse(
              json['latitude'].toString(),
            ),
            double.parse(
              json['longitude'].toString(),
            ),
          ),
          name: json['name'],
          percentage: double.parse(
            json['percentage'].toString(),
          ),
          firebaseId: json['firebase_id']);
  Map<String, dynamic> toJSON() => {
        "latitude": location.latitude.toString(),
        "longitude": location.longitude.toString(),
        "name": name,
        "percentage": percentage.toString(),
        "firebase_id": firebaseId.toString(),
      };
}
