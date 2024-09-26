// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';

// class WindyAnimationApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: WindyMap(),
//     );
//   }
// }

// class WindyMap extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Windy-Like Animations'),
//       ),
//       body: Stack(
//         children: [
//           // FlutterMap base layer with TileLayer inside
//           FlutterMap(
//             options: MapOptions(
//               center: LatLng(51.5, -0.09),
//               zoom: 5.0,
//             ),
//             layers: [
//               TileLayerOptions(
//                 urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
//                 subdomains: ['a', 'b', 'c'],
//               ),
//             ],
//           ),
//           // Wind animation overlay
//           Positioned.fill(
//             child: WindAnimationLayer(),
//           ),
//           // Wave animation overlay
//           Positioned.fill(
//             child: WaveAnimationLayer(
//               weatherData: [
//                 {'lat': 51.5, 'lon': -0.09, 'waveHeight': 5},
//                 {'lat': 52.0, 'lon': -0.12, 'waveHeight': 10},
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class WindAnimationLayer extends StatefulWidget {
//   @override
//   _WindAnimationLayerState createState() => _WindAnimationLayerState();
// }

// class _WindAnimationLayerState extends State<WindAnimationLayer> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   List<WindParticle> particles = [];
//   Random random = Random();

//   @override
//   void initState() {
//     super.initState();

//     _controller = AnimationController(
//       vsync: this,
//       duration: Duration(seconds: 10),
//     )..repeat(); // Infinite loop for the animation

//     // Initialize wind particles
//     for (int i = 0; i < 100; i++) {
//       particles.add(WindParticle(
//         position: Offset(random.nextDouble() * 400, random.nextDouble() * 600),
//         windSpeed: random.nextDouble() * 20 + 10,  // Random wind speed
//         direction: random.nextDouble() * 360,     // Random direction
//       ));
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _controller,
//       builder: (context, child) {
//         return LayoutBuilder(
//           builder: (context, constraints) {
//             return CustomPaint(
//               size: Size(constraints.maxWidth, constraints.maxHeight),
//               painter: WindPainter(particles: particles, controller: _controller),
//             );
//           },
//         );
//       },
//     );
//   }
// }

// class WindPainter extends CustomPainter {
//   List<WindParticle> particles;
//   Animation<double> controller;

//   WindPainter({required this.particles, required this.controller});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final Paint particlePaint = Paint()
//       ..color = Colors.white.withOpacity(0.7)
//       ..style = PaintingStyle.fill;

//     for (WindParticle particle in particles) {
//       // Calculate particle movement based on wind direction and speed
//       double dx = particle.windSpeed * cos(particle.direction * pi / 180);
//       double dy = particle.windSpeed * sin(particle.direction * pi / 180);

//       // Update particle position
//       particle.position = Offset(
//         (particle.position.dx + dx * controller.value) % size.width,
//         (particle.position.dy + dy * controller.value) % size.height,
//       );

//       // Draw the particle
//       canvas.drawCircle(particle.position, 2, particlePaint);
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return true;  // Always repaint to animate particles
//   }
// }

// class WindParticle {
//   Offset position;
//   double windSpeed;
//   double direction;  // Angle in degrees

//   WindParticle({
//     required this.position,
//     required this.windSpeed,
//     required this.direction,
//   });
// }

// class WaveAnimationLayer extends StatefulWidget {
//   final List<Map<String, dynamic>> weatherData; // List of lat, lon, waveHeight data

//   WaveAnimationLayer({required this.weatherData});

//   @override
//   _WaveAnimationLayerState createState() => _WaveAnimationLayerState();
// }

// class _WaveAnimationLayerState extends State<WaveAnimationLayer> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: Duration(seconds: 2),
//     )..repeat(reverse: true);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _controller,
//       builder: (context, child) {
//         return LayoutBuilder(
//           builder: (context, constraints) {
//             return CustomPaint(
//               size: Size(constraints.maxWidth, constraints.maxHeight),
//               painter: WavePainter(widget.weatherData, _controller),
//             );
//           },
//         );
//       },
//     );
//   }
// }

// class WavePainter extends CustomPainter {
//   final List<Map<String, dynamic>> weatherData;
//   final Animation<double> animation;

//   WavePainter(this.weatherData, this.animation);

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 2
//       ..color = Colors.blueAccent.withOpacity(0.5);

//     for (var data in weatherData) {
//       double waveHeight = data['waveHeight'];
//       LatLng latLng = LatLng(data['lat'], data['lon']);
      
//       // Convert lat/lon to screen coordinates here
//       Offset position = Offset(
//         size.width * 0.5, // Placeholder for proper lat/lon conversion
//         size.height * 0.5, // Placeholder for proper lat/lon conversion
//       );

//       // Draw expanding and shrinking circle for wave height
//       double radius = waveHeight * 10 * animation.value;
//       canvas.drawCircle(position, radius, paint);
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return true;
//   }
// }
