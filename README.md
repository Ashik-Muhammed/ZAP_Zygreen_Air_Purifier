# Zygreen Air Purifier

A Flutter mobile app and ESP32 firmware to monitor and control the ZAP Zygreen Air Purifier.

This repository contains a Flutter app (Dart) and ESP32 firmware (C/C++) used to read air-quality sensors and display/control the purifier from a mobile device.

Features
- Real-time sensor readings (PM2.5, PM10, temperature, humidity, VOC — depending on connected sensors)
- Device status and control from the Flutter app
- Over-the-air (OTA) or serial firmware flashing (firmware tooling depends on chosen build system)

Repository layout
- /app or /flutter : Flutter mobile application (Dart)
- /firmware or /esp32 : ESP32 firmware (C/C++)
- /web : any static/HTML files used by the project

Prerequisites
- Flutter SDK (stable)
- Android Studio or Xcode (for mobile platform builds)
- ESP32 toolchain (ESP-IDF or PlatformIO / Arduino CLI) for building/flashing firmware
- A USB cable to program the ESP32

Quickstart - Flutter app
1. Clone the repo:

   git clone https://github.com/Ashik-Muhammed/ZAP_Zygreen_Air_Purifier.git
   cd ZAP_Zygreen_Air_Purifier

2. Open the Flutter project (usually in `app/` or root) and fetch dependencies:

   flutter pub get

3. Run on a connected device or emulator:

   flutter run

Quickstart - ESP32 firmware
- Locate the firmware folder (commonly `firmware/`, `esp32/`, or `embedded/`).
- Build and flash using your chosen toolchain. Examples:

  PlatformIO:
    pio run -e esp32dev -t upload

  ESP-IDF (example):
    idf.py build
    idf.py -p /dev/ttyUSB0 flash

Wiring and sensors
- Connect sensors per their datasheets. Typical sensors used for air quality projects include:
  - PMS5003 / PMS7003 (PM2.5 / PM10)
  - SHT3x or DHT22 (temperature / humidity)
  - VOC sensor (e.g. MQ-135 / CCS811)
- Power the sensors with the correct voltage (3.3V or 5V depending on sensor) and share common ground with the ESP32.
- Update pin assignments in the firmware source before building.

Configuration
- App configuration (BLE, Wi-Fi credentials, or MQTT) may be in a settings screen or in a config file. Replace placeholders with your network/credentials as needed.
- For OTA updates, enable and configure the OTA code in the firmware and point the app or the updater to the correct URL or service.

.


## Getting Started

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/Ashik-Muhammed/ZAP_Zygreen_Air_Purifier.git
   cd ZAP_Zygreen_Air_Purifier
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── constants/         # App constants and configurations
├── screens/           # App screens
│   ├── dashboard_screen.dart
│   └── splash_screen.dart
├── theme/             # App theming and styling
│   └── app_theme.dart
└── widgets/           # Reusable widgets
    ├── air_quality_chart.dart
    └── metric_card.dart
```

## Dependencies

- `fl_chart`: For beautiful and interactive charts
- `provider`: For state management
- `intl`: For date and number formatting
- `flutter_svg`: For rendering SVG assets

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgements

- Flutter team for the amazing framework
- fl_chart for the beautiful charting library
- All contributors who have helped improve this project
