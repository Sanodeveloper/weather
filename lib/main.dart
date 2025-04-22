import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math'; // For random precipitation probability (mock data)
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'ui_styles.dart'; // Import the new file for UI styles
import 'package:flutter_animate/flutter_animate.dart'; // Import flutter_animate
import 'package:intl/intl.dart'; // For formatting sunrise and sunset times

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Weather App Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _weather = '取得中...';
  String _message = '';
  String _temperature = '取得中...';
  String _precipitation = '取得中...';
  String _location = '取得中...';
  String _humidity = '取得中...';
  String _windSpeed = '取得中...';
  String _sunrise = '取得中...';
  String _sunset = '取得中...';

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final lat = position.latitude;
      final lon = position.longitude;
      final apiKey = "YOUR_API_KEY"; // Replace with your OpenWeatherMap API key
      final url =
          'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=ja';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _weather = data['weather'][0]['description'];
          _temperature = "${data['main']['temp']}°C";
          _precipitation =
              "${Random().nextInt(100)}%"; // Mock precipitation probability
          _location = data['name'];
          _humidity = "${data['main']['humidity']}%";
          _windSpeed = "${data['wind']['speed']} m/s";
          _sunrise = DateFormat('HH:mm').format(
            DateTime.fromMillisecondsSinceEpoch(data['sys']['sunrise'] * 1000),
          );
          _sunset = DateFormat('HH:mm').format(
            DateTime.fromMillisecondsSinceEpoch(data['sys']['sunset'] * 1000),
          );
          _message = _getWeatherMessage(_weather);
        });
      } else {
        setState(() {
          _weather = '天気情報の取得に失敗しました';
          _temperature = 'N/A';
          _precipitation = 'N/A';
          _location = '不明';
          _humidity = 'N/A';
          _windSpeed = 'N/A';
          _sunrise = 'N/A';
          _sunset = 'N/A';
          _message = '';
        });
      }
    } catch (e) {
      setState(() {
        _weather = 'エラー: $e';
        _temperature = 'N/A';
        _precipitation = 'N/A';
        _location = '不明';
        _humidity = 'N/A';
        _windSpeed = 'N/A';
        _sunrise = 'N/A';
        _sunset = 'N/A';
        _message = '';
      });
    }
  }

  String _getWeatherMessage(String weather) {
    switch (weather) {
      case 'clear sky':
        return '今日は晴れ！お散歩日和ですね☀️';
      case 'broken clouds':
        return '曇りがちですが、少し散歩してみませんか？☁️';
      case 'rain':
        return '雨が降っています。傘を忘れずに☔';
      case 'snow':
        return '雪が降っています。暖かくしてお過ごしください❄️';
      default:
        return '素敵な一日をお過ごしください✨';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          widget.title,
          style: const TextStyle(fontFamily: 'Comic Sans MS', fontSize: 24),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppBackground.gradient),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
              ), // Add horizontal padding
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(
                                '現在地: $_location',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.cloud, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                '天気: $_weather',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.thermostat, color: Colors.red),
                              const SizedBox(width: 8),
                              Text(
                                '気温: $_temperature',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(
                                Icons.water_drop,
                                color: Colors.blueAccent,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '降水確率: $_precipitation',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(
                                Icons.opacity,
                                color: Colors.lightBlue,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '湿度: $_humidity',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.air, color: Colors.green),
                              const SizedBox(width: 8),
                              Text(
                                '風速: $_windSpeed',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.wb_sunny, color: Colors.orange),
                              const SizedBox(width: 8),
                              Text(
                                '日の出: $_sunrise',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(
                                Icons.nights_stay,
                                color: Colors.deepPurple,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '日の入り: $_sunset',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _fetchWeather,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.black.withOpacity(0.3),
                      elevation: 12,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ).copyWith(
                      overlayColor: MaterialStateProperty.all(
                        Colors.orange.withOpacity(0.2),
                      ),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.orange, Colors.deepOrange],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: const Text(
                          '天気を更新',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
