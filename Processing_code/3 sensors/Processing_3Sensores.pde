import processing.serial.*;
import java.util.ArrayList;

Serial minhaPorta;
String dadoSerial = "";
String data = "";

// Listas de dados
ArrayList<Float> visList = new ArrayList<Float>();
ArrayList<Float> irList = new ArrayList<Float>();
ArrayList<Float> uvList = new ArrayList<Float>();
ArrayList<Float> luxList = new ArrayList<Float>();
ArrayList<Float> uvIntensityList = new ArrayList<Float>();
ArrayList<Long> timeList = new ArrayList<Long>(); 

// Tempo inicial de referência(ms)
long startTime; 

float scrollY = 0;
float maxScroll = 0;
float graphHeight = 220;
int graphSpacing = 20;

void setup() {
  size(1200, 600);
  printArray(Serial.list()); 
  minhaPorta = new Serial(this, Serial.list()[4], 9600);
  minhaPorta.bufferUntil('\n');

  int s = second();
  int m = minute();
  int h = hour();
  int mon = month();
  int d = day();
  int y = year();
  data = d + "/" + mon + "/"+ y+" " +  h + ":"+ m + ":"+ s; 

  startTime = System.currentTimeMillis(); 
}

void draw() {
  background(0);
  pushMatrix();
  translate(0, -scrollY);

  fill(255);
  textSize(20);
  textAlign(LEFT, TOP);
  text("Dado bruto: " + dadoSerial, 20, 10);
  text("Amostras: " + visList.size(), 20, 40);

  // Desenha os gráficos
  drawGraph(visList, color(0, 150, 255), "Vis (nm)", 100);
  drawGraph(irList, color(255, 100, 0), "IR (nm)", int(100 + graphHeight * 1 + graphSpacing));
  drawGraph(uvList, color(255, 0, 255), "UV (Index)", int(100 + graphHeight * 2 + graphSpacing * 2));
  drawGraph(luxList, color(200, 200, 0), "Lux (lumens)", int(100 + graphHeight * 3 + graphSpacing * 3));
  drawGraph(uvIntensityList, color(100, 255, 100), "UV Intensity (mW/cm^2)", int(100 + graphHeight * 4 + graphSpacing * 4));

  popMatrix();
  maxScroll = (graphHeight + graphSpacing) * 5 + 100 - height;
  maxScroll = max(0, maxScroll);
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  scrollY += e * 30;
  scrollY = constrain(scrollY, 0, maxScroll);
}

void drawGraph(ArrayList<Float> dataList, color graphColor, String label, int offsetY) {
  int graphX = 70;
  int graphY = offsetY;
  int graphW = width - 100;
  int graphH = 150;

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
    text(nf(yVal, 1, 2), graphX - 10, y);
  }

  // Eixo X (hora:minuto:segundo)
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

  fill(graphColor);
  textAlign(LEFT, CENTER);
  text(label, graphX + 10, graphY - 30);

  // Linhas do gráfico
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
  String linha = trim(p.readStringUntil('\n'));
  if (linha == null || linha.length() < 10) return;

  String pattern = "Vis: ([0-9.\\-]+) IR: ([0-9.\\-]+) UV: ([0-9.\\-]+) lux: ([0-9.\\-]+) UV Intensity \\(mW/cm\\^2\\): ([0-9.\\-]+)";
  String[] valores = match(linha, pattern);

  if (valores != null) {
    dadoSerial = linha;

    float vis = float(valores[1]);
    float ir = float(valores[2]);
    float uv = float(valores[3]);
    float lux = float(valores[4]);
    float uvIntensity = float(valores[5]);

    visList.add(vis);
    irList.add(ir);
    uvList.add(uv);
    luxList.add(lux);
    uvIntensityList.add(uvIntensity);

    long currentTime = System.currentTimeMillis();
    timeList.add(currentTime);

    println("Tempo: " + timestampToTime(currentTime) + "  Vis: " + vis + " IR: " + ir + " UV: " + uv + " Lux: " + lux + " UV Int: " + uvIntensity);
    
    salvarCSV();
  } else {
    println("Formato inválido: " + linha);
  }
}

void salvarCSV() {
  String[] linhas = new String[timeList.size() + 1];
  linhas[0] = "Tempo (HH:mm:ss);Vis (nm);IR (nm);UV;Lux;UV Intensity (mW/cm^2);" + data;

  for (int i = 0; i < timeList.size(); i++) {
    linhas[i + 1] = timestampToTime(timeList.get(i)) + ";" +
                    nf(visList.get(i), 1, 2) + ";" +
                    nf(irList.get(i), 1, 2) + ";" +
                    nf(uvList.get(i), 1, 2) + ";" +
                    nf(luxList.get(i), 1, 2) + ";" +
                    nf(uvIntensityList.get(i), 1, 2);
  }

  saveStrings("dadosSensores.csv", linhas);
  println("CSV salvo com sucesso!");
}

// Converte timestamp (ms) em HH:mm:ss
String timestampToTime(long timestamp) {
  int s = int((timestamp / 1000) % 60);
  int m = int((timestamp / (1000 * 60)) % 60);
  int h = int((timestamp / (1000 * 60 * 60)) % 24);
  return nf(h, 2) + ":" + nf(m, 2) + ":" + nf(s, 2);
}
