#include "Adafruit_TCS34725.h"
#include <Wire.h>
#define TCAADDR0 0x70 // Multiplexor address 00

Adafruit_TCS34725 tcsX = Adafruit_TCS34725(TCS34725_INTEGRATIONTIME_24MS, TCS34725_GAIN_4X);
struct CRGB {
  Adafruit_TCS34725 tcsX = Adafruit_TCS34725(TCS34725_INTEGRATIONTIME_24MS, TCS34725_GAIN_4X);
  uint16_t Clear;
  uint16_t Red;
  uint16_t Green;
  uint16_t Blue;
  uint16_t cct;
  uint16_t lux;
};

int note1;

CRGB tcs[2];

void tcaselect(uint8_t i) {
  Wire.beginTransmission(TCAADDR0);
  Wire.write(1 << i);
  Wire.endTransmission();
  delay(1);
}

void readSensors(int channel1, int channel2) {
  int channels[2] = {channel1, channel2};
  
  for (int i = 0; i < 2; i++)
  {
    tcaselect(channels[i]);
    tcs[i].tcsX.setInterrupt(false);
    delay(60);
    tcs[i].tcsX.getRawData(&tcs[i].Red, &tcs[i].Green, &tcs[i].Blue, &tcs[i].Clear);

    tcs[i].cct = tcs[i].tcsX.calculateColorTemperature(tcs[i].Red, tcs[i].Green, tcs[i].Blue);
    tcs[i].lux = tcs[i].tcsX.calculateLux(tcs[i].Red, tcs[i].Green, tcs[i].Blue);
    tcs[i].tcsX.setInterrupt(false);
  }

}

void printCRGB() {
  for (int b = 0; b < 2; b++) {
    int note;
       
    if ((tcs[b].Red > tcs[b].Green) and (tcs[b].Red > tcs[b].Blue) and (tcs[b].Red > 1000)) {
      // Red
      note = (b+1)*100 + 0;
    } else if ((tcs[b].Green > tcs[b].Red) and (tcs[b].Green > tcs[b].Blue) and (tcs[b].Green > 1000)) {
      // Green
      note = (b+1)*100 + 1;
    } else if ((tcs[b].Blue > tcs[b].Green) and  (tcs[b].Blue > tcs[b].Red) and (tcs[b].Blue > 1000)) {
      // Blue
      note = (b+1)*100 + 2;
    } else {
      // Whatever
      note=-1;
    }
    
    if (note != -1) { 
      char c = (char)note;
      Serial.println(c);
    }
  }
}

void setup() {
  Serial.begin(9600);
  Wire.begin();
  for (int i = 0; i < 2; i++) {
    tcs[i].tcsX.setInterrupt(false); //turn on LED
  }
}


void loop() {
  readSensors(0, 7);
  printCRGB();
}
