#include <ArduinoBLE.h>

#define DISPLAY_NAME "Fake Kilter Board"
#define API_LEVEL 3
#define ADVERTISING_SERVICE_UUID "4488B571-7806-4DF6-BCFF-A2897E4953FF"
#define DATA_TRANSFER_SERVICE_UUID "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
#define DATA_TRANSFER_CHARACTERISTIC "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"

BLEService advertisingService(ADVERTISING_SERVICE_UUID);
BLEService dataTransferService(DATA_TRANSFER_SERVICE_UUID);
BLECharacteristic dataTransferCharacteristic(DATA_TRANSFER_CHARACTERISTIC, BLEWrite, 20);

void setup() {
  Serial.begin(115200);
  while (!Serial);  // Wait for serial port to connect

  // Send initial API level
  Serial.write(4);
  Serial.write(API_LEVEL);

  char boardName[2 + sizeof(DISPLAY_NAME)];
  snprintf(boardName, sizeof(boardName), "%s%s%d", DISPLAY_NAME, "@", API_LEVEL);

  if (!BLE.begin()) {
    Serial.println("Starting BLE failed!");
    while (1);
  }

  BLE.setLocalName(boardName);
  BLE.setAdvertisedService(advertisingService);
  
  dataTransferService.addCharacteristic(dataTransferCharacteristic);
  
  BLE.addService(advertisingService);
  BLE.addService(dataTransferService);

  dataTransferCharacteristic.setEventHandler(BLEWritten, characteristicWritten);

  BLE.advertise();
}

void loop() {
  BLE.poll();

  if (Serial.available() > 0) {
    int inByte = Serial.read();
    if (inByte == 4) {
      // Respond with API level
      Serial.write(4);
      Serial.write(API_LEVEL);
    }
  }
}

void characteristicWritten(BLEDevice central, BLECharacteristic characteristic) {
  if (characteristic.uuid() == DATA_TRANSFER_CHARACTERISTIC) {
    const uint8_t* value = characteristic.value();
    int len = characteristic.valueLength();
    Serial.write(value, len);
  }
}