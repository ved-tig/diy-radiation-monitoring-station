#include <Wire.h>
#include <Adafruit_MPL115A2.h>

Adafruit_MPL115A2 mpl115a2;

void setup(void) 
{
  Serial.begin(9600);
 
  if (! mpl115a2.begin()) {
    Serial.println("Sensor not found! Check wiring");
    while (1);
  }
  delay(2000);
}

void loop(void){
  float med_P = 0, med_T = 0;
  float pressureKPA = 0, temperatureC = 0, offset;    
  int i, n_med, interval_med;

  n_med = 2; //numero de medições total
  offset = 2.5; // offset do sensor de temperatura
  interval_med = 2; //intervalo entre medições, em segundos

  //tempo para receber cada medição: n_med * interval med (segundos)

  for (i=0;i<n_med;i++){
    mpl115a2.getPT(&pressureKPA,&temperatureC);

    med_T += temperatureC + offset;
    med_P += pressureKPA *10; //para milibar
    delay(interval_med *1000);
  }

  med_T = med_T /n_med;
  med_P = med_P /n_med;

  Serial.print("Pressure (kPa): "); Serial.print(med_P, 4); Serial.print(" kPa  ");
  Serial.print("Temp (*C): "); Serial.print(med_T, 1); Serial.println(" *C");
  
  
  
  
}
