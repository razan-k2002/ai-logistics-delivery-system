from flask import Flask, request, jsonify
import requests

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

if __name__ == "__main__":
    app.run(port=5000, debug=True)