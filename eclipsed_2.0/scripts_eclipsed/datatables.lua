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

datatables.SpecialCursesAvtice = true
datatables.RedColor = Color(1.5,0,0,1,0,0,0)
datatables.PinkColor = Color(2,0,0.7,1,0,0,0)
datatables.MisfortuneLuck = -5

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

datatables.AbihuFam = {}
datatables.AbihuFam.Subtype = 2

datatables.RubikCubelet = {}
datatables.RubikCubelet.TriggerChance = 0.33

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

datatables.MiniPony = {} -- items.xml - addcostumeonpickup="true"
--datatables.MiniPony.Costume = Isaac.GetCostumeIdByPath("gfx/characters/minipony.anm2")
datatables.MiniPony.MoveSpeed = 1.5 -- locked speed while holding

datatables.Eclipse = {}
datatables.Eclipse.DamageDelay = 6
datatables.Eclipse.DamageBoost = 1.0

datatables.MongoCells = {}
datatables.MongoCells.CreepFrame = 8
datatables.MongoCells.OnHurtChance = 0.33
datatables.MongoCells.FartBabyBeans = {CollectibleType.COLLECTIBLE_BEAN, CollectibleType.COLLECTIBLE_BUTTER_BEAN, CollectibleType.COLLECTIBLE_KIDNEY_BEAN}
datatables.MongoCells.ExplosionDamage = 100

datatables.ExplodingKittens = {}
datatables.ExplodingKittens.ActivationTimer = 120  -- 4 sec.  30 frames = 1 second
datatables.ExplodingKittens.BombKards = {
	[EclipsedMod.enums.Pickups.KittenBomb] = true,
	[EclipsedMod.enums.Pickups.KittenBomb2] = true,
}

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
datatables.KeeperMirror.PoofColor = Color(0,1.5,1.3)

datatables.SecretLoveLetter = {}
datatables.SecretLoveLetter.TearVariant = TearVariant.CHAOS_CARD --Isaac.GetEntityVariantByName("Love Letter Tear")
datatables.SecretLoveLetter.SpritePath = "gfx/LoveLetterTear.png"
datatables.SecretLoveLetter.BannedEnemies = {
	[260] = true, -- lil ghosts.  for haunt boos, cause he just don't switch to 2nd phase
}

datatables.NirlyCap = 5
datatables.NirlyOK = {
[ItemConfig.CARDTYPE_TAROT] = true,
[ItemConfig.CARDTYPE_SUIT] = true,
[ItemConfig.CARDTYPE_SPECIAL] = true,
[ItemConfig.CARDTYPE_TAROT_REVERSE] = true,
}

datatables.RubberDuck = {}
datatables.RubberDuck.MaxLuck = 20

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

datatables.LongElk = {}
datatables.LongElk.InvFrames = 24  -- frames count when you invincible
datatables.LongElk.BoneSpurTimer = 18  -- frames count after which bone spur can be spawned
datatables.LongElk.NumSpur = 5 -- number of bone spurs after which oldest bone spur will be removed/killed: removeTimer = (BoneSpurTimer * NumSpur)
--datatables.LongElk.Costume = Isaac.GetCostumeIdByPath("gfx/characters/longelk.anm2") --longelk -- items.xml - addcostumeonpickup="true"
datatables.LongElk.Damage = 400
datatables.LongElk.TeleDelay = 40

EclipsedMod.datatables = datatables