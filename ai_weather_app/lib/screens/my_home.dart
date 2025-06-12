import 'dart:async';

import 'package:ai_weather_app/screens/sensor_dashboard.dart';
import 'package:ai_weather_app/service/sensor_data_manager.dart';
import 'package:ai_weather_app/service/weather_service.dart';
import 'package:ai_weather_app/util/background_helper.dart';
import 'package:ai_weather_app/widgets/current_weather.dart';
import 'package:ai_weather_app/widgets/forecast_card.dart';
import 'package:ai_weather_app/model/forecast_data.dart';
import 'package:ai_weather_app/model/weather_data.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {  
  // Service object
  WeatherService service = WeatherService();
  SensorDataManager dataManager = SensorDataManager();

  // Current weather
  WeatherData? current;

  // 7-day forecast data
  List<ForecastData> forecast = [];

  // Determine if its day or night
  bool isDay = DateTime.now().hour >= 6 && DateTime.now().hour < 18;

  // Fetch initial data
  Future<void> fetchInitialData() async {
    if (current == null && forecast.isEmpty) {
      WeatherData newCurrent = await service.getSensorData();
      List<ForecastData> newForecast = await service.getForecastData();

      // update sensor data too
      dataManager.updateData(
        temperature: double.tryParse(newCurrent.temperature) ?? 0.0,
        humidity: double.tryParse(newCurrent.humidity) ?? 0.0,
        pressure: double.tryParse(newCurrent.pressure) ?? 0.0,
      );

      // update UI
      setState(() {
        current = newCurrent;
        forecast = newForecast;
      });
    }
  }

  // Program loop
  final Duration frameRate = Duration(seconds: 60);
  Timer? timer;
  
  void loop(Duration frameRate) {
    // cancel previous timer if any
    timer?.cancel();

    // use timer for periodic data fetch
    timer = Timer.periodic(frameRate, (timer) async {
      WeatherData newCurrent = await service.getSensorData();
      List<ForecastData> newForecast = await service.getForecastData();

      // update sensor data too
      dataManager.updateData(
        temperature: double.tryParse(newCurrent.temperature) ?? 0.0,
        humidity: double.tryParse(newCurrent.humidity) ?? 0.0,
        pressure: double.tryParse(newCurrent.pressure) ?? 0.0,
      );

      // update UI
      setState(() {
        current = newCurrent;
        forecast = newForecast;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    fetchInitialData();
    loop(frameRate);    
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],

      extendBodyBehindAppBar: false,

      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        centerTitle: true,
        title: Text('W E A T H E R'),
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            // Display current weather
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: getSkyGradient(isDay),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                  child: Row(
                    children: [
                      // Left : Weather stats
                      Expanded(
                        child: CurrentWeather(current: current),
                      ),
                      // Right: Weather animation
                      Expanded(
                        child: FutureBuilder<LottieComposition>(
                          future: NetworkLottie(getWeatherAnimation(current == null ? [] : current!.skyConditions, isDay)).load(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasError && snapshot.hasData) {
                              return Lottie(
                                composition: snapshot.data!,
                                fit: BoxFit.contain,
                              );
                            } else {
                              return Center(child: CircularProgressIndicator(color: Colors.white,));
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 30,),
        
            // Show 7-day forecast
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 5, bottom: 10),
                child: Text(
                  'Forecast',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ),
        
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: forecast.length,
                itemBuilder: (context, index) => ForecastCard(data: forecast[index]),
              ),
            ),
            SizedBox(height: 30,),
        
            // Navigate to Sensor Dashboard
            TextButton(
              onPressed: () async {
                // navigate to sensor dashboard with provider
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider.value(
                      value: dataManager,
                      child: SensorDashboard(),
                    ),
                  ),
                );
              }, 
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: Text(
                  'Sensor Dashboard',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20,),
          ],
        ),
      ),
    );
  }
}
