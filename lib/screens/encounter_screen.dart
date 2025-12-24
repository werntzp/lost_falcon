import 'package:flutter/material.dart';
import 'package:lost_falcon/const.dart';
import "package:shared_preferences/shared_preferences.dart";

// main class
class EncounterScreen extends StatefulWidget {
  const EncounterScreen({super.key});

  @override
  _EncounterScreenState createState() => _EncounterScreenState();
}

class _EncounterScreenState extends State<EncounterScreen> {
  EnumEncounter __encounter = EnumEncounter.none; // Default value

  void _load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? themeString = prefs.getString('app_theme');
    if (themeString != null) {
      setState(() {
        __encounter = EnumEncounter.values.firstWhere(
          (e) => e.toString().split('.').last == themeString,
          orElse: () => EnumEncounter.none, // Fallback if string doesn't match
        );
      });
      setState(() {});
    }
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
  // close
  // ************************
  void _close() {
    // save the move, stealth, and rest points into the prefs object
    SharedPreferences.getInstance().then((prefs) {});
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
            const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Encounter!",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'LumanosimoRegular',
                          fontSize: 30.0)),
                ]),
            const Padding(
              padding: EdgeInsets.all(5.0),
            ),
            const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Encounter!",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'LumanosimoRegular',
                          fontSize: 30.0)),
                ]),
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
