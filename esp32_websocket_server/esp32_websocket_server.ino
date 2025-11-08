#include <WiFiManager.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include <Preferences.h>

// -------------------- CONFIG --------------------
const int resetPin = 0;  // GPIO0 or another button pin for WiFi reset
const char* firebaseHost = "https://zygreeen-default-rtdb.asia-southeast1.firebasedatabase.app"; // No trailing slash
const char* firebaseAuth = "FU3LTXixX9slqmCMrd9W0wPekel7WskEO5urppFN"; // Firebase database secret
Preferences preferences;
String deviceId;
// -------------------------------------------------

WiFiManager wifiManager;

void setup() {
  Serial.begin(115200);
  pinMode(resetPin, INPUT_PULLUP);

  // Check WiFi reset button
  checkResetButton();

  // Generate or retrieve unique device ID
  preferences.begin("device", false);
  if (preferences.isKey("id")) {
    deviceId = preferences.getString("id");
  } else {
    deviceId = WiFi.macAddress();
    deviceId.replace(":", "");
    preferences.putString("id", deviceId);
  }
  preferences.end();
  Serial.println("Device ID: " + deviceId);

  // Connect to WiFi
  Serial.println("Connecting WiFi using WiFiManager...");
  if (!wifiManager.autoConnect("ESP32_Setup")) {
    Serial.println("Failed to connect, restarting...");
    delay(3000);
    ESP.restart();
  }

  Serial.println("✅ WiFi Connected!");
  Serial.print("IP Address: ");
  Serial.println(WiFi.localIP());
}

void loop() {
  if (WiFi.status() == WL_CONNECTED) {
    // Simulate sensor readings
    float temperature = random(200, 300) / 10.0; // 20–30°C
    float humidity    = random(400, 700) / 10.0; // 40–70%
    int airQuality    = random(0, 100);          // 0–100 AQI
    int pm25          = random(0, 150);          // PM2.5 µg/m3
    int pm10          = random(0, 200);          // PM10 µg/m3

    sendToFirebase(temperature, humidity, airQuality, pm25, pm10);
  } else {
    Serial.println("WiFi Disconnected. Retrying...");
    delay(2000);
  }

  delay(5000); // Send every 5 seconds
}

// -----------------------------------------------------
// SEND DATA TO FIREBASE
// -----------------------------------------------------
void sendToFirebase(float temp, float hum, int air, int pm25, int pm10) {
  if (WiFi.status() != WL_CONNECTED) return;

  HTTPClient http;
  // Only latest reading node
  String latestUrl = String(firebaseHost) + "/devices/" + deviceId + "/latest.json?auth=" + firebaseAuth;

  // Prepare JSON payload
  StaticJsonDocument<256> doc;
  doc["temperature"] = temp;
  doc["humidity"] = hum;
  doc["airQuality"] = air;
  doc["pm25"] = pm25;
  doc["pm10"] = pm10;
  doc["timestamp"] = millis();

  String payload;
  serializeJson(doc, payload);

  // PUT latest
  http.begin(latestUrl);
  http.addHeader("Content-Type", "application/json");
  int code = http.PUT(payload);
  if (code == 200) {
    Serial.println("✅ Latest data sent successfully");
  } else {
    Serial.printf("⚠️ Error sending data: %s\n", http.errorToString(code).c_str());
  }
  http.end();

  Serial.println(payload);
}

// -----------------------------------------------------
// CHECK WIFI RESET BUTTON
// -----------------------------------------------------
void checkResetButton() {
  unsigned long start = millis();
  bool resetTriggered = false;
  while (millis() - start < 5000) {
    if (digitalRead(resetPin) == LOW) {
      resetTriggered = true;
      break;
    }
    delay(100);
  }

  if (resetTriggered) {
    Serial.println("Button pressed! Resetting WiFi credentials...");
    wifiManager.resetSettings();
    delay(1000);
    ESP.restart();
  }
}
