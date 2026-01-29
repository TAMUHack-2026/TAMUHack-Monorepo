#include <SoftwareSerial.h>

// Global variables

// HM-10 / BT05 wiring example:
// BLE TX -> Arduino D10 (RX)
// BLE RX -> Arduino D11 (TX)  (use voltage divider!)
SoftwareSerial BLE(0, 1); // RX, TX

const uint8_t VOLTAGE_PORT = A2;
const float CONVERSION_FACTOR = 5.0/1023.0;

void setup() {
  BLE.begin(9600);
}

void loop() {
  // Compute start time
  unsigned long start_time = millis();
  // Retrieve voltage from port
  float voltage = analogRead(VOLTAGE_PORT) * CONVERSION_FACTOR;
  // Split voltage into 4 bytes
  if (voltage > 0) {
    uint8_t* split = (uint8_t*)(&voltage);
    for (uint8_t i = 0; i < sizeof(float); i++) {
      BLE.write(split[i]);
      delay(100);
    }
  }
  // Ensure that sample rate is 10ms
  // delay(50 - millis() + start_time);
}