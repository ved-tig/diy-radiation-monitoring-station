# diy-radiation-monitoring-station
DIY radiation, pressure, and temperature monitoring station for environmental data collection, developed as part of the LIP internship program.

# Setup
After connecting the sensors according to the wiring diagram and connecting each Arduino/ microprocessor, run the respective Arduino codes for each one.

Open each processing file. The `minhaPorta = new Serial(this, Serial.list()[x], 9600);` excerpt of the file may need to be changed depending on the port of the Arduinos or other connected devices.

If the ports are correct, the programs will run and display all data taken and save it into an .csv in the folder of each processing file
