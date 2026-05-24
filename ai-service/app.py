from flask import Flask, request, jsonify
import requests
import joblib
import numpy as np
from datetime import datetime
from datetime import datetime, timezone

app = Flask(__name__)

GOOGLE_ROUTES_API_KEY = "AIzaSyCJIl6U7WfUWcw8QjSQVKgPw-I-U7pl81I"
ORS_API_KEY = "eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6ImQyYjE0NDY1Y2FjNTQyMmI4OTkwNmY2OGJkYzc4NWFjIiwiaCI6Im11cm11cjY0In0="

# Load ML model
try:
    eta_model = joblib.load('eta_model.pkl')
    print("ML ETA model loaded successfully!")
except:
    eta_model = None
    print("No ML model found, using route duration only")

def get_distance_matrix(locations):
    """OpenRouteService fallback"""
    url = "https://api.openrouteservice.org/v2/matrix/driving-car"
    headers = {
        "Authorization": ORS_API_KEY,
        "Content-Type": "application/json"
    }
    body = {
        "locations": locations,
        "metrics": ["distance", "duration"]
    }
    response = requests.post(url, json=body, headers=headers)
    return response.json()

def get_traffic_duration(origin, destination):
    """Get real-time traffic duration using Google Routes API"""
    url = "https://routes.googleapis.com/directions/v2:computeRoutes"
    headers = {
        "Content-Type": "application/json",
        "X-Goog-Api-Key": GOOGLE_ROUTES_API_KEY,
        "X-Goog-FieldMask": "routes.duration,routes.distanceMeters"
    }
    body = {
        "origin": {
            "location": {
                "latLng": {
                    "latitude": origin[1],
                    "longitude": origin[0]
                }
            }
        },
        "destination": {
            "location": {
                "latLng": {
                    "latitude": destination[1],
                    "longitude": destination[0]
                }
            }
        },
        "travelMode": "DRIVE",
        "routingPreference": "TRAFFIC_AWARE",
        "departureTime": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    }

    response = requests.post(url, json=body, headers=headers)
    data = response.json()
    print("Google Routes API response:", data)

    if "routes" in data and len(data["routes"]) > 0:
        duration_str = data["routes"][0]["duration"]
        duration_seconds = int(duration_str.replace("s", ""))
        return duration_seconds / 60

    return None

@app.route("/optimize", methods=["POST"])
def optimize_route():
    data = request.json
    locations = data.get("locations")

    if not locations or len(locations) < 2:
        return jsonify({"error": "At least 2 locations required"}), 400

    # Try Google Routes API first for real-time traffic
    traffic_duration = None
    try:
        traffic_duration = get_traffic_duration(locations[0], locations[1])
        print(f"Google Routes API traffic duration: {traffic_duration} mins")
    except Exception as e:
        print(f"Google Routes API error: {e}")

    # Fall back to OpenRouteService if Google fails
    if traffic_duration is None:
        print("Falling back to OpenRouteService...")
        matrix = get_distance_matrix(locations)
        durations = matrix.get("durations")
        if not durations:
            return jsonify({"error": "Failed to get distance matrix"}), 500

        n = len(locations)
        visited = [False] * n
        route = [0]
        visited[0] = True

        for _ in range(n - 1):
            last = route[-1]
            nearest = None
            nearest_time = float("inf")
            for j in range(n):
                if not visited[j] and durations[last][j] < nearest_time:
                    nearest = j
                    nearest_time = durations[last][j]
            route.append(nearest)
            visited[nearest] = True

        total_duration = sum(
            durations[route[i]][route[i+1]] for i in range(len(route)-1)
        )
        traffic_duration = total_duration / 60

    return jsonify({
        "optimized_route": [0, 1],
        "total_duration_minutes": round(traffic_duration, 2),
        "total_duration_seconds": round(traffic_duration * 60, 2),
        "traffic_aware": True
    })

@app.route("/predict-eta", methods=["POST"])
def predict_eta():
    data = request.json

    estimated_time = data.get("estimated_time", 10)
    driver_experience = data.get("driver_experience", 0)
    driver_avg_time = data.get("driver_avg_time", estimated_time)

    now = datetime.now()
    hour_of_day = now.hour
    day_of_week = now.weekday()

    if eta_model is not None:
        features = np.array([[
            estimated_time,
            hour_of_day,
            day_of_week,
            driver_experience,
            driver_avg_time
        ]])
        predicted = eta_model.predict(features)[0]
        predicted = max(1, round(predicted))
    else:
        predicted = estimated_time

    return jsonify({
        "predicted_eta_minutes": predicted,
        "base_estimated_minutes": estimated_time,
        "hour_of_day": hour_of_day,
        "model_used": "RandomForest" if eta_model else "fallback"
    })

if __name__ == "__main__":
    app.run(port=5000, debug=True)