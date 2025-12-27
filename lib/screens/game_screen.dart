import 'package:flutter/material.dart';
import 'package:hexagon/hexagon.dart';
import 'package:lost_falcon/const.dart';
import '../models/map_model.dart';
import 'dart:math';
import 'dart:async';

int _round = 1;
int _proximity = 6;
int _health = 6;
int _endurance = 6;
int _move = 0;
int _stealth = 0;
int _rest = 0;
int _dice = _endurance; 
int _oldHex = 0;
int _selectedHex = 0;
EnumPhase _phase = EnumPhase.mapping;
EnumEncounter _encounter = EnumEncounter.none;
List<MapHex> _map = [];
bool _moveAllowed = false;
List<int> _hexesTraveled = [];
List<int> _rollingDice = []; 
Timer? _rollTimer; 

// extension used to capitalize the first letter of a word 
extension StringExtension on String {
  String capitalizeFirstLetter() {
    if (isEmpty) {
      return this;
    }
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

bool _overlayShowing = false; 

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  _GameScreenState createState() => _GameScreenState();
}

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
      _overlayShowing = false; 
      setState(() {
        // do nothing 
      });
  }

  // *********************************************
  // display overlay to get dice allocation
  // *********************************************
  Future<void> _diceAllocationOverlay() async {

    _dice = _endurance; 

    _completer = Completer<void>();

    if (_overlayEntry != null) return; // Prevent stacking

    _overlayShowing = true; 
    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Colors.black.withAlpha((0.4*255).toInt()) // adjustable darkness
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
                "$constDiceAllocationMessage1 $_dice $constDiceAllocationMessage2",
                style: const TextStyle(color: Colors.white, fontFamily: constAppTextFont, fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const Padding(
                padding: EdgeInsets.all(10.0),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  GestureDetector(
                    onTap: () { _incrementMove(); },
                    onLongPress: () { _decrementMove(); },
                    child: Row(children: <Widget>[
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
                    ],),
                  ),
                  const SizedBox(height: 5),
                  GestureDetector(
                    onTap: () { _incrementStealth(); },
                    onLongPress: () { _decrementStealth(); },
                    child: Row(children: <Widget>[
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
                    ],),
                  ),
                  const SizedBox(height: 5),
                  GestureDetector(
                    onTap: () { _incrementRest(); },
                    onLongPress: () { _decrementRest(); },
                    child: Row(children: <Widget>[
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
                    ],),
                  ),
                ],),
              const Padding(
                padding: EdgeInsets.all(10.0),
              ),
              SizedBox(
                width: 160.0,
                height: 55.0,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black, // Text and icon color
                    backgroundColor: Colors.white, // Background color
                    overlayColor: Colors.blueAccent.withValues(), // pressed ripple
                    side: const BorderSide(color: Colors.black,   width: 3.0,), // Border color
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
                  onPressed:  () { _closeDiceAllocationOverlay(); },
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
  void _closeDiceRollingOverlay() {

      _overlayEntry?.remove(); 
      _completer?.complete(); 
      _overlayEntry = null; 
      _completer = null; 
      _overlayShowing = false; 

  }

  // *********************************************
  // user selected a die
  // *********************************************
  void _tapDice(int value, int target) async {

    // get rid of the overlay (either way)
    _closeDiceRollingOverlay();

    // if the number on the die is greater than the target, do the move,
    // otherwise give them a failed message 
    if (value >= target) {

      // clear all hexes
      for (MapHex hex in _map) {
        hex.current = false;
      }

      // set this one assuming it isn't same as the old and add it to the list traveled
      if (_selectedHex != _oldHex) {
        _map[_selectedHex].current = true;
        _hexesTraveled.add(_selectedHex);
      }

      // map out next hexes
      _doMappingPhase();

    }
    else {
      await _moveOverlayMessage(constMoveFailedMessage);
    }

    // update ui 
    setState(() {
      _moveAllowed = false; 
    });

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
  List<Widget> _drawDice(int count, int target) {

    // set number of dice based on how many allocated  
    _rollingDice = List.generate(count, (_) => Random().nextInt(6) + 1);

    // set each one    
    return _rollingDice.map((value) {
      return GestureDetector(
        onTap: () {
          _tapDice(value, target);
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

    // Stop the rolling after 1 second
    Future.delayed(const Duration(seconds: 2), () {
      _rollTimer?.cancel();
    });

  }

  // *********************************************
  // display overlay for rolling and choosing dice 
  // *********************************************
  Future<void> _diceRollOverlay(EnumPhase phase, int rollToBeat, int numDice) async {

    _completer = Completer<void>();
    if (_overlayEntry != null) return; // Prevent stacking

    _overlayShowing = true; 
    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Colors.black.withAlpha((0.4*255).toInt()) // adjustable darkness
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
                "$constDiceRollMoveMessage1 $rollToBeat $constDiceRollMoveMessage2 $constDiceRollMoveMessage3 $constDiceRollMoveMessage4",
                style: const TextStyle(color: Colors.white, fontFamily: constAppTextFont, fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const Padding(
                padding: EdgeInsets.all(10.0),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _drawDice(numDice, rollToBeat),
                  )
                ],
              ),
            ],
            ))))]));
  
    Overlay.of(context).insert(_overlayEntry!);

    // start the timer to roll dice 
    _startRolling();

  }

  // *********************************************
  // failed to move overlay
  // *********************************************
  Future<void> _moveOverlayMessage(String message) async {

    _completer = Completer<void>();
    if (_overlayEntry != null) return; // Prevent stacking

    _overlayShowing = true;
    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Align(alignment: Alignment.center,
            child: Card(
              elevation: 8.0,              
              color: Colors.black,
              child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                message,
                style: const TextStyle(fontFamily: constAppTextFont, fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center))))]));

    Overlay.of(context).insert(_overlayEntry!);

    // Remove after 1 second
    Future.delayed(const Duration(seconds: 2), () {
      _overlayEntry?.remove(); 
      _completer?.complete(); 
      _overlayEntry = null; 
      _completer = null; 
      _overlayShowing = false;
    });

    await _completer!.future; 

  }

  // ************************
  // _incrementMove
  // ************************
  void _incrementMove() {
    // if there are points available, add
    if (_dice > 0) {
      setState(() {
        _dice--;
        _move++;
        _overlayEntry?.markNeedsBuild();
      });
    }
  }

  // ************************
  // _decrementMove
  // ************************
  void _decrementMove() {
    // if there are any move points assigned, remove
    if (_move > 0) {
      setState(() {
        _dice++;
        _move--;
        _overlayEntry?.markNeedsBuild();
      });
    }
  }

  // ************************
  // _incrementStealth
  // ************************
  void _incrementStealth() {
    // if there are points available, add
    if (_dice > 0) {
      setState(() {
        _dice--;
        _stealth++;
        _overlayEntry?.markNeedsBuild();
      });
    }
  }

  // ************************
  // _decrementStealth
  // ************************
  void _decrementStealth() {
    // if there are stealth points assigned, remove
    if (_stealth > 0) {
      setState(() {
        _dice++;
        _stealth--;
        _overlayEntry?.markNeedsBuild();
      });
    }
  }

  // ************************
  // _incrementRest
  // ************************
  void _incrementRest() {
    // if there are points available, add
    if (_dice > 0) {
      setState(() {
        _dice--;
        _rest++;
        _overlayEntry?.markNeedsBuild();
      });
    }
  }

  // ************************
  // _decrementRest
  // ************************
  void _decrementRest() {
    // if there are any rest points assigned, remove
    if (_rest > 0) {
      setState(() {
        _dice++;
        _rest--;
        _overlayEntry?.markNeedsBuild();
      });
    }
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
    _round = 1;
    _proximity = 6;
    _health = 6;
    _endurance = 6;
    _move = 0;
    _stealth = 0;
    _rest = 0;
    _phase = EnumPhase.allocate;

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
  String _displayRound() {
    return _round.toString();
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
  // _ uttonPress
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
        _round++;
      });
    }

    // if mapping phase, populate next three hexes
    if (_phase == EnumPhase.mapping) {
      _doMappingPhase();
    }

    // if encounter phase, decide if they had an encounter
    if (_phase == EnumPhase.encounter) {
      _doEncounterPhase();
    }

    // if allocate phase, bring up allocation dialog
    if (_phase == EnumPhase.allocate) {
      // send the number of dice available to allocate
      await _diceAllocationOverlay(); 
    }

    // if move phase, see if they a re able to move out of the current hex based on die/point allocation
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
    return 1.0; 

    /*
    int id = _getIdFromColRow(col, row);
    // if they've traveled through a hex, give it more padding
    if (_hexesTraveled.contains(id)) {
      return 5.0;
    } else {
      return 1.0;
    }
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
    _oldHex = h.id;
    // get the id of the hex they selected
    _selectedHex = _getIdFromColRow(col, row);

    // if this is move phase, do all the logic
    if ((_phase == EnumPhase.move) && (_moveAllowed)) {
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

      // if they have dice assigned to move, bring up the overlay to pick from the die roll
      if (_move > 0) {
        // bring up overlay 
        await _diceRollOverlay(EnumPhase.move, moveCost, _move);
      } else {
        await _moveOverlayMessage(constNoDiceAllocatedForMoveMessage);
      }
    }
  }
 
  // ************************
  void _showMapHexInfo(int row, int col) {
    // show pop-up with terrain info or anything else
    debugPrint("_showMapHexInfo long press");
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
            child: Image.asset(constImagePlayerLocation, fit: BoxFit.cover))
          );
    }
    // else if player traveled through hex, show person icon
    else if (_hexesTraveled.contains(id)) {
      return const Positioned(
        top: 25,
        left: 32, 
        child: Icon(Icons.directions_run, color: Colors.black, size: 50)
          );      
    }
    // else, just an empty container
    else {
      return Container(); 
    }
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
                    style: TextStyle(fontFamily: constAppTextFont, fontSize: 50)),
                  const Padding(padding: EdgeInsets.all(0.0),),
                  Center(
                    child: RichText(
                      textAlign: TextAlign.center, 
                      text: TextSpan(
                        children: [
                          const TextSpan(text: constRoundText,
                              style: TextStyle(fontFamily: constAppTextFont, fontSize: 19, color: Colors.black),              
                          ),
                          const TextSpan(
                            text: ' ',
                            style: TextStyle(fontFamily: constAppTextFont, fontSize: 19, color: Colors.black),
                          ),                
                          TextSpan(
                            text: _displayRound(),
                            style: const TextStyle(fontFamily: constAppTextFont, fontSize: 19, color: Colors.black),
                          ),
                          const TextSpan(
                            text: ' - ',
                            style: TextStyle(fontFamily: constAppTextFont, fontSize: 19, color: Colors.black),
                          ),                
                          TextSpan(text: _displayPhase(false),
                              style: const TextStyle(fontFamily: constAppTextFont, fontSize: 19, color: Colors.black),              
                          ),
                      ],
                      ),
                    ),
                  ),
                  Expanded(child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: HexagonOffsetGrid.evenFlat(
                      color: const Color.fromARGB(255, 173, 147, 62),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 10.0),
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
                              debugPrint("row: $row.toString(), col: $col.toString()");
                              // do something if we're in the move phase
                              if (_phase == EnumPhase.move) {
                                _selectMapHex(row, col);
                              }
                            },
                            onLongPress: () {
                              _showMapHexInfo(row, col);
                            },
                            child: Stack(
                                children: [
                                  AspectRatio(
                                  aspectRatio: HexagonType.FLAT.ratio,
                                  child: Image.asset(
                                    _getMapHexGraphic(row, col),
                                    fit: BoxFit.cover,
                                  )),
                                  _showMapHexExtras(row, col), 
                                ]
                            ),
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
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.hiking, size: 30, color: Colors.black),
                      SizedBox(width: 1), // spacing column
                      Text(constInventoryText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: constAppTextFont,
                              fontSize: 15.0)),
                      SizedBox(width: 25), // middle spacing column
                      Icon(Icons.healing, size: 30, color: Colors.black),
                      SizedBox(width: 1), // spacing column                        
                      Text(constAilmentsText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                                fontWeight: FontWeight.bold,
                              fontFamily: constAppTextFont,
                              fontSize: 15.0)),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                  ),                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                  Column(
                    children: [SizedBox(
                    width: 160.0,
                    height: 55.0,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black, // Text and icon color
                        backgroundColor: Colors.white, // Background color
                        overlayColor: Colors.blueAccent.withValues(), // pressed ripple
                        side: const BorderSide(color: Colors.black,   width: 3.0,), // Border color
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
                      onPressed:  () {
                        _continueButtonPress(); 
                      },  
                    ),
                  )]),
                    const SizedBox(
                      width: 15.0,
                      height: 5.0),
                    Column(
                      children: [SizedBox(
                      width: 160.0,
                      height: 55.0,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black, // Text and icon color
                          backgroundColor: Colors.white, // Background color
                          overlayColor: Colors.blueAccent.withValues(), // pressed ripple
                          side: const BorderSide(color: Colors.black,   width: 3.0,), // Border color
                        ),   
                        child: const Align(
                            alignment: Alignment.center,
                            child: Text(
                              constQuitText,
                              style: const TextStyle(
                                  fontFamily: constAppTextFont,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0),
                            )),
                        onPressed:  () {
                          // TBD
                        },  
                      ),
                    )]),
                  ],
 
                     
                  ),
                    const Padding(
                    padding: EdgeInsets.all(12.0),
                  ),
                ])));
  }
}
