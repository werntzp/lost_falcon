import 'package:lost_falcon/const.dart';

class MapHex {
  final int id;
  final int row; // row
  final int col; // col
  bool current = false; // player is here currently
  bool previous = false; // player was here on a previous turn
  EnumTerrain terrain = EnumTerrain.unknown; // terrain type

  MapHex(this.id, this.row, this.col);
}
