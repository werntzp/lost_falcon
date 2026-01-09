import 'package:lost_falcon/const.dart';
import 'package:lost_falcon/models/map_model.dart';
import 'dart:math';


class EncounterFactory {

  // lists for graphics and messages 
  final List<String> _paths = [];
  final List<String> _messages = [];

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

    enc = EnumEncounter.dust.name;
    _paths.add("$constImageEncounters$enc.jpg");      
    
    enc = EnumEncounter.chemicals.name;
    _paths.add("$constImageEncounters$enc.jpg");      
    
    enc = EnumEncounter.thorns.name;
    _paths.add("$constImageEncounters$enc.jpg");      
    
    enc = EnumEncounter.rockslide.name;
    _paths.add("$constImageEncounters$enc.jpg");      
    
    enc = EnumEncounter.highground.name;
    _paths.add("$constImageEncounters$enc.jpg");      
    
    enc = EnumEncounter.building.name;
    _paths.add("$constImageEncounters$enc.jpg");      
    
    enc = EnumEncounter.road.name;
    _paths.add("$constImageEncounters$enc.jpg");      
    
    enc = EnumEncounter.soldier.name;
    _paths.add("$constImageEncounters$enc.jpg");      
    
    enc = EnumEncounter.snake.name;
    _paths.add("$constImageEncounters$enc.jpg");      
    
    enc = EnumEncounter.wolf.name;
    _paths.add("$constImageEncounters$enc.jpg");      
    
    enc = EnumEncounter.mortar.name;
    _paths.add("$constImageEncounters$enc.jpg");      
    
    enc = EnumEncounter.helicopter.name;
    _paths.add("$constImageEncounters$enc.jpg");      
    
    enc = EnumEncounter.cave.name;
    _paths.add("$constImageEncounters$enc.jpg");      
    
    enc = EnumEncounter.gunships.name;
    _paths.add("$constImageEncounters$enc.jpg");      
    
    enc = EnumEncounter.minefield.name;
    _paths.add("$constImageEncounters$enc.jpg");      
    
    enc = EnumEncounter.sniper.name;
    _paths.add("$constImageEncounters$enc.jpg");      
    
    enc = EnumEncounter.milepost.name;
    _paths.add("$constImageEncounters$enc.jpg");      
    
    enc = EnumEncounter.tributary.name;
    _paths.add("$constImageEncounters$enc.jpg");   


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
  String getEncounterDescription(EnumEncounter encounter) { 
  
    return "E_NOTIMPL";

  }

  // ************************
  // depending where they are, did an encounter happen?  
  // ************************
  EnumEncounter getRandomEncounter(MapHex currentHex) {
    EnumEncounter encounter = EnumEncounter.none; 

    // roll two "dice" (tens and ones) and depending on distance from
    // starting hex, see whether the player has an encounter
    int tens = Random().nextInt(5) + 1;
    int ones = Random().nextInt(5) + 1;
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

    return encounter; 

  }

}