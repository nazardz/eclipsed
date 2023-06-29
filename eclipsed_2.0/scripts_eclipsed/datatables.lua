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

datatables.OblivionCard = {}
datatables.OblivionCard.SpritePath = "gfx/oblivioncardtear.png"

datatables.DeliObject = {}
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
datatables.RedBag.GenAfterRoom = 1 -- general (for red poop)
datatables.RedBag.RedPoopChance = 0.05 -- chance to spawn red poop
datatables.RedBag.RedPickups = { -- possible items
	{PickupVariant.PICKUP_THROWABLEBOMB, 0, 1}, -- varitant, subtype, generation delay (how many room need to be cleared to activate it again after spawning this pickup)
	{PickupVariant.PICKUP_HEART, HeartSubType.HEART_FULL, 3},
	{PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALF, 2},
	{PickupVariant.PICKUP_HEART, HeartSubType.HEART_DOUBLEPACK, 4},
	{PickupVariant.PICKUP_HEART, HeartSubType.HEART_SCARED, 3},
	{PickupVariant.PICKUP_TAROTCARD, Card.CARD_DICE_SHARD, 6},
	{PickupVariant.PICKUP_TAROTCARD, Card.CARD_CRACKED_KEY, 6},
	{PickupVariant.PICKUP_TAROTCARD, enums.Pickups.RedPill, 2},
	{PickupVariant.PICKUP_TAROTCARD, enums.Pickups.RedPillHorse, 4},
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
	[enums.Items.enums.Items.TetrisDice_full] = true,
}

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

EclipsedMod.datatables = datatables