#include <Arduino.h>
#include <OneWire.h>
#include <DallasTemperature.h>
#include <Wire.h>
#include <WiFi.h>
#include <FirebaseESP32.h>

// Wi-Fi and Firebase Credentials
#define WIFI_SSID "Autobonics_4G"
#define WIFI_PASSWORD "autobonics@27"
#define API_KEY "AIzaSyBxP7VheiLqEq2PWQHspH1ij0Pi-BkIFiM"
#define DATABASE_URL "https://alcohol-health-monitoring-default-rtdb.firebaseio.com"
#define USER_EMAIL "device@gmail.com"
#define USER_PASSWORD "12345678"

// Sensor Pins
#define ONE_WIRE_BUS 13  // DS18B20 temperature sensor
#define MQ3_PIN 35       // MQ3 gas sensor

// Firebase Objects
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;
String uid;
String path;

// Temperature Sensor Setup
OneWire oneWire(ONE_WIRE_BUS);
DallasTemperature tempSensor(&oneWire);

// Sensor Data
float temperature = 0;
int mq3_value = 0;

void firebaseSetup() {
    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
    Serial.print("Connecting to Wi-Fi");
    while (WiFi.status() != WL_CONNECTED) {
        Serial.print(".");
        delay(300);
    }
    Serial.println("\nConnected with IP: " + WiFi.localIP().toString());

    config.api_key = API_KEY;
    auth.user.email = USER_EMAIL;
    auth.user.password = USER_PASSWORD;
    config.database_url = DATABASE_URL;
    Firebase.begin(&config, &auth);
    Firebase.reconnectWiFi(true);
    fbdo.setResponseSize(2048);

    Serial.println("Getting User UID...");
    while ((auth.token.uid) == "") {
        Serial.print('.');
        delay(1000);
    }
    uid = auth.token.uid.c_str();
    Serial.println("User UID: " + uid);
    path = "devices/" + uid + "/reading";
}

void setup() {
    Serial.begin(115200);
    firebaseSetup(); // Initialize Wi-Fi and Firebase
    delay(100);
    tempSensor.begin();
}

void loop() {
    // Print sensor values and update every second
    if (millis() % 1000 == 0) {
        Serial.print("Temperature: ");
        Serial.print(temperature);
        Serial.print(" °C / MQ3 Value: ");
        Serial.println(mq3_value);
        updatedata();
    }
}

void readdata() {
    tempSensor.requestTemperatures();
    temperature = tempSensor.getTempCByIndex(0);
    mq3_value = analogRead(MQ3_PIN);
    if (mq3_value < 2000) {
        mq3_value = 0;
    }
}

void updatedata() {
    readdata(); // Read sensor data
    static unsigned long sendDataPrevMillis = 0;
    if (Firebase.ready() && (millis() - sendDataPrevMillis > 2000)) {
        sendDataPrevMillis = millis();
        FirebaseJson json;
        json.set("temperature", temperature);
        json.set("alcohol", mq3_value);
        json.set(F("ts/.sv"), F("timestamp"));

        if (Firebase.setJSON(fbdo, path.c_str(), json)) {
            Serial.println("Data upload success");
        } else {
            Serial.println("Data upload failed: " + fbdo.errorReason());
        }
    }
}
