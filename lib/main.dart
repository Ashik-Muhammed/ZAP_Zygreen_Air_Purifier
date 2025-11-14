import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:zygreen_air_purifier/providers/esp32_provider.dart';
import 'package:zygreen_air_purifier/providers/sensor_provider.dart';
import 'package:zygreen_air_purifier/providers/air_quality_provider.dart';
import 'package:zygreen_air_purifier/screens/splash_screen.dart';
import 'package:zygreen_air_purifier/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        name: 'ZygreenAirPurifier',
        options: const FirebaseOptions(
          apiKey: "AIzaSyCU5jQjKRHRni2rqrTjhQY7ZNW91OkcH_s",
          appId: "1:501260037462:web:2cc0d81dd61664c7a23af7",
          messagingSenderId: "501260037462",
          projectId: "zygreeen",
          storageBucket: "zygreeen.firebasestorage.app",
          authDomain: "zygreeen.firebaseapp.com",
          databaseURL: "https://zygreeen-default-rtdb.asia-southeast1.firebasedatabase.app",
          measurementId: "G-DCRFKL21Y4",
        ),
      );
    }
    
    // Create providers
    final esp32Provider = ESP32Provider();
    final sensorProvider = SensorProvider();
    final airQualityProvider = AirQualityProvider();
    
    try {
      // Initialize air quality provider first
      await airQualityProvider.init();
      
      // Check if we have a saved connection and try to reconnect
      if (esp32Provider.connectedDeviceId != null) {
        try {
          await esp32Provider.connectToDevice(esp32Provider.connectedDeviceId!);
          if (esp32Provider.isConnected) {
            // Initialize sensor data if connected
            await sensorProvider.initSensorData();
          }
        } catch (e) {
          debugPrint('Error reconnecting to device: $e');
        }
      }
    } catch (e) {
      debugPrint('Error initializing AirQualityProvider: $e');
      // Continue running the app even if air quality data fails to load
    }
    
    // Run the app with providers
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AirQualityProvider>.value(value: airQualityProvider),
          ChangeNotifierProvider.value(value: esp32Provider),
          ChangeNotifierProvider.value(value: sensorProvider),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e) {
    debugPrint('Error initializing app: $e');
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              'Error initializing app. Please restart the application.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zygreen Air Purifier',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
