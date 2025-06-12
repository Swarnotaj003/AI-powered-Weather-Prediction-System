class WeatherData {
  /*
    Model class to store current weather data
  */
  final DateTime timestamp;
  final String temperature;
  final String humidity;
  final String pressure;
  final List<String> skyConditions;

  WeatherData({
    required this.timestamp,
    required this.temperature,
    required this.humidity,
    required this.pressure,
    required this.skyConditions,
  });
}