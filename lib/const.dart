const appTitle = "Lost Falcon";
const appTitleWWord1 = "Lost";
const appTitleWWord2 = "Falcon";
const appSplashGraphic = "assets/images/falcon_jet_splash_logo.jpg";
const appVersion = "Version 1.0, February 2026";
const sdsLogo = "assets/images/sds_logo.png";
const constAppTextFont = "Lemonada";

// images
const constAssetsImagesFolder = "assets/images/"; 
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
const constImageBackground = "assets/images/lf_terrain_background.jpg";
const constImageEncounters = "assets/images/lf_enc_";
const constImageRescued = "rescued.jpg";
const constImageCaptured = "captured.jpg";
const constImageKilled = "dead.jpg";

// phases
const constMovePhase = "Move Phase";
const constStealthPhase = "Stealth Phase";
const constRestPhase = "Rest Phase";

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
const constTerrainRescue=
    "United States military forces are patrolling here -- reach them to be rescued!";    

// messages
const constAlreadMovedMessage = "You are not able to move any more this turn";
const constSameHexPickedMessage = "Choose a new spot for movement, or press Continue if you don't want to move this turn";
const constHexTooFarMessage = "You can only move to an adjacent hex";
const constHexImpassableMessage = "You cannot move into an impassable hex";
const constDiceAllocationMessage1 = "You have";
const constDiceAllocationMessage2 =
    "dice to allocate. Tap once to increment, and long press to decrement.";
const constGameOverRescued = "You made it back to friendly forces and have been rescued!";
const constGameOverCaptured = "Unable to escape your pursuers, you now wait in captivity.";
const constGameOverKilled = "Despite your best efforts, you died alone, far from home.";
const constDiceRollMoveMessage1 = "It is not easy navigating across the terrain. In order to keep your bearing and move forward, you must roll a";
const constDiceRollMoveMessage2 =
    "(or higher) to get out of the hex you are currently in.";
const constMoveFailedMessage =
    "You failed in the attempt to move from this hex";
const constNoDiceAllocatedForMoveMessage = "You are unable to move this round";
const constMoveSuccessMessage =
    "Moved successfully to a new hex, and you can now re-roll one die during Stealth phase";
const constDiceRollStealthMessage1 = "Hostile forces are actively looking for you. They will steadily close in on your position unless you roll a"; 
const constDiceRollStealthMessage2 =
    "(or higher) to stay ahead of them.";
const constDiceRollStealthMessage4 =
    " You can re-roll one die by double tapping on it.";
const constStealthFailedMessage =
    "You failed in an attempt to keep ahead of your pursuers and lose 1 Proximity";
const constNoDiceAllocatedForStealthMessage =
    "You lost 1 Proximity as your pursuers gained ground"; 
const constStealthSuccessMessage =
    "Your stealthy movement kept distance between you and your pursuers";
const constDiceRollRestMessage1 = "Endurance is the key to your survival. As it lowers, you lose dice to assign in the Allocation Phase. Rolling a";
const constDiceRollRestMessage2 =
    "(or higher) means you successfully rested and thus raise your Endurance by one.";
const constRestFailedMessage =
    "You were unable to rest to keep up your strength, and lose 1 Endurance";
const constNoDiceAllocatedForRestMessage =
    "You lost 1 Endurance due to fatigue";
const constRestSuccessMessage =
    "You were able to rest successfully";
const constDiceRollPickSix =
    "If you choose the 6, your Health is reduced by one point, or you can decide to fail the roll.";
const constMoveSixMessage = "You were successful at moving, but still lost Health due to some minor injuries";
const constStealthSixMessage = "You were successful at hiding, but still lost Health due to some minor injuries";
const constRestSixMessage = "You were successful at resting, but still lost Health due to some minor injuries";
const constGameOverLost = "You scored X points for traveling through Z hexes";
const constGameOverWon = "You scored X points for traveling through Z hexes and a bonus of your remaining Health, Proximity, and Endurance";

// encounters
const constEncountersMessage =
    "Let's see if you had any encounters this round!";

const constDustEncounterMessage =
    "A dust storm kicks up obstructing your view while the strong wind and harsh blowing sand wears you down.";
const constDustOption1 = "Stumble backward to the previous hex";
const constDustOption2 = "Lose 2 Endurance pushing through";    

const constChemicalsEncounterMessage =
    "You have to cross through a field full of chemical munitions which burns and irritates your skin, resulting in injuries.";

const constThornsEncounterMessage =
    "Your progress has been halted by dense, unpassable heavy brush covered in half-inch thorns.";
const constThornsOption1 = "Give up and move back to the previous hex";
const constThornsOption2 = "Push through but take a deep cut";    
const constThornsOption3 = "Cut a path with your machete skipping Stealth and Rest phases";
const constThornsOption4 = "Cut a path with your machete keeping Stealth and Rest phases";

const constRockslideEncounterMessage =
    "As you are climbing, a rockslide carries you down you the hill and you suffer a broken foot in the tumble.";

const constHighgroundEncounterMessage =
    "From this vantage you can see for miles, including a bustling village that may be welcoming.";

const constBuildingEncounterMessage =
    "It appears that this building has been abandoned. The burn marks and bullet holes present this as another casualty of war.";
const constBuildingOption1 = "Scavenge some materials to make a bandage and gain 2 Health";
const constBuildingOption2 = "Spend some quiet time here to gain 1 Endurance";
const constBuildingOption3 = "Find a usable machete";    

const constRoadEncounterMessage =
    "A flat stretch of road provides an easier path to move on.";
const constRoadOption1 = "Immediately move to an adjacent hex";
const constRoadOption2 = "Increase your Proximity by 1";

const constSoldierEncounterMessage =
    "A fallen soldier lies facedown hidden in the brush.";
const constSoldierOption1 = "Find a working AK-47 with several rounds left in the magazine";
const constSoldierOption2 = "Find a map show the location of a crashed helicopter";

const constSnakeEncounterMessage =
    "As you trek across the desert, you disturb a sleeping snake.";
const constSnakeOption1 = "It strikes quickly, but luckily the bite is just a superficial wound.";
const constSnakeOption2 = "It strikes quickly, and unfortunately the bite brings on a raging fever.";
const constSnakeOption3 = "Before it can bite you, you are able to use your machete and kill it.";

const constWolfEncounterMessage =
    "A low, menacing growl startles you as a wolf lunges out of the twilight.";
const constWolfOption1 = "It kocks you down, but races away leaving you with just a superficial wound.";
const constWolfOption2 = "It knocks you down and tears into you before running off, resulting in a deep cut.";
const constWolfOption3 = "You are able to strike it with your machete and drive it off, but during the scuffle, your machete snaps at the handle.";

const constMortarEncounterMessage =
    "A piercing whistle announces the arrival of mortar rounds falling around you.";
const constMortarOption1 = "Move to a new hex, but get wounded and lose 1 Endurance";
const constMortarOption2 = "Drop into cover, losing 1 Proximity";

const constHelicopterEncounterMessage = 
    "You stumble upon a crashed and abandoned Blackhawk helicopter.";
const constHelicopterOption1 = "Find a working flare gun";
const constHelicopterOption2 = "Use it as shelter to gain 2 Endurance";

const constApcEncounterMessage =
    "The hulk of an armored personnel carrier sits quietly.";
const constApcOption1 = "Find a first aid kit and use it to heal up";
const constApcOption2 = "Use it as a shelter to gain 1 Proximity and Endurance";

const constCaveEncounterMessage =
    "This small cave may have served as a hiding spot for rebel forces before being abandoned.";
const constCaveOption1 = "Find a map showing a source of water";
const constCaveOption2 = "Find a pair of powerful binoculars";

const constGunshipsEncounterMessage =
    "Roaring overhead comes a flight of attack helicopters firing rockets which pin down your pursuers.";
const constGunshipsOption1 = "Use the opportunity to gain 2 Proximity";
const constGunshipsOption2 = "Rest up to gain 2 Health and 1 Endurance";
const constGunshipsOption3 = "Signal your exact position with the flare gun and be rescued";

const constMinefieldEncounterMessage = "A large, well marked minefield block your way.";
const constMinefieldOption1 = "Pass through slowly, losing 1 Prximity";
const constMinefieldOption2 = "Return to your last spot and this hex becomes impassable";

const constSniperEncounterMessage =
    "As you work your way across an open area a high powered sniper round strikes you in the shoulder!";
const constSniperOption1 = "Make a run for it, but take another hit";
const constSniperOption2 = "Fall back into cover and this hex becomes impassable";

const constMilepostEncounterMessage =
    "You come to an intersection that provides several safe looking movement options.";
const constMilepostOption1 = "Terrain ahead becomes favorable";
const constMilepostOption2 = "A village is nearby";
const constMilepostOption3 = "Gain +2 to your next movement roll";

const constTributaryEncounterMessage =
    "You come across a stream that provides needed water and is easy to move along.";
const constTributaryOption1 = "Follow the stream and move again";
const constTributaryOption2 = "A refreshing rest in the water gains 1 Health and Endurance";

const constNoEncounterMessage =
    "Nothing but blue skies and empty desert ahead of you.";

// village actions
const constVillageRobbedItems =
    "You were robbed in the village and lost your items! Move to a new hex.";
const constVillageRobbedNoItems =
    "The villagers looked pretty threatening, so you decide to leave. Move to a new hex.";
const constVillageDelayed =
    "The villagers do not harm you, but purposefull slow you down which lets your pursuers get closer. Lose Proximity and Endurance. Move to a new hex.";
const constVillageKickedOut =
    "You are forcibly kicked out of the village and cannot enter here again.";
const constVillageUntrusting =
    "Everyone in the village warily ignores you and lets you pass through. Move to a new hex.";
const constVillagePeaceful =
    "You are offered sanctuary. Gain Endurance and move to a new hex.";
const constVillageHelpful =
    "A villager gives you an old motorcycle. You gain Proximity and can drive three map spots in any direction before it runs out of gas.";
const constVillageAlliedAfflictions =
    "A doctor in the village heals an affliction before you leave. Gain Health, Proximity, and Endurance. Move to a new hex.";
const constVillageAlliedNoAfflications =
    "A doctor in the village treats you. Gain Health, Proximity, and Endurance. Move to a new hex.";

// afflictions
const constAfflictions = "The following afflictions are impacting you: ";
const constNoAfflictions = "Other than some minor scrapes and bruises, you are in good shape.";
const constAfflictionFever = "a high fever limiting your ability to move, rest, or hide";
const constAfflictionGunShotWound = "a horrible wound dramatically lowering your Health";
const constAfflictionBrokenFoot = "a broken foot hobbling your every step which limits your movement";
const constAfflictionBurn = "a burn which continues to send shocks of pain through you reducing your Endurance";
const constAfflictionDeepCut = "a deep cut that won't stop bleeding and straining your every movement";

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
const constHomeText = "Home";
const constFailText = "Fail";


const constDieFaceRed = "assets/images/dice_face_red_";
const constDieFaceWhite = "assets/images/dice_face_white_";

const constMapRows = 5;
const constMapCols = 15;
const constFakeHex = -1;
const constStartRow = 0;
const constStartCol = 0;
const constNoDice = 0;
const constDieSides = 6;
const constZero = 0; 

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

enum EnumMessageType { success, fail }

enum EnumDirection { increment, decrement }

enum EnumGameOver { rescued, captured, killed }

enum EnumPhase { mapping, encounter, allocate, move, stealth, rest }

enum EnumTerrain { scrub, brush, hills, village, rough, rescue, unknown, background }

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
