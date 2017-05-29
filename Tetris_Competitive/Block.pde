// Class for each individual block of a piece *after* it has stopped

class Block {
  // Position of the block in the playfield
  int posCellX;
  int posCellY;
  
  color blockColor;
  
  private Playfield playfield;
  
  Block(int pX, int pY, color c, Playfield pf) {
    posCellX = pX;
    posCellY = pY;
    blockColor = c;
    playfield = pf;
  }
  
  void display() {    
    pushStyle();
    stroke(255);
    strokeWeight(2);
    fill(blockColor);
    rect(posCellX * playfield.cellSize, (Playfield.numCellsH-2-posCellY) * playfield.cellSize, playfield.cellSize, playfield.cellSize);
    popStyle();
  }
}