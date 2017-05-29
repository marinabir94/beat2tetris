// Class for each piece
// Based on: http://tetris.wikia.com/wiki/Tetromino

class Tetromino {
  // Define types of tetrominoes as blocks for each possible rotation
  // Based on: http://codeincomplete.com/posts/javascript-tetris/         
  private int[] pieceI = {0x0F00, 0x2222, 0x00F0, 0x4444};
  private int[] pieceJ = {0x8E00, 0x6440, 0x0E20, 0x44C0};
  private int[] pieceL = {0x2E00, 0x4460, 0x0E80, 0xC440};
  private int[] pieceO = {0x6600, 0x6600, 0x6600, 0x6600};
  private int[] pieceS = {0x06C0, 0x8C40, 0x6C00, 0x4620};
  private int[] pieceT = {0x4E00, 0x4640, 0x0E40, 0x4C40};
  private int[] pieceZ = {0x0C60, 0x4C80, 0xC600, 0x2640};
  private int[][] pieces = {pieceI, pieceJ, pieceL, pieceO, pieceS, pieceT, pieceZ};
  
  int cornerRadius = 2;
  
  int type;
  int[] piecePositions; // Each possible possition with rotation (one of pieces)
  int blocks; // Current blocks occupied in the current rotation (one of piecePosition)
  int rotation;

  color pieceColor;

  // Position of upper left corner of the piece in the playfield
  int posCellX;
  int posCellY;
  
  Playfield playfield;

  Tetromino(Playfield pf, color c) {
    // Assign a type randomly
    type = int(random(7));
    piecePositions = pieces[type];

    rotation = 0; // Start with initial rotation
    blocks = piecePositions[rotation]; // Assign initial blocks for intial rotation

    pieceColor = c;

    // I and O spawn in the middle columns
    // The rest spawn in the left-middle columns
    posCellX = Playfield.numCellsW / 2 - 2;
    posCellY = 21;
    
    playfield = pf;
  }
  
  // Function to check if the new position of the piece is valid or not
  private boolean checkNewPos(int newX, int newY, int newBlocks) {
    int row = 0, col = 0;
    
    // Check each block of the piece and verify if that position is already occupied
    for (int bit = 0x8000; bit > 0; bit = bit >> 1) {
      // Go row by row, from top to bottom
      if ((newBlocks & bit) > 0) {
        if (newX + col >= Playfield.numCellsW || newX + col < 0 || playfield.grid[newX + col][posCellY - row] != null) {
          // A block is in an already occupied position
          return false;
        } else if (newY - row <= 0 || playfield.grid[posCellX + col][newY - row] != null) {
          // A bottom block has collided, so this piece has to be stopped
          playfield.stopPiece(this);
          return false;
        }
      }
      // If we're done with this row, go to the next
      if (++col == 4) {
        col = 0;
        ++row;
      }
    }

    return true;
  }
  
  // Function to rotate the piece
  void rot(int r) {
    int newRotation = rotation + r;
    
    // Limit the rotation index between 0 and 3
    if (newRotation >= 4) {
      // If we're at rotation 4, start again from 0
      newRotation = 0;
    } else if (newRotation < 0) {
      // If we're at rotation -1, start again from 3
      newRotation = 3;
    }
    
    // Check if the new rotation is valid
    if (checkNewPos(posCellX, posCellY, piecePositions[newRotation])) {
      // If the new rotation is valid, apply it
      rotation = newRotation;
      blocks = piecePositions[rotation];
    }
  }

  // Function to move the piece
  void move(int movX, int movY) {
    // Check if the new position is valid
    if (checkNewPos(posCellX + movX, posCellY + movY, blocks)) {
      // If the new position is valid, apply it
      posCellX += movX;
      posCellY += movY;
    }
  }

  void display() {
    int row = 0, col = 0;

    pushStyle();
    stroke(255);
    strokeWeight(2);
    fill(pieceColor);
    for (int bit = 0x8000; bit > 0; bit = bit >> 1) {
      // Go row by row, from top to bottom
      if ((blocks & bit) > 0) {
        // Draw "block" by "block"
        rect((posCellX + col) * playfield.cellSize, (Playfield.numCellsH-2-posCellY + row) * playfield.cellSize, playfield.cellSize, playfield.cellSize, cornerRadius);
      }
      // If we're done with this row, go to the next
      if (++col == 4) {
        col = 0;
        ++row;
      }
    }
    popStyle();
  }
}