import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_absolute_error
import joblib
import psycopg2
from dotenv import load_dotenv
import os
from pathlib import Path
from pathlib import Path 

env_path = Path(__file__).parent / ".env"
load_dotenv(dotenv_path=env_path)

# Connect to database
conn = psycopg2.connect(
    host="localhost",
    database=os.getenv("DB_NAME", "ai_logistics_db"),
    user=os.getenv("DB_USER", "postgres"),
    password=os.getenv("DB_PASSWORD"),
    port=os.getenv("DB_PORT", 5432)
)

# Fetch completed deliveries with real data
query = """
    SELECT 
        d.estimated_time,
        d.actual_delivery_time,
        EXTRACT(HOUR FROM d.created_at) AS hour_of_day,
        EXTRACT(DOW FROM d.created_at) AS day_of_week,
        dr.id AS driver_id,
        COUNT(prev.id) AS driver_experience,
        COALESCE(AVG(prev.actual_delivery_time), 0) AS driver_avg_time
    FROM deliveries d
    JOIN drivers dr ON d.driver_id = dr.id
    LEFT JOIN deliveries prev ON prev.driver_id = dr.id 
        AND prev.status = 'delivered'
        AND prev.created_at < d.created_at
    WHERE d.status = 'delivered'
        AND d.actual_delivery_time IS NOT NULL
        AND d.estimated_time IS NOT NULL
    GROUP BY d.id, d.estimated_time, d.actual_delivery_time, 
             d.created_at, dr.id
"""

df = pd.read_sql(query, conn)
conn.close()

print(f"Training data: {len(df)} completed deliveries")

if len(df) < 5:
    print("Not enough data yet! Need at least 5 completed deliveries.")
    print("Generating synthetic training data for now...")
    
    # Generate synthetic data based on realistic patterns
    np.random.seed(42)
    n = 100
    
    estimated = np.random.randint(3, 30, n)
    hour = np.random.randint(0, 24, n)
    day = np.random.randint(0, 7, n)
    experience = np.random.randint(0, 50, n)
    avg_time = estimated * np.random.uniform(0.8, 1.4, n)
    
    # Rush hour factor
    rush_hour = ((hour >= 7) & (hour <= 9)) | ((hour >= 16) & (hour <= 19))
    actual = estimated * np.random.uniform(0.9, 1.3, n)
    actual[rush_hour] *= 1.3  # 30% longer during rush hour
    actual = actual.astype(int)
    
    df = pd.DataFrame({
        'estimated_time': estimated,
        'hour_of_day': hour,
        'day_of_week': day,
        'driver_experience': experience,
        'driver_avg_time': avg_time,
        'actual_delivery_time': actual
    })

# Features and target
features = ['estimated_time', 'hour_of_day', 'day_of_week', 
            'driver_experience', 'driver_avg_time']
X = df[features]
y = df['actual_delivery_time']

# Train/test split
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

# Train Random Forest model
model = RandomForestRegressor(
    n_estimators=100,
    max_depth=10,
    random_state=42
)
model.fit(X_train, y_train)

# Evaluate
y_pred = model.predict(X_test)
mae = mean_absolute_error(y_test, y_pred)
print(f"Model trained! Mean Absolute Error: {mae:.2f} minutes")

# Feature importance
print("\nFeature Importance:")
for feat, imp in zip(features, model.feature_importances_):
    print(f"  {feat}: {imp:.3f}")

# Save model
model_path = Path(__file__).parent / "eta_model.pkl"
joblib.dump(model, model_path)
print("\nModel saved to eta_model.pkl")