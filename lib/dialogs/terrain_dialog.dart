import '../const.dart';
import 'package:flutter/material.dart';

String _displayMessage(EnumTerrain terrain) {
  String name = "";

  // format the type of unit killed nicely
  if (terrain == EnumTerrain.scrub) {
    name = constTerrainScrub;
  } else if (terrain == EnumTerrain.brush) {
    name = constTerrainBrush;
  } else if (terrain == EnumTerrain.rough) {
    name = constTerrainRough;
  } else if (terrain == EnumTerrain.hills) {
    name = constTerrainHills;
  } else if (terrain == EnumTerrain.village) {
    name = constTerrainVillage;
  } else if (terrain == EnumTerrain.rescue) {
    name = constTerrainRescue;    
  } else {
    name = constTerrainUnkown;
  }

  return name;
}

String _displayImage(EnumTerrain terrain) {
  String name = "";

  // format the type of unit killed nicely
  if (terrain == EnumTerrain.scrub) {
    name = constImageScrub;
  } else if (terrain == EnumTerrain.brush) {
    name = constImageBrush;
  } else if (terrain == EnumTerrain.rough) {
    name = constImageRough;
  } else if (terrain == EnumTerrain.hills) {
    name = constImageHills;
  } else if (terrain == EnumTerrain.village) {
    name = constImageVillage;
  } else if (terrain == EnumTerrain.rescue) {
    name = constImageRescue;    
  } else {
    name = constImageUnknown;
  }

  return name;
}

void showTerrainInfoDialog(BuildContext context, EnumTerrain terrain) {
  showDialog<String>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    builder: (BuildContext context) => AlertDialog(
      backgroundColor: const Color.fromARGB(255, 173, 147, 62),
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column: Image
          Container(
            height: 100,
            width: 100,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black, // Set border color
                width: 1.0, // Set "thin" thickness
              ),
            ),
            child: Image.asset(_displayImage(terrain), fit: BoxFit.fill),
          ),
          // Right column: Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_displayMessage(terrain),
                    style: const TextStyle(
                        fontFamily: constAppTextFont, fontSize: 18)),
              ],
            ),
          ),
        ],
      ),
      actions: [
        SizedBox(
          width: 125.0,
          height: 45.0,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black, // Text and icon color
              backgroundColor: Colors.white, // Background color
              overlayColor: Colors.blueAccent.withValues(), // pressed ripple
              side: const BorderSide(
                color: Colors.black,
                width: 5.0,
              ),
            ),
            child: const Align(
                alignment: Alignment.center,
                child: Text(
                  constOKText,
                  style: TextStyle(
                      fontFamily: constAppTextFont,
                      color: Colors.black,
                      fontSize: 25.0),
                )),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    ),
  );
}
