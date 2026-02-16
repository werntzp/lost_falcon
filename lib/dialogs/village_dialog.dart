import '../const.dart';
import 'package:flutter/material.dart';


void showVillageReactionDialog(BuildContext context, String title, String villageReaction) {

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
            child: Image.asset(constImageVillage, fit: BoxFit.fill),
          ),
          // Right column: Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontFamily: constAppTextFont, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Text(villageReaction,
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
