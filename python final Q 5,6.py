import pandas as pd
from sklearn.ensemble import IsolationForest
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error, r2_score

# STEP 1: Load Data
df = pd.read_csv("multi_sensor_data.csv")

print("Data Preview:")
print(df.head())

# -------------------------------
# ✅ Q5: ANOMALY DETECTION
# -------------------------------

features = ["Temperature", "Vibration", "Pressure", "EnergyConsumption", "ProductionUnits"]
X = df[features]

# Handle missing values
X = X.fillna(X.mean())

# Train Isolation Forest
model = IsolationForest(contamination=0.3, random_state=42)
df["anomaly"] = model.fit_predict(X)

# Filter anomalies
anomalies = df[df["anomaly"] == -1]

print("\nAnomalies:")
print(anomalies[["Timestamp", "MachineID"]])

# Save top anomalies
anomalies.head(200).to_csv("top_200_anomalies.csv", index=False)

# -------------------------------
# ✅ Q6: HEALTH SCORE + REGRESSION
# -------------------------------

# Create HealthScore
df["HealthScore"] = (
    0.3 * df["Temperature"] +
    0.2 * df["Vibration"] +
    0.2 * df["Pressure"] +
    0.2 * df["EnergyConsumption"] +
    0.1 * df["Defects"]
)

# Features & Target
X = df[["Temperature", "Vibration", "Pressure", "EnergyConsumption", "ProductionUnits"]]
y = df["HealthScore"]

# Split data
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)

# Train model
reg_model = LinearRegression()
reg_model.fit(X_train, y_train)

# Predict
y_pred = reg_model.predict(X_test)

# Evaluation
print("\nModel Performance:")
print("MSE:", mean_squared_error(y_test, y_pred))
print("R2 Score:", r2_score(y_test, y_pred))

# Feature Importance
importance = pd.DataFrame({
    "Feature": X.columns,
    "Coefficient": reg_model.coef_
})

print("\nFeature Importance:")
print(importance)