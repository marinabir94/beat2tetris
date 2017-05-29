// Class for the playfield, a.k.a. grid or matrix
// Based on: http://tetris.wikia.com/wiki/Playfield

class Playfield {
  final static int numCellsW = 10;
  final static int numCellsH = 22; // Only 20 are shown
  
  // Matrix of blocks
  Block[][] grid; // To track occupied cells
  
  // Position of the upper left corner
  float posX, posY;
  
  float pfWidth;
  float pfHeight;
  float cellSize;
  boolean showGrid = true;
  
  int cornerRadius = 4;
  
  Tetromino currentPiece;
  
  int score;
  boolean gameOver = false;
  
  int id;
  
  // Variables for animating the increasing of the score
  private boolean increasingScore = false;
  private int increasingSpeed = 20;
  private int increasedScore;
  
  Playfield(int identifier, float x, float y, float h, float w) {
    id = identifier;
    
    grid = new Block[numCellsW][numCellsH];
    
    posX = x;
    posY = y;
    
    pfHeight = h;
    pfWidth = w;
    cellSize = pfWidth / 10;
    
    currentPiece = null;
    
    score = 0;
  }
  
  // Check if the goal socre has been achieved and finishes the game if it has
  void checkGoalAchieved() {
    // If this player has reached the goal score, set game over to the other player
    if (score >= goalScore) {
      if (id == 1) {
        playfield2.gameOver = true;
      } else {
        playfield1.gameOver = true;
      }
      saveLog();
    }
  }
  
  // Update the matrix of blocks with the new blocks after a piece has been stopped
  private void updateGrid(Tetromino t) {
    int row = 0, col = 0;
    
    for(int bit = 0x8000; bit > 0; bit = bit >> 1) {
      if ((t.blocks & bit) > 0) {
        // There's a block in this position
        Block b = new Block(t.posCellX + col, t.posCellY - row, t.pieceColor, this); // Create the block
        grid[t.posCellX + col][t.posCellY - row] = b; // Update the matrix of blocks
      }
      if (++col == 4) {
        col = 0;
        ++row;
      }
    }
  }
  
  // Function to delete a complete row
  private void deleteRow(int row) {
    // Delete the line
    for (int j = 0; j < numCellsW; j++) {
       grid[j][row] = null;
    }
    
    // Move down all pieces above this line
    for (int i = row+1; i < numCellsH-2; i++) {
      for (int j = 0; j < numCellsW; j++) {
        if (grid[j][i] != null) {
          grid[j][i].posCellY--;
        }
        grid[j][i-1] = grid[j][i];
      }
    }
  }
  
  private void updateScoreBar() {
    if (id == 1) {
      scoreBar1.updateBar();
    } else if (id == 2) {
      scoreBar2.updateBar();
    }
  }
  
  // Rapidly increases the score value
  private void animateIncreaseScore() {
    if (score < increasedScore) {
      score += increasingSpeed;
    } else {
      // The score is done increasing;
      increasingScore = false;
      checkGoalAchieved();
    }
    updateScoreBar();
  }
  
  // Increments the score by the passed value
  void updateScore(int increment) {
    increasedScore = score + increment;
    increasingScore = true;
    updateScoreBar();
  }
  
  // Function to check if there's a complete row or a block above the top
  private void checkRow() {
    int c; // Counter of blocks for each row
    int deletedLines = 0; // Counter of completed rows at the same time
    for (int i = numCellsH-2; i >= 0; i--) {
      c = 0;
      for (int j = 0; j < numCellsW; j++) {
        if (grid[j][i] != null) {
          if (i >= 20) {
            // There's a piece above the top of the playfield
            // GAME OVER
            gameOver = true;
            break;
          } else {
            c++;
          }
        }
      }
      if (c >= numCellsW) {
        // There's a full row
        deleteRow(i);
        deletedLines++;
      }
    }
    // Update score (the more lines at once, the more each one counts)
    updateScore(deletedLines * deletedLines * 100);
  }
  
  // Function to add a new piece
  void addPiece(Tetromino t) {
    currentPiece = t;
  }
  
  // Function to rotate the current piece
  void rotatePiece(int r) {
    if (currentPiece != null) {
      currentPiece.rot(r);
    }
  }
  
  // Function to move the current piece
  void movePiece(int movX, int movY) {
    if (currentPiece != null) {
      currentPiece.move(movX, movY);
    }
  }
  
  // Function to decompose the current piece into blocks and add a new piece
  void stopPiece(Tetromino t) {
    currentPiece = null;
    updateGrid(t);
    checkRow();
  }
  
  // Function to move the current piece down automatically each time
  void run() {
    movePiece(0, -1);
  }
  
  // Draw the grid of the playfield
  private void drawGrid() {
    pushStyle();
    stroke(232);
    // Vertical lines
    for (int i = 1; i < numCellsW; i++) {
      line(i * cellSize, 0, i * cellSize, pfHeight);
    }
    
    // Horizontal lines
    for (int i = 1; i < numCellsH-2; i++) {
      line(0, i * cellSize, pfWidth, i * cellSize);
    }
    popStyle();
  }
  
  void display() {
    if (increasingScore) {
      animateIncreaseScore();
    }
    
    pushMatrix();
    translate(posX, posY);
    // Draw grid
    if (showGrid) {
      drawGrid();
    }
    // Draw blocks
    for (int i = 0; i < numCellsW; i++) {
      for (int j = 0; j < numCellsH-2; j++) {
        if (grid[i][j] != null) {
          grid[i][j].display();
        }
      }
    }
    // Draw current piece
    if (currentPiece != null) {
      currentPiece.display();
    }
    // Draw border
    pushStyle();
    strokeWeight(2);
    stroke(100);
    noFill();
    rect(0, 0, pfWidth, pfHeight, cornerRadius);
    popStyle();
    popMatrix();
  }
}