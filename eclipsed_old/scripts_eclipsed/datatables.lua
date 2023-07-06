
local enums = require("scripts_eclipsed.enums")

local datatables = {}

datatables.SpecialCursesAvtice = true

--- LOCAL TABLES --
datatables.RedColor = Color(1.5,0,0,1,0,0,0) -- red color I guess
datatables.PinkColor = Color(2,0,0.7,1,0,0,0) -- pink color
datatables.TrinketDespawnTimer = 35 -- x>25; x=35 -- it will be removed
datatables.CurseChance = 0.1 -- chances to mod curses to apply
datatables.VoidThreshold = 0.15  -- chance to trigger void curse when entering room
datatables.JammingThreshold = 0.15 -- chance to trigger jamming curse after clearing room
datatables.PrideThreshold = 0.5 -- chance to become champion
datatables.BishopThreshold = 0.15 -- chance to trigger damage reduction
datatables.MisfortuneLuck = -5 -- -5 luck
datatables.FoolThreshold = 0.15 -- chance to trigger fool when entering room
datatables.DesolationThreshold = 0.5 -- chance to turn item into ItemWisp
datatables.MagicianThreshold = 0.25 -- chance to shoot homing projectile
datatables.MyUseFlags_Gene = UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC
datatables.MyUseFlags_Deli = UseFlag.USE_NOANIM | UseFlag.USE_MIMIC
datatables.completionInit = {
	all     = 0, heart	= 0, isaac	= 0, bbaby	= 0, satan	= 0, lamb	= 0,
	rush	= 0, hush	= 0, deli	= 0, mega	= 0, greed	= 0, mother	= 0, beast	= 0,}
datatables.completionFull = {
	all     = 2, heart	= 2, isaac	= 2, bbaby	= 2, satan	= 2, lamb	= 2,
	rush	= 2, hush	= 2, deli	= 2, mega	= 2, greed	= 2, mother	= 2, beast	= 2,}

datatables.challengesInit = {potato = 0, lobotomy = 0, magician = 0, beatmaker = 0, mongofamily = 0, all = 0} -- shovel=0,

datatables.challengesFull = {potato = 2, lobotomy = 2, magician = 2, beatmaker = 2, mongofamily = 2, all = 2} -- shovel=2,

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
datatables.UnbiddenBData.Stats.LUCK = -3
datatables.UnbiddenBData.Stats.TRAR_FLAG = TearFlags.TEAR_WAIT | TearFlags.TEAR_CONTINUUM
datatables.UnbiddenBData.Stats.TEAR_COLOR = Color(0.5,1,2,1,0,0,0)
datatables.UnbiddenBData.Stats.LASER_COLOR = Color(1,1,1,1,-0.5,0.7,1)

datatables.BellCurse = { -- bell curse turns next bombs into golden trollbombs
	[BombVariant.BOMB_TROLL] = true,
	[BombVariant.BOMB_SUPERTROLL] = true,
}

datatables.NoBombTrace = { -- do not trace this bombs (used for: when you reenters room, prevents adding bomb-effect to existing bombs what was placed before getting any mod bomb item)
	[BombVariant.BOMB_TROLL]= true,
	[BombVariant.BOMB_SUPERTROLL]= true,
	[BombVariant.BOMB_GOLDENTROLL]= true,
	[BombVariant.BOMB_THROWABLE] = true,
	[BombVariant.BOMB_ROCKET] = true,
	[BombVariant.BOMB_ROCKET_GIGA] = true,
}

datatables.ActiveItemWisps = {
	[enums.Items.RedMirror] = CollectibleType.COLLECTIBLE_RED_KEY,
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
}

datatables.TemporaryWisps = {
	[enums.Items.StoneScripture] = true,
	[enums.Items.GardenTrowel] = true,
}

datatables.QueueItemsCheck = {
	[enums.Items.GravityBombs] = true,
	[enums.Items.MidasCurse] = true,
	[enums.Items.RubberDuck] = true,
	[CollectibleType.COLLECTIBLE_BIRTHRIGHT] = true,
}
------------SLOTS--------------
datatables.ReplaceBeggarVariants = {
	[4] = true, --beggar
	[5] = true, --devil beggar
	[7] = true, --key master
	[9] = true, --bomb bum
	[13] = true, -- battery bum
	[18] = true -- rotten beggar
}

datatables.MongoBeggar= {}
datatables.MongoBeggar.ReplaceChance = 0.1 --chance to replace beggar
datatables.MongoBeggar.PityCounter = 6 --do something if beggar haven't done anything 7 times in a row
datatables.MongoBeggar.PrizeCounter = 6 --guaranteed to give leave after 6 activations
datatables.MongoBeggar.PrizeChance = 0.05 --prize chance
datatables.MongoBeggar.ActivateChance = 0.2 --activation chance

datatables.DeliriumBeggar = {}
datatables.DeliriumBeggar.ReplaceChance = 0.1
datatables.DeliriumBeggar.PityCounter = 6
datatables.DeliriumBeggar.ActivateChance = 0.33 --activation chance - charmed enemy (chance to activate)
datatables.DeliriumBeggar.PrizeChance = 0.05 --reward chance - charmed boss (chance after activation)
datatables.DeliriumBeggar.DeliPickupChance = 0.25 --delirium pickup chance (chance after activation)
------------PASSIVE------------
datatables.PandoraJar = {}
datatables.PandoraJar.CurseChance = 0.33

datatables.Eclipse = {}
datatables.Eclipse.DamageDelay = 6
datatables.Eclipse.DamageBoost = 1.0


datatables.MongoCells = {}
datatables.MongoCells.HeadlessCreepFrame = 8
datatables.MongoCells.DryBabyChance = 0.33
datatables.MongoCells.FartBabyChance = 0.33
datatables.MongoCells.FartBabyBeans = {CollectibleType.COLLECTIBLE_BEAN, CollectibleType.COLLECTIBLE_BUTTER_BEAN, CollectibleType.COLLECTIBLE_KIDNEY_BEAN}
datatables.MongoCells.DepressionCreepFrame = 8
datatables.MongoCells.DepressionLightChance = 0.33
datatables.MongoCells.BBFDamage = 100
datatables.MongoCells.FamiliarEffects = {
	steven = { CollectibleType.COLLECTIBLE_LITTLE_STEVEN, CollectibleType.COLLECTIBLE_SPOON_BENDER },
	harlequin = { CollectibleType.COLLECTIBLE_HARLEQUIN_BABY, CollectibleType.COLLECTIBLE_THE_WIZ },
	freezer = { CollectibleType.COLLECTIBLE_FREEZER_BABY, CollectibleType.COLLECTIBLE_URANUS },
	ghost = { CollectibleType.COLLECTIBLE_GHOST_BABY, CollectibleType.COLLECTIBLE_OUIJA_BOARD },
	abel = { CollectibleType.COLLECTIBLE_ABEL, CollectibleType.COLLECTIBLE_MY_REFLECTION },
	rainbow = { CollectibleType.COLLECTIBLE_RAINBOW_BABY, CollectibleType.COLLECTIBLE_FRUIT_CAKE },
	brimstone = { CollectibleType.COLLECTIBLE_LIL_BRIMSTONE, CollectibleType.COLLECTIBLE_BRIMSTONE },
	bandages = { CollectibleType.COLLECTIBLE_BALL_OF_BANDAGES, CollectibleType.COLLECTIBLE_MOMS_EYESHADOW, 1 },
	
	sissy = { CollectibleType.COLLECTIBLE_SISSY_LONGLEGS, CollectibleType.COLLECTIBLE_MOMS_WIG },
	buddyBox = { CollectibleType.COLLECTIBLE_BUDDY_IN_A_BOX, CollectibleType.COLLECTIBLE_FRUIT_CAKE },
	headless = { CollectibleType.COLLECTIBLE_HEADLESS_BABY, CollectibleType.COLLECTIBLE_ANEMIC },
	twistedPir = { CollectibleType.COLLECTIBLE_TWISTED_PAIR, CollectibleType.COLLECTIBLE_20_20 },
	mush = { CollectibleType.COLLECTIBLE_1UP, CollectibleType.COLLECTIBLE_GODS_FLESH },
	maggy = { CollectibleType.COLLECTIBLE_SISTER_MAGGY, CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL },
}
datatables.MongoCells.HiddenWispEffects = {
	haunt = { CollectibleType.COLLECTIBLE_LIL_HAUNT, CollectibleType.COLLECTIBLE_MOMS_PERFUME },
	abaddon = { CollectibleType.COLLECTIBLE_LIL_ABADDON, CollectibleType.COLLECTIBLE_MAW_OF_THE_VOID }, -- don't work
	loki = { CollectibleType.COLLECTIBLE_LIL_LOKI, CollectibleType.COLLECTIBLE_LOKIS_HORNS }, -- don't work
	monstro = { CollectibleType.COLLECTIBLE_LIL_MONSTRO, CollectibleType.COLLECTIBLE_MONSTROS_LUNG }, -- don't work
	gish = { CollectibleType.COLLECTIBLE_LITTLE_GISH, CollectibleType.COLLECTIBLE_BALL_OF_TAR }, -- don't work
	mysteryEgg = { CollectibleType.COLLECTIBLE_MYSTERY_EGG, CollectibleType.COLLECTIBLE_POKE_GO }, -- don't work
	multi = { CollectibleType.COLLECTIBLE_MULTIDIMENSIONAL_BABY, CollectibleType.COLLECTIBLE_CONTINUUM }, -- don't work
	acid = { CollectibleType.COLLECTIBLE_ACID_BABY, CollectibleType.COLLECTIBLE_PHD }, -- don't work
	spiderMod = { CollectibleType.COLLECTIBLE_SPIDER_MOD, CollectibleType.COLLECTIBLE_GUPPYS_EYE }, -- don't work
	seraph = { CollectibleType.COLLECTIBLE_SERAPHIM, CollectibleType.COLLECTIBLE_SACRED_HEART }, -- don't work
	bumbo = { CollectibleType.COLLECTIBLE_BUMBO, CollectibleType.COLLECTIBLE_DEEP_POCKETS }, -- don't work
	battery = { CollectibleType.COLLECTIBLE_CHARGED_BABY, CollectibleType.COLLECTIBLE_BATTERY }, -- don't work
	fate = { CollectibleType.COLLECTIBLE_FATES_REWARD, CollectibleType.COLLECTIBLE_FATE }, -- don't work
	kingBaby = { CollectibleType.COLLECTIBLE_KING_BABY, CollectibleType.COLLECTIBLE_GLITCHED_CROWN }, -- glitched don't work
	yolisten = { CollectibleType.COLLECTIBLE_YO_LISTEN, CollectibleType.COLLECTIBLE_XRAY_VISION }, -- don't work
	depression = { CollectibleType.COLLECTIBLE_DEPRESSION, CollectibleType.COLLECTIBLE_AQUARIUS }, -- don't work
	bobby = { CollectibleType.COLLECTIBLE_BROTHER_BOBBY, CollectibleType.COLLECTIBLE_EPIPHORA }, -- don't work
	robo = { CollectibleType.COLLECTIBLE_ROBO_BABY, CollectibleType.COLLECTIBLE_TECHNOLOGY }, -- don't work
	robo2 = { CollectibleType.COLLECTIBLE_ROBO_BABY_2, CollectibleType.COLLECTIBLE_TECHNOLOGY_2 }, -- don't work
	rotten = { CollectibleType.COLLECTIBLE_ROTTEN_BABY, CollectibleType.COLLECTIBLE_MULLIGAN }, -- don't work
	--guardian = {CollectibleType.COLLECTIBLE_GUARDIAN_ANGEL, CollectibleType.},
	--prism = {CollectibleType.COLLECTIBLE_ANGELIC_PRISM, CollectibleType.},
	--seals = {CollectibleType.COLLECTIBLE_7_SEALS, CollectibleType.},
	demonBaby = { CollectibleType.COLLECTIBLE_DEMON_BABY, CollectibleType.COLLECTIBLE_MARKED }, -- don't work
	botFly = { CollectibleType.COLLECTIBLE_BOT_FLY, CollectibleType.COLLECTIBLE_LOST_CONTACT }, -- don't work
	boiled = { CollectibleType.COLLECTIBLE_BOILED_BABY, CollectibleType.COLLECTIBLE_HAEMOLACRIA }, -- don't work
	bloodPuppy = { CollectibleType.COLLECTIBLE_BLOOD_PUPPY, CollectibleType.COLLECTIBLE_CHARM_VAMPIRE }, -- don't work
	leech = { CollectibleType.COLLECTIBLE_LEECH, CollectibleType.COLLECTIBLE_CHARM_VAMPIRE }, -- don't work
}

datatables.MewGen = {}
datatables.MewGen.ActivationTimer = 150 -- activate it after 5 seconds
datatables.MewGen.RechargeTimer = 90 -- reactivate telekinesis every 3 seconds (90 frames)

datatables.DMS = {}
datatables.DMS.Chance = 0.25 -- chance to spawn purgatory soul after killing enemy

datatables.RedLotus = {}
datatables.RedLotus.DamageUp = 1.0 --  red lotus X flat damage up after removing broken heart

datatables.Viridian = {} -- sprite:RenderLayer(LayerId, Position, TopLeftClamp, BottomRightClamp)
datatables.Viridian.FlipOffsetY = 34

datatables.Limb = {}
datatables.Limb.InvFrames = 24  -- frames count after death when you are invincible

datatables.RedButton = {}
datatables.RedButton.PressCount = 0 -- press counter
datatables.RedButton.Limit = 66 -- limit
datatables.RedButton.SpritePath = "gfx/grid/grid_redbutton.png"
datatables.RedButton.KillButtonChance = 0.98 --99 -- actually 1%
datatables.RedButton.EventButtonChance = 0.5 --50 -- 50/50% chance of spawning event button (if EventButtonChance = 60, actual chance is 40%)
datatables.RedButton.VarData = 999 -- data to check right grid entity

datatables.MidasCurse = {}
datatables.MidasCurse.FreezeTime = 10000 -- midas freeze timer
datatables.MidasCurse.MaxGold = 1.0 -- for check ?? (idk what is this for)
datatables.MidasCurse.MinGold = 0.1 -- for check ??
datatables.MidasCurse.TurnGoldChance = 1.0 -- with black candle is 0.1
--datatables.MidasCurse.TearColor = Color(2, 1, 0, 1, 0, 0, 0)

datatables.RubberDuck = {}
datatables.RubberDuck.MaxLuck = 20 -- add luck when picked up (stackable)

datatables.MeltedCandle = {}
datatables.MeltedCandle.TearChance = 0.8 -- random + player.Luck > tearChance
datatables.MeltedCandle.TearFlags = TearFlags.TEAR_FREEZE | TearFlags.TEAR_BURN -- tear effects
datatables.MeltedCandle.TearColor =  Color(2, 2, 2, 1, 0.196, 0.196, 0.196) --spider bite color
datatables.MeltedCandle.FrameCount = 92 -- duration of freeze

datatables.VoidKarma = {}
datatables.VoidKarma.DamageUp = 0.5 -- add given values to player each time entering new level
datatables.VoidKarma.TearsUp = 1.0
datatables.VoidKarma.RangeUp = 40
datatables.VoidKarma.ShotSpeedUp = 0.1
datatables.VoidKarma.SpeedUp = 0.1
datatables.VoidKarma.LuckUp = 0.5
datatables.VoidKarma.EvaCache = CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_SHOTSPEED | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_SPEED | CacheFlag.CACHE_LUCK

datatables.CompoBombs = {}
datatables.CompoBombs.BasicCountdown = 44 -- no way to get placed bomb countdown. meh. but it will explode anyway after 44 frames
datatables.CompoBombs.ShortCountdown = 20 -- if player has short fuse trinket
datatables.CompoBombs.FetusCountdown = 30 -- 30 for fetus
datatables.CompoBombs.DimensionX = -22 -- move in X dimension (offset)
datatables.CompoBombs.Baned = { -- don't add this effect on next bombs
	[BombVariant.BOMB_DECOY]= true,
	[BombVariant.BOMB_TROLL]= true,
	[BombVariant.BOMB_SUPERTROLL]= true,
	[BombVariant.BOMB_GOLDENTROLL]= true,
	[BombVariant.BOMB_THROWABLE] = true,
	[BombVariant.BOMB_GIGA] = true,
	[BombVariant.BOMB_ROCKET] = true
}

datatables.MirrorBombs = {}
datatables.MirrorBombs.BasicCountdown = 44 -- basic explosion countdown (copy compo bombs shortfuse and fetus countdown)
datatables.MirrorBombs.Ban = { -- don't add this effect on next bombs
	[BombVariant.BOMB_TROLL]= true,
	[BombVariant.BOMB_SUPERTROLL]= true,
	[BombVariant.BOMB_GOLDENTROLL]= true,
}

datatables.FrostyBombs = {} -- sprite:ReplaceSpritesheet ( int LayerId, string PngFilename )
datatables.FrostyBombs.NancyChance = 0.1 -- chance to add bomb effect if you have nancy bombs
datatables.FrostyBombs.FetusChance = 0.25 -- chance to add bomb effect to fetus bombs + player.Luck
datatables.FrostyBombs.Flags = TearFlags.TEAR_SLOW | TearFlags.TEAR_ICE
datatables.FrostyBombs.Ban = { -- don't affect next bombs (not used)
	[BombVariant.BOMB_TROLL]= true,
	[BombVariant.BOMB_SUPERTROLL]= true,
	[BombVariant.BOMB_GOLDENTROLL]= true,
}

datatables.GravityBombs = {}
datatables.GravityBombs.BlackHoleEffect = Isaac.GetEntityVariantByName("BlackHoleBombsEffect") -- black hole effect
datatables.GravityBombs.GigaBombs = 1
datatables.GravityBombs.AttractorForce = 50 -- basic force
datatables.GravityBombs.AttractorRange = 250 -- basic range
datatables.GravityBombs.AttractorGridRange = 5 -- basic range
datatables.GravityBombs.MaxRange = 2500 -- max range for attraction
datatables.GravityBombs.MaxForce = 15 -- max force for attraction
datatables.GravityBombs.MaxGrid = 200 -- max range for grid destroyer
datatables.GravityBombs.IterRange = 15 -- increase attraction range
datatables.GravityBombs.IterForce = 0.5 -- increase attraction force
datatables.GravityBombs.IterGrid = 2.5 -- increase grid destroy range
datatables.GravityBombs.NancyChance = 0.1 -- chance to add bomb effect if you have Nancy bombs
datatables.GravityBombs.FetusChance = 0.25 -- chance to add bomb effect to dr.fetus bombs
datatables.GravityBombs.Ban = { -- don't affect this bombs (not used)
	[BombVariant.BOMB_TROLL]= true,
	[BombVariant.BOMB_SUPERTROLL]= true,
	[BombVariant.BOMB_GOLDENTROLL]= true,
}
datatables.DiceBombs = {}
datatables.DiceBombs.ChestsTable = {50,51,52,53,54,55,56,57,58,60}
datatables.DiceBombs.PickupsTable = {10, 20, 30, 40, 50, 69, 70, 90, 300, 350}
datatables.DiceBombs.NancyChance = 0.05
datatables.DiceBombs.FetusChance = 0.25
datatables.DiceBombs.Ban = { -- don't affect this bombs (not used)
	[BombVariant.BOMB_TROLL]= true,
	[BombVariant.BOMB_SUPERTROLL]= true,
	[BombVariant.BOMB_GOLDENTROLL]= true,
}
datatables.BatteryBombs = {}
datatables.BatteryBombs.NancyChance = 0.1
datatables.BatteryBombs.FetusChance = 0.25
datatables.BatteryBombs.Ban = { -- don't affect this bombs (not used?)
	[BombVariant.BOMB_TROLL]= true,
	[BombVariant.BOMB_SUPERTROLL]= true,
	[BombVariant.BOMB_GOLDENTROLL]= true,
}
datatables.DeadBombs = {}
datatables.DeadBombs.ChanceBony = 0.16 -- chance to spawn friendly monster
datatables.DeadBombs.NancyChance = 0.1
datatables.DeadBombs.FetusChance = 0.25
datatables.DeadBombs.Ban = { -- don't affect this bombs (not used)
	[BombVariant.BOMB_TROLL]= true,
	[BombVariant.BOMB_SUPERTROLL]= true,
	[BombVariant.BOMB_GOLDENTROLL]= true,
}

--- FAMILIARS --

datatables.NadabBrain = {}
datatables.NadabBrain.Variant = Isaac.GetEntityVariantByName("NadabBrain")
datatables.NadabBrain.Speed = 3.75
datatables.NadabBrain.Respawn = 300
datatables.NadabBrain.MaxDistance = 150
datatables.NadabBrain.BurnTime = 42
datatables.NadabBrain.CollisionDamage = 3.5

datatables.Lililith = {}
datatables.Lililith.Variant = Isaac.GetEntityVariantByName("Lililith")
datatables.Lililith.GenAfterRoom = 7 -- spawn baby after every X room.

datatables.AbihuFam = {}
datatables.AbihuFam.Variant = Isaac.GetEntityVariantByName("AbihuFam")
datatables.AbihuFam.Subtype = 2 -- 0 - idle, 1 - walking
datatables.AbihuFam.CollisionTime = 44 -- collision delay
datatables.AbihuFam.SpawnRadius = 50 -- spawn radius of fire jets when get damage (with bffs)
datatables.AbihuFam.BurnTime = 42 -- enemy burn time

datatables.RedBag = {}
datatables.RedBag.Variant = Isaac.GetEntityVariantByName("Red Bag")
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

--- TRINKETS --

datatables.QueenSpades = {}
datatables.QueenSpades.Chance = 0.33 -- chance to spawn purple portal after clearing room

datatables.XmasLetter = {}
datatables.XmasLetter.Chance = 0.5 -- chance to activate cookie when entering room

datatables.AbyssCart = {}
datatables.AbyssCart.NoRemoveChance = 0.5 --this value * (trinket multiplier-1) -- chance to not be removed after triggering
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

datatables.RedScissors = {}
datatables.RedScissors.GigaBombsSplitNum = 5
datatables.RedScissors.NormalReplaceFrame = 58 -- replace troll bombs on this frame
datatables.RedScissors.GigaReplaceFrame = 86 -- replace giga bombs on this frame
datatables.RedScissors.TrollBombs = { -- replace next bombs
	[BombVariant.BOMB_TROLL] = true,
	[BombVariant.BOMB_SUPERTROLL] = true,
	[BombVariant.BOMB_GOLDENTROLL] = true,
	[BombVariant.BOMB_SMALL] = true,
	[BombVariant.BOMB_BRIMSTONE] = true,
	[BombVariant.BOMB_GIGA] = true,
}

datatables.MilkTeeth = {}
datatables.MilkTeeth.CoinChance = 0.15 -- 0.3 golden/mombox -- 0.5 golden+mombox
datatables.MilkTeeth.CoinDespawnTimer = 75  -- remove coin on == 0

datatables.TeaBag = {}
datatables.TeaBag.Radius = 100
datatables.TeaBag.PoisonSmoke = EffectVariant.SMOKE_CLOUD -- remove smoke clouds

datatables.BinderClip = {}
datatables.BinderClip.DoublerChance = 0.15

datatables.DeadEgg = {}
datatables.DeadEgg.Timeout = 150

datatables.Penance = {}
datatables.Penance.Timeout = 10
datatables.Penance.Chance = 0.16
datatables.Penance.LaserVariant = 5
datatables.Penance.Effect = EffectVariant.REDEMPTION
datatables.Penance.Color = Color(1.25, 0.05, 0.15, 0.5)

--- ACTIVE --

datatables.SecretLoveLetter = {}
datatables.SecretLoveLetter.TearVariant = TearVariant.CHAOS_CARD --Isaac.GetEntityVariantByName("Love Letter Tear")
datatables.SecretLoveLetter.SpritePath = "gfx/LoveLetterTear.png"
datatables.SecretLoveLetter.BannedEnemies = {
	[260] = true, -- lil ghosts.  for haunt boos, cause he just don't switch to 2nd phase
}

datatables.WitchPot = {}
datatables.WitchPot.KillThreshold = 0.1 -- 0.1 actual chance
datatables.WitchPot.GulpThreshold = 0.5 -- 0.4
datatables.WitchPot.SpitThreshold = 0.9 -- 0.4
--datatables.WitchPot.RollThreshold = 1 -- 0.1
datatables.WitchPot.SpitChance = 0.4 -- 0.4

datatables.ElderSign = {}
datatables.ElderSign.Pentagram = EffectVariant.HERETIC_PENTAGRAM --EffectVariant.PENTAGRAM_BLACKPOWDER
datatables.ElderSign.Timeout = 20
datatables.ElderSign.AuraRange = 60

datatables.WhiteKnight = {}
datatables.WhiteKnight.Costume = NullItemID.ID_REVERSE_CHARIOT_ALT
--datatables.WhiteKnight.Costume = NullItemID.ID_REVERSE_CHARIOT_ALT --Isaac.GetCostumeIdByPath("gfx/characters/whiteknight.anm2")

datatables.BlackKnight = {}
datatables.BlackKnight.Costume = Isaac.GetCostumeIdByPath("gfx/characters/knightmare.anm2")
datatables.BlackKnight.Target = Isaac.GetEntityVariantByName("kTarget")
datatables.BlackKnight.DoorRadius = 40 -- distance in which auto-enter door
datatables.BlackKnight.BlastDamage = 75 -- blast damage when land
datatables.BlackKnight.BlastRadius = 50 -- areas where blast affects
datatables.BlackKnight.BlastKnockback = 30 -- knockback
datatables.BlackKnight.PickupDistance = 30 -- auto-pickup range
datatables.BlackKnight.InvFrames = 120 -- inv frames after using item
datatables.BlackKnight.IgnoreAnimations = { -- ignore next animations while jumped/landed
	["WalkDown"] = true,
	["Hit"] = true,
	["PickupWalkDown"] = true,
	["Sad"] = true,
	["Happy"] = true,
	["WalkLeft"] = true,
	["WalkRight"] = true,
	["WalkUp"] = true,
}
datatables.BlackKnight.TeleportAnimations = { -- teleport anims
	["TeleportUp"] = true,
	["TeleportDown"] = true,
}
datatables.BlackKnight.StonEnemies = { -- crush stone enemies
	[EntityType.ENTITY_STONEY] = true,
	[EntityType.ENTITY_STONEHEAD] = true,
	[EntityType.ENTITY_QUAKE_GRIMACE] = true,
	[EntityType.ENTITY_BOMB_GRIMACE] = true,
}
datatables.BlackKnight.ChestVariant = { -- chests
	[PickupVariant.PICKUP_BOMBCHEST] = true,
	[PickupVariant.PICKUP_LOCKEDCHEST] = true,
	[PickupVariant.PICKUP_MEGACHEST] = true,
	[PickupVariant.PICKUP_REDCHEST] = true,
	[PickupVariant.PICKUP_CHEST] = true,
	[PickupVariant.PICKUP_SPIKEDCHEST] = true,
	[PickupVariant.PICKUP_ETERNALCHEST] = true,
	[PickupVariant.PICKUP_MIMICCHEST] = true,
	[PickupVariant.PICKUP_OLDCHEST] = true,
	[PickupVariant.PICKUP_WOODENCHEST] = true,
	[PickupVariant.PICKUP_HAUNTEDCHEST] = true,
}

datatables.LongElk = {}
datatables.LongElk.InvFrames = 24  -- frames count when you invincible (not used)
datatables.LongElk.BoneSpurTimer = 18  -- frames count after which bone spur can be spawned
datatables.LongElk.NumSpur = 5 -- number of bone spurs after which oldest bone spur will be removed/killed: removeTimer = (BoneSpurTimer * NumSpur)
datatables.LongElk.Costume = Isaac.GetCostumeIdByPath("gfx/characters/longelk.anm2") --longelk
datatables.LongElk.Damage = 400
datatables.LongElk.TeleDelay = 40

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

datatables.BG = {} -- bleeding grimoire
datatables.BG.FrameCount = 62 -- frame count to remove bleeding from enemies (bleeding will be removed on 0, it wouldn't apply anew until framecount == -25)
datatables.BG.Costume = Isaac.GetCostumeIdByPath("gfx/characters/bleedinggrimoire.anm2")

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

datatables.FloppyDisk = {}
datatables.FloppyDisk.MissingNo = true -- add missingNo if not found saved item

datatables.MiniPony = {}
datatables.MiniPony.Costume = Isaac.GetCostumeIdByPath("gfx/characters/minipony.anm2")
datatables.MiniPony.MoveSpeed = 1.5 -- locked speed while holding

datatables.KeeperMirror = {}
datatables.KeeperMirror.Target = Isaac.GetEntityVariantByName("mTarget")
datatables.KeeperMirror.TargetRadius = 10
datatables.KeeperMirror.TargetTimeout = 80 -- target will be removed when == 0. spawn coin
datatables.KeeperMirror.RedHeart = 3 -- price of items
datatables.KeeperMirror.HalfHeart = 2
datatables.KeeperMirror.Collectible = 15
datatables.KeeperMirror.NormalPickup = 5
datatables.KeeperMirror.DoublePickup = 7
datatables.KeeperMirror.DoubleHeart = 6
datatables.KeeperMirror.RKey = 99
datatables.KeeperMirror.MicroBattery = 3
datatables.KeeperMirror.MegaBattery = 7
datatables.KeeperMirror.GrabBag = 7
datatables.KeeperMirror.GiantPill = 7

datatables.StrangeBox = {}
datatables.StrangeBox.Variants = { -- pickup variants
	PickupVariant.PICKUP_HEART,
	PickupVariant.PICKUP_COIN,
	PickupVariant.PICKUP_KEY,
	PickupVariant.PICKUP_BOMB,
	PickupVariant.PICKUP_CHEST,
	PickupVariant.PICKUP_BOMBCHEST,
	PickupVariant.PICKUP_SPIKEDCHEST,
	PickupVariant.PICKUP_ETERNALCHEST,
	PickupVariant.PICKUP_MIMICCHEST,
	PickupVariant.PICKUP_OLDCHEST,
	PickupVariant.PICKUP_WOODENCHEST,
	PickupVariant.PICKUP_MEGACHEST,
	PickupVariant.PICKUP_HAUNTEDCHEST,
	PickupVariant.PICKUP_LOCKEDCHEST,
	PickupVariant.PICKUP_GRAB_BAG,
	PickupVariant.PICKUP_REDCHEST,
	PickupVariant.PICKUP_PILL,
	PickupVariant.PICKUP_LIL_BATTERY,
	PickupVariant.PICKUP_TAROTCARD,
	PickupVariant.PICKUP_TRINKET
}

datatables.CharonObol = {}
datatables.CharonObol.Timeout = 360

datatables.Lobotomy = {}

datatables.HeartTransplant = {}
datatables.HeartTransplant.ChargeBar = Sprite()
datatables.HeartTransplant.ChargeBar:Load("gfx/ui/heartbeat_chargebar.anm2", true)
datatables.HeartTransplant.DischargeDelay = 15
datatables.HeartTransplant.ChainValue = {
	{0, 0, 0.0, 1}, -- damage multiplier, tears up, speed up, charge speed
	{0.0, 0, 0.1, 1},
	{0.1, 0, 0.15, 2},
	{0.1, -0.25, 0.2, 2},
	{0.2, -0.25, 0.3, 3},
	{0.25, -0.5, 0.4, 3},
	{0.3, -0.5, 0.5, 4},
	{0.6, -1, 0.6, 4},
	{0.5, -1, 0.7, 5},
	{0.8, -1.5, 0.8, 5},
	{0.8, -1.5, 0.9, 6},
	{1.0, -2, 1, 6},
}

--- CARDS --

datatables.ExplodingKittens = {}
datatables.ExplodingKittens.ActivationTimer = 120  -- 300 frames, 10 seconds
datatables.ExplodingKittens.BombKards = {
	[enums.Pickups.KittenBomb] = true,
	[enums.Pickups.KittenBomb2] = true,
}

datatables.DeliObject = {}
datatables.DeliObject.CycleTimer = 150 -- 30 frames ~ 1 second
datatables.DeliObject.Chance = 0.1
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
datatables.DeliObject.TrollCBombChance = 0.1
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

datatables.MultiCast = {}
datatables.MultiCast.NumWisps = 3 -- multi cast card number of wisps to spawn

datatables.Corruption = {}
datatables.Corruption.CostumeHead = Isaac.GetCostumeIdByPath("gfx/characters/corruptionhead.anm2")

datatables.Offering = {}
datatables.Offering.DamageNum = 2 -- take num heart damage (2 == full heart)

datatables.OblivionCard = {}
datatables.OblivionCard.TearVariant =  TearVariant.CHAOS_CARD --Isaac.GetEntityVariantByName("Oblivion Card Tear")--
datatables.OblivionCard.SpritePath = "gfx/oblivioncardtear.png"
datatables.OblivionCard.PoofColor = Color(0.5,1,2,1,0,0,0) -- light blue

datatables.Apocalypse = {}
datatables.Apocalypse.Room = nil -- room where it was used (room index)
datatables.Apocalypse.RNG = nil -- rng of card

datatables.KingChess = {}
datatables.KingChess.RadiusStonePoop = 40
datatables.KingChess.Radius = 48 -- 50 >= x >= 45

datatables.InfiniteBlades = {}
datatables.InfiniteBlades.newSpritePath = "gfx/effects/effect_momsknife.png"
datatables.InfiniteBlades.MaxNumber = 7 -- max number of knife tears
datatables.InfiniteBlades.VelocityMulti = 15 -- velocity multiplier
datatables.InfiniteBlades.DamageMulti = 3.0 -- deal multiplied damage (player.Damage * DamageMulti)

datatables.DeuxEx = {}
datatables.DeuxEx.LuckUp = 100 -- value of luck to add

datatables.BannedCard = {}
datatables.BannedCard.NumCards = 2
datatables.BannedCard.Chance = 0.01

datatables.RubikCubelet = {}
datatables.RubikCubelet.TriggerChance = 0.33

datatables.GhostGem = {}
datatables.GhostGem.NumSouls = 4

--datatables.ZeroStoneUsed = false

datatables.RedPills = {}
--datatables.RedPills.RedEffect = Isaac.GetPillEffectByName("Side effects?") -- "Ultra-reality"
datatables.RedPills.DamageUp = 10.8 -- dmg up
datatables.RedPills.HorseDamageUp = 2 * datatables.RedPills.DamageUp
datatables.RedPills.DamageDown = 0.00001 -- init damage down by time (red stew effect)
datatables.RedPills.DamageDownTick = 0.00001 -- increment of DamageDown
datatables.RedPills.WavyCap = 1 -- layers of Wavy Cap effect. will be saved until DamageUp > 0
datatables.RedPills.HorseWavyCap = 2 * datatables.RedPills.WavyCap

datatables.DefuseCardBombs = {
	[BombVariant.BOMB_TROLL] = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_NORMAL},
	[BombVariant.BOMB_SUPERTROLL] = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_DOUBLEPACK},
	[BombVariant.BOMB_GOLDENTROLL] = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_GOLDEN},
	[BombVariant.BOMB_GIGA] = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_GIGA},
	[BombVariant.BOMB_THROWABLE] = {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_THROWABLEBOMB, 0},
}

datatables.CURSE_COLUMNS = 8
datatables.CURSE_SPRITE_SCALE = 16
datatables.CurseHorizontalOffset = 240 -- X vector dimension offset
datatables.CurseVerticalOffset = 12 -- Y dimension offset
datatables.CurseIconOpacity = 1 -- Visibility

datatables.CurseIcons = Sprite()
datatables.CurseIcons:Load("gfx/curse_icons/eclipsed_curse_icon.anm2", true)


datatables.countVHS = 2
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

datatables.GoldenEggChance = 0.33


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

datatables.CodexAnimarumWispChance = 0.5

datatables.NirlyCap = 5
datatables.NirlyOK = {
[0] = true,
[1] = true,
[3] = true,
[5] = true,
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

datatables.LockedGrimoireWispChance = 0.25
datatables.LockedGrimoireChests = {
	{PickupVariant.PICKUP_CHEST, 1},
	{PickupVariant.PICKUP_LOCKEDCHEST, 0.5},
	{PickupVariant.PICKUP_REDCHEST, 0.15},
	{PickupVariant.PICKUP_OLDCHEST, 0.15},
	{PickupVariant.PICKUP_WOODENCHEST, 0.15},
	{PickupVariant.PICKUP_MEGACHEST, 0.05},
}

datatables.UnbiidenBannedCurses = {
[enums.Curses.Poverty] = true,
[enums.Curses.Desolation] = true,
[enums.Curses.Montezuma] = true, 
}

datatables.WarHandChance = 0.16


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

return datatables
