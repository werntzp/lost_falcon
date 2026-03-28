import '../const.dart';
import 'package:flutter/material.dart';
import '../models/map_model.dart';

String _displayMessage(MapHex mapHex) {
  String name = "";
  EnumTerrain terrain = mapHex.terrain;
  EnumEncounter encounter = mapHex.encounter;

  // if they had an encounter here, show that, otherwise use terrain message
  if (encounter == EnumEncounter.none) {
    // format the type of unit killed nicely
    if (mapHex.rescue) {
      name = constTerrainRescue;    
    } else if (terrain == EnumTerrain.scrub) {
      name = constTerrainScrub;
    } else if (terrain == EnumTerrain.brush) {
      name = constTerrainBrush;
    } else if (terrain == EnumTerrain.rough) {
      name = constTerrainRough;
    } else if (terrain == EnumTerrain.hills) {
      name = constTerrainHills;
    } else if (terrain == EnumTerrain.village) {
      name = constTerrainVillage;
    } else {
      name = constTerrainUnkown;
    }
  }
  else {
    // else show them something about the encounter
    name = constEncounterTerrainDialogMessage;
    if (encounter == EnumEncounter.apc) {
      name = name.replaceFirst("Z", constApcTerrainDialogText);
    } else if (encounter == EnumEncounter.dust) {
      name = name.replaceFirst("Z", constDustTerrainDialogText);
    } else if (encounter == EnumEncounter.chemicals) {
      name = name.replaceFirst("Z", constChemicalsTerrainDialogText);
    } else if (encounter == EnumEncounter.thorns) {
      name = name.replaceFirst("Z", constThornsTerrainDialogText);      
    } else if (encounter == EnumEncounter.rockslide) {
      name = name.replaceFirst("Z", constRockslideTerrainDialogText);      
    } else if (encounter == EnumEncounter.highground) {
      name = name.replaceFirst("Z", constHighgroundTerrainDialogText);      
    } else if (encounter == EnumEncounter.building) {
      name = name.replaceFirst("Z", constBuildingTerrainDialogText);      
    } else if (encounter == EnumEncounter.road) {
      name = name.replaceFirst("Z", constRoadTerrainDialogText);      
    } else if (encounter == EnumEncounter.soldier) {
      name = name.replaceFirst("Z", constSoldierTerrainDialogText);      
    } else if (encounter == EnumEncounter.snake) {
      name = name.replaceFirst("Z", constSnakeTerrainDialogText);      
    } else if (encounter == EnumEncounter.wolf) {
      name = name.replaceFirst("Z", constWolfTerrainDialogText);      
    } else if (encounter == EnumEncounter.mortar) {
      name = name.replaceFirst("Z", constMortarTerrainDialogText);      
    } else if (encounter == EnumEncounter.helicopter) {
      name = name.replaceFirst("Z", constHelicopterTerrainDialogText);      
    } else if (encounter == EnumEncounter.cave) {
      name = name.replaceFirst("Z", constCaveTerrainDialogText);      
    } else if (encounter == EnumEncounter.gunships) {
      name = name.replaceFirst("Z", constGunshipsTerrainDialogText);      
    } else if (encounter == EnumEncounter.minefield) {
      name = name.replaceFirst("Z", constMinefieldTerrainDialogText);      
    } else if (encounter == EnumEncounter.milepost) {
      name = name.replaceFirst("Z", constMilepostTerrainDialogText);      
    } else if (encounter == EnumEncounter.tributary) {
      name = name.replaceFirst("Z", constTributaryTerrainDialogText);      
    }

  }

  return name;
}

String _displayImage(MapHex mapHex, List<String> visuals) {
  String name = "";
  EnumTerrain terrain = mapHex.terrain;
  EnumEncounter encounter = mapHex.encounter;

  // if they had an encounter here, show that, otherwise use terrain message
  if (encounter == EnumEncounter.none) {
    // format the type of unit killed nicely
    if (mapHex.rescue) {
      name = constImageRescue;
    } else if (terrain == EnumTerrain.scrub) {
      name = constImageScrub;
    } else if (terrain == EnumTerrain.brush) {
      name = constImageBrush;
    } else if (terrain == EnumTerrain.rough) {
      name = constImageRough;
    } else if (terrain == EnumTerrain.hills) {
      name = constImageHills;
    } else if (terrain == EnumTerrain.village) {
      name = constImageVillage;
    } else {
      name = constImageUnknown;
    }
  }
  else { 
    name = visuals[encounter.index];

  }

  return name;
}

void showTerrainInfoDialog(BuildContext context, MapHex mapHex, List<String> visuals) {
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
            child: Image.asset(_displayImage(mapHex, visuals), fit: BoxFit.fill),
          ),
          // Right column: Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_displayMessage(mapHex),
                    style: const TextStyle(
                        fontFamily: constAppTextFont, fontSize: 15)),
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
