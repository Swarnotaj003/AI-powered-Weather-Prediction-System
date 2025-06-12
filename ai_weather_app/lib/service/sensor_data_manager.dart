import 'package:flutter/material.dart';

class SensorDataManager extends ChangeNotifier{
  // Data lists for graph (start with 7 zeroes)
  List<double> temperatures = List<double>.filled(7, 0.0, growable: true);
  List<double> humidities = List<double>.filled(7, 0.0, growable: true);
  List<double> pressures = List<double>.filled(7, 0.0, growable: true);

  // Method to add and trim data
  void updateData({
    required double temperature,
    required double humidity,
    required double pressure,
  }) {
    _addAndTrim(temperatures, temperature);
    _addAndTrim(humidities, humidity);
    _addAndTrim(pressures, pressure);
    notifyListeners();
  }

  void _addAndTrim(List<double> list, double newValue) {
    list.add(newValue);
    list.removeAt(0);
  }
}
