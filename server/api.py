from flask import Flask, jsonify
from flask_cors import CORS
from ai_model.weather_predictor import WeatherPredictor
import threading
import time
from datetime import datetime
from dotenv import load_dotenv
import os

# Load environment variables
load_dotenv()

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes
weather_predictor = WeatherPredictor()

def initialize_weather_predictor():
    """Initialize the weather predictor with historical data"""
    print("Initializing weather predictor...")
    if weather_predictor.download_historical_data():
        print("Historical data downloaded successfully")
        if weather_predictor.fetch_initial_training_data():
            print("Initial training data fetched successfully")
            return True
    print("Failed to initialize weather predictor")
    return False

def create_error_response(message, status_code=500):
    """Create a consistent error response format"""
    return jsonify({
        'success': False,
        'error': {
            'message': message,
            'code': status_code
        }
    }), status_code

def create_success_response(data, message=None):
    """Create a consistent success response format"""
    response = {
        'success': True,
        'data': data
    }
    if message:
        response['message'] = message
    return jsonify(response)

@app.route('/api/current-weather', methods=['GET'])
def get_current_weather():
    """Endpoint to get current weather data"""
    try:
        # Fetch current sensor data
        if not weather_predictor.fetch_sensor_data():
            return create_error_response('Failed to fetch current weather data', 500)

        # Get the latest reading from historical data
        if not weather_predictor.historical_data:
            return create_error_response('No weather data available yet', 404)

        latest_reading = weather_predictor.historical_data[-1]
        
        # Calculate sky condition based on the latest reading
        temp = float(latest_reading['field1'])
        humidity = float(latest_reading['field2'])
        pressure = float(latest_reading['field3'])
        sky_condition = weather_predictor.calculate_sky_condition(temp, humidity, pressure)
        
        return create_success_response({
            'temperature': temp,
            'humidity': humidity,
            'pressure': pressure,
            'sky_condition': sky_condition,
            'timestamp': latest_reading['created_at'],
            'location': weather_predictor.city
        })
    except Exception as e:
        return create_error_response(str(e), 500)

@app.route('/api/weather-forecast', methods=['GET'])
def get_weather_forecast():
    """Endpoint to get weather forecast"""
    try:
        # First ensure we have enough data and train the model
        if not weather_predictor.historical_data or len(weather_predictor.historical_data) < 240:
            return create_error_response('Insufficient historical data for prediction. Need at least 240 readings.', 404)

        # Train the model
        if not weather_predictor.train_model():
            return create_error_response('Failed to train the weather prediction model.', 500)

        # Get predictions for next 7 days
        forecast = weather_predictor.predict_weather()
        
        if not forecast:
            return create_error_response('Unable to generate forecast. Prediction failed.', 404)

        # Print the forecast in a formatted table
        weather_predictor._print_forecast(forecast)

        # Format the forecast data
        formatted_forecast = []
        for day in forecast:
            formatted_forecast.append({
                'date': day['date'],
                'min_temperature': day['min_temperature'],
                'max_temperature': day['max_temperature'],
                'humidity': day['humidity'],
                'pressure': day['pressure']
            })

        return create_success_response({
            'forecast': formatted_forecast,
            'generated_at': datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        })
    except Exception as e:
        print(f"Error in weather forecast: {str(e)}")  # Add logging
        return create_error_response(f'Failed to generate forecast: {str(e)}', 500)

if __name__ == '__main__':
    # Initialize the weather predictor with historical data
    if initialize_weather_predictor():
        print("Weather predictor initialized successfully")
    else:
        print("Warning: Weather predictor initialization failed")
    
    # Start the Flask server using environment variables
    app.run(
        host=os.getenv('FLASK_HOST', '0.0.0.0'),
        port=int(os.getenv('FLASK_PORT', 8080)),
        debug=os.getenv('FLASK_DEBUG', 'True').lower() == 'true'
    ) 