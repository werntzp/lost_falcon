import 'package:flutter/material.dart';
import 'const.dart';
import 'screens/game_screen.dart';

void main() {
  runApp(const LostFalconApp());
}

class LostFalconApp extends StatelessWidget {
  const LostFalconApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: appTitle,
      debugShowCheckedModeBanner: false,
      home: LostFalconHome(),
    );
  }
}

class LostFalconHome extends StatelessWidget {
  const LostFalconHome({super.key});

  void _showHelpScreen(context) {
    //Navigator.push(
    //context,
    //MaterialPageRoute(builder: (context) => HelpScreen()),
    //);
  }

  void _showGameScreen(context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GameScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Stack(
      children: <Widget>[
        Image(
          image: const AssetImage(appSplashGraphic),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          fit: BoxFit.cover,
        ),
        const Padding(
          padding: EdgeInsets.all(10.0),
          child: Align(
            alignment: Alignment.topCenter,
            child: Text(
              "  $appTitleWWord1\r\n$appTitleWWord2",
              style: TextStyle(
                  fontFamily: 'LumanosimoRegular',
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 82.0),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Container(
                        decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 3)),
            child: const Image(
              image: AssetImage(sdsLogo),
              width: 75.0,
              height: 75.0,
              fit: BoxFit.cover,
            )),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(30.0),
          child: Align(
            alignment: Alignment.center,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                const SizedBox(
                  height: 575.0,
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
                          "Play",
                          style: TextStyle(
                              fontFamily: 'LumanosimoRegular',
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 30.0),
                        )),
                    onPressed: () {
                      _showGameScreen(context);
                    },
                  ),
                ),
                const SizedBox(
                  height: 5.0,
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
                          "Help",
                          style: TextStyle(
                              fontFamily: 'LumanosimoRegular',
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 30.0),
                        )),
                    onPressed: () {
                      _showHelpScreen(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    )));
  }
}
