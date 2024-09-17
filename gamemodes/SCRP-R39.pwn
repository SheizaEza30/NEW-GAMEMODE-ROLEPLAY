/*

								 _____                 _ _   _____                   _          ____________ 
								/  ___|               | | | /  __ \                 | |         | ___ \ ___ \
								\ `--. _ __ ___   __ _| | | | /  \/ ___  _   _ _ __ | |_ _   _  | |_/ / |_/ /
								 `--. \ '_ ` _ \ / _` | | | | |    / _ \| | | | '_ \| __| | | | |    /|  __/ 
								/\__/ / | | | | | (_| | | | | \__/\ (_) | |_| | | | | |_| |_| | | |\ \| |    
								\____/|_| |_| |_|\__,_|_|_|  \____/\___/ \__,_|_| |_|\__|\__, | \_| \_\_|    
								                                                          __/ |              
								                                                         |___/
	                                                      By: donsta3000/Foster               

*/
//==============================================================================
//          -- > Includes
//==============================================================================
#include <a_samp>
#include <zcmd>
#include <a_mysql>
#include <sscanf2>
#include <foreach>
#include <streamer>
#include <easyDialog>
#include <lookup>
#include <YSI\y_hooks>

#include "/modules/server/defines.pwn"


//==============================================================================
//          -- > Enums
//==============================================================================

enum acc
{
	SQLID,
	Name[32],
	Status,
	Admin,
	RegisterIP[16],
	LatestIP[16]
};

enum pinfo
{
	ID,
 	Username[32],
	Tutorial,
	Level,
	XP,
	Cash,
	Admin,
	AdminDuty,
	Skin,
	Float:PosX,
	Float:PosY,
	Float:PosZ,
	VWorld,
	Interior,
	Age,
	Gender,
	Kicks,
	Muted,
	Faction,
	Rank,
	Job,
	House,
	Business_1,
	Business_2,
	Float:Health,
	Float:Armour,
	bEntered,
	hEntered,
	TotalVehicles,
	Bank,
	Dealership,
	RegisterIP[16],
	LatestIP[16],
	NewID,
	NewVehicle,
	ExemptIP,
    TotalTimePlayed,
    OnlinePeriod,
    IsSpec,
    QuizProgress,
    ClothesSelection,
    Payday,
    LastOnline,
    DrivingTest,
    DeleteingObject,
    TruckingCompleted,
    TruckCoolDown,
    InHospital,
    MovableObject,
    FactionOffer,
    Cuffed,
    Spawn,
    Jail,
    PNC,
    Weapons[104],
    Duty,
    Uniform
};




enum vehicle
{
	SQLID,
	Model,
	Float:PosX,
	Float:PosY,
	Float:PosZ,
	Float:PosA,
	Color1,
	Color2,
	Type,
	Plate[11],
	Owner,
	Fuel,
	Float:Damage,
	Locked,
	Faction,
	Rank,
	FuelTimer,
	Radio,
	RadioStatus,
	RadioURL[128],
	Nitrous,
	Hydraulics,
	Wheels,
	vPanels,
	vDoors,
	vLights,
	vTires,
	Broken,
	Hotwired
};


enum faction
{
	SQLID,
	Name[64],
	Type,
	Rank1[32],
	Rank2[32],
	Rank3[32],
	Rank4[32],
	Rank5[32],
	Rank6[32],
	Rank7[32],
	Rank8[32],
	Rank9[32],
	Rank10[32],
	CommandRank,
	MaxRank,
	VaultRank,
	Vault,
	Float:PosX,
	Float:PosY,
	Float:PosZ
};


enum icon
{
	SQLID,
	Name[32],
	Float:PosX,
	Float:PosY,
	Float:PosZ,
	Interior,
	World,
	Type,
	Faction,
	Text3D:LabelID,
	PickupID,
	Icon
};

enum object
{
	SQLID,
	ObjectID,
	Name[32],
	Model,
	Float:PosX,
	Float:PosY,
	Float:PosZ,
	Float:AngX,
	Float:AngY,
	Float:AngZ,
	World,
	Interior,
	Movable,
	Float:NewX,
	Float:NewY,
	Float:NewZ,
	Float:aNewX,
	Float:aNewY,
	Float:aNewZ,
	Faction
};

enum truck
{
	TruckID,
	RouteID,
	CheckpointID,
	SectionID,
	TimeTaken,
	Capacity,
	Boxes
};

enum taxijob
{
	Duty,
	Driver,
	Offering,
	Passanger,
	Fare,
	Meter,
	Timer
};

/*enum postmanjob
{
	InProgress,
	HouseID,
	VehicleID,
	TimeTaken
};*/


enum driving
{
	DrivingTest,
	GDL,
	CDL,
	MDL
};



enum ems
{
	Service,
	Incident[128],
	Location[64]
};



enum inv
{
    PhoneNumber,
    PhoneStatus,
    PhoneCaller,
    PhoneEmergency,
    VehicleRadio,
    Radio,
    RadioFreq,
    Screwdriver
};



native WP_Hash(buffer[], len, const str[]);


//==========================================================================
//	Server/Player Variables												  //
//==========================================================================

new Character[MAX_PLAYERS][pinfo];
new Account[MAX_PLAYERS][acc];
new Inventory[MAX_PLAYERS][inv];

new OOCStatus = 0;

new Weapon[MAX_PLAYERS][13];
new WeaponAmmo[MAX_PLAYERS][13];

new SkinSelection[MAX_PLAYERS] = 0;
new bool: LoggedIn[MAX_PLAYERS];

//==========================================================================


//==========================================================================
//	Side-Jobs															  //
//==========================================================================
new Trucking[MAX_PLAYERS][truck];
new Taxi[MAX_PLAYERS][taxijob];
//new Postman[MAX_PLAYERS][postmanjob];
new GDL_Test[MAX_PLAYERS];
new DMV[MAX_PLAYERS][driving];
//==========================================================================


//==========================================================================
//	Vehicles															  //
//==========================================================================
new Vehicles[MAX_VEH][vehicle], Total_Vehicles_Created, Total_FactionVehicles_Created;
new Engine[MAX_VEH], Lights[MAX_VEH], alarm[MAX_VEH], doors[MAX_VEH], bonnet[MAX_VEH], boot[MAX_VEH], objective[MAX_VEH];
new bool:validvehicle[MAX_VEH];
//==========================================================================


//==========================================================================
//	Factions															  //
//==========================================================================
new Factions[MAX_FACTIONS][faction], Total_Factions_Created, facid[MAX_PLAYERS];

new EmergencyCall[MAX_PLAYERS][ems];
new EmergencyLights[MAX_VEH];
new EmergencyState[MAX_VEH];
//==========================================================================


//==========================================================================
//	Icons & Objects  													  //
//==========================================================================
new IconID;
new Icons[MAX_ICONS][icon], Total_Icons_Created;
new Objects[MAX_OBJECTZ][object], Total_Objects_Created;
//==========================================================================


//==========================================================================
//	Server Clock 														  //
//==========================================================================
new Text:Clock;
new ClockHours;
new ClockMinutes;
new ClockSeconds;
//==========================================================================


//==========================================================================
//	UI  																  //
//==========================================================================
new Text:BlackScreen[MAX_PLAYERS];
new Text:BlackOutText[MAX_PLAYERS];

new InformationBoxTimer[MAX_PLAYERS];
new Text:InfoBox[MAX_PLAYERS];

new Text:SpeedBox[MAX_PLAYERS];
new Speedo[MAX_PLAYERS];
//==========================================================================


//==========================================================================
//	Optimisations														  //
//==========================================================================
new bool:PickedUpPickup[MAX_PLAYERS];
new LastPickup[MAX_PLAYERS];
new LastCommandTime[MAX_PLAYERS];
//==========================================================================

//==========================================================================
//	Dealership  														  //
//==========================================================================
new VehicleModel[MAX_PLAYERS];
new VehiclePrice[MAX_PLAYERS];
//==========================================================================


//==========================================================================
//	AFK Check   														  //
//==========================================================================
new InactivtyCheck[MAX_PLAYERS];
new Float:InactivtyCheck_X[MAX_PLAYERS];
new Float:InactivtyCheck_Y[MAX_PLAYERS];
new Float:InactivtyCheck_Z[MAX_PLAYERS];
//==========================================================================

//==============================================================================
//          -- > Gamemode Includes
//==============================================================================	

#include "/modules/server/connection.pwn"
#include "/modules/server/load_settings.pwn"
#include "/modules/server/features/login_music.pwn"

#include "modules/business/functions.pwn"
#include "modules/houses/functions.pwn"

#include "modules/player/connect/cameras.pwn"
#include "modules/player/connect/banning.pwn"
//#include "modules/player/connect/cameras.pwn"
#include "modules/player/animations.pwn"
//==============================================================================




//new LastQuestion;
//==========================================================================
new LetterList[26][] =
{
    "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"
};



new MaleSkins[][] =
{
    1, 2, 3, 4, 5, 6, 7, 14, 15, 17, 101, 136, 142,
	170, 184, 186, 185, 188, 234, 250, 37, 38, 36, 59,
	60, 72, 95, 98, 29, 217, 223, 240, 242, 299, 297, 296

};

new FemaleSkins[][] =
{
    9, 10, 12, 13, 31, 39, 40, 41, 53, 54, 55, 56,
    65, 69, 76, 77, 88, 89, 90, 91, 92, 93, 131, 141,
    148, 150, 151, 157, 169, 172, 190, 191, 192, 193, 211
};

new JobNames[][] =
{
	"Jobless",
	"Taxi Driver",
	"Mechanic"
};

new AdminNames[][] =
{
	"None",
	"Trial Administrator",
	"Junior Administrator",
	"Administrator",
	"Senior Administrator",
	"Head Administrator",
	"Server Owner"
};


new FactionTypeName[][] =
{
	"None",
	"Gang",
	"Law Enforcement",
	"News Agency",
	"Fire/Medical Service"
};


new Mod_Hydraulics[][] =
{
// {componentid, price, name}
   {1087, 5000, "Hydraulics"}
};

new Mod_NOS[][] =
{
// {componentid, price, name}
   {1009, 1000, "NOS x2"},
   {1008, 3000, "NOS x5"},
   {1010, 7000, "NOS x10"}
};

new Mod_Wheels[][] =
{
// {componentid, price, name}
   {1073, 5000, "Shadow"},
   {1074, 5000, "Mega"},
   {1075, 5000, "Rimshine"}, 
   {1076, 5000, "Wires"}, 
   {1077, 5000, "Classic"}, 
   {1078, 5000, "Twist"}, 
   {1079, 5000, "Cutter"}, 
   {1080, 5000, "Switch"},
   {1081, 5000, "Grove"}, 
   {1082, 5000, "Import"}, 
   {1083, 5000, "Dollar"},
   {1084, 5000, "Trance"}, 
   {1085, 5000, "Atomic"} 
};



new DealershipData_Normal[47][2] =
{
   // {model, price}
   {400, 40000}, //Landstalker
   {401, 36000}, //Bravura
   {402, 125000}, //Buffalo
   {404, 18000}, //Perenial
   {410, 14500}, //Manana
   {412, 40000}, //VooDoo
   {418, 20000}, //Moonbeam
   {419, 54000}, //Esperanto
   {422, 48000}, //Bobcat
   {436, 35000}, //Previon
   {445, 60000}, //Admiral
   {458, 60000}, //Solair
   {466, 38000}, //Glendale
   {467, 50500}, //Oceanic
   {474, 48000}, //Hermes
   {475, 56000}, //Sabre
   {478, 20000}, //Walton
   {479, 40000}, //Regina
   {482, 54000}, //Burrito
   {489, 52000}, //Rancher
   {491, 46500}, //Virgo
   {492, 46000}, //Greenwood
   {496, 42000}, //BlistaC
   {500, 54000}, //Mesa
   {516, 38000}, //Nebula
   {517, 40500}, //Majestic
   {518, 42000}, //Buccaneer
   {526, 39500}, //Fortune
   {527, 28500}, //Cadrona
   {529, 50000}, //Willard
   {534, 66000}, //Remington
   {536, 54000}, //Blade
   {542, 19000}, //Clover
   {543, 30000}, //Sadler
   {546, 45500}, //Intruder
   {547, 44500}, //Primo
   {549, 19500}, //Tampa
   {551, 44000}, //Merit
   {554, 58000}, //Yosemite
   {566, 48000}, //Tahoma
   {567, 50000}, //Savanna
   {576, 36000}, //Tornado
   {579, 70000}, //Huntley
   {585, 80000}, //Emperor
   {589, 63000}, //Club
   {600, 44000}, //Picador
   {602, 60500} //Alpha
};



new Float:GDL_ROUTE[24][3] =
{
	{-210.467, 1195.7174, 19.4595},
	{-198.157, 1113.3500, 19.4677},
	{-115.366, 1084.1632, 19.5979},
	{-110.706, 1048.7262, 19.7140},
	{-78.069, 1037.6333, 19.5920},
	{-62.850, 1182.1318, 19.4212},
	{105.639, 1195.5851, 18.1282},
	{174.943, 1144.1349, 14.1144},
	{218.735, 981.2390, 28.1376},
	{786.517, 1124.2362, 28.3065},
	{792.041, 1154.4191, 29.0965},
	{624.403, 1154.6246, 13.2717},
	{511.965, 1124.8113, 14.2078},
	{616.817, 1152.7097, 13.2844},
	{704.345, 1152.0806, 17.0540},
	{710.259, 1112.9852, 27.6219},
	{236.969, 977.4380, 28.0700},
	{159.151, 910.4887, 21.5284},
	{-122.473, 826.9639, 20.3922},
	{-285.019, 803.9043, 14.7534},
	{-209.487, 874.9276, 10.2070},
	{-188.159, 1083.7526, 19.4621},
	{-261.280, 1100.4268, 19.4663},
	{-261.2219, 1211.4304, 19.5240}
};

new Float:NoobSpawns[][3] =
{
	{-204.5245, 1119.2860, 19.7422}
};

new Float:JailSpawns[][3] =
{
	{742.2824, -1406.2723, 3001.0859},// Jail01
	{741.9931, -1402.5006, 3001.0859},// Jail02
	{741.9655, -1398.4995, 3001.0859}// Jail03
};

new Float:TruckCheckpoints[11][3] =
{
	{404.8743, 2453.1125, 17.5161},
	{1037.5325, 2130.1348, 10.5475}, // Truck_Warehouse
	{1499.8726, 2108.6675, 10.5474}, // Truck_Stadium
	{2790.5161, 1975.6687, 10.5474}, // Truck_GeneralStore
	{313.6451, -238.0031, 1.3047}, // Truck_BBWarehouse
	{-37.4684, -223.1257, 5.1568}, // Truck_BBTruck
	{-379.0875, -1402.5735, 24.7965}, // Truck_FlintRange
	{-2262.1399, 2300.7214, 4.4451}, //Bayside Dock
	{-1503.0349, 2531.7246, 55.3123}, //El Quebardos Medical
	{-1328.3145, 2677.3943, 49.6874}, // EQ Gas
	{-300.6160, 2663.4534, 62.3581} // Perker's FeednSeed
};

new DealershipData_Commercial[16][3] =
{
   // {model, price, capacity}
   {403, 165000, 0}, //Linerunner
   {413, 26000, 10}, //Pony
   {414, 58000, 20}, //Mule
   {422, 22000, 8}, //Bobcat
   {413, 240000, 40}, //Securicar
   {455, 220000, 60}, //FlatBed
   {440, 20000, 13}, //Rumpo
   {456, 70000, 25}, //Yankee
   {459, 34000, 10}, //Topfun Van
   {478, 16000, 7}, //Walton
   {482, 40000, 13}, //Burrito
   {498, 46000, 16}, //Boxville
   {499, 50000, 17}, //Benson
   {514, 210000, 0}, //Tanker
   {543, 20000, 8}, //Sadler
   {554, 37000, 12} //Yosemite
};
new VehicleNames[][] =
{
    "Landstalker", "Bravura", "Buffalo", "Linerunner", "Perrenial", "Sentinel",
    "Dumper", "Firetruck", "Trashmaster", "Stretch", "Manana", "Infernus",
    "Voodoo", "Pony", "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam",
    "Esperanto", "Taxi", "Washington", "Bobcat", "Whoopee", "BF Injection",
    "Hunter", "Premier", "Enforcer", "Securicar", "Banshee", "Predator", "Bus",
    "Rhino", "Barracks", "Hotknife", "Trailer", "Previon", "Coach", "Cabbie",
    "Stallion", "Rumpo", "RC Bandit", "Romero", "Packer", "Monster", "Admiral",
    "Squalo", "Seasparrow", "Pizzaboy", "Tram", "Trailer", "Turismo", "Speeder",
    "Reefer", "Tropic", "Flatbed", "Yankee", "Caddy", "Solair", "Berkley's RC Van",
    "Skimmer", "PCJ-600", "Faggio", "Freeway", "RC Baron", "RC Raider", "Glendale",
    "Oceanic","Sanchez", "Sparrow", "Patriot", "Quad", "Coastguard", "Dinghy",
    "Hermes", "Sabre", "Rustler", "ZR-350", "Walton", "Regina", "Comet", "BMX",
    "Burrito", "Camper", "Marquis", "Baggage", "Dozer", "Maverick", "News Chopper",
    "Rancher", "FBI Rancher", "Virgo", "Greenwood", "Jetmax", "Hotring", "Sandking",
    "Blista Compact", "Police Maverick", "Boxville", "Benson", "Mesa", "RC Goblin",
    "Hotring Racer A", "Hotring Racer B", "Bloodring Banger", "Rancher", "Super GT",
    "Elegant", "Journey", "Bike", "Mountain Bike", "Beagle", "Cropduster", "Stunt",
    "Tanker", "Roadtrain", "Nebula", "Majestic", "Buccaneer", "Shamal", "Hydra",
    "FCR-900", "NRG-500", "HPV1000", "Cement Truck", "Tow Truck", "Fortune",
    "Cadrona", "FBI Truck", "Willard", "Forklift", "Tractor", "Combine", "Feltzer",
    "Remington", "Slamvan", "Blade", "Freight", "Streak", "Vortex", "Vincent",
    "Bullet", "Clover", "Sadler", "Firetruck", "Hustler", "Intruder", "Primo",
    "Cargobob", "Tampa", "Sunrise", "Merit", "Utility", "Nevada", "Yosemite",
    "Windsor", "Monster", "Monster", "Uranus", "Jester", "Sultan", "Stratium",
    "Elegy", "Raindance", "RC Tiger", "Flash", "Tahoma", "Savanna", "Bandito",
    "Freight Flat", "Streak Carriage", "Kart", "Mower", "Dune", "Sweeper",
    "Broadway", "Tornado", "AT-400", "DFT-30", "Huntley", "Stafford", "BF-400",
    "News Van", "Tug", "Trailer", "Emperor", "Wayfarer", "Euros", "Hotdog", "Club",
    "Freight Box", "Trailer", "Andromada", "Dodo", "RC Cam", "Launch", "LSPD Cruiser",
    "SFPD Cruiser", "LVPD Cruiser", "Police Ranger", "Picador", "S.W.A.T", "Alpha",
    "Phoenix", "Glendale", "Sadler", "Luggage", "Luggage", "Stairs", "Boxville",
    "Tiller", "Utility Trailer"
};

new WeaponNameList[][] =
{
    "Unarmed" "Fist", "BrassKnuckles" "KnuckleDuster", "GolfClub", "NightStick", "Knife", "BaseballBat",
    "Shovel", "PoolCue", "Katana", "Chainsaw", "PurpleDildo", "BigWhiteVibrator",
    "MedWhiteVibrator", "SmlWhiteVibrator", "Flowers", "Cane", "Grenade", "Teargas",
    "Molotov", "None1", "None2", "None3",  "Colt45" "9mm", "SDPistol" "Silenced9mm",
    "DesertEagle", "Shotgun", "SawnoffShotgun", "Spas12", "Mac10" "UZI",
    "MP5", "AK47", "M4", "Tec9", "CountryRifle", "Sniper", "RPG",
    "HeatRPG", "Flamethrower", "Minigun", "Satchel", "Detonator",
    "SprayCan", "Extinguisher", "Camera", "NVGoggles", "IRGoggles",
    "Parachute"
};

new Float:BusinessInteriorPos[][] =
{
    { -25.7114, -187.821, 1003.5469 },
    { 315.2440, -140.885, 999.60160 },
    { 386.5259, 173.6381, 1008.3828 },
    { 961.9308, -51.9071, 1001.1172 },
	{ 161.4048, -94.2416, 1001.8047 },
	{ 378.0260, -190.515, 1000.6328 },
	{ 296.9199, -108.071, 1001.5156 },
	{ 833.2697, 10.58841, 1004.1796 },
	{ -103.559, -24.2256, 1000.7187 },
	{ -2240.46, 137.0604, 1035.4140 },
	{ 663.8362, -575.605, 16.343263 },
	{ 207.7379, -109.019, 1005.1328 },
	{ 204.3329, -166.694, 1000.5234 },
	{ 493.3909, -22.7227, 1000.6796 },
	{ 501.9809, -69.1501, 998.75781 },
	{ -227.020, 1401.220, 27.760000 },
	{ 457.3047, -88.4284, 999.55468 },
	{ 454.9739, -110.104, 1000.0772 },
	{ 375.9624, -65.8168, 1001.5078 },
	{ 369.5795, -4.48720, 1001.8588 }
};

new BusinessInteriors[][][32] =
{
    { 1, "Convenience Store", 17 },
    { 2, "Ammunation", 	 7 },
    { 3, "News Agency", 3 },
    { 4, " Betting Shop", 3} ,
	{ 5, "Clothes Shop(Zip)", 18 },
	{ 6, "Doughnut Place", 17 },
	{ 2, "Ammunation 3", 6 },
	{ 4, "Off Track Betting", 3 },
	{ 7, "Sex Shop",  3 },
	{ 8, "Electronic Shop", 6 },
	{ 1, "Gas Station", 0 },
	{ 5, "Binco",  15 },
	{ 5, "Didier Sachs", 14 },
	{ 9, "Club", 17 },
	{ 9, "Bar", 11 },
	{ 9, "Lil Prob Inn", 18 },
	{ 6, "Jay's' Diner", 4 },
	{ 6, "Grant Diner", 5 },
	{ 10, "Burger Shot", 10 },
	{ 10, "Cluckin' Bell", 9 }
};

new BusinessTypeNames[][] = 
{
	"None",
	"General Store",
	"Ammunation",
	"News",
	"Betting",
	"Clothes",
	"Doughnut",
	"Sex",
	"Electronic Store",
	"Club",
	"Fast Food"
};



new Float:HouseInteriorCoords[][] =
{
	{ -33.6552, 1564.2339, 1080.2109 },
	{ 5.2788, 1612.1793,   1084.3750 },
	{ 18.3167, 1566.3641,  1084.4297 },
	{ -33.0208, 1614.3723, 1084.4297 },
	{ 62.3589, 1557.1005,  1083.8662 },
	{ 59.8227, 1612.7520,  1083.8594 },
	{ 106.9103, 1561.0291, 1084.4375 },
	{ 109.5615, 1620.7977, 1084.3047 },
	{ 146.0323, 1562.4762, 1082.1406 },
	{ 151.6272, 1623.3051, 1081.8254 },
	{ 198.2629, 1624.6292, 1080.9965 },
	{ 217.3181, 1555.3815, 1084.0154 },
	{ 264.7508, 1625.2355, 1083.8828 },
	{ 275.7429, 1559.3079, 1080.2578 },
	
	{ 2260.268798, -1136.082885, 1050.632812},
	{ 2269.389404, -1210.436767, 1047.562500},
	{ 2365.161865,-1135.018554,1050.875},
	{ 2237.725097,-1080.449096,1049.023437},
	{ 2308.842529,-1211.722167,1049.023437},
	{ 2283.092529,-1139.795166,1050.898437},
	{ 2317.780273,-1025.810302,1050.217773},
	{ 244.125152,304.773101,999.148437},
	{ 2324.419921,-1145.568359,1050.710083},
	{ 1298.597900, -796.083007, 1084.0},
	{ 2332.923828, -1076.169433, 1049.023437},
	{ 385.8040,1471.7699,1080.1875},
	{ 375.9720,1417.2699,1081.3281},
	{ 328.0446,1478.8771,1084.4375},
	{ 446.8716,1397.5302,1084.3047},
	{ 227.7230,1114.3899,1080.9922},
	{ 261.1731,1285.9613,1080.2578},
	{ 140.3826,1368.5656,1083.8632},
	{ -42.3809,1407.2510,1084.4297},
	{ 83.2081,1323.7213,1083.8594},
	{ 260.9420,1238.5099,1084.2578}
};

new HouseInteriorInfo[][][32] =
{
	{ "Robada", 			3 },
	{ "Bayside Yellow", 	2 },
	{ "Small Outer",		1 },
	{ "Med Robada", 		7 },
	{ "2 Floor Lade", 	   15 },
	{ "Bayside Large Stairs", 15 },
	{ "Shite Hole", 	   15 },
	{ "Granny Wallpaper",   8 },
	{ "Small Flat Green",   9 },
	{ "Dark Blue House",   10 },
	{ "vLarge 2 floor",     3 },
	{ "Large Lade",         8 },
	{ "Med Stripe Wall",    1 },
	{ "Unknown",            1 },
	
	{ "House 1", 10},
	{ "House 2", 10},
	{ "House 3", 8},
	{ "House 4", 2},
	{ "House 5", 6},
	{ "House 6", 11},
	{ "House 7", 9},
	{ "House 8", 1},
	{ "House 9", 12},
	{ "House 10", 5},
	{ "House 11", 6},
	{ "House 19", 15},
	{ "House 20", 15},
	{ "House 21", 15},
	{ "House 22", 2},
	{ "House 23", 5},
	{ "House 24", 4},
	{ "House 25", 5},
	{ "House 26", 8},
	{ "House 27", 9},
	{ "House 28", 9}
};

//==============================================================================
main()
{
	print("------------------------------------------------------------------------------");
	print("|                       Small County Roleplay - Started!						|");
	print("------------------------------------------------------------------------------");
}

public OnGameModeExit()
{

	mysql_close(SQL_CONNECTION);
	return 1;
}

public OnGameModeInit()
{
    MySQLConnect();
    SetGameModeText("NOT CONNECTED");
    ManualVehicleEngineAndLights();
    ShowPlayerMarkers(0);
	EnableStuntBonusForAll(0);
	DisableInteriorEnterExits();
	
    //==========================================================================
    //      -- > Loads
    //==========================================================================
    
	mysql_tquery(SQL_CONNECTION, "SELECT * FROM `Settings` LIMIT 1", "LoadSettings");

    Fetch_Houses();

    Fetch_Businesses();

	mysql_tquery(SQL_CONNECTION, "SELECT * FROM `Objects`", "LoadObjects");

	mysql_tquery(SQL_CONNECTION, "SELECT * FROM `Icons` ORDER BY SQLID ASC", "LoadIcons");

	mysql_tquery(SQL_CONNECTION, "SELECT * FROM `ServerVehicles` ORDER BY SQLID ASC", "LoadVehicles");

	mysql_tquery(SQL_CONNECTION, "SELECT * FROM `FactionVehicles` ORDER BY SQLID ASC", "LoadFactionVehicles");

	mysql_tquery(SQL_CONNECTION, "SELECT * FROM `Factions` ORDER BY SQLID ASC", "LoadFactions");

    //==========================================================================
    //SetTimer("UpdateTime", 60000, 1);
    SetTimer("UpdateTime", SECONDS(1), 1);
    gettime(ClockHours, ClockMinutes);
    printf("%d:%02d:%02d", ClockHours, ClockMinutes, ClockSeconds);
    SetWorldTime(ClockHours);
    CreateClock();

    SendRconCommand("loadfs Mapping");
    AddPlayerClass(1, -318.6522, 1049.3909, 20.3403, 358.4333, 0, 0, 0, 0, 0, 0);
    //==========================================================================
    for(new i = 0; i < MAX_PLAYERS; i++)
	{
		InfoBox[i] = TextDrawCreate(323.000030, 363.377899, "Testing");
		TextDrawLetterSize(InfoBox[i], 0.309000, 1.417481);
		TextDrawTextSize(InfoBox[i], -114.333312, 300.325866);
		TextDrawAlignment(InfoBox[i], 2);
		TextDrawColor(InfoBox[i], -1);
		TextDrawUseBox(InfoBox[i], true);
		TextDrawBoxColor(InfoBox[i], 51);
		TextDrawSetShadow(InfoBox[i], 0);
		TextDrawSetOutline(InfoBox[i], -1);
		TextDrawBackgroundColor(InfoBox[i], 255);
		TextDrawFont(InfoBox[i], 1);
		TextDrawSetProportional(InfoBox[i], 1);

//,323.000030, 370,
		SpeedBox[i] = TextDrawCreate(550, 370, "MPH:");
		TextDrawLetterSize(SpeedBox[i], 0.309000, 1.417481);
		TextDrawTextSize(SpeedBox[i], -114.333312, 100);
		TextDrawAlignment(SpeedBox[i], 2);
		TextDrawColor(SpeedBox[i], -1);
		TextDrawUseBox(SpeedBox[i], false);
		TextDrawBoxColor(SpeedBox[i], 51);
		TextDrawSetShadow(SpeedBox[i], 0);
		TextDrawSetOutline(SpeedBox[i], -1);
		TextDrawBackgroundColor(SpeedBox[i], 255);
		TextDrawFont(SpeedBox[i], 2);
		TextDrawSetProportional(SpeedBox[i], 1);

		AnimText[i] = TextDrawCreate(610.0, 400.0,
		"~r~~k~~PED_LOCK_TARGET~ ~w~to stop the animation");
		TextDrawUseBox(AnimText[i], 0);
		TextDrawFont(AnimText[i], 2);
		TextDrawSetShadow(AnimText[i],0); 
	    TextDrawSetOutline(AnimText[i],1);
	    TextDrawBackgroundColor(AnimText[i],0x000000FF);
	    TextDrawColor(AnimText[i],0xFFFFFFFF);
	    TextDrawAlignment(AnimText[i],3);


		BlackScreen[i] = TextDrawCreate(644.000000, 0.000000, "                                                                                                                                ");
		TextDrawBackgroundColor(BlackScreen[i], 255);
		TextDrawFont(BlackScreen[i], 1);
		TextDrawLetterSize(BlackScreen[i], 0.500000, 1.000000);
		TextDrawColor(BlackScreen[i], -1);
		TextDrawSetOutline(BlackScreen[i], 0);
		TextDrawSetProportional(BlackScreen[i], 1);
		TextDrawSetShadow(BlackScreen[i], 1);
		TextDrawUseBox(BlackScreen[i], 1);
		TextDrawBoxColor(BlackScreen[i], 255);
		TextDrawTextSize(BlackScreen[i], -11.000000, 0.000000);
		//192

		BlackOutText[i] = TextDrawCreate(10.000000, 192.000000, "You have been knocked unconscious!");
		TextDrawBackgroundColor(BlackOutText[i], -1);
		TextDrawFont(BlackOutText[i], 2);
		TextDrawLetterSize(BlackOutText[i], 0.760000, 2.000000);
		TextDrawColor(BlackOutText[i], -16776961);
		TextDrawSetOutline(BlackOutText[i], 0);
		TextDrawSetProportional(BlackOutText[i], 1);
		TextDrawSetShadow(BlackOutText[i], 0);

	}
	return 1;
}



public OnLookupComplete(playerid)
{
	if(IsProxyUser(playerid))
	{
		new str[128];
		format(str, sizeof(str), "%s's connection has been rejected. (VPN/Proxy)", GetName(playerid));
		KickPlayer(playerid);
		SendAdminsMessage(1, COLOR_INDIANRED, str);
	}
}


public OnPlayerConnect(playerid)
{
    new str[196];
    Account_Reset(playerid);
    Character_Reset(playerid);
	NameCheck(playerid);

    format(str, 128, "%s has joined the server", GetName(playerid));
    SendAdminsMessage(1, COLOR_GRAY, str);

	TogglePlayerSpectating(playerid, 1);
	SetPlayerColor(playerid, COLOR_WHITE);

	SetTimerEx("PlayerConnected", 100, false, "d", playerid);
}


new LoginAttempts[MAX_PLAYERS] = 0;



forward PlayerConnected(playerid);
public PlayerConnected(playerid)
{
	if(IsPlayerConnected(playerid))
	{
		new str[128], query[400];
		format(str, sizeof(str), "%s [%s]", Server[Name], Server[Version]);
		SendClientMessage(playerid, COLOR_ORANGE, str);
		format(str, 128, "Welcome to the server, %s.", GetName(playerid));
	    SendClientMessage(playerid, COLOR_WHITE, str);
		
		Login_Camera(playerid);

	    InfoBoxForPlayer(playerid, "== ~y~[Small County Roleplay]~w~ ==~n~Welcome to Small County Roleplay!");

	    LoggedIn[playerid] = false;
	    LoginAttempts[playerid] = 0;

		mysql_format(SQL_CONNECTION, query, sizeof(query), "SELECT NULL FROM `Accounts` WHERE Username = '%e' LIMIT 1", GetName(playerid));
		mysql_tquery(SQL_CONNECTION, query, "Handle_Account", "i", playerid);
	}

	return 1;
}


Login_Dialog(playerid)
{
    new str[128];
    format(str, sizeof(str), "{FFFFFF}Hello, %s!\n\nWelcome back to {D69929}Small County RP{FFFFFF}.\nPlease login with your existing password below.", GetName(playerid));
    Dialog_Show(playerid, LOGIN, DIALOG_STYLE_PASSWORD, "Small County Roleplay | Login", str, "Login", "Leave");
    return 1;
}

Register_Dialog(playerid)
{
    new str[128];
    format(str, sizeof(str), "{FFFFFF}Hello, %s!\n\nWelcome to {D69929}Small County RP{FFFFFF}.\nThis username isn't registered, thus you will register it now!\n\nEnter your desired password:", GetName(playerid));
    Dialog_Show(playerid, REGISTER, DIALOG_STYLE_PASSWORD, "Small County Roleplay | Register", str,"Register","Leave");
    return 1;
}


forward Handle_Account(playerid);
public Handle_Account(playerid)
{
    if(cache_num_rows())
    {
        Login_Dialog(playerid);
    }
    else
    {
        Register_Dialog(playerid);
    }
    return 1;
}

Dialog:LOGIN(playerid, response, listitem, inputtext[])
{
	if(!response){ SendClientMessage(playerid, COLOR_RED, "You have left the server."); KickPlayer(playerid);}
    if(response)
    {
        new query[256], escapepass[129];
        WP_Hash(escapepass, sizeof(escapepass), inputtext);

		mysql_format(SQL_CONNECTION, query, sizeof(query), "SELECT SQLID, Status, Admin FROM Accounts WHERE Username = '%e' AND Password = '%e' LIMIT 1", GetName(playerid), escapepass);
    	mysql_tquery(SQL_CONNECTION, query, "Login", "i", playerid);

	}
    return 1;
}


forward Login(playerid);
public Login(playerid)
{
    if(cache_num_rows())
    {
        Account[playerid][SQLID] = cache_get_field_content_int(0, "SQLID", SQL_CONNECTION);
        Account[playerid][Status] = cache_get_field_content_int(0, "Status", SQL_CONNECTION);
        Account[playerid][Admin] = cache_get_field_content_int(0, "Admin", SQL_CONNECTION);
        format(Account[playerid][Name], 32, "%s", GetName(playerid));

        printf("%s: Logged in.", Account[playerid][Name]);

        //Log_IP(playerid, ACCOUNT_LOGIN);

        Characters_Fetch(playerid);
    }
    else // Login
    {
        if(LoginAttempts[playerid] < 2)
        {
            Login_Dialog(playerid);
            //Log_IP(playerid, FAILED_ACCOUNT_LOGIN);

            SendClientMessage(playerid, COLOR_ORANGERED, "Incorrect Password.");
            LoginAttempts[playerid] ++;
        }
        else
        {
            SendClientMessage(playerid, COLOR_RED, "Too many failed login attempts.");
            KickPlayer(playerid);
        }
    }
    return 1;
}

forward Characters_Fetch(playerid);
public Characters_Fetch(playerid)
{
    new query[128];
    mysql_format(SQL_CONNECTION, query, sizeof(query), "SELECT ID, Name, Level FROM Characters WHERE A_ID = %d LIMIT 3", Account[playerid][SQLID]);
    mysql_tquery(SQL_CONNECTION, query, "Characters_Menu", "i", playerid);
    return 1;
}

forward Characters_Menu(playerid);
public Characters_Menu(playerid)
{
    new str[64], dialog[512], C_ID, C_Name[24], C_LVL;

    format(str, sizeof(str), "C_ID\tCharacter Name\tLevel\n");
    strcat(dialog, str, sizeof(dialog));

    for( new id = 0; id < cache_num_rows(); id++)
    {
        C_ID = cache_get_field_content_int(id, "ID", SQL_CONNECTION);
        cache_get_field_content(id, "Name", C_Name, SQL_CONNECTION, 24);
        C_LVL = cache_get_field_content_int(id, "Level", SQL_CONNECTION);

        format(str, sizeof(str), "[%d] \t%s\t%d\n", C_ID, C_Name, C_LVL);
        strcat(dialog, str, sizeof(dialog));
    }

    if(cache_num_rows() < 3) 
    {
        format(str, sizeof(str), " \tCreate Character\t\n");
        strcat(dialog, str, sizeof(dialog));
    }

    format(str, sizeof(str), "%s's Characters", Account[playerid][Name]);
    Dialog_Show(playerid, Character_Select, DIALOG_STYLE_TABLIST_HEADERS, str, dialog, "Select","Leave");

    return 1;
}

Dialog:Character_Select(playerid, response, listitem, inputtext[])
{
    if(!response){ SendClientMessage(playerid, COLOR_RED, "You have left the server."); KickPlayer(playerid);}
    if(response)
    {
        new C_ID[6];
        strmid(C_ID, inputtext, strfind(inputtext, "[") + 1,  strfind(inputtext, "]"));
        printf("%d",strval(C_ID));//continue onto character selection (maybe tutorial in brackets)
        Character_Fetch(playerid, strval(C_ID));
    }
    return 1;
}


forward Character_Fetch(playerid, id);
public Character_Fetch(playerid, id)
{
    new query[128];
    if(id)
    {
	    Character[playerid][ID] = id;
	    mysql_format(SQL_CONNECTION, query, sizeof(query), "SELECT * FROM Characters WHERE ID = %d LIMIT 1", id);
	    mysql_tquery(SQL_CONNECTION, query, "Character_Load", "i", playerid);	
    }
    else
    {
    	Character_Create(playerid);
    }
    return 1;
}

Character_Create(playerid)
{
	Dialog_Show(playerid, CREATECHARACTER, DIALOG_STYLE_INPUT, "Character Creation", "Please enter your new character's (roleplay)name, it must include the underscore('_'):", "Create","Cancel");
	return 1;
}


Dialog:REGISTER(playerid, response, listitem, inputtext[])
{
	if(strlen(inputtext) < 6 || strlen(inputtext) > 24)
    {
        SendClientMessage(playerid, COLOR_ORANGERED, "You must insert a password between 6-24 characters!");
        Register_Dialog(playerid);
    }
    else if(strlen(inputtext) > 5 && strlen(inputtext) < 24)
    {
        new query[400],escapepass[129];
        
        WP_Hash(escapepass, sizeof(escapepass), inputtext);

		GetPlayerIp(playerid, Character[playerid][RegisterIP], 16);

    	mysql_format(SQL_CONNECTION, query, sizeof(query), "INSERT INTO Accounts (Username, Password, RegisterIP, RegisterDate) VALUES('%e','%e','%e', %d)", GetName(playerid), escapepass, Character[playerid][RegisterIP], gettime());
		mysql_tquery(SQL_CONNECTION, query, "GetAccID", "i", playerid);
		
        Quiz(playerid, 1);
	}
    return 1;
}

forward GetAccID(playerid);
public GetAccID(playerid)
{
	Account[playerid][SQLID] = cache_insert_id();
	return 1;
}

forward GetCharacterID(playerid);
public GetCharacterID(playerid)
{
	Character[playerid][ID] = cache_insert_id();
	return 1;
}



public OnPlayerDisconnect(playerid, reason)
{
	KillTimer(InactivtyCheck[playerid]);
	StopAudioStreamForPlayer(playerid);

	FailDrivingTest(playerid, "You logged out.");
	EndTruckingMission(playerid, "You logged out.");

	if(Character[playerid][ClothesSelection] == 0 || Character[playerid][InHospital] == 0)
	{
    	GetPlayerPos(playerid, Character[playerid][PosX], Character[playerid][PosY], Character[playerid][PosZ]);
    }
	GetPlayerHealth(playerid, Character[playerid][Health]);
	GetPlayerArmour(playerid, Character[playerid][Armour]);
	Character_Save(playerid);
	LoggedIn[playerid] = false;
	Character_Vehicles_Unload(playerid);
    new pName[24], str[128];
    GetPlayerName(playerid, pName, 24);

    switch(reason)
        {
            case 0: format(str, 128, "%s has left. (Timeout)", pName);
            case 1: format(str, 128, "%s has left. (Leaving)", pName);
            case 2: format(str, 128, "%s has left. (Kicked)", pName);
        }
    SendAdminsMessage(1, COLOR_GRAY, str);
	return 1;
}

forward FixKick(playerid);
public FixKick(playerid)
{
	Kick(playerid);
	return 1;
}


stock Log(playerid, string[])
{
	new File:logfile, logentry[255], time[3], date[3], datestr[11], filepath[48];
	gettime(time[0], time[1], time[2]);
    getdate(date[0], date[1], date[2]);
	format(logentry, sizeof logentry, "[%02d:%02d:%02d] %s(%d): %s\r\n", time[0], time[1], time[2], GetName(playerid), playerid, string);
    format(datestr, sizeof datestr, "%02d-%02d-%d", date[2], date[1], date[0]);
    format(filepath, sizeof filepath, LOG_PATH, datestr);
    logfile = fopen(filepath, io_append);

    if(logfile)
    {
        fwrite(logfile, logentry);
        fclose(logfile);
    }
	return 1;
}


CMD:changeaccountpassword(playerid,params[])
{
	new password[64], escapepass[129];
	if(sscanf(params, "s[32]", password)) return SendClientMessage(playerid, COLOR_GRAY, "/changeaccountpassword [New Password]");
	{
		if(strlen(password) > 5 && strlen(password) < 24)
		{
			WP_Hash(escapepass, sizeof(escapepass), password);
			MYSQL_Update_String(Account[playerid][SQLID], "Accounts", "Password", escapepass);


			SendClientMessage(playerid, COLOR_LGREEN, "You have successfully changed your password, keep it safe.");
		}
	    else
	    {
	    	SendErrorMessage(playerid, "Your password needs longer than 5 characters but less than 24!");
	    }
	}	
	return 1;
}


CMD:achangeapassword(playerid,params[])
{
	new name[32],password[64], query[260], escapepass[129];
	if(Account[playerid][Admin] >= 6)
	{
		if(sscanf(params, "s[32]s[32]", name, password)) return SendClientMessage(playerid, COLOR_GRAY, "/achangeapassword [Master Account Name] [New Password]");
		{
			if(strlen(password) > 5 && strlen(password) < 24)
			{
				WP_Hash(escapepass, sizeof(escapepass), password);
			    mysql_format(SQL_CONNECTION, query, sizeof(query), "UPDATE Accounts SET Password = '%e' WHERE Username = '%e' LIMIT 1", escapepass, name);
				mysql_tquery(SQL_CONNECTION, query);
				SendClientMessage(playerid, COLOR_LGREEN, "You have successfully changed the account's password, keep it safe.");
			}
		    else
		    {
		    	SendErrorMessage(playerid, "Your password needs longer than 5 characters but less than 24!");
		    }
		}	
	}
	else
	{
		SendErrorMessage(playerid, ERROR_ADMIN);
	}
	return 1;
}


CMD:changecname(playerid,params[])
{
	
	if(Account[playerid][Admin] >= 6)
	{
		new player, NewName[64];
		if(sscanf(params, "us[32]", player, NewName)) return SendClientMessage(playerid, COLOR_GRAY, "/changecname [playerid] [New Name]");
		{
			MYSQL_Update_String(Character[player][ID], "Characters", "Name", NewName);
			SetPlayerName(player, NewName);
			SendClientMessage(playerid, COLOR_LGREEN, "You have successfully changed the character's name.");

		}	
	}
	else
	{
		SendErrorMessage(playerid, ERROR_ADMIN);
	}
	return 1;
}


CMD:logout(playerid,params[])
{
	new str[128];
	if(LoopAnim[playerid]) 
    {
        LoopAnim[playerid] = 0;
        TextDrawHideForPlayer(playerid,AnimText[playerid]);
	}

	GetPlayerPos(playerid, Character[playerid][PosX], Character[playerid][PosY], Character[playerid][PosZ]);
	KillTimer(InactivtyCheck[playerid]);

	FailDrivingTest(playerid, "You logged out.");
	EndTruckingMission(playerid, "You logged out.");

	format(str, sizeof(str), "%s has logged out.", GetRoleplayName(playerid));
	SendLocalMessage(playerid, str, Range_Normal, COLOR_GRAY, COLOR_GRAY);
	SendAdminsMessage(1, COLOR_GRAY, str);

	Character_Save(playerid);
	Character_Vehicles_Unload(playerid);

	LoggedIn[playerid] = false;
	SetPlayerName(playerid, Account[playerid][Name]);

	Login_Camera(playerid);
	Character_Reset(playerid);
	Characters_Fetch(playerid);
	return 1;
}			





public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{

	return 1;
}

forward CloseInfo(playerid);
public CloseInfo(playerid)
{
	TextDrawHideForPlayer(playerid, InfoBox[playerid]);
	return 1;
}

forward HideSpeedo(playerid);
public HideSpeedo(playerid)
{
	TextDrawHideForPlayer(playerid, SpeedBox[playerid]);
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
    if (newstate == PLAYER_STATE_DRIVER)
    {
		new vid = GetPlayerVehicleID(playerid), model = GetVehicleModel(vid), str[128];
		format(str, sizeof(str), "~w~%s", VehicleNames[model-400]);
		GameTextForPlayer(playerid,str,3000,1);
		Speedo[playerid] = SetTimerEx("UpdateVehicleSpeedo", 500, true, "i", playerid);

		if(Vehicles[vid][Faction] > 0)
		{
			format(str, sizeof(str), "Faction Vehicle:\t | \t %s \t | \tRank: %d", Factions[GetFactionIDFromSQLID(Vehicles[vid][Faction])][Name], Vehicles[vid][Rank]);
			SendClientMessage(playerid, COLOR_GRAY, str);
		}
		else if(Vehicles[vid][Type] == 4)
		{
			SendClientMessage(playerid, COLOR_GRAY, "| Department of Motor Vehicles | Instruction Vehicle |");
		}
		else if(Vehicles[vid][Type] == 5)
		{
			if(Trucking[playerid][TimeTaken] == 0)
			{
				GameTextForPlayer(playerid, "~b~National Trucking Co.~n~~n~ ~y~To do the trucking mission with this vehicle use the command~p~ /starttrucking~y~.", 6000, 3);
				SendClientMessage(playerid, COLOR_GRAY, "| National Trucking Co. | Company Delivery Vehicle |");
			}
			else
			{
				SendClientMessage(playerid, COLOR_GRAY, "| National Trucking Co. | You are currently doing a trucking mission, please proceed to the way-point. |");
			}
		}
		else if(Vehicles[vid][Type] == 6)
		{
			SendClientMessage(playerid, COLOR_GRAY, "This vehicle can be hotwired (/hotwire), if you have the correct tools.");
		}
		SetPlayerArmedWeapon(playerid,0);
	}
	if (newstate == PLAYER_STATE_ONFOOT)
	{
		for(new i; i < MAX_PLAYERS; i++)
		{
		    if(IsPlayerConnected(i) && Character[i][IsSpec] == playerid)
		    {
		        PlayerSpectatePlayer(i, playerid);
		        break;
			}
		}
		if(Taxi[playerid][Passanger] != -1 && Character[playerid][Job] == TAXI_JOB)
		{
			EndTaxiMeter(playerid);
		}
		if(Taxi[playerid][Driver] != -1)
		{
			EndTaxiMeter(Taxi[playerid][Driver]);
			Taxi[playerid][Driver] = -1;
		}

		StopAudioStreamForPlayer(playerid);
		
	}
	if ((newstate == PLAYER_STATE_PASSENGER || newstate == PLAYER_STATE_DRIVER) && oldstate == PLAYER_STATE_ONFOOT)
	{
		for(new i; i < MAX_PLAYERS; i++)
		{
		    if(IsPlayerConnected(i) && Character[i][IsSpec] == playerid)
		    {
		        PlayerSpectateVehicle(i, GetPlayerVehicleID(playerid));
		        break;
			}
		}
	}
	if(Vehicles[GetPlayerVehicleID(playerid)][RadioStatus] == 1)
	{
		PlayAudioStreamForPlayer(playerid, Vehicles[GetPlayerVehicleID(playerid)][RadioURL]);
	}
	return 1;
}


public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	new vid = GetPlayerVehicleID(playerid);
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid == PLAYER_STATE_DRIVER))
		{
			if(PRESSED(KEY_HANDBRAKE)) 
			{
				if(Engine[vid] == 0)
				{
					if(CanDriveVehicle(playerid, vid))
					{
						Engine_TOGGLE(playerid, vid);
					}
				}
			}
			else if(PRESSED(KEY_LOOK_BEHIND))
			{
				Lights_TOGGLE(playerid, vid);
			}
		}
	}
	if(LoopAnim[playerid])
	{
		if(PRESSED(KEY_HANDBRAKE)) 
		{
		    StopLoopingAnim(playerid);
	        TextDrawHideForPlayer(playerid,AnimText[playerid]);
	    }
    }
	return 1;
}
forward GivePlayerPayday(playerid, amount);
public GivePlayerPayday(playerid, amount)
{
	Character[playerid][Payday] += amount;
	if(Character[playerid][Payday] > 20000)
	{
		Character[playerid][Payday] = 20000;
		MYSQL_Update_Character(playerid, "Payday", Character[playerid][Payday]);

		SendClientMessage(playerid, COLOR_DARKVIOLET, "You have reached your paycheck capacity($20,000). In order to continue earning money you will have to collect the accumulated funds.");
	}
	else
	{
		MYSQL_Update_Character(playerid, "Payday", Character[playerid][Payday]);
	}

}


CMD:payday(playerid,params[])
{
	if(InRangeOfIcon(playerid, 4))
	{
	    if(Character[playerid][Payday] > 0)
	    {
	        new str[128];
	        format(str, sizeof(str), "You have collected a total of $%d in payments.", Character[playerid][Payday]);
	        SendClientMessage(playerid, COLOR_DGREEN, str);
   	 		GivePlayerMoneyEx(playerid, Character[playerid][Payday]);
	    	Character[playerid][Payday] = 0;
		}
		else
		{
		    SendClientMessage(playerid, COLOR_YELLOW, "You do not have anything to collect from your payday.");
		}
	}

	return 1;
}


forward GivePayday(playerid);
public GivePayday(playerid)
{

	new bizincome[128], standard[128];
	Line(playerid);
	SendClientMessage(playerid, COLOR_YELLOW, "------PAYDAY------");

//Business Payout
	if(Character[playerid][Business_1] > 0)
	{
		format(bizincome, sizeof(bizincome), "Amount added to your business safe = $%d.", Business[Character[playerid][Business_1]][Payout]);
		SendClientMessage(playerid, COLOR_YELLOW, bizincome);
		
		GivePlayerXP(playerid, PAYDAY_XP_BIZ);
		
		format(bizincome, sizeof(bizincome), "You have received %d XP for owning a business.", PAYDAY_XP_BIZ);
		SendClientMessage(playerid, COLOR_GRAY, bizincome);

		Business[Character[playerid][Business_1]][Safe] += Business[Character[playerid][Business_1]][Payout];
	}

	if(Character[playerid][Business_2] > 0)
	{
		format(bizincome, sizeof(bizincome), "Amount added to your second business' safe = $%d.", Business[Character[playerid][Business_2]][Payout]);
		SendClientMessage(playerid, COLOR_YELLOW, bizincome);
		
		GivePlayerXP(playerid, PAYDAY_XP_BIZ);
		
		format(bizincome, sizeof(bizincome), "You have received %d XP for owning a business.", PAYDAY_XP_BIZ);
		SendClientMessage(playerid, COLOR_GRAY, bizincome);

		Business[Character[playerid][Business_2]][Safe] += Business[Character[playerid][Business_2]][Payout];
	}

//No faction Payout
	if(Character[playerid][Faction] == 0)
	{
		format(standard, sizeof(standard), "Income from Government benefits = $%d.", PAYDAY_STANDARD);
		SendClientMessage(playerid, COLOR_YELLOW, standard);
		
		GivePlayerPayday(playerid, PAYDAY_STANDARD);
		GivePlayerXP(playerid, PAYDAY_XP_STANDARD);
		
		format(standard, sizeof(standard), "You have received %d XP.", PAYDAY_XP_STANDARD);
		SendClientMessage(playerid, COLOR_GRAY, standard);
	}
	if(Character[playerid][Faction] > 0)
	{
		//400 * rank - 100
	    new Salary;
	    Salary = (PAYDAY_FACTION * Character[playerid][Rank]) / 2;
        GivePlayerPayday(playerid, Salary);

        new fid = GetFactionIDFromSQLID(Character[playerid][Faction]);

		format(standard, sizeof(standard), "Income for being rank %d in %s = $%d.",  Character[playerid][Rank], Factions[fid][Name],Salary);
		SendClientMessage(playerid, COLOR_YELLOW, standard);
		
		GivePlayerXP(playerid, PAYDAY_XP_FACTION);

		format(standard, sizeof(standard), "You have received %d XP for being in a faction.", PAYDAY_XP_FACTION);
		SendClientMessage(playerid, COLOR_GRAY, standard);
	}
	SendClientMessage(playerid, COLOR_YELLOW, "All income can be collected from your local bank unless otherwise specified.");
	Line(playerid);
	return 1;
}

CMD:givepayday(playerid,params[])
{
	if(Account[playerid][Admin] >= 6)
	{
		GivePayday(playerid);
	}
	else
	{
		SendErrorMessage(playerid, ERROR_ADMIN);
	}
	return 1;
}


stock CreateSpacer(playerid, lines)
{
	for(new i = 0; i < lines; i++)
	{
	    SendClientMessage(playerid, COLOR_WHITE, "");
	}
	return 1;
}


forward MYSQL_Update_String(sqlid, table[], column[], str[]);
public MYSQL_Update_String(sqlid, table[], column[], str[])
{
	new query[280];
    mysql_format(SQL_CONNECTION, query, sizeof(query), "UPDATE `%e` SET `%e` = '%e' WHERE SQLID = %d LIMIT 1", table, column, str, sqlid);
	mysql_tquery(SQL_CONNECTION, query);
	return 1;
}

forward MYSQL_Update_Interger(sqlid, table[], column[], interger);
public MYSQL_Update_Interger(sqlid, table[], column[], interger)
{
	new query[280];
    mysql_format(SQL_CONNECTION, query, sizeof(query), "UPDATE `%e` SET `%e` = %d WHERE SQLID = %d LIMIT 1", table, column, interger, sqlid);
	mysql_tquery(SQL_CONNECTION, query);
	return 1;
}

forward MYSQL_Update_Float(sqlid, table[], column[], Float:interger);
public MYSQL_Update_Float(sqlid, table[], column[], Float:interger)
{
	new query[280];
    mysql_format(SQL_CONNECTION, query, sizeof(query), "UPDATE `%e` SET `%e` = %f WHERE SQLID = %d LIMIT 1", table, column, interger, sqlid);
	mysql_tquery(SQL_CONNECTION, query);
	return 1;
}

MYSQL_Update_Character(playerid, option1[], option2)
{
	new query[128];
    mysql_format(SQL_CONNECTION, query, sizeof(query), "UPDATE Characters SET %e = %d WHERE ID = %d LIMIT 1", option1, option2, Character[playerid][ID]);
	mysql_tquery(SQL_CONNECTION, query);
	return 1;
}

CMD:pvars(playerid)
{
	for(new i; pinfo:i < pinfo; i++)
	{
    	SendClientMessage(playerid, COLOR_WHITE, Character[playerid][pinfo:i]);
	}
	return 1;
}

Account_Reset(playerid)
{
	for(new i; acc:i < acc; i++)
	{
    	Account[playerid][acc:i] = 0;
	}
	return 1;
}

Character_Reset(playerid)
{
	for(new i; pinfo:i < pinfo; i++)
	{
    	Character[playerid][pinfo:i] = 0;
	}

	Character[playerid][IsSpec] = -1;

 	Inventory[playerid][PhoneStatus] = 0;
 	Inventory[playerid][PhoneCaller] = -1;
 	Inventory[playerid][PhoneNumber] = 0;
 	Inventory[playerid][PhoneEmergency] = 0;
 	Inventory[playerid][VehicleRadio] = 0;
 	Inventory[playerid][Radio] = 0;
 	Inventory[playerid][RadioFreq] = 0;
 	Inventory[playerid][Screwdriver] = 0;

 	Trucking[playerid][TruckID] = 0;
 	Trucking[playerid][RouteID] = 0;
 	Trucking[playerid][SectionID] = 0;
 	Trucking[playerid][CheckpointID] = 0;
 	Trucking[playerid][Capacity] = 0;
 	Trucking[playerid][Boxes] = 0;

 	Taxi[playerid][Driver] = -1;
 	Taxi[playerid][Offering] = -1;
 	Taxi[playerid][Passanger] = -1;
 	Taxi[playerid][Meter] = 0;
 	Taxi[playerid][Fare] = 0;


 	DMV[playerid][DrivingTest] = 0;
 	DMV[playerid][GDL] = 0;
 	DMV[playerid][CDL] = 0;
 	DMV[playerid][MDL] = 0;

 	PickedUpPickup[playerid] = false;
	LoopAnim[playerid] = 0;
	LibsPreloaded[playerid] = 0;
	return 1;
}




stock GetPlayerID(const name[])
{
    new pName[MAX_PLAYER_NAME];
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i)) continue;
        GetPlayerName(i, pName, MAX_PLAYER_NAME);
        if(!strcmp(pName, name))
            return i;
    }
    return INVALID_PLAYER_ID;
}



stock NameCheck(playerid)
{
	new str[128];
    new namecheck = strfind(GetName(playerid), "_", true);
	if(namecheck >= 1)
	{
        SendClientMessage(playerid, COLOR_RED, "On Small County Roleplay we operate a 'Master Account' system. In order to register an account you will need to join with a nickname(without the '_'), instead of your roleplay name.");
		format(str, sizeof(str), "%s was kicked by the server for joining with a roleplay name.",GetName(playerid));
		SendAdminsMessage(1, COLOR_ORANGERED, str);
		KickPlayer(playerid);
	}
	return 1;
}


stock GetName(playerid)
{
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, MAX_PLAYER_NAME);
    return name;
}

stock GetRoleplayName(playerid)
{
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, MAX_PLAYER_NAME);
    name[strfind(name,"_")] = ' ';
    return name;
}

new Float:StartHealth[MAX_VEH] = 1000.0;

stock IsAdminInVehicle(playerid)
{
	if(IsPlayerInAnyVehicle(playerid))
	{
		for (new i = 0; i < MAX_PLAYERS; ++i)
		{
			if(Account[i][Admin] > 0 && GetPlayerVehicleID(playerid) == GetPlayerVehicleID(i))
			{
				return 0;
			}
		}
		
	}
	return 1;
}



public OnPlayerUpdate(playerid)
{
	new VID = GetPlayerVehicleID(playerid);
	if(VID > 0)
	{
		static Float:VHP;
		GetVehicleHealth(VID, VHP);

		if(VHP < 300.0 && Engine[VID] == 1)	
		{
			SetVehicleHealth(VID, 300.0);	
			Engine_SET(playerid, VID, 0);
	    	SendLocalMessage(playerid, "* The engine packs up after sustaining a considerable amount of damage. *", Range_Normal, COLOR_RP, COLOR_RP);
		}
		else if(VHP < 300.0 && Engine[VID] == 0)	
		{
			SetVehicleHealth(VID, 300.0);	
    	}

	    if(Account[playerid][Admin] == 0)
	    {
    		if(InRangeOfIcon(playerid, 11) == 0 && IsAdminInVehicle(playerid) == 0 && Trucking[playerid][TruckID] == 0)
			{
				static Float:VehicleHP;
				GetVehicleHealth(VID, VehicleHP);
			    if(VehicleHP != StartHealth[VID] && GetPlayerState(playerid) == PLAYER_STATE_DRIVER && VehicleHP == 1000.0)
			    {
			        new Float:Calculation;
			        Calculation = floatsub(StartHealth[VID], VehicleHP);
					if(Calculation < 0.0 && Calculation != -1000.0)
					{
				    	new str[128], Float:NewHealth = 1000.0;
				    	NewHealth = NewHealth + Calculation;
				    	//SetVehicleHealth(VID, NewHealth);
						format(str, sizeof(str), "POSSIBLE HACK DETECTED: %s (Repair Hack) Damage received: %f", GetRoleplayName(playerid), Calculation);
						SendAdminsMessage(1, COLOR_RED, str);
				        //KickPlayer(playerid);
					}
					StartHealth[VID] = VehicleHP;
		    	}
			}
		}

		if(GDL_Test[playerid] > 0)
		{
			static Float:VehicleHP;
			GetVehicleHealth(VID, VehicleHP);
			if(VehicleHP < 950)
			{
				FailDrivingTest(playerid, "The vehicle is damaged.");
			}
			
		}
		if(Trucking[playerid][CheckpointID] > 0)
		{
			static Float:VehicleHP;
			new id = Trucking[playerid][TruckID];
			GetVehicleHealth(id, VehicleHP);
			if(VehicleHP < 400)
			{
				EndTruckingMission(playerid, "The vehicle is too damaged to continue.");
			}
			
		}
	}
	else if(Character[playerid][ClothesSelection] == 1)
	{
		new Keys,ud,lr;
    	GetPlayerKeys(playerid,Keys,ud,lr);
    	if(Keys == KEY_SECONDARY_ATTACK)
    	{
    	    new str[128];
		    Character[playerid][ClothesSelection] = 0;
		    Character[playerid][Skin] = GetPlayerSkin(playerid);

			MYSQL_Update_Character(playerid, "Skin", Character[playerid][Skin]);

			SetPlayerPos(playerid, Character[playerid][PosX], Character[playerid][PosY], Character[playerid][PosZ]);
			SetPlayerInterior(playerid, Character[playerid][Interior]);
			SetPlayerVirtualWorld(playerid, Character[playerid][VWorld]);
			SetCameraBehindPlayer(playerid);
	       	TogglePlayerControllable(playerid, 1);

	       	format(str, sizeof(str), "Thank you for shopping at %s.", Business[Character[playerid][bEntered]][Name]);
	       	InfoBoxForPlayer(playerid, str);
    	}
        else if(lr == KEY_LEFT)
        {
		    new str[128];
		    if(Character[playerid][Gender] == 1)
			{
      			if(SkinSelection[playerid] <= sizeof(MaleSkins) - 1 && SkinSelection[playerid] > 0)
				{
	 				SkinSelection[playerid] --;
					SetPlayerSkin(playerid, MaleSkins[SkinSelection[playerid]][0]);
					return 1;
				}
				else if(SkinSelection[playerid] == 0)
				{
				    SkinSelection[playerid] = sizeof(MaleSkins) - 1;
				    SetPlayerSkin(playerid, MaleSkins[SkinSelection[playerid]][0]);
				    return 1;
				}
				format(str, sizeof(str), "You are viewing skin: %d", MaleSkins[SkinSelection[playerid]][0]);
	  			InfoBoxForPlayer2(playerid, str);
	  			return 1;
		    }
			else if(Character[playerid][Gender] == 2)
			{
				if(SkinSelection[playerid] <= sizeof(FemaleSkins) - 1 && SkinSelection[playerid] > 0)
				{
	 				SkinSelection[playerid] --;
					SetPlayerSkin(playerid, FemaleSkins[SkinSelection[playerid]][0]);
				}
				else if(SkinSelection[playerid] == 0)
				{
				    SkinSelection[playerid] = sizeof(FemaleSkins) - 1;
				    SetPlayerSkin(playerid, FemaleSkins[SkinSelection[playerid]][0]);
				}
				format(str, sizeof(str), "You are viewing skin: %d", FemaleSkins[SkinSelection[playerid]][0]);
	  			InfoBoxForPlayer2(playerid, str);
			}
        }
        else if(lr == KEY_RIGHT)
		{
		    new str[128];
		    if(Character[playerid][Gender] == 1)
		    {
				if(SkinSelection[playerid] < sizeof(MaleSkins) - 1)
				{
	 				SkinSelection[playerid] += 1;
					SetPlayerSkin(playerid, MaleSkins[SkinSelection[playerid]][0]);
				}
				else
				{
				    SkinSelection[playerid] = 0;
				    SetPlayerSkin(playerid, MaleSkins[SkinSelection[playerid]][0]);
				}
				format(str, sizeof(str), "You are viewing skin: %d", MaleSkins[SkinSelection[playerid]][0]);
	  			InfoBoxForPlayer2(playerid, str);
	  			return 1;
		    }
			else if(Character[playerid][Gender] == 2)
			{
				if(SkinSelection[playerid] < sizeof(FemaleSkins) - 1)
				{
	 				SkinSelection[playerid] ++;
					SetPlayerSkin(playerid, FemaleSkins[SkinSelection[playerid]][0]);
				}
				else
				{
				    SkinSelection[playerid] = 0;
				    SetPlayerSkin(playerid, FemaleSkins[SkinSelection[playerid]][0]);
				}
				format(str, sizeof(str), "You are viewing skin: %d", FemaleSkins[SkinSelection[playerid]][0]);
	  			InfoBoxForPlayer2(playerid, str);
			}
		}
	}

	else if(Character[playerid][IsSpec] != -1)
	{
		new Keys,ud,lr;
    	GetPlayerKeys(playerid,Keys,ud,lr);
        if(lr == KEY_LEFT)
        {
        	new newplayer = Character[playerid][IsSpec] - 1;

        	if(IsPlayerConnected(newplayer))
    		{
	           	Character[playerid][IsSpec] -= 1;
	        	SpectatePlayer(playerid, Character[playerid][IsSpec]);
        	}
        	else
    		{
    			SendErrorMessage(playerid, ERROR_CONNECTED);
    		}
        }
        else if(lr == KEY_RIGHT)
		{
        	new newplayer = Character[playerid][IsSpec] - 1;

        	if(IsPlayerConnected(newplayer))
    		{
	           	Character[playerid][IsSpec] += 1;
	        	SpectatePlayer(playerid, Character[playerid][IsSpec]);
        	}
        	else
    		{
    			SendErrorMessage(playerid, ERROR_CONNECTED);
    		}
		}
	}
	return 1;
}

CMD:repair(playerid,params[])
{
    if(InRangeOfIcon(playerid, 11) == 1)
	{
		if(GetPlayerVehicleID(playerid) > 0)
		{
		    if(Character[playerid][Cash] >= 1000)
		    {
		        GivePlayerMoneyEx(playerid, -1000);
		        new vid = GetPlayerVehicleID(playerid);
				RepairVehicle(vid);
				Vehicles[vid][Broken] = 0;
				if(IsPlayerVehicle(vid)) MYSQL_Update_Interger(Vehicles[vid][SQLID], "PlayerVehicles", "Broken", 0);
		        SendClientMessage(playerid, COLOR_LGREEN, "> Your vehicle has been insta-repaired because I haven't got a better way of doing it yet");
		    	
		    }
		    else
		    {
		        SendErrorMessage(playerid, ERROR_MONEY);
		    }

		}
	}
	return 1;
}


CMD:afix(playerid,params[])
{
	if(Account[playerid][Admin] >= 1)
	{
	    new str[128];
	    if(GetPlayerVehicleID(playerid))
	    {
	    	new vid = GetPlayerVehicleID(playerid);
			RepairVehicle(vid);
			Vehicles[vid][Broken] = 0;
			if(IsPlayerVehicle(vid)) MYSQL_Update_Interger(Vehicles[vid][SQLID], "PlayerVehicles", "Broken", 0);
			format(str, sizeof(str), "%s has repaired vehicle %d.", GetRoleplayName(playerid), vid);
			SendAdminsMessage(6, COLOR_SLATEGRAY, str);
	    	//SendAdminsMessage(1, COLOR_SEAGREEN, str);
	    }
	}
	else
	{
	    SendErrorMessage(playerid, ERROR_ADMIN);
	}
    return 1;
}


CMD:flip(playerid,params[])
{
	if(Account[playerid][Admin] >= 1)
	{
	    new str[128], vID = GetPlayerVehicleID(playerid);
	    if(GetPlayerVehicleID(playerid))
	    {
			new Float:angle;
	        GetVehicleZAngle(vID, angle);
	        SetVehicleZAngle(vID, angle);
			format(str, sizeof(str), "%s has flipped vehicle %d.", GetRoleplayName(playerid), vID);
	    	SendAdminsMessage(6, COLOR_SLATEGRAY, str);
	    }
	}
	else
	{
	    SendErrorMessage(playerid, ERROR_ADMIN);
	}
    return 1;
}

/*
forward CheckForRepairHack(playerid, vehicleid, Float:Calculation);
public CheckForRepairHack(playerid, vehicleid, Float:Calculation)
{
	if(IsPlayerInAnyVehicle(playerid))
	{

	    printf("Damage Delt2: %f",Calculation);
		if(Calculation < 0.0 )
		{
	    	new str[128];
			format(str, sizeof(str), "HACK DETECTED: %s (Repair Hack)", GetRoleplayName(playerid));
			SendAdminsMessage(1, COLOR_RED, str);
	        //KickPlayer(playerid);
		}
	}
    return 1;
}
*/



stock InfoBoxForPlayer(playerid, text[])
{
    //CloseInfo(playerid);
    TextDrawSetString(InfoBox[playerid], text);
	TextDrawShowForPlayer(playerid, InfoBox[playerid]);
    SetTimerEx("CloseInfo", SECONDS(7), false, "d", playerid);
	return 1;
}

stock InfoBoxForPlayer2(playerid, text[])
{
    CloseInfo(playerid);
    TextDrawSetString(InfoBox[playerid], text);
	TextDrawShowForPlayer(playerid, InfoBox[playerid]);
	return 1;
}

stock ShowSpeedo(playerid, speed, fuel)
{
	new str[128], fuelbar[14];
	if(speed < 151)
	{
		fuel /= 10;
		if(fuel >= 1)
		{
			format(fuelbar, sizeof(fuelbar), "|~r~||||");
		}
		else
		{
			format(fuelbar, sizeof(fuelbar), "~r~|||||");
		}
		if(fuel >= 3)
		{
			format(fuelbar, sizeof(fuelbar), "||~r~|||");
		}
		if(fuel >= 5)
		{
			format(fuelbar, sizeof(fuelbar), "|||~r~||");
		}
		if(fuel >= 7)
		{
			format(fuelbar, sizeof(fuelbar), "||||~r~|");
		}
		if(fuel >= 9)
		{
			format(fuelbar, sizeof(fuelbar), "|||||");
		}



		if(speed > 65 && GDL_Test[playerid] > 0) 
		{
			FailDrivingTest(playerid, "Speeding.");
			format(str, sizeof(str), "Speed:~r~ %d ~w~MPH~n~Fuel: %s", speed, fuelbar);
		}
		else
		{
			format(str, sizeof(str), "Speed: %d MPH~n~Fuel: %s", speed, fuelbar);
		}
		if(Engine[GetPlayerVehicleID(playerid)] == 0)
		{
			KillTimer(Vehicles[GetPlayerVehicleID(playerid)][FuelTimer]);
		}
	    TextDrawSetString(SpeedBox[playerid], str);
		TextDrawShowForPlayer(playerid, SpeedBox[playerid]);
	}


	else
	{
	    format(str, sizeof(str), "POSSIBLE HACK DETECTED: %s (Speed Hack) Speed received: %d MPH.", GetName(playerid), speed);
	    SendAdminsMessage(1, COLOR_RED, str);
	}
	return 1;
}


stock KickPlayer(playerid)
{
	SetTimerEx("FixKick", 200, false, "d", playerid);
}

stock Character_Save(playerid)
{
	if(LoggedIn[playerid] == true)
	{
		new query[3000];

		mysql_format(SQL_CONNECTION, query, sizeof(query), "UPDATE Characters SET Tutorial = %d, Level = %d, XP = %d, Cash = %d,Skin = %d, PosX = %f,PosY = %f,PosZ = %f,VWorld = %d,Interior = %d, Kicks = %d, Muted = %d,Faction = %d, Rank = %d, Job = %d, Health = 100, Armour = %f, hEntered = %d, bEntered =%d, Bank = %d, LatestIP = '%e', Age = %d, Gender = %d, ExemptIP = %d, TotalTimePlayed = %d, OnlinePeriod = %d, Payday = %d WHERE ID = %d LIMIT 1",

			Character[playerid][Tutorial],
			Character[playerid][Level],
			Character[playerid][XP],
			Character[playerid][Cash],
			Character[playerid][Skin],
		    Character[playerid][PosX],
			Character[playerid][PosY],
			Character[playerid][PosZ],
			GetPlayerVirtualWorld(playerid),
			GetPlayerInterior(playerid),
			Character[playerid][Kicks],
			Character[playerid][Muted],
		    Character[playerid][Faction],
		    Character[playerid][Rank],
		    Character[playerid][Job],
		    Character[playerid][Armour],
			Character[playerid][hEntered],
			Character[playerid][bEntered],
			Character[playerid][Bank],
			Character[playerid][LatestIP],
			Character[playerid][Age],
			Character[playerid][Gender],
			Character[playerid][ExemptIP],
			Character[playerid][TotalTimePlayed],
			Character[playerid][OnlinePeriod],
			Character[playerid][Payday],
			Character[playerid][ID]);
			
		mysql_tquery(SQL_CONNECTION, query);


		mysql_format(SQL_CONNECTION, query, sizeof(query), "UPDATE Characters SET LastOnline = %d, Cuffed = %d, Spawn = %d, Jail = %d, Uniform = %d WHERE ID = %d LIMIT 1",

			Character[playerid][LastOnline],
			Character[playerid][Cuffed],
			Character[playerid][Spawn],
			Character[playerid][Jail],
			Character[playerid][Uniform],
			Character[playerid][ID]);
			
		mysql_tquery(SQL_CONNECTION, query);


		mysql_format(SQL_CONNECTION, query, sizeof(query), "UPDATE Characters SET PhoneStatus = %d, PhoneNumber = %d, VehicleRadio = %d, Radio = %d, RadioFreq = %d, Screwdriver = %d WHERE ID = %d LIMIT 1",
		
			Inventory[playerid][PhoneStatus],
			Inventory[playerid][PhoneNumber],
			Inventory[playerid][VehicleRadio],
			Inventory[playerid][Radio],
			Inventory[playerid][RadioFreq],
			Inventory[playerid][Screwdriver],
			Character[playerid][ID]);
			
		mysql_tquery(SQL_CONNECTION, query);


		mysql_format(SQL_CONNECTION, query, sizeof(query), "UPDATE Characters SET GDL = %d, CDL = %d, MDL = %d, TruckingCompleted = %d, TruckCoolDown = %d, Fare = %d WHERE ID = %d LIMIT 1",
		
			DMV[playerid][GDL],
			DMV[playerid][CDL],
			DMV[playerid][MDL],

			Character[playerid][TruckingCompleted],
			Character[playerid][TruckCoolDown],

			Taxi[playerid][Fare],

			Character[playerid][ID]);
			
		mysql_tquery(SQL_CONNECTION, query);


		mysql_format(SQL_CONNECTION, query, sizeof(query), "UPDATE Accounts SET Admin = %d WHERE SQLID = %d LIMIT 1",
		
			Account[playerid][Admin],
			Account[playerid][SQLID]);
			
		mysql_tquery(SQL_CONNECTION, query, "", "");

	    Weapons_Save(playerid);

	}
	return 1;
}

Weapons_Save(playerid)
{
	new weap[104],query[200];
    for(new x = 1; x < 13; x++)
    {
    	new weapna, weapam, str[18];
    	GetPlayerWeaponData(playerid, x, weapna, weapam);
    	if(weapam == 0) 
		{
			Weapon[playerid][x] = 0;
			WeaponAmmo[playerid][x] = 0;
		}
    	format(str, sizeof(str), "%d,%d,", Weapon[playerid][x], WeaponAmmo[playerid][x]);
        strcat(weap, str);
    }
    mysql_format(SQL_CONNECTION, query, sizeof(query), "UPDATE Characters SET Weapons = '%e' WHERE ID = %d LIMIT 1", weap, Character[playerid][ID]);	
	mysql_tquery(SQL_CONNECTION, query);
}

stock GetWeaponSlot(weaponid)
{
	new slot;
	switch(weaponid)
	{
		case  0 .. 1: 		slot = 0;
		case  2 .. 9: 		slot = 1;
		case 10 .. 15: 		slot = 10;
		case 16 .. 18, 39: 	slot = 8;
		case 22 .. 24: 		slot = 2;
		case 25 .. 27: 		slot = 3;
		case 28 .. 29, 32: 	slot = 4;
		case 30 .. 31: 		slot = 5;
		case 33 .. 34: 		slot = 6;
		case 35 .. 38: 		slot = 7;
		case 40      : 		slot = 12;
		case 41 .. 43: 		slot = 9;
		case 44 .. 46: 		slot = 11;
	}
	return slot;
}

forward OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ);
public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
	if(weaponid > 0)
	{
		new wslot = GetWeaponSlot(weaponid), wi, wa;

	    if(Weapon[playerid][wslot] > 0)
		{
			GetPlayerWeaponData(playerid, wslot, wi, wa);
			//format(str, sizeof(str), "- ca %d sa %d", wa, WeaponAmmo[playerid][wslot]);
			//SendClientMessage(playerid, COLOR_YELLOW, str);

			if(wa > WeaponAmmo[playerid][wslot] + 1)
			{
				InfoBoxForPlayer(playerid, "client ammo above server");
			}
			if(WeaponAmmo[playerid][wslot] > wa)
			{
				WeaponAmmo[playerid][wslot] = wa-1;
			}
			else if(WeaponAmmo[playerid][wslot] == wa)
			{
				WeaponAmmo[playerid][wslot] --;
			}


			if(WeaponAmmo[playerid][wslot] == 0) Weapon[playerid][wslot] = 0;

			if(WeaponAmmo[playerid][wslot] < 0)
			{
				IssueBan(playerid, "Auto", "Hacked ammo");
		   		InfoBoxForPlayer(playerid, "~r~You have been banned for using hacked ammo.");
			}

		}
		else
		{
		    IssueBan(playerid, "Auto", "Hacked weapons");
		    InfoBoxForPlayer(playerid, "~r~You have been banned for using hacked weapons.");
		}
		//str[128],  format(str, sizeof(str), "- Slot: %d %d Weapon: %d Ammo: %d", wslot, weaponid, Weapon[playerid][wslot], WeaponAmmo[playerid][wslot]);
		//SendClientMessage(playerid, COLOR_WHITE, str);

	   //format(szstr, sizeof(szstr), "Weapon %i fired. hittype: %i   hitid: %i   pos: %f, %f, %f	slot:%d", weaponid, hittype, hitid, fX, fY, fZ, GetWeaponSlot(weaponid));
	}
    return 1;
}

stock ClearPlayerWeapons(playerid)
{
	ResetPlayerWeapons(playerid);
	Weapon[playerid][1] = 0;
	WeaponAmmo[playerid][1] = 0;
	Weapon[playerid][2] = 0;
	WeaponAmmo[playerid][2] = 0;
	Weapon[playerid][3] = 0;
	WeaponAmmo[playerid][3] = 0;
	Weapon[playerid][4] = 0;
	WeaponAmmo[playerid][4] = 0;
	Weapon[playerid][5] = 0;
	WeaponAmmo[playerid][5] = 0;
	Weapon[playerid][6] = 0;
	WeaponAmmo[playerid][6] = 0;
	Weapon[playerid][7] = 0;
	WeaponAmmo[playerid][7] = 0;
	Weapon[playerid][8] = 0;
	WeaponAmmo[playerid][8] = 0;
	Weapon[playerid][9] = 0;
	WeaponAmmo[playerid][9] = 0;
	Weapon[playerid][10] = 0;
	WeaponAmmo[playerid][10] = 0;
	Weapon[playerid][11] = 0;
	WeaponAmmo[playerid][11] = 0;
	Weapon[playerid][12] = 0;
	WeaponAmmo[playerid][12] = 0;
	return 1;
}

UpdatePlayerWeapons(playerid)
{
	new Holding;
	Holding = GetPlayerWeapon(playerid);
	ResetPlayerWeapons(playerid);
	for(new w = 1; w < 13; w++)
	{
		if(WeaponAmmo[playerid][w] == 0) Weapon[playerid][w] = 0;
		if(Weapon[playerid][w] > 0) GivePlayerWeapon(playerid,Weapon[playerid][w],WeaponAmmo[playerid][w]);
	}
    SetPlayerArmedWeapon(playerid, Holding);
	return 1;
}

stock GetWeaponIDFromName(str[])
{
    for(new i = 0; i < 48; i++)
	{
        if (i == 19 || i == 20 || i == 21) continue;
        if (strfind(WeaponNameList[i], str, true) != -1)
		{
            return i;
        }
    }
    return -1;
}

CMD:resetweapons(playerid, params[])
{
    if(Account[playerid][Admin] >= 3)
    {
        new Player;
    	if(sscanf(params, "u", Player)) return SendClientMessage(playerid, COLOR_GRAY, "/resetweapons [playerid]");
		ClearPlayerWeapons(Player);
		UpdatePlayerWeapons(Player);
    }
    else
    {
        SendErrorMessage(playerid, ERROR_ADMIN);
    }
    return 1;
}

CMD:updateweapons(playerid, params[])
{
    if(Account[playerid][Admin] >= 3)
    {
        new Player;
    	if(sscanf(params, "u", Player)) return SendClientMessage(playerid, COLOR_GRAY, "/resetweapons [playerid]");
		UpdatePlayerWeapons(Player);
    }
    else
    {
        SendErrorMessage(playerid, ERROR_ADMIN);
    }
    return 1;
}

stock Restricted_Weapon(WeaponID)
{
	if(WeaponID == 35 || WeaponID >= 36 || WeaponID >= 38)
	{
	    return 0;
	}
	return 1;
}

stock GivePlayerGun(player, WeaponID, Ammo)
{

    Weapon[player][GetWeaponSlot(WeaponID)] = WeaponID;
	WeaponAmmo[player][GetWeaponSlot(WeaponID)] = Ammo;
		
    UpdatePlayerWeapons(player);	
	return 1;
}


CMD:giveweapon(playerid, params[])
{
    new WeaponName[50], gWeaponAmmo, Player, WeaponID, str[128];
    if(Account[playerid][Admin] >= 2)
    {
        if(sscanf(params, "us[50]d", Player, WeaponName, gWeaponAmmo)) return SendClientMessage(playerid, COLOR_GRAY, "/giveweapon [playerid] [Name] [Ammo]");
		WeaponID = GetWeaponIDFromName(WeaponName);
		if(Account[playerid][Admin] != 6 && !Restricted_Weapon(WeaponID)) return SendErrorMessage(playerid, ERROR_OPTION);
		if(gWeaponAmmo > 1000) return SendErrorMessage(playerid, ERROR_VALUE);
	    
		GivePlayerGun(Player, WeaponID, gWeaponAmmo);

        format(str, sizeof(str), "Admin %s has given %s weapon: %s (Ammo:%d)", GetRoleplayName(playerid), GetRoleplayName(Player), WeaponNameList[WeaponID], gWeaponAmmo);
		SendAdminsMessage(1, COLOR_YELLOW, str);
		SendClientMessage(Player, COLOR_YELLOW, str);
    }
    else
    {
        SendErrorMessage(playerid, ERROR_ADMIN);
    }
    return 1;
}

forward Character_Load(playerid);
public Character_Load(playerid)
{

	Character[playerid][ID] = cache_get_field_content_int(0, "ID", SQL_CONNECTION);
	cache_get_field_content(0, "Name", Character[playerid][Username], SQL_CONNECTION, 32);
    Character[playerid][Tutorial] = cache_get_field_content_int(0, "Tutorial", SQL_CONNECTION);
    Character[playerid][Level] = cache_get_field_content_int(0, "Level", SQL_CONNECTION);
    Character[playerid][XP] = cache_get_field_content_int(0, "XP", SQL_CONNECTION);
    Character[playerid][Cash] = cache_get_field_content_int(0, "Cash", SQL_CONNECTION);
    Character[playerid][Skin] = cache_get_field_content_int(0, "Skin", SQL_CONNECTION);
    Character[playerid][PosX] = cache_get_field_content_float(0, "PosX", SQL_CONNECTION);
    Character[playerid][PosY] = cache_get_field_content_float(0, "PosY", SQL_CONNECTION);
    Character[playerid][PosZ] = cache_get_field_content_float(0, "PosZ", SQL_CONNECTION);
    Character[playerid][Interior] = cache_get_field_content_int(0, "Interior", SQL_CONNECTION);
    Character[playerid][VWorld] = cache_get_field_content_int(0, "VWorld", SQL_CONNECTION);
    Character[playerid][Age] = cache_get_field_content_int(0, "Age", SQL_CONNECTION);
    Character[playerid][Gender] = cache_get_field_content_int(0, "Gender", SQL_CONNECTION);
    Character[playerid][Kicks] = cache_get_field_content_int(0, "Kicks", SQL_CONNECTION);
    Character[playerid][Muted] = cache_get_field_content_int(0, "Muted", SQL_CONNECTION);
    Character[playerid][Faction] = cache_get_field_content_int(0, "Faction", SQL_CONNECTION);
    Character[playerid][Rank] = cache_get_field_content_int(0, "Rank", SQL_CONNECTION);
    Character[playerid][Job] = cache_get_field_content_int(0, "Job", SQL_CONNECTION);
    Character[playerid][Health] = cache_get_field_content_float(0, "Health", SQL_CONNECTION);
    Character[playerid][Armour] = cache_get_field_content_float(0, "Armour", SQL_CONNECTION);
    Character[playerid][hEntered] = cache_get_field_content_int(0, "hEntered", SQL_CONNECTION);
    Character[playerid][bEntered] = cache_get_field_content_int(0, "bEntered", SQL_CONNECTION);
    Character[playerid][Bank] = cache_get_field_content_int(0, "Bank", SQL_CONNECTION);
	Character[playerid][ExemptIP] = cache_get_field_content_int(0, "ExemptIP", SQL_CONNECTION);
	Character[playerid][TotalTimePlayed] = cache_get_field_content_int(0, "TotalTimePlayed", SQL_CONNECTION);
	Character[playerid][OnlinePeriod] = cache_get_field_content_int(0, "OnlinePeriod", SQL_CONNECTION);
	Character[playerid][Payday] = cache_get_field_content_int(0, "Payday", SQL_CONNECTION);
	Character[playerid][Cuffed] = cache_get_field_content_int(0, "Cuffed", SQL_CONNECTION);
	Character[playerid][Spawn] = cache_get_field_content_int(0, "Spawn", SQL_CONNECTION);
	Character[playerid][Jail] = cache_get_field_content_int(0, "Jail", SQL_CONNECTION);
	Character[playerid][Uniform] = cache_get_field_content_int(0, "Uniform", SQL_CONNECTION);
	
	Inventory[playerid][PhoneStatus] = cache_get_field_content_int(0, "PhoneStatus", SQL_CONNECTION);
	Inventory[playerid][PhoneNumber] = cache_get_field_content_int(0, "PhoneNumber", SQL_CONNECTION);
	Inventory[playerid][VehicleRadio] = cache_get_field_content_int(0, "VehicleRadio", SQL_CONNECTION);
	Inventory[playerid][Radio] = cache_get_field_content_int(0, "Radio", SQL_CONNECTION);
	Inventory[playerid][RadioFreq] = cache_get_field_content_int(0, "RadioFreq", SQL_CONNECTION);
	Inventory[playerid][Screwdriver] = cache_get_field_content_int(0, "Screwdriver", SQL_CONNECTION);

	Character[playerid][TruckingCompleted] = cache_get_field_content_int(0, "TruckingCompleted", SQL_CONNECTION);
	Character[playerid][TruckCoolDown] = cache_get_field_content_int(0, "TruckCoolDown", SQL_CONNECTION);

	DMV[playerid][GDL] = cache_get_field_content_int(0, "GDL", SQL_CONNECTION);
	DMV[playerid][CDL] = cache_get_field_content_int(0, "CDL", SQL_CONNECTION);
	DMV[playerid][MDL] = cache_get_field_content_int(0, "MDL", SQL_CONNECTION);

	Taxi[playerid][Fare] = cache_get_field_content_int(0, "Fare", SQL_CONNECTION);

	Character[playerid][LastOnline] = gettime();


	cache_get_field_content(0, "Weapons", Character[playerid][Weapons], SQL_CONNECTION, 104);

	new pos = 0;
	for (new x = 1; x < 13; ++x)
	{
        new temp[4];
        strmid(temp, Character[playerid][Weapons], pos, strfind(Character[playerid][Weapons], ",", true, pos));

		Weapon[playerid][x] = strval(temp); 
		pos += strlen(temp) + 1;

		strmid(temp, Character[playerid][Weapons], pos, strfind(Character[playerid][Weapons], ",", true, pos));

		WeaponAmmo[playerid][x] = strval(temp); 
        pos += strlen(temp) + 1;
	}


	StopAudioStreamForPlayer(playerid);

	for(new b = 1; b < MAX_BIZ; b++)
	{
	    if(Business[b][Owner] == Character[playerid][ID])
	    {
	        Character[playerid][Business_1] = b;
	        break;
	    }
	}

	if(Character[playerid][Business_1] > 0)
	{
		for(new b = 1; b < MAX_BIZ; b++)
		{
		    if(Business[b][Owner] == Character[playerid][ID] && b != Character[playerid][Business_1])
		    {
		        Character[playerid][Business_2] = b;
		        break;
		    }
		}
	}

	for(new h; h < MAX_HOUSES; h++)
	{
	    if(Houses[h][Owner] == Character[playerid][ID])
	    {
	        Character[playerid][House] = h;
	        break;
	    }
	}

    GetPlayerIp(playerid, Character[playerid][LatestIP], 16);
    SetPlayerName(playerid, Character[playerid][Username]);
	PlayerSpawnIn(playerid);
    return 1;
}



IssueBan(playerid, adminname[], reason[])
{
	new query[256], ip[18];
	GetPlayerIp(playerid, ip, 18);
	
    mysql_format(SQL_CONNECTION, query, sizeof(query), "INSERT INTO Bans (PlayerName, IP, C_ID, A_ID, Timestamp, BannedBy, Reason) VALUES('%s', '%s', %d, %d, %d, '%s', '%e')", GetName(playerid), ip, Character[playerid][ID], Account[playerid][SQLID], gettime(), adminname, reason);
	mysql_tquery(SQL_CONNECTION, query);
	KickPlayer(playerid);
	return 1;
}


forward PlayerSpawnIn(playerid);
public PlayerSpawnIn(playerid)
{
	new query[300], str[128];
	if(Character[playerid][Tutorial] <= 1)
    {

        Quiz(playerid, 1);
        return 1;
	}
	else if(Character[playerid][Tutorial] >= 2 && Character[playerid][Tutorial] < 5)
    {
	    Register(playerid);
		InfoBoxForPlayer(playerid, "It appears as if you didn't finish the registration process, you will now continue it.");
        return 1;
	}
	TogglePlayerSpectating(playerid, 0);

	LoggedIn[playerid] = true;
	Character[playerid][LastOnline] = gettime();

	TextDrawShowForPlayer(playerid, Clock);
	SetSpawnInfo(playerid, NO_TEAM, Character[playerid][Skin], Character[playerid][PosX], Character[playerid][PosY], Character[playerid][PosZ], 0.0, 0, 0, 0, 0, 0, 0);
	SpawnPlayer(playerid);
	
	SetPlayerHealth(playerid, Character[playerid][Health]);
	SetPlayerArmour(playerid, Character[playerid][Armour]);
	SetPlayerSkin(playerid, Character[playerid][Skin]);
	SetPlayerScore(playerid, Character[playerid][Level]);
	SetPlayerTime(playerid, ClockHours, ClockMinutes);


	new Float:pos[3];
	GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
	InactivtyCheck[playerid] = SetTimerEx("CheckActivity", MINUTES(15), true, "d", playerid);
	LastCommandTime[playerid] = gettime();
	InactivtyCheck_X[playerid] = pos[0];
	InactivtyCheck_Y[playerid] = pos[1];
	InactivtyCheck_Z[playerid] = pos[2];

	PickedUpPickup[playerid] = false;

	SetPlayerPosEx(playerid, Character[playerid][PosX], Character[playerid][PosY], Character[playerid][PosZ], Character[playerid][Interior], Character[playerid][VWorld]);
	SetPlayerMoneyEx(playerid, Character[playerid][Cash]);
	

    mysql_format(SQL_CONNECTION, query, sizeof(query), "SELECT * FROM `PlayerVehicles` WHERE Owner = %d LIMIT 3", Character[playerid][ID]);
	mysql_tquery(SQL_CONNECTION, query,"Character_Vehicles_Load", "i", playerid);
	UpdatePlayerWeapons(playerid);

	format(str, sizeof(str), "[Loaded Character]: %s", GetRoleplayName(playerid));
	SendClientMessage(playerid, COLOR_PALEGOLDENROD, str);

	if(Character[playerid][Jail] > 0)
	{
		format(str, sizeof(str), "[INFO] You are still in jail, you have a further %d minute(s) to serve.", Character[playerid][Jail]);
		SendClientMessage(playerid, COLOR_INDIANRED, str);
		return SendToJail(playerid);
	}


	if(Character[playerid][Spawn] == 0) SetPlayerPosEx(playerid, NoobSpawns[0][0], NoobSpawns[0][1], NoobSpawns[0][2], 0, 0);

	else if(Character[playerid][Spawn] == 1) SetPlayerPosEx(playerid, Character[playerid][PosX], Character[playerid][PosY], Character[playerid][PosZ], Character[playerid][Interior], Character[playerid][VWorld]);

	else if(Character[playerid][Spawn] == 2)
	{
		if(Character[playerid][House] > 0) SetPlayerPosEx(playerid, Houses[Character[playerid][House]][PosX], Houses[Character[playerid][House]][PosY], Houses[Character[playerid][House]][PosZ], 0, 0);
		else
		{
			SendErrorMessage(playerid, "Couldn't spawn at house.");
			SetPlayerPosEx(playerid, Character[playerid][PosX], Character[playerid][PosY], Character[playerid][PosZ], Character[playerid][Interior], Character[playerid][VWorld]);	
		}
	}

	else if(Character[playerid][Spawn] == 3)
	{
		if(Character[playerid][Business_1] > 0) SetPlayerPosEx(playerid, Business[Character[playerid][Business_1]][PosX], Business[Character[playerid][Business_1]][PosY], Business[Character[playerid][Business_1]][PosZ], 0 ,0);
		else
		{
			SendErrorMessage(playerid, "Couldn't spawn at business.");
			SetPlayerPosEx(playerid, Character[playerid][PosX], Character[playerid][PosY], Character[playerid][PosZ], Character[playerid][Interior], Character[playerid][VWorld]);
		}
	}

	else if(Character[playerid][Spawn] == 4)
	{
		if(Character[playerid][Business_2] > 0) SetPlayerPosEx(playerid, Business[Character[playerid][Business_2]][PosX], Business[Character[playerid][Business_2]][PosY], Business[Character[playerid][Business_2]][PosZ], 0 ,0);
		else
		{
			SendErrorMessage(playerid, "Couldn't spawn at business.");
			SetPlayerPosEx(playerid, Character[playerid][PosX], Character[playerid][PosY], Character[playerid][PosZ], Character[playerid][Interior], Character[playerid][VWorld]);
		}
	}

	else if(Character[playerid][Spawn] == 5)
	{
		
		if(Character[playerid][Faction] != 0)
		{
			new fid = GetFactionIDFromSQLID(Character[playerid][Faction]);
			SetPlayerPosEx(playerid, Factions[fid][PosX], Factions[fid][PosY], Factions[fid][PosZ], 0, 0);
		}
		else
		{
			SendErrorMessage(playerid, "Couldn't spawn at faction spawn.");
			SetPlayerPosEx(playerid, Character[playerid][PosX], Character[playerid][PosY], Character[playerid][PosZ], Character[playerid][Interior], Character[playerid][VWorld]);
		}
	}

	else SetPlayerPosEx(playerid, Character[playerid][PosX], Character[playerid][PosY], Character[playerid][PosZ], Character[playerid][Interior], Character[playerid][VWorld]); 


	if(Character[playerid][Cuffed] == 1) 
	{
		SetPlayerSpecialAction(playerid,SPECIAL_ACTION_CUFFED);
	}

	return 1;
}


CMD:changespawn(playerid, params[])
{
	new str[128], dialog[600];
 	format(str, sizeof(str), "(0) Noob Spawn\n(1) Last Position\n");
    strcat(dialog, str, sizeof(dialog));
	if(Character[playerid][House])
	{
	 	format(str, sizeof(str), "(2) %s\n", Houses[Character[playerid][House]][Name]);
	    strcat(dialog, str, sizeof(dialog));
	}
	if(Character[playerid][Business_1])
	{
	 	format(str, sizeof(str), "(3) %s\n", Business[Character[playerid][Business_1]][Name]);
	    strcat(dialog, str, sizeof(dialog));
	}
	if(Character[playerid][Business_2])
	{
	 	format(str, sizeof(str), "(4) %s\n", Business[Character[playerid][Business_2]][Name]);
	    strcat(dialog, str, sizeof(dialog));
	}
	if(Character[playerid][Faction])
	{
		format(str, sizeof(str), "(5) Faction Spawn");
    	strcat(dialog, str, sizeof(dialog));
	}
	Dialog_Show(playerid, ChangeSpawn, DIALOG_STYLE_LIST, "Change Character Spawn", dialog,"Select","Cancel");
	return 1;
}

Dialog:ChangeSpawn(playerid, response, listitem, inputtext[])
{
	if(!response) return 0;

	new spawnid[6], finalid;
    strmid(spawnid, inputtext, strfind(inputtext, "(") + 1,  strfind(inputtext, ")"));
    finalid = strval(spawnid);
	MYSQL_Update_Character(playerid, "Spawn", finalid);

	Character[playerid][Spawn] = finalid;
	SendClientMessage(playerid, COLOR_GREEN, "Spawn updated.");
    return 1;
}

forward CheckActivity(playerid);
public CheckActivity(playerid)
{
	new Float:pos[3];
	GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
	if(InactivtyCheck_X[playerid] == pos[0] && InactivtyCheck_Y[playerid] == pos[1] && InactivtyCheck_Z[playerid] == pos[2] && gettime() - LastCommandTime[playerid] > 899)
	{
		new str[128];
		format(str, sizeof(str), "%s has been kicked for inactivty.", GetRoleplayName(playerid));
		SendPunishmentMessage(str);
		KickPlayer(playerid);
	}
	else
	{
		InactivtyCheck_X[playerid] = pos[0];
		InactivtyCheck_Y[playerid] = pos[1];
		InactivtyCheck_Z[playerid] = pos[2];
	}
	return 1;
}

stock Register(playerid)
{
    
	TogglePlayerSpectating(playerid, 0);
	SetSpawnInfo(playerid, NO_TEAM, Character[playerid][Skin], 258.4893,-41.4008,1002.0234, 0, 0, 0, 0, 0, 0, 0);
	SpawnPlayer(playerid);
	
    Character[playerid][Bank] = 5000;
 	Character[playerid][Level] = 1;
	Character[playerid][PosX] = -204.5245;
	Character[playerid][PosY] = 1119.2860;
	Character[playerid][PosZ] = 19.7422;
	Character[playerid][Skin] = 1;
	Character[playerid][Age] = 18;
	LoggedIn[playerid] = true;
	Character[playerid][ClothesSelection] = 1;
	
	SetSelectionPos(playerid);
	SetPlayerSkinEx(playerid, Character[playerid][Skin]);
    SetPlayerMoneyEx(playerid, 1000);

	
	Dialog_Show(playerid, REG1, DIALOG_STYLE_INPUT, ""COL_BLUE"Character Setup", ""COL_WHITE"Let's start off with your age, how old are you?","Continue","");
	return 1;
}


stock SetSelectionPos(playerid)
{
	SetPlayerPos(playerid, 184.6707, -88.0618, 1002.0234);
	SetPlayerFacingAngle(playerid, 90.0);
	
	SetPlayerInterior(playerid, 18);
	SetPlayerVirtualWorld(playerid, playerid + 1000);

	SetPlayerCameraPos(playerid,181.6707, -88.0618, 1002.0234);
	SetPlayerCameraLookAt(playerid,181.6707, -88.0618, 1002.0234);
	
	TogglePlayerControllable(playerid, 0);
	return 1;
}




#define WRONG 0
#define CORRECT 1
#define BANNED 2


new QAnswer[MAX_PLAYERS] = 0;

new QuizQuestions[][][] = {

	{"1", "[QUIZ] Is it ever acceptable to ban evade?", " (A) No, doing so will result in the loss of any chance of getting unbanned. \n (B) Yes, unless you were caught hacking. \n (C) No, unless you feel that you've been wrongfully banned. \n (D) No, unless any player tells you otherwise."},
	{"2", "[QUIZ] Are certain hacks permitted on the server?", " (A) Yes, a very small proportion of hacks are indeed permitted for use. \n (B) No, under no circumstances should hacks be used/installed when playing on this server. \n (C) No, unless an individual with high authority creates an extenuating circumstance for you and gives you the go-ahead. \n (D) Indeed, all hacks can be used provided that they are used sensibly."},
	{"3", "[QUIZ] Which of the following adheres to the correct use of an expression of quantity?", " (A) 1 Grands \n (B) 1 Millions \n (C) 1 Million \n (D) 5 Millions."},
	{"2", "[QUIZ] How can the term 'METAGAMING' be defined?", " (A) Messing around OOCly. \n (B) Using information obtained OOC'ly in an IC situation.\n (C) Using information obtained IC'ly in an OOC situation.\n (D) Forcing certain actions upon a player."},
	{"4", "[QUIZ] How can the term 'POWERGAMING' be defined?", " (A) The act of acquiring a position of power within the server. \n (B) Using the OOC chat IC'ly. \n (C) Acting in a realistic manner that can be appreciated by all. \n (D) None of the above."},
	{"1", "[QUIZ] How can the term 'Money Farming' be defined?", " (A) Creating Characters for the sole purpose of gaining money. \n (B) Adopting a farm IC'ly, and selling goods produced by this farm with the intention to make profit. \n (C) Taking on the role of a homeless individual and begging others for money with adequate role-play. \n (D) Approaching other community members and offering to pay IRL cash in return for IG cash."},
	{"3", "[QUIZ] What is the correct definition of the abbreviation 'IC'?", " (A) In Chapter - A specific chapter in your character's life. \n (B) In Church - The act of role-playing within a church. \n (C) In Character - Taking the role of your character and acting realistically and appropriately whilst doing so. \n (D) Idiotic Characters - The concept of role-playing characters of the idiotic nature."},
	{"3", "[QUIZ] Select the proper form of a /me.", " (A) /me there is a bottle by my feet. \n (B) /me you would hear the vehicle screeching to a halt. \n (C) /me rotates his head as he catches a glimpse of the suited man."},
	{"2", "[QUIZ] Select the proper form of a /do.", " (A) /do paces himself to his intended destination, panting heavily upon arrival. \n (B) /do Large quantities of blood would be seen cascading down from my receding hairline. \n (C) /do Places his dominant hand on the his waist, as he swiftly lifts his shirt and withdraws the pistol from his waistline. \n (D) /do What do you think you're doing?"},
	{"2", "[QUIZ] What is the correct usage of the standard IC chat?", " (A) Hey, how long have you been role-playing on this server? \n (B) Greetings, the name's Donovan, but you may call me Don. \n (C) Woah, what is that name tag hovering over your head and where can I procure one? \n (D) What is the CMD to check which administrator are online at the moment?"},
	{"4", "[QUIZ] What is the expected way to speak to an administrator when requesting for assistance?", " (A) Uh, where the fuck is my car, you fucking knob? \n (B) I just logged in and I can't seem to see car anywhere, TP it to me this instant. \n (C) This guy in front of me has absolutely no idea how to RP, ban him now. \n (D) Hi, I was wondering if you could possibly TP to me, I appear to be experiencing a bug that requires your attention."},
	{"4", "[QUIZ] Which of the following is expected of you when playing on this server?", " (A) Act politely in the IC chat, avoid any illegal role-play whatsoever. \n (B) Role-playing with others at all times, as oppose to role-playing passively. \n (C) Logging in with a ping that never exceeds 100 or more. \n (D) Role-playing realistically and to the standards that satisfy that of SC:RP."},
	{"1", "[QUIZ] What is the threshold in relation to the things you are permitted to role-play?", " (A) Non-existent, with the exception of pedophilia and so long as the actions demonstrated are realistic. \n (B) Illegal role-play - Under no circumstances should such role-play be exercised. \n (C) Passive role-play - Role-play must always involve other parties for it to be regarded as realistic. \n (D) None of the above."},
	{"3", "[QUIZ] What is the minimum age to play on this server?", " (A) 18. \n (B) 16. \n (C) There is none, so long as the standards of English and the standards of role-play upholds what is expected on SC:RP. \n (D)  14."}, 
	{"4", "[QUIZ] Are OOC insults permitted in this community?", " (A) Yes, but only when the opposing party has warranted the particular insult. \n (B) Yes, members who partake in the community must neglect all emotions and simply ignore insults that are thrown towards them. \n (C) No, unless you are conversing with an administrator. \n (D) No, under no circumstances should words of such nature be undertook."}
};

stock DBNameCheck(playerid, string[])
{
	new query[400];
	mysql_format(SQL_CONNECTION, query, sizeof(query), "SELECT * FROM Characters WHERE Name = '%e' LIMIT 1", string);
	mysql_tquery(SQL_CONNECTION, query, "FreeNameCheck", "i", playerid);
	return 1;
}
forward FreeNameCheck(playerid);
public FreeNameCheck(playerid)
{
 	if(cache_num_rows())
    {
   		 SendErrorMessage(playerid, "Name taken.");
   		 format(Character[playerid][Username], 32, "");
		 Dialog_Show(playerid, CREATECHARACTER, DIALOG_STYLE_INPUT, "Character Creation", "Please enter your new character's (roleplay)name, it must include the underscore('_'):", "Create","Cancel");

    }
    else
    {
        	SetPlayerName(playerid, Character[playerid][Username]);
	        new query[400];
   			GetPlayerIp(playerid, Character[playerid][RegisterIP], 16);
	    	mysql_format(SQL_CONNECTION, query, sizeof(query), "INSERT INTO Characters (A_ID, Name, RegisterIP, RegisterDate) VALUES(%d, '%e','%e', %d)", Account[playerid][SQLID], Character[playerid][Username], Character[playerid][RegisterIP], gettime());
			mysql_tquery(SQL_CONNECTION, query, "GetCharacterID", "i", playerid);
			Register(playerid);
    }
	return 1;
}
stock Quiz(playerid, section)
{
	
    if(section == 1)
	{
		Dialog_Show(playerid, QUIZ1, DIALOG_STYLE_LIST, "[QUIZ] Do you know how to Roleplay?"," (A) Yes\n (B) No","Select","");
	}
    else
	{
	    new rand = random(sizeof(QuizQuestions));

	    CreateSpacer(playerid, 10);

	    format(QAnswer[playerid], 2, "%d", strval(QuizQuestions[rand][0]));

		Dialog_Show(playerid, QUIZ2, DIALOG_STYLE_LIST, QuizQuestions[rand][1], QuizQuestions[rand][2],"Select","");

		SendSplitMessage(playerid, COLOR_SLATEGRAY, QuizQuestions[rand][1]);
		SendSplitMessage(playerid, COLOR_WHITE, QuizQuestions[rand][2]);
	}
	return 1;
}

Dialog:QUIZ1(playerid, response, listitem, inputtext[])
{
	if(listitem == 0)
	{
	    Quiz_Info(playerid, CORRECT, 2);
    }
    else
    {
		Quiz_Info(playerid, BANNED, 0);
    }
    return 1;
}

stock NameValidator(pname[])
{
    new underline=0;
    //GetPlayerName(playerid, pname, sizeof(pname));pname[MAX_PLAYER_NAME],
    if(strfind(pname,"[",true) != (-1)) return 0;
    else if(strfind(pname,"]",true) != (-1)) return 0;
    else if(strfind(pname,"$",true) != (-1)) return 0;
    else if(strfind(pname,"(",true) != (-1)) return 0;
    else if(strfind(pname,")",true) != (-1)) return 0;
    else if(strfind(pname,"=",true) != (-1)) return 0;
    else if(strfind(pname,"@",true) != (-1)) return 0;
    else if(strfind(pname,"0",true) != (-1)) return 0;
    else if(strfind(pname,"1",true) != (-1)) return 0;
    else if(strfind(pname,"2",true) != (-1)) return 0;
    else if(strfind(pname,"3",true) != (-1)) return 0;
    else if(strfind(pname,"4",true) != (-1)) return 0;
    else if(strfind(pname,"5",true) != (-1)) return 0;
    else if(strfind(pname,"6",true) != (-1)) return 0;
    else if(strfind(pname,"7",true) != (-1)) return 0;
    else if(strfind(pname,"8",true) != (-1)) return 0;
    else if(strfind(pname,"9",true) != (-1)) return 0;
    new maxname = strlen(pname);
    for(new i=2; i<maxname; i++)
    {
       if(pname[i] == '_') underline ++;
    }
    if(underline != 1) return 0;

    else
    {
    	return 1;
    }

}

Dialog:CREATECHARACTER(playerid, response, listitem, inputtext[])
{
	if(!response) 
	{
		KickPlayer(playerid);
		return 0;
	}

    else if(response)
    {
        if(NameValidator(inputtext))
		{
			format(Character[playerid][Username], 32, "%s", inputtext);
			DBNameCheck(playerid, inputtext);
		}
		else
		{
		    SendErrorMessage(playerid, "Invalid name.");
		    Dialog_Show(playerid, CREATECHARACTER, DIALOG_STYLE_INPUT, "Character Creation", "Please enter your new character's (roleplay)name, it must include the underscore('_'):", "Create","Cancel");
		}
	}
    return 1;
}


Dialog:QUIZ2(playerid, response, listitem, inputtext[])
{
	if(listitem + 1 == strval(QAnswer[playerid]))
	{
		if(Character[playerid][QuizProgress] < 5)
		{
			Character[playerid][QuizProgress]++;
			Quiz_Info(playerid, CORRECT, 3);
		}
		else
		{
			CreateSpacer(playerid, 10);
			Character_Create(playerid);
		}
	}
	else
	{
		Quiz_Info(playerid, WRONG, 0);
	}
    return 1;
}

stock Quiz_Info(playerid, info, section)
{
	if(info == 0)
	{
	    InfoBoxForPlayer(playerid, "That is the ~r~INCORRECT ~w~please review your answer - reconnect to try the quiz again.");
        KickPlayer(playerid);
	}
	if(info == 1)
	{
	    InfoBoxForPlayer(playerid, "Good job, you got the answer ~g~CORRECT~w~!");
	    Quiz(playerid, section);
	}
	else if(info == 2)
	{
		IssueBan(playerid, "Auto", "Failed quiz");
        InfoBoxForPlayer(playerid, "~r~You don't know how to roleplay thus have been banned from this ~g~HEAVY~r~ roleplay server.");
	}
	return 1;
}



forward LoadObjects();
public LoadObjects()
{
	if(cache_num_rows())
    {
        for(new i = 0; i<cache_num_rows(); i++)
        {
			Objects[i+1][SQLID] = cache_get_field_content_int(i, "SQLID", SQL_CONNECTION);
			cache_get_field_content(i, "Name", Objects[i+1][Name], SQL_CONNECTION, 126);
			Objects[i+1][Model] = cache_get_field_content_int(i, "Model", SQL_CONNECTION);
			Objects[i+1][PosX] = cache_get_field_content_float(i, "PosX", SQL_CONNECTION);
			Objects[i+1][PosY] = cache_get_field_content_float(i, "PosY", SQL_CONNECTION);
		 	Objects[i+1][PosZ] = cache_get_field_content_float(i, "PosZ", SQL_CONNECTION);
			Objects[i+1][AngX] = cache_get_field_content_float(i, "AngX", SQL_CONNECTION);
			Objects[i+1][AngY] = cache_get_field_content_float(i, "AngY", SQL_CONNECTION);
			Objects[i+1][AngZ] = cache_get_field_content_float(i, "AngZ", SQL_CONNECTION);
			Objects[i+1][World] = cache_get_field_content_int(i, "World", SQL_CONNECTION);
			Objects[i+1][Interior] = cache_get_field_content_int(i, "Interior", SQL_CONNECTION);
			Objects[i+1][Movable] = cache_get_field_content_int(i, "Movable", SQL_CONNECTION);
			Objects[i+1][NewX] = cache_get_field_content_float(i, "NewX", SQL_CONNECTION);
			Objects[i+1][NewY] = cache_get_field_content_float(i, "NewY", SQL_CONNECTION);
			Objects[i+1][NewZ] = cache_get_field_content_float(i, "NewZ", SQL_CONNECTION);
			Objects[i+1][aNewX] = cache_get_field_content_float(i, "aNewX", SQL_CONNECTION);
			Objects[i+1][aNewY] = cache_get_field_content_float(i, "aNewY", SQL_CONNECTION);
			Objects[i+1][aNewZ] = cache_get_field_content_float(i, "aNewZ", SQL_CONNECTION);
			Objects[i+1][Faction] = cache_get_field_content_int(i, "Faction", SQL_CONNECTION);

			Total_Objects_Created++;

	        if(Objects[i+1][Model] >= 1)
	        {
				Objects[i+1][ObjectID] = CreateDynamicObject(Objects[i+1][Model], Objects[i+1][PosX], Objects[i+1][PosY], Objects[i+1][PosZ], Objects[i+1][AngX], Objects[i+1][AngY], Objects[i+1][AngZ], Objects[i+1][World], Objects[i+1][Interior], -1, 200.0, 0.0);
			
			}
		}
	}
	printf("[MYSQL]: %d Objects have been successfully loaded from the database.", Total_Objects_Created);
	return 1;
}

forward OnPlayerEditDynamicObject(playerid, objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz);
public OnPlayerEditDynamicObject(playerid, objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz)
{
	new fID = -1;
	for(new i = 1; i < MAX_OBJECTZ; i++)
	{
	    if(Objects[i][ObjectID] == objectid)
		{
			fID = i;
			break;
		}
	}

	if(fID == -1) return 1;

	if(Character[playerid][MovableObject] == 1)
	{
		if(response == EDIT_RESPONSE_FINAL)
		{
			new query[280];
			mysql_format(SQL_CONNECTION, query, sizeof(query), "UPDATE Objects SET Movable= 1, NewX = %f, NewY = %f, NewZ = %f, aNewX = %f, aNewY = %f, aNewZ = %f WHERE SQLID = %d LIMIT 1", x, y, z, rx, ry, rz, Objects[fID][SQLID]);
	    	mysql_tquery(SQL_CONNECTION, query);
			Objects[fID][NewX] = x;
			Objects[fID][NewY] = y;
			Objects[fID][NewZ] = z;
			Objects[fID][aNewX] = rx;
			Objects[fID][aNewY] = ry;
			Objects[fID][aNewZ] = rz;
			Objects[fID][Movable] = 1;

		    SetDynamicObjectPos(objectid, Objects[fID][PosX], Objects[fID][PosY], Objects[fID][PosZ]);
		    SetDynamicObjectRot(objectid, Objects[fID][AngX], Objects[fID][AngY], Objects[fID][AngZ]);
		    Character[playerid][MovableObject] = 0;

		    SendClientMessage(playerid, COLOR_LIMEGREEN, "Object successfully updated! (moveable)");
	    	return 1;
		}
	}


	else if(Character[playerid][DeleteingObject] == 0)
	{
		if(response == EDIT_RESPONSE_FINAL)
		{
			new query[280];
			mysql_format(SQL_CONNECTION, query, sizeof(query), "UPDATE Objects SET PosX = %f, PosY = %f, PosZ = %f, AngX = %f, AngY = %f, AngZ = %f WHERE SQLID = %d LIMIT 1", x, y, z, rx, ry, rz, Objects[fID][SQLID]);
	    	mysql_tquery(SQL_CONNECTION, query);
			Objects[fID][PosX] = x;
			Objects[fID][PosY] = y;
			Objects[fID][PosZ] = z;
			Objects[fID][AngX] = rx;
			Objects[fID][AngY] = ry;
			Objects[fID][AngZ] = rz;
	    	return 1;
		}
	}

	else if(Character[playerid][DeleteingObject] == 1)
	{
		new query[128], str[128];
		mysql_format(SQL_CONNECTION, query, sizeof(query), "DELETE FROM `%e`.`Objects` WHERE `Objects`.`SQLID` = %d", SQL_DB, Objects[fID][SQLID]);
		mysql_tquery(SQL_CONNECTION, query);

		Total_Objects_Created --;
		DestroyDynamicObject(Objects[fID][ObjectID]);


		format(str, sizeof(str), "%s has deleted a object(ID:%d).", GetRoleplayName(playerid), fID);
		SendAdminsMessage(1, COLOR_ORANGERED, str);

		ResetObjectVariables(fID);
		Character[playerid][DeleteingObject] = 0;
	}

	if(response == EDIT_RESPONSE_CANCEL)
	{
	    SetDynamicObjectPos(objectid, Objects[fID][PosX], Objects[fID][PosY], Objects[fID][PosZ]);
	    SetDynamicObjectRot(objectid, Objects[fID][AngX], Objects[fID][AngY], Objects[fID][AngZ]);
	    Character[playerid][DeleteingObject] = 0;
	    Character[playerid][MovableObject] = 0;
	}
	return 1;
}


stock ReloadObjects()
{

	for(new id = 0; id < MAX_OBJECTZ; id++)
    {
        if(IsValidDynamicObject(Objects[id][ObjectID]))
        {
			DestroyDynamicObject(Objects[id][ObjectID]);
			ResetObjectVariables(id);
			Total_Objects_Created --;
		}
	}
	mysql_tquery(SQL_CONNECTION, "SELECT * FROM `Objects`", "LoadObjects");
	return 1;
}

CMD:reloadobjects(playerid, params[])
{
    if(Account[playerid][Admin] >= 6)
	{
		ReloadObjects();
	}
	return 1;
}

stock GetInFrontOfPlayer(playerid, &Float:x, &Float:y, Float:distance)
{
    // Created by Y_Less

    new Float:a;

    GetPlayerPos(playerid, x, y, a);
    GetPlayerFacingAngle(playerid, a);

    if (GetPlayerVehicleID(playerid)) 
    {
        GetVehicleZAngle(GetPlayerVehicleID(playerid), a);
    }

    x += (distance * floatsin(-a, degrees));
    y += (distance * floatcos(-a, degrees));
}

CMD:createobject(playerid, params[])
{
    if(Account[playerid][Admin] >= 6)
	{
	    new option1, option2[64], query[280], Float:pos[3], oint, oworld;
	    if(sscanf(params, "ds[64]", option1, option2)) return SendClientMessage(playerid, COLOR_GRAY, "/createobject [modelid] [info]");
		{
		    GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
		    GetInFrontOfPlayer(playerid, pos[0], pos[1], 1);
		    oint = GetPlayerInterior(playerid);
		    oworld = GetPlayerVirtualWorld(playerid);
			new fID = CreateDynamicObject(option1, pos[0], pos[1], pos[2], 0, 0, 0, oworld, oint, -1, 200.0, 0.0);
		    mysql_format(SQL_CONNECTION, query, sizeof(query), "INSERT INTO Objects (Name,Model,PosX,PosY,PosZ,World,Interior) VALUES ('%e', %d, %f, %f, %f, %d, %d)",
									option2,
									option1,
									pos[0],
									pos[1],
									pos[2],
									oworld,
									oint);

			mysql_tquery(SQL_CONNECTION, query, "GetObjectID", "i", fID);

            Objects[fID][ObjectID] = fID;
			Objects[fID][PosX] = pos[0];
			Objects[fID][PosY] = pos[1];
			Objects[fID][PosZ] = pos[2];
			Objects[fID][AngX] = 0;
			Objects[fID][AngY] = 0;
			Objects[fID][AngZ] = 0;
			Objects[fID][Model] = option1;
			Objects[fID][Interior] = oint;
			Objects[fID][World] = oworld;
			format(Objects[fID][Name], 64, "%e", option2);

			Total_Objects_Created++;
			SendClientMessage(playerid, COLOR_GRAY, "Model Created");
		}
	}
	return 1;
}
forward GetObjectID(fID);
public GetObjectID(fID)
{
	Objects[fID][SQLID] = cache_insert_id();
	printf("%d %d", Objects[fID][SQLID], fID);
	return 1;
}


stock ResetObjectVariables(fID)
{
	Objects[fID][SQLID] = 0;
	Objects[fID][ObjectID] = 0;
	Objects[fID][Name] = 0;
	Objects[fID][Model] = 0;
	Objects[fID][PosX] = 0;
	Objects[fID][PosY] = 0;
	Objects[fID][PosZ] = 0;
	Objects[fID][AngX] = 0;
	Objects[fID][AngY] = 0;
	Objects[fID][AngZ] = 0;
	Objects[fID][Movable] = 0;
	Objects[fID][NewX] = 0;
	Objects[fID][NewY] = 0;
	Objects[fID][NewZ] = 0;
	Objects[fID][aNewX] = 0;
	Objects[fID][aNewY] = 0;
	Objects[fID][aNewZ] = 0;
	Objects[fID][Faction] = 0;
	return 1;
}



CMD:deleteobject(playerid, params[])
{
	if(Account[playerid][Admin] == 6)
	{
		SendClientMessage(playerid, COLOR_YELLOW, "WARNING: To delete an object click on it and press the 'save' button. If you would like to abandon the deletion process press ESC.");
     	Character[playerid][DeleteingObject] = 1;
     	SelectObject(playerid);
	}
	else
	{
	    SendErrorMessage(playerid, ERROR_ADMIN);
	}
	return 1;
}

CMD:makemovableobject(playerid, params[])
{
	if(Account[playerid][Admin] == 6)
	{
		SendClientMessage(playerid, COLOR_YELLOW, "WARNING: You are about to create a movable object.");
     	Character[playerid][MovableObject] = 1;
     	SelectObject(playerid);
	}
	else
	{
	    SendErrorMessage(playerid, ERROR_ADMIN);
	}
	return 1;
}


public OnPlayerRequestClass(playerid,classid)
{
	SpawnPlayer(playerid);
	SetPlayerSkin(playerid, Character[playerid][Skin]);
    return 1;
}

forward OnPlayerSelectDynamicObject(playerid, objectid, modelid, Float:x, Float:y, Float:z);
public OnPlayerSelectDynamicObject(playerid, objectid, modelid, Float:x, Float:y, Float:z)
{
	new fID = -1;
	for(new i = 1; i < MAX_OBJECTZ; i++)
	{
	    if(Objects[i][ObjectID] == objectid)
		{
			fID = i;
			break;
		}
	}

	if(fID == -1) return 1;


	if(IsValidDynamicObject(Objects[fID][ObjectID]))
    {
    	EditDynamicObject(playerid, Objects[fID][ObjectID]);
    }
	return 1;
}


CMD:selectobject(playerid, params[])
{
    if(Account[playerid][Admin] >= 6)
	{
	    new option1[24];
	    if(sscanf(params, "s[24]", option1)) return SendClientMessage(playerid, COLOR_GRAY, "/selectobject [mouse/near]");
		{
	 		if(!strcmp(option1, "mouse", true))
			{
	    		SelectObject(playerid);
	        }

	 		if(!strcmp(option1, "near", true))
			{
			    for(new i = 1; i < MAX_OBJECTZ;i++)
			    {
					if(IsPlayerInRangeOfPoint(playerid, 2.0, Objects[i][PosX], Objects[i][PosY], Objects[i][PosZ]))
					{
					    EditDynamicObject(playerid, Objects[i][ObjectID]);
					    return 1;
					}
			    }
	        }
		}
	}
	else
	{
		SendErrorMessage(playerid, ERROR_ADMIN);
	}
	return 1;
}
ALTCMD:selecto->selectobject;

CMD:door(playerid, params[])
{

    new option1[24];
    if(sscanf(params, "s[24]", option1)) return SendClientMessage(playerid, COLOR_GRAY, "/door [open/close]");
	{
		new Object = InRangeOfMovableFactionObject(playerid, 2.0);
	    if(Object)
    	{
    		if(Objects[Object][Faction] == Character[playerid][Faction] && Objects[Object][Model] == 1495 || Objects[Object][Model] == 19303)
			{
		 		if(!strcmp(option1, "open", true))
				{
		    		MoveDynamicObject(Objects[Object][ObjectID], Objects[Object][NewX], Objects[Object][NewY], Objects[Object][NewZ], 1.0, Objects[Object][aNewX], Objects[Object][aNewY], Objects[Object][aNewZ]);
		        }

    	 		if(!strcmp(option1, "close", true))
				{
		    		MoveDynamicObject(Objects[Object][ObjectID], Objects[Object][PosX], Objects[Object][PosY], Objects[Object][PosZ], 1.0, Objects[Object][AngX], Objects[Object][AngY], Objects[Object][AngZ]);
		        }
	        }
	        else SendErrorMessage(playerid, "You don't have the keys to this door.");
	    }
	    else SendErrorMessage(playerid, ERROR_LOCATION);
    }


	return 1;
}

CMD:gate(playerid, params[])
{

    new option1[24];
    if(sscanf(params, "s[24]", option1)) return SendClientMessage(playerid, COLOR_GRAY, "/gate [open/close]");
	{
		new Object = InRangeOfMovableFactionObject(playerid, 6.5);
	    if(Object)
    	{
    		if(Objects[Object][Faction] == Character[playerid][Faction] && Objects[Object][Model] == 2957)
			{
		 		if(!strcmp(option1, "open", true))
				{
		    		MoveDynamicObject(Objects[Object][ObjectID], Objects[Object][NewX], Objects[Object][NewY], Objects[Object][NewZ], 1.0, Objects[Object][aNewX], Objects[Object][aNewY], Objects[Object][aNewZ]);
		        }

    	 		if(!strcmp(option1, "close", true))
				{
		    		MoveDynamicObject(Objects[Object][ObjectID], Objects[Object][PosX], Objects[Object][PosY], Objects[Object][PosZ], 1.0, Objects[Object][AngX], Objects[Object][AngY], Objects[Object][AngZ]);
		        }
	        }
	        else SendErrorMessage(playerid, "You don't have the remote for this gate.");
	    }
	    else SendErrorMessage(playerid, ERROR_LOCATION);
    }


	return 1;
}

forward LoadIcons();
public LoadIcons()
{
	new str[300];
	if(cache_num_rows())
    {
        for(new i = 0; i<cache_num_rows(); i++)
        {
			Icons[i][SQLID] = cache_get_field_content_int(i, "SQLID", SQL_CONNECTION);
			cache_get_field_content(i, "Name", Icons[i][Name], SQL_CONNECTION, 32);
			Icons[i][PosX] = cache_get_field_content_float(i, "PosX", SQL_CONNECTION);
			Icons[i][PosY] = cache_get_field_content_float(i, "PosY", SQL_CONNECTION);
			Icons[i][PosZ] = cache_get_field_content_float(i, "PosZ", SQL_CONNECTION);
			Icons[i][Interior] = cache_get_field_content_int(i, "Interior", SQL_CONNECTION);
			Icons[i][World] = cache_get_field_content_int(i, "World", SQL_CONNECTION);
			Icons[i][Type] = cache_get_field_content_int(i, "Type", SQL_CONNECTION);
			Icons[i][Faction] = cache_get_field_content_int(i, "Faction", SQL_CONNECTION);
			Icons[i][Icon] = cache_get_field_content_int(i, "Icon", SQL_CONNECTION);

			Total_Icons_Created++;
	        if(Icons[i][Type] >= 1)
	        {
				format(str, sizeof(str), "%s", Icons[i][Name]);
	  			Icons[i][LabelID] = CreateDynamic3DTextLabel(str, COLOR_WHITE, Icons[i][PosX],Icons[i][PosY],Icons[i][PosZ], 100, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, -1, -1, -1, 10.0);
				Icons[i][PickupID] = CreateDynamicPickup(Icons[i][Icon], 23, Icons[i][PosX], Icons[i][PosY], Icons[i][PosZ], Icons[i][World], Icons[i][Interior], -1, 250);
			}
			if(Icons[i][Faction] > 0)
			{
				
			}
		}
	}
	printf("[MYSQL]: %d Icons have been successfully loaded from the database.", Total_Icons_Created);
	return 1;
}

forward LoadIcon(id);
public LoadIcon(id)
{
	new str[300];
	if(cache_num_rows())
    {

		Icons[id][SQLID] = cache_get_field_content_int(0, "SQLID", SQL_CONNECTION);
		cache_get_field_content(0, "Name", Icons[id][Name], SQL_CONNECTION, 126);
		Icons[id][PosX] = cache_get_field_content_float(0, "PosX", SQL_CONNECTION);
		Icons[id][PosY] = cache_get_field_content_float(0, "PosY", SQL_CONNECTION);
		Icons[id][PosZ] = cache_get_field_content_float(0, "PosZ", SQL_CONNECTION);
		Icons[id][Interior] = cache_get_field_content_int(0, "Interior", SQL_CONNECTION);
		Icons[id][World] = cache_get_field_content_int(0, "World", SQL_CONNECTION);
		Icons[id][Type] = cache_get_field_content_int(0, "Type", SQL_CONNECTION);
		Icons[id][Faction] = cache_get_field_content_int(0, "Faction", SQL_CONNECTION);
		Icons[id][Icon] = cache_get_field_content_int(0, "Icon", SQL_CONNECTION);

		Total_Icons_Created++;
        if(Icons[id][Type] >= 1)
        {
			format(str, sizeof(str), "%s", Icons[id][Name]);
  			Icons[id][LabelID] = CreateDynamic3DTextLabel(str, COLOR_WHITE, Icons[id][PosX],Icons[id][PosY],Icons[id][PosZ], 100, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, -1, -1, -1, 10.0);
			Icons[id][PickupID] = CreateDynamicPickup(Icons[id][Icon], 23, Icons[id][PosX], Icons[id][PosY], Icons[id][PosZ], Icons[id][World], Icons[id][Interior], -1, 250);
		}
		
	}
	printf("[MYSQL]: Icon %d has been successfully reloaded from the database.", id);
	return 1;
}

stock InformationBox(playerid, text[])
{
    TextDrawSetString(InfoBox[playerid], text);
	TextDrawShowForPlayer(playerid, InfoBox[playerid]);
    InformationBoxTimer[playerid] = SetTimerEx("HideInformationBox", SECONDS(1), true, "d", playerid);
	return 1;
}

forward HideInformationBox(playerid);
public HideInformationBox(playerid)
{
	if(gettime() - LastPickup[playerid] > 4)
	{
		PickedUpPickup[playerid] = false;
		TextDrawHideForPlayer(playerid, InfoBox[playerid]);
		KillTimer(InformationBoxTimer[playerid]);
	}
	return 1;
}

#define ICON_NONE 0
#define ICON_REG_DEALERSHIP 1
#define ICON_SUPER_DEALERSHIP 2
#define ICON_COM_DEALERSHIP 3
#define ICON_PAYDAY 4
#define ICON_BANK 5
#define ICON_ATM 6
#define ICON_PAYPHONE 7
#define ICON_SCRAPDEALER 9
#define ICON_SPRAY 10
#define ICON_REPAIR 11
#define ICON_REGDEALERSHIP 12


public OnPlayerPickUpDynamicPickup(playerid, pickupid)
{
	if(PickedUpPickup[playerid] == false)
	{
		PickedUpPickup[playerid] = true;
	    LastPickup[playerid] = gettime();
		new i;
	 	for(i = 0; i < MAX_BIZ; i++)
	    {
	        if(pickupid == Business[i][PickupID])
	        {
			    new str[128];
			    format(str, sizeof(str), "~b~ %s ~n~ ~w~ Use /enter to enter this establishment.", Business[i][Name]);
			    InformationBox(playerid, str);
			    return 1;
			}
		}

	 	for(i = 0; i < MAX_HOUSES; i++)
	    {
	        if(pickupid == Houses[i][PickupID])
	        {
			    new str[128];
			    format(str, sizeof(str), "~g~ %s ~n~ ~w~ Use /enter to enter this house.", Houses[i][Name]);
			    InformationBox(playerid, str);
			    return 1;
			}
		}

		for(i = 0; i < MAX_ICONS; i++)
		{
			if(pickupid == Icons[i][PickupID])
			{

				if(Icons[i][Type] == 1)  return InformationBox(playerid, "~p~Regular Vehicle Dealership~n~~w~Please use the command ~y~/buyvehicle ~w~to view the dealership's stock!"); 
				else if(Icons[i][Type] == 2)  return InformationBox(playerid, "~p~Supercar Vehicle Dealership~n~~w~Please use the command ~y~/buyvehicle ~w~to view the dealership's stock!");
				else if(Icons[i][Type] == 3)  return InformationBox(playerid, "~p~Commercial Vehicle Dealership~n~~w~Please use the command ~y~/buyvehicle ~w~to view the dealership's stock!");
				else if(Icons[i][Type] == 4)  return InformationBox(playerid, "~g~$$ Payday $$~n~~w~If you have a paycheck you can collect it using the command ~y~/payday~w~. Paydays are obtained every hour if you have played an hour prior.");
				else if(Icons[i][Type] == 5)  return InformationBox(playerid, "~g~Bank~n~~w~To access you bank account do ~y~/balance, /withdraw or /deposit~w~.");
				else if(Icons[i][Type] == 6)  return InformationBox(playerid, "~g~ATM");
				else if(Icons[i][Type] == 7)  return InformationBox(playerid, "~y~PayPhone - Use /payphone to use.");
				else if(Icons[i][Type] == 9)  return InformationBox(playerid, "~p~Scrap Dealer~n~~w~You can sell your vehicle for scrap by using the command ~y~/scrapcar~w~. Please note that this will ~r~DELETE~w~ your vehicle.");
				else if(Icons[i][Type] == 10) return InformationBox(playerid, "~r~Garage~n~~w~To spray your vehicle a different color use the command ~y~/spray [1/2] [color id]~w~.");
				else if(Icons[i][Type] == 11) return InformationBox(playerid, "~g~Repair Garage~n~~w~To repair your vehicle use the command ~y~/repair~w~.");
				else if(Icons[i][Type] == 12) return InformationBox(playerid, "~g~DMV~n~~w~ The driving test cost $1000 to take. To proceed use the command ~y~/dmv~w~.");				
				else if(Icons[i][Type] == 13) return InformationBox(playerid, "~y~Lockers~n~~w~ To access the locker please use ~y~/locker~w~.");
				else if(Icons[i][Type] == 14) return InformationBox(playerid, "~p~Vehicle Modification Center~n~~w~ Mechanics can perform vehicle modifications to personal vehicles here using the command ~y~/vmods~w~.");
				else if(Icons[i][Type] == 15) return InformationBox(playerid, "~b~Faction Weapon Cache~n~~w~ Faction weapons can be bought and equipped here using the command ~y~/weaponcache~w~.~n~~r~WARNING~w~:It is against the rules to distribute faction weapons.");
			}
		}
	}
    return 1;
}

forward LoadVehicles();
public LoadVehicles()
{
	if(cache_num_rows())
    {
        for(new i = 0; i<cache_num_rows(); i++)
        {
	        new vid = GetFreeVehicleSlot();
	        ResetVehicleVariables(vid);
	        validvehicle[vid] = true;
			Vehicles[vid][SQLID] = cache_get_field_content_int(i, "SQLID", SQL_CONNECTION);
			Vehicles[vid][Model] = cache_get_field_content_int(i, "Model", SQL_CONNECTION);
			Vehicles[vid][PosX] = cache_get_field_content_float(i, "PosX", SQL_CONNECTION);
			Vehicles[vid][PosY] = cache_get_field_content_float(i, "PosY", SQL_CONNECTION);
			Vehicles[vid][PosZ] = cache_get_field_content_float(i, "PosZ", SQL_CONNECTION);
			Vehicles[vid][PosA] = cache_get_field_content_float(i, "PosA", SQL_CONNECTION);
			Vehicles[vid][Color1] = cache_get_field_content_int(i, "Color1", SQL_CONNECTION);
			Vehicles[vid][Color2] = cache_get_field_content_int(i, "Color2", SQL_CONNECTION);
			Vehicles[vid][Type] = cache_get_field_content_int(i, "Type", SQL_CONNECTION);
			cache_get_field_content(i, "Plate", Vehicles[vid][Plate], SQL_CONNECTION, 12);
			Vehicles[vid][Locked] = cache_get_field_content_int(i, "Locked", SQL_CONNECTION);
			Vehicles[vid][Fuel] = cache_get_field_content_int(i, "Fuel", SQL_CONNECTION);
			if(Vehicles[vid][Model] > 399 && Vehicles[vid][Model] < 612)
			{
		        new Vehicle = CreateVehicle(Vehicles[vid][Model],Vehicles[vid][PosX],Vehicles[vid][PosY],Vehicles[vid][PosZ],Vehicles[vid][PosA],Vehicles[vid][Color1],Vehicles[vid][Color2], 120);

		//            fuel[Vehicle] = Vehicles[vid][Fuel];
				SetVehicleNumberPlate(Vehicle, Vehicles[vid][Plate]);
		        SetVehicleToRespawn(Vehicle);
		        SetVehicleParamsEx(Vehicle, 0, 0,  alarm[vid], Vehicles[vid][Locked], bonnet[vid], boot[vid], objective[vid]);

				Vehicles[Vehicle][SQLID] = Vehicles[vid][SQLID];
				Vehicles[Vehicle][Type] = Vehicles[vid][Type];
				Vehicles[Vehicle][Owner] = 0;
				Vehicles[Vehicle][Model] = Vehicles[vid][Model];
				Vehicles[Vehicle][PosX] = Vehicles[vid][PosX];
				Vehicles[Vehicle][PosY] = Vehicles[vid][PosY];
				Vehicles[Vehicle][PosZ] = Vehicles[vid][PosZ];
				Vehicles[Vehicle][PosA] = Vehicles[vid][PosA]; 
				Vehicles[Vehicle][Color1] = Vehicles[vid][Color1]; 
				Vehicles[Vehicle][Color2] = Vehicles[vid][Color2]; 
				Vehicles[Vehicle][Faction] = 0; 
				Vehicles[Vehicle][Rank] = 0;
				Vehicles[Vehicle][Fuel] = Vehicles[vid][Fuel];
				Vehicles[Vehicle][Radio] = 0;
		        Total_Vehicles_Created ++;

			}
			else printf("[MYSQL] ERROR LOADING SERVER VEHICLE SQLID: %d",Vehicles[vid][SQLID]);
		}
	}
	printf("[MYSQL]: %d Vehicles have been successfully loaded from the database.", Total_Vehicles_Created);
	return 1;
}


forward LoadFactionVehicles();
public LoadFactionVehicles()
{
	if(cache_num_rows())
    {
        for(new i = 0; i < cache_num_rows(); i++)
        {
	        new vid = GetFreeVehicleSlot();
	        validvehicle[vid] = true;
			Vehicles[vid][SQLID] = cache_get_field_content_int(i, "SQLID", SQL_CONNECTION);
			Vehicles[vid][Model] = cache_get_field_content_int(i, "Model", SQL_CONNECTION);
			Vehicles[vid][PosX] = cache_get_field_content_float(i, "PosX", SQL_CONNECTION);
			Vehicles[vid][PosY] = cache_get_field_content_float(i, "PosY", SQL_CONNECTION);
			Vehicles[vid][PosZ] = cache_get_field_content_float(i, "PosZ", SQL_CONNECTION);
			Vehicles[vid][PosA] = cache_get_field_content_float(i, "PosA", SQL_CONNECTION);
			Vehicles[vid][Color1] = cache_get_field_content_int(i, "Color1", SQL_CONNECTION);
			Vehicles[vid][Color2] = cache_get_field_content_int(i, "Color2", SQL_CONNECTION);
			Vehicles[vid][Type] = cache_get_field_content_int(i, "Type", SQL_CONNECTION);
			cache_get_field_content(i, "Plate", Vehicles[vid][Plate], SQL_CONNECTION, 12);
			Vehicles[vid][Locked] = cache_get_field_content_int(i, "Locked", SQL_CONNECTION);
	        Vehicles[vid][Faction] = cache_get_field_content_int(i, "Faction", SQL_CONNECTION);
	        Vehicles[vid][Rank] = cache_get_field_content_int(i, "Rank", SQL_CONNECTION);
			Vehicles[vid][Fuel] = cache_get_field_content_int(i, "Fuel", SQL_CONNECTION);

	        if(Vehicles[vid][Model] > 399 && Vehicles[vid][Model] < 612)
			{
				new Vehicle = CreateVehicle(Vehicles[vid][Model],Vehicles[vid][PosX],Vehicles[vid][PosY],Vehicles[vid][PosZ],Vehicles[vid][PosA],Vehicles[vid][Color1],Vehicles[vid][Color2], 3600);

				SetVehicleNumberPlate(Vehicle, Vehicles[vid][Plate]);
		        SetVehicleToRespawn(Vehicle);
		        SetVehicleParamsEx(Vehicle, 0, 0,  alarm[vid], Vehicles[vid][Locked], bonnet[vid], boot[vid], objective[vid]);

				Vehicles[Vehicle][SQLID] = Vehicles[vid][SQLID];
				Vehicles[Vehicle][Type] = 3;
				Vehicles[Vehicle][Owner] = 0;
				Vehicles[Vehicle][Model] = Vehicles[vid][Model];
				Vehicles[Vehicle][PosX] = Vehicles[vid][PosX];
				Vehicles[Vehicle][PosY] = Vehicles[vid][PosY];
				Vehicles[Vehicle][PosZ] = Vehicles[vid][PosZ];
				Vehicles[Vehicle][PosA] = Vehicles[vid][PosA]; 
				Vehicles[Vehicle][Color1] = Vehicles[vid][Color1]; 
				Vehicles[Vehicle][Color2] = Vehicles[vid][Color2]; 
				Vehicles[Vehicle][Faction] = Vehicles[vid][Faction]; 
				Vehicles[Vehicle][Rank] = Vehicles[vid][Rank]; 
				Vehicles[Vehicle][Fuel] = Vehicles[vid][Fuel];
				Vehicles[Vehicle][Radio] = 0;
				Total_FactionVehicles_Created ++;
		        Total_Vehicles_Created ++;
	        }
        	else printf("[MYSQL] ERROR LOADING FACTION VEHICLE SQLID: %d",Vehicles[vid][SQLID]);
		}
	}
	printf("[MYSQL]: %d Faction Vehicles have been successfully loaded from the database.", Total_FactionVehicles_Created);
	return 1;
}

forward SpawnFactionVehicles();
public SpawnFactionVehicles()
{
	if(cache_num_rows())
    {
        for(new i = 0; i<cache_num_rows(); i++)
        {
	        new vid = GetFreeVehicleSlot();
	        validvehicle[vid] = true;
			Vehicles[vid][SQLID] = cache_get_field_content_int(0, "SQLID", SQL_CONNECTION);
			Vehicles[vid][Model] = cache_get_field_content_int(0, "Model", SQL_CONNECTION);
			Vehicles[vid][PosX] = cache_get_field_content_float(0, "PosX", SQL_CONNECTION);
			Vehicles[vid][PosY] = cache_get_field_content_float(0, "PosY", SQL_CONNECTION);
			Vehicles[vid][PosZ] = cache_get_field_content_float(0, "PosZ", SQL_CONNECTION);
			Vehicles[vid][PosA] = cache_get_field_content_float(0, "PosA", SQL_CONNECTION);
			Vehicles[vid][Color1] = cache_get_field_content_int(0, "Color1", SQL_CONNECTION);
			Vehicles[vid][Color2] = cache_get_field_content_int(0, "Color2", SQL_CONNECTION);
			Vehicles[vid][Type] = cache_get_field_content_int(0, "Type", SQL_CONNECTION);
			cache_get_field_content(0, "Plate", Vehicles[vid][Plate], SQL_CONNECTION, 12);
			Vehicles[vid][Locked] = cache_get_field_content_int(0, "Locked", SQL_CONNECTION);
	        Vehicles[vid][Faction] = cache_get_field_content_int(0, "Faction", SQL_CONNECTION);
	        Vehicles[vid][Rank] = cache_get_field_content_int(0, "Rank", SQL_CONNECTION);
			Vehicles[vid][Fuel] = cache_get_field_content_int(i, "Fuel", SQL_CONNECTION);
			if(Vehicles[vid][Model] > 399 && Vehicles[vid][Model] < 612)
			{
				new Vehicle = CreateVehicle(Vehicles[vid][Model],Vehicles[vid][PosX],Vehicles[vid][PosY],Vehicles[vid][PosZ],Vehicles[vid][PosA],Vehicles[vid][Color1],Vehicles[vid][Color2], 3600);
		//            fuel[Vehicle] = Vehicles[vid][Fuel];
				SetVehicleNumberPlate(Vehicle, Vehicles[Vehicle][Plate]);
		        SetVehicleToRespawn(Vehicle);
		        SetVehicleParamsEx(Vehicle, 0, 0,  alarm[vid], Vehicles[Vehicle][Locked], bonnet[Vehicle], boot[Vehicle], objective[Vehicle]);

				Vehicles[Vehicle][SQLID] = Vehicles[vid][SQLID];
				Vehicles[Vehicle][Type] = 3;
				Vehicles[Vehicle][Owner] = 0;
				Vehicles[Vehicle][Model] = Vehicles[vid][Model];
				Vehicles[Vehicle][PosX] = Vehicles[vid][PosX];
				Vehicles[Vehicle][PosY] = Vehicles[vid][PosY];
				Vehicles[Vehicle][PosZ] = Vehicles[vid][PosZ];
				Vehicles[Vehicle][PosA] = Vehicles[vid][PosA]; 
				Vehicles[Vehicle][Color1] = Vehicles[vid][Color1]; 
				Vehicles[Vehicle][Color2] = Vehicles[vid][Color2]; 
				Vehicles[Vehicle][Faction] = Vehicles[vid][Faction]; 
				Vehicles[Vehicle][Rank] = Vehicles[vid][Rank]; 
				Vehicles[Vehicle][Fuel] = Vehicles[vid][Fuel];
				Vehicles[Vehicle][Radio] = 0;
				Total_FactionVehicles_Created ++;
		        Total_Vehicles_Created ++;
	        }
	        else printf("[MYSQL] ERROR LOADING FACTION VEHICLE SQLID: %d",Vehicles[vid][SQLID]);
		}
	}
	return 1;
}




forward Character_Vehicles_Load(playerid);
public Character_Vehicles_Load(playerid)
{
    if(cache_num_rows())
    {
        for(new i = 0; i<cache_num_rows(); i++)
        {
			if(Character[playerid][TotalVehicles] < 4)
			{
				Total_Vehicles_Created++;
				static Float:VehicleHP;
			  	new vid = GetFreeVehicleSlot();
			  	ResetVehicleVariables(vid);
			    validvehicle[vid] = true;

				Vehicles[vid][SQLID] = cache_get_field_content_int(i, "SQLID", SQL_CONNECTION);
				Vehicles[vid][Model] = cache_get_field_content_int(i, "Model", SQL_CONNECTION);
				Vehicles[vid][PosX] = cache_get_field_content_float(i, "PosX", SQL_CONNECTION);
				Vehicles[vid][PosY] = cache_get_field_content_float(i, "PosY", SQL_CONNECTION);
				Vehicles[vid][PosZ] = cache_get_field_content_float(i, "PosZ", SQL_CONNECTION);
				Vehicles[vid][PosA] = cache_get_field_content_float(i, "PosA", SQL_CONNECTION);
				Vehicles[vid][Color1] = cache_get_field_content_int(i, "Color1", SQL_CONNECTION);
				Vehicles[vid][Color2] = cache_get_field_content_int(i, "Color2", SQL_CONNECTION);
				Vehicles[vid][Type] = cache_get_field_content_int(i, "Type", SQL_CONNECTION);
				cache_get_field_content(i, "Plate", Vehicles[vid][Plate], SQL_CONNECTION, 12);
				Vehicles[vid][Owner] = cache_get_field_content_int(i, "Owner", SQL_CONNECTION);
				Vehicles[vid][Fuel] = cache_get_field_content_int(i, "Fuel", SQL_CONNECTION);
				VehicleHP = cache_get_field_content_float(i, "Damage", SQL_CONNECTION);
				Vehicles[vid][Radio] = cache_get_field_content_int(i, "Radio", SQL_CONNECTION);
				Vehicles[vid][Nitrous] = cache_get_field_content_int(i, "Nitrous", SQL_CONNECTION);
				Vehicles[vid][Hydraulics] = cache_get_field_content_int(i, "Hydraulics", SQL_CONNECTION);
				Vehicles[vid][Wheels] = cache_get_field_content_int(i, "Wheels", SQL_CONNECTION);
				Vehicles[vid][vPanels] = cache_get_field_content_int(i, "Panels", SQL_CONNECTION);
				Vehicles[vid][vDoors] = cache_get_field_content_int(i, "Doors", SQL_CONNECTION);
				Vehicles[vid][vLights] = cache_get_field_content_int(i, "Lights", SQL_CONNECTION);
				Vehicles[vid][vTires] = cache_get_field_content_int(i, "Tires", SQL_CONNECTION);

				if(Vehicles[vid][Model] > 399 && Vehicles[vid][Model] < 612)
				{	
				    new Vehicle = CreateVehicle(Vehicles[vid][Model], Vehicles[vid][PosX], Vehicles[vid][PosY], Vehicles[vid][PosZ]+3, Vehicles[vid][PosA], Vehicles[vid][Color1], Vehicles[vid][Color2], -1);

					Vehicles[Vehicle][SQLID] = Vehicles[vid][SQLID];
					Vehicles[Vehicle][Type] = 1;
					Vehicles[Vehicle][Owner] = Character[playerid][ID];
					Vehicles[Vehicle][Model] = Vehicles[vid][Model];
					Vehicles[Vehicle][PosX] = Vehicles[vid][PosX];
					Vehicles[Vehicle][PosY] = Vehicles[vid][PosY];
					Vehicles[Vehicle][PosZ] = Vehicles[vid][PosZ] + 1;
					Vehicles[Vehicle][PosA] = Vehicles[vid][PosA]; 
					Vehicles[Vehicle][Color1] = Vehicles[vid][Color1]; 
					Vehicles[Vehicle][Color2] = Vehicles[vid][Color2]; 
					Vehicles[Vehicle][Faction] = 0; 
					Vehicles[Vehicle][Rank] = 0;
					Vehicles[Vehicle][Radio] = Vehicles[vid][Radio];

					Vehicles[Vehicle][Nitrous] = Vehicles[vid][Nitrous];
					Vehicles[Vehicle][Hydraulics] = Vehicles[vid][Hydraulics];
					Vehicles[Vehicle][Wheels] = Vehicles[vid][Wheels];



					Character[playerid][TotalVehicles]++;

					SetVehicleToRespawn(Vehicle);
					SetVehicleNumberPlate(Vehicle, Vehicles[vid][Plate]);
				    SetVehicleHealth(Vehicle, VehicleHP);
				    UpdateVehicleDamageStatus(Vehicle, Vehicles[Vehicle][vPanels], Vehicles[Vehicle][vDoors], Vehicles[Vehicle][vLights], Vehicles[Vehicle][vTires]);
				    SetVehicleParamsEx(Vehicle, 0, 0,  alarm[Vehicle], doors[Vehicle], bonnet[Vehicle], boot[Vehicle], objective[Vehicle]);

				    if(Vehicles[Vehicle][Nitrous] > 1007 && Vehicles[Vehicle][Nitrous] < 1011)
			    	{
			    		AddVehicleComponent(Vehicle, Vehicles[Vehicle][Nitrous]);
			    	}
			    	if(Vehicles[Vehicle][Hydraulics] == 1087)
			    	{
			    		AddVehicleComponent(Vehicle, Vehicles[Vehicle][Hydraulics]);
			    	}
			    	if(Vehicles[Vehicle][Wheels] > 1072 && Vehicles[Vehicle][Wheels] < 1086)
			    	{
			    		AddVehicleComponent(Vehicle, Vehicles[Vehicle][Wheels]);
			    	}
				}
				else printf("[MYSQL] ERROR LOADING VEHICLE SQLID: %d",Vehicles[vid][SQLID]);
			}

		}
	}

	return 1;
}

stock Character_Vehicles_Unload(playerid)
{
	for(new id; id < MAX_VEH; id++)
    {
		if (IsVehicleSpawned(id))
	    {
	        if(Vehicles[id][Type] == 1)
	        {
				if (Character[playerid][ID] == Vehicles[id][Owner])
				{
					static Float:VehicleHP[1], VehicleDamage[4];
					GetVehicleHealth(id, VehicleHP[0]);
					GetVehicleDamageStatus(id, VehicleDamage[0], VehicleDamage[1], VehicleDamage[2], VehicleDamage[3]);
					MYSQL_Update_Float(Vehicles[id][SQLID], "PlayerVehicles", "Damage", VehicleHP[0]);
					MYSQL_Update_Interger(Vehicles[id][SQLID], "PlayerVehicles", "Panels", VehicleDamage[0]);
					MYSQL_Update_Interger(Vehicles[id][SQLID], "PlayerVehicles", "Doors",  VehicleDamage[1]);
					MYSQL_Update_Interger(Vehicles[id][SQLID], "PlayerVehicles", "Lights", VehicleDamage[2]);
					MYSQL_Update_Interger(Vehicles[id][SQLID], "PlayerVehicles", "Tires",  VehicleDamage[3]);
					DestroyVehicle(id);
					Total_Vehicles_Created --;
					validvehicle[id] = false;
					ResetVehicleVariables(id);
				}
			}
		}
	}
	return 1;
}

forward LoadFactions();
public LoadFactions()
{
	if(cache_num_rows())
    {
        for(new id = 0; id<cache_num_rows(); id++)
        {
			Factions[id+1][SQLID] = cache_get_field_content_int(id, "SQLID", SQL_CONNECTION);
			cache_get_field_content(id, "Name", Factions[id+1][Name], SQL_CONNECTION, 64);
			cache_get_field_content(id, "Rank1", Factions[id+1][Rank1], SQL_CONNECTION, 32);
			cache_get_field_content(id, "Rank2", Factions[id+1][Rank2], SQL_CONNECTION, 32);
			cache_get_field_content(id, "Rank3", Factions[id+1][Rank3], SQL_CONNECTION, 32);
			cache_get_field_content(id, "Rank4", Factions[id+1][Rank4], SQL_CONNECTION, 32);
			cache_get_field_content(id, "Rank5", Factions[id+1][Rank5], SQL_CONNECTION, 32);
			cache_get_field_content(id, "Rank6", Factions[id+1][Rank6], SQL_CONNECTION, 32);
			cache_get_field_content(id, "Rank7", Factions[id+1][Rank7], SQL_CONNECTION, 32);
			cache_get_field_content(id, "Rank8", Factions[id+1][Rank8], SQL_CONNECTION, 32);
			cache_get_field_content(id, "Rank9", Factions[id+1][Rank9], SQL_CONNECTION, 32);
			cache_get_field_content(id, "Rank10", Factions[id+1][Rank10], SQL_CONNECTION, 32);
			Factions[id+1][Type] = cache_get_field_content_int(id, "Type", SQL_CONNECTION);
			Factions[id+1][CommandRank] = cache_get_field_content_int(id, "CommandRank", SQL_CONNECTION);
			Factions[id+1][MaxRank] = cache_get_field_content_int(id, "MaxRank", SQL_CONNECTION);
			Factions[id+1][VaultRank] = cache_get_field_content_int(id, "VaultRank", SQL_CONNECTION);
			Factions[id+1][Vault] = cache_get_field_content_int(id, "Vault", SQL_CONNECTION);
			Factions[id+1][PosX] = cache_get_field_content_float(id, "PosX", SQL_CONNECTION);
			Factions[id+1][PosY] = cache_get_field_content_float(id, "PosY", SQL_CONNECTION);
			Factions[id+1][PosZ] = cache_get_field_content_float(id, "PosZ", SQL_CONNECTION);
			Total_Factions_Created++;
	    }
	}
	printf("[MYSQL]: %d Factions have been successfully loaded from the database.", Total_Factions_Created);
	return 1;
}



stock UnloadServerVehicles()
{
	for(new id; id < MAX_VEH; id++)
    {
		if (IsVehicleSpawned(id))
	    {
	        if(Vehicles[id][Type] == 2)
	        {
				 DestroyVehicle(id);
				 Total_Vehicles_Created --;
				 validvehicle[id] = false;
				 ResetVehicleVariables(id);
			}
		}
	}
	return 1;
}

stock UnloadFactionVehicles()
{
	for(new id; id < MAX_VEH; id++)
    {
		if (IsVehicleSpawned(id))
	    {
	        if(Vehicles[id][Type] == 3)
	        {

			 DestroyVehicle(id);
			 Total_Vehicles_Created --;
			 validvehicle[id] = false;
			 ResetVehicleVariables(id);

			}
		}
	}
	return 1;
}

stock RespawnFactionVehicles(factionid)
{
	for(new id; id < MAX_VEH; id++)
    {
		if (IsVehicleSpawned(id))
	    {
	        if(Vehicles[id][Type] == 3)
	        {
				if(Vehicles[id][Faction] == factionid)
				{
					 DestroyVehicle(id);
					 Total_Vehicles_Created --;
					 validvehicle[id] = false;
					 ResetVehicleVariables(id);
				}
			}
		}
	}
	new querya[300];

    mysql_format(SQL_CONNECTION, querya, sizeof(querya), "SELECT * FROM FactionVehicles WHERE Faction = %d",factionid);
    mysql_tquery(SQL_CONNECTION, querya, "SpawnFactionVehicles");


	return 1;
}


/*ReloadPlayerVehicles(playerid)
{

		Character_Vehicles_Unload(playerid);
		LoadPlayerVehicles(playerid);
		return 1;
}*/

ReloadServerVehicles()
{

		UnloadServerVehicles();
		LoadVehicles();
		return 1;
}

ResetVehicleVariables(id)
{
    Vehicles[id][SQLID] = 0;
    Vehicles[id][Model] = 0;
    Vehicles[id][PosX] = 0;
    Vehicles[id][PosY] = 0;
    Vehicles[id][PosZ] = 0;
	Vehicles[id][PosA] = 0;
	Vehicles[id][Color1] = 0;
	Vehicles[id][Color2] = 0;
	Vehicles[id][Type] = 0;
	Vehicles[id][Plate] = 0;
	Vehicles[id][Owner] = 0;
	Vehicles[id][Fuel] = 0;
	Vehicles[id][Damage] = 0;
	Vehicles[id][Faction] = 0; 
	Vehicles[id][Rank] = 0; 
	Vehicles[id][FuelTimer] = -1;
	Vehicles[id][Radio] = 0;
	Vehicles[id][RadioStatus] = 0;
	Vehicles[id][Nitrous] = 0;
	Vehicles[id][Hydraulics] = 0;
	Vehicles[id][Wheels] = 0;
	Vehicles[id][Broken] = 0;
	Vehicles[id][Hotwired] = 0;
	return 1;
}

stock IsVehicleSpawned(vehicleid)
{
	new Float:X,Float:Y,Float:Z;
	GetVehiclePos(vehicleid, X, Y, Z);
	if (X == 0.0 && Y == 0.0 && Z == 0.0) return 0;
	return 1;
}


CMD:fvreload(playerid,params[])
{
	if(Account[playerid][Admin] >= 2)
	{
	    if(Character[playerid][Faction] > 0)
	    {
	        if(Character[playerid][Rank] > 6)
	    	{
			    new optiona[8];
			    if(sscanf(params, "s[8]", optiona)) return SendClientMessage(playerid, COLOR_GRAY, "/fvreload [all]");
		        if(!strcmp(optiona, "all", true))
				{
		    		RespawnFactionVehicles(Character[playerid][Faction]);
		        }
	        }
		}
    }
    else
    {
        SendErrorMessage(playerid, ERROR_ADMIN);
    }
	return 1;
}

stock ReloadAll()
{
	ReloadHouses();
	ReloadBiz();
	return 1;
}

stock ReloadIcons()
{
	for(new id = 0; id < MAX_ICONS; id++)
	{
            Total_Icons_Created = 0;
        	DestroyDynamic3DTextLabel(Icons[id][LabelID]);
        	DestroyDynamicPickup(Icons[id][PickupID]);
	}
	mysql_tquery(SQL_CONNECTION, "SELECT * FROM `Icons` ORDER BY SQLID ASC", "LoadIcons");
	return 1;
}

stock ReloadBiz()
{
	Reload_Businesses();
	return 1;
}

stock ReloadHouses()
{
	for(new id = 0; id < MAX_HOUSES; id++)
	{
			Total_Houses_Created = 0;
        	DestroyDynamic3DTextLabel(Houses[id][LabelID]);
   			DestroyDynamicPickup(Houses[id][PickupID]);
	}
	mysql_tquery(SQL_CONNECTION, "SELECT * FROM `Houses` ORDER BY SQLID ASC", "LoadHouses");
	return 1;
}


stock ReloadIcon(id)
{
	new query[128];
	Total_Icons_Created --;
	DestroyDynamic3DTextLabel(Icons[id][LabelID]);
	DestroyDynamicPickup(Icons[id][PickupID]);

	mysql_format(SQL_CONNECTION, query, sizeof(query), "SELECT * FROM `Icons` WHERE SQLID = %d LIMIT 1", Business[id][SQLID]);
	mysql_tquery(SQL_CONNECTION, query, "LoadIcon", "d", id);
	return 1;
}


forward AddBusinessMoney(id, amount);
public AddBusinessMoney(id, amount)
{
	if(id > 0)
	{
		Business[id][Safe] += amount;
        MYSQL_Update_Interger(Business[id][SQLID], "Business", "Safe", Business[id][Safe]);
		return 1;
	}
	return 0;
}

forward SetPlayerMoneyEx(playerid, amount);
public SetPlayerMoneyEx(playerid, amount)
{
	Character[playerid][Cash] = amount;
	MYSQL_Update_Character(playerid, "Cash", Character[playerid][Cash]);

    ResetPlayerMoney(playerid);
	GivePlayerMoney(playerid, Character[playerid][Cash]);
	return 1;
}

forward GivePlayerMoneyEx(playerid, amount);
public GivePlayerMoneyEx(playerid, amount)
{
	Character[playerid][Cash] += amount;
	MYSQL_Update_Character(playerid, "Cash", Character[playerid][Cash]);

    ResetPlayerMoney(playerid);
	GivePlayerMoney(playerid, Character[playerid][Cash]);
	return 1;
}

forward GivePlayerXP(playerid, amount);
public GivePlayerXP(playerid, amount)
{
	Character[playerid][XP] += amount;
	MYSQL_Update_Character(playerid, "XP", Character[playerid][XP]);
	return 1;
}


stock GetFreeVehicleSlot()
{
    for(new i = 1; i < sizeof(validvehicle); i ++)
    {
        if(!validvehicle[i]) return i;
    }
    return -1;
}

stock IsInRangeOfPlayer(playerid, targetid, distance)
{
    new Float:TargetPos[3];
    GetPlayerPos(targetid, TargetPos[0], TargetPos[1], TargetPos[2]);
    if(IsPlayerInRangeOfPoint(playerid, distance, TargetPos[0], TargetPos[1], TargetPos[2])) return 1;
    return 0;
}


stock IsABike(vid)
{
	new modelid = GetVehicleModel(vid);
	if(modelid == 509||modelid == 510||modelid == 481) return 1;
	else return 0;
}

stock GetNearestVehicle(playerid, Float:dis)
{
    new Float:X, Float:Y, Float:Z;
    if(GetPlayerPos(playerid, X, Y, Z))
    {
        new vehicleid = INVALID_VEHICLE_ID;
        for(new v, Float:temp, Float:VX, Float:VY, Float:VZ; v != MAX_VEH; v++)
        {
            if(GetVehiclePos(v, VX, VY, VZ))
            {
                VX -= X, VY -= Y, VZ -= Z;
                temp = VX * VX + VY * VY + VZ * VZ;
                if(temp < dis) dis = temp, vehicleid = v;
            }
        }
        dis = floatpower(dis, 1.0);
        return vehicleid;
    }
    return INVALID_VEHICLE_ID;
}

stock InRangeOfHouse(playerid)
{
	for(new id = 0; id < MAX_HOUSES; id++)
	{
    	if(IsPlayerInRangeOfPoint(playerid, 2.0, Houses[id][PosX], Houses[id][PosY], Houses[id][PosZ]))
		{
			return id;
		}
	}
    return 0;
}


stock InRangeOfPump(playerid)
{
	for(new id = 0; id < MAX_OBJECTZ; id++)
	{
    	if(IsPlayerInRangeOfPoint(playerid, 8.0, Objects[id][PosX], Objects[id][PosY], Objects[id][PosZ]) && Objects[id][Model] == 1676)
		{
			return 1;
		}
	}
    return 0;
}

stock InRangeOfMovableObject(playerid)
{
	for(new id = 1; id < MAX_OBJECTZ; id++)
	{
    	if(IsPlayerInRangeOfPoint(playerid, 4.0, Objects[id][PosX], Objects[id][PosY], Objects[id][PosZ]) && Objects[id][Movable] == 1)
		{
			return id;
		}
	}
    return 0;
}

stock InRangeOfMovableFactionObject(playerid, Float:distance)
{
	for(new id = 1; id < MAX_OBJECTZ; id++)
	{
    	if(IsPlayerInRangeOfPoint(playerid, distance, Objects[id][PosX], Objects[id][PosY], Objects[id][PosZ]) && Objects[id][Movable] == 1 && Objects[id][Faction] != 0)
		{
			return id;
		}
	}
    return 0;
}

stock FindVehicleByNameID(const vname[])
{

    if('4' <= vname[0] <= '6') return INVALID_VEHICLE_ID;

    for(new i,LEN = strlen(vname); i != sizeof(VehicleNames); i++)
        if(!strcmp(VehicleNames[i],vname,true,LEN))
            return i + 400;

    return INVALID_VEHICLE_ID;
}


stock Restricted_Vehicle(vID)
{
	if(vID == 520 || vID == 425 || vID == 577 || vID == 432 || vID == 406 || vID == 592)
	{
	    return 1;
	}
	return 0;
}

stock IsVehicleTaxi(vID)
{
	if(vID == 420 || vID == 438)
	{
	    return 1;
	}
	return 0;
}

CMD:v(playerid, params[])
{
    new vehicleid[20], color1, color2, str[128], State = GetPlayerState(playerid);
    if(Account[playerid][Admin] > 0)
	{
		if(State == PLAYER_STATE_DRIVER) return SendErrorMessage(playerid, "You are currently driving a vehicle.");
	    if(!sscanf(params, "s[20]dd", vehicleid, color1, color2))
	    {
	        new vID = FindVehicleByNameID(vehicleid);
	        if(vID == INVALID_VEHICLE_ID)
	        {
	            vID = strval(vehicleid);
	            if(!(399 < vID < 612)) return SendErrorMessage(playerid, ERROR_OPTION);
	        }
	        if(Account[playerid][Admin] != 6 && Restricted_Vehicle(vID)) return SendErrorMessage(playerid, ERROR_OPTION);
	        if(Total_Vehicles_Created < MAX_VEHICLES)
        	{
		        new Float: curX, Float: curY, Float: curZ, Float: curR;

		        GetPlayerPos(playerid, curX, curY, curZ);
		        GetPlayerFacingAngle(playerid, curR);
		        new makecar = CreateVehicle(vID, curX+1, curY+1, curZ, curR, color1, color2, -1);
		        ResetVehicleVariables(makecar);
		        validvehicle[makecar] = true;
				LinkVehicleToInterior(makecar, GetPlayerInterior(playerid));

				PutPlayerInVehicle(playerid, makecar, 0);
				SetVehicleNumberPlate(makecar, "SCRP");
				Lights[makecar] = 1;
				Total_Vehicles_Created++;

   				Vehicles[makecar][Fuel] = 100;
				Engine_SET(playerid, makecar, 1);
				SetVehicleParamsEx(makecar,Engine[makecar],1,alarm[makecar],doors[makecar],bonnet[makecar],boot[makecar],objective[makecar]);
				//Lights_TOGGLE(playerid, makecar);
				format(str, sizeof(str), "You have successfully spawned a %s.", VehicleNames[vID-400]);
		        SendClientMessage(playerid, COLOR_YELLOW, str);
		        return 1;
        	}
	        
	    }
	    else if(!sscanf(params, "s[20]", vehicleid))
	    {
	       	new vID = FindVehicleByNameID(vehicleid);
	        if(vID == INVALID_VEHICLE_ID)
	        {
	            vID = strval(vehicleid);
	            if(!(399 < vID < 612)) return SendErrorMessage(playerid, "That is not a valid vehicle name/id!");
	        }
	        if(Account[playerid][Admin] != 6 && Restricted_Vehicle(vID)) return SendErrorMessage(playerid, ERROR_OPTION);
        	if(Total_Vehicles_Created < MAX_VEHICLES)
        	{
		        new Float: curX, Float: curY, Float: curZ, Float: curR;

		        GetPlayerPos(playerid, curX, curY, curZ);
		        GetPlayerFacingAngle(playerid, curR);
		        new makecar = CreateVehicle(vID, curX+1, curY+1, curZ, curR, -1, -1, -1);
		        ResetVehicleVariables(makecar);
		        validvehicle[makecar] = true;
				LinkVehicleToInterior(makecar, GetPlayerInterior(playerid));

				PutPlayerInVehicle(playerid, makecar, 0);
				SetVehicleNumberPlate(makecar, "SCRP");
				Lights[makecar] = 1;
				Total_Vehicles_Created++;
				Vehicles[makecar][Fuel] = 100;
				Engine_SET(playerid, makecar, 1);
				SetVehicleParamsEx(makecar,Engine[makecar],1,alarm[makecar],doors[makecar],bonnet[makecar],boot[makecar],objective[makecar]);
				//Lights_TOGGLE(playerid, makecar);
				format(str, sizeof(str), "You have successfully spawned a %s.", VehicleNames[vID-400]);
		        SendClientMessage(playerid, COLOR_YELLOW, str);

		        return 1;
	        }
	    }
	    else return SendClientMessage(playerid, COLOR_GRAY, "/v [modelid] [color1 optional] [color2 optional]");
	}
    return 1;
}
CMD:veh(playerid, params[]) return cmd_v(playerid, params);
CMD:vehicle(playerid, params[]) return cmd_v(playerid, params);



public OnPlayerDeath(playerid, killerid, reason)
{
	new str[128];

	if(Character[playerid][Jail] > 0)
	{
		format(str, sizeof(str), "[INFO] You are still in jail, you have a further %d minute(s) to serve.", Character[playerid][Jail]);
		SendClientMessage(playerid, COLOR_INDIANRED, str);
		return SendToJail(playerid);
	}


    Character[playerid][InHospital] = 1;
    GetPlayerPos(playerid, Character[playerid][PosX], Character[playerid][PosY], Character[playerid][PosZ]);


	if(LoopAnim[playerid]) 
    {
        LoopAnim[playerid] = 0;
        TextDrawHideForPlayer(playerid,AnimText[playerid]);
	}

	TextDrawShowForPlayer(playerid, BlackScreen[playerid]);
    TextDrawShowForPlayer(playerid, BlackOutText[playerid]);


	format(str, sizeof(str), "* %s falls to the floor, knocked unconscious. *", GetRoleplayName(playerid));
	SendLocalMessage(playerid, str, Range_Normal, COLOR_RP, COLOR_RP);

    ClearPlayerWeapons(playerid);

	TogglePlayerSpectating(playerid, true);
	TogglePlayerControllable(playerid, false);


	if(killerid != INVALID_PLAYER_ID)
    {
		format(str, sizeof(str),"%s has been killed by %s.",GetRoleplayName(playerid),GetRoleplayName(killerid));
    	SendAdminsMessage(1, COLOR_RED, str);
    }
    else
    {
        format(str, sizeof(str),"%s has died.",GetRoleplayName(playerid));
    	SendAdminsMessage(1, COLOR_ORANGERED, str);
    }

	SetTimerEx("Hospital", SECONDS(10), 0, "i", playerid);
	return 1;
}

forward Hospital(playerid);
public Hospital(playerid)
{

	SetSpawnInfo(playerid, 0, Character[playerid][Skin], -318.6522, 1049.3909, 20.3403, 358.4333, 0, 0, 0, 0, 0, 0);
	SpawnPlayer(playerid);

	TogglePlayerSpectating(playerid, false);
	TogglePlayerControllable(playerid, true);

	Character[playerid][Armour] = 0;
	Character[playerid][Health] = 100;
	Character[playerid][InHospital] = 0;

	new fee = (random(100) + 25) * Character[playerid][Level];

	SetPlayerHealth(playerid, Character[playerid][Health]);
	SetPlayerArmour(playerid, Character[playerid][Armour]);
	GivePlayerMoneyEx(playerid, -fee);
	SetPlayerPosEx(playerid, -320.2086, 1048.7581, 20.3403, 0, 0);
	SetPlayerFacingAngle(playerid, 91.4410);

	TextDrawHideForPlayer(playerid, BlackScreen[playerid]);
	TextDrawHideForPlayer(playerid, BlackOutText[playerid]);

	FailDrivingTest(playerid, "You died.");
	EndTruckingMission(playerid, "You died.");

	new str[128];
	format(str, sizeof(str), "You were taken to the nearest hospital, you managed to pull through! You were charged $%d in medical bills.", fee);
	SendClientMessage(playerid, COLOR_PALETURQUOISE, str);
	return 1;
}

//==============================================================================
//
//      -- > PLAYER COMMANDS
//
//==============================================================================
stock Line(playerid)
{
	SendClientMessage(playerid, COLOR_IVORY, "_________________________________________________");
	return 1;
}

CMD:help(playerid, params[])
{
	Line(playerid);

	SendClientMessage(playerid, COLOR_YELLOW, "Chat Commands:");
	SendClientMessage(playerid, COLOR_WHITE, "/me /do /b /(s)hout /(l)ow /(w)hisper");


	SendClientMessage(playerid, COLOR_YELLOW, "Vehicle Commands:");
	SendClientMessage(playerid, COLOR_WHITE, "/(e)ngine /lights /vmusic /myvehicles");


	SendClientMessage(playerid, COLOR_YELLOW, "Purchasing Commands:");
	SendClientMessage(playerid, COLOR_WHITE, "/buy /buyhouse /buybiz");


	SendClientMessage(playerid, COLOR_YELLOW, "Other Commands:");
	SendClientMessage(playerid, COLOR_WHITE, "/stats /inventory /changeaccountpassword /(clearanim)ation /changespawn");


	SendClientMessage(playerid, COLOR_YELLOW, "Help Commands:");
	SendClientMessage(playerid, COLOR_WHITE, "/fhelp /bhelp /phelp /rhelp /animlist");

	Line(playerid);

	return 1;
}

CMD:phonehelp(playerid, params[])
{
	Line(playerid);
	SendClientMessage(playerid, COLOR_YELLOW, "Phone Commands:");
	SendClientMessage(playerid, COLOR_WHITE, "/call /answer /phoneinfo /phone(on/off)");
	Line(playerid);
	return 1;
}
ALTCMD:phelp->phonehelp;


CMD:radiohelp(playerid, params[])
{
	Line(playerid);
	SendClientMessage(playerid, COLOR_YELLOW, "Radio Commands:");
	SendClientMessage(playerid, COLOR_WHITE, "/(r)adio /radiotune /radioinfo /radioon /radiooff");
	Line(playerid);
	return 1;
}
ALTCMD:rhelp->radiohelp;

CMD:fhelp(playerid, params[])
{
	if(Character[playerid][Faction] > 0)
	{
		new str[128];

		Line(playerid);
		SendClientMessage(playerid, COLOR_YELLOW, "Faction Commands:");
		SendClientMessage(playerid, COLOR_WHITE, "/(f)ac /membersonline /members");

		new fid = GetFactionIDFromSQLID(Character[playerid][Faction]);

		if(Character[playerid][Faction] == 1)
		{
			format(str, sizeof(str), " %s Commands:", Factions[fid][Name]);
			SendClientMessage(playerid, COLOR_YELLOW, str);
			SendClientMessage(playerid, COLOR_WHITE, "/door /fine /(un)cuff /(un)jail /pnc /radar /megaphone /radio /locker /changeuniform");
		}

		if(Character[playerid][Faction] > 0 && Character[playerid][Rank] >= Factions[fid][CommandRank])
		{
			format(str, sizeof(str), "Rank %d+ Commands:", Factions[fid][CommandRank]);
			SendClientMessage(playerid, COLOR_YELLOW, str);
			SendClientMessage(playerid, COLOR_WHITE, "/hire /fire /promote /demote /editranks /frespawn /setrank /setspawn");
		}
		Line(playerid);
	}
	else
	{
		SendClientMessage(playerid, COLOR_YELLOW, ERROR_FACTION);
	}
	return 1;
}


CMD:bhelp(playerid, params[])
{
	if(Character[playerid][Business_1] > 0 || Character[playerid][Business_2] > 2)
	{
		SendClientMessage(playerid, COLOR_YELLOW, "Business Commands:");
		SendClientMessage(playerid, COLOR_WHITE, "/entrancefee /checksafe /safeget /safestore /key");
	}
	else
	{
		SendClientMessage(playerid, COLOR_GRAY, "You don't own a business.");
	}
	return 1;
}


CMD:kill(playerid,params[])
{
	new str[128];
	SetPlayerHealth(playerid, 0);
	format(str, sizeof(str), "%s has used /kill.", GetRoleplayName(playerid));
	SendAdminsMessage(1, COLOR_RED, str);
	return 1;
}

forward SetPlayerPosEx(playerid, Float:X, Float:Y, Float:Z, Int, vWorld);
public SetPlayerPosEx(playerid, Float:X, Float:Y, Float:Z, Int, vWorld)
{
	TogglePlayerControllable(playerid, 0);
	SetTimerEx("UnfreezePlayer", 1500, false, "d", playerid);
	SetPlayerPos(playerid, X, Y, Z-5);
    SetPlayerInterior(playerid, Int);
	SetPlayerVirtualWorld(playerid, vWorld);
	SetTimerEx("Move_Player", 1000, false, "dfff", playerid, X, Y, Z);
	PickedUpPickup[playerid] = false;
	return 1;
}

forward Move_Player(playerid, Float:X, Float:Y, Float:Z);
public Move_Player(playerid, Float:X, Float:Y, Float:Z)
{
	SetPlayerPos(playerid, X, Y, Z);
	return 1;
}

CMD:enter(playerid)
{
	new str[128], bID = InRangeOfBiz(playerid), id = InRangeOfHouse(playerid);
	if(GetPlayerVehicleID(playerid)) return SendErrorMessage(playerid, "Cannot be done when you are in a vehicle.");
	if(bID > 0)
	{
        if(Business[bID][Locked] == 0)
		{
		    if(Business[bID][Owned] == 1)
		    {
 				
	            if(Business[bID][EntranceFee] <= Character[playerid][Cash])
	            {

					AddBusinessMoney(bID, Business[bID][EntranceFee]);
	            	GivePlayerMoneyEx(playerid, -Business[bID][EntranceFee]);

					format(str, sizeof(str), "Welcome to the %s.", Business[bID][Name]);
					if(Business[bID][Owned] != 3) SendClientMessage(playerid, COLOR_WHITE, str);

					SetPlayerPosEx(playerid, Business[bID][InteriorX], Business[bID][InteriorY], Business[bID][InteriorZ], Business[bID][Interior], Business[bID][World]);


					if(bID == Character[playerid][Business_1] || bID == Character[playerid][Business_2])
					{
						SendClientMessage(playerid, COLOR_YELLOW, "You appear to own this business, for a list of commands use /bhelp!");
					}
					Character[playerid][bEntered] = bID;
				}
				else
				{
					SendErrorMessage(playerid, ERROR_MONEY);
				}
			}
			else
			{

				SetPlayerPosEx(playerid, Business[bID][InteriorX], Business[bID][InteriorY], Business[bID][InteriorZ], Business[bID][Interior], Business[bID][World]);
				Character[playerid][bEntered] = bID;
				format(str, sizeof(str), "Welcome to the %s.", Business[bID][Name]);
				SendClientMessage(playerid, COLOR_WHITE, str);
			}
		}
		else
		{
			format(str, sizeof(str), "* %s attempts to open the door of the business.*", GetRoleplayName(playerid));
			SendLocalMessage(playerid, str, Range_Short, COLOR_RP, COLOR_RP);

			format(str, sizeof(str), "* As the door is locked, it doesn't open. ((%s))",GetRoleplayName(playerid));
			SendLocalMessage(playerid, str, Range_Short, COLOR_RP, COLOR_RP);
		}

	}

    if(id > 0)
	{
        if(Houses[id][Locked] == 0)
        {
            if(IsPlayerInRangeOfPoint(playerid, 2.0, Houses[id][PosX], Houses[id][PosY], Houses[id][PosZ]))
            {
                SetPlayerPosEx(playerid, Houses[id][IntX], Houses[id][IntY], Houses[id][IntZ], Houses[id][Interior], Houses[id][World]);
                Character[playerid][hEntered] = id;
            }
		}
		else
		{
		    format(str, sizeof(str), "* %s attempts to open the house door.*", GetRoleplayName(playerid));
			SendLocalMessage(playerid, str, Range_Short, COLOR_RP, COLOR_RP);

			format(str, sizeof(str), "* As the door is locked, it doesn't open. ((%s))",GetRoleplayName(playerid));
			SendLocalMessage(playerid, str, Range_Short, COLOR_RP, COLOR_RP);
		}
    }
	return 1;
}
ALTCMD2:ent->enter;


forward UnfreezePlayer(playerid);
public UnfreezePlayer(playerid)
{
	TogglePlayerControllable(playerid, 1);
	if(Trucking[playerid][SectionID] == 1)
	{
		GameTextForPlayer(playerid, "Goods loaded!", 3000, 3);
		SendClientMessage(playerid, COLOR_YELLOWGREEN, "You have collected the imported goods from the airport, now proceed to the point of processing for this particular good.");
	}
	return 1;
}

CMD:exit(playerid)
{
	new hID = Character[playerid][hEntered], bID = Character[playerid][bEntered];
	if(IsPlayerInRangeOfPoint(playerid, 5.0, Houses[hID][IntX], Houses[hID][IntY], Houses[hID][IntZ]) && GetPlayerVirtualWorld(playerid) == Houses[hID][World])
    {
        SetPlayerPosEx(playerid, Houses[hID][PosX], Houses[hID][PosY], Houses[hID][PosZ], 0 , 0);
        Character[playerid][hEntered] = 0;
    }


    if(IsPlayerInRangeOfPoint(playerid, 5.0, Business[bID][InteriorX], Business[bID][InteriorY], Business[bID][InteriorZ]) && GetPlayerVirtualWorld(playerid) == Business[bID][World])
    {
        SetPlayerPosEx(playerid, Business[bID][PosX], Business[bID][PosY], Business[bID][PosZ], 0, 0);
        Character[playerid][bEntered] = 0;
    }

 	return 1;
}

stock GetPlayerRank(playerid)
{
	new rank[34], fid = GetFactionIDFromSQLID(Character[playerid][Faction]);
    switch(Character[playerid][Rank])
    {
			case 1: format(rank, sizeof(rank), "%s", Factions[fid][Rank1]);
			case 2: format(rank, sizeof(rank), "%s", Factions[fid][Rank2]);
			case 3: format(rank, sizeof(rank), "%s", Factions[fid][Rank3]);
			case 4: format(rank, sizeof(rank), "%s", Factions[fid][Rank4]);
			case 5: format(rank, sizeof(rank), "%s", Factions[fid][Rank5]);
			case 6: format(rank, sizeof(rank), "%s", Factions[fid][Rank6]);
			case 7: format(rank, sizeof(rank), "%s", Factions[fid][Rank7]);
			case 8: format(rank, sizeof(rank), "%s", Factions[fid][Rank8]);
			case 9: format(rank, sizeof(rank), "%s", Factions[fid][Rank9]);
			case 10: format(rank, sizeof(rank), "%s", Factions[fid][Rank10]);
    }
    return rank;
}

stock GetRankName(factionid, rankk)
{
	new rank[34], fid = factionid;
    switch(rankk)
    {
			case 1: format(rank, sizeof(rank), "%s", Factions[fid][Rank1]);
			case 2: format(rank, sizeof(rank), "%s", Factions[fid][Rank2]);
			case 3: format(rank, sizeof(rank), "%s", Factions[fid][Rank3]);
			case 4: format(rank, sizeof(rank), "%s", Factions[fid][Rank4]);
			case 5: format(rank, sizeof(rank), "%s", Factions[fid][Rank5]);
			case 6: format(rank, sizeof(rank), "%s", Factions[fid][Rank6]);
			case 7: format(rank, sizeof(rank), "%s", Factions[fid][Rank7]);
			case 8: format(rank, sizeof(rank), "%s", Factions[fid][Rank8]);
			case 9: format(rank, sizeof(rank), "%s", Factions[fid][Rank9]);
			case 10: format(rank, sizeof(rank), "%s", Factions[fid][Rank10]);
    }
    return rank;
}

CMD:stats(playerid, params[])
{
	//new player;
	//if(sscanf(params, "u", player, playerid))

	new str[168], fac[64], fid = GetFactionIDFromSQLID(Character[playerid][Faction]);
	if(Character[playerid][Faction] != 0)
	{
	    format(fac, sizeof(fac), "%s", Factions[fid][Name]);
	}
	else
	{
	    format(fac, sizeof(fac), "Civilian");
	}
	Line(playerid);
	format(str, sizeof(str), "> %s's Stats", GetRoleplayName(playerid));
	SendClientMessage(playerid, COLOR_GRAY, str);
	format(str, sizeof(str), "> Age: [%d] | Money: [%d] | Bank: [%d]", Character[playerid][Age], Character[playerid][Cash], Character[playerid][Bank]);
	SendClientMessage(playerid, COLOR_GRAY, str);
	format(str, sizeof(str), "> Faction: [%s] | Rank: [%s(%d)]", fac, GetPlayerRank(playerid), Character[playerid][Rank]);
	SendClientMessage(playerid, COLOR_GRAY, str);
	format(str, sizeof(str), "> House: [%s] | Business: [%s] | Business_2 [%s]", Houses[Character[playerid][House]][Name], Business[Character[playerid][Business_1]][Name], Business[Character[playerid][Business_2]][Name]);
	SendClientMessage(playerid, COLOR_GRAY, str);
	format(str, sizeof(str), "> Vehicles: [%d] | Job: [%s] | TotalTimePlayed: [%d]", Character[playerid][TotalVehicles], JobNames[Character[playerid][Job]][0], Character[playerid][TotalTimePlayed]);
	SendClientMessage(playerid, COLOR_GRAY, str);
	format(str, sizeof(str), "> XP: [%d] | OnlinePeriod: [%d] | TruckMissionsCompleted: [%d]", Character[playerid][XP], Character[playerid][OnlinePeriod], Character[playerid][TruckingCompleted]);
	SendClientMessage(playerid, COLOR_GRAY, str);
	Line(playerid);
	
	return 1;
}

CMD:levelup(playerid, params[])
{
	new RequiredXP = Character[playerid][Level] * 10, NextLevel = Character[playerid][Level] + 1, option[12], str[128];

	format(str, sizeof(str), "Are you sure you want to buy level %d using %d experience points(XP)? (/levelup [confirm/decline])", NextLevel, RequiredXP);
	if(sscanf(params, "s[12]", option)) return SendClientMessage(playerid, COLOR_WHEAT, str);
	{
		if(!strcmp(option, "confirm", true))
		{
			if(Character[playerid][XP] >= RequiredXP)
			{
				Character[playerid][XP] -= RequiredXP;
				Character[playerid][Level] = NextLevel;
				SetPlayerScore(playerid, Character[playerid][Level]);

				format(str, sizeof(str), "Congratulations, you are now level %d! You have %d experience points(XP) remaining.", Character[playerid][Level], Character[playerid][XP]);
				SendClientMessage(playerid, COLOR_WHEAT, str);
			}
			else
			{
				SendErrorMessage(playerid, "Not enough experience points.");
			}
		}

	}
	
	return 1;
}


new GeneralStore[][] =
{
   //{Itemid???? Item, price}
   {1, 125,	"Mobile Phone"}, 
   {0, 50, 	"Watch"},  
   {0, 15, 	"Water Bottle"}, 
   {0, 45,	"Cigarettes"}, 
   {0, 2, 	"Lighter"},		
   {0, 12, 	"Rope"},
   {2, 2400,"Vehicle Radio"},
   {3, 400, "Radio"},
   {4, 35, 	"Screwdriver"}
};

#define PHONE 												  				     0
#define WATCH                                                        		     1
#define WATERBOTTLE                                                 		     2
#define CIGARETTES                                                     		   	 3
#define LIGHTER                                                         		 4
#define ROPE                                                             		 5
#define VRADIO 																	 6
#define RADIO 																	 7
#define SCREWDRIVER																 8

CMD:buy(playerid, params[])
{
	if(Character[playerid][bEntered] > 0)
	{
		if(Business[Character[playerid][bEntered]][Type]== 1)//Convenience Store
		{
			new CheckOut[600], StoreName[64], str[64];

			format(StoreName, sizeof(StoreName), "%s", Business[Character[playerid][bEntered]][Name]);

			for (new i = 0; i < sizeof(GeneralStore); ++i)
			{
				format(str, sizeof(str), "%s ($%d)\n", GeneralStore[i][2], GeneralStore[i][1]);
				strcat(CheckOut, str, sizeof(CheckOut));
			}

			Dialog_Show(playerid, GENERALSTORE, DIALOG_STYLE_LIST, StoreName, CheckOut, "Buy","Cancel");
		}
		if(Business[Character[playerid][bEntered]][Type]== 6)//Diner
		{
			Dialog_Show(playerid, DINER, DIALOG_STYLE_LIST, "Diner's Menu", "-Starters-\n\n Salad \n Garlic Bread \n\n-Main Course-\n Burger \n Chips \n Chicken Nuggets \n Hotdog \n\n-Desserts-\n Icecream \n Brownie", "View","Cancel");
		}
		if(Business[Character[playerid][bEntered]][Type]== 5)//Clothes
		{
			if(Character[playerid][Cash] >= 250)
			{
				TogglePlayerControllable(playerid, 0);
			    GivePlayerMoneyEx(playerid, -250);
			    AddBusinessMoney(Character[playerid][bEntered], 250);
			    Character[playerid][ClothesSelection] = 1;
			    GetPlayerPos(playerid, Character[playerid][PosX], Character[playerid][PosY], Character[playerid][PosZ]);
			    Character[playerid][VWorld] = GetPlayerVirtualWorld(playerid);
				Character[playerid][Interior] = GetPlayerInterior(playerid);

				SetPlayerPos(playerid, 184.6707, -88.0618, 1002.0234);
				SetPlayerVirtualWorld(playerid, playerid + 1000);
				SetPlayerInterior(playerid, 18);
				SetPlayerFacingAngle(playerid, 90.0);
				SetPlayerCameraPos(playerid,181.6707, -88.0618, 1002.0234);
				SetPlayerCameraLookAt(playerid,181.6707, -88.0618, 1002.0234);
				if(Character[playerid][Gender] == 1)
				{
		  			SetPlayerSkin(playerid, MaleSkins[SkinSelection[playerid]][0]);
				}
				if(Character[playerid][Gender] == 2)
				{
					SetPlayerSkin(playerid, FemaleSkins[SkinSelection[playerid]][0]);
				}
				InfoBoxForPlayer2(playerid, "Use the arrow keys to scroll through the skins, once you find a suitable skin use the ENTER key to purchase the item.");

			 }
			 else
			 {
			    SendErrorMessage(playerid, ERROR_MONEY);
			 }
		}
	}
    return 1;
}

CMD:inventory(playerid, params[])
{
	new str[128], dialog[1000];
	if(Inventory[playerid][PhoneStatus] > 0)
	{
		format(str, sizeof(str), "Mobile Phone (Status:%d)\n", Inventory[playerid][PhoneStatus]);
		strcat(dialog, str, sizeof(dialog));
	}
	if(Inventory[playerid][VehicleRadio] > 0)
	{
		format(str, sizeof(str), "Vehicle Multimedia System (x%d)\n", Inventory[playerid][VehicleRadio]);
		strcat(dialog, str, sizeof(dialog));
	}
	if(Inventory[playerid][Radio] > 0)
	{
		format(str, sizeof(str), "Handheld Radio (%d Mhz)\n", Inventory[playerid][Radio], Inventory[playerid][RadioFreq]);
		strcat(dialog, str, sizeof(dialog));
	}
	if(Inventory[playerid][Screwdriver] > 0)
	{
		format(str, sizeof(str), "Screwdriver(x%d)\n", Inventory[playerid][Screwdriver]);
		strcat(dialog, str, sizeof(dialog));
	}
	Dialog_Show(playerid, INVENTORY, DIALOG_STYLE_MSGBOX, "Player Inventory", dialog,"Close","");
	return 1;
}



forward GiveInventoryItem(playerid, item, quantity);
public GiveInventoryItem(playerid, item, quantity)
{
	new str[128];
	if(item == PHONE)
	{
	    if(Inventory[playerid][PhoneStatus] == 0)
	    {
			Inventory[playerid][PhoneNumber] = 100000 + random(8999999);
			Inventory[playerid][PhoneStatus] = 1;
			MYSQL_Update_Character(playerid, "PhoneStatus", Inventory[playerid][PhoneStatus]);
			MYSQL_Update_Character(playerid, "PhoneNumber",Inventory[playerid][PhoneNumber]);
			SendInfoMessage(playerid, "A phone has been added to your inventory.");
			return 1;
		}
		else
		{
		    SendErrorMessage(playerid, ERROR_OWNED);
		}
	}

	else if(item == VRADIO)
	{
		if(Inventory[playerid][VehicleRadio] >= 99) return SendErrorMessage(playerid, "You cannot buy anymore of this item.");
		Inventory[playerid][VehicleRadio] += quantity;
		MYSQL_Update_Character(playerid, "VehicleRadio", Inventory[playerid][VehicleRadio]);
		format(str, sizeof(str), "You have had %d (vehicle) sound system(s) added to your inventory, you now have a total of %d on you.", quantity, Inventory[playerid][VehicleRadio]);
		SendInfoMessage(playerid, str);
		return 1;
	}

	else if(item == RADIO)
	{
		if(Inventory[playerid][Radio] >= 1) return SendErrorMessage(playerid, "You cannot buy anymore of this item.");
		Inventory[playerid][Radio] += quantity;
		Inventory[playerid][RadioFreq] = 1000;
		MYSQL_Update_Character(playerid, "Radio", Inventory[playerid][Radio]);
		format(str, sizeof(str), "%d radio has been added to your inventory and tuned to 1000 MHz, for more help refer to /rhelp.", quantity);
		SendInfoMessage(playerid, str);
		return 1;

	}
	else if(item == SCREWDRIVER)
	{
		if(Inventory[playerid][Screwdriver] >= 10) return SendErrorMessage(playerid, "You cannot buy anymore of this item.");
		Inventory[playerid][Screwdriver] += quantity;
		MYSQL_Update_Character(playerid, "Screwdriver", Inventory[playerid][Screwdriver]);
		format(str, sizeof(str), "%d screwdriver has been added to your inventory.", quantity);
		SendClientMessage(playerid, COLOR_LIGHTGRAY, str);
		return 1;

	}
	else
	{
		SendErrorMessage(playerid, "Item not found.");
	}

	return 1;
}



stock BuyItem(playerid, item)
{
	if(GeneralStore[item][1] <= Character[playerid][Cash])
	{
		new str[128];
		GiveInventoryItem(playerid, item, 1);

		AddBusinessMoney(Character[playerid][bEntered], GeneralStore[item][1]);
		GivePlayerMoneyEx(playerid, -GeneralStore[item][1]);

		format(str, sizeof(str), "* The cashier swipes the object past the scanner. The cash register would display $%d. *", GeneralStore[item][1]);
		SendLocalMessage(playerid, str, Range_VShort, COLOR_RP, COLOR_RP);
	}
	else
	{
		SendErrorMessage(playerid, ERROR_MONEY);
	}
	return 1;
}

Dialog:GENERALSTORE(playerid, response, listitem, inputtext[])
{
	if(!response) return SendClientMessage(playerid, COLOR_RP, "* You decided not to buy anything at the checkout. *");
    if(response)
    {
		BuyItem(playerid, listitem);  
	}
    return 1;
}

forward TakeInventoryItem(playerid, item, quantity);
public TakeInventoryItem(playerid, item, quantity)
{
	new str[128];

	if(item == VRADIO)
	{
		if(Inventory[playerid][VehicleRadio] <= 0) return SendErrorMessage(playerid, "Item couldn't be taken.");
		Inventory[playerid][VehicleRadio] -= quantity;
		MYSQL_Update_Character(playerid, "VehicleRadio", Inventory[playerid][VehicleRadio]);

		format(str, sizeof(str), "[INFO] You have had %d (vehicle) sound system(s) taken from your inventory, you now have a total of %d on you.", quantity, Inventory[playerid][VehicleRadio]);
		SendClientMessage(playerid, COLOR_LIGHTGRAY, str);
		return 1;

	}
	else if(item == SCREWDRIVER)
	{
		if(Inventory[playerid][Screwdriver] <= 0) return SendErrorMessage(playerid, "Item couldn't be taken.");
		Inventory[playerid][Screwdriver] -= quantity;
		MYSQL_Update_Character(playerid, "Screwdriver", Inventory[playerid][Screwdriver]);

		format(str, sizeof(str), "[INFO] %d screwdriver has been taken from your inventory, you have %d left.", quantity, Inventory[playerid][Screwdriver]);
		SendClientMessage(playerid, COLOR_LIGHTGRAY, str);
		return 1;

	}
	else
	{
		SendErrorMessage(playerid, "Item not found.");
	}

	return 1;
}



stock FormatNumber(Float:amount)
{
	new str[16];
	format(str, sizeof(str), "%d", floatround(amount));
	new l = strlen(str);
	if (amount < 0) // -
	{
  		if (l > 4) strins(str, ",", l-3);
		if (l > 7) strins(str, ",", l-6);
		if (l > 10) strins(str, ",", l-9);
	}
	else
	{
		if (l > 3) strins(str, ",", l-3);
		if (l > 6) strins(str, ",", l-6);
		if (l > 9) strins(str, ",", l-9);
	}
	return str;
}





//==============================================================================
//          -- > Chat Functions
//==============================================================================




stock SendSplitMessage(playerid, color, final[])
{
    #pragma unused playerid, color
    new buffer[SPLITLENGTH+5];
    new len = strlen(final);
    if(len>SPLITLENGTH)
    {
        new times = (len/SPLITLENGTH);
        for(new i = 0; i < times+1; i++)
        {
            strdel(buffer, 0, SPLITLENGTH+5);
            if(len-(i*SPLITLENGTH)>SPLITLENGTH)
            {
                strmid(buffer, final, SPLITLENGTH*i, SPLITLENGTH*(i+1));
                format(buffer, sizeof(buffer), "%s ...", buffer);
            }
            else
            {
                strmid(buffer, final, SPLITLENGTH*i, len);
            }
            SendClientMessage(playerid, color, buffer);
        }
    }
    else
    {
        //if == 1 - normal if = 2 asay
        SendClientMessage(playerid, color, final);
    }
}

stock SendLocalMessage(playerid, msg[], Float:MessageRange, Range1color, Range2color)
{
    new Float: PlayerX, Float: PlayerY, Float: PlayerZ;
    GetPlayerPos(playerid, PlayerX, PlayerY, PlayerZ);
    for(new i = 0; i < MAX_PLAYERS; i++ )
    {
        if(IsPlayerInRangeOfPoint(i, MessageRange, PlayerX, PlayerY,PlayerZ))
        {
            SendSplitMessage(i, Range1color, msg);
        }
        else if(IsPlayerInRangeOfPoint(i, MessageRange/2.0, PlayerX, PlayerY,PlayerZ))
        {
            SendSplitMessage(i, Range2color, msg);
        }
    }
    return 1;
}


stock SendPunishmentMessage(str[])
{
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i))
        {
            if(LoggedIn[i] == true)
            {
                new astr[128];
                format(astr, sizeof(astr), "[PUNISHMENT] %s", str);
                SendClientMessage(i, COLOR_ORANGERED, astr);
             }
        }
    }
    return 1;
}

stock SendErrorMessage(playerid, str[])
{
    new astr[128];
    format(astr, sizeof(astr), "> [ERROR] %s", str);
    SendClientMessage(playerid, COLOR_GRAY, astr);
    return 1;
}

stock SendInfoMessage(playerid, str[])
{
    new astr[128];
    format(astr, sizeof(astr), "[INFO] %s", str);
    SendClientMessage(playerid, COLOR_LBLUE, astr);
    return 1;
}

stock SendAdminsMessage(level, color, str[])
{
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i))
        {
            new astr[128];
            if(Account[i][Admin] >= level)
            {
                format(astr, sizeof(astr), "[Admin Msg] %s", str);
                SendClientMessage(i, color, astr);
            }
        }
    }
}

public OnPlayerText(playerid, text[])
{
	new str[600];
	if(LoggedIn[playerid] == false) return SendErrorMessage(playerid, ERROR_LOGGEDIN);
	if(Character[playerid][Muted] != 0) return InfoBoxForPlayer(playerid, "~r~You have been muted - you cannot speak.");

	LastCommandTime[playerid] = gettime();
	Log(playerid, text);

	if(Inventory[playerid][PhoneStatus] != 4)
    {
        format(str, sizeof(str), "%s says: %s",GetRoleplayName(playerid), text);
        SendLocalMessage(playerid, str, Range_Normal, COLOR_WHITE, COLOR_GRAY);
        SetPlayerChatBubble(playerid, text, COLOR_WHITE, Range_Normal, SECONDS(7));
    }  
    else if(Inventory[playerid][PhoneStatus] == 4)
	{

	    format(str, sizeof(str), "[Phone] %s says: %s",GetRoleplayName(playerid), text);
		SendSplitMessage(Inventory[playerid][PhoneCaller], COLOR_WHITE, str);
		SendLocalMessage(playerid, str, Range_Normal, COLOR_WHITE, COLOR_GRAY);
		SetPlayerChatBubble(playerid, text, COLOR_WHITE, Range_Normal, SECONDS(7));

		if(Inventory[playerid][PhoneEmergency] == 1)
		{
			if(strfind(text, "Police", true) != -1 || strfind(text, "Cops", true) != -1 || strfind(text, "sheriff", true) != -1 || strfind(text, "SD", true) != -1)
			{
				EmergencyCall[playerid][Service] = 1;
				Inventory[playerid][PhoneEmergency] = 2;
				SendClientMessage(playerid, COLOR_WHITE, "[Phone] Operator: Okay, you've requested the Sheriff's Department. Could you please give me more information on the incident?");
			}
			else if(strfind(text, "Medic", true) != -1)
			{
				EmergencyCall[playerid][Service] = 3;
				Inventory[playerid][PhoneEmergency] = 2;
				SendClientMessage(playerid, COLOR_WHITE, "[Phone] Operator: Okay, you've requested an Ambulance. Could you please give me more information on the incident?");
			}
			else if(strfind(text, "Fire", true) != -1)
			{
				EmergencyCall[playerid][Service] = 3;
				Inventory[playerid][PhoneEmergency] = 2;
				SendClientMessage(playerid, COLOR_WHITE, "[Phone] Operator: Okay, you've requested the Fire Department. Could you please give me more information on the incident?");
			}
			else
			{
				SendClientMessage(playerid, COLOR_WHITE, "[Phone] Operator: Sorry, I didn't quite get that could you rephrase that?");
			}
		}
		else if(Inventory[playerid][PhoneEmergency] == 2)
		{
			format(EmergencyCall[playerid][Incident], 128, "%s", text);
			SendClientMessage(playerid, COLOR_WHITE, "[Phone] Operator: Thank you. Lastly could you tell me where the incident has taken place?");
			Inventory[playerid][PhoneEmergency] = 3;
		}
		else if(Inventory[playerid][PhoneEmergency] == 3)
		{
			new fid = EmergencyCall[playerid][Service];
			format(EmergencyCall[playerid][Location], 128, "%s", text);
			SendClientMessage(playerid, COLOR_WHITE, "[Phone] Operator: Thank you. I've passed all of the information to the respective department, they should be at your location soon.");
			EndCall(playerid);
			format(str, 128, "[911 Call] Call from: %d", Inventory[playerid][PhoneNumber]);
			SendFactionMessage(fid, COLOR_CORNFLOWERBLUE, str);
			format(str, 128, "[911 Call] Incident description: %s", EmergencyCall[playerid][Incident]);
			SendFactionMessage(fid, COLOR_CORNFLOWERBLUE, str);
			format(str, 128, "[911 Call] Incident location: %s", EmergencyCall[playerid][Location]);
			SendFactionMessage(fid, COLOR_CORNFLOWERBLUE, str);
			Inventory[playerid][PhoneEmergency] = 0;

			new query[600], calltime[12];
			format(calltime, sizeof(calltime), "%02d:%02d:%02d", ClockHours, ClockMinutes, ClockSeconds);
		    mysql_format(SQL_CONNECTION, query, sizeof(query), "INSERT INTO `911 Calls` (Timestamp, Caller, Incident, Location, Service, Number, IGTime) VALUES( %d, %d, '%e', '%e', %d, %d, '%e')", gettime(), Character[playerid][ID], EmergencyCall[playerid][Incident], EmergencyCall[playerid][Location], EmergencyCall[playerid][Service], Inventory[playerid][PhoneNumber], calltime);
			mysql_tquery(SQL_CONNECTION, query);
		}
	}

	return 0;
	
}	

//==============================================================================
//          -- > Chat Commands
//==============================================================================

CMD:b(playerid, params[])
{
    new str[200];
    if(sscanf(params, "s[200]", str)) return SendClientMessage(playerid, COLOR_GRAY, "/b [message]");

    format(str, sizeof(str), "(( %s: %s ))", GetRoleplayName(playerid), str);
    SendLocalMessage(playerid, str,Range_Normal, COLOR_LBLUE, COLOR_LBLUE);
    SetPlayerChatBubble(playerid, str, COLOR_LBLUE, Range_Normal, 7000);

    return 1;
}

CMD:me(playerid, params[])
{
    new str[200];
    if(sscanf(params, "s[200]", str)) return SendClientMessage(playerid, COLOR_GRAY, "/me [message]");

    format(str, sizeof(str), "%s %s", GetRoleplayName(playerid), str);
    SendLocalMessage(playerid, str, Range_Normal, COLOR_RP, COLOR_RP);
    SetPlayerChatBubble(playerid, str, COLOR_RP, Range_Normal, 7000);
    
    return 1;
}

CMD:ame(playerid, params[])
{
    new str[200];
    if(sscanf(params, "s[200]", str)) return SendClientMessage(playerid, COLOR_GRAY, "/ame [message]");

    format(str, sizeof(str), "* %s %s *", GetRoleplayName(playerid), str);
    SetPlayerChatBubble(playerid, str, COLOR_RP, Range_Short, 7000);
    SendClientMessage(playerid, COLOR_RP, str);
    return 1;
}

CMD:a(playerid, params[])
{
    new str[200];
    if(Account[playerid][Admin] > 0)
    {
        if(sscanf(params, "s[200]", str)) return SendClientMessage(playerid, COLOR_GRAY, "/a [text]");
        format(str, sizeof(str), "%s: %s", GetRoleplayName(playerid), str);
        SendAdminsMessage(1, COLOR_TURQUOISE, str);
    }
    else SendErrorMessage(playerid, ERROR_ADMIN);
    return 1;
}

CMD:do(playerid, params[])
{
    new str[200];
    if(sscanf(params, "s[200]", str)) return SendClientMessage(playerid, COLOR_GRAY, "/do [text]");

    format(str, sizeof(str), "%s ((%s))", str, GetRoleplayName(playerid));
    SendLocalMessage(playerid, str, Range_Normal, COLOR_RP, COLOR_RP);
    return 1;
}

CMD:shout(playerid, params[])
{
    new str[200], msg[200];
    if(sscanf(params, "s[200]", msg)) return SendClientMessage(playerid, COLOR_GRAY, "/(s)hout [text]");
    if(Inventory[playerid][PhoneStatus] != 4)
    {
        format(str, sizeof(str), "%s shouts: %s!", GetRoleplayName(playerid), msg);
        SendLocalMessage(playerid, str, Range_Long, COLOR_ORANGE, COLOR_ORANGE);
        SetPlayerChatBubble(playerid, str, COLOR_ORANGE, Range_Long, 7000);
    }
    else
    {
        format(str, sizeof(str), "[Phone] %s shouts: %s!", GetRoleplayName(playerid), msg);
        SendSplitMessage(Inventory[playerid][PhoneCaller], COLOR_ORANGE, msg);
        SendLocalMessage(playerid, str, Range_Long, COLOR_ORANGE, COLOR_ORANGE);
        SetPlayerChatBubble(playerid, str, COLOR_ORANGE, Range_Long, 7000);
    }
    return 1;
}
ALTCMD:s->shout;

CMD:low(playerid, params[])
{
    new str[168], msg[200];
    if(sscanf(params, "s[200]", msg)) return SendClientMessage(playerid, COLOR_GRAY, "/(l)ow [text]");

    format(str, sizeof(str), "[LOW] %s: %s", GetRoleplayName(playerid), msg);
    SendLocalMessage(playerid, str, Range_VShort, COLOR_GRAY, COLOR_GRAY);
    SetPlayerChatBubble(playerid, "* Speaks quietly. *", COLOR_RP, Range_VShort, 4000);

    return 1;
}
ALTCMD:l->low;

CMD:whisper(playerid, params[])
{
    new str[200], msg[200], pID;
    if(sscanf(params, "us[200]", pID,msg)) return SendClientMessage(playerid, COLOR_GRAY, "/whisper [playerid] [message]");

    if(IsInRangeOfPlayer(playerid, pID, 5))
    {
        format(str, sizeof(str), "%s whispers: %s", GetRoleplayName(playerid), msg);
        SendSplitMessage(pID, COLOR_WHITE, str);
        format(str, sizeof(str), "* %s whispers something to %s. *", GetRoleplayName(playerid), GetRoleplayName(pID));
        SendLocalMessage(playerid, str, Range_Short, COLOR_RP, COLOR_RP);
        SetPlayerChatBubble(playerid, str, COLOR_RP, Range_Short, 7000);
    }
    else
    {
        InfoBoxForPlayer(playerid, "You are too far away from this player.");
    }
    return 1;
}
ALTCMD:w->whisper;

CMD:pm(playerid, params[])
{
    new pID, pmmsg[200], str[200];
    if(sscanf(params, "us[200]", pID, pmmsg)) return SendClientMessage(playerid, COLOR_GRAY, "/pm [playerid] [message]");
    format(str, sizeof(str), "[PM from [%d] %s]: %s", playerid, GetRoleplayName(playerid), pmmsg);
    SendSplitMessage(pID, COLOR_YELLOW, str);

    format(str, sizeof(str), "[PM to [%d] %s]: %s", pID, GetRoleplayName(pID), pmmsg);
    SendSplitMessage(playerid, COLOR_YELLOW, str);
    return 1;
}

CMD:ooc(playerid, params[])
{
    new str[128];

    if(sscanf(params, "s[128]", params)) return SendClientMessage(playerid, COLOR_GRAY, "/(o)oc [message]");
    if(OOCStatus == 1)
    {
		if(Character[playerid][Muted] == 0)
		{
	    	format(str, sizeof(str), "(([Global]%s: %s ))", GetRoleplayName(playerid), params);
	    	SendClientMessageToAll(COLOR_LBLUE, str);
	    }
	    else SendErrorMessage(playerid, "You are muted.");
	
	}
	else
	{
	    SendErrorMessage(playerid, "Global chat is currently DISABLED!");
	}
    return 1;
}
ALTCMD:o->ooc;

CMD:announcement(playerid, params[])
{
	new str[200];
	if(Account[playerid][Admin] > 0)
	{
		if(sscanf(params, "s[200]", str)) return SendClientMessage(playerid, COLOR_GRAY, "/announcement [message]");

		format(str, sizeof(str), "[Announcement] %s: %s", GetRoleplayName(playerid), str);
		for (new i = 0; i < MAX_PLAYERS; ++i)
		{
			if(LoggedIn[i] == true) SendSplitMessage(i, COLOR_VIOLET, str);
		}

		SetPlayerChatBubble(playerid, str, COLOR_VIOLET, 20.0, SECONDS(7));
	}
	else SendErrorMessage(playerid, ERROR_ADMIN);
	return 1;
}
ALTCMD:announce->announcement;


CMD:buyhouse(playerid, params[])
{
	new str[128], option[12], id = InRangeOfHouse(playerid);

	if(id == 0) 										return SendErrorMessage(playerid, ERROR_LOCATION);
    if(Houses[id][Owner] != 0) 							return SendErrorMessage(playerid, ERROR_OWNER);
    if(Houses[id][Price] > Character[playerid][Cash])  return SendErrorMessage(playerid, ERROR_MONEY);
	if(Character[playerid][House] != 0) 				return SendErrorMessage(playerid, ERROR_OWNED);
	
	if(sscanf(params, "s[12]", option)) return SendClientMessage(playerid, COLOR_LBLUE, "Are you sure that you want to buy this house? (/buyhouse [confirm/decline])");
	{
		if(!strcmp(option, "confirm", true))
		{
		    format(str, sizeof(str), "> You have bought %s!", Houses[id][Name]);
    		SendClientMessage(playerid, COLOR_LBLUE, str);

		    GivePlayerMoneyEx(playerid, -Houses[id][Price]);
			Character[playerid][House] = id;
            Houses[id][Owner] = Character[playerid][ID];

			MYSQL_Update_Interger(Houses[id][SQLID], "Houses", "Owner", Houses[id][Owner]);

			Reload_House(id);
		}
		
		else if(!strcmp(option, "decline", true))
		{
			SendErrorMessage(playerid, "You chose not to proceed with the purchase.");

		}
	}

	return 1;
}

CMD:sellhouse(playerid, params[])
{
	new str[128], id = InRangeOfHouse(playerid);
	if(id == 0) return SendErrorMessage(playerid, ERROR_LOCATION);

    if(Houses[id][Owner] > 0)
    {
        if(Character[playerid][House] == id)
		{
			new option[12];
			if(sscanf(params, "s[12]", option)) return SendClientMessage(playerid, COLOR_LBLUE, "Are you sure that you want to buy this house? (/buyhouse [confirm/decline])");
			{
				if(!strcmp(option, "confirm", true))
				{
				    format(str, sizeof(str), "> You have sold %s to the server!", Houses[id][Name]);
				    SendClientMessage(playerid, COLOR_LBLUE, str);
				    GivePlayerMoneyEx(playerid, Houses[id][Price]);
					Character[playerid][House] = 0;
					Houses[id][Owner] = 0;

					MYSQL_Update_Interger(Houses[id][SQLID], "Houses", "Owner", 0);

			        Reload_House(id);
		        }

        		else if(!strcmp(option, "decline", true))
				{
					SendErrorMessage(playerid, "You chose not to proceed with the purchase.");

				}
	        }
		}

    }

	return 1;
}

CMD:buybiz(playerid, params[])
{
	new str[128], query[400], id = InRangeOfBiz(playerid);
	if(InRangeOfBiz(playerid) > 0)
	{
 	    if(Business[id][Owned] == 0)
 	    {
 	        if(Character[playerid][Business_1] == 0 || Character[playerid][Business_2] == 0)
 	        {
     	        if(Business[id][Price] <= Character[playerid][Cash])
				{
				    new option[12];
					if(sscanf(params, "s[12]", option)) return SendClientMessage(playerid, COLOR_LBLUE, "Are you sure that you want to buy this business? (/buybiz [confirm/decline])");
					{
						if(!strcmp(option, "confirm", true))
						{
							format(str, sizeof(str), "> You have bought this biz(ID:%d)!", Business[id][SQLID]);
						    SendClientMessage(playerid, COLOR_LBLUE, str);

						    GivePlayerMoneyEx(playerid, -Business[id][Price]);

						    if(Character[playerid][Business_1] == 0)
					    	{
					    		Character[playerid][Business_1] = id;
					    	}
					    	else if(Character[playerid][Business_2] == 0)
					    	{
				    			Character[playerid][Business_2] = id;
					    	}
					    	else return SendErrorMessage(playerid, "You already own two businesses!");
							

							Business[id][Owned] = 1;
							Business[id][Owner] = Character[playerid][ID];

							mysql_format(SQL_CONNECTION, query, sizeof(query), "UPDATE `Business` SET Owner = %d, Owned = %d WHERE SQLID = %d LIMIT 1",  Business[id][Owner],Business[id][Owned],Business[id][SQLID]);
							mysql_tquery(SQL_CONNECTION, query);
							
							mysql_format(SQL_CONNECTION, query, sizeof(query), "SELECT `Name` FROM Characters WHERE SQLID = %d LIMIT 1", Business[id][Owner]);
		        			mysql_tquery(SQL_CONNECTION, query, "Update_Business_Label", "i", id);

							Reload_Business(id);
						}
					}
					if(!strcmp(option, "decline", true))
					{
						SendErrorMessage(playerid, "You chose not to proceed with the purchase.");

					}

				}
				else
				{
				    SendErrorMessage(playerid, ERROR_MONEY);
				}
			}
			else
			{
			    SendErrorMessage(playerid, ERROR_OWNED);
			}
 	    }
 	    else
 	    {
 	        SendErrorMessage(playerid, ERROR_OWNER);
 	    }


	}
	return 1;
}

CMD:sellbiz(playerid, params[])
{
	new id = InRangeOfBiz(playerid);
	if(id > 0)
	{
    	if(Business[id][Owned] == 1)
 	    {
 	        if(Character[playerid][Business_1] == id || Character[playerid][Business_2] == id)
			{
			    new option[12];
				if(sscanf(params, "s[12]", option)) return SendClientMessage(playerid, COLOR_LBLUE, "Are you sure that you want to sell your business? (/sellbiz [confirm/decline])");
				{
					if(!strcmp(option, "confirm", true))
					{
						new str[128], query[400], SalePrice;

					    SalePrice = Business[id][Price] / 2 + 1000;
					    GivePlayerMoneyEx(playerid, SalePrice);
					    format(str, sizeof(str), "> You have sold your business(ID:%d) for $%d!", Business[id][SQLID], SalePrice);
					    SendClientMessage(playerid, COLOR_LBLUE, str);

					    if(Character[playerid][Business_1] == id) Character[playerid][Business_1] = 0;
					    else if(Character[playerid][Business_2] == id) Character[playerid][Business_2] = 0;
					    else return SendErrorMessage(playerid, "Couldn't find business.");

						//format(Business[id][Owner], 32, "");
						Business[id][Owned] = 0;
						Business[id][Owner] = 0;

						mysql_format(SQL_CONNECTION, query, sizeof(query), "UPDATE `Business` SET Owned = 0, Owner = 0 WHERE SQLID = %d LIMIT 1",Business[id][SQLID]);
                        mysql_tquery(SQL_CONNECTION, query);
                        
                        mysql_format(SQL_CONNECTION, query, sizeof(query), "SELECT `Name` FROM Characters WHERE SQLID = %d LIMIT 1", Business[id][Owner]);
		        		mysql_tquery(SQL_CONNECTION, query, "Update_Business_Label", "i", id);
	                    
	                    Reload_Business(id);
					}
					if(!strcmp(option, "decline", true))
					{
						SendClientMessage(playerid, COLOR_GRAY, "You chose not to proceed with the purchase.");
						return 1;

					}
				}
			}
     	}
	}
	else
 	{
 		SendErrorMessage(playerid, ERROR_LOCATION);
 		return 1;
 	}
	return 1;
}

CMD:key(playerid, params[])
{
	new str[128], id = GetNearestVehicle(playerid, 5.0);
	if(id != INVALID_VEHICLE_ID)
	{ 
		if(Vehicles[id][Locked] == 0)
		{
			SetVehicleParamsEx(id, Engine[id], Lights[id], alarm[id], doors[id], bonnet[id], boot[id], objective[id]);

		}
		return 1;
	}

	id = InRangeOfHouse(playerid);
    if(id != 0)
 	{
 	    if(Character[playerid][House] == id)
 	    {
 	        if(Houses[id][Locked] == 0)
 	        {
         		format(str, sizeof(str), "* %s places the key in the door, locking it.*", GetRoleplayName(playerid), str);
				SendLocalMessage(playerid, str, Range_Short, COLOR_RP, COLOR_RP);
				Houses[id][Locked] = 1;
				MYSQL_Update_Interger(Houses[id][SQLID], "Houses", "Locked", 1);
				return 1;
 	        }
 	        else
 	        {
 	            format(str, sizeof(str), "* %s places the key in the door, unlocking it.*", GetRoleplayName(playerid), str);
				SendLocalMessage(playerid, str, Range_Short, COLOR_RP, COLOR_RP);
				Houses[id][Locked] = 0;
				MYSQL_Update_Interger(Houses[id][SQLID], "Houses", "Locked", 0);
				return 1;
 	        }
 	    }
 	}
    
    id = InRangeOfBiz(playerid);
    if(id != 0)
 	{
 	    if(Character[playerid][Business_1] == id || Character[playerid][Business_2] == id)
 	    {
 	        if(Business[id][Locked] == 0)
 	        {
         		format(str, sizeof(str), "* %s places the key in the door, locking it.*", GetRoleplayName(playerid), str);
				SendLocalMessage(playerid, str, Range_Short, COLOR_RP, COLOR_RP);
				Business[id][Locked] = 1;
				MYSQL_Update_Interger(Houses[id][SQLID], "Business", "Locked", 1);
				return 1;
 	        }
 	        else
 	        {
 	            format(str, sizeof(str), "* %s places the key in the door, unlocking it.*", GetRoleplayName(playerid), str);
				SendLocalMessage(playerid, str, Range_Short, COLOR_RP, COLOR_RP);
				MYSQL_Update_Interger(Houses[id][SQLID], "Business", "Locked", 1);
				Business[id][Locked] = 0;
				return 1;
 	        }
 	    }
 	}

	return 0;
}

forward CalculateVehicleSpeed(vehicleid, MPH);
public CalculateVehicleSpeed(vehicleid, MPH)
{
    new Float:speed_x,Float:speed_y,Float:speed_z,Float:calculation, calculation2;
    GetVehicleVelocity(vehicleid,speed_x,speed_y,speed_z);
    if(MPH == 0)
	{
		calculation = floatsqroot(((speed_x*speed_x)+(speed_y*speed_y))+(speed_z*speed_z))*136.666667;
	}
	else
	{
		calculation = floatsqroot(((speed_x*speed_x)+(speed_y*speed_y))+(speed_z*speed_z))*100;
    	calculation2 = floatround(calculation,floatround_round);
    }

    return calculation2;
}

forward UpdateVehicleSpeedo(playerid);
public UpdateVehicleSpeedo(playerid)
{
    new vid = GetPlayerVehicleID(playerid);
	if(GetPlayerVehicleID(playerid))
	{
	    ShowSpeedo(playerid, CalculateVehicleSpeed(vid, 1), Vehicles[vid][Fuel]);
	}
	else
	{
	    HideSpeedo(playerid);
	    KillTimer(Speedo[playerid]);
	}


    return 1;
}

CMD:aengine(playerid,params[])
{
	new State = GetPlayerState(playerid), vid = GetPlayerVehicleID(playerid);
	if(Account[playerid][Admin] > 5)
	{
		if(IsABike(vid))	{	SetVehicleParamsEx(vid, 1, Lights[vid], alarm[vid], doors[vid], bonnet[vid], boot[vid], objective[vid]);	}
		if(IsPlayerInAnyVehicle(playerid))
		{
		    if(State == PLAYER_STATE_DRIVER)
		    {

				    Engine_TOGGLE(playerid, vid);

		    }
		    else
		    {
				SendClientMessage(playerid, COLOR_GRAY, "You have to be the driver of a vehicle to use this command.");
		    }
		}
		else
		{
		    SendErrorMessage(playerid, ERROR_VEHICLE);
		}
	}
	return 1;
}

stock IsPlayerVehicle(vid)
{
	if(Vehicles[vid][Type] == 1)
	{
		return 1;
	}
	return 0;

}

stock IsServerVehicle(vid)
{
	if(Vehicles[vid][Type] == 2 || Vehicles[vid][Type] == 4 || Vehicles[vid][Type] == 5 || Vehicles[vid][Type] == 6)
	{
		return 1;
	}
	return 0;
}

stock IsPlayerVehicleOwner(playerid, vid)
{
	if(IsPlayerVehicle(vid) && Vehicles[vid][Owner] == Character[playerid][ID])
	{
		return 1;
	}
	return 0;

}

CanDriveVehicle(playerid, vid)
{
	if(IsAdminSpawnedVehicle(vid) || IsPlayerVehicle(vid) && IsPlayerVehicleOwner(playerid, vid))
	{
		return 1;
	}
	else if(Vehicles[vid][Type] == 4 && GDL_Test[playerid] > 0 || Trucking[playerid][CheckpointID] > 0 && Vehicles[vid][Type] == 5 || Vehicles[vid][Type] == 3 && Vehicles[vid][Faction] == Character[playerid][Faction] && Vehicles[vid][Rank] <= Character[playerid][Rank])
	{
		return 1;
	}
	return 0;

}

CanHotwireVehicle(vid)
{
	if(IsAdminSpawnedVehicle(vid) || IsPlayerVehicle(vid) && Vehicles[vid][Locked] == 0  || Vehicles[vid][Type] == 6)
	{
		if(Engine[vid] != 1)
		{
			return 1;
		}
	}
	return 0;
}

CMD:hotwire(playerid)
{
	new State = GetPlayerState(playerid), vid = GetPlayerVehicleID(playerid);

	if(IsPlayerInAnyVehicle(playerid))
	{
		if(State == PLAYER_STATE_DRIVER)
		{
			if(CanHotwireVehicle(vid))
			{
				if(Inventory[playerid][Screwdriver] > 0)
				{
					TakeInventoryItem(playerid, SCREWDRIVER, 1);
					Hotwire_Stage1(playerid, vid);
				}
				else SendErrorMessage(playerid, "You do not have the equipment required to hotwire this vehicle.");
			}
			else SendErrorMessage(playerid, "This vehicle cannot be hotwired.");
		}
		else SendErrorMessage(playerid, "You need to be in the driver's seat in order to hotwire the vehicle.");
	}
	else SendErrorMessage(playerid, "You are not in a vehicle.");
	return 1;
}

Hotwire_Stage1(playerid, vid)
{
	new str[128];
   	format(str, sizeof(str), "* %s reaches under the dashboard, ripping away the plastic cover revealing some exposed wiring. *", GetRoleplayName(playerid));
	SendLocalMessage(playerid, str, Range_Normal, COLOR_RP, COLOR_RP);
	SetTimerEx("Hotwire_Stage2", 2000, false, "dd", playerid, vid);
	return 1;
}

forward Hotwire_Stage2(playerid, vid);
public Hotwire_Stage2(playerid, vid)
{
	new str[128];
   	format(str, sizeof(str), "* %s uses their screwdriver to pry open the plastic coating of the wires before attempting the hotwire... *", GetRoleplayName(playerid));
	SendLocalMessage(playerid, str, Range_Normal, COLOR_RP, COLOR_RP);
	SetTimerEx("Hotwire_Stage3", 2000, false, "dd", playerid, vid);
	return 1;
}

forward Hotwire_Stage3(playerid, vid);
public Hotwire_Stage3(playerid, vid)
{
	new str[128], rand = random(10);
   	format(str, sizeof(str), "* %s touches two wires together in an attempt to start the engine... *", GetRoleplayName(playerid));
	SendLocalMessage(playerid, str, Range_Normal, COLOR_RP, COLOR_RP);
	if(rand > 5)
	{
		SetTimerEx("Hotwire_Stage4", 2000, false, "dd", playerid, vid);
	}
	else SetTimerEx("Hotwire_Stage3", 2000, false, "dd", playerid, vid);
	return 1;
}

forward Hotwire_Stage4(playerid, vid);
public Hotwire_Stage4(playerid, vid)
{
	new str[128];
   	format(str, sizeof(str), "* At last the engine roars into life. *", GetRoleplayName(playerid));
	SendLocalMessage(playerid, str, Range_Normal, COLOR_RP, COLOR_RP);
	SendClientMessage(playerid, COLOR_WHITE, "Vehicle hotwired.");
	Engine_SET(playerid, vid, 1);
	Vehicles[vid][Hotwired] = 1;
	return 1;
}

CMD:engine(playerid,params[])
{
	new State = GetPlayerState(playerid), vid = GetPlayerVehicleID(playerid);
	if(IsABike(vid))	{	SetVehicleParamsEx(vid, 1, Lights[vid], alarm[vid], doors[vid], bonnet[vid], boot[vid], objective[vid]);	}
	if(IsPlayerInAnyVehicle(playerid))
	{
	    if(State == PLAYER_STATE_DRIVER)
	    {
	        if(CanDriveVehicle(playerid, vid))
	        {
		        Engine_TOGGLE(playerid, vid);
			}
			else
			{
			    SendClientMessage(playerid, COLOR_GRAY, "You do not have the keys for this vehicle!");
			}
	    }
	    else
	    {
			SendClientMessage(playerid, COLOR_GRAY, "You have to be the driver of a vehicle to use this command.");
	    }
	}
	else
	{
	    SendErrorMessage(playerid, ERROR_VEHICLE);
	}
	return 1;
}
ALTCMD:e->engine;


CMD:stall(playerid,params[])
{
	new State = GetPlayerState(playerid), vid = GetPlayerVehicleID(playerid);
	if(IsPlayerInAnyVehicle(playerid))
	{
	    if(State == PLAYER_STATE_DRIVER)
	    {
	    	if(Engine[vid] == 1)
	    	{
		    	new str[128];
		    	format(str, sizeof(str), "* The vehicle's engine would cut out. It would appear that %s stalled it. *", GetRoleplayName(playerid));
				SendLocalMessage(playerid, str, Range_Normal, COLOR_RP, COLOR_RP);
			    Engine_SET(playerid, vid, 0);
			}
	    }
	    else
	    {
			SendClientMessage(playerid, COLOR_GRAY, "You have to be the driver of a vehicle to use this command.");
	    }
	}
	else
	{
	    SendErrorMessage(playerid, ERROR_VEHICLE);
	}
	return 1;
}

stock Engine_TOGGLE(playerid, vid)
{
	new str[128];
	GetVehicleParamsEx(vid, Engine[vid], Lights[vid], alarm[vid], doors[vid], bonnet[vid], boot[vid], objective[vid]);
    if(Engine[vid] <= 0)
    {
        format(str, sizeof(str), "* %s places the key into the ignition, turning the key, attempting to turn the engine on. *", GetRoleplayName(playerid));
		SendLocalMessage(playerid, str, Range_Normal, COLOR_RP, COLOR_RP);

		Engine_SET(playerid, vid, 1);

		//Vehicles[vid][FuelTimer] = SetTimerEx("ReduceFuel", 60000, true, "d", vid);
		return 1;
    }
    else if(Engine[vid] >= 1)
    {
        format(str, sizeof(str), "* %s turns the key, turning the engine off and removing the keys from the ignition. *", GetRoleplayName(playerid));
		SendLocalMessage(playerid, str, Range_Normal, COLOR_RP, COLOR_RP);

		Engine_SET(playerid, vid, 0);
        return 1;
    }
	return 1;
}


stock Engine_SET(playerid, vid, State)
{

	GetVehicleParamsEx(vid, Engine[vid], Lights[vid], alarm[vid], doors[vid], bonnet[vid], boot[vid], objective[vid]);
	if(Engine[vid] == State) return 1;
    if(Engine[vid] == 0 || Engine[vid] && State == 1)
    {
    	static Float:VehicleHP;
    	GetVehicleHealth(vid, VehicleHP);
    	if(VehicleHP <= 300.0) return SendLocalMessage(playerid, "* The engine wouldn't start as it's extensively damaged. *", Range_Normal, COLOR_RP, COLOR_RP);
    	if(Vehicles[vid][Fuel] <= 0) return SendLocalMessage(playerid, "* The engine wouldn't turn on due to a lack of fuel. *", Range_Normal, COLOR_RP, COLOR_RP);
		SetVehicleParamsEx(vid,1,Lights[vid],alarm[vid],doors[vid],bonnet[vid],boot[vid],objective[vid]);
		Engine[vid] = 1;
		KillTimer(Vehicles[vid][FuelTimer]);
		Vehicles[vid][FuelTimer] = SetTimerEx("ReduceFuel", MINUTES(1), true, "d", vid);
		GameTextForPlayer(playerid, "~g~Engine On!", 2000, 4);
		return 1;
    }
    else if(Engine[vid] == 1 && State == 0)
    {
		SetVehicleParamsEx(vid,0,Lights[vid],alarm[vid],doors[vid],bonnet[vid],boot[vid],objective[vid]);
        Engine[vid] = 0;
        KillTimer(Vehicles[vid][FuelTimer]);
        return 1;
    }
    //printf("vid = %d, state: %d, playerid: %d, engine: %d", vid, State, playerid, Engine[vid]);
	return 1;
}

stock Lights_TOGGLE(playerid, vid)
{
	GetVehicleParamsEx(vid, Engine[vid], Lights[vid], alarm[vid], doors[vid], bonnet[vid], boot[vid], objective[vid]);
    if(Lights[vid] == 0)
    {
		SetVehicleParamsEx(vid,Engine[vid],1,alarm[vid],doors[vid],bonnet[vid],boot[vid],objective[vid]);
		Lights[vid] = 1;
		GameTextForPlayer(playerid, "~g~Lights ON!", 2000, 4);
    }
    else
    {
		SetVehicleParamsEx(vid,Engine[vid],0,alarm[vid],doors[vid],bonnet[vid],boot[vid],objective[vid]);
		Lights[vid] = 0;
		GameTextForPlayer(playerid, "~r~Lights OFF!", 2000, 4);
    }
	return 1;
}

stock Lights_SET(vid, State)
{

	GetVehicleParamsEx(vid, Engine[vid], Lights[vid], alarm[vid], doors[vid], bonnet[vid], boot[vid], objective[vid]);
    if(Lights[vid] == 0 || Lights[vid] && State == 1)
    {
		SetVehicleParamsEx(vid,Engine[vid],1,alarm[vid],doors[vid],bonnet[vid],boot[vid],objective[vid]);
		Lights[vid] = 1;

    }
    else if(Lights[vid] == 1 && State == 0)
    {
		SetVehicleParamsEx(vid,Engine[vid],0,alarm[vid],doors[vid],bonnet[vid],boot[vid],objective[vid]);
		Lights[vid] = 0;
    }
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	Engine[vehicleid] = 0;
	Lights[vehicleid] = 0;

	EmergencyLights[vehicleid] = 0;
	SetVehicleParamsEx(vehicleid, 0, 0,alarm[vehicleid],doors[vehicleid],bonnet[vehicleid],boot[vehicleid],objective[vehicleid]);

	if(Vehicles[vehicleid][FuelTimer] > -1)
	{
		KillTimer(Vehicles[vehicleid][FuelTimer]);
	}

	if(Vehicles[vehicleid][Type] == 1)
	{
	    if(Vehicles[vehicleid][Nitrous] > 1007 && Vehicles[vehicleid][Nitrous] < 1011)
    	{
    		AddVehicleComponent(vehicleid, Vehicles[vehicleid][Nitrous]);
    	}
    	if(Vehicles[vehicleid][Hydraulics] == 1087)
    	{
    		AddVehicleComponent(vehicleid, Vehicles[vehicleid][Hydraulics]);
    	}
    	if(Vehicles[vehicleid][Wheels] > 1072 && Vehicles[vehicleid][Wheels] < 1086)
    	{
    		AddVehicleComponent(vehicleid, Vehicles[vehicleid][Wheels]);
    	}
	}

	if(IsPlayerVehicle(vehicleid))
	{
		if(Vehicles[vehicleid][Broken] == 1)
		{
			SetVehicleHealth(vehicleid, 300.0);
		}
	}

	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	if(IsPlayerVehicle(vehicleid)) 
	{
		if(Vehicles[vehicleid][Broken] == 0) 
		{
			Vehicles[vehicleid][Broken] = 1;
			MYSQL_Update_Interger(Vehicles[vehicleid][SQLID], "PlayerVehicles", "Broken", 1);
		}
    }
    return 1;
}

forward ReduceFuel(vehicleid);
public ReduceFuel(vehicleid)
{
	if(Engine[vehicleid] == 1)
	{
		if(Vehicles[vehicleid][Fuel] > 0)
		{
			//printf("Fuel Down");
			//printf("From: %d", Vehicles[vehicleid][Fuel]);
			Vehicles[vehicleid][Fuel] --;
			//printf("To: %d", Vehicles[vehicleid][Fuel]);
			//printf("Timer: %d", Vehicles[vehicleid][FuelTimer]);
			if(Vehicles[vehicleid][Type] == 2 || Vehicles[vehicleid][Type] == 4 || Vehicles[vehicleid][Type] == 5 || Vehicles[vehicleid][Type] == 6)
			{
				MYSQL_Update_Interger(Vehicles[vehicleid][SQLID], "ServerVehicles", "Fuel", Vehicles[vehicleid][Fuel]);
			}
			else if(Vehicles[vehicleid][Type] == 1)
			{
				MYSQL_Update_Interger(Vehicles[vehicleid][SQLID], "PlayerVehicles", "Fuel", Vehicles[vehicleid][Fuel]);
			}
			else if(Vehicles[vehicleid][Type] == 3)
			{
				MYSQL_Update_Interger(Vehicles[vehicleid][SQLID], "FactionVehicles", "Fuel", Vehicles[vehicleid][Fuel]);
			}
		}
		else
		{

			SetVehicleParamsEx(vehicleid, 0, 0,alarm[vehicleid],doors[vehicleid],bonnet[vehicleid],boot[vehicleid],objective[vehicleid]);
			Engine[vehicleid] = 0;
			Lights[vehicleid] = 0;
		}
	}
	else KillTimer(Vehicles[vehicleid][FuelTimer]);
	return 1;
}

CMD:setfuel(playerid,params[])
{
	new State = GetPlayerState(playerid), vehicleid = GetPlayerVehicleID(playerid);
	if(Account[playerid][Admin] > 0)
	{
		new option;
		if(sscanf(params, "d", option)) return SendClientMessage(playerid, COLOR_GRAY, "/setfuel [amount]");
		{
			if(option > -1 && option < 101)
			{
				if(IsPlayerInAnyVehicle(playerid))
				{
				    if(State == PLAYER_STATE_DRIVER)
				    {
						Vehicles[vehicleid][Fuel] = option;
						if(Vehicles[vehicleid][Type] == 2 || Vehicles[vehicleid][Type] == 4 || Vehicles[vehicleid][Type] == 5 || Vehicles[vehicleid][Type] == 6)
						{
							MYSQL_Update_Interger(Vehicles[vehicleid][SQLID], "ServerVehicles", "Fuel", Vehicles[vehicleid][Fuel]);

						}
						if(Vehicles[vehicleid][Type] == 1)
						{
							MYSQL_Update_Interger(Vehicles[vehicleid][SQLID], "PlayerVehicles", "Fuel", Vehicles[vehicleid][Fuel]);
						}
						if(Vehicles[vehicleid][Type] == 3)
						{
							MYSQL_Update_Interger(Vehicles[vehicleid][SQLID], "FactionVehicles", "Fuel", Vehicles[vehicleid][Fuel]);
						}

				    }
				    else
				    {
						SendClientMessage(playerid, COLOR_GRAY, "You have to be the driver of a vehicle to use this command.");
				    }
				}
				else
				{
				    SendErrorMessage(playerid, ERROR_VEHICLE);
				}
			}
		}
	}
	return 1;
}

CMD:refuel(playerid,params[])
{
	if(IsPlayerInAnyVehicle(playerid))
	{
		new State = GetPlayerState(playerid), vid = GetPlayerVehicleID(playerid), str[128], option, refueltime;

		if(!InRangeOfPump(playerid)) return SendErrorMessage(playerid, ERROR_LOCATION);
		if(Engine[vid] == 1) return SendErrorMessage(playerid, "You cannot refuel with your engine on!");
		format(str, sizeof(str), "/refuel [amount] - Current Level: %d", Vehicles[vid][Fuel]);
		if(sscanf(params, "d", option)) return SendClientMessage(playerid, COLOR_GRAY, str);
		{
			if(option > -1 && option < 101 && option + Vehicles[vid][Fuel] < 101)
			{
				new cost = option * 2; //+ tax; tax = random(10),
				if(cost <= Character[playerid][Cash])
				{

					    if(State == PLAYER_STATE_DRIVER)
					    {
						    Vehicles[vid][Fuel] += option;
					    	format(str, sizeof(str), "You have been charged $%d for your purchase of %d liters of fuel." , cost, option);
						    SendClientMessage(playerid, COLOR_SEAGREEN, str);
					    	GivePlayerMoneyEx(playerid, -cost);
					    	TogglePlayerControllable(playerid, 0);
					    	refueltime = option * 300;
							SetTimerEx("Refueled", refueltime, false, "d", playerid);
							GameTextForPlayer(playerid, "~p~Refueling...", refueltime, 3);
					    }
					    else
					    {
							SendClientMessage(playerid, COLOR_GRAY, "You have to be the driver of a vehicle to use this command.");
					    }
				}
				else
				{
					SendErrorMessage(playerid, ERROR_MONEY);
				}
			}
		}
	}
	else
	{
	    SendErrorMessage(playerid, ERROR_VEHICLE);
	}
	return 1;
}

stock GetVehiclePosEx(vid, &Float:px, &Float:py, &Float:pz, Float:offsetx = 0.0, Float:offsety = 0.0, Float:offsetz = 0.0)
{
    new
        Float:rx, Float:ry, Float:rz,
        Float:sx, Float:sy, Float:sz,
        Float:cy, Float:cx, Float:cz;
    GetVehiclePos(vid, px, py, pz);
    GetVehicleRot(vid, rx, ry, rz);
    sx = floatsin(rx, degrees),
    sy = floatsin(ry, degrees),
    sz = floatsin(rz, degrees),
    cx = floatcos(rx, degrees),
    cy = floatcos(ry, degrees),
    cz = floatcos(rz, degrees);
    if (offsetx)
    {
        px = px + offsetx * (cy * cz - sx * sy * sz);
        py = py + offsetx * (cz * sx * sy + cy * sz);
        pz = pz - offsetx * (cx * sy);
    }
    if (offsety)
    {
        px = px - offsety * (cx * sz);
        py = py + offsety * (cx * cz);
        pz = pz + offsety * (sx);
    }
    if (offsetz)
    {
        px = px + offsetz * (cz * sy + cy * sx * sz);
        py = py - offsetz * (cy * cz * sx + sy * sz);
        pz = pz + offsetz * (cx * cy);
    }
    return 1;
}

stock GetVehicleRot(vehicleid, &Float:rx, &Float:ry, &Float:rz)
{
    new
        Float:qw,
        Float:qx,
        Float:qy,
        Float:qz;
    GetVehicleRotationQuat(vehicleid, qw, qx, qy, qz);
    ConvertQuatToEuler(qw, -qx, -qy, -qz, rx, ry, rz);
    return 1;
}

stock ConvertQuatToEuler(Float:qw, Float:qx, Float:qy, Float:qz, &Float:rx, &Float:ry, &Float:rz)
{
    new
        Float:sqw = qw * qw,
        Float:sqx = qx * qx,
        Float:sqy = qy * qy,
        Float:sqz = qz * qz;
    rx = asin (2 * (qw * qx + qy * qz) / (sqw + sqx + sqy + sqz));
    ry = atan2(2 * (qw * qy - qx * qz), 1 - 2 * (sqy + sqx));
    rz = atan2(2 * (qw * qz - qx * qy), 1 - 2 * (sqz + sqx));
    return 1;
}

forward Refueled(playerid);
public Refueled(playerid)
{
	TogglePlayerControllable(playerid, 1);
	GameTextForPlayer(playerid, "~p~Refueling Complete!", 3000, 3);
	return 1;
}



CMD:lights(playerid, params[])
{
    new State = GetPlayerState(playerid), vid = GetPlayerVehicleID(playerid);
	if(vid)
	{
	    if(State == PLAYER_STATE_DRIVER)
	    {
			Lights_TOGGLE(playerid, vid);
	    }
	    else
	    {
	        SendErrorMessage(playerid, "You must be the vehicle driver to use this command.");
	    }
	}
	else
	{
	    SendErrorMessage(playerid, "This can only be done as the driver of a vehicle.");
	}

	return 1;
}
ALTCMD:lon->lights;

stock IsBusinessOwner(playerid, bid)
{
	if(Business[bid][Owner] == Character[playerid][ID]) return 1;
	return 0;
}

IsInOwnedBusiness(playerid)
{
	if(Character[playerid][bEntered] == Character[playerid][Business_1] || Character[playerid][bEntered] == Character[playerid][Business_2]) return Character[playerid][bEntered];
	return 0;
}



CMD:safestore(playerid,params[])
{
		new str[128], amount, bid = IsInOwnedBusiness(playerid);
		if(bid)
		{
			if(sscanf(params, "d", amount)) return SendClientMessage(playerid, COLOR_GRAY, "/safestore [amount]");
			if(Character[playerid][Cash] >= amount)
			{
				MYSQL_Update_Interger(Business[bid][SQLID], "Business", "Safe", Business[bid][Safe] += amount);
				format(str, sizeof(str), "You stored $%d in the safe! Total($%d)", amount, Business[bid][Safe]);
				SendClientMessage(playerid, COLOR_GREEN, str);
				GivePlayerMoneyEx(playerid, -amount);
			}
			else
			{
			SendErrorMessage(playerid, ERROR_MONEY);
			}
		}
		else
		{
			SendErrorMessage(playerid, ERROR_LOCATION);
		}
		return 1;
}

/*CMD:crime(playerid,params[])
{
	new id;
	if(sscanf(params, "d", id)) return SendClientMessage(playerid, COLOR_GRAY, "/crime [id]");
	{
		PlayCrimeReportForPlayer(playerid, 0, id);
	}

	return 1;
}*/

CMD:safeget(playerid,params[])
{
		new str[128], amount, bid = IsInOwnedBusiness(playerid);
		if(bid)
		{
			if(sscanf(params, "d", amount)) return SendClientMessage(playerid, COLOR_GRAY, "/safeget [amount]");
			if(Business[bid][Safe] >= amount)
			{
				MYSQL_Update_Interger(Business[bid][SQLID], "Business", "Safe", Business[bid][Safe] -= amount);
				format(str, sizeof(str), "You taken $%d from the safe! Total($%d)", amount, Business[bid][Safe]);
				SendClientMessage(playerid, COLOR_GREEN, str);
				GivePlayerMoneyEx(playerid, amount);
			}
			else
			{
			SendErrorMessage(playerid, ERROR_MONEY);
			}
		}
		else
		{
			SendErrorMessage(playerid, ERROR_LOCATION);
		}
		return 1;
}

CMD:checksafe(playerid,params[])
{
		new str[128], bid = IsInOwnedBusiness(playerid);
		if(bid)
		{
		    bid = Character[playerid][bEntered];
			format(str, sizeof(str), "There is $%d in the safe!", Business[bid][Safe]);
			SendClientMessage(playerid, COLOR_GREEN, str);
		}
		else
		{
			SendErrorMessage(playerid, ERROR_LOCATION);
		}
		return 1;
}

CMD:entrancefee(playerid,params[])
{
		new str[128], amount, bid = IsInOwnedBusiness(playerid);
		if(bid)
		{
			if(sscanf(params, "d", amount)) return SendClientMessage(playerid, COLOR_GRAY, "/entrancefee [amount]");
			if(amount > 0 && amount <= 50)
			{
			    Business[bid][EntranceFee] = amount;
			    MYSQL_Update_Interger(Business[bid][SQLID], "Business", "EntranceFee", Business[bid][EntranceFee]);
				format(str, sizeof(str), "EntranceFee set at $%d!", Business[bid][EntranceFee]);
				SendClientMessage(playerid, COLOR_GREEN, str);
				Reload_Business(bid);
			}
			else
			{
				SendErrorMessage(playerid, ERROR_MONEY);
			}
		}
		else
		{
			SendErrorMessage(playerid, ERROR_LOCATION);
		}
		return 1;
}


CMD:myvehicles(playerid, params[])
{
	new str[128], dialog[1000];
	for (new i = 0; i < MAX_VEHICLES; ++i)
	{
		if(GetVehicleModel(i))
		{
			if(Vehicles[i][Owner] == Character[playerid][ID])
			{
				

				format(str, sizeof(str), "%s (%d)\n", VehicleNames[GetVehicleModel(i)-400], i);
				strcat(dialog, str, sizeof(dialog));

				
			}
		}
	}
	Dialog_Show(playerid, None, DIALOG_STYLE_LIST, "My Vehicles", dialog, "Close","");
	return 1;
}



forward InRangeOfIcon(playerid, type);
public InRangeOfIcon(playerid, type)
{
	for(new id = 0; id < MAX_ICONS; id++)
	{
		if(IsPlayerInRangeOfPoint(playerid, 4.0, Icons[id][PosX], Icons[id][PosY], Icons[id][PosZ]) && Icons[id][Type] == type)
		{
		    return 1;
		}

	}
	return 0;
}



forward InRangeOfAnyIcon(playerid);
public InRangeOfAnyIcon(playerid)
{
	for(new id = 0; id < MAX_ICONS; id++)
	{
		if(IsPlayerInRangeOfPoint(playerid, 4.0, Icons[id][PosX], Icons[id][PosY], Icons[id][PosZ]))
		{
		    return 1;
		}

	}
	return 0;
}


forward InRangeOfBiz(playerid);
public InRangeOfBiz(playerid)
{
	for(new id = 0; id < MAX_BIZ; id++)
	{
		if(IsPlayerInRangeOfPoint(playerid, 3.0, Business[id][PosX], Business[id][PosY], Business[id][PosZ]))
		{
		    return id;
		}

	}
	return 0;
}

CMD:bizinfo(playerid,params[])
{
	if(Account[playerid][Admin] >= 1)
	{
		if(InRangeOfBiz(playerid) > 0)
		{
		    new str[128];
            format(str, sizeof(str), ""COL_WHITE"Business ID:"COL_BLUE" %d \n"COL_WHITE"Price:"COL_BLUE" $%d \n"COL_WHITE"Safe Amount:"COL_BLUE" $%d", InRangeOfBiz(playerid), Business[InRangeOfBiz(playerid)][Price], Business[InRangeOfBiz(playerid)][Safe]);
		    Dialog_Show(playerid,BANK_BALANCE,DIALOG_STYLE_MSGBOX,"Business Information",str,"Close","");
		}
		else
		{

		}
	}
	return 1;
}
ALTCMD:binfo->bizinfo;

Dialog:QUIZ22(playerid, response, listitem, inputtext[])
{
	if(listitem + 1 == strval(QAnswer[playerid]))
	{
		Quiz_Info2(playerid, CORRECT);
	}
	else
	{
		Quiz_Info2(playerid, WRONG);
	}
    return 1;
}

stock Quiz_Info2(playerid, info)
{
	if(info == 0)
	{
	    InfoBoxForPlayer(playerid, "That is the ~r~INCORRECT ~w~please review your answer - reconnect to try the quiz again.");
	}
	if(info == 1)
	{
	    InfoBoxForPlayer(playerid, "Good job, you got the answer ~g~CORRECT~w~!");
	}
	return 1;
}

CMD:quiztest(playerid,params[])
{
	if(Account[playerid][Admin] >= 1)
	{
		new rand;
		if(sscanf(params, "d", rand)) return SendClientMessage(playerid, COLOR_GRAY, "/quiztest [section]");
	    //new rand = random(sizeof(QuizQuestions));
	    CreateSpacer(playerid, 10);
	    format(QAnswer[playerid], 2, "%d", strval(QuizQuestions[rand][0]));
		Dialog_Show(playerid, QUIZ22, DIALOG_STYLE_LIST, QuizQuestions[rand][1], QuizQuestions[rand][2],"Select","");
		SendSplitMessage(playerid, COLOR_SLATEGRAY, QuizQuestions[rand][1]);
		SendSplitMessage(playerid, COLOR_WHITE, QuizQuestions[rand][2]);

	}
	return 1;
}

CMD:balance(playerid,params[])
{
    if(InRangeOfIcon(playerid, 5) == 1)
	{
		new str[128];
		if(Business[Character[playerid][bEntered]][Owned] == 2)
		{
			format(str, sizeof(str), "Bank Balance: "COL_DGREEN"$%s", FormatNumber(Character[playerid][Bank]));
			Dialog_Show(playerid,BANK_BALANCE,DIALOG_STYLE_MSGBOX,"- My Bank -",str,"Close","");
		}
		else
		{
			SendErrorMessage(playerid, ERROR_LOCATION);
		}
	}
	return 1;
}

Dialog:BANK_BALANCE(playerid, response, listitem, inputtext[])
{
    return 1;
}

CMD:withdraw(playerid,params[])
{
	if(InRangeOfIcon(playerid, 5) == 1)
	{
		new str[128], amount;
		if(Business[Character[playerid][bEntered]][Owned] == 2)
		{
			if(sscanf(params, "d", amount)) return SendClientMessage(playerid, COLOR_GRAY, "/withdraw [amount]");
			if(Character[playerid][Bank] >= amount)
			{
				MYSQL_Update_Character(playerid, "Bank", Character[playerid][Bank] -= amount);

				format(str, sizeof(str), ""COL_LBLUE"Withdrawal Amount: "COL_DGREEN"$%s\n"COL_LBLUE"Bank Balance: "COL_DGREEN"$%s", FormatNumber(amount), FormatNumber(Character[playerid][Bank]));
				Dialog_Show(playerid,BANK_BALANCE,DIALOG_STYLE_MSGBOX,"- My Bank -",str,"Close","");
				GivePlayerMoneyEx(playerid, amount);
			}
			else
			{
			SendErrorMessage(playerid, ERROR_MONEY);
			}
		}
		else
		{
			SendErrorMessage(playerid, ERROR_LOCATION);
		}
	}
	return 1;
}

CMD:deposit(playerid,params[])
{
	if(InRangeOfIcon(playerid, 5) == 1)
	{
		new str[128], amount;
		if(Business[Character[playerid][bEntered]][Owned] == 2)
		{
			if(sscanf(params, "d", amount)) return SendClientMessage(playerid, COLOR_GRAY, "/deposit [amount]");
			if(Character[playerid][Cash] >= amount)
			{
				MYSQL_Update_Character(playerid, "Bank", Character[playerid][Bank] += amount);
				format(str, sizeof(str), ""COL_LBLUE"Deposited Amount: "COL_DGREEN"$%s\n"COL_LBLUE"Bank Balance: "COL_DGREEN"$%s", FormatNumber(amount), FormatNumber(Character[playerid][Bank]));
				Dialog_Show(playerid,BANK_BALANCE,DIALOG_STYLE_MSGBOX,"- My Bank -",str,"Close","");
				GivePlayerMoneyEx(playerid, -amount);
			}
			else
			{
			SendErrorMessage(playerid, ERROR_MONEY);
			}
		}
		else
		{
			SendErrorMessage(playerid, ERROR_LOCATION);
		}
	}
	return 1;
}

//==============================================================================
//
//      -- > ADMIN COMMANDS
//
//==============================================================================

CMD:ahelp(playerid, params[])
{
	if(Account[playerid][Admin] == 0) return SendErrorMessage(playerid, ERROR_ADMIN);
	if(Account[playerid][Admin] >= 1)
	{
		SendClientMessage(playerid, COLOR_YELLOW, "Admin Commands:");
		SendClientMessage(playerid, COLOR_GRAY, "ADMIN LVL 1:[/adminduty][/binfo][/kick][/ban][/(un)freeze][/(down)slap][/(un)mute][/(announce)ment]");
		SendClientMessage(playerid, COLOR_GRAY, "ADMIN LVL 1:[/setplayer [id] [option]]");
		SendClientMessage(playerid, COLOR_GRAY, "ADMIN LVL 1:\t [health][armour][level][skinvw][inteior][age][gender]");
	}
	if(Account[playerid][Admin] >= 2)
	{
		SendClientMessage(playerid, COLOR_GRAY, "ADMIN LVL 2:[/gotoh][/gotoi][/gotob][/gotov][/gotop][/getp][/getv][/giveweapon][/resetweapons]");
	}
	if(Account[playerid][Admin] >= 3)
	{
		SendClientMessage(playerid, COLOR_GRAY, "ADMIN LVL 3:[/deletepv][/vehicle][/delv][/delvall][/fvreload]");
	}
	if(Account[playerid][Admin] >= 4)
	{
		SendClientMessage(playerid, COLOR_GRAY, "ADMIN LVL 4:[/sethouse][/seticon][/setveh][/settime]");
	}
	if(Account[playerid][Admin] >= 5)
	{
		SendClientMessage(playerid, COLOR_GRAY, "ADMIN LVL 5:[/createfv][/deletefv][/factionmanager][/businessmanager][/iconmanager]");
 		SendClientMessage(playerid, COLOR_GRAY, "ADMIN LVL 5:[/setplayer [id] [option]]");
		SendClientMessage(playerid, COLOR_GRAY, "ADMIN LVL 5:\t [faction][rank][job][hentered][bentered]");
	}
	if(Account[playerid][Admin] >= 6)
	{
		SendClientMessage(playerid, COLOR_GRAY, "ADMIN LVL 6:[/reload][/payday][/createsv][/deletesv][/setbiz][/housemanager]");
		SendClientMessage(playerid, COLOR_GRAY, "ADMIN LVL 6:[/editobject][/selectobject][/makemovableobject][/changecname][/achangeapassword]");
 		SendClientMessage(playerid, COLOR_GRAY, "ADMIN LVL 6:[/setplayer [id] [option]]");
 		SendClientMessage(playerid, COLOR_GRAY, "ADMIN LVL 6:\t [house][Business_1][bank][cash][admin][vehicle(1,2,3)][ExemptIP]");
		SendClientMessage(playerid, COLOR_GRAY, "DEBUG CMD:  [/inhouse][/inbiz][/vinfo][/binfo]");
	}
	
	return 1;
}
ALTCMD:ah->ahelp;

CMD:inhouse(playerid,params[])
{
	new str[128];
	if(Account[playerid][Admin] >= 1)
		{
			format(str, sizeof(str), "You are in house: %d and next id is ", Character[playerid][hEntered]);
			SendClientMessage(playerid, COLOR_GRAY, str);
		}
	else
		{
			SendErrorMessage(playerid, ERROR_ADMIN);
		}
	return 1;
}

CMD:inbiz(playerid,params[])
{
	new str[128];
	if(Account[playerid][Admin] >= 1)
		{
			format(str, sizeof(str), "You are in business: %d next ID is. You are in VW %d %d and Int %d %d", Character[playerid][bEntered], Business[Character[playerid][bEntered]][World], GetPlayerVirtualWorld(playerid), Business[Character[playerid][bEntered]][Interior], GetPlayerInterior(playerid));
			SendClientMessage(playerid, COLOR_GRAY, str);
			InfoBoxForPlayer(playerid, "You are muted, you can't talk. \n If you think this is incorrect,\n Post an appeal on forums.");

		}
	else
		{
			SendErrorMessage(playerid, ERROR_ADMIN);
		}
	return 1;
}

CMD:restart(playerid, params[])
{
	if(Account[playerid][Admin] >= 5)
	{
	    SendClientMessageToAll(COLOR_ORANGERED, "The server is restarting in 5 seconds, thus you have been kicked! ");
	    SendRconCommand("password 38rwbui8b8");
	   	foreach(Player, i)
		{
		    KickPlayer(i);
		}
		SetTimer("RestartServer", SECONDS(5), false);
	}
	else
	{
	    SendErrorMessage(playerid, ERROR_ADMIN);
	}
    return 1;
}

forward RestartServer();
public RestartServer()
{
	return SendRconCommand("gmx");
}


CMD:settime(playerid,params[])
{
	if(Account[playerid][Admin] >= 6)
	{
	    new time,str[128];
		if(sscanf(params, "d",time)) return SendClientMessage(playerid, COLOR_GRAY, "/settime [hour]");
		if(time < 0 || time >24)return SendClientMessage(playerid, COLOR_GRAY, "/settime [0-24]");
        	else if(time <= 24 && time >= 0)
	        {
	            ClockHours = time;
	            SetWorldTime(time);
	            format(str, sizeof(str), "%s has set the time to %d!", GetRoleplayName(playerid),time);
				SendAdminsMessage(1, COLOR_ORANGERED, str);
	        }
  	}
	else
	{
	    SendErrorMessage(playerid, ERROR_ADMIN);
	}
	return 1;
}


CMD:kick(playerid, params[])
{
	if(Account[playerid][Admin] >= 1)
	{

        new pID, str[128], reason[128];
		if(sscanf(params, "uS(Not specified)[128]", pID,reason)) return SendClientMessage(playerid, COLOR_GRAY, "/kick [ID/Name] [reason]");
	    if(Account[pID][Admin] >= 1 && Account[playerid][Admin] != 6)
		{
			SendErrorMessage(playerid, "You can't kick admins.");
			return 1;
		}
		format(str, sizeof(str), "Admin %s has kicked %s | Reason: %s", GetRoleplayName(playerid), GetRoleplayName(pID), reason);
		SendPunishmentMessage(str);
		Character[pID][Kicks] ++;
		KickPlayer(pID);

 	}
	else
	{
	    SendErrorMessage(playerid, ERROR_ADMIN);
	}
	return 1;
}

CMD:ban(playerid, params[])
{
	if(Account[playerid][Admin] >= 1)
	{
        new pID, str[128], reason[128];
		if(sscanf(params, "uS(Not specified)[128]", pID,reason)) return SendClientMessage(playerid, COLOR_GRAY, "/ban [id] [reason]");
		if(Character[pID][Admin] >= 1  && Account[playerid][Admin] != 6)
		{
			SendClientMessage(playerid, COLOR_RED, "You can't ban admins.");
		}
		else
		{
			format(str, sizeof(str), "Admin %s has banned %s | Reason: %s", GetRoleplayName(playerid), GetRoleplayName(pID), reason);
			SendPunishmentMessage(str);
			IssueBan(pID, GetName(playerid), reason);
		}

 	}
	else
	{
	    SendErrorMessage(playerid, ERROR_ADMIN);
	}

	return 1;
}

CMD:toggleooc(playerid, params[])
{
	new str[128];
	if(Account[playerid][Admin] >= 3)
	{
		if(OOCStatus == 0)
	    {
			OOCStatus = 1;
	     	format(str, sizeof(str), "Admin %s has enabled the global OOC chat, you may now talk via /(o)oc!", GetRoleplayName(playerid));
	     	SendClientMessage(playerid, COLOR_YELLOW, str);
	    }
	    else
	    {
			OOCStatus = 0;
   			format(str, sizeof(str), "Admin %s has disabled the global OOC chat.", GetRoleplayName(playerid));
	     	SendClientMessage(playerid, COLOR_YELLOW, str);
	    }
	}
	else
	{
	    SendErrorMessage(playerid, ERROR_ADMIN);
	}
	return 1;
}

CMD:mute(playerid, params[])
{
	new str[128], pID, astr[128];
	if(Account[playerid][Admin] >= 2)
	{
	    if(sscanf(params, "u", pID)) return SendClientMessage(playerid, COLOR_GRAY, "/mute [id]");
	    format(str, sizeof(str), "Admin %s has muted %s.", GetRoleplayName(playerid), GetRoleplayName(pID));
	    SendClientMessageToAll(COLOR_GRAY, str);
	    Character[pID][Muted] = 1;
	    format(astr, sizeof(astr), "%s has muted %s!", GetRoleplayName(playerid), GetRoleplayName(pID));
		SendAdminsMessage(1, COLOR_RED, astr);
	}
	else
	{
		SendErrorMessage(playerid, ERROR_ADMIN);

	}
	return 1;
}

CMD:unmute(playerid, params[])
{
	new str[128], pID, astr[128];
	if(Account[playerid][Admin] >= 2)
	{
	    if(sscanf(params, "u", pID)) return SendClientMessage(playerid, COLOR_GRAY, "/unmute [id]");
	    format(str, sizeof(str), "Admin %s has unmuted you.", GetRoleplayName(playerid));
	    SendClientMessage(pID, COLOR_RED, str);
	    Character[pID][Muted] = 0;
 	    format(astr, sizeof(astr), "%s has unmuted %s!", GetRoleplayName(playerid), GetRoleplayName(pID));
		SendAdminsMessage(1, COLOR_RED, astr);
	}
	else
	{
		SendErrorMessage(playerid, ERROR_ADMIN);

	}
	return 1;
}

CMD:freeze(playerid, params[])
{
	new pID, str[128];
	if(Account[playerid][Admin] >= 2)
	{
	    if(sscanf(params, "u", pID)) return SendClientMessage(playerid, COLOR_GRAY, "/freeze [id]");
		TogglePlayerControllable(pID, 0);
		format(str, sizeof(str), "Admin %s has frozen %s.", GetRoleplayName(playerid), GetRoleplayName(pID));
		SendAdminsMessage(1, COLOR_RED, str);
        SendClientMessage(pID, COLOR_RED, "> You have been frozen by an admin, they should tell you why shortly.");
	}
	else
	{
	    SendErrorMessage(playerid, ERROR_ADMIN);
	}
	return 1;
}



CMD:slap(playerid, params[])
{
	new pID, str[128],Float:px, Float:py, Float:pz;
	if(Account[playerid][Admin] >= 1)
	{
	    if(sscanf(params, "u", pID)) return SendClientMessage(playerid, COLOR_GRAY, "/slap [id]");
	    PlayerPlaySound(playerid, 1130, 0.0, 0.0, 10.0);
		if(!IsPlayerInAnyVehicle(pID))
		{
			GetPlayerPos(pID, px, py, pz);
			SetPlayerPos(pID, px, py, pz+5);
			format(str, sizeof(str), "Admin %s has slapped you.", GetRoleplayName(playerid));
			SendClientMessage(pID, COLOR_SEAGREEN, str);
		}
		else if(IsPlayerInAnyVehicle(pID))
		{
			new Float:pos[3];
			GetVehicleVelocity(GetPlayerVehicleID(pID), pos[0], pos[1], pos[2]);
			SetVehicleVelocity(GetPlayerVehicleID(pID), pos[0], pos[1], pos[2] + 0.2);
			format(str, sizeof(str), "Admin %s has slapped you.", GetRoleplayName(playerid));
			SendClientMessage(pID, COLOR_SEAGREEN, str);
		}

	}
	else
	{
	    SendErrorMessage(playerid, ERROR_ADMIN);
	}
	return 1;
}

CMD:downslap(playerid, params[])
{
	new pID, str[128],Float:px, Float:py, Float:pz;
	if(Account[playerid][Admin] >= 1)
	{
	    if(sscanf(params, "u", pID)) return SendClientMessage(playerid, COLOR_GRAY, "/downslap [id]");
		GetPlayerPos(pID, px, py, pz);
		SetPlayerPos(pID, px, py, pz-5);
		format(str, sizeof(str), "Admin %s has just slapped you.", GetRoleplayName(playerid));
		SendClientMessage(pID, COLOR_SEAGREEN, str);
	}
	else
	{
	    SendErrorMessage(playerid, ERROR_ADMIN);
	}
	return 1;
}

forward SpectatePlayer(playerid, targetid);
public SpectatePlayer(playerid, targetid)
{
	if(IsPlayerConnected(targetid))
	{
		new str[128];

		if(Character[playerid][IsSpec] == -1)
	    {
        	GetPlayerPos(playerid, Character[playerid][PosX], Character[playerid][PosY], Character[playerid][PosZ]);
            Character[playerid][Interior] = GetPlayerInterior(playerid);
            Character[playerid][VWorld] = GetPlayerVirtualWorld(playerid);
	    }
	    
		Character[playerid][IsSpec] = targetid;

		if(IsPlayerInAnyVehicle(targetid))
		{
		  	SetPlayerInterior(playerid, GetPlayerInterior(targetid));
		    SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(targetid));

            TogglePlayerSpectating(playerid, 1);
            PlayerSpectateVehicle(playerid, GetPlayerVehicleID(targetid));

		    format(str, sizeof(str), "You are spectating %s.", GetRoleplayName(targetid));
			SendClientMessage(playerid, COLOR_LBLUE, str);
		    return 1;
		}

		else
		{
		    SetPlayerInterior(playerid, GetPlayerInterior(targetid));
		    SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(targetid));

		    Character[playerid][bEntered] = Character[targetid][bEntered];
		    Character[playerid][hEntered] = Character[targetid][hEntered];

			TogglePlayerSpectating(playerid, 1);
		    PlayerSpectatePlayer(playerid, targetid);

		    format(str, sizeof(str), "You are now spectating %s.", GetRoleplayName(targetid));
			SendClientMessage(playerid, COLOR_LBLUE, str);

		    return 1;
		}
	}
	else
	{
		SendErrorMessage(playerid, "Invaild player.");
	}
	return 1;
}

CMD:spec(playerid, params[])
{
	new TargetPlayer;
	if(Account[playerid][Admin] > 0)
	{
	    if(sscanf(params, "u", TargetPlayer)) return SendClientMessage(playerid, COLOR_GRAY, "/spec [id]");
		if(Character[TargetPlayer][IsSpec] > -1) return SendClientMessage(playerid, COLOR_GRAY, "Player is spectating!");
		if(TargetPlayer == playerid) return SendClientMessage(playerid, COLOR_GRAY, "No speccing yourself!");
		if(LoggedIn[TargetPlayer] == false) return SendErrorMessage(playerid, "Player not logged in!");

		SpectatePlayer(playerid, TargetPlayer);
	}
	else
	{
	    SendErrorMessage(playerid, ERROR_ADMIN);
	}
	return 1;
}

CMD:specoff(playerid, params[])
{
	if(Account[playerid][Admin] > 0)
	{
        if(Character[playerid][IsSpec] == -1) return SendClientMessage(playerid, COLOR_GRAY, "You are NOT speccing anyone!");
        Character[playerid][IsSpec] = -1;
		TogglePlayerSpectating(playerid, 0);
	    SetPlayerPosEx(playerid, Character[playerid][PosX], Character[playerid][PosY], Character[playerid][PosZ], Character[playerid][Interior], Character[playerid][VWorld]);
        UpdatePlayerWeapons(playerid);
	}
	return 1;
}

public OnPlayerEnterDynamicRaceCP(playerid, checkpointid)
{
	if(checkpointid == GDL_Test[playerid])
	{
		new vid = GetPlayerVehicleID(playerid);
		if(Vehicles[vid][Type] == 4)
		{
			if(DMV[playerid][DrivingTest] < 22)
			{
				PlayerPlaySound(playerid, 1139, 0.0, 0.0, 10.0);
				DMV[playerid][DrivingTest]++;
				new id = DMV[playerid][DrivingTest];
				DestroyDynamicRaceCP(checkpointid);
				GDL_Test[playerid] = CreateDynamicRaceCP(0, GDL_ROUTE[id][0], GDL_ROUTE[id][1], GDL_ROUTE[id][2], GDL_ROUTE[id+1][0], GDL_ROUTE[id+1][1], GDL_ROUTE[id+1][2], 3, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), playerid, 1000);
			}
			else if(DMV[playerid][DrivingTest] == 22)
			{
				PlayerPlaySound(playerid, 1139, 0.0, 0.0, 10.0);
				DMV[playerid][DrivingTest]++;
				new id = DMV[playerid][DrivingTest];
				DestroyDynamicRaceCP(checkpointid);
				GDL_Test[playerid] = CreateDynamicRaceCP(1, GDL_ROUTE[id][0], GDL_ROUTE[id][1], GDL_ROUTE[id][2], 0, 0, 0, 5, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), playerid, 500);
			}
			else
			{
				new vID = GetPlayerVehicleID(playerid);
				PlayerPlaySound(playerid, 1139, 0.0, 0.0, 10.0);
				DMV[playerid][DrivingTest] = 0;
				DMV[playerid][GDL] = 1;
				DestroyDynamicRaceCP(checkpointid);
				GDL_Test[playerid] = 0;
				GameTextForPlayer(playerid, "~g~Driving Test Passed!", 5000, 3);
				SendClientMessage(playerid, COLOR_LBLUE, "Well done, you have completed the driving test!");
				if(Vehicles[vID][Type] == 4)
				{
					Engine_SET(playerid, vID, 0);
					SetVehiclePos(vID, Vehicles[vID][PosX],Vehicles[vID][PosY],Vehicles[vID][PosZ]);
				 	SetVehicleZAngle(vID, Vehicles[vID][PosA]);
				}
				GivePlayerXP(playerid, 1);
			}
		}
		else
		{
			SendErrorMessage(playerid, "Incorrect Vehicle.");
		}
	}

	if(Trucking[playerid][CheckpointID] == checkpointid)
	{
		new vID = GetPlayerVehicleID(playerid), str[128];
		if(Vehicles[vID][Type] == 5 && Trucking[playerid][TruckID] == GetPlayerVehicleID(playerid))
		{
			if(Trucking[playerid][RouteID] == 0)
			{
				PlayerPlaySound(playerid, 1139, 0.0, 0.0, 10.0);
				DestroyDynamicRaceCP(checkpointid);
				Trucking[playerid][RouteID] =  random(9) + 1;
				new id = Trucking[playerid][RouteID];
				Trucking[playerid][SectionID] = 1;

				TogglePlayerControllable(playerid, 0);
				SetTimerEx("UnfreezePlayer", SECONDS(20), false, "d", playerid);

				GameTextForPlayer(playerid, "Please wait as the goods are being loaded...", 15000, 3);

				Trucking[playerid][CheckpointID] = CreateDynamicRaceCP(2, TruckCheckpoints[id][0], TruckCheckpoints[id][1], TruckCheckpoints[id][2], 0.0, 0.0, 0.0, 3, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), playerid, 5000);
			}
			else if(Trucking[playerid][RouteID] > 0)
			{
				if(Trucking[playerid][SectionID] == 1)
				{
					new id =  random(Total_Biz_Created);
					if(id == 0)
					{
						id = 1;
					}
					Trucking[playerid][SectionID] = 2;
					PlayerPlaySound(playerid, 1139, 0.0, 0.0, 10.0);
					DestroyDynamicRaceCP(checkpointid);
					Trucking[playerid][CheckpointID] = CreateDynamicRaceCP(2, Business[id][PosX], Business[id][PosY], Business[id][PosZ], 0.0, 0.0, 0.0, 8, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), playerid, 5000);
					format(str, sizeof(str), "The imported good is now being processed. You will now deliver the finished product to %s.", Business[id][Name]);
					SendClientMessage(playerid, COLOR_YELLOWGREEN, str);
				}

				else if(Trucking[playerid][SectionID] == 2)
				{
					
					new id = GetPlayerVehicleID(playerid);
					DestroyDynamicRaceCP(checkpointid);
					Trucking[playerid][SectionID] = 3;
					PlayerPlaySound(playerid, 1139, 0.0, 0.0, 10.0);
					SendClientMessage(playerid, COLOR_YELLOWGREEN, "Delivery Complete, now take the truck back to it's original parking spot in order to complete the mission.");
					Trucking[playerid][CheckpointID] = CreateDynamicRaceCP(1, Vehicles[id][PosX], Vehicles[id][PosY], Vehicles[id][PosZ], 0.0, 0.0, 0.0, 5, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), playerid, 5000);

					
				}
				else if(Trucking[playerid][SectionID] == 3)
				{
					new Time = gettime(), Float:TruckLevel = Character[playerid][TruckingCompleted], Float:Multiplier, Payment, Earnings, Pay, Bonus, Float:vDamage, DamageCost;
					printf("%d",Time);
					Time -= Trucking[playerid][TimeTaken];
					printf("%d",Time);
					Time /= 60;
					printf("%d",Time);
					if(Time <= 20)
					{

						Multiplier = TruckLevel / 200.0;

						Bonus = floatround((random(750) + 250) * Multiplier, floatround_round);

						Pay = (random(1750) + 250);

						Payment = floatround((Pay * Multiplier) + Pay, floatround_round);

						DamageCost = floatround((GetVehicleHealth(vID, vDamage)), floatround_round);
						//50% damage 50% off of pay?
						Earnings = (Payment + Bonus) - DamageCost;

						if(Earnings > 8000) { Earnings = 8000; }
						printf("Bonus: $%d", Bonus);
						printf("Multiplier: %f", Multiplier);
						printf("Pay: $%d", Pay);
						printf("Payment: $%d", Payment);
						printf("Earnings: $%d", Earnings);

						format(str, sizeof(str), " Base-line Pay = $%d \n Damage Cost: $%d \n Bonus: $%d \n Total Earnings: $%d", Payment, DamageCost, Bonus, Earnings);
						SendClientMessage(playerid, COLOR_YELLOW, str);
					}
					else if(Time > 20)
					{
						Earnings = 1000;
					}
					
					DestroyDynamicRaceCP(checkpointid);
					GameTextForPlayer(playerid, "~g~Trucking Mission Passed!", 5000, 3);

					GivePlayerPayday(playerid, Earnings);
					SendClientMessage(playerid, COLOR_GRAY, "All earnings have been added to your paycheck which can be collected at any bank.");

					SendClientMessage(playerid, COLOR_GRAY, "You have received 1 XP for completing the mission.");
					GivePlayerXP(playerid, 1);
					RepairVehicle(vID);

					Trucking[playerid][RouteID] = 0;
					Trucking[playerid][TruckID] = 0;
					Trucking[playerid][SectionID] = 0;
					Trucking[playerid][CheckpointID] = 0;
					Trucking[playerid][TimeTaken] = 0;

					Character[playerid][TruckingCompleted]++;

					if(Vehicles[vID][Type] == 5)
					{
						Engine_SET(playerid, vID, 0);
						SetVehiclePos(vID, Vehicles[vID][PosX],Vehicles[vID][PosY],Vehicles[vID][PosZ]);
					 	SetVehicleZAngle(vID, Vehicles[vID][PosA]);
					}


				}
			}
		}
		else
		{
			SendErrorMessage(playerid, "Incorrect Vehicle.");
		}
	}

	return 1;
}

CMD:hot(playerid, params[])
{
	PlayAudioStreamForPlayer(playerid, "http://sc.hot108.com:4020/listen.pls");
	return 1;
}

CMD:stopmusic(playerid, params[])
{
	StopAudioStreamForPlayer(playerid);
	return 1;
}

CMD:dmv(playerid, params[])
{
	if(DMV[playerid][GDL] == 1) return SendErrorMessage(playerid, "You already have this license!");
	if(GDL_Test[playerid] == 0)
	{
		if(InRangeOfIcon(playerid,12))
		{
			if(Character[playerid][Cash] >= 1000)
			{
				new id = 0;
    			GDL_Test[playerid] = CreateDynamicRaceCP(0, GDL_ROUTE[id][0], GDL_ROUTE[id][1], GDL_ROUTE[id][2], GDL_ROUTE[id+1][0], GDL_ROUTE[id+1][1], GDL_ROUTE[id+1][2], 3, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), playerid, 500);
				GivePlayerMoneyEx(playerid, -1000);
				SendClientMessage(playerid, COLOR_WHEAT, "You have started your driving test, please proceed to an instruction vehicle owned by the DMV.");
				SendClientMessage(playerid, COLOR_GRAY, "If you wish to end the test prematurely use the command /endtest.");
				
			}
			else
			{
				SendErrorMessage(playerid, ERROR_MONEY);
			}
			
		}
		else
		{
			SendErrorMessage(playerid, ERROR_LOCATION);
		}
	}
	else
	{
		SendErrorMessage(playerid, "You are already doing your driving test!");
	}
	return 1;
}

CMD:endtest(playerid, params[])
{
	if(GDL_Test[playerid] > 0)
	{
		new option[12];
		if(sscanf(params, "s[12]", option)) return SendClientMessage(playerid, COLOR_LBLUE, "Are you sure you want to quit your driving test? (/endtest [confirm/decline])");
		{
			if(!strcmp(option, "confirm", true))
			{
				FailDrivingTest(playerid, "You have ended your driving test.");
			}
			else if(!strcmp(option, "decline", true))
			{
				SendClientMessage(playerid, COLOR_GRAY, "You decided not to quit your test.");
			}
		}
	}
	return 1;
}

stock FailDrivingTest(playerid, string[])
{

	if(GDL_Test[playerid] > 0)
	{
		new str[128], vID = GetPlayerVehicleID(playerid);
		format(str, sizeof(str), "TEST FAILED: %s", string);
		SendClientMessage(playerid, COLOR_DARKRED, str);
		GameTextForPlayer(playerid, "~r~Driving Test Failed!", 5000, 3);
		DestroyDynamicRaceCP(GDL_Test[playerid]);
		if(Vehicles[vID][Type] == 4)
		{
			Engine_SET(playerid, vID, 0);
		}
		DMV[playerid][DrivingTest] = 0;
		GDL_Test[playerid] = 0;
	}
	
	return 1;
}

CMD:starttrucking(playerid, params[])
{

	if(Trucking[playerid][CheckpointID] == 0)
	{
		if(gettime() - Character[playerid][TruckCoolDown] < 600) return SendErrorMessage(playerid, "Your trucking cool-down period of 10 minutes hasn't ended.");
		if(Vehicles[GetPlayerVehicleID(playerid)][Type] == 5)
		{
			new vModel = GetVehicleModel(GetPlayerVehicleID(playerid));
			if(vModel == 482 && Character[playerid][TruckingCompleted] < 50) return SendErrorMessage(playerid, "You need to have done at least 50 missions before you can use this vehicle."); // burrito
			if(vModel == 515 && Character[playerid][TruckingCompleted] < 40) return SendErrorMessage(playerid, "You need to have done at least 40 missions before you can use this vehicle."); //road train
			if(vModel == 422 && Character[playerid][TruckingCompleted] < 30) return SendErrorMessage(playerid, "You need to have done at least 30 missions before you can use this vehicle."); //bobcat
			if(vModel == 403 && Character[playerid][TruckingCompleted] < 20) return SendErrorMessage(playerid, "You need to have done at least 20 missions before you can use this vehicle."); // linerunner
			if(vModel == 440 && Character[playerid][TruckingCompleted] < 10) return SendErrorMessage(playerid, "You need to have done at least 10 missions before you can use this vehicle."); // rumpo
			new id = 0;
			Trucking[playerid][RouteID] = 0;
			Trucking[playerid][TruckID] = GetPlayerVehicleID(playerid);
			Character[playerid][TruckCoolDown] = gettime();
			Trucking[playerid][TimeTaken] = gettime();

			//GivePlayerMoneyEx(playerid, -1000);
			SendClientMessage(playerid, COLOR_YELLOWGREEN, "You have started a trucking mission, please make your way to the airport indicated on your map.");
			SendClientMessage(playerid, COLOR_GRAY, "If you wish to end the mission prematurely use the command /endmission.");
			
    		Trucking[playerid][CheckpointID] = CreateDynamicRaceCP(2, TruckCheckpoints[id][0], TruckCheckpoints[id][1], TruckCheckpoints[id][2], 0.0, 0.0, 0.0, 6, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), playerid, 2000);

		}
		else
		{
			SendErrorMessage(playerid, ERROR_LOCATION);
		}
	}
	else
	{
		SendErrorMessage(playerid, "You are already doing a trucking mission!");
	}
	return 1;
}

stock EndTruckingMission(playerid, string[])
{

	if(Trucking[playerid][CheckpointID] > 0)
	{
		new str[128], vID = Trucking[playerid][TruckID];
		format(str, sizeof(str), "MISSION FAILED: %s", string);
		SendClientMessage(playerid, COLOR_DARKRED, str);
		GameTextForPlayer(playerid, "~r~Truck Mission Failed!", 5000, 3);
		DestroyDynamicRaceCP(Trucking[playerid][CheckpointID]);
		if(Vehicles[vID][Type] == 5)
		{
			Engine_SET(playerid, vID, 0);
			SetVehiclePos(vID, Vehicles[vID][PosX],Vehicles[vID][PosY],Vehicles[vID][PosZ]);
		 	SetVehicleZAngle(vID, Vehicles[vID][PosA]);	
		}
		Trucking[playerid][CheckpointID] = 0;
		Trucking[playerid][RouteID] = 0;
		Trucking[playerid][TruckID] = 0;
		Trucking[playerid][SectionID] = 0;
		Trucking[playerid][CheckpointID] = 0;
		Trucking[playerid][TimeTaken] = 0;
	}
	
	return 1;
}

CMD:endmission(playerid, params[])
{
	if(Trucking[playerid][CheckpointID] > 0)
	{
		new option[12];
		if(sscanf(params, "s[12]", option)) return SendClientMessage(playerid, COLOR_LBLUE, "Are you sure you want to quit your trucking mission? (/endmission [confirm/decline])");
		{
			if(!strcmp(option, "confirm", true))
			{
				EndTruckingMission(playerid, "You have ended your mission.");
			}
			else if(!strcmp(option, "decline", true))
			{
				SendClientMessage(playerid, COLOR_GRAY, "You decided not to quit your mission.");
			}
		}
	}
	return 1;
}

CMD:installstereo(playerid, params[])
{
	new vid = GetPlayerVehicleID(playerid);
	if(Character[playerid][Job] == MECHANIC_JOB)
	{
		if(Inventory[playerid][VehicleRadio] > 0)
		{
			if(IsPlayerVehicle(vid))
			{
				if(Vehicles[vid][Radio] != 1)
				{
					new str[128];
					Vehicles[vid][Radio] = 1;
					Inventory[playerid][VehicleRadio] --;

					format(str, sizeof(str), "* %s swiftly slides the new stereo system into the free compartment before screwing it into place. *", GetRoleplayName(playerid));
					SendLocalMessage(playerid, str, Range_Short, COLOR_RP, COLOR_RP);

					MYSQL_Update_Interger(Vehicles[vid][SQLID], "PlayerVehicles", "Radio", Vehicles[vid][Radio]);
				}
				else SendErrorMessage(playerid, "This vehicle already has a radio!");
				
			}
			else SendErrorMessage(playerid, "This can only be performed within a player-owned vehicle.");
			
		}
		else SendErrorMessage(playerid, "You don't have a radio to install!");
	}
	else SendErrorMessage(playerid, ERROR_JOB);
	return 1;
}

CMD:tow(playerid, params[])
{
	if(Character[playerid][Job] != MECHANIC_JOB) return SendErrorMessage(playerid, "You must be a mechanic to tow vehicles.");

	new vehicleid = GetPlayerVehicleID(playerid), modelid = GetVehicleModel(vehicleid);
	if(modelid != 525 && modelid != 531) return SendErrorMessage(playerid, "You must be in a tow truck or tractor.");
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return SendErrorMessage(playerid,"You must be the driver.");
	if(IsTrailerAttachedToVehicle(vehicleid)) return SendErrorMessage(playerid,"You are already towing a vehicle, use /detach if you want to tow another.");

	new Float:pX, Float:pY, Float:pZ, Float:vX, Float:vY, Float:vZ, found = 0, vid = 0;
	GetPlayerPos(playerid, pX, pY, pZ);

	while(vid < MAX_VEHICLES && found == 0)
	{
		vid ++;
		GetVehiclePos(vid, vX, vY, vZ);
		if(floatabs(pX-vX) < 7.0 && floatabs(pY-vY) < 7.0 && floatabs(pZ-vZ) < 7.0 && vid != vehicleid)
		{
	    	found = 1;
			AttachTrailerToVehicle(vid, vehicleid);
			break;
		}
	}
	
	if(!found) return SendClientMessage(playerid, COLOR_SKYBLUE, "There are no vehicles near to tow.");
		
	return 1;
}

CMD:detach(playerid, params[])
{
    new vehicleid = GetPlayerVehicleID(playerid);

	if(vehicleid == 0 || (vehicleid > 0 && GetVehicleTrailer(vehicleid) == 0)) return SendErrorMessage(playerid, "You are not in a vehicle or you are not towing anything that can be detached.");
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return SendErrorMessage(playerid, "You must be the driver to operate the tow controls.");

	DetachTrailerFromVehicle(vehicleid);
	SendClientMessage(playerid, COLOR_SKYBLUE, "You have unhooked the vehicle.");
	return 1;
}

new CompactDisks[][][] =
{
    {"Barry White - Love's Theme Tune","http://www.soselettricista.com/musica.mp3"},
    {"Barry White - Can't Get Enough of Your Love, Babe", "http://hyra-en-stuga.se/assets/multimedia/02-Barry_White-Can_T_Get_Enough_Of_Your_Love_Babe.mp3"},
    {"Sugar Hill Gang - Rappers Delight","http://www.exxxplosivo.com/music/HipHop2004/15%20Rappers%20Delight.mp3"},
    {"Conscious Daughters - Something To Ride To", "http://a.tumblr.com/tumblr_la7mo9xNWH1qzcg1so1.mp3"}

};

new RadioStations[][][] =
{
	{5,"Hot 108 Jamz", "http://sc.hot108.com:4020/listen.pls"},
	{4,"Kiss 100", "http://icy-e-02.sharp-stream.com/kiss100.mp3"},
	{4,"Gay FM", "http://87.230.82.13:80/listen.pls "},
	{6,"Absolute Classic Rock", "http://icecast.timlradio.co.uk/ac128.mp3"},
	{1,"Abacus FM Country", "http://dir.xiph.org/listen/1016913/listen.m3u"},
	{1,"VWCountry", "http://dir.xiph.org/listen/1016913/listen.m3u"},
	{3,"ABCJazz", "http://dir.xiph.org/listen/1297135/listen.m3u"},
	{2,"Party Vibe Radio", "http://yp.shoutcast.com/sbin/tunein-station.pls?id=205366"},
	{0,"None","None"}
};

new RadioGenres[][] = 
{
	"Classical",
	"Country",
	"House",
	"Jazz",
	"Pop",
	"Rap",
	"Rock"
};


CMD:vmusic(playerid, params[])
{
	new vid = GetPlayerVehicleID(playerid);
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(Vehicles[vid][Radio] == 1)
		{
			if(IsPlayerVehicle(vid))
			{
				RadioSystem_MainMenu(playerid);
			}
			else SendErrorMessage(playerid, "You must be in a player vehicle, in the driving seat in order to control the vehicle's radio.");
		}
		else SendErrorMessage(playerid, "This vehicle doesn't have a radio!");
	} 
	else SendErrorMessage(playerid, "You must be in a vehicle to perform this command.");
	return 1;
}
ALTCMD:vstereo->vmusic;
ALTCMD:vradio->vmusic;

stock RadioSystem_MainMenu(playerid)
{
	Dialog_Show(playerid, RadioSystem, DIALOG_STYLE_LIST, "Vehicle Radio System", ""COL_GRAY"-> "COL_WHITE"Radio Stations\n"COL_GRAY"-> "COL_WHITE"Compact Discs\n \n"COL_ORANGE"Turn [OFF]", "Select","Close");
	return 1;
}

stock RadioSystem_Genres(playerid)
{
	new StationCount = sizeof(RadioGenres), MainDialog[600];
    for (new i = 0; i < StationCount; ++i)
    {
    	new str[128];

		format(str, sizeof(str),"%s"COL_GRAY"-> "COL_WHITE"%s\n", str, RadioGenres[i]);
		strcat(MainDialog, str, sizeof(MainDialog));
    	
    }
    strcat(MainDialog, "\n \n"COL_GRAY"-> "COL_WHITE"Custom", sizeof(MainDialog));
    Dialog_Show(playerid, RadioSystem_Genres_2, DIALOG_STYLE_LIST, "Vehicle Radio System - Genres", MainDialog, "Select","Back");
	return 1;
}

Dialog:RadioSystem_Genres_2(playerid, response, listitem)
{
	if(!response) return RadioSystem_MainMenu(playerid);

	new StationCount = sizeof(RadioStations), MainDialog[600];
	printf("Listitem: %d RadioStations: %d",listitem, sizeof(RadioGenres));
	if(listitem == sizeof(RadioGenres) + 1)
	{
		new vid = Vehicles[GetPlayerVehicleID(playerid)][SQLID], str[256];

		format(str, sizeof(str), "SELECT id, Name FROM `vehicleradio` WHERE vid = %d ORDER BY Name ASC LIMIT 20", vid);
		mysql_tquery(SQL_CONNECTION, str, "ViewCustomURLs", "d", playerid);	
		//Dialog_Show(playerid, RadioSystem_Custom, DIALOG_STYLE_INPUT, "Vehicle Radio System - Custom", "Please enter a custom radio link:", "Tune", "Back");
	}

	else if(listitem == sizeof(RadioGenres)) {
		RadioSystem_Genres(playerid);
	}

	else {
		for (new i = 0; i < StationCount; ++i)
	    {
	    	new str[128];
	    	if(listitem == RadioStations[i][0][0])
	    	{
	    		format(str, sizeof(str),"%s"COL_GRAY"-> "COL_WHITE"%s\n", str, RadioStations[i][1]);
				strcat(MainDialog, str, sizeof(MainDialog));
	    	}
	    }
        Dialog_Show(playerid, RadioSystem_Stations, DIALOG_STYLE_LIST, "Vehicle Radio System - Radio", MainDialog, "Tune","Back");
	}
    
	return 1;
}


Dialog:RadioSystem_Custom(playerid, response, listitem, inputtext[])
{
	if(!response) return Dialog_Show(playerid, RadioSystem_Custom, DIALOG_STYLE_INPUT, "Vehicle Radio System - Custom", "Please enter a custom radio link:", "Tune", "Back");

	else if(response)
	{
		new vid = GetPlayerVehicleID(playerid);
		
		for(new i; i < MAX_PLAYERS; ++i)
	    {
	        if(!IsPlayerConnected(i))continue;
	        
	        if(IsPlayerInVehicle(i, vid))
	        {
	        	PlayVehicleRadio(playerid, inputtext);
	        }
	    }


	}
    
	return 1;
}


Dialog:RadioSystem(playerid, response, listitem, inputtext[])
{
	new vid = GetPlayerVehicleID(playerid);
	if(!response) return 1;
	if(listitem == 0)//radio
	{
	    RadioSystem_Genres(playerid);
		return 1;
	}
	else if(listitem == 1)
	{
	    new CDCount = sizeof(CompactDisks), MainDialog[600];
	    for (new i = 0; i < CDCount; ++i)
	    {
	    	new str[128];

			format(str, sizeof(str),"%s %s\n", str, CompactDisks[i][0]);
			strcat(MainDialog, str, sizeof(MainDialog));
	    	
	    }
	    Dialog_Show(playerid, RadioSystem_CDs, DIALOG_STYLE_LIST, "Vehicle Radio System - Compact Disks", MainDialog, "Play","Back");
		return 1;
	}
	else if(listitem == 3)
	{
		for (new i = 0; i < MAX_PLAYERS; ++i)
		{
			if(!IsPlayerConnected(i)) continue;
            
            if(IsPlayerInVehicle(i, vid))
            {
                StopAudioStreamForPlayer(i);
                Vehicles[vid][RadioStatus] = 0;
                format(Vehicles[vid][RadioURL], 128, "");
            }
		}
		return 1;
	}
	else
	{
		RadioSystem_MainMenu(playerid);
	}
    return 1;
}

Dialog:RadioSystem_Stations(playerid, response, listitem, inputtext[])
{
	if(!response) return RadioSystem_Genres(playerid);

	new vid = GetPlayerVehicleID(playerid);
    for(new i; i < MAX_PLAYERS; ++i)
    {
        if(!IsPlayerConnected(i))continue;
        
        if(IsPlayerInVehicle(i, vid))
        {
        	new x[128];
        	strmid(x, inputtext, 3, strlen(inputtext));
        	print(x);
        	for(new y = 0; y < sizeof(RadioStations); y++){
        		if(RadioStations[y][1][0] == x[0]){
        			//printf("We have a match! %s %s", RadioStations[y][1], RadioStations[y][2]);
        			PlayAudioStreamForPlayer(i, RadioStations[y][2]);
		            format(Vehicles[vid][RadioURL], 128, "%s", RadioStations[y][2]);
		            Vehicles[vid][RadioStatus] = 1;
        		}
        	}

            
           // print(RadioStations[listitem][2]);
            //	print(RadioStations[0][0]);// []-radionumber ----- [] 0=name 1=link //CDs chosen by player
        }
    }
    return 1;
}

Dialog:RadioSystem_CDs(playerid, response, listitem, inputtext[])
{
	if(!response) return RadioSystem_MainMenu(playerid);

	PlayVehicleRadio(playerid, CompactDisks[listitem][1]);

    return 1;
}




forward ViewCustomURLs(playerid);
public ViewCustomURLs(playerid)
{
	if(cache_num_rows())
    {
    	new str[128], Dialog[2000], name[128], sid;

        strcat(Dialog, "Add Station\n \n", sizeof(Dialog));

        for(new id = 0; id < cache_num_rows(); id++)
        {
        	sid = cache_get_field_content_int(id, "id", SQL_CONNECTION);
        	cache_get_field_content(id, "Name", name, SQL_CONNECTION, 128);

        	format(str, sizeof(str), "(%d) %s\n", sid, name);
        	strcat(Dialog, str, sizeof(Dialog));

        }
        Dialog_Show(playerid, RadioSystem_CustomMenu, DIALOG_STYLE_LIST, "Vehicle Radio System - Custom", Dialog, "Select", "Back");
	}
	else
	{
		Dialog_Show(playerid, RadioSystem_CustomMenu, DIALOG_STYLE_MSGBOX, "Vehicle Radio System - Custom", "None", "Return", "");
	}
	return 1;
}

Dialog:RadioSystem_CustomMenu(playerid, response, listitem, inputtext[])
{
	if(!response) RadioSystem_Genres(playerid);
	new sid[2], str[256];
	if(listitem == 0){
		Dialog_Show(playerid, RadioSystem_Custom, DIALOG_STYLE_INPUT, "Vehicle Radio System - Custom", "Please enter a custom radio link:", "Tune", "Back");
	}
	else if(listitem == 1) return 1;

	strmid(sid, inputtext, strfind(inputtext, "(") + 1,  strfind(inputtext, ")"));

	format(str, sizeof(str), "SELECT streamURL FROM `vehicleradio` WHERE id = %d ORDER BY id DESC LIMIT 20", strval(sid));
	mysql_tquery(SQL_CONNECTION, str, "PlayCustomURL", "d", playerid);	

	return 1;
}


forward PlayCustomURL(playerid);
public PlayCustomURL(playerid)
{
	if(cache_num_rows())
    {
    	new url[264];

    	cache_get_field_content(0, "streamURL", url, SQL_CONNECTION, 256);
    	PlayVehicleRadio(playerid, url);
	}
	else
	{
		SendErrorMessage(playerid, "The stream you selected could not be found.");
	}
	return 1;
}

stock PlayVehicleRadio(playerid, url[])
{
	new vid = GetPlayerVehicleID(playerid);
    for(new i; i < MAX_PLAYERS; ++i)
    {
        if(!IsPlayerConnected(i))continue;
        if(IsPlayerInVehicle(i, vid))
        {
        	if(Vehicles[vid][Radio])
     		{
     			PlayAudioStreamForPlayer(i, url);
	            format(Vehicles[vid][RadioURL], 128, "%s", url);
	            Vehicles[vid][RadioStatus] = 1;
	            //	print(CompactDisks[0][0]);// []-radionumber ----- [] 0=name 1=link //CDs chosen by player
     		}
            
        }
    }
}

stock Query_Set_PlayerVehicle(vehicleid, option1[], option2)
{
	if(Vehicles[vehicleid][Type] != 1) return print("Error in Query_Set_PlayerVehicle.");
	MYSQL_Update_Interger(Vehicles[vehicleid][SQLID], "PlayerVehicles", option1, option2);
	return 1;
}




stock VehicleMods_MainMenu(playerid)
{
	Dialog_Show(playerid, VehicleMods, DIALOG_STYLE_LIST, "Vehicle Modification System", "Nitrous Oxide\nHydraulics\nAfter Market Wheels", "Select","Close");
	return 1;
}


Dialog:VehicleMods(playerid, response, listitem, inputtext[])
{
	if(!response) return 1;
	else if(listitem == 0) return VehicleMods_Nitrous(playerid);
	else if(listitem == 1) return VehicleMods_Hydraulics(playerid);
	else if(listitem == 2) return VehicleMod_Wheels(playerid);
    return 1;
}

stock VehicleMods_Hydraulics(playerid)
{
	new str[128], dialog[400];
	for (new i = 0; i < sizeof(Mod_Hydraulics); ++i)
	{
		format(str, sizeof(str), "%s ("COL_GREEN"$%d"COL_WHITE")\n", Mod_Hydraulics[i][2], Mod_Hydraulics[i][1]);
        strcat(dialog, str, sizeof(dialog));
	}
	format(str, sizeof(str), "\n"COL_RED"Remove Modification");
	strcat(dialog, str, sizeof(dialog));
	Dialog_Show(playerid, VehicleMods_Hydraulics, DIALOG_STYLE_LIST, "Vehicle Modification System - Hydraulics", dialog, "Select","Back");
	return 1;
}



Dialog:VehicleMods_Hydraulics(playerid, response, listitem, inputtext[])
{
	if(!response) return VehicleMods_MainMenu(playerid);
	new vid = GetPlayerVehicleID(playerid);
	new component = GetVehicleComponentInSlot(vid, CARMODTYPE_HYDRAULICS);

	if(listitem != sizeof(Mod_Hydraulics))
	{
		if(component == Mod_Hydraulics[listitem][0]) return SendErrorMessage(playerid, "You already have hydraulics installed.");
		if(Character[playerid][Cash] < Mod_Hydraulics[listitem][1]) return SendErrorMessage(playerid, ERROR_MONEY);
		GivePlayerMoneyEx(playerid, -Mod_Hydraulics[listitem][1]);
		AddVehicleComponent(vid, Mod_Hydraulics[listitem][0]);
		Query_Set_PlayerVehicle(vid, "Hydraulics", Mod_Hydraulics[listitem][0]);
	}
	else if(listitem == sizeof(Mod_Hydraulics))
	{
		Query_Set_PlayerVehicle(vid, "Hydraulics", 0);
		for (new i = 0; i < sizeof(Mod_Hydraulics); ++i)
		{
			if(component == Mod_Hydraulics[i][0]) return RemoveVehicleComponent(vid, Mod_Hydraulics[i][0]);
		}

	}
    return 1;
}


stock VehicleMods_Nitrous(playerid)
{
	new str[128], dialog[400];
	for (new i = 0; i < sizeof(Mod_NOS); ++i)
	{
		format(str, sizeof(str), "%s ("COL_GREEN"$%d"COL_WHITE")\n", Mod_NOS[i][2], Mod_NOS[i][1]);
        strcat(dialog, str, sizeof(dialog));
	}
	format(str, sizeof(str), "\n"COL_RED"Remove Modification");
	strcat(dialog, str, sizeof(dialog));
	Dialog_Show(playerid, VehicleMods_Nitrous, DIALOG_STYLE_LIST, "Vehicle Modification System - Nitrous Oxide", dialog, "Select","Back");
	return 1;
}


Dialog:VehicleMods_Nitrous(playerid, response, listitem, inputtext[])
{
	if(!response) return VehicleMods_MainMenu(playerid);
	new vid = GetPlayerVehicleID(playerid);
	new component = GetVehicleComponentInSlot(vid, CARMODTYPE_NITRO);


	if(listitem != sizeof(Mod_NOS))
	{
		if(component == Mod_NOS[listitem][0]) return SendErrorMessage(playerid, "You already have this type of NOS installed.");
		if(Character[playerid][Cash] < Mod_NOS[listitem][1]) return SendErrorMessage(playerid, ERROR_MONEY);
		GivePlayerMoneyEx(playerid, -Mod_NOS[listitem][1]);
		AddVehicleComponent(vid, Mod_NOS[listitem][0]);
		Query_Set_PlayerVehicle(vid, "Nitrous", Mod_NOS[listitem][0]);
	}
	else if(listitem == sizeof(Mod_NOS))
	{
		Query_Set_PlayerVehicle(vid, "Nitrous", 0);
		for (new i = 0; i < sizeof(Mod_NOS); ++i)
		{
			if(component == Mod_NOS[i][0]) return RemoveVehicleComponent(vid, Mod_NOS[i][0]);
		}

	}

    return 1;
}


stock VehicleMod_Wheels(playerid)
{
	new str[128], dialog[600];
	for (new i = 0; i < sizeof(Mod_Wheels); ++i)
	{
		format(str, sizeof(str), "%s ("COL_GREEN"$%d"COL_WHITE")\n", Mod_Wheels[i][2], Mod_Wheels[i][1]);
        strcat(dialog, str, sizeof(dialog));
	}
	format(str, sizeof(str), "\n"COL_RED"Remove Modification");
	strcat(dialog, str, sizeof(dialog));
	Dialog_Show(playerid, VehicleMod_Wheels, DIALOG_STYLE_LIST, "Vehicle Modification System - Wheels", dialog, "Install","Back");
	return 1;
}


Dialog:VehicleMod_Wheels(playerid, response, listitem, inputtext[])
{
	if(!response) return VehicleMods_MainMenu(playerid);

	new vid = GetPlayerVehicleID(playerid);
	new component = GetVehicleComponentInSlot(vid, CARMODTYPE_WHEELS);

	if(listitem != sizeof(Mod_Wheels))
	{
		if(component == Mod_Wheels[listitem][0]) return SendErrorMessage(playerid, "You already have these wheels installed.");
		if(Character[playerid][Cash] < Mod_Wheels[listitem][1]) return SendErrorMessage(playerid, ERROR_MONEY);
		GivePlayerMoneyEx(playerid, -Mod_Wheels[listitem][1]);
		AddVehicleComponent(vid, Mod_Wheels[listitem][0]);
		Query_Set_PlayerVehicle(vid, "Wheels", Mod_Wheels[listitem][0]);
	}
 	
	else if(listitem == sizeof(Mod_Wheels)) 
	{
		Query_Set_PlayerVehicle(vid, "Wheels", 0);
		for (new i = 0; i < sizeof(Mod_Wheels); ++i)
		{
			if(component == Mod_Wheels[i][0]) return RemoveVehicleComponent(vid, Mod_Wheels[i][0]);
		}

	}

    return 1;
}


CMD:vmods(playerid, params[])
{
	new vid = GetPlayerVehicleID(playerid);
	if(Character[playerid][Job] == MECHANIC_JOB)
	{	
		if(InRangeOfIcon(playerid, 14))
		{
			if(vid != INVALID_VEHICLE_ID)
			{
				if(Vehicles[vid][Type] == 1)// Command to offer vmods?  && Vehicles[vid][Owner] == Character[playerid][ID]
				{
					VehicleMods_MainMenu(playerid);		
				}
				else SendErrorMessage(playerid, "Modifications cannot be done to this vehicle.");
				
			}
			else SendErrorMessage(playerid, "You need to be in a vehicle!");
		}
		else SendErrorMessage(playerid, ERROR_LOCATION);
	}
	else SendErrorMessage(playerid, ERROR_JOB);
	return 1;
}

CMD:setfare(playerid, params[])
{

	if(Character[playerid][Job] == TAXI_JOB)
	{
		if(IsVehicleTaxi(GetVehicleModel(GetPlayerVehicleID(playerid))))
		{
			new option, str[128];
			if(Taxi[playerid][Passanger] != -1) return SendErrorMessage(playerid, "Cannot be done at this point in time.");
			if(sscanf(params, "d", option)) return SendClientMessage(playerid, COLOR_GRAY, "/setfare [price] - Allows you to choose the fare charged to your passengers.");
			{
				if(option <= 25 || option < 0)
				{
					Taxi[playerid][Fare] = option;
					format(str, sizeof(str), "You have set your fare at $%d, this will be charged when you pickup a passenger and turn on the meter.", Taxi[playerid][Fare]);
					SendClientMessage(playerid, COLOR_IVORY, str);
				}
				else
				{
					SendErrorMessage(playerid, ERROR_VALUE);
				}

			}
		}
		else
		{
			SendErrorMessage(playerid, "This can only be performed within a taxi fitted with a meter.");
		}
	}
	else
	{
		SendErrorMessage(playerid, ERROR_JOB);
	}
	return 1;
}


CMD:endfare(playerid, params[])
{
	if(Character[playerid][Job] == TAXI_JOB)
	{
		if(!IsVehicleTaxi(GetVehicleModel(GetPlayerVehicleID(playerid)))) return SendErrorMessage(playerid, "You may only do this inside the taxi.");
		EndTaxiMeter(playerid);
		SendClientMessage(playerid, COLOR_LINEN, "You have force-ended the fare.");

	}
	else
	{
		SendErrorMessage(playerid, ERROR_JOB);
	}
	return 1;
}

CMD:offertaxi(playerid, params[])
{

	if(Character[playerid][Job] == TAXI_JOB)
	{
		new player, str[128];
		if(!IsVehicleTaxi(GetVehicleModel(GetPlayerVehicleID(playerid)))) return SendErrorMessage(playerid, "You may only do this inside the taxi.");
		if(sscanf(params, "u", player)) return SendClientMessage(playerid, COLOR_GRAY, "/offertaxi [playerid] - Allows you to charge the player for their taxi journey");
		{
			if(IsInRangeOfPlayer(playerid, player, 5))
			{
				Taxi[playerid][Offering] = player;
				Taxi[player][Driver] = playerid;
				format(str, sizeof(str), "%s has offered you a taxi ride, use /taxi to proceed with it.", GetRoleplayName(playerid));
				SendClientMessage(player, COLOR_IVORY, str);
				format(str, sizeof(str), "You have offered %s a taxi ride, please wait for them to accept.", GetRoleplayName(player));
				SendClientMessage(playerid, COLOR_IVORY, str);
			}
			else
			{
				SendErrorMessage(playerid, ERROR_LOCATION);
			}
		}

	}
	else
	{
		SendErrorMessage(playerid, ERROR_JOB);
	}
	return 1;
}


CMD:taxi(playerid, params[])
{

	if(Taxi[playerid][Driver] != -1 && Taxi[Taxi[playerid][Driver]][Offering] == playerid)
	{
		new option[12], str[128];
		if(sscanf(params, "s[12]", option)) return SendClientMessage(playerid, COLOR_LBLUE, "/taxi [accept/decline] - Allows you to accept the fair for the taxi ride you're about to embark on.");
		{
			if(!strcmp(option, "accept", true))
			{
				if(!IsVehicleTaxi(GetVehicleModel(GetPlayerVehicleID(playerid))) || GetPlayerVehicleID(playerid) != GetPlayerVehicleID(Taxi[playerid][Driver])) return SendErrorMessage(playerid, "You may only do this inside the taxi.");
				SendClientMessage(playerid, COLOR_MINTCREAM, "You have accepted the taxi offer, the meter will now start and you will be charged.");

				format(str, sizeof(str), "%s has accepted the taxi offer.", GetRoleplayName(playerid));
				SendClientMessage(Taxi[Taxi[playerid][Driver]][Offering], COLOR_MINTCREAM, str);
				SendClientMessage(Taxi[playerid][Driver], COLOR_MINTCREAM, str);

				Taxi[Taxi[playerid][Driver]][Passanger] = playerid;

				Taxi[Taxi[playerid][Driver]][Timer] = SetTimerEx("TaxiMeter", SECONDS(5), true, "d", Taxi[playerid][Driver]);

				
			
			}
			else if(!strcmp(option, "decline", true))
			{
				SendClientMessage(playerid, COLOR_GRAY, "You decided not to embark on this taxi ride.");

				format(str, sizeof(str), "%s has declined the taxi offer.", GetRoleplayName(playerid));
				SendClientMessage(Taxi[Taxi[playerid][Driver]][Offering], COLOR_MINTCREAM, str);
				SendClientMessage(Taxi[playerid][Driver], COLOR_MINTCREAM, str);

				Taxi[Taxi[playerid][Driver]][Offering] = -1;
				Taxi[playerid][Driver] = -1;
			}
		}

	}
	else
	{
		SendErrorMessage(playerid, "No-one is offering you a taxi.");
	}
	return 1;
}

forward TaxiMeter(player);
public TaxiMeter(player)
{
	new str[128];
	Taxi[player][Meter] += Taxi[player][Fare];
	//Taxi[player][Fare] += 5;
	format(str, sizeof(str), "Taxi Meter: ~g~$%d", Taxi[player][Meter]);
	GameTextForPlayer(player, str, 5000, 3);
	GameTextForPlayer(Taxi[player][Passanger], str, 5000, 1);
	return 1;
}

forward EndTaxiMeter(playerid);
public EndTaxiMeter(playerid)
{
	KillTimer(Taxi[playerid][Timer]);
	GivePlayerMoneyEx(playerid, Taxi[playerid][Meter]);
	GivePlayerMoneyEx(Taxi[playerid][Passanger], -Taxi[playerid][Meter]);

	ResetTaxiVariables(Taxi[playerid][Passanger]);
	ResetTaxiVariables(playerid);

	return 1;
}

stock ResetTaxiVariables(playerid)
{
 	Taxi[playerid][Driver] = -1;
 	Taxi[playerid][Offering] = -1;
 	Taxi[playerid][Passanger] = -1;
 	Taxi[playerid][Meter] = 0;
 	Taxi[playerid][Fare] = 0;
	return 1;
}



CMD:pay(playerid, params[])
{
	new player, amount, str[128];
	if(sscanf(params, "ui", player, amount)) return SendClientMessage(playerid, COLOR_GRAY, "/pay [playerid] [amount]");
	{
		if(IsInRangeOfPlayer(playerid, player, 5))
		{
			if(amount > Character[playerid][Cash] || amount > 250000 || amount <= 0 || Character[playerid][Cash] <= 0 || playerid == player) return SendErrorMessage(playerid, ERROR_VALUE);
			
			format(str, sizeof(str), "* %s withdraws their wallet, and takes out some cash before giving it to %s. *", GetRoleplayName(playerid), GetRoleplayName(player));
			SendLocalMessage(playerid, str, Range_Short, COLOR_RP, COLOR_RP);

			format(str, sizeof(str), "You have paid $%d to %s.", amount, GetRoleplayName(player));
			SendClientMessage(playerid, COLOR_OLIVE, str);	

			format(str, sizeof(str), "%s has paid you $%d.", GetRoleplayName(playerid), amount);
			SendClientMessage(player, COLOR_OLIVE, str);			

			GivePlayerMoneyEx(playerid, -amount);
			GivePlayerMoneyEx(player, amount);
		}
		else
		{
			SendErrorMessage(playerid, ERROR_LOCATION);
		}
	}

	return 1;
}


CMD:give(playerid, params[])
{
	new player, amount, item[24];
	if(sscanf(params, "usi", player, item, amount)) return SendClientMessage(playerid, COLOR_GRAY, "/give [playerid] [item] [quantity]");
	{
		if(amount <= 0) return SendErrorMessage(playerid, "Invalid amount.");
		if(player == playerid) return SendErrorMessage(playerid, "Invalid Player");
		if(IsInRangeOfPlayer(playerid, player, 5))
		{
			if(!strcmp(item, "VehicleRadio", true))
			{
				if(Inventory[playerid][VehicleRadio] >= amount)
				{
					TakeInventoryItem(playerid, VRADIO, amount);
					GiveInventoryItem(player, VRADIO, amount);

				}
				else SendErrorMessage(playerid, "You don't have this item.");
				return 1;
			}

			else if(!strcmp(item, "Weapon", true))
			{

			}

			else if(!strcmp(item, "Screwdriver", true))
			{
				if(Inventory[playerid][Screwdriver] >= amount)
				{
					TakeInventoryItem(playerid, SCREWDRIVER, amount);
					GiveInventoryItem(player, SCREWDRIVER, amount);

				}
				else SendErrorMessage(playerid, "You don't have this item.");
				return 1;
			}
		}
		else SendErrorMessage(playerid, "You are too far away from this player.");
		
	}
	return 1;
}



CMD:gotop(playerid, params[])
{
	new TargetPlayer, str[128],Float:X, Float:Y, Float:Z;
	if(Account[playerid][Admin] >= 1)
	{
	    if(sscanf(params, "u", TargetPlayer)) return SendClientMessage(playerid, COLOR_GRAY, "/gotop [id]");
	    if(!IsPlayerConnected(TargetPlayer)) return SendErrorMessage(playerid, ERROR_OPTION);
		if(IsPlayerInAnyVehicle(playerid))
		{
		    GetPlayerPos(TargetPlayer, X, Y, Z);
		  	SetVehiclePos(GetPlayerVehicleID(playerid), X, Y, Z+5);

		  	SetPlayerInterior(playerid, GetPlayerInterior(TargetPlayer));
		    SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(TargetPlayer));

		    Character[playerid][bEntered] = Character[TargetPlayer][bEntered];
		    Character[playerid][hEntered] = Character[TargetPlayer][hEntered];

		    format(str, sizeof(str), "You have teleported to %s.", GetRoleplayName(TargetPlayer));
			SendClientMessage(playerid, COLOR_LBLUE, str);
		    format(str, sizeof(str), "Admin %s has teleported to your position.", GetRoleplayName(playerid));
			SendClientMessage(TargetPlayer, COLOR_LBLUE, str);
		    return 1;
		}
		else
		{
		    GetPlayerPos(TargetPlayer, X, Y, Z);
		    SetPlayerPosEx(playerid, X, Y, Z+2, GetPlayerInterior(TargetPlayer), GetPlayerVirtualWorld(TargetPlayer));

		    Character[playerid][bEntered] = Character[TargetPlayer][bEntered];
		    Character[playerid][hEntered] = Character[TargetPlayer][hEntered];

		    format(str, sizeof(str), "You have teleported to %s.", GetRoleplayName(TargetPlayer));
			SendClientMessage(playerid, COLOR_LBLUE, str);
		    format(str, sizeof(str), "Admin %s has teleported to your position.", GetRoleplayName(playerid));
			SendClientMessage(TargetPlayer, COLOR_LBLUE, str);
		    return 1;
		}
	}
	else
	{
	    SendErrorMessage(playerid, ERROR_ADMIN);
	}
	return 1;
}

CMD:getp(playerid, params[])
{
	new TargetPlayer, str[128],Float:X, Float:Y, Float:Z;
	if(Account[playerid][Admin] >= 1)
	{
	    if(sscanf(params, "u", TargetPlayer)) return SendClientMessage(playerid, COLOR_GRAY, "/getp [playerid]");
        if(IsPlayerInAnyVehicle(TargetPlayer))
		{
		    GetPlayerPos(playerid, X, Y, Z);
		  	SetVehiclePos(GetPlayerVehicleID(TargetPlayer), X, Y, Z+5);

		  	SetPlayerInterior(TargetPlayer, GetPlayerInterior(playerid));
		    SetPlayerVirtualWorld(TargetPlayer, GetPlayerVirtualWorld(playerid));

		    Character[TargetPlayer][bEntered] = Character[playerid][bEntered];
		    Character[TargetPlayer][hEntered] = Character[playerid][hEntered];

		    format(str, sizeof(str), "You have teleported %s to your position.", GetRoleplayName(TargetPlayer));
			SendClientMessage(playerid, COLOR_LBLUE, str);
		    format(str, sizeof(str), "Admin %s has teleported you to their position.", GetRoleplayName(playerid));
			SendClientMessage(TargetPlayer, COLOR_LBLUE, str);
		    return 1;
		}
		else
		{
		    GetPlayerPos(playerid, X, Y, Z);
		    SetPlayerPosEx(TargetPlayer, X, Y, Z+2, GetPlayerInterior(playerid), GetPlayerVirtualWorld(playerid));

		    Character[TargetPlayer][bEntered] = Character[playerid][bEntered];
		    Character[TargetPlayer][hEntered] = Character[playerid][hEntered];

		    format(str, sizeof(str), "You have teleported %s to your position.", GetRoleplayName(TargetPlayer));
			SendClientMessage(playerid, COLOR_LBLUE, str);
		    format(str, sizeof(str), "Admin %s has teleported you to their position.", GetRoleplayName(playerid));
			SendClientMessage(TargetPlayer, COLOR_LBLUE, str);
		    return 1;
		}
	}
	else
	{
	    SendErrorMessage(playerid, ERROR_ADMIN);
	}
	return 1;
}

CMD:gotoh(playerid,params[])
{
	if(Account[playerid][Admin] >= 2)
	{
	    new id, name[32], str[128];

		if(sscanf(params, "s[32]", name)) return SendClientMessage(playerid, COLOR_GRAY, "/gotoh [House Name]");
		{
			for(id = 0; id < Total_Houses_Created + 1; id++)
	        {
	            if(strfind(Houses[id][Name], name, true) != -1)
	            {
					SetPlayerPosEx(playerid, Houses[id][PosX], Houses[id][PosY], Houses[id][PosZ], 0, 0);
			        Character[playerid][hEntered] = 0;
			        Character[playerid][bEntered] = 0;
		   			format(str, sizeof(str), "%s has teleported to house %s(%d).", GetRoleplayName(playerid), Houses[id][Name], id);
					SendAdminsMessage(1, COLOR_SLATEGRAY, str);
					return 1;
			    }
			}
		}
  	}
	else
	{
	    SendErrorMessage(playerid, ERROR_ADMIN);
	}
	return 1;
}

CMD:gotob(playerid,params[])
{
	if(Account[playerid][Admin] >= 2)
	{
	    new id, idi[32], str[128];

		if(sscanf(params, "s[32]", idi)) return SendClientMessage(playerid, COLOR_GRAY, "/gotob [Business Name]");
		{
			for(id = 0; id < Total_Biz_Created + 1; id++)
	        {
	            if(strfind(Business[id][Name], idi, true) != -1)
	            {
					SetPlayerPosEx(playerid, Business[id][PosX], Business[id][PosY], Business[id][PosZ], 0, 0);
			        Character[playerid][hEntered] = 0;
			        Character[playerid][bEntered] = 0;
		   			format(str, sizeof(str), "%s has teleported to business %s(%d).", GetRoleplayName(playerid), Business[id][Name], id);
					SendAdminsMessage(1, COLOR_SLATEGRAY, str);
					return 1;
			    }
			}
		}
  	}
	else
	{
	    SendErrorMessage(playerid, ERROR_ADMIN);
	}
	return 1;
}

CMD:gotoi(playerid,params[])
{
	if(Account[playerid][Admin] >= 2)
	{
	    new id, str[128];
		if(sscanf(params, "d", id)) return SendClientMessage(playerid, COLOR_GRAY, "/gotoi [icon id]");
		{
			if(id <= Total_Icons_Created)
			{
				SetPlayerPosEx(playerid, Icons[id][PosX], Icons[id][PosY], Icons[id][PosZ], Icons[id][Interior], Icons[id][World]);
		        Character[playerid][hEntered] = 0;
		        Character[playerid][bEntered] = 0;
	   			format(str, sizeof(str), "%s has teleported to Icon(%d).", GetRoleplayName(playerid), id);
				SendAdminsMessage(1, COLOR_SLATEGRAY, str);
			}
			else
			{
				SendErrorMessage(playerid, ERROR_OPTION);
			}
		}
  	}
	else
	{
	    SendErrorMessage(playerid, ERROR_ADMIN);
	}
	return 1;
}

CMD:gotov(playerid, params[])
{
	if(Account[playerid][Admin] >= 1)
	{
	    new TargetVehicle, Float:X, Float:Y, Float:Z, str[128];
		if(sscanf(params, "d", TargetVehicle)) return SendClientMessage(playerid, COLOR_GRAY, "/gotov [VehicleID]");

		if(GetVehicleModel(TargetVehicle))
		{
		    if(IsPlayerInAnyVehicle(playerid))
		    {
		        GetVehiclePos(TargetVehicle, X, Y, Z);
		        SetVehiclePos(GetPlayerVehicleID(playerid), X, Y, Z+5);

		        Character[playerid][hEntered] = 0;
	        	Character[playerid][bEntered] = 0;

	        	format(str, sizeof(str), "You have TPed to vehicle %d.", TargetVehicle);
				SendClientMessage(playerid, COLOR_LBLUE, str);
		    }
			GetVehiclePos(TargetVehicle, X, Y, Z);
			SetPlayerPos(playerid, X, Y, Z+5);

			Character[playerid][hEntered] = 0;
	        Character[playerid][bEntered] = 0;

			format(str, sizeof(str), "You have been teleported to vehicle %d position.", TargetVehicle);
			SendClientMessage(playerid, COLOR_LBLUE, str);
		}
		else
		{
			SendErrorMessage(playerid, "Invalid vehicle ID.");
		}
	}
	else
	{
	    SendErrorMessage(playerid, ERROR_ADMIN);
	}
	return 1;
}

CMD:getv(playerid, params[])
{
	new TargetVehicle, Float:X, Float:Y, Float:Z, str[128];
	if(Account[playerid][Admin] >= 4)
	{
		if(sscanf(params, "d", TargetVehicle)) return SendClientMessage(playerid, COLOR_GRAY, "/getv [VehicleID]");
		GetPlayerPos(playerid, X, Y, Z);
		GetInFrontOfPlayer(playerid, X, Y, 1);
		SetVehiclePos(TargetVehicle, X, Y, Z);
		format(str, sizeof(str), "Vehicle %d has been teleported.", TargetVehicle);
		SendClientMessage(playerid, COLOR_LBLUE, str);

	}
	else
	{
	    SendErrorMessage(playerid, ERROR_ADMIN);
	}
	return 1;
}


CMD:admins(playerid)
{
	new 
		iCount,
		szString[128];

	SendClientMessage(playerid, COLOR_GREEN, "Administrators:");

	for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
	{
		if(IsPlayerConnected(i))
		{
			if(Account[playerid][Admin] > 0)
			{
				iCount++;

				switch(Character[playerid][AdminDuty])
				{
					case 0: format(szString, sizeof(szString), "%s (Off Duty): %s", AdminNames[Account[i][Admin]][0], GetRoleplayName(i));
					case 1: format(szString, sizeof(szString), "%s (Administrating): %s", AdminNames[Account[i][Admin]][0], GetRoleplayName(i));
				}
				SendClientMessage(playerid, COLOR_GRAY, szString);
			}
		}
	}
	if(!iCount)
		return SendClientMessage(playerid, COLOR_GRAY, "There are no administrators online!");

	return 1;
}


CMD:adminduty(playerid, params[])
{
	new str[128], option[24];
	if(Account[playerid][Admin] > 0)
	{
		if(sscanf(params, "s[12]", option)) return SendClientMessage(playerid, COLOR_GRAY, "/adminduty [on/off]");
		if(!strcmp(option, "on", true))
		{
			if(Character[playerid][AdminDuty] == 0)
			{
				Character[playerid][AdminDuty] = 1;
				for (new i = 0; i < MAX_PLAYERS; ++i)
				{
					if(LoggedIn[i] == true)
					{
						format(str, sizeof(str), "%s %s is now on admin duty, feel free to request their help.", AdminNames[Account[playerid][Admin]][0], GetRoleplayName(playerid));
						SendInfoMessage(i, str);
					}
				}
				SendClientMessage(playerid, COLOR_YELLOW, "You are now on admin duty.");
				SetPlayerColor(playerid, COLOR_GREEN);
			}
			else SendErrorMessage(playerid, "You are already on admin duty!");
		}
		else if(!strcmp(option, "off", true))
		{
			if(Character[playerid][AdminDuty] == 1)
			{
			    Character[playerid][AdminDuty] = 0;
			    SendClientMessage(playerid, COLOR_YELLOW, "You are now off admin duty.");
			    SetPlayerColor(playerid, COLOR_WHITE);
			}
			else SendErrorMessage(playerid, "You are not on admin duty.");
		}
	}
	else
	{
     	SendErrorMessage(playerid, ERROR_ADMIN);
	}
	return 1;
}
ALTCMD:aduty->adminduty;


new reportcount = 0;
CMD:report(playerid, params[])
{
	new str[250], pid, info[200];
	if(sscanf(params, "us[200]", pid, info)) return SendClientMessage(playerid, COLOR_GRAY, "/report [playerid] [reason]");
	if(pid == playerid) return SendErrorMessage(playerid, "You cannot report yourself!");
	if(IsPlayerConnected(pid))
	{
		reportcount++;
		format(str, sizeof(str), "(#%d) Report from: [%s] | Report on: [%s] | Reason:[%s]", reportcount, GetRoleplayName(playerid), GetRoleplayName(pid), info);
		SendAdminsMessage(1, COLOR_YELLOW, str);//log
	}
	else SendErrorMessage(playerid, "Player not connected.");
	return 1;
}


CMD:deleteicon(playerid, params[])
{
	new id, query[100], str[128];
	if(Account[playerid][Admin] == 6)
	{
	    if(sscanf(params, "d", id)) return SendClientMessage(playerid, COLOR_GRAY, "/deleteicon [id]");
		mysql_format(SQL_CONNECTION, query, sizeof(query), "DELETE FROM `Icons` WHERE `Icons`.`SQLID` = %d", Icons[id][SQLID]);
		mysql_tquery(SQL_CONNECTION, query);
		Total_Icons_Created --;
		format(str, sizeof(str), "%s has deleted an icon(ID:%d).", GetRoleplayName(playerid), id);
		SendAdminsMessage(1, COLOR_ORANGERED, str);
		ReloadIcons();
	}
	else
	{
	    SendErrorMessage(playerid, ERROR_ADMIN);
	}
	return 1;
}

CMD:deletebiz(playerid, params[])
{
	new bizid, query[100], str[128];
	if(Account[playerid][Admin] == 6)
	{
	    if(sscanf(params, "d", bizid)) return SendClientMessage(playerid, COLOR_GRAY, "/deletebiz [id]");
		mysql_format(SQL_CONNECTION, query, sizeof(query), "DELETE FROM `%e`.`Business` WHERE `Business`.`ID` = %d", SQL_DB, Business[bizid][SQLID]);
		mysql_tquery(SQL_CONNECTION, query);
		Total_Biz_Created --;
		format(str, sizeof(str), "%s has deleted a business(ID:%d).", GetRoleplayName(playerid), bizid);
		SendAdminsMessage(1, COLOR_ORANGERED, str);
		ReloadBiz();
	}
	else
	{
	    SendErrorMessage(playerid, ERROR_ADMIN);
	}
	return 1;
}

CMD:deletehouse(playerid, params[])
{
	new hid, query[100], str[128];
	if(Account[playerid][Admin] == 6)
	{
	    if(sscanf(params, "d", hid)) return SendClientMessage(playerid, COLOR_GRAY, "/deletehouse [id]");
		mysql_format(SQL_CONNECTION, query, sizeof(query), "DELETE FROM `Houses` WHERE `Houses`.`SQLID` = %d", Houses[hid][SQLID]);
		mysql_tquery(SQL_CONNECTION, query);
		Total_Houses_Created --;
		format(str, sizeof(str), "%s has deleted a house(ID:%d).", GetRoleplayName(playerid), Houses[hid][SQLID]);
		SendAdminsMessage(1, COLOR_ORANGERED, str);
		ReloadHouses();
	}
	else
	{
	    SendErrorMessage(playerid, ERROR_ADMIN);
	}
	return 1;
}

CMD:billcosby(playerid, params[])
{
    if(LoggedIn[playerid] == false) return 1;
    GameTextForPlayer(playerid, "~w~zip ~r~zop ~b~zoopity ~y~bop!", 5000, 0);
    return 1;
}

CMD:setplayer(playerid, params[])
{
	new str[128], player, option1[24], option2;
	if(Account[playerid][Admin] > 0)
	{
        if(sscanf(params, "us[12]d", player, option1, option2)) return SendClientMessage(playerid, COLOR_GRAY, "/setplayer [id] [option] [value]");
		{
		    if(Account[player][Admin] > Account[playerid][Admin]) return SendErrorMessage(playerid, ERROR_ADMINLEVEL);
    		if(IsPlayerConnected(player))
			{
	            if(player != INVALID_PLAYER_ID)
				{

				    if(!strcmp(option1, "level", true))
					{
					    if (Account[playerid][Admin] >= 6)
						{
			                SetPlayerScore(player, option2);
							Character[player][Level] = option2;
							MYSQL_Update_Character(player, option1, option2);
							SendSetMessages(player, playerid, option1, option2);
							return 1;
					    }
					    else
				    	{
					    	SendErrorMessage(playerid, ERROR_ADMIN);
				    	}
					}

				    else if(!strcmp(option1, "skin", true))
					{
					    if (Account[playerid][Admin] > 0)
						{
							if(option2 < 1 || option2 > 311)
							{
								SendClientMessage(playerid, COLOR_GREY, "Skin can't be below 1 or above 311 !");
								return 1;
							}
							else
							{
					        	SetPlayerSkinEx(player, option2);
								MYSQL_Update_Character(player, option1, option2);
				                SendSetMessages(player, playerid, option1, option2);
								return 1;
						    }
				        }
					}

				    else if(!strcmp(option1, "vworld", true))
					{
					    if (Account[playerid][Admin] > 0)
						{
			                SetPlayerVirtualWorld(player, option2);
							Character[player][VWorld] = option2;
							MYSQL_Update_Character(player, option1, option2);
			                SendSetMessages(player, playerid, option1, option2);
							return 1;
				        }
					}

				    else if(!strcmp(option1, "interior", true))
					{
					    if (Account[playerid][Admin] > 0)
						{
			                SetPlayerInterior(player, option2);
							Character[player][Interior] = option2;
							MYSQL_Update_Character(player, option1, option2);
							SendSetMessages(player, playerid, option1, option2);
							return 1;
						}
					}

					else if(!strcmp(option1, "hp", true))
					{
					    if (Account[playerid][Admin] > 0)
						{
							if(option2 > 0 && option2 < 101)
							{
				                SetPlayerHealth(player, option2);
								Character[player][Health] = option2;

				                format(str, sizeof(str), " Admin %s has set %s's %s to %d.", GetRoleplayName(playerid), GetRoleplayName(player), option1, option2);
				                SendClientMessage(player, COLOR_YELLOW, str);
								SendAdminsMessage(1, COLOR_YELLOW, str);
								return 1;
				            }
					    }
					    else
						{
							SendErrorMessage(playerid, ERROR_ADMIN);
						}
					}

				    else if(!strcmp(option1, "armour", true))
					{
					    if (Account[playerid][Admin] > 0)
						{
							if(option2 > 0 && option2 < 101)
							{
				                SetPlayerArmour(player, option2);
								Character[player][Armour] = option2;
								SendSetMessages(player, playerid, option1, option2);
								return 1;
				            }
					    }
					    else
				    	{
					    	SendErrorMessage(playerid, ERROR_ADMIN);
				    	}
					}

				    else if(!strcmp(option1, "faction", true))
					{
					    if (Account[playerid][Admin] > 4)
						{
						    if(option2 > 0 && option2 <= MAX_FACTIONS)
						    {
						        Character[player][Faction] = Factions[option2][SQLID];
						        Character[player][Rank] = 1;
								MYSQL_Update_Character(player, option1, option2);
								MYSQL_Update_Character(player, "Rank", 1);
								new fid = GetFactionIDFromSQLID(Character[player][Faction]);
						        format(str, sizeof(str), " Admin %s has set %s's %s to %s(%d).", GetRoleplayName(playerid), GetRoleplayName(player), option1, Factions[fid][Name], option2);
				                SendClientMessage(player, COLOR_YELLOW, str);
								SendAdminsMessage(1, COLOR_YELLOW, str);
								return 1;
						    }
						    else if(option2 == 0)
							{
						        Character[player][Faction] = option2;
						        Character[player][Rank] = 0;
								MYSQL_Update_Character(player, option1, option2);
								MYSQL_Update_Character(player, "Rank", 0);
              					format(str, sizeof(str), " Admin %s has set %s's %s to factionless(%d).", GetRoleplayName(playerid), GetRoleplayName(player), option1, Factions[Character[player][Faction]][Name], option2);
				                SendClientMessage(player, COLOR_YELLOW, str);
								SendAdminsMessage(1, COLOR_YELLOW, str);
								return 1;
							}
						    else
						    {
						        SendClientMessage(playerid, COLOR_YELLOW, ERROR_OPTION);
						    }
				        }
					}
				    else if(!strcmp(option1, "rank", true))
					{
					    if (Account[playerid][Admin] > 4)
						{
							new fid = GetFactionIDFromSQLID(Character[player][Faction]);
         					if(option2 > 0 && option2 <= Factions[fid][MaxRank])
						    {
						        Character[player][Rank] = option2;
						        MYSQL_Update_Character(player, option1, option2);
						        SendSetMessages(player, playerid, option1, option2);
								return 1;
						    }
						    else
						    {
						        SendClientMessage(playerid, COLOR_YELLOW, ERROR_OPTION);
						    }
				        }
					}

				    else if(!strcmp(option1, "age", true))
					{
					    if (Account[playerid][Admin] > 0)
						{
	                        if(option2 > 0 && option2 <= 90)
							{
	                            Character[player][Age] = option2;
	                            MYSQL_Update_Character(player, option1, option2);
						        SendSetMessages(player, playerid, option1, option2);
	                            return 1;
						    }
						    else
						    {
						        SendErrorMessage(playerid, ERROR_OPTION);
						    }
				        }
					}
				    else if(!strcmp(option1, "gender", true))
					{
					    if (Account[playerid][Admin] > 0)
						{
	                        if(option2 > 0 && option2 <= 2)
							{
	                            Character[player][Gender] = option2;
	                            MYSQL_Update_Character(player, option1, option2);
						        SendSetMessages(player, playerid, option1, option2);
	                            return 1;
						    }
						    else
						    {
						        SendErrorMessage(playerid, ERROR_OPTION);

						    }
				        }
					}
				    else if(!strcmp(option1, "house", true))
					{
					    if (Account[playerid][Admin] >= 6)
						{
	                        if(option2 > 0 && option2 <= MAX_HOUSES)
							{
	                            Character[player][House] = option2;
						        SendSetMessages(player, playerid, option1, option2);
	                            return 1;
						    }
						    else
						    {
						        SendErrorMessage(playerid, ERROR_OPTION);
						    }
				        }
					}
				    else if(!strcmp(option1, "business", true))
					{
					    if (Account[playerid][Admin] >= 6)
						{
	                        if(option2 > 0 && option2 <= MAX_BIZ)
							{
	                            Character[player][Business_1] = option2;
						        SendSetMessages(player, playerid, option1, option2);
	                            return 1;
						    }
						    else
						    {
						        SendErrorMessage(playerid, ERROR_OPTION);
						    }
				        }
					}
					else if(!strcmp(option1, "Business_2", true))
					{
					    if (Account[playerid][Admin] >= 6)
						{
	                        if(option2 > 0 && option2 <= MAX_BIZ)
							{
	                            Character[player][Business_2] = option2;
						        SendSetMessages(player, playerid, option1, option2);
	                            return 1;
						    }
						    else
						    {
						        SendErrorMessage(playerid, ERROR_OPTION);
						    }
				        }
					}
				    else if(!strcmp(option1, "hentered", true))
					{
					    if (Account[playerid][Admin] >= 4)
						{
	                        if(option2 > 0 && option2 <= MAX_HOUSES)
							{
	                            Character[player][hEntered] = option2;
						        SendSetMessages(player, playerid, option1, option2);
	                            return 1;
						    }
						    else
						    {
						        SendErrorMessage(playerid, ERROR_OPTION);
						    }
				        }
					}
				    else if(!strcmp(option1, "bentered", true))
					{
					    if (Account[playerid][Admin] >= 4)
						{
	                        if(option2 > 0 && option2 <= MAX_BIZ)
							{
	                            Character[player][bEntered] = option2;
						        SendSetMessages(player, playerid, option1, option2);
	                            return 1;
						    }
						    else
						    {
						        SendErrorMessage(playerid, ERROR_OPTION);
						    }
				        }
					}
				    else if(!strcmp(option1, "bank", true))
					{
					    if (Account[playerid][Admin] >= 6)
						{
	                            Character[player][Bank] = option2;
	                            MYSQL_Update_Character(player, option1, option2);
						        SendSetMessages(player, playerid, option1, option2);
	                            return 1;
				        }
					}
				    else if(!strcmp(option1, "cash", true))
					{
					    if (Account[playerid][Admin] >= 6)
						{
	                            Character[player][Cash] = option2;
	                            GivePlayerMoneyEx(player, 0);
	                            MYSQL_Update_Character(player, option1, option2);
						        SendSetMessages(player, playerid, option1, option2);
	                            return 1;
				        }
					}
				    else if(!strcmp(option1, "admin", true))
					{
					    if (Account[playerid][Admin] >= 6)
						{
                            if(option2 > 0 && option2 <= 6)
							{
	                            Account[player][Admin] = option2;
	                            MYSQL_Update_Interger(Account[player][SQLID], "Accounts", "Admin", Account[player][Admin]);
						        SendSetMessages(player, playerid, option1, option2);
	                            return 1;
							}
						}
					}
				    else if(!strcmp(option1, "ExemptIP", true))
					{
					    if (Account[playerid][Admin] >= 6)
						{
                            if(option2 >= 0 && option2 <= 1)
							{
	                            Character[player][ExemptIP] = option2;
	                            MYSQL_Update_Character(player, option1, option2);
                                SendSetMessages(player, playerid, option1, option2);
	                            return 1;
							}
						}
					}
				    else if(!strcmp(option1, "Job", true))
					{
					    if (Account[playerid][Admin] >= 4)
						{
                            if(option2 >= 0 && option2 <= MAX_JOBS)
							{
	                            Character[player][Job] = option2;
	                            MYSQL_Update_Character(player, option1, option2);
                                SendSetMessages(player, playerid, option1, option2);
	                            return 1;
							}
						}
					}
				    else if(!strcmp(option1, "PhoneStatus", true))
					{
					    if(Account[playerid][Admin] >= 2)
						{
						    if(Inventory[player][PhoneNumber] > 0)
						    {
	                            if(option2 >= 0 && option2 <= 5)
								{
		                            Inventory[player][PhoneStatus] = option2;
		                            MYSQL_Update_Character(player, option1, option2);
	                                SendSetMessages(player, playerid, option1, option2);
		                            return 1;
								}
				            }
						}
					}
				}
				else
				{
				    SendErrorMessage(playerid, ERROR_INVALIDPLAYER);
				}
			}
		}
/*		else
		{
		    SendClientMessage(playerid, COLOR_GRAY, "/setplayer [id] [option]");
		    SendClientMessage(playerid, COLOR_GRAY, "Options:\t [health][armour][level][skinvw][inteior][age][gender][faction]");
		    SendClientMessage(playerid, COLOR_GRAY, "Options:\t [rank][job][house][Business_1][hentered][bentered][bank][adminlevel]");

		}*/
	}
	else
	{
		SendErrorMessage(playerid, ERROR_ADMIN);
	}
	return 1;
}
ALTCMD:setp->setplayer;


CMD:setskill(playerid, params[])
{
	new weapon, level;
	if(Account[playerid][Admin] >= 5)
	{

        if(sscanf(params, "dd", weapon, level)) return SendClientMessage(playerid, COLOR_GRAY, "/setskill [weaponid] [level]");
		{
			SetPlayerSkillLevel(playerid, weapon, level);
			SendClientMessage(playerid, COLOR_HOTTRACK, "Done!");
		}
	}
	return 1;
}


public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{

    new Float:damage, Float:health, Float:armour, Float: dist, Float:poz[3], dam;

    GetPlayerHealth(playerid,health);
    GetPlayerArmour(playerid,armour);
    GetPlayerPos(playerid, poz[0], poz[1], poz[2]);
    dist = GetPlayerDistanceFromPoint(issuerid, poz[0], poz[1], poz[2]);
    dam = floatround(dist);

    if(issuerid != INVALID_PLAYER_ID)
    {
       
        new newdamage = 0;     

        switch(GetPlayerWeapon(issuerid)){
            case 0: 
            { // Fist
                damage = 7;
                newdamage = 1;
            }
            case 1,2,3,5,6,7: 
            { // Misc Melee
                damage = 18;
                newdamage = 1;
            }
            case 22: 
            { //9mm
                damage = 24;
                newdamage = 1;
            }

            case 24: 
            { // Deagle
                damage = 50;
                newdamage = 1;
            }

            case 25: 
            { // Shotgun
                damage = 75 - (dam * 2);
                if(damage <= 0) damage = 2;
                newdamage = 1;
            }
            case 23: 
            {
                    
                damage = 30; // Silenced 9mm
                newdamage = 1;
            }
            case 27: 
            {
                damage = 25 - (dam * 2);
                if(damage <= 0) damage = 2; // SPAS 12
                newdamage = 1;
            }
            case 29: 
            { // MP5
                damage = 17;
                newdamage = 1;
            }
            case 31: 
            { // M4
                damage = 26;
                newdamage = 1;
            }
            case 30: 
            { // AK
                damage = 25;
                newdamage = 1;
            }
            case 33: 
            {
                    damage = 65; //Country Rifle
                    newdamage = 1;
            }
            case 34: 
            { // Sniper
                damage = 90;
                newdamage = 1;
            }
            case 28,32: 
            {
                damage = 17; //Uzi
                newdamage = 1;
            }
            case 8,4: 
            {
                damage = 30; //Katana / Knife
                newdamage = 1;
            }
        }

        switch(bodypart)
        {
                case 3: damage = damage - (damage / 3.8);
                case 4: damage = damage - (damage / 4.0);
                case 5: damage = damage - (damage / 2.4);
                case 6: damage = damage - (damage / 2.5);
                case 7: damage = damage - (damage / 3.0);
                case 8: damage = damage - (damage / 2.9);
        }
        if(newdamage == 1)
        {
                if(armour == 0)
                {
                	health = health - damage;
                	if(health < 0)
                	{
                        health = health - health;
                    }
                }

                else
                {
	                armour = armour - damage;
	                if(armour < 0)
	                {
		                health = health + armour;
		                armour = 0;
                    }
                }
                SetPlayerHealth(playerid, health);
                SetPlayerArmour(playerid, armour);
        }
    }
    else if(issuerid == INVALID_PLAYER_ID)
    {
       
    }

    return 1;
}



stock SendSetMessages(player, playerid, option1[], option2)
{
	new str[128];
    format(str, sizeof(str), " Admin %s has set %s's %s to %d.", GetRoleplayName(playerid), GetRoleplayName(player), option1, option2);
    SendClientMessage(player, COLOR_YELLOW, str);
	SendAdminsMessage(1, COLOR_YELLOW, str);
	return 1;
}


CMD:setbiz(playerid, params[])
{
	new str[128], query[128], id, option2[24], option3;
	if(Account[playerid][Admin] > 5)
	{

        if(sscanf(params, "ds[12]d", id, option2, option3)) return SendClientMessage(playerid, COLOR_GRAY, "/setbiz [id] [interior/exterior/owner/owned/price/payout/type] [value]");
		{
		     //			| Option 1 | Interior |
			if(!strcmp(option2, "interior", true))
			{
				new int = GetPlayerInterior(playerid);
				Business[id][Interior] = int;
				GetPlayerPos(playerid, Business[id][InteriorX], Business[id][InteriorY], Business[id][InteriorZ]);

				mysql_format(SQL_CONNECTION, query, sizeof(query), "UPDATE Business SET Interior = %d, InteriorX = %f, InteriorY = %f, InteriorZ = %f WHERE SQLID = %d LIMIT 1", Business[id][Interior], Business[id][InteriorX], Business[id][InteriorY], Business[id][InteriorZ], Business[id][SQLID]);
				mysql_tquery(SQL_CONNECTION, query);

				format(str, sizeof(str), "Biz id: "COL_BLUE"%i "COL_WHITE"interior has been set to "COL_BLUE"%i", id, int);
				SendClientMessage(playerid, COLOR_WHITE, str);
			}


 //			| Option 2 | Exterior |
			if(!strcmp(option2, "exterior", true))
			{
				GetPlayerPos(playerid, Business[id][PosX],Business[id][PosY],Business[id][PosZ]);

				mysql_format(SQL_CONNECTION, query, sizeof(query), "UPDATE Business SET PosX = %f, PosY = %f, PosZ = %f WHERE SQLID = %d LIMIT 1",

												Business[id][PosX],
												Business[id][PosY],
												Business[id][PosZ],
												Business[id][SQLID]);

				mysql_tquery(SQL_CONNECTION, query);
				SendClientMessage(playerid, COLOR_GREEN, "> Business updated!");
				Reload_Business(id);
			}

			if(!strcmp(option2, "owner", true))
			{
				MYSQL_Update_Interger(Business[id][SQLID], "Business", "Owner", option3);
				SendClientMessage(playerid, COLOR_GREEN, "> Business updated!");
				Reload_Business(id);
			}

			if(!strcmp(option2, "owned", true))
			{
			    if(option3 <= 3)
			    {
					MYSQL_Update_Interger(Business[id][SQLID], "Business", "Owned", option3);
					SendClientMessage(playerid, COLOR_GREEN, "> Business updated!");
					Reload_Business(id);
				}
			}

			if(!strcmp(option2, "price", true))
			{
				MYSQL_Update_Interger(Business[id][SQLID], "Business", "Price", option3);
				SendClientMessage(playerid, COLOR_GREEN, "> Business updated!");
				Reload_Business(id);
			}

			if(!strcmp(option2, "payout", true))
			{
				MYSQL_Update_Interger(Business[id][SQLID], "Business", "Payout", option3);

				SendClientMessage(playerid, COLOR_GREEN, "> Business updated!");
				Reload_Business(id);
			}

			if(!strcmp(option2, "Safe", true))
			{
				MYSQL_Update_Interger(Business[id][SQLID], "Business", "Safe", option3);
				SendClientMessage(playerid, COLOR_GREEN, "> Business updated!");
				Reload_Business(id);
			}

			if(!strcmp(option2, "Type", true))
			{
				MYSQL_Update_Interger(Business[id][SQLID], "Business", "Type", option3);
				SendClientMessage(playerid, COLOR_GREEN, "> Business updated!");
				Reload_Business(id);
			}

			if(!strcmp(option2, "EntranceFee", true))
			{
				MYSQL_Update_Interger(Business[id][SQLID], "Business", "EntranceFee", option3);
				SendClientMessage(playerid, COLOR_GREEN, "> Business updated!");
				Reload_Business(id);
			}

			if(!strcmp(option2, "Locked", true))
			{
			    if(option3 <= 3)
			    {
					MYSQL_Update_Interger(Business[id][SQLID], "Business", "Locked", option3);
					SendClientMessage(playerid, COLOR_GREEN, "> Business updated!");
					Reload_Business(id);
				}
			}
		}
	}
	else
	{
	    SendErrorMessage(playerid, ERROR_ADMIN);
	}
	return 1;
}

CMD:seticon(playerid, params[])
{
	new query[128], id, option2[24];
	if(Account[playerid][Admin] == 6)
	{
		if(sscanf(params, "ds[64]", id, option2)) return SendClientMessage(playerid, COLOR_GRAY, "/seticon [id] [pos] ");
		{
			if(!strcmp(option2, "pos", true))
			{
            	Icons[id][Interior] = GetPlayerInterior(playerid);
            	Icons[id][World] = GetPlayerVirtualWorld(playerid);
				GetPlayerPos(playerid, Icons[id][PosX], Icons[id][PosY], Icons[id][PosZ]);

				mysql_format(SQL_CONNECTION, query, sizeof(query), "UPDATE Icons SET World = %d, Interior = %d, PosX = %f, PosY = %f, PosZ = %f WHERE SQLID = %d LIMIT 1", Icons[id][World], Icons[id][Interior], Icons[id][PosX], Icons[id][PosY], Icons[id][PosZ], Icons[id][SQLID]);
				mysql_tquery(SQL_CONNECTION, query);
				ReloadIcon(id);
			}

  		}
	}
	else
	{
	    SendErrorMessage(playerid, ERROR_ADMIN);
	}
	return 1;
}

CMD:sethouse(playerid, params[])
{
	new str[128], query[128], id, option[24], option2;

	if(Account[playerid][Admin] == 6)
	{
		if(sscanf(params, "ds[24]d", id, option, option2)) return SendClientMessage(playerid, COLOR_GRAY, "/sethouse [id] [interiorhere/exterior/owner/price/interior/world/locked/safe] [value]");
		{

 //			| Option 1 | Interior |
			if(!strcmp(option, "interiorhere", true))
			{
				GetPlayerPos(playerid, Houses[id][IntX],Houses[id][IntY],Houses[id][IntZ]);
		    	Houses[id][Interior] = GetPlayerInterior(playerid);
                Houses[id][World] = Total_Houses_Created + playerid + 1000;
                
				mysql_format(SQL_CONNECTION, query, sizeof(query), "UPDATE Houses SET IntX = %f, IntY = %f, IntZ = %f, Interior = %d, World = %d WHERE SQLID = %d LIMIT 1", Houses[id][IntX], Houses[id][IntY], Houses[id][IntZ], Houses[id][Interior], Houses[id][World], Houses[id][SQLID]);
			    mysql_tquery(SQL_CONNECTION, query);

			    format(str, sizeof(str), "You set the interior for house id: %d.", Houses[id][SQLID]);
			    SendClientMessage(playerid, COLOR_YELLOW, str);
			}


 //			| Option 2 | Exterior |
			if(!strcmp(option, "exterior", true))
			{
				GetPlayerPos(playerid, Houses[id][PosX], Houses[id][PosY], Houses[id][PosZ]);

				mysql_format(SQL_CONNECTION, query, sizeof(query), "UPDATE Houses SET PosX = %f, PosY = %f, PosZ = %f WHERE SQLID = %d LIMIT 1",

												Houses[id][PosX],
												Houses[id][PosY],
												Houses[id][PosZ],
												Houses[id][SQLID]);

				mysql_tquery(SQL_CONNECTION, query);
				SendClientMessage(playerid, COLOR_GREEN, "> House(s) updated!");
				Reload_House(id);
			}
			if(!strcmp(option, "interior", true))
			{
				Houses[id][Interior] = option2;
				MYSQL_Update_Interger(Houses[id][SQLID], "Houses", "Interior", Houses[id][Interior]);
                Reload_House(id);
			}
			if(!strcmp(option, "world", true))
			{
				Houses[id][World] = option2;
				MYSQL_Update_Interger(Houses[id][SQLID], "Houses", "World", Houses[id][World]);
                Reload_House(id);
			}
			if(!strcmp(option, "owner", true))
			{
				Houses[id][Owner] = option2;
				MYSQL_Update_Interger(Houses[id][SQLID], "Houses", "Owner", Houses[id][Owner]);
                Reload_House(id);
			}
			if(!strcmp(option, "price", true))
			{
				Houses[id][Price] = option2;
				MYSQL_Update_Interger(Houses[id][SQLID], "Houses", "Price", Houses[id][Price]);
                Reload_House(id);
			}
			if(!strcmp(option, "locked", true))
			{
				Houses[id][Locked] = option2;
				MYSQL_Update_Interger(Houses[id][SQLID], "Houses", "Locked", Houses[id][Locked]);
                Reload_House(id);
			}
			if(!strcmp(option, "safe", true))
			{
				Houses[id][Safe] = option2;
				MYSQL_Update_Interger(Houses[id][SQLID], "Houses", "Safe", Houses[id][Safe]);
                Reload_House(id);
			}
		}
	}
	else
	{
	    SendErrorMessage(playerid, ERROR_ADMIN);
	}
	return 1;
}

CMD:reload(playerid, params[])
{
	new option[6];
	if(Account[playerid][Admin] == 6)
	{
		if(sscanf(params, "s[24]", option)) return SendClientMessage(playerid, COLOR_GRAY, "/reload [biz/houses]");
		{
   			if(!strcmp(option, "Business", true))
			{
				ReloadBiz();
				SendClientMessage(playerid, COLOR_GREEN, "Businesses Reloaded!");
			}
			if(!strcmp(option, "houses", true))
			{
				ReloadHouses();
				SendClientMessage(playerid, COLOR_GREEN, "Houses Reloaded!");
			}
			if(!strcmp(option, "all", true))
			{
				ReloadAll();
				ReloadServerVehicles();
				ReloadIcons();
				SendClientMessage(playerid, COLOR_RED, "Reloading everything!");
			}
			if(!strcmp(option, "vehicles", true))
			{
				ReloadServerVehicles();
			}
			if(!strcmp(option, "icons", true))
			{
				ReloadIcons();
			}
		}
	}
	return 1;
}

CMD:createservervehicle(playerid, params[])
{
    if(Account[playerid][Admin] >= 6)
	{
		new model[24], color1, color2, str[128], query[400], Float:pos[4], type;
		if(sscanf(params, "s[24]ddD(1)", model, color1, color2, type)) return SendClientMessage(playerid, COLOR_GRAY, "/createsv [vehiclemodel] [color1] [color2]");

       	new vID = FindVehicleByNameID(model);
        if(vID == INVALID_VEHICLE_ID)
        {
            vID = strval(model);
            if(!(399 < vID < 612)) return SendClientMessage(playerid, COLOR_YELLOW, "ERROR: That ID is not a valid car id!");
        }
        if(Account[playerid][Admin] != 6 && Restricted_Vehicle(vID)) return SendErrorMessage(playerid, ERROR_OPTION);
		GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
		GetPlayerFacingAngle(playerid, pos[3]);

		new Vehicle = CreateVehicle(vID, pos[0], pos[1], pos[2], pos[3], color1, color2, 3600);

		Vehicles[Vehicle][Model] = vID;
		Vehicles[Vehicle][Color1] = color1;
		Vehicles[Vehicle][Color2] = color2;
		Vehicles[Vehicle][PosX] = pos[0];
		Vehicles[Vehicle][PosY] = pos[1];
		Vehicles[Vehicle][PosZ] = pos[2];
		Vehicles[Vehicle][PosA] = pos[3];
		Vehicles[Vehicle][Fuel] = 100;

		if(type >= 2 && type <= 6)
		{
			Vehicles[Vehicle][Type] = type;
		}
		else
		{
			Vehicles[Vehicle][Type] = 2;
		}

		format(str, sizeof(str), "You created a vehicle with the model "COL_BLUE"%d", Vehicles[Vehicle][Model]);
		SendClientMessage(playerid, COLOR_WHITE, str);

		SetVehicleParamsEx(Vehicle, 1, 1, 0, 0, 0, 0, 0);

		format(str, sizeof(str), "%s%s%d%d%s%s%s", LetterList[random(sizeof(LetterList))], LetterList[random(sizeof(LetterList))], random(10), random(10), LetterList[random(sizeof(LetterList))], LetterList[random(sizeof(LetterList))], LetterList[random(sizeof(LetterList))]);
		SetVehicleNumberPlate(Vehicle, str);
		SetVehicleToRespawn(Vehicle);
		PutPlayerInVehicle(playerid, Vehicle, 0);
		validvehicle[Vehicle] = true;

		format(Vehicles[Vehicle][Plate], 11, "%s", str);

		Total_Vehicles_Created++;
		mysql_format(SQL_CONNECTION, query, sizeof(query), "INSERT INTO `ServerVehicles` (Model, PosX, PosY, PosZ, PosA, Color1, Color2, Type, Plate) VALUES(%d, %f, %f, %f, %f, %d, %d, %d, '%e')",

	                        Vehicles[Vehicle][Model],
	                        Vehicles[Vehicle][PosX],
	                        Vehicles[Vehicle][PosY],
	                        Vehicles[Vehicle][PosZ],
	                        Vehicles[Vehicle][PosA],
	                        Vehicles[Vehicle][Color1],
                            Vehicles[Vehicle][Color2],
                            Vehicles[Vehicle][Type],
							Vehicles[Vehicle][Plate]);

    	mysql_tquery(SQL_CONNECTION, query, "VehicleInsertID", "i", Vehicle);
	}
	else
	{
	    SendErrorMessage(playerid, ERROR_ADMIN);
	}
	return 1;
}
ALTCMD:createsv->createservervehicle;

forward VehicleInsertID(vid);
public VehicleInsertID(vid)
{
	Vehicles[vid][SQLID] = cache_insert_id();
	return 1;
}

CMD:createfactionvehicle(playerid, params[])
{
    if(Account[playerid][Admin] >= 5)
	{
		new model[24], color1, color2, str[128], query[400], factionid, rank, Float:pos[4];
		if(sscanf(params, "s[24]dddd", model, color1, color2, factionid, rank)) return SendClientMessage(playerid, COLOR_GRAY, "/createfv [vehiclemodel] [color1] [color2] [factionslotid] [rank]");

       	new vID = FindVehicleByNameID(model);
        if(vID == INVALID_VEHICLE_ID)
        {
            vID = strval(model);
            if(!(399 < vID < 612)) return SendClientMessage(playerid, COLOR_YELLOW, "ERROR: That ID is not a valid car id!");
        }

        if(rank > 8 || rank < 1 || factionid > MAX_FACTIONS || factionid <= 0)
        {
            SendErrorMessage(playerid, ERROR_OPTION);
            return 1;
        }
        if(Account[playerid][Admin] != 6 && Restricted_Vehicle(vID)) return SendErrorMessage(playerid, ERROR_OPTION);

		GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
		GetPlayerFacingAngle(playerid, pos[3]);

		new Vehicle = CreateVehicle(vID, pos[0], pos[1], pos[2], pos[3], color1, color2, -1);

		Vehicles[Vehicle][Model] = vID;
		Vehicles[Vehicle][Type] = 3;
		Vehicles[Vehicle][Color1] = color1;
		Vehicles[Vehicle][Color2] = color2;
		Vehicles[Vehicle][Faction] = Factions[factionid][SQLID];
		Vehicles[Vehicle][Rank] = rank;
		Vehicles[Vehicle][Locked] = 0;
		Vehicles[Vehicle][Fuel] = 100;
		Vehicles[Vehicle][PosX] = pos[0];
		Vehicles[Vehicle][PosY] = pos[1];
		Vehicles[Vehicle][PosZ] = pos[2];
		Vehicles[Vehicle][PosA] = pos[3];

		SetVehicleParamsEx(Vehicle, 1, 1, 0, 0, 0, 0, 0);

		format(str, sizeof(str), "%s%s%d%d%s%s%s", LetterList[random(sizeof(LetterList))], LetterList[random(sizeof(LetterList))], random(10), random(10), LetterList[random(sizeof(LetterList))], LetterList[random(sizeof(LetterList))], LetterList[random(sizeof(LetterList))]);
		SetVehicleNumberPlate(Vehicle, str);
		format(Vehicles[Vehicle][Plate], 11, "%s", str);
		SetVehicleToRespawn(Vehicle);
		PutPlayerInVehicle(playerid, Vehicle, 0);
		validvehicle[Vehicle] = true;

		Total_Vehicles_Created++;
		mysql_format(SQL_CONNECTION, query, sizeof(query), "INSERT INTO `FactionVehicles` (Model, PosX, PosY, PosZ, PosA, Color1, Color2, Type, Plate, Locked, Faction, Rank) VALUES(%d, %f, %f, %f, %f, %d, %d, 3, '%e', %d, %d, %d)",

	                        Vehicles[Vehicle][Model],
	                        Vehicles[Vehicle][PosX],
	                        Vehicles[Vehicle][PosY],
	                        Vehicles[Vehicle][PosZ],
	                        Vehicles[Vehicle][PosA],
	                        Vehicles[Vehicle][Color1],
                            Vehicles[Vehicle][Color2],
							Vehicles[Vehicle][Plate],
							Vehicles[Vehicle][Locked],
							Vehicles[Vehicle][Faction],
							Vehicles[Vehicle][Rank]);

		mysql_tquery(SQL_CONNECTION, query, "VehicleInsertID", "i", Vehicle);

		format(str, sizeof(str), "Faction vehicle created: "COL_BLUE"%d", Vehicles[Vehicle][Model]);
		SendAdminsMessage(1, COLOR_WHITE, str);

	}
	else
	{
	    SendErrorMessage(playerid, ERROR_ADMIN);
	}
	return 1;
}
ALTCMD:createfv->createfactionvehicle;

CMD:delv(playerid, params[])
{
	new Vehicle;
    if(Account[playerid][Admin] < 0) return SendErrorMessage(playerid, ERROR_ADMIN);
    {
   		if(!IsPlayerInAnyVehicle(playerid)) return SendErrorMessage(playerid, ERROR_VEHICLE);
   		{
	    	Vehicle = GetPlayerVehicleID(playerid);
	    	if(Vehicles[Vehicle][SQLID] == 0)
	    	{
		    	if(Vehicle > 0)
		    	{
		    		Total_Vehicles_Created --;
	  			    DestroyVehicle(Vehicle);
	  			    validvehicle[Vehicle] = false;
	  			    ResetVehicleVariables(Vehicle);
	  			    SendClientMessage(playerid, COLOR_YELLOW, "The vehicle has been deleted!");
				}
	        }
    	}
	}
    return 1;
}

CMD:delvall(playerid, params[])
{
    if(Account[playerid][Admin] < 1) return SendErrorMessage(playerid, ERROR_ADMIN);
    {
   		DeleteAdminVehicles();
	}
    return 1;
}

stock IsAdminSpawnedVehicle(vid)
{
	if(Vehicles[vid][Type] == 0)
	{
		return 1;
	}
	return 0;
}

stock DeleteAdminVehicles()
{
	new AmountDeleted = 0, str[128];
	for(new id; id < MAX_VEH; id++)
    {
		if (IsVehicleSpawned(id))
	    {
	        if(!IsVehicleOccupied(id))
	        {
		        if(IsAdminSpawnedVehicle(id))
		        {
					 DestroyVehicle(id);
					 Total_Vehicles_Created --;
					 AmountDeleted++;
					 validvehicle[id] = false;
					 ResetVehicleVariables(id);
				}
			}
		}
	}
	if(AmountDeleted > 0)
	{
		format(str, sizeof(str), "%d admin spawned vehicle(s) have been deleted.", AmountDeleted);
		SendAdminsMessage(1, COLOR_YELLOW, str);
	}
	return 1;
}

stock IsVehicleOccupied(carid)
{
    for(new i =0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerInVehicle(i,carid))
        {
        	return 1;
        }
    }
	return 0;
}


CMD:savecar(playerid, params[])
{
	if(IsPlayerInAnyVehicle(playerid))
	{

		new vid = GetPlayerVehicleID(playerid), str[128], query[400];
	 	if(IsPlayerVehicleOwner(playerid, vid))
	    {

     		GetVehiclePos(vid, Vehicles[vid][PosX],Vehicles[vid][PosY],Vehicles[vid][PosZ]);
      		GetVehicleZAngle(vid, Vehicles[vid][PosA]);

			format(str, sizeof(str), "You have saved the posistion of your vehicle! (ID: %d)", Vehicles[vid][SQLID]);
			SendClientMessage(playerid, COLOR_YELLOW, str);

			mysql_format(SQL_CONNECTION, query, sizeof(query), "UPDATE PlayerVehicles SET PosX = %f, PosY = %f, PosZ = %f, PosA = %f WHERE SQLID = %d LIMIT 1",Vehicles[vid][PosX],Vehicles[vid][PosY],Vehicles[vid][PosZ],Vehicles[vid][PosA],Vehicles[vid][SQLID]);
   			mysql_tquery(SQL_CONNECTION, query);
   			return 1;
		}
		else if(Character[playerid][Faction] == Vehicles[vid][Faction])
		{
		    if(Character[playerid][Rank] < 7) return SendErrorMessage(playerid, ERROR_RANK);
		    if(Vehicles[vid][Type] == 3)
		    {
	     		GetVehiclePos(vid, Vehicles[vid][PosX],Vehicles[vid][PosY],Vehicles[vid][PosZ]);
	      		GetVehicleZAngle(vid, Vehicles[vid][PosA]);

				format(str, sizeof(str), "You have parked this faction vehicle(ID: %d) at this current point!",vid);
				SendClientMessage(playerid, COLOR_YELLOW, str);

				mysql_format(SQL_CONNECTION, query, sizeof(query), "UPDATE FactionVehicles SET PosX = %f, PosY = %f, PosZ = %f, PosA = %f WHERE SQLID = %d LIMIT 1",Vehicles[vid][PosX],Vehicles[vid][PosY],Vehicles[vid][PosZ],Vehicles[vid][PosA],Vehicles[vid][SQLID]);
	   			mysql_tquery(SQL_CONNECTION, query);
	   			return 1;
			}
		}
	}
	return 1;
}

CMD:setrank(playerid, params[])
{
	if(IsPlayerInAnyVehicle(playerid))
	{
		new vid = GetPlayerVehicleID(playerid), str[128], rank, fid = GetFactionIDFromSQLID(Character[playerid][Faction]);
	 	if(Vehicles[vid][Faction] == Character[playerid][Faction] && Character[playerid][Rank] >= Factions[fid][CommandRank])
	    {
	    	if(sscanf(params, "d", rank)) return SendClientMessage(playerid, COLOR_GRAY, "/setrank [1-max faction rank] (sets the vehicle's rank)");
	    	if(rank < 1 || rank > Factions[fid][MaxRank]) return SendErrorMessage(playerid, "Invalid rank.");
    		if(rank > Character[playerid][Rank]) return SendErrorMessage(playerid, "You cannot set the rank of the vehicle past your rank.");
			if(Vehicles[vid][Rank] > Character[playerid][Rank]) return SendErrorMessage(playerid, "The vehicle is ranked higher than you.");

			Vehicles[vid][Rank] = rank;

			format(str, sizeof(str), "You have updated this vehicle's rank to %d! (ID: %d)", Vehicles[vid][Rank], Vehicles[vid][SQLID]);
			SendClientMessage(playerid, COLOR_YELLOW, str);

   			MYSQL_Update_Interger(Vehicles[vid][SQLID], "PlayerVehicles", "Rank", Vehicles[vid][Rank]);
   			return 1;
		}
	}
	return 1;
}


CMD:setspawn(playerid, params[])
{

	new fid = GetFactionIDFromSQLID(Character[playerid][Faction]);
 	if(Character[playerid][Rank] == Factions[fid][MaxRank])
    {
    	new Float:pos[3], query[200];
    	GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
    	Factions[fid][PosX] = pos[0];
    	Factions[fid][PosY] = pos[1];
    	Factions[fid][PosZ] = pos[2];
		mysql_format(SQL_CONNECTION, query, sizeof(query), "UPDATE Factions SET PosX = %f, PosY = %f, PosZ = %f WHERE SQLID = %d LIMIT 1", Factions[fid][PosX], Factions[fid][PosY], Factions[fid][PosZ], Factions[fid][SQLID]);
		mysql_tquery(SQL_CONNECTION, query);

		SendClientMessage(playerid, COLOR_WHITE, "Faction spawn updated.");
	}
	else SendErrorMessage(playerid, ERROR_RANK);
	
	return 1;
}


CMD:setvehicle(playerid, params[])
{
    if(Account[playerid][Admin] >= 4)
	{
	    new option[64];
		if(sscanf(params, "s[64]", option)) return SendClientMessage(playerid, COLOR_GRAY, "/setvehicle [pos][color1][color2][model] [id]");
		{
			if(IsPlayerInAnyVehicle(playerid))
			{

 //				| Option 1 | Pos |
				if(!strcmp(option, "pos", true))
				{
					new vID = GetPlayerVehicleID(playerid), str[128], query[400];

				    if(IsServerVehicle(vID))
				    {

			     		GetVehiclePos(vID, Vehicles[vID][PosX],Vehicles[vID][PosY],Vehicles[vID][PosZ]);
			      		GetVehicleZAngle(vID, Vehicles[vID][PosA]);

						format(str, sizeof(str), "You have admin parked (ID: %d)",vID);
						SendClientMessage(playerid, COLOR_YELLOW, str);

						mysql_format(SQL_CONNECTION, query, sizeof(query), "UPDATE ServerVehicles SET PosX = %f, PosY = %f, PosZ = %f, PosA = %f WHERE SQLID = %d LIMIT 1",Vehicles[vID][PosX],Vehicles[vID][PosY],Vehicles[vID][PosZ],Vehicles[vID][PosA],Vehicles[vID][SQLID]);
			   			mysql_tquery(SQL_CONNECTION, query);
			   			return 1;
					}
					if(Vehicles[vID][Type] == 3)
				    {
			     		GetVehiclePos(vID, Vehicles[vID][PosX],Vehicles[vID][PosY],Vehicles[vID][PosZ]);
			      		GetVehicleZAngle(vID, Vehicles[vID][PosA]);

						format(str, sizeof(str), "You have admin parked this faction vehicle(ID: %d)!",vID);
						SendClientMessage(playerid, COLOR_YELLOW, str);

						mysql_format(SQL_CONNECTION, query, sizeof(query), "UPDATE FactionVehicles SET PosX = %f, PosY = %f, PosZ = %f, PosA = %f WHERE SQLID = %d LIMIT 1",Vehicles[vID][PosX],Vehicles[vID][PosY],Vehicles[vID][PosZ],Vehicles[vID][PosA],Vehicles[vID][SQLID]);
			   			mysql_tquery(SQL_CONNECTION, query);
			   			return 1;
					}
			    }
			}

		    else
			{
				SendErrorMessage(playerid, ERROR_VEHICLE);
			}
		}

		new option2;
		if(sscanf(params, "s[64]d", option, option2)) return SendClientMessage(playerid, COLOR_GRAY, "/setvehicle [pos][color1][color2][model] [id]");
		{
			if(IsPlayerInAnyVehicle(playerid))
			{
				new vid = GetPlayerVehicleID(playerid);
 //				| Option 2 | Color |
				if(!strcmp(option, "color1", true))
				{
					
				 	new str[128];

				    if(Vehicles[vid][Type] == 1)
				    {
				        Vehicles[vid][Color1] = option2;
                        ChangeVehicleColor(vid,Vehicles[vid][Color1],Vehicles[vid][Color2]);

						format(str, sizeof(str), "Resprayed player vehicle(ID: %d) color1(%d).",vid, Vehicles[vid][Color1]);
						SendClientMessage(playerid, COLOR_YELLOW, str);

   						MYSQL_Update_Interger(Vehicles[vid][SQLID], "PlayerVehicles", "Color1", Vehicles[vid][Color1]);
					}


				    else if(IsServerVehicle(vid))
				    {
				        Vehicles[vid][Color1] = option2;
                        ChangeVehicleColor(vid,Vehicles[vid][Color1],Vehicles[vid][Color2]);

						format(str, sizeof(str), "Resprayed server vehicle(ID: %d) color1(%d).",vid, Vehicles[vid][Color1]);
						SendClientMessage(playerid, COLOR_YELLOW, str);

   						MYSQL_Update_Interger(Vehicles[vid][SQLID], "ServerVehicles", "Color1", Vehicles[vid][Color1]);

					}

					else if(Vehicles[vid][Type] == 3)
				    {
				        Vehicles[vid][Color1] = option2;
                        ChangeVehicleColor(vid,Vehicles[vid][Color1],Vehicles[vid][Color2]);

						format(str, sizeof(str), "Resprayed server vehicle(ID: %d) color1(%d).",vid, Vehicles[vid][Color1]);
						SendClientMessage(playerid, COLOR_YELLOW, str);

   						MYSQL_Update_Interger(Vehicles[vid][SQLID], "FactionVehicles", "Color1", Vehicles[vid][Color1]);
						
					}

				    else
				    {
				        Vehicles[vid][Color1] = option2;
                        ChangeVehicleColor(vid,Vehicles[vid][Color1],Vehicles[vid][Color2]);

						format(str, sizeof(str), "Resprayed vehicle(ID: %d) color2(%d).",vid, Vehicles[vid][Color1]);
						SendClientMessage(playerid, COLOR_YELLOW, str);

					}

			    }

 //				| Option 3 | Color2 |
				if(!strcmp(option, "color2", true))
				{
					
				 	new str[128];

				    if(Vehicles[vid][Type] == 1)
				    {
				        Vehicles[vid][Color2] = option2;
                        ChangeVehicleColor(vid,Vehicles[vid][Color2],Vehicles[vid][Color2]);

						format(str, sizeof(str), "Resprayed player vehicle(ID: %d) color1(%d).",vid, Vehicles[vid][Color2]);
						SendClientMessage(playerid, COLOR_YELLOW, str);

   						MYSQL_Update_Interger(Vehicles[vid][SQLID], "PlayerVehicles", "Color2", Vehicles[vid][Color2]);
					}


				    else if(IsServerVehicle(vid))
				    {
				        Vehicles[vid][Color2] = option2;
                        ChangeVehicleColor(vid,Vehicles[vid][Color2],Vehicles[vid][Color2]);

						format(str, sizeof(str), "Resprayed server vehicle(ID: %d) color1(%d).",vid, Vehicles[vid][Color2]);
						SendClientMessage(playerid, COLOR_YELLOW, str);

   						MYSQL_Update_Interger(Vehicles[vid][SQLID], "ServerVehicles", "Color2", Vehicles[vid][Color2]);

					}

					else if(Vehicles[vid][Type] == 3)
				    {
				        Vehicles[vid][Color2] = option2;
                        ChangeVehicleColor(vid,Vehicles[vid][Color2],Vehicles[vid][Color2]);

						format(str, sizeof(str), "Resprayed server vehicle(ID: %d) color1(%d).",vid, Vehicles[vid][Color2]);
						SendClientMessage(playerid, COLOR_YELLOW, str);

   						MYSQL_Update_Interger(Vehicles[vid][SQLID], "FactionVehicles", "Color2", Vehicles[vid][Color2]);
						
					}

				    else
				    {
				        Vehicles[vid][Color2] = option2;
                        ChangeVehicleColor(vid,Vehicles[vid][Color2],Vehicles[vid][Color2]);

						format(str, sizeof(str), "Resprayed vehicle(ID: %d) color2(%d).",vid, Vehicles[vid][Color2]);
						SendClientMessage(playerid, COLOR_YELLOW, str);

					}
				}

//				| Option 4 | Model |
				if(!strcmp(option, "model", true))
				{
					if(Account[playerid][Admin])
					{
						if(!(399 < option2 < 612)) return SendClientMessage(playerid, COLOR_YELLOW, "ERROR: That ID is not a valid car id!");
						
					 	new str[128], NewModel;

					    if(Vehicles[vid][Type] == 1)
					    {
	                        Vehicles[vid][Model] = option2;
				     		GetVehiclePos(vid, Vehicles[vid][PosX],Vehicles[vid][PosY],Vehicles[vid][PosZ]);
				      		GetVehicleZAngle(vid, Vehicles[vid][PosA]);

							RemovePlayerFromVehicle(playerid);
							DestroyVehicle(vid);

							NewModel = CreateVehicle(Vehicles[vid][Model],Vehicles[vid][PosX],Vehicles[vid][PosY],Vehicles[vid][PosZ],Vehicles[vid][PosA],Vehicles[vid][Color1],Vehicles[vid][Color2], 3600);
							PutPlayerInVehicle(playerid, NewModel, 0);

							format(str, sizeof(str), "You have changed player vehicle(ID: %d) to vehicle (%d)",vid, Vehicles[vid][Model]);
							SendClientMessage(playerid, COLOR_YELLOW, str);

				   			MYSQL_Update_Interger(Vehicles[vid][SQLID], "PlayerVehicles", "Model", Vehicles[vid][Model]);
						}

					    if(IsServerVehicle(vid))
					    {
	                        Vehicles[vid][Model] = option2;
				     		GetVehiclePos(vid, Vehicles[vid][PosX],Vehicles[vid][PosY],Vehicles[vid][PosZ]);
				      		GetVehicleZAngle(vid, Vehicles[vid][PosA]);

							RemovePlayerFromVehicle(playerid);
							DestroyVehicle(vid);

							NewModel = CreateVehicle(Vehicles[vid][Model],Vehicles[vid][PosX],Vehicles[vid][PosY],Vehicles[vid][PosZ],Vehicles[vid][PosA],Vehicles[vid][Color1],Vehicles[vid][Color2], 3600);
							PutPlayerInVehicle(playerid, NewModel, 0);

							format(str, sizeof(str), "You have changed server vehicle(ID: %d) to vehicle (%d)",vid, Vehicles[vid][Model]);
							SendClientMessage(playerid, COLOR_YELLOW, str);

				   			MYSQL_Update_Interger(Vehicles[vid][SQLID], "ServerVehicles", "Model", Vehicles[vid][Model]);

						}
					}
					else SendErrorMessage(playerid, ERROR_ADMIN);
			    }

			}

		    else
			{
				SendErrorMessage(playerid, ERROR_VEHICLE);
			}
		}
	}
	else
	{
	    SendErrorMessage(playerid, ERROR_ADMIN);
	}
	return 1;
}

ALTCMD:setv->setvehicle;


CMD:spray(playerid, params[])
{
	if(InRangeOfIcon(playerid,10))
	{
		new option[64], option2;
		if(sscanf(params, "s[64]d", option, option2)) return SendClientMessage(playerid, COLOR_GRAY, "/spray [1/2] [color id]");
		{
			if(IsPlayerInAnyVehicle(playerid))
			{
				new vid = GetPlayerVehicleID(playerid), str[128];
				if(!strcmp(option, "1", true))
				{
					if(option2 < 256 && option2 > -1)
					{
					    if(Vehicles[vid][Type] != 1 && Vehicles[vid][Type] != 2)
					    {
					        Vehicles[vid][Color1] = option2;
			                ChangeVehicleColor(vid,Vehicles[vid][Color1],Vehicles[vid][Color2]);

							format(str, sizeof(str), "Resprayed vehicle(ID: %d) color2(%d).",vid, Vehicles[vid][Color1]);
							SendClientMessage(playerid, COLOR_YELLOW, str);

						}

					    if(Vehicles[vid][Type] == 1)
					    {
					        Vehicles[vid][Color1] = option2;
			                ChangeVehicleColor(vid,Vehicles[vid][Color1],Vehicles[vid][Color2]);

							format(str, sizeof(str), "Resprayed player vehicle(ID: %d) color1(%d).",vid, Vehicles[vid][Color1]);
							SendClientMessage(playerid, COLOR_YELLOW, str);

   							MYSQL_Update_Interger(Vehicles[vid][SQLID], "PlayerVehicles", "Color1", Vehicles[vid][Color1]);

						}
					}
			    }

				if(!strcmp(option, "2", true))
				{

				    if(IsAdminSpawnedVehicle(vid))
				    {
				        Vehicles[vid][Color2] = option2;
		                ChangeVehicleColor(vid,Vehicles[vid][Color1],Vehicles[vid][Color2]);

						format(str, sizeof(str), "Resprayed vehicle(ID: %d) color2(%d).",vid, Vehicles[vid][Color2]);
						SendClientMessage(playerid, COLOR_YELLOW, str);

					}

				    if(Vehicles[vid][Type] == 1)
				    {
				        Vehicles[vid][Color2] = option2;
		                ChangeVehicleColor(vid,Vehicles[vid][Color1],Vehicles[vid][Color2]);

						format(str, sizeof(str), "Resprayed player vehicle(ID: %d) color2(%d).",vid, Vehicles[vid][Color2]);
						SendClientMessage(playerid, COLOR_YELLOW, str);

   						MYSQL_Update_Interger(Vehicles[vid][SQLID], "PlayerVehicles", "Color2", Vehicles[vid][Color2]);
						
					}
				}
		 	}
		}
	}
 	else
 	{
 	    SendErrorMessage(playerid, ERROR_LOCATION);
 	}
	return 1;
}

CMD:respawnvehicle(playerid, params[])
{
	if(Account[playerid][Admin] >= 1)
	{
		if(IsPlayerInAnyVehicle(playerid))
		{
		    new str[128];
		    format(str, sizeof(str), "> Vehicle ID: %d has been respawned.",GetPlayerVehicleID(playerid));
			SendClientMessage(playerid, COLOR_YELLOW, str);
		    SetVehiclePos(GetPlayerVehicleID(playerid), Vehicles[GetPlayerVehicleID(playerid)][PosX],Vehicles[GetPlayerVehicleID(playerid)][PosY],Vehicles[GetPlayerVehicleID(playerid)][PosZ]);
		 	SetVehicleZAngle(GetPlayerVehicleID(playerid), Vehicles[GetPlayerVehicleID(playerid)][PosA]);
		}
		else
	    {
	        SendErrorMessage(playerid, ERROR_VEHICLE);
	    }
	}
	else
	{
	    SendErrorMessage(playerid, ERROR_ADMIN);
	}
	return 1;
}

CMD:frespawn(playerid, params[])
{
	if(Character[playerid][Faction] > 0)
    {
        if(Character[playerid][Rank] > 6)
    	{
		    new optiona[8];
		    if(sscanf(params, "s[8]", optiona)) return SendClientMessage(playerid, COLOR_GRAY, "/frespawn [all]");
	        if(!strcmp(optiona, "all", true))
			{
				for(new id; id < MAX_VEH; id++)
				{
					if (IsVehicleSpawned(id))
					{
					    if(Vehicles[id][Type] == 3)
					    {
					    	if(!IsVehicleOccupied(id))
				    		{
								if(Vehicles[id][Faction] == Character[playerid][Faction])
								{
									new Panels, Doors, Lightz, Tires, Float:VehicleHP, NewV;	

									GetVehicleDamageStatus(id, Panels, Doors, Lightz, Tires);
									GetVehicleHealth(id, VehicleHP);

	                                DestroyVehicle(id);
			 						Engine_SET(playerid, id, 0);

			 						NewV = CreateVehicle(Vehicles[id][Model],Vehicles[id][PosX],Vehicles[id][PosY],Vehicles[id][PosZ],Vehicles[id][PosA],Vehicles[id][Color1],Vehicles[id][Color2], -1);
		 							SetVehicleHealth(NewV, VehicleHP);
									UpdateVehicleDamageStatus(NewV, Panels, Doors, Lightz, Tires);
			 						
								}
							}
						}
				    }
				}
				SendFactionMessage(Character[playerid][Faction], COLOR_YELLOW, "[INFO] The unoccupied faction vehicles have been respawned.");
	        }
        }
	}

	return 1;
}

CMD:businessmanager(playerid, params[])
{
	if(Account[playerid][Admin] >= 5)
	{
		Dialog_Show(playerid, BUSINESSMENU, DIALOG_STYLE_LIST, "Business System", "Create Business\nEdit Business Name\nChange Business Interior\nBusiness List", "Select","Cancel");
	}
	else
	{
	    SendErrorMessage(playerid, ERROR_ADMIN);
	}
	return 1;
}
ALTCMD:bmanager->businessmanager;

CMD:bizeditor(playerid, params[])
{
	if(Account[playerid][Admin] >= 5)
	{
		new bID = InRangeOfBiz(playerid),str[128], dialog[512];
		bizzid[playerid] = bID;
		if(bID)
		{
			format(str, sizeof(str), "Option\tValue\n");
        	strcat(dialog, str, sizeof(dialog));

			format(str, sizeof(str), "Name:\t ["COL_LBLUE"%s"COL_WHITE"]\n", Business[bID][Name]);
        	strcat(dialog, str, sizeof(dialog));

	 		format(str, sizeof(str), "Type:\t ["COL_LBLUE"%s"COL_WHITE"]\n", BusinessTypeNames[Business[bID][Type]][0]);
        	strcat(dialog, str, sizeof(dialog));

        	format(str, sizeof(str), "Price:\t ["COL_LBLUE"$%s"COL_WHITE"]\n", FormatNumber(Business[bID][Price]));
        	strcat(dialog, str, sizeof(dialog));

        	format(str, sizeof(str), "Payout:\t ["COL_LBLUE"$%s"COL_WHITE"]\n", FormatNumber(Business[bID][Payout]));
        	strcat(dialog, str, sizeof(dialog));

        	format(str, sizeof(str), "EntranceFee:\t ["COL_LBLUE"$%s"COL_WHITE"]\n", FormatNumber(Business[bID][EntranceFee]));
        	strcat(dialog, str, sizeof(dialog));

			Dialog_Show(playerid, EDITOR_BIZ, DIALOG_STYLE_TABLIST_HEADERS, Business[bID][Name], dialog, "Select","Cancel");//flist2
		}
		else SendErrorMessage(playerid, ERROR_LOCATION);
	}
	else
	{
	    SendErrorMessage(playerid, ERROR_ADMIN);
	}
	return 1;
}
//interior/exterior/owner/owned/

Dialog:EDITOR_BIZ(playerid, response, listitem, inputtext[])
{
	if(!response) return 0;
    if(response)
    {
    	new bID = bizzid[playerid];
        switch(listitem)
        {
            case 0: Dialog_Show(playerid, EDITOR_BIZ_NAME, DIALOG_STYLE_INPUT, Business[bID][Name],"Enter the business' new name:","Change","Cancel");			
			case 1:
			{
				new str[128], dialog[600];
				for (new i = 0; i < sizeof(BusinessTypeNames); ++i)
				{
					format(str, sizeof(str), "%s\n", BusinessTypeNames[i][0]);
			        strcat(dialog, str, sizeof(dialog));
				}
				Dialog_Show(playerid, EDITOR_BIZ_TYPE, DIALOG_STYLE_LIST, Business[bID][Name], dialog, "Select", "Cancel");
			}
		}
	}
    return 1;
}


Dialog:EDITOR_BIZ_NAME(playerid, response, listitem, inputtext[])
{
	if(!response) return SendErrorMessage(playerid, ERROR_DIALOG);
    if(response)
    {
    	new str[128];
		format(Business[bizzid[playerid]][Name], 64, "%s", inputtext);
		format(str, sizeof(str), "(Name Change) Business: [%d] -> [%s]", bizzid[playerid], Business[bizzid[playerid]][Name]);
		
		SendInfoMessage(playerid, str);

		MYSQL_Update_String(Business[bizzid[playerid]][SQLID], "Business", "Name", Business[bizzid[playerid]][Name]);
		Reload_Business(bizzid[playerid]);
	}
    return 1;
}

Dialog:EDITOR_BIZ_TYPE(playerid, response, listitem, inputtext[])
{
	if(!response) return 0;
	if(response)
	{
		new str[128];
		Business[bizzid[playerid]][Type] = listitem;
		format(str, sizeof(str), "(Type Change) Business: [%s] -> [%s]", Business[bizzid[playerid]][Name], BusinessTypeNames[bizzid[playerid]][0]);

		SendInfoMessage(playerid, str);

		MYSQL_Update_Interger(Business[bizzid[playerid]][SQLID], "Business", "Type", Business[bizzid[playerid]][Type]);
		Reload_Business(bizzid[playerid]);
	}
	return 1;
}

CMD:createbiz(playerid, params[])
{
	if(Account[playerid][Admin] >= 5)
	{
		Dialog_Show(playerid, CREATEBUSINESS, DIALOG_STYLE_INPUT, "Business Creation","Enter the name of the business you wish\nto create.","Continue","Cancel");
	}
	else
	{
	    SendErrorMessage(playerid, ERROR_ADMIN);
	}
	return 1;
}


CMD:housemanager(playerid, params[])
{
	if(Account[playerid][Admin] >= 5)
	{
		Dialog_Show(playerid, HOUSEMENU, DIALOG_STYLE_LIST, "House Management", "Create House\nEdit House Name\nChange House Interior\nHouse List", "Select","Cancel");
	}
	else
	{
	    SendErrorMessage(playerid, ERROR_ADMIN);
	}
	return 1;
}





CMD:clearanimation(playerid, params[])
{
	ClearAnimations(playerid);
	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_HANDSUP) return SetPlayerSpecialAction(playerid,SPECIAL_ACTION_NONE);
	return 1;
}
ALTCMD:clearanim->clearanimation;





CMD:hire(playerid, params[])
{
	if(Character[playerid][Faction] > 0)
	{
		new fid = GetFactionIDFromSQLID(Character[playerid][Faction]);
		if(Character[playerid][Rank] >= Factions[fid][CommandRank])
		{
			new option1[24], player, str[128];
		    if(sscanf(params, "us[24]", player, option1)) return SendClientMessage(playerid, COLOR_GRAY, "/hire [playerid] [confirm/decline]");
			{
				if(player == playerid) return SendErrorMessage(playerid, "You cannot hire yourself.");
				if(Character[player][Faction] > 0) return SendErrorMessage(playerid, "This player is already in a faction.");

		 		if(!strcmp(option1, "confirm", true))
				{
					Character[player][FactionOffer] = Character[playerid][Faction];
					
		    		format(str, sizeof(str), "%s is offering for you to join the faction %s. Use /joinfaction to proceed with the offer.", GetRoleplayName(playerid), Factions[fid][Name]);
		    		SendClientMessage(player, COLOR_LIMEGREEN, str);

		    		format(str, sizeof(str), "You have offered %s to join the %s.", GetRoleplayName(player), Factions[fid][Name]);
		    		SendClientMessage(playerid, COLOR_LIMEGREEN, str);
		        }	

		        else if(!strcmp(option1, "decline", true))
				{
		    		SendErrorMessage(playerid, "You decided not to hire them.");
		        }	
		    }
		}
		else SendErrorMessage(playerid, ERROR_RANK);
	}
	else SendErrorMessage(playerid, ERROR_FACTION);
	
	return 1;
}


CMD:joinfaction(playerid, params[])
{
	if(Character[playerid][FactionOffer] > 0)
	{

		new option1[24], str[128];
	    if(sscanf(params, "s[24]", option1)) return SendClientMessage(playerid, COLOR_LBLUE, "/joinfaction [accept/decline]");
		{
	 		if(!strcmp(option1, "accept", true))
			{
				Character[playerid][Faction] = Character[playerid][FactionOffer];
				Character[playerid][Rank] = 1;
				Character[playerid][FactionOffer] = 0;

				MYSQL_Update_Character(playerid, "Faction", Character[playerid][Faction]);
				MYSQL_Update_Character(playerid, "Rank", 1);

	    		format(str, sizeof(str), "%s has joined the faction.", GetRoleplayName(playerid));
	    		SendFactionMessage(Character[playerid][Faction], COLOR_LEMONCHIFFON, str);
	        }	

	        else if(!strcmp(option1, "decline", true))
			{
				Character[playerid][FactionOffer] = 0;
	    		SendErrorMessage(playerid, "You decided not to join the faction.");
	        }	
	    }
	}
	else SendErrorMessage(playerid, "You are not being offered a place in a faction.");
	
	return 1;
}

CMD:fire(playerid, params[])
{
	if(Character[playerid][Faction] > 0)
	{
		new fid = GetFactionIDFromSQLID(Character[playerid][Faction]);
		if(Character[playerid][Rank] >= Factions[fid][CommandRank])
		{
			new option1[24], player, str[128];
		    if(sscanf(params, "us[24]", player, option1)) return SendClientMessage(playerid, COLOR_GRAY, "/fire [playerid] [confirm/decline]");
			{
				if(player == playerid) return SendErrorMessage(playerid, "You cannot fire yourself.");

		 		if(!strcmp(option1, "confirm", true))
				{
					MYSQL_Update_Character(player, "Faction", 0);
					MYSQL_Update_Character(player, "Rank", 0);

					Character[player][Faction] = 0;
					Character[player][Rank] = 0;

		    		
		    		format(str, sizeof(str), "%s has fired you from the %s.", GetRoleplayName(playerid), Factions[fid][Name]);
		    		SendClientMessage(player, COLOR_INDIANRED, str);

		    		format(str, sizeof(str), "%s has been fired from the %s.", GetRoleplayName(player), Factions[fid][Name]);
		    		SendFactionMessage(Character[playerid][Faction] , COLOR_INDIANRED, str);
		        }	

		        else if(!strcmp(option1, "decline", true))
				{
		    		SendErrorMessage(playerid, "You decided not to fire them.");
		        }	
		    }
		}
		else SendErrorMessage(playerid, ERROR_RANK);
	}
	else SendErrorMessage(playerid, ERROR_FACTION);
	
	return 1;
}

CMD:promote(playerid, params[])
{
	if(Character[playerid][Faction] > 0)
	{
		if(Character[playerid][Rank] >= Factions[playerid][CommandRank])
		{
			new player, str[128];
		    if(sscanf(params, "u", player)) return SendClientMessage(playerid, COLOR_GRAY, "/promote [playerid]");
			{
				if(player == playerid) return SendErrorMessage(playerid, "You cannot promote yourself.");
				new fid = GetFactionIDFromSQLID(Character[playerid][Faction]);
				if(Character[playerid][Faction] != Character[player][Faction]) return SendErrorMessage(playerid, "That person isn't in your faction.");
				if(Character[player][Rank] + 1 >= Character[playerid][Rank]) return SendErrorMessage(playerid, "This player cannot be promote to or past your rank.");
				if(Character[player][Rank] + 1 > Factions[fid][MaxRank]) return SendErrorMessage(playerid, "You cannot promote someone past rank 8.");
		 		
		 		Character[player][Rank] += 1;
				MYSQL_Update_Character(player, "Rank", Character[player][Rank]);

				
				format(str, sizeof(str), "%s has been promoted to %s (%d).", GetRoleplayName(player), GetPlayerRank(player), Character[player][Rank]);
	    		SendFactionMessage(Character[playerid][Faction], COLOR_PALEGREEN, str);

		    }
		}
		else SendErrorMessage(playerid, ERROR_RANK);
	}
	else SendErrorMessage(playerid, ERROR_FACTION);
	
	return 1;
}



CMD:demote(playerid, params[])
{
	if(Character[playerid][Faction] > 0)
	{
		if(Character[playerid][Rank] >= Factions[playerid][CommandRank])
		{
			new player, str[128];
		    if(sscanf(params, "u", player)) return SendClientMessage(playerid, COLOR_GRAY, "/demote [playerid]");
			{
				if(player == playerid) return SendErrorMessage(playerid, "You cannot demote yourself.");
				if(Character[playerid][Faction] != Character[player][Faction]) return SendErrorMessage(playerid, "That person isn't in your faction.");
				if(Character[player][Rank] >= Character[playerid][Rank]) return SendErrorMessage(playerid, "This player cannot be demoted to or past your rank.");
				if(Character[player][Rank] - 1 <= 0) return SendErrorMessage(playerid, "You cannot demote this person any further.");
		 		
				MYSQL_Update_Character(player, "Rank", Character[player][Rank]--);

				format(str, sizeof(str), "%s has been demoted to %s(%d).", GetRoleplayName(player), GetPlayerRank(player), Character[player][Rank]);
	    		SendFactionMessage(Character[playerid][Faction] , COLOR_INDIANRED, str);

		    }
		}
		else SendErrorMessage(playerid, ERROR_RANK);
	}
	else SendErrorMessage(playerid, ERROR_FACTION);
	
	return 1;
}

#define RADIO_NONE 0
#define RADIO_ON 2
#define RADIO_OFF 1

CMD:radio(playerid, params[])
{
	new msg[128], str[128];
	if(Inventory[playerid][Radio] == RADIO_NONE) return SendErrorMessage(playerid, "You don't have a radio.");
	if(Inventory[playerid][Radio] == RADIO_ON)
	{
		if(Inventory[playerid][RadioFreq] > 0)
		{
			if(sscanf(params, "s[128]", msg)) return SendClientMessage(playerid, COLOR_GRAY, "/radio [message]");

			format(str, sizeof(str), "[Radio | %dMHz] %s: %s", Inventory[playerid][RadioFreq], GetRoleplayName(playerid), msg);
			SendFreqMessage(playerid, Inventory[playerid][RadioFreq], str);
			format(str, sizeof(str), "[Radio] %s: %s", GetRoleplayName(playerid), msg);
			SendLocalMessage(playerid, str, Range_Short, COLOR_SLATEGRAY, COLOR_SLATEGRAY);
		}
		else SendErrorMessage(playerid, "Invalid frequency.");	
	}
	else SendErrorMessage(playerid, "Your radio isn't on!");
	
	return 1;
}
ALTCMD:r->radio;


CMD:radioon(playerid, params[])
{
	if(Inventory[playerid][Radio] > RADIO_NONE)
	{
		if(Inventory[playerid][Radio] == RADIO_OFF)
		{
			new str[128];
			Inventory[playerid][Radio] = RADIO_ON;
			MYSQL_Update_Character(playerid, "Radio", Inventory[playerid][Radio]);
			format(str, sizeof(str), "* %s flicks a switch on the side of their radio turning it on. *", GetRoleplayName(playerid));
			SendLocalMessage(playerid, str, Range_Short, COLOR_RP, COLOR_RP);
		}
		else SendErrorMessage(playerid, "Your radio is already on!");
	}
	else SendErrorMessage(playerid, "You don't have a radio to use!");
	return 1;
}
ALTCMD:ron->radioon;

CMD:radiooff(playerid, params[])
{
	if(Inventory[playerid][Radio] > RADIO_NONE)
	{
		if(Inventory[playerid][Radio] == RADIO_ON)
		{
			new str[128];
			Inventory[playerid][Radio] = RADIO_OFF;
			MYSQL_Update_Character(playerid, "Radio", Inventory[playerid][Radio]);
			format(str, sizeof(str), "* %s flicks a switch on the side of their radio turning it off. *", GetRoleplayName(playerid));
			SendLocalMessage(playerid, str, Range_Short, COLOR_RP, COLOR_RP);
		}
		else SendErrorMessage(playerid, "Your radio is already off!");
	}
	else SendErrorMessage(playerid, "You don't have a radio to use!");
	return 1;
}
ALTCMD:roff->radiooff;

CMD:radiotune(playerid, params[])
{
	if(Inventory[playerid][Radio] > RADIO_NONE)
	{
		if(Inventory[playerid][Radio] == RADIO_ON)
		{
			new frequency, str[128];
			if(sscanf(params, "d", frequency)) return SendClientMessage(playerid, COLOR_GRAY, "/radiotune [frequency]");
			if(frequency == Inventory[playerid][RadioFreq]) return SendErrorMessage(playerid, "You are already on this frequency!");
			if(frequency < 1 || frequency > 9999) return SendErrorMessage(playerid, "You can only tune your radio between the frequencies 1 - 9999 MHz.");

			Inventory[playerid][RadioFreq] = frequency;
			MYSQL_Update_Character(playerid, "RadioFreq", Inventory[playerid][RadioFreq]);

			format(str, sizeof(str), "* %s fiddles with their radio for a moment, changing the frequency. *", GetRoleplayName(playerid));
			SendLocalMessage(playerid, str, Range_Short, COLOR_RP, COLOR_RP);
		}
		else SendErrorMessage(playerid, "Your radio is off!");
	}
	else SendErrorMessage(playerid, "You don't have a radio to use!");
	
	return 1;
}
ALTCMD:rtune->radiotune;

CMD:radioinfo(playerid)
{
	new str[128];
	if(Inventory[playerid][Radio] > 0)
	{
		format(str, sizeof(str), "You are currently on the frequency %d MHz.", Inventory[playerid][RadioFreq]);
		SendClientMessage(playerid, COLOR_WHITE, str);
	
	}
	else SendErrorMessage(playerid, "You don't have a radio to use!");
	
	return 1;
}

CMD:cuff(playerid, params[])
{
	if(IsLawEnforcement(playerid))
	{
		new player;
		if(sscanf(params, "u", player)) return SendClientMessage(playerid, COLOR_GRAY, "/cuff [playerid]");
      	{
      		if(IsInRangeOfPlayer(playerid, player, 5))
  			{
  				if(Character[player][Cuffed] == 0)
				{
	  				new str[128];
	      			SetPlayerSpecialAction(player, SPECIAL_ACTION_CUFFED);//variable cuffed
	      			Character[player][Cuffed] = 1;

	      			format(str, sizeof(str), "* %s has been placed into handcuffs by %s. *", GetRoleplayName(player), GetRoleplayName(playerid));
	      			SendLocalMessage(playerid, str, Range_Short, COLOR_RP, COLOR_RP);
	      		}
	      		else SendErrorMessage(playerid, "This player is already cuffed!");
  			}
  			else SendErrorMessage(playerid, "You are too far away from the specified player.");
      	}		
		
	}
	else
	{
	    SendErrorMessage(playerid, ERROR_FACTION);
	}
	return 1;
}

CMD:uncuff(playerid, params[])
{
	if(IsLawEnforcement(playerid))
	{
		new player;
		if(sscanf(params, "u", player)) return SendClientMessage(playerid, COLOR_GRAY, "/uncuff [playerid]");
      	{
      		if(IsInRangeOfPlayer(playerid, player, 5))
  			{
  				if(Character[player][Cuffed] == 1)
				{
					new str[128];
	      			SetPlayerSpecialAction(player, SPECIAL_ACTION_NONE);
	      			Character[player][Cuffed] = 0;

	      			format(str, sizeof(str), "* %s has been uncuffed by %s. *", GetRoleplayName(player), GetRoleplayName(playerid));
	      			SendLocalMessage(playerid, str, Range_Short, COLOR_RP, COLOR_RP);
				}
				else SendErrorMessage(playerid, "This player isn't cuffed.");
  			}
  			else SendErrorMessage(playerid, "You are too far away from the specified player.");
      	}		
		
	}
	else
	{
	    SendErrorMessage(playerid, ERROR_FACTION);
	}
	return 1;
}


CMD:jail(playerid, params[])
{
	if(IsLawEnforcement(playerid))
	{
		new player, minutes;
		if(sscanf(params, "ui", player, minutes)) return SendClientMessage(playerid, COLOR_GRAY, "/jail [playerid] [minutes]");
      	{
      		if(player == playerid) return SendErrorMessage(playerid, "You cannot jail yourself.");
      		if(IsInRangeOfPlayer(playerid, player, 5))
  			{
  				if(Character[player][Cuffed] == 1)
				{
	  				if(Character[player][Jail] == 0)
					{
						if(minutes <= 90 && minutes > 0)
						{

							Character[player][Jail] = minutes;
							MYSQL_Update_Character(player, "Jail", Character[player][Jail]);
		      				SendToJail(player);

	      					ClearPlayerWeapons(player);

							Add_PoliceNationalComputer(Character[player][ID], playerid, PNC_JAIL, "", minutes);

							SetPlayerSpecialAction(player, SPECIAL_ACTION_NONE);
			      			Character[player][Cuffed] = 0;

							new str[128];
		      				format(str, sizeof(str), "[INFO] %s has been jailed by %s for %d minutes.", GetRoleplayName(player), GetRoleplayName(playerid), minutes);
		      				SendFactionMessage(1, COLOR_INDIANRED, str);
		      				SendClientMessage(player, COLOR_INDIANRED, str);
		      				SendAdminsMessage(6, COLOR_SLATEGRAY, str);
						}
		  				
		      		}
		      		else SendErrorMessage(playerid, "This player is already jailed!");
		      	}
		      	else SendErrorMessage(playerid, "The player needs to be restrained before this can be performed.");
  			}
  			else SendErrorMessage(playerid, "You are too far away from the specified player.");
      	}		
	}
	else SendErrorMessage(playerid, ERROR_FACTION); 
	return 1;
}


CMD:unjail(playerid, params[])
{
	if(IsLawEnforcement(playerid))
	{
		new player;
		if(sscanf(params, "u", player)) return SendClientMessage(playerid, COLOR_GRAY, "/unjail [playerid]");
      	{
      		if(player == playerid) return SendErrorMessage(playerid, "You cannot unjail yourself.");
      		if(IsInRangeOfPlayer(playerid, player, 5))
  			{
	  				if(Character[player][Jail] > 0)
					{
							new str[128];
							Character[player][Jail] = 0;
							MYSQL_Update_Character(player, "Jail", Character[player][Jail]);

		      				SetPlayerPosEx(player, -229.1438, 971.7680, 19.4704, 0, 0);
	      					ClearPlayerWeapons(player);

		      				format(str, sizeof(str), "[INFO] %s has been UNJAILED by %s.", GetRoleplayName(player), GetRoleplayName(playerid));
		      				SendFactionMessage(1, COLOR_INDIANRED, str);
		      				SendClientMessage(player, COLOR_INDIANRED, str);
		      				SendAdminsMessage(6, COLOR_SLATEGRAY, str);
						
		  				
		      		}
		      		else SendErrorMessage(playerid, "This player is not in jailed!");

  			}
  			else SendErrorMessage(playerid, "You are too far away from the specified player.");
      	}		
	}
	else SendErrorMessage(playerid, ERROR_FACTION); 
	return 1;
}

CMD:megaphone(playerid, params[])
{
	new str[128];
	if(IsLawEnforcement(playerid))
	{
		if(GetPlayerVehicleID(playerid))
		{
			if(Vehicles[GetPlayerVehicleID(playerid)][Faction] == 1)
			{
				if(sscanf(params, "s[128]", str)) return SendClientMessage(playerid, COLOR_GRAY, "/megaphone [message]");

				format(str, sizeof(str), "[MEGAPHONE] << %s: %s >>", GetRoleplayName(playerid), str);
				SendLocalMessage(playerid, str, Range_VLong, COLOR_YELLOW, COLOR_YELLOW);
				SetPlayerChatBubble(playerid, str, COLOR_VIOLET, 20.0, 7000);
			}
			else SendErrorMessage(playerid, "This vehicle isn't fitted with a megaphone.");
		}
	}
	
	return 1;
}
ALTCMD:m->megaphone;

CMD:fine(playerid, params[])
{
	if(IsLawEnforcement(playerid))
	{
		new player, amount, reason[64];
		if(sscanf(params, "uds[64]", player, amount, reason)) return SendClientMessage(playerid, COLOR_GRAY, "/fine [playerid] [amount] [reason]");
      	{
      		if(IsInRangeOfPlayer(playerid, player, 5))
  			{
  				if(amount > 0 && amount < 50000)
				{
					new str[128];
					Add_PoliceNationalComputer(Character[player][ID], playerid, PNC_FINES, reason, amount);
					GivePlayerMoneyEx(player, -amount);

					format(str, sizeof(str), "[INFO] %s has fined %s $%d for %s.", GetRoleplayName(playerid), GetRoleplayName(player), amount, reason);
					SendClientMessage(playerid, COLOR_INDIANRED, str);
					SendClientMessage(player, COLOR_INDIANRED, str);
					SendAdminsMessage(6, COLOR_SLATEGRAY, str);
				}
				else SendErrorMessage(playerid, "You can only fine someone amounts between $1 and $50,000.");
  			}
  			else SendErrorMessage(playerid, "You are too far away from the specified player.");
      	}		
	}
	else SendErrorMessage(playerid, ERROR_FACTION); 
	return 1;
}

CMD:elm(playerid, params[])
{
	if(IsEmergancyService(Character[playerid][Faction]))
	{
		new vid = GetPlayerVehicleID(playerid);
		if(vid != INVALID_VEHICLE_ID)
		{
			if(IsEmergancyService(Vehicles[vid][Faction]))
			{
				if(EmergencyLights[vid] == 0)
				{
					Lights_SET(vid, 1);
					EmergencyLights[vid] = 1;
					SendClientMessage(playerid, COLOR_LEMONCHIFFON, "You have turned on the emergency lights.");
				}
				else
				{
				 	new VehicleDamage[4];
			 		EmergencyLights[vid] = 0;
				 	GetVehicleDamageStatus(vid, VehicleDamage[0], VehicleDamage[1], VehicleDamage[2], VehicleDamage[3]);
					UpdateVehicleDamageStatus(vid, VehicleDamage[0], VehicleDamage[1], 0, VehicleDamage[3]);
					Lights_SET(vid, Lights[vid]);

					SendClientMessage(playerid, COLOR_LEMONCHIFFON, "You have turned off the emergency lights.");
				}
			}
			else SendErrorMessage(playerid, "This vehicle doesn't have an Emergency Light System.");
		}		
	}
	else SendErrorMessage(playerid, ERROR_FACTION); 
	return 1;
}


CMD:radar(playerid, params[])
{
	if(IsLawEnforcement(playerid))
	{
		new vid = GetPlayerVehicleID(playerid);
		if(vid != INVALID_VEHICLE_ID)
		{
			if(Vehicles[vid][Faction] == 1)
			{
				new dialog[500], str[128], Float:pos[3];
				for(new i = 0; i<MAX_VEH; i++)
			    {
			        if(IsVehicleSpawned(i))
			        {
						GetVehiclePos(i, pos[0], pos[1], pos[2]);
						if(IsPlayerInRangeOfPoint(playerid, 20.0, pos[0], pos[1], pos[2]))
						{
							if(IsVehicleOccupied(i) && GetPlayerVehicleID(playerid) != i)
							{
						 		format(str, sizeof(str), "SPEED: %d - Vehicle: %s \n", CalculateVehicleSpeed(i, 1), VehicleNames[GetVehicleModel(i) - 400][0]);
	        					strcat(dialog, str, sizeof(dialog));
	        				}
	        			}
			        }
			    }
		    	Dialog_Show(playerid, Radar, DIALOG_STYLE_LIST, "Police National Computer (PNC)", dialog, "Enter","Cancel");
			}
			else SendErrorMessage(playerid, "This isn't a police vehicle.");
		}		
	}
	else SendErrorMessage(playerid, ERROR_FACTION); 
	return 1;
}



CMD:handsup(playerid, params[])
{
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_HANDSUP);
	return 1;
}

stock SendToJail(playerid)
{
 	new rand = random(sizeof(JailSpawns));
	SetPlayerPosEx(playerid, JailSpawns[rand][0], JailSpawns[rand][1], JailSpawns[rand][2], 1, 22);

	return 0;
}

stock Add_PoliceNationalComputer(player, playerid, Charge, ChargeReason[], Value)
{
	new query[400];
    mysql_format(SQL_CONNECTION, query, sizeof(query), "INSERT INTO PoliceNationalComputer (Time, Player, Officer, OfficerName, OfficerRank, Type, Reason, Value) VALUES( %d, %d, %d, '%e', '%e', %d, '%e', %d)", gettime(), player, Character[playerid][ID], GetRoleplayName(playerid), GetPlayerRank(playerid), Charge, ChargeReason, Value);
	mysql_tquery(SQL_CONNECTION, query);
	return 1;
}

stock Add_PoliceNationalComputer2(player, playerid, Charge, ChargeReason[], Value, pName[])
{
	new query[400];
    mysql_format(SQL_CONNECTION, query, sizeof(query), "INSERT INTO PoliceNationalComputer (Time, Player, Officer, OfficerName, OfficerRank, Type, Reason, Value, PlayerName) VALUES( %d, %d, %d, '%e', '%e', %d, '%e', %d, '%e')", gettime(), player, Character[playerid][ID], GetRoleplayName(playerid), GetPlayerRank(playerid), Charge, ChargeReason, Value, pName);
	mysql_tquery(SQL_CONNECTION, query);
	return 1;
}


CMD:policenationalcomputer(playerid, params[])
{
	if(IsLawEnforcement(playerid))
	{

		new vid = GetPlayerVehicleID(playerid);
		if(Vehicles[vid][Faction] == 1 || Character[playerid][bEntered] == 22)
		{
			Character[playerid][PNC] = 0;
			PoliceNationalComputer(playerid);
		}
		else SendErrorMessage(playerid, "You are not near a Police National Computer.");
	}
	else SendErrorMessage(playerid, ERROR_FACTION); 
	return 1;
}
ALTCMD:pnc->policenationalcomputer;

stock PoliceNationalComputer(playerid)
{
	Dialog_Show(playerid, PNC_Main, DIALOG_STYLE_LIST, "Police National Computer (PNC)", "Person Search\nVehicle Search\n \nOutstanding Warrants\nRecent 911 Calls\nWeapon Log ", "Enter","Shutdown");
	return 1;
}

stock PoliceNC_PersonSearch(playerid)
{
	Dialog_Show(playerid, PNC_PSearch, DIALOG_STYLE_INPUT, "Police National Computer (PNC)", "Name:", "Enter","Cancel");
	return 1;
}

stock PoliceNC_VehicleSearch(playerid)
{
	Dialog_Show(playerid, PNC_VSearch, DIALOG_STYLE_INPUT, "Police National Computer (PNC)", "Vehicle Registration:", "Enter","Cancel");
	return 1;
}


stock PoliceNC_Records(playerid)
{
	Dialog_Show(playerid, PNC_Records, DIALOG_STYLE_LIST, "Police National Computer (PNC)", "Personal Information\n \nJail Record\nPrevious Charges\nCitation Record\n \nIssue Warrant\nAdd Charge", "Enter","Back");
	return 1;
}

stock PoliceNC_AddCharge(playerid)
{
	Dialog_Show(playerid, PNC_AddCharge, DIALOG_STYLE_INPUT, "Police National Computer (PNC)", "Type the charge below:", "Add","Cancel");
	return 1;
}

stock PoliceNC_IssueWarrant(playerid)
{
	Dialog_Show(playerid, PNC_IssueWarrant, DIALOG_STYLE_INPUT, "Police National Computer (PNC)", "WARNING: YOU ARE ABOUT TO ISSUE A WARRANT FOR THIS PERSON'S ARREST. \n \nType the reason for the warrant below:", "Issue","Cancel");
	return 1;
}


Dialog:PNC_Main(playerid, response, listitem, inputtext[])
{
	if(!response) return 1;
	if(listitem == 0) return PoliceNC_PersonSearch(playerid);
	else if(listitem == 1) return PoliceNC_VehicleSearch(playerid);
	else if(listitem == 3)
	{
		mysql_tquery(SQL_CONNECTION, "SELECT ID, Time, OfficerName, OfficerRank, Reason, Value, PlayerName FROM `PoliceNationalComputer` WHERE Type = 4 AND Value = 1 ORDER BY ID DESC", "ViewActiveWarrants", "d", playerid);	
	}
	else if(listitem == 4)
	{
		mysql_tquery(SQL_CONNECTION, "SELECT ID, Incident, Location, Number, IGTime FROM `911 Calls` WHERE Service = 1 ORDER BY ID DESC LIMIT 10", "ViewRecent911", "d", playerid);	
	}
	else if(listitem == 5)
	{
		mysql_tquery(SQL_CONNECTION, "SELECT OfficerName, OfficerRank, Reason FROM `PoliceNationalComputer` WHERE Type = 5 ORDER BY Time DESC LIMIT 20", "ViewWeaponLog", "d", playerid);	
	}
	else
	{
		PoliceNationalComputer(playerid);
	}
	return 1;
}

Dialog:PNC_PSearch(playerid, response, listitem, inputtext[])
{
	if(!response) return PoliceNationalComputer(playerid);

	ReplaceSpaces(inputtext);
	if(!NameValidator(inputtext)) return PoliceNC_PersonSearch(playerid);


	new CharacterID = GetSQLIDFromName(inputtext);

	if(CharacterID == 0)
	{
		SendErrorMessage(playerid, "Invalid Name.");
		return PoliceNC_PersonSearch(playerid);
	}

	Character[playerid][PNC] = CharacterID;

	PoliceNC_Records(playerid);

    return 1;
}

Dialog:PNC_VSearch(playerid, response, listitem, inputtext[])
{
	if(!response) return PoliceNationalComputer(playerid);
	if(strlen(inputtext) > 2 && strlen(inputtext) < 9)
    {
		new query[160];
	    mysql_format(SQL_CONNECTION, query, sizeof(query), "SELECT Owner, Model FROM `PlayerVehicles` WHERE Plate = '%e' LIMIT 1", inputtext); //Jail
		mysql_tquery(SQL_CONNECTION, query, "ViewVehicleInfo", "d", playerid);	
	}
	else SendErrorMessage(playerid, "Invalid plate.");
    return 1;
}

CMD:members(playerid)
{
	if(Character[playerid][Faction] > 0)
	{
		new query[128], str[128], name[24], dialog[600], pRank;

	    mysql_format(SQL_CONNECTION, query, sizeof(query), "SELECT Name, Rank FROM `Characters` WHERE Faction = %d ORDER BY Name ASC", Character[playerid][Faction]);
		new Cache:result = mysql_query(SQL_CONNECTION, query);
		printf("%d", cache_num_rows());
        for(new id = 0; id < cache_num_rows(); id++)
        {
			cache_get_field_content(id, "Name", name, SQL_CONNECTION, MAX_PLAYER_NAME);
			pRank = cache_get_field_content_int(id, "Rank", SQL_CONNECTION);
		 	format(str, sizeof(str), "%s (%s)\n", name, GetRankName(GetFactionIDFromSQLID(Character[playerid][Faction]), pRank));
	        strcat(dialog, str, sizeof(dialog));
	    }
	 	cache_delete(result);
	    Dialog_Show(playerid, None, DIALOG_STYLE_MSGBOX, "Members", dialog, "Back", "");
	}
	else SendErrorMessage(playerid, ERROR_FACTION);
	
	return 1;
}

Dialog:PNC_Records(playerid, response, listitem, inputtext[])
{
	if(!response) return PoliceNationalComputer(playerid);
	if(listitem == 0)
	{
		new query[128], str[128], name[24], dialog[600];

	    mysql_format(SQL_CONNECTION, query, sizeof(query), "SELECT Name, Age, Gender, PhoneNumber, GDL, CDL, MDL FROM `Characters` WHERE ID = %d LIMIT 1", Character[playerid][PNC]);
		new Cache:result = mysql_query(SQL_CONNECTION, query);
		cache_get_field_content(0, "Name", name, SQL_CONNECTION, MAX_PLAYER_NAME);
		new pAge = cache_get_field_content_int(0, "Age", SQL_CONNECTION);
		new pGender = cache_get_field_content_int(0, "Gender", SQL_CONNECTION);
		new pPhoneNumber = cache_get_field_content_int(0, "PhoneNumber", SQL_CONNECTION);
		new pGDL = cache_get_field_content_int(0, "GDL", SQL_CONNECTION);
		new pCDL = cache_get_field_content_int(0, "CDL", SQL_CONNECTION);
		new pMDL = cache_get_field_content_int(0, "MDL", SQL_CONNECTION);
	 	cache_delete(result);

	 	format(str, sizeof(str), ""COL_WHITE"_________________________________________________\n");
        strcat(dialog, str, sizeof(dialog));

	 	format(str, sizeof(str), "-> General Information\n");
        strcat(dialog, str, sizeof(dialog));
	 	format(str, sizeof(str), "Name:\t\t [%s]\n", name);
        strcat(dialog, str, sizeof(dialog));
	 	format(str, sizeof(str), "Age:\t\t [%d]\n", pAge);
        strcat(dialog, str, sizeof(dialog));
	 	format(str, sizeof(str), "Gender:\t ", pGender);
        strcat(dialog, str, sizeof(dialog));
        if(pGender == 1) format(str, sizeof(str), "[Male]\n \n"); 
		else format(str, sizeof(str), "[Female]\n \n"); 
        strcat(dialog, str, sizeof(dialog));

	 	format(str, sizeof(str), ""COL_WHITE"_________________________________________________\n");
        strcat(dialog, str, sizeof(dialog));

	 	format(str, sizeof(str), "> Phone Information\n");
        strcat(dialog, str, sizeof(dialog));
	 	format(str, sizeof(str), "Phone Number: \t[%d]\n \n", pPhoneNumber);
        strcat(dialog, str, sizeof(dialog));

	 	format(str, sizeof(str), ""COL_WHITE"_________________________________________________\n");
        strcat(dialog, str, sizeof(dialog));

	 	format(str, sizeof(str), "-> Licenses\n");
        strcat(dialog, str, sizeof(dialog));
	 	format(str, sizeof(str), "General Driving License: ");
        strcat(dialog, str, sizeof(dialog));
		if(pGDL == 1) format(str, sizeof(str), "\t[VALID]\n"); 
		else format(str, sizeof(str), "\t[INVALID]\n"); 
        strcat(dialog, str, sizeof(dialog));

	 	format(str, sizeof(str), "Commercial Driving License: ");
        strcat(dialog, str, sizeof(dialog));
		if(pCDL == 1) format(str, sizeof(str), "\t[VALID]\n"); 
		else format(str, sizeof(str), "\t[INVALID]\n"); 
        strcat(dialog, str, sizeof(dialog));

	 	format(str, sizeof(str), "Motorcycle Driving License:");
        strcat(dialog, str, sizeof(dialog));
		if(pMDL == 1) format(str, sizeof(str), "\t[VALID]\n"); 
		else format(str, sizeof(str), "\t[INVALID]\n"); 
        strcat(dialog, str, sizeof(dialog));

   	 	format(str, sizeof(str), ""COL_WHITE"_________________________________________________\n");
        strcat(dialog, str, sizeof(dialog));

	 	Dialog_Show(playerid, PNC_PRecord, DIALOG_STYLE_MSGBOX, "Police National Computer (PNC)", dialog, "Back", "");

	}

	else if(listitem == 2)
	{
		new query[160];
	    mysql_format(SQL_CONNECTION, query, sizeof(query), "SELECT Time, OfficerName, OfficerRank, Value FROM `PoliceNationalComputer` WHERE Player = %d AND Type = 1 ORDER BY ID ASC", Character[playerid][PNC]); //Jail
		mysql_tquery(SQL_CONNECTION, query, "ViewJailRecord", "d", playerid);	
	}

	else if(listitem == 3)
	{
		new query[160];
	    mysql_format(SQL_CONNECTION, query, sizeof(query), "SELECT Time, OfficerName, OfficerRank, Reason FROM `PoliceNationalComputer` WHERE Player = %d AND Type = 2 ORDER BY ID ASC", Character[playerid][PNC]); //charges
		mysql_tquery(SQL_CONNECTION, query, "ViewCharges", "d", playerid);	
	}
	else if(listitem == 4)
	{
		new query[160];
	    mysql_format(SQL_CONNECTION, query, sizeof(query), "SELECT Time, OfficerName, OfficerRank, Reason, Value FROM `PoliceNationalComputer` WHERE Player = %d AND Type = 3 ORDER BY ID ASC", Character[playerid][PNC]); //charges
		mysql_tquery(SQL_CONNECTION, query, "ViewFines", "d", playerid);	
	}

	else if(listitem == 6)
	{
		PoliceNC_IssueWarrant(playerid);	
	}

	else if(listitem == 7)
	{
		PoliceNC_AddCharge(playerid);
	}
	else PoliceNC_Records(playerid);


    return 1;
}

Dialog:PNC_AddCharge(playerid, response, listitem, inputtext[])
{
	if(!response) return PoliceNC_Records(playerid);
	if(strlen(inputtext) > 4 && strlen(inputtext) < 128)
    {
    	Add_PoliceNationalComputer(Character[playerid][PNC], playerid, PNC_CHARGE, inputtext, 0);
    	SendClientMessage(playerid, COLOR_YELLOW, "Charge added successfully.");
    	PoliceNC_Records(playerid);
	}
	else 
	{
		SendErrorMessage(playerid, "Input too short/long.");
		PoliceNC_AddCharge(playerid);
	}
	return 1;
}

Dialog:PNC_IssueWarrant(playerid, response, listitem, inputtext[])
{
	if(!response) return PoliceNC_Records(playerid);
	if(strlen(inputtext) > 4 && strlen(inputtext) < 128)
    {
    	Add_PoliceNationalComputer2(Character[playerid][PNC], playerid, PNC_WARRANT, inputtext, 1, GetRoleplayNameFromSQLID(Character[playerid][PNC]));
    	new str[128];
    	format(str, sizeof(str), "[WARRANT] %s has issued a warrant for %s's arrest.", GetRoleplayName(playerid), GetRoleplayNameFromSQLID(Character[playerid][PNC]));
    	SendFactionMessage(1, COLOR_INDIANRED, str);
    	SendAdminsMessage(6, COLOR_SLATEGRAY, str);

    	SendClientMessage(playerid, COLOR_SEAGREEN, "Warrant successfully issued.");
    	PoliceNC_Records(playerid);
	}
	else 
	{
		SendErrorMessage(playerid, "Input too short/long.");
		PoliceNC_AddCharge(playerid);
	}
	return 1;
}


Dialog:PNC_PRecord(playerid, response, listitem, inputtext[])
{
	return PoliceNC_Records(playerid);
}

forward ViewVehicleInfo(playerid);
public ViewVehicleInfo(playerid)
{
	if(cache_num_rows())
    {
    	new str[128], owner, dialog[1000], model;

    	owner = cache_get_field_content_int(0, "Owner", SQL_CONNECTION);
    	model = cache_get_field_content_int(0, "Model", SQL_CONNECTION);

	 	format(str, sizeof(str), ""COL_WHITE"_________________________________________________\n");
        strcat(dialog, str, sizeof(dialog));

	 	format(str, sizeof(str), "-> Vehicle Information\n");
        strcat(dialog, str, sizeof(dialog));
	 	format(str, sizeof(str), "Owner:\t\t [%s]\n", GetRoleplayNameFromSQLID(owner));
        strcat(dialog, str, sizeof(dialog));
	 	format(str, sizeof(str), "Model:\t\t [%s]\n", VehicleNames[model - 400][0]);
        strcat(dialog, str, sizeof(dialog));

	 	format(str, sizeof(str), ""COL_WHITE"_________________________________________________\n");
        strcat(dialog, str, sizeof(dialog));
        
        Dialog_Show(playerid, PNC_VInfo, DIALOG_STYLE_MSGBOX, "Police National Computer (PNC)", dialog, "Back", "");
	}
	else
	{
		PoliceNC_VehicleSearch(playerid);
		SendErrorMessage(playerid, "Vehicle not found.");
	}
	return 1;
}

Dialog:PNC_VInfo(playerid, response, listitem, inputtext[])
{
	return PoliceNC_VehicleSearch(playerid);
}

forward ViewActiveWarrants(playerid);
public ViewActiveWarrants(playerid)
{
	if(cache_num_rows())
    {
    	new str[128], Dialog[2000], oname[24], orank[32], creason[128], wid, player[MAX_PLAYER_NAME];
        for(new id = 0; id < cache_num_rows(); id++)
        {
        	wid = cache_get_field_content_int(id, "ID", SQL_CONNECTION);
        	cache_get_field_content(id, "OfficerName", oname, SQL_CONNECTION, MAX_PLAYER_NAME);
        	cache_get_field_content(id, "OfficerRank", orank, SQL_CONNECTION, 32); 
			cache_get_field_content(id, "Reason", creason, SQL_CONNECTION, 64); 
			cache_get_field_content(id, "PlayerName", player, SQL_CONNECTION, MAX_PLAYER_NAME); 

        	format(str, sizeof(str), "Active WARRANT (#%d) issued by: %s %s | %s(wanted) for %s |\n", wid, orank, oname, player, creason);
        	strcat(Dialog, str, sizeof(Dialog));

        }
        Dialog_Show(playerid, PNC_ViewAW, DIALOG_STYLE_MSGBOX, "Police National Computer (PNC)", Dialog, "Return", "");
	}
	else
	{
		Dialog_Show(playerid, PNC_ViewAW, DIALOG_STYLE_MSGBOX, "Police National Computer (PNC)", "None", "Return", "");
	}
	return 1;
}


forward ViewWeaponLog(playerid);
public ViewWeaponLog(playerid)
{
	if(cache_num_rows())
    {
    	new str[128], Dialog[2000], oname[24], orank[32], winfo[128];
        for(new id = 0; id < cache_num_rows(); id++)
        {
        	cache_get_field_content(id, "OfficerName", oname, SQL_CONNECTION, MAX_PLAYER_NAME);
        	cache_get_field_content(id, "OfficerRank", orank, SQL_CONNECTION, 32); 
			cache_get_field_content(id, "Reason", winfo, SQL_CONNECTION, 64); 

        	format(str, sizeof(str), "Weapon Issued to: %s - %s | Information: %s |\n", orank, oname, winfo);
        	strcat(Dialog, str, sizeof(Dialog));

        }
        Dialog_Show(playerid, PNC_ViewAW, DIALOG_STYLE_MSGBOX, "Police National Computer (PNC)", Dialog, "Return", "");
	}
	else
	{
		Dialog_Show(playerid, PNC_ViewAW, DIALOG_STYLE_MSGBOX, "Police National Computer (PNC)", "None", "Return", "");
	}
	return 1;
}

forward ViewRecent911(playerid);
public ViewRecent911(playerid)
{
	if(cache_num_rows())
    {
    	new str[300], Dialog[2000], cid, incident[128], location[128], number, IgTime[12];
        for(new id = 0; id < cache_num_rows(); id++)
        {
        	cid = cache_get_field_content_int(id, "ID", SQL_CONNECTION);
        	cache_get_field_content(id, "Incident", incident, SQL_CONNECTION, 128);
        	cache_get_field_content(id, "Location", location, SQL_CONNECTION, 128);
        	number = cache_get_field_content_int(id, "Number", SQL_CONNECTION);
        	cache_get_field_content(id, "IGTime", IgTime, SQL_CONNECTION, 128);

        	format(str, sizeof(str), "911 Call (#%d) at %s | Incident: %s | Location: %s | Number: %d |\n", cid, IgTime, incident, location, number);
        	strcat(Dialog, str, sizeof(Dialog));

        }
        Dialog_Show(playerid, PNC_ViewAW, DIALOG_STYLE_MSGBOX, "Police National Computer (PNC)", Dialog, "Return", "");
	}
	else
	{
		Dialog_Show(playerid, PNC_ViewAW, DIALOG_STYLE_MSGBOX, "Police National Computer (PNC)", "None", "Return", "");
	}
	return 1;
}

Dialog:PNC_ViewAW(playerid, response, listitem, inputtext[])
{
	return PoliceNationalComputer(playerid);
}

forward ViewCharges(playerid);
public ViewCharges(playerid)
{
	if(cache_num_rows())
    {
    	new str[128], Dialog[2000], oname[24], orank[32], creason[128];
        for(new id = 0; id < cache_num_rows(); id++)
        {
        	cache_get_field_content(id, "OfficerName", oname, SQL_CONNECTION, MAX_PLAYER_NAME);
        	cache_get_field_content(id, "OfficerRank", orank, SQL_CONNECTION, 32); 
			cache_get_field_content(id, "Reason", creason, SQL_CONNECTION, 32); 

        	format(str, sizeof(str), "| [TIME] | Issued by: %s - %s | Reason: %s |\n", orank, oname, creason);
        	strcat(Dialog, str, sizeof(Dialog));

        }
        Dialog_Show(playerid, PNC_PRecord, DIALOG_STYLE_MSGBOX, "Police National Computer (PNC)", Dialog, "Return", "");
	}
	else
	{
		Dialog_Show(playerid, PNC_PRecord, DIALOG_STYLE_MSGBOX, "Police National Computer (PNC)", "None", "Return", "");
	}
	return 1;
}

forward ViewFines(playerid);
public ViewFines(playerid)
{
	if(cache_num_rows())
    {
    	new str[128], Dialog[2000], oname[24], orank[32], value, creason[128];
        for(new id = 0; id < cache_num_rows(); id++)
        {
        	cache_get_field_content(id, "OfficerName", oname, SQL_CONNECTION, MAX_PLAYER_NAME);
        	cache_get_field_content(id, "OfficerRank", orank, SQL_CONNECTION, 32); 
        	value = cache_get_field_content_int(id, "Value", SQL_CONNECTION);
			cache_get_field_content(id, "Reason", creason, SQL_CONNECTION, 32); 

        	format(str, sizeof(str), "| [TIME] | Issued by: %s - %s | Amount: $%d | Reason: %s |\n", orank, oname, value, creason);
        	strcat(Dialog, str, sizeof(Dialog));

        }
        Dialog_Show(playerid, PNC_PRecord, DIALOG_STYLE_MSGBOX, "Police National Computer (PNC)", Dialog, "Return", "");
	}
	else
	{
		Dialog_Show(playerid, PNC_PRecord, DIALOG_STYLE_MSGBOX, "Police National Computer (PNC)", "None", "Return", "");
	}
	return 1;
}


forward ViewJailRecord(playerid);
public ViewJailRecord(playerid)
{
	if(cache_num_rows())
    {
    	new str[128], Dialog[2000], oname[24], orank[32], Value;
    	printf("%d",cache_num_rows());
        for(new id = 0; id < cache_num_rows(); id++)
        {
        	cache_get_field_content(id, "OfficerName", oname, SQL_CONNECTION, MAX_PLAYER_NAME);
        	cache_get_field_content(id, "OfficerRank", orank, SQL_CONNECTION, 32); 
        	Value = cache_get_field_content_int(id, "Value", SQL_CONNECTION);

        	format(str, sizeof(str), "| [TIME] | %s - %s | %d minutes |\n", orank, oname, Value);
        	strcat(Dialog, str, sizeof(Dialog));

        }
        Dialog_Show(playerid, PNC_PRecord, DIALOG_STYLE_MSGBOX, "Police National Computer (PNC)", Dialog, "Return", "");
	}
	else
	{
		Dialog_Show(playerid, PNC_PRecord, DIALOG_STYLE_MSGBOX, "Police National Computer (PNC)", "None", "Return", "");
	}
	return 1;
}


stock GetSQLIDFromName(name[])
{
	new query[128], CID;
    mysql_format(SQL_CONNECTION, query, sizeof(query), "SELECT ID FROM `Characters` WHERE Name = '%e' LIMIT 1", name);
	new Cache:result = mysql_query(SQL_CONNECTION, query);
	CID = cache_get_field_content_int(0, "ID", SQL_CONNECTION);
 	cache_delete(result);
	return CID;
}


stock GetRoleplayNameFromSQLID(sqlid)
{
	new query[128], name[64];
    mysql_format(SQL_CONNECTION, query, sizeof(query), "SELECT Name FROM `Characters` WHERE ID = %d LIMIT 1", sqlid);
	new Cache:result = mysql_query(SQL_CONNECTION, query);
	cache_get_field_content(0, "Name", name, SQL_CONNECTION, 64);
 	cache_delete(result);
	return name;
}



stock ReplaceSpaces(str[])
{
    for(new i, len = strlen(str); i < len; i++)
    {
        if(str[i] == ' ') str[i] = '_';
    }
}

stock IsLawEnforcement(playerid)
{
	if(Factions[GetFactionIDFromSQLID(Character[playerid][Faction])][Type] == 2)
	{
		return 1;
	}
	return 0;
}

stock IsEmergancyService(fsqlid)
{
	new fid = GetFactionIDFromSQLID(fsqlid);
	if(Factions[fid][Type] == 4 || Factions[fid][Type] == 2)
	{
		return 1;
	}
	return 0;
}


stock SendFactionMessage(fac, color, msg[])
{
	foreach(Player, x)
	{
		if(IsPlayerConnected(x))
		{
		    if(Character[x][Faction] == fac)
		    {
				SendClientMessage(x, color, msg);
			}
		}
	}
	return 1;
}

stock SendFreqMessage(pid, freq, msg[])
{
	foreach(Player, x)
	{
		if(IsPlayerConnected(x))
		{
			if(x != pid)
			{
				if(Inventory[x][Radio] == RADIO_ON)
				{
					if(Inventory[x][RadioFreq] == freq)
				    {
						SendClientMessage(x, COLOR_SLATEBLUE, msg);
					}
				}
			    
			}
		}
	}
	return 1;
}



CMD:fac(playerid, params[])
{
	new msg[128], str[128];
	if(Character[playerid][Faction] > 0)
	{
		if(sscanf(params, "s[128]", msg)) return SendClientMessage(playerid, COLOR_GRAY, "/fac [message]");

		format(str, sizeof(str), "(( %s %s: %s ))", GetPlayerRank(playerid), GetRoleplayName(playerid), msg);
		SendFactionMessage(Character[playerid][Faction], COLOR_GREEN, str);
			
		
	}
	else
	{
	    SendErrorMessage(playerid, ERROR_FACTION);
	}
	return 1;
}
ALTCMD:f->fac;

CMD:membersonline(playerid, params[])
{
	new str[128];
	if(Character[playerid][Faction] > 0)
	{
		new fid = GetFactionIDFromSQLID(Character[playerid][Faction]);
		format(str, sizeof(str), "%s members ONLINE",Factions[fid][Name]);
		SendClientMessage(playerid, COLOR_YELLOW, str);
	    foreach(Player, x)
		{
		    if(Character[x][Faction] == Character[playerid][Faction])
		    {

				format(str, sizeof(str), "%s %s",GetPlayerRank(playerid), GetRoleplayName(x));
				SendClientMessage(playerid, COLOR_WHITE, str);
			}
		}
		SendClientMessage(playerid, COLOR_YELLOW, ">========================================<");

	}
	else
	{
	  	SendClientMessage(playerid, COLOR_RED, "You aren't in a faction.");
	}
	return 1;
}


//==============================================================================
//==============================================================================
//==============================================================================
//==============================================================================
//==============================================================================

stock CreateClock()
{
	new Clockstr[8];
    format(Clockstr, sizeof(Clockstr), "%02d:%02d:%02d", ClockHours, ClockMinutes, ClockSeconds);
    Clock = TextDrawCreate(546.000000,22.000000,Clockstr);
    TextDrawAlignment(Clock,0);
    TextDrawBackgroundColor(Clock, COLOR_BLACK);
    TextDrawFont(Clock,3);
    TextDrawLetterSize(Clock,0.5,2.3);
    TextDrawColor(Clock, COLOR_WHITE);
    TextDrawSetOutline(Clock,1);
    TextDrawSetProportional(Clock,1);
    TextDrawSetShadow(Clock,1);

}

forward UpdateTime();
public UpdateTime()
{
    new Clockstr[126];
	ClockSeconds++;
    if(ClockSeconds == 60)
    {
        ClockMinutes++;
        ClockSeconds = 0;
        if(ClockMinutes == 60)
        {
            ClockMinutes = 0;
            ClockHours++;

			for(new playerid; playerid < MAX_PLAYERS; playerid++)
			{
				if(IsPlayerConnected(playerid) && LoggedIn[playerid] == true)
				{
					if(Character[playerid][OnlinePeriod] > 29)
					{
						GivePayday(playerid);
                        Character[playerid][OnlinePeriod] = 0;

				    }
				    else
			    	{
			    		SendClientMessage(playerid, COLOR_GRAY, "You didn't get an hourly paycheck as you haven't played long enough.");
			    	}
				}
			}

            if(ClockHours == 24)
            {
                ClockHours = 0;
            }
        }

        format(Clockstr, sizeof(Clockstr), "%02d:%02d:%02d", ClockHours, ClockMinutes, ClockSeconds);

		for(new i = 0; i<MAX_PLAYERS; i++)
        {
            if(IsPlayerConnected(i) && LoggedIn[i] == true)
            {
                SetPlayerTime(i, ClockHours, ClockMinutes);
                Character[i][TotalTimePlayed]++;
                Character[i][OnlinePeriod]++;
                PickedUpPickup[i] = false;

                if(Character[i][Jail] > 0)
            	{
            		Character[i][Jail] --;
            		MYSQL_Update_Character(i, "Jail", Character[i][Jail]);
            		new str[64];
            		format(str, sizeof(str), "Time left: %d minutes", Character[i][Jail]);
            		GameTextForPlayer(i, str, 5000, 1);
            		if(Character[i][Jail] == 0) 
        			{
        				SetPlayerPosEx(i, -229.1438, 971.7680, 19.4704, 0, 0);
        				SendClientMessage(i, COLOR_DARKVIOLET, "You have been released from prison, we hope you've learned from your mistakes!");
            		}
            	}
            }
        }
        TextDrawSetString(Clock, Clockstr);
    }

	else
	{

		format(Clockstr, sizeof(Clockstr), "%02d:%02d:%02d", ClockHours, ClockMinutes, ClockSeconds);

		for(new i = 0; i<MAX_PLAYERS; i++)
	    {
	        if(IsPlayerConnected(i) && LoggedIn[i] == true)
	        {


	        }
	    }

	    new Panels, Doors, Lightz, Tires;										
		for(new i = 0; i<MAX_VEH; i++)
	    {
	        if(IsVehicleSpawned(i))
	        {
				if(EmergencyLights[i] == 1)
           		{
       				if(EmergencyState[i] == 1)
					{
			            GetVehicleDamageStatus(i,Panels, Doors, Lightz, Tires);
			            UpdateVehicleDamageStatus(i, Panels, Doors, 4, Tires);
			            EmergencyState[i] = 0;
					}
					else 
					{
			            GetVehicleDamageStatus(i,Panels, Doors, Lightz, Tires);
			            UpdateVehicleDamageStatus(i, Panels, Doors, 1, Tires);
			            EmergencyState[i] = 1;
					}
           		}
	          
	        }
	    }
	    TextDrawSetString(Clock, Clockstr);
	}
	return 1;
}


public OnPlayerCommandReceived(playerid, cmdtext[])
{

	LastCommandTime[playerid] = gettime();

	if(LoggedIn[playerid] == false)
	{
	    SendErrorMessage(playerid, ERROR_LOGGEDIN);
	    return 0;
	}
	else if(Character[playerid][Jail])
	{
		if(strfind(cmdtext, "/s ", true) == 0) return 1;
		else if(strfind(cmdtext, "/ame ", true) == 0) return 1;
		else if(strfind(cmdtext, "/me ", true) == 0) return 1;
		else if(strfind(cmdtext, "/do ", true) == 0) return 1;
		else if(strfind(cmdtext, "/l ", true) == 0) return 1;
		else if(strfind(cmdtext, "/pm ", true) == 0) return 1;
		else if(strfind(cmdtext, "/b", true) == 0) return 1;
		else if(strfind(cmdtext, "/logout", true) == 0) return 1;
		else if(strfind(cmdtext, "/admins", true) == 0) return 1;
		else if(strfind(cmdtext, "/stats", true) == 0) return 1;
		else 
		{
			SendErrorMessage(playerid, "You are in jail, you do not have access to this command.");
			return 0;
		}
	}
	else if(Character[playerid][ClothesSelection] == 1)
	{
	    SendErrorMessage(playerid, "You cannot perform commands at this point in time.");
	    return 0;
	}
	else if(Character[playerid][InHospital] == 1)
	{
	    SendErrorMessage(playerid, "You cannot perform commands at this point in time.");
	    return 0;
	}
    else return 1;
}

public OnPlayerCommandPerformed(playerid, cmdtext[], success)
{
    if(!success) SendClientMessage(playerid, COLOR_GRAY, "> [ERROR] Command not recognized, please check the command and try again. For more help please refer to /help or /n.");
	else
	{
		Log(playerid, cmdtext);
	}
	
	return 1;
}




Dialog:REG1(playerid, response, listitem, inputtext[])
{
	if(!response){}
    if(response)
    {
		if(strval(inputtext) > 15 && strval(inputtext) < 99)
		{
			new str[64];
	        TogglePlayerSpectating(playerid, 0);
	        
	        MYSQL_Update_Character(playerid, "Age", strval(inputtext));
	        MYSQL_Update_Character(playerid, "Tutorial", 2);

	        Character[playerid][Tutorial] = 2;
	        Character[playerid][Age] = strval(inputtext);
	        
	        format(str, sizeof(str), "You are %d years old.",strval(inputtext));
	        InfoBoxForPlayer(playerid, str);
	        Dialog_Show(playerid, REG2, DIALOG_STYLE_MSGBOX, "Character Setup", "What is your gender?","Male","Female");
		}
		else
		{
		    Dialog_Show(playerid, REG1, DIALOG_STYLE_INPUT, ""COL_BLUE"Character Setup", ""COL_WHITE"Let's start off with your age, how old are you?","Continue","");
		}
	}
    return 1;
}

Dialog:REG2(playerid, response, listitem, inputtext[])
{
	if(!response)
    {
        Character[playerid][Gender] = 2;
        SetPlayerSkinEx(playerid, 31);
    	
    }
	if(response)
	{
        Character[playerid][Gender] = 1;
        SetPlayerSkinEx(playerid, 1);
        
	}

	//

	Dialog_Show(playerid, SPAWN_SELECT, DIALOG_STYLE_MSGBOX, "Small County Roleplay", "Well done, you've completed the registration process. You can now spawn in!","Spawn","");
    return 1;
}

Dialog:SPAWN_SELECT(playerid, response, listitem, inputtext[])
{
    if(response)
    {
        StopAudioStreamForPlayer(playerid);
        
	    SetPlayerScore(playerid, 1);
        SetCameraBehindPlayer(playerid);
       	SetPlayerFacingAngle(playerid, 269.4926);
       	SetPlayerPosEx(playerid, -204.5245, 1119.2860, 19.7422, 0, 0);
       	
       	LoggedIn[playerid] = true;
       	Character[playerid][ClothesSelection] = 0;
       	Character[playerid][Skin] = GetPlayerSkin(playerid);
       	Character[playerid][Tutorial] = 5;

		
		TextDrawShowForPlayer(playerid, Clock);
		TogglePlayerControllable(playerid, 1);
		
       	InfoBoxForPlayer(playerid, "Welcome to Small County Roleplay! \n We hope that you enjoy your time playing here. Feel free to ask any questions in /n - alternatively you could use /help!");
    }
    else
    {
		KickPlayer(playerid);
    }
    return 1;
}

CMD:factionmanager(playerid, params[])
{
	if(Account[playerid][Admin] >= 5)//create name type list
	{
		new str[600];
		strcat(str, "Create Faction\n");

  		for(new i=1; i<MAX_FACTIONS; i++)
		{
			if(Factions[i][SQLID] == 0) continue;

			format(str, sizeof(str), "%sFaction slot(%d): %s\n", str, i, Factions[i][Name]);
		}

		Dialog_Show(playerid, FLIST, DIALOG_STYLE_LIST, "Faction Manager", str, "Select", "Close");
	}
	else
	{
	    SendErrorMessage(playerid, ERROR_ADMIN);
	}
	return 1;
}
ALTCMD:fmanager->factionmanager;

Dialog:FLIST(playerid, response, listitem, inputtext[])
{
	if(!response) return SendErrorMessage(playerid, ERROR_DIALOG);
    if(listitem == 0)
    {
             Dialog_Show(playerid, FCREATE, DIALOG_STYLE_INPUT, "Faction Manager - Creation","Enter the name of the faction you wish\nto create.","Create","Cancel");
	}
	else
	{
	    if(!Factions[listitem][Name] )
	    {
			SendErrorMessage(playerid, ERROR_OPTION);
			return 1;
	    }
        if(!Factions[listitem][Rank1])
        {
			SendErrorMessage(playerid, ERROR_OPTION);
			return 1;
        }
        new dialog[600], str[128];
		facid[playerid] = listitem;

	 	format(str, sizeof(str), "Faction Name: ["COL_LBLUE"%s"COL_WHITE"]\n", Factions[listitem][Name]);
        strcat(dialog, str, sizeof(dialog));

	 	format(str, sizeof(str), "Faction Type: ["COL_LBLUE"%s"COL_WHITE"]\n", FactionTypeName[Factions[listitem][Type]][0]);
        strcat(dialog, str, sizeof(dialog));

	 	format(str, sizeof(str), "Command Rank: ["COL_LBLUE"%s"COL_WHITE"]\n", GetRankNameFromID(listitem, Factions[listitem][CommandRank]));
        strcat(dialog, str, sizeof(dialog));

	 	format(str, sizeof(str), "Max Rank: ["COL_LBLUE"%s"COL_WHITE"]\n", GetRankNameFromID(listitem, Factions[listitem][MaxRank]));
        strcat(dialog, str, sizeof(dialog));

	 	format(str, sizeof(str), "Faction Rank Names\n");
        strcat(dialog, str, sizeof(dialog));

        if(Account[playerid][Admin] > 5)
    	{
    		format(str, sizeof(str), "Faction Payouts\n");
        	strcat(dialog, str, sizeof(dialog));
    	}

		Dialog_Show(playerid, FLIST2, DIALOG_STYLE_LIST, "Faction Manager", dialog, "Edit","Cancel");
	}

    return 1;
}

#define MAX_FACTIONTYPES 5
stock GetRankNameFromID(fid, rank)
{
	new query[128], name[64], rankname[64];
	format(rankname, sizeof(rankname), "Rank%d", rank);
    mysql_format(SQL_CONNECTION, query, sizeof(query), "SELECT %s FROM `Factions` WHERE SQLID = %d LIMIT 1", rankname, Factions[fid][SQLID]);
	new Cache:result = mysql_query(SQL_CONNECTION, query);
	cache_get_field_content(0, rankname, name, SQL_CONNECTION, 64);
 	cache_delete(result);
	return name;
}


Dialog:FLIST2(playerid, response, listitem, inputtext[])
{
	if(!response) return SendErrorMessage(playerid, ERROR_DIALOG);
	new dialog[600];
	if(listitem == 0)
    {
		Dialog_Show(playerid, FNAME, DIALOG_STYLE_INPUT, "Faction Manager Name Editor","Enter the new name for this faction:","Change Name","Cancel");
	}
	else if(listitem == 1)
	{
		new str[128];
	 	
		for (new i = 0; i < MAX_FACTIONTYPES; ++i)
		{
			format(str, sizeof(str), "%s\n", FactionTypeName[i][0]);
        	strcat(dialog, str, sizeof(dialog));
		}
        Dialog_Show(playerid, FTYPE, DIALOG_STYLE_LIST, "Faction Manager Type Editor",dialog,"Set Type","Cancel");
	}

	else if(listitem == 2)
	{
        Dialog_Show(playerid, EditCommandRank, DIALOG_STYLE_LIST, "Faction Manager Command Rank Editor",  GetRankList(facid[playerid]),"Set Type","Cancel");
	}
	else if(listitem == 3)
	{
        Dialog_Show(playerid, EditMaxRank, DIALOG_STYLE_LIST, "Faction Manager Command MaxRank Editor",  GetFullRankList(facid[playerid]),"Set Type","Cancel");
	}
	else if(listitem == 4)
	{
		Dialog_Show(playerid, RANK, DIALOG_STYLE_LIST, "Faction Rank Editor",  GetRankList(facid[playerid]), "Select","Cancel");
	}
	else if(listitem == 5)
	{
		Dialog_Show(playerid, RANK, DIALOG_STYLE_LIST, "Faction Pay Editor",  GetRankList(facid[playerid]), "Select","Cancel");
	}
	return 1;
}


stock GetRankList(faccid)
{
	new rank[300], str[128];

	for (new i = 0; i < Factions[faccid][MaxRank]; ++i)
	{
		strcat(str, "%s\n", sizeof(str));
	}

	format(rank, sizeof(rank), str,
						Factions[faccid][Rank1],
						Factions[faccid][Rank2],
						Factions[faccid][Rank3],
						Factions[faccid][Rank4],
						Factions[faccid][Rank5],
						Factions[faccid][Rank6],
						Factions[faccid][Rank7],
						Factions[faccid][Rank8],
						Factions[faccid][Rank9],
						Factions[faccid][Rank10]);
	
	return rank;
}

stock GetFullRankList(faccid)
{
	new rank[300], str[128];

	for (new i = 0; i < 10; ++i)
	{
		strcat(str, "%s\n", sizeof(str));
	}

	format(rank, sizeof(rank), str,
						Factions[faccid][Rank1],
						Factions[faccid][Rank2],
						Factions[faccid][Rank3],
						Factions[faccid][Rank4],
						Factions[faccid][Rank5],
						Factions[faccid][Rank6],
						Factions[faccid][Rank7],
						Factions[faccid][Rank8],
						Factions[faccid][Rank9],
						Factions[faccid][Rank10]);
	
	return rank;
}

Dialog:EditMaxRank(playerid, response, listitem, inputtext[])
{
	if(!response) return SendErrorMessage(playerid, ERROR_DIALOG);
	new str[128];
	Factions[facid[playerid]][MaxRank] = listitem + 1;
	format(str, sizeof(str), "The max rank has sucessfully been changed to %s.", GetRankNameFromID(facid[playerid], listitem + 1));
	SendClientMessage(playerid, COLOR_GREEN, str);
	MYSQL_Update_Interger(Factions[facid[playerid]][SQLID], "Factions", "MaxRank", Factions[facid[playerid]][MaxRank]);

	return 1;
}



Dialog:EditCommandRank(playerid, response, listitem, inputtext[])
{
	if(!response) return SendErrorMessage(playerid, ERROR_DIALOG);
	new str[128];
	Factions[facid[playerid]][CommandRank] = listitem + 1;
	format(str, sizeof(str), "The command rank has sucessfully been changed to %s.", GetRankNameFromID(facid[playerid], listitem + 1));
	SendClientMessage(playerid, COLOR_GREEN, str);
	MYSQL_Update_Interger(Factions[facid[playerid]][SQLID], "Factions", "CommandRank", Factions[facid[playerid]][CommandRank]);
	return 1;
}


Dialog:FCREATE(playerid, response, listitem, inputtext[])
{
	if(!response) return SendErrorMessage(playerid, ERROR_DIALOG);

	new str[128], query[800];
	Total_Factions_Created++;
	format(Factions[Total_Factions_Created][Name], 64, "%s", inputtext);

	format(Factions[Total_Factions_Created][Rank1], 32, "Rank 1 - Lowest");
	format(Factions[Total_Factions_Created][Rank2], 32, "Rank 2");
	format(Factions[Total_Factions_Created][Rank3], 32, "Rank 3");
	format(Factions[Total_Factions_Created][Rank4], 32, "Rank 4");
	format(Factions[Total_Factions_Created][Rank5], 32, "Rank 5");
	format(Factions[Total_Factions_Created][Rank6], 32, "Rank 6");
	format(Factions[Total_Factions_Created][Rank7], 32, "Rank 7");
	format(Factions[Total_Factions_Created][Rank8], 32, "Rank 8 - Leader");
	format(Factions[Total_Factions_Created][Rank9], 32, "Rank 9");
	format(Factions[Total_Factions_Created][Rank10], 32, "Rank 10");

	mysql_format(SQL_CONNECTION, query, sizeof(query), "INSERT INTO `Factions` (Name, Rank1, Rank2, Rank3, Rank4, Rank5, Rank6, Rank7, Rank8, Rank9, Rank10, CommandRank, MaxRank, VaultRank, Vault) VALUES('%e','%e','%e','%e','%e','%e','%e','%e','%e','%e','%e', 7, 8, 7, 20000)",

			Factions[Total_Factions_Created][Name],
			Factions[Total_Factions_Created][Rank1],Factions[Total_Factions_Created][Rank2],
			Factions[Total_Factions_Created][Rank3],Factions[Total_Factions_Created][Rank4],
			Factions[Total_Factions_Created][Rank5],Factions[Total_Factions_Created][Rank6],
			Factions[Total_Factions_Created][Rank7],Factions[Total_Factions_Created][Rank8],
			Factions[Total_Factions_Created][Rank9],Factions[Total_Factions_Created][Rank10]);

	mysql_tquery(SQL_CONNECTION, query);
	Factions[Total_Factions_Created][CommandRank] = 7;
	Factions[Total_Factions_Created][MaxRank] = 8;
	Factions[Total_Factions_Created][VaultRank] = 7;
	Factions[Total_Factions_Created][SQLID] = cache_insert_id();
	Factions[Total_Factions_Created][Vault] = 20000;
	format(str, sizeof(str), "Faction %s(ID:%d) has been created.",Factions[Total_Factions_Created][Name], Factions[Total_Factions_Created][SQLID]);
	SendAdminsMessage(1, COLOR_RED, str);
	Total_Factions_Created ++;

    return 1;
}


Dialog:FNAME(playerid, response, listitem, inputtext[])
{
	if(!response) return SendErrorMessage(playerid, ERROR_DIALOG);
    if(response)
    {
		format(Factions[facid[playerid]][Name], 64, "%s", inputtext);
		new str[128];
		format(str, sizeof(str), "Faction(ID%d) name has been changed to %s.", facid[playerid], Factions[facid[playerid]][Name]);
		SendAdminsMessage(1, COLOR_YELLOW, str);
		MYSQL_Update_String(Factions[facid[playerid]][SQLID], "Factions", "Name", Factions[facid[playerid]][Name]);


	}
    return 1;
}

Dialog:FTYPE(playerid, response, listitem, inputtext[])
{
	if(!response) return SendErrorMessage(playerid, ERROR_DIALOG);
	new str[128], fType = listitem;

	Factions[facid[playerid]][Type] = fType;
	format(str, sizeof(str), "Faction(ID%d) has been changed to type %s.", facid[playerid], FactionTypeName[Factions[facid[playerid]][Type]][0]);
	SendAdminsMessage(1, COLOR_YELLOW, str);
	MYSQL_Update_Interger(Factions[facid[playerid]][SQLID], "Factions", "Type", Factions[facid[playerid]][Type]);

    return 1;
}

//Faction Commands

CMD:editranks(playerid, params[])
{

	if(Character[playerid][Rank] == Factions[GetFactionIDFromSQLID(Character[playerid][Faction])][MaxRank])
	{
        facid[playerid] = GetFactionIDFromSQLID(Character[playerid][Faction]);
		
		Dialog_Show(playerid, RANK, DIALOG_STYLE_LIST, "Faction Rank Editor", GetRankList(facid[playerid]), "Select","Cancel");
	}
	else
	{
	    SendClientMessage(playerid, COLOR_RED, "You have to be the leader of this faction for usage of this command.");
	}
	return 1;
}

stock GetFactionIDFromSQLID(sqlid)
{
	for (new i = 0; i < MAX_FACTIONS; ++i)
	{
		if(Factions[i][SQLID] == sqlid)
		{
			return i;
		}
		else continue;
	}
	return 1;
}

Dialog:RANK(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		new str[128], rid = listitem + 1;
		Character[playerid][NewID] = rid;
		format(str, sizeof(str), "Enter the new rank name:[Rank ID: %d]", Character[playerid][NewID]);
		Dialog_Show(playerid, RANK_SET, DIALOG_STYLE_INPUT, "Faction Rank Editor", str, "Change","Cancel");

	}
	else
	{
	    InfoBoxForPlayer(playerid, "You canceled out the dialog box.");
	}
    return 1;
}

Dialog:RANK_SET(playerid, response, listitem, inputtext[])
{
	if(response)
    {
		new str[8], str2[128];
		format(str, sizeof(str), "Rank%d", Character[playerid][NewID]);

		MYSQL_Update_String(Factions[facid[playerid]][SQLID], "Factions", str, inputtext);

		format(str2, sizeof(str2), "You have successfully updated Rank %d to %s", Character[playerid][NewID], inputtext);
		SendClientMessage(playerid, COLOR_LBLUE, str2);
		//format(Faction[facid[playerid]][Rank1], 32, "%s", inputtext);
		switch(Character[playerid][NewID])
		{
			case 1: format(Factions[facid[playerid]][Rank1], 32, "%s", inputtext);
			case 2: format(Factions[facid[playerid]][Rank2], 32, "%s", inputtext);
			case 3: format(Factions[facid[playerid]][Rank3], 32, "%s", inputtext);
			case 4: format(Factions[facid[playerid]][Rank4], 32, "%s", inputtext);
			case 5: format(Factions[facid[playerid]][Rank5], 32, "%s", inputtext);
			case 6: format(Factions[facid[playerid]][Rank6], 32, "%s", inputtext);
			case 7: format(Factions[facid[playerid]][Rank7], 32, "%s", inputtext);
			case 8: format(Factions[facid[playerid]][Rank8], 32, "%s", inputtext);
			case 9: format(Factions[facid[playerid]][Rank9], 32, "%s", inputtext);
			case 10: format(Factions[facid[playerid]][Rank10], 32, "%s", inputtext);
			

		}

		Dialog_Show(playerid, RANK, DIALOG_STYLE_LIST, "Faction Rank Editor", GetRankList(facid[playerid]), "Select","Cancel");

	}
	else
	{
	    InfoBoxForPlayer(playerid, "You canceled out the dialog box.");
	}
    return 1;
}




CMD:houseinteriors(playerid, params[])
{
	if(Account[playerid][Admin] > 0)
	{
		new str[128], dialog[600];
		for (new i = 0; i < sizeof(HouseInteriorInfo); ++i)
		{
			format(str, sizeof(str), "%s\n", HouseInteriorInfo[i][0]);
	        strcat(dialog, str, sizeof(dialog));
		}

		Dialog_Show(playerid, HOUSEINTERIORS, DIALOG_STYLE_LIST, "House Interiors", dialog, "Teleport","Exit");
	}
	return 1;
}


Dialog:HOUSEINTERIORS(playerid, response, listitem, inputtext[])
{
    if(response)
    {
        SetPlayerPosEx(playerid, HouseInteriorCoords[listitem][0], HouseInteriorCoords[listitem][1], HouseInteriorCoords[listitem][2], HouseInteriorInfo[listitem][1][0], 0);
    }
    return 1;
}




Dialog:BIZINTERIORS(playerid, response, listitem, inputtext[])
{
    if(response)
    {
        SetPlayerPosEx(playerid, BusinessInteriorPos[listitem][0], BusinessInteriorPos[listitem][1], BusinessInteriorPos[listitem][2], BusinessInteriors[listitem][2][0], 0);
    }
    return 1;
}

CMD:bizinteriors(playerid,params[])
{
	if(Account[playerid][Admin] > 0)
	{
		new str[128], dialog[400];
		for (new i = 0; i < sizeof(BusinessInteriors); ++i)
		{
			format(str, sizeof(str), "%s\n", BusinessInteriors[i][1]);
	        strcat(dialog, str, sizeof(dialog));
		}

		Dialog_Show(playerid, BIZINTERIORS, DIALOG_STYLE_LIST, "BusinessInteriors", dialog, "Teleport","Exit");
	}
	return 1;
}

Dialog:BUSINESSMENU(playerid, response, listitem, inputtext[])
{
	if(!response) return SendErrorMessage(playerid, ERROR_DIALOG);
    if(response)
    {
        Create_New_Biz_ID[playerid] = InRangeOfBiz(playerid);
        bizzid[playerid] = Create_New_Biz_ID[playerid];
        switch(listitem)
        {
            case 0: //create business
            {
                Dialog_Show(playerid, CREATEBUSINESS, DIALOG_STYLE_INPUT, "Business Creation","Enter the name of the business you wish\nto create.","Continue","Cancel");
			}
			case 1: //Business name changer
			{
				if(InRangeOfBiz(playerid))
				{
					Dialog_Show(playerid, EDITOR_BIZ_NAME, DIALOG_STYLE_INPUT, "Business Editor","Enter the new business name:","Change Name","Cancel");
				}
				else SendErrorMessage(playerid, ERROR_LOCATION);
			}
			case 2: //Interior Changer
			{
		    	if(InRangeOfBiz(playerid))
			    {
	    			new str[128], dialog[400];
					for (new i = 0; i < sizeof(BusinessInteriors); ++i)
					{
						format(str, sizeof(str), "%s\n", BusinessInteriors[i][1]);
				        strcat(dialog, str, sizeof(dialog));
					}

					Dialog_Show(playerid, CREATEBUSINESS3, DIALOG_STYLE_LIST, "Business Creation - Business Type",dialog,"Create","Cancel");
				}
				else SendErrorMessage(playerid, ERROR_LOCATION);
			}
			case 3: //Business list
			{

			    Dialog_Show(playerid, BIZLIST, DIALOG_STYLE_LIST, "Businesses", "", "Close", "");

			}
		}
	}
    return 1;
}


Dialog:CREATEBUSINESS(playerid, response, listitem, inputtext[])
{
	if(!response) return SendErrorMessage(playerid, ERROR_DIALOG);
    if(response)
    {

		new query[400], Float:pos[3];
		Total_Biz_Created++;

        GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
		mysql_format(SQL_CONNECTION, query, sizeof(query), "INSERT INTO Business (Name,PosX,PosY,PosZ,World,Interior,Owned,Owner,Price,Payout,Type) VALUES('%e', %f, %f, %f, 0, 0, 0, 0, 0, 0, 0)",

										inputtext,
										pos[0],
										pos[1],
										pos[2]);

		mysql_tquery(SQL_CONNECTION, query, "GetBizID", "i", playerid);



		//GetPlayerPos(playerid, Business[Create_New_Biz_ID[playerid]][PosX],Business[Create_New_Biz_ID[playerid]][PosY],Business[Create_New_Biz_ID[playerid]][PosZ]);
		//format(Business[Character[playerid][NewID]][Name], 32, "%s", inputtext);

		Dialog_Show(playerid, CREATEBusiness_2, DIALOG_STYLE_INPUT, "Business Creation", "Enter the price of the business you have created:", "Continue","Cancel");
	}
    return 1;
}


forward GetBizID(playerid);
public GetBizID(playerid)
{
	Create_New_Biz_ID[playerid] = cache_insert_id();
	return 1;
}

Dialog:CREATEBusiness_2(playerid, response, listitem, inputtext[])
{
	if(!response) return SendErrorMessage(playerid, ERROR_DIALOG);
    if(response)
    {

        if(strval(inputtext) > 0 && strval(inputtext) < 5000000)
        {
			Business[Create_New_Biz_ID[playerid]][Price] = strval(inputtext);

			MYSQL_Update_Interger(Create_New_Biz_ID[playerid], "Business", "Price", Business[Create_New_Biz_ID[playerid]][Price]);

			new str[128];
			format(str, sizeof(str), "Price set at: $%d", Business[Create_New_Biz_ID[playerid]][Price]);
			SendClientMessage(playerid, COLOR_GRAY, str);
			Dialog_Show(playerid, CREATEBUSINESS4, DIALOG_STYLE_INPUT, "Business Creation", "Enter the payout of the business you have created:", "Continue","Cancel");
		}
		else
		{
		    Dialog_Show(playerid, CREATEBusiness_2, DIALOG_STYLE_INPUT, "Business Creation", "Enter the price of the business you have created:", "Continue","Cancel");

		}

    }
    return 1;
}

Dialog:CREATEBUSINESS4(playerid, response, listitem, inputtext[])
{
	if(!response) return SendErrorMessage(playerid, ERROR_DIALOG);
    if(response)
    {
		Business[Create_New_Biz_ID[playerid]][Payout] = strval(inputtext);
		MYSQL_Update_Interger(Create_New_Biz_ID[playerid], "Business", "Payout", Business[Create_New_Biz_ID[playerid]][Payout]);


		new str[128];
		format(str, sizeof(str), "Payout set at: $%d", Business[Create_New_Biz_ID[playerid]][Payout]);
		SendClientMessage(playerid, COLOR_GRAY, str);
		Dialog_Show(playerid, CREATEBUSINESS3, DIALOG_STYLE_LIST, "Business Creation - Business Type","[1]Convenience Store\n[2]Ammunation\n[3]News Agency\n[4] Betting Shop\n[5]Clothes Shop(Zip)\n[6]Doughnut Place\n[2]Ammunation 3\n[4]Off Track Betting\n[7]Sex Shop\n[8]Electronic Shop\n[1]Gas Station\n[5]Binco\n[5]Didier Sachs\n[9]Club\n[9]Bar\n[9]Lil Prob Inn\n[6]Jay's Diner\n[6]Grant Diner\n[10]Burger Shot\n[10]Cluckin' Bell","Create","Cancel");
    }
    return 1;
}


Dialog:CREATEBUSINESS3(playerid, response, listitem, inputtext[])
{
    if(response)
    {
        new query[300], str[128];

		Business[Create_New_Biz_ID[playerid]][InteriorX] = BusinessInteriorPos[listitem][0];
		Business[Create_New_Biz_ID[playerid]][InteriorY] = BusinessInteriorPos[listitem][1];
		Business[Create_New_Biz_ID[playerid]][InteriorZ] = BusinessInteriorPos[listitem][2];
		Business[Create_New_Biz_ID[playerid]][World] = Create_New_Biz_ID[playerid];
		Business[Create_New_Biz_ID[playerid]][Interior] = BusinessInteriors[listitem][2][0];
		Business[Create_New_Biz_ID[playerid]][Type] = BusinessInteriors[listitem][0][0];
		mysql_format(SQL_CONNECTION, query, sizeof(query), "UPDATE Business SET Interior = %d, World = %d, Type = %d, InteriorX = %f, InteriorY = %f, InteriorZ = %f WHERE SQLID = %d LIMIT 1", BusinessInteriors[listitem][2][0], Business[Create_New_Biz_ID[playerid]][World], BusinessInteriors[listitem][0][0], BusinessInteriorPos[listitem][0], BusinessInteriorPos[listitem][1], BusinessInteriorPos[listitem][2], Business[Create_New_Biz_ID[playerid]][SQLID]);
		mysql_tquery(SQL_CONNECTION, query);
		format(str, sizeof(str), "%s has created/updated business: %s.", GetRoleplayName(playerid), Business[Create_New_Biz_ID[playerid]][Name]);
		SendAdminsMessage(1, COLOR_ORANGERED, str);
		Reload_Business(Create_New_Biz_ID[playerid]);


    }
    return 1;
}


Dialog:BIZLIST(playerid, response, listitem, inputtext[])
{

    return 1;
}

Dialog:CHANGEBINTERIOR(playerid, response, listitem, inputtext[])
{
	if(!response) return SendErrorMessage(playerid, ERROR_DIALOG);
    if(response)
    {
    	if(InRangeOfBiz(playerid))
	    {
			Create_New_Biz_ID[playerid] = InRangeOfBiz(playerid);
			Dialog_Show(playerid, CREATEBUSINESS3, DIALOG_STYLE_LIST, "Business Creation - Business Type","[1]Convenience Store\n[2]Ammunation\n[3]News Agency\n[4] Betting Shop\n[5]Clothes Shop(Zip)\n[6]Doughnut Place\n[2]Ammunation 3\n[4]Off Track Betting\n[7]Sex Shop\n[8]Electronic Shop\n[1]Gas Station\n[5]Binco\n[5]Didier Sachs\n[9]Club\n[9]Bar\n[9]Lil Prob Inn\n[6]Jay's Diner\n[6]Grant Diner\n[10]Burger Shot\n[10]Cluckin' Bell","Create","Cancel");
		}
	}
    return 1;
}


Dialog:ChangeHouseName(playerid, response, listitem, inputtext[])
{
	if(!response) return SendErrorMessage(playerid, ERROR_DIALOG);
    if(response)
    {
		format(Houses[houseid[playerid]][Name], 64, "%s", inputtext);
		new str[128];
		format(str, sizeof(str), "You have set house %d's name to %s.", houseid[playerid], Houses[houseid[playerid]][Name]);
		SendClientMessage(playerid, COLOR_YELLOW, str);
		MYSQL_Update_String(Houses[houseid[playerid]][SQLID], "Houses", "Name", Houses[houseid[playerid]][Name]);

		Reload_House(houseid[playerid]);
	}
    return 1;
}




CMD:gotopos(playerid,params[])
{
	if(Account[playerid][Admin] > 4)
	{
		new Float:pos[3], int;
	    if(sscanf(params, "fffi", pos[0], pos[1], pos[2], int)) return SendClientMessage(playerid, COLOR_GRAY, "/gotopos [x] [y] [z] [int]");
		{
			SetPlayerPosEx(playerid, pos[0], pos[1], pos[2], int, 0);
			SetPlayerInterior(playerid, int);
		}
	}
	return 1;
}

#define PHONE_NONE 		0
#define PHONE_OFF 		1
#define PHONE_ON 		2
#define PHONE_RINGING 	3
#define PHONE_CONNECTED 4

CMD:phoneinfo(playerid,params[])
{
	if(Inventory[playerid][PhoneStatus] > 0)
	{
		
	    new str[128];
	    format(str, sizeof(str), "Phone Number: %d", Inventory[playerid][PhoneNumber]);
	    SendClientMessage(playerid, COLOR_WHITE, str);
		

	}
	else SendErrorMessage(playerid, ERROR_NOTOWNED);
	
	return 1;
}

CMD:phoneon(playerid,params[])
{
	if(Inventory[playerid][PhoneStatus] > 0)
	{
		if(Inventory[playerid][PhoneStatus] == PHONE_OFF)
		{
		    new str[128];
		    Inventory[playerid][PhoneStatus] = PHONE_ON;
		    format(str, sizeof(str), "* %s presses and holds the power button of the phone. *",GetRoleplayName(playerid));
		    SendClientMessage(playerid, COLOR_RP, str);
			SetPlayerChatBubble(playerid, str, COLOR_RP, 10.0, 5000);
		    SendErrorMessage(playerid, "You have turned your phone on!");
		}
		else SendErrorMessage(playerid, "The phone is already on!");
	}
	else SendErrorMessage(playerid, ERROR_NOTOWNED);
	
	return 1;
}

CMD:phoneoff(playerid,params[])
{
	if(Inventory[playerid][PhoneStatus] > 0)
	{
		if(Inventory[playerid][PhoneStatus] == PHONE_ON)
		{
		    new str[128];
		    Inventory[playerid][PhoneStatus] = PHONE_OFF;
		    format(str, sizeof(str), "* %s presses and holds the power button of the phone. *",GetRoleplayName(playerid));
		    SendClientMessage(playerid, COLOR_RP, str);
			SetPlayerChatBubble(playerid, str, COLOR_RP, 10.0, 5000);
		    SendErrorMessage(playerid, "You have turned your phone off!");
		}
		else SendErrorMessage(playerid, "The phone is already off/in use!");	
	}
	else SendErrorMessage(playerid, ERROR_NOTOWNED);
	return 1;
}


CMD:call(playerid,params[])
{
	if(Inventory[playerid][PhoneStatus] > PHONE_NONE)
	{
		if(Inventory[playerid][PhoneStatus] == PHONE_ON)
		{
		    new number;
		    if(sscanf(params, "d", number)) return SendClientMessage(playerid, COLOR_GRAY, "/call [phone number]");
			{
			    if(number == Inventory[playerid][PhoneNumber]) return SendErrorMessage(playerid, "You cannot call yourself!");
				
				ProcessCall(playerid, number);
			}
		}
		else SendErrorMessage(playerid, "The phone is already off/in use!");
	}
	else SendErrorMessage(playerid, ERROR_NOTOWNED);
	return 1;
}

stock ProcessCall(playerid, number)
{	 
	new str[128];
 	format(str, sizeof(str), "* %s presses a few buttons on his phone before holding it to his ear. *",GetRoleplayName(playerid));
	SendLocalMessage(playerid, str, Range_Short, COLOR_RP, COLOR_RP);
	SetPlayerChatBubble(playerid, str, COLOR_RP, 10.0, 5000);

	if(number == 911)
	{
		SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USECELLPHONE);
		Inventory[playerid][PhoneStatus] = PHONE_CONNECTED;
		Inventory[playerid][PhoneEmergency] = 1;
		SendClientMessage(playerid, COLOR_WHITE, "[Phone] Operator: 911, what emergency service do you require? (Police, Medical, Fire)");
		return 1;
	}
	else
	{
		for(new player; player < MAX_PLAYERS; player++)
		{
		    if(Inventory[player][PhoneNumber] == number)
		    {
		    	if(Inventory[player][PhoneStatus] == PHONE_ON)
	    		{
    				SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USECELLPHONE);

			        Inventory[playerid][PhoneStatus] = PHONE_RINGING;
			        Inventory[player][PhoneStatus] = PHONE_RINGING;
	                Inventory[player][PhoneCaller] = playerid;
	                Inventory[playerid][PhoneCaller] = player;

	               
					format(str, sizeof(str), "* %s phone would begin to ring. *",GetRoleplayName(Inventory[playerid][PhoneCaller]));
					SendLocalMessage(Inventory[playerid][PhoneCaller], str, Range_Short, COLOR_RP, COLOR_RP);
	    			SetPlayerChatBubble(Inventory[playerid][PhoneCaller], "** Ring, ring. **", COLOR_RP, 10.0, 5000);
			        return 1;
		        }
		        else return CutCall(playerid, "The number you've dialed would go straight to voice-mail.");
		    }
		}
	}	
	return CutCall(playerid, "Invalid phone number.");
}

stock CutCall(playerid, msg[128])
{
	SendErrorMessage(playerid, msg);
	Inventory[playerid][PhoneStatus] = PHONE_ON;
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_STOPUSECELLPHONE);

	Inventory[playerid][PhoneStatus] = PHONE_ON;
	Inventory[playerid][PhoneCaller] = INVALID_PLAYER_ID;
	Inventory[playerid][PhoneEmergency] = 0;
	return 1;
}

stock EndCall(playerid)
{
	new str[128];
	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_USECELLPHONE) SetPlayerSpecialAction(playerid, SPECIAL_ACTION_STOPUSECELLPHONE);
	if(GetPlayerSpecialAction(Inventory[playerid][PhoneCaller]) == SPECIAL_ACTION_USECELLPHONE) SetPlayerSpecialAction(Inventory[playerid][PhoneCaller], SPECIAL_ACTION_STOPUSECELLPHONE);

    format(str, sizeof(str), "* %s presses a button on his phone - ending the call. *",GetRoleplayName(playerid));
    SendClientMessage(playerid, COLOR_RP, str);
	SetPlayerChatBubble(playerid, str, COLOR_RP, 10.0, 5000);
	format(str, sizeof(str), "* The phone line would go dead. *");
    SendClientMessage(Inventory[playerid][PhoneCaller], COLOR_RP, str);
    
	Inventory[playerid][PhoneStatus] = PHONE_ON;
	Inventory[playerid][PhoneEmergency] = 0;

	if(Inventory[playerid][PhoneCaller] != INVALID_PLAYER_ID && Inventory[playerid][PhoneCaller] != -1)
	{
		Inventory[Inventory[playerid][PhoneCaller]][PhoneStatus] = PHONE_ON;
		Inventory[Inventory[playerid][PhoneCaller]][PhoneCaller] = INVALID_PLAYER_ID;
		Inventory[playerid][PhoneCaller] = INVALID_PLAYER_ID;
	}

	return 1;
}

CMD:hangup(playerid,params[])
{
	if(Inventory[playerid][PhoneStatus] > PHONE_NONE)
	{
		if(Inventory[playerid][PhoneStatus] > PHONE_ON)
		{
			EndCall(playerid);
		}
		else SendErrorMessage(playerid, "The phone is already off/not in use!");
	}
	else SendErrorMessage(playerid, ERROR_NOTOWNED);
	return 1;
}

CMD:answer(playerid,params[])
{
	if(Inventory[playerid][PhoneStatus] > PHONE_NONE)
	{
		if(Inventory[playerid][PhoneStatus] == PHONE_RINGING)
		{
			new str[128];
			Inventory[playerid][PhoneStatus] = PHONE_CONNECTED;
			Inventory[Inventory[playerid][PhoneCaller]][PhoneStatus] = PHONE_CONNECTED;
			SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USECELLPHONE);
			
            format(str, sizeof(str), "* %s presses a button on his phone - answering the call. *",GetRoleplayName(playerid));
		    SendClientMessage(playerid, COLOR_RP, str);
			SetPlayerChatBubble(playerid, str, COLOR_RP, 10.0, 5000);
		}
		else SendErrorMessage(playerid, "No-one is calling you!");
	}
	else
	{
	    SendErrorMessage(playerid, ERROR_NOTOWNED);
	}
	return 1;
}


Dialog:DINER(playerid, response, listitem, inputtext[])
{
	if(!response) return SendClientMessage(playerid, COLOR_PINK, "* You decided not to buy anything at the checkout. *");
    if(response)
    {
	    switch(listitem)
	    {
	        case 0://-Starters-\n\n Salad \n Garlic Bread \n\n-Main Course-\n Burger \n Chips \n Chicken Nuggets \n Hotdog \n\n-Desserts-\n Icecream \n Brownie
	        {
	            SendClientMessage(playerid, COLOR_ORANGE, "Waiter says: You may not eat the menu, sir!");
	        }
			case 1://
			{
			    SendClientMessage(playerid, COLOR_YELLOW, "Salad");

			}
			case 2://
			{
			    SendClientMessage(playerid, COLOR_YELLOW, "Garlic Bread");

			}
			case 3://
			{
			    SendClientMessage(playerid, COLOR_ORANGE, "Waiter shouts: You may not eat the menu, sir!");

			}
			case 4:
			{
                SendClientMessage(playerid, COLOR_YELLOW, "Burger");
			}
			case 5:
			{
                SendClientMessage(playerid, COLOR_YELLOW, "Chips");
			}
			case 6:
			{
                SendClientMessage(playerid, COLOR_YELLOW, "Chicken Nuggets");
			}
			case 7:
			{
                SendClientMessage(playerid, COLOR_YELLOW, "Hotdog");
			}
			case 8:
			{
                SendClientMessage(playerid, COLOR_ORANGERED, "Waiter says: You may not eat the menu, sir!");
			}
			case 9:
			{
                SendClientMessage(playerid, COLOR_YELLOW, "Icecream");
			}
			case 10:
			{
                SendClientMessage(playerid, COLOR_YELLOW, "Brownie");
			}
		}
	}
    return 1;
}

Dialog:HOUSEMENU(playerid, response, listitem, inputtext[])
{
	if(!response) return SendClientMessage(playerid, COLOR_GRAY, "You closed the dialog.");
    if(response)
    {
        houseid[playerid] = InRangeOfHouse(playerid);
        switch(listitem)
        {
            case 0: //create house
            {
                Dialog_Show(playerid, CREATEHOUSE, DIALOG_STYLE_INPUT, "House Creation","Enter the name of the new house:","Continue","Cancel");
			}
			case 1: //Change House Name
			{
            	if(houseid[playerid] > 0)
				{
					Dialog_Show(playerid, ChangeHouseName, DIALOG_STYLE_INPUT, "House Editor", "Please enter the desired name:", "Continue","Cancel");
				}
				else
				{
                    SendErrorMessage(playerid, "You need to be standing in the house icon you wish to change the name of!");
				}

			}
			case 2: //Interior Changer
			{
				new id = InRangeOfHouse(playerid);
			   	if(id)
			   	{
					Character[playerid][NewID] = id;
					new str[128], dialog[600];
					for (new i = 0; i < sizeof(HouseInteriorInfo); ++i)
					{
						format(str, sizeof(str), "%s\n", HouseInteriorInfo[i][0]);
				        strcat(dialog, str, sizeof(dialog));
					}
					Dialog_Show(playerid, CREATEHOUSE3, DIALOG_STYLE_LIST, "House Interiors", dialog, "Select","Exit");
				}
			}
			case 3: //House List
			{
				//Something
				print("");
			}
		}
	}
    return 1;
}

forward GetHouseID(playerid);
public GetHouseID(playerid)
{
	Character[playerid][NewID] = cache_insert_id();
	Houses[Character[playerid][NewID]][SQLID] = Character[playerid][NewID];
	return 1;
}

Dialog:CREATEHOUSE(playerid, response, listitem, inputtext[])
{
	if(!response) return SendErrorMessage(playerid, ERROR_DIALOG);
    if(response)
    {
		new query[400], Float:pos[3];
		Total_Houses_Created++;
  		GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
		mysql_format(SQL_CONNECTION, query, sizeof(query), "INSERT INTO Houses (Name, PosX, PosY, PosZ, Interior, World, IntX, IntY, IntZ, Owner, Price, Locked, Safe) VALUES('%e',%f,%f,%f,0,0,0,0,0,0,0,0,0)",

                                        inputtext,
										pos[0],
									 	pos[1],
										pos[2]);

		mysql_tquery(SQL_CONNECTION, query, "GetHouseID");

   		Total_Houses_Created++;

		Dialog_Show(playerid, CREATEHOUSE2, DIALOG_STYLE_INPUT, "House Creation", "Enter the purchase price of the house:", "Continue","Cancel");
	}
    return 1;
}

Dialog:CREATEHOUSE2(playerid, response, listitem, inputtext[])
{
	if(!response) return SendErrorMessage(playerid, ERROR_DIALOG);
    if(response)
    {
        if(strval(inputtext) >= 0)
        {
	        new hID = Character[playerid][NewID];
			Houses[hID][Price] = strval(inputtext);

			new str[128], dialog[600];
			for (new i = 0; i < sizeof(HouseInteriorInfo); ++i)
			{
				format(str, sizeof(str), "%s\n", HouseInteriorInfo[i][0]);
		        strcat(dialog, str, sizeof(dialog));
			}
			Dialog_Show(playerid, CREATEHOUSE3, DIALOG_STYLE_LIST, "House Interiors", dialog, "Select","Exit");
		}
		else
		{
			Dialog_Show(playerid, CREATEHOUSE2, DIALOG_STYLE_INPUT, "House Creation", "Enter the purchase price of the house:", "Continue","Cancel");
		}
    }
    return 1;
}

stock WorldFreeIdCheck(hID, id)
{
	new query[200];
	mysql_format(SQL_CONNECTION, query, sizeof(query), "SELECT `World` FROM `Houses` WHERE (`World` = %d) LIMIT 1", id);
 	mysql_tquery(SQL_CONNECTION, query, "OnWorldFreeIdCheck", "dd", hID, id);
	return 1;
}

forward OnWorldFreeIdCheck(hID, id);
public OnWorldFreeIdCheck(hID, id)
{
	if(cache_num_rows())
    {
		Houses[hID][World]++;
		WorldFreeIdCheck(hID, Houses[hID][World]);

	}
	else
	{
		MYSQL_Update_Interger(Houses[hID][SQLID], "Houses", "World", Houses[hID][World]);
		return 1;

	}

	return 1;
}

Dialog:CREATEHOUSE3(playerid, response, listitem, inputtext[])
{
    if(response)
    {
    	new query[300], hID = Character[playerid][NewID];
    	printf("%d", hID);

        Houses[hID][IntX] = HouseInteriorCoords[listitem][0];
        Houses[hID][IntY] = HouseInteriorCoords[listitem][1];
        Houses[hID][IntZ] = HouseInteriorCoords[listitem][2];
        Houses[hID][Interior] = HouseInteriorInfo[listitem][1][0];
   
        
        Houses[hID][World] = Character[playerid][NewID];
        WorldFreeIdCheck(hID, Houses[hID][World]);

		mysql_format(SQL_CONNECTION, query, sizeof(query), "UPDATE Houses SET Interior = %d, IntX = %f, IntY = %f, IntZ = %f, Price = %d WHERE SQLID = %d LIMIT 1", Houses[hID][Interior], Houses[hID][IntX], Houses[hID][IntY], Houses[hID][IntZ], Houses[hID][Price], Houses[hID][SQLID]);
		mysql_tquery(SQL_CONNECTION, query);
		printf("%s", query);
		format(query, sizeof(query), "%s has created/edited house: %s.", GetRoleplayName(playerid), Houses[hID][Name]);
		SendAdminsMessage(1, COLOR_ORANGERED, query);
		Reload_House(hID);

    }
    return 1;
}



CMD:deletefactionvehicle(playerid, params[])
{
	if(Account[playerid][Admin] >= 5)
	{
		if(IsPlayerInAnyVehicle(playerid))
		{
			new vid = GetPlayerVehicleID(playerid), option[24];
			if(sscanf(params, "s[12]", option)) return SendClientMessage(playerid, COLOR_YELLOW, "Are you sure that you want to delete this vehicle? (/deletefv [confirm/decline])");
			{
				if(!strcmp(option, "confirm", true))
				{

					if(Vehicles[vid][Type] == 3)
					{
					    new query[128];
					    SendClientMessage(playerid, COLOR_ORANGERED, "Vehicle deleted!");

					    mysql_format(SQL_CONNECTION, query, sizeof(query), "DELETE FROM `FactionVehicles` WHERE `SQLID` = %d", Vehicles[vid][SQLID]);
						mysql_tquery(SQL_CONNECTION, query);
						validvehicle[vid] = false;
						DestroyVehicle(vid);
						ResetVehicleVariables(vid);
					}
					else
					{
					    SendClientMessage(playerid, COLOR_ORANGERED, "Couldn't complete deletation as this vehicle is not a faction vehicle!");
					}
				}

				if(!strcmp(option, "decline", true))
				{
					SendClientMessage(playerid, COLOR_ORANGERED, "Vehicle deletation process canceled.");
				}
			}
		}
	}
	return 1;
}
ALTCMD:deletefv->deletefactionvehicle;


CMD:deleteservervehicle(playerid, params[])
{
	if(Account[playerid][Admin] >= 6)
	{
		if(IsPlayerInAnyVehicle(playerid))
		{
			new vid = GetPlayerVehicleID(playerid), option[24];
			if(sscanf(params, "s[12]", option)) return SendClientMessage(playerid, COLOR_YELLOW, "Are you sure that you want to delete this vehicle? (/deletesv [confirm/decline])");
			{
				if(!strcmp(option, "confirm", true))
				{

					if(Vehicles[vid][Type] == 2 || Vehicles[vid][Type] == 4)
					{
					    new query[128];
					    SendClientMessage(playerid, COLOR_ORANGERED, "Vehicle deleted!");

					    mysql_format(SQL_CONNECTION, query, sizeof(query), "DELETE FROM `ServerVehicles` WHERE `SQLID` = %d", Vehicles[vid][SQLID]);
						mysql_tquery(SQL_CONNECTION, query);
						validvehicle[vid] = false;
						DestroyVehicle(vid);
						ResetVehicleVariables(vid);
					}
					else
					{
					    SendClientMessage(playerid, COLOR_RED, "Couldn't complete deletation as this vehicle is not a server vehicle!");
					}
				}

				if(!strcmp(option, "decline", true))
				{
					SendClientMessage(playerid, COLOR_RED, "Vehicle deletation process canceled.");
				}
			}
		}
	}
	return 1;
}
ALTCMD:deletesv->deleteservervehicle;

CMD:deleteplayervehicle(playerid, params[])
{
	if(Account[playerid][Admin] >= 5)
	{
		if(IsPlayerInAnyVehicle(playerid))
		{
			new vid = GetPlayerVehicleID(playerid), option[24];
			if(sscanf(params, "s[12]", option)) return SendClientMessage(playerid, COLOR_YELLOW, "Are you sure that you want to delete this vehicle? (/deletepv [confirm/decline])");
			{
				if(!strcmp(option, "confirm", true))
				{

					if(IsPlayerVehicle(vid))
					{
					    new query[128];
					    SendClientMessage(playerid, COLOR_ORANGERED, "Vehicle deleted!");

					    mysql_format(SQL_CONNECTION, query, sizeof(query), "DELETE FROM `PlayerVehicles` WHERE `SQLID` = %d", Vehicles[vid][SQLID]);
						mysql_tquery(SQL_CONNECTION, query);
						validvehicle[vid] = false;
						DestroyVehicle(vid);
						ResetVehicleVariables(vid);
					}
				}

				if(!strcmp(option, "decline", true))
				{
					SendClientMessage(playerid, COLOR_RED, "Vehicle deletation process canceled.");
				}
			}
		}
	}
	return 1;
}
ALTCMD:deletepv->deleteplayervehicle;


CMD:scrapcar(playerid, params[])
{
	new vid = GetPlayerVehicleID(playerid);
	if(IsPlayerInAnyVehicle(playerid))
	{
	    if(InRangeOfIcon(playerid, 9))
	    {
			if(IsPlayerVehicleOwner(playerid, vid))
			{
			    new query[128];
			    GivePlayerMoneyEx(playerid, 5000);
			    SendClientMessage(playerid, COLOR_WHITE, "Grimy Scrap Dealer says: Thank you for selling your vehicle for scrap metal.");


			    mysql_format(SQL_CONNECTION, query, sizeof(query), "DELETE FROM `PlayerVehicles` WHERE `SQLID` = %d", Vehicles[vid][SQLID]);
				mysql_tquery(SQL_CONNECTION, query);
				Character[playerid][TotalVehicles] --;


				validvehicle[vid] = false;
				DestroyVehicle(vid);
				ResetVehicleVariables(vid);
			}
		}
	}
	return 1;
}

CMD:buyvehicle(playerid,params[])
{
    if(InRangeOfIcon(playerid, 1) == 1)
	{
		ShowVehicleDialog(playerid);
	}
    else if(InRangeOfIcon(playerid, 3) == 1)
	{
		ShowVehicleDialog2(playerid);
	}
	return 1;
}




stock GetTabulators(str[])   // -> Empty Slot
{
    new x = strlen(str);  // -> 10
    x = floatround((x/8), floatround_floor); // -> 1
    new Tabs[20];
    for(new i = x; i < 5; i++) // 5 = Max tabulators  // -> 4 x "\t"
    {
          format(Tabs, 20, "%s\t", Tabs);
    }
    if(x == 0) format(Tabs, 20, "\t\t\t\t");
    return Tabs;
}

stock ShowVehicleDialog(playerid)
{
 	new DialogText[2000], MainDialog[1000];
	for ( new i = 0; i < sizeof(DealershipData_Normal); i++ )
    {
		new model = DealershipData_Normal[i][0];
		new price = DealershipData_Normal[i][1];
		new strLength = strlen(VehicleNames[model-400]);
		if(model == 418)
		{
			format(DialogText,sizeof(DialogText),"%s %s(%d) \t "COL_DGREEN"$%s\n", DialogText, VehicleNames[model-400], model, FormatNumber(price));
			strcat(MainDialog, DialogText, sizeof(MainDialog));
		}
		if(model == 404)
		{
			format(DialogText,sizeof(DialogText),"%s %s(%d) \t\t "COL_DGREEN"$%s\n", DialogText, VehicleNames[model-400], model, FormatNumber(price));
			strcat(MainDialog, DialogText, sizeof(MainDialog));
		}
		if(strLength <= 8 && model != 418)
		{
			format(DialogText,sizeof(DialogText),"%s %s(%d)\t\t "COL_DGREEN"$%s\n", DialogText, VehicleNames[model-400], model, FormatNumber(price));
			strcat(MainDialog, DialogText, sizeof(MainDialog));
		}
		if(strLength > 8 && model != 404)
		{
			format(DialogText,sizeof(DialogText),"%s %s(%d) \t "COL_DGREEN"$%s\n", DialogText, VehicleNames[model-400], model, FormatNumber(price));
			strcat(MainDialog, DialogText, sizeof(MainDialog));
		}

	}
	Dialog_Show(playerid, VEHICLELIST, DIALOG_STYLE_LIST, "Vehicle Dialog", DialogText,"Select","Exit");
	return 1;
}



Dialog:VEHICLELIST(playerid, response, listitem, inputtext[])
{
    if(!response) return 0;
	if(response)
    {
		if(Character[playerid][Cash] < DealershipData_Normal[listitem][1]) return SendClientMessage(playerid,COLOR_GRAY, ERROR_MONEY);
		{
   			new ConfirmationMessage[128], name[MAX_PLAYER_NAME+1];
			VehicleModel[playerid] = DealershipData_Normal[listitem][0];
			VehiclePrice[playerid] = DealershipData_Normal[listitem][1];

			TogglePlayerControllable(playerid, false);

			SetPlayerCameraPos(playerid, 95.5539, 1045.3966, 14.0215);

			SetPlayerCameraLookAt(playerid, 94.5747, 1045.5946, 13.7615);

			Character[playerid][Dealership] = CreateVehicle(VehicleModel[playerid],84.7893,1048.24,13.6436,229.316,1,2, -1);
            GetPlayerName(playerid, name, sizeof(name));
			SetVehicleVirtualWorld(Character[playerid][Dealership], GetPlayerID(name) + 1000);
			SetPlayerVirtualWorld(playerid, GetPlayerID(name) + 1000);

			format(ConfirmationMessage, sizeof(ConfirmationMessage), "Are you sure that you want to buy a "COL_DGREEN"%s "COL_WHITE"for "COL_DGREEN"$%s"COL_WHITE"?", VehicleNames[DealershipData_Normal[listitem][0]-400], FormatNumber(VehiclePrice[playerid]));
			Dialog_Show(playerid, VEHICLE_CONFIRM, DIALOG_STYLE_MSGBOX, "Vehicle Purchase Confirmation", ConfirmationMessage,"Confirm","Back");


		}
   	}
 	return 1;
}

Dialog:VEHICLE_CONFIRM(playerid, response, listitem, inputtext[])
{
    if(!response)
	{
		SetPlayerVirtualWorld(playerid, 0);
		SetCameraBehindPlayer(playerid);
		TogglePlayerControllable(playerid, true);
		DestroyVehicle(Character[playerid][Dealership]);
		ShowVehicleDialog(playerid);
		return 0;
	}
	else if(Character[playerid][TotalVehicles] >= 3)
	{
		SetPlayerVirtualWorld(playerid, 0);
		SetCameraBehindPlayer(playerid);
		TogglePlayerControllable(playerid, true);
		DestroyVehicle(Character[playerid][Dealership]);
		SendClientMessage(playerid, COLOR_GRAY, "[ERR--] Too many owned vehicles");
		ShowVehicleDialog(playerid);
	    return 0;
	}
	new str[8], str2[128], query[400];

    GivePlayerMoneyEx(playerid, -VehiclePrice[playerid]);

    new Vehicle = CreateVehicle(VehicleModel[playerid], 114.1409, 1066.5261, 13.3817, 269.8916, 0, 0, -1);

    Vehicles[Vehicle][Model] = VehicleModel[playerid];
    Vehicles[Vehicle][PosX] = 114.1409;
    Vehicles[Vehicle][PosY] = 1066.5261;
    Vehicles[Vehicle][PosZ] = 13.3817;
    Vehicles[Vehicle][PosA] = 269.8916;
    Vehicles[Vehicle][Owner] = Character[playerid][ID];
    Vehicles[Vehicle][Type] = 1;
    Vehicles[Vehicle][Fuel] = 100;
    Lights[Vehicle] = 0;
    Character[playerid][TotalVehicles]++;


    format(str, sizeof(str), "%s%s%d%d%s%s%s", LetterList[random(sizeof(LetterList))], LetterList[random(sizeof(LetterList))], random(9), random(9), LetterList[random(sizeof(LetterList))], LetterList[random(sizeof(LetterList))], LetterList[random(sizeof(LetterList))]);
	SetVehicleNumberPlate(Vehicle, str);

    format(Vehicles[Vehicle][Plate], 11, "%s", str);
    validvehicle[Vehicle] = true;
	Total_Vehicles_Created++;

	format(str2, sizeof(str2), "Salesman says: Thank you for purchasing a %s here at Wang Autos, your band new vehicle is out front - enjoy.", VehicleNames[Vehicles[Vehicle][Model]-400]);
	SendClientMessage(playerid, COLOR_WHITE, str2);

	SetPlayerVirtualWorld(playerid, 0);
	SetCameraBehindPlayer(playerid);
	TogglePlayerControllable(playerid, true);
	DestroyVehicle(Character[playerid][Dealership]);

	mysql_format(SQL_CONNECTION, query, sizeof(query), "INSERT INTO `PlayerVehicles` (Model, PosX, PosY, PosZ, PosA, Color1, Color2, Type, Plate, Owner, Fuel, Damage) VALUES(%d, %f, %f, %f, %f, 0, 0, 1, '%e', '%d', 100, 1000.0)",

                        Vehicles[Vehicle][Model],
                        Vehicles[Vehicle][PosX],
                        Vehicles[Vehicle][PosY],
                        Vehicles[Vehicle][PosZ],
                        Vehicles[Vehicle][PosA],
						Vehicles[Vehicle][Plate],
						Vehicles[Vehicle][Owner]);

	mysql_tquery(SQL_CONNECTION, query, "VehicleInsertID", "i", Vehicle);
	//Dialog_Show(playerid, VEHICLE_COLOR, DIALOG_STYLE_LIST, "Vehicle Dialog", "Black\nWhite\nBlue\nRed\nDark Green\nPink\nYellow\nSilver","Select","Finish");

    return 1;
}

/*Dialog:VEHICLE_COLOR(playerid, response, listitem, inputtext[])
{
    if(!response)
	{
		SetPlayerVirtualWorld(playerid, 0);
		SetCameraBehindPlayer(playerid);
		TogglePlayerControllable(playerid, true);
		DestroyVehicle(Character[playerid][Dealership]);
		return 1;
	}
	new query[128];
	ChangeVehicleColor(Character[playerid][Dealership],listitem,listitem);
	ChangeVehicleColor(Character[playerid][NewVehicle],listitem,listitem);
	mysql_format(SQL_CONNECTION, query, sizeof(query), "UPDATE PlayerVehicles SET Color1 = %d, Color2 = %d WHERE SQLID = %d LIMIT 1",listitem,listitem,Character[playerid][NewVehicle]);
	mysql_tquery(SQL_CONNECTION, query);throat 
	Dialog_Show(playerid, VEHICLE_COLOR, DIALOG_STYLE_LIST, "Vehicle Dialog", "Black\nWhite\nBlue\nRed\nDark Green\nPink\nYellow\nSilver","Select","Finish");
	return 1;
}*/


stock ShowVehicleDialog2(playerid)
{
	new DialogText[2000], MainDialog[1000];
	for ( new i = 0; i < sizeof(DealershipData_Commercial); i++ )
    {
		new model = DealershipData_Commercial[i][0];
		new price = DealershipData_Commercial[i][1];
		new capacity = DealershipData_Commercial[i][2];
		//new strLength = strlen(VehicleNames[model-400]);

		format(DialogText,sizeof(DialogText),"%s %s(%d) \t "COL_DGREEN"$%d "COL_WHITE"Capacity: %d boxes\n", DialogText, VehicleNames[model-400], model, price, capacity);
		strcat(MainDialog, DialogText, sizeof(MainDialog));

	}
	Dialog_Show(playerid, VEHICLELIST2, DIALOG_STYLE_LIST, "Vehicle Dialog", DialogText,"Select","Exit");
	return 1;
}

Dialog:VEHICLELIST2(playerid, response, listitem, inputtext[])
{
    if(!response) return 0;
	if(response)
    {
		if(Character[playerid][Cash] < DealershipData_Commercial[listitem][1]) return SendClientMessage(playerid,COLOR_GRAY, ERROR_MONEY);
		{
   			new ConfirmationMessage[128];
			VehicleModel[playerid] = DealershipData_Commercial[listitem][0];
			VehiclePrice[playerid] = DealershipData_Commercial[listitem][1];

			TogglePlayerControllable(playerid, false);
			
			Character[playerid][Dealership] = CreateVehicle(VehicleModel[playerid], -138.3560, 1082.1108, 20.1789, 358.3029,1,2, -1);
			SetPlayerCameraPos(playerid, -145.4871, 1094.8253, 22.6712);
			SetPlayerCameraLookAt(playerid, -144.8873, 1094.0190, 22.2362);
			SetVehicleVirtualWorld(Character[playerid][Dealership], playerid + 1000);
			SetPlayerVirtualWorld(playerid, playerid + 1000);

			format(ConfirmationMessage, sizeof(ConfirmationMessage), "Are you sure that you want to buy a "COL_DGREEN"%s "COL_WHITE"for "COL_DGREEN"$%d"COL_WHITE"?", VehicleNames[DealershipData_Commercial[listitem][0]-400], VehiclePrice[playerid]);
			Dialog_Show(playerid, VEHICLE_CONFIRM2, DIALOG_STYLE_MSGBOX, "Vehicle Purchase Confirmation", ConfirmationMessage,"Confirm","Back");


		}
   	}
 	return 1;
}

Dialog:VEHICLE_CONFIRM2(playerid, response, listitem, inputtext[])
{
    if(!response)
	{
		SetPlayerVirtualWorld(playerid, 0);
		SetCameraBehindPlayer(playerid);
		TogglePlayerControllable(playerid, true);
		DestroyVehicle(Character[playerid][Dealership]);
		ShowVehicleDialog2(playerid);
		return 0;
	}
	else if(Character[playerid][TotalVehicles] >= 3)
	{
		SetPlayerVirtualWorld(playerid, 0);
		SetCameraBehindPlayer(playerid);
		TogglePlayerControllable(playerid, true);
		DestroyVehicle(Character[playerid][Dealership]);
		SendClientMessage(playerid, COLOR_GRAY, "[ERROR] Too many owned vehicles");
		ShowVehicleDialog2(playerid);
	    return 0;
	}
	new str[8], str2[128], query[400];

    GivePlayerMoneyEx(playerid, -VehiclePrice[playerid]);

    new Vehicle = CreateVehicle(VehicleModel[playerid], -138.3560, 1082.1108, 19.5789, 358.3029, 0, 0, -1);

    Vehicles[Vehicle][Model] = VehicleModel[playerid];
    Vehicles[Vehicle][PosX] = -138.3560;
    Vehicles[Vehicle][PosY] = 1082.1108;
    Vehicles[Vehicle][PosZ] = 19.5789;
    Vehicles[Vehicle][PosA] = 358.3029;
    Vehicles[Vehicle][Owner] = Character[playerid][ID];
    Vehicles[Vehicle][Type] = 1;
    Vehicles[Vehicle][Fuel] = 100;
    Lights[Vehicle] = 0;
    Character[playerid][TotalVehicles]++;


    format(str, sizeof(str), "%s%s%d%d%s%s%s", LetterList[random(sizeof(LetterList))], LetterList[random(sizeof(LetterList))], random(9), random(9), LetterList[random(sizeof(LetterList))], LetterList[random(sizeof(LetterList))], LetterList[random(sizeof(LetterList))]);
	SetVehicleNumberPlate(Vehicle, str);

    format(Vehicles[Vehicle][Plate], 11, "%s", str);
    validvehicle[Vehicle] = true;
	Total_Vehicles_Created++;

	format(str2, sizeof(str2), "Salesman_Parker says: Thank you for purchasing a (%d) here at Commercial Autos, your band new commercial vehicle is out front - enjoy.", Vehicles[Vehicle][Model]);
	SendClientMessage(playerid, COLOR_WHITE, str2);

	SetPlayerVirtualWorld(playerid, 0);
	SetCameraBehindPlayer(playerid);
	TogglePlayerControllable(playerid, true);
	DestroyVehicle(Character[playerid][Dealership]);

	mysql_format(SQL_CONNECTION, query, sizeof(query), "INSERT INTO `PlayerVehicles` (Model, PosX, PosY, PosZ, PosA, Color1, Color2, Type, Plate, Owner, Fuel, Damage) VALUES(%d, %f, %f, %f, %f, 0, 0, 1, '%e', '%d', 100, 1000.0)",

                        Vehicles[Vehicle][Model],
                        Vehicles[Vehicle][PosX],
                        Vehicles[Vehicle][PosY],
                        Vehicles[Vehicle][PosZ],
                        Vehicles[Vehicle][PosA],
						Vehicles[Vehicle][Plate],
						Vehicles[Vehicle][Owner]);

	mysql_tquery(SQL_CONNECTION, query, "VehicleInsertID", "i", Vehicle);
	//Dialog_Show(playerid, VEHICLE_COLOR, DIALOG_STYLE_LIST, "Vehicle Dialog", "Black\nWhite\nBlue\nRed\nDark Green\nPink\nYellow\nSilver","Select","Finish");

    return 1;
}

CMD:iconmanager(playerid, params[])
{
	if(Account[playerid][Admin] >= 5)
	{
		Dialog_Show(playerid, ICONMENU, DIALOG_STYLE_LIST, "Icon System", "Create Icon\nChange Type\nEdit Label\nChange Icon", "Select","Cancel");
	}
	else
	{
	    SendErrorMessage(playerid, ERROR_ADMIN);
	}
	return 1;
}


CMD:iconinfo(playerid,params[])
{
	if(Account[playerid][Admin] >= 1)
	{
		if(InRangeOfAnyIcon(playerid) > 0)
		{
		    new str[128], id = InRangeOfIconID(playerid);
            format(str, sizeof(str), "Icon Type: %d SQLID: %d", Icons[id][Type], Icons[id][SQLID]);
		    Dialog_Show(playerid,BANK_BALANCE,DIALOG_STYLE_MSGBOX,"Business Information",str,"Close","");
		}
		else
		{

		}
	}
	return 1;
}

stock Icon_List_Creation(playerid)
{
    Dialog_Show(playerid, IconCreation, DIALOG_STYLE_LIST, "Icon System","Please select the icon you wish to create:\nInformation(1239)\nHeart(1239)\nArmour(1242)\nBlue House(1272)\nGreen House(1273)\nCash(1212)\nAdrenaline(1241)\nStar(1247)\n\nBomb(1252)\nFilm(1253)\nSkull(1254)\nDollar Sign(1274)\nBlue Clothes(1275)\nDuel Skulls(1131)\nSave Floppy Disk(1277)\nRed 2 Player Icon(1314)\nTiki Statue(1276)\nParachute(1310)\nWhite Down Arrow(1318)\nDrug Bundle(1279)","Select","Cancel");
	return 1;
}

stock Icon_List_Type(playerid)
{
  	Dialog_Show(playerid, IconType, DIALOG_STYLE_LIST, "Icon System","Please select the icon type:\nRegular Vehicle Dealership\nFast Vehicle Dealership\nCommercial Dealership\nPayDay\nBank\nATM\nPay Phone\nNothing\nScrap Dealer\nSpray Garage\nRepair Garage\nDMV\nFaction Locker\nVehicle Mod Garage\nWeapon Cache","Select","Cancel");
    return 1;
}


stock Icon_Label_Change(playerid)
{
  	Dialog_Show(playerid, IconText, DIALOG_STYLE_INPUT, "Icon System", "Enter the new text for this icon:","Confirm","Cancel");
    return 1;
}

stock Icon_Change(playerid)
{
  	Dialog_Show(playerid, IconChange, DIALOG_STYLE_LIST, "Icon System","Select a new icon:\nInformation(1239)\nHeart(1239)\nArmour(1242)\nBlue House(1272)\nGreen House(1273)\nCash(1212)\nAdrenaline(1241)\nStar(1247)\n\nBomb(1252)\nFilm(1253)\nSkull(1254)\nDollar Sign(1274)\nBlue Clothes(1275)\nDuel Skulls(1131)\nSave Floppy Disk(1277)\nRed 2 Player Icon(1314)\nTiki Statue(1276)\nParachute(1310)\nWhite Down Arrow(1318)\nDrug Bundle(1279)","Select","Cancel");
	return 1;
}


stock InRangeOfIconID(playerid)
{
	for(new id = 0; id < MAX_ICONS; id++)
	{
		if(IsPlayerInRangeOfPoint(playerid, 4.0, Icons[id][PosX], Icons[id][PosY], Icons[id][PosZ]))
		{
		    return id;
		}

	}
	return -1;
}

Dialog:ICONMENU(playerid, response, listitem, inputtext[])
{
	if(!response) { SendErrorMessage(playerid, ERROR_DIALOG); }
    if(response)
    {
    	new iID = InRangeOfAnyIcon(playerid);
        if(listitem == 0)
    	{
			Icon_List_Creation(playerid);
    	}

        else if(listitem == 1)
    	{
			if(iID != 0)
			{
				IconID = InRangeOfIconID(playerid);
				Icon_List_Type(playerid);
			}
    	}       

    	else if(listitem == 2)
    	{
			if(iID != 0)
			{
				IconID = InRangeOfIconID(playerid);
				Icon_Label_Change(playerid);
			}
    	} 

    	else if(listitem == 3)
    	{
			if(iID != 0)
			{
				IconID = InRangeOfIconID(playerid);
				Icon_Change(playerid);
			}
    	} 


		else Dialog_Show(playerid, ICONMENU, DIALOG_STYLE_LIST, "Icon System", "Create Icon\nEdit Type\nEdit Label", "Select","Cancel");
	}
    return 1;
}

Dialog:IconCreation(playerid, response, listitem, inputtext[])
{
    if(!response) return SendErrorMessage(playerid, ERROR_DIALOG);

    new modelid[6], query[400], Float:pos[3];

    strmid(modelid, inputtext, strfind(inputtext, "(") + 1,  strfind(inputtext, ")"));

    if(listitem == 0)
    {
		Icon_List_Creation(playerid);
		return 1;
	}

	GetPlayerPos(playerid, pos[0], pos[1], pos[2]);

	IconID = Total_Icons_Created ++;

	mysql_format(SQL_CONNECTION, query, sizeof(query), "INSERT INTO Icons (PosX,PosY,PosZ,World,Interior,Type,Faction,Icon) VALUES(%f, %f, %f, %d, %d, 0, 0, %d)",

									pos[0],
									pos[1],
									pos[2],
									GetPlayerVirtualWorld(playerid),
									GetPlayerInterior(playerid),
									strval(modelid));

	mysql_tquery(SQL_CONNECTION, query, "GetIconID");


	Icons[IconID][PosX] = pos[0];
	Icons[IconID][PosY] = pos[1];
	Icons[IconID][PosZ] = pos[2];
	Icons[IconID][Interior] = GetPlayerInterior(playerid);
	Icons[IconID][World] = GetPlayerVirtualWorld(playerid);
	Icons[IconID][Icon] = strval(modelid);					

	Icon_List_Type(playerid);
	return 1;
}

forward GetIconID();
public GetIconID()
{
	Icons[IconID][SQLID] = cache_insert_id();
	return 1;
}

Dialog:IconType(playerid, response, listitem, inputtext[])
{
    if(!response) return SendErrorMessage(playerid, ERROR_DIALOG);

    if(listitem == 0)
    {
		Icon_List_Type(playerid);   
    }
    else
    {
            Icons[IconID][Type] = listitem;
            Icon_Set_Type(listitem);
            InfoBoxForPlayer(playerid, "You have successfully created/edited an ~g~ICON~w~!");
    }
    return 1;
}


stock Icon_Set_Type(type)
{
	MYSQL_Update_Interger(Icons[IconID][SQLID], "Icons", "Type", type);
	ReloadIcon(IconID);
	return 1;
}

Dialog:IconText(playerid, response, listitem, inputtext[])
{
    if(!response) return SendErrorMessage(playerid, ERROR_DIALOG);
    Icon_Set_Text(inputtext);
    SendClientMessage(playerid, COLOR_LGREEN, "Icon updated.");
    
    return 1;
}


stock Icon_Set_Text(txt[])
{
	MYSQL_Update_String(Icons[IconID][SQLID], "Icons", "Name", txt);
	ReloadIcon(IconID);
	return 1;
}

Dialog:IconChange(playerid, response, listitem, inputtext[])
{
    if(!response) return SendErrorMessage(playerid, ERROR_DIALOG);

 	new modelid[6];
    strmid(modelid, inputtext, strfind(inputtext, "(") + 1,  strfind(inputtext, ")"));

    if(listitem == 0)
    {
		Icon_Change(playerid);
		return 1;
	}
	MYSQL_Update_Interger(Icons[IconID][SQLID], "Icons", "Icon", strval(modelid));
	ReloadIcon(IconID);
    return 1;
}



CMD:changeuniform(playerid,params[])
{
	if(Character[playerid][Faction] > 0)
	{
		if(Character[playerid][Uniform] != 0 || Character[playerid][Uniform] != Character[playerid][Skin])
		{
			SetPlayerSkin(playerid, Character[playerid][Uniform]);
		}
		else SendErrorMessage(playerid, "Uniform not set.");
	}
	return 1;
}

CMD:locker(playerid,params[])
{
	if(Character[playerid][Faction] > 0)
	{
		new id = InRangeOfIconID(playerid);
		if(id > 0 && Icons[id][Faction] == Character[playerid][Faction] && Icons[id][Type] == 13)
		{
		    Locker_Main(playerid);
		}
		else SendErrorMessage(playerid, ERROR_LOCATION);
	}
	return 1;
}

stock Locker_Main(playerid)
{
    Dialog_Show(playerid, LockerMain, DIALOG_STYLE_LIST, "Locker - Main Menu","Toggle Duty\nUniform\nEquipment","Select","Cancel");
	return 1;
}

stock Locker_Uniform(playerid)
{
	if(IsLawEnforcement(playerid))
	{
    	Dialog_Show(playerid, LockerUniform, DIALOG_STYLE_LIST, "Locker - Uniform","Black Uniform - White\nBlack Uniform - White 2\nBeige Uniform - White\nBlack & Beige Uniform - White\nBeige & Black Uniform - White\nBiking Uniform\nSWAT Uniform\nBlack Uniform - Black\nBlack Uniform - Hispanic\n","Select","Cancel");
	}
	else if(Character[playerid][Faction] == 3)
	{
		Dialog_Show(playerid, LockerUniform, DIALOG_STYLE_LIST, "Locker - Uniform", "Fire 1\nFire 2\nFire 3\n \nParamedic 1\nParamedic 2\nParamedic 3", "Select", "Cancel");
	}	
	return 1;
}

stock Locker_Equipment(playerid)
{
	if(IsLawEnforcement(playerid))
	{
    	Dialog_Show(playerid, LockerEquipment, DIALOG_STYLE_LIST, "Locker - Equipment","Baton\nKevlar Vest\nPepper Spray\nService Pistol","Select","Cancel");		
	}
	else if(Character[playerid][Faction] == 3)
	{
		Dialog_Show(playerid, LockerEquipment, DIALOG_STYLE_LIST, "Locker - Equipment","Extinguisher","Select","Cancel");
	}

	return 1;
}

Dialog:LockerMain(playerid, response, listitem, inputtext[])
{
	if(!response) return 0;
	if(listitem == 0)
	{
		new str[128];
		if(Character[playerid][Duty] == 0)
		{
			Character[playerid][Duty] = 1;
			format(str, sizeof(str), "[INFO] %s has gone on duty!", GetRoleplayName(playerid));
			SendFactionMessage(Character[playerid][Faction], COLOR_GRAY, str);
		}
		else if(Character[playerid][Duty] == 1)
		{
			Character[playerid][Duty] = 0;
			format(str, sizeof(str), "[INFO] %s has gone off duty!", GetRoleplayName(playerid));
			SendFactionMessage(Character[playerid][Faction], COLOR_GRAY, str);
		}
	}
	else if(listitem == 1)
	{
		Locker_Uniform(playerid);
	}
	else if(listitem == 2)
	{
		Locker_Equipment(playerid);
	}
    return 1;
}

SetPlayerSkinEx(playerid, skinid)
{
	SetPlayerSkin(playerid, skinid);
	Character[playerid][Skin] = skinid;
	return 1;
}

Dialog:LockerUniform(playerid, response, listitem, inputtext[])
{
	if(!response) Locker_Main(playerid);
	if(IsLawEnforcement(playerid))
	{
		if(listitem == 0) SetPlayerSkin(playerid, 280);

		else if(listitem == 1) SetPlayerSkin(playerid, 281);
		
		else if(listitem == 2) SetPlayerSkin(playerid, 282);
		
		else if(listitem == 3) SetPlayerSkin(playerid, 283);

		else if(listitem == 4) SetPlayerSkin(playerid, 288);

		else if(listitem == 5) SetPlayerSkin(playerid, 284);

		else if(listitem == 6) SetPlayerSkin(playerid, 285);

		else if(listitem == 7) SetPlayerSkin(playerid, 265);

		else if(listitem == 8) SetPlayerSkin(playerid, 267);
	}

	else if(Character[playerid][Faction] == 3)
	{
		if(listitem == 0) SetPlayerSkin(playerid, 277);

		else if(listitem == 1) SetPlayerSkin(playerid, 278);
		
		else if(listitem == 2) SetPlayerSkin(playerid, 279);
		
		else if(listitem == 4) SetPlayerSkin(playerid, 274);

		else if(listitem == 5) SetPlayerSkin(playerid, 275);

		else if(listitem == 6) SetPlayerSkin(playerid, 276);
	}
	Character[playerid][Uniform] = GetPlayerSkin(playerid);
    return 1;
}


Dialog:LockerEquipment(playerid, response, listitem, inputtext[])
{
	if(!response) Locker_Main(playerid);
	if(IsLawEnforcement(playerid))
	{
		if(listitem == 0) GivePlayerGun(playerid, 3, 1);

		else if(listitem == 1) SetPlayerArmour(playerid, 100.0);
		
		else if(listitem == 2) GivePlayerGun(playerid, 41, 35);
		
		else if(listitem == 3) GivePlayerGun(playerid, 24, 35);
	}

	else if(Character[playerid][Faction] == 3)
	{
		if(listitem == 0)
		{
			GivePlayerGun(playerid, 42, 100);
		}
	}
    return 1;
}



CMD:weaponcache(playerid,params[])
{
	if(Character[playerid][Faction] > 0)
	{
		new id = InRangeOfIconID(playerid);
		if(id > 0 && Icons[id][Faction] == Character[playerid][Faction] && Icons[id][Type] == 15 && Icons[id][Faction] == Character[playerid][Faction])
		{
	    	FWeapons_Main(playerid);
		}
		else SendErrorMessage(playerid, ERROR_LOCATION);
	}
	return 1;
}

stock FWeapons_Main(playerid)
{
	new str[600], query[200];
	
	if(Character[playerid][Faction] == 1)
	{
		strcat(str, "Purchase Weapons\n");
	}
	mysql_format(SQL_CONNECTION, query, sizeof(query), "SELECT SQLID, Weapon, Ammo FROM `FactionWeapons` WHERE Faction = %d AND Status = 1", Character[playerid][Faction]);
	new Cache:result = mysql_query(SQL_CONNECTION, query);

	for(new i=0; i<cache_num_rows(); i++)
	{
		format(str, sizeof(str), "%sWeapon(#%d) %s(Ammo:%d)  \n", str, cache_get_field_content_int(i, "SQLID", SQL_CONNECTION), WeaponNameList[cache_get_field_content_int(i, "Weapon", SQL_CONNECTION)], cache_get_field_content_int(i, "Ammo", SQL_CONNECTION));
	}

 	cache_delete(result);

	Dialog_Show(playerid, FWeaponsMain, DIALOG_STYLE_LIST, "Faction Weapons", str, "Select", "Close");
	return 1;
}


stock FWeapons_Buy(playerid)
{
    Dialog_Show(playerid, FWeaponsBuy, DIALOG_STYLE_LIST, "Locker - Main Menu","Shotgun($1500)\nMP5($2200)\nCombat Shotgun($4000)\nM4($7000)\nSniper($12000)","Select","Cancel");
	return 1;
}


Dialog:FWeaponsMain(playerid, response, listitem, inputtext[])
{
	if(!response) return 1;
	if(Character[playerid][Faction] == 1)
	{
		if(listitem == 0)
		{
			FWeapons_Buy(playerid);
			return 1;
		}
	}

	new WeapSQLID[4], query[150], str[64];
    strmid(WeapSQLID, inputtext, strfind(inputtext, "#") + 1,  strfind(inputtext, ")"));

	mysql_format(SQL_CONNECTION, query, sizeof(query), "SELECT Weapon, Ammo FROM `FactionWeapons` WHERE SQLID = %d AND Status = 1", strval(WeapSQLID));
	new Cache:result = mysql_query(SQL_CONNECTION, query);

	if(cache_num_rows())
	{
		new w, a;
		new Weap = cache_get_field_content_int(0, "Weapon", SQL_CONNECTION);
		new Ammo = cache_get_field_content_int(0, "Ammo", SQL_CONNECTION);
		GetPlayerWeaponData(playerid, GetWeaponSlot(Weap), w, a);
		if(w != 0) 
		{
			SendErrorMessage(playerid, "Weapon of this type already equipped.");
			return 0;
		}
		GivePlayerGun(playerid, Weap, Ammo);
		MYSQL_Update_Interger(strval(WeapSQLID), "FactionWeapons", "Status", 0);

		if(Character[playerid][Faction] == 1)
		{
			format(str, sizeof(str), "Weapon OUT at %d:%d - %s with %d rounds.", ClockHours, ClockMinutes, WeaponNameList[Weap], Ammo);
			Add_PoliceNationalComputer(0, playerid, PNC_WLOG, str, 0);
		}
		SendInfoMessage(playerid, "Weapon equipped.");

	}
	else SendErrorMessage(playerid, "Weapon not found.");
	cache_delete(result);
	
    return 1;
}

stock BuyFactionWeapon(playerid, weap, ammo)
{
	new query[300];
    mysql_format(SQL_CONNECTION, query, sizeof(query), "INSERT INTO FactionWeapons (Weapon, Ammo, Faction, Status) VALUES(%d, %d, %d, 1)", weap, ammo, Character[playerid][Faction]);
	mysql_tquery(SQL_CONNECTION, query);

	SendInfoMessage(playerid, "Weapon successfully purchased.");
	return 1;
}


Dialog:FWeaponsBuy(playerid, response, listitem, inputtext[])
{
	if(!response) return FWeapons_Main(playerid);
	new extractprice[6], weapprice;
    strmid(extractprice, inputtext, strfind(inputtext, "$") + 1,  strfind(inputtext, ")"));
    weapprice = strval(extractprice);

    if(Character[playerid][Cash] < weapprice) return SendErrorMessage(playerid, ERROR_MONEY);
    GivePlayerMoneyEx(playerid, -weapprice);


 	if(listitem == 0)
	{
		BuyFactionWeapon(playerid, 25, 30);
	}
	else if(listitem == 1)
	{
		BuyFactionWeapon(playerid, 29, 120);
	}
	else if(listitem == 2)
	{
		BuyFactionWeapon(playerid, 27, 35);
	}
	else if(listitem == 3)
	{
		BuyFactionWeapon(playerid, 31, 150);
	}
	else if(listitem == 4)
	{
		BuyFactionWeapon(playerid, 34, 20);
	}
    return 1;
}



CMD:internet(playerid,params[])
{
	WebPortal(playerid);
	return 1;
}

stock WebPortal(playerid)
{
    Dialog_Show(playerid, Internet, DIALOG_STYLE_INPUT, "San Andreas Internet Portal","Welcome to the San Andreas Internet Portal.\n\nPlease enter a web-URL:","Enter","Close");
	return 1;
}

Dialog:WebPortal(playerid, response, listitem, inputtext[])
{
	WebPortal(playerid);
	return 1;
}

Dialog:Internet(playerid, response, listitem, inputtext[])
{
	if(!response) return 0;
	if(!strcmp(inputtext, "www.legalweapons.com", true)) Website_LegalWeapons(playerid);
	else if(!strcmp(inputtext, "www.legalweapons.com/buy", true)) Website_LegalWeapons_Buy1(playerid); 


	else if(!strcmp(inputtext, "www.sheriffdeparment.com/pnc", true))
	{
		if(IsLawEnforcement(playerid))
		{
			PoliceNationalComputer(playerid);
		}
		else WebError(playerid, 401, inputtext);
	}

	else WebError(playerid, 404, inputtext);
		
    return 1;
}

stock WebError(playerid, type, url[])
{
	new str[128], estr[128];
	if(type == 404) format(estr, sizeof(estr), "ERROR 404: The requested page/file was not found.");
	else if(type == 401) format(estr, sizeof(estr), "ERROR 401: You are not authorised to view this content.");
	else if(type == 402) format(estr, sizeof(estr), "ERROR 402: Transaction Failure.");

	format(str, sizeof(str), "http://%s/", url);

	Dialog_Show(playerid, Error, DIALOG_STYLE_MSGBOX, str, estr,"Close","");
}

Dialog:Error(playerid, response, listitem, inputtext[])
{
	WebPortal(playerid);
	return 1;
}


stock Website_LegalWeapons(playerid)
{
	new str[200], mstr[1000];
	format(str, sizeof(str), "\t Legal Weapons | The world's number 1 weapon supplier! \n\n\n");
	strcat(mstr, str, sizeof(mstr));
	format(str, sizeof(str), "Are you looking for a gun, knife or even explosives? \n\n");
	strcat(mstr, str, sizeof(mstr));
	format(str, sizeof(str), "Well you're in the right place, here at Legal Weapons we supply the world's legitimate leaders \n");
	strcat(mstr, str, sizeof(mstr));
	format(str, sizeof(str), "and civilians with all their lethal weapon needs*. If you are in LAW ENFORCEMENT then I'm sorry\n");
	strcat(mstr, str, sizeof(mstr));
	format(str, sizeof(str), "to inform you that we're out of stock :-(. As for anyone else, please proceed to the buying section\n");
	strcat(mstr, str, sizeof(mstr));
	format(str, sizeof(str), "of the website!\n\n\n");
	strcat(mstr, str, sizeof(mstr));
	format(str, sizeof(str), "*Legal Weapons in no way condones the selling of illegal weapons.");
	strcat(mstr, str, sizeof(mstr));


    Dialog_Show(playerid, WebPortal, DIALOG_STYLE_MSGBOX, "http://www.legalweapons.com/", mstr,"Close","");
	return 1;
}



stock Website_LegalWeapons_Buy1(playerid)
{
	SendInfoMessage(playerid, "Please note that all purchases are done via direct debit, thus cash will be instantaiously taken from your bank account should you make a purchase.");
    Dialog_Show(playerid, BuyLegalWeapons, DIALOG_STYLE_LIST, "http://www.legalweapons.com/buy","| ($4000) | Kitchen Knife (for cooking only) | \n| ($25000) | Chainsaw (for cutting down trees) \n| ($7000) | 9mm Tool (handle with extra care) \n| ($12000) | Eagle in a desert \n| ($10000) | Double Barreled BB Gun ","Select","Cancel");
	return 1;
}

Dialog:BuyLegalWeapons(playerid, response, listitem, inputtext[])
{
	if(!response) return 0;
	new extractprice[6], weapprice, str[128];
    strmid(extractprice, inputtext, strfind(inputtext, "$") + 1,  strfind(inputtext, " |"));
    weapprice = strval(extractprice);

    if(weapprice > Character[playerid][Bank])
    {
    	WebError(playerid, 402, "www.legalweapons.com/buy");
    	return 0;
    }
    else
	{
		Character[playerid][Bank] -= weapprice;
		format(str, sizeof(str), "$%d has been deducted from your bank account. You should recieve more information on your weapon shortly.", weapprice);
		SendInfoMessage(playerid, str);
	}

	if(listitem == 0)
	{
		GivePlayerGun(playerid, 4, 1);
	}
	else if (listitem == 1)
	{
		GivePlayerGun(playerid, 9, 1);
	}
	else if (listitem == 2)
	{
		GivePlayerGun(playerid, 22, 60);
	}
	else if (listitem == 3)
	{
		GivePlayerGun(playerid, 24, 60);
	}
	else if (listitem == 4)
	{
		GivePlayerGun(playerid, 25, 40);
	}
	WebPortal(playerid);
	return 1;
}


CMD:clearchat(playerid, params[])
{
	for(new i = 0; i < 100; i++)
	{
		SendClientMessage(playerid, COLOR_WHITE, "");
	}
	return 1;
}

stock GetPosBehindVehicle(vehicleid, &Float:x, &Float:y, &Float:z, Float:offset=0.5)
{
	new Float:vehicleSize[3], Float:vehiclePos[3];
	GetVehiclePos(vehicleid, vehiclePos[0], vehiclePos[1], vehiclePos[2]);
	GetVehicleModelInfo(GetVehicleModel(vehicleid), VEHICLE_MODEL_INFO_SIZE, vehicleSize[0], vehicleSize[1], vehicleSize[2]);
	GetXYBehindVehicle(vehicleid, vehiclePos[0], vehiclePos[1], (vehicleSize[1]/2)+offset);
	x = vehiclePos[0];
	y = vehiclePos[1];
	z = vehiclePos[2];
	return 1;
}

stock SetVehicleHoodState(vid, setstate)
{
     new veh[7];
     GetVehicleParamsEx(vid,veh[0],veh[1],veh[2],veh[3],veh[4],veh[5],veh[6]);
	 if(setstate) SetVehicleParamsEx(vid,veh[0],veh[1],veh[2],veh[3],VEHICLE_PARAMS_ON,veh[5],veh[6]);
	 else SetVehicleParamsEx(vid,veh[0],veh[1],veh[2],veh[3],VEHICLE_PARAMS_OFF,veh[5],veh[6]);
}

stock SetVehicleTrunkState(vid, setstate)
{
	 new veh[7];
     GetVehicleParamsEx(vid,veh[0],veh[1],veh[2],veh[3],veh[4],veh[5],veh[6]);
	 if(setstate) SetVehicleParamsEx(vid,veh[0],veh[1],veh[2],veh[3],veh[4],VEHICLE_PARAMS_ON,veh[6]);
	 else SetVehicleParamsEx(vid,veh[0],veh[1],veh[2],veh[3],veh[4],VEHICLE_PARAMS_OFF,veh[6]);
}

stock GetVehicleTrunkState(vid)
{
	 new veh[7];
     GetVehicleParamsEx(vid,veh[0],veh[1],veh[2],veh[3],veh[4],veh[5],veh[6]);
	 return veh[5];
}

stock TogVehicleTrunkState(vid)
{
	 new veh[7];
     GetVehicleParamsEx(vid,veh[0],veh[1],veh[2],veh[3],veh[4],veh[5],veh[6]);
     if(veh[5] == VEHICLE_PARAMS_OFF) SetVehicleParamsEx(vid,veh[0],veh[1],veh[2],veh[3],veh[4],VEHICLE_PARAMS_ON,veh[6]);
	 else SetVehicleParamsEx(vid,veh[0],veh[1],veh[2],veh[3],veh[4],VEHICLE_PARAMS_OFF,veh[6]);
}

/*stock GetNearestVehicle(playerid, Float:dis) // some stock i have found around the forums
{
    new Float:X, Float:Y, Float:Z;
    if(GetPlayerPos(playerid, X, Y, Z))
    {
        new vehicleid = INVALID_VEHICLE_ID;
        for(new v, Float:temp, Float:VX, Float:VY, Float:VZ; v != MAX_VEHICLES; v++)
        {
            if(GetVehiclePos(v, VX, VY, VZ))
            {
                VX -= X, VY -= Y, VZ -= Z;
                temp = VX * VX + VY * VY + VZ * VZ;
                if(temp < dis) dis = temp, vehicleid = v;
            }
        }
        dis = floatpower(dis, 0.5);
        return vehicleid;
    }
    return INVALID_VEHICLE_ID;
}
*/

GetXYBehindVehicle(vehicleid, &Float:q, &Float:w, Float:distance)
{
	new Float:a;
	GetVehiclePos(vehicleid, q, w, a);
	GetVehicleZAngle(vehicleid, a);
	q += (distance * -floatsin(-a, degrees));
	w += (distance * -floatcos(-a, degrees));
}



CMD:trunk(playerid, params[])
{
	new Float:cPos[3], vID = GetNearestVehicle(playerid, 25.0);

	if(vID == INVALID_VEHICLE_ID) return SendErrorMessage(playerid, "You are not in range of a vehicle."); 
	GetPosBehindVehicle(vID, cPos[0], cPos[1], cPos[2], 1.0);
	
	if(!IsPlayerInRangeOfPoint(playerid, 1.0, cPos[0], cPos[1], cPos[2])) return SendErrorMessage(playerid, "You must be at the boot of the vehicle to do this command.");
	
	TogVehicleTrunkState(vID);
 //AttachDynamicObjectToVehicle(objectid, vehicleid, Float:offsetx, Float:offsety, Float:offsetz, Float:rx, Float:ry, Float:rz);
	return 1;
}




/*
Dialog:(playerid, response, listitem, inputtext[])
{

    return 1;
}
*/
