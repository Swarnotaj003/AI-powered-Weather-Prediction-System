import 'package:ai_weather_app/model/forecast_data.dart';
import 'package:ai_weather_app/util/date_time_formatter.dart';
import 'package:flutter/material.dart';

class ForecastCard extends StatelessWidget {
  /*
    Custom Card UI to display forecast data
  */
  final ForecastData data;

  const ForecastCard({
    super.key,
    required this.data,
  });  

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blueGrey[900],

      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
        child: Column(
          children: [
            // Date
            Text(
              getDateString(data.timestamp),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[400],
              ),
            ),
    
            // Day
            Text(
              getDayString(data.timestamp),
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10,),
    
            // Temperatures
            Row (
              children: [
                Column(
                  children: [
                    Text("MIN", style: TextStyle(color: Colors.grey[400], fontSize: 10),),
                    Text(
                      "${data.minTemperature}°C",
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 2,),
                Icon(Icons.thermostat, color: Colors.red[400],),
                SizedBox(width: 2,),
                Column(
                  children: [
                    Text("MAX", style: TextStyle(color: Colors.white, fontSize: 10),),
                    Text(
                      "${data.maxTemperature}°C",
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 5,),
    
            // Humidity
            // Text("Relative humidity"),
            Row(
              children: [
                Icon(Icons.opacity, color: Colors.blue[800],),
                SizedBox(width: 5,),
                Text(
                  "${data.humidity}%",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 5,),
    
            // Pressure
            // Text("Air Pressure"),
            Row(
              children: [
                Icon(Icons.speed, color: Colors.green[300],),
                SizedBox(width: 5,),
                Text(
                  "${data.pressure} hPa",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}