import requests
import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestRegressor
from datetime import datetime, timedelta
import time
import json
import os
import csv
import math
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

class WeatherPredictor:
    def __init__(self):
        self.city = os.getenv('CITY', 'Kolkata')
        self.latitude = float(os.getenv('LATITUDE', 22.5726))
        self.longitude = float(os.getenv('LONGITUDE', 88.3639))
        self.base_url = os.getenv('WEATHER_API_BASE_URL', 'https://api.open-meteo.com/v1')
        self.archive_url = os.getenv('WEATHER_ARCHIVE_API_URL', 'https://archive-api.open-meteo.com/v1/archive')
        self.timezone = os.getenv('TIMEZONE', 'Asia/Kolkata')
        self.historical_data = []  # Local list to store readings
        self.max_readings = 720     # Maximum number of readings to store for current conditions
        self.last_api_call = 0
        self.min_api_interval = 1  # Minimum 1 second between API calls

    def calculate_sky_condition(self, temp, humidity, pressure):
        """Determine sky condition based on humidity and pressure"""
        conditions = []
        
        # Temperature-based condition
        if temp < 5:
            conditions.append("Freezing")
        elif temp < 10:
            conditions.append("Chilly")
        elif temp < 18:
            conditions.append("Cool")
        elif temp < 25:
            conditions.append("Mild")
        elif temp < 32:
            conditions.append("Warm")
        elif temp < 40:
            conditions.append("Hot")
        else:
            conditions.append("Scorching")

            
        # Humidity-based condition
        if humidity > 90:
            conditions.append("Rainy")
        elif humidity > 60:
            conditions.append("Humid")
        elif humidity < 40:
            conditions.append("Dry")
        else:
            conditions.append("Comfortable")
            
        # Pressure-based condition
        if pressure < 990:
            conditions.append("Probable storm")
        elif pressure <= 1000:
            conditions.append("Strong wind")
        elif pressure <= 1020:
            conditions.append("Light breeze")
        else:
            conditions.append("Calm wind")
            
        return ", ".join(conditions)

    def fetch_sensor_data(self):
        """Fetch current weather data from Open-Meteo API"""
        try:
            # Check if enough time has passed since last API call
            current_time = time.time()
            if current_time - self.last_api_call < self.min_api_interval:
                time.sleep(self.min_api_interval - (current_time - self.last_api_call))
            
            # Make API request
            url = f"{self.base_url}/forecast"
            params = {
                'latitude': self.latitude,
                'longitude': self.longitude,
                'current': 'temperature_2m,relative_humidity_2m,pressure_msl',
                'timezone': self.timezone
            }
            
            response = requests.get(url, params=params)
            response.raise_for_status()
            data = response.json()
            
            # Extract current conditions
            current_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            new_reading = {
                'created_at': current_time,
                'field1': str(data['current']['temperature_2m']),
                'field2': str(data['current']['relative_humidity_2m']),
                'field3': str(data['current']['pressure_msl'])
            }
            
            # Print current conditions
            print("\nCurrent Weather Conditions in Kolkata:")
            print(f"Time: {current_time}")
            print(f"Temperature: {new_reading['field1']}°C")
            print(f"Humidity: {new_reading['field2']}%")
            print(f"Pressure: {new_reading['field3']} hPa")
            
            # Update historical data
            if len(self.historical_data) >= self.max_readings:
                # Remove oldest reading and append new one
                self.historical_data.pop(0)
                self.historical_data.append(new_reading)
                print(f"Replaced oldest reading. Current size: {len(self.historical_data)} readings")
            else:
                # Simply append new reading
                self.historical_data.append(new_reading)
                print(f"Added new reading. Current size: {len(self.historical_data)} readings")
            
            # Update last API call time
            self.last_api_call = time.time()
            return True
            
        except Exception as e:
            print(f"Error fetching sensor data: {str(e)}")
            return False

    def prepare_features(self, data):
        """Prepare features for the model"""
        features = []
        for entry in data:
            features.append([
                float(entry['field1']),  # Temperature
                float(entry['field2']),  # Humidity
                float(entry['field3'])   # Pressure
            ])
        return np.array(features)

    def train_model(self):
        """Train the model on historical data"""
        if len(self.historical_data) < 240:  # Need at least 240 readings (10 days)
            print(f"Error: Insufficient data for training. Need at least 240 readings, got {len(self.historical_data)}")
            return False
        if len(self.historical_data) > 720:  # Cap at 720 readings (30 days)
            self.historical_data = self.historical_data[-720:]

        X = self.prepare_features(self.historical_data)
        # Prepare all three target variables
        y_temp = np.array([float(entry['field1']) for entry in self.historical_data])
        y_humidity = np.array([float(entry['field2']) for entry in self.historical_data])
        y_pressure = np.array([float(entry['field3']) for entry in self.historical_data])
        
        # Train three separate Random Forest models
        self.temp_model = RandomForestRegressor(n_estimators=100, random_state=42).fit(X, y_temp)
        self.humidity_model = RandomForestRegressor(n_estimators=100, random_state=42).fit(X, y_humidity)
        self.pressure_model = RandomForestRegressor(n_estimators=100, random_state=42).fit(X, y_pressure)
        return True

    def predict_weather(self):
        """Predict weather for the next 7 days using our trained model"""
        if not self.train_model():
            return None

        predictions = []
        current_date = datetime.now()

        # Get the last reading as base for predictions
        last_reading = self.historical_data[-1]
        base_temp = float(last_reading['field1'])
        base_humidity = float(last_reading['field2'])
        base_pressure = float(last_reading['field3'])

        # Calculate variations from historical data
        temp_variation = np.std([float(r['field1']) for r in self.historical_data])
        humidity_variation = np.std([float(r['field2']) for r in self.historical_data])
        pressure_variation = np.std([float(r['field3']) for r in self.historical_data])

        for i in range(0, 7):
            # Prepare features for prediction
            features = np.array([[base_temp, base_humidity, base_pressure]])
            
            # Predict all three values using their respective models
            base_predicted_temp = self.temp_model.predict(features)[0]
            base_predicted_humidity = self.humidity_model.predict(features)[0]
            base_predicted_pressure = self.pressure_model.predict(features)[0]
            
            # Add some random variation to the base predictions
            daily_temp_variation = np.random.normal(0, temp_variation * 0.2)
            daily_humidity_variation = np.random.normal(0, humidity_variation * 0.2)
            daily_pressure_variation = np.random.normal(0, pressure_variation * 0.2)
            
            base_predicted_temp += daily_temp_variation
            base_predicted_humidity += daily_humidity_variation
            base_predicted_pressure += daily_pressure_variation

            # Calculate day/night variations
            # Day is considered from 6 AM to 6 PM (12 hours)
            # Night is considered from 6 PM to 6 AM (12 hours)
            prediction_date = current_date + timedelta(days=i)
            hour = prediction_date.hour
            
            # Day/night temperature adjustment factor
            if 6 <= hour < 18:  # Day time
                min_scale = 2
                max_scale = 0.5
            else:  # Night time
                min_scale = 0.5
                max_scale = 2
            
            # Apply day/night variations to min and max temperatures
            min_temp = base_predicted_temp - temp_variation * min_scale
            max_temp = base_predicted_temp + temp_variation * max_scale
            
            # Ensure humidity stays within valid range
            predicted_humidity = max(0, min(100, base_predicted_humidity))
            
            predictions.append({
                'date': prediction_date.strftime('%Y-%m-%d'),
                'min_temperature': round(min_temp, 2),
                'max_temperature': round(max_temp, 2),
                'humidity': round(predicted_humidity, 2),
                'pressure': round(base_predicted_pressure, 2)
            })

        return predictions

    def _print_forecast(self, forecast):
        """Print the forecast in a formatted table"""
        if not forecast:
            return

        # Get current time for the generation timestamp
        generation_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        
        print("\n" + "=" * 60)
        print(f"7-Day Weather Forecast (Generated at: {generation_time})")
        print("=" * 60)
        print(f"{'Date':<12} {'Min Temp':<10} {'Max Temp':<10} {'Humidity':<10} {'Pressure':<10}")
        print("-" * 60)
        
        for day in forecast:
            print(f"{day['date']:<12} {day['min_temperature']:>6.1f}°C   {day['max_temperature']:>6.1f}°C   {day['humidity']:>6.1f}%    {day['pressure']:>6.1f} hPa")
        print("=" * 60)

    def download_historical_data(self):
        """Download and save complete historical weather data"""
        try:
            # Use current date as end date
            end_date = datetime.now() - timedelta(days=1)   # Last day
            start_date = end_date - timedelta(days=29)  # 30 days back
            
            # Format dates for API
            start_str = start_date.strftime('%Y-%m-%d')
            end_str = end_date.strftime('%Y-%m-%d')
            
            print(f"\nDuration: ({start_str} to {end_str})")
            print(f"Expected readings: 720 (30 days × 24 hours)")
            
            # Make API request
            url = self.archive_url
            params = {
                'latitude': self.latitude,
                'longitude': self.longitude,
                'start_date': start_str,
                'end_date': end_str,
                'hourly': 'temperature_2m,relative_humidity_2m,pressure_msl',
                'timezone': self.timezone
            }
            
            response = requests.get(url, params=params)
            
            if response.status_code != 200:
                print(f"API Error: {response.text}")
                return False
                
            data = response.json()
            
            if 'hourly' not in data:
                print("Invalid API response format - 'hourly' data missing")
                return False
            
            # Process hourly data
            hourly_data = data['hourly']
            timestamps = hourly_data['time']
            temperatures = hourly_data['temperature_2m']
            humidities = hourly_data['relative_humidity_2m']
            pressures = hourly_data['pressure_msl']
            
            # Filter out any rows with None or NaN values
            valid_data = []
            invalid_count = 0
            for i in range(len(timestamps)):
                if (temperatures[i] is not None and 
                    humidities[i] is not None and 
                    pressures[i] is not None and
                    not any(math.isnan(x) for x in [temperatures[i], humidities[i], pressures[i]])):
                    valid_data.append({
                        'timestamp': timestamps[i],
                        'temperature': temperatures[i],
                        'humidity': humidities[i],
                        'pressure': pressures[i]
                    })
                else:
                    invalid_count += 1
            
            print(f"Received: {len(timestamps)} readings")
            print(f"Valid: {len(valid_data)} readings")
            print(f"Invalid: {invalid_count} readings")
            
            # Create data directory if it doesn't exist
            data_dir = "data"
            if not os.path.exists(data_dir):
                os.makedirs(data_dir)
            
            # Always use the same filename to overwrite
            csv_filename = os.path.join(data_dir, "historical_weather_data.csv")
            
            with open(csv_filename, 'w', newline='') as csvfile:
                fieldnames = ['timestamp', 'temperature', 'humidity', 'pressure']
                writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
                
                writer.writeheader()
                writer.writerows(valid_data)
            
            return True
            
        except requests.exceptions.RequestException as e:
            print(f"Network error while downloading historical data: {str(e)}")
            return False
        except Exception as e:
            print(f"Error downloading historical data: {str(e)}")
            return False

    def fetch_initial_training_data(self):
        """Fetch optimal volume of data for initial model training from the downloaded CSV file"""
        try:
            print("\nFetching training data from CSV...")
            
            # Use the fixed CSV filename
            data_dir = "data"
            csv_filename = os.path.join(data_dir, "historical_weather_data.csv")
            if not os.path.exists(csv_filename):
                print("No historical data CSV file found")
                return False
            
            # Read the CSV and load all valid data
            self.historical_data = []
            skipped_rows = 0
            total_rows = 0
            with open(csv_filename, 'r') as csvfile:
                reader = csv.DictReader(csvfile)
                for row_num, row in enumerate(reader, start=2):
                    total_rows += 1
                    try:
                        # Skip rows with empty values
                        if not all(row[field].strip() for field in ['timestamp', 'temperature', 'humidity', 'pressure']):
                            skipped_rows += 1
                            continue
                            
                        try:
                            reading = {
                                'created_at': row['timestamp'].strip(),
                                'field1': float(row['temperature'].strip()),
                                'field2': float(row['humidity'].strip()),
                                'field3': float(row['pressure'].strip())
                            }
                            self.historical_data.append(reading)
                        except ValueError:
                            skipped_rows += 1
                            continue
                                
                    except Exception:
                        skipped_rows += 1
                        continue
            
            print(f"Data summary:")
            print(f"- Total rows: {total_rows}")
            print(f"- Skipped rows: {skipped_rows}")
            print(f"- Training data: {len(self.historical_data)} readings")
            return True
            
        except Exception as e:
            print(f"Error: {str(e)}")
            return False

    def run(self):
        """Run the weather prediction system"""
        try:
            print("\nInitializing Weather Prediction System...")
            print(f"Location: {self.city} ({self.latitude}, {self.longitude})")
            
            # First, download and save complete historical data
            print("\nStep 1: Downloading historical data...")
            if not self.download_historical_data():
                print("Failed to download historical data. Exiting...")
                return
                
            # Then, fetch optimal training data for initial prediction
            print("\nStep 2: Fetching training data...")
            if not self.fetch_initial_training_data():
                print("Failed to fetch training data. Exiting...")
                return
            
            # Fetch current sensor data before making prediction
            print("\nStep 3: Fetching current sensor data...")
            if not self.fetch_sensor_data():
                print("Failed to fetch current sensor data. Exiting...")
                return
                
            # Make first prediction using training data
            print("\nStep 4: Generating initial forecast...")
            forecast = self.predict_weather()
            if forecast:
                self._print_forecast(forecast)
            else:
                print("Failed to generate initial forecast. Exiting...")
                return
            
            print("\nSwitching to 300-second interval updates...")
            
            while True:
                try:
                    # Calculate time until next update
                    current_time = datetime.now()
                    next_update = current_time + timedelta(seconds=300)
                    time_remaining = 300
                    
                    # Display countdown
                    while time_remaining > 0:
                        minutes = time_remaining // 60
                        seconds = time_remaining % 60
                        print(f"\rNext update in: {minutes:02d}:{seconds:02d}", end="", flush=True)
                        time.sleep(1)
                        time_remaining -= 1
                    print("\r" + " " * 30 + "\r", end="", flush=True)  # Clear the countdown line
                    
                    self.fetch_sensor_data()
                    forecast = self.predict_weather()
                    if forecast:
                        self._print_forecast(forecast)
                    else:
                        print("Failed to generate initial forecast. Exiting...")
                        return
                    
                except KeyboardInterrupt:
                    print("\nStopping weather prediction system...")
                    break
                except Exception as e:
                    print(f"\nError in main loop: {str(e)}")
                    time.sleep(5)  # Wait before retrying
            
        except Exception as e:
            print(f"\nError in main function: {str(e)}")
            import traceback
            print(f"Traceback: {traceback.format_exc()}")
            time.sleep(5)  # Wait before retrying

if __name__ == "__main__":
    predictor = WeatherPredictor()
    predictor.run() 