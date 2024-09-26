

# Ship Routing Application

This Flutter-based ship routing application calculates optimal paths between source and destination locations using the **A* algorithm**. It supports both mobile and web platforms, offering real-time weather integration and an intuitive user experience for selecting routes. The app helps optimize ship routes for factors such as travel time, safety, and weather conditions.

---

## Features

- **A* Algorithm-Based Ship Routing**  
  Calculates the optimal route between source and destination with time, distance, and weather considerations using the A* algorithm for efficient pathfinding.

- **Cross-Platform Support**  
  Available for both **Android** and **iOS** through Flutter, as well as web-based access for desktop users, providing a seamless multi-platform experience.

- **Interactive Map and Manual Input**  
  Users can select source and destination by:
  - Manually entering latitude and longitude.
  - Interactively choosing locations via the map interface.

- **Real-Time Route Visualization**  
  Displays the calculated route with **real-time updates** for distance and travel time, ensuring that users have an accurate overview of their trip.

- **Weather Data and Heatmap Visualization**  
  Visualizes **live wind and wave data** with a dynamic heatmap, showing the impact of weather conditions on the chosen route. This allows for safer and more informed route planning.

- **Search Functionality**  
  An interactive search experience, similar to Google Maps, allows users to easily find and select ports, harbors, and marinas with autocomplete suggestions and recent search history.

---

## Installation

### Prerequisites

- **Flutter SDK**: [Install Flutter](https://flutter.dev/docs/get-started/install) for your development platform.
- **Dart SDK**: Ensure Dart is installed as part of the Flutter SDK.
- **Android Studio / Xcode**: For Android and iOS development.
- **Web Browser**: For web development, use Chrome or another modern browser.

### Steps to Install

1. **Clone the Repository**  
   Clone this repository to your local machine:
   ```bash
   git clone https://github.com/your-repo/ship-routing-app.git
   cd ship-routing-app
   ```

2. **Install Dependencies**  
   Navigate to the project folder and run the following command to install the necessary packages:
   ```bash
   flutter pub get
   ```

3. **Run the Application**  
   - For mobile (Android/iOS):
     ```bash
     flutter run
     ```
   - For web:
     ```bash
     flutter run -d chrome
     ```

4. **Build the Application**  
   - For Android:
     ```bash
     flutter build apk
     ```
   - For iOS:
     ```bash
     flutter build ios
     ```
   - For web:
     ```bash
     flutter build web
     ```

### Troubleshooting

- Ensure you have connected physical devices or emulators for Android/iOS testing.
- If the app fails to run, ensure your Flutter and Dart SDKs are up to date by running:
   ```bash
   flutter upgrade
   ```

---

## Project Structure

- **lib/**: Contains the main application code.
- **assets/**: Stores static assets such as icons and images.
- **pubspec.yaml**: Lists dependencies for the project.

---

## Contributing

Contributions are welcome! If you encounter any issues or have feature requests, feel free to open an issue or submit a pull request.

---

## License

This project is licensed under the MIT License – see the [LICENSE](LICENSE) file for details.

---

By following these steps, you’ll be able to install and run the ship routing application locally on your preferred platform.
