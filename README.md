


# Nautilus

This project provides a ship routing solution between a source and destination location using the A* algorithm. The project consists of both a **web application** and a **Flutter mobile application** that allow users to enter the source and destination locations (using latitude and longitude), and the optimal route between the two points is calculated and displayed.

The routing system incorporates a* algorithm for optimal pathfinding between ports, harbors, and marinas, and uses mapping features for route visualization.

## Table of Contents
- [Features](#features)
- [Installation](#installation)
  - [Web Application](#web-application)
  - [Flutter Mobile Application](#flutter-mobile-application)
- [Usage](#usage)
- [Technologies](#technologies)
- [Contributing](#contributing)
- [License](#license)

## Features
- A Algorithm-Based Ship Routing*: Efficiently calculates the optimal path between a source and destination, ensuring a balance between time, safety, and route efficiency. The A* algorithm is designed to find the shortest and safest path based on dynamic data such as wind and waves.

- Cross-Platform Support: The application is available on both web and mobile platforms, allowing users to access ship routing functionalities seamlessly across devices.

- Real-Time Route Visualization: Displays the optimal route on a detailed map with real-time distance and time estimations, giving users an accurate overview of the journey.

- Flexible Location Input: Users can either manually enter latitude and longitude coordinates or interactively select locations on a map, giving them flexibility in how they plan their route.

- Weather-Integrated Visualization: Integrates live wind and wave data using heatmap animations, providing users with an intuitive understanding of weather conditions along the route. This helps in making safer routing decisions, factoring in real-time maritime weather forecasts.

- Advanced Search Functionality: Offers an interactive search experience similar to Google Maps, optimized for maritime routes. Users can easily search for ports, harbors, and marinas, with recent searches and autocomplete suggestions to simplify the process of selecting a start or destination.

These features are designed to make ship routing more efficient, user-friendly, and safer by integrating real-time data and modern mapping technologies.

## Installation

### Web Application

#### Prerequisites
- Python 3.8+
- Flask (or another Python web framework)


#### Steps
1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/nautilus.git
   cd ShipRouting/flsk.py
   ```

2. Install the dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Run the Flask server:
   ```bash
   python app.py
   ```

4. Open the web application in your browser at:
   ```bash
   http://localhost:5000
   ```


### Flutter Mobile Application

#### Prerequisites
- Flutter SDK
- Android Studio (for Android)
- Xcode (for iOS)

#### Steps
1. Clone the repository:
   ```bash
   git clone [https://github.com/your-username/nautilus.git]
   cd route_application/flutterapp
   ```

2. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

3. Connect a device or start an emulator and run the Flutter app:
   ```bash
   flutter run
   ```

4. For Android:
   - Make sure you have the Android SDK installed.
   - Run the app on a connected device or emulator.

5. For iOS:
   - Open the project in Xcode.
   - Ensure that all the provisioning profiles and certificates are set correctly.
   - Run the app on a connected device or simulator.

## Usage

### Web Application
1. Open the web application.
2. Enter the source and destination (either by entering latitude and longitude or by selecting locations on the map).
3. Click the **get voyage** button to calculate the optimal ship route.
4. The path will be displayed on the map with relevant distance and time information.

### Flutter Application
1. Launch the mobile app.
2. Enter the source and destination coordinates or select locations via map.
3. Tap **get voyage** to find and visualize the optimal route.
4. The map will show the path along with route information.

## Technologies

- **Backend**: Flask (Python)
- **Frontend**: HTML, CSS, JavaScript
- **Mobile**: Flutter
- **Routing Algorithm**: 3D A* Algorithm,Isochrone,dijkstra algorithm 
- **Mapping**: OpenStreetMap
- **Wave Data**: https://coastwatch.pfeg.noaa.gov/erddap/griddap/NWW3_Global_Best.html

## Contributing

1. Fork the repository.
2. Create a feature branch (`git checkout -b feature-name`).
3. Commit your changes (`git commit -m 'Add some feature'`).
4. Push to the branch (`git push origin feature-name`).
5. Open a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Authors

- [@baranekumar56](https://github.com/baranekumar56)
- [@pojith](https://www.github.com/pojith)
- [@sithaarth24](https://github.com/sithaarth24)
- [@sakthissb](https://github.com/sakthissb)

---
