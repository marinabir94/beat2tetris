// Class for the bar of heart-rate synchronization

class SyncBar {
  private int time;
  
  // Time interval for checking if both heart rates are similar to each other
  private float secondsForIncrease = 5;
  // Amount of BPM that both HR can be different for them to be similar enough
  private int rangeHR = 10;
  // Amount (percentage) it increases every time it's checked that they are similar
  private float increasePercentage = 0.05;
  private float lastHR1, lastHR2;
  
  float value  = 0; // Between 0 (empty) and 1 (full)
  
  // Variables for animating the emptying of the bar
  boolean emptying = false;
  float emptyingSpeed = 0.1;
  
  SyncBar() {    
    lastHR1 = playerHR1;
    lastHR2 = playerHR2;
    time = millis();
  }
  
  // When the bar is full, award points and empty it
  private void useBar() {
    int reward = 100;
    
    playfield1.updateScore(reward);
    playfield2.updateScore(reward);
    emptying = true;
  }
  
  // Receives an increment (positive or negative) to add it to the value
  void updateBar(float increment) {
    value += increment;
    if (value > 1) {
      value = 1;
    } else if (value < 0) {
      value = 0;
    }
    
    if (value >= 1) {
      useBar();
    }
  }
  
  // Check if both heart rates have stayed similar to each other a certain time
  void checkHeartRates() {
    // Check if enough time has passed to check again
    if (millis() > time + secondsForIncrease * 1000 && playerHR1 != -1 && playerHR2 != -1) {
      time = millis();
      // Check if both were close enough last time we checked and now
      if (abs(lastHR1 - lastHR2) <= rangeHR && abs(playerHR1 - playerHR2) <= rangeHR) {
        // Increase the bar
        updateBar(increasePercentage);
      } else {
        // Decrease the bar
        updateBar(-increasePercentage);
      }
      lastHR1 = playerHR1;
      lastHR2 = playerHR2;
    }
  }
  
  // Rapidly decreases the bar value
  private void emptyBar() {
    value -= emptyingSpeed;
    if (value <= 0) {
      value = 0;
      emptying = false;
    }
  }
  
  void run() {
    if (emptying) {
      emptyBar();
    }
    checkHeartRates();
  }
}