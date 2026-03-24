import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherProvider extends ChangeNotifier {
  bool isLoading = true;
  String city = '';
  double temperature = 0;
  String condition = '';

  Future<void> fetchWeather() async {
    isLoading = true;
    notifyListeners();

    try {
      Position? position = await Geolocator.getLastKnownPosition();
      position ??= await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 3),
      );

      // Fetch city
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      city = placemarks.first.locality ?? "Unknown";

      // Fetch weather
      const apiKey =
          'f114b12c10e3befce8b8bf13ade7eeee'; // Replace with your OpenWeatherMap API Key
      final url =
          'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&units=metric&appid=$apiKey';
      final response = await http.get(Uri.parse(url));
      print('weather ${response.statusCode}');
      print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        temperature = data['main']['temp'];
        condition = data['weather'][0]['main']; // Clear, Clouds, Rain, etc.
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      print("Weather fetch error: $e");
    }

    isLoading = false;
    notifyListeners();
  }
}
