import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // For time validation
import 'package:flutter_typeahead/flutter_typeahead.dart'; // For autocomplete search
import '../services/routing_service.dart'; // Assuming you have your RoutingService class
import 'route_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? sourceLatLng;
  LatLng? destinationLatLng;
  String sourceLocation = 'Select source';
  String destinationLocation = 'Select destination';
  List<LatLng> routePoints = [];
  LatLng? _selectedLocation;
  bool isLoading = false;
  bool selectingSource = true;
  Set<String> _recentSearches = {};
  // ignore: non_constant_identifier_names
  late double ship_speed=10;

  final TextEditingController _sourceLatitudeController =
      TextEditingController();
  final TextEditingController _sourceLongitudeController =
      TextEditingController();
  final TextEditingController _destinationLatitudeController =
      TextEditingController();
  final TextEditingController _destinationLongitudeController =
      TextEditingController();
  final TextEditingController _startTimeController =
      TextEditingController(text: '00:00');
  final TextEditingController _sourceSearchController = TextEditingController();
  final TextEditingController _destinationSearchController =
      TextEditingController();
  final TextEditingController _speed = TextEditingController(text:"10");

  // List of shipports for autocomplete search
  final List<Shipport> shipports = [
    Shipport('Port of Dubai', LatLng(25.276987, 55.296249)),
    Shipport('Port of Jebel Ali', LatLng(25.0164, 55.0464)),
    Shipport('Port of Mumbai', LatLng(19.0760, 72.8777)),
    Shipport('Port of Karachi', LatLng(24.8607, 67.0011)),
    Shipport('Port of Colombo', LatLng(6.9271, 79.8612)),
    Shipport('Port of Chennai', LatLng(13.0827, 80.2707)),
    Shipport('Port of Singapore', LatLng(1.2897, 103.8500)),
    Shipport('Port of Durban', LatLng(-29.8587, 31.0218)),
    Shipport('Port of Mombasa', LatLng(-4.0435, 39.6682)),
    Shipport('Port of Salalah', LatLng(17.0154, 54.0922)),
    Shipport('Port of Maputo', LatLng(-25.9654, 32.5884)),
    Shipport('Port of Dar es Salaam', LatLng(-6.7924, 39.2083)),
    Shipport('Port of Victoria', LatLng(-4.6167, 55.4500)),
    Shipport('Port of Djibouti', LatLng(11.8251, 42.5903)),
    Shipport('Port of Aden', LatLng(12.7857, 45.0160)),
    Shipport('Port of Berbera', LatLng(10.4419, 45.0154)),
    Shipport('Port of Tanjung Priok', LatLng(-6.1281, 106.8413)),
    Shipport('Port of Port Louis', LatLng(-20.1607, 57.5037)),
    Shipport('Port of Seychelles', LatLng(-4.6167, 55.4500)),
    Shipport('Port of Suez', LatLng(30.5852, 32.2652)),
    Shipport('Port of Suakin', LatLng(19.6233, 37.2333)),
    Shipport('Port of Kismayo', LatLng(-0.3566, 42.5455)),
    Shipport('Port of Jiwani', LatLng(25.0325, 61.3964)),
    Shipport('Port of Muscat', LatLng(23.6100, 58.5930)),
    Shipport('Port of Cochin', LatLng(9.9669, 76.2818)),
    Shipport('Port of Visakhapatnam', LatLng(17.6868, 83.2185)),
    Shipport('Port of Tuticorin', LatLng(8.7658, 78.1401)),
    Shipport('Port of Port Blair', LatLng(11.6234, 92.6565)),
    Shipport('Port of Banjul', LatLng(13.4543, -16.5790)),
    Shipport('Port of Monrovia', LatLng(6.3156, -10.8047)),
    Shipport('Port of Port Sudan', LatLng(19.6100, 37.2167)),
    Shipport('Port of Koper', LatLng(45.5464, 13.7300)),
    Shipport('Port of Tanga', LatLng(-6.0747, 39.1027)),
    Shipport('Port of Mohammedia', LatLng(33.7331, -7.3593)),
    Shipport('Port of La Réunion', LatLng(-20.8855, 55.4471)),
    Shipport('Port of Mayotte', LatLng(-12.8343, 45.1662)),
    Shipport('Port of Walvis Bay', LatLng(-22.9576, 14.5126)),
    Shipport('Port of Lamu', LatLng(-2.2790, 40.9046)),
    Shipport('Port of Malé', LatLng(4.1755, 73.5093)),
    Shipport('Port of Mombasa', LatLng(-4.0435, 39.6682)),
    Shipport('Port of Sir Bani Yas', LatLng(24.2983, 52.5056)),
    Shipport('Port of Port Said', LatLng(31.2592, 32.3058)),
    Shipport('Port of Al Hudaydah', LatLng(14.7974, 42.9576)),
    Shipport('Port of Jeddah', LatLng(21.5433, 39.1728)),
    Shipport('Port of Salalah', LatLng(17.0154, 54.0922)),
    Shipport('Port of Bandar Abbas', LatLng(27.1833, 56.2667)),
    Shipport('Port of Chittagong', LatLng(22.3384, 91.8318)),
    Shipport('Port of Kuantan', LatLng(3.8094, 103.3396)),
    Shipport('Port of Batam', LatLng(1.1008, 104.0734)),
    Shipport('Port of Tanjung Balai Karimun', LatLng(0.9072, 103.3825)),
    Shipport('Port of Ternate', LatLng(0.7902, 127.3620)),
    Shipport('Port of Pangkalan Bun', LatLng(-2.7200, 111.6161)),
    // Add more shipports here...
  ];

  // Fetch route coordinates between source and destination
  Future<void> fetchRoute() async {
    if (sourceLatLng == null || destinationLatLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Both source and destination must be selected')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Fetch intermediate points from FastAPI
      final intermediatePoints = await RoutingService()
          .getIntermediatePoints(sourceLatLng!, destinationLatLng!);

      print('intermed ${intermediatePoints}');

      // Combine the points into routePoints
      setState(() {
        routePoints = [
          sourceLatLng!,
          ...intermediatePoints,
          destinationLatLng!
        ];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch route: $e')),
      );
    }
  }

  // Fetch location name using reverse geocoding
  Future<void> fetchLocationName(LatLng latLng, bool isSource) async {
    final url =
        'https://nominatim.openstreetmap.org/reverse?lat=${latLng.latitude}&lon=${latLng.longitude}&format=json';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'];
        final locationName =
            '${address['ocean'] ?? ''}, ${address['city'] ?? ''}';

        setState(() {
          if (isSource) {
            sourceLocation = locationName.isNotEmpty
                ? locationName
                : '${latLng.latitude}, ${latLng.longitude}';
            _sourceLatitudeController.text = '${latLng.latitude}';
            _sourceLongitudeController.text = '${latLng.longitude}';
          } else {
            destinationLocation = locationName.isNotEmpty
                ? locationName
                : '${latLng.latitude}, ${latLng.longitude}';
            _destinationLatitudeController.text = '${latLng.latitude}';
            _destinationLongitudeController.text = '${latLng.longitude}';
          }
        });
      } else {
        throw Exception('Failed to load location name');
      }
    } catch (e) {
      setState(() {
        if (isSource) {
          _sourceLatitudeController.text = '${latLng.latitude}';
          _sourceLongitudeController.text = '${latLng.longitude}';
        } else {
          _destinationLatitudeController.text = '${latLng.latitude}';
          _destinationLongitudeController.text = '${latLng.longitude}';
        }
      });
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Error fetching location name: $e')),
      // );
    }
  }

  // Validate if the time input is in correct format
  bool _isValidTime(String time) {
    try {
      final format = DateFormat('HH:mm'); // Expect 24-hour format
      format.parseStrict(time);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Handle map tap to select source or destination
  void _onMapTap(TapPosition tapPosition, LatLng latLng) async {
    setState(() async {
      if (selectingSource) {
        sourceLatLng = latLng;
        fetchLocationName(latLng, true);
      } else {
        destinationLatLng = latLng;
        fetchLocationName(latLng, false);
      }

      selectingSource = !selectingSource;
      double? speed = double.tryParse(_speed.text);
      ship_speed = speed!;
      // Fetch route once both source and destination are selected
      if (sourceLatLng != null && destinationLatLng != null) {
        final c = await fetchRoute();
      }
    });
  }

  // Validate and submit form data
  void _validateAndSubmit() {
    final startTime = _startTimeController.text;
    //final departureTime = _departureTimeController.text;

    // Validate time format
    if (!_isValidTime(startTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid start time format')),
      );
      return;
    }

    // if (!_isValidTime(departureTime)) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Invalid departure time format')),
    //   );
    //   return;
    // }

    double? sourceLat = double.tryParse(_sourceLatitudeController.text);
    double? sourceLng = double.tryParse(_sourceLongitudeController.text);
    double? destLat = double.tryParse(_destinationLatitudeController.text);
    double? destLng = double.tryParse(_destinationLongitudeController.text);
    double? speed = double.tryParse(_speed.text);
    if (sourceLat != null && sourceLng != null) {
      sourceLatLng = LatLng(sourceLat, sourceLng);
    }

    if (destLat != null && destLng != null) {
      destinationLatLng = LatLng(destLat, destLng);
    }

    if (sourceLatLng == null || destinationLatLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Source and destination locations must be set')),
      );
      ship_speed = speed!;
      return;
    }

    // Print details
    print('Source: $sourceLatLng, LatLng: $sourceLat');
    print('Destination: $destinationLatLng, LatLng: $destLat');
    print('Start Time: $startTime');
    //print('Departure Time: $departureTime');

    // Navigate to another screen to display route, distance, and path
    if (routePoints.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RouteScreen(
            startPoint: sourceLatLng!,
            endPoint: destinationLatLng!,
            intermediatePoints:
                routePoints, // Pass the route points to the next screen
          ),
        ),
      );
    } else {
      print('not');
    }
  }

  List<String> _getSuggestions(String query) {
    // Get shipport suggestions that match the query
    final shipportSuggestions = shipports
        .where((shipport) =>
            shipport.name.toLowerCase().contains(query.toLowerCase()))
        .map((shipport) => shipport.name)
        .toList();

    // Get recent searches that match the query
    final recentSuggestions = _recentSearches
        .where((search) => search.toLowerCase().contains(query.toLowerCase()))
        .toList();

    // Combine both lists and take up to 4 suggestions from each
    final suggestions = <String>[]
      ..addAll(recentSuggestions.take(1))
      ..addAll(shipportSuggestions.take(4));

    return suggestions;
  }

  void _onSourceSearch(String query) {
    final selectedShipport = shipports.firstWhere(
      (shipport) => shipport.name == query,
      orElse: () => Shipport('', LatLng(0, 0)),
    );

    if (selectedShipport.name.isNotEmpty) {
      setState(() {
        sourceLatLng = selectedShipport.location;
        _sourceLatitudeController.text =
            '${selectedShipport.location.latitude}';
        _sourceLongitudeController.text =
            '${selectedShipport.location.longitude}';
        sourceLocation = selectedShipport.name;

        // Set the search box text to the selected suggestion
        _sourceSearchController.text = selectedShipport.name;

        // Add to recent searches
        _recentSearches.add(sourceLocation);

        // Update map and fetch route if destination is also set
        if (destinationLatLng != null) {
          fetchRoute();
        }
      });
    }
  }

  void _onDestinationSearch(String query) {
    final selectedShipport = shipports.firstWhere(
      (shipport) => shipport.name == query,
      orElse: () => Shipport('', LatLng(0, 0)),
    );

    if (selectedShipport.name.isNotEmpty) {
      setState(() {
        destinationLatLng = selectedShipport.location;
        _destinationLatitudeController.text =
            '${selectedShipport.location.latitude}';
        _destinationLongitudeController.text =
            '${selectedShipport.location.longitude}';
        destinationLocation = selectedShipport.name;

        // Set the search box text to the selected suggestion
        _destinationSearchController.text = selectedShipport.name;

        // Add to recent searches
        _recentSearches.add(destinationLocation);

        // Update map and fetch route if source is also set
        if (sourceLatLng != null) {
          fetchRoute();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Screen'),
      ),
      body: Column(
        children: [
          // Custom AppBar using Row
          Container(
            color: Colors.blue, // Background color of the custom app bar
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.01,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Map Screen',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // IconButton(
                //   icon: const Icon(Icons.menu, color: Colors.white),
                //   onPressed: () {
                //     // Action for the menu button or any other action you want to add
                //   },
                // ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.01,
            ),
            child: Column(
              children: [
                TypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: _sourceSearchController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      labelText: 'Search Source Shipport',
                      prefixIcon: Icon(Icons.search, color: Colors.blue),
                    ),
                  ),
                  suggestionsCallback: _getSuggestions,
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion),
                      leading: Icon(Icons.location_on, color: Colors.blue),
                    );
                  },
                  onSuggestionSelected: _onSourceSearch,
                ),
                SizedBox(height: screenHeight * 0.02),
                TypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: _destinationSearchController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      labelText: 'Search Destination Shipport',
                      prefixIcon: Icon(Icons.search, color: Colors.blue),
                    ),
                  ),
                  suggestionsCallback: _getSuggestions,
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion),
                      leading: Icon(Icons.location_on, color: Colors.blue),
                    );
                  },
                  onSuggestionSelected: _onDestinationSearch,
                ),
                SizedBox(height: screenHeight * 0.02),
                // Input fields for Source Latitude and Longitude
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _sourceLatitudeController,
                        decoration: const InputDecoration(
                          labelText: 'Source Latitude',
                        ),
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.02),
                    Expanded(
                      child: TextField(
                        controller: _sourceLongitudeController,
                        decoration: const InputDecoration(
                          labelText: 'Source Longitude',
                        ),
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
                // Input fields for Destination Latitude and Longitude
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _destinationLatitudeController,
                        decoration: const InputDecoration(
                          labelText: 'Destination Latitude',
                        ),
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.02),
                    Expanded(
                      child: TextField(
                        controller: _destinationLongitudeController,
                        decoration: const InputDecoration(
                          labelText: 'Destination Longitude',
                        ),
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
                // Input field for Start Time
                TextField(
                  controller: _startTimeController,
                  decoration:
                      const InputDecoration(labelText: 'Start Time (HH:mm)'),
                ),
                TextField(
                  controller: _speed,
                  decoration: const InputDecoration(labelText: 'ShipSpeed'),
                ),
                SizedBox(height: screenHeight * 0.02),
                ElevatedButton(
                  onPressed: isLoading ? null : _validateAndSubmit,
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                center: LatLng(
                    19.323850045434238, 78.81635086496908), // Example center
                zoom: 4,
                onTap: _onMapTap,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                // Show the selected source and destination markers

                if (sourceLatLng != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 80.0,
                        height: 80.0,
                        point: sourceLatLng!,
                        builder: (ctx) => Column(
                          children: [
                            const Text(
                              'Start',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            const Icon(Icons.location_on, color: Colors.blue),
                          ],
                        ),
                      ),
                    ],
                  ),
                if (destinationLatLng != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 80.0,
                        height: 80.0,
                        point: destinationLatLng!,
                        builder: (ctx) => Column(
                          children: [
                            const Text(
                              'End',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            const Icon(Icons.location_on, color: Colors.red),
                          ],
                        ),
                      ),
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
          ),
          if (isLoading) const CircularProgressIndicator(),
        ],
      ),
    );
  }
}

class Shipport {
  final String name;
  final LatLng location;

  Shipport(this.name, this.location);
}
