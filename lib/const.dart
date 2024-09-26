const appTitle = "Lost Falcon";
const appTitleWWord1 = "Lost";
const appTitleWWord2 = "Falcon";
const appSplashGraphic = "images/falcon_jet_splash_logo.jpg";
const appVersion = "Version 1.0, January 2025";
const sdsLogo = "images/sds_logo.png";

const constImageScrub = "images/lf_scrub_transparent.gif";
const constImageBrush = "images/lf_brush_transparent.gif";
const constImageRough = "images/lf_rough_transparent.gif";
const constImageHills = "images/lf_hills_transparent.gif";
const constImageVillage = "images/lf_village_transparent.gif";
const constImageWaves = "images/lf_waves_transparent.gif";
const constImageRescue = "images/lf_american_flag_transparent.gif";
const constImagePlayerLocation = "images/lf_player_location_transparent.gif";
const constImageUnknown = "images/lf_unknown_transparent.gif";

const constMapRows = 5;
const constMapCols = 15;

enum EnumTerrain { scrub, brush, hills, village, rough, river, rescue, unknown }

enum EnumAfflictions { deepcut, burn, brokenfoot, gunshotwound, fever }

enum Inventory { ak, machete, firstaidkit, flaregun, binoculars }
