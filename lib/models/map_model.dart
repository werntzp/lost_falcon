import 'package:lost_falcon/const.dart';
import 'dart:math';

class Cube {
  final int x;
  final int y;
  final int z;

  const Cube(this.x, this.y, this.z);
}

class MapHex {
  final int id;
  final int col; // col
  final int row; // row
  bool lastBeforeVillage =
      false; // save where they were before they entered village
  bool current = false; // player is here currently
  bool previous = false; // player was here on a previous turn
  bool visible = false; // player can "see" into this hex from where they are
  EnumTerrain terrain = EnumTerrain.unknown; // terrain type
  EnumEncounter encounter = EnumEncounter.none; // which encounter occured here 
  bool rescue = false; // are rescue forces in this hex
  bool impassable = false; // tracks if the hex is impassable (for whatever reason)

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
    final startCube = _offsetToCube(startHex.col, startHex.row);
    final destCube = _offsetToCube(destHex.col, destHex.row);
    return _cubeDistance(startCube, destCube);
  }

  // ************************
  // build and return a cube
  // ************************
  static Cube _offsetToCube(int col, int row) {
    final x = col;
    final z = row - ((col & 1) == 0 ? col ~/ 2 : (col + 1) ~/ 2);
    final y = -x - z;
    return Cube(x, y, z);
  }

  // ************************
  // figure out distance between cubes
  // ************************
  static int _cubeDistance(Cube a, Cube b) {
    return ((a.x - b.x).abs() + (a.y - b.y).abs() + (a.z - b.z).abs()) ~/ 2;
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

  // ************************
  // get an id from the column and row
  // ************************
  static int _getIdFromColRow(List<MapHex> map, int col, int row) {
    int id = 0;

    for (MapHex m in map) {
      if ((m.row == row) && (m.col == col)) {
        id = m.id;
        break;
      }
    }
    return id;
  }

  // ************************
  // return an initialized map
  // ************************
  static List<MapHex> initMap() {
    List<MapHex> map = [];
    int counter = 0;

    // loop through and create initial map
    for (int c = 0; c < constMapCols; c++) {
      for (int r = 0; r < constMapRows; r++) {
        MapHex mh = MapHex(counter, c, r);
        map.add(mh);
        // increment the counter
        counter++;
      }
    }

    // now go through and set up a few initial spots
    map[_getIdFromColRow(map, constStartCol, constStartRow)].current =
        true; // start post
    map[_getIdFromColRow(map, constStartCol, constStartRow)].terrain =
        EnumTerrain.scrub; // start in scrub
    map[_getIdFromColRow(map, constStartCol, constStartRow)].visible = true;

    // rescue hex should be visible at start
    map[_getIdFromColRow(map, 14, 4)].visible = true;

    // set a few specific ones to be background hexes that can't be entered or selected
    map[_getIdFromColRow(map, 0, 2)].terrain = EnumTerrain.background;
    map[_getIdFromColRow(map, 0, 2)].visible = true;
    map[_getIdFromColRow(map, 0, 3)].terrain = EnumTerrain.background;
    map[_getIdFromColRow(map, 0, 3)].visible = true;
    map[_getIdFromColRow(map, 0, 4)].terrain = EnumTerrain.background;
    map[_getIdFromColRow(map, 0, 4)].visible = true;
    map[_getIdFromColRow(map, 1, 4)].terrain = EnumTerrain.background;
    map[_getIdFromColRow(map, 1, 4)].visible = true;
    map[_getIdFromColRow(map, 13, 0)].terrain = EnumTerrain.background;
    map[_getIdFromColRow(map, 13, 0)].visible = true;
    map[_getIdFromColRow(map, 14, 0)].terrain = EnumTerrain.background;
    map[_getIdFromColRow(map, 14, 0)].visible = true;

    // set where US rescue forces start 
    map[_getIdFromColRow(map, 14, 4)].rescue = true;

    // return the map back out
    return List.from(map);
  }
}
