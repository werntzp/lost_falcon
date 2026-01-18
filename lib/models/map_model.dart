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
    int finalRow = 0;
    int finalCol = 0;
    int rowChange = 0;

    // go numsteps columns away, but if that goes over the max, make it the max
    currentCol + numSteps > constMapCols
        ? finalCol = constMapCols
        : finalCol = currentCol + numSteps;

    // randomly move up or down a row as we go across columns
    rowChange = Random().nextInt(2) - 1; // -1, 0, or +1
    finalRow = currentRow + rowChange;
    // check bounds
    if ((finalRow < 0) || (finalRow >= constMapRows)) {
      finalRow = currentRow;
    }

    // ok, now we have the map spot so send out a hex
    return MapHex(constFakeHex, finalCol, finalRow);
  }
}
