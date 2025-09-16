import processing.serial.*; 
import java.util.ArrayList;

Serial minhaPorta; 
String dadoSerial = ""; 
String data = "";

// Arrays para guardar os valores
ArrayList<Float> tempList = new ArrayList<Float>();
ArrayList<Float> pressList = new ArrayList<Float>();
ArrayList<Long> timeList = new ArrayList<Long>(); 

// Tempo inicial de referência(ms)
long startTime;

void setup() {
  int s = second();
  int m = minute();
  int h = hour();
  int mon = month();
  int d = day();
  int y = year();
  
  data = d + "/" + mon + "/"+ y+" " +  h + ":"+ m + ":"+ s; 
  
  size(1200, 600);
  printArray(Serial.list()); 
  
  minhaPorta = new Serial(this, Serial.list()[4], 9600);
  minhaPorta.bufferUntil('\n');

  startTime = System.currentTimeMillis(); 
}

void draw() {
  background(0);
  fill(255);
  textSize(20);
  textAlign(LEFT, TOP);
  text("Dado bruto: " + dadoSerial, 20, 10);
  text("Amostras: " + tempList.size(), 20, 40);

  // Desenha os gráficos
  drawGraph(tempList, color(0, 150, 255), "Temperatura (°C)", 100);
  drawGraph(pressList, color(255, 60, 60), "Pressão (mBar)", 370);
}

void drawGraph(ArrayList<Float> dataList, color graphColor, String label, int offsetY) {
  int graphX = 70;
  int graphY = offsetY;
  int graphW = width - 120;
  int graphH = 200;

  stroke(200);
  noFill();
  rect(graphX, graphY, graphW, graphH);

  if (timeList.size() < 2 || dataList.size() < 2) return;

  float[] dataArray = new float[dataList.size()];
  for (int i = 0; i < dataList.size(); i++) {
    dataArray[i] = dataList.get(i);
  }

  float maxY = max(dataArray);
  float minY = min(dataArray);

  long startX = timeList.get(0);
  long endX = timeList.get(timeList.size() - 1);
  long rangeX = endX - startX;
  if (rangeX == 0) rangeX = 1; 

  // Eixo Y
  int numYTicks = 5;
  fill(255);
  textAlign(RIGHT, CENTER);
  for (int i = 0; i <= numYTicks; i++) {
    float yVal = lerp(minY, maxY, i / float(numYTicks));
    float y = map(yVal, minY, maxY, graphY + graphH, graphY);
    stroke(80);
    line(graphX - 5, y, graphX, y);
    noStroke();
    text(nf(yVal, 1, 1), graphX - 10, y);
  }

  // Eixo X - mostrando horas
  int numXTicks = 6;
  textAlign(CENTER, TOP);
  for (int i = 0; i <= numXTicks; i++) {
    long tVal = (long)lerp(0, rangeX, i / float(numXTicks));
    float x = map(tVal, 0, rangeX, graphX, graphX + graphW);
    stroke(80);
    line(x, graphY + graphH, x, graphY + graphH + 5);
    noStroke();
    text(timestampToTime(startX + tVal), x, graphY + graphH + 8);
  }

  // Legenda
  fill(graphColor);
  textAlign(LEFT, CENTER);
  text(label, graphX + 10, graphY - 30);

  // Linha do gráfico
  stroke(graphColor);
  strokeWeight(2);
  for (int i = 1; i < timeList.size(); i++) {
    float x1 = map(timeList.get(i - 1) - startX, 0, rangeX, graphX, graphX + graphW);
    float y1 = map(dataList.get(i - 1), minY, maxY, graphY + graphH, graphY);
    float x2 = map(timeList.get(i) - startX, 0, rangeX, graphX, graphX + graphW);
    float y2 = map(dataList.get(i), minY, maxY, graphY + graphH, graphY);
    line(x1, y1, x2, y2);
  }
}

void serialEvent(Serial p) {
  dadoSerial = trim(p.readStringUntil('\n'));

  String pattern = "Pressure \\(kPa\\): ([0-9.\\-]+) kPa\\s+Temp \\(\\*C\\): ([0-9.\\-]+) \\*C";
  String[] valores = match(dadoSerial, pattern);

  if (valores != null) {
    float press = float(valores[1]);
    float temp = float(valores[2]);

    pressList.add(press);
    tempList.add(temp);

    long currentTime = System.currentTimeMillis();
    timeList.add(currentTime);

    println("Tempo: " + timestampToTime(currentTime) + 
            "  Pressão: " + press + " mBar  Temperatura: " + temp + " °C");
  } else {
    println("Formato inválido: " + dadoSerial);
  }
  
  salvarCSV();
}

void salvarCSV() {
  String[] linhas = new String[timeList.size() + 1];
  linhas[0] = "Tempo (HH:mm:ss);Pressão (mBar);Temperatura (°C);" + data;

  for (int i = 0; i < timeList.size(); i++) {
    linhas[i + 1] = timestampToTime(timeList.get(i)) + ";" +
                    nf(pressList.get(i), 1, 2) + ";" +
                    nf(tempList.get(i), 1, 2);
  }

  saveStrings("dadosPT.csv", linhas);
  println("Arquivo CSV salvo!");
}

// Converte timestamp (ms) para HH:mm:ss
String timestampToTime(long timestamp) {
  int s = int((timestamp / 1000) % 60);
  int m = int((timestamp / (1000 * 60)) % 60);
  int h = int((timestamp / (1000 * 60 * 60)) % 24);
  return nf(h, 2) + ":" + nf(m, 2) + ":" + nf(s, 2);
}
