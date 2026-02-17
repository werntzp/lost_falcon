import 'package:lost_falcon/const.dart';

class InventoryItem {
  final EnumInventory item;
  bool hasEverBeenPickedUp = false;
  bool isCurrentlyHeld = false; 
  bool hasEverBeenUsed = false;

  InventoryItem(this.item);

}

