import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RoutingService {
  // New method to fetch intermediate points from FastAPI
  Future<List<LatLng>> getIntermediatePoints(LatLng source, LatLng destination) async {
  final url = 'http://10.0.2.2:8000/get_points'; // Change IP based on your environment
  
  final body = jsonEncode({
    'start_latitude': source.latitude,
    'start_longitude': source.longitude,
    'end_latitude': destination.latitude,
    'end_longitude': destination.longitude,
    'ship_speed':10
  });

  // Use await to ensure the app waits for the response from the server
  final response = await http.post(
    Uri.parse(url),
    headers: {'Content-Type': 'application/json'},
    body: body,
  );
  print(response.statusCode);
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    print(data['intermediete_points']);
    final points = data['intermediete_points'] as List;
    
    // Processing the response here
    return points.map((point) => LatLng(point[0], point[1])).toList();
  } else {
    throw Exception('Failed to fetch intermediate points');
  }
}
}
