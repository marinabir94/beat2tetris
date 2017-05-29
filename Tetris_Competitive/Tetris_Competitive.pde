import processing.sound.*;
import oscP5.*;
import processing.serial.*;
import processing.net.*; 

// Socket
Client myClient;
String dataIn;
int time_client;

OscP5 oscP5Wii, oscP5HR;
Serial serial;

boolean soundActivated = false;
SoundFile tetrisSong;

// Game components
Playfield playfield1, playfield2;
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
  
  myClient = new Client(this, "127.0.0.1", 5204);
  time_client = millis();
  
  noCursor();
  
  oscP5HR = new OscP5(this, 5204);
  oscP5Wii = new OscP5(this, 8001);
  //String portName = "COM4"; // Windows, change to match port
  //String portName = Serial.list()[3]; // Mac, change to match port
  String portName = "/dev/tty.usbmodem769851";
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
  playfield2.display();
  
  heartBeatUI1.display();
  heartBeatUI2.display();
  
  if (!playfield1.gameOver && !playfield2.gameOver) {
    syncBar.run();
  }
  
  scoreBar1.display();
  scoreBar2.display();
  
  // Every appropriate frame (depending on speed), move down the current piece
  if (millis() > time + 1000 / speed && !playfield1.gameOver && !playfield2.gameOver) {
    time = millis();
    playfield1.run();
    playfield2.run();
    
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
  
  if (playfield1.gameOver || playfield2.gameOver) {
    drawGameOver();
  }
  
  readSerial();
}

void createPlayfields() {
  float playfieldHeight = height * 0.65;
  float playFieldWidth = playfieldHeight / 2.0;
  
  playfield1 = new Playfield(1, width/2 - playFieldWidth - width * 0.05, height - playfieldHeight - height * 0.05, playfieldHeight, playFieldWidth);
  playfield2 = new Playfield(2, width/2 + width * 0.05, height - playfieldHeight - height * 0.05, playfieldHeight, playFieldWidth);
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
  scoreBar1 = new ScoreBar(playfield1, playfield1.posX - playfield1.cellSize*2.5, playfield1.posY, playfield1.cellSize*1.5, playfield1.pfHeight);
  scoreBar2 = new ScoreBar(playfield2, playfield2.posX + playfield2.pfWidth + playfield2.cellSize*1, playfield2.posY, playfield2.cellSize*1.5, playfield2.pfHeight);
}

void createAllGameComponents() {
  createPlayfields();
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
  if (playfield1.gameOver && playfield2.gameOver) {
    winMessage = "Both players win!";
  } else if (playfield1.gameOver) {
    winMessage = "Right player wins!";
  } else if (playfield2.gameOver) {
    winMessage = "Left player wins!";
  }  
  
  pushStyle();
  // Draw background
  noStroke();
  fill(0, 180);
  rect(playfield1.posX - playfield1.cellSize*0.7, playfield1.posY - playfield1.cellSize*0.7, playfield1.pfWidth * 2.5 + playfield1.cellSize*1.2, playfield1.pfHeight + playfield1.cellSize*1.2, 10);
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
  Playfield pf = null;
  //println(msg);
  if (msg.addrPattern().startsWith("/hr/")) {
    println("tostring: "+msg.toString());
    println(split(msg.toString(), '/'));
    playerHR1 = float(split(msg.toString(), '/')[3]);
    playerHR2 = float(split(msg.toString(), '/')[4]);
    println("players: " + playerHR1 + "  - " + playerHR2);
  }
  
  if (msg.addrPattern().startsWith("/wii/1/")) {
    wiimote = 1;
    pf = playfield1;
  } else if (msg.addrPattern().startsWith("/wii/2/")) {
    wiimote = 2;
    pf = playfield2;
  }
  
  if (wiimote > 0 && pf != null) {
    if (msg.addrPattern().contains("/button/")) {
      // Button
      if (msg.addrPattern().endsWith("/Right")) {
        pf.movePiece(1, 0);
      } else if (msg.addrPattern().endsWith("/Left")) {
        pf.movePiece(-1, 0);
      } else if (msg.addrPattern().endsWith("/Down")) {
        pf.movePiece(0, -1);
      }
    } else if (msg.addrPattern().contains("/accel/")) {
      // Accelerometer
      if (msg.addrPattern().endsWith("/cw")) {
        pf.rotatePiece(1);
      } else if (msg.addrPattern().endsWith("/ccw")) {
        pf.rotatePiece(-1);
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
      int playerID = inByte / 100; // Should be 1 or 2
      int colorID = inByte % 100; // Should be 0, 1 or 2
      
      // Select playfield of player
      Playfield pf = null;
      if (playerID == 1) {
        pf = playfield1;
      } else if (playerID == 2) {
        pf = playfield2;
      }
      
      // If everything's correct and there's no active piece in that playfield,
      // add the selected piece to that playfield
      if (pf != null && pf.currentPiece == null) {
        if (colorID == 0 || colorID == 1 || colorID == 2) {
          pieceSelector.pieceToPlayfield(colorID, pf);
        }
      }
    }
  }
}

void keyReleased() {
  if (key == 'h' || key == 'H') {
    myClient.write("print/hr");
  }
  if (!playfield1.gameOver && !playfield2.gameOver) {
    // If the game is not over
    
    // Player 1
    if (key == 'w' || key == 'W') {
      playfield1.rotatePiece(1);
    } else if (key == 'd' || key == 'D') {
      playfield1.movePiece(1, 0);
    } else if (key == 'a' || key == 'A') {
      playfield1.movePiece(-1, 0);
    } else if (key == 's' || key == 'S') {
      playfield1.movePiece(0, -1);
    }
    
    // Player 2
    if (keyCode == UP) {
      playfield2.rotatePiece(1);
    } else if (keyCode == RIGHT) {
      playfield2.movePiece(1, 0);
    } else if (keyCode == LEFT) {
      playfield2.movePiece(-1, 0);
    } else if (keyCode == DOWN) {
      playfield2.movePiece(0, -1);
    }
    
    // Piece selection, player 1
    if (playfield1.currentPiece == null) {
      if (key == '1') {
        pieceSelector.pieceToPlayfield(0, playfield1);
      } else if (key == '2') {
        pieceSelector.pieceToPlayfield(1, playfield1);
      } else if (key == '3') {
        pieceSelector.pieceToPlayfield(2, playfield1);
      }
    }
    
    // Piece selection, player 2
    if (playfield2.currentPiece == null) {
      if (key == '7') {
        pieceSelector.pieceToPlayfield(0, playfield2);
      } else if (key == '8') {
        pieceSelector.pieceToPlayfield(1, playfield2);
      } else if (key == '9') {
        pieceSelector.pieceToPlayfield(2, playfield2);
      }
    }
    
    if (key == 'y') {
      playfield1.updateScore(100);
    }
    
    // Debugging
    if (key == 'k' || key == 'K') {
      adjustSpeed(speed-1);
    } else if (key == 'l' || key == 'L') {
      adjustSpeed(speed+1);
    } else if(key == 'g' || key == 'G') {
      playfield1.showGrid = !playfield1.showGrid;
      playfield2.showGrid = !playfield2.showGrid;
    }
  } else {
    // If the game is over
    if (key == ' ') {
      restartGame();
    }
  }
}