// Class for the heart UI elements

class HeartBeatUI {
  // Position of the center
  private float posX, posY;
  
  private PImage heartImg;
  private float heartSizeContracted;
  private float heartSizeExpanded;
  private float heartSizeCurrent;
  
  private float millisBetweenBeats;
  private float pctToContracted = 0.2; // Percentage of the beat for contraction
  private float pctToExpanded = 0.8; // Percentage of the beat for expansion
  
  private int time;
  
  private int id; // For getting the appropriate heart rate
  private float heartRate;
  
  private PImage heartContour;
  
  HeartBeatUI(int identifier, float x, float y) {
    id = identifier;
    
    posX = x;
    posY = y;
    
    heartImg = loadImage("heart.png");
    heartSizeCurrent = heartSizeExpanded;
    
    heartSizeContracted = width * 0.1;
    heartSizeExpanded = heartSizeContracted * 1.2;
    
    heartContour = loadImage("heart_contour.png");
    
    time = millis();
  }
  
  void updateHeartRate() {
    if (id == 1) {
      heartRate = playerHR1;
    } else if (id == 2) {
      heartRate = playerHR2;
    }
  }
  
  void display() {
    // Depending on the heart rate, animate heart appropriately
    updateHeartRate();
    if(heartRate != -1) millisBetweenBeats = 60 * 1000 / heartRate;
    float beatPct = (millis() - time) / millisBetweenBeats;
    if (beatPct < pctToExpanded) {
      // Expand heart
      float beatToExpanded = beatPct / pctToExpanded;
      heartSizeCurrent = lerp(heartSizeContracted, heartSizeExpanded, beatToExpanded);
    } else {
      // Contract heart
      float beatToContracted = (beatPct-pctToExpanded) / pctToContracted;
      heartSizeCurrent = lerp(heartSizeExpanded, heartSizeContracted, beatToContracted);
    }
    
    if (millis() > time + millisBetweenBeats) {
      // Beat completed, restart animation
      time = millis();
    }
    
    // Draw heart background
    pushMatrix();
    translate(posX, posY);
    pushStyle();
    imageMode(CENTER);
    tint(255, 128);
    image(heartImg, 0, 0, heartSizeCurrent, heartSizeCurrent);
    popStyle();
    // Draw heart with sync bar
    pushStyle();
    imageMode(CENTER);
    image(heartImg, 0, 0, heartSizeCurrent*syncBar.value, heartSizeCurrent*syncBar.value);
    popStyle();
    // Draw contour
    pushStyle();
    imageMode(CENTER);
    image(heartContour, 0, 0, heartSizeCurrent, heartSizeCurrent*0.89);
    popStyle();
    // Draw BPM
    pushStyle();
    textAlign(CENTER, CENTER);
    textSize(46);
    fill(50);
    if(heartRate != -1) text(int(heartRate), 0, height*0.115);
    popStyle();
    popMatrix();
  }
}