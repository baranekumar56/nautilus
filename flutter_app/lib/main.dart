
import 'package:flutter/material.dart';
import 'package:oc_dir/screens/test3.dart';
import 'package:oc_dir/screens/verfication_screen.dart';
import 'package:oc_dir/screens/windyapai.dart';
import 'screens/ship_detail.dart';
import 'screens/map_screen.dart';
import 'screens/route_screen.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
void main() {
  runApp(MyApp());
}

// ignore: use_key_in_widget_constructors
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OceanMap',
      theme: ThemeData(
    textTheme: GoogleFonts.poppinsTextTheme(), // Modern Font
    primarySwatch: Colors.blue,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  ),
      home: MapScreen(),
    );
  }
}
