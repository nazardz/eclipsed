local enums = {}

enums.Characters = {}
enums.Items = {}
enums.Trinkets = {}
enums.Pickups = {}
enums.Challenges = {}
enums.Curses = {}
enums.CurseText = {} -- idk why show_curse name when adding curse not works, dumb idea actually
enums.CurseIconsList = {}
enums.Slots = {}
enums.Familiars = {}
enums.Effects = {}

--- PLAYERS --

enums.Characters.Nadab = Isaac.GetPlayerTypeByName("Nadab", false)
enums.Characters.Abihu = Isaac.GetPlayerTypeByName("Abihu", true)
enums.Characters.Unbidden = Isaac.GetPlayerTypeByName("Unbidden", false)
enums.Characters.UnbiddenB = Isaac.GetPlayerTypeByName("Unbidden ", true)

--- COLLECTIBLES --

enums.Items.FloppyDisk = Isaac.GetItemIdByName("Floppy Disk")
enums.Items.FloppyDiskFull = Isaac.GetItemIdByName("Floppy Disk ")
enums.Items.RedMirror = Isaac.GetItemIdByName("Red Mirror")
enums.Items.RedLotus = Isaac.GetItemIdByName("Red Lotus")
enums.Items.MidasCurse = Isaac.GetItemIdByName("Curse of the Midas")
enums.Items.RubberDuck = Isaac.GetItemIdByName("Duckling")
enums.Items.IvoryOil = Isaac.GetItemIdByName("Ivory Oil")
enums.Items.BlackKnight = Isaac.GetItemIdByName("Black Knight")
enums.Items.WhiteKnight = Isaac.GetItemIdByName("White Knight")
enums.Items.KeeperMirror = Isaac.GetItemIdByName("Moonlighter")
enums.Items.RedBag = Isaac.GetItemIdByName("Red Bag")
enums.Items.MeltedCandle = Isaac.GetItemIdByName("Melted Candle")
enums.Items.MiniPony = Isaac.GetItemIdByName("Unicorn")
enums.Items.StrangeBox = Isaac.GetItemIdByName("Strange Box")
enums.Items.RedButton = Isaac.GetItemIdByName("Red Button")
enums.Items.LostMirror = Isaac.GetItemIdByName("Lost Mirror")
enums.Items.BleedingGrimoire = Isaac.GetItemIdByName("Bleeding Grimoire")
enums.Items.BlackBook = Isaac.GetItemIdByName("Black Book")
enums.Items.RubikDice = Isaac.GetItemIdByName("Rubik's Dice")
enums.Items.RubikDiceScrambled0 = Isaac.GetItemIdByName("Scrambled Rubik's Dice")
enums.Items.RubikDiceScrambled1 = Isaac.GetItemIdByName("Scrambled Rubik's Dice ")
enums.Items.RubikDiceScrambled2 = Isaac.GetItemIdByName("Scrambled Rubik's Dice  ")
enums.Items.RubikDiceScrambled3 = Isaac.GetItemIdByName("Scrambled Rubik's Dice   ")
enums.Items.RubikDiceScrambled4 = Isaac.GetItemIdByName("Scrambled Rubik's Dice    ")
enums.Items.RubikDiceScrambled5 = Isaac.GetItemIdByName("Scrambled Rubik's Dice     ")
enums.Items.VHSCassette = Isaac.GetItemIdByName("VHS Cassette")
enums.Items.Lililith = Isaac.GetItemIdByName("Lililith")
enums.Items.CompoBombs = Isaac.GetItemIdByName("Compo Bombs")
enums.Items.LongElk = Isaac.GetItemIdByName("Long Elk")
enums.Items.Limb = Isaac.GetItemIdByName("Limbus")
enums.Items.GravityBombs = Isaac.GetItemIdByName("Black Hole Bombs")
enums.Items.MirrorBombs = Isaac.GetItemIdByName("Glass Bombs")
enums.Items.AbihuFam = Isaac.GetItemIdByName("Abihu")
enums.Items.FrostyBombs = Isaac.GetItemIdByName("Ice Cube Bombs")
enums.Items.VoidKarma = Isaac.GetItemIdByName("Karma Level")
enums.Items.CharonObol = Isaac.GetItemIdByName("Charon's Obol")
enums.Items.Viridian = Isaac.GetItemIdByName("VVV")
enums.Items.BookMemory = Isaac.GetItemIdByName("Book of Memories")
enums.Items.NadabBrain = Isaac.GetItemIdByName("Nadab's Brain")
enums.Items.Threshold = Isaac.GetItemIdByName("Threshold")
enums.Items.MongoCells = Isaac.GetItemIdByName("Mongo Cells")
enums.Items.NadabBody = Isaac.GetItemIdByName("Nadab's Body")
enums.Items.CosmicJam = Isaac.GetItemIdByName("Space Jam")
enums.Items.DMS = Isaac.GetItemIdByName("Death's Sickle")
enums.Items.MewGen = Isaac.GetItemIdByName("Mew-Gen")
enums.Items.ElderSign = Isaac.GetItemIdByName("Elder Sign")
enums.Items.Eclipse = Isaac.GetItemIdByName("Eclipse")
enums.Items.WitchPot = Isaac.GetItemIdByName("Witch's Pot")
enums.Items.PandoraJar = Isaac.GetItemIdByName("Pandora's Jar")
enums.Items.SecretLoveLetter = Isaac.GetItemIdByName("Secret Love Letter")
enums.Items.BatteryBombs = Isaac.GetItemIdByName("Battery Bombs")
enums.Items.DiceBombs = Isaac.GetItemIdByName("Dice Bombs")
enums.Items.Pyrophilia = Isaac.GetItemIdByName("Pyrophilia")
enums.Items.SpikedCollar = Isaac.GetItemIdByName("Spike Collar")
enums.Items.DeadBombs = Isaac.GetItemIdByName("Dead Bombs")
enums.Items.AgonyBox = Isaac.GetItemIdByName("Agony Box")
enums.Items.Potato = Isaac.GetItemIdByName("Potato")
enums.Items.SurrogateConception = Isaac.GetItemIdByName("Surrogate Conception")
enums.Items.HeartTransplant = Isaac.GetItemIdByName("Heart Transplant")
enums.Items.GardenTrowel = Isaac.GetItemIdByName("Garden Trowel")
enums.Items.ElderMyth = Isaac.GetItemIdByName("Elder Myth")
enums.Items.ForgottenGrimoire = Isaac.GetItemIdByName("Forgotten Grimoire")
enums.Items.CodexAnimarum = Isaac.GetItemIdByName("Codex Animarum")
enums.Items.RedBook = Isaac.GetItemIdByName("Red Book")
enums.Items.CosmicEncyclopedia = Isaac.GetItemIdByName("Cosmic Encyclopedia")
enums.Items.AncientVolume = Isaac.GetItemIdByName("Ancient Sacred Volume")
enums.Items.HolyHealing = Isaac.GetItemIdByName("Tome of Holy Healing")
enums.Items.WizardBook = Isaac.GetItemIdByName("Wizard's Book")
enums.Items.RitualManuscripts = Isaac.GetItemIdByName("Ritual Manuscripts")
enums.Items.StitchedPapers = Isaac.GetItemIdByName("Stitched Papers")
enums.Items.NirlyCodex = Isaac.GetItemIdByName("Nirly's Codex") -- I know it's Nilry
enums.Items.AlchemicNotes = Isaac.GetItemIdByName("Alchemic Notes")
enums.Items.LockedGrimoire = Isaac.GetItemIdByName("Locked Grimoire")
enums.Items.StoneScripture = Isaac.GetItemIdByName("Stone Scripture")
enums.Items.HuntersJournal = Isaac.GetItemIdByName("Hunter's Journal")
enums.Items.TomeDead = Isaac.GetItemIdByName("Tome of the Dead")
enums.Items.TetrisDice_full = Isaac.GetItemIdByName("Tetris Dice")
enums.Items.TetrisDice1 = Isaac.GetItemIdByName("Tetracube")
enums.Items.TetrisDice2 = Isaac.GetItemIdByName("2 Tetracubes")
enums.Items.TetrisDice3 = Isaac.GetItemIdByName("3 Tetracubes")
enums.Items.TetrisDice4 = Isaac.GetItemIdByName("4 Tetracubes")
enums.Items.TetrisDice5 = Isaac.GetItemIdByName("5 Tetracubes")
enums.Items.TetrisDice6 = Isaac.GetItemIdByName("6 Tetracubes")
enums.Items.Ignite = Isaac.GetItemIdByName("Ignite")
enums.Items.SteroidMeat = Isaac.GetItemIdByName("Steroid Meat")
enums.Items.HolyRavioli = Isaac.GetItemIdByName("Holy Ravioli")
enums.Items.Shroomface = Isaac.GetItemIdByName("Shroomface")
enums.Items.Whispers = Isaac.GetItemIdByName("Whispers")
enums.Items.AngryMeal = Isaac.GetItemIdByName("Angry Meal")
enums.Items.BaconPancakes = Isaac.GetItemIdByName("Bacon Pancakes")
enums.Items.BabylonCandle = Isaac.GetItemIdByName("Babylon Candle")
enums.Items.MephistoPact = Isaac.GetItemIdByName("Mephisto's Pact")
enums.Items.RealEngine = Isaac.GetItemIdByName("Real Engine")
enums.Items.GlitterInjection = Isaac.GetItemIdByName("Glitter Injection")

--enums.Items.Pizza = Isaac.GetItemIdByName("Pizza Pepperoni")
--enums.Items.Gagger = Isaac.GetItemIdByName("Little Gagger")
--enums.Items.EyeKey = Isaac.GetItemIdByName("Eye Key")
--enums.Items.EyeKeyClosed = Isaac.GetItemIdByName("Sleeping Eye Key")
--enums.Items.Dynamite = Isaac.GetItemIdByName("Dynamite")
--enums.Items.BathBombs = Isaac.GetItemIdByName("Bath Bombs")
--enums.Items.Pinata = Isaac.GetItemIdByName("Pinata")
--enums.Items.Zooma = Isaac.GetItemIdByName("Zooma")
--enums.Items.Throne = Isaac.GetItemIdByName("Basement Throne") --
--enums.Items.DeliJunior = Isaac.GetItemIdByName("Delirium Jr.") --
--enums.Items.AngelCore = Isaac.GetItemIdByName("Angel's Core") --
--enums.Items.GhostData = Isaac.GetItemIdByName("GHOST DATA") --

--- TRINKETS --

enums.Trinkets.WitchPaper = Isaac.GetTrinketIdByName("Witch Paper")
enums.Trinkets.Duotine = Isaac.GetTrinketIdByName("Duotine")
enums.Trinkets.TornSpades = Isaac.GetTrinketIdByName("Torn Spades")
enums.Trinkets.RedScissors = Isaac.GetTrinketIdByName("Red Scissors")
enums.Trinkets.LostFlower = Isaac.GetTrinketIdByName("Lost Flower")
enums.Trinkets.MilkTeeth = Isaac.GetTrinketIdByName("Milk Teeth")
enums.Trinkets.TeaBag = Isaac.GetTrinketIdByName("Tea Bag")
enums.Trinkets.BobTongue = Isaac.GetTrinketIdByName("Bob's Tongue")
enums.Trinkets.BinderClip = Isaac.GetTrinketIdByName("Binder Clip")
enums.Trinkets.MemoryFragment = Isaac.GetTrinketIdByName("Memory Fragment")
enums.Trinkets.AbyssCart = Isaac.GetTrinketIdByName("Cartridge?")
enums.Trinkets.RubikCubelet = Isaac.GetTrinketIdByName("Rubik's Cubelet")
enums.Trinkets.TeaFungus = Isaac.GetTrinketIdByName("Tea Fungus")
enums.Trinkets.DeadEgg = Isaac.GetTrinketIdByName("Dead Egg")
enums.Trinkets.Penance = Isaac.GetTrinketIdByName("Penance")
enums.Trinkets.Pompom = Isaac.GetTrinketIdByName("Pomegranate")
enums.Trinkets.XmasLetter = Isaac.GetTrinketIdByName("Xmas Letter")
enums.Trinkets.BlackPepper = Isaac.GetTrinketIdByName("Black Pepper")
enums.Trinkets.Cybercutlet = Isaac.GetTrinketIdByName("Cyber Cutlet")
enums.Trinkets.GildedFork = Isaac.GetTrinketIdByName("Gilded Fork")
enums.Trinkets.GoldenEgg = Isaac.GetTrinketIdByName("Golden Egg")
enums.Trinkets.BrokenJawbone = Isaac.GetTrinketIdByName("Broken Jawbone")
enums.Trinkets.WarHand = Isaac.GetTrinketIdByName("Hand of War")
enums.Trinkets.GhostData = Isaac.GetTrinketIdByName("Ghost Data")
enums.Trinkets.GiftCertificate = Isaac.GetTrinketIdByName("Gift Certificate")
enums.Trinkets.BlackPearl = Isaac.GetTrinketIdByName("Black Pearl")
enums.Trinkets.PhotocopyPHD = Isaac.GetTrinketIdByName("Photocopy PHD")

--- PICKUPS --

enums.Pickups.OblivionCard = Isaac.GetCardIdByName("01_OblivionCard")
enums.Pickups.BattlefieldCard = Isaac.GetCardIdByName("X_BattlefieldCard")
enums.Pickups.TreasuryCard = Isaac.GetCardIdByName("X_TreasuryCard")
enums.Pickups.BookeryCard = Isaac.GetCardIdByName("X_BookeryCard")
enums.Pickups.BloodGroveCard = Isaac.GetCardIdByName("X_BloodGroveCard")
enums.Pickups.StormTempleCard = Isaac.GetCardIdByName("X_StormTempleCard")
enums.Pickups.ArsenalCard = Isaac.GetCardIdByName("X_ArsenalCard")
enums.Pickups.OutpostCard = Isaac.GetCardIdByName("X_OutpostCard")
enums.Pickups.CryptCard = Isaac.GetCardIdByName("X_CryptCard")
enums.Pickups.MazeMemoryCard = Isaac.GetCardIdByName("X_MazeMemoryCard")
enums.Pickups.ZeroMilestoneCard = Isaac.GetCardIdByName("X_ZeroMilestoneCard")
enums.Pickups.CemeteryCard = Isaac.GetCardIdByName("X_CemeteryCard")
enums.Pickups.VillageCard = Isaac.GetCardIdByName("X_VillageCard")
enums.Pickups.GroveCard = Isaac.GetCardIdByName("X_GroveCard")
enums.Pickups.WheatFieldsCard = Isaac.GetCardIdByName("X_WheatFieldsCard")
enums.Pickups.SwampCard = Isaac.GetCardIdByName("X_SwampCard")
enums.Pickups.RuinsCard = Isaac.GetCardIdByName("X_RuinsCard")
enums.Pickups.SpiderCocoonCard = Isaac.GetCardIdByName("X_SpiderCocoonCard")
enums.Pickups.VampireMansionCard = Isaac.GetCardIdByName("X_VampireMansionCard")
enums.Pickups.RoadLanternCard = Isaac.GetCardIdByName("X_RoadLanternCard")
enums.Pickups.SmithForgeCard = Isaac.GetCardIdByName("X_SmithForgeCard")
enums.Pickups.ChronoCrystalsCard = Isaac.GetCardIdByName("X_ChronoCrystalsCard")
enums.Pickups.WitchHut  = Isaac.GetCardIdByName("X_WitchHutCard")
enums.Pickups.BeaconCard = Isaac.GetCardIdByName("X_BeaconCard")
enums.Pickups.TemporalBeaconCard = Isaac.GetCardIdByName("X_TemporalBeaconCard")

enums.Pickups.Decay = Isaac.GetCardIdByName("X_Decay")
enums.Pickups.AscenderBane = Isaac.GetCardIdByName("X_AscenderBane")
enums.Pickups.MultiCast = Isaac.GetCardIdByName("X_MultiCast")
enums.Pickups.Wish = Isaac.GetCardIdByName("X_Wish")
enums.Pickups.Offering = Isaac.GetCardIdByName("X_Offering")
enums.Pickups.InfiniteBlades = Isaac.GetCardIdByName("X_InfiniteBlades")
enums.Pickups.Transmutation = Isaac.GetCardIdByName("X_Transmutation")
enums.Pickups.RitualDagger = Isaac.GetCardIdByName("X_RitualDagger")
enums.Pickups.Fusion = Isaac.GetCardIdByName("X_Fusion")
enums.Pickups.DeuxEx = Isaac.GetCardIdByName("X_DeuxExMachina")
enums.Pickups.Adrenaline = Isaac.GetCardIdByName("X_Adrenaline")
enums.Pickups.Corruption = Isaac.GetCardIdByName("X_Corruption")

enums.Pickups.Apocalypse = Isaac.GetCardIdByName("02_ApoopalypseCard")
enums.Pickups.KingChess = Isaac.GetCardIdByName("03_KingChess")
enums.Pickups.KingChessW = Isaac.GetCardIdByName("X_KingChessW")
enums.Pickups.BannedCard = Isaac.GetCardIdByName("X_BannedCard")
enums.Pickups.Trapezohedron = Isaac.GetCardIdByName("04_Trapezohedron")
enums.Pickups.SoulUnbidden = Isaac.GetCardIdByName("X_SoulUnbidden")
enums.Pickups.SoulNadabAbihu = Isaac.GetCardIdByName("X_SoulNadabAbihu")

enums.Pickups.GhostGem = Isaac.GetCardIdByName("X_GhostGem")
enums.Pickups.CursedGem = Isaac.GetCardIdByName("CursedGem")
enums.Pickups.CrystalGem = Isaac.GetCardIdByName("CrystalGem")
enums.Pickups.BloodyGem = Isaac.GetCardIdByName("BloodyGem")
enums.Pickups.LovelyGem = Isaac.GetCardIdByName("LovelyGem")
enums.Pickups.GoldenGem = Isaac.GetCardIdByName("GoldenGem")
enums.Pickups.ShinyGem = Isaac.GetCardIdByName("ShinyGem")
enums.Pickups.SweetGem = Isaac.GetCardIdByName("SweetGem")

enums.Pickups.DeliObjectCell = Isaac.GetCardIdByName("Dell_Object")
enums.Pickups.DeliObjectBomb = Isaac.GetCardIdByName("Dell_Bomb")
enums.Pickups.DeliObjectKey = Isaac.GetCardIdByName("Dell_Key")
enums.Pickups.DeliObjectCard = Isaac.GetCardIdByName("Dell_Card")
enums.Pickups.DeliObjectPill = Isaac.GetCardIdByName("Dell_Pill")
enums.Pickups.DeliObjectRune = Isaac.GetCardIdByName("Dell_Rune")
enums.Pickups.DeliObjectHeart = Isaac.GetCardIdByName("Dell_Heart")
enums.Pickups.DeliObjectCoin = Isaac.GetCardIdByName("Dell_Coin")
enums.Pickups.DeliObjectBattery = Isaac.GetCardIdByName("Dell_Battery")

enums.Pickups.Domino34 = Isaac.GetCardIdByName("X_Domino34")
enums.Pickups.Domino25 = Isaac.GetCardIdByName("X_Domino25")
enums.Pickups.Domino16 = Isaac.GetCardIdByName("X_Domino16")
enums.Pickups.Domino00 = Isaac.GetCardIdByName("X_Domino00")
--enums.Pickups.Domino12 = Isaac.GetCardIdByName("X_Domino12") -- shoot pizza 8 pizza around you (piercing + tomato)

enums.Pickups.KittenBomb = Isaac.GetCardIdByName("exploding_kitten_bomb")
enums.Pickups.KittenDefuse = Isaac.GetCardIdByName("exploding_kitten_defuse")
enums.Pickups.KittenFuture = Isaac.GetCardIdByName("exploding_kitten_future")
enums.Pickups.KittenNope = Isaac.GetCardIdByName("exploding_kitten_nope")
enums.Pickups.KittenSkip = Isaac.GetCardIdByName("exploding_kitten_skip")
enums.Pickups.KittenFavor = Isaac.GetCardIdByName("exploding_kitten_favor")
enums.Pickups.KittenShuffle = Isaac.GetCardIdByName("exploding_kitten_shuffle")
enums.Pickups.KittenAttack = Isaac.GetCardIdByName("exploding_kitten_attack")
enums.Pickups.KittenBomb2 = Isaac.GetCardIdByName("exploding_kitten_bomb2")
enums.Pickups.KittenDefuse2 = Isaac.GetCardIdByName("exploding_kitten_defuse2")
enums.Pickups.KittenFuture2 = Isaac.GetCardIdByName("exploding_kitten_future2")
enums.Pickups.KittenNope2 = Isaac.GetCardIdByName("exploding_kitten_nope2")
enums.Pickups.KittenSkip2 = Isaac.GetCardIdByName("exploding_kitten_skip2")
enums.Pickups.KittenFavor2 = Isaac.GetCardIdByName("exploding_kitten_favor2")
enums.Pickups.KittenShuffle2 = Isaac.GetCardIdByName("exploding_kitten_shuffle2")
enums.Pickups.KittenAttack2 = Isaac.GetCardIdByName("exploding_kitten_attack2")

--enums.Pickups.RedPill = Isaac.GetCardIdByName("X_RedPill")
--enums.Pickups.RedPillHorse = Isaac.GetCardIdByName("X_RedPillHorse")
enums.Pickups.RedPill = Isaac.GetPillEffectByName("Duotine")
enums.Pickups.RedPillColor = 889
enums.Pickups.RedPillColorHorse = 2937 -- (889+2048)

--- CHALLENGES --

enums.Challenges.Potatoes = Isaac.GetChallengeIdByName("[Eclipsed] When life gives you Potatoes!") -- unlock mongo beggar
enums.Challenges.Magician = Isaac.GetChallengeIdByName("[Eclipsed] Curse of The Magician") -- unlock Mew-Gen
enums.Challenges.Lobotomy = Isaac.GetChallengeIdByName("[Eclipsed] Lobotomy") -- delirious beggar and pickups
--enums.Challenges.IsaacIO = Isaac.GetChallengeIdByName("Isaac.io") -- kill - size up, take damage - size down
enums.Challenges.Beatmaker = Isaac.GetChallengeIdByName("[Eclipsed] Beatmaker") -- start with heart transplant, heart transplant don't decrease beat counter
enums.Challenges.MongoFamily = Isaac.GetChallengeIdByName("[Eclipsed] Mongo Family") --start with mongo cells, at the start of each floor spawn 3 familiars, you can choose one
--enums.Challenges.ShovelNight = Isaac.GetChallengeIdByName("[Eclipsed] Shovel Night / Graveyard Keeper") --

--- CURSES --

enums.Curses.Void = 1 << (Isaac.GetCurseIdByName("Curse of the Void!")-1) -- reroll enemies and grid, apply delirium spritesheet, always active on void floors?
enums.Curses.Jamming = 1 << (Isaac.GetCurseIdByName("Curse of the Jamming!")-1) -- respawn enemies in room after clearing
enums.Curses.Emperor = 1 << (Isaac.GetCurseIdByName("Curse of the Emperor!")-1) -- no exit door from boss room
enums.Curses.Magician = 1 << (Isaac.GetCurseIdByName("Curse of the Magician!")-1) -- homing enemy tears (except boss)
enums.Curses.Pride = 1 << (Isaac.GetCurseIdByName("Curse of the Pride!")-1) -- all enemies is champion (except boss) - without health buff
enums.Curses.Bell = 1 << (Isaac.GetCurseIdByName("Curse of the Bell!")-1) -- all troll bombs is golden
enums.Curses.Envy = 1 << (Isaac.GetCurseIdByName("Curse of the Envy!")-1) -- other shop items disappear when you buy one
enums.Curses.Carrion = 1 << (Isaac.GetCurseIdByName("Curse of Carrion!")-1) -- turn normal poops into red
enums.Curses.Bishop = 1 << (Isaac.GetCurseIdByName("Curse of the Bishop!")-1) -- 16% cahance to enemies prevent damage
enums.Curses.Montezuma = 1 << (Isaac.GetCurseIdByName("Curse of Montezuma!")-1) -- slippery ground
enums.Curses.Misfortune = 1 << (Isaac.GetCurseIdByName("Curse of Misfortune!")-1) -- -5 luck
enums.Curses.Poverty = 1 << (Isaac.GetCurseIdByName("Curse of Poverty!")-1) -- greed enemy tears
enums.Curses.Fool = 1 << (Isaac.GetCurseIdByName("Curse of the Fool!")-1) -- 16% chance to respawn enemies in cleared rooms, don't close doors (except boss)
enums.Curses.Secrets = 1 << (Isaac.GetCurseIdByName("Curse of Secrets!")-1) -- hide secret/supersecret room doors
enums.Curses.Warden = 1 << (Isaac.GetCurseIdByName("Curse of the Warden!")-1) -- all locked doors need 2 keys - visual bug with chains not appearing
enums.Curses.Desolation = 1 << (Isaac.GetCurseIdByName("Curse of the Desolation!")-1) -- 16% chance to turn item into Item Wisp when picked up. Add wisped item after clearing room
--enums.Curses.Reaper	 -- spawn invulnerable scythe following you, kills you if you touch it. (can kill enemies?)
--enums.Curses.BrokenHeart -- turn all empty heart places into broken hearts OR add 1 broken heart
--enums.Curses.Pain	-- special room doors become spiked -- except boss
--enums.Curses.Devil	-- spawn Big Horn hand throwing bombs at you when entering room
--enums.Curses.Justice	--	idk
--enums.Curses.Oblivion	-- chance to enter out of map room with random enemies/boss. spawns purple portal-teleport after clearing room

enums.CurseText[enums.Curses.Void] = "Curse of the Void!"
enums.CurseText[enums.Curses.Jamming] = "Curse of the Jamming!"
enums.CurseText[enums.Curses.Emperor] = "Curse of the Emperor!"
enums.CurseText[enums.Curses.Magician] = "Curse of the Magician!"
enums.CurseText[enums.Curses.Pride] = "Curse of the Pride!"
enums.CurseText[enums.Curses.Bell] = "Curse of the Bell!"
enums.CurseText[enums.Curses.Envy] = "Curse of the Envy!"
enums.CurseText[enums.Curses.Carrion] = "Curse of Carrion!"
enums.CurseText[enums.Curses.Bishop] = "Curse of the Bishop!"
enums.CurseText[enums.Curses.Montezuma] = "Curse of Montezuma!"
enums.CurseText[enums.Curses.Misfortune] = "Curse of Misfortune!"
enums.CurseText[enums.Curses.Poverty] = "Curse of Poverty!"
enums.CurseText[enums.Curses.Fool] = "Curse of the Fool!"
enums.CurseText[enums.Curses.Secrets] = "Curse of Secrets!"
enums.CurseText[enums.Curses.Warden] = "Curse of the Warden!"
enums.CurseText[enums.Curses.Desolation] = "Curse of the Desolation!"

enums.CurseIconsList[enums.Curses.Void] = "gfx/curse_icons/curse_void.png"
enums.CurseIconsList[enums.Curses.Jamming] = "gfx/curse_icons/curse_jamming.png"
enums.CurseIconsList[enums.Curses.Emperor] = "gfx/curse_icons/curse_emperror.png"
enums.CurseIconsList[enums.Curses.Magician] = "gfx/curse_icons/curse_magician.png"
enums.CurseIconsList[enums.Curses.Pride] = "gfx/curse_icons/curse_pride.png"
enums.CurseIconsList[enums.Curses.Bell] = "gfx/curse_icons/curse_bell.png"
enums.CurseIconsList[enums.Curses.Envy] = "gfx/curse_icons/curse_envy.png"
enums.CurseIconsList[enums.Curses.Carrion] = "gfx/curse_icons/curse_carrion.png"
enums.CurseIconsList[enums.Curses.Bishop] = "gfx/curse_icons/curse_bishop.png"
enums.CurseIconsList[enums.Curses.Montezuma] = "gfx/curse_icons/curse_montezuma.png"
enums.CurseIconsList[enums.Curses.Misfortune] = "gfx/curse_icons/curse_misfortune.png"
enums.CurseIconsList[enums.Curses.Poverty] = "gfx/curse_icons/curse_poverty.png"
enums.CurseIconsList[enums.Curses.Fool] = "gfx/curse_icons/curse_fool.png"
enums.CurseIconsList[enums.Curses.Secrets] = "gfx/curse_icons/curse_secrets.png"
enums.CurseIconsList[enums.Curses.Warden] = "gfx/curse_icons/curse_warden.png"
enums.CurseIconsList[enums.Curses.Desolation] = "gfx/curse_icons/curse_desol.png"

--- FAMILIARS --
enums.Familiars.RedBag = Isaac.GetEntityVariantByName("Red Bag")
enums.Familiars.Lililith = Isaac.GetEntityVariantByName("Lililith")
enums.Familiars.NadabBrain = Isaac.GetEntityVariantByName("NadabBrain")
enums.Familiars.AbihuFam = Isaac.GetEntityVariantByName("AbihuFam")

--- SLOTS --
enums.Slots.DeliriumBeggar = Isaac.GetEntityVariantByName("Delirious Bum")
enums.Slots.MongoBeggar = Isaac.GetEntityVariantByName("Mongo Beggar")

--- EFFECTS --
enums.Effects.KeeperMirrorTarget = Isaac.GetEntityVariantByName("mTarget")
enums.Effects.BlackKnightTarget = Isaac.GetEntityVariantByName("kTarget")
enums.Effects.BlackHoleBombsEffect = Isaac.GetEntityVariantByName("BlackHoleBombsEffect")

EclipsedMod.enums = enums