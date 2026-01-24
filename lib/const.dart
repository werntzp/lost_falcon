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
const constImageEncounters = "assets/images/lf_enc_";

// descriptions
const constTerrainUnkown = "You cannot see what lies ahead here yet.";
const constTerrainScrub =
    "Scrub is easiest for movement and rest, but offers little concealment.";
const constTerrainBrush =
    "Brush is slightly tougher to move through or rest in, but offers some hiding spots.";
const constTerrainRough =
    "Rough terrain is harder to travel through and limits rest, but it does offer better concealment.";
const constTerrainHills =
    "Hills are difficult to cross which hampers movement and rest, but they offer excellent places to hide.";
const constTerrainVillage =
    "Villages can provide sanctuary or bring danger, so think carefully before you enter one.";

// messages
const constDiceAllocationMessage1 = "You have";
const constDiceAllocationMessage2 =
    "dice to allocate. Tap once to increment, and long press to decrement.";

const constGameOverHealth = "You died.";
const constGameOverProximity = "You were captured.";
const constGameOverEncounter = "You were killed.";

const constDiceRollMoveMessage1 = "You need to roll a";
const constDiceRollMoveMessage2 =
    "or higher to move from your current location.";
const constDiceRollMoveMessage3 =
    "However, if you choose a 6, your Health is reduced by one point.";
const constDiceRollMoveMessage4 =
    "Moving successfully allows you to re-roll one die during the Stealth phase.";
const constMoveFailedMessage =
    "You failed in the attempt to move from your current location.";
const constNoDiceAllocatedForMoveMessage = "You are unable to move this round.";

const constDiceRollStealthMessage1 = "You need to roll a";
const constDiceRollStealthMessage2 =
    "or higher to remain hidden from your pursuers.";
const constDiceRollStealthMessage3 =
    "However, if you choose a 6, your Health is reduced by one point.";
const constDiceRollStealthMessage4 =
    "Since you were successful at moving across the map, you can re-roll one die by double tapping on it.";
const constStealthFailedMessage =
    "You failed in an attempt to keep ahead of your pursuers. Lose one Proximity.";
const constNoDiceAllocatedForStealthMessage =
    "You lost one Proximity as your pursuers gained ground.";

const constDiceRollRestMessage1 = "You need to roll a";
const constDiceRollRestMessage2 =
    "or higher to successfully rest and improve your Endurance by one.";
const constDiceRollRestMessage3 =
    "However, if you choose a 6, your Health is reduced by one point.";
const constRestFailedMessage =
    "You were unable to rest and keep up your strength. Lose one Endurance.";
const constNoDiceAllocatedForRestMessage =
    "You lost one Endurance due to fatigue.";
const constMoveSixMessage = "You were successful at moving to a new space, but still lost Health due to some minor injuries.";
const constStealthSixMessage = "You were successful at hiding, but still lost Health due to some minor injuries.";
const constRestSixMessage = "You were successful at keeping up your Endurance, but still lost Health due to some minor injuries.";

// encounters
const constEncountersMessage =
    "Let's see if you had any encounters this round!";
const constDustEncounterMessage =
    "A dust storm kicks up obstructing your view while the strong wind and harsh blowing sand wears you down.";
const constChemicalsEncounterMessage =
    "You have to cross through a field full of chemical munitions which burns and irritates your skin.";
const constThornsEncounterMessage =
    "Your progress has been halted by these half-inch thorns.";
const constRockslideEncounterMessage =
    "As you are climbing, a rockslide carries you down you the hill and you suffer a broken foot in the tumble.";
const constHighgroundEncounterMessage =
    "From this vantage you can see for miles, including a bustling village that may be welcoming.";
const constBuildingEncounterMessage =
    "It appears that this building has been abandoned. The burn marks and bullet holes present this as another casualty of war.";
const constRoadEncounterMessage =
    "A flat stretch of road provides an easier path to move on.";
const constSoldierEncounterMessage =
    "A fallen soldier lies facedown hidden in the brush.";
const constSnakeEncounterMessage =
    "As you trek across the desert, you disturb a sleeping snake. You jerk away but it is too late.";
const constWolfEncounterMessage =
    "A low, menacing growl startles you as a   lunges out.";
const constMortarEncounterMessage =
    "A piercing whistle announces the arrival of mortar rounds falling around you. You can:";
const constMortarOption1 = "Sprint to a new hex, getting wounded, and losing Endurance";
const constMortarOption2 = "Drop into cover, losing Proximity";
const constHelicopterEncounterMessage =
    "You stumble upon a crashed and abandoned Blackhawk that looks like it has been stripped clean.";
const constApcEncounterMessage =
    "The hulk of an armored personnel carrier sits quietly. The insides have been thoroughly stripped.";
const constCaveEncounterMessage =
    "This small cave may have served as a hiding spot for rebel forces before being abandoned.";
const constGunshipsEncounterMessage =
    "Roaring overhead is a flight of attack helicopters intent on ruining someone's day.";
const constMinefieldEncounterMessage = "Mines block your way.";
const constSniperEncounterMessage =
    "You work your way across an open area that gives a perfect field of fire for snipers. A round strikes you in the shoulder.";
const constMilepostEncounterMessage =
    "You come to an intersection that provides several safe looking options to move quickly down.";
const constTributaryEncounterMessage =
    "You come across a stream that provides needed water and is easy to move along.";
const constNoEncounterMessage =
    "Nothing but blue skies and empty desert ahead of you.";

// village actions
const constVillageRobbedItems =
    "You were robbed in the village and lost your items! Move to an adjacent, mapped spot.";
const constVillageRobbedNoItems =
    "The villagers looked pretty threatening, so you decide to leave. Move to an adjacent, mapped spot.";
const constVillageDelayed =
    "The villagers do not harm you, but purposefull slow you down which lets your pursuers get closer. Lose Proximity and Endurance. Move to an adjacent, mapped spot";
const constVillageKickedOut =
    "You are forcibly kicked out of the village and cannot enter here again.";
const constVillageUntrusting =
    "Everyone warily ignores you and lets you pass through. Move to any adjacent spot.";
const constVillagePeaceful =
    "You are offered sanctuary. Gain Endurance and move to an adjacent, mapped spot.";
const constVillageHelpful =
    "A villager gives you an old motorcycle. You gain Proximity and can drive three map spots in any direction before it runs out of gas.";
const constVillageAlliedAfflictions =
    "A doctor in the village heals an affliction before you leave. Gain Health, Proximity, and Endurance. Move to any adjacent spot.";
const constVillageAlliedNoAfflications =
    "A doctor in the village treats you. Gain Health, Proximity, and Endurance. Move to any adjacent spot.";

// afflictions

const constAfflictions = "The following afflictions are impacting you: ";
const constNoAfflictions = "Other than some minor scrapes and bruises, you are in good shape.";
const constAfflictionFever = "a high fever limiting your ability to move, rest, or hide";
const constAfflictionGunShotWound = "a horrible wound dramatically lowering your Health";
const constAfflictionBrokenFoot = "a broken foot hobbling your every step which limits your movement";
const constAfflictionBurn = "a burn which continues to send shocks of pain through you reducing your Endurance";
const constAfflictionDeepCut = "a deep cut straining every moment and eroding your Health";

// inventory
const constInventory = "You have collected the following items: ";
const constNoInventory = "Unfortunately, you have no items or gear to use.";


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
const constDieSides = 6;

const constScrubMoveCost = 2;
const constBrushMoveCost = 3;
const constHillsMoveCost = 5;
const constRoughMoveCost = 4;

const constScrubStealthCost = 4;
const constBrushStealthCost = 4;
const constHillsStealthCost = 3;
const constRoughStealthCost = 3;

const constScrubRestCost = 3;
const constBrushRestCost = 3;
const constHillsRestCost = 5;
const constRoughRestCost = 4;

enum EnumDirection { increment, decrement }

enum EnumGameOver { health, proximity, encounter }

enum EnumPhase { mapping, encounter, allocate, move, stealth, rest }

enum EnumTerrain { scrub, brush, hills, village, rough, rescue, unknown }

enum EnumAffliction { deepcut, burn, brokenfoot, gunshotwound, fever }

enum EnumInventory { ak, machete, firstaidkit, flaregun, binoculars }

enum EnumVillageReactions {
  none,
  robbed,
  delayed,
  kickedout,
  untrusting,
  peaceful,
  helpful,
  allied
}

enum EnumEncounter {
  apc,
  dust,
  chemicals,
  thorns,
  rockslide,
  highground,
  building,
  road,
  soldier,
  snake,
  wolf,
  mortar,
  helicopter,
  cave,
  gunships,
  minefield,
  sniper,
  milepost,
  tributary,
  none
}
