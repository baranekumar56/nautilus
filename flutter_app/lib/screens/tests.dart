// // import 'package:flutter/material.dart';
// // import 'package:flutter_map/flutter_map.dart';
// // import 'package:latlong2/latlong.dart';

// // class HeatMapPainter extends CustomPainter {
// //   final List<Map<String, dynamic>> points;

// //   HeatMapPainter(this.points);

// //   @override
// //   void paint(Canvas canvas, Size size) {
// //     final Paint paint = Paint()
// //       ..style = PaintingStyle.fill
// //       ..isAntiAlias = true;

// //     for (var point in points) {
// //       double intensity = point['intensity'];
// //       Color color = getColorForIntensity(intensity);

// //       paint.color = color.withOpacity(0.5);

// //       // Draw an elliptical gradient around the point to simulate waves
// //       final gradient = RadialGradient(
// //         colors: [
// //           color.withOpacity(0.7),
// //           color.withOpacity(0.3),
// //           Colors.transparent,
// //         ],
// //         stops: [0.2, 0.5, 1.0],
// //       );

// //       Rect rect = Rect.fromCircle(
// //         center: Offset(point['x'], point['y']),
// //         radius: intensity * 10, // Adjust the radius for wave size
// //       );

// //       canvas.drawRect(
// //         rect,
// //         Paint()
// //           ..shader = gradient.createShader(rect)
// //           ..style = PaintingStyle.fill,
// //       );
// //     }
// //   }

// //   @override
// //   bool shouldRepaint(covariant CustomPainter oldDelegate) {
// //     return true;
// //   }

// //   // Function to get color based on intensity
// //   Color getColorForIntensity(double intensity) {
// //     if (intensity > 75) {
// //       return const Color.fromARGB(255, 115, 247, 218);
// //     } else if (intensity > 50) {
// //       return const Color.fromARGB(255, 207, 236, 101);
// //     } else {
// //       return Colors.red;
// //     }
// //   }
// // }

// // class HeatMapWaveExample extends StatefulWidget {
// //   @override
// //   _HeatMapWaveExampleState createState() => _HeatMapWaveExampleState();
// // }

// // class _HeatMapWaveExampleState extends State<HeatMapWaveExample> {
// //   final List<Map<String, dynamic>> heatmapPoints = [
// //     {"lat": -23.5505, "lng": -46.6333, "intensity": 50},
// //     {"lat": -23.6805, "lng": -46.5653, "intensity": 80},
// //     {"lat": -23.6505, "lng": -46.7753, "intensity": 30},
// //   ];

// //   List<Map<String, dynamic>> projectedPoints = [];
// //   MapController _mapController = MapController();

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('HeatMap Example'),
// //       ),
// //       body: Stack(
// //         children: [
// //           // Map Layer
// //           FlutterMap(
// //             mapController: _mapController,
// //             options: MapOptions(
// //               center: LatLng(-23.5505, -46.6333), // Example center (São Paulo)
// //               zoom: 10.0, // Adjust zoom level
// //               onPositionChanged: (position, hasGesture) {
// //                 // Recalculate heatmap points on map move
// //                 setState(() {
// //                   projectedPoints = _projectHeatmapPoints();
// //                 });
// //               },
// //             ),
// //             children: [
// //               TileLayer(
// //                 urlTemplate:
// //                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
// //                 subdomains: const ['a', 'b', 'c'],
// //               ),
// //             ],
// //           ),
// //           // Heatmap Layer
// //           Positioned.fill(
// //             child: IgnorePointer(
// //               child: CustomPaint(
// //                 painter: HeatMapPainter(projectedPoints),
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   List<Map<String, dynamic>> _projectHeatmapPoints() {
// //     LatLngBounds bounds = _mapController.bounds!;
// //     double mapWidth = MediaQuery.of(context).size.width;
// //     double mapHeight = MediaQuery.of(context).size.height;

// //     return heatmapPoints.map((point) {
// //       LatLng latLng = LatLng(point['lat'], point['lng']);
// //       var x = ((latLng.longitude - bounds.west) / (bounds.east - bounds.west)) * mapWidth;
// //       var y = ((bounds.north - latLng.latitude) / (bounds.north - bounds.south)) * mapHeight;
// //       return {
// //         "x": x,
// //         "y": y,
// //         "intensity": point['intensity'],
// //       };
// //     }).toList();
// //   }
// // }

// // void main() {
// //   runApp(MaterialApp(
// //     home: HeatMapWaveExample(),
// //   ));
// // }

// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';

// class HeatMapPainter extends CustomPainter {
//   final List<Map<String, dynamic>> points;

//   HeatMapPainter(this.points);

//   @override
//   void paint(Canvas canvas, Size size) {
//     final Paint paint = Paint()
//       ..style = PaintingStyle.fill
//       ..isAntiAlias = true;

//     for (var point in points) {
//       double intensity = point['intensity'];
//       Color color = getColorForIntensity(intensity);

//       paint.color = color.withOpacity(0.5);

//       final gradient = RadialGradient(
//         colors: [
//           color.withOpacity(0.7),
//           color.withOpacity(0.3),
//           Colors.transparent,
//         ],
//         stops: [0.2, 0.5, 1.0],
//       );

//       Rect rect = Rect.fromCircle(
//         center: Offset(point['x'], point['y']),
//         radius: intensity * 10, // Adjust the radius for wave size
//       );

//       canvas.drawRect(
//         rect,
//         Paint()
//           ..shader = gradient.createShader(rect)
//           ..style = PaintingStyle.fill,
//       );
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return true;
//   }

//   Color getColorForIntensity(double intensity) {
//     if (intensity > 75) {
//       return const Color.fromARGB(255, 115, 247, 218);
//     } else if (intensity > 50) {
//       return const Color.fromARGB(255, 207, 236, 101);
//     } else {
//       return Colors.red;
//     }
//   }
// }

// class HeatMapWaveExample extends StatefulWidget {
//   @override
//   _HeatMapWaveExampleState createState() => _HeatMapWaveExampleState();
// }

// class _HeatMapWaveExampleState extends State<HeatMapWaveExample> {
//   final List<Map<String, dynamic>> heatmapPoints = [
//     {"lat": -23.5505, "lng": -46.6333, "intensity": 50},
//     {"lat": -23.6805, "lng": -46.5653, "intensity": 80},
//     {"lat": -23.6505, "lng": -46.7753, "intensity": 30},
//   ];

//   List<Map<String, dynamic>> projectedPoints = [];
//   MapController _mapController = MapController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('HeatMap Example'),
//       ),
//       body: Column(
//         children: [
//           // Upper Part: Map View with Heatmap Overlay
//           Expanded(
//             child: Stack(
//               children: [
//                 FlutterMap(
//                   mapController: _mapController,
//                   options: MapOptions(
//                     center: LatLng(-23.5505, -46.6333), // Example center
//                     zoom: 10.0, // Adjust zoom level
//                     onPositionChanged: (position, hasGesture) {
//                       setState(() {
//                         projectedPoints = _projectHeatmapPoints();
//                       });
//                     },
//                   ),
//                   children: [
//                     TileLayer(
//                       urlTemplate:
//                           "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
//                       subdomains: const ['a', 'b', 'c'],
//                     ),
//                   ],
//                 ),
//                 Positioned.fill(
//                   child: IgnorePointer(
//                     child: CustomPaint(
//                       painter: HeatMapPainter(projectedPoints),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Lower Part: List View with Heatmap Details
//           Container(
//             height: 200.0, // Adjust as needed
//             color: Colors.white,
//             child: ListView.builder(
//               itemCount: heatmapPoints.length,
//               itemBuilder: (context, index) {
//                 final point = heatmapPoints[index];
//                 Color color = getColorForIntensity(point['intensity']);
//                 return ListTile(
//                   contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                   leading: Container(
//                     width: 10.0,
//                     height: 40.0,
//                     color: color,
//                   ),
//                   title: Text('Lat: ${point['lat']}, Lng: ${point['lng']}'),
//                   subtitle: Text('Intensity: ${point['intensity']}'),
//                   tileColor: index.isEven ? Colors.grey[200] : Colors.white,
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   List<Map<String, dynamic>> _projectHeatmapPoints() {
//     LatLngBounds bounds = _mapController.bounds!;
//     double mapWidth = MediaQuery.of(context).size.width;
//     double mapHeight = MediaQuery.of(context).size.height;

//     return heatmapPoints.map((point) {
//       LatLng latLng = LatLng(point['lat'], point['lng']);
//       var x = ((latLng.longitude - bounds.west) / (bounds.east - bounds.west)) * mapWidth;
//       var y = ((bounds.north - latLng.latitude) / (bounds.north - bounds.south)) * mapHeight;
//       return {
//         "x": x,
//         "y": y,
//         "intensity": point['intensity'],
//       };
//     }).toList();
//   }

//   Color getColorForIntensity(double intensity) {
//     if (intensity > 75) {
//       return const Color.fromARGB(255, 115, 247, 218);
//     } else if (intensity > 50) {
//       return const Color.fromARGB(255, 207, 236, 101);
//     } else {
//       return Colors.red;
//     }
//   }
// }

// void main() {
//   runApp(MaterialApp(
//     home: HeatMapWaveExample(),
//   ));
// }
