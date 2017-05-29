// Class for the bar of scores

class ScoreBar {  
  float barWidth;
  float barHeight;
  float posX, posY; // Top left corner
  float margin; // Margin between the inner and the outter part of the bar
  
  int cornerRadius = 8;
  
  float value = 0; // Between 0 (empty) and 1 (full)
  
  Playfield playfield;
  
  // Hue value of color in HSV/HSB
  int bottomColor = 0; // Red
  int topColor = 120; // Green
  
  ScoreBar(Playfield pf, float x, float y, float w, float h) {
    playfield = pf;
    posX = x;
    posY = y;
    barWidth = w;
    barHeight = h;
    margin = 1;
  }
  
  void updateBar() {
    value = float(playfield.score) / float(goalScore);
    if (value > 1.0) {
      value = 1.0;
    }
  }
  
  void drawGradient(float x, float y, float w, float h) {
    for (int i = int(y+h); i > y; i--) {
      colorMode(HSB, 360, 100, 100);
      stroke(lerp(topColor, bottomColor, i/(y+h)), 60, 100);
      strokeWeight(1);
      line(x, i, x+w, i);
    }
  }
  
  void display() {
    pushMatrix();
    translate(posX, posY);
    // Background (outter part)
    pushStyle();
    noStroke();
    fill(232);
    rect(0, 0, barWidth, barHeight, cornerRadius);
    popStyle();
    // Bar (inner part)
    pushStyle();
    drawGradient(margin, (barHeight - margin) - value * (barHeight - margin), barWidth - margin*2, value * (barHeight));
    popStyle();
    // Outter border
    pushStyle();
    noFill();
    stroke(232);
    strokeWeight(4);
    rect(0, 0, barWidth, barHeight, cornerRadius);
    popStyle();
    // Score
    pushStyle();
    textAlign(CENTER, CENTER);
    textSize(30);
    fill(50);
    text(playfield.score, barWidth/2, -barHeight*0.05);
    popStyle();
    popMatrix();
  }
}