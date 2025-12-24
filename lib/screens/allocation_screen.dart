import 'package:flutter/material.dart';
import 'package:lost_falcon/const.dart';
import "package:shared_preferences/shared_preferences.dart";

// main class
class AllocationScreen extends StatefulWidget {
  const AllocationScreen({super.key});

  @override
  _AllocationScreenState createState() => _AllocationScreenState();
}

class _AllocationScreenState extends State<AllocationScreen> {
  int _points = 0;
  int _move = 0;
  int _stealth = 0;
  int _rest = 0;
  String _displayPoints = "0";
  String _displayMove = "0";
  String _displayStealth = "0";
  String _displayRest = "0";

  void _load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      _points = prefs.getInt("endurance") ?? 0;
      _displayPoints = _points.toString();
    });
  }

  // override the init function to see if there's anything custom stored
  @override
  void initState() {
    _load();
    super.initState();
  }

  // release the controller resources
  @override
  void dispose() {
    super.dispose();
  }

  // ************************
  // _incrementMove
  // ************************
  void _incrementMove() {
    // if there are points available, add
    if (_points > 0) {
      setState(() {
        _points--;
        _move++;
        _displayPoints = _points.toString();
        _displayMove = _move.toString();
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
        _points++;
        _move--;
        _displayPoints = _points.toString();
        _displayMove = _move.toString();
      });
    }
  }

  // ************************
  // _incrementStealth
  // ************************
  void _incrementStealth() {
    // if there are points available, add
    if (_points > 0) {
      setState(() {
        _points--;
        _stealth++;
        _displayPoints = _points.toString();
        _displayStealth = _stealth.toString();
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
        _points++;
        _stealth--;
        _displayPoints = _points.toString();
        _displayStealth = _stealth.toString();
      });
    }
  }

  // ************************
  // _incrementRest
  // ************************
  void _incrementRest() {
    // if there are points available, add
    if (_points > 0) {
      setState(() {
        _points--;
        _rest++;
        _displayPoints = _points.toString();
        _displayRest = _rest.toString();
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
        _points++;
        _rest--;
        _displayPoints = _points.toString();
        _displayRest = _rest.toString();
      });
    }
  }

  // ************************
  // close
  // ************************
  void _close() {
    // save the move, stealth, and rest points into the prefs object
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt("move", _move);
      prefs.setInt("stealth", _stealth);
      prefs.setInt("rest", _rest);
    });
    // close
    Navigator.pop(context, "true");
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: null,
      body: Center(
        child: Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(15.0),
            ),
            const Text("Points Available",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'LumanosimoRegular',
                    fontSize: 30.0)),
            Text(_displayPoints,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'LumanosimoRegular',
                    fontSize: 30.0)),
            const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: 12.0,
                  ),
                  Center(
                    child: Text(
                        "More points increase your chances of\r\n"
                        "moving out of your current hex,\r\n"
                        "evading pursuing enemeies,\r\n"
                        "or resting to recover health.\r\n",
                        softWrap: true,
                        style: TextStyle(
                            fontFamily: 'LumanosimoRegular', fontSize: 15.0)),
                  ),
                  SizedBox(
                    width: 12.0,
                  ),
                ]),
            const Padding(
              padding: EdgeInsets.all(12.0),
            ),
            const Text("Move",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'LumanosimoRegular',
                    fontSize: 30.0)),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              GestureDetector(
                onTap: _incrementMove,
                child: const Icon(Icons.add_circle_outlined),
              ),
              const SizedBox(
                width: 12.0,
              ),
              Text(_displayMove,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'LumanosimoRegular',
                      fontSize: 30.0)),
              const SizedBox(
                width: 12.0,
              ),
              GestureDetector(
                onTap: _decrementMove,
                child: const Icon(Icons.remove_circle_outlined),
              ),
            ]),
            const Padding(
              padding: EdgeInsets.all(12.0),
            ),
            const Text("Stealth",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'LumanosimoRegular',
                    fontSize: 30.0)),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              GestureDetector(
                onTap: _incrementStealth,
                child: const Icon(Icons.add_circle_outlined),
              ),
              const SizedBox(
                width: 12.0,
              ),
              Text(_displayStealth,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'LumanosimoRegular',
                      fontSize: 30.0)),
              const SizedBox(
                width: 12.0,
              ),
              GestureDetector(
                onTap: _decrementStealth,
                child: const Icon(Icons.remove_circle_outlined),
              ),
            ]),
            const Padding(
              padding: EdgeInsets.all(12.0),
            ),
            const Text("Rest",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'LumanosimoRegular',
                    fontSize: 30.0)),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              GestureDetector(
                onTap: _incrementRest,
                child: const Icon(Icons.add_circle_outlined),
              ),
              const SizedBox(
                width: 12.0,
              ),
              Text(_displayRest,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'LumanosimoRegular',
                      fontSize: 30.0)),
              const SizedBox(
                width: 12.0,
              ),
              GestureDetector(
                onTap: _decrementRest,
                child: const Icon(Icons.remove_circle_outlined),
              ),
            ]),
            const Padding(
              padding: EdgeInsets.all(25.0),
            ),
            GestureDetector(
              onTap: _close,
              child: const Icon(Icons.check_circle, size: 35.0),
            ),
          ],
        ),
      ),
    ));
  }
}
