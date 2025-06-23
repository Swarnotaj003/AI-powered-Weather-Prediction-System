import 'package:flutter/material.dart';

// Night sky
final nightGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Colors.indigo[900]!, Colors.blueGrey[900]!, Colors.black],
);

// Day sky
final dayGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Colors.lightBlue[200]!, Colors.lightBlue[500]!, Colors.blue[800]!],
);

/*
  Return an appropriate background gradient as per day or night
*/
LinearGradient getSkyGradient(bool isDay) {
  return isDay ? dayGradient : nightGradient;
}

/*
  URL to all the available weather animations
*/
final String rainyDay = 'https://lottie.host/e4f6764a-63e7-482f-b429-62176953f43f/QfyfJC9yXa.json';
final String rainyNight = 'https://lottie.host/6cf0330d-4390-40fd-ba3a-e5f8d22d58ee/YxGYnxw1l2.json';
final String dayFog = 'https://lottie.host/9bb43375-fb7d-481e-9f99-873359fea0cb/d9ftZiiP29.json';
final String snow = 'https://lottie.host/9b221dea-677d-489f-a3ce-bc19e66b82f0/ZmII0WXn3I.json';
final String mist = 'https://lottie.host/bf94aac7-2102-45c5-979a-27333a49d18c/7gKLeUlcK4.json';
final String moon = 'https://lottie.host/f2ca3c83-5a79-4fcb-887a-84bf9cafe066/pUhQv68HqA.json';
final String partlyCloudy = 'https://lottie.host/8db5390b-1f09-444d-816b-3703c9c42d4f/nP6cDXNNGx.json';
final String storm = 'https://lottie.host/bfffeeb4-aeac-4aea-bac8-b59f83492412/1wVphzVlNK.json';
final String sunny = 'https://lottie.host/fc035323-d38e-4ee9-99b7-89985297fb65/CLw9aUAxcP.json';
final String windy = 'https://lottie.host/2aef2232-e58a-4d69-9a4b-a1786589b157/BI0GC9n7Za.json';

/*
  Return an appropriate weather animation
  based on sky conditions
*/
String getWeatherAnimation(List<String> skyConditions, bool isDay) {
  String url = isDay ? sunny : moon;

  if (skyConditions.length < 3) {
    return url;
  }

  for (String skyCondition in skyConditions) {
    skyCondition.trim();
  }

  // | Temperature | Humidity    | Pressure       | Background Theme        |
  // | ----------- | ----------- | -------------- | ----------------------- |
  // | X	         | Humid/Rainy | Probable storm | Storm		                |
  // | X	         | Rainy       | X		          | RainyDay/RainyNight     |
  // | Freezing    | X	         | Probable storm | Snow	 	                |
  // | X           | X	         | Probable storm | Mist          	        |
  // | Freezing/Chilly/Cool| X   | Strong wind    | DayFog/Mist 	          |
  // | Freezing/Chilly/Cool| X   | X              | Windy   		            |
  // | Scorch/Hot/Warm     | X   | Strong wind    | PartlyCloudyDay/Moon    |
  // | Scorch/Hot/Warm/Mild| X   | X  	          | Sunny/Moon	            |

  if ((skyConditions[1] == 'Humid' || skyConditions[1] == 'Rainy') && skyConditions[2] == 'Probable storm') {
    url = storm;
  }
  else if (skyConditions[1] == 'Rainy') {
    url = isDay ? rainyDay : rainyNight;
  }
  else if (skyConditions[0] == 'Freezing' && skyConditions[2] == 'Probable storm') {
    url = snow;
  }
  else if (skyConditions[2] == 'Probable storm') {
    url = mist;
  }
  else if (
    (skyConditions[0] == 'Freezing' || skyConditions[0] == 'Chilly' || skyConditions[0] == 'Cool') && skyConditions[2] == 'Strong wind'
  ) {
    url = isDay ? dayFog : mist;
  }
  else if ((skyConditions[0] == 'Freezing' || skyConditions[0] == 'Chilly' || skyConditions[0] == 'Cool')) {
    url = windy;
  }
  else if (
    (skyConditions[0] == 'Scorching' || skyConditions[0] == 'Hot' || skyConditions[0] == 'Warm') && skyConditions[2] == 'Strong wind'
  ) {
    url = isDay ? partlyCloudy : moon;
  }
  else if (skyConditions[0] == 'Scorching' || skyConditions[0] == 'Hot' || skyConditions[0] == 'Warm' || skyConditions[0] == 'Mild') {
    url = isDay ? sunny : moon;
  }
  return url;
}
