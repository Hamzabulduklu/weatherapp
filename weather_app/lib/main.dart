import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:weather_icons/weather_icons.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hava Durumu',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WeatherPage(),
    );
  }
}

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  String _city = "Istanbul";
  String _apiKey = "Your api"; // OpenWeather API Key
  String? _temperature;
  String? _description;
  String? _icon;
  bool _isLoading = false;

  Future<void> _getWeather() async {
    setState(() {
      _isLoading = true;
    });

    final url =
        "https://api.openweathermap.org/data/2.5/weather?q=$_city&appid=$_apiKey&units=metric&lang=tr";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _temperature = "${data['main']['temp']}°C";
          _description = data['weather'][0]['description'];
          _icon = data['weather'][0]['main'];
        });
      } else {
        _showError("Hava durumu bilgisi alınamadı. Kod: ${response.statusCode}");
      }
    } catch (e) {
      _showError("Bir hata oluştu: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hata"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tamam"),
          ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon(String? condition) {
    switch (condition) {
      case "Clear":
        return WeatherIcons.day_sunny;
      case "Clouds":
        return WeatherIcons.cloud;
      case "Rain":
        return WeatherIcons.rain;
      case "Snow":
        return WeatherIcons.snow;
      case "Thunderstorm":
        return WeatherIcons.thunderstorm;
      default:
        return WeatherIcons.na;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hava Durumu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Şehir Adı',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                _city = value;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getWeather,
              child: const Text('Hava Durumunu Getir'),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : _temperature != null
                ? Column(
              children: [
                BoxedIcon(
                  _getWeatherIcon(_icon),
                  size: 80,
                  color: Colors.blueAccent,
                ),
                const SizedBox(height: 20),
                Text(
                  _temperature!,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _description!,
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            )
                : const Text(
              'Hava durumu bilgisi için şehir adı girin.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
