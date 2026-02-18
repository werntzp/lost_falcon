import 'package:lost_falcon/const.dart';
import 'package:lost_falcon/models/inventory_model.dart';
import 'dart:math';

class PilotException implements Exception {
  final EnumGameOver reason;
  final String message;

  PilotException(this.reason, this.message);

  @override
  String toString() => 'DiceException($reason): $message';
}

class Pilot {
  int _health = 6;
  int _proximity = 6;
  int _endurance = 6;
  final Set<InventoryItem> _inventory = {};
  final Set<EnumAffliction> _afflictions = {};

  // ************************
  // constructor
  // ************************
  Pilot() {
    // reset all values
    _health = 6;
    _proximity = 6;
    _endurance = 6;
    // clear and reset inventory 
    _inventory.clear(); 
    _inventory.add(InventoryItem(EnumInventory.ak));
    _inventory.add(InventoryItem(EnumInventory.binoculars));
    _inventory.add(InventoryItem(EnumInventory.firstaidkit));
    _inventory.add(InventoryItem(EnumInventory.flaregun));
    _inventory.add(InventoryItem(EnumInventory.machete));

  }

  // ************************
  // return health
  // ************************
  int getHealth() {
    return _health;
  }

  // ************************
  // set health
  // ************************
  void setHealth(EnumDirection direction) {
    if (direction == EnumDirection.increment) {
      _health++;
      if (_health > 6) {
        _health = 6;
      }
    } else {
      _health--;
      if (_health < 0) {
        _health = 0;
      }
    }
  }

  // ************************
  // return proximity
  // ************************
  int getProximity() {
    return _proximity;
  }

  // ************************
  // set proximity
  // ************************
  void setProximity(EnumDirection direction) {
    if (direction == EnumDirection.increment) {
      _proximity++;
      if (_proximity > 6) {
        _proximity = 6;
      }
    } else {
      _proximity--;
      if (_proximity <= 0) {
        _proximity = 0;
      }
    }
  }

  // ************************
  // return endurance
  // ************************
  int getEndurance() {
    return _endurance;
  }

  // ************************
  // set endurance
  // ************************
  void setEndurance(EnumDirection direction) {
    if (direction == EnumDirection.increment) {
      _endurance++;
      if (_endurance > 6) {
        _endurance = 6;
      }
      // if they have a burn, they can't increase endurance beyond 5
      if ((_afflictions.contains(EnumAffliction.burn)) && (_endurance == 6)) {
        _endurance = 5;
      }
    } else {
      _endurance--;
      if (_endurance <= 0) {
        _endurance = 1;
        // always have one endurance, but if this happens, remove a health
        setHealth(EnumDirection.decrement);
      }
    }
  }

  // ************************
  // return if they have any afflictions
  // ************************
  bool hasAnyAfflictions() {
    return _afflictions.isNotEmpty ? true : false;
  }

  // ************************
  // return whether the pilot has a specific affliction
  // ************************
  bool hasAnAffliction(EnumAffliction affliction) {
    return _afflictions.contains(affliction) ? true : false;
  }

  // ************************
  // set a new affliction
  // ************************
  void setAffliction(EnumAffliction affliction) {
    int hurt = 0;

    // can only have each affliction once, so they get a fever on 2nd
    if (_afflictions.contains(affliction)) {
      _afflictions.add(EnumAffliction.fever);
    } else {
      _afflictions.add(affliction);
      // depending on affliction, do other things
      if (affliction == EnumAffliction.deepcut) {
        setHealth(EnumDirection.decrement);
        setHealth(EnumDirection.decrement);
      } else if (affliction == EnumAffliction.gunshotwound) {
        // decrement health based on how bad wound is
        hurt = Random().nextInt(4) + 1;
        for (int i = 1; i <= hurt; i++) {
          setHealth(EnumDirection.decrement);
        }
      }
    }
  }

  // ************************
  // heal an affliction
  // ************************
  void healAffliction() {

    // if zero return, if only one clear it, otherwise pick a random one
    if (_afflictions.isEmpty) {
      return; 
    }
    else if (_afflictions.length == 1) {
      _afflictions.clear();
    } else {
      EnumAffliction item =
          _afflictions.elementAt(Random().nextInt(_afflictions.length));
      _afflictions.remove(item);
    }
  }

  // ************************
  // list the afflictions in a friendly message
  // ************************
  String describeAfflictions() {
    final message = <String>[];

    if (_afflictions.isNotEmpty) {
      // see which afflictions they have, and put those together with
      // descriptions into a message displayed on the dialog
      if (_afflictions.contains(EnumAffliction.brokenfoot)) {
        message.add(constAfflictionBrokenFoot);
      }

      if (_afflictions.contains(EnumAffliction.burn)) {
        message.add(constAfflictionBurn);
      }

      if (_afflictions.contains(EnumAffliction.deepcut)) {
        message.add(constAfflictionDeepCut);
      }

      if (_afflictions.contains(EnumAffliction.fever)) {
        message.add(constAfflictionFever);
      }

      if (_afflictions.contains(EnumAffliction.gunshotwound)) {
        message.add(constAfflictionGunShotWound);
      }

      final result = message.join("; ");
      return constAfflictions + result;
    } else {
      return constNoAfflictions;
    }
  }

  // ************************
  // get an item
  // ************************
  InventoryItem returnInventoryItem(EnumInventory item) {
    return _inventory.firstWhere((x)=> x.item == item);

  }

  // ************************
  // do they have anything?
  // ************************
  bool hasAnyItems() {
    bool result = false; 

    for (InventoryItem ii in _inventory) {
      if (ii.isCurrentlyHeld) {
        result = true;
        break; 
      }
    }

    return result; 

  }

  // ************************
  // check to see if they have an item 
  // ************************
  bool hasAnItem(EnumInventory item) {
    return _inventory.firstWhere((x)=> x.item == item).isCurrentlyHeld;

  }

  // ************************
  // drop all items
  // ************************
  void dropAllItems() {

    for (InventoryItem ii in _inventory) {
      ii.isCurrentlyHeld = false; 
    }

  }

  // ************************
  // drop a specific item
  // ************************
  void dropOneItem(EnumInventory item) {
    _inventory.firstWhere((x)=> x.item == item).isCurrentlyHeld = false; 

  }

  // ************************
  // add an item
  // ************************
  void pickUpItem(EnumInventory item) {
    late InventoryItem ii; 

    // pick it up and show it as currently held, but only if we've never held it before
    ii = _inventory.firstWhere((x)=> x.item == item); 
    if (!ii.hasEverBeenPickedUp) { 
      ii.hasEverBeenPickedUp = true;
      ii.isCurrentlyHeld = true; 
    } 

  }

  // ************************
  // use an item
  // ************************
  void useItem(EnumInventory item, bool drop) {

    // mark it as used
    _inventory.firstWhere((x)=> x.item == item).hasEverBeenUsed = true;  
    // maybe drop it 
    if (drop) { dropOneItem(item); }
 
  }

}
