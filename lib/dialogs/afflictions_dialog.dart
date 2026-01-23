import 'package:flutter/services.dart';

import '../const.dart';
import 'package:flutter/material.dart';

String _buildMessage(Set<EnumAffliction> afflictions) {
  final message = <String>[];

  // see which afflictions they have, and put those together with
  // descriptions into a message displayed on the dialog 
  if (afflictions.contains(EnumAffliction.brokenfoot)) {
    message.add(constAfflictionBrokenFoot);
  }

  if (afflictions.contains(EnumAffliction.burn)) {
    message.add(constAfflictionBurn);
  }

  if (afflictions.contains(EnumAffliction.deepcut)) {
    message.add(constAfflictionDeepCut);
  }

  if (afflictions.contains(EnumAffliction.fever)) {
    message.add(constAfflictionFever);
  }

  if (afflictions.contains(EnumAffliction.gunshotwound)) {
    message.add(constAfflictionGunShotWound);
  }

  final result = message.join("; ");
  return constAfflictions + result; 

}

void showAfflictionsDialog(BuildContext context, Set<EnumAffliction> afflictions) {
  String message; 

  message = afflictions.isNotEmpty ? _buildMessage(afflictions) : constNoAfflictions;

  showDialog<String>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    builder: (BuildContext context) => AlertDialog(
      backgroundColor: const Color.fromARGB(255, 173, 147, 62),
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Right column: Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message,
                    style:
                        const TextStyle(fontFamily: constAppTextFont, fontSize: 18)),
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
