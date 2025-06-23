import 'dart:convert';

import 'package:ai_weather_app/model/forecast_data.dart';
import 'package:ai_weather_app/model/weather_data.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';

class WeatherService {  
  // Link to our API
  final String url = dotenv.env['API_URL'] ?? 'http://localhost:8080';

  // Get current weather data
  Future<WeatherData> getSensorData() async {
    WeatherData data;
    try {
      Response response = await get(Uri.parse('$url/api/current-weather'));
      Map<String, dynamic> map = jsonDecode(response.body)['data'];
      data = WeatherData(
        timestamp: DateTime.now(),
        temperature: map['temperature'].toStringAsFixed(1),
        humidity: map['humidity'].toStringAsFixed(1),
        pressure: map['pressure'].toStringAsFixed(1),
        skyConditions: List<String>.from(map['sky_condition'].split(", ")),
      );
    }
    catch (e) {
      // print(e);
      data = WeatherData(
        timestamp: DateTime.now(), 
        temperature: '00', 
        humidity: '00', 
        pressure: '0000.0', 
        skyConditions: ['Exception', e.runtimeType.toString(), 'Loading...'],
      );
    }
    return data;
  }  

  // Get 7-day weather forecast
  Future<List<ForecastData>> getForecastData() async {
    List<ForecastData> data;
    try {
      Response response = await get(Uri.parse('$url/api/weather-forecast'));
      List<dynamic> forecastList = jsonDecode(response.body)['data']['forecast'];
      int i = 0;
      data = forecastList.map((value) {
        return ForecastData(
          timestamp: DateTime.now().add(Duration(days: i++)),
          minTemperature: value['min_temperature'].round().toString(),
          maxTemperature: value['max_temperature'].round().toString(),
          humidity: value['humidity'].toStringAsFixed(1),
          pressure: value['pressure'].toStringAsFixed(1),
        );
      }).toList();
    }
    catch (e) {
      // print(e);
      data = [
        ForecastData(
          timestamp: DateTime.now(),
          minTemperature: '00',
          maxTemperature: '00',
          humidity: '00',
          pressure: '0000.0',
        ),
      ];
    }
    return data;
  }
}
