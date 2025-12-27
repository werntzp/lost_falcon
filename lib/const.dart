const appTitle = "Lost Falcon";
const appTitleWWord1 = "Lost";
const appTitleWWord2 = "Falcon";
const appSplashGraphic = "assets/images/falcon_jet_splash_logo.jpg";
const appVersion = "Version 1.0, February 2026";
const sdsLogo = "assets/images/sds_logo.png";
const constAppTextFont = "Lemonada";

// images
const constImageDie6 = "assets/images/lf_die_6.png";
const constImageDie5 = "assets/images/lf_die_5.png";
const constImageDie4 = "assets/images/lf_die_4.png";
const constImageDie3 = "assets/images/lf_die_3.png";
const constImageDie2 = "assets/images/lf_die_2.png";
const constImageDie1 = "assets/images/lf_die_1.png";
const constImageDie0 = "assets/images/lf_die_0.png";
const constImageStatus6 = "assets/images/lf_status_6.png";
const constImageStatus5 = "assets/images/lf_status_5.png";
const constImageStatus4 = "assets/images/lf_status_4.png";
const constImageStatus3 = "assets/images/lf_status_3.png";
const constImageStatus2 = "assets/images/lf_status_2.png";
const constImageStatus1 = "assets/images/lf_status_1.png";
const constImageStatus0 = "assets/images/lf_status_0.png";
const constImageScrub = "assets/images/lf_terrain_scrub.jpg";
const constImageBrush = "assets/images/lf_terrain_brush.jpg";
const constImageRough = "assets/images/lf_terrain_rocky.jpg";
const constImageHills = "assets/images/lf_terrain_hills.jpg";
const constImageVillage = "assets/images/lf_terrain_village.jpg";
const constImageScrubGrey = "assets/images/lf_terrain_scrub_grey.jpg";
const constImageBrushGrey = "assets/images/lf_terrain_brush_grey.jpg";
const constImageRoughGrey = "assets/images/lf_terrain_rocky_grey.jpg";
const constImageHillsGrey = "assets/images/lf_terrain_hills_grey.jpg";
const constImageVillageGrey = "assets/images/lf_terrain_village_grey.jpg";
const constImageRescue = "assets/images/lf_rescue.jpg";
const constImagePlayerLocation = "assets/images/lf_american_flag_small.gif";
const constImageUnknown = "assets/images/lf_terrain_unknown.jpg";

// messages
const constNoMovePoints =
    "You are unable to move this phase as you allocated no move points.";
const constMoveFailed =
    "You were unable to move from your current location thus turn.";
const constDiceAllocationMessage1 = "You have";
const constDiceAllocationMessage2 = "dice to allocate. Tap once to increment, and long press to decrement.";
const constDiceRollMoveMessage1 = "You need to roll over a";
const constDiceRollMoveMessage2 = "to move into a new hex.";
const constDiceRollMoveMessage3 = "However, if you choose a 6, your Health is reduced by one point.";
const constDiceRollMoveMessage4 = "Moving out of the hex successfully, allows you to re-roll one die during the Stealth phase.";
const constMoveText = "Move";
const constStealthText = "Stealth";
const constRestText = "Rest";
const constHealthText = "Health";
const constProximityText = "Proximity";
const constEnduranceText = "Endurance";
const constRoundText = "Round";
const constInventoryText = "Inventory";
const constAilmentsText = "Ailments";
const constQuitText = "Quit";
const constContinueText = "Continue";
const constOKText = "OK";

const constMapRows = 5;
const constMapCols = 15;
const constFakeHex = -1;
const constStartRow = 0;
const constStartCol = 0;

const constScrubMoveCost = 2;
const constBrushMoveCost = 3;
const constHillsMoveCost = 5;
const constVillageMoveCost = 1;
const constRoughMoveCost = 4;

const constScrubStealthCost = 4;
const constBrushStealthCost = 4;
const constHillsStealthCost = 3;
const constVillageStealthCost = 7;
const constRoughStealthCost = 3;

const constScrubRestCost = 3;
const constBrushRestCost = 3;
const constHillsRestCost = 5;
const constVillageRestCost = 7;
const constRoughRestCost = 4;

enum EnumPhase { mapping, encounter, allocate, move, stealth, rest }

enum EnumTerrain { scrub, brush, hills, village, rough, rescue, unknown }

enum EnumAffliction { deepcut, burn, brokenfoot, gunshotwound, fever }

enum EnumInventory { ak, machete, firstaidkit, flaregun, binoculars }

enum EnumEncounter {
  dust,
  chemicals,
  thorns,
  eathquake,
  highground,
  building,
  road,
  soldier,
  snake,
  wolf,
  mortar,
  chopper,
  apc,
  cave,
  gunships,
  minefield,
  sniper,
  milepost,
  tributary,
  none
}
