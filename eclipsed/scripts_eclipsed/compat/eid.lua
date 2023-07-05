if EID then -- External Item Description

	local enums = require("scripts_eclipsed.enums")
	
	local function AddPlayerIcon(player, frame)
		local PlayerIconUnbidden = Sprite()
		PlayerIconUnbidden:Load("gfx/ui/eid_player_icons.anm2", true)
		local iconShort = "Player" .. player
		EID:addIcon(iconShort,"Players", frame, 12, 12, -1, 1, PlayerIconUnbidden)
	end
	
	AddPlayerIcon(enums.Characters.Unbidden, 0)
	AddPlayerIcon(enums.Characters.UnbiddenB, 1)
	AddPlayerIcon(enums.Characters.Nadab, 2)
	AddPlayerIcon(enums.Characters.Abihu, 3)
	
	EID:addBirthright(enums.Characters.Nadab, "Explosion and fire immunity. #Spawns 3 random items from {{BombBeggar}} Bomb Beggar pool. #Only one can be taken.")
	EID:addBirthright(enums.Characters.Abihu, "Explosion and fire immunity. #{{Heart}} Full health. #{{Chargeable}} Charging Blue Flame is always active.")
	EID:addBirthright(enums.Characters.Unbidden, "Remove {{BrokenHeart}} one broken heart and add {{SoulHeart}} a soul heart. #Item Wisps no longer removed at the start of next floor.")
	EID:addBirthright(enums.Characters.UnbiddenB, "Remove and prevent all curses. #Sets Rewind-meter to 100%. #{{Collectible".. enums.Items.Threshold .."}} Threshold no longer decreses Rewind-meter when it used to turn wisp into item.")

	local disk_desk = "!!! SINGLE USE !!! #Save your items. #If you have saved items: replace your items by saved items. #{{Warning}} Give {{Collectible258}} MissingNo if saved item is missing."
	EID:addCollectible(enums.Items.FloppyDisk, disk_desk)
	EID:addCollectible(enums.Items.FloppyDiskFull, disk_desk)

	EID:addCollectible(enums.Items.RedMirror,
			"Turn nearest {{Trinket}} trinket into {{Card78}} cracked key.")
	EID:addCollectible(enums.Items.RedLotus,
			"Remove one {{BrokenHeart}} broken heart and give {{Damage}} flat 1.0 damage up at the start of the floor.")
	EID:addCollectible(enums.Items.MidasCurse,
			"Add 3 {{GoldenHeart}} golden hearts. #10% chance to get golden pickups. #When you lose golden heart turn everything into gold. #{{Warning}} Curse effect: # {{Warning}} 100% chance to get golden pickups. # {{Warning}} All food-related items turn into coins if you try to pick them up. #Curse effect can be removed by {{Collectible260}} Black Candle.")
	EID:addCollectible(enums.Items.RubberDuck,
			"↑ {{Luck}} +20 temporary luck up when picked up. #↑ {{Luck}} +1 luck up when entering unvisited room. #↓ {{Luck}} -1 luck down when entering visited room. #Temporary luck can't go below player's real luck.")
	EID:addCollectible(enums.Items.IvoryOil,
			"Charge active items when entering an uncleared room for the first time.")
	EID:addCollectible(enums.Items.BlackKnight,
			"You can't move. #Use to jump to target marker. #Crush and knockback monsters when you land on the ground. #Destroy stone monsters.")
	EID:addCollectible(enums.Items.WhiteKnight,
			"Use to jump to nearest enemy. #Crush and knockback monsters when you land on the ground. #Destroy stone monsters.")
	EID:addCollectible(enums.Items.KeeperMirror,
			"Sell item or pickup in target mark. #Spawn 1 coin if no pickup was targeted")
	EID:addCollectible(enums.Items.RedBag,
			"Chance to drop red pickups after clearing room. #Possible pickups: {{Heart}} red hearts, {{Card49}} dice shards, {{Pill}} red pills, {{Card78}} cracked keys, {{Bomb}} red throwable bombs. #{{Warning}} Can spawn Red Poop.")
	EID:addCollectible(enums.Items.MeltedCandle,
			"Tears have a chance to wax enemies for 3 seconds. #Waxed enemy {{Freezing}} freezes and {{Burning}} burns. #When a waxed enemy dies, it leaves fire.")
	EID:addCollectible(enums.Items.MiniPony,
			"Grants flight and {{Speed}} 1.5 speed while held. #On use, grants {{Collectible77}} My Little Unicorn effect.")
	EID:addCollectible(enums.Items.StrangeBox,
			"Create {{Collectible249}} option choice item for all items, pickups and shop items in the room.")
	EID:addCollectible(enums.Items.RedButton,
			"Spawn Red Button when entering room. #Activate random pressure plate effect when pressed. #{{Warning}}After pressing 66 times, no longer appear in current room.")
	EID:addCollectible(enums.Items.LostMirror,
			"Turn you into {{Player10}} soul.")
	EID:addCollectible(enums.Items.BleedingGrimoire,
			"Start {{BleedingOut}} bleeding. #Your tears apply {{BleedingOut}} bleeding to enemies.")
	EID:addCollectible(enums.Items.BlackBook,
			"Apply random status effects on enemies in room. #Possible effects: {{Freezing}}Freeze; {{Poison}}Poison; {{Slow}}Slow; {{Charm}}Charm; {{Confusion}}Confusion; {{Collectible202}}Midas Touch; {{Fear}}Fear; {{Burning}}Burn; {{Collectible398}}Shrink; {{BleedingOut}}Bleed; {{Collectible596}}Frozen; {{Magnetize}}Magnetized; {{Bait}}Bait.")

	local description = "In 'solved' state {{Collectible105}} reroll items. #{{Warning}} Turn into {{Collectible".. enums.Items.RubikDiceScrambled0 .."}} 'scrambled' Rubik's Dice, increasing it's charge bar. #In 'scrambled' state it can be used without full charge, but will reroll items into {{Collectible721}} glitched items. #After fully recharging, it returns to 'solved' state."
	EID:addCollectible(enums.Items.RubikDice, description)
	EID:addCollectible(enums.Items.RubikDiceScrambled0, description)
	EID:addCollectible(enums.Items.RubikDiceScrambled1, description)
	EID:addCollectible(enums.Items.RubikDiceScrambled2, description)
	EID:addCollectible(enums.Items.RubikDiceScrambled3, description)
	EID:addCollectible(enums.Items.RubikDiceScrambled4, description)
	EID:addCollectible(enums.Items.RubikDiceScrambled5, description)

	EID:addCollectible(enums.Items.VHSCassette,
			"!!! SINGLE USE !!! #Randomly move to later floor. #Void - is last possible floor. #On ascension you will be send to Home. #Spawn 12 pickups of two types.")
	EID:addCollectible(enums.Items.Lililith,
			"Spawn a random familiar every 7 rooms. #Spawned familiars will be removed on next floor. #Possible familiars: {{Collectible113}} demon baby, {{Collectible275}} lil brimstone, {{Collectible679}} lil abaddon, {{Collectible360}} incubus, {{Collectible417}} succubus, {{Collectible270}} leech, {{Collectible698}} twisted pair.")
	EID:addCollectible(enums.Items.CompoBombs,
			"+5 bombs when picked up. #Place 2 bombs at once. #Second bomb is red throwable bomb")
	EID:addCollectible(enums.Items.MirrorBombs,
			"+5 bombs when picked up. #The placed bomb will be copied to the opposite side of the room.")
	EID:addCollectible(enums.Items.GravityBombs,
			"+1 giga bomb when picked up. #Bombs get {{Collectible512}} Black Hole effect.")
	EID:addCollectible(enums.Items.AbihuFam,
			"{{Collectible281}}Decoy familiar. #Can {{Burning}} burn enemies on contact.")
	EID:addCollectible(enums.Items.NadabBody,
			"{{Throwable}} Can be picked up and thrown. #Blocks enemy tears. #When thrown explodes on contact with enemy. #{{Warning}} The explosion can hurt you!")
	EID:addCollectible(enums.Items.Limb,
			"When you die and don't have any extra life, you will be turned into {{Player10}} soul for current level.")
	EID:addCollectible(enums.Items.LongElk,
			"Grants flight. #While moving leave {{Collectible683}} bone spurs. #On use do short dash in movement direction, and kill next contacted enemy.")
	EID:addCollectible(enums.Items.FrostyBombs,
			"+5 bombs when picked up. #Bombs leave water creep. #Bombs {{Slow}} slow down enemies. #Turn killed enemies into ice statues.")
	EID:addCollectible(enums.Items.VoidKarma,
			"↑ All stats up when entering new level. #{{Damage}} +0.5 damage up #{{Tears}} +0.27 tears up #{{Range}} +1.0 range up #{{Shotspeed}} +0.1 shotspeed up #{{Speed}} +0.1 speed up #{{Luck}} +0.5 luck up #Double it's effect if you didn't take damage on previous floor.")
	EID:addCollectible(enums.Items.CharonObol,
			"Pay {{Coin}} 1 coin to spawn {{Collectible684}} hungry soul. #Removes itself when you die.")
	EID:addCollectible(enums.Items.Viridian,
			"Grants flight. #Flip player's sprite.")
	EID:addCollectible(enums.Items.BookMemory,
			"Erase all enemies in room from current run. #Can't erase bosses. #Add {{BrokenHeart}} broken heart when used.")
	EID:addCollectible(enums.Items.MongoCells,
			"Copy your familiars. #Description of familiars contains information about what bonuses they will add.")
	EID:addCollectible(enums.Items.CosmicJam,
			"Add Item Wisp from all items in room to player.")
	EID:addCollectible(enums.Items.DMS,
			"Enemies has 25% chance to spawn {{Collectible634}} purgatory soul after death.")
	EID:addCollectible(enums.Items.MewGen,
			"Grants flight. #If don't shoot more than 5 seconds, activates {{Collectible522}} Telekinesis effect.")
	EID:addCollectible(enums.Items.ElderSign,
			"Creates Pentagram for 3 seconds at position where you stand. #Pentagram spawn {{Collectible634}} purgatory Soul. #{{Freezing}} Freeze enemies inside pentagram.")
	EID:addCollectible(enums.Items.Eclipse,
			"While shooting grants pulsing aura, dealing player's damage. #{{Damage}} x2.0 damage boost when level has {{CurseDarkness}} Curse of Darkness.")
	EID:addCollectible(enums.Items.Threshold,
			"If player has Item Wisps: give actual item from Item Wisp. #\7 Tainted Unbidden: -1% to rewind. #Else activate black rune effect: #\7 Deals 40 damage to all enemies. #\7 Converts all pedestal items in the room into random stat ups. #\7 Converts all pickups in the room into blue flies and spiders.")
	EID:addCollectible(enums.Items.WitchPot,
			"Spawn new trinket. #40% chance to smelt current trinket. #40% chance to spit out smelted trinket. #10% Chance to reroll your current trinket. #{{Warning}} 10% Chance to destroy your current trinket.")
	EID:addCollectible(enums.Items.PandoraJar,
			"Adds a purple wisp with homing tears. #{{Warning}} 15% chance to add a special curse. #If all curses have been added, grants {{Collectible515}} Mystery Gift. Effect only triggers once per floor")
	EID:addCollectible(enums.Items.DiceBombs,
			"+5 bombs when picked up. #The placed bomb will reroll pickups, chests and items within explosion range. #Devolve enemies hit by an explosion.")
	EID:addCollectible(enums.Items.BatteryBombs,
			"+5 bombs when picked up. #Bombs zap 5 electrical bolts in random directions. #Recharges active item when player is hit by an explosion. #Charge points based on bomb damage.")
	EID:addCollectible(enums.Items.Pyrophilia,
			"+5 bombs when picked up. #Heal half heart when an enemy hit by a bomb explosion.")
	EID:addCollectible(enums.Items.SpikedCollar,
			"Instead taking damage activates {{Collectible126}} Razor Blade effect.")
	EID:addCollectible(enums.Items.DeadBombs,
			"+5 bombs when picked up. #Spawn {{Collectible683}} Bone Spurs for each killed enemy by explosion. #33% chance to spawn frinedly Bony, Pasty, Bone Fly, Big Bony, Black Bony or Revenant.")
	EID:addCollectible(enums.Items.AgonyBox,
			"Prevents next incoming damage and removes one point of charge. #Entering a new floor recharges one point.") -- #Charges 1 point when you take damage from spikes in {{SacrificeRoom}} Sacrifice Room.
	EID:addCollectible(enums.Items.Potato,
			"+1 Max HP")
	EID:addCollectible(enums.Items.SecretLoveLetter,
			"Hold letter and throw it in shooting direction. #Letter doesn't have damage. #If letter touched enemy then all enemies of this type become charmed until you use Secret Love Letter on another enemy. #Charmed enemies saved between rooms and levels. #Charm bosses only for period of time.")
	EID:addCollectible(enums.Items.SurrogateConception,
			"After clearing boss room spawns random boss familiar. #Can be triggered only once per floor.")
	EID:addCollectible(enums.Items.HeartTransplant,
			"Charges every ~2 seconds. #Discharges af full charge. #Each use grants damage, tears and speed up boost; and increases it's beat counter. #Higher beat counter grants better boost, but faster item recharge. #When used at max beat counter: fires 10 tears in a circle around the player. #Failed use of item decreases beat counter.")
	EID:addCollectible(enums.Items.NadabBrain,
			"{{Throwable}} Familiar, throwed in a player shooting direction. #Explode, burn enemy and leave fire on contact. #Very low speed.")
	EID:addCollectible(enums.Items.GardenTrowel,
			"Spawn {{Collectible683}} bone spurs. #Can dig up dirt patches like {{Card34}} Rune of Ehwas, {{Collectible84}} We Need To Go Deeper")
	
	
	EID:addTrinket(enums.Trinkets.WitchPaper,
			"{{Collectible422}} Turn back time when you die. #Destroys itself after triggering.")
	EID:addTrinket(enums.Trinkets.QueenSpades,
			"33% chance to spawn portal to random room after clearing room. #Leaving room removes portal.")
	EID:addTrinket(enums.Trinkets.RedScissors,
			"Turn troll-bombs into red throwable bombs.") -- inferior scissors, nah
	EID:addTrinket(enums.Trinkets.Duotine,
			"Replaces all future {{Pill}} pills by Red pills while holding this trinket.")
	EID:addTrinket(enums.Trinkets.LostFlower,
			"Give you {{Heart}} full heart container when you get {{EternalHeart}} eternal heart. #Destroys itself when you take damage. #{{Player10}}{{Player31}} Lost: activate {{Card51}} Holy Card effect when you get eternal heart. #{{Player10}}{{Player31}} Lost: use Lost Mirror while holding this trinket to activate {{Card51}} Holy Card effect.")
	EID:addTrinket(enums.Trinkets.TeaBag,
			"Remove poison and fart clouds near player.")
	EID:addTrinket(enums.Trinkets.MilkTeeth,
			"Enemies have a 15% chance to drop vanishing {{Coin}} coins when they die.")
	EID:addTrinket(enums.Trinkets.BobTongue,
			"Bombs get toxic aura, similar to {{Collectible446}} Dead Tooth effect.")
	EID:addTrinket(enums.Trinkets.BinderClip,
			"10% chance to get double hearts, coins, keys and bombs. #Pickups with {{Collectible670}} option choices no longer disappear.")
	EID:addTrinket(enums.Trinkets.MemoryFragment,
			"Spawn last 3 used {{Card}}{{Rune}}{{Pill}} cards, runes, pills at the start of next floor.") -- +1 golden/mombox/stackable
	EID:addTrinket(enums.Trinkets.AbyssCart,
			"If you have baby familiar when you die, remove him and revive you. #Sacrificable familiars will blink periodically when you have 1 heart left. #Destroys itself after triggering and drops {{EternalHeart}} eternal heart.")
	EID:addTrinket(enums.Trinkets.RubikCubelet,
			"33% chance to reroll items into {{Collectible721}} glitched items when you take damage.")
	EID:addTrinket(enums.Trinkets.TeaFungus,
			"Rooms are flooded.")
	EID:addTrinket(enums.Trinkets.DeadEgg,
			"Spawn dead bird familiar for 10 seconds when bomb explodes.")
	EID:addTrinket(enums.Trinkets.Penance,
			"16% chance to apply Red Cross indicator to enemies upon entering a room. #When marked enemies die, they shoot beams of light in 4 directions.")
	EID:addTrinket(enums.Trinkets.Pompom,
			"Picking up {{Heart}} red hearts can convert them into random red wisps.")
	EID:addTrinket(enums.Trinkets.XmasLetter,
			"50% chance when entering room for the first time activate {{Collectible557}} Fortune Cookie. #Leaving this trinket in {{DevilRoom}} devil deal turn it into {{Collectible515}} Mystery Gift on next enter.")
	EID:addTrinket(enums.Trinkets.BlackPepper,
			"Red throwable bombs gain the bomb effects.")
	EID:addTrinket(enums.Trinkets.Cybercutlet,
			"Auto-reroll food items. #When you take damage heal 1 red heart and remove this trinket.")
	EID:addTrinket(enums.Trinkets.GildedFork,
			"Turn red hearts into coins. #Half Heart into 2 coins; #Full Heart into 3 coins; #Double Hearts into 6 coins.")
	EID:addTrinket(enums.Trinkets.GoldenEgg,
			"Turn hearts, coins, keys, bombs, pills, batteries and trinkets into their golden versions on touch. #66% chance to remove itself after triggering.")
	EID:addTrinket(enums.Trinkets.BrokenJawbone,
			"Spawn dirt patches in secret and super secret rooms. #Dirt patches can be dig up by {{Card34}} Rune of Ehwas, {{Collectible84}} We Need To Go Deeper or {{Collectible".. enums.Items.GardenTrowel .."}} Garden Trowel, and spawn {{Chest}} a random chest.")
	
	EID:addCard(enums.Pickups.OblivionCard,
			"Throwable eraser card. #Erase enemies for current level.")
	EID:addCard(enums.Pickups.BattlefieldCard,
			"Teleport to out of map {{ChallengeRoom}} Boss Challenge.")
	EID:addCard(enums.Pickups.TreasuryCard,
			"Teleport to out of map {{TreasureRoom}} Treasury.")
	EID:addCard(enums.Pickups.BookeryCard,
			"Teleport to out of map {{Library}} Library.")
	EID:addCard(enums.Pickups.BloodGroveCard,
			"Teleport to out of map {{CursedRoom}} Curse Room.")
	EID:addCard(enums.Pickups.StormTempleCard,
			"Teleport to out of map {{AngelRoom}} Angel Room.")
	EID:addCard(enums.Pickups.ArsenalCard,
			"Teleport to out of map {{ChestRoom}} Chest Room.")
	EID:addCard(enums.Pickups.OutpostCard,
			"Teleport to out of map {{IsaacsRoom}} {{BarrenRoom}} Bedroom.")
	EID:addCard(enums.Pickups.CryptCard,
			"Teleport to out of map {{LadderRoom}} Crawlspace.")
	EID:addCard(enums.Pickups.MazeMemoryCard,
			"Teleport to out of map {{TreasureRoom}} room with 18 items from random pools. #Only one can be taken. #Apply {{CurseBlind}} Curse of Blind for current level.")
	EID:addCard(enums.Pickups.ZeroMilestoneCard,
			"Spawn item which constantly changes between items of current room pool.")
	EID:addCard(enums.Pickups.CemeteryCard,
			"Teleport to out of map {{SuperSecretRoom}} Super Secret room. #Room contains {{Collectible".. enums.Items.GardenTrowel .."}} Garden Trowel and 4 dirt patches.")
	EID:addCard(enums.Pickups.VillageCard,
			"Teleport to out of map {{ArcadeRoom}} Arcade.")
	EID:addCard(enums.Pickups.GroveCard,
			"Teleport to out of map {{ChallengeRoom}} Challenge. #Room contains item from treasure pool.")
	EID:addCard(enums.Pickups.WheatFieldsCard,
			"Teleport to out of map {{ChestRoom}} Chest room. #All pickups in room is golden.")	
	EID:addCard(enums.Pickups.RuinsCard,
			"Teleport to out of map {{SecretRoom}} Secret room.")				
	EID:addCard(enums.Pickups.SwampCard,
			"Teleport to out of map {{SuperSecretRoom}} Super Secret room. #Room contains rotten hearts and rotten beggar.")	
	EID:addCard(enums.Pickups.SpiderCocoonCard,
			"Activate Spider Butt, Box of Spiders, Infestation! and Infestation? effect")	
	EID:addCard(enums.Pickups.RoadLanternCard,
			"Grants {{Collectible91}} Spelunker Hat item wisp with 1hp.")	
	EID:addCard(enums.Pickups.ChronoCrystalsCard,
			"Grants {{Collectible514}} Broken Modem item wisp with 1hp.")	
	EID:addCard(enums.Pickups.VampireMansionCard,
			"Teleport to out of map {{SuperSecretRoom}} Super Secret room. #Room contains black heart and devil beggar.")					
	EID:addCard(enums.Pickups.SmithForgeCard,
			"Smelt your trinkets. #Teleport to out of map {{SuperSecretRoom}} Super Secret room. #Room contains 3 trinkets")	
	EID:addCard(enums.Pickups.WitchHut,
			"Teleport to out of map {{SuperSecretRoom}} Super Secret room. #Room contains 9 random pills")
	EID:addCard(enums.Pickups.BeaconCard,
			"Teleport to out of map {{Shop}} Shop with 2 items and Restock machine.")
	EID:addCard(enums.Pickups.TemporalBeaconCard,
			"Teleport to out of map {{Shop}} Shop with 8 items.")

	EID:addCard(enums.Pickups.Apocalypse,
			"Fills the whole room with red poop.")
	EID:addCard(enums.Pickups.BannedCard,
			"Spawn 2 copies of this card.")

	EID:addCard(enums.Pickups.KingChess,
			"Poop around you. #Black poops.")
	EID:addCard(enums.Pickups.KingChessW,
			"Poop around you. #White poops.")

	EID:addCard(enums.Pickups.GhostGem,
			"Spawn 4 {{Collectible634}} purgatory souls.")
	EID:addCard(enums.Pickups.Trapezohedron,
			"Turn all {{Trinket}} trinkets into {{Card78}} cracked keys.")
	EID:addCard(enums.Pickups.SoulUnbidden,
			"Add items from all item wisps to player. #If player doesn't have item wisps, add one.")
	EID:addCard(enums.Pickups.SoulNadabAbihu,
			"Fire and Explosion immunity. #{{Collectible257}} Fire Mind and {{Collectible256}} Hot Bombs effect for current room.")

	EID:addCard(enums.Pickups.Domino34,
			"Reroll items and pickups on current level.")
	EID:addCard(enums.Pickups.Domino25,
			"Respawn and reroll enemies in current room.")
	EID:addCard(enums.Pickups.Domino16,
			"Spawn 6 pickups of one type.")
	EID:addCard(enums.Pickups.Domino00,
			"50/50 chance to remove or double items, pickups and enemies")

	EID:addCard(enums.Pickups.AscenderBane,
			"Remove one {{BrokenHeart}} broken heart. #Add random special curse.")
	EID:addCard(enums.Pickups.Decay,
			"Turn your {{Heart}} red hearts into {{RottenHeart}} rotten hearts. #{{Trinket140}} Apple of Sodom effect for current room.")
	EID:addCard(enums.Pickups.MultiCast,
			"Spawn 3 wisps based on your active item. #Spawn regular wisps if you don't have an active item.")
	EID:addCard(enums.Pickups.Wish,
			"{{Collectible515}} Mystery Gift effect.")
	EID:addCard(enums.Pickups.Offering,
			"{{Collectible536}} Sacrificial Altar effect.")
	EID:addCard(enums.Pickups.InfiniteBlades,
			"Shoot 7 knives in firing direction.")
	EID:addCard(enums.Pickups.Transmutation,
			"Reroll pickups and enemies into random pickups.")
	EID:addCard(enums.Pickups.RitualDagger,
			"{{Collectible114}} Mom's Knife for current room.")
	EID:addCard(enums.Pickups.Fusion,
			"{{Collectible512}} Throw a Black Hole.")
	EID:addCard(enums.Pickups.DeuxEx,
			"↑ {{Luck}} +100 luck up for current room.")
	EID:addCard(enums.Pickups.Adrenaline,
			"Turn all your {{Heart}} red hearts into {{Battery}} batteries. #{{Collectible493}} Adrenaline effect for current room.")
	EID:addCard(enums.Pickups.Corruption,
			"You can use your active item x10 times for free in current room. #{{Warning}} Remove your active item on next room or when you use your active item 10 times. #{{Warning}} Doesn't affect pocket active item.") --{{Active1}}

	EID:addCard(enums.Pickups.DeliObjectCell,
			"Spawn random friendly enemy. #The enemy is from the pool of encountered enemies in current run. #While on the ground - randomly cycle between delirious pickups. #80% chance to not be consumed and reroll its effect. #Only one delirious pickups can be held at the same time.")
	EID:addCard(enums.Pickups.DeliObjectBomb,
			"Spawn bomb with random effects. #Chance to spawn troll, super troll or golden troll bomb. #While on the ground - randomly cycle between delirious pickups. #80% chance to not be consumed and reroll its effect. #Only one delirious pickups can be held at the same time.")
	EID:addCard(enums.Pickups.DeliObjectKey,
			"Open nearest chest or door. #If room doesn't have any locked door or chests, if possible makes red room door. #While on the ground - randomly cycle between delirious pickups. #80% chance to not be consumed and reroll its effect. #Only one delirious pickups can be held at the same time.")
	EID:addCard(enums.Pickups.DeliObjectCard,
			"Random card effect. #While on the ground - randomly cycle between delirious pickups. #80% chance to not be consumed and reroll its effect. #Only one delirious pickups can be held at the same time.")
	EID:addCard(enums.Pickups.DeliObjectPill,
			"Random pill effect. #While on the ground - randomly cycle between delirious pickups. #80% chance to not be consumed and reroll its effect. #Only one delirious pickups can be held at the same time.")
	EID:addCard(enums.Pickups.DeliObjectRune,
			"Random rune or soul effect. #While on the ground - randomly cycle between delirious pickups. #80% chance to not be consumed and reroll its effect. #Only one delirious pickups can be held at the same time.")
	EID:addCard(enums.Pickups.DeliObjectHeart,
			"Add random heart directly to player. #Red, soul, black, eternal, rotten, golden, bone, heart container or broken. #While on the ground - randomly cycle between delirious pickups. #80% chance to not be consumed and reroll its effect. #Only one delirious pickups can be held at the same time.")
	EID:addCard(enums.Pickups.DeliObjectCoin,
			"Add random coin. #Penny, nickel, dime, or lucky. #While on the ground - randomly cycle between delirious pickups. #80% chance to not be consumed and reroll its effect. #Only one delirious pickups can be held at the same time.")
	EID:addCard(enums.Pickups.DeliObjectBattery,
			"Randomly charge active item. #2 points, full charge or overcharge. #While on the ground - randomly cycle between delirious pickups. #80% chance to not be consumed and reroll its effect. #Only one delirious pickups can be held at the same time.")

	EID:addCard(enums.Pickups.RedPill,
			"Temporary ↑ {{Damage}} +10.8 Damage up. #Damage up slowly fades away similarly to {{Collectible621}} Red Stew. #Apply 2 layers of {{Collectible582}} Wavy Cap effect.")
	EID:addCard(enums.Pickups.RedPillHorse,
			"Temporary ↑ {{Damage}} +21.6 Damage up. #Damage up slowly fades away similarly to {{Collectible621}} Red Stew. #Apply 4 layers of {{Collectible582}} Wavy Cap effect.")

	EID:addCard(enums.Pickups.KittenBomb,
			"{{Warning}} Use this card or 'explode' after 3 seconds. #If card is in an extra pocket, it will not 'explode'. #Activate {{Collectible483}} Mama Mega Explosion for current room. #List of possible 'explode' effects if card wasn't used: #\7 Activate {{Pill}} Horse pill Horf effect. #\7 Activate {{Pill}} Horse pill Explosive Diarrhea effect. #\7 Spawn 3 Epic Fetus rockets around the room. #\7 Spawn 3 Golden troll bombs around the room. #\7 Spawn 3 Giga bombs around the room.")
	EID:addCard(enums.Pickups.KittenDefuse,
			"{{Trinket63}} Safety Scissors effect. #Turn all troll bombs, giga bombs, throwable bombs into their respective bomb variants.")
	EID:addCard(enums.Pickups.KittenFuture,
			"Use {{Collectible419}} Teleport 2.0. #Teleports you to uncleared random room.")
	EID:addCard(enums.Pickups.KittenNope,
			"Use {{Collectible478}} Pause. #Freezes all enemies in the room.")
	EID:addCard(enums.Pickups.KittenSkip,
			"Open all regular doors in room. #No effect on boss room.")
	EID:addCard(enums.Pickups.KittenFavor,
			"Use {{Collectible".. enums.Items.StrangeBox .."}} Strange Box. #Spawn {{Collectible249}} option choice items and pickups.")
	EID:addCard(enums.Pickups.KittenShuffle,
			"Use {{Collectible".. enums.Items.RubikDiceScrambled0 .."}} Rubik's Dice. #Turn all items in room into {{Collectible721}} glitched items.")
	EID:addCard(enums.Pickups.KittenAttack,
			"Use {{Collectible49}} Shoop da Whoop! #Shoot brimstone laser.")
	EID:addCard(enums.Pickups.KittenBomb2,
			"{{Warning}} Use this card or 'explode' after 3 seconds. #If card is in an extra pocket, it will not 'explode'. #Spawn 3 pickup Giga bombs near player. #List of possible 'explode' effects if card wasn't used: #\7 Activate {{Pill}} Horse pill Horf effect. #\7 Activate {{Pill}} Horse pill Explosive Diarrhea effect. #\7 Spawn 3 Epic Fetus rockets around the room. #\7 Spawn 3 Golden troll bombs around the room. #\7 Spawn 3 Giga bombs around the room.")
	EID:addCard(enums.Pickups.KittenDefuse2,
			"Use {{Trinket522}} Telekinesis.")
	EID:addCard(enums.Pickups.KittenFuture2,
			"Grants {{Collectible161}} Ankh item, but only if you don't have this item.")
	EID:addCard(enums.Pickups.KittenNope2,
			"Apply 1 {{Collectible313}} Holy Mantle effect for current room.")
	EID:addCard(enums.Pickups.KittenSkip2,
			"Tears get spectral and piercing effect.")
	EID:addCard(enums.Pickups.KittenFavor2,
			"Trigger {{Collectible689}} Glitched Crown effect. #All items in room cycle between 5 random items.")
	EID:addCard(enums.Pickups.KittenShuffle2,
			"Trigger {{Collectible258}} Missing No. effect. #Randomizes your items.")
	EID:addCard(enums.Pickups.KittenAttack2,
			"Use {{Collectible611}} Larynx at full charge. #Isaac shouts, damaging and pushing away nearby enemies.")
	
	EID:addCollectible(enums.Items.ElderMyth,
			"Spawn {{Card}} Loop cards.")
	EID:addCollectible(enums.Items.ForgottenGrimoire,
			"Add {{EmptyBoneHeart}} 1 bone heart.")
	EID:addCollectible(enums.Items.CodexAnimarum,
			"Spawn {{Collectible684}} 1 Hungry Soul.")
	EID:addCollectible(enums.Items.RedBook,
			"Spawn 1 red pickup. #Possible pickups: {{Heart}} red hearts, {{Card49}} dice shards, {{Pill}} red pills, {{Card78}} cracked keys, {{Bomb}} red throwable bombs.")
	EID:addCollectible(enums.Items.CosmicEncyclopedia,
			"Spawn 6 pickups of one type. #Possible pickups: hearts, coins, keys, bombs, chests, bags, cards, pills, batteries, items.")
	EID:addCollectible(enums.Items.HolyHealing,
			"{{Heart}} Full health#If you don't have any red hearts add 3 soul hearts#If you don't have any hearts add Holy Mantle")
	EID:addCollectible(enums.Items.AncientVolume,
			"Grants {{Collectible497}} Camo Undies effect.")
	EID:addCollectible(enums.Items.WizardBook,
			"Spawn 2-4 random locusts.")
	EID:addCollectible(enums.Items.RitualManuscripts,
			"Add {{BlendedHeart}} Blended Heart.")		
	EID:addCollectible(enums.Items.StitchedPapers,
			"Each tear has a random effect in the current room.")	
			
	EID:addCollectible(enums.Items.NirlyCodex,
			"You can collect up to 5 cards into a Book. #When used, activates all collected cards. #Hold Drop button to discard all cards.")	
	EID:addCollectible(enums.Items.AlchemicNotes,
			"Turn all pickups into their wisps versions.")	
		EID:addCollectible(enums.Items.LockedGrimoire,
			"Consumes 1 key per use. #Drops content of random chest. #Possible chest rewards: nothing, 100% regular, 50% golden, 15% old, 15% wooden, 15% red, 10% mega chests.")
	EID:addCollectible(enums.Items.StoneScripture,
			"Can be used 3 times in one room. #Fully recharges when entering new room. #Using the item causes ghost explosion.")
	EID:addCollectible(enums.Items.HuntersJournal,
			"Spawn 2 black chargers. #When charger dies activates Black Hole.")
	EID:addCollectible(enums.Items.TomeDead,
			"Enemies leave little ghosts, you can collect them. #Every 10 collected ghosts grants 1 charge. #Use the book to release Purgatory souls. #The book can be used without being fully charged.")		
	EID:addTrinket(enums.Trinkets.WarHand,
			"16% chacne to replace regular bomb pickup into giga bomb pickup.")				
	local description_tetris = "Rerolls empty pedestal into an item from a random pool"
	
	EID:addCollectible(enums.Items.TetrisDice_full, description_tetris)
	EID:addCollectible(enums.Items.TetrisDice1, description_tetris)
	EID:addCollectible(enums.Items.TetrisDice2, description_tetris)
	EID:addCollectible(enums.Items.TetrisDice3, description_tetris)
	EID:addCollectible(enums.Items.TetrisDice4, description_tetris)
	EID:addCollectible(enums.Items.TetrisDice5, description_tetris)
	EID:addCollectible(enums.Items.TetrisDice6, description_tetris)
	
	---Русский EID
	description_tetris = "Меняет пустой пьедестал в предмет из случайного пула"
	EID:addCollectible(enums.Items.TetrisDice_full, description_tetris, "Кубик Тетриса", "ru")
	EID:addCollectible(enums.Items.TetrisDice1, description_tetris, "Тетракуб", "ru")
	EID:addCollectible(enums.Items.TetrisDice2, description_tetris, "2 Тетракуба", "ru")
	EID:addCollectible(enums.Items.TetrisDice3, description_tetris, "3 Тетракуба", "ru")
	EID:addCollectible(enums.Items.TetrisDice4, description_tetris, "4 Тетракуба", "ru")
	EID:addCollectible(enums.Items.TetrisDice5, description_tetris, "5 Тетракуба", "ru")
	EID:addCollectible(enums.Items.TetrisDice6, description_tetris, "6 Тетракуба", "ru")
	
	EID:addTrinket(enums.Trinkets.WarHand,
			"16% шанс заменить обычную бомбу на гигабомбу.", "Рука Войны", "ru")
	EID:addCollectible(enums.Items.TomeDead,
			"Враги оставляют маленьких призраков, их можно собирать. #Каждые 10 собранных призраков дают 1 заряд. #Используйте книгу, чтобы освободить души Чистилища. #Книгу можно использовать без полной зарядки", "Фолиант мертвых","ru")		
	EID:addCollectible(enums.Items.LockedGrimoire,
			"Расходует 1 ключ за использование. #Выбрасывает содержимое случайного сундука. #Возможные награды сундуков: ничего, 100% обычные, 50% золотые, 15% старые, 15% деревянные, 15% красные, 10% мегасундуки.", "Закрытый гримуар", "ru")	
	EID:addCollectible(enums.Items.StoneScripture,
			"Может быть использован 3 раза в одной комнате. #Полная перезарядка в новой комнате. #При использований создает взрыв призрака.", "Каменное Писание", "ru")
	EID:addCollectible(enums.Items.HuntersJournal,
			"Призывает 2 черных личинок. #Когда личинка умирает активирует эффект Черной дыры.", "Журнал Охотника", "ru")
	EID:addCollectible(enums.Items.AlchemicNotes,
			"Превращает все расходники в огоньки.", "Алхимические заметки", "ru")
	
	EID:addCollectible(enums.Items.NirlyCodex,
			"Вы можете собрать 10 карт в Книгу. #При использовании активирует все собранные карты. #Удерживайте кнопку сброса, чтобы сбросить все карты.", "Кодекс Нирли", "ru")
	EID:addCollectible(enums.Items.StitchedPapers,
			"Каждая слеза имеет случайный эффект в текущей комнате.", "Сшитые бумажки", "ru")
	EID:addCollectible(enums.Items.WizardBook,
			"Создает 2-4 случайных саранчи.", "Книга Волшебника", "ru")
	EID:addCollectible(enums.Items.RitualManuscripts,
			"Добавляет {{BlendedHeart}} смешанное сердце.", "Ритуальные рукописи", "ru")
	EID:addCollectible(enums.Items.AncientVolume,
			"Дает эффект {{Collectible497}} Камуфляжных трусов.", "Древний священный том", "ru")
	EID:addCollectible(enums.Items.HolyHealing,
			"{{Heart}}Полное лечение.", "Том святого исцеления", "ru")
	EID:addCollectible(enums.Items.CosmicEncyclopedia,
			"Создает 6 предметов одного типа. #Возможные премдметы: сердца, монеты, ключи, бомбы, сундуки, мешки, карты, пилюли, батарейки, предметы", "Космическая энциклопедия", "ru")
	EID:addCollectible(enums.Items.RedBook,
			"Создает 1 красный расходник. #Возможные расходники: {{Heart}} красное сердце, {{Card49}} осколок кости, {{Pill}} красная пилюля, {{Card78}} треснувший ключ, {{Bomb}} красная бросаемая бомба.", "Красная книга", "ru")
	EID:addCollectible(enums.Items.CodexAnimarum,
			"Создает {{Collectible684}} 1 призрака", "Кодекс Душ", "ru")
	EID:addCollectible(enums.Items.ElderMyth,
			"Создает {{Card}} Loop карты", "Древний Миф", "ru")
	EID:addCollectible(enums.Items.ForgottenGrimoire,
			"Добавляет {{EmptyBoneHeart}} 1 костяное сердце", "Забытый гримуар", "ru")
	
	EID:addBirthright(enums.Characters.Nadab, "Невосприимчивость к взрыву и огню. #Создает 3 случайных предмета из пула {{BombBeggar}} Попрошайки бомб. #Можно взять только один.", "Надав", "ru")
	EID:addBirthright(enums.Characters.Abihu, "Невосприимчивость к взрыву и огню. #{{Heart}} Полное востановления здоровье. #{{Chargeable}} Зарядка синего пламени всегда активна.", "Авиуд", "ru")
	EID:addBirthright(enums.Characters.Unbidden, "Убирает одно {{BrokenHeart}} разбитое сердце и добавляет {{SoulHeart}} синее сердце. #Предметные огоньки больше не удаляются в начале следующего этажа.", "Непрошенный", "ru")
	EID:addBirthright(enums.Characters.UnbiddenB, "Убирает и предотвращает появление проклятий. #Устанавливает счетчик перемотки на 100%. #{{Collectible".. enums.Items.Threshold .."}} Порог больше не уменьшает счетчик перемотки, когда он использовался для превращения огонька в предмет.", "Порченый Непрошенный", "ru")

	disk_desk = "!!! ОДНОРАЗОВЫЙ !!! #Сохраните свои предметы. #Если у вас есть сохраненные предметы: замените свои предметы сохраненными предметами. #{{Warning}} Дает {{Collectible258}} Потерянный № если сохраненный предмет отсутствует."
	EID:addCollectible(enums.Items.FloppyDisk, disk_desk, "Дискета", "ru")
	EID:addCollectible(enums.Items.FloppyDiskFull, disk_desk, "Дискета", "ru")

	EID:addCollectible(enums.Items.RedMirror,
			"Превращает ближайший {{Trinket}} брелок в {{Card78}} треснувший ключ.", "Красное зеркало", "ru")
	EID:addCollectible(enums.Items.RedLotus,
			"Удаляет одно {{BrokenHeart}} разбитое сердце и дает {{Damage}} 1.0 увеличение урона в начале этажа.", "Красный лотос", "ru")
	EID:addCollectible(enums.Items.MidasCurse,
			"+3 {{GoldenHeart}} золотых сердец. #10% шанс получить золотые расходники. #Когда вы теряете золотое сердце, превращайте все в золото. #{{Warning}} Эффект проклятия: # {{Warning}} 100% шанс получить золотые расходники. # {{Warning}} Все предметы, связанные с едой, превращаются в монеты, если вы пытаетесь их поднять. #Эффект проклятия можно снять с помощью {{Collectible260}} Черной Свечи.", "Проклятие Мидаса", "ru")
	EID:addCollectible(enums.Items.RubberDuck,
			"↑ {{Luck}} +20 к временной удаче. #↑ {{Luck}} +1 удача при входе в непосещенную комнату. #↓ {{Luck}} -1 удача при входе в посещенную комнату. #Временная удача не может быть ниже реальной удачи игрока.", "Утенок", "ru")
	EID:addCollectible(enums.Items.IvoryOil,
			"Заряжайте активные предметы при входе в непройденную комнату в первый раз.", "Масло Айвори", "ru")
	EID:addCollectible(enums.Items.BlackKnight,
			"Вы не можете двигаться. #При использрваний прыгайте к маркеру. #Сокрушайте и отбрасывайте монстров, когда приземляетесь на землю. #Каменных монстров можно уничтожить.", "Черный конь", "ru")
	EID:addCollectible(enums.Items.WhiteKnight,
			"При использрваний прыгайте к ближайшему врагу. #Сокрушайте и отбрасывайте монстров, когда приземляетесь на землю. #Каменных монстров можно уничтожить.", "Белый конь", "ru")
	EID:addCollectible(enums.Items.KeeperMirror,
			"Продай предмет или расходник внутри маркера. #Создает 1 монету, если не было выбрано ни одного предмета.", "Луносвет", "ru")

	EID:addCollectible(enums.Items.RedBag,
			"Шанс создать красный расходник после зачистки комнаты. #Возможные расходники: {{Heart}} красное сердце, {{Card49}} осколок кости, {{Pill}} красная пилюля, {{Card78}} треснувший ключ, {{Bomb}} красная бросаемая бомба. #{{Warning}} Есть шанс создать красную какашку.", "Красный мешок", "ru")
	EID:addCollectible(enums.Items.MeltedCandle,
			"Слезы имеют шанс наложить воск на врагов на 3 секунды. #Враги с воском {{Freezing}} заморожены и будут {{Burning}} гореть. #Когда враг умирает, то созадет огонь.", "Расплавленная свеча", "ru")
	EID:addCollectible(enums.Items.MiniPony,
			"Дает полет и {{Speed}} 1.5 скорость. #При использований дает эффект {{Collectible77}} Мой маленький единорог.", "Единорог", "ru")
	EID:addCollectible(enums.Items.StrangeBox,
			"Создает {{Collectible249}} предметы и расходники на выбор для предметов и расходников в комнате.", "Странная коробка", "ru")
	EID:addCollectible(enums.Items.RedButton,
			"Создает красную кнопку при входе в комнату. #При нажатий ативирует случайный эффект кнопки. #{{Warning}}Исчезает после 66 нажатий в текущей комнате.", "Красная кнопка", "ru")
	EID:addCollectible(enums.Items.LostMirror,
			"Превращает игрока в {{Player10}} душу.", "Потерянное зеркало", "ru")
	EID:addCollectible(enums.Items.BleedingGrimoire,
			"Начни {{BleedingOut}} кровоточит. #Слезы накладывают {{BleedingOut}} кровотечение на врагов.", "Кровоточащий гримуар", "ru")
	EID:addCollectible(enums.Items.BlackBook,
			"Добавляет случайный статус эффект всем врагам в комнате. #Возможные статусы: {{Freezing}}Замарозка; {{Poison}}Яд; {{Slow}}Замедление; {{Charm}}Очарование; {{Confusion}}Конфузия; {{Collectible202}}Прикосновение Мидаса; {{Fear}}Страх; {{Burning}}Поджог; {{Collectible398}}Уменшение; {{BleedingOut}}Кровотечение; {{Collectible596}}Ледяной; {{Magnetize}}Намагниченный; {{Bait}}Приманка.", "Черная книга", "ru")

	description = "В 'решенной' форме {{Collectible105}} меняет предметы. #{{Warning}} Меняеть форму на {{Collectible".. enums.Items.RubikDiceScrambled0 .."}} 'перемешанную' и увеличивает свой максимальный заряд. #В 'перемешанной' форме может быть использован и без полного заряда, но замененный предмет всегда будет {{Collectible721}} глючным. #После полной зарядки, возвращяет в 'решенную' форму."
	EID:addCollectible(enums.Items.RubikDice, description, "Кости Рубика", "ru")
	EID:addCollectible(enums.Items.RubikDiceScrambled0, description, "Перемешанные кости Рубика", "ru")
	EID:addCollectible(enums.Items.RubikDiceScrambled1, description, "Перемешанные кости Рубика", "ru")
	EID:addCollectible(enums.Items.RubikDiceScrambled2, description, "Перемешанные кости Рубика", "ru")
	EID:addCollectible(enums.Items.RubikDiceScrambled3, description, "Перемешанные кости Рубика", "ru")
	EID:addCollectible(enums.Items.RubikDiceScrambled4, description, "Перемешанные кости Рубика", "ru")
	EID:addCollectible(enums.Items.RubikDiceScrambled5, description, "Перемешанные кости Рубика", "ru")

	EID:addCollectible(enums.Items.VHSCassette,
			"!!! ОДНОРАЗОВЫЙ !!! #Переместись на случайный следующий этаж. #Пустота - последний возможный этаж. #При вознесений переместись Домой. #Создает 12 предметов двух типов.", "Видеокассета", "ru")
	EID:addCollectible(enums.Items.Lililith,
			"Созадет случайного спутника каждые 7 комнат. #Созданные спутники удаляются при переходе на новый этаж. #Возможные спутники: {{Collectible113}} Малыш демон, {{Collectible275}} Маленькая сера, {{Collectible679}} Малютка Абаддон, {{Collectible360}} Инкуб, {{Collectible417}} Суккуб, {{Collectible270}} Пиявка, {{Collectible698}} Нечестивая парочка.", "Лилилит", "ru")
	EID:addCollectible(enums.Items.CompoBombs,
			"+5 Бомб. #К бомбам прикрепляется красна бросаемая бомба.", "Композитные бомбы", "ru")
	EID:addCollectible(enums.Items.MirrorBombs,
			"+5 Бомб. #Бомбы будут отражаться на противоположной стороне комнаты.", "Стеклянные бомбы", "ru")
	EID:addCollectible(enums.Items.GravityBombs,
			"+1 Гига бомба. #Бомбы получают эффект {{Collectible512}} Черной дыры.", "Чернодырные бомбы", "ru")
	EID:addCollectible(enums.Items.AbihuFam,
			"{{Collectible281}} Отвлекающий спутник. #может {{Burning}} поджечь врагов.", "Авиуд", "ru")
	EID:addCollectible(enums.Items.NadabBody,
			"{{Throwable}} Можно подобрать и бросить. #Блокирует слезы врагов. #После броска взрывается при контакте с врагом. #{{Warning}} Взрыв может нанести игроку урон!", "Тело Надава", "ru")
	EID:addCollectible(enums.Items.Limb,
			"Если игрок умер и у него нету дополнительных жизней, то он возродиться в виде {{Player10}} Потерянного на текущий этаж.", "Лимб", "ru")
	EID:addCollectible(enums.Items.LongElk,
			"Дает полет. #Пока игрок движется, оставляет {{Collectible683}} костяшки. #При использований, игрок совершает короткий рывок и убивает врага на пути.", "Длинный олень", "ru")
	EID:addCollectible(enums.Items.FrostyBombs,
			"+5 Бомб. #Бомбы оставляют след из слез. #Бомбы {{Slow}} замедляют врагов. #Враги превращаются в ледяные статуи после смерти.", "Ледяные бомбы", "ru")
	EID:addCollectible(enums.Items.VoidKarma,
			"↑ Увеличение всех параметров при переходе на новый этаж. #{{Damage}} +0.25 урон #{{Tears}} +0.25 скорострельность #{{Range}} +2.5 далность #{{Shotspeed}} +0.1 скорость слезы #{{Speed}} +0.05 скорость #{{Luck}} +0.5 удачи #Дублирует свой эффект, если игрок не получил урона на предыдущем этаже.", "Уровень Кармы", "ru")
	EID:addCollectible(enums.Items.CharonObol,
			"Заплати {{Coin}} 1 монету чтобы призвать {{Collectible684}} призрака. #Удаляется если игрок умирает.", "Обол Харона", "ru")
	EID:addCollectible(enums.Items.Viridian,
			"Дает полет. #Переворачивает игрока.", "VVV", "ru")
	EID:addCollectible(enums.Items.BookMemory,
			"Стирает всех врагов в комнате из текущей игры. #Не может стереть боссов. #Добавляет одно {{BrokenHeart}} разбитое сердце.", "Книга памяти", "ru")
	EID:addCollectible(enums.Items.MongoCells,
			"Копируй своих спутников. #Описание спутников содержат информацию о том, какие бонусы они добавят.", "Монго клетки", "ru")
	EID:addCollectible(enums.Items.CosmicJam,
			"Доавляет предметных огоньков из всех предметов в комнате.", "Космическое варенье", "ru")
	EID:addCollectible(enums.Items.DMS,
			"25% шанс что после смерти враги создадут {{Collectible634}} призраков.", "Серп Смерти", "ru")
	EID:addCollectible(enums.Items.MewGen,
			"Дает полет. #Если не стрелять больше 5 секнд, использует {{Collectible522}} Телекинез.", "Мяу-Ген", "ru")
	EID:addCollectible(enums.Items.ElderSign,
			"Создает пентаграмму на 3 секнду в месте где стоял игрок. #Пентаграмма созадет {{Collectible634}} призрака. #Враги внутри пентаграммы {{Freezing}} застывають.", "Знак Старших", "ru")
	EID:addCollectible(enums.Items.Eclipse,
			"Пока игрок стреляет создает ауру, которая наносит урон врагам #{{Damage}} x2.0 увеличение урона ауры, если на уровне есть {{CurseDarkness}} проклятие темноты.", "Затмение", "ru")
	EID:addCollectible(enums.Items.Threshold,
			"Если у игрока есть предметные огоньки: дает предмет из предметного огонька. #\7 Испорченный Непрошенный: -1% перемотки. #Если нет предметных огоньков, то дает эффект Черной руны: #\7 Наносит 40 урона всем врагам в комнате. #\7 Поглощает все предметы в комнате и дает повышение случайных характеристик. #\7 Превращает все расходники в комнате в синих мух и пауков.", "Порог", "ru")
	EID:addCollectible(enums.Items.WitchPot,
			"Создает новый брелок. #40% шанс поглотить брелок. #40% шанс выплюнуть поглощенный брелок. #10% шанс заменить брелок в кармане. #{{Warning}} 10% шанс уничтожить брелок в кармане.", "Ведьмин горшок", "ru")
	EID:addCollectible(enums.Items.PandoraJar,
			"Добавляет пурпурный огонек с самонаводящимися слезами. #{{Warning}} 15% шанс добавить проклятие. #Если все проклятия были добавлены, срабатывает эффект {{Collectible515}} Загадочного подарка. Эффект срабатывает только один раз за этаж.", "Кувшин Пандоры", "ru")
	EID:addCollectible(enums.Items.DiceBombs,
			"+5 Бомб. #Бомбы меняют предметы и расходники в области взрыва. #Меняет врагов пережившыих взрыв на более слабые их версии.", "Бомбы-кубики", "ru")
	EID:addCollectible(enums.Items.BatteryBombs,
			"+5 Бомб. #Бомбы стреляют 5 лазерами в разыне стороны при взрыве. #Заражает активный предмет игрока если он попал в область взрыва бомбы. #Очки заряда зависять от урона бомб.", "Бомбы батарейки", "ru")
	EID:addCollectible(enums.Items.Pyrophilia,
			"+5 Бомб. #Восстанавливает половинку сердца если враг попал под взрыв.", "Пирофилия", "ru")
	EID:addCollectible(enums.Items.SpikedCollar,
			"Вместо получения урона использует {{Collectible126}} Лезвие бритвы.", "Шипастый ошейник", "ru")
	EID:addCollectible(enums.Items.DeadBombs,
			"+5 Бомб. #Создает {{Collectible683}} Орбитальный кусочек кости за кждого убитого врага взрывом бомбы. #33% шанс создать: Костяшка, Бледный, Костяная муха, Большая костяшка, Чёрная костяшка или Ревенант.", "Мертвые бомбы", "ru")
	EID:addCollectible(enums.Items.AgonyBox,
			"Предотвращает следующий входящий урон и удаляет одно очко заряда. #Переход на новый этаж перезаряжает одно очко заряда.", "Куб агонии", "ru")-- #Charges 1 point when you take damage from spikes in {{SacrificeRoom}} Sacrifice Room.
	EID:addCollectible(enums.Items.Potato,
			"+1 Контейнер сердца", "Картоха", "ru")
	EID:addCollectible(enums.Items.SecretLoveLetter,
			"Можно бросить в выбранном напрвлений. #Письмо не имеет урона. #При контакте с врагом, очаровывает его и всех врагов этого типа, пока письмо не было использовано на другом враге. #Очарованные враги сохраняются между комнатами и этажами. #Очаровывает боссов только на короткое время.", "Секретное любовное письмо", "ru")
	EID:addCollectible(enums.Items.SurrogateConception,
			"После зачистки комнаты босса создает одного случайного спутника босса. #Срабатывает только один раз за этаж.", "Суррогатное зачатие", "ru")
	EID:addCollectible(enums.Items.HeartTransplant,
			"Заряжается каждые ~2 секунды, #Сбрасывается при полном заряде. #Каждое использование дает бонус к урону, скорострельности и скорости; и увеличивает счетчик ударов. #Высокий счетчик ударов дает увеличенный бонус, но быструю перезарядку предмета. #При максимальном счетчик ударов: стреляй 10 слезами вокруг себя. #Неудачное использование предмета уменьшает счетчик ударов.", "Пересадка сердца", "ru")
	EID:addCollectible(enums.Items.NadabBrain,
			"{{Throwable}} Спутник, запускается в сторону куда стреляет игрок. #Взрывается, поджигает и оставляет огонь при контакте с врагом. #Очень медленный.", "Мозг Надава", "ru")
	EID:addCollectible(enums.Items.GardenTrowel,
			"Создает {{Collectible683}} костяные шпоры. #Может выкопать земляную насыпь как {{Card34}} руна Ehwaz или {{Collectible84}} Нам нужно глубже!", "Садовая лопатка", "ru")
	
	EID:addTrinket(enums.Trinkets.WitchPaper,
			"{{Collectible422}} Поверните время вспять, когда вы умрете. #Уничтожается после срабатывания.", "Ведьмина бумага", "ru")
	EID:addTrinket(enums.Trinkets.QueenSpades,
			"33% шанс создать портал в случайную комнату после зачистки комнаты. #Убирает портал если вы покинули комнату.", "Порванный Пик", "ru")
	EID:addTrinket(enums.Trinkets.RedScissors,
			"Превращает тролль-бомбы в красные бросаемые бомбы.", "Красные ножницы", "ru") -- inferior scissors, nah
	EID:addTrinket(enums.Trinkets.Duotine,
			"Заменяет все {{Pill}} пилюли на Красные пилюли.", "Дуотин", "ru")
	EID:addTrinket(enums.Trinkets.LostFlower,
			"Дает {{Heart}} полный контейнер сердца при подборе {{EternalHeart}} вечного сердца. #Уничтожается при получении урона. #{{Player10}}{{Player31}} Потерянный: использует {{Card51}} Святую карту при подборе вечного сердца. #{{Player10}}{{Player31}} Потерянный: использование Потерянного зеркала когда у вас есть этот брелок активирует эффект Святой карты.", "Потерянный цветок", "ru")
	EID:addTrinket(enums.Trinkets.TeaBag,
			"Убирает отравленные и пердежные облака рядом с игроком.", "Чайный пакетик", "ru")
	EID:addTrinket(enums.Trinkets.MilkTeeth,
			"15% шанс что враги при смерти создадут исчезающую {{Coin}} монетку.", "Молочный зубик", "ru")
	EID:addTrinket(enums.Trinkets.BobTongue,
			"Бомбы получают отравляющую ауру похожий на эффект {{Collectible446}} Мёртвого зуба.", "Язык Боба", "ru")
	EID:addTrinket(enums.Trinkets.BinderClip,
			"10% шанс получить двойные сердца, монеты, ключи и бомбы. #{{Collectible670}} Расходникик с выбором больше не исчезают.", "Зажим", "ru")
	EID:addTrinket(enums.Trinkets.MemoryFragment,
			"Создает 3 последних {{Card}}{{Rune}}{{Pill}} расходника которые были использованы в начале следующего этажа.", "Обрывок воспоминаний", "ru") -- +1 golden/mombox/stackable
	EID:addTrinket(enums.Trinkets.AbyssCart,
			"Если вас убили и у вас есть спутник малыш, то убирает его и воскрешает вас. #Жертвенные спутники начинают мигать когда у вас остается половинка сердца. #Уничтожается после срабатывания и создает {{EternalHeart}} вечное сердце.", "Картридж?", "ru")
	EID:addTrinket(enums.Trinkets.RubikCubelet,
			"33% шанс заменить предметы в комнате на {{Collectible721}} глючные предметы при получений урона.", "Кублет Рубика", "ru")
	EID:addTrinket(enums.Trinkets.TeaFungus,
			"Комнаты заполнены водой.", "Чайный гриб", "ru")
	EID:addTrinket(enums.Trinkets.DeadEgg,
			"Создает мертвую птичку на 10 секунд при взрыве бомб.", "Мертвое яйцо", "ru")
	EID:addTrinket(enums.Trinkets.Penance,
			"16% шанс добавить значок с красным крестом над врагами при заходе в комнату. #При убийстве врага со значком, создается 4 световых лазера.", "Епитимья", "ru")
	EID:addTrinket(enums.Trinkets.Pompom,
			"При подборе {{Heart}} сердца есть шанс что она превратиться в случайный красный огонек.", "Гранат", "ru")
	EID:addTrinket(enums.Trinkets.XmasLetter,
			"50% шанс использовать {{Collectible557}} Печенье с предсказанием при входе в комнату в первый раз. #Если оставить этот брелок в {{DevilRoom}} комнате дьявола то при следующем заходе в комнату она превратиться в {{Collectible515}} Загадочный подарок.", "Рождественское письмо", "ru")
	EID:addTrinket(enums.Trinkets.BlackPepper,
			"Красные бросаемые бомбы получают эфеект от ваших модификаторов бомб.", "Черный перчик", "ru")
	EID:addTrinket(enums.Trinkets.Cybercutlet,
			"Автоматически заменяет предметы еды. #Если игрок получил урон, восстанавливает 1 полное сердце и удаляется.", "Кибер котлета", "ru")
	EID:addTrinket(enums.Trinkets.GildedFork,
			"Превращает красные сердца в монеты. #Пол-сердца в 2 монеты; #Полное сердце в 3 монеты; #Двойные сердца в 6 монет.", "Позолченная вилка", "ru")
	EID:addTrinket(enums.Trinkets.GoldenEgg,
			"Превращает сердца, монеты, ключи, бомбы, пилюлюи, батарейки и брелки в золотые версий при подборе. #66% шанс уничтожения при срабатывании.", "Золотое яйцо", "ru")
	EID:addTrinket(enums.Trinkets.BrokenJawbone,
			"Создает земляную насыпь в секретных и супер секретных комнатах. #Земляную насыпь можно выкопать с помощью {{Card34}} руна Ehwaz, {{Collectible84}} Нам нужно глубже! или {{Collectible".. enums.Items.GardenTrowel .."}} Садовой лопаткой.", "Сломанная челюсть", "ru")

	EID:addCard(enums.Pickups.OblivionCard,
			"Выбрасывается и мгновенно стирает любого врага. #Стирает врагов только на текущий этаж.", "Карта Забвение", "ru")
	EID:addCard(enums.Pickups.BattlefieldCard,
			"Телепортирует в {{ChallengeRoom}} комнату испытаний боссами за пределами карты.", "Карта Поле битвы", "ru")
	EID:addCard(enums.Pickups.TreasuryCard,
			"Телепортирует в {{TreasureRoom}} сокровищницу за пределами карты.", "Карта Казна", "ru")
	EID:addCard(enums.Pickups.BookeryCard,
			"Телепортирует в {{Library}} библиотеку за пределами карты.", "Карта Книжарня", "ru")
	EID:addCard(enums.Pickups.BloodGroveCard,
			"Телепортирует в {{CursedRoom}} проклятую комнату за пределами карты.", "Карта Кровавая роща", "ru")
	EID:addCard(enums.Pickups.StormTempleCard,
			"Телепортирует в {{AngelRoom}} комнату ангела за пределами карты.", "Карта Храм молний", "ru")
	EID:addCard(enums.Pickups.ArsenalCard,
			"Телепортирует в {{ChestRoom}} Хранилище за пределами карты.", "Карта Арсенал", "ru")
	EID:addCard(enums.Pickups.OutpostCard,
			"Телепортирует в {{IsaacsRoom}} {{BarrenRoom}} Спальню за пределами карты.", "Карта Застава", "ru")
	EID:addCard(enums.Pickups.CryptCard,
			"Телепортирует в {{LadderRoom}} Ретро сокровищницу за пределами карты.", "Карта Родовой склеп", "ru")
	EID:addCard(enums.Pickups.MazeMemoryCard,
			"Телепортирует в {{TreasureRoom}} комнату за пределами карты, которая содержит 18 случайных предметов. #Можно взять только один. #Добавляет {{CurseBlind}} проклятие слепоты на этаж.", "Карта Лабиринт памяти", "ru")
	EID:addCard(enums.Pickups.ZeroMilestoneCard,
			"Создает предмет который меняется между предметами пула комнаты.", "Карта Нулевой меридиан", "ru")
	EID:addCard(enums.Pickups.CemeteryCard,
			"Телепортирует в {{SuperSecretRoom}} супер секретную комнату за пределами карты. #Комната содержит {{Collectible".. enums.Items.GardenTrowel .."}} Садовую лопатку и 4 земляные насыпи.", "Карта Кладбище", "ru")
	EID:addCard(enums.Pickups.VillageCard,
			"Телепортирует в {{ArcadeRoom}} игровую комнату за пределами карты.", "Карта Деревня", "ru")
	EID:addCard(enums.Pickups.GroveCard,
			"Телепортирует в {{ChallengeRoom}} комнату испытаний за пределами карты. #Комната содержит предмет из пула сокровищницы.", "Карта Роща", "ru")
	EID:addCard(enums.Pickups.WheatFieldsCard,
			"Телепортирует в {{ChestRoom}} Хранилище за пределами карты. #Все прдеметы в комнате золотые.", "Карта Пшеничные поля", "ru")	
	EID:addCard(enums.Pickups.RuinsCard,
			"Телепортирует в {{SecretRoom}} секретную комнату за пределами карты.", "Карта Руины", "ru")				
	EID:addCard(enums.Pickups.SwampCard,
			"Телепортирует в {{SuperSecretRoom}} супер секретную комнату за пределами карты. #Комната содержит гнилые сердца и гнилого попрошайку.", "Карта Болото", "ru")	
	EID:addCard(enums.Pickups.SpiderCocoonCard,
			"Активиреет Паучью задницу, Коробку с пауками, Зараженный! и Зараженный?", "Карта Паучий кокон", "ru")	
	EID:addCard(enums.Pickups.RoadLanternCard,
			"Дает предметный огонек {{Collectible91}} Каски спелеолога c 1 оз.", "Карта Дорожный фонарь", "ru")	
	EID:addCard(enums.Pickups.ChronoCrystalsCard,
			"Дает предметный огонек {{Collectible514}} Сломанного модема c 1 оз.", "Карта Хронокристаллы", "ru")	
	EID:addCard(enums.Pickups.VampireMansionCard,
			"Телепортирует в {{SuperSecretRoom}} супер секретную комнату за пределами карты. #Комната содержит черное сердце и дьявольского попрошайку.", "Карта Особняк вампиров", "ru")					
	EID:addCard(enums.Pickups.SmithForgeCard,
			"Поглощает тринкеты (эффект Плавильни). #Телепортирует в {{SuperSecretRoom}} супер секретную комнату за пределами карты. #Комната содержит 3 брелка", "Карта Кузнечный цех", "ru")
	EID:addCard(enums.Pickups.WitchHut,
			"Телепортирует в {{SuperSecretRoom}} супер секретную комнату за пределами карты. #Комната содержит 9 пилюл", "Карта Хижина ведьмы", "ru")
	EID:addCard(enums.Pickups.BeaconCard,
			"Телепортирует в {{Shop}} магазин c 2 предметами и автоматом пополнения за пределами карты.", "Карта Маяк", "ru")
	EID:addCard(enums.Pickups.TemporalBeaconCard,
			"Телепортирует в {{Shop}} подземный магазин с 8 предметами за пределами карты.", "Карта Маяк времени", "ru")

	EID:addCard(enums.Pickups.Apocalypse,
			"Вся комната заполняется красными какашками.", "Апокалипсис", "ru")
	EID:addCard(enums.Pickups.BannedCard,
			"Создает 2 копий этой карты.", "Запретная карта", "ru")

	EID:addCard(enums.Pickups.KingChess,
			"Черные какашки вокруг тебя.", "Черный король", "ru")
	EID:addCard(enums.Pickups.KingChessW,
			"Белые какашки вокруг тебя.", "Белый король", "ru")

	EID:addCard(enums.Pickups.GhostGem,
			"Создает 4 призрака {{Collectible634}} Чистилища.", "Призрачный камень", "ru")
	EID:addCard(enums.Pickups.Trapezohedron,
			"Превращает все {{Trinket}} брелки в {{Card78}} треснувшие ключи.", "Трапецоэдр", "ru")
	EID:addCard(enums.Pickups.SoulUnbidden,
			"Добавляет предметы из предметных огоньков. #Если у игрока нет предметных огоньков, добавляет один.", "Душа Непрошенного", "ru")
	EID:addCard(enums.Pickups.SoulNadabAbihu,
			"Невосприимчивость к взрыву и огню. #Эффект {{Collectible257}} Огненного разума и {{Collectible256}} Горячих бомб.", "Душа Надава и Авиуда", "ru")

	EID:addCard(enums.Pickups.Domino34,
			"Меняет все предметы и расходники на этаже.", "Домина 3|4", "ru")
	EID:addCard(enums.Pickups.Domino25,
			"Восстанавливает и меняет врагов в комнате.", "Домина 2|5", "ru")
	EID:addCard(enums.Pickups.Domino16,
			"Создает 6 предметов одного типа.", "Домина 1|6", "ru")
	EID:addCard(enums.Pickups.Domino00,
			"50/50 шанс удвоить или удалить все предметы, расходники и врагов", "Домина 0|0", "ru")

	EID:addCard(enums.Pickups.AscenderBane,
			"Убирает одно {{BrokenHeart}} разбитое сердце. #Добавляет случайное проклятие.", "Бремя возвышения", "ru")
	EID:addCard(enums.Pickups.Decay,
			"Превращает все ваши  {{Heart}} красные сердца в {{RottenHeart}} гнилые сердца. #{{Trinket140}} эффект Содомского яблока в текущей комнате.", "Гниение", "ru")
	EID:addCard(enums.Pickups.MultiCast,
			"Создайте 3 огонька в зависимости от вашего активного предмета. #Создает обычные огоньки, если у вас нет активного предмета", "Цепная реакция", "ru")
	EID:addCard(enums.Pickups.Wish,
			"Используй {{Collectible515}} Загадочный подарок.", "Желание", "ru")
	EID:addCard(enums.Pickups.Offering,
			"Используй {{Collectible536}} Жертвенный алтарь.", "Подношение", "ru")
	EID:addCard(enums.Pickups.InfiniteBlades,
			"Запускает 7 ножей в последнюу сторону куда стрелял игрок.", "Уйма клинков", "ru")
	EID:addCard(enums.Pickups.Transmutation,
			"Превращает все расходники и всех врагов в случайные расходники,", "Трансмутация", "ru")
	EID:addCard(enums.Pickups.RitualDagger,
			"{{Collectible114}} эффект Маминого ножа в текущей комнате.", "Ритуальный кинжал", "ru")
	EID:addCard(enums.Pickups.Fusion,
			"{{Collectible512}} кидай Черную дыру.", "Слияние", "ru")
	EID:addCard(enums.Pickups.DeuxEx,
			"↑ {{Luck}} +100 удачи в текущей комнате.", "Deus Ex Machina", "ru")
	EID:addCard(enums.Pickups.Adrenaline,
			"Превращает все ваши {{Heart}} красные сердца в {{Battery}} батарейки. #Дает эффект {{Collectible493}} Адреналина в текущей комнате.", "Адреналин", "ru")
	EID:addCard(enums.Pickups.Corruption,
			"Можно использовать активный предмет бесплатно x10 раз в текущей комнате. #{{Warning}} Удаляет ваш активный предмет в следующей комнате или после использования активного предмета 10 раз. #{{Warning}} Не работает на карманный активный предмет.", "Скверна", "ru")

	EID:addCard(enums.Pickups.DeliObjectCell,
			"Создает дружелюбного монстра. #Враг из пула встреченных врагов. #Пока лежит на земля - случайно меняется на другой бредовый расходник. #При использований с 80% шансом может не исчезнуть и заменяется на другой бредовый расходник. #Одновременно можно подобрать только один бредовый расходник.", "Бредовая клетка", "ru")
	EID:addCard(enums.Pickups.DeliObjectBomb,
			"Создает бомбу со случайным эффектом, #Есть шанс создать тролль-бомбу. #Пока лежит на земля - случайно меняется на другой бредовый расходник. #При использований с 80% шансом может не исчезнуть и заменяется на другой бредовый расходник. #Одновременно можно подобрать только один бредовый расходник.", "Бредовая бомба", "ru")
	EID:addCard(enums.Pickups.DeliObjectKey,
			"Открывает ближайщий сундук или дверь. #Если нет запертого сундука или двери, по возможности открывает красную комнату. #Пока лежит на земля - случайно меняется на другой бредовый расходник. #При использований с 80% шансом может не исчезнуть и заменяется на другой бредовый расходник. #Одновременно можно подобрать только один бредовый расходник.", "Бредовый ключ", "ru")
	EID:addCard(enums.Pickups.DeliObjectCard,
			"Случайный эффект карты. #Пока лежит на земля - случайно меняется на другой бредовый расходник. #При использований с 80% шансом может не исчезнуть и заменяется на другой бредовый расходник. #Одновременно можно подобрать только один бредовый расходник.", "Бредовая карта", "ru")
	EID:addCard(enums.Pickups.DeliObjectPill,
			"Случайный эффект пилюли. #Пока лежит на земля - случайно меняется на другой бредовый расходник. #При использований с 80% шансом может не исчезнуть и заменяется на другой бредовый расходник. #Одновременно можно подобрать только один бредовый расходник.", "Бредовая пилюля", "ru")
	EID:addCard(enums.Pickups.DeliObjectRune,
			"Случайный эффект руны или души. #Пока лежит на земля - случайно меняется на другой бредовый расходник. #При использований с 80% шансом может не исчезнуть и заменяется на другой бредовый расходник. #Одновременно можно подобрать только один бредовый расходник.", "Бредовая руна", "ru")
	EID:addCard(enums.Pickups.DeliObjectHeart,
			"Добавляет игроку случайное сердце. #Красное, синее, черное, вечное, гнилое, золотое, костяное, контейнер или разбитое сердце. #Пока лежит на земля - случайно меняется на другой бредовый расходник. #При использований с 80% шансом может не исчезнуть и заменяется на другой бредовый расходник. #Одновременно можно подобрать только один бредовый расходник.", "Бредовое сердце", "ru")
	EID:addCard(enums.Pickups.DeliObjectCoin,
			"Добавляет случайную монету. #Пенни, пятак, червонец, или счастливый пенни. #Пока лежит на земля - случайно меняется на другой бредовый расходник. #При использований с 80% шансом может не исчезнуть и заменяется на другой бредовый расходник. #Одновременно можно подобрать только один бредовый расходник.", "Бредовая монета", "ru")
	EID:addCard(enums.Pickups.DeliObjectBattery,
			"Случайно зараяжает активный предмет. #2 пункта, полный заряд или двойной полный заряд. #Пока лежит на земля - случайно меняется на другой бредовый расходник. #При использований с 80% шансом может не исчезнуть и заменяется на другой бредовый расходник. #Одновременно можно подобрать только один бредовый расходник.", "Бредовая батарейка", "ru")

	EID:addCard(enums.Pickups.RedPill,
			"Временное ↑ {{Damage}} увеличение урона на +10.8. #Урон постепенно угасает, подобно {{Collectible621}} Красной похлёбке. #Накладывает 2 слоя эффекта {{Collectible582}} Волнистой шляпки.", "Красная пилюля", "ru")
	EID:addCard(enums.Pickups.RedPillHorse,
			"Временное ↑ {{Damage}} увеличение урона на +21.6. #Урон постепенно угасает, подобно {{Collectible621}} Красной похлёбке. #Накладывает 4 слоя эффекта {{Collectible582}} Волнистой шляпки,", "Красная пилюля", "ru")

	EID:addCard(enums.Pickups.KittenBomb,
			"{{Warning}} Используй эту карту или 'взорвись' через 3 секунды. #Если карта в дополнительном кармане, она не 'взорвется'. #Используй {{Collectible483}} Маму Мега! в текущей комнате. #Список возможный эффектов 'взорвись' если карта не была использована: #\7 Используй {{Pill}} лошадиную пилюлю Хорф! #\7 Используй {{Pill}} лошадиную пилюлю Взрывная диарея! #\7 Создает 3 ракеты Эпичного Зародыша в комнате. #\7 Создает 3 золотых тролль-бомб в комнате. #\7 Создает 3 Гига бомбы в комнате.", "Взрывной котенок", "ru")
	EID:addCard(enums.Pickups.KittenDefuse,
			"Эффект {{Trinket63}} Безопасных ножниц. #Обезвреживает тролль-бомбы и делает их обычными подбираемыми бомбами.", "Карта Обезвредь", "ru")
	EID:addCard(enums.Pickups.KittenFuture,
			"Используй {{Collectible419}} Телепорт 2.0. #Телепортирует в случайную комнату, в которой вы еще не были.", "Карта Подсмутри грядущее", "ru")
	EID:addCard(enums.Pickups.KittenNope,
			"Используй {{Collectible478}} Паузу. #Все враги замирают.", "Карта Неть", "ru")
	EID:addCard(enums.Pickups.KittenSkip,
			"Открывает все обычные двери в комнате. #Не действует в комнате босса.", "Карта Слиняй", "ru")
	EID:addCard(enums.Pickups.KittenFavor,
			"Используй {{Collectible".. enums.Items.StrangeBox .."}} Странную коробку. #{{Collectible249}} Создает предметы и расходники на выбор.", "Карта Подлижись", "ru")
	EID:addCard(enums.Pickups.KittenShuffle,
			"Используй {{Collectible".. enums.Items.RubikDiceScrambled0 .."}} Кости Рубика. #Превращяет все предметы в комнате в {{Collectible721}} глючные предметы.", "Карта Затасуй", "ru")
	EID:addCard(enums.Pickups.KittenAttack,
			"Используй {{Collectible49}} Шуп Да Вуп! #Атака серным лазером.", "Карта Нападай", "ru")
	EID:addCard(enums.Pickups.KittenBomb2,
			"{{Warning}} Используй эту карту или 'взорвись' через 3 секунды. #Если карта в дополнительном кармане, она не 'взорвется'. #Саздает 3 подбираемых Гига бомб рядом с игроком. #Список возможный эффектов 'взорвись' если карта не была использована: #\7 Используй {{Pill}} лошадиную пилюлю Хорф! #\7 Используй {{Pill}} лошадиную пилюлю Взрывная диарея! #\7 Создает 3 ракеты Эпичного Зародыша в комнате. #\7 Создает 3 золотых тролль-бомб в комнате. #\7 Создает 3 Гига бомбы в комнате.", "Взрывной котенок", "ru")
	EID:addCard(enums.Pickups.KittenDefuse2,
			"Используй {{Trinket522}} Телекинез.", "Карта Обезвредь", "ru")
	EID:addCard(enums.Pickups.KittenFuture2,
			"Дает {{Collectible161}} Анкх, но только если у вас нет этого предмета.", "Карта Подсмутри грядущее", "ru")
	EID:addCard(enums.Pickups.KittenNope2,
			"Эффект {{Collectible313}} Святой мантии в текущей комнате.", "Карта Неть", "ru")
	EID:addCard(enums.Pickups.KittenSkip2,
			"Слезы проходять через врагов и препятствия", "Карта Слиняй", "ru")
	EID:addCard(enums.Pickups.KittenFavor2,
			"Эффект {{Collectible689}} Глючной короны. #Пьедесталы предметов быстро переключаются между 5 случайными предметами.", "Карта Подлижись", "ru")
	EID:addCard(enums.Pickups.KittenShuffle2,
			"Эффект {{Collectible258}} Потерянный №. #Меняет все твой предметы.", "Карта Затасуй", "ru")
	EID:addCard(enums.Pickups.KittenAttack2,
			"Используй {{Collectible611}} Гортань на полную мощность. #Персонаж кричит, нанося урон и отталкивая ближайших врагов.", "Карта Нападай", "ru")

	-- Mongo Cells modifier

	local MongoFamiliarsUpdate = {}
	MongoFamiliarsUpdate[CollectibleType.COLLECTIBLE_DRY_BABY] = "#{{Collectible".. enums.Items.MongoCells .."}} Mongo Cells: 33% chance to activate Necronomicon when you take non-self damage."
	MongoFamiliarsUpdate[CollectibleType.COLLECTIBLE_FARTING_BABY] = "#{{Collectible".. enums.Items.MongoCells .."}} Mongo Cells: 33% chance to random farting when you take non-self damage."
	MongoFamiliarsUpdate[CollectibleType.COLLECTIBLE_BBF] = "#{{Collectible".. enums.Items.MongoCells .."}} Mongo Cells: explode when you take non-self damage."
	MongoFamiliarsUpdate[CollectibleType.COLLECTIBLE_BOBS_BRAIN] = "#{{Collectible".. enums.Items.MongoCells .."}} Mongo Cells: explode and leave poison cloud when you take non-self damage."
	MongoFamiliarsUpdate[CollectibleType.COLLECTIBLE_HOLY_WATER] = "#{{Collectible".. enums.Items.MongoCells .."}} Mongo Cells: spawn holy water creep when you take non-self damage."
	MongoFamiliarsUpdate[CollectibleType.COLLECTIBLE_DEPRESSION] = "#{{Collectible".. enums.Items.MongoCells .."}} Mongo Cells: leave water trail; 33% chance to spawn light beam when you take non-self damage."
	MongoFamiliarsUpdate[CollectibleType.COLLECTIBLE_MOMS_RAZOR] = "#{{Collectible".. enums.Items.MongoCells .."}} Mongo Cells: apply bleeding to you when you take non-self damage."
	MongoFamiliarsUpdate[CollectibleType.COLLECTIBLE_LITTLE_STEVEN] = "#{{Collectible".. enums.Items.MongoCells .."}} Mongo Cells: Homing tears."
	MongoFamiliarsUpdate[CollectibleType.COLLECTIBLE_HARLEQUIN_BABY] = "#{{Collectible".. enums.Items.MongoCells .."}} Mongo Cells: Wiz tears, shoot tears diagonally."
	MongoFamiliarsUpdate[CollectibleType.COLLECTIBLE_FREEZER_BABY] = "#{{Collectible".. enums.Items.MongoCells .."}} Mongo Cells: shoot ice tears; grants Uranus effect."
	MongoFamiliarsUpdate[CollectibleType.COLLECTIBLE_GHOST_BABY] = "#{{Collectible".. enums.Items.MongoCells .."}} Mongo Cells: shoot spectral tears."
	MongoFamiliarsUpdate[CollectibleType.COLLECTIBLE_ABEL] = "#{{Collectible".. enums.Items.MongoCells .."}} Mongo Cells: shoot boomerang tears."
	MongoFamiliarsUpdate[CollectibleType.COLLECTIBLE_RAINBOW_BABY] = "#{{Collectible".. enums.Items.MongoCells .."}} Mongo Cells: shoot random tears."
	MongoFamiliarsUpdate[CollectibleType.COLLECTIBLE_LIL_BRIMSTONE] = "#{{Collectible".. enums.Items.MongoCells .."}} Mongo Cells: grants Brimstone lasers."
	MongoFamiliarsUpdate[CollectibleType.COLLECTIBLE_BALL_OF_BANDAGES] = "#{{Collectible".. enums.Items.MongoCells .."}} Mongo Cells: only if familiar Lv.2 or above; tears can charm enemies."
	MongoFamiliarsUpdate[CollectibleType.COLLECTIBLE_LIL_HAUNT] = "#{{Collectible".. enums.Items.MongoCells .."}} Mongo Cells: tears can apply fear to enemies."
	MongoFamiliarsUpdate[CollectibleType.COLLECTIBLE_SISSY_LONGLEGS] = "#{{Collectible".. enums.Items.MongoCells .."}} Mongo Cells: periodically spawn blue spiders."
	MongoFamiliarsUpdate[CollectibleType.COLLECTIBLE_BUDDY_IN_A_BOX] = "#{{Collectible".. enums.Items.MongoCells .."}} Mongo Cells: shoot random tears."
	MongoFamiliarsUpdate[CollectibleType.COLLECTIBLE_HEADLESS_BABY] = "#{{Collectible".. enums.Items.MongoCells .."}} Mongo Cells: leave trail of blood."
	MongoFamiliarsUpdate[CollectibleType.COLLECTIBLE_TWISTED_PAIR] = "#{{Collectible".. enums.Items.MongoCells .."}} Mongo Cells: shoot 2 tears at once"
	MongoFamiliarsUpdate[CollectibleType.COLLECTIBLE_1UP] = "#{{Collectible".. enums.Items.MongoCells .."}} Mongo Cells: tears can shrink enemies"
	MongoFamiliarsUpdate[CollectibleType.COLLECTIBLE_SISTER_MAGGY] = "#{{Collectible".. enums.Items.MongoCells .."}} Mongo Cells: Dmg up"
	MongoFamiliarsUpdate[CollectibleType.COLLECTIBLE_LIL_ABADDON] = "#{{Collectible".. enums.Items.MongoCells .."}} Mongo Cells: grants Maw of the Void; firing tears for 3 seconds and releasing the fire button creates a black brimstone ring"
	MongoFamiliarsUpdate[CollectibleType.COLLECTIBLE_LIL_LOKI] = "#{{Collectible".. enums.Items.MongoCells .."}} Mongo Cells: chance to shoot tears in 4 directions"
	MongoFamiliarsUpdate[CollectibleType.COLLECTIBLE_LIL_MONSTRO] = "#{{Collectible".. enums.Items.MongoCells .."}} Mongo Cells: grants Monstro's Lung; tears are charged and released in a shotgun style attack."
	MongoFamiliarsUpdate[CollectibleType.COLLECTIBLE_LITTLE_GISH] = "#{{Collectible".. enums.Items.MongoCells .."}} Mongo Cells: leave black slowing creep and cahnce to shoot slowing tears."
	MongoFamiliarsUpdate[CollectibleType.COLLECTIBLE_MYSTERY_EGG] = "#{{Collectible".. enums.Items.MongoCells .."}} Mongo Cells: entering a hostile room has a chance to spawn a charmed enemy."
	MongoFamiliarsUpdate[CollectibleType.COLLECTIBLE_MULTIDIMENSIONAL_BABY] = "#{{Collectible".. enums.Items.MongoCells .."}} Mongo Cells: grants Continuum tears."
	MongoFamiliarsUpdate[CollectibleType.COLLECTIBLE_ACID_BABY] = "#{{Collectible".. enums.Items.MongoCells .."}} Mongo Cells: pills doesn't have negative effects."
	MongoFamiliarsUpdate[CollectibleType.COLLECTIBLE_SPIDER_MOD] = "#{{Collectible".. enums.Items.MongoCells .."}} Mongo Cells: you can see the contents of chests, bags, shopkeepers and fireplaces."
	MongoFamiliarsUpdate[CollectibleType.COLLECTIBLE_SERAPHIM] = "#{{Collectible".. enums.Items.MongoCells .."}} Mongo Cells: get Sacred Heart effect."
	MongoFamiliarsUpdate[CollectibleType.COLLECTIBLE_BUMBO] = "#{{Collectible".. enums.Items.MongoCells .."}} Mongo Cells: increases the coin cap to 999."
	MongoFamiliarsUpdate[CollectibleType.COLLECTIBLE_CHARGED_BABY] = "#{{Collectible".. enums.Items.MongoCells .."}} Mongo Cells: you can overcharge your active items."
	MongoFamiliarsUpdate[CollectibleType.COLLECTIBLE_FATES_REWARD] = "#{{Collectible".. enums.Items.MongoCells .."}} Mongo Cells: you can fly."
	MongoFamiliarsUpdate[CollectibleType.COLLECTIBLE_KING_BABY] = "#{{Collectible".. enums.Items.MongoCells .."}} Mongo Cells: grants Glitched Crown effect; item pedestals quickly cycle between 5 random items."
	MongoFamiliarsUpdate[CollectibleType.COLLECTIBLE_YO_LISTEN] = "#{{Collectible".. enums.Items.MongoCells .."}} Mongo Cells: X-Ray vision."
	MongoFamiliarsUpdate[CollectibleType.COLLECTIBLE_BROTHER_BOBBY] = "#{{Collectible".. enums.Items.MongoCells .."}} Mongo Cells: shooting in one direction gradually decreases tear delay."
	MongoFamiliarsUpdate[CollectibleType.COLLECTIBLE_ROBO_BABY] = "#{{Collectible".. enums.Items.MongoCells .."}} Mongo Cells: player shoot lasers"
	MongoFamiliarsUpdate[CollectibleType.COLLECTIBLE_ROBO_BABY_2] = "#{{Collectible".. enums.Items.MongoCells .."}} Mongo Cells: player shoot continuous laser"
	MongoFamiliarsUpdate[CollectibleType.COLLECTIBLE_ROTTEN_BABY] = "#{{Collectible".. enums.Items.MongoCells .."}} Mongo Cells: tears have a chance to spawn blue flies."
	MongoFamiliarsUpdate[CollectibleType.COLLECTIBLE_DEMON_BABY] = "#{{Collectible".. enums.Items.MongoCells .."}} Mongo Cells: grants Marked effect; automatically fire tears at a movable red target."
	MongoFamiliarsUpdate[CollectibleType.COLLECTIBLE_BOT_FLY] = "#{{Collectible".. enums.Items.MongoCells .."}} Mongo Cells: shielded tears; tears can block enemy tears."
	MongoFamiliarsUpdate[CollectibleType.COLLECTIBLE_BOILED_BABY] = "#{{Collectible".. enums.Items.MongoCells .."}} Mongo Cells: grants Haemolacria effect; shoot tears in arc"
	MongoFamiliarsUpdate[CollectibleType.COLLECTIBLE_BLOOD_PUPPY] = "#{{Collectible".. enums.Items.MongoCells .."}} Mongo Cells: grants Charm of Vampire effect; killing 13 enemies heals half a heart."
	MongoFamiliarsUpdate[CollectibleType.COLLECTIBLE_LEECH] = "#{{Collectible".. enums.Items.MongoCells .."}} Mongo Cells: grants Charm of Vampire effect; killing 13 enemies heals half a heart."

	local function MongoCellsModifier(descObj) -- descObj contains all informations about the currently described entity
		if descObj.ObjType == 5 and descObj.ObjVariant == 100 and MongoFamiliarsUpdate[descObj.ObjSubType] then return true end
	end
	local function MongoCellsCallback(descObj)
		-- alter the description object as you like
		EID:appendToDescription(descObj, MongoFamiliarsUpdate[descObj.ObjSubType])
		return descObj -- return the modified description object
	end
	
	
	
	EID:addDescriptionModifier("Mongo Cells Modifier", MongoCellsModifier, MongoCellsCallback)
end
