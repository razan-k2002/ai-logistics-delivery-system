from flask import Flask, request, jsonify
import requests
import joblib
import numpy as np
from datetime import datetime
# Load ML model
try:
    eta_model = joblib.load('eta_model.pkl')
    print("ML ETA model loaded successfully!")
except:
    eta_model = None
    print("No ML model found, using route duration only")
app = Flask(__name__)

ORS_API_KEY = "eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6ImQyYjE0NDY1Y2FjNTQyMmI4OTkwNmY2OGJkYzc4NWFjIiwiaCI6Im11cm11cjY0In0="

def get_distance_matrix(locations):
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

@app.route("/optimize", methods=["POST"])
def optimize_route():
    data = request.json
    locations = data.get("locations")  # list of [lng, lat] pairs

    if not locations or len(locations) < 2:
        return jsonify({"error": "At least 2 locations required"}), 400

    matrix = get_distance_matrix(locations)

    durations = matrix.get("durations")
    if not durations:
        return jsonify({"error": "Failed to get distance matrix"}), 500

    # Find optimal order using nearest neighbor algorithm
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

    return jsonify({
        "optimized_route": route,
        "total_duration_seconds": total_duration,
        "total_duration_minutes": round(total_duration / 60, 2)
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
# Load chatbot model
try:
    import pickle
    with open('chatbot/chatbot_model.pkl', 'rb') as f:
        chatbot_model = pickle.load(f)
    print("Chatbot model loaded successfully!")
except:
    chatbot_model = None
    print("No chatbot model found")

@app.route("/chat", methods=["POST"])
def chat():
    data = request.json
    message = data.get("message", "").lower().strip()
    user_role = data.get("role", "customer")

    if not message:
        return jsonify({"error": "No message provided"}), 400

    if chatbot_model is None:
        return jsonify({
            "intent": "unknown",
            "response": "Chatbot not available",
            "action": "NONE",
            "confidence": 0
        })

    # Predict intent
    intent = chatbot_model.predict([message])[0]
    confidence = max(chatbot_model.predict_proba([message])[0])

    # If confidence too low, return unknown
    if confidence < 0.4:
        return jsonify({
            "intent": "unknown",
            "response": "I'm not sure I understand. Can you rephrase your question?",
            "action": "NONE",
            "confidence": round(confidence, 2)
        })

    # Map intent to response and action
    responses = {
        "greeting": {
            "response": "Hello! I'm your AI logistics assistant. How can I help you today?",
            "action": "NONE"
        },
        "goodbye": {
            "response": "Goodbye! Have a great day!",
            "action": "NONE"
        },
        "help": {
            "customer": {
                "response": "I can help you with:\n- Track your delivery\n- Check ETA\n- Place a new order\n- Cancel a delivery",
                "action": "NONE"
            },
            "driver": {
                "response": "I can help you with:\n- Show your deliveries\n- Mark delivery as complete\n- Check your performance",
                "action": "NONE"
            },
            "admin": {
                "response": "I can help you with:\n- Check pending deliveries\n- Show available drivers\n- View system analytics",
                "action": "NONE"
            }
        },
        "track_order": {
            "response": "Let me fetch your latest delivery status.",
            "action": "FETCH_DELIVERY_STATUS"
        },
        "eta": {
            "response": "Let me check the estimated arrival time for your delivery.",
            "action": "FETCH_ETA"
        },
        "place_order": {
            "response": "I'll take you to the new delivery screen!",
            "action": "NAVIGATE_CREATE_DELIVERY"
        },
        "cancel_order": {
            "response": "I'll help you cancel your delivery.",
            "action": "CANCEL_DELIVERY"
        },
        "driver_deliveries": {
            "response": "Let me fetch your assigned deliveries.",
            "action": "FETCH_DRIVER_DELIVERIES"
        },
        "mark_delivered": {
            "response": "I'll mark your current delivery as complete.",
            "action": "MARK_DELIVERED"
        },
        "pending_deliveries": {
            "response": "Let me check the pending deliveries count.",
            "action": "FETCH_PENDING_COUNT"
        },
        "available_drivers": {
            "response": "Let me check driver availability.",
            "action": "FETCH_AVAILABLE_DRIVERS"
        },
        "performance": {
            "response": "Let me pull up the system analytics.",
            "action": "FETCH_ANALYTICS"
        }
    }

    # Get response based on intent
    if intent == "help" and isinstance(responses["help"], dict):
        result = responses["help"].get(user_role, responses["help"]["customer"])
    elif intent in responses:
        result = responses[intent]
    else:
        result = {
            "response": "I'm not sure how to help with that. Try asking about your delivery status or ETA.",
            "action": "NONE"
        }

    return jsonify({
        "intent": intent,
        "response": result["response"],
        "action": result["action"],
        "confidence": round(confidence, 2)
    })
if __name__ == "__main__":
    app.run(port=5000, debug=True)