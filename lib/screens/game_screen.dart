// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:hexagon/hexagon.dart';
import 'package:lost_falcon/const.dart';
import 'package:lost_falcon/models/encounter_model.dart';
import '../models/map_model.dart';
import '../models/pilot_model.dart';
import '../dialogs/terrain_dialog.dart';
import '../dialogs/info_dialog.dart';
import '../dialogs/village_dialog.dart';
import '../dialogs/yes_no_dialog.dart';
import '../main.dart';
import 'dart:math';
import 'dart:async';
import 'package:logger/logger.dart';

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
Set<int> _hexesCrashedChopper = {};
Set<int> _hexesTributary = {};
Set<int> _hexesFriendlyVillage = {};
List<int> _rollingDice = [];
Timer? _rollTimer;
bool _allowedToReRoll = false;
int _currentEncounterIndex = 1;
List<Image> _encounterImages = [];
bool _skipRest = false;
bool _skipStealh = false;
bool _rescued = false;
bool _milepostFriendlyTerrain = false;
bool _movementBonus = false;
int _reRolledDiceIndex = -1;
bool _forcesPatrollingUp = true;
bool _villageLastMappingPhase = false; 
final _logger = Logger(); 
final _random = Random(); 
bool _isGameOver = false; 
bool _flareGunForceEncounter = false; 
bool _binocularMapExtraHexes = false; 
int  _extraHexes = 0; 
List<String> _encounterVisuals = []; 
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
//  class to render decision button
// *********************************************
class ActionButton extends StatelessWidget {
  final String message;
  final VoidCallback onAction;
  final VoidCallback onCloseRequest;
  final bool isActive; 
  final bool inInventory; 

  const ActionButton(
      {super.key,
      required this.message,
      required this.isActive,
      required this.inInventory, 
      required this.onAction,
      required this.onCloseRequest});

  Color _getTextColor() { 
    Color textColor = Colors.black; 

    // if not in inventory, the text font will be grey 
    if (!inInventory) { textColor = Colors.grey; }
    return textColor; 

  }

  Color _getBackGroundColor() { 
    Color backgroundColor = Colors.grey; 

    // if active, show white, if not active, show grey, if not in inventory, show black
    if (!inInventory) {
      backgroundColor = Colors.black;
    }
    else { 
      if (isActive) { backgroundColor = Colors.white; }
    }
    return backgroundColor; 

  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 250.0,
        height: 70.0,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            alignment: Alignment.center,
            backgroundColor: _getBackGroundColor(), // Background color
            overlayColor: Colors.blueAccent.withValues(), // pressed ripple
            side: const BorderSide(
              color:  Colors.black,
              width: 3.0,
            ), // Border color
          ),
          onPressed: () {
            if (isActive) {
              onAction();
              onCloseRequest();
            }
          },
          child: Center(
              child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: constAppTextFont,
                color: _getTextColor(), 
                fontSize: 12.0),
          )),
        ));
  }
}

// *********************************************
//  generic message overlay
// *********************************************
class MessageOverlay extends StatelessWidget {
  final VoidCallback onFinished;
  final EnumMessageType messageType;
  final String message;

  const MessageOverlay(
      {super.key,
      required this.onFinished,
      required this.messageType,
      required this.message});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      const ModalBarrier(dismissible: false, color: Colors.black12),
      Align(
          alignment: Alignment.center,
          child: Card(
              elevation: 8.0,
              color: (messageType == EnumMessageType.success)
                  ? Colors.green
                  : Colors.red,
              child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(message,
                      style: const TextStyle(
                          fontFamily: constAppTextFont,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      textAlign: TextAlign.center))))
    ]);
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
      _random.nextBool()
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

  // *********************************************
  // which was last place they were before the village
  // *********************************************
  int _getLastBeforeVillage() {
    int id = 0;

    for (MapHex mh in _map.reversed) {
      if (mh.lastBeforeVillage == true) {
        id = mh.id;
        break;
      }
    }

    return id;
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
  //  apc - find a first aid kit
  // *********************************************
  void _doApcKit() {
    // pick up a first aid kit
    _pilot.pickUpItem(EnumInventory.firstaidkit);

  }

  // *********************************************
  //  apc - rest
  // *********************************************
  void _doApcRest() {
    _pilot.setProximity(EnumDirection.increment);
    _pilot.setEndurance(EnumDirection.increment);
  }

  // *********************************************
  //  helicopter - find a flare gun
  // *********************************************
  void _doHelicopterFlare() {
    _pilot.pickUpItem(EnumInventory.flaregun);
  }

  // *********************************************
  //  helicopter - rest
  // *********************************************
  void _doHelicopterRest() {
    _pilot.setEndurance(EnumDirection.increment);
    _pilot.setEndurance(EnumDirection.increment);
  }

  // *********************************************
  //  wolf - growl
  // *********************************************
  Widget _returnWolf() {
    String message = "";

    // decide on what message to put up
    if (_pilot.hasAnItem(EnumInventory.machete)) {
      message = constWolfOption3;
      // but lose the machete
      _pilot.dropOneItem(EnumInventory.machete);
    } else if (_moveDice >= 3) {
      message = constWolfOption1;
      // superficial wound
      _pilot.setHealth(EnumDirection.decrement);
    } else {
      message = constWolfOption2;
      _pilot.setAffliction(EnumAffliction.deepcut);
    }

    return Column(children: [
      const Padding(
        padding: EdgeInsets.all(5.0),
      ),
      Text(
        message,
        style: const TextStyle(
            color: Colors.white, fontFamily: constAppTextFont, fontSize: 15),
        textAlign: TextAlign.center,
      ),
      const Padding(
        padding: EdgeInsets.all(10.0),
      ),
      _returnContinueButton(),
    ]);
  }

  // *********************************************
  //  snake - ssssssssssssssssss
  // *********************************************
  Widget _returnSnake() {
    String message = "";

    // decide on what message to put up
    if (_pilot.hasAnItem(EnumInventory.machete)) {
      message = constSnakeOption3;
    } else if (_map[_selectedHex].terrain == EnumTerrain.scrub) {
      message = constSnakeOption1;
      _pilot.setHealth(EnumDirection.decrement);
    } else {
      message = constSnakeOption2;
      _pilot.setAffliction(EnumAffliction.fever);
    }

    return Column(children: [
      const Padding(
        padding: EdgeInsets.all(5.0),
      ),
      Text(
        message,
        style: const TextStyle(
            color: Colors.white, fontFamily: constAppTextFont, fontSize: 15),
        textAlign: TextAlign.center,
      ),
      const Padding(
        padding: EdgeInsets.all(10.0),
      ),
      _returnContinueButton(),
    ]);
  }

  // *********************************************
  //  mortar - run to next hex
  // *********************************************
  void _doMortarRun() {
    int newId =
        _getIdFromColRow(_map[_selectedHex].col + 1, _map[_selectedHex].row);

    // change all the values so we update where we're at 
    _map[_oldHex].current = false;
    _map[_selectedHex].current = false;
    _map[newId].current = true;
    _map[_selectedHex].previous = true;
    _map[newId].previous = true;
    _oldHex = _selectedHex; 
    _selectedHex = newId; 
    _pilot.setEndurance(EnumDirection.decrement);
    _pilot.setAffliction(EnumAffliction.gunshotwound);

    // since we ran into a new hex, auto make that scrub 
    _map[_selectedHex].terrain = EnumTerrain.scrub; 

  }

  // *********************************************
  //  mortar - drop
  // *********************************************
  void _doMortarDrop() {
    _pilot.setProximity(EnumDirection.decrement);
  }

  // *********************************************
  //  dust - keep going
  // *********************************************
  void _doDustForward() {
    // lose endurance fighting the storm
    _pilot.setEndurance(EnumDirection.decrement);
    _pilot.setEndurance(EnumDirection.decrement);
  }

  // *********************************************
  //  dust - go back
  // *********************************************
  void _doDustBack() {
    // no longer where they selected
    _map[_selectedHex].current = false;
    // move them back to old hex (unless old hex was a village, then push them back again)
    if (_map[_oldHex].terrain == EnumTerrain.village) {
      _map[_getLastBeforeVillage()].current = true;
      _selectedHex = _getLastBeforeVillage();
    } else {
      _map[_oldHex].current = true;
      _selectedHex = _oldHex;
    }
    setState(() {
      // do nothing
    });
  }

  // *********************************************
  //  cave - get a binos
  // *********************************************
  void _doCaveBinos() {
    // add binoculars
    _pilot.pickUpItem(EnumInventory.binoculars);
  }

  // *********************************************
  //  cave - find a map
  // *********************************************
  void _doCaveMap() {
    late MapHex newHex;
    int id = 0;

    // add a village 4 spaces away and surround it with brush or scrub
    newHex = MapFactory.moveRandomSteps(
        _map[_selectedHex].row, _map[_selectedHex].col, 3);
    id = _getIdFromColRow(newHex.col, newHex.row);
    _map[id].terrain = EnumTerrain.brush;
    _map[id].visible = true;
    // make that open and mark it where a tributary is
    _hexesTributary.add(id);
    // walk around it to make bordering spaces either scrub or brush if they are empty
    setState(() {
      _setTerrainAroundSpot(newHex.col, newHex.row);
    });
  }

  // *********************************************
  //  soldier - get a rifle
  // *********************************************
  void _doSoldierRifle() {
    // add an AK
    _pilot.pickUpItem(EnumInventory.ak);
  }

  // *********************************************
  //  soldier - find a map
  // *********************************************
  void _doSoldierMap() {
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
  //  gunships - increase proximity
  // *********************************************
  void _doGunshipsProximity() {
    // increase 2 proximity
    _pilot.setProximity(EnumDirection.increment);
    _pilot.setProximity(EnumDirection.increment);
  }

  // *********************************************
  //  gunships - extra rest
  // *********************************************
  void _doGunshipsRest() {
    // gain 2 helath and 1 endurance
    _pilot.setHealth(EnumDirection.increment);
    _pilot.setHealth(EnumDirection.increment);
    _pilot.setEndurance(EnumDirection.increment);
  }

  // *********************************************
  //  gunships - use flare gun
  // *********************************************
  void _doGunshipsFlareGun() {
    // win!
    _rescued = true;
  }

  // *********************************************
  //  gunships - if they have flaregun, add option
  // *********************************************
  Widget _checkGunshipsFlareGun() {
    if (!_pilot.hasAnItem(EnumInventory.flaregun)) {
      return Container();
    } else {
      return ActionButton(
          message: constGunshipsOption3,
          isActive: true,
          inInventory: true,
          onAction: _doGunshipsFlareGun,
          onCloseRequest: widget.onClose);
    }
  }

  // *********************************************
  //  building - make a bandage
  // *********************************************
  void _doBuildingBandage() {
    // gain 2 health back
    _pilot.setHealth(EnumDirection.increment);
    _pilot.setHealth(EnumDirection.increment);
  }

  // *********************************************
  //  building - extra rest
  // *********************************************
  void _doBuildingRest() {
    // gain 1 endurance
    _pilot.setEndurance(EnumDirection.increment);
  }

  // *********************************************
  //  building - get machete
  // *********************************************
  void _doBuildingMachete() {
    // pick up the machete
    _pilot.pickUpItem(EnumInventory.machete);
  }

  // *********************************************
  //  building - if they don't already have a machete, can get one
  // *********************************************
  Widget _checkBuildingMachete() {
    if (_pilot.hasAnItem(EnumInventory.machete)) {
      return Container();
    } else {
      return ActionButton(
          message: constBuildingOption3,
          isActive: true,
          inInventory: true,          
          onAction: _doBuildingMachete,
          onCloseRequest: widget.onClose);
    }
  }

  // *********************************************
  //  tributary - move
  // *********************************************
  void _doTributaryMove() {
    _moveAllowed = true;
  }

  // *********************************************
  //  tributary - rest
  // *********************************************
  void _doTributaryRest() {
    _pilot.setHealth(EnumDirection.increment);
    _pilot.setEndurance(EnumDirection.increment);
  }

  // *********************************************
  //  road - move
  // *********************************************
  void _doRoadMove() {
    // can keep on moving
    _moveAllowed = true;
  }

  // *********************************************
  //  road - proximity
  // *********************************************
  void _doRoadProximity() {
    // Increase
    _pilot.setProximity(EnumDirection.increment);
  }

  // *********************************************
  //  sniper - run
  // *********************************************
  void _doSniperRun() {
    // take 2 gunshot wounds!
    _pilot.setAffliction(EnumAffliction.gunshotwound);
    _pilot.setAffliction(EnumAffliction.gunshotwound);
    // then run
    _moveAllowed = true;
  }

  // *********************************************
  //  sniper - retreat
  // *********************************************
  void _doSniperRetreat() {
    _pilot.setAffliction(EnumAffliction.gunshotwound);
    _pilot.setAffliction(EnumAffliction.deepcut);
    // move them back to old hex (unless old hex was a village, then push them back again)
    if (_map[_oldHex].terrain == EnumTerrain.village) {
      _map[_getLastBeforeVillage()].current = true;
    } else {
      _map[_oldHex].current = true;
    }
    _map[_selectedHex].current = false;
    _map[_selectedHex].impassable = true;
    // redraw
    setState() {
      // do nothing
    }

  }

  // *********************************************
  //  minefield - retreat
  // *********************************************
  void _doMinefieldRetreat() {
    // move them back to old hex (unless old hex was a village, then push them back again)
    if (_map[_oldHex].terrain == EnumTerrain.village) {
      _map[_getLastBeforeVillage()].current = true;
    } else {
      _map[_oldHex].current = true;
    }
    _map[_selectedHex].current = false;
    _map[_selectedHex].impassable = true;

  }

  // *********************************************
  //  minefield - move through
  // *********************************************
  void _doMinefieldMove() {
    _pilot.setProximity(EnumDirection.decrement);
  }

  // *********************************************
  //  milepost - friendly terrain
  // *********************************************
  void _doMilepostFriendlyTerrain() {
    _milepostFriendlyTerrain = true;
  }

  // *********************************************
  //  milepost - new village
  // *********************************************
  void _doMilepostNewVillage() {
    late MapHex newHex;
    int id = 0;

    newHex = MapFactory.moveRandomSteps(
        _map[_selectedHex].row, _map[_selectedHex].col, 2);
    // make that a village
    id = _getIdFromColRow(newHex.col, newHex.row);
    _map[id].terrain = EnumTerrain.village;
    _map[id].visible = true;
    // walk around it to make bordering spaces either scrub or brush if they are empty
    setState(() {
      _setTerrainAroundSpot(newHex.col, newHex.row);
    });
  }

  // *********************************************
  //  milepost - extra movement
  // *********************************************
  void _doMilepostMovementBonus() {
    _movementBonus = true;
  }

  // *********************************************
  //  thorns -- either go back, or chop/skip
  // *********************************************
  void _doThorns1() {
    // if machete,
    if (_pilot.hasAnItem(EnumInventory.machete)) {
      // set flags to skip stealth and rest
      _skipStealh = true;
      _skipRest = true;
    } else {
      // move them back to old hex (unless old hex was a village, then push them back again)
      if (_map[_oldHex].terrain == EnumTerrain.village) {
        _map[_getLastBeforeVillage()].current = true;
      } else {
        _map[_oldHex].current = true;
      }
      _map[_selectedHex].current = false;
      _map[_selectedHex].impassable = true;      

    }
  }

  // *********************************************
  //  thorns -- push on or chop/keep
  // *********************************************
  void _doThorns2() {
    // if machete,
    if (_pilot.hasAnItem(EnumInventory.machete)) {
      // just continue on like normal
    } else {
      // they fight through, so add deep cut
      _pilot.setAffliction(EnumAffliction.deepcut);
    }
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
    String option1 = "";
    String option2 = "";

    // always set additional move to false so we have to be explicit
    _moveAllowed = false; 

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
        // add this spot to the set
        _hexesFriendlyVillage.add(id);
        return _returnContinueButton();

        // rockslide
      } else if (encounter == EnumEncounter.rockslide) {
        _pilot.setAffliction(EnumAffliction.brokenfoot);
        return _returnContinueButton();

        // mortar fire
      } else if (encounter == EnumEncounter.mortar) {
        return Column(children: [
          ActionButton(
              message: constMortarOption1,
              isActive: true,
            inInventory: true,              
              onAction: _doMortarRun,
              onCloseRequest: widget.onClose),
          ActionButton(
              message: constMortarOption2,
              isActive: true,
              inInventory: true,
              onAction: _doMortarDrop,
              onCloseRequest: widget.onClose)
        ]);
        // dust storm
      } else if (encounter == EnumEncounter.dust) {
        return Column(children: [
          ActionButton(
              message: constDustOption1,
              isActive: true,
              inInventory: true,
              onAction: _doDustBack,
              onCloseRequest: widget.onClose),
          ActionButton(
              message: constDustOption2,
              isActive: true,
              inInventory: true,
              onAction: _doDustForward,
              onCloseRequest: widget.onClose)
        ]);

        // chemical weapons
      } else if (encounter == EnumEncounter.chemicals) {
        // if theyhave a wound or cut, lose further health
        if ((_pilot.hasAnAffliction(EnumAffliction.burn)) ||
            (_pilot.hasAnAffliction(EnumAffliction.gunshotwound))) {
          _pilot.setHealth(EnumDirection.decrement);
          _pilot.setHealth(EnumDirection.decrement);
        } else {
          _pilot.setAffliction(EnumAffliction.burn);
          // if they have 6 endurance, lose 1
          if (_pilot.getEndurance() == 6) {
            _pilot.setEndurance(EnumDirection.decrement);
          }
        }
        return _returnContinueButton();

        // thorny briars
      } else if (encounter == EnumEncounter.thorns) {
        if (_pilot.hasAnItem(EnumInventory.machete)) {
          option1 = constThornsOption3;
          option2 = constThornsOption4;
        } else {
          option1 = constThornsOption1;
          option2 = constThornsOption2;
        }

        return Column(children: [
          ActionButton(
              message: option1,
              isActive: true,
              inInventory: true,
              onAction: _doThorns1,
              onCloseRequest: widget.onClose),
          ActionButton(
              message: option2,
              isActive: true,
              inInventory: true,
              onAction: _doThorns2,
              onCloseRequest: widget.onClose)
        ]);

        // building
      } else if (encounter == EnumEncounter.building) {
        return Column(children: [
          ActionButton(
              message: constBuildingOption1,
              isActive: true,
              inInventory: true,
              onAction: _doBuildingBandage,
              onCloseRequest: widget.onClose),
          ActionButton(
              message: constBuildingOption2,
              isActive: true,
              inInventory: true,
              onAction: _doBuildingRest,
              onCloseRequest: widget.onClose),
          _checkBuildingMachete(),
        ]);

        // road
      } else if (encounter == EnumEncounter.road) {
        return Column(children: [
          ActionButton(
              message: constRoadOption1,
              isActive: true,
              inInventory: true,
              onAction: _doRoadMove,
              onCloseRequest: widget.onClose),
          ActionButton(
              message: constRoadOption2,
              isActive: true,
              inInventory: true,
              onAction: _doRoadProximity,
              onCloseRequest: widget.onClose),
        ]);

        // dead soldier
      } else if (encounter == EnumEncounter.soldier) {
        return Column(children: [
          ActionButton(
              message: constSoldierOption1,
              isActive: true,
              inInventory: true,
              onAction: _doSoldierRifle,
              onCloseRequest: widget.onClose),
          ActionButton(
              message: constSoldierOption2,
              isActive: true,
              inInventory: true,
              onAction: _doSoldierMap,
              onCloseRequest: widget.onClose),
        ]);

        // snake
      } else if (encounter == EnumEncounter.snake) {
        return _returnSnake();

        // wolf
      } else if (encounter == EnumEncounter.wolf) {
        return _returnWolf();

        // helicopter
      } else if (encounter == EnumEncounter.helicopter) {
        // remove from the list
        try {
          _hexesCrashedChopper.remove(_selectedHex);
          _map[_selectedHex].encounter = EnumEncounter.helicopter;
        }
        catch (e) {
          // do nothing
        }
        // don't show flare gun option if they already have it 
        if (!_pilot.hasAnItem(EnumInventory.flaregun)) {
          return Column(children: [
            ActionButton(
                message: constHelicopterOption1,
                isActive: true,
                inInventory: true,
                onAction: _doHelicopterFlare,
                onCloseRequest: widget.onClose),
            ActionButton(
                message: constHelicopterOption2,
                isActive: true,
                inInventory: true,
                onAction: _doHelicopterRest,
                onCloseRequest: widget.onClose)
          ]);
        }
        else { 
          return Column(children: [
            ActionButton(
                message: constHelicopterOption2,
                isActive: true,
                inInventory: true,
                onAction: _doHelicopterRest,
                onCloseRequest: widget.onClose)
          ]);     
        }
         // apc
      } else if (encounter == EnumEncounter.apc) {
        return Column(children: [
          ActionButton(
              message: constApcOption1,
              isActive: true,
              inInventory: true,
              onAction: _doApcKit,
              onCloseRequest: widget.onClose),
          ActionButton(
              message: constApcOption2,
              isActive: true,
              inInventory: true,
              onAction: _doApcRest,
              onCloseRequest: widget.onClose)
        ]);
      }

      // cave
      else if (encounter == EnumEncounter.cave) {
        return Column(children: [
          ActionButton(
              message: constCaveOption1,
              isActive: true,
              inInventory: true,
              onAction: _doCaveMap,
              onCloseRequest: widget.onClose),
          ActionButton(
              message: constCaveOption2,
              isActive: true,
              inInventory: true,
              onAction: _doCaveBinos,
              onCloseRequest: widget.onClose)
        ]);

        // gunships
      } else if (encounter == EnumEncounter.gunships) {
        return Column(children: [
          ActionButton(
              message: constGunshipsOption1,
              isActive: true,
              inInventory: true,
              onAction: _doGunshipsProximity,
              onCloseRequest: widget.onClose),
          ActionButton(
              message: constGunshipsOption2,
              isActive: true,
              inInventory: true,
              onAction: _doGunshipsRest,
              onCloseRequest: widget.onClose),
          _checkGunshipsFlareGun(),
        ]);

        // minefield
      } else if (encounter == EnumEncounter.minefield) {
        return Column(children: [
          ActionButton(
              message: constMinefieldOption1,
              isActive: true,
              inInventory: true,
              onAction: _doMinefieldMove,
              onCloseRequest: widget.onClose),
          ActionButton(
              message: constMinefieldOption2,
              isActive: true,
              inInventory: true,
              onAction: _doMinefieldRetreat,
              onCloseRequest: widget.onClose)
        ]);

        // sniper
      } else if (encounter == EnumEncounter.sniper) {
        return Column(children: [
          ActionButton(
              message: constSniperOption1,
              isActive: true,
              inInventory: true,
              onAction: _doSniperRun,
              onCloseRequest: widget.onClose),
          ActionButton(
              message: constSniperOption2,
              isActive: true,
              inInventory: true,
              onAction: _doSniperRetreat,
              onCloseRequest: widget.onClose)
        ]);

        // milepost
      } else if (encounter == EnumEncounter.milepost) {
        // no matter what, they can move again
        _moveAllowed = true;
        return Column(children: [
          ActionButton(
              message: constMilepostOption1,
              isActive: true,
              inInventory: true,
              onAction: _doMilepostFriendlyTerrain,
              onCloseRequest: widget.onClose),
          ActionButton(
              message: constMilepostOption2,
              isActive: true,
              inInventory: true,
              onAction: _doMilepostNewVillage,
              onCloseRequest: widget.onClose),
          ActionButton(
              message: constMilepostOption3,
              isActive: true,
              inInventory: true,
              onAction: _doMilepostMovementBonus,
              onCloseRequest: widget.onClose)
        ]);

        // tributary
      } else if (encounter == EnumEncounter.tributary) {
        // remove from the list
        try {
          _hexesTributary.remove(_selectedHex);
        }
        catch (e) {
          // do nothing
        }
        return Column(children: [
          ActionButton(
              message: constTributaryOption1,
              isActive: true,
              inInventory: true,
              onAction: _doTributaryMove,
              onCloseRequest: widget.onClose),
          ActionButton(
              message: constTributaryOption2,
              isActive: true,
              inInventory: true,
              onAction: _doTributaryRest,
              onCloseRequest: widget.onClose)
        ]);

        // catch all (remove later)
      } else {
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
    if ((_hexesCrashedChopper.contains(_selectedHex)) ||
        (_hexesTributary.contains(_selectedHex))) {
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
          _currentEncounterIndex = _random.nextInt(_encounterImages.length);
        } else {
          // are we finding a crashed helicopter or a tributary?
          _currentEncounterIndex = _hexesCrashedChopper.contains(_selectedHex)
              ? EnumEncounter.helicopter.index
              : EnumEncounter.tributary.index;
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
            _currentEncounterIndex = _random.nextInt(_encounterImages.length);
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
            // if the player forced the encounter by using the flare gun, the set of
            // encounters is smaller
            if (_flareGunForceEncounter) {
              _currentEncounterIndex =
                  _encounterFactory.getForcedEncounter(_map[_selectedHex]);
            }
            else {
              _currentEncounterIndex =
                  _encounterFactory.getRandomEncounter(_map[_selectedHex]);
            }
            // if we find a cave, it can't be in scrub or brush, so just flip to no encounter
            if (EnumEncounter.values[_currentEncounterIndex] ==
                EnumEncounter.cave) {
              if ((_map[_selectedHex].terrain == EnumTerrain.scrub) ||
                  (_map[_selectedHex].terrain == EnumTerrain.brush)) {
                _currentEncounterIndex = EnumEncounter.none.index;
              }
            }
            // if we have a rockslide, can only be in rough or hills, so may need to flip to no encounter
            if (EnumEncounter.values[_currentEncounterIndex] ==
                EnumEncounter.rockslide) {
              if ((_map[_selectedHex].terrain == EnumTerrain.scrub) ||
                  (_map[_selectedHex].terrain == EnumTerrain.brush)) {
                _currentEncounterIndex = EnumEncounter.none.index;
              }
            }
            // hardcode for testing
            // _currentEncounterIndex = EnumEncounter.dust.index;
            message = _encounterFactory
                .getEncounterDescription(_currentEncounterIndex);
            // add this encoutner to the map hex for later (if not a none)
            if (_currentEncounterIndex != EnumEncounter.none.index) { 
              _map[_selectedHex].encounter = EnumEncounter.values[_currentEncounterIndex];
            }
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
//  class to build each die 
// *********************************************
class _DiceOption extends StatelessWidget {
  final int value;
  final void Function(int value) onSelected;
  final EnumPhase phase; 

  const _DiceOption({
    required this.value,
    required this.phase, 
    required this.onSelected,    
  });

  @override
  Widget build(BuildContext context) {
    String assetPath = "";
    if (phase == EnumPhase.move) {
      assetPath = (value == _moveDice) ? "$constDieFaceRed$value.jpg" : "$constDieFaceWhite$value.jpg";
    }
    else if (phase == EnumPhase.stealth) {
      assetPath = (value == _stealthDice) ? "$constDieFaceRed$value.jpg" : "$constDieFaceWhite$value.jpg";
    }
    else {
      assetPath = (value == _restDice) ? "$constDieFaceRed$value.jpg" : "$constDieFaceWhite$value.jpg";
    }

    return GestureDetector(
      onTap: () => onSelected(value),
      child: Container(
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: SizedBox(
          width: 40,
          height: 40, 
          child: Image.asset(
          assetPath,
          fit: BoxFit.contain,)
        ),
      ),
    );
  }
}

// *********************************************
//  decide how many dice to return 
// *********************************************
int _getMaxDice(EnumPhase phase) {
  int result = 6; 

  // pretty simple, always six unless the pilot has a broken foot and
  // then you only get two move dice
  if ((phase == EnumPhase.move) && (_pilot.hasAnAffliction(EnumAffliction.brokenfoot))) {
    result = 2; 
  }

  return result; 

}

// *********************************************
//  class to build each row 
// *********************************************
class DiceSelectionRow extends StatelessWidget {
  final String label;
  final EnumPhase phase;
  final void Function(int) onSelected;

  const DiceSelectionRow({
    super.key,
    required this.label,
    required this.phase,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontFamily: constAppTextFont,            
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int value = 0; value <= _getMaxDice(phase); value++)
              _DiceOption(
                value: value,
                phase: phase,
                onSelected: onSelected,
              ),
          ],
        ),

        const SizedBox(height: 20),
      ],
    );
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

  // ************************
  // adjust move dice
  // ************************
  void _pickMoveDice(int value) {
    // first check, if not allocation phase, just bail
    if (_phase != EnumPhase.allocate) {
      return;
    }

    // can't pick more dice than available
    if ((value + _stealthDice + _restDice) > _pilot.getEndurance()) {
      return;
    }  

    // set the new value
    _moveDice = value; 
    _totalDice = _getTotalDice();

    // redraw
    _overlayEntry?.markNeedsBuild();
    setState(() {
      // do nothing
    });

  }
  

  // ************************
  // adjust stealth dice
  // ************************
  void _pickStealthDice(int value) {
    // first check, if not allocation phase, just bail
    if (_phase != EnumPhase.allocate) {
      return;
    }

    // can't pick more dice than available
    if ((_moveDice + value + _restDice) > _pilot.getEndurance()) {
      return;
    }  
    // set the new value
    _stealthDice = value; 
    _totalDice = _getTotalDice();

    // redraw
    _overlayEntry?.markNeedsBuild();
    setState(() {
      // do nothing
    });
  }


  // ************************
  // adjust rest dice
  // ************************
  void _pickRestDice(int value) {
    // first check, if not allocation phase, just bail
    if (_phase != EnumPhase.allocate) {
      return;
    }

    // can't pick more dice than available
    if ((_moveDice + _stealthDice + value) > _pilot.getEndurance()) {
      return;
    }  
    // set the new value
    _restDice = value; 
    _totalDice = _getTotalDice();

    // redraw
    _overlayEntry?.markNeedsBuild();
    setState(() {
      // do nothing
    });

  }  

  // *********************************************
  // how many dice are there to allocate?
  // *********************************************
  int _getTotalDice() {
     return _pilot.getEndurance() - (_moveDice + _stealthDice + _restDice);

  }

  // *********************************************
  // total up how many points they got 
  // *********************************************
  String _getEndGamePoints(EnumGameOver gameOverReason, int totalPoints, int hexesTraveled) {
    String message; 

    // decide on which string to return 
    if (gameOverReason == EnumGameOver.rescued) {
      message = constGameOverWon
      .replaceFirst("X", totalPoints.toString())     // total points
      .replaceFirst("Z", hexesTraveled.toString());    // hexes traveled 
    }
    else { 
      message = constGameOverLost
      .replaceFirst("X", totalPoints.toString())     // total points
      .replaceFirst("Z", hexesTraveled.toString());    // hexes traveled 
    }

    return message; 

  }

  // *********************************************
  // decide which message to show 
  // *********************************************
  String _getEndGameText(EnumGameOver gameOverReason) {

    if (gameOverReason == EnumGameOver.rescued) {
      return constGameOverRescued;
    }
    else if (gameOverReason == EnumGameOver.captured) {
      return constGameOverCaptured;
    }
    else {
      return constGameOverKilled;
    }
  }

  // *********************************************
  // and which graphic to show 
  // *********************************************
  String _getEndGameGraphic(EnumGameOver gameOverReason) {
    bool male = Random().nextBool(); 
    String num  = (male) ? "1" : "2";
    late String img;
    String folder = constAssetsImagesFolder; 

    if (gameOverReason == EnumGameOver.rescued) {
      img = constImageRescued;
    }
    else if (gameOverReason == EnumGameOver.captured) {
      img = constImageCaptured;
    }
    else {
      img = constImageKilled;
    }

    return folder + num + img; 
  }

  // *********************************************
  // display overlay with game results and message
  // *********************************************
  Future<void> _endGameOverlay(EnumGameOver gameOverReason, int hexesTraveled, int totalPoints) async {
    _completer = Completer<void>();
    if (_overlayEntry != null) return; // Prevent stacking

    // set this here
    _isGameOver = true; 

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
                          Container(
                            color: Colors.black54,
                            alignment: Alignment.center,
                            height: 275,
                            width: 275,
                            child: Image.asset(_getEndGameGraphic(gameOverReason),
                              fit: BoxFit.contain,),
                          ),
                          const SizedBox(height: 20),
                          Text(
                              _getEndGameText(gameOverReason),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontFamily: constAppTextFont,
                                  color: Colors.white,
                                  fontSize: 20.0),
                          ),
                          const SizedBox(height: 15),                             
                          Text(
                              _getEndGamePoints(gameOverReason, totalPoints, hexesTraveled),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontFamily: constAppTextFont,
                                  color: Colors.white,
                                  fontSize: 12.0),
                          ),                             
                          const SizedBox(height: 15),
                          ConstrainedBox(
                              constraints: const BoxConstraints(
                              minWidth: 0.0,
                              maxWidth: 160.0,
                              minHeight: 0.0,
                              maxHeight: 55.0,
                          ),
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.black, // Text and icon color
                                backgroundColor: Colors.white, // Background color
                                side: const BorderSide(color: Colors.black,   width: 5.0,), // Border color
                            ),   
                            child: const Align(
                              alignment: Alignment.center,
                              child: Text(
                                constOKText, 
                                style: TextStyle(
                                    fontFamily: constAppTextFont, 
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28.0),
                              )),
                              onPressed: () { _genericCloseOverlay(); },
                              ),
                      )],
                      )                    
                    ),
                  ),
                ), 
               
              ],
            ));

    Overlay.of(context).insert(_overlayEntry!);
  }

  // *********************************************
  // use the flare gun 
  // *********************************************
  void _doFlareGun() {

    // force an encounter (but don't drop yet)
    _flareGunForceEncounter = true; 

  }

  // *********************************************
  // use the binoculars  
  // *********************************************
  void _doBinoculars() {

    // set flag that it is ok to map extra hexes 
    _binocularMapExtraHexes = true; 
    _extraHexes = 0; 
    setState(() {
      // drop them
      _pilot.dropOneItem(EnumInventory.binoculars);      
    });

  }

  // *********************************************
  // machete
  // *********************************************
  void _doMachete() {

    // the button will never be active, so this is just
    // an empty method because I need one 

  }


  // *********************************************
  // use the first aid kit
  // *********************************************
  void _doFirstAidKit() {

    // randomly heal one affliction (except fever)
    if (_pilot.hasAnyAfflictions()) {
        _pilot.healAffliction();
    }

    setState(() {
    // increase health by one
    _pilot.setHealth(EnumDirection.increment);    
    // drop
    _pilot.dropOneItem(EnumInventory.firstaidkit);
    });

  }

  // *********************************************
  // use the AK
  // *********************************************
  void _doAK() {

    setState(() {
      // increase proximity by two 
      _pilot.setProximity(EnumDirection.increment);
      _pilot.setProximity(EnumDirection.increment);
      // now drop
      _pilot.dropOneItem(EnumInventory.ak);
      
    });

  }

  // *********************************************
  // decide how to display the AK 
  // *********************************************
  Widget _displayAK() {
    String buttonMessage = constInventoryAKTitle;
    bool buttonIsActive = false; 
    bool itemInInventory = false; 

    // if they don't have the AK, just show title and not action
    if (_pilot.hasAnItem(EnumInventory.ak)) {
      buttonMessage = "$constInventoryAKTitle ($constInventoryAKAction)";
      buttonIsActive = true; 
      itemInInventory = true; 
    }
    return 
        ActionButton(
          message: buttonMessage,
          isActive: buttonIsActive,
          inInventory: itemInInventory,
          onAction: _doAK,
          onCloseRequest: _genericCloseOverlay);                          

  }

  // *********************************************
  // decide how to display the flare gun 
  // *********************************************
  Widget _displayFlareGun() {
    String buttonMessage = constInventoryFlareGunTitle;
    bool buttonIsActive = false; 
    bool itemInInventory = false;

    // do they have it? 
    if (_pilot.hasAnItem(EnumInventory.flaregun)) {
      itemInInventory = true; 
    }

    // flare gun only active in scrub 
    if ((_pilot.hasAnItem(EnumInventory.flaregun) && (_getCurrentHex().terrain == EnumTerrain.scrub))) {
      buttonMessage = "$constInventoryFlareGunTitle ($constInventoryFlareGunAction)";
      buttonIsActive = true; 
      itemInInventory = true;       
    }
    return 
        ActionButton(
          message: buttonMessage,
          isActive: buttonIsActive,
          inInventory: itemInInventory,
          onAction: _doFlareGun,
          onCloseRequest: _genericCloseOverlay);                          

  }

  // *********************************************
  // we need to show machete even if used only passively
  // *********************************************
  Widget _displayMachete() {
    String buttonMessage = constInventoryMacheteTitle;
    bool buttonIsActive = false; 
    bool itemInInventory = false; 

    // if they don't have it, just show title and not action
    if (_pilot.hasAnItem(EnumInventory.machete)) {
      buttonMessage = "$constInventoryMacheteTitle ($constInventoryMacheteAction)";
      buttonIsActive = false; 
      itemInInventory = true; 
    }
    return 
        ActionButton(
          message: buttonMessage,
          isActive: buttonIsActive,
          inInventory: itemInInventory,
          onAction: _doMachete,
          onCloseRequest: _genericCloseOverlay);                          

  }

  // *********************************************
  // decide how to display the binoculars 
  // *********************************************
  Widget _displayBinoculars() {
    String buttonMessage = constInventoryScopeTitle;
    bool buttonIsActive = false; 
    bool itemInInventory = false; 

    // if they don't have the AK, just show title and not action
    if (_pilot.hasAnItem(EnumInventory.binoculars)) {
      buttonMessage = "$constInventoryScopeTitle ($constInventoryScopeAction)";
      buttonIsActive = true; 
      itemInInventory = true; 
    }
    return 
        ActionButton(
          message: buttonMessage,
          isActive: buttonIsActive,
          inInventory: itemInInventory,
          onAction: _doBinoculars,
          onCloseRequest: _genericCloseOverlay);                          

  }

  // *********************************************
  // decide how to display the first aid kit 
  // *********************************************
  Widget _displayFirstAidKit() {
    String buttonMessage = constInventoryFirstAidKitTitle;
    bool buttonIsActive = false; 
    bool itemInInventory = false; 

    // if they don't have the first aid kit, just show title and not action
    if (_pilot.hasAnItem(EnumInventory.firstaidkit)) {
      buttonMessage = "$constInventoryFirstAidKitTitle ($constInventoryFirstAidKitAction)";
      buttonIsActive = true; 
      itemInInventory = true; 
    }
    return 
        ActionButton(
          message: buttonMessage,
          isActive: buttonIsActive,
          inInventory: itemInInventory,
          onAction: _doFirstAidKit,
          onCloseRequest: _genericCloseOverlay);                          

  }

  // *********************************************
  // display overlay to show inventory and actions
  // *********************************************
  Future<void> _inventoryOverlay() async {
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
                          const SizedBox(height: 10),
                          const Text(
                            constInventoryMessage,
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: constAppTextFont,
                                fontSize: 15),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          _displayAK(),
                          const SizedBox(height: 5),
                          _displayBinoculars(),
                          const SizedBox(height: 5),
                          _displayFirstAidKit(),
                          const SizedBox(height: 5),
                          _displayFlareGun(),
                          const SizedBox(height: 5),
                          _displayMachete(),                          
                          const SizedBox(height: 10),
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
  // which message to send 
  // *********************************************
  String _getAllocationMessage() { 
    String message = "$constDiceAllocationMessage1 $_totalDice $constDiceAllocationMessage2";

    if (_phase != EnumPhase.allocate) {
      message = constDiceAllocationLocked; 
    }

    return message; 

  }

  // *********************************************
  // display overlay to get dice allocation
  // *********************************************
  Future<void> _diceAllocationOverlay() async {
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
                            _getAllocationMessage(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontFamily: constAppTextFont,
                                fontSize: 15),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          DiceSelectionRow(
                            label: constMoveText,
                            phase: EnumPhase.move,
                            onSelected: _pickMoveDice,
                          ),
                          const SizedBox(height: 10),
                          DiceSelectionRow(
                            label: constStealthText,
                            phase: EnumPhase.stealth,
                            onSelected: _pickStealthDice,
                          ),
                          const SizedBox(height: 10),
                          DiceSelectionRow(
                            label: constRestText,
                            phase: EnumPhase.rest,
                            onSelected: _pickRestDice,
                          ),
                          const SizedBox(height: 20),
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
  // close out overlays
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
    String title = ""; 

    result = _random.nextInt(11) + 2;

    // if this may be friendly as a result of the highground encounter, add bonus
    if (_hexesFriendlyVillage.contains(_selectedHex)) {
      result++;
    }

    // based on result, let's do this thing
    if (result == 2) {
      // robbed
      title = "Robbed";
      _villageReaction = EnumVillageReactions.robbed;
      // if they had items, they are all lost
      if (_pilot.hasAnyAfflictions()) {
        message = constVillageRobbedItems;
        _pilot.dropAllItems();
      } else {
        message = constVillageRobbedNoItems;
      }
      _moveAllowed = true;
    } else if (result == 3) {
      // delayed
      title = "Delayed";
      _villageReaction = EnumVillageReactions.delayed;
      // reduce values
      _pilot.setProximity(EnumDirection.decrement);
      _pilot.setEndurance(EnumDirection.decrement);
      message = constVillageDelayed;
      _moveAllowed = true;
    } else if ((result == 4) || (result == 5)) {
      // kicked out
      title = "Kicked out";
      _villageReaction = EnumVillageReactions.kickedout;
      message = constVillageKickedOut;
      // village now impassable
      _map[_selectedHex].impassable = true;
      // move them back to old hex (unless old hex was a village, then push them back again)
      if (_map[_oldHex].terrain == EnumTerrain.village) {
        _map[_getLastBeforeVillage()].current = true;
      } else {
        _map[_oldHex].current = true;
      }
      _map[_selectedHex].current = false;
      _selectedHex = _oldHex; 
      // can't move
      _moveAllowed = false;
    } else if ((result == 6) || (result == 7) || (result == 8)) {
      // untrusting
      title = "Untrusting";
      _villageReaction = EnumVillageReactions.untrusting;
      message = constVillageUntrusting;
      _moveAllowed = true;
    } else if ((result == 9) || (result == 10)) {
      // peaceful
      title = "Peaceful";
      _villageReaction = EnumVillageReactions.peaceful;
      message = constVillagePeaceful;
      // increment by 2
      _pilot.setEndurance(EnumDirection.increment);
      _pilot.setEndurance(EnumDirection.increment);
      _moveAllowed = true;
    } else if (result == 11) {
      // helpful
      title = "Helpful";
      _villageReaction = EnumVillageReactions.helpful;
      message = constVillageHelpful;
      _moveAllowed = true;
      _pilot.setProximity(EnumDirection.increment);
    } else {
      title = "Allied";
      _villageReaction = EnumVillageReactions.allied;
      // heal an affliction
      if (_pilot.hasAnyAfflictions()) {
        _pilot.healAffliction();
        message = constVillageAlliedAfflictions;
      } else {
        message = constVillageAlliedNoAfflictions;
      }

      _pilot.setEndurance(EnumDirection.increment);
      _pilot.setHealth(EnumDirection.increment);
      _pilot.setProximity(EnumDirection.increment);
      _moveAllowed = true;
    }

    // throw up village dialog
    showVillageReactionDialog(context, title, message);

    setState(() {
      // do nothing
    });
  }

  // *********************************************
  // user selected a die
  // *********************************************
  void _tapDice(EnumPhase phase, int value, int target) async {
    String moveMessage = constMoveSuccessMessage;
    String restMessage = constRestSuccessMessage;

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
          _map[_selectedHex].previous = true;
          _allowedToReRoll = true;
        }

        // special case, if they moved into the rescue hex, then just end the game successfully
        _checkRescueConditions();
        // map out next hexes
        _doMappingPhase();
        // for now, assume they can't move again
        // did they choose a six?
        if (value == 6) {
          _pilot.setHealth(EnumDirection.decrement);
          await _overlayMessage(constMoveSixMessage, EnumMessageType.fail);
        } else {
          // see if we need to concatenate messages
          if (_stealthDice > 0) {
            moveMessage = "$moveMessage $constReRollMessage";
          }
          await _overlayMessage(moveMessage, EnumMessageType.success);
        }
        // did they enter a village? that brings a whole new thing to check
        if (_map[_selectedHex].terrain == EnumTerrain.village) {
          // save where they were
          _map[_oldHex].lastBeforeVillage = true;
          _handleVillage();
        }
      } else {
        _allowedToReRoll = false;
        await _overlayMessage(constMoveFailedMessage, EnumMessageType.fail);
        // reset where they were
        _selectedHex = _oldHex; 
      }
    } else if (phase == EnumPhase.stealth) {
      // for stealth phase, see if they chose a six
      if (value >= target) {
        if (value == 6) {
          _pilot.setHealth(EnumDirection.decrement);
          await _overlayMessage(constStealthSixMessage, EnumMessageType.fail);
        } else {
          await _overlayMessage(
              constStealthSuccessMessage, EnumMessageType.success);
        }
      } else {
        _pilot.setProximity(EnumDirection.decrement);
        await _overlayMessage(constStealthFailedMessage, EnumMessageType.fail);
      }
    } else {
      // rest
      if (value >= target) {
        // decide whether they can get more endurance, and if so, tell them,
        // otherwise, just say they rested 
        if (_pilot.getEndurance() != 6) {
          // also check if they have a burn
          if ((_pilot.getEndurance() <= 5) && (!_pilot.hasAnAffliction(EnumAffliction.burn))) {
            restMessage = "$restMessage $constGainEnduranceMessage";
          }
        }
        // actually increment
        _pilot.setEndurance(EnumDirection.increment);
        // did they choose a six?
        if (value == 6) {
          _pilot.setHealth(EnumDirection.decrement);
          await _overlayMessage(constRestSixMessage, EnumMessageType.fail);
        } else {
          await _overlayMessage(restMessage, EnumMessageType.success);
        }
      } else {
        if (_pilot.getEndurance() == 1) {
          restMessage = constRestFailedLoseHealthMessage; 
        }        
        else { 
          restMessage = constRestFailedMessage;
        }
        _pilot.setEndurance(EnumDirection.decrement);
        await _overlayMessage(restMessage, EnumMessageType.fail);
      }
    }

    // update ui
    setState(() {
      // do nothing
    });

    // do some end game checks
    if (_pilot.getHealth() <= 0) {
      await _endGameOverlay(EnumGameOver.killed, _totalHexesTraveled(), _totalUpPoints(EnumGameOver.killed));
    }

    if (_pilot.getProximity() <= 0) {
      await _endGameOverlay(EnumGameOver.captured, _totalHexesTraveled(), _totalUpPoints(EnumGameOver.captured));
    }

  }

  // *********************************************
  // reroll one die
  // *********************************************
  void _reRoll(int index) {
    int mod = 0;
    // if they have a fever, impacts all die rolls
    if (_pilot.hasAnAffliction(EnumAffliction.fever)) {
      mod = 1;
    }

    // only do this if they are allowed, and then flip that flag
    if (_allowedToReRoll) {
      _allowedToReRoll = false;
      _reRolledDiceIndex = index;
      _rollingDice[index] = (_random.nextInt(6) + 1 - mod).clamp(1, 6);
      _overlayEntry?.markNeedsBuild(); // forces overlay to redraw
    }
  }

  // *********************************************
  // give dice new values
  // *********************************************
  void _rollDice() {
    int mod = 0;
    int bonus = 0;
    int clamp = 6;

    // if they have a fever, impacts all die rolls
    if (_pilot.hasAnAffliction(EnumAffliction.fever)) {
      mod = 1;
    }

    // if they have a gunshot wound, also can't roll a six
    if (_pilot.hasAnAffliction(EnumAffliction.gunshotwound)) {
      clamp = 5;
    }

    // if they have movement bonus due to milestone encounter, add + 2
    if (_movementBonus) {
      bonus = 2;
      _movementBonus = false;
    }

    setState(() {
      // the clamp usage ensures keeps it between 1 and max number (usually a six)
      _rollingDice = _rollingDice
          .map((_) => (_random.nextInt(6) + 1 - mod + bonus).clamp(1, clamp))
          .toList();
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
      final asset = (index == _reRolledDiceIndex)
          ? "$constDieFaceRed$value.jpg"
          : "$constDieFaceWhite$value.jpg";

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
            asset,
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
    _rollTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _rollDice(); // your existing method that randomizes all dice
      _overlayEntry?.markNeedsBuild(); // forces overlay to redraw
    });

    // Stop the rolling after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      _rollTimer?.cancel();
      _overlayEntry?.markNeedsBuild();
    });
  }

  // *********************************************
  // if they have six, give them message about it and
  // option to fail the roll
  // *********************************************
  Widget _sixMessage(EnumPhase phase) {

    // first step, make sure time isn't active
    if (!_rollTimer!.isActive) {
      // if all the dice rolled are six (regardless of how many, show the fail button),
      // otherwise just show the text warning about picking a six
      if (_rollingDice.every((r) => r == 6)) {
        return Column(
                children: [
                  const Text(
                    constDiceRollPickSixAndFailOption,
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: constAppTextFont,
                        fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  SizedBox(
                      width: 160.0,
                      height: 55.0,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black, // Text and icon color
                          backgroundColor: Colors.white, // Background color
                          overlayColor:
                              Colors.blueAccent.withValues(), // pressed ripple
                          side: const BorderSide(
                            color: Colors.black,
                            width: 3.0,
                          ), // Border color
                        ),
                        child: const Align(
                            alignment: Alignment.center,
                            child: Text(
                              constFailText,
                              style: TextStyle(
                                  fontFamily: constAppTextFont,
                                  color: Colors.black,
                                  fontSize: 18.0),
                            )),
                        onPressed: () {
                          _tapDice(phase, -1, 0); // this guarantees a failed roll
                        },
                      ))
                ],
              );
      }
      // just show text message if any of them are a six
      else if (_rollingDice.contains(6)) {
        return const Text(
          constDiceRollPickSix,
          style: TextStyle(
              color: Colors.white, fontFamily: constAppTextFont, fontSize: 13),
          textAlign: TextAlign.center,
        );
      }
      // otherwise, just an empty container
      else {
       return Container();       
      }

    }
    // timer still active, so show empty container
    else { 
      return Container();
    }

  }

  // *********************************************
  // display overlay for rolling and choosing dice
  // *********************************************
  Future<void> _diceRollOverlay(EnumPhase phase, int rollToBeat) async {
    String message = "";
    String title = "";

    // always reset this
    _reRolledDiceIndex = -1;

    if (phase == EnumPhase.move) {
      title = constMovePhase;
      message =
          "$constDiceRollMoveMessage1 $rollToBeat $constDiceRollMoveMessage2";
    } else if (phase == EnumPhase.stealth) {
      title = constStealthPhase;
      message =
          "$constDiceRollStealthMessage1 $rollToBeat $constDiceRollStealthMessage2";
      if (_allowedToReRoll) {
        message += constDiceRollStealthMessage4;
      }
    } else {
      // rest phase
      title = constRestPhase;
      message =
          "$constDiceRollRestMessage1 $rollToBeat $constDiceRollRestMessage2";
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
                                title,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: constAppTextFont,
                                    fontSize: 18),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                message,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: constAppTextFont,
                                    fontSize: 13),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 15),
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
                              const SizedBox(height: 12),
                              _sixMessage(phase),
                            ],
                          ))))
            ]));

    Overlay.of(context).insert(_overlayEntry!);

    // start the timer to roll dice
    _startRolling();
  }

  // *********************************************
  // overlay with a message, either good or bad
  // *********************************************
  Future<void> _overlayMessage(String message, EnumMessageType type) async {
    _completer = Completer<void>();
    if (_overlayEntry != null) return; // Prevent stacking

    _overlayEntry = OverlayEntry(
      builder: (_) => MessageOverlay(
        onFinished: _genericCloseOverlay,
        messageType: type,
        message: message,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    Future.delayed(const Duration(seconds: 3), () {
      _genericCloseOverlay();
    });

    return _completer?.future;
  }

  // *********************************************
  // this needs to be called to insert the encounter overlay
  // *********************************************
  Future<void> _showEncounterOverlay(BuildContext context) async {
    final completer = Completer<void>();
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => ImageCyclerOverlay(onClose: () {
        entry.remove();
        completer.complete();
      }),
    );

    Overlay.of(context).insert(entry);
    return completer.future;
  }

  // ************************
  // quit the current game and go back to main screen
  // ************************
  void _quitGame() async {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const LostFalconApp()));
  }

  // ************************
  // set up a new game
  // ************************
  void _newGame() async {
    // clear stuff out
    _map.clear();
    _hexesCrashedChopper.clear();
    _hexesTributary.clear();
    _hexesFriendlyVillage.clear();

    // get an initialized map from the factory
    _map = MapFactory.initMap();
    // add the starting hex to the list the player traveled
    _map[_getIdFromColRow(constStartCol, constStartRow)].previous = true;

    // initial values
    _round = 1;
    _pilot = Pilot();
    _moveDice = constNoDice;
    _stealthDice = constNoDice;
    _restDice = constNoDice;
    _totalDice = 6; 
    _phase = EnumPhase.allocate;
    _isGameOver = false; 

    // clear encounter visuals then grab
    _encounterVisuals.clear();
    _encounterVisuals = EncounterFactory().getEncounterVisuals();

  }

  // ************************
  // which images to show
  // ************************
  AssetImage _healthImage() {
    int value = _pilot.getHealth();
    String display = value.toString(); 
    late String die;

    if ((value == 1) || (value == 2)) {
      die = "$constDieFaceRed$display.jpg";
    }
    else if ((value == 3) || (value == 4)) {
      die = "$constDieFaceYellow$display.jpg";
    }
    else {
      die = "$constDieFaceGreen$display.jpg";
    }

    return AssetImage(die);
  }

  // ************************
  // which images to show
  // ************************
  AssetImage _proximityImage() {
    int value = _pilot.getProximity();
    String display = value.toString(); 
    late String die;

    if ((value == 1) || (value == 2)) {
      die = "$constDieFaceRed$display.jpg";
    }
    else if ((value == 3) || (value == 4)) {
      die = "$constDieFaceYellow$display.jpg";
    }
    else {
      die = "$constDieFaceGreen$display.jpg";
    }

    return AssetImage(die);
  }

  // ************************
  // which image to show
  // ************************
  AssetImage _enduranceImage() {
    int value = _pilot.getEndurance();
    String display = value.toString(); 
    late String die;

    if ((value == 1) || (value == 2)) {
      die = "$constDieFaceRed$display.jpg";
    }
    else if ((value == 3) || (value == 4)) {
      die = "$constDieFaceYellow$display.jpg";
    }
    else {
      die = "$constDieFaceGreen$display.jpg";
    }

    return AssetImage(die);
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
  // friendly display of the round
  // ************************
  String _displayRound() {
    return _round.toString();
  }

  // ************************
  // how many hexes has teh player traveled?
  // ************************
  int _totalHexesTraveled() {
    int count = 0;

    for (MapHex mh in _map) {
      if (mh.previous == true) {
        count++;
      }
    }
    return count;
  }

  // ************************
  // total up end game points
  // ************************
  int _totalUpPoints(EnumGameOver gameOverReason) {
    int hexCount = _totalHexesTraveled();

    // if they won, bonus is remaining health + proximinty + endurance
    int bonus = (gameOverReason == EnumGameOver.rescued)
        ? (_pilot.getHealth() + _pilot.getProximity() + _pilot.getEndurance())
        : 0;

    return hexCount + bonus;
  }

  // ************************
  // map next three hexes
  // ************************
  void _doMappingPhase() {
    int die = _random.nextInt(6) + 1;
    EnumTerrain hex1;
    EnumTerrain hex2;
    EnumTerrain hex3;
    EnumTerrain hexToUse;
    int hexCount = 0;
    MapHex currentHex = _getCurrentHex();
    int row = currentHex.row;
    int col = currentHex.col;
    late MapHex destHex;
    int newRow = 0;
    int newCol = 0;

    _logger.d("doMappingPhase: row #$row, col #$col");

    // odd thing -- don't let villages drop next to each other 
    if (_villageLastMappingPhase) {
      // reroll 
      die = _random.nextInt(5) + 1;
      _villageLastMappingPhase = false; 
    }

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
      _villageLastMappingPhase = true; 
    }

    // special case -- if this is a result of the milepost encounter, everything is scrub
    if (_milepostFriendlyTerrain == true) {
      _milepostFriendlyTerrain = false;
      hex1 = EnumTerrain.scrub;
      hex2 = EnumTerrain.scrub;
      hex3 = EnumTerrain.scrub;
    }


    // start with first hex
    hexToUse = hex1;
    hexCount = 1;

    // start to fill in hexes - depending on whether they are valid hexes and not already filled
    // walk around the whole way; should only hit 3 of these 4 in every situation

    // #1: row-1, col
    if (((row - 1) >= 0)) {
      if (_map[_getIdFromColRow(col, row - 1)].visible == false) {
        _map[_getIdFromColRow(col, row - 1)].terrain = hexToUse;
        _map[_getIdFromColRow(col, row - 1)].visible = true;
        hexCount++;
      }
    }

    // #2: decide if we're doing row+1 or row-1 with col+1
    destHex = _map[_getIdFromColRow(col + 1, row - 1)];
    if (MapFactory.getDistanceBetweenHexes(currentHex, destHex) == 1) {
      newRow = row - 1;
      newCol = col + 1;
    } else {
      newRow = row + 1;
      newCol = col + 1;
    }

    if ((newRow <= constMapRows) &&
        (newRow >= 0) &&
        (newCol <= constMapCols) &&
        (newCol >= 0)) {
      if (_map[_getIdFromColRow(newCol, newRow)].visible == false) {
        if (hexCount == 1) {
          hexToUse = hex1;
        } else if (hexCount == 2) {
          hexToUse = hex2;
        } else {
          hexToUse = hex3;
        }
        _map[_getIdFromColRow(newCol, newRow)].terrain = hexToUse;
        _map[_getIdFromColRow(newCol, newRow)].visible = true;
        hexCount++;
      }
    }

    // #3: row, col +1
    if ((col + 1) <= constMapCols) {
      if (_map[_getIdFromColRow(col + 1, row)].visible == false) {
        if (hexCount == 1) {
          hexToUse = hex1;
        } else if (hexCount == 2) {
          hexToUse = hex2;
        } else {
          hexToUse = hex3;
        }
        // no villages in last column
        if (((col + 1) == (constMapCols - 1)) && (hexToUse == EnumTerrain.village)) {
          hexToUse = EnumTerrain.scrub; 
        }
        _map[_getIdFromColRow(col + 1, row)].terrain = hexToUse;
        _map[_getIdFromColRow(col + 1, row)].visible = true;
        hexCount++;
      }
    }

    // #4: row +1, col
    if (hexCount < 4) {
      if ((row + 1) <= constMapRows) {
        if (_map[_getIdFromColRow(col, row + 1)].visible == false) {
          if (hexCount == 1) {
            hexToUse = hex1;
          } else if (hexCount == 2) {
            hexToUse = hex2;
          } else {
            hexToUse = hex3;
          }
          // no villages in last column
          if (((col + 1) == (constMapCols - 1)) && (hexToUse == EnumTerrain.village)) {
            hexToUse = EnumTerrain.scrub; 
          }          
          _map[_getIdFromColRow(col, row + 1)].terrain = hexToUse;
          _map[_getIdFromColRow(col, row + 1)].visible = true;
          hexCount++;
        }
      }
    }

    // #5: row, col-1
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

    // #6: decide if we're doing row+1 or row-1 with col-1
    if (hexCount < 4) {
      destHex = _map[_getIdFromColRow(col-1, row + 1)];
      if (MapFactory.getDistanceBetweenHexes(currentHex, destHex) == 1) {
        newRow = row + 1;
        newCol = col - 1;
      } else {
        newRow = row - 1;
        newCol = col - 1;
      }

      if ((newRow <= constMapRows) &&
          (newRow >= 0) &&
          (newCol <= constMapCols) &&
          (newCol >= 0)) {
        if (_map[_getIdFromColRow(newCol, newRow)].visible == false) {
          if (hexCount == 1) {
            hexToUse = hex1;
          } else if (hexCount == 2) {
            hexToUse = hex2;
          } else {
            hexToUse = hex3;
          }
          _map[_getIdFromColRow(newCol, newRow)].terrain = hexToUse;
          _map[_getIdFromColRow(newCol, newRow)].visible = true;
          hexCount++;
        }
      }
    }

    setState(() {
      // nothing to do here yet
    });
  }

  // ************************
  // move the u.s. patrol along the outer column
  // ************************
  void _moveUSForces() async {
    int col = constMapCols - 1; // they are always in the last column
    late int row;

    // loop through the rows and hide each one as we iterate
    for (int i = 1; i < constMapRows; i++) {
      // while we're here, hide them all (unless player is within one)
      if (MapFactory.getDistanceBetweenHexes(_getCurrentHex(), MapHex(constFakeHex, col, i)) != 1) {
         _map[_getIdFromColRow(col, i)].visible = false;
      }
      // see if forces are here
      if (_map[_getIdFromColRow(col, i)].rescue) {
        // save the row and remove the forces from that spot
        _map[_getIdFromColRow(col, i)].rescue = false; 
        row = i;
      }
    }

    // decide where US forces are moving 
    if (_forcesPatrollingUp) {
      row--;
      if (row <= constStartRow) {
        _forcesPatrollingUp = false;
        row = 2;
      }
    } else {
      row++;
      if (row >= constMapRows) {
        _forcesPatrollingUp = true;
        row = 3;
      }
    }

    // set the new location 
    _map[_getIdFromColRow(col, row)].rescue = true; 

    // now update them on the map
    _map[_getIdFromColRow(col, row)].visible = true;

    // if the us forces moved to where the player is, they win!
    if (_selectedHex == _getIdFromColRow(col, row)) {
      await _endGameOverlay(EnumGameOver.rescued, _totalHexesTraveled(), _totalUpPoints(EnumGameOver.rescued));
    }

    setState(() {
      // redraw
    });
  }

  // ************************
  // advance through phases
  // ************************
  void _continueButtonPress() async {
    String restMessage = constRestFailedMessage; 

    // if game is over, just ignore the click
    if (_isGameOver) {
      return; 
    }

    // special check, if this is a move phase, and they are in a village, don't let them try to end here
    if ((_phase == EnumPhase.move) && (_map[_selectedHex].terrain == EnumTerrain.village)) {
        await _overlayMessage(constCantEndInVillage, EnumMessageType.fail);
        return; 
    }

    // if move or encounter phase and they either have move remaining or are still in the
    // same hex, then check whether to continue or not 
    if (((_phase == EnumPhase.move) || (_phase == EnumPhase.encounter)) && (_moveAllowed == true)) {
        if (await showYesNoDialog(context, constAboutToEndMovePhase)) {
          // continue along 
        }
        else { 
          return;   
        }
    }

    // increment the phase from current one since they moved to the next
    try {
      // and increment the turn
      setState(() {
        _phase = EnumPhase.values[_phase.index + 1];
      });
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

    // if encounter phase, decide if they had an encounter
    if (_phase == EnumPhase.encounter) {
      await _showEncounterOverlay(context);

      // if they forced an encounter, drop the flare gun now
      if (_flareGunForceEncounter) {
        _pilot.dropOneItem(EnumInventory.flaregun);
        _flareGunForceEncounter = false; 
      }

      // we should do a quick mapping phase here just in case
      _doMappingPhase(); 

      // do a game end check after each encounter
      if (_pilot.getHealth() == 0) {
        await _endGameOverlay(EnumGameOver.killed, _totalHexesTraveled(), _totalUpPoints(EnumGameOver.killed));

      }
      if (_pilot.getProximity() == 0) {
        await _endGameOverlay(EnumGameOver.captured, _totalHexesTraveled(), _totalUpPoints(EnumGameOver.captured));
      }

      // did we get rescued? 
      if ((_currentEncounterIndex == EnumEncounter.gunships.index) && (_rescued)) {
        // show the end game overlay 
        await _endGameOverlay(EnumGameOver.rescued, _totalHexesTraveled(), _totalUpPoints(EnumGameOver.rescued));
      }

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
      // move the u.s. forces up or down
      _moveUSForces();
      // reset village flags and counters
      _villageReaction = EnumVillageReactions.none;
      _motorcycleMoves = 0;
      // set flag that allows a move (so they only do it once per turn)
      if (_moveDice > 0) {
        _moveAllowed = true;
        setState(() {
          // do nothing
        });
      } else {
        await _overlayMessage(
            constNoDiceAllocatedForMoveMessage, EnumMessageType.fail);
        _allowedToReRoll = false;
        //_continueButtonPress();
      }
    }

    // if stealth phase, decide whether they successfully hid from pursuers
    if (_phase == EnumPhase.stealth) {
      if (_stealthDice > 0) {
        // set number of dice based on how many allocated
        _rollingDice =
            List.generate(_stealthDice, (_) => _random.nextInt(6) + 1);
        setState(() {
          // do nothing
        });
        await _diceRollOverlay(EnumPhase.stealth,
            MapFactory.getStealthCost(_getCurrentHex().terrain));
      } else {
        _pilot.setProximity(EnumDirection.decrement);
        await _overlayMessage(constStealthFailedMessage, EnumMessageType.fail);
        //_continueButtonPress();
      }

      // do a game over check to see if the pilot was captured
      if (_pilot.getProximity() <= 0) {
        await _endGameOverlay(EnumGameOver.captured, _totalHexesTraveled(), _totalUpPoints(EnumGameOver.captured));
      }
    }

    // if rest phase, decide whether they lose any endurance
    if (_phase == EnumPhase.rest) {
      if (_restDice > 0) {
        _rollingDice = List.generate(_restDice, (_) => _random.nextInt(6) + 1);
        setState(() {
          // do nothing
        });
        await _diceRollOverlay(
            EnumPhase.rest, MapFactory.getRestCost(_getCurrentHex().terrain));
      } else {
        // if they are at one, we know they won't go lower, but need to let player
        // know health is being impacted
        if (_pilot.getEndurance() == 1) {
          restMessage = constRestFailedLoseHealthMessage; 
        }
        _pilot.setEndurance(EnumDirection.decrement);
        await _overlayMessage(restMessage, EnumMessageType.fail);
        //_continueButtonPress();
      }
    }
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

  // *********************************************
  // which was last place they were before the village
  // *********************************************
  int _getLastBeforeVillage() {
    int id = 0;

    for (MapHex mh in _map.reversed) {
      if (mh.lastBeforeVillage == true) {
        id = mh.id;
        break;
      }
    }

    return id;
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
  // return if the plahyer has traveled through this hex
  // ************************
  bool _hasPlayerTraveledHere(int id) {
    bool result = false;

    if (_map[id].previous == true) {
      result = true;
    }
    return result;
  }

  // ************************
  // decide which graphics to display on the map 
  // ************************
  String _getMapHexGraphic(int row, int col) {
    EnumTerrain enumTerrain = _map[_getIdFromColRow(col, row)].terrain;
    String asset;
    int id = _getIdFromColRow(col, row);

    if (enumTerrain == EnumTerrain.scrub) {
      // decide whether they've been here before (color vs b&w)
      if (_hasPlayerTraveledHere(id)) {
        asset = constImageScrub;
      } else {
        asset = constImageScrubGrey;
      }
    } else if (enumTerrain == EnumTerrain.brush) {
      // decide whether they've been here before (color vs b&w)
      if (_hasPlayerTraveledHere(id)) {
        asset = constImageBrush;
      } else {
        asset = constImageBrushGrey;
      }
    } else if (enumTerrain == EnumTerrain.hills) {
      // decide whether they've been here before (color vs b&w)
      if (_hasPlayerTraveledHere(id)) {
        asset = constImageHills;
      } else {
        asset = constImageHillsGrey;
      }
    } else if (enumTerrain == EnumTerrain.rough) {
      // decide whether they've been here before (color vs b&w)
      if (_hasPlayerTraveledHere(id)) {
        asset = constImageRough;
      } else {
        asset = constImageRoughGrey;
      }
    } else if (enumTerrain == EnumTerrain.village) {
      // decide whether they've been here before (color vs b&w)
      if (_hasPlayerTraveledHere(id)) {
        asset = constImageVillage;
      } else {
        asset = constImageVillageGrey;
      }
    } else if (enumTerrain == EnumTerrain.background) {
      asset = constImageBackground;
    } else {
      asset = constImageUnknown;
    }

    // special cases, if this terrain is the crashed helicopter or water source, show them
    // instead 
    if (_hexesCrashedChopper.contains(id)) {
      if (_hasPlayerTraveledHere(id)) {
        asset = EncounterFactory().getEncounterGraphic(EnumEncounter.helicopter.index);        
      }
      else { 
        asset = constImageEncounterHelicopterGrey; 
      }
    }
    else if (_hexesTributary.contains(id)) {  
      if (_hasPlayerTraveledHere(id)) {      
        asset = EncounterFactory().getEncounterGraphic(EnumEncounter.tributary.index);
      }
      else { 
        asset = constImageEncountersTributaryGrey; 
      }
    }

    // if we had an encounter here, so that graphic instead of terrain
    if (_map[id].encounter != EnumEncounter.none) {
      asset = _encounterVisuals[_map[id].encounter.index];
    }

    // final special case, if this is where US forces are, show them instead of regular terrain
    if (_map[id].rescue) {
      asset = constImageRescue;    
    }

    return asset;
  }

  // ************************
  // check if rescued
  // ************************
  void _checkRescueConditions() async {
    // special case, if they moved into the rescue hex, then just end the game successfully
    if (_map[_selectedHex].rescue) {
      // close any overlay
      _genericCloseOverlay(); 
      // show the end game overlay 
      await _endGameOverlay(EnumGameOver.rescued, _totalHexesTraveled(), _totalUpPoints(EnumGameOver.rescued));
    }
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

    // check: if they are using the binoculars, they are mapping extra hexes 
    if ((_binocularMapExtraHexes) && (_extraHexes <= 2) && (hexDistance <= 3)) {
      // map it (if unknown)
      if ((_map[_selectedHex].terrain == EnumTerrain.unknown) &&
        (_map[_selectedHex].visible == false)) {
          // pick a random terrain
          _map[_selectedHex].terrain = EnumTerrain.values[_random.nextInt(5)];
          _map[_selectedHex].visible = true;
          setState(() {
            // do nothing 
          });
          // increase count, and if now at 2, flip flag  
          _extraHexes++;
          if (_extraHexes == 2) {
            await _overlayMessage(constUsedBinocularsMessage, EnumMessageType.fail); 
            _binocularMapExtraHexes = false;
          }
      }

    }

    // check: if this hex is impassable, bail right out
    if (_map[_selectedHex].impassable) {
      await _overlayMessage(constHexImpassableMessage, EnumMessageType.fail);
      _selectedHex = _oldHex;
      return;
    }

    // check: can they move anymore? 
    if ((_phase == EnumPhase.move) && (!_moveAllowed)) {
      await _overlayMessage(constAlreadMovedMessage, EnumMessageType.fail);
      _selectedHex = _oldHex;
      return;
    } 

    // check: if move phase and they picked same hex, bail right out
    if ((_phase == EnumPhase.move) && (_oldHex == _selectedHex)) {
      // move selected hex back to where they were
      _selectedHex = _oldHex; 
      await _overlayMessage(constSameHexPickedMessage, EnumMessageType.fail);
      return;
    }

    // check: if they picked a special background hex that's not obvious, bail right out
    if (_map[_selectedHex].terrain == EnumTerrain.background) {
      _selectedHex = _oldHex;
      return;
    }

    // check: if they are trying to enter a village during an encounter move, say no
    if ((_map[_selectedHex].terrain == EnumTerrain.village) && 
      (_villageReaction != EnumVillageReactions.none)) {
      await _overlayMessage(constEncounterVillageMessage, EnumMessageType.fail);
      return;
    }

    // if this is move phase, do all the logic
    if ((_phase == EnumPhase.move) && (_moveAllowed)) {
      // is the hex too far away?
      if (hexDistance > 1) {
        await _overlayMessage(constHexTooFarMessage, EnumMessageType.fail);
        _selectedHex = _oldHex;        
        return;
      }

      // special case -- crashed helicopter due to encounter
      if (_hexesCrashedChopper.contains(_selectedHex)) {
        // they just move, no roll or anything
        _map[_oldHex].current = false;
        _map[_selectedHex].current = true;
        _map[_oldHex].previous = true;
        _map[_selectedHex].previous = true;
        // no more move this turn
        _moveAllowed = false; 
        // and since move was successful, they can do a re-roll in stealth phase
        _allowedToReRoll = true; 
        // special case, check if game over in case they moved into rescue hex
        _checkRescueConditions();
      }

      // regular move
      else if (_villageReaction == EnumVillageReactions.none) {
        // what is the move cost?
        moveCost = MapFactory.getMoveCost(h.terrain);
        // if they have dice assigned to move, bring up the overlay to pick from the die roll
        if (_moveDice > 0) {
          // bring up overlay
          _rollingDice =
              List.generate(_moveDice, (_) => _random.nextInt(6) + 1);
          await _diceRollOverlay(EnumPhase.move, moveCost);
        } else {
          await _overlayMessage(
              constNoDiceAllocatedForMoveMessage, EnumMessageType.fail);
        }
        _moveAllowed = false;
        // other village moves
      } else {
        // ok to move
        _map[_oldHex].current = false;
        _map[_selectedHex].current = true;
        _map[_oldHex].previous = true;
        _map[_selectedHex].previous = true;
        // check if they moved into another village (rare but it happens)
        if (_map[_selectedHex].terrain == EnumTerrain.village) {
          _handleVillage();
        }
        // special case, check if game over in case they moved into rescue hex
        _checkRescueConditions();
        // map out next spaces
        _doMappingPhase();

        // if on motorcycle, increment those moves
        if (_villageReaction == EnumVillageReactions.helpful) {
          _motorcycleMoves++;
          if (_motorcycleMoves >= 3) {
            _motorcycleMoves = 0;
            _moveAllowed = false;
          }
        } 
        else {
          _moveAllowed = false;  
        }
      }
    } else if ((_phase == EnumPhase.encounter) && (_moveAllowed)) {
      // there are some encounters where they can also move
      // is the hex too far away?
      if (hexDistance > 1) {
        // abort
        _selectedHex = _oldHex;
        return;
      }

      // ok to move
      _map[_oldHex].current = false;
      _map[_selectedHex].current = true;
      _map[_oldHex].previous = true;
      _map[_selectedHex].previous = true;
      // no more move allowed 
      _moveAllowed = false; 
      // special case, check if game over in case they moved into rescue hex
      _checkRescueConditions();
      // map out next spaces
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
    showTerrainInfoDialog(context, _map[_getIdFromColRow(col, row)], _encounterVisuals);

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
          top: 27,
          left: 30,
          child: Container(
              height: 40,
              width: 50,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 2, // thin border
                ),
              ),
              child: Image.asset(constImagePlayerLocation, fit: BoxFit.cover)));
    }
    // else if player cannot travel through this hex, show close icon
    else if (_map[id].impassable) {
      return const Positioned(
          top: 10,
          left: 15,
          child: Icon(Icons.block, color: Colors.red, size: 75));
    }

    // else if player traveled through hex, show person icon
    else if (_hasPlayerTraveledHere(id)) {
      return const Positioned(
          top: 10,
          left: 15,
          child: Icon(Icons.star_border, color: Colors.black, size: 75));
    }

    // else, just an empty container
    else {
      return Container();
    }
  }
 
  // ************************
  // if they have items, display dialog
  // ************************
  void _handleInventoryTap() async {
    await _inventoryOverlay(); 
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
  // bring up the allocation screen 
  // ************************
  void _handleAllocationTap() async {
      await _diceAllocationOverlay();
  }

  // ************************
  // return inventory color based on whether they have items
  // ************************
  Color _returnInventoryColor() {
    Color result = const Color.fromARGB(255, 68, 68, 68);

    if (_pilot.hasAnyItems()) {
      result = Colors.white;
    }
    return result;
  }

  // ************************
  // return ailments color based on whether they have items
  // ************************
  Color _returnAfflictionsColor() {
    Color result = const Color.fromARGB(255, 68, 68, 68);

    if (_pilot.hasAnyAfflictions()) {
      result = Colors.white;
    }
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
                  const Padding(
                    padding: EdgeInsets.all(5.0),
                  ),                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(), 
                      Column(
                        children: [
                          const Text(constHealthText,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: constAppTextFont,
                                  fontSize: 12.0)
                          ),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                            clipBehavior: Clip.hardEdge, // ensures border clips cleanly
                            child:
                            Image(
                              image: _healthImage(),
                              width: 48.0,
                              height: 48.0,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(), 
                      Column(
                        children: [
                          const Text(constProximityText,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: constAppTextFont,
                                  fontSize: 12.0)
                          ),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                            clipBehavior: Clip.hardEdge, // ensures border clips cleanly
                            child:
                            Image(
                              image: _proximityImage(),
                              width: 48.0,
                              height: 48.0,
                              fit: BoxFit.fill,
                            ),
                          ), 
                        ],
                      ),
                      const Spacer(),                       
                      Column(
                        children: [
                          const Text(constEnduranceText,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: constAppTextFont,
                                  fontSize: 12.0)
                          ),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                            clipBehavior: Clip.hardEdge, // ensures border clips cleanly
                            child:
                              Image(
                                image: _enduranceImage(),
                                width: 48.0,
                                height: 48.0,
                                fit: BoxFit.fill,
                              ),
                          ), 
                        ],
                      ),
                      const Spacer(),   
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
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
                        elevation: 0.0, // col.toDouble(),
                        padding: 0.0,
                        cornerRadius: null, // hex shape (vs rounded)
                        color: Colors.grey,
                        //child: Text("$row, $col"),
                        child: GestureDetector(
                          onTap: () {
                            // do something if we're in the move phase
                            if ((_phase == EnumPhase.move) ||
                                (_phase == EnumPhase.encounter)) {
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
                          child: Column(children: [
                            Icon(Icons.hiking,
                                size: 30, color: _returnInventoryColor()),
                            const SizedBox(width: 1), // spacing column
                            Text(constInventoryText,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: _returnInventoryColor(),
                                    fontWeight: FontWeight.bold,
                                    fontFamily: constAppTextFont,
                                    fontSize: 15.0)),
                          ])),
                      const SizedBox(
                        width: 50,
                      ),
                      GestureDetector(
                        onTap: () {
                          _handleAfflictionsTap();
                        },
                        child: Column(
                          children: [
                            Icon(Icons.healing,
                                size: 30, color: _returnAfflictionsColor()),
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
                      const SizedBox(
                        width: 50,
                      ),
                      GestureDetector(
                        onTap: () {
                          _handleAllocationTap();
                        },
                        child: const Column(
                          children: [
                            Icon(Icons.casino,
                                size: 30, color: Colors.white),
                            SizedBox(width: 1), // spacing column
                            Text(constAllocationsText,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
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
                              _quitGame();
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
