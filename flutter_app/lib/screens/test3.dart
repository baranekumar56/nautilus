// // import 'package:flutter/material.dart';
// // import 'package:flutter_map/flutter_map.dart';
// // import 'package:latlong2/latlong.dart';

// // class WindyMapWithHeatmap extends StatelessWidget {
// //   final List<Map<String, dynamic>> weatherData = [
// //     {"lat": 51.5, "lon": -0.09, "windSpeed": 15.0, "waveHeight": 2.5},
// //     {"lat": 51.6, "lon": -0.10, "windSpeed": 10.0, "waveHeight": 1.2},
// //     {"lat": 51.7, "lon": -0.08, "windSpeed": 20.0, "waveHeight": 3.0},
// //   ];

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: Stack(
// //         children: [
// //           TileLayer(
// //                 urlTemplate:
// //                     "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
// //                 subdomains: const ['a', 'b', 'c'],
// //               ),
// //           FlutterMap(
// //             options: MapOptions(
// //               center: LatLng(51.5, -0.09),
// //               zoom: 5.0,
// //             ),
         
// //           ),
// //           Positioned.fill(
// //             child: CustomPaint(
// //               painter: HeatmapPainter(weatherData),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // class HeatmapPainter extends CustomPainter {
// //   final List<Map<String, dynamic>> weatherData;

// //   HeatmapPainter(this.weatherData);

// //   @override
// //   void paint(Canvas canvas, Size size) {
// //     final paint = Paint()..style = PaintingStyle.fill;

// //     for (var data in weatherData) {
// //       double windSpeed = data['windSpeed'];
// //       double waveHeight = data['waveHeight'];
// //       Offset position = mapLatLngToPixel(data['lat'], data['lon']);  // Convert lat/lon to pixel position

// //       paint.color = getHeatmapColor(windSpeed);  // Set color based on wind speed

// //       // Draw a circle at each weather data point
// //       canvas.drawCircle(position, waveHeight * 5, paint);  // Circle size is proportional to wave height
// //     }
// //   }

// //   // Function to map wind speed to a heatmap color
// //   Color getHeatmapColor(double windSpeed) {
// //     if (windSpeed < 10) {
// //       return Colors.green.withOpacity(0.5);  // Low wind speed
// //     } else if (windSpeed < 20) {
// //       return Colors.yellow.withOpacity(0.5);  // Moderate wind speed
// //     } else {
// //       return Colors.red.withOpacity(0.5);  // High wind speed
// //     }
// //   }

// //   @override
// //   bool shouldRepaint(CustomPainter oldDelegate) {
// //     return true;
// //   }
// // }

// // // Helper function to convert LatLng to screen position
// // Offset mapLatLngToPixel(double lat, double lon) {
// //   final mapController = MapController();
// //   LatLng latLng = LatLng(lat, lon);
// //   var pixelPos = mapController.latLngToScreenPoint(latLng);
// //   return Offset(pixelPos.x, pixelPos.y);
// // }

// import 'dart:async';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';

// class WindyMapWithHeatmap extends StatefulWidget {
//   @override
//   _WindyMapWithHeatmapState createState() => _WindyMapWithHeatmapState();
// }

// class _WindyMapWithHeatmapState extends State<WindyMapWithHeatmap>
//     with SingleTickerProviderStateMixin {
//   AnimationController? _controller;

//   final List<Map<String, dynamic>> weatherData = [
//     {"lat": 51.5, "lon": -0.09, "windSpeed": 15.0, "waveHeight": 2.5},
//     {"lat": 51.6, "lon": -0.10, "windSpeed": 10.0, "waveHeight": 1.2},
//     {"lat": 51.7, "lon": -0.08, "windSpeed": 20.0, "waveHeight": 3.0},
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(seconds: 5),
//       vsync: this,
//     )..repeat(); // Repeats the animation for wind particles
//   }

//   @override
//   void dispose() {
//     _controller?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final mapController = MapController(); // Create the MapController

//     return Scaffold(
//       body: Stack(
//         children: [
//           FlutterMap(
//             mapController: mapController,
//             options: MapOptions(
//               center: LatLng(51.5, -0.09),
//               zoom: 5.0,
//             ),
//             layers: [
//               TileLayerOptions(
//                 urlTemplate:
//                     "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
//                 subdomains: const ['a', 'b', 'c'],
//               ),
//             ],
//           ),
//           // Heatmap Layer
//           Positioned.fill(
//             child: CustomPaint(
//               painter: HeatmapPainter(weatherData, mapController),
//             ),
//           ),
//           // Wind Particle Animation Layer
//           Positioned.fill(
//             child: AnimatedBuilder(
//               animation: _controller!,
//               builder: (context, child) {
//                 return CustomPaint(
//                   painter: WindParticlePainter(weatherData, mapController, _controller!.value),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class WindParticlePainter extends CustomPainter {
//   final List<Map<String, dynamic>> weatherData;
//   final MapController mapController;
//   final double animationValue;

//   WindParticlePainter(this.weatherData, this.mapController, this.animationValue);

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.blue.withOpacity(0.7)
//       ..strokeWidth = 2.0;

//     for (var data in weatherData) {
//       // Convert lat/lon to pixel position
//       Offset? position = mapLatLngToPixel(data['lat'], data['lon']);

//       if (position != null) {
//         // Draw wind particle based on wind speed and direction
//         double windSpeed = data['windSpeed'];
//         double particleSize = windSpeed * 0.1; // Scale size by wind speed
//         double dx = cos(animationValue * 2 * pi) * particleSize;
//         double dy = sin(animationValue * 2 * pi) * particleSize;
        
//         canvas.drawLine(
//           position,
//           position.translate(dx, dy), // Create a moving particle effect
//           paint,
//         );
//       }
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return true; // Redraw on animation
//   }

//   // Helper function to convert LatLng to screen position
//   Offset? mapLatLngToPixel(double lat, double lon) {
//     if (!mapController.Onready) return null;

//     LatLng latLng = LatLng(lat, lon);
//     var pixelPos = mapController.latLngToScreenPoint(latLng);
//     return Offset(pixelPos.x, pixelPos.y);
//   }
// }

// class HeatmapPainter extends CustomPainter {
//   final MapController mapController;
//   final List<Map<String, dynamic>> weatherData;

//   HeatmapPainter(this.mapController, this.weatherData);

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()..style = PaintingStyle.fill;

//     for (var data in weatherData) {
//       double windSpeed = data['windSpeed'];
//       double waveHeight = data['waveHeight'];

//       LatLng latLng = LatLng(data['lat'], data['lon']);
//       Offset? position = mapLatLngToPixel(mapController, latLng);  // Use custom method

//       if (position != null) {
//         paint.color = getHeatmapColor(windSpeed);  // Set color based on wind speed
//         canvas.drawCircle(position, waveHeight * 5, paint);  // Circle size proportional to wave height
//       }
//     }
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) {
//     return true;
//   }

//   // Function to map wind speed to a heatmap color
//   Color getHeatmapColor(double windSpeed) {
//     if (windSpeed < 10) {
//       return Colors.green.withOpacity(0.5);  // Low wind speed
//     } else if (windSpeed < 20) {
//       return Colors.yellow.withOpacity(0.5);  // Moderate wind speed
//     } else {
//       return Colors.red.withOpacity(0.5);  // High wind speed
//     }
//   }
//   // Helper function to map waveHeight to gradient colors
//   List<Color> getWaveColors(double waveHeight) {
//     if (waveHeight < 1.5) {
//       return [Colors.blue.withOpacity(0.5), Colors.blue.withOpacity(0.2)];
//     } else if (waveHeight < 2.5) {
//       return [Colors.green.withOpacity(0.5), Colors.green.withOpacity(0.2)];
//     } else {
//       return [Colors.red.withOpacity(0.5), Colors.red.withOpacity(0.2)];
//     }
//   }

//   // Helper function to convert LatLng to screen position
//  Offset? mapLatLngToPixel(MapController mapController, LatLng latLng) {
//   // Try to convert LatLng to pixel position
//   try {
//     var pixelPos = mapController.latLngToScreenPoint(latLng);
//     if (pixelPos != null) {
//       return Offset(pixelPos.x, pixelPos.y);
//     }
//   } catch (e) {
//     print('Error converting LatLng to screen point: $e');
//   }
//   return null;  // Return null if conversion fails
// }

// }


