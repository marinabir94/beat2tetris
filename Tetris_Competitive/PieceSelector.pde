// Class for the piece selector above the screen

class PieceSelector {
  class NextPieceUI {
    Tetromino tetromino;
    float size;
    color pieceColor;
    float cornerRadius = 10;
    
    NextPieceUI(color c) {
      size = playfield1.cellSize * 6;
      pieceColor = c;
      createPiece();
    }
    
    private void createPiece() {
      // The initial playfield is irrelevant
      tetromino = new Tetromino(playfield1, pieceColor);
    }
    
    void display() {
      int typePiece = tetromino.type;
      pushStyle();
      // Box
      noStroke();
      fill(pieceColor);
      rect(0, 0, size, size, cornerRadius);
      // Piece
      pushMatrix();
      // Display piece centered
      if (typePiece == 0 || typePiece == 3) {
        // I and O
        translate(-playfield1.cellSize*2, playfield1.cellSize*3);
      } else if (typePiece == 4 || typePiece == 6) {
        // S and Z
        translate(-playfield1.cellSize*1.5, playfield1.cellSize*2);
      } else {
        // J, L and T
        translate(-playfield1.cellSize*1.5, playfield1.cellSize*3);
      }
      tetromino.display();
      popMatrix();
      popStyle();
    }
  }
  
  NextPieceUI[] nextPiecesUI;
  //color[] colors = {#FF0000, #00FF00, #0000FF};
  color[] colors = {#FF4040, #30EE30, #4040FF};
  
  PieceSelector() {
    nextPiecesUI = new NextPieceUI[3];
    for (int i = 0; i < 3; i++) {
      nextPiecesUI[i] = new NextPieceUI(colors[i]);
    }
  }
  
  // Assing one of the three pieces to one of the playfields
  void pieceToPlayfield(int index, Playfield pf) {
    nextPiecesUI[index].tetromino.playfield = pf;
    pf.addPiece(nextPiecesUI[index].tetromino);
    nextPiecesUI[index].createPiece();
  }
  
  void display() {
    pushMatrix();
    translate(width/2 - nextPiecesUI[0].size * 1.5 - width * 0.05, height * 0.05);
    nextPiecesUI[0].display();
    translate(nextPiecesUI[1].size + width * 0.05, 0);
    nextPiecesUI[1].display();
    translate(nextPiecesUI[2].size + width * 0.05, 0);
    nextPiecesUI[2].display();
    popMatrix();
  }
}