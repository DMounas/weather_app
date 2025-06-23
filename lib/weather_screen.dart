// weather_screen.dart

import 'dart:convert';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:weather_app/additional_info_item.dart';
import 'package:weather_app/hourly_forecast_item.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/secrets.dart';

IconData getWeatherIcon(String weatherCondition) {
  switch (weatherCondition.toLowerCase()) {
    case 'clouds':
      return Icons.cloud;
    case 'rain':
    case 'drizzle':
      return Icons.water_drop_outlined;
    case 'thunderstorm':
      return Icons.thunderstorm;
    case 'snow':
      return Icons.ac_unit;
    case 'clear':
      return Icons.wb_sunny;
    case 'haze':
    case 'mist':
    case 'fog':
      return Icons.foggy;
    default:
      return Icons.wb_sunny; // A sensible default
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather;

  // --- CHANGE #1: Add state for city name and a controller for the TextField ---
  final TextEditingController _cityController = TextEditingController();
  String _cityName = 'Guwahati'; // Default city

  // --- CHANGE #2: Modify the function to accept city and fetch in Celsius ---
  Future<Map<String, dynamic>> getCurrentWeather(String cityName) async {
    try {
      final res = await http.get(
        Uri.parse(
          // Added "&units=metric" to get temperature in Celsius
          "https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherAPIKey&units=metric",
        ),
      );

      final data = json.decode(res.body);

      if (data['cod'] != '200') {
        // Use the error message from the API if available
        throw data['message'] ?? 'An unexpected error occurred';
      }

      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  void _fetchWeather() {
    setState(() {
      weather = getCurrentWeather(_cityName);
    });
  }

  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather(_cityName);
  }

  // --- CHANGE #3: Add a dialog to get user input ---
  void _showCitySearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter City Name'),
          content: TextField(
            controller: _cityController,
            decoration: const InputDecoration(hintText: "e.g., Delhi"),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_cityController.text.isNotEmpty) {
                  setState(() {
                    _cityName = _cityController.text;
                  });
                  _fetchWeather();
                  _cityController.clear();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // The title is now removed to make space for the location name below
        title: const Text(
          'Weather App',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          // --- CHANGE #4: Add a search button ---
          IconButton(
            onPressed: _showCitySearchDialog,
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: _fetchWeather, // Refresh button now uses the helper
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder(
        future: weather,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final data = snapshot.data!;
          // --- CHANGE #5: Extract the location name ---
          final currentCityName = data['city']['name'];
          final currentTemp = data['list'][0]['main']['temp'];
          final currentSky = data['list'][0]['weather'][0]['main'];
          final currentHumidity = data['list'][0]['main']['humidity'];
          final currentWindSpeed = data['list'][0]['wind']['speed'];
          // OpenWeatherMap might not always provide rain data, so we handle null safely
          final currentPrecipitation = data['list'][0]['rain']?['3h'] ?? 0;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Main Card
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                // --- CHANGE #6: Display location and temperature in Celsius ---
                                Text(
                                  currentCityName,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '${currentTemp.round()}°C', // Rounded and with Celsius symbol
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Icon(
  getWeatherIcon(currentSky),
  size: 64,
),
                                const SizedBox(height: 16),
                                Text(currentSky, style: const TextStyle(fontSize: 20)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
            
                  const SizedBox(height: 20),
            
                  //Forecast Cards
                  const Text(
                    "Hourly Forecast",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
            
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      itemCount: 5,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final hourlyForecast = data['list'][index + 1];
                        final hourlySky = hourlyForecast['weather'][0]['main'];
                        // --- CHANGE #7: Pass rounded temperature ---
                       final IconData hourlyIcon = getWeatherIcon(hourlySky);
                        final hourlyTemp =
                            hourlyForecast['main']['temp'].round().toString();
                        final time = DateTime.parse(hourlyForecast['dt_txt']);
                        return HourlyForecastItem(
        time: DateFormat.jm().format(time),
        temperature: hourlyTemp,
        // Pass the dynamic icon to the item
        weatherIcon: hourlyIcon,
      );
    },
  ),
),
            
                  const SizedBox(height: 20),
            
                  //Additional Information Cards
                  const Text(
                    "Additional Information",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
            
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      AdditionalInfoItem(
                        icon: Icons.water_drop,
                        label: "Humidity",
                        value: "$currentHumidity%",
                      ),
                      AdditionalInfoItem(
                        icon: Icons.air,
                        label: "Wind Speed",
                        value: "$currentWindSpeed m/s",
                      ),
                      AdditionalInfoItem(
                        icon: Icons.beach_access,
                        label: "Precipitation",
                        value: "$currentPrecipitation mm",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}