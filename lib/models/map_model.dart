import 'package:lost_falcon/const.dart';

class MapHex {
  final int id;
  final int col; // col
  final int row; // row
  bool current = false; // player is here currently
  bool previous = false; // player was here on a previous turn
  bool visible = false; // player can "see" into this hex from where they are
  EnumTerrain terrain = EnumTerrain.unknown; // terrain type

  MapHex(this.id, this.col, this.row);
}
