const appTitle = "Lost Falcon";
const appTitleWWord1 = "Lost";
const appTitleWWord2 = "Falcon";
const appSplashGraphic = "assets/images/falcon_jet_splash_logo.jpg";
const appVersion = "Version 1.0, February 2026";
const sdsLogo = "assets/images/sds_logo.png";
const constAppTextFont = "Lemonada";

// images
const constImageDie = "assets/images/lf_die_";
const constImageStatus = "assets/images/lf_status_";
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
const constDiceAllocationMessage1 = "You have";
const constDiceAllocationMessage2 = "dice to allocate. Tap once to increment, and long press to decrement.";

const constGameOverHealth = "You died.";
const constGameOverProximity = "You were captured.";
const constGameOverEncounter = "You were killed.";

const constDiceRollMoveMessage1 = "You need to roll a";
const constDiceRollMoveMessage2 = "or higher to move from your current location.";
const constDiceRollMoveMessage3 = "However, if you choose a 6, your Health is reduced by one point.";
const constDiceRollMoveMessage4 = "Moving successfully allows you to re-roll one die during the Stealth phase.";
const constMoveFailedMessage =
    "You failed in the attempt to move from your current location.";
const constNoDiceAllocatedForMoveMessage =
    "You are unable to move this round.";

const constDiceRollStealthMessage1 = "You need to roll a";
const constDiceRollStealthMessage2 = "or higher to remain hidden from your pursuers.";
const constDiceRollStealthMessage3 = "However, if you choose a 6, your Health is reduced by one point.";
const constDiceRollStealthMessage4 = "Since you were successful at moving across the map, you can re-roll one die by double tapping on it.";
const constStealthFailedMessage =
    "You failed in an attempt to keep ahead of your pursuers. Lose one Proximity.";
const constNoDiceAllocatedForStealthMessage =
    "You lost one Proximity as your pursuers gained ground.";

const constDiceRollRestMessage1 = "You need to roll a";
const constDiceRollRestMessage2 = "or higher to successfully rest and improve your Endurance by one.";
const constDiceRollRestMessage3 = "However, if you choose a 6, your Health is reduced by one point.";
const constRestFailedMessage =
    "You were unable to rest and keep up your strength. Lose one Endurance.";
const constNoDiceAllocatedForRestMessage =
    "You lost one Endurance due to fatigue.";

// buttons and labels 
const constMoveText = "Move";
const constStealthText = "Stealth";
const constRestText = "Rest";
const constHealthText = "Health";
const constProximityText = "Proximity";
const constEnduranceText = "Endurance";
const constRoundText = "Round";
const constInventoryText = "Inventory";
const constAfflictionsText = "Afflictions";
const constQuitText = "Quit";
const constContinueText = "Continue";
const constOKText = "OK";

const constMapRows = 5;
const constMapCols = 15;
const constFakeHex = -1;
const constStartRow = 0;
const constStartCol = 0;
const constNoDice = 0; 

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

enum EnumDirection { increment, decrement}

enum EnumGameOver { health, proximity, encounter } 

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
