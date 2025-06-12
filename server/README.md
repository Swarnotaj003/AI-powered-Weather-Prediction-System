# AI-based Weather Prediction Server 🌤🌐🤖

An AI-based weather prediction server build using the `Flask` framework in `Python` that provides current weather conditions and forecasts using machine learning. The server uses historical weather data of the local zone and real-time sensor data to make accurate predictions.

## ✨ Features

- **Real-time Weather Data**: Fetches current weather conditions (temperature, humidity, pressure) from Open-Meteo API
- **7-Day Weather Forecast**: Predicts weather conditions for the next week
- **Sky Condition Analysis**: Determines sky conditions based on temperature, humidity, and pressure
- **Historical Data Management**: Maintains and updates historical weather data for training
- **RESTful API**: Provides endpoints for current weather and forecasts
- **Environment Configuration**: Uses `.env` for flexible configuration

## 🔌 API Endpoints

1. `/api/current-weather`
   - Method: GET
   - Returns: Current temperature, humidity, pressure, and sky conditions

2. `/api/weather-forecast`
   - Method: GET
   - Returns: 7-day weather forecast with min/max temperatures, humidity, and pressure

## 🤔 Why RandomForest?

RandomForest was chosen as the machine learning algorithm for several reasons:

1. **Handling Non-linear Relationships**: Weather patterns often have complex, non-linear relationships between variables. RandomForest can capture these relationships effectively.

2. **Feature Importance**: The algorithm provides insights into which weather parameters (temperature, humidity, pressure) are most influential in predictions.

3. **Robustness**: 
   - Handles outliers well
   - Less prone to overfitting compared to single decision trees
   - Works well with both numerical and categorical data

4. **Performance**:
   - Fast training and prediction times
   - Good accuracy with relatively small datasets
   - Can handle missing data gracefully

5. **Interpretability**: While being a powerful algorithm, it's still relatively interpretable compared to deep learning models.

## 🛠️ Technology Stack

- **Backend**: Flask
- **Machine Learning**: scikit-learn (RandomForestRegressor)
- **Data Processing**: pandas, numpy
- **API Integration**: requests
- **Environment Management**: python-dotenv

## 🚀 Setup

1. Install dependencies:
```bash
pip install -r requirements.txt
```

2. Navigate to the root project directory and move down to server directory:
```
cd server
```

3. Create a `.env` file defining the following variables:
```
# API Server Configuration
FLASK_HOST=0.0.0.0  # wildcard address to listen on all networks
FLASK_PORT=8080
FLASK_DEBUG=True

# Weather Predictor Configuration
CITY=Kolkata
LATITUDE=22.5726
LONGITUDE=88.3639
WEATHER_API_BASE_URL=https://api.open-meteo.com/v1
WEATHER_ARCHIVE_API_URL=https://archive-api.open-meteo.com/v1/archive
TIMEZONE=Asia/Kolkata

```

4. Run the server:
```bash
python api.py
```

## 📊 Data Flow

1. **Data Collection**:
   - Fetches historical data (30 days) from Open-Meteo API
   - Collects real-time weather data every 5 minutes

2. **Model Training**:
   - Uses 720 readings (30 days × 24 hours) for training
   - Trains separate models for temperature, humidity, and pressure

3. **Prediction**:
   - Generates 7-day forecasts
   - Includes day/night variations
   - Considers historical patterns and current conditions

## ⚠️ Error Handling

The server implements comprehensive error handling:
- API rate limiting
- Data validation
- Consistent error response format
- Graceful fallbacks for missing data

## 🔮 Future Improvements
1. Fetch real time data from a real-world sensor
2. Add more weather parameters like wind speed, precipitation etc.
3. Implement model retraining schedule
4. Add data visualization endpoints
5. Implement caching for API responses
6. Add authentication for API endpoints 