import "package:flutter/material.dart";
import 'dart:math';
import '../main.dart';
import '../const.dart';

class GameOverScreen extends StatelessWidget {
final EnumGameOver gameOverReason;
final int hexesTraveled; 
final int totalPoints; 


const GameOverScreen({super.key, required this.gameOverReason, required this.hexesTraveled, required this.totalPoints});

  String _totalPointsText() {
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

  // main build function
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Stack(
              children: <Widget>[
                Column(
                  children: [
                    AspectRatio(aspectRatio: 1024 / 1536,
                      child: Image.asset(_graphic(), fit: BoxFit.contain)),
                    Expanded(
                      child: Container(
                        color: Colors.black, 
                        width: double.infinity, 
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                           Text(
                              _dialogText(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontFamily: constAppTextFont,
                                  color: Colors.white,
                                  fontSize: 20.0),
                             ),
                            const SizedBox(height: 15),                             
                          Text(
                              _totalPointsText(),
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
                                      constHomeText, 
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
                              )), 
                          ],)),
                      )
                    ],)
              ])));                
   }
}
