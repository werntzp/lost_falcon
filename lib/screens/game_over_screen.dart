import "package:flutter/material.dart";
import 'dart:math';
import '../main.dart';
import '../const.dart';

class GameOverScreen extends StatelessWidget {
final EnumGameOver gameOverReason;


const GameOverScreen({super.key, required this.gameOverReason});

String _dialogText() {

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

String _graphic() {
  int i = Random().nextInt(1) + 1; // return a 1 or 2 
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

  return folder + i.toString() + img; 

}

  // main build function
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Stack(
              children: <Widget>[
                Image(
                  image: AssetImage(_graphic()),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  fit: BoxFit.cover,
                ),              
              Padding(
                padding: const EdgeInsets.all(1.0),
                child: Align(
                  alignment: Alignment.topCenter,
                  child:  Text(
                    _dialogText(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontFamily: constAppTextFont,
                        color: Colors.white,
                        fontSize: 35.0),
                  ),
                ),
              ),
                  const Padding(
                    padding: EdgeInsets.all(15.0),
                  ),
                Positioned(
                  top: 750,
                  left: 125, 
                child: Center(
                  child: SizedBox(
                  width: 160.0,
                  height: 55.0,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black, // Text and icon color
                      backgroundColor: Colors.white, // Background color
                      side: BorderSide(color: Colors.black,   width: 5.0,), // Border color
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
                        onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LostFalconApp()),
                            );
                    },                 
                  ),
                ),
                  )),
              ],)

            ));
  }
}
