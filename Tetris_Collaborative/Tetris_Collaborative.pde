import processing.sound.*;
import oscP5.*;
import processing.serial.*;

OscP5 oscP5Wii, oscP5HR;
Serial serial;

boolean soundActivated = true;
SoundFile tetrisSong;

// Game components
Playfield playfield1;
HeartBeatUI heartBeatUI1, heartBeatUI2;
SyncBar syncBar;
PieceSelector pieceSelector;
ScoreBar scoreBar1, scoreBar2;

float speed = 1; // 1 movement per second

final int goalScore = 1000; // Score at which the game will end

// Variables for players heart rate
float playerHR1 = -1;
float playerHR2 = -1;

// Variables for timing
int startTime;
int time;

PFont uiFont;

PImage contours;

void setup() {
  size(1120, 700); // 16:10
  //fullScreen();
  
  noCursor();
  
  oscP5HR = new OscP5(this, 5204);
  oscP5Wii = new OscP5(this, 8001);
  //String portName = "COM4"; // Windows, change to match port
  //String portName = Serial.list()[1]; // Mac, change to match port
  String portName = "/dev/tty.usbmodem769851";
  //portName = Serial.list()[1];
  println(Serial.list());
  serial = new Serial(this, portName, 9600);
  
  if (soundActivated) {
    tetrisSong = new SoundFile(this, "Tetris.mp3");
    tetrisSong.loop();
  }
  
  uiFont = loadFont("AngelineVintage-48.vlw");
  textFont(uiFont);
  
  contours = loadImage("contours.png");
  
  createAllGameComponents();
  
  startTime = millis();
  time = startTime;
}

void draw() {
  background(246);
  
  pieceSelector.display();
  
  playfield1.display();
  
  heartBeatUI1.display();
  heartBeatUI2.display();
  
  if (!playfield1.gameOver) {
    syncBar.run();
  }
  
  scoreBar1.display();
  scoreBar2.display();
  
  // Every appropriate frame (depending on speed), move down the current piece
  if (millis() > time + 1000 / speed && !playfield1.gameOver) {
    time = millis();
    playfield1.run();
    
    // FOR TESTING ONLY
    // Increment the bar 1 % every second
    //syncBar1.updateBar(0.01);
    //syncBar2.updateBar(0.01);
    // Change the heart rate
    //playerHR1 *= random(0.99, 1.01);
    //playerHR2 *= random(0.99, 1.01);
  }
  
  // Draw contours
  image(contours, 0, 0, width, height);
  
  if (playfield1.gameOver) {
    drawGameOver();
  }
  
  readSerial();
}

void createPlayfield() {
  float playfieldHeight = height * 0.65;
  float playFieldWidth = playfieldHeight / 2.0;
  
  playfield1 = new Playfield(width/2 - playFieldWidth/2, height - playfieldHeight - height * 0.05, playfieldHeight, playFieldWidth);
}

void createHeartBeatUIs() {
  float lateralSpace = scoreBar1.posX;
  heartBeatUI1 = new HeartBeatUI(1, lateralSpace/2, height*0.5);
  heartBeatUI2 = new HeartBeatUI(2, width - lateralSpace/2, height*0.5);
}

void createSyncBar() {
  syncBar = new SyncBar();
}

void createScoreBars() {
  scoreBar1 = new ScoreBar(playfield1, playfield1.posX - playfield1.cellSize*10, playfield1.posY, playfield1.cellSize*1.5, playfield1.pfHeight);
  scoreBar2 = new ScoreBar(playfield1, playfield1.posX + playfield1.pfWidth + playfield1.cellSize*8.5, playfield1.posY, playfield1.cellSize*1.5, playfield1.pfHeight);
}

void createAllGameComponents() {
  createPlayfield();
  createSyncBar();
  createPieceSelector();
  createScoreBars();
  createHeartBeatUIs();
}

void createPieceSelector() {
  pieceSelector = new PieceSelector();
}

void adjustSpeed(float newSpeed) {
  if (newSpeed > 0) {
    speed = newSpeed;
  }
  
  // Adjust playback rate of the song
  if (soundActivated) {
    tetrisSong.rate(1 + speed/10);
  }
}

void restartGame() {
  speed = 1;
  createAllGameComponents();
}

void drawGameOver() {
  // Create message depending on who won
  String winMessage = "GAME OVER";
  if (playfield1.gameOver && playfield1.score == goalScore) {
    winMessage = "You win!";
  } 
  
  pushStyle();
  // Draw background
  noStroke();
  fill(0, 180);
  rect(playfield1.posX - playfield1.cellSize*8.2, playfield1.posY - playfield1.cellSize*0.7, playfield1.pfWidth * 2.5 + playfield1.cellSize*1.2, playfield1.pfHeight + playfield1.cellSize*1.2, 10);
  // Draw text
  textAlign(CENTER, CENTER);
  textSize(62);
  fill(255);
  text(winMessage, width/2, playfield1.posY + playfield1.pfHeight * 0.4);
  textSize(28);
  text("Press space to restart", width/2, playfield1.posY + playfield1.pfHeight * 0.55);
  popStyle();
}

// Returns the timestap as: YYYY-MM-DD HH.MM.SS
String timestamp() {
  String  t = year() + "-" + month() + "-" + day() + " " + hour() + "." + minute() + "." + second();
  return t;
}

// Save the duration of the game to a text file
void saveLog() {
  int duration = millis() - startTime;
  PrintWriter output = createWriter(timestamp() + ".txt");
  output.println(duration);
  output.flush();
  output.close();
}

// Processing of OSC messages
// Wiimote events (via OSCulator) and HR events (via Python)
void oscEvent(OscMessage msg) {
  int wiimote = 0;
  
  if (msg.addrPattern().startsWith("/hr/")) {
    println("tostring: "+msg.toString());
    println(split(msg.toString(), '/'));
    playerHR1 = float(split(msg.toString(), '/')[3]);
    playerHR2 = float(split(msg.toString(), '/')[4]);
    println("players: " + playerHR1 + "  - " + playerHR2);
  }
  
  if (msg.addrPattern().startsWith("/wii/1/")) {
    wiimote = 1;
  } else if (msg.addrPattern().startsWith("/wii/2/")) {
    wiimote = 2;
  }
  
  if (wiimote > 0) {
    if (msg.addrPattern().contains("/button/") && wiimote == 1) {
      // Button
      if (msg.addrPattern().endsWith("/Right")) {
        playfield1.movePiece(1, 0);
      } else if (msg.addrPattern().endsWith("/Left")) {
        playfield1.movePiece(-1, 0);
      } else if (msg.addrPattern().endsWith("/Down")) {
        playfield1.movePiece(0, -1);
      }
    } else if (msg.addrPattern().contains("/accel/") && wiimote == 2) {
      // Accelerometer
      if (msg.addrPattern().endsWith("/cw")) {
        playfield1.rotatePiece(1);
      } else if (msg.addrPattern().endsWith("/ccw")) {
        playfield1.rotatePiece(-1);
      }
    }
  } 
}

// Processing of Serial messages
// Color sensor (via Arduino)
void readSerial() {
  if (serial.available() > 0) {
    int inByte = serial.read();
    // Remove the two noisy values (10 and 13)
    if (inByte != 10 && inByte != 13) {
      int colorID = inByte % 100; // Should be 0, 1 or 2
      
      // If everything's correct and there's no active piece in that playfield,
      // add the selected piece to that playfield
      if (playfield1.currentPiece == null) {
        if (colorID == 0 || colorID == 1 || colorID == 2) {
          pieceSelector.pieceToPlayfield(colorID, playfield1);
        }
      }
    }
  }
}

void keyReleased() {
  if (!playfield1.gameOver) {
    // If the game is not over
    
    if (keyCode == UP) {
      playfield1.rotatePiece(1);
    } else if (keyCode == RIGHT) {
      playfield1.movePiece(1, 0);
    } else if (keyCode == LEFT) {
      playfield1.movePiece(-1, 0);
    } else if (keyCode == DOWN) {
      playfield1.movePiece(0, -1);
    }
    
    // Piece selection
    if (playfield1.currentPiece == null) {
      if (key == '1') {
        pieceSelector.pieceToPlayfield(0, playfield1);
      } else if (key == '2') {
        pieceSelector.pieceToPlayfield(1, playfield1);
      } else if (key == '3') {
        pieceSelector.pieceToPlayfield(2, playfield1);
      }
    }
    
    // Debugging
    if (key == 'k' || key == 'K') {
      adjustSpeed(speed-1);
    } else if (key == 'l' || key == 'L') {
      adjustSpeed(speed+1);
    } else if(key == 'g' || key == 'G') {
      playfield1.showGrid = !playfield1.showGrid;
    }
  } else {
    // If the game is over
    if (key == ' ') {
      restartGame();
    }
  }
}