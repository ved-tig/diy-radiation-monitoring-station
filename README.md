# DIY Radiation Monitoring Station

**DIY radiation, pressure, and temperature monitoring station for environmental data collection, developed as part of the LIP internship program.**

This project aims to build a station for monitoring ambient radiation, pressure, and temperature using affordable sensors and microcontrollers. The code was developed as part of an internship at **Laboratório de Instrumentação e Física Experimental de Partículas (LIP)**.

## Repository Structure

The repository is organized into the following folders:

1. **`arduino_code/`**: Contains the Arduino code for controlling the radiation, pressure, and temperature sensors.
2. **`processing_code/`**: Contains the Processing code to visualize real-time data collected from the sensors.
3. **`circuit_diagram/`**: Contains the wiring diagram for correctly connecting the sensors to the Arduinos.

## Setup Instructions

### Step 1: Check Connections

Before running the code, **check the Arduino channels** after connecting them to the computer or Raspberry Pi. This will ensure each Arduino is connected to the correct sensor.

- Identify the ports of the Arduinos that will be used to control the sensors and make a note of them.

### Step 2: Connect the Sensors

Refer to the wiring diagram in the **`circuit_diagram/`** folder to correctly connect the sensors to the Arduinos. Ensure all wires are connected as shown in the diagram to avoid issues.

### Step 3: Upload the Arduino Code

1. Open the **Arduino code** files from the **`arduino_code/`** folder.
2. **Upload the code** to each Arduino corresponding to the sensors.
3. Verify that the code is correctly uploaded by checking if the indicator lights on the Arduinos turn on.

### Step 4: Run the Processing Code

Once the Arduino codes are uploaded, it’s time to run the **Processing code**.

1. Open the files in the **`processing_code/`** folder.
2. Ensure the correct serial port is configured for each Arduino.
3. Run the code in **Processing** to begin visualizing the sensor data in real time.

### Step 5: Monitoring

- After launching the **Processing apps**, you will start seeing the radiation, pressure, and temperature data displayed as the sensors collect environmental information.
- The visualization will allow you to monitor the data in real time.

## How to Contribute

Feel free to contribute improvements, bug fixes, or new features! To contribute, follow these steps:

1. Fork this repository.
2. Create a new **branch** for your modification:  
   `git checkout -b my-modification`
3. Make the necessary changes and **commit**:  
   `git commit -am 'Adding my modification'`
4. Push your **branch** to GitHub:  
   `git push origin my-modification`
5. Open a **pull request** explaining your changes.

