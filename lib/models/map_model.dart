import 'package:lost_falcon/const.dart';
import 'dart:math';

class MapHex {
  final int id;
  final int col; // col
  final int row; // row
  bool current = false; // player is here currently
  bool previous = false; // player was here on a previous turn
  bool visible = false; // player can "see" into this hex from where they are
  EnumTerrain terrain = EnumTerrain.unknown; // terrain type

  MapHex(this.id, this.col, this.row);
}

class MapFactory {

  // ************************
  // return move number based on terrain
  // ************************
  static int getMoveCost(EnumTerrain terrain) {
    int moveCost = 0; 

      if (terrain == EnumTerrain.scrub) {
        moveCost = constScrubMoveCost;
      } else if (terrain == EnumTerrain.brush) {
        moveCost = constBrushMoveCost;
      } else if (terrain == EnumTerrain.hills) {
        moveCost = constHillsMoveCost;
      } else if (terrain == EnumTerrain.rough) {
        moveCost = constRoughMoveCost;
      }

    return moveCost; 

  }

  // ************************
  // return stealth number based on terrain
  // ************************
  static int getStealthCost(EnumTerrain terrain) {
    int stealthCost = 0; 

      if (terrain == EnumTerrain.scrub) {
        stealthCost = constScrubStealthCost;
      } else if (terrain == EnumTerrain.brush) {
        stealthCost = constBrushStealthCost;
      } else if (terrain == EnumTerrain.hills) {
        stealthCost = constHillsStealthCost;
      } else if (terrain == EnumTerrain.rough) {
        stealthCost = constRoughStealthCost;
      }

    return stealthCost; 

  }

  // ************************
  // return rest number based on terrain 
  // ************************
  static int getRestCost(EnumTerrain terrain) {
    int restCost = 0; 

      if (terrain == EnumTerrain.scrub) {
        restCost = constScrubRestCost;
      } else if (terrain == EnumTerrain.brush) {
        restCost = constBrushRestCost;
      } else if (terrain == EnumTerrain.hills) {
        restCost = constHillsRestCost;
      } else if (terrain == EnumTerrain.rough) {
        restCost = constRoughRestCost;
      }

    return restCost; 

  }


  // ************************
  // how far are we from the starting hex?  
  // ************************
  static int getDistanceBetweenHexes(MapHex startHex, MapHex destHex) {
    // figure out the distance between starting hex and destination (current one)
    int distance = 0;

    if (startHex.row == destHex.row) {
      // if same row, just count across columns
      distance = (destHex.col - startHex.col).abs();
    } else if (startHex.col == destHex.col) {
      // if same column, just count across rows
      distance = (destHex.row - startHex.row).abs();
    } else {
      // this is where it gets tricky
      int dx = (destHex.row - startHex.row).abs();
      int dy = (destHex.col - startHex.col).abs();
      if (startHex.col < destHex.col) {
        distance = dx + dy - (dx / 2.0).ceil();
      } else {
        distance = dx + dy - (dx / 2.0).floor();
      }
    }

    return distance;
  }

  // ************************
  // how far are we from the starting hex?  
  // ************************
  static MapHex moveRandomSteps(int currentRow, int currentCol, int numSteps) {
    int nextRow = 0;
    int nextCol = 0; 
    bool rowUp = false; 
    bool colUp = false; 

    for (int i = 1; i <= numSteps; i++) {
      // get a random direction to move up  
      rowUp = Random().nextBool();
      colUp = Random().nextBool();

      // going up or down from current column 
      colUp ? nextCol = currentCol + 1 : nextCol = currentCol; 
      // but check bounds 
      if (nextCol > constMapCols) { nextCol = currentCol; }

      // going up or down rows depends on whether column is even or odd 
      if (currentCol % 2 == 0) {
        // if even, down is row-1, up is same row
        rowUp ? nextRow = currentRow : nextRow = currentRow - 1;  
      }
      else { 
        // if odd, down is same row, up row+1
        rowUp ? nextRow = currentRow + 1: nextRow = currentRow;  
      }
      // check bounds
      if ((nextRow < 0) || (nextRow == constMapRows)) { nextRow = currentRow; }

      // so we've found a safe spot, so swap value and iterate again 
      currentCol = nextCol;
      currentRow = nextRow; 

    }

    // ok, now we have the map spot so send out a hex
    return MapHex(constFakeHex, currentCol, currentRow);

  }

}
