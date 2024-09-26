import 'package:flutter/material.dart';
import 'package:hexagon/hexagon.dart';
import 'package:lost_falcon/const.dart';
import '../models/map_model.dart';
import 'dart:math';

int _turn = 1;
int _proximity = 6;
int _health = 6;
int _endurance = 6;
List<MapHex> _map = [];

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
    _newGame();
  }

  void _newGame() async {
    _initMap();
  }

  // ************************
  // _getIdFromRowCol
  // ************************
  int _getIdFromRowCol(int row, int col) {
    int id = 0;

    for (MapHex m in _map) {
      if ((m.row == row) && (m.col == col)) {
        id = m.id;
        break;
      }
    }
    return id;
  }

  // ************************
  // _getMapHexPadding
  // ************************
  double _getMapHexPadding(int row, int col) {
    int id = _getIdFromRowCol(row, col);
    if (_map[id].current) {
      return 5.0;
    } else {
      return 1.0;
    }
  }

  // ************************
  // _getMapHexGraphic
  // ************************
  String _getMapHexGraphic(int row, int col) {
    EnumTerrain enumTerrain = _map[_getIdFromRowCol(row, col)].terrain;
    String asset;
    bool isCurrentPlayerLocation = _map[_getIdFromRowCol(row, col)].current;

    if (isCurrentPlayerLocation) {
      asset = constImagePlayerLocation;
    } else {
      if (enumTerrain == EnumTerrain.scrub) {
        asset = constImageScrub;
      } else if (enumTerrain == EnumTerrain.brush) {
        asset = constImageBrush;
      } else if (enumTerrain == EnumTerrain.hills) {
        asset = constImageHills;
      } else if (enumTerrain == EnumTerrain.rough) {
        asset = constImageRough;
      } else if (enumTerrain == EnumTerrain.village) {
        asset = constImageVillage;
      } else if (enumTerrain == EnumTerrain.river) {
        asset = constImageWaves;
      } else if (enumTerrain == EnumTerrain.rescue) {
        asset = constImageRescue;
      } else {
        asset = constImageUnknown;
      }
    }

    return asset;
  }

  // ************************
  // _getMapHexColor
  // ************************
  Color _getMapHexColor(row, col) {
    EnumTerrain enumTerrain = _map[_getIdFromRowCol(row, col)].terrain;
    Color c = Colors.black;

    if (enumTerrain == EnumTerrain.scrub) {
      c = Colors.yellow.shade600;
    } else if (enumTerrain == EnumTerrain.brush) {
      c = Colors.lime.shade800;
    } else if (enumTerrain == EnumTerrain.hills) {
      c = Colors.brown.shade200;
    } else if (enumTerrain == EnumTerrain.rough) {
      c = Colors.brown.shade400;
    } else if (enumTerrain == EnumTerrain.village) {
      c = Colors.grey.shade200;
    } else if (enumTerrain == EnumTerrain.river) {
      c = Colors.blue;
    } else if (enumTerrain == EnumTerrain.rescue) {
      c = Colors.white;
    } else {
      c = Colors.black;
    }

    return c;
  }

  // ************************
  // _getRandomTerrain
  // ************************
  EnumTerrain _getRandomTerrain() {
    EnumTerrain enumTerrain;
    int i;

    i = Random().nextInt(10);
    // 1: village
    if (i == 1) {
      enumTerrain = EnumTerrain.village;
    }
    // 2-4: scrub
    else if (i.clamp(2, 4) == i) {
      enumTerrain = EnumTerrain.scrub;
    }
    // 5-6: brushwood
    else if (i.clamp(5, 7) == i) {
      enumTerrain = EnumTerrain.brush;
    } else if (i.clamp(8, 9) == i) {
      enumTerrain = EnumTerrain.hills;
    } else {
      enumTerrain = EnumTerrain.rough;
    }

    return enumTerrain;
  }

  // ************************
  // _initMap
  // ************************
  void _initMap() {
    int counter = 0;

    // loop through and create initial map
    for (int r = 0; r < constMapRows; r++) {
      for (int c = 0; c < constMapCols; c++) {
        MapHex m = MapHex(counter, r, c);
        _map.add(m);
        // increment the counter
        counter++;
      }
    }

    // now go through and set up a few initial spots
    _map[_getIdFromRowCol(0, 0)].current = true; // start post
    _map[_getIdFromRowCol(0, 0)].terrain = EnumTerrain.scrub; // start in scrub
    _map[_getIdFromRowCol(4, 13)].terrain = EnumTerrain.river; // river
    _map[_getIdFromRowCol(3, 14)].terrain = EnumTerrain.river; // river
    _map[_getIdFromRowCol(4, 14)].terrain = EnumTerrain.rescue; // river

    // randomly pick adjacent terrain at the start
    _map[_getIdFromRowCol(0, 1)].terrain = _getRandomTerrain();
    _map[_getIdFromRowCol(1, 1)].terrain = _getRandomTerrain();
    _map[_getIdFromRowCol(1, 0)].terrain = _getRandomTerrain();
  }

  // ************************
  // _selectMapHex
  // ************************
  void _selectMapHex(int row, int col) {
    // set the map hex they selected as current, and re-draw
    int id = _getIdFromRowCol(row, col);
    int old = -1;

    // figure out what was previously selected
    for (MapHex hex in _map) {
      if (hex.current) {
        old = hex.id;
        break;
      }
    }

    setState(() {
      // clear all hexes
      for (MapHex hex in _map) {
        hex.current = false;
      }
      // set this one assuming it isn't same as the old
      if (id != old) {
        _map[id].current = true;
      }
    });
  }

  // ************************
  // _showMapHexInfo
  // ************************
  void _showMapHexInfo(int row, int col) {
    // show pop-up with terrain info or anything else
  }

  // ************************
  // build
  // ************************
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            backgroundColor: const Color(0xffd3d3d3),
            body: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Text("Health",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0)),
                        ),
                        Expanded(
                          child: Text("Proximity",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0)),
                        ),
                        Expanded(
                          child: Text("Endurance",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0)),
                        ),
                        Expanded(
                          child: Text("Turn",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0)),
                        ),
                      ]),
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Text("$_health",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 22.0)),
                        ),
                        Expanded(
                          child: Text("$_proximity",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 22.0)),
                        ),
                        Expanded(
                          child: Text("$_endurance",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 22.0)),
                        ),
                        Expanded(
                          child: Text("$_turn",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 22.0)),
                        ),
                      ]),
                  const Padding(
                    padding: EdgeInsets.all(2.0),
                  ),
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              debugPrint('Received click');
                            },
                            child: const Text('Inventory'),
                          ),
                        ),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              debugPrint('Received click');
                            },
                            child: const Text('Ailments'),
                          ),
                        ),
                      ]),
                  Expanded(
                      child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: HexagonOffsetGrid.evenFlat(
                      color: Colors.black54,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25.0, vertical: 75.0),
                      columns: constMapCols,
                      rows: constMapRows,
                      buildTile: (col, row) => HexagonWidgetBuilder(
                        elevation: 8.0, // col.toDouble(),
                        padding: _getMapHexPadding(
                            row, col), // how close together hexes are
                        cornerRadius: null, // hex shape (vs rounded)
                        color: _getMapHexColor(row, col),
                        //child: Text("$row, $col"),
                        child: GestureDetector(
                            onTap: () {
                              // do something
                              _selectMapHex(row, col);
                            },
                            onLongPress: () {
                              _showMapHexInfo(row, col);
                            },
                            child: Image.asset(_getMapHexGraphic(row,
                                col))), // put image here wrapped in a gesture detector
                      ),
                    ),
                  ))
                ])));
  }
}
