import 'package:lost_falcon/const.dart';
import 'package:lost_falcon/models/map_model.dart';
import 'dart:math';
import 'package:logger/logger.dart';

class EncounterFactory {
  // lists for graphics and messages
  final List<String> _paths = [];
  final List<String> _messages = [];
  final _logger = Logger(); 

  // three lists for encounters
  final List<List<EnumEncounter>> _close = List.generate(
    constDieSides + 1,
    (_) => List.filled(constDieSides + 1, EnumEncounter.none),
  );
  final List<List<EnumEncounter>> _medium = List.generate(
    constDieSides + 1,
    (_) => List.filled(constDieSides + 1, EnumEncounter.none),
  );
  final List<List<EnumEncounter>> _far = List.generate(
    constDieSides + 1,
    (_) => List.filled(constDieSides + 1, EnumEncounter.none),
  );

  EncounterFactory() {
    String enc = "";

    // fill specific spots in all the grids
    _close[1][1] = EnumEncounter.dust;
    _close[1][2] = EnumEncounter.dust;
    _close[1][3] = EnumEncounter.dust;
    _close[1][4] = EnumEncounter.dust;
    _close[1][5] = EnumEncounter.chemicals;
    _close[1][6] = EnumEncounter.thorns;
    _close[2][1] = EnumEncounter.rockslide;
    _close[5][5] = EnumEncounter.highground;
    _close[5][6] = EnumEncounter.building;
    _close[6][1] = EnumEncounter.road;
    _close[6][2] = EnumEncounter.road;
    _close[6][3] = EnumEncounter.road;
    _close[6][4] = EnumEncounter.soldier;
    _close[6][5] = EnumEncounter.soldier;
    _close[6][6] = EnumEncounter.soldier;

    _medium[1][1] = EnumEncounter.dust;
    _medium[1][2] = EnumEncounter.dust;
    _medium[1][3] = EnumEncounter.dust;
    _medium[1][4] = EnumEncounter.dust;
    _medium[1][5] = EnumEncounter.dust;
    _medium[1][6] = EnumEncounter.snake;
    _medium[2][1] = EnumEncounter.wolf;
    _medium[2][2] = EnumEncounter.mortar;
    _medium[2][3] = EnumEncounter.mortar;
    _medium[6][1] = EnumEncounter.helicopter;
    _medium[6][2] = EnumEncounter.helicopter;
    _medium[6][3] = EnumEncounter.apc;
    _medium[6][4] = EnumEncounter.cave;
    _medium[6][5] = EnumEncounter.gunships;
    _medium[6][6] = EnumEncounter.gunships;

    _far[1][1] = EnumEncounter.dust;
    _far[1][2] = EnumEncounter.rockslide;
    _far[1][3] = EnumEncounter.rockslide;
    _far[1][4] = EnumEncounter.rockslide;
    _far[1][5] = EnumEncounter.rockslide;
    _far[1][6] = EnumEncounter.minefield;
    _far[2][1] = EnumEncounter.sniper;
    _far[2][2] = EnumEncounter.sniper;
    _far[2][3] = EnumEncounter.sniper;
    _far[5][6] = EnumEncounter.milepost;
    _far[6][1] = EnumEncounter.tributary;
    _far[6][2] = EnumEncounter.tributary;
    _far[6][3] = EnumEncounter.building;
    _far[6][4] = EnumEncounter.gunships;
    _far[6][5] = EnumEncounter.gunships;
    _far[6][6] = EnumEncounter.gunships;

    enc = EnumEncounter.apc.name;
    _paths.add("$constImageEncounters$enc.jpg");
    _messages.add(constApcEncounterMessage);

    enc = EnumEncounter.dust.name;
    _paths.add("$constImageEncounters$enc.jpg");
    _messages.add(constDustEncounterMessage);

    enc = EnumEncounter.chemicals.name;
    _paths.add("$constImageEncounters$enc.jpg");
    _messages.add(constChemicalsEncounterMessage);

    enc = EnumEncounter.thorns.name;
    _paths.add("$constImageEncounters$enc.jpg");
    _messages.add(constThornsEncounterMessage);

    enc = EnumEncounter.rockslide.name;
    _paths.add("$constImageEncounters$enc.jpg");
    _messages.add(constRockslideEncounterMessage);

    enc = EnumEncounter.highground.name;
    _paths.add("$constImageEncounters$enc.jpg");
    _messages.add(constHighgroundEncounterMessage);

    enc = EnumEncounter.building.name;
    _paths.add("$constImageEncounters$enc.jpg");
    _messages.add(constBuildingEncounterMessage);

    enc = EnumEncounter.road.name;
    _paths.add("$constImageEncounters$enc.jpg");
    _messages.add(constRoadEncounterMessage);

    enc = EnumEncounter.soldier.name;
    _paths.add("$constImageEncounters$enc.jpg");
    _messages.add(constSoldierEncounterMessage);

    enc = EnumEncounter.snake.name;
    _paths.add("$constImageEncounters$enc.jpg");
    _messages.add(constSnakeEncounterMessage);

    enc = EnumEncounter.wolf.name;
    _paths.add("$constImageEncounters$enc.jpg");
    _messages.add(constWolfEncounterMessage);

    enc = EnumEncounter.mortar.name;
    _paths.add("$constImageEncounters$enc.jpg");
    _messages.add(constMortarEncounterMessage);

    enc = EnumEncounter.helicopter.name;
    _paths.add("$constImageEncounters$enc.jpg");
    _messages.add(constHelicopterEncounterMessage);

    enc = EnumEncounter.cave.name;
    _paths.add("$constImageEncounters$enc.jpg");
    _messages.add(constCaveEncounterMessage);

    enc = EnumEncounter.gunships.name;
    _paths.add("$constImageEncounters$enc.jpg");
    _messages.add(constGunshipsEncounterMessage);

    enc = EnumEncounter.minefield.name;
    _paths.add("$constImageEncounters$enc.jpg");
    _messages.add(constMinefieldEncounterMessage);

    enc = EnumEncounter.sniper.name;
    _paths.add("$constImageEncounters$enc.jpg");
    _messages.add(constSniperEncounterMessage);

    enc = EnumEncounter.milepost.name;
    _paths.add("$constImageEncounters$enc.jpg");
    _messages.add(constMilepostEncounterMessage);

    enc = EnumEncounter.tributary.name;
    _paths.add("$constImageEncounters$enc.jpg");
    _messages.add(constTributaryEncounterMessage);

    enc = EnumEncounter.none.name;
    _paths.add("$constImageEncounters$enc.jpg");
    _messages.add(constNoEncounterMessage);
  }

  // ************************
  // list of encounters as strings in a list
  // ************************
  List<String> getEncounterVisuals() {
    return List.from(_paths);
  }

  // ************************
  // encounter description
  // ************************
  String getEncounterDescription(int index) {
    return _messages[index];
  }

  // ************************
  // get an individual encounter graphic 
  // ************************
  String getEncounterGraphic(int index) {
    return _paths[index];
  }

  // ************************
  // collapse 2d array into a 1d 
  // ************************
  List<EnumEncounter> _fold(List<List<EnumEncounter>> original) {
    List<EnumEncounter> folded = []; 

    for (var r = original.length - 1; r >= 0; r--) {
      for (var c = original[r].length - 1; c >= 0; c--) {
        if (original[r][c] != EnumEncounter.none) {
          folded.add(original[r][c]);
        }
      }
    }

    return List.from(folded);

  }

  // ************************
  // when forcing an encounter, return just from the list 
  // and again, that depends where they are 
  // ************************
  int getForcedEncounter(MapHex currentHex) {
    MapHex startHex = MapHex(constFakeHex, constStartRow, constStartCol);
    int distance = MapFactory.getDistanceBetweenHexes(startHex, currentHex);
    List<EnumEncounter> encounters = []; 

    // use the distance to figure out which array to use 
    // 1-4 hexes from start
    if ((distance >= 1) && (distance <= 4)) {
      encounters = _fold(_close);
      // 5-9
    } else if ((distance >= 5) && (distance <= 9)) {
      encounters = _fold(_medium);
      // 10-15
    } else if ((distance >= 10) && (distance <= 15)) {
      encounters = _fold(_far);
    }

    // now pick randomly 
    return Random().nextInt(encounters.length) + 1; 

  }

  // ************************
  // depending where they are, did an encounter happen? 
  // ************************
  int getRandomEncounter(MapHex currentHex) {
    EnumEncounter encounter = EnumEncounter.none;

    // roll two "dice" (tens and ones) and depending on distance from
    // starting hex, see whether the player has an encounter
    int tens = Random().nextInt(6) + 1;
    int ones = Random().nextInt(6) + 1;

    _logger.d("encounter roll: $tens$ones");
    
    MapHex startHex = MapHex(constFakeHex, constStartRow, constStartCol);
    int distance = MapFactory.getDistanceBetweenHexes(startHex, currentHex);

    // 1-4 hexes from start
    if ((distance >= 1) && (distance <= 4)) {
      encounter = _close[tens][ones];
      // 5-9
    } else if ((distance >= 5) && (distance <= 9)) {
      encounter = _medium[tens][ones];
      // 10-15
    } else if ((distance >= 10) && (distance <= 15)) {
      encounter = _far[tens][ones];
    }

    return encounter.index;
  }
}
