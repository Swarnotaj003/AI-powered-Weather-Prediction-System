# AI-powered Weather Prediction App 🌤🤖📱

A modern `Flutter` application that provides real-time weather conditions and AI-powered forecasts. The app connects to a Flask backend server that uses machine learning to predict weather patterns.

## ✨ Features

- **Real-time Weather Display**: Shows current temperature, humidity, pressure, and sky conditions
- **7-Day Forecast**: Displays detailed weather predictions for the upcoming week
- **Beautiful UI**: Modern and intuitive user interface 
- **Sensor Dashboard**: Monitor recent sensor data trends with dynamic line graphs for temperature, humidity, and pressure  
- **Subtle animations**: Displays weather animations as per sky conditions

## 🛠️ Technology Stack

- **Frontend**: Flutter
- **State Management**: Provider
- **HTTP Client**: Http client
- **Charts**: Flutter charts
- **Animations**: Lottie files
- **Environment Management**: Flutter dotenv

## 🚀 Getting Started

1. Install Flutter:
   - Follow the official [Flutter installation](https://flutter.dev/docs/get-started/install) guide
   - Ensure you have an IDE like Android Studi or Xcode installed
   - Ensure that you have an Android emulator or physical device for testing

2. Navigate to the root project directory and enter:
```bash
cd ai_weather_app
```

3. Create a .env file with the following content
```
API_URL='http://<YOUR_SERVER_IPv4_ADDRESS>:8080'

```

4. Install dependencies:
```bash
flutter pub get
```

5. Run the app:
```bash
flutter run
```

## 📱 App Structure

```
lib/
├── model/           # Data models
├── screens/         # UI screens
├── service /        # API and sensor data management
├── utils/           # Utility functions
└── widgets/         # Reusable widgets
```

## 🔌 API Integration

The app communicates with two main endpoints:

1. `/api/current-weather`
   - Fetches real-time weather data
   - Updates every minute
   - Includes temperature, humidity, pressure

2. `/api/weather-forecast`
   - Retrieves 7-day weather predictions
   - Includes min/max temperatures
   - Shows humidity and pressure trends

## 🔮 Future Improvements

1. Add weather notifications and alerts
2. Implement weather maps
3. Add weather sharing features
4. Add historical weather data view
