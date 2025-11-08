#include <WiFiManager.h>          
#include <HTTPClient.h>
#include <ArduinoJson.h>

// -------------------- USER CONFIG --------------------
const int resetPin = 0;  // GPIO0 or another button pin for WiFi reset
const char* firebaseHost = "https://zygreeen-default-rtdb.asia-southeast1.firebasedatabase.app"; // No trailing slash
const char* firebaseAuth = "FU3LTXixX9slqmCMrd9W0wPekel7WskEO5urppFN"; // Remove leading/trailing spaces
const char* deviceId = "device_01"; // Unique per device
// -----------------------------------------------------

WiFiManager wifiManager;

void setup() {
  Serial.begin(115200);
  pinMode(resetPin, INPUT_PULLUP);

  Serial.println("Checking reset button...");
  checkResetButton(); // Will reset WiFi if button held

  Serial.println("Connecting WiFi using WiFiManager...");
  // This will start AP if no WiFi is saved or connection fails
  if (!wifiManager.autoConnect("ESP32_Setup")) {
    Serial.println("Failed to connect, restarting...");
    delay(3000);
    ESP.restart();
  }

  Serial.println("WiFi Connected!");
  Serial.print("IP Address: ");
  Serial.println(WiFi.localIP());
}

void loop() {
  if (WiFi.status() == WL_CONNECTED) {
    float temperature = random(200, 300) / 10.0; // 20°C–30°C
    float humidity    = random(400, 700) / 10.0; // 40%–70%
    int airQuality    = random(0, 100);          // 0–100

    sendToFirebase(temperature, humidity, airQuality);
  } else {
    Serial.println("WiFi Disconnected. Retrying...");
    delay(2000);
  }

  delay(5000); // Send every 5 seconds
}

// -----------------------------------------------------
//  SEND DATA TO FIREBASE
// -----------------------------------------------------
void sendToFirebase(float temp, float hum, int air) {
  if (WiFi.status() != WL_CONNECTED) return;

  HTTPClient http;
  String url = String(firebaseHost) + "/devices/" + deviceId + ".json?auth=" + firebaseAuth;
  http.begin(url);
  http.addHeader("Content-Type", "application/json");

  StaticJsonDocument<200> doc;
  doc["temperature"] = temp;
  doc["humidity"] = hum;
  doc["airQuality"] = air;
  doc["timestamp"] = millis();

  String payload;
  serializeJson(doc, payload);

  int httpResponseCode = http.PUT(payload); // Use PUT to overwrite the node
  Serial.printf("Firebase Response: %d\n", httpResponseCode);

  if (httpResponseCode == 200) {
    Serial.println("Data sent successfully:");
    Serial.println(payload);
  } else {
    Serial.printf("Error sending data: %s\n", http.errorToString(httpResponseCode).c_str());
  }

  http.end();
}

// -----------------------------------------------------
//  CHECK RESET BUTTON
// -----------------------------------------------------
void checkResetButton() {
  unsigned long start = millis();
  bool resetTriggered = false;

  while (millis() - start < 5000) { // Check for 5 seconds
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
