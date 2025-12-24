import 'package:flutter/material.dart';
import 'package:lost_falcon/const.dart';
import "package:shared_preferences/shared_preferences.dart";

// main class
class DieRollScreen extends StatefulWidget {
  const DieRollScreen({super.key});

  @override
  _DieRollScreenState createState() => _DieRollScreenState();
}

class _DieRollScreenState extends State<DieRollScreen> {
  int _dieCount = 0;
  int _successRoll = 0;
  EnumPhase _phase = EnumPhase.allocate;

  void _load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _dieCount = prefs.getInt("die") ?? 0;
    _successRoll = prefs.getInt("success") ?? 1;
    _phase = EnumPhase.values.firstWhere(
      (e) => e.toString().split('.').last == prefs.getString('phase'),
      orElse: () => EnumPhase.move,
    );
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
    // pass back success (or failure) of the roll
    // pass back any penalties if they chose a six
    // TODO
    SharedPreferences.getInstance().then((prefs) {});
    // close
    Navigator.pop(context, "true");
  }

  // ************************
  // resultCard
  // ************************
  Widget _resultCard() {
    return const Card();
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
                  Text("Choose Dice",
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
                  Text(
                      "This is where the explanation goes for why a die roll is needed.",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'LumanosimoRegular',
                          fontSize: 30.0)),
                ]),
            const Padding(
              padding: EdgeInsets.all(5.0),
            ),
            //
            //OutlinedButton(
            //  style: OutlinedButton.styleFrom(backgroundColor: Colors.black45),
            //  onPressed: () {
            //    debugPrint('Received Roll Dice click');
            //  },
            //  child: const Text('Roll Dice',
            //      style: TextStyle(
            //          color: Colors.white,
            //          fontWeight: FontWeight.bold,
            //          fontFamily: 'LumanosimoRegular',
            //          fontSize: 15.0)),
            //),
            //
            const Padding(
              padding: EdgeInsets.all(5.0),
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[_resultCard()]),
            const Padding(
              padding: EdgeInsets.all(5.0),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(backgroundColor: Colors.black45),
              onPressed: () {
                debugPrint('Received Continue click');
              },
              child: const Text('Continue',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'LumanosimoRegular',
                      fontSize: 15.0)),
            ),
          ],
        ),
      ),
    ));
  }
}
