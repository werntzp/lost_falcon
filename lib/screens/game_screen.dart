import 'package:flutter/material.dart';
import 'package:hexagon/hexagon.dart';
import 'package:lost_falcon/const.dart';
import 'package:lost_falcon/models/encounter_model.dart';
import '../models/map_model.dart';
import '../models/pilot_model.dart';
import '../dialogs/terrain_dialog.dart';
import '../dialogs/info_dialog.dart';
import 'dart:math';
import 'dart:async';

Pilot _pilot = Pilot();
final EncounterFactory _encounterFactory = EncounterFactory();
int _round = 1;
int _moveDice = constNoDice;
int _stealthDice = constNoDice;
int _restDice = constNoDice;
int _totalDice = _pilot.getEndurance();
int _oldHex = 0;
int _selectedHex = 0;
int _motorcycleMoves = 0;
EnumPhase _phase = EnumPhase.mapping;
List<MapHex> _map = [];
bool _moveAllowed = false;
Set<int> _hexesTraveled = {};
Set<int> _hexesImpassable = {};
Set<int> _hexesCrashedChopper = {}; 
List<int> _rollingDice = [];
Timer? _rollTimer;
bool _allowedToReRoll = false;
int _currentEncounterIndex = 1;
List<Image> _encounterImages = [];
bool _skipRest = false;
bool _skipStealh = false; 

EnumVillageReactions _villageReaction = EnumVillageReactions.none;

// extension used to capitalize the first letter of a word
extension StringExtension on String {
  String capitalizeFirstLetter() {
    if (isEmpty) {
      return this;
    }
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

// *********************************************
//  class to cycle images in the overlay
// *********************************************
class ImageCyclerOverlay extends StatefulWidget {
  final VoidCallback onClose;

  const ImageCyclerOverlay({super.key, required this.onClose});

  @override
  State<ImageCyclerOverlay> createState() => _ImageCyclerOverlayState();
}

// *********************************************
//  implementation code
// *********************************************
class _ImageCyclerOverlayState extends State<ImageCyclerOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> fade;

  final rand = Random();
  int index = 0;
  bool ready = false;
  Timer? timer;
  String message = constEncountersMessage;
  bool handleEncounter = false;

  // ************************
  // pick terrain
  // ************************
  void _pickTerrain(int col, int row) {
    int id = 0;

    id = _getIdFromColRow(col, row);
    if (!_map[id].visible) {
      Random().nextBool()
          ? _map[id].terrain = EnumTerrain.scrub
          : _map[id].terrain = EnumTerrain.brush;
      _map[id].visible = true;
    }
  }

  // ************************
  // randomly mark terrain around the marked spot
  // ************************
  void _setTerrainAroundSpot(int col, int row) {
    int newRow = 0;
    int newCol = 0;

    // walk around this new spot and change terrain to brush or scrub
    // row -1, col
    newCol = col;
    newRow = row - 1;
    if ((newRow >= 0)) {
      _pickTerrain(newCol, newRow);
    }

    // row +1, col
    newCol = col;
    newRow = row + 1;
    if ((newRow <= constMapRows)) {
      _pickTerrain(newCol, newRow);
    }

    // for even cols
    if (col % 2 == 0) {
      // row, col +1
      newCol = col + 1;
      newRow = row;
      if ((newCol <= constMapCols)) {
        _pickTerrain(newCol, newRow);
      }

      // row, col -1
      newCol = col - 1;
      newRow = row;
      if ((newCol >= 0)) {
        _pickTerrain(newCol, newRow);
      }

      // row +1, col +1
      newCol = col + 1;
      newRow = row + 1;
      if ((newRow <= constMapRows) || (newCol <= constMapCols)) {
        _pickTerrain(newCol, newRow);
      }

      // row +1, col -1
      newCol = col - 1;
      newRow = row + 1;
      if ((newRow <= constMapRows) || (newCol >= 0)) {
        _pickTerrain(newCol, newRow);
      }
    } else {
      // row -1, col +1
      newCol = col + 1;
      newRow = row - 1;
      if ((newRow >= 0) || (newCol <= constMapCols)) {
        _pickTerrain(newCol, newRow);
      }

      // row, col +1;
      newCol = col + 1;
      newRow = row;
      if ((newCol <= constMapCols)) {
        _pickTerrain(newCol, newRow);
      }

      // row -1, col -1
      newCol = col - 1;
      newRow = row - 1;
      if ((newRow >= 0) || (newCol >= 0)) {
        _pickTerrain(newCol, newRow);
      }

      // row, col -1
      newCol = col - 1;
      newRow = row;
      if ((newCol >= 0)) {
        _pickTerrain(newCol, newRow);
      }
    }
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

  // *********************************************
  //  mortar - run to next hex
  // *********************************************
  void  _doMortarRun() {
    int newId = _getIdFromColRow(_map[_selectedHex].col+1, _map[_selectedHex].row);
    
    _hexesTraveled.add(_selectedHex);
    _map[_selectedHex].current = false; 
    _hexesTraveled.add(newId);
    _map[newId].current = true; 
    _pilot.setEndurance(EnumDirection.decrement);
    _pilot.setAffliction(EnumAffliction.gunshotwound);

  }

  // *********************************************
  //  mortar - drop
  // *********************************************
  void  _doMortarDrop() {
    _pilot.setProximity(EnumDirection.decrement);
  }  
 
  // *********************************************
  //  mortar - choose what happens when mortars rain down
  // *********************************************
  Widget _returnMortar() {
    return 
      Column(
        children: [
        SizedBox(
            width: 250.0,
            height: 70.0,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black, // Text and icon color
                backgroundColor: Colors.white, // Background color
                overlayColor: Colors.blueAccent.withValues(), // pressed ripple
                side: const BorderSide(
                  color: Colors.black,
                  width: 3.0,
                ), // Border color
              ),
              child: const Align(
                  alignment: Alignment.center,
                  child: Text(
                    constMortarOption1,
                    style: TextStyle(
                        fontFamily: constAppTextFont,
                        color: Colors.black,
                        fontSize: 12.0),
                  )),
              onPressed: () {
                // run! 
                _doMortarRun();
                widget.onClose();
              },
            )),
         SizedBox(
            width: 250.0,
            height: 70.0,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black, // Text and icon color
                backgroundColor: Colors.white, // Background color
                overlayColor: Colors.blueAccent.withValues(), // pressed ripple
                side: const BorderSide(
                  color: Colors.black,
                  width: 3.0,
                ), // Border color
              ),
              child: const Align(
                  alignment: Alignment.center,
                  child: Text(
                    constMortarOption2,
                    style: TextStyle(
                        fontFamily: constAppTextFont,
                        color: Colors.black,
                        fontSize: 12.0),
                  )),
              onPressed: () {
                // drop into cover
                _doMortarDrop();
                widget.onClose();
              },
            )),           

        ]
      );

  }

  // *********************************************
  //  dust - keep going 
  // *********************************************
  void  _doDustForward() {
    
    // lose endurance fighting the storm 
    _pilot.setEndurance(EnumDirection.decrement);
    _pilot.setEndurance(EnumDirection.decrement);
  } 

  // *********************************************
  //  dust - go back
  // *********************************************
  void  _doDustBack() {

    // move the back to last spot
    _map[_oldHex].current = true;
    _map[_selectedHex].current = false;

  }

  // *********************************************
  //  dust - choose what happens when you get caught in storm 
  // *********************************************
  Widget _returnDust() {
    return 
      Column(
        children: [
        SizedBox(
            width: 250.0,
            height: 70.0,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black, // Text and icon color
                backgroundColor: Colors.white, // Background color
                overlayColor: Colors.blueAccent.withValues(), // pressed ripple
                side: const BorderSide(
                  color: Colors.black,
                  width: 3.0,
                ), // Border color
              ),
              child: const Align(
                  alignment: Alignment.center,
                  child: Text(
                    constDustOption1,
                    style: TextStyle(
                        fontFamily: constAppTextFont,
                        color: Colors.black,
                        fontSize: 12.0),
                  )),
              onPressed: () {
                // run! 
                _doDustBack();
                widget.onClose();
              },
            )),
         SizedBox(
            width: 250.0,
            height: 70.0,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black, // Text and icon color
                backgroundColor: Colors.white, // Background color
                overlayColor: Colors.blueAccent.withValues(), // pressed ripple
                side: const BorderSide(
                  color: Colors.black,
                  width: 3.0,
                ), // Border color
              ),
              child: const Align(
                  alignment: Alignment.center,
                  child: Text(
                    constDustOption2,
                    style: TextStyle(
                        fontFamily: constAppTextFont,
                        color: Colors.black,
                        fontSize: 12.0),
                  )),
              onPressed: () {
                // drop into cover
                _doDustForward();
                widget.onClose();
              },
            )),           

        ]
      );

  }
  
  // *********************************************
  //  soldier - get a rifle
  // *********************************************
  void  _doSoldierRifle() {

    // add an AK
    _pilot.addInventoryItem(EnumInventory.ak);

  }

  // *********************************************
  //  soldier - find a map
  // *********************************************
  void  _doSoldierMap() {
    late MapHex newHex; 
    int id = 0; 

      // add a village 4 spaces away and surround it with brush or scrub
        newHex = MapFactory.moveRandomSteps(
            _map[_selectedHex].row, _map[_selectedHex].col, 3);
        id = _getIdFromColRow(newHex.col, newHex.row);
        _map[id].terrain = EnumTerrain.brush;
        _map[id].visible = true;
        // make that open and mark it where a crashed helicopter is 
        _hexesCrashedChopper.add(id);
        // walk around it to make bordering spaces either scrub or brush if they are empty
        setState(() {
          _setTerrainAroundSpot(newHex.col, newHex.row);
        });

  }



  // *********************************************
  // soldier - dead guy 
  // *********************************************
  Widget _returnSoldier() {

    return 
      Column(
        children: [
        SizedBox(
            width: 250.0,
            height: 70.0,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black, // Text and icon color
                backgroundColor: Colors.white, // Background color
                overlayColor: Colors.blueAccent.withValues(), // pressed ripple
                side: const BorderSide(
                  color: Colors.black,
                  width: 3.0,
                ), // Border color
              ),
              child: const Align(
                  alignment: Alignment.center,
                  child: Text(
                    constSoldierOption1,
                    style: TextStyle(
                        fontFamily: constAppTextFont,
                        color: Colors.black,
                        fontSize: 12.0),
                  )),
              onPressed: () {
                _doSoldierRifle();
                widget.onClose();
              },
            )),
         SizedBox(
            width: 250.0,
            height: 70.0,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black, // Text and icon color
                backgroundColor: Colors.white, // Background color
                overlayColor: Colors.blueAccent.withValues(), // pressed ripple
                side: const BorderSide(
                  color: Colors.black,
                  width: 3.0,
                ), // Border color
              ),
              child: const Align(
                  alignment: Alignment.center,
                  child: Text(
                    constSoldierOption2,
                    style: TextStyle(
                        fontFamily: constAppTextFont,
                        color: Colors.black,
                        fontSize: 12.0),
                  )),
              onPressed: () {
                _doSoldierMap();
                widget.onClose();
              },
            )),           

        ]
      );

  }

  // *********************************************
  //  building - make a bandage
  // *********************************************
  void  _doBuildingBandage() {

    // gain 2 health back
    _pilot.setHealth(EnumDirection.increment);
    _pilot.setHealth(EnumDirection.increment);

  }

  // *********************************************
  //  building - extra rest
  // *********************************************
  void  _doBuildingRest() {

    // gain 1 endurance
    _pilot.setEndurance(EnumDirection.increment);

  }

  // *********************************************
  //  building - get machete
  // *********************************************
  void  _doBuildingMachete() {

    // gain 1 endurance
    _pilot.addInventoryItem(EnumInventory.machete);

  }

  // *********************************************
  //  building - if they don't already have a machete, can get one 
  // *********************************************
  Widget _checkBuildingMachete() {

    if (_pilot.hasAnInventoryItem(EnumInventory.machete)) {
      return Container(); 
    }
    else {
      return SizedBox(
            width: 250.0,
            height: 70.0,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black, // Text and icon color
                backgroundColor: Colors.white, // Background color
                overlayColor: Colors.blueAccent.withValues(), // pressed ripple
                side: const BorderSide(
                  color: Colors.black,
                  width: 3.0,
                ), // Border color
              ),
              child: const Align(
                  alignment: Alignment.center,
                  child: Text(
                    constBuildingOption3,
                    style: TextStyle(
                        fontFamily: constAppTextFont,
                        color: Colors.black,
                        fontSize: 12.0),
                  )),
              onPressed: () {
                _doBuildingMachete();
                widget.onClose();
              },
            ));         

    }

  }

  // *********************************************
  //  road - move
  // *********************************************
  void  _doRoadMove() {

    // can keep on moving
    _moveAllowed = true; 

  }

  // *********************************************
  //  road - proximity
  // *********************************************
  void  _doRoadProximity() {

    // Increase
    _pilot.setProximity(EnumDirection.increment);

  }


  // *********************************************
  //  an empty building
  // *********************************************
  Widget _returnBuilding() {

    return 
      Column(
        children: [
        SizedBox(
            width: 250.0,
            height: 70.0,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black, // Text and icon color
                backgroundColor: Colors.white, // Background color
                overlayColor: Colors.blueAccent.withValues(), // pressed ripple
                side: const BorderSide(
                  color: Colors.black,
                  width: 3.0,
                ), // Border color
              ),
              child: const Align(
                  alignment: Alignment.center,
                  child: Text(
                    constBuildingOption1,
                    style: TextStyle(
                        fontFamily: constAppTextFont,
                        color: Colors.black,
                        fontSize: 12.0),
                  )),
              onPressed: () {
                _doBuildingBandage();
                widget.onClose();
              },
            )),
         SizedBox(
            width: 250.0,
            height: 70.0,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black, // Text and icon color
                backgroundColor: Colors.white, // Background color
                overlayColor: Colors.blueAccent.withValues(), // pressed ripple
                side: const BorderSide(
                  color: Colors.black,
                  width: 3.0,
                ), // Border color
              ),
              child: const Align(
                  alignment: Alignment.center,
                  child: Text(
                    constBuildingOption2,
                    style: TextStyle(
                        fontFamily: constAppTextFont,
                        color: Colors.black,
                        fontSize: 12.0),
                  )),
              onPressed: () {
                _doBuildingRest();
                widget.onClose();
              },
            )),           
            _checkBuildingMachete(),
        ]
      );

  }

  // *********************************************
  // road - which way to go 
  // *********************************************
  Widget _returnRoad() {

    return 
      Column(
        children: [
        SizedBox(
            width: 250.0,
            height: 70.0,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black, // Text and icon color
                backgroundColor: Colors.white, // Background color
                overlayColor: Colors.blueAccent.withValues(), // pressed ripple
                side: const BorderSide(
                  color: Colors.black,
                  width: 3.0,
                ), // Border color
              ),
              child: const Align(
                  alignment: Alignment.center,
                  child: Text(
                    constRoadOption1,
                    style: TextStyle(
                        fontFamily: constAppTextFont,
                        color: Colors.black,
                        fontSize: 12.0),
                  )),
              onPressed: () {
                _doRoadMove();
                widget.onClose();
              },
            )),
         SizedBox(
            width: 250.0,
            height: 70.0,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black, // Text and icon color
                backgroundColor: Colors.white, // Background color
                overlayColor: Colors.blueAccent.withValues(), // pressed ripple
                side: const BorderSide(
                  color: Colors.black,
                  width: 3.0,
                ), // Border color
              ),
              child: const Align(
                  alignment: Alignment.center,
                  child: Text(
                    constRoadOption2,
                    style: TextStyle(
                        fontFamily: constAppTextFont,
                        color: Colors.black,
                        fontSize: 12.0),
                  )),
              onPressed: () {
                _doRoadProximity();
                widget.onClose();
              },
            )),           

        ]
      );

  }



  // *********************************************
  //  thorns -- either go back, or chop/skip
  // *********************************************
  void  _doThorns1() {

    // if machete, 
    if (_pilot.hasAnInventoryItem(EnumInventory.machete)) {
      // set flags to skip stealth and rest 
      _skipStealh = true;
      _skipRest = true; 
    }
    else {
      _map[_oldHex].current = true;
      _map[_selectedHex].current = false;
      _hexesImpassable.add(_selectedHex);
    }

  }

  // *********************************************
  //  thorns -- push on or chop/keep
  // *********************************************
  void  _doThorns2() {

    // if machete, 
    if (_pilot.hasAnInventoryItem(EnumInventory.machete)) {
      // just continue on like normal 
    }
    else {
      // they fight through, so add deep cut
      _pilot.setAffliction(EnumAffliction.deepcut);
    }

  }

  // *********************************************
  //  see what happens if they are blocked by thorns
  // *********************************************
  Widget _returnThorns() {
    String option1 = constThornsOption1;
    String option2 = constThornsOption2;

    if (_pilot.hasAnInventoryItem(EnumInventory.machete)) {
      option1 = constThornsOption3;
      option2 = constThornsOption4;
    }

    return 
      Column(
        children: [
        SizedBox(
            width: 250.0,
            height: 70.0,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black, // Text and icon color
                backgroundColor: Colors.white, // Background color
                overlayColor: Colors.blueAccent.withValues(), // pressed ripple
                side: const BorderSide(
                  color: Colors.black,
                  width: 3.0,
                ), // Border color
              ),
              child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    option1,
                    style: const TextStyle(
                        fontFamily: constAppTextFont,
                        color: Colors.black,
                        fontSize: 12.0),
                  )),
              onPressed: () {
                _doThorns1();
                widget.onClose();
              },
            )),
         SizedBox(
            width: 250.0,
            height: 70.0,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black, // Text and icon color
                backgroundColor: Colors.white, // Background color
                overlayColor: Colors.blueAccent.withValues(), // pressed ripple
                side: const BorderSide(
                  color: Colors.black,
                  width: 3.0,
                ), // Border color
              ),
              child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    option2,
                    style: const TextStyle(
                        fontFamily: constAppTextFont,
                        color: Colors.black,
                        fontSize: 12.0),
                  )),
              onPressed: () {
                _doThorns2();
                widget.onClose();
              },
            )),           

        ]
      );

  }


  // *********************************************
  //  see what happens if they come across chemical munitions
  // *********************************************
  Widget _returnChemicals() {
    // if theyhave a wound or cut, lose further health 
    if ((_pilot.hasAnAffliction(EnumAffliction.burn)) || (_pilot.hasAnAffliction(EnumAffliction.gunshotwound))) {
      _pilot.setHealth(EnumDirection.decrement);
      _pilot.setHealth(EnumDirection.decrement);
    }
    else { 
      _pilot.setAffliction(EnumAffliction.burn);

    }

    return SizedBox(
        width: 160.0,
        height: 55.0,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black, // Text and icon color
            backgroundColor: Colors.white, // Background color
            overlayColor: Colors.blueAccent.withValues(), // pressed ripple
            side: const BorderSide(
              color: Colors.black,
              width: 3.0,
            ), // Border color
          ),
          child: const Align(
              alignment: Alignment.center,
              child: Text(
                constContinueText,
                style: TextStyle(
                    fontFamily: constAppTextFont,
                    color: Colors.black,
                    fontSize: 18.0),
              )),
          onPressed: () {
            widget.onClose();
          },
        ));
  }

  // *********************************************
  //  pass back button to close the overlay
  // *********************************************
  Widget _returnContinueButton() {
    return SizedBox(
        width: 160.0,
        height: 55.0,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black, // Text and icon color
            backgroundColor: Colors.white, // Background color
            overlayColor: Colors.blueAccent.withValues(), // pressed ripple
            side: const BorderSide(
              color: Colors.black,
              width: 3.0,
            ), // Border color
          ),
          child: const Align(
              alignment: Alignment.center,
              child: Text(
                constContinueText,
                style: TextStyle(
                    fontFamily: constAppTextFont,
                    color: Colors.black,
                    fontSize: 18.0),
              )),
          onPressed: () {
            widget.onClose();
          },
        ));
  }

  // *********************************************
  //  figure out what happened and their options (if any)
  // *********************************************
  Widget _handleEncounter() {
    EnumEncounter encounter = EnumEncounter.values[_currentEncounterIndex];
    late MapHex newHex;
    int id = 0;

    if (handleEncounter) {
      // no encounter
      if (encounter == EnumEncounter.none) {
        return _returnContinueButton();
      }
      // highground
      else if (encounter == EnumEncounter.highground) {
        // add a village 4 spaces away and surround it with brush or scrub
        newHex = MapFactory.moveRandomSteps(
            _map[_selectedHex].row, _map[_selectedHex].col, 4);
        // make that a village
        id = _getIdFromColRow(newHex.col, newHex.row);
        _map[id].terrain = EnumTerrain.village;
        _map[id].visible = true;
        // walk around it to make bordering spaces either scrub or brush if they are empty
        setState(() {
          _setTerrainAroundSpot(newHex.col, newHex.row);
        });

        return _returnContinueButton();
      // broken foot
      } else if (encounter == EnumEncounter.rockslide) {
        _pilot.setAffliction(EnumAffliction.brokenfoot);
        return _returnContinueButton();
      // mortar fire
      } else if (encounter == EnumEncounter.mortar) {
        return _returnMortar(); 
      // dust storm
      } else if (encounter == EnumEncounter.dust) {
        return _returnDust(); 
      // chemical weapons
      } else if (encounter == EnumEncounter.chemicals) {
        return _returnChemicals(); 
      // thorny briars
      } else if (encounter == EnumEncounter.thorns) {
        return _returnThorns(); 
      // building
      } else if (encounter == EnumEncounter.building) {
        return _returnBuilding(); 
      // road
      } else if (encounter == EnumEncounter.road) {
        return _returnRoad(); 
      // dead soldier
      } else if (encounter == EnumEncounter.soldier) {
        return _returnSoldier(); 

      }
      // catch all (remove later)
      else {
        return _returnContinueButton();
      }
    } else {
      // while cycling, just have nothing
      return Container();
    }
  }

  @override
  void initState() {
    super.initState();
    bool skipDueToEncounter = false; 

    // set a flag here in case we're in a hex which a preset encounter
    // is going to happen in
    if (_hexesCrashedChopper.contains(_selectedHex)) {
      skipDueToEncounter = true; 
    }

    // Animation controller for smooth fades
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    fade = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    );

    // Delay preload until widget is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // preload all our encounter images
      _encounterImages = _encounterFactory
          .getEncounterVisuals()
          .map((p) => Image.asset(p))
          .toList();
      for (final img in _encounterImages) {
        await precacheImage(img.image, context);
      }

      // Immediately show the first image
      setState(() {
        if (!skipDueToEncounter) {
          _currentEncounterIndex = rand.nextInt(_encounterImages.length);
        }
        else {
          _currentEncounterIndex = EnumEncounter.helicopter.index; 
          message =
              _encounterFactory.getEncounterDescription(_currentEncounterIndex);          
        }
        ready = true;
      });
      controller.forward(from: 0);

      // Start cycling once everything is ready
      if (!skipDueToEncounter) {
        timer = Timer.periodic(const Duration(milliseconds: 300), (_) {
          if (!mounted) return;
          setState(() {
            _currentEncounterIndex = rand.nextInt(_encounterImages.length);
            controller.forward(from: 0);
          });
        });
      }

      // Stop after 2 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted) return;
        timer?.cancel();
        handleEncounter = true;
        setState(() {
          // only pick an encounter that is appropriate based on their distance from start
          if (!skipDueToEncounter) {
            _currentEncounterIndex =
                _encounterFactory.getRandomEncounter(_map[_selectedHex]);
            // hardcode this for testing!
            _currentEncounterIndex = EnumEncounter.helicopter.index; 
            message =
                _encounterFactory.getEncounterDescription(_currentEncounterIndex);
          }
        });
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
        child: Container(
            color: Colors.black
                .withAlpha((0.4 * 255).toInt()) // adjustable darkness
            ),
      ),
      Positioned(
          top: 200,
          left: 50,
          right: 50,
          child: Material(
              elevation: 8.0,
              color: Colors.transparent,
              child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 12),
                       Container(
                        color: Colors.black54,
                        alignment: Alignment.center,
                        height: 275,
                        width: 275,
                        child: FadeTransition(
                          opacity: fade,
                          child: ready
                              ? _encounterImages[_currentEncounterIndex]
                              : const SizedBox(),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(10.0),
                      ),
                      Text(
                        message,
                        style: const TextStyle(
                            color: Colors.white,
                            fontFamily: constAppTextFont,
                            fontSize: 15),
                        textAlign: TextAlign.center,
                      ),
                      const Padding(
                        padding: EdgeInsets.all(10.0),
                      ),
                      _handleEncounter(),
                    ],
                  ))))
    ]);
  }
}

// *********************************************
//  gamescreen class
// *********************************************
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  _GameScreenState createState() => _GameScreenState();
}

// *********************************************
//  stateclass
// *********************************************
class _GameScreenState extends State<GameScreen> {
  OverlayEntry? _overlayEntry;
  Completer<void>? _completer;

  @override
  void initState() {
    super.initState();
    // reset all values
    _newGame();
    // do our round 1 mapping
    _doMappingPhase();
    // show initial overlay for allocation phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _diceAllocationOverlay();
    });
  }

  // *********************************************
  // finished allocatiing dice
  // *********************************************
  void _closeDiceAllocationOverlay() {
    _overlayEntry?.remove();
    _completer?.complete();
    _overlayEntry = null;
    _completer = null;
    setState(() {
      // do nothing
    });
  }

  // *********************************************
  // display overlay to get dice allocation
  // *********************************************
  Future<void> _diceAllocationOverlay() async {
    _totalDice = _pilot.getEndurance();

    _completer = Completer<void>();

    if (_overlayEntry != null) return; // Prevent stacking

    _overlayEntry = OverlayEntry(
        builder: (context) => Stack(
              children: [
                Positioned.fill(
                  child: Container(
                      color: Colors.black
                          .withAlpha((0.4 * 255).toInt()) // adjustable darkness
                      ),
                ),
                Positioned(
                  top: 200,
                  left: 50,
                  right: 50,
                  child: Material(
                    elevation: 8.0,
                    color: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 12),
                          Text(
                            "$constDiceAllocationMessage1 $_totalDice $constDiceAllocationMessage2",
                            style: const TextStyle(
                                color: Colors.white,
                                fontFamily: constAppTextFont,
                                fontSize: 15),
                            textAlign: TextAlign.center,
                          ),
                          const Padding(
                            padding: EdgeInsets.all(10.0),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  _changeMove(EnumDirection.increment);
                                },
                                onLongPress: () {
                                  _changeMove(EnumDirection.decrement);
                                },
                                child: Row(
                                  children: <Widget>[
                                    const SizedBox(width: 75),
                                    Image(
                                      image: _moveImage(),
                                      width: 80.0,
                                      height: 18.0,
                                      fit: BoxFit.fill,
                                    ),
                                    const SizedBox(width: 5), // spacing column
                                    const Text(constMoveText,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: constAppTextFont,
                                            fontSize: 18.0)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 5),
                              GestureDetector(
                                onTap: () {
                                  _changeStealth(EnumDirection.increment);
                                },
                                onLongPress: () {
                                  _changeStealth(EnumDirection.decrement);
                                },
                                child: Row(
                                  children: <Widget>[
                                    const SizedBox(width: 75),
                                    Image(
                                      image: _stealthImage(),
                                      width: 80.0,
                                      height: 18.0,
                                      fit: BoxFit.fill,
                                    ),
                                    const SizedBox(width: 5), // spacing column
                                    const Text(constStealthText,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: constAppTextFont,
                                            fontSize: 18.0)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 5),
                              GestureDetector(
                                onTap: () {
                                  _changeRest(EnumDirection.increment);
                                },
                                onLongPress: () {
                                  _changeRest(EnumDirection.decrement);
                                },
                                child: Row(
                                  children: <Widget>[
                                    const SizedBox(width: 75),
                                    Image(
                                      image: _restImage(),
                                      width: 80.0,
                                      height: 18.0,
                                      fit: BoxFit.fill,
                                    ),
                                    const SizedBox(width: 5), // spacing column
                                    const Text(constRestText,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: constAppTextFont,
                                            fontSize: 18.0)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.all(10.0),
                          ),
                          SizedBox(
                            width: 160.0,
                            height: 55.0,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor:
                                    Colors.black, // Text and icon color
                                backgroundColor:
                                    Colors.white, // Background color
                                overlayColor: Colors.blueAccent
                                    .withValues(), // pressed ripple
                                side: const BorderSide(
                                  color: Colors.black,
                                  width: 3.0,
                                ), // Border color
                              ),
                              child: const Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    constOKText,
                                    style: TextStyle(
                                        fontFamily: constAppTextFont,
                                        color: Colors.black,
                                        fontSize: 18.0),
                                  )),
                              onPressed: () {
                                _genericCloseOverlay();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ));

    Overlay.of(context).insert(_overlayEntry!);
  }

  // *********************************************
  // close out overlay
  // *********************************************
  void _genericCloseOverlay() {
    _overlayEntry?.remove();
    _completer?.complete();
    _overlayEntry = null;
    _completer = null;
  }

  // *********************************************
  // player entered a village
  // *********************************************
  void _handleVillage() async {
    int result = 0;
    String message = "";

    result = Random().nextInt(10) + 2;

    // based on result, let's do this thing
    if (result == 2) {
      // robbed
      _villageReaction = EnumVillageReactions.robbed;
      // if they had items, they are all lost
      if (_pilot.hasAnyInventory()) {
        message = constVillageRobbedItems;
        _pilot.clearInventory();
      } else {
        message = constVillageRobbedNoItems;
      }
      _moveAllowed = true;
    } else if (result == 3) {
      // delayed
      _villageReaction = EnumVillageReactions.delayed;
      // reduce values
      _pilot.setProximity(EnumDirection.decrement);
      _pilot.setEndurance(EnumDirection.decrement);
      message = constVillageDelayed;
      _moveAllowed = true;
    } else if ((result == 4) || (result == 5)) {
      // kicked out
      _villageReaction = EnumVillageReactions.kickedout;
      message = constVillageKickedOut;
      // village now impassable
      _hexesImpassable.add(_selectedHex);
      // move them back to old hex
      _map[_oldHex].current = true;
      _map[_selectedHex].current = false;
      // remove this hex from one they've traveled in
      _hexesTraveled.remove(_selectedHex);
      // can't move
      _moveAllowed = false;
    } else if ((result == 6) || (result == 7) || (result == 8)) {
      // untrusting
      _villageReaction = EnumVillageReactions.untrusting;
      message = constVillageUntrusting;
      _moveAllowed = true;
    } else if ((result == 9) || (result == 10)) {
      // peaceful
      _villageReaction = EnumVillageReactions.peaceful;
      message = constVillagePeaceful;
      // increment by 2
      _pilot.setEndurance(EnumDirection.increment);
      _pilot.setEndurance(EnumDirection.increment);
      _moveAllowed = true;
    } else if (result == 11) {
      // helpful
      _villageReaction = EnumVillageReactions.helpful;
      message = constVillageHelpful;
      _moveAllowed = true;
      _pilot.setProximity(EnumDirection.increment);
    } else {
      _villageReaction = EnumVillageReactions.allied;
      // heal an affliction
      if (_pilot.hasAnyAfflictions()) {
        _pilot.healAffliction();
        message = constVillageAlliedAfflictions;
      } else {
        message = constVillageAlliedNoAfflications;
      }

      _pilot.setEndurance(EnumDirection.increment);
      _pilot.setHealth(EnumDirection.increment);
      _pilot.setProximity(EnumDirection.increment);
      _moveAllowed = true;
    }

    // throw up village dialog
    await _villageEncounterOverlay(message);

    setState(() {
      // do nothing
    });
  }

  // *********************************************
  // user selected a die
  // *********************************************
  void _tapDice(EnumPhase phase, int value, int target) async {
    // get rid of the overlay (either way)
    _genericCloseOverlay();

    // decide what to do based on phase
    if (phase == EnumPhase.move) {
      if (value >= target) {
        // clear all hexes
        for (MapHex hex in _map) {
          hex.current = false;
        }
        // set this one assuming it isn't same as the old and add it to the list traveled
        if (_selectedHex != _oldHex) {
          _map[_selectedHex].current = true;
          _hexesTraveled.add(_selectedHex);
          _allowedToReRoll = true;
        }
        // map out next hexes
        _doMappingPhase();
        // for now, assume they can't move again
        _moveAllowed = false;
        // did they choose a six?
        if (value == 6) {
          _pilot.setHealth(EnumDirection.decrement);
          await _failedOverlayMessage(constMoveSixMessage);
        }
        // did they enter a village? that brings a whole new thing to check
        if (_map[_selectedHex].terrain == EnumTerrain.village) {
          _handleVillage();
        }
      } else {
        _allowedToReRoll = false;
        await _failedOverlayMessage(constMoveFailedMessage);
      }
    } else if (phase == EnumPhase.stealth) {
      // for stealth phase, see if they chose a six
      if (value >= target) {
        if (value == 6) {
          _pilot.setHealth(EnumDirection.decrement);
          await _failedOverlayMessage(constStealthSixMessage);          
        }
      } else {
        _pilot.setProximity(EnumDirection.decrement);
        await _failedOverlayMessage(constStealthFailedMessage);
      }
    } else {
      // rest
      if (value >= target) {
        _pilot.setEndurance(EnumDirection.increment);
        // did they choose a six?
        if (value == 6) {
          _pilot.setHealth(EnumDirection.decrement);
          await _failedOverlayMessage(constRestSixMessage);
        }
      } else {
        _pilot.setEndurance(EnumDirection.decrement);
        await _failedOverlayMessage(constRestFailedMessage);
      }
    }

    // update ui
    setState(() {
      // do nothing
    });
  }

  // *********************************************
  // reroll one die
  // *********************************************
  void _reRoll(int index) {
    // only do this if they are allowed, and then flip that flag
    if (_allowedToReRoll) {
      _allowedToReRoll = false;
      setState(() {
        _rollingDice[index] = Random().nextInt(6) + 1;
      });
      _overlayEntry?.markNeedsBuild(); // forces overlay to redraw
    }
  }

  // *********************************************
  // give dice new values
  // *********************************************
  void _rollDice() {
    setState(() {
      _rollingDice = _rollingDice.map((_) => Random().nextInt(6) + 1).toList();
    });
  }

  // *********************************************
  // draw the dice
  // *********************************************
  List<Widget> _drawDice(EnumPhase phase, int target) {
    // set each one
    return _rollingDice.asMap().entries.map((entry) {
      final index = entry.key;
      final value = entry.value;

      return GestureDetector(
          onTap: () {
            _tapDice(phase, value, target);
          },
          onDoubleTap: () {
            // can only reroll during stealth phase if they successfully moved
            if ((_phase == EnumPhase.stealth) && (_allowedToReRoll)) { 
              _reRoll(index);
            }
          },
          child: Image.asset(
            'assets/images/dice_face_white_$value.jpg',
            width: 64,
            height: 64,
          ));
    }).toList();
  }

  // *********************************************
  // start a timer to roll the dice
  // *********************************************
  void _startRolling() {
    // Cancel any previous timer
    _rollTimer?.cancel();

    // Start a new timer that fires repeatedly
    _rollTimer = Timer.periodic(const Duration(milliseconds: 60), (_) {
      _rollDice(); // your existing method that randomizes all dice
      _overlayEntry?.markNeedsBuild(); // forces overlay to redraw
    });

    // Stop the rolling after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      _rollTimer?.cancel();
    });
  }

  // *********************************************
  // display overlay for rolling and choosing dice
  // *********************************************
  Future<void> _diceRollOverlay(
      EnumPhase phase, int rollToBeat, int numDice) async {
    String message = "";

    if (phase == EnumPhase.move) {
      message =
          "$constDiceRollMoveMessage1 $rollToBeat $constDiceRollMoveMessage2 $constDiceRollMoveMessage3 $constDiceRollMoveMessage4";
    } else if (phase == EnumPhase.stealth) {
      message =
          "$constDiceRollStealthMessage1 $rollToBeat $constDiceRollStealthMessage2 $constDiceRollStealthMessage3 ";
      if (_allowedToReRoll) {
        message += constDiceRollStealthMessage4;
      }
    } else {
      // rest phase
      message =
          "$constDiceRollRestMessage1 $rollToBeat $constDiceRollRestMessage2 $constDiceRollRestMessage3 ";
    }

    _completer = Completer<void>();
    if (_overlayEntry != null) return; // Prevent stacking

    _overlayEntry = OverlayEntry(
        builder: (context) => Stack(children: [
              Positioned.fill(
                child: Container(
                    color: Colors.black
                        .withAlpha((0.4 * 255).toInt()) // adjustable darkness
                    ),
              ),
              Positioned(
                  top: 200,
                  left: 50,
                  right: 50,
                  child: Material(
                      elevation: 8.0,
                      color: Colors.transparent,
                      child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 12),
                              Text(
                                message,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: constAppTextFont,
                                    fontSize: 15),
                                textAlign: TextAlign.center,
                              ),
                              const Padding(
                                padding: EdgeInsets.all(10.0),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: _drawDice(phase, rollToBeat),
                                  )
                                ],
                              ),
                            ],
                          ))))
            ]));

    Overlay.of(context).insert(_overlayEntry!);

    // start the timer to roll dice
    _startRolling();
  }

  // *********************************************
  // village message overlay
  // *********************************************
  Future<void> _villageEncounterOverlay(String message) async {
    _completer = Completer<void>();
    if (_overlayEntry != null) return; // Prevent stacking

    _overlayEntry = OverlayEntry(
        builder: (context) => Stack(children: [
              Align(
                  alignment: Alignment.center,
                  child: Card(
                      elevation: 8.0,
                      color: Colors.black,
                      child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(message,
                              style: const TextStyle(
                                  fontFamily: constAppTextFont,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                              textAlign: TextAlign.center))))
            ]));

    Overlay.of(context).insert(_overlayEntry!);

    // Remove after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      _overlayEntry?.remove();
      _completer?.complete();
      _overlayEntry = null;
      _completer = null;
    });

    await _completer!.future;
  }

  // *********************************************
  // failed message overlay
  // *********************************************
  Future<void> _failedOverlayMessage(String message) async {
    _completer = Completer<void>();
    if (_overlayEntry != null) return; // Prevent stacking

    _overlayEntry = OverlayEntry(
        builder: (context) => Stack(children: [
              Align(
                  alignment: Alignment.center,
                  child: Card(
                      elevation: 8.0,
                      color: Colors.red,
                      child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(message,
                              style: const TextStyle(
                                  fontFamily: constAppTextFont,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                              textAlign: TextAlign.center))))
            ]));

    Overlay.of(context).insert(_overlayEntry!);

    // Remove after 1 second
    Future.delayed(const Duration(seconds: 2), () {
      _overlayEntry?.remove();
      _completer?.complete();
      _overlayEntry = null;
      _completer = null;
    });

    await _completer!.future;
  }

  // *********************************************
  // this needs to be called to insert the encounter overlay
  // *********************************************
  Future<void> _showEncounterOverlay(BuildContext context) async {
    final completer = Completer<void>(); 
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => ImageCyclerOverlay(
        onClose: () { 
          entry.remove();
          completer.complete();
        }
      ),
    );

    Overlay.of(context).insert(entry!);
    return completer.future;
    //overlay.insert(entry);
  }

  // ************************
  // _changeMove
  // ************************
  void _changeMove(EnumDirection direction) {
    // if up, see if there are dice left
    if ((direction == EnumDirection.increment) && (_totalDice > 0)) {
      _totalDice--;
      _moveDice++;
    } else if ((direction == EnumDirection.decrement) && (_moveDice > 0)) {
      _totalDice++;
      _moveDice--;
    }

    // redraw the overlay
    setState(() {
      _overlayEntry?.markNeedsBuild();
    });
  }

  // ************************
  // _changeStealth
  // ************************
  void _changeStealth(EnumDirection direction) {
    // if up, see if there are dice left
    if ((direction == EnumDirection.increment) && (_totalDice > 0)) {
      _totalDice--;
      _stealthDice++;
    } else if ((direction == EnumDirection.decrement) && (_stealthDice > 0)) {
      _totalDice++;
      _stealthDice--;
    }

    // redraw the overlay
    setState(() {
      _overlayEntry?.markNeedsBuild();
    });
  }

  // ************************
  // _changeRest
  // ************************
  void _changeRest(EnumDirection direction) {
    // if up, see if there are dice left
    if ((direction == EnumDirection.increment) && (_totalDice > 0)) {
      _totalDice--;
      _restDice++;
    } else if ((direction == EnumDirection.decrement) && (_restDice > 0)) {
      _totalDice++;
      _restDice--;
    }

    // redraw the overlay
    setState(() {
      _overlayEntry?.markNeedsBuild();
    });
  }

  // ************************
  // _newGame
  // ************************
  void _newGame() async {
    // set up the map
    _initMap();

    // initial values
    _round = 1;
    _pilot = Pilot();
    _moveDice = constNoDice;
    _stealthDice = constNoDice;
    _restDice = constNoDice;
    _phase = EnumPhase.allocate;
  }

  // ************************
  // _healthImage
  // ************************
  AssetImage _healthImage() {
    String value = _pilot.getHealth().toString();
    return AssetImage("$constImageStatus$value.png");
  }

  // ************************
  // _proximityImage
  // ************************
  AssetImage _proximityImage() {
    String value = _pilot.getProximity().toString();
    return AssetImage("$constImageStatus$value.png");
  }

  // ************************
  // _enduranceImage
  // ************************
  AssetImage _enduranceImage() {
    String value = _pilot.getEndurance().toString();
    return AssetImage("$constImageStatus$value.png");
  }

  // ************************
  // _moveImage
  // ************************
  AssetImage _moveImage() {
    String value = _moveDice.toString();
    return AssetImage("$constImageDie$value.png");
  }

  // ************************
  // _stealthImage
  // ************************
  AssetImage _stealthImage() {
    String value = _stealthDice.toString();
    return AssetImage("$constImageDie$value.png");
  }

  // ************************
  // _restImage
  // ************************
  AssetImage _restImage() {
    String value = _restDice.toString();
    return AssetImage("$constImageDie$value.png");
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
  String _displayRound() {
    return _round.toString();
  }

  // ************************
  // _doMappingPhase
  // ************************
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
  // advance through phases 
  // ************************
  void _continueButtonPress() async {
    // increment the phase from current one since they moved to the next
    try {
      _phase = EnumPhase.values[_phase.index + 1];
    } catch (e) {
      // if we hit the end of the phases, go back to the beginning
      _phase = EnumPhase.encounter;
      // and increment the turn
      setState(() {
        _round++;
      });
    }

    // always set these to false to start
    _moveAllowed = false;

    // if mapping phase, populate next three hexes
    //if (_phase == EnumPhase.mapping) {
    //  _doMappingPhase();
    //}

    // if encounter phase, decide if they had an encounter
    if (_phase == EnumPhase.encounter) {
      await _showEncounterOverlay(context);

      setState(() {
        _doMappingPhase(); 
      });
    }

    // if allocate phase, bring up allocation dialog
    if (_phase == EnumPhase.allocate) {
      // reset all dice allocations
      _moveDice = 0;
      _stealthDice = 0;
      _restDice = 0;
      _totalDice = _pilot.getEndurance();
      await _diceAllocationOverlay();
    }

    // if move phase, just set the flag allowing them to move (when they pick a new hex)
    if (_phase == EnumPhase.move) {
      // reset village flags and counters
      _villageReaction = EnumVillageReactions.none;
      _motorcycleMoves = 0;
      // set flag that allows a move (so they only do it once per turn)
      if (_moveDice > 0) {
        _moveAllowed = true;
      }
    }

    // if stealth phase, decide whether they successfully hid from pursuers
    if (_phase == EnumPhase.stealth) {
      if (_stealthDice > 0) {
        // set number of dice based on how many allocated
        _rollingDice =
            List.generate(_stealthDice, (_) => Random().nextInt(6) + 1);
        await _diceRollOverlay(EnumPhase.stealth,
            MapFactory.getStealthCost(_getCurrentHex().terrain), _stealthDice);
      } else {
        _pilot.setProximity(EnumDirection.decrement);
        await _failedOverlayMessage(constStealthFailedMessage);
      }
    }

    // if rest phase, decide whether they lose any endurance
    if (_phase == EnumPhase.rest) {
      if (_restDice > 0) {
        await _diceRollOverlay(EnumPhase.rest,
            MapFactory.getRestCost(_getCurrentHex().terrain), _restDice);
      } else {
        _pilot.setEndurance(EnumDirection.decrement);
        await _failedOverlayMessage(constRestFailedMessage);
      }
    }

    // finally
    setState(() {
      // nothing to do here yet
    });
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
  // _getMapHexGraphic
  // ************************
  String _getMapHexGraphic(int row, int col) {
    EnumTerrain enumTerrain = _map[_getIdFromColRow(col, row)].terrain;
    String asset;
    int id = _getIdFromColRow(col, row);

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

    return asset;
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
  // user has clicked into a hex
  // ************************
  void _selectMapHex(int row, int col) async {
    int moveCost = 0;
    int hexDistance = 0;

    // get current hex
    MapHex h = _getCurrentHex();
    // save that for the moment
    _oldHex = h.id;
    // get the id of the hex they selected
    _selectedHex = _getIdFromColRow(col, row);
    // get distance between hexes
    hexDistance =
        MapFactory.getDistanceBetweenHexes(_map[_oldHex], _map[_selectedHex]);

    // first check, if this hex is impassable, bail right out
    if ((_hexesImpassable.isNotEmpty) &
        (_hexesImpassable.contains(_selectedHex))) {
      return;
    }

    // if this is move phase, do all the logic
    if ((_phase == EnumPhase.move) && (_moveAllowed)) {
      // is the hex too far away?
      if (hexDistance > 1) {
        // abort
        return;
      }

      // special case -- crashed helicopter due to encounter
      if (_hexesCrashedChopper.contains(_selectedHex)) {
        // they just move, no roll or anything 
        _map[_oldHex].current = false;
        _map[_selectedHex].current = true;
        _hexesTraveled.add(_selectedHex);
        _hexesTraveled.add(_oldHex);
      }
      // regular move
      else if (_villageReaction == EnumVillageReactions.none) {
        // what is the move cost?
        moveCost = MapFactory.getMoveCost(h.terrain);
        // if they have dice assigned to move, bring up the overlay to pick from the die roll
        if (_moveDice > 0) {
          // bring up overlay
          _rollingDice =
              List.generate(_moveDice, (_) => Random().nextInt(6) + 1);
          await _diceRollOverlay(EnumPhase.move, moveCost, _moveDice);
        } else {
          await _failedOverlayMessage(constNoDiceAllocatedForMoveMessage);
        }
        _moveAllowed = false;
      // special village move 
      } else {
        // if robbed, delayed, or peaceful need to move into a hex that's already mapped
        if (_map[_selectedHex].terrain == EnumTerrain.unknown) {
          // must be untrusting, helpful, or allied
          if ((_villageReaction == EnumVillageReactions.untrusting) ||
              (_villageReaction == EnumVillageReactions.helpful) ||
              (_villageReaction == EnumVillageReactions.allied)) {
            // ok to move
            _map[_oldHex].current = false;
            _map[_selectedHex].current = true;
            _hexesTraveled.add(_selectedHex);
            _hexesTraveled.add(_oldHex);
            _doMappingPhase();
          }
        } else {
          // ok to move
          _map[_oldHex].current = false;
          _map[_selectedHex].current = true;
          _hexesTraveled.add(_selectedHex);
          _hexesTraveled.add(_oldHex);
          _doMappingPhase();
        }

        // if on motorcycle, increment those moves
        if (_villageReaction == EnumVillageReactions.helpful) {
          _motorcycleMoves++;
          if (_motorcycleMoves > 3) {
            _motorcycleMoves = 0;
            _moveAllowed = false;
          }
        } else {
          _moveAllowed = false;
        }
      }

    }
    else if ((_phase == EnumPhase.encounter) && (_moveAllowed)) {
      // there are some encounters where they can also move
            // is the hex too far away?
      if (hexDistance > 1) {
        // abort
        return;
      }

      // ok to move
      _map[_oldHex].current = false;  
      _map[_selectedHex].current = true;
      _hexesTraveled.add(_selectedHex);
      _hexesTraveled.add(_oldHex); 
      _doMappingPhase();

    }

    setState(() {
      // do nothing
    });

  }

  // ************************
  // pop up with terrain information
  // ************************
  void _showMapHexInfo(int row, int col) {
    int id = _getIdFromColRow(col, row);
    showTerrainInfoDialog(context, _map[id].terrain);
  }

  // ************************
  // _showMapHexExtras
  // ************************
  Widget _showMapHexExtras(int row, int col) {
    int id = _getIdFromColRow(col, row);
    bool isCurrentPlayerLocation = _map[id].current;

    // if player in current hex, show american flag
    if (isCurrentPlayerLocation) {
      return Positioned(
          top: 30,
          left: 35,
          child: Container(
              height: 35,
              width: 45,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 2, // thin border
                ),
              ),
              child: Image.asset(constImagePlayerLocation, fit: BoxFit.cover)));
    }
    // else if this hex contains a crashed chopper
    else if ((_hexesCrashedChopper.isNotEmpty) && (_hexesCrashedChopper.contains(id))) {
      return const Positioned(
          top: 25,
          left: 32,
          child: Icon(Icons.place, color: Colors.yellow, size: 50));
    }

    // else if player cannot travel through this hex, show close icon
    else if ((_hexesImpassable.isNotEmpty) && (_hexesImpassable.contains(id))) {
      return const Positioned(
          top: 25,
          left: 32,
          child: Icon(Icons.block, color: Colors.red, size: 50));
    }

    // else if player traveled through hex, show person icon
    else if (_hexesTraveled.contains(id)) {
      return const Positioned(
          top: 25,
          left: 32,
          child: Icon(Icons.directions_run, color: Colors.black, size: 50));
    }

    // else, just an empty container
    else {
      return Container();
    }
  }

  // ************************
  // if they have items, display dialog
  // ************************
  void _handleInventoryTap() { 
    if (_pilot.hasAnyInventory()) {
      showInfoDialog(context, _pilot.describeInventory());
    }
  }

  // ************************
  // if they have afflictions, display dialog
  // ************************
  void _handleAfflictionsTap() {
    if (_pilot.hasAnyAfflictions()) {
      showInfoDialog(context, _pilot.describeAfflictions());
    }
  }
  
  // ************************
  // return inventory color based on whether they have items
  // ************************
  Color _returnInventoryColor() {
    Color result = const Color.fromARGB(255, 68, 68, 68);

    if (_pilot.hasAnyInventory()) { result = Colors.white; }
    return result; 

  }

  // ************************
  // return ailments color based on whether they have items
  // ************************
  Color _returnAfflictionsColor() {
    Color result = const Color.fromARGB(255, 68, 68, 68);

    if (_pilot.hasAnyAfflictions()) { result = Colors.white; }
    return result; 

  }

  // ************************
  // build
  // ************************
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            backgroundColor: const Color.fromARGB(255, 173, 147, 62),
            body: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.all(1.0),
                  ),
                  const Text(appTitle,
                      style: TextStyle(
                          fontFamily: constAppTextFont, fontSize: 50)),
                  const Padding(
                    padding: EdgeInsets.all(0.0),
                  ),
                  Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: constRoundText,
                            style: TextStyle(
                                fontFamily: constAppTextFont,
                                fontSize: 19,
                                color: Colors.black),
                          ),
                          const TextSpan(
                            text: ' ',
                            style: TextStyle(
                                fontFamily: constAppTextFont,
                                fontSize: 19,
                                color: Colors.black),
                          ),
                          TextSpan(
                            text: _displayRound(),
                            style: const TextStyle(
                                fontFamily: constAppTextFont,
                                fontSize: 19,
                                color: Colors.black),
                          ),
                          const TextSpan(
                            text: ' - ',
                            style: TextStyle(
                                fontFamily: constAppTextFont,
                                fontSize: 19,
                                color: Colors.black),
                          ),
                          TextSpan(
                            text: _displayPhase(false),
                            style: const TextStyle(
                                fontFamily: constAppTextFont,
                                fontSize: 19,
                                color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                      child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: HexagonOffsetGrid.evenFlat(
                      color: const Color.fromARGB(255, 173, 147, 62),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 10.0),
                      columns: constMapCols,
                      rows: constMapRows,
                      buildTile: (col, row) => HexagonWidgetBuilder(
                        elevation: 8.0, // col.toDouble(),
                        padding: 1.0,
                        cornerRadius: null, // hex shape (vs rounded)
                        color: Colors.grey,
                        //child: Text("$row, $col"),
                        child: GestureDetector(
                          onTap: () {
                            debugPrint(
                                "row: $row.toString(), col: $col.toString()");
                            // do something if we're in the move phase
                            if ((_phase == EnumPhase.move) || (_phase == EnumPhase.encounter ))  {
                              _selectMapHex(row, col);
                            }
                          },
                          onLongPress: () {
                            _showMapHexInfo(row, col);
                          },
                          child: Stack(children: [
                            AspectRatio(
                                aspectRatio: HexagonType.FLAT.ratio,
                                child: Image.asset(
                                  _getMapHexGraphic(row, col),
                                  fit: BoxFit.cover,
                                )),
                            _showMapHexExtras(row, col),
                          ]),
                        ), // put image here wrapped in a gesture detector
                      ),
                    ),
                  )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(width: 35), // spacing column
                      Image(
                        image: _healthImage(),
                        width: 80.0,
                        height: 18.0,
                        fit: BoxFit.fill,
                      ),
                      const SizedBox(width: 5), // spacing column
                      const Text(constHealthText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: constAppTextFont,
                              fontSize: 12.0)),
                      const SizedBox(width: 72), // flexible spacing column
                      Image(
                        image: _moveImage(),
                        width: 80.0,
                        height: 18.0,
                        fit: BoxFit.fill,
                      ),
                      const SizedBox(width: 5), // spacing column
                      const Text(constMoveText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: constAppTextFont,
                              fontSize: 12.0)),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.all(2.0),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(width: 35), // spacing column
                      Image(
                        image: _proximityImage(),
                        width: 80.0,
                        height: 18.0,
                        fit: BoxFit.fill,
                      ),
                      const SizedBox(width: 5), // spacing column
                      const Text(constProximityText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: constAppTextFont,
                              fontSize: 12.0)),
                      const SizedBox(width: 50), // middle spacing column
                      Image(
                        image: _stealthImage(),
                        width: 80.0,
                        height: 18.0,
                        fit: BoxFit.fill,
                      ),
                      const SizedBox(width: 5), // spacing column
                      const Text(constStealthText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: constAppTextFont,
                              fontSize: 12.0)),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.all(2.0),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(width: 35), // spacing column
                      Image(
                        image: _enduranceImage(),
                        width: 80.0,
                        height: 18.0,
                        fit: BoxFit.fill,
                      ),
                      const SizedBox(width: 5), // spacing column
                      const Text(constEnduranceText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: constAppTextFont,
                              fontSize: 12.0)),
                      const SizedBox(width: 43), // middle spacing column
                      Image(
                        image: _restImage(),
                        width: 80.0,
                        height: 18.0,
                        fit: BoxFit.fill,
                      ),
                      const SizedBox(width: 5), // spacing column
                      const Text(constRestText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: constAppTextFont,
                              fontSize: 12.0)),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _handleInventoryTap();
                        },
                        child: 
                          Column(
                            children: [
                              Icon(Icons.hiking, size: 30, color: _returnInventoryColor()),
                              const SizedBox(width: 1), // spacing column
                              Text(constInventoryText,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: _returnInventoryColor(),
                                      fontWeight: FontWeight.bold,
                                      fontFamily: constAppTextFont,
                                      fontSize: 15.0)),
                            ]
                          )
                        ),
                      const SizedBox(width: 80,), 
                     GestureDetector(
                        onTap: () {
                          _handleAfflictionsTap();
                        },
                        child: 
                         Column(
                        children: [
                          Icon(Icons.healing, size: 30, color: _returnAfflictionsColor()),
                          const SizedBox(width: 1), // spacing column
                          Text(constAfflictionsText,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: _returnAfflictionsColor(),
                                  fontWeight: FontWeight.bold,
                                  fontFamily: constAppTextFont,
                                  fontSize: 15.0)),
                        ],
                      ),
                     ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Column(children: [
                        SizedBox(
                          width: 160.0,
                          height: 55.0,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor:
                                  Colors.black, // Text and icon color
                              backgroundColor: Colors.white, // Background color
                              overlayColor: Colors.blueAccent
                                  .withValues(), // pressed ripple
                              side: const BorderSide(
                                color: Colors.black,
                                width: 3.0,
                              ), // Border color
                            ),
                            child: const Align(
                                alignment: Alignment.center,
                                child: Text(
                                  constContinueText,
                                  style: TextStyle(
                                      fontFamily: constAppTextFont,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0),
                                )),
                            onPressed: () {
                              _continueButtonPress();
                            },
                          ),
                        )
                      ]),
                      const SizedBox(width: 15.0, height: 5.0),
                      Column(children: [
                        SizedBox(
                          width: 160.0,
                          height: 55.0,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor:
                                  Colors.black, // Text and icon color
                              backgroundColor: Colors.white, // Background color
                              overlayColor: Colors.blueAccent
                                  .withValues(), // pressed ripple
                              side: const BorderSide(
                                color: Colors.black,
                                width: 3.0,
                              ), // Border color
                            ),
                            child: const Align(
                                alignment: Alignment.center,
                                child: Text(
                                  constQuitText,
                                  style: TextStyle(
                                      fontFamily: constAppTextFont,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0),
                                )),
                            onPressed: () {
                              // TBD
                            },
                          ),
                        )
                      ]),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.all(12.0),
                  ),
                ])));
  }
}
