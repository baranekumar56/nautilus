import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; 
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter/animation.dart';

class Shipport {
  final String name;
  final LatLng location;

  Shipport(this.name, this.location);
}

// Extension outside the State class
extension LatLngBoundsExtension on LatLngBounds {
  LatLngBounds expandBy(double margin) {
    return LatLngBounds(
      LatLng(southWest.latitude - margin, southWest.longitude - margin),
      LatLng(northEast.latitude + margin, northEast.longitude + margin),
    );
  }
}

class RouteScreen extends StatefulWidget {
  final LatLng startPoint;
  final LatLng endPoint;
  final List<LatLng> intermediatePoints;

  const RouteScreen({
    Key? key,
    required this.startPoint,
    required this.endPoint,
    required this.intermediatePoints,
  }) : super(key: key);

  @override
  _WeatherRouteScreenState createState() => _WeatherRouteScreenState();
}

class _WeatherRouteScreenState extends State<RouteScreen>
    with SingleTickerProviderStateMixin {
   late  MapController _mapController; 

  double _currentZoom = 4.0;
  LatLng? _selectedLocation;
  final List<LatLng> _heatmapPoints = [];
  final List<Color> _heatmapColors = [];
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _recentSearches = {};
  final List<Shipport> shipports = [
    Shipport('Port of Los Angeles', LatLng(33.7331, -118.2610)),
    Shipport('Port of Singapore', LatLng(1.2897, 103.8500)),
    Shipport('Port of Shanghai', LatLng(31.2304, 121.4737)),
    // Add other shipports...
  ];

  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    // Animation setup
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _opacityAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    // _fetchWeatherData();
  }

  LatLngBounds _calculateBounds() {
    final List<LatLng> routePoints = [
      widget.startPoint,
      ...widget.intermediatePoints,
      widget.endPoint
    ];
    final bounds = LatLngBounds.fromPoints(routePoints);
    return bounds
        .expandBy(0.1); // Expand bounds to include the surrounding area
  }

  void _processWeatherData(LatLng point, double? waveHeight) {
    Color color = Colors.grey; // Default color for missing data

    if (waveHeight != null) {
      if (waveHeight > 6.0) {
        color = Colors.red; // High intensity
      } else if (waveHeight > 3.0) {
        color = Colors.orange; // Medium intensity
      } else {
        color = Colors.green; // Low intensity
      }
    }

    setState(() {
      _heatmapPoints.add(point);
      _heatmapColors.add(color);
    });
  }

  double? _extractWaveHeight(Map<String, dynamic> data) {
    try {
      // Navigate through the JSON data structure to get wave height
      final List<dynamic> values = data['data']['Thgt']['values'];
      if (values.isNotEmpty) {
        return values[0].toDouble(); // or appropriate extraction logic
      } else {
        return null; // No data available
      }
    } catch (e) {
      print('Error extracting wave height: $e');
      return null;
    }
  }

  int _latToIndex(double lat) {
    // Example conversion logic, assuming latitude range [-90, 90]
    // and dataset indices [0, 310]
    int index = ((lat + 90) * (310 / 180)).round();
    return index.clamp(0, 310); // Ensure index is within valid range
  }

// Convert longitude to grid index (adjusted for valid range)
  int _lngToIndex(double lng) {
    // Example conversion logic, assuming longitude range [-180, 180]
    // and dataset indices [0, 719]
    int index = ((lng + 180) * (719 / 360)).round();
    return index.clamp(0, 719); // Ensure index is within valid range
  }

  Future<void> _fetchWeatherData() async {
    final LatLngBounds bounds = _calculateBounds();
    final double latStep = 0.5; // Adjust based on required granularity
    final double lngStep = 0.5;
    int f = 0;
    for (double lat = bounds.southWest.latitude;
        lat <= bounds.northEast.latitude;
        lat += latStep) {
      for (double lng = bounds.southWest.longitude;
          lng <= bounds.northEast.longitude;
          lng += lngStep) {
        // Round latitude and longitude to nearest decimals if needed
        final int latIndex = _latToIndex(lat);
        final int lngIndex = _lngToIndex(lng);
        // NOAA ERDDAP API URL for wave height (Thgt)
        final url =
            'https://upwell.pfeg.noaa.gov/erddap/griddap/NWW3_Global_Best.json?Thgt%5B(2024-09-09T18:00:00Z):1:(2024-09-09T18:00:00Z)%5D%5B(0.0):1:(0.0)%5D%5B${latIndex}:${latIndex}%5D%5B${lngIndex}:${lngIndex}%5D';

        try {
          final response = await http.get(Uri.parse(url));
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            print('Data received for $lat, $lng: $data'); // Log the response

            // Extract wave height and process data
            final waveHeight = _extractWaveHeight(data);
            _processWeatherData(LatLng(lat, lng), waveHeight);
          } else {
            print(
                'Failed to fetch data for $lat, $lng: ${response.statusCode}');
            f = 1;
            break;
          }
        } catch (e) {
          print('Error fetching data for $lat, $lng: $e');
        }
      }
      if (f == 1) break;
    }
    setState(() {});
  }

  List<String> _getSuggestions(String query) {
    final recentSuggestions = _recentSearches
        .where((search) => search.toLowerCase().contains(query.toLowerCase()))
        .toList();
    final shipportSuggestions = shipports
        .where((shipport) =>
            shipport.name.toLowerCase().contains(query.toLowerCase()))
        .map((shipport) => shipport.name)
        .toList();

    return [...recentSuggestions.take(4), ...shipportSuggestions.take(4)];
  }

  Future<void> _onSearch(String query) async {
    final selectedShipport = shipports.firstWhere(
      (shipport) => shipport.name == query,
      orElse: () => Shipport('', LatLng(0, 0)),
    );

    if (selectedShipport.name.isNotEmpty) {
      LatLng newLocation = selectedShipport.location;
      _mapController.move(newLocation, _currentZoom);
      setState(() {
        _selectedLocation = newLocation;
        _recentSearches.remove(query);
        _recentSearches.add(query);
        if (_recentSearches.length > 4) {
          _recentSearches.remove(_recentSearches.first);
        }
        _searchController.text = query;
      });
    } else {
      _showNoResultsMessage();
    }
  }

  void _showNoResultsMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No shipport found for the given name.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<LatLng> routePoints = [
      widget.startPoint,
      ...widget.intermediatePoints,
      widget.endPoint
    ];
    final Color primaryColor = Colors.blueAccent;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ocean Route',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: routePoints.isNotEmpty ? routePoints[0] : LatLng(0, 0),
              zoom: _currentZoom,
              minZoom: 1.0,
              maxZoom: 18.0,
              interactiveFlags: InteractiveFlag.all,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
              ),
              if (routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      strokeWidth: 4.0,
                      color: primaryColor,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point: widget.startPoint,
                    builder: (ctx) => AnimatedBuilder(
                      animation: _opacityAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _opacityAnimation.value,
                          child: const Icon(Icons.location_on,
                              color: Colors.green, size: 40),
                        );
                      },
                    ),
                  ),
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point: widget.endPoint,
                    builder: (ctx) => AnimatedBuilder(
                      animation: _opacityAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _opacityAnimation.value,
                          child: const Icon(Icons.location_on,
                              color: Colors.red, size: 40),
                        );
                      },
                    ),
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  // Generate markers from _heatmapPoints and _heatmapColors
                  ...List.generate(_heatmapPoints.length, (index) {
                    final point = _heatmapPoints[index];
                    final color = _heatmapColors[index];
                    return Marker(
                      width: 80.0,
                      height: 80.0,
                      point: point,
                      builder: (ctx) => Icon(Icons.circle, color: color),
                    );
                  }),
                  // Add marker for _selectedLocation if it's not null
                  if (_selectedLocation != null)
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: _selectedLocation!,
                      builder: (ctx) => const Icon(Icons.search,
                          color: Colors.blue, size: 40),
                    ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TypeAheadField(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search shipports',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                suggestionsCallback: (query) async {
                  return _getSuggestions(query);
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    title: Text(suggestion),
                  );
                },
                onSuggestionSelected: (suggestion) {
                  _onSearch(suggestion);
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'zoom_in',
            onPressed: () {
              setState(() {
                _currentZoom++;
                _mapController.move(_mapController.center, _currentZoom);
              });
            },
            child: const Icon(Icons.zoom_in),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'zoom_out',
            onPressed: () {
              setState(() {
                _currentZoom--;
                _mapController.move(_mapController.center, _currentZoom);
              });
            },
            child: const Icon(Icons.zoom_out),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
     _mapController.dispose();  
  }
}


