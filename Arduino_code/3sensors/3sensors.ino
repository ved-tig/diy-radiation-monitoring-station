/*************************************************** 
  This is a library for the Si1145 UV/IR/Visible Light Sensor

  Designed specifically to work with the Si1145 sensor in the
  adafruit shop
  ----> https://www.adafruit.com/products/1777

  These sensors use I2C to communicate, 2 pins are required to  
  interface
  Adafruit invests time and resources providing this open source code, 
  please support Adafruit and open-source hardware by purchasing 
  products from Adafruit!

  Written by Limor Fried/Ladyada for Adafruit Industries.  
  BSD license, all text above must be included in any redistribution
 ****************************************************/

#include <Wire.h>
#include "Adafruit_SI1145.h"

#include <Adafruit_Sensor.h>
#include <Adafruit_TSL2561_U.h>
//#include <Adafruit_MPL115A2.h>

int UVOUT = A0; //Output from the sensor
int REF_3V3 = A1; //3.3V power on the Arduino board


Adafruit_TSL2561_Unified tsl = Adafruit_TSL2561_Unified(TSL2561_ADDR_FLOAT, 12345);
Adafruit_SI1145 uv = Adafruit_SI1145();

void displaySensorDetails(void)
{
  sensor_t sensor;
  tsl.getSensor(&sensor);
}

void configureSensor(void)
{
  /* You can also manually set the gain or enable auto-gain support */
  // tsl.setGain(TSL2561_GAIN_1X);      /* No gain ... use in bright light to avoid sensor saturation */
  // tsl.setGain(TSL2561_GAIN_16X);     /* 16x gain ... use in low light to boost sensitivity */
  tsl.enableAutoRange(true);            /* Auto-gain ... switches automatically between 1x and 16x */
  
  /* Changing the integration time gives you better sensor resolution (402ms = 16-bit data) */
  //tsl.setIntegrationTime(TSL2561_INTEGRATIONTIME_13MS);      /* fast but low resolution */
  // tsl.setIntegrationTime(TSL2561_INTEGRATIONTIME_101MS);  /* medium resolution and speed   */
   tsl.setIntegrationTime(TSL2561_INTEGRATIONTIME_402MS);  /* 16-bit data but slowest conversions */

}

void setup() {
  Serial.begin(9600);
  pinMode(UVOUT, INPUT);
  pinMode(REF_3V3, INPUT);
  
  if (! uv.begin()) {
    Serial.println("Didn't find Si1145");
    while (1);
  }
  if(!tsl.begin())
  {
    /* There was a problem detecting the TSL2561 ... check your connections */
    Serial.print("Ooops, no TSL2561 detected ... Check your wiring or I2C ADDR!");
    while(1);
  }
  
  /* Setup the sensor gain and integration time */
  configureSensor();

 delay(2000);
}

void loop() {
  float med_vis = 0, med_IR = 0, med_UV = 0, med_lux = 0, med_index = 0;

  int i, n_med, interval_med;

  n_med = 2; //numero de medições total
  
  interval_med = 2; //intervalo entre medições, em segundos
  
  /* Get a new sensor event */ 
  sensors_event_t event;
  tsl.getEvent(&event);

  //tempo para receber cada medição: n_med * interval med (segundos)

  for (i=0;i<n_med;i++){

    med_vis += uv.readVisible();
    med_IR += uv.readIR();
    med_UV += uv.readUV();
    med_lux += event.light;

    
    int uvLevel = averageAnalogRead(UVOUT);
    int refLevel = averageAnalogRead(REF_3V3);

    //Use the 3.3V power pin as a reference to get a very accurate output value from sensor
    float outputVoltage = 3.3 / refLevel * uvLevel;

    float uvIntensity = mapfloat(outputVoltage, 0.99, 2.8, 0.0, 15.0); //Convert the voltage to a UV intensity level

    med_index += uvIntensity;

    delay(interval_med *1000);
  }

  med_vis = med_vis/n_med;
  med_IR = med_IR/n_med;
  med_UV = med_UV/n_med / 100;
  med_lux = med_lux / n_med;
  med_index = med_index/ n_med;
  

  Serial.print("Vis: "); Serial.print(med_vis);
  Serial.print(" IR: "); Serial.print(med_IR);
  Serial.print(" UV: ");  Serial.print(med_UV);
  Serial.print(" lux: ");   Serial.print(med_lux); 
  
  
  Serial.print(" UV Intensity (mW/cm^2): ");
  Serial.print(med_index);

  Serial.println();
  Serial.println();
  
}
int averageAnalogRead(int pinToRead)
{
  byte numberOfReadings = 8;
  unsigned int runningValue = 0; 

  for(int x = 0 ; x < numberOfReadings ; x++)
    runningValue += analogRead(pinToRead);
  runningValue /= numberOfReadings;

  return(runningValue);  
}

//The Arduino Map function but for floats
//From: http://forum.arduino.cc/index.php?topic=3922.0
float mapfloat(float x, float in_min, float in_max, float out_min, float out_max)
{
  return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}
