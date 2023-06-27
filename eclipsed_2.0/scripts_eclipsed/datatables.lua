local datatables = {}
local enums = EclipsedMod.enums

datatables.completionInit = {
	all     = 0, heart	= 0, isaac	= 0, bbaby	= 0, satan	= 0, lamb	= 0,
	rush	= 0, hush	= 0, deli	= 0, mega	= 0, greed	= 0, mother	= 0, beast	= 0,
	}
datatables.completionFull = {
	all     = 2, heart	= 2, isaac	= 2, bbaby	= 2, satan	= 2, lamb	= 2,
	rush	= 2, hush	= 2, deli	= 2, mega	= 2, greed	= 2, mother	= 2, beast	= 2,
	}
datatables.challengesInit = {potato = 0, lobotomy = 0, magician = 0, beatmaker = 0, mongofamily = 0, all = 0}
datatables.challengesFull = {potato = 2, lobotomy = 2, magician = 2, beatmaker = 2, mongofamily = 2, all = 2}

datatables.NoAnimNoAnnounMimic = UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC
datatables.NoAnimNoAnnounMimicNoCostume = UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC | UseFlag.USE_NOCOSTUME

datatables.VoidThreshold = 0.16
datatables.SpecialCursesAvtice = true
datatables.RedColor = Color(1.5,0,0)

datatables.TextFont = Font()
datatables.TextFont:Load("font/pftempestasevencondensed.fnt")

datatables.AllowedPickupVariants = {
	[PickupVariant.PICKUP_COLLECTIBLE] = true,
	[PickupVariant.PICKUP_HEART] = true,
	[PickupVariant.PICKUP_KEY] = true,
	[PickupVariant.PICKUP_BOMB] = true,
	[PickupVariant.PICKUP_THROWABLEBOMB] = true,
	[PickupVariant.PICKUP_GRAB_BAG] = true,
	[PickupVariant.PICKUP_PILL] = true,
	[PickupVariant.PICKUP_LIL_BATTERY] = true,
	[PickupVariant.PICKUP_TAROTCARD] = true,
	[PickupVariant.PICKUP_TRINKET] = true,
}

datatables.NotAllowedPickupVariants = {
	[PickupVariant.PICKUP_COLLECTIBLE] = true,
	[PickupVariant.PICKUP_BROKEN_SHOVEL] = true,
	[PickupVariant.PICKUP_BIGCHEST] = true,
	[PickupVariant.PICKUP_TROPHY] = true,
	[PickupVariant.PICKUP_BED] = true,
	[PickupVariant.PICKUP_MOMSCHEST] = true,
}

datatables.HourglassIcon = Sprite()
datatables.HourglassPic = Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS).GfxFileName
datatables.HourglassIcon:Load("gfx/005.100_Collectible.anm2", true)
datatables.HourglassIcon:ReplaceSpritesheet(1, datatables.HourglassPic)
datatables.HourglassIcon:LoadGraphics()
datatables.HourglassIcon.Scale = Vector.One * 0.8
datatables.HourglassIcon:SetFrame("Idle", 8)

datatables.HourglassText = Font()
datatables.HourglassText:Load("font/pftempestasevencondensed.fnt")


datatables.MeltedCandle = {}
datatables.MeltedCandle.TearChance = 0.8
datatables.MeltedCandle.TearFlags = TearFlags.TEAR_FREEZE | TearFlags.TEAR_BURN
datatables.MeltedCandle.TearColor =  Color(2, 2, 2, 1, 0.196, 0.196, 0.196)
datatables.MeltedCandle.FrameCount = 92

datatables.HeartTransplant = {}
datatables.HeartTransplant.ChargeBar = Sprite()
datatables.HeartTransplant.ChargeBar:Load("gfx/ui/heartbeat_chargebar.anm2", true)
datatables.HeartTransplant.DischargeDelay = 15 -- half second -> 0.5
datatables.HeartTransplant.ChainValue = {
--dmg mult, tears up, speed up, recharge speed
	{0, 	0, 			0.0, 	1},
	{0.0, 	0, 			0.1, 	1},
	{0.1, 	0, 			0.15, 	2},
	{0.1, 	-0.25, 		0.2, 	2},
	{0.2, 	-0.25, 		0.3, 	3},
	{0.25, 	-0.5, 		0.4, 	3},
	{0.3, 	-0.5, 		0.5, 	4},
	{0.6, 	-1, 		0.6, 	4},
	{0.5, 	-1, 		0.7, 	5},
	{0.8, 	-1.5, 		0.8, 	5},
	{0.8, 	-1.5, 		0.9, 	6},
	{1.0, 	-2, 		1, 		6},
}

datatables.AbyssCart = {}
datatables.AbyssCart.SacrificeBabies = {
	--[167] = 10, by this way I must get all game items (not good variant)
	{167, 10},  -- HARLEQUIN_BABY
	{8, 1},  -- BROTHER_BOBBY
	{67, 7},  -- SISTER_MAGGY
	{100, 5},  -- LITTLE_STEVEN
	{268, 54},  -- ROTTEN_BABY
	{269, 55},  -- HEADLESS_BABY
	{322, 74},  -- MONGO_BABY
	{188, 8},  -- ABEL
	{491, 112},  -- ACID_BABY
	{607, 208},  -- BOILED_BABY
	{518, 119},  -- BUDDY_IN_A_BOX
	{652, 239},  -- CUBE_BABY
	{113, 2},  -- DEMON_BABY
	{265, 51},  -- DRY_BABY
	{404, 95},  -- FARTING_BABY
	{608, 209},  -- FREEZER_BABY
	{163, 9},  -- GHOST_BABY
	{112, 32},  -- GUARDIAN_ANGEL
	{360, 80},  -- INCUBUS
	{472, 109},  -- KING_BABY
	{679, 230},  -- LIL_ABADDON
	{275, 61},  -- LIL_BRIMSTONE
	{435, 97},  -- LIL_LOKI
	{431, 101},  -- MULTIDIMENSIONAL_BABY
	{174, 11},  -- RAINBOW_BABY
	{95, 6},  -- ROBO_BABY
	{267, 53},  -- ROBO_BABY_2
	{390, 92},  -- SERAPHIM
	{363, 83},  -- SWORN_PROTECTOR
	--{661, 1},  -- QUINTS
	{698, 235},  -- TWISTED_BABY
}

datatables.Eclipse = {}
datatables.Eclipse.DamageDelay = 6
datatables.Eclipse.DamageBoost = 1.0

datatables.MongoCells = {}
datatables.MongoCells.CreepFrame = 8
datatables.MongoCells.FartBabyBeans = {CollectibleType.COLLECTIBLE_BEAN, CollectibleType.COLLECTIBLE_BUTTER_BEAN, CollectibleType.COLLECTIBLE_KIDNEY_BEAN}
datatables.MongoCells.ExplosionDamage = 100

datatables.ExplodingKittens = {} -- 4 sec.  30 frames = 1 second
datatables.ExplodingKittens.BombCards = {
	[EclipsedMod.enums.Pickups.KittenBomb] = true,
	[EclipsedMod.enums.Pickups.KittenBomb2] = true,
}

datatables.SecretLoveLetter = {}
datatables.SecretLoveLetter.SpritePath = "gfx/LoveLetterTear.png"
datatables.SecretLoveLetter.BannedEnemies = {
	[260] = true, -- lil ghosts.  for haunt boos, cause he just don't switch to 2nd phase
}

datatables.CardTypes = {
	[ItemConfig.CARDTYPE_TAROT] = true,
	[ItemConfig.CARDTYPE_SUIT] = true,
	[ItemConfig.CARDTYPE_SPECIAL] = true,
	[ItemConfig.CARDTYPE_TAROT_REVERSE] = true,
}

datatables.RuneObjectTypes = {
	[ItemConfig.CARDTYPE_RUNE] = true,
	[ItemConfig.CARDTYPE_SPECIAL_OBJECT] = true,
}

datatables.TetrisDicesQuestionMark = "gfx/items/collectibles/questionmark.png"
datatables.TetrisDices = {
	enums.Items.TetrisDice2,
	enums.Items.TetrisDice3,
	enums.Items.TetrisDice4,
	enums.Items.TetrisDice5,
	enums.Items.TetrisDice6,
	enums.Items.TetrisDice_full,
}
datatables.TetrisDicesCheck = {
	[enums.Items.TetrisDice1] = 1,
	[enums.Items.TetrisDice2] = 2,
	[enums.Items.TetrisDice3] = 3,
	[enums.Items.TetrisDice4] = 4,
	[enums.Items.TetrisDice5] = 5,
	[enums.Items.TetrisDice6] = 6,
}

datatables.RedButton = {}
datatables.RedButton.PressCount = 0 -- press counter
datatables.RedButton.Limit = 66 -- limit
datatables.RedButton.SpritePath = "gfx/grid/grid_redbutton.png"
datatables.RedButton.VarData = 999 -- data to check right grid entity

datatables.VoidKarma = {}
datatables.VoidKarma.DamageUp = 0.5
datatables.VoidKarma.TearsUp = 1.0
datatables.VoidKarma.RangeUp = 40
datatables.VoidKarma.ShotSpeedUp = 0.1
datatables.VoidKarma.SpeedUp = 0.1
datatables.VoidKarma.LuckUp = 0.5

datatables.SurrogateConceptionFams = {
	CollectibleType.COLLECTIBLE_LIL_HAUNT,
	CollectibleType.COLLECTIBLE_LIL_GURDY,
	CollectibleType.COLLECTIBLE_LIL_LOKI,
	CollectibleType.COLLECTIBLE_LIL_MONSTRO,
	CollectibleType.COLLECTIBLE_LIL_DELIRIUM,
	CollectibleType.COLLECTIBLE_7_SEALS,
	CollectibleType.COLLECTIBLE_LITTLE_CHUBBY,
	CollectibleType.COLLECTIBLE_LITTLE_CHAD,
	CollectibleType.COLLECTIBLE_LITTLE_GISH,
	CollectibleType.COLLECTIBLE_LITTLE_STEVEN,
	CollectibleType.COLLECTIBLE_BIG_CHUBBY,
	CollectibleType.COLLECTIBLE_HUSHY,
	CollectibleType.COLLECTIBLE_BUMBO,
	CollectibleType.COLLECTIBLE_SERAPHIM,
	CollectibleType.COLLECTIBLE_GEMINI,
	CollectibleType.COLLECTIBLE_PEEPER,
	CollectibleType.COLLECTIBLE_DADDY_LONGLEGS,
}

datatables.LililithDemonSpawn = { -- familiars that can be spawned by lililith
	CollectibleType.COLLECTIBLE_DEMON_BABY,
	CollectibleType.COLLECTIBLE_LIL_BRIMSTONE,
	CollectibleType.COLLECTIBLE_LIL_ABADDON,
	CollectibleType.COLLECTIBLE_INCUBUS,
	CollectibleType.COLLECTIBLE_SUCCUBUS,
	CollectibleType.COLLECTIBLE_LEECH,
	CollectibleType.COLLECTIBLE_TWISTED_PAIR,
}

datatables.UnbiidenBannedCurses = {
	[enums.Curses.Poverty] = true,
	[enums.Curses.Desolation] = true,
	[enums.Curses.Montezuma] = true,
}

datatables.TemporaryWisps = {
	[enums.Items.StoneScripture] = true,
	[enums.Items.GardenTrowel] = true,
}

datatables.CurseSecretRooms = {
	[RoomType.ROOM_SECRET] = true,
	[RoomType.ROOM_SUPERSECRET] = true,
}

datatables.Corruption = {}
datatables.Corruption.CostumeHead = Isaac.GetCostumeIdByPath("gfx/characters/corruptionhead.anm2")

datatables.MiniPony = {} -- items.xml - addcostumeonpickup="true"
--datatables.MiniPony.Costume = Isaac.GetCostumeIdByPath("gfx/characters/minipony.anm2")

datatables.LongElk = {}
--datatables.LongElk.Costume = Isaac.GetCostumeIdByPath("gfx/characters/longelk.anm2") --longelk -- items.xml - addcostumeonpickup="true"


EclipsedMod.datatables = datatables