class DieResult {
  final int value; // value of the die
  final bool success; // was the die a success
  final bool penaltyForSix; // is there a penalty for rolling a six
  final String penaltyMessage; // message for the penalty

  DieResult(this.value, this.success, this.penaltyForSix, this.penaltyMessage);
}
