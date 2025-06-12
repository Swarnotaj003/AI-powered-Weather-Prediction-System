import 'package:ai_weather_app/service/sensor_data_manager.dart';
import 'package:ai_weather_app/util/data_stats.dart';
import 'package:ai_weather_app/widgets/my_line_graph.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SensorDashboard extends StatefulWidget {
  const SensorDashboard({super.key,});

  @override
  State<SensorDashboard> createState() => _SensorDashboardState();
}

class _SensorDashboardState extends State<SensorDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],

      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        centerTitle: true,
        title: Text('D A S H B O A R D'),
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          }, 
          icon: Icon(Icons.arrow_back_ios, color: Colors.white,),
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: Consumer<SensorDataManager>(
            builder: (context, dataManager, _) {
              return Column(
                children: [
                  Text(
                    'Track the latest readings from your sensor',
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 10,),

                  // Temperature graph
                  SizedBox(
                    height: 300,
                    child: Card(
                      color: Colors.blueGrey[900],
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 15,
                        ),
                        child: MyLineGraph(                          
                          dataPoints: dataManager.temperatures,
                          minVal: (getMinPoint((dataManager.temperatures)) * 0.75).floorToDouble(),
                          maxVal: (getMaxPoint((dataManager.temperatures)) * 1.25).ceilToDouble(),
                          ylabel: 'Temperature (in °C)',
                          myGradientColors: [Colors.pink[400]!, Colors.red[700]!],
                        ),
                      ),
                    ),
                  ),

                  // Humidity graph
                  SizedBox(
                    height: 300,
                    child: Card(
                      color: Colors.blueGrey[900],
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 15,
                        ),
                        child: MyLineGraph(
                          dataPoints: dataManager.humidities,
                          minVal: (getMinPoint(dataManager.humidities) * 0.75).floorToDouble(),
                          maxVal: (getMaxPoint(dataManager.humidities) * 1.25).ceilToDouble(),
                          ylabel: 'Humidity (in %)',
                          myGradientColors: [
                            Colors.lightBlue[400]!,
                            Colors.blue[700]!,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Pressure graph
                  SizedBox(
                    height: 300,
                    child: Card(
                      color: Colors.blueGrey[900],
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 15,
                        ),
                        child: MyLineGraph(
                          dataPoints: dataManager.pressures,
                          minVal: (getMinPoint(dataManager.pressures) * 0.75).floorToDouble(),
                          maxVal: (getMaxPoint(dataManager.pressures) * 1.25).ceilToDouble(),
                          ylabel: 'Pressure (in hPa)',
                          myGradientColors: [
                            Colors.lightGreen[400]!,
                            Colors.green[700]!,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
          ),
        ),
      ),
    );
  }
}
