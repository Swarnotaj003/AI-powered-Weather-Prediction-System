import 'package:ai_weather_app/model/weather_data.dart';
import 'package:flutter/material.dart';

class CurrentWeather extends StatelessWidget {
  const CurrentWeather({
    super.key,
    required this.current,
  });

  final WeatherData? current;

  @override
  Widget build(BuildContext context) {
    if (current == null) {
      return Center(child: CircularProgressIndicator(color: Colors.white,));
    } 
    else {
      return Column(
        children: [
          Expanded(child: SizedBox()),
      
          // sky condition
          Text(
            '${current == null ? 'Loading...' : current!.skyConditions[0].trim()} & ${current == null ? 'Loading...' : current!.skyConditions[1].trim()}',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[300],
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
      
          // temperature
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${current == null ? '0' : current!.temperature.split('.')[0]}°C',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
              ),
              Icon(
                Icons.thermostat_outlined,
                color: Colors.red[400],
                size: 32,
              )
            ],
          ),
      
          // humidity 
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.opacity,
                color: Colors.blue[800],
              ),
              SizedBox(width: 5,),
              Text(
                '${current == null ? '0' : current!.humidity}%',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          // pressure
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.speed,
                color: Colors.green[300],
              ),
              SizedBox(width: 5,),
              Text(
                '${current == null ? '000.00' : current!.pressure} hPa',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
              ),
            ],
          ),
      
          // wind status                  
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.air,
                color: Colors.grey[300],
              ),
              SizedBox(width: 5,),
              Text(
                current == null ? 'Loading...' : current!.skyConditions[2].trim(),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[300],
                ),
              ),
            ],
          ),
      
          Expanded(child: SizedBox()),
        ],
      );
    }
  }
}
