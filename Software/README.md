# Campus Companion 🎓📍

**Campus Companion** is a smart navigation and utility application designed to help students, faculty, and visitors navigate the university campus with ease. Built with **Flutter**, it features a robust GPS navigation system, real-time location tracking, and a searchable directory of campus buildings.

## 🚀 Features

*   **📍 Advanced GPS Navigation**:
    *   **Road-Following Paths**: Uses OSRM to draw accurate walking paths on the campus roads (not just straight lines!).
    *   **Google Maps Integration**: High-quality map visualization.
    *   **Web Support**: Custom fallback routing system to ensure navigation works smoothly on web browsers despite CORS restrictions.
*   **🏃 Live Location Tracking**:
    *   **High Accuracy Mode**: Utilizes hardware GPS for precise real-time positioning.
    *   **Visual Feedback**: Distinct blue marker with an accuracy circle to show your exact location.
*   **🧪 Simulation Mode**:
    *   **Teleport Feature**: Instantly simulate your location at the "Admin Block" to test navigation features without being physically on campus.
*   **🏢 Building Directory**:
    *   **Searchable List**: Quickly find any department, hostel, or facility.
    *   **Building Details**: View details and start navigation with a single tap.
*   **📱 Cross-Platform**: Runs seamlessly on **Android**, **iOS**, and **Web**.

## 🛠️ Tech Stack

*   **Framework**: [Flutter](https://flutter.dev/) (Dart)
*   **Maps**: `google_maps_flutter`
*   **Location**: `geolocator`
*   **Routing**: Google Directions API + OSRM (Open Source Routing Machine)
*   **State Management**: `Provider` / `setState`
*   **Backend**: Firebase (Auth, Firestore)

## 📸 Screenshots

| Map View | Navigation | Building Details |
|----------|------------|------------------|
| *(Add screenshot here)* | *(Add screenshot here)* | *(Add screenshot here)* |

## 🏁 Getting Started

### Prerequisites

*   [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
*   Android Studio / VS Code.
*   Google Maps API Key (configured in `android/app/src/main/AndroidManifest.xml` and `web/index.html`).

### Installation

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/your-username/campus-companion.git
    cd campus-companion
    ```

2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Run the app**:
    *   **Android**:
        ```bash
        flutter run
        ```
    *   **Web**:
        ```bash
        flutter run -d chrome
        ```

## 📱 Building APK (Android)

To generate a release APK for installation on Android devices:

```bash
flutter build apk --release
```

The APK will be located at: `build/app/outputs/flutter-apk/app-release.apk`

## 🤝 Contributing

Contributions are welcome! Please fork the repository and submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
