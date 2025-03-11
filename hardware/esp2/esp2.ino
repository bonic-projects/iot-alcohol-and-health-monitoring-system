#include <Arduino.h>
#include <OneWire.h>
#include <DallasTemperature.h>
#include <Wire.h>
#include <WiFi.h>
#include <FirebaseESP32.h>
#include "MAX30100_PulseOximeter.h"

#define REPORTING_PERIOD_MS 1000

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

// Pulse Oximeter Setup
PulseOximeter pox;
uint32_t tsLastReport = 0;
uint32_t tsLastTempRead = 0; // Separate timing for temperature updates
unsigned long sendDataPrevMillis = 0; // Timing for Firebase uploads

// Sensor Data
float temperature = 0;
int mq3_value = 0;
float bpm = 0;
float spo2 = 0;

void firebaseSetup() {
    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
    Serial.print("Connecting to Wi-Fi");
    while (WiFi.status() != WL_CONNECTED) {
        Serial.print(".");
        delay(300);
        pox.update(); // Keep MAX30100 alive during Wi-Fi connection
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
        pox.update(); // Keep MAX30100 alive during UID fetch
    }
    uid = auth.token.uid.c_str();
    Serial.println("User UID: " + uid);
    path = "devices/" + uid + "/reading";
}

void onBeatDetected() {
    Serial.println("Beat!");
}

void setup() {
    Serial.begin(115200);

    firebaseSetup(); // Initialize Wi-Fi and Firebase

    Serial.print("Initializing pulse oximeter...");
    if (!pox.begin()) {
        Serial.println("FAILED");
        for (;;);  // Stop execution if sensor fails
    }
    Serial.println("SUCCESS");
    pox.setIRLedCurrent(MAX30100_LED_CURR_7_6MA); 
    pox.setOnBeatDetectedCallback(onBeatDetected);

    delay(100); // Small delay to stabilize I2C before initializing temp sensor
    tempSensor.begin();
}

void loop() {
    pox.update(); // Call this as frequently as possible

    // Print sensor values and update MAX30100 data every second
    if (millis() - tsLastReport > REPORTING_PERIOD_MS) {
        bpm = pox.getHeartRate();
        spo2 = pox.getSpO2();

        Serial.print("Heart rate: ");
        Serial.print(bpm);
        Serial.print(" bpm / SpO2: ");
        Serial.print(spo2);
        Serial.println("%");

        Serial.print("Temperature: ");
        Serial.print(temperature);
        Serial.print(" °C / MQ3 Value: ");
        Serial.println(mq3_value);

        tsLastReport = millis();
        updatedata(); // Call updatedata after printing
    }

    pox.update(); // Additional call to ensure frequent updates
}

void readdata() {
    if (millis() - tsLastTempRead > 2000) {  
        tempSensor.requestTemperatures();
        temperature = tempSensor.getTempCByIndex(0);
        tsLastTempRead = millis();
    }
    mq3_value = analogRead(MQ3_PIN); 
}

void updatedata() {
    readdata(); // Read sensor data

    if (Firebase.ready() && (millis() - sendDataPrevMillis > 10000)) {
        sendDataPrevMillis = millis();
        FirebaseJson json;
        json.set("temperature", temperature);
        json.set("alcohol", mq3_value);
        json.set("bpm", bpm);
        json.set("oxygen", spo2);
        json.set(F("ts/.sv"), F("timestamp"));

        // Print data being sent for debugging
        Serial.print("Sending to Firebase - BPM: ");
        Serial.print(bpm);
        Serial.print(", SpO2: ");
        Serial.println(spo2);

        if (Firebase.setJSON(fbdo, path.c_str(), json)) {
            Serial.println("Data upload success");
        } else {
            Serial.println("Data upload failed: " + fbdo.errorReason());
        }
        delay(2000);  // Give some time to print the message
        reset_max30100();
    }
}

void reset_max30100() {
    Serial.println("Resetting MAX30100 Sensor...");
    pox.shutdown();  // Turn off the sensor
    delay(500);
    pox.begin();  // Restart the sensor
    pox.setIRLedCurrent(MAX30100_LED_CURR_7_6MA);
    pox.setOnBeatDetectedCallback(onBeatDetected);
    Serial.println("MAX30100 Sensor Reset Done!");
}