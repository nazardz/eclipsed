local datatables = {}
local mod = EclipsedMod
local enums = mod.enums

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

datatables.CURSE_COLUMNS = 8
datatables.CURSE_SPRITE_SCALE = 16
datatables.CurseHorizontalOffset = 240 -- X vector dimension offset
datatables.CurseVerticalOffset = 12 -- Y dimension offset
datatables.CurseIconOpacity = 1 -- Visibility

datatables.CurseIcons = Sprite()
datatables.CurseIcons:Load("gfx/curse_icons/eclipsed_curse_icon.anm2", true)

datatables.OblivionCard = {}
datatables.OblivionCard.SpritePath = "gfx/oblivioncardtear.png"

datatables.DeliObject = {}
datatables.DeliObject.CheckGetCard = {
	[enums.Pickups.DeliObjectCell] = true,
	[enums.Pickups.DeliObjectBomb] = true,
	[enums.Pickups.DeliObjectKey] = true,
	[enums.Pickups.DeliObjectCard] = true,
	[enums.Pickups.DeliObjectPill] = true,
	[enums.Pickups.DeliObjectRune] = true,
	[enums.Pickups.DeliObjectHeart] = true,
	[enums.Pickups.DeliObjectCoin] = true,
	[enums.Pickups.DeliObjectBattery] = true,
}
datatables.DeliObject.Variants = {
	enums.Pickups.DeliObjectCell,
	enums.Pickups.DeliObjectBomb,
	enums.Pickups.DeliObjectKey,
	enums.Pickups.DeliObjectCard,
	enums.Pickups.DeliObjectPill,
	enums.Pickups.DeliObjectRune,
	enums.Pickups.DeliObjectHeart,
	enums.Pickups.DeliObjectCoin,
	enums.Pickups.DeliObjectBattery,
}
datatables.DeliObject.BombFlags = {
	TearFlags.TEAR_HOMING,
	TearFlags.TEAR_POISON,
	TearFlags.TEAR_BURN,
	TearFlags.TEAR_ATTRACTOR,
	TearFlags.TEAR_SAD_BOMB,
	TearFlags.TEAR_SCATTER_BOMB,
	TearFlags.TEAR_BUTT_BOMB,
	TearFlags.TEAR_GLITTER_BOMB,
	TearFlags.TEAR_STICKY,
	TearFlags.TEAR_CROSS_BOMB,
	TearFlags.TEAR_CREEP_TRAIL,
	TearFlags.TEAR_BLOOD_BOMB,
	TearFlags.TEAR_BRIMSTONE_BOMB,
	TearFlags.TEAR_GHOST_BOMB,
	TearFlags.TEAR_ICE,
	TearFlags.TEAR_REROLL_ENEMY,
	TearFlags.TEAR_RIFT,
	--TearFlags.TEAR_GIGA_BOMB,
}

datatables.AlchemicNotesPickups = {
	[PickupVariant.PICKUP_HEART] = true,
	[PickupVariant.PICKUP_COIN] = true,
	[PickupVariant.PICKUP_KEY] = true,
	[PickupVariant.PICKUP_BOMB] = true,
	[PickupVariant.PICKUP_PILL] = true,
	[PickupVariant.PICKUP_LIL_BATTERY] = true,
	[PickupVariant.PICKUP_TAROTCARD] = true,
	[PickupVariant.PICKUP_THROWABLEBOMB] = true,
}

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

datatables.PickupHeartPrice = {
	[HeartSubType.HEART_FULL] = true,
	[HeartSubType.HEART_HALF] = true,
	[HeartSubType.HEART_HALF_SOUL] = true,
	[HeartSubType.HEART_SCARED] = true,
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
datatables.MeltedCandle.TearFlags = TearFlags.TEAR_FREEZE | TearFlags.TEAR_BURN
datatables.MeltedCandle.TearColor =  Color(2, 2, 2, 1, 0.196, 0.196, 0.196)

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

datatables.RubikDice = {}
datatables.RubikDice.GlitchReroll = 0.5 -- chance to become scrambled dice when used
datatables.RubikDice.ScrambledDices = { -- checklist
	[enums.Items.RubikDiceScrambled0] = true,
	[enums.Items.RubikDiceScrambled1] = true,
	[enums.Items.RubikDiceScrambled2] = true,
	[enums.Items.RubikDiceScrambled3] = true,
	[enums.Items.RubikDiceScrambled4] = true,
	[enums.Items.RubikDiceScrambled5] = true,
}
datatables.RubikDice.ScrambledDicesList = { -- list
	enums.Items.RubikDiceScrambled0,
	enums.Items.RubikDiceScrambled1,
	enums.Items.RubikDiceScrambled2,
	enums.Items.RubikDiceScrambled3,
	enums.Items.RubikDiceScrambled4,
	enums.Items.RubikDiceScrambled5
}

datatables.tableVHS = {
		{'1','1a','1b','1c','1d'}, -- basement 1 downpoor
		{'2','2a','2b','2c','2d'},
		{'3','3a','3b','3c','3d'},
		{'4','4a','4b','4c','4d'},
		{'5','5a','5b','5c','5d'},
		{'6','6a','6b','6c','6d'},
		{'7','7a','7b','7c','7d'},
		{'8','8a','8b','8c','8d'}, -- womb 2
		{'9'},	-- blue womb
		{'10','10a'}, -- cathedral sheol
		{'11','11a'}, -- chest dark room
		{'12'} -- void
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
datatables.MongoCells.FartBabyBeans = {
	CollectibleType.COLLECTIBLE_BEAN,
	CollectibleType.COLLECTIBLE_BUTTER_BEAN,
	CollectibleType.COLLECTIBLE_KIDNEY_BEAN,
}

datatables.MongoCells.FlyFamiliarVariant = {
	[FamiliarVariant.OBSESSED_FAN] = CollectibleType.COLLECTIBLE_HIVE_MIND,
    [FamiliarVariant.PAPA_FLY] = CollectibleType.COLLECTIBLE_HIVE_MIND,
    [FamiliarVariant.ANGRY_FLY] = CollectibleType.COLLECTIBLE_HIVE_MIND,
    [FamiliarVariant.PSY_FLY] = CollectibleType.COLLECTIBLE_HIVE_MIND,
    [FamiliarVariant.BEST_BUD] = CollectibleType.COLLECTIBLE_HIVE_MIND,
    [FamiliarVariant.BLUEBABYS_ONLY_FRIEND] = CollectibleType.COLLECTIBLE_HIVE_MIND,
    [FamiliarVariant.SWORN_PROTECTOR] = CollectibleType.COLLECTIBLE_HIVE_MIND,
    [FamiliarVariant.FRIEND_ZONE] = CollectibleType.COLLECTIBLE_HIVE_MIND,
    [FamiliarVariant.LOST_FLY] = CollectibleType.COLLECTIBLE_HIVE_MIND,
    [FamiliarVariant.BIG_FAN] = CollectibleType.COLLECTIBLE_HIVE_MIND,
    [FamiliarVariant.SMART_FLY] = CollectibleType.COLLECTIBLE_HIVE_MIND,
    [FamiliarVariant.FOREVER_ALONE] = CollectibleType.COLLECTIBLE_HIVE_MIND,
    [FamiliarVariant.DISTANT_ADMIRATION] = CollectibleType.COLLECTIBLE_HIVE_MIND,
}
datatables.MongoCells.CleanFamiliarVariant = {
    [FamiliarVariant.BOMB_BAG] = {5,40,0,6},
    [FamiliarVariant.SACK_OF_PENNIES] = {5,20,0,6},
    [FamiliarVariant.LITTLE_CHAD] = {5,10,2,6},
    [FamiliarVariant.RELIC] = {5,10,8,6},
    [FamiliarVariant.LIL_CHEST] = {5,350,0,6},
    [FamiliarVariant.SACK_OF_SACKS] = {5,69,0},
}
datatables.MongoCells.FamiliarEffectsVariant = {
    [FamiliarVariant.LITTLE_STEVEN] = {CollectibleType.COLLECTIBLE_SPOON_BENDER, true},
    [FamiliarVariant.HARLEQUIN_BABY] = {CollectibleType.COLLECTIBLE_THE_WIZ, true},
    [FamiliarVariant.FREEZER_BABY] = {CollectibleType.COLLECTIBLE_URANUS, false},
    [FamiliarVariant.GHOST_BABY] = {CollectibleType.COLLECTIBLE_OUIJA_BOARD, false},
    [FamiliarVariant.ABEL] = {CollectibleType.COLLECTIBLE_MY_REFLECTION, false},
    [FamiliarVariant.RAINBOW_BABY] = {CollectibleType.COLLECTIBLE_FRUIT_CAKE, false},
    [FamiliarVariant.LIL_BRIMSTONE] = {CollectibleType.COLLECTIBLE_BRIMSTONE, true},
    --[FamiliarVariant.BALL_OF_BANDAGES_1] = {CollectibleType.COLLECTIBLE_MOMS_EYESHADOW, false},
    [FamiliarVariant.BALL_OF_BANDAGES_2] = {CollectibleType.COLLECTIBLE_MOMS_EYESHADOW, false},
    [FamiliarVariant.BALL_OF_BANDAGES_3] = {CollectibleType.COLLECTIBLE_MOMS_EYESHADOW, false},
    [FamiliarVariant.BALL_OF_BANDAGES_4] = {CollectibleType.COLLECTIBLE_MOMS_EYESHADOW, false},
    [FamiliarVariant.SISSY_LONGLEGS] = {CollectibleType.COLLECTIBLE_MOMS_WIG, false},
    [FamiliarVariant.BUDDY_IN_A_BOX] = {CollectibleType.COLLECTIBLE_FRUIT_CAKE, false},
    [FamiliarVariant.HEADLESS_BABY] = {CollectibleType.COLLECTIBLE_ANEMIC, false},
    [FamiliarVariant.TWISTED_BABY] = {CollectibleType.COLLECTIBLE_20_20, false},
    [FamiliarVariant.ONE_UP] = {CollectibleType.COLLECTIBLE_GODS_FLESH, false},
    [FamiliarVariant.WORM_FRIEND] = {CollectibleType.COLLECTIBLE_MOMS_CONTACTS, false},
    [FamiliarVariant.BLUE_BABY_SOUL] = {CollectibleType.COLLECTIBLE_SPOON_BENDER, true},
    [FamiliarVariant.LIL_HAUNT] = {CollectibleType.COLLECTIBLE_DARK_MATTER, true}
}
datatables.MongoCells.HiddenWispEffectsVariant = {
	[FamiliarVariant.SISTER_MAGGY] = CollectibleType.COLLECTIBLE_BLOOD_OF_THE_MARTYR,
    [FamiliarVariant.LIL_ABADDON] = CollectibleType.COLLECTIBLE_MAW_OF_THE_VOID,
    [FamiliarVariant.LIL_LOKI] = CollectibleType.COLLECTIBLE_LOKIS_HORNS,
    [FamiliarVariant.LIL_MONSTRO] = CollectibleType.COLLECTIBLE_MONSTROS_LUNG,
    [FamiliarVariant.LITTLE_GISH] = CollectibleType.COLLECTIBLE_BALL_OF_TAR,
    [FamiliarVariant.MYSTERY_EGG] = CollectibleType.COLLECTIBLE_POKE_GO,
    [FamiliarVariant.MULTIDIMENSIONAL_BABY] = CollectibleType.COLLECTIBLE_CONTINUUM,
    [FamiliarVariant.HUSHY] = CollectibleType.COLLECTIBLE_CONTINUUM,
    [FamiliarVariant.ACID_BABY] = CollectibleType.COLLECTIBLE_PHD,
    [FamiliarVariant.SPIDER_MOD] = CollectibleType.COLLECTIBLE_GUPPYS_EYE,
    [FamiliarVariant.SERAPHIM] = CollectibleType.COLLECTIBLE_SACRED_HEART,
    [FamiliarVariant.BUMBO] = CollectibleType.COLLECTIBLE_DEEP_POCKETS,
    [FamiliarVariant.CHARGED_BABY] = CollectibleType.COLLECTIBLE_BATTERY,
    [FamiliarVariant.FATES_REWARD] = CollectibleType.COLLECTIBLE_FATE,
    [FamiliarVariant.KING_BABY] = CollectibleType.COLLECTIBLE_GLITCHED_CROWN,
    [FamiliarVariant.DEPRESSION] = CollectibleType.COLLECTIBLE_AQUARIUS,
    [FamiliarVariant.BROTHER_BOBBY] = CollectibleType.COLLECTIBLE_EPIPHORA,
    [FamiliarVariant.ROBO_BABY] = CollectibleType.COLLECTIBLE_TECHNOLOGY,
    [FamiliarVariant.ROBO_BABY_2] = CollectibleType.COLLECTIBLE_TECHNOLOGY_2,
    [FamiliarVariant.ROTTEN_BABY] = CollectibleType.COLLECTIBLE_MULLIGAN,
    [FamiliarVariant.ANGELIC_PRISM] = CollectibleType.COLLECTIBLE_PLAYDOUGH_COOKIE,
    [FamiliarVariant.DEMON_BABY] = CollectibleType.COLLECTIBLE_MARKED,
    [FamiliarVariant.BOT_FLY] = CollectibleType.COLLECTIBLE_LOST_CONTACT,
    [FamiliarVariant.BOILED_BABY] = CollectibleType.COLLECTIBLE_HAEMOLACRIA,
    [FamiliarVariant.BLOOD_PUPPY] = CollectibleType.COLLECTIBLE_LUSTY_BLOOD,
    [FamiliarVariant.LEECH] = CollectibleType.COLLECTIBLE_CHARM_VAMPIRE,
    [FamiliarVariant.LIL_GURDY] = CollectibleType.COLLECTIBLE_MARS,
    [FamiliarVariant.LEECH] = CollectibleType.COLLECTIBLE_CHARM_VAMPIRE,
    [FamiliarVariant.DEAD_CAT] = CollectibleType.COLLECTIBLE_GUPPYS_COLLAR,
    [FamiliarVariant.GUPPYS_HAIRBALL] = CollectibleType.COLLECTIBLE_GUPPYS_TAIL,
    [FamiliarVariant.JUICY_SACK] = CollectibleType.COLLECTIBLE_SPIDER_BITE,
    [FamiliarVariant.PUNCHING_BAG] = CollectibleType.COLLECTIBLE_ROTTEN_TOMATO,
    [FamiliarVariant.MONGO_BABY] = CollectibleType.COLLECTIBLE_BFFS,
    [FamiliarVariant.SAMSONS_CHAINS] = CollectibleType.COLLECTIBLE_SULFURIC_ACID,
    [FamiliarVariant.CAINS_OTHER_EYE] = CollectibleType.COLLECTIBLE_EYE_SORE,
    [FamiliarVariant.CENSER] = CollectibleType.COLLECTIBLE_STOP_WATCH,
    [FamiliarVariant.MILK] = CollectibleType.COLLECTIBLE_SOY_MILK,
    [FamiliarVariant.YO_LISTEN] = CollectibleType.COLLECTIBLE_XRAY_VISION,
    [FamiliarVariant.LIL_SPEWER] = CollectibleType.COLLECTIBLE_AQUARIUS,
    [FamiliarVariant.JAW_BONE] = CollectibleType.COLLECTIBLE_MAGNETO,
    [FamiliarVariant.POINTY_RIB] = CollectibleType.COLLECTIBLE_CUPIDS_ARROW,
    [FamiliarVariant.BLOOD_OATH] = CollectibleType.COLLECTIBLE_ADRENALINE,
    [FamiliarVariant.SLIPPED_RIB] = CollectibleType.COLLECTIBLE_METAL_PLATE,
    [FamiliarVariant.LIL_DUMPY] = CollectibleType.COLLECTIBLE_LINGER_BEAN,
    [FamiliarVariant.LIL_PORTAL] = CollectibleType.COLLECTIBLE_CARD_READING,
    --[FamiliarVariant.STAR_OF_BETHLEHEM] = CollectibleType.,
    --[FamiliarVariant.FINGER] = CollectibleType.,
    --[FamiliarVariant.SHADE] = CollectibleType.,
    --[FamiliarVariant.INCUBUS] = CollectibleType.,
    --[FamiliarVariant.GEMINI] = CollectibleType.,
    --[FamiliarVariant.GUILLOTINE] = CollectibleType.,
    --[FamiliarVariant.SACRIFICIAL_DAGGER] = CollectibleType.,
    --[FamiliarVariant.PEEPER] = CollectibleType.,
    --[FamiliarVariant.DADDY_LONGLEGS] = CollectibleType.,
    --[FamiliarVariant.LITTLE_CHUBBY] = CollectibleType.,
    --[FamiliarVariant.BIG_CHUBBY] = CollectibleType.,
    --[FamiliarVariant.GUARDIAN_ANGEL] = CollectibleType.,
    --[FamiliarVariant.7_SEALS] = CollectibleType.,
    --[FamiliarVariant.ISAACS_HEART] = CollectibleType.,
    --[FamiliarVariant.BLOODSHOT_EYE] = CollectibleType.,
    --[FamiliarVariant.TINYTOMA] = CollectibleType.,
}
--[FamiliarVariant.BUM_FRIEND]
--[FamiliarVariant.DARK_BUM]
--[FamiliarVariant.KEY_BUM]
--[FamiliarVariant.GB_BUG]
--[FamiliarVariant.SUCCUBUS]
--[FamiliarVariant.LOST_SOUL]
--[FamiliarVariant.PASCHAL_CANDLE]
--[FamiliarVariant.STITCHES]
datatables.MongoCells.TrinketFamiliarVariant = {
    [FamiliarVariant.DEAD_BIRD] = TrinketType.TRINKET_BLACK_FEATHER,
    [FamiliarVariant.MONGO_BABY] = TrinketType.TRINKET_FORGOTTEN_LULLABY,
    [FamiliarVariant.CUBE_BABY] = TrinketType.TRINKET_ICE_CUBE,
    [FamiliarVariant.EVES_BIRD_FOOT] = TrinketType.TRINKET_BLACK_FEATHER,
}

datatables.MongoCells.TrinketFamiliarCheck = {
    TrinketType.TRINKET_BLACK_FEATHER,
    TrinketType.TRINKET_FORGOTTEN_LULLABY,
    TrinketType.TRINKET_ICE_CUBE,
    TrinketType.TRINKET_BLACK_FEATHER,
}

datatables.ExplodingKittens = {} -- 4 sec.  30 frames = 1 second
datatables.ExplodingKittens.BombCards = {
	[mod.enums.Pickups.KittenBomb] = true,
	[mod.enums.Pickups.KittenBomb2] = true,
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
	[6] = true,
}

datatables.ElderMythCardPool = {
	enums.Pickups.OblivionCard,
	enums.Pickups.BattlefieldCard,
	enums.Pickups.TreasuryCard,
	enums.Pickups.BookeryCard,
	enums.Pickups.BloodGroveCard,
	enums.Pickups.StormTempleCard,
	enums.Pickups.ArsenalCard,
	enums.Pickups.OutpostCard,
	enums.Pickups.CryptCard,
	enums.Pickups.MazeMemoryCard,
	enums.Pickups.ZeroMilestoneCard,
	enums.Pickups.CemeteryCard,
	enums.Pickups.VillageCard,
	enums.Pickups.GroveCard,
	enums.Pickups.WheatFieldsCard,
	enums.Pickups.SwampCard,
	enums.Pickups.RuinsCard,
	enums.Pickups.SpiderCocoonCard,
	enums.Pickups.VampireMansionCard,
	enums.Pickups.RoadLanternCard,
	enums.Pickups.SmithForgeCard,
	enums.Pickups.ChronoCrystalsCard,
	enums.Pickups.WitchHut,
	enums.Pickups.BeaconCard,
	enums.Pickups.TemporalBeaconCard,
}

datatables.Pompom = {}
datatables.Pompom.Chance = 0.5 -- chance to turn heart into red wisp on collision
datatables.Pompom.WispsList = {
	CollectibleType.COLLECTIBLE_BLOOD_RIGHTS,
	CollectibleType.COLLECTIBLE_CONVERTER,
	CollectibleType.COLLECTIBLE_MOMS_BRA,
	--CollectibleType.COLLECTIBLE_KAMIKAZE,
	CollectibleType.COLLECTIBLE_YUM_HEART,
	CollectibleType.COLLECTIBLE_D6,
	--CollectibleType.COLLECTIBLE_D20,
	CollectibleType.COLLECTIBLE_RAZOR_BLADE,
	CollectibleType.COLLECTIBLE_RED_CANDLE,
	CollectibleType.COLLECTIBLE_THE_JAR,
	CollectibleType.COLLECTIBLE_SCISSORS,
	CollectibleType.COLLECTIBLE_RED_KEY,
	CollectibleType.COLLECTIBLE_MEGA_BLAST,
	--CollectibleType.COLLECTIBLE_SULFUR,
	CollectibleType.COLLECTIBLE_SHARP_STRAW,
	CollectibleType.COLLECTIBLE_MEAT_CLEAVER,
	-- CollectibleType.COLLECTIBLE_PLAN_C,
	--CollectibleType.COLLECTIBLE_SUMPTORIUM,
	65540, -- notched axe (redstone) red laser wisp
	-- CollectibleType.COLLECTIBLE_VENGEFUL_SPIRIT, -- unkillable
	-- CollectibleType.COLLECTIBLE_POTATO_PEELER, -- unkillable
}

datatables.RedBag = {}
datatables.RedBag.RedPickups = { -- possible items
	{PickupVariant.PICKUP_THROWABLEBOMB, 0, 1}, -- varitant, subtype, generation delay (how many room need to be cleared to activate it again after spawning this pickup)
	{PickupVariant.PICKUP_HEART, HeartSubType.HEART_FULL, 3},
	{PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALF, 2},
	{PickupVariant.PICKUP_HEART, HeartSubType.HEART_DOUBLEPACK, 4},
	{PickupVariant.PICKUP_HEART, HeartSubType.HEART_SCARED, 3},
	{PickupVariant.PICKUP_TAROTCARD, Card.CARD_DICE_SHARD, 6},
	{PickupVariant.PICKUP_TAROTCARD, Card.CARD_CRACKED_KEY, 6},
	{PickupVariant.PICKUP_PILL, enums.Pickups.RedPillColor, 4},
	--{PickupVariant.PICKUP_PILL, enums.Pickups.RedPillColorHorse, 6},
	--{PickupVariant.PICKUP_TAROTCARD, enums.Pickups.RedPill, 4},
	--{PickupVariant.PICKUP_TAROTCARD, enums.Pickups.RedPillHorse, 6},
	{PickupVariant.PICKUP_TAROTCARD, enums.Pickups.Trapezohedron, 5}
}

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
datatables.TetrisDicesCheckEmpty = {
	[enums.Items.TetrisDice2] = true,
	[enums.Items.TetrisDice3] = true,
	[enums.Items.TetrisDice4] = true,
	[enums.Items.TetrisDice5] = true,
	[enums.Items.TetrisDice6] = true,
	[enums.Items.TetrisDice_full] = true,
}

datatables.DiceBombs = {}
datatables.DiceBombs.ChestsTable = {50,51,52,53,54,55,56,57,58,60}
datatables.DiceBombs.PickupsTable = {10, 20, 30, 40, 50, 69, 70, 90, 300, 350}

datatables.LockedGrimoireChests = {
	{PickupVariant.PICKUP_CHEST, 1},
	{PickupVariant.PICKUP_LOCKEDCHEST, 0.5},
	{PickupVariant.PICKUP_REDCHEST, 0.15},
	{PickupVariant.PICKUP_OLDCHEST, 0.15},
	{PickupVariant.PICKUP_WOODENCHEST, 0.15},
	{PickupVariant.PICKUP_MEGACHEST, 0.05},
}

datatables.RedButton = {}
datatables.RedButton.PressCount = 0 -- press counter
datatables.RedButton.Limit = 66 -- limit
datatables.RedButton.SpritePath = "gfx/grid/grid_redbutton.png"
datatables.RedButton.VarData = 999 -- data to check right grid entity

datatables.VoidKarma = {}
datatables.VoidKarma.DamageUp = 0.5
datatables.VoidKarma.TearsUp = 1.25
datatables.VoidKarma.RangeUp = 50
datatables.VoidKarma.ShotSpeedUp = 0.15
datatables.VoidKarma.SpeedUp = 0.15
datatables.VoidKarma.LuckUp = 1

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

datatables.ChestVariant = {
	[PickupVariant.PICKUP_CHEST] = true,
	[PickupVariant.PICKUP_BOMBCHEST] = true,
	[PickupVariant.PICKUP_LOCKEDCHEST] = true,
	[PickupVariant.PICKUP_MEGACHEST] = true,
	[PickupVariant.PICKUP_REDCHEST] = true,
	[PickupVariant.PICKUP_SPIKEDCHEST] = true,
	[PickupVariant.PICKUP_ETERNALCHEST] = true,
	[PickupVariant.PICKUP_MIMICCHEST] = true,
	[PickupVariant.PICKUP_OLDCHEST] = true,
	[PickupVariant.PICKUP_WOODENCHEST] = true,
	[PickupVariant.PICKUP_HAUNTEDCHEST] = true,
}

datatables.NoGoldenChest = {
	[PickupVariant.PICKUP_CHEST] = true,
	[PickupVariant.PICKUP_BOMBCHEST] = true,
	[PickupVariant.PICKUP_SPIKEDCHEST] = true,
	[PickupVariant.PICKUP_ETERNALCHEST] = true,
	[PickupVariant.PICKUP_MIMICCHEST] = true,
	[PickupVariant.PICKUP_OLDCHEST] = true,
	[PickupVariant.PICKUP_WOODENCHEST] = true,
	[PickupVariant.PICKUP_HAUNTEDCHEST] = true,
	[PickupVariant.PICKUP_REDCHEST] = true,
	--[PickupVariant.PICKUP_MEGACHEST] = true,
	--[PickupVariant.PICKUP_LOCKEDCHEST] = true,
}

datatables.DefuseCardBombs = {
	[BombVariant.BOMB_TROLL] = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_NORMAL},
	[BombVariant.BOMB_SUPERTROLL] = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_DOUBLEPACK},
	[BombVariant.BOMB_GOLDENTROLL] = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_GOLDEN},
	[BombVariant.BOMB_GIGA] = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_GIGA},
	[BombVariant.BOMB_THROWABLE] = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_THROWABLEBOMB, 0},
}

datatables.BinderClipDuplicate = {
	[PickupVariant.PICKUP_HEART] = HeartSubType.HEART_DOUBLEPACK,
	[PickupVariant.PICKUP_COIN] = HeartSubType.COIN_DOUBLEPACK,
	[PickupVariant.PICKUP_KEY] = HeartSubType.KEY_DOUBLEPACK,
	[PickupVariant.PICKUP_BOMB] = HeartSubType.BOMB_DOUBLEPACK,
}

datatables.InfiniteBlades = {}
datatables.InfiniteBlades.newSpritePath = "gfx/effects/effect_momsknife.png"

datatables.BlackBook = {}
datatables.BlackBook.Duration = 162 -- duration of status effect
datatables.BlackBook.EffectFlags = { -- possible effects
	{EntityFlag.FLAG_FREEZE, Color(0.5, 0.5, 0.5, 1, 0, 0, 0), datatables.BlackBook.Duration}, -- effect, color, duration
	{EntityFlag.FLAG_POISON, Color(0.4, 0.97, 0.5, 1, 0, 0, 0), datatables.BlackBook.Duration},
	{EntityFlag.FLAG_SLOW, Color(0.15, 0.15, 0.15, 1, 0, 0, 0), datatables.BlackBook.Duration},
	{EntityFlag.FLAG_CHARM, Color(1, 0, 1, 1, 0.196, 0, 0), datatables.BlackBook.Duration},
	{EntityFlag.FLAG_CONFUSION, Color(0.5, 0.5, 0.5, 1, 0, 0, 0), datatables.BlackBook.Duration},
	{EntityFlag.FLAG_MIDAS_FREEZE, Color(2, 1, 0, 1, 0, 0, 0), datatables.BlackBook.Duration},
	{EntityFlag.FLAG_FEAR, Color(0.6, 0.4, 1.0, 1.0, 0, 0, 0), datatables.BlackBook.Duration},
	{EntityFlag.FLAG_BURN, Color(1, 1, 1, 1, 0.3, 0, 0), datatables.BlackBook.Duration},
	{EntityFlag.FLAG_SHRINK, Color(1, 1, 1, 1, 0, 0, 0), datatables.BlackBook.Duration},
	{EntityFlag.FLAG_BLEED_OUT, Color(1.25, 0.05, 0.15, 1, 0, 0, 0), datatables.BlackBook.Duration},
	{EntityFlag.FLAG_ICE, Color(1, 1, 3, 1, 0, 0, 0), datatables.BlackBook.Duration},
	{EntityFlag.FLAG_MAGNETIZED, Color(0.6, 0.4, 1.0, 1.0, 0, 0, 0), datatables.BlackBook.Duration},
	{EntityFlag.FLAG_BAITED, Color(0.7, 0.14, 0.1, 1, 0.3, 0, 0), datatables.BlackBook.Duration},
}

datatables.BG = {}
datatables.BG.FrameCount = 62
datatables.BG.Costume = Isaac.GetCostumeIdByPath("gfx/characters/bleedinggrimoire.anm2")


datatables.IgnoreAnimations = { -- ignore next animations while jumped/landed
	["WalkDown"] = true,
	["Hit"] = true,
	["PickupWalkDown"] = true,
	["Sad"] = true,
	["Happy"] = true,
	["WalkLeft"] = true,
	["WalkRight"] = true,
	["WalkUp"] = true,
}
datatables.TeleportAnimations = { -- teleport anims
	["TeleportUp"] = true,
	["TeleportDown"] = true,
}
datatables.StonEnemies = { -- crush stone enemies
	[EntityType.ENTITY_STONEY] = true,
	[EntityType.ENTITY_STONEHEAD] = true,
	[EntityType.ENTITY_QUAKE_GRIMACE] = true,
	[EntityType.ENTITY_BOMB_GRIMACE] = true,
}

datatables.TrollBombs = {
	[BombVariant.BOMB_TROLL] = true,
	[BombVariant.BOMB_SUPERTROLL] = true,
	[BombVariant.BOMB_GOLDENTROLL] = true,
}

datatables.RedScissors = {
	[BombVariant.BOMB_TROLL] = true,
	[BombVariant.BOMB_SUPERTROLL] = true,
	[BombVariant.BOMB_GOLDENTROLL] = true,
	[BombVariant.BOMB_GIGA] = true,
}

datatables.BellCurse = { -- bell curse turns next bombs into golden trollbombs
	[BombVariant.BOMB_TROLL] = true,
	[BombVariant.BOMB_SUPERTROLL] = true,
}

datatables.BannedBombs = { -- ignore next bombs
	[BombVariant.BOMB_DECOY]= true,
	[BombVariant.BOMB_TROLL]= true,
	[BombVariant.BOMB_SUPERTROLL]= true,
	[BombVariant.BOMB_GOLDENTROLL]= true,
	[BombVariant.BOMB_THROWABLE] = true,
	[BombVariant.BOMB_GIGA] = true,
	[BombVariant.BOMB_ROCKET] = true
}

datatables.NoBombTrace = {
	[BombVariant.BOMB_TROLL]= true,
	[BombVariant.BOMB_SUPERTROLL]= true,
	[BombVariant.BOMB_GOLDENTROLL]= true,
	[BombVariant.BOMB_THROWABLE] = true,
	[BombVariant.BOMB_ROCKET] = true,
	[BombVariant.BOMB_ROCKET_GIGA] = true,
}

datatables.GhostDataWisps = {
	[enums.Items.RedMirror] = CollectibleType.COLLECTIBLE_RED_KEY,
	[enums.Items.BlackBook] = CollectibleType.COLLECTIBLE_UNDEFINED,
	[enums.Items.MiniPony] = CollectibleType.COLLECTIBLE_MY_LITTLE_UNICORN,
	[enums.Items.LostMirror] = CollectibleType.COLLECTIBLE_GLASS_CANNON,
	[enums.Items.VHSCassette] = CollectibleType.COLLECTIBLE_EDENS_SOUL,
	[enums.Items.RubikDice] = CollectibleType.COLLECTIBLE_UNDEFINED,
	[enums.Items.RubikDiceScrambled0] = CollectibleType.COLLECTIBLE_UNDEFINED,
	[enums.Items.RubikDiceScrambled1] = CollectibleType.COLLECTIBLE_UNDEFINED,
	[enums.Items.RubikDiceScrambled2] = CollectibleType.COLLECTIBLE_UNDEFINED,
	[enums.Items.RubikDiceScrambled3] = CollectibleType.COLLECTIBLE_UNDEFINED,
	[enums.Items.RubikDiceScrambled4] = CollectibleType.COLLECTIBLE_UNDEFINED,
	[enums.Items.RubikDiceScrambled5] = CollectibleType.COLLECTIBLE_UNDEFINED,
	[enums.Items.LongElk] = CollectibleType.COLLECTIBLE_NECRONOMICON,
	[enums.Items.WhiteKnight] = CollectibleType.COLLECTIBLE_PONY,
	[enums.Items.BlackKnight] = CollectibleType.COLLECTIBLE_PONY,
	[enums.Items.FloppyDisk] = CollectibleType.COLLECTIBLE_EDENS_SOUL,
	[enums.Items.FloppyDiskFull] = CollectibleType.COLLECTIBLE_EDENS_SOUL,
	[enums.Items.ElderSign] = CollectibleType.COLLECTIBLE_PAUSE,
	[enums.Items.WitchPot] = CollectibleType.COLLECTIBLE_FORTUNE_COOKIE,
	[enums.Items.CosmicEncyclopedia] = CollectibleType.COLLECTIBLE_UNDEFINED,
	[enums.Items.BookMemory] = CollectibleType.COLLECTIBLE_ERASER,
	[enums.Items.SecretLoveLetter] = CollectibleType.COLLECTIBLE_KIDNEY_BEAN, -- triegger only on shot
	--[enums.Items.CosmicJam] = CollectibleType.COLLECTIBLE_LEMEGETON, -- give Lemegeton Wisp
	[enums.Items.CharonObol] = CollectibleType.COLLECTIBLE_IV_BAG, -- if have coin
	[enums.Items.AgonyBox] = CollectibleType.COLLECTIBLE_DULL_RAZOR, -- only on takeDmg
}

datatables.ActiveItemWisps = {
	[enums.Items.RedMirror] = CollectibleType.COLLECTIBLE_RED_KEY,
	[enums.Items.BlackBook] = CollectibleType.COLLECTIBLE_UNDEFINED,
	[enums.Items.MiniPony] = CollectibleType.COLLECTIBLE_MY_LITTLE_UNICORN,
	[enums.Items.LostMirror] = CollectibleType.COLLECTIBLE_GLASS_CANNON,
	[enums.Items.VHSCassette] = CollectibleType.COLLECTIBLE_EDENS_SOUL,
	[enums.Items.RubikDice] = CollectibleType.COLLECTIBLE_UNDEFINED,
	[enums.Items.RubikDiceScrambled0] = CollectibleType.COLLECTIBLE_UNDEFINED,
	[enums.Items.RubikDiceScrambled1] = CollectibleType.COLLECTIBLE_UNDEFINED,
	[enums.Items.RubikDiceScrambled2] = CollectibleType.COLLECTIBLE_UNDEFINED,
	[enums.Items.RubikDiceScrambled3] = CollectibleType.COLLECTIBLE_UNDEFINED,
	[enums.Items.RubikDiceScrambled4] = CollectibleType.COLLECTIBLE_UNDEFINED,
	[enums.Items.RubikDiceScrambled5] = CollectibleType.COLLECTIBLE_UNDEFINED,
	[enums.Items.LongElk] = CollectibleType.COLLECTIBLE_NECRONOMICON,
	[enums.Items.WhiteKnight] = CollectibleType.COLLECTIBLE_PONY,
	[enums.Items.BlackKnight] = CollectibleType.COLLECTIBLE_PONY,
	[enums.Items.FloppyDisk] = CollectibleType.COLLECTIBLE_EDENS_SOUL,
	[enums.Items.FloppyDiskFull] = CollectibleType.COLLECTIBLE_EDENS_SOUL,
	[enums.Items.ElderSign] = CollectibleType.COLLECTIBLE_PAUSE,
	[enums.Items.WitchPot] = CollectibleType.COLLECTIBLE_FORTUNE_COOKIE,
	[enums.Items.CosmicEncyclopedia] = CollectibleType.COLLECTIBLE_UNDEFINED,
	[enums.Items.BookMemory] = CollectibleType.COLLECTIBLE_ERASER,
	--[enums.Items.SecretLoveLetter] = CollectibleType.COLLECTIBLE_KIDNEY_BEAN, -- triegger only on shot
	--[enums.Items.CosmicJam] = CollectibleType.COLLECTIBLE_LEMEGETON, -- give Lemegeton Wisp
	--[enums.Items.CharonObol] = CollectibleType.COLLECTIBLE_IV_BAG, -- if have coin
	--[enums.Items.AgonyBox] = CollectibleType.COLLECTIBLE_DULL_RAZOR, -- only on takeDmg
}

datatables.DeliriumBeggarBan = {
[17] = true,
[33] = true,
[42] = true,
[44] = true,
[68] = true,
[96] = true,
[201] = true,
[202] = true,
[203] = true,
[212] = true,
[218] = true,
[235] = true,
[236] = true,
[286] = true,
[291] = true,
[302] = true,
[409] = true,
[802] = true,
[804] = true,
[809] = true,
[815] = true,
[831] = true,
[835] = true,
[852] = true,
[864] = true,
[877] = true,
[887] = true,
[893] = true,
[903] = true,
[915] = true,
[951] = true,
}

datatables.NadabData = {}
datatables.NadabData.CostumeHead = Isaac.GetCostumeIdByPath("gfx/characters/nadab_head.anm2")
datatables.NadabData.ExplosionCountdown = 30 -- so don't spam
datatables.NadabData.MrMegaDmgMultiplier = 0.75 -- dmg up when you pick Mr.Mega
datatables.NadabData.SadBombsFiredelay = -1.0 -- tears up when you pick up Sad bombs
datatables.NadabData.FastBombsSpeed = 1.0 -- speed up to 1.0 when you pick up fast bomb
datatables.NadabData.RingCapFrameCount = 10 -- ring cap delay to 2nd (3rd and etc. based on Ring Cap stack) explosion
datatables.NadabData.StickySpiderRadius = 30 -- spawn blue spiders in given radius from enemies. well, cause player is bomb, blue spiders can't be obtained from enemies by collision (you can, but I don't want to)
datatables.NadabData.BombBeggarSprites = { -- next animations trigger giving bomb, cause character don't have bombs
	['Idle'] = true,
	['PayNothing'] = true,
}
datatables.NadabData.Stats = {}
datatables.NadabData.Stats.DAMAGE = 1.2
datatables.NadabData.Stats.SPEED = -0.35

datatables.AbihuData = {}
datatables.AbihuData.CostumeHead = Isaac.GetCostumeIdByPath("gfx/characters/abihu_costume.anm2")
datatables.AbihuData.DamageDelay = 30
datatables.AbihuData.HoldBombDelay = 20
datatables.AbihuData.ChargeBar = Sprite()
datatables.AbihuData.ChargeBar:Load("gfx/ui/flame_chargebar.anm2", true)
datatables.AbihuData.Stats = {}
datatables.AbihuData.Stats.DAMAGE = 1.14286
datatables.AbihuData.Stats.SPEED = 1.0
datatables.AbihuData.Unlocked = false

datatables.UnbiddenData = {}
datatables.UnbiddenData.WispHP = 6
datatables.UnbiddenData.RadiusWisp = 100
datatables.UnbiddenData.Stats = {}
datatables.UnbiddenData.Stats.DAMAGE = 1.35
datatables.UnbiddenData.Stats.LUCK = -1

datatables.UnbiddenBData = {}
datatables.UnbiddenBData.DevilPrice = 15
datatables.UnbiddenBData.OptionPrice = 5
datatables.UnbiddenBData.DamageDelay = 6
datatables.UnbiddenBData.Knockback = 4
datatables.UnbiddenBData.TearVariant = TearVariant.MULTIDIMENSIONAL
datatables.UnbiddenBData.ChargeBar = Sprite()
datatables.UnbiddenBData.ChargeBar:Load("gfx/chargebar.anm2", true)
datatables.UnbiddenBData.Stats = {}
datatables.UnbiddenBData.Stats.DAMAGE = 1
datatables.UnbiddenBData.Stats.RANGE_M = 0.5
datatables.UnbiddenBData.Stats.LUCK = -3
datatables.UnbiddenBData.Stats.TRAR_FLAG = TearFlags.TEAR_WAIT | TearFlags.TEAR_CONTINUUM
datatables.UnbiddenBData.Stats.TEAR_COLOR = Color(0.5,1,2,1,0,0,0)
datatables.UnbiddenBData.Stats.LASER_COLOR = Color(1,1,1,1,-0.5,0.7,1)

datatables.NadabBody = {}
datatables.NadabBody.SpritePath = "gfx/familiar/nadabbody.png"

datatables.NadabData.BombMods = {
	[CollectibleType.COLLECTIBLE_FAST_BOMBS] = CacheFlag.CACHE_SPEED,
	[CollectibleType.COLLECTIBLE_SAD_BOMBS] = CacheFlag.CACHE_FIREDELAY,
	[CollectibleType.COLLECTIBLE_MR_MEGA] = CacheFlag.CACHE_DAMAGE,
	[CollectibleType.COLLECTIBLE_BOBBY_BOMB] = CacheFlag.CACHE_TEARFLAG,
}

datatables.BaconPancakes = {}
datatables.BaconPancakes.Luck = 2
datatables.BaconPancakes.Damage = 0.5
datatables.BaconPancakes.MaxFireDelay = 1.5
datatables.BaconPancakes.ShotSpeed = 0.2
datatables.BaconPancakes.Range = 100
datatables.BaconPancakes.MoveSpeed = 0.2

datatables.BabylonCandle = {}
datatables.BabylonCandle.RoomTypes = {
	[RoomType.ROOM_SHOP] = true,
	[RoomType.ROOM_TREASURE] = true,
	[RoomType.ROOM_MINIBOSS] = true,
	[RoomType.ROOM_BOSS] = true,
	[RoomType.ROOM_SUPERSECRET] = true,
	[RoomType.ROOM_SECRET] = true,
	[RoomType.ROOM_ARCADE] = true,
	[RoomType.ROOM_CURSE] = true,
	[RoomType.ROOM_CHALLENGE] = true,
	[RoomType.ROOM_LIBRARY] = true,
	[RoomType.ROOM_SACRIFICE] = true,
	--[RoomType.ROOM_DEVIL] = true,
	--[RoomType.ROOM_ANGEL] = true,
	--[RoomType.ROOM_DUNGEON] = true,
	[RoomType.ROOM_CHEST] = true,
	[RoomType.ROOM_ISAACS] = true,
	[RoomType.ROOM_BARREN] = true,
	[RoomType.ROOM_DICE] = true,
	--[RoomType.ROOM_BLACK_MARKET] = true,
	[RoomType.ROOM_ULTRASECRET] = true,
	--[RoomType.ROOM_BOSSRUSH] = true,
}

datatables.CopyPHD = {}
datatables.CopyPHD.DamageUP = {
[PillEffect.PILLEFFECT_HEALTH_DOWN] = true,
[PillEffect.PILLEFFECT_RANGE_DOWN] = true,
[PillEffect.PILLEFFECT_SPEED_DOWN] = true,
[PillEffect.PILLEFFECT_TEARS_DOWN] = true,
[PillEffect.PILLEFFECT_LUCK_DOWN] = true,
[PillEffect.PILLEFFECT_SHOT_SPEED_DOWN] = true,
}
datatables.CopyPHD.BlackHeart = {
[PillEffect.PILLEFFECT_BAD_TRIP] = true,
[PillEffect.PILLEFFECT_PARALYSIS] = true,
[PillEffect.PILLEFFECT_AMNESIA] = true,
[PillEffect.PILLEFFECT_WIZARD] = true,
[PillEffect.PILLEFFECT_ADDICTED] = true,
[PillEffect.PILLEFFECT_QUESTIONMARK] = true,
[PillEffect.PILLEFFECT_RETRO_VISION] = true,

}


EclipsedMod.datatables = datatables