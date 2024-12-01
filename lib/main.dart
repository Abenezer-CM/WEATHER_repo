import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weatherapp/providers/theme_provider.dart';
import 'package:weatherapp/screens/weather_screen.dart';
import 'package:provider/provider.dart';

void main() {
  // Ensure that the Flutter engine is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Lock the app to portrait mode
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(ChangeNotifierProvider(
        create: (BuildContext context) => ThemeProvider(),
        child: const MyApp()));
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: (themeProvider.isDarkMode)
          ? ThemeData.dark(useMaterial3: true)
          : ThemeData.light(useMaterial3: true),
      home: const WeatherScreen(),
    );
  }
}
