import 'package:lost_falcon/const.dart';

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
  bool _hasFever = false;
  bool _hasGunshotWound = false;
  bool _hasBrokenFoot = false;
  bool _hasBurn = false;
  bool _hasDeepCut = false;

  // ************************
  // constructor
  // ************************
  Pilot() {
    // reset all values
    _health = 6;
    _proximity = 6;
    _endurance = 6;
    _hasFever = false;
    _hasGunshotWound = false;
    _hasBrokenFoot = false;
    _hasBurn = false;
    _hasDeepCut = false;
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
      if (_health == 0) {
        throw PilotException(EnumGameOver.health, constGameOverHealth);
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
      if (_proximity == 0) {
        throw PilotException(EnumGameOver.proximity, constGameOverProximity);
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
    } else {
      _endurance--;
      if (_endurance <= 0) {
        _endurance = 1;
        // always have one endurance, but if this that happens, remove a health 
        setHealth(EnumDirection.decrement);
      }
    }
  }

  // ************************
  // return whether the pilot has this affliction
  // ************************
  bool hasAffliction(EnumAffliction affliction) {
    bool result = false;

    if ((affliction == EnumAffliction.fever) && (_hasFever)) {
      result == true;
    } else if ((affliction == EnumAffliction.gunshotwound) &&
        (_hasGunshotWound)) {
      result == true;
    } else if ((affliction == EnumAffliction.brokenfoot) && (_hasBrokenFoot)) {
      result == true;
    } else if ((affliction == EnumAffliction.burn) && (_hasBurn)) {
      result == true;
    } else if ((affliction == EnumAffliction.deepcut) && (_hasDeepCut)) {
      result == true;
    }

    return result;
  }

  // ************************
  // set a new affliction
  // ************************
  void newAffliction(EnumAffliction affliction) {
    if (affliction == EnumAffliction.fever) {
      _hasFever = true;
    } else if (affliction == EnumAffliction.gunshotwound) {
      _hasGunshotWound == true;
    } else if (affliction == EnumAffliction.brokenfoot) {
      _hasBrokenFoot == true;
    } else if (affliction == EnumAffliction.burn) {
      _hasBurn == true;
    } else if (affliction == EnumAffliction.deepcut) {
      _hasDeepCut == true;
    }
  }
}
