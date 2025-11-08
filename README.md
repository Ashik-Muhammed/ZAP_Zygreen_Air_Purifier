# Zygreen Air Purifier App

A modern Flutter application for monitoring and controlling your Zygreen Air Purifier. The app provides real-time air quality metrics, historical data visualization, and smart recommendations for maintaining optimal indoor air quality.

## Features

- **Real-time Air Quality Monitoring**: Track PM2.5, PM10, temperature, and humidity levels
- **Interactive Charts**: Visualize air quality trends with beautiful, responsive charts
- **Smart Recommendations**: Get personalized tips for improving your indoor air quality
- **Modern UI**: Clean, intuitive interface with a beautiful color scheme and smooth animations
- **Responsive Design**: Works on both mobile and tablet devices

## Screenshots

[Add screenshots here]

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Android Studio / Xcode (for running on emulator/device)
- VS Code or Android Studio (recommended for development)

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
