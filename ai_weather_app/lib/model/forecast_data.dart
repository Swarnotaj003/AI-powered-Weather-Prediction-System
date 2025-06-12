class ForecastData {
  /*
    Model class to store weather forecast data
  */
  final DateTime timestamp;
  final String minTemperature;
  final String maxTemperature;
  final String humidity;
  final String pressure;

  ForecastData({
    required this.timestamp,
    required this.minTemperature,
    required this.maxTemperature,
    required this.humidity,
    required this.pressure,
  });
}