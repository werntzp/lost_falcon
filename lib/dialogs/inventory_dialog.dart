import '../const.dart';
import 'package:flutter/material.dart';
import '../models/pilot_model.dart';

void showInventoryDialog(BuildContext context) {

  showDialog<String>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    builder: (BuildContext context) => AlertDialog(
      backgroundColor: const Color.fromARGB(255, 173, 147, 62),
      content: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Right column: Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("message",
                    style:
                        TextStyle(fontFamily: constAppTextFont, fontSize: 18)),
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
