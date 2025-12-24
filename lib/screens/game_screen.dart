import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hexagon/hexagon.dart';
import 'package:lost_falcon/const.dart';
import 'allocation_screen.dart';
import 'die_roll_screen.dart';
import '../models/map_model.dart';
import 'dart:math';
import "package:shared_preferences/shared_preferences.dart";

int _turn = 1;
int _proximity = 6;
int _health = 6;
int _endurance = 6;
int _move = 0;
int _stealth = 0;
int _rest = 0;
EnumPhase _phase = EnumPhase.mapping;
EnumEncounter _encounter = EnumEncounter.none;
List<MapHex> _map = [];
bool _moveAllowed = false;
List<int> _hexesTraveled = [];

extension StringExtension on String {
  String capitalizeFirstLetter() {
    if (isEmpty) {
      return this;
    }
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
    _newGame();
  }

  // ************************
  // _showAlertDialog
  // ************************
  void _showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(message,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'LumanosimoRegular',
                  fontSize: 25.0)),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'LumanosimoRegular',
                      fontSize: 20.0)),
            ),
          ],
        );
      },
    );
  }

  // ************************
  // _newGame
  // ************************
  void _newGame() async {
    // set up the map
    _initMap();

    // initial values
    _turn = 1;
    _proximity = 6;
    _health = 6;
    _endurance = 6;
    _move = 0;
    _stealth = 0;
    _rest = 0;
    _phase = EnumPhase.mapping;

    // go to button press
    _continueButtonPress();
  }

  // ************************
  // _healthImage
  // ************************
  AssetImage _healthImage() {
    // decide which image to reutrn based on health
    if (_health == 6) {
      return const AssetImage(constImageStatus6);
    } else if (_health == 5) {
      return const AssetImage(constImageStatus5);
    } else if (_health == 4) {
      return const AssetImage(constImageStatus4);
    } else if (_health == 3) {
      return const AssetImage(constImageStatus3);
    } else if (_health == 2) {
      return const AssetImage(constImageStatus2);
    } else if (_health == 1) {
      return const AssetImage(constImageStatus1);
    } else {
      return const AssetImage(constImageStatus0);
    }
  }

  // ************************
  // _proximityImage
  // ************************
  AssetImage _proximityImage() {
    // decide which image to reutrn based on health
    if (_proximity == 6) {
      return const AssetImage(constImageStatus6);
    } else if (_proximity == 5) {
      return const AssetImage(constImageStatus5);
    } else if (_proximity == 4) {
      return const AssetImage(constImageStatus4);
    } else if (_proximity == 3) {
      return const AssetImage(constImageStatus3);
    } else if (_proximity == 2) {
      return const AssetImage(constImageStatus2);
    } else if (_proximity == 1) {
      return const AssetImage(constImageStatus1);
    } else {
      return const AssetImage(constImageStatus0);
    }
  }

  // ************************
  // _enduranceImage
  // ************************
  AssetImage _enduranceImage() {
    // decide which image to reutrn based on health
    if (_endurance == 6) {
      return const AssetImage(constImageStatus6);
    } else if (_endurance == 5) {
      return const AssetImage(constImageStatus5);
    } else if (_endurance == 4) {
      return const AssetImage(constImageStatus4);
    } else if (_endurance == 3) {
      return const AssetImage(constImageStatus3);
    } else if (_endurance == 2) {
      return const AssetImage(constImageStatus2);
    } else if (_endurance == 1) {
      return const AssetImage(constImageStatus1);
    } else {
      return const AssetImage(constImageStatus0);
    }
  }

  // ************************
  // _moveImage
  // ************************
  AssetImage _moveImage() {
    // decide which image to reutrn based on health
    if (_move == 6) {
      return const AssetImage(constImageDie6);
    } else if (_move == 5) {
      return const AssetImage(constImageDie5);
    } else if (_move == 4) {
      return const AssetImage(constImageDie4);
    } else if (_move == 3) {
      return const AssetImage(constImageDie3);
    } else if (_move == 2) {
      return const AssetImage(constImageDie2);
    } else if (_move == 1) {
      return const AssetImage(constImageDie1);
    } else {
      return const AssetImage(constImageDie0);
    }
  }

  // ************************
  // _stealthImage
  // ************************
  AssetImage _stealthImage() {
    // decide which image to reutrn based on health
    if (_stealth == 6) {
      return const AssetImage(constImageDie6);
    } else if (_stealth == 5) {
      return const AssetImage(constImageDie5);
    } else if (_stealth == 4) {
      return const AssetImage(constImageDie4);
    } else if (_stealth == 3) {
      return const AssetImage(constImageDie3);
    } else if (_stealth == 2) {
      return const AssetImage(constImageDie2);
    } else if (_stealth == 1) {
      return const AssetImage(constImageDie1);
    } else {
      return const AssetImage(constImageDie0);
    }
  }

  // ************************
  // _restImage
  // ************************
  AssetImage _restImage() {
    // decide which image to reutrn based on health
    if (_rest == 6) {
      return const AssetImage(constImageDie6);
    } else if (_rest == 5) {
      return const AssetImage(constImageDie5);
    } else if (_rest == 4) {
      return const AssetImage(constImageDie4);
    } else if (_rest == 3) {
      return const AssetImage(constImageDie3);
    } else if (_rest == 2) {
      return const AssetImage(constImageDie2);
    } else if (_rest == 1) {
      return const AssetImage(constImageDie1);
    } else {
      return const AssetImage(constImageDie0);
    }
  }

  // ************************
  // _displayPhase
  // ************************
  String _displayPhase(bool next) {
    String phase = "";

    if (next) {
      // if we're at last phase, need to roll back to first one
      try {
        phase = EnumPhase.values[_phase.index + 1].name;
      } catch (e) {
        phase = EnumPhase.mapping.name;
      }
    } else {
      phase = EnumPhase.values[_phase.index].name;
    }

    return phase.capitalizeFirstLetter();
  }

  // ************************
  // _displayTurn
  // ************************
  String _displayTurn() {
    return _turn.toString();
  }

  // ************************
  // _doRestPhase
  // ************************
  void _doRestPhase() {
    int highRoll = 0;
    int restCost = 0;
    bool playerRested = false;
    bool playerHurt = false;
    String dialogMessage = "";

    // loop through dice allocated, grab top one
    for (int i = 1; i <= _rest; i++) {
      int roll = Random().nextInt(6) + 1;
      if (roll > highRoll) {
        highRoll = roll;
      }
    }

    // then see what rest cost is for the hext they are in
    MapHex h = _getCurrentHex();
    if (h.terrain == EnumTerrain.scrub) {
      restCost = constScrubStealthCost;
    } else if (h.terrain == EnumTerrain.brush) {
      restCost = constBrushStealthCost;
    } else if (h.terrain == EnumTerrain.hills) {
      restCost = constHillsStealthCost;
    } else if (h.terrain == EnumTerrain.village) {
      restCost = constVillageStealthCost;
    } else if (h.terrain == EnumTerrain.rough) {
      restCost = constRoughStealthCost;
    }

    // if die roll higher than map hex cost, they were successful,
    // otherwise decrement endurance by one
    if (highRoll >= restCost) {
      playerRested = true;
    }
    if (highRoll == 6) {
      playerHurt;
    }

    setState(() {
      // if rested and less than six, get one back
      if ((playerRested == true) && (_endurance < 6)) {
        _endurance++;
      }
      // if not rested, decrement endurance
      if (!playerRested) {
        _endurance--;
      }
      // if also hurt, lose a health
      if (playerHurt == true) {
        _health--;
      }
    });

    // display relevant dialog
    if (playerRested == true) {
      dialogMessage = "You successfully rested and kept up your endurance. ";
    } else {
      dialogMessage = "You were unable to rest and are getting weaker. ";
    }
    if (playerHurt == true) {
      dialogMessage += "You also lost health due to a nagging injury.";
    }
    _showAlertDialog(context, dialogMessage);
  }

  // ************************
  // _doStealthPhase
  // ************************
  void _doStealthPhase() {
    int highRoll = 0;
    int stealthCost = 0;
    bool playerHid = false;
    bool playerHurt = false;
    String dialogMessage = "";

    // loop through dice allocated, grab top one
    for (int i = 1; i <= _stealth; i++) {
      int roll = Random().nextInt(6) + 1;
      if (roll > highRoll) {
        highRoll = roll;
      }
    }

    // then see what stealth cost is for the hext they are in
    MapHex h = _getCurrentHex();
    if (h.terrain == EnumTerrain.scrub) {
      stealthCost = constScrubStealthCost;
    } else if (h.terrain == EnumTerrain.brush) {
      stealthCost = constBrushStealthCost;
    } else if (h.terrain == EnumTerrain.hills) {
      stealthCost = constHillsStealthCost;
    } else if (h.terrain == EnumTerrain.village) {
      stealthCost = constVillageStealthCost;
    } else if (h.terrain == EnumTerrain.rough) {
      stealthCost = constRoughStealthCost;
    }

    // if die roll higher than map hex cost, they were successful,
    // otherwise decrement proximity by one
    if (highRoll >= stealthCost) {
      playerHid = true;
    }
    if (highRoll == 6) {
      playerHurt;
    }

    setState(() {
      if (!playerHid) {
        _proximity--;
      }
      if (playerHurt == true) {
        _health--;
      }
    });

    // display relevant dialog
    if (playerHid == true) {
      dialogMessage =
          "You successfully hid and kept your distance from pursuering forces this turn. ";
    } else {
      dialogMessage =
          "You were unable to hide from your pursuers as they continue to gain on you. ";
    }
    if (playerHurt == true) {
      dialogMessage += "You were injured in the process and lost health.";
    }
    _showAlertDialog(context, dialogMessage);
  }

  // ************************
  // _doEncounterPhase
  // ************************
  void _doEncounterPhase() {
    // roll two "dice" (tens and ones) and depending on distance from
    // starting hex, see whether the player has an encounter
    int tens = Random().nextInt(5) + 1;
    int ones = Random().nextInt(5) + 1;
    int distance = _getDistance();

    // based on distance, check for encounters
    if ((distance >= 1) && (distance <= 4)) {
      if (tens == 1) {
        if ((ones >= 1) && (ones <= 4)) {
          _encounter = EnumEncounter.dust;
        } else if (ones == 5) {
          _encounter = EnumEncounter.chemicals;
        } else if (ones == 6) {
          _encounter = EnumEncounter.thorns;
        }
      } else if (tens == 2) {
      } else if (tens == 5) {
      } else if (tens == 6) {}
    } else if ((distance >= 5) && (distance <= 9)) {
      //
    } else if ((distance >= 10) && (distance <= 15)) {
      //
    }
  }

  void _doMappingPhase() {
    int die = Random().nextInt(6) + 1;
    EnumTerrain hex1;
    EnumTerrain hex2;
    EnumTerrain hex3;
    EnumTerrain hexToUse;
    int hexCount = 0;
    MapHex currentHex = _getCurrentHex();
    int row = currentHex.row;
    int col = currentHex.col;

    // pick terrain for the next three hexes based on random roll
    if (die == 1) {
      hex1 = EnumTerrain.brush;
      hex2 = EnumTerrain.scrub;
      hex3 = EnumTerrain.scrub;
    } else if (die == 2) {
      hex1 = EnumTerrain.brush;
      hex2 = EnumTerrain.hills;
      hex3 = EnumTerrain.brush;
    } else if (die == 3) {
      hex1 = EnumTerrain.brush;
      hex2 = EnumTerrain.rough;
      hex3 = EnumTerrain.brush;
    } else if (die == 4) {
      hex1 = EnumTerrain.rough;
      hex2 = EnumTerrain.brush;
      hex3 = EnumTerrain.hills;
    } else if (die == 5) {
      hex1 = EnumTerrain.scrub;
      hex2 = EnumTerrain.rough;
      hex3 = EnumTerrain.scrub;
    } else {
      hex1 = EnumTerrain.rough;
      hex2 = EnumTerrain.village;
      hex3 = EnumTerrain.rough;
    }

    // start with first hex
    hexToUse = hex1;
    hexCount = 1;

    // start to fill in hexes - depending on whether they are valid hexes and not already filled
    // walk around the whole way; should only hit 3 of these 4 in every situation

    // row -1, col
    if (((row - 1) >= 0)) {
      if (_map[_getIdFromColRow(col, row - 1)].visible == false) {
        _map[_getIdFromColRow(col, row - 1)].terrain = hexToUse;
        _map[_getIdFromColRow(col, row - 1)].visible = true;
        hexCount++;
      }
    }

    // only do row +1, col +1 if the current column is even
    if (col % 2 == 0) {
      if (((row + 1) <= constMapRows) && ((col + 1) <= constMapCols)) {
        if (_map[_getIdFromColRow(col + 1, row + 1)].visible == false) {
          if (hexCount == 1) {
            hexToUse = hex1;
          } else if (hexCount == 2) {
            hexToUse = hex2;
          } else {
            hexToUse = hex3;
          }
          _map[_getIdFromColRow(col + 1, row + 1)].terrain = hexToUse;
          _map[_getIdFromColRow(col + 1, row + 1)].visible = true;
          hexCount++;
        }
      }
    }

    // row, col +1
    if ((col + 1) <= constMapCols) {
      if (_map[_getIdFromColRow(col + 1, row)].visible == false) {
        if (hexCount == 1) {
          hexToUse = hex1;
        } else if (hexCount == 2) {
          hexToUse = hex2;
        } else {
          hexToUse = hex3;
        }
        _map[_getIdFromColRow(col + 1, row)].terrain = hexToUse;
        _map[_getIdFromColRow(col + 1, row)].visible = true;
        hexCount++;
      }
    }

    // row +1, col
    if ((row + 1) <= constMapRows) {
      if (_map[_getIdFromColRow(col, row + 1)].visible == false) {
        if (hexCount == 1) {
          hexToUse = hex1;
        } else if (hexCount == 2) {
          hexToUse = hex2;
        } else {
          hexToUse = hex3;
        }
        _map[_getIdFromColRow(col, row + 1)].terrain = hexToUse;
        _map[_getIdFromColRow(col, row + 1)].visible = true;
        hexCount++;
      }
    }

    // row - 1, col +1
    if (hexCount < 4) {
      if (((row - 1) >= 0) && ((col + 1) <= constMapCols)) {
        if (_map[_getIdFromColRow(col + 1, row - 1)].visible == false) {
          if (hexCount == 1) {
            hexToUse = hex1;
          } else if (hexCount == 2) {
            hexToUse = hex2;
          } else {
            hexToUse = hex3;
          }
          _map[_getIdFromColRow(col + 1, row - 1)].terrain = hexToUse;
          _map[_getIdFromColRow(col + 1, row - 1)].visible = true;
          hexCount++;
        }
      }
    }

    // row , col +1
    if (hexCount < 4) {
      if ((col - 1) >= 0) {
        if (_map[_getIdFromColRow(col - 1, row)].visible == false) {
          if (hexCount == 1) {
            hexToUse = hex1;
          } else if (hexCount == 2) {
            hexToUse = hex2;
          } else {
            hexToUse = hex3;
          }
          _map[_getIdFromColRow(col - 1, row)].terrain = hexToUse;
          _map[_getIdFromColRow(col - 1, row)].visible = true;
          hexCount++;
        }
      }
    }

    // row +1 , col -1
    if (hexCount < 4) {
      if (((row + 1) <= constMapRows) && ((col - 1) >= 0)) {
        if (_map[_getIdFromColRow(col - 1, row)].visible == false) {
          if (hexCount == 1) {
            hexToUse = hex1;
          } else if (hexCount == 2) {
            hexToUse = hex2;
          } else {
            hexToUse = hex3;
          }
          _map[_getIdFromColRow(col - 1, row + 1)].terrain = hexToUse;
          _map[_getIdFromColRow(col - 1, row + 1)].visible = true;
          hexCount++;
        }
      }
    }

    setState(() {
      // nothing to do here yet
    });
  }

  // ************************
  // _continueButtonPress
  // ************************
  void _continueButtonPress() async {
    // increment the phase from current one since they moved to the next
    try {
      _phase = EnumPhase.values[_phase.index + 1];
    } catch (e) {
      // if we hit the end of the phases, go back to the beginning
      _phase = EnumPhase.mapping;
      // and increment the turn
      setState(() {
        _turn++;
      });
    }

    // special case -- for turn 1, do initial mapping, skip encounter, and go right to allocation
    if ((_turn == 1) && (_phase == EnumPhase.encounter)) {
      _doMappingPhase();
      _phase = EnumPhase.allocate;
    }

    // if mapping phase, populate next three hexes
    if (_phase == EnumPhase.mapping) {
      _doMappingPhase();
    }
    // if map phase, then we're going to the encounter phase

    // if encounter phase, decide if they had an encounter
    if (_phase == EnumPhase.encounter) {
      _doEncounterPhase();
    }

    // if allocate phase, bring up allocation dialog
    if (_phase == EnumPhase.allocate) {
      // send the number of dice available to allocate
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt("endurance", _endurance);

      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AllocationScreen()),
      );
      // if they allocated, update the values
      if (result != null) {
        setState(() {
          _move = (prefs.getInt("move") ?? 0);
          _stealth = (prefs.getInt("stealth") ?? 0);
          _rest = (prefs.getInt("rest") ?? 0);
        });
      }
    }

    // if move phase, see if they are able to move out of the current hex based on die/point allocation
    if (_phase == EnumPhase.move) {
      // set flag that allows a move (so they only do it once per turn)
      _moveAllowed = true;
    }

    // if stealth phase, decide whether they successfully hid from pursuers
    if (_phase == EnumPhase.stealth) {
      _doStealthPhase();
    }

    // if rest phase, decide whether they lose any endurance
    if (_phase == EnumPhase.rest) {
      _doRestPhase();
    }

    // finally
    setState(() {
      // nothing to do here yet
    });
  }

  // ************************
  // _getDistance
  // ************************
  int _getDistance() {
    // figure out the distance between starting hex and destination (current one)
    MapHex startHex = MapHex(constFakeHex, constStartRow, constStartCol);
    MapHex destHex = _getCurrentHex();
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
  // _getCurrentHex
  // ************************
  MapHex _getCurrentHex() {
    MapHex hex = MapHex(constFakeHex, constFakeHex, constFakeHex);
    for (MapHex m in _map) {
      if (m.current) {
        hex = m;
        break;
      }
    }

    return hex;
  }

  // ************************
  // _getIdFromRowCol
  // ************************
  int _getIdFromColRow(int col, int row) {
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
    int id = _getIdFromColRow(col, row);

    // if they've traveled through a hex, give it more padding
    if (_hexesTraveled.contains(id)) {
      return 5.0;
    } else {
      return 1.0;
    }
    /*
    if (_map[id].current) {
      return 5.0;
    } else {
      return 1.0;
    }
    */
  }

  // ************************
  // _getMapHexGraphic
  // ************************
  String _getMapHexGraphic(int row, int col) {
    EnumTerrain enumTerrain = _map[_getIdFromColRow(col, row)].terrain;
    String asset;
    bool isCurrentPlayerLocation = _map[_getIdFromColRow(col, row)].current;
    int id = _getIdFromColRow(col, row);

    if (isCurrentPlayerLocation) {
      asset = constImagePlayerLocation;
    } else {
      if (enumTerrain == EnumTerrain.scrub) {
        // decide whether they've been here before (color vs b&w)
        if (_hexesTraveled.contains(id)) {
          asset = constImageScrub;
        } else {
          asset = constImageScrubGrey;
        }
      } else if (enumTerrain == EnumTerrain.brush) {
        // decide whether they've been here before (color vs b&w)
        if (_hexesTraveled.contains(id)) {
          asset = constImageBrush;
        } else {
          asset = constImageBrushGrey;
        }
      } else if (enumTerrain == EnumTerrain.hills) {
        // decide whether they've been here before (color vs b&w)
        if (_hexesTraveled.contains(id)) {
          asset = constImageHills;
        } else {
          asset = constImageHillsGrey;
        }
      } else if (enumTerrain == EnumTerrain.rough) {
        // decide whether they've been here before (color vs b&w)
        if (_hexesTraveled.contains(id)) {
          asset = constImageRough;
        } else {
          asset = constImageRoughGrey;
        }
      } else if (enumTerrain == EnumTerrain.village) {
        // decide whether they've been here before (color vs b&w)
        if (_hexesTraveled.contains(id)) {
          asset = constImageVillage;
        } else {
          asset = constImageVillageGrey;
        }
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
    EnumTerrain enumTerrain = _map[_getIdFromColRow(col, row)].terrain;
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
    for (int c = 0; c < constMapCols; c++) {
      for (int r = 0; r < constMapRows; r++) {
        MapHex m = MapHex(counter, c, r);
        _map.add(m);
        // increment the counter
        counter++;
      }
    }

    // now go through and set up a few initial spots
    _map[_getIdFromColRow(constStartCol, constStartRow)].current =
        true; // start post
    _map[_getIdFromColRow(constStartCol, constStartRow)].terrain =
        EnumTerrain.scrub; // start in scrub
    _map[_getIdFromColRow(constStartCol, constStartRow)].visible = true;

    // add the starting hex to the list the player travels
    _hexesTraveled.add(_getIdFromColRow(constStartCol, constStartRow));

    // rescue hex
    _map[_getIdFromColRow(14, 4)].terrain = EnumTerrain.rescue;
    _map[_getIdFromColRow(14, 4)].visible = true;
  }

  // ************************
  // _selectMapHex
  // ************************
  void _selectMapHex(int row, int col) async {
    bool playerMoved = false;
    int moveCost = 0;

    // get current hex
    MapHex h = _getCurrentHex();
    // save that for the moment
    int old = h.id;
    // get the id of the hex they selected
    int selected = _getIdFromColRow(col, row);

    // if this is move phase, do all the logic
    if ((_phase == EnumPhase.move) && (_moveAllowed)) {
      // if they have allocated move points, see if they have enough to move out of current hex
      if (_move > 0) {
        // what is the move cost?
        if (h.terrain == EnumTerrain.scrub) {
          moveCost = constScrubMoveCost;
        } else if (h.terrain == EnumTerrain.brush) {
          moveCost = constBrushMoveCost;
        } else if (h.terrain == EnumTerrain.hills) {
          moveCost = constHillsMoveCost;
        } else if (h.terrain == EnumTerrain.village) {
          moveCost = constVillageMoveCost;
        } else if (h.terrain == EnumTerrain.rough) {
          moveCost = constRoughMoveCost;
        }

        // go to the die result screen
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setInt("die", _move);
        prefs.setInt("success", moveCost);
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DieRollScreen()),
        );

        // what did we get back?
        if (result != null) {
          playerMoved = (prefs.getBool("success") ?? false);
        }
      } else {
        _showAlertDialog(context, constNoMovePoints);
      }

      // if they moved, update screen, otherwise let them know what happened
      if (playerMoved) {
        setState(() {
          // clear all hexes
          for (MapHex hex in _map) {
            hex.current = false;
          }
          // set this one assuming it isn't same as the old and add it to the list traveled
          if (selected != old) {
            _map[selected].current = true;
            _hexesTraveled.add(selected);
          }
          // map out next hexes
          _doMappingPhase();
        });
      } else {
        _showAlertDialog(context, constMoveFailed);
      }
      // regardless of whether succesful or not, no more moves
      _moveAllowed = false;
    }
  }

  // ************************
  // _showMapHexInfo
  // ************************
  void _showMapHexInfo(int row, int col) {
    // show pop-up with terrain info or anything else
    debugPrint("_showMapHexInfo long press");
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
                  const Padding(
                    padding: EdgeInsets.all(3.0),
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                              const Text("Health",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'LumanosimoRegular',
                                      fontSize: 15.0)),
                              Image(
                                image: _healthImage(),
                                width: 60.0,
                                height: 15.0,
                                fit: BoxFit.fill,
                              ),
                              const Padding(
                                padding: EdgeInsets.all(1.0),
                              ),
                              const Text("Proximity",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'LumanosimoRegular',
                                      fontSize: 15.0)),
                              Image(
                                image: _proximityImage(),
                                width: 60.0,
                                height: 15.0,
                                fit: BoxFit.fill,
                              ),
                              const Padding(
                                padding: EdgeInsets.all(1.0),
                              ),
                              const Text("Endurance",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'LumanosimoRegular',
                                      fontSize: 15.0)),
                              Image(
                                image: _enduranceImage(),
                                width: 60.0,
                                height: 15.0,
                                fit: BoxFit.fill,
                              ),
                              const Padding(
                                padding: EdgeInsets.all(1.0),
                              ),
                            ])),
                        Expanded(
                            child: Column(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text("Move",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'LumanosimoRegular',
                                        fontSize: 15.0)),
                                Image(
                                  image: _moveImage(),
                                  width: 60.0,
                                  height: 15.0,
                                  fit: BoxFit.fill,
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(1.0),
                                ),
                                const Text("Stealth",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'LumanosimoRegular',
                                        fontSize: 15.0)),
                                Image(
                                  image: _stealthImage(),
                                  width: 60.0,
                                  height: 15.0,
                                  fit: BoxFit.fill,
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(1.0),
                                ),
                                const Text("Rest",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'LumanosimoRegular',
                                        fontSize: 15.0)),
                                Image(
                                  image: _restImage(),
                                  width: 60.0,
                                  height: 15.0,
                                  fit: BoxFit.fill,
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(1.0),
                                ),
                              ],
                            )
                          ],
                        )),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                              const Text("Turn",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'LumanosimoRegular',
                                      fontSize: 25.0)),
                              const Padding(
                                padding: EdgeInsets.all(1.0),
                              ),
                              Text(_displayTurn(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'LumanosimoRegular',
                                      fontSize: 22.0)),
                              const Padding(
                                padding: EdgeInsets.all(1.0),
                              ),
                              Text(_displayPhase(false),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'LumanosimoRegular',
                                      fontSize: 22.0)),
                            ])),
                      ]),
                  const Padding(
                    padding: EdgeInsets.all(2.0),
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.black45),
                          onPressed: () {
                            debugPrint('Received click');
                          },
                          child: const Text('Inventory',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'LumanosimoRegular',
                                  fontSize: 15.0)),
                        ),
                        const SizedBox(width: 15),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.black45),
                          onPressed: () {
                            debugPrint('Received click');
                          },
                          child: const Text('Ailments',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'LumanosimoRegular',
                                  fontSize: 15.0)),
                        ),
                      ]),
                  Expanded(
                      child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: HexagonOffsetGrid.evenFlat(
                      color: Colors.black54,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 35.0),
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
                              debugPrint("row: " +
                                  row.toString() +
                                  ", col: " +
                                  col.toString());

                              // do something if we're in the move phase
                              if (_phase == EnumPhase.move) {
                                _selectMapHex(row, col);
                              }
                            },
                            onLongPress: () {
                              _showMapHexInfo(row, col);
                            },
                            child: AspectRatio(
                                aspectRatio: HexagonType.FLAT.ratio,
                                child: Image.asset(
                                  _getMapHexGraphic(row, col),
                                  fit: BoxFit.cover,
                                ))), // put image here wrapped in a gesture detector
                      ),
                    ),
                  )),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.black45),
                          onPressed: () {
                            _continueButtonPress();
                          },
                          child: Text(
                              "Continue to ${_displayPhase(true)} phase",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'LumanosimoRegular',
                                  fontSize: 15.0)),
                        ),
                      ]),
                ])));
  }
}
