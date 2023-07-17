if Encyclopedia then
	local mod = EclipsedMod
	local enums = mod.enums
	local functions = mod.functions
	
	function Encyclopedia.AddDelirious(itemTab)
		Encyclopedia.AddPocketItem(itemTab, "delirious")
	end

	function Encyclopedia.AddSpecial(itemTab)
		Encyclopedia.AddPocketItem(itemTab, "especial")
	end

	local KittenTrivia =
		{ -- Trivia
			{str = "Trivia", fsize = 2, clr = 3, halign = 0},
			{str = "Exploding Kitten Cards is a reference to the card game Exploding Kittens."},
			{str = "Exploding Kittens is a highly-strategic, kitty powered version of Russian Roulette."},
			{str = "Players draw cards until somebody draws an Exploding Kitten, at which point they explode and are out of the game. To avoid exploding, they can defuse the kitten with a laser pointer or catnip sandwich OR use powerful action cards to move or avoid the Exploding Kitten."},
			{str = "Betray your friends. Try not to explode. The last player left alive wins."},
		}
	local DuotineTrivia =
		{ -- Trivia
			{str = "Trivia", fsize = 2, clr = 3, halign = 0},
			{str = "Red Pill (Duotine) is a reference to the game Fran Bow."},
			{str = "Fran Bow is a point and click adventure with a touch of horror by Killmonday Games. You play as Fran Bow, a ten year old girl with extraordinary curiosity but also a troubled mind and a story to tell!"},
			{str = "Duotine is the brand of psychoactive pills seen throughout the game"},
			{str = "Red Duotine, causes severe hallucinations and may even cause users to see into the Ultrareality."},
		}
	local LoopHeroTrivia =
		{ -- Trivia
			{str = "Trivia", fsize = 2, clr = 3, halign = 0},
			{str = "Loop Cards is a reference to the game Loop Hero."},
			{str = "Loop Hero is an indie deckbuilding game by Four Quarters. The Lich has thrown the world into a timeless loop and plunged its inhabitants into never ending chaos."},
			{str = "Wield an expanding deck of mystical cards to place enemies, buildings, and terrain along each unique expedition loop for the brave hero."},
		}
	local SlayTheSpireTrivia =
	{ -- Trivia
		{str = "Trivia", fsize = 2, clr = 3, halign = 0},
		{str = "This Cards is a reference to the game Slay The Spire."},
		{str = "Slay the Spire is a roguelike deck-building game."},
		{str = "Player, through one of four characters, attempts to ascend a spire of multiple floors, created through procedural generation, battling through enemies and bosses."},
		{str = "Combat takes place through a collectible card game-based system, with the player gaining new cards as rewards from combat and other means, requiring the player to use strategies of deck-building games to construct an effective deck to complete the climb."},
	}

	local Wiki = {
		Unbidden = {
			{ -- Start Data
				{str = "Start Data", fsize = 2, clr = 3, halign = 0},
				{str = "Stats", clr = 3, halign = 0},
				{str = "HP: 1 Soul Heart"},
				{str = "Speed: 1.00"},
				{str = "Tears: 2.73"},
				{str = "Damage: 4.72"},
				{str = "Range: 6.50"},
				{str = "Shotspeed: 1.00"},
				{str = "Luck: -1"},
			},
			{ -- Traits
				{str = "Traits", fsize = 2, clr = 3, halign = 0},
				{str = "Unbidden can't pick up items. Instead turn them into Item Wisps."},
				{str = "Passive Item Wisps will turn into actual items at the start of next floor."},
				{str = "Active Item Wisps stay with player. Unbidden can swap between them."},
				{str = "One time use active items removes their item wisps when used. It removes only one copy of wisp."},
				{str = "Heart containers will be turned into soul hearts."},
				{str = "Unbidden can get both items from More Options, Angel rooms or Alt.Path treasure."},
				{str = "Angel chance doesn't drop when Unbiiden takes items from Devil deal."},
				{str = "When Unbidden dies, time is rewound and 1 broken heart is added."},
				{str = "If you try to pick devil deal item while you don't have required health, you will receive 1 broken heart and a half soul heart."},
			},
			{ -- Notes
				{str = "Notes", fsize = 2, clr = 3, halign = 0},
				{str = "Unbidden can't wisp quest/story items."},
				{str = "Unbidden can't wisp items inside Boss Challenge, Boss Rush, Genesis and Death Certificate rooms."},
				{str = "Item wisps will not be added when entering Void or Home."},
			},
			{ -- Interactions
				{ str = "Interactions", fsize = 2, clr = 3, halign = 0 },
				{ str = "Resurrection items are basically useless for Unbidden (Except when using Plan C). The resurrection will be triggered mostly after checking the time rewind conditions."},
				{ str = "Resurrection items triggered only after Unbidden gets 11 broken hearts."},
				{ str = "Using Plan C doesn't trigger time rewind."},
				{ str = "Unbidden can't pick up Schoolbag."},
			},
			{ -- Birthright
				{str = "Birthright", fsize = 2, clr = 3, halign = 0},
				{str = "Remove one broken heart and add a soul heart"},
				{str = "Item Wisps no longer removed at the start of next floor"},
			},
			{ -- Trivia
				{str = "Trivia", fsize = 2, clr = 3, halign = 0},
				{str = "No one asked if I wanted to be born."},
			},
		},
		UnbiddenB = {
			{ -- Start Data
				{str = "Start Data", fsize = 2, clr = 3, halign = 0},
				{str = "Items: - Threshold"},
				{str = "Stats:"},
				{str = "HP: ???"},
				{str = "Speed: 1.00"},
				{str = "Tears: 2.73"},
				{str = "Damage: 3.50"},
				{str = "Range: 6.50"},
				{str = "Shotspeed: 1.00"},
				{str = "Luck: -3"},
				{str = "Can Fly"},
			},
			{ -- Traits
				{str = "Traits", fsize = 2, clr = 3, halign = 0},
				{str = "Unbidden can't pick items. Instead turn them into Item Wisps."},
				{str = "To obtain actual passive items, use pocket item - Threshold."},
				{str = "Active Item Wisps stay with player. Unbidden can swap between them by CTRL."},
				{str = "One time use active items removes their item wisps when used. It removes only one copy of wisp."},
				{str = "Unbidden can get both items from More Options, Angel rooms or Alt.Path treasure."},
				{str = "Angel chance doesn't drop when Unbiiden takes items from Devil deal."},
				{str = "When Unbidden dies, time is rewound."},
				{str = "Unbidden has Rewind-meter, starting from 100%."},
				{str = "When Unbidden dies Rewind-meter decreases. Decrease percentage will rise after each time rewind. Decrease percentage resets after clearing room."},
				{str = "Devil deals cost 15% of Rewind-meter."},
				{str = "Using Threshold to turn wisp into item decreases 1% per use."},
				{str = "If item wisp dies, it increases Rewind-meter to 1%."},
				{str = "Clearing room increases Rewind-meter to 0.25%."},
				{str = "When Rewind-meter reaches 0% - start new game."},
				{str = "Unbidden can't shoot, but deals AoE damage to all enemies within the aura range."},
				{str = "Aura's stats based on Unbidden's stats: range, shotspeed, damage, firedelay and tear effects."},
				{str = "At least one curse is active."},
			},
			{ -- Notes
				{str = "Notes", fsize = 2, clr = 3, halign = 0},
				{str = "Unbidden can't wisp quest/story items."},
				{str = "Unbidden can't wisp items inside Boss Challenge, Boss Rush, Genesis and Death Certificate rooms."},
				{str = "Unbidden can be softlocked inside curse room."},
			},
			{ -- Interactions
				{ str = "Interactions", fsize = 2, clr = 3, halign = 0 },
				{ str = "Resurrection items are basically useless for Unbidden (Except when using Plan C). The resurrection will be triggered mostly after checking the time rewind conditions."},
				{ str = "Using Plan C drops Rewind-meter to 0."},
				{ str = "If you revive after using Plan C you can attack as usual, by shooting tears."},
				{ str = "Unbidden can't pick up Schoolbag."},	
			},
			{ -- Items
				{str = "Items", fsize = 2, clr = 3, halign = 0},
				{str = "Threshold"},
				{str = "Threshold is Unbidden's pocket active item."},
				{str = "If player has passive item wisp - turns wisp into actual item."},
				{str = "Turning wisp into item decreases Rewind-meter by 1%."},
				{str = "Threshold will indicate which wisp can be granted as item."},
				{str = "Else activates Black Rune effect:"},
				{str = "- Deals 40 damage to all enemies in the room."},
				{str = "- Consumes all pickups in the room and turns them into Blue Flies and Spiders."},
				{str = "- Consumes all pedestal items in the room and turns them into random stat upgrades."},
			},
			{ -- Birthright
				{str = "Birthright", fsize = 2, clr = 3, halign = 0},
				{str = "Remove and prevent all curses."},
				{str = "Sets Rewind-meter to 100%."},
				{str = "Threshold no longer decreses Rewind-meter when it used to turn wisp into item."},
			},
			{ -- Trivia
				{str = "Trivia", fsize = 2, clr = 3, halign = 0},
				{str = "Infinity should be understood not as some specific number, but as a size. Like the size of something that never ends."},
				{str = "Infinity is an idea, it is the concept of something that has no end, that can go on forever."},
			},
		},
		Nabab = {
			{ -- Start Data
				{str = "Start Data", fsize = 2, clr = 3, halign = 0},
				{str = "Items: - Abihu"},
				{str = "Stats", clr = 3, halign = 0},
				{str = "HP: 4 Red Hearts"},
				{str = "Speed: 0.65"},
				{str = "Tears: 2.73"},
				{str = "Damage: 4.2"},
				{str = "Range: 6.50"},
				{str = "Shotspeed: 1.00"},
				{str = "Luck: 0"},
			},
			{ -- Traits
				{str = "Traits", fsize = 2, clr = 3, halign = 0},
				{str = "Nadab explodes instead of planting a bomb."},
				{str = "Use red hearts to explode."},
				{str = "Bombs heal character for half heart."},
				{str = "You must have Heart Containers to be able to explode."},
			},
			{ -- Interactions
				{ str = "Interactions", fsize = 2, clr = 3, halign = 0 },
				{ str = "2 of Clubs: When used doubles your red hearts, similar to 2 of Hearts" },
				{ str = "Bombs Are Keys: Swaps the hearts and keys" },
			},
			{ -- Abihu
				{str = "Items", fsize = 2, clr = 3, halign = 0},
				{str = "Abihu"},
				{str = "Decoy familiar (similar to Punching Bag)"},
				{str = "Can burn enemies on contact"},
			},
			{ -- Birthright
				{str = "Birthright", fsize = 2, clr = 3, halign = 0},
				{str = "Spawns 3 random items from bomb bum item pool. Only one can be taken."},
				{str = "Prevents damage from fire and explosion."},
			},
			{ -- Trivia
				{str = "Trivia", fsize = 2, clr = 3, halign = 0},
				{str = "Nadab were the oldest son of Aaron, the brother of Moses."},
				{str = "Nadab and Abihu are known for offering 'unauthorized fire' or 'profane fire', before the Lord and dying as a result."},
				{str = "Those who served as priests before the Lord were required to serve Him honorably. If they did not, the consequence was death."},
				{str = "In the case of Aaron’s sons, they dishonored the Lord by disobeying His command."},
				{str = "The 'foreign fire' they offered did not come from a sacred brazen altar."},
			},
		},
		Abihu = {
			{ -- Start Data
				{str = "Start Data", fsize = 2, clr = 3, halign = 0},
				{str = "Items: - Nadab's Body"},
				{str = "Stats", clr = 3, halign = 0},
				{str = "HP: 4 Red Hearts"},
				{str = "Speed: 2.0"},
				{str = "Tears: 2.73"},
				{str = "Damage: 4.0"},
				{str = "Range: 6.50"},
				{str = "Shotspeed: 1.00"},
				{str = "Luck: 0"},
			},
			{ -- Traits
				{str = "Traits", fsize = 2, clr = 3, halign = 0},
				{str = "Abihu can't shoot, but when he takes damage he can charge and shoot blue flame for current room."},
				{str = "Nadab's Body explodes when you try to plant a bomb."},
				{str = "Use red hearts to explode Nadab's Body."},
				{str = "Bombs heal character for half heart."},
				{str = "You must have Heart Containers to be able to explode Nadab's Body."},
				{str = "Burn enemies touching you."},
				{str = "Abihu can pick up bomb and throw it or hold drop button to drop it."},
				{str = "If you don't holding Nadab's Body, hold drop button to respawn Nadab's Body near you."},
			},
			{ -- Interactions
				{ str = "Interactions", fsize = 2, clr = 3, halign = 0 },
				{ str = "2 of Clubs: When used doubles your red hearts, similar to 2 of Hearts" },
				{ str = "Bombs Are Keys: Swaps the hearts and keys" },
			},
			{ -- Nadab's Body
				{str = "Items", fsize = 2, clr = 3, halign = 0},
				{str = "Nadab's Body"},
				{str = "Can be picked up and thrown"},
				{str = "Blocks enemy tears"},
				{str = "When thrown explodes on contact with enemy"},
				{str = "The explosion can hurt you!"},
			},
			{ -- Birthright
				{str = "Birthright", fsize = 2, clr = 3, halign = 0},
				{str = "Full heal."},
				{str = "You can freely charge and shoot blue flame."},
				{str = "Prevents damage from fire and explosion."},
			},
			{ -- Trivia
				{str = "Trivia", fsize = 2, clr = 3, halign = 0},
				{str = "Abihu were the second oldest son of Aaron, the brother of Moses."},
				{str = "Nadab and Abihu are known for offering 'unauthorized fire' or 'profane fire', before the Lord and dying as a result."},
				{str = "Those who served as priests before the Lord were required to serve Him honorably. If they did not, the consequence was death."},
				{str = "In the case of Aaron’s sons, they dishonored the Lord by disobeying His command."},
				{str = "The 'foreign fire' they offered did not come from a sacred brazen altar."},
			},
		},

		FloppyDisk = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Save all your current items"},
				{str = "If you already have saved items, replace your current items by saved ones."},
				{str = "Gives Missing No for each missing saved item."},
			},
			{ -- Notes
				{str = "Notes", fsize = 2, clr = 3, halign = 0},
				{str = "Missing No. will be given only if you saved 'MOD' items and then disabled said 'MOD'"},
				{str = "It can give different items than saved ones if items order was shifted (by other mods)"},
			},
			{ -- virtues
				{str = "Wisp", fsize = 2, clr = 3, halign = 0},
				{str = "Random wisp"},
				{str = "If it was killed - spawn another random wisp after clearing room"},
				{str = "This effect lasts for the current run"},
			},
		},
		RedMirror = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Turn nearest trinket into cracked key"},
			},
			{ -- virtues
				{str = "Wisp", fsize = 2, clr = 3, halign = 0},
				{str = "Red key wisp"},
				{str = "Chance to open red room when entering unexplored room"},
			},
		},
		RedLotus = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Trigger at the start of stage"},
				{str = "Remove 1 broken heart and give +1 flat damage up"},
				{str = "Give +X flat damage up for each Red Lotus item"},
			},
		},
		MidasCurse = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Add 3 golden hearts"},
				{str = "When you lose golden heart turn everything into gold"},
				-- curse
				{str = "- 100% chance to get golden pickups"},
				{str = "- All food-related items turn into coins if you try to pick them"},
			},
			{ -- Synergies
				{str = "Synergies", fsize = 2, clr = 3, halign = 0},
				{str = "Black Candle: Lowered the chance to get golden pickups from 100% to 10%."},
			},
			{ -- abyss
				{str = "Abyss Locust", fsize = 2, clr = 3, halign = 0},
				{str = "An yellow locust that deals 0.1x damage and midas freezes enemies"},
			},
		},
		RubberDuck = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "+20 temporary luck up"},
				{str = "+1 luck up when entering unvisited room"},
				{str = "-1 luck down when entering visited room"},
				{str = "Temporary luck can't go below player's real luck"},
			},
			{ -- Trivia
				{str = "Trivia", fsize = 2, clr = 3, halign = 0},
				{str = "Ducking is a reference to the game Killing Room."},
				{str = "Killing Room is a rogue-like FPS with strong RPG elements set in a 22nd century reality-show parody."},
				{str = "Win a fortune or die, but never disappoint your audience. And audience is virtual or real with revolutionary but optional features for streamers and their fans."},
			},
		},
		IvoryOil = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Charge active items when entering an uncleared room for the first time"},
				{str = "Charging priority starts from the main active item, secondary item, and then pocket item."},
				{str = "Large rooms charge 2 points"},
			},
			{ -- abyss
				{str = "Abyss Locust", fsize = 2, clr = 3, halign = 0},
				{str = "A white electric locust"},
			},
			{ -- Trivia
				{str = "Trivia", fsize = 2, clr = 3, halign = 0},
				{str = "Ivory Oil is a reference to the game Iconoclasts."},
				{str = "Iconoclasts is an indie 2D open-world platformer game. It is the masterwork of indie developer Joakim Sandberg, seven long years in the making."},
				{str = "Ivory is the main source of power for the human societies of the Planet."},
			},
		},
		BlackKnight = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "You can't move, but control target mark"},
				{str = "Use to jump to target marker"},
				{str = "Crush and knockback monsters when you land on the ground"},
				{str = "Destroy stone monsters"},
			},
			{ -- abyss
				{str = "Abyss Locust", fsize = 2, clr = 3, halign = 0},
				{str = "A black locust"},
			},
			{ -- virtues
				{str = "Wisp", fsize = 2, clr = 3, halign = 0},
				{str = "A pony wisp that can't shoot, but charges in shooting direction"},
				{str = "Wisps removed when entering new room"},
			},
		},
		WhiteKnight = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Use to jump to nearest enemy"},
				{str = "Crush and knockback monsters when you land on the ground"},
				{str = "Destroy stone monsters"},
			},
			{ -- abyss
				{str = "Abyss Locust", fsize = 2, clr = 3, halign = 0},
				{str = "A white locust"},
			},
			{ -- virtues
				{str = "Wisp", fsize = 2, clr = 3, halign = 0},
				{str = "A pony wisp that can't shoot, but charges in shooting direction"},
				{str = "Wisps removed when entering new room"},
			},
		},
		KeeperMirror = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Sell item or pickup in target mark"},
				{str = "Spawn 1 coin if no pickup was targeted"},
			},
			{ -- abyss
				{str = "Abyss Locust", fsize = 2, clr = 3, halign = 0},
				{str = "A green locust that has a 20% chance to drop coin when it kills an enemy"},
			},
			{ -- virtues
				{str = "Wisp", fsize = 2, clr = 3, halign = 0},
				{str = "A green coin wisp that has a 20% chance to drop coin when it kills an enemy"},
			},
			{ -- Trivia
				{str = "Trivia", fsize = 2, clr = 3, halign = 0},
				{str = "Moonlighter (The Merchant Mirror) is a reference to the game Moonlighter, created by Digital Sun Games."},
				{str = "Moonlighter is a rogue-lite game about a shopkeeper that dreams of becoming a hero."},
				{str = "Moonlighter has procedurally generated dungeons, extremely hard bosses, tons of cool items, a mountain of gold, many silly enemies, and just one shop."},
				{str = "The Merchant Mirror allows you to turn items into Gold."},
			},
		},
		RedBag = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Chance to drop red pickups after clearing room"},
				{str = "Possible pickups: red hearts, dice shards, red pills, cracked keys, red throwable bombs"},
				{str = "Can spawn Red Poop"},
			},
		},
		MeltedCandle = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Tears have a chance to wax enemies for 3 seconds"},
				{str = "Waxed enemy freezes and burns"},
				{str = "When a waxed enemy dies, it leaves fire"},
			},
			{ -- abyss
				{str = "Abyss Locust", fsize = 2, clr = 3, halign = 0},
				{str = "A white burning locust that deals 0.5x damage and has a 50% chance to wax enemies [freeze and burn]"},
			},
		},
		MiniPony = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Grants flight and 1.5 speed while held"},
				{str = "On use, grants My Little Unicorn effect"},
			},
			{ -- abyss
				{str = "Abyss Locust", fsize = 2, clr = 3, halign = 0},
				{str = "A red locust that has a higher speed"},
			},
			{ -- virtues
				{str = "Wisp", fsize = 2, clr = 3, halign = 0},
				{str = "A rainbow wisp"},
			},
		},
		StrangeBox = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Create option choice item for all items, pickups and shop items in the room"},
			},
			{ -- abyss
				{str = "Abyss Locust", fsize = 2, clr = 3, halign = 0},
				{str = "2 black locusts that is otherwise normal"},
			},
			{ -- virtues
				{str = "Wisp", fsize = 2, clr = 3, halign = 0},
				{str = "A black wisp that shoots continuum tears"},
			},
		},
		RedButton = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Spawn Red pressure plate when entering room"},
				{str = "Activate random pressure plate effect when pressed"},
				{str = "After pressing 66 times, no longer appears in current room"},
				{str = "Have a chance to spawn killswitch button. It's chances affected by luck"},
			},
			{ -- Trivia
				{str = "Trivia", fsize = 2, clr = 3, halign = 0},
				{str = "Red Button is a reference to the game Please, Don't Touch Anything created by Four Quarters."},
				{str = "Please, Don’t Touch Anything is a cryptic, brain-racking button-pushing simulation."},
			},
		},
		LostMirror = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Turn you into soul"},
				{str = "Clear room to remove this effect"},
			},
			{ -- Interactions
				{str = "Interactions", fsize = 2, clr = 3, halign = 0},
				{str = "Lost Flower: Using Lost Mirror while holding this trinket apply Holy Mantle effect"},
			},
			{ -- virtues
				{str = "Wisp", fsize = 2, clr = 3, halign = 0},
				{str = "A big white wisp that shoots big tears"},
				{str = "If one wisp was destroyed, other wisps also will be destroyed"},
			},
		},
		BleedingGrimoire = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Start bleeding"},
				{str = "Your tears cause enemies to bleed while you bleed"},
				{str = "If you don't have red hearts, the bleeding tear effect only lasts for the current room."},
				{str = "Heal to stop bleeding"},
			},
			{ -- abyss
				{str = "Abyss Locust", fsize = 2, clr = 3, halign = 0},
				{str = "A red locust that can apply bleeding to enemies"},
			},
			{ -- virtues
				{str = "Wisp", fsize = 2, clr = 3, halign = 0},
				{str = "A red wisp that can apply bleeding to enemies"},
			},
			{ -- Trivia
				{str = "Trivia", fsize = 2, clr = 3, halign = 0},
				{str = "Bleeding Grimoire is a reference to the game They Bleed Pixels, created by indie studio Spooky Squid Games."},
				{str = "They Bleed Pixels is a fiendishly difficult action platformer inspired by H.P. Lovecraft and classic horror."},
			},
		},
		BlackBook = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Apply random status effects on enemies in room"},
				{str = "Possible effects: Freeze, Poison, Slow, Charm, Confusion, Midas Touch, Fear, Burn, Shrink, Bleed, Frozen, Magnetized, Bait"},
			},
			{ -- abyss
				{str = "Abyss Locust", fsize = 2, clr = 3, halign = 0},
				{str = "A black locust that has a 20% chance to apply random status effect"},
			},
			{ -- virtues
				{str = "Wisp", fsize = 2, clr = 3, halign = 0},
				{str = "A black wisp with random tear effects"},
			},
			{ -- Trivia
				{str = "Trivia", fsize = 2, clr = 3, halign = 0},
				{str = "Black Book is a reference to the game Black Book, created by indie studio Morteshka."},
				{str = "Black Book is a dark RPG Adventure where one plays as a young sorceress. Battle evil forces, aid commonfolk and travel across the rural countryside of Russia, where creatures from folklore live alongside humans."},
			},
		},
		RubikDice = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "In 'solved' state reroll items"},
				{str = "Turn into 'scrambled' Rubik's Dice, randomly increasing it's charge bar"},
				{str = "In 'scrambled' state it can be used without full charge, but will reroll items into glitched items"},
				{str = "At full charge, it returns to 'solved' state"},
			},
			{ -- virtues
				{str = "Wisp", fsize = 2, clr = 3, halign = 0},
				{str = "A glitched blue wisp with random tear effects"},
			},
		},
		VHSCassette = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Randomly move to later floor"},
				{str = "On ascension you will be send to Home"},
				{str = "Spawn 12 pickups of two types"},
				{str = "Possible pickup types:"},
				{str = "- coins"},
				{str = "- keys"},
				{str = "- hearts"},
				{str = "- bombs"},
				{str = "- chests"},
				{str = "- trinkets"},
				{str = "- batteries"},
				{str = "- items"},
				{str = "- shop items"},
				{str = "- pills"},
				{str = "- bags"},
				{str = "- cards and runes"},
			},
			{ -- virtues
				{str = "Wisp", fsize = 2, clr = 3, halign = 0},
				{str = "Random wisps"},
				{str = "If it was killed - spawn another random wisp after clearing room"},
				{str = "This effect lasts for the current run"},
			},
		},
		Lililith = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Spawn a random demon familiar every 7 rooms"},
				{str = "Spawned familiars will be removed on next floor"},
				{str = "Possible familiars: demon baby, lil brimstone, lil abaddon, incubus, succubus, leech, twisted pair"},
			},
			{ -- abyss
				{str = "Abyss Locust", fsize = 2, clr = 3, halign = 0},
				{str = "A swarmed red locust that has a 20% chance to spawn blue flies"},
			},
		},
		CompoBombs = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "+5 bombs when picked up"},
				{str = "Place 2 bombs at once. Second bomb is red throwable bomb"},
			},
		},
		MirrorBombs = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "+5 bombs when picked up"},
				{str = "The placed bomb will be copied to the opposite side of the room"},
			},
		},
		GravityBombs = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "+1 giga bomb when picked up"},
				{str = "Bombs get Black Hole effect"},
			},
			{ -- abyss
				{str = "Abyss Locust", fsize = 2, clr = 3, halign = 0},
				{str = "A purple locust that has a 5% chance to spawn attractor rift"},
			},
		},
		AbihuFam = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Decoy familiar"},
				{str = "Can burn enemies on contact"},
			},
			{ -- Trivia
				{str = "Trivia", fsize = 2, clr = 3, halign = 0},
				{str = "Abihu were the second oldest son of Aaron, the brother of Moses."},
				{str = "Nadab and Abihu are known for offering 'unauthorized fire' or 'profane fire', before the Lord and dying as a result."},
				{str = "Those who served as priests before the Lord were required to serve Him honorably. If they did not, the consequence was death."},
				{str = "In the case of Aaron’s sons, they dishonored the Lord by disobeying His command."},
				{str = "The 'foreign fire' they offered did not come from a sacred brazen altar."},
			},
		},
		NadabBody = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Can be picked up and thrown"},
				{str = "Blocks enemy tears"},
				{str = "When thrown explodes on contact with enemy"},
				{str = "Warning!", fsize = 2, clr = 3, halign = 0},
				{str = "The explosion can hurt you!"},
			},
			{ -- Trivia
				{str = "Trivia", fsize = 2, clr = 3, halign = 0},
				{str = "Nadab were the oldest son of Aaron, the brother of Moses."},
				{str = "Nadab and Abihu are known for offering 'unauthorized fire' or 'profane fire', before the Lord and dying as a result."},
				{str = "Those who served as priests before the Lord were required to serve Him honorably. If they did not, the consequence was death."},
				{str = "In the case of Aaron’s sons, they dishonored the Lord by disobeying His command."},
				{str = "The 'foreign fire' they offered did not come from a sacred brazen altar."},
			},
		},
		Limb = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "If you die and don't have any extra life, you will be turned into soul for current level"},
			},
			{ -- abyss
				{str = "Abyss Locust", fsize = 2, clr = 3, halign = 0},
				{str = "A purple locust that spawns purgatory souls when it kills an enemy"},
			},
		},
		LongElk = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Grants flight. While moving leave bone spurs"},
				{str = "On use do short dash in movement direction, and kill next contacted enemy"},
				{str = "Deal massive damage to bosses"},
			},
			{ -- virtues
				{str = "Wisp", fsize = 2, clr = 3, halign = 0},
				{str = "A black wisps that activates Necronomicon when destroyed"},
			},
			{ -- judas
				{str = "Judas Birthright", fsize = 2, clr = 3, halign = 0},
				{str = "Spawn fire jets around you when enemy was touched"},
			},
			{ -- Trivia
				{str = "Trivia", fsize = 2, clr = 3, halign = 0},
				{str = "Long Elk is a reference to the game Inscryption."},
				{str = "Inscryption is an inky black card-based odyssey that blends the deckbuilding roguelike, escape-room style puzzles, and psychological horror into a blood-laced smoothie."},
			},
		},
		FrostyBombs = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "+5 bombs when picked up"},
				{str = "Bombs leave water creep"},
				{str = "Bombs slow down enemies"},
				{str = "Turn killed enemies into ice statues"},
			},
			{ -- abyss
				{str = "Abyss Locust", fsize = 2, clr = 3, halign = 0},
				{str = "A blue locust that turns killed enemies into ice statues"},
			},
		},
		VoidKarma = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "All stats up when entering new level"},
				{str = "+0.5 damage up"},
				{str = "+0.27 tears up"},
				{str = "+1.0 range up"},
				{str = "+0.1 shotspeed up"},
				{str = "+0.1 speed up"},
				{str = "+0.5 luck up"},
				{str = "Double it's effect if you didn't take damage on previous floor"},
				{str = "+1 effect for each copy of this item"},
			},
			{ -- Trivia
				{str = "Trivia", fsize = 2, clr = 3, halign = 0},
				{str = "Karma Level is a reference to the game Rain World."},
				{str = "Rain World is a physics-based survival platformer set in a long-abandoned world, taken over by creatures both fascinating and fearsome."},
				{str = "Bone-crushing intense rain pounds the surface regularly, making life as we know it almost impossible. The creatures in this world hibernate much of the time, but must spend the dry periods between rain finding food to last another day."},
				{str = "Karma is a mechanic and important plot element of Rain World."},
			},
		},
		CharonObol = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Pay 1 coin to spawn hungry soul"},
				{str = "Removes itself when you die"},
			},
			{ -- virtues
				{str = "Wisp", fsize = 2, clr = 3, halign = 0},
				{str = "A red coin wisp"},
			},
			{ -- Trivia
				{str = "Trivia", fsize = 2, clr = 3, halign = 0},
				{str = "Charon's Obol is a reference to the game Hades."},
				{str = "Hades is a roguelike game from Supergiant Games"},
				{str = "You play as Zagreus, immortal son of Hades, on his quest to escape from the underworld, fighting through many angry lost souls along the way."},
			},
		},
		Viridian = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Grants flight. Flip player's sprite"},
			},
			{ -- Trivia
				{str = "Trivia", fsize = 2, clr = 3, halign = 0},
				{str = "VVV is a reference to the game VVVVVV."},
				{str = "VVVVVV is a 2D puzzle platform game designed by Terry Cavanagh."},
				{str = "Unlike most platformers, the player can't jump. Instead, the player must flip gravity while standing on a surface."},
			},
		},
		BookMemory = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Erase all enemies in room from current run. Can't erase bosses"},
				{str = "Add broken heart when used"},
			},
			{ -- virtues
				{str = "Wisp", fsize = 2, clr = 3, halign = 0},
				{str = "A blue eraser wisp that erases enemy it touched and destroys itself"},
			},
			{ -- Trivia
				{str = "Trivia", fsize = 2, clr = 3, halign = 0},
				{str = "Book of Memories is a reference to the game Loop Hero."},
				{str = "Loop Hero is an indie deckbuilding game by Four Quarters. The Lich has thrown the world into a timeless loop and plunged its inhabitants into never ending chaos."},
				{str = "Wield an expanding deck of mystical cards to place enemies, buildings, and terrain along each unique expedition loop for the brave hero."},
			}
		},
		MongoCells = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Copy your familiars"},
				{str = "Dry baby - 33% chance to activate Necronomicon when you take non-self damage"},
				{str = "Farting baby - 33% chance to random farting when you take non-self damage"},
				{str = "BBF - explode when you take non-self damage"},
				{str = "Bob's brain - explode and leave poison cloud when you take non-self damage"},
				{str = "Holy water - spawn holy water creep when you take non-self damage"},
				{str = "Depression - leave water trail and 33% chance to spawn light beam when you take non-self damage"},
				{str = "Mom's Razor - apply bleeding to you when you take non-self damage"},
				{str = "Little Steven - Homing tears"},
				{str = "Harlequin baby - Wiz tears, shoot diagonally"},
				{str = "Freezer baby - Ice tears [Uranus]"},
				{str = "Ghost baby - Spectral tears"},
				{str = "Abel - Boomerang tears [My Reflection]"},
				{str = "Rainbow baby - Random tears [Fruit Cake]"},
				{str = "Lil Brimstone - Brimstone lasers"},
				{str = "Ball of Bandage - only if familiar Lv.2 or above. Charming tears"},
				{str = "Lil Haunt - fear tears"},
				{str = "Sissy Longlegs - periodically spawn blue spiders"},
				{str = "Buddy in a Box - Random tears [Fruit Cake]"},
				{str = "Headless baby - leave trail of blood [Anemic]"},
				{str = "Twisted Pair - double tears [20/20]"},
				{str = "1 up - shrinking tears [God's Flesh]"},
				{str = "Sister Maggy - Dmg up [Book of Belial]"},
				{str = "Lil Abaddon - grants Maw of the Void"},
				{str = "Lil Loki - shoot tears in 4 directions, chances is based on luck [Loki's Horns]"},
				{str = "Lil Monstro - grants Monstro's Lung"},
				{str = "Lil Gish - leave black slowing creep and shoot slowing tears"},
				{str = "Mystery Egg - Periodically spawn friendly monsters when entering room"},
				{str = "Multidimensional baby - Continuum tears"},
				{str = "Acid baby - pills doesn't have negative effects"},
				{str = "Spider Mod - You can see pickups inside chests [Guppy's Eye]"},
				{str = "Seraphim - get Sacred Heart effect"},
				{str = "Bumbo - increase coin limit to 999 [Deep Pockets]"},
				{str = "Charged baby - you can get extra charges on active items [Battery]"},
				{str = "Fate Rewards - you can fly"},
				{str = "King baby - grants Glitched Crown effect"},
				{str = "Yo Listen - X-Ray vision"},
				{str = "Brother Bobby - increase tears while firing in one direction [Epiphora]"},
				{str = "Robo baby - shoot lasers"},
				{str = "Robo baby 2 - shoot continuous laser"},
				{str = "Rotten baby - tears have a chance to spawn blue flies"},
				{str = "Demon baby - grants Merked effect"},
				{str = "Bot Fly - shielded tears; tears can block enemy tears"},
				{str = "Boiled baby - grants haemolacria effect; shoot tears in arc"},
				{str = "Blood Puppy - grants Charm of Vampire effect"},
				{str = "Leech - grants Charm of Vampire effect"},
			},
		},
		CosmicJam = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Add Item Wisp from all items in room"},
			},
			{ -- Interactions
				{str = "Interactions", fsize = 2, clr = 3, halign = 0},
				{str = "Book of Virtues: Item Wisps can shoot tears",},
			},
		},
		DMS = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Enemies has 25% chance to spawn purgatory soul after death"},
				{str = "Chance does not affected by luck"},
			},
		},
		MewGen = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Grants flight"},
				{str = "If don't shoot more than 5 seconds, activates Telekinesis effect"},
			},
			{ -- abyss
				{str = "Abyss Locust", fsize = 2, clr = 3, halign = 0},
				{str = "A pink locust that homes in on enemies"},
			},
			{ -- Trivia
				{str = "Trivia", fsize = 2, clr = 3, halign = 0},
				{str = "Mew-Gen is a reference to the game Mewgenics."},
				{str = "Mewgenics is an upcoming tactical role-playing roguelike life simulation video game developed by Edmund McMillen and Tyler Glaiel."},
				{str = "The game has players breed cats, which assume character classes and are sent out on adventures, featuring tactical combat on procedurally-generated grid battlegrounds."},
			}
		},
		ElderSign = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Creates Pentagram for 3 seconds at position where you stand"},
				{str = "Spawn purgatory soul and freeze enemies inside pentagram"},
			},
			{ -- abyss
				{str = "Abyss Locust", fsize = 2, clr = 3, halign = 0},
				{str = "A green locust that has a 10% chance to feeze enemies"},
			},
			{ -- virtues
				{str = "Wisp", fsize = 2, clr = 3, halign = 0},
				{str = "A green wisp that freezes all enemies in room when destroyed"},
				{str = "If one wisp was destroyed, other wisps also will be destroyed"},
			},
			{ -- judas
				{str = "Judas Birthright", fsize = 2, clr = 3, halign = 0},
				{str = "Burn enemies inside pentagram"},
				{str = "Enemies killed inside pentagram leaves fire"},
			},
			{ -- Trivia
				{str = "Trivia", fsize = 2, clr = 3, halign = 0},
				{str = "Elder Sign is a reference to the H.P. Lovecraft."},
				{str = "The Elder Sign is a symbol that is used to protect against the Great Old Ones/Outer Gods, who seem to fear it."},
				{str = "Based on Lovecraft's original letters and work it is worth observing that Lovecraft himself at times seemed to consider the sign a hand gesture."},
			}
		},
		Eclipse = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "While shooting grants pulsing aura, dealing player's damage"},
				{str = "x2.0 damage boost when level has Curse of Darkness"},
			},
		},
		Threshold = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "If player has passive item wisp - turns wisp into actual item."},
				{str = "Threshold will indicate which wisp can be granted as item."},
				{str = "- Tainted Unbidden: -1% to rewind."},
				{str = "Else activates Black Rune effect:"},
				{str = "- Deals 40 damage to all enemies in the room."},
				{str = "- Consumes all pickups in the room and turns them into Blue Flies and Spiders."},
				{str = "- Consumes all pedestal items in the room and turns them into random stat upgrades."},
			},
		},
		WitchPot = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Spawn new trinket"},
				{str = "40% chance to smelt current trinket"},
				{str = "40% chance to spit out smelted trinket"},
				{str = "10% Chance to reroll your current trinket"},
				{str = "10% Chance to destroy your current trinket"},
			},
			{ -- virtues
				{str = "Wisp", fsize = 2, clr = 3, halign = 0},
				{str = "A green wisp that adds 0.2 luck to player"},
			},
		},
		PandoraJar = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Adds a purple wisp with homing tears"},
				{str = "15% chance to add a special curse"},
				{str = "If all special curses was added, spawn random item from current item pool"},
			},
			{ -- abyss
				{str = "Abyss Locust", fsize = 2, clr = 3, halign = 0},
				{str = "6 purple locusts that deals 0.5x damage, has a 20% chance to apply fear and homes in on enemies"},
			},
			{ -- Interactions
				{str = "Interactions", fsize = 2, clr = 3, halign = 0},
				{str = "Book of Virtues: spawn 2 wisps at once",},
			},
		},
		DiceBombs = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "+5 bombs when picked up"},
				{str = "Bombs will reroll pickups, chests and items within explosion range"},
				{str = "Devolve enemies hit by an explosion"},
			},
		},
		BatteryBombs = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "+5 bombs when picked up"},
				{str = "On explosion bombs zap 5 electrical bolts in random directions"},
				{str = "Recharges active item when player is hit by an explosion"},
				{str = "Charge points based on bomb damage"},
			},
			{ -- abyss
				{str = "Abyss Locust", fsize = 2, clr = 3, halign = 0},
				{str = "An yellow electric locust"},
			},
		},
		Pyrophilia = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "+5 bombs when picked up"},
				{str = "Heal half heart when an enemy hit by a bomb explosion"},
				{str = "Effect triggers only 1 time per explosion"},
			},
		},
		SpikedCollar = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Instead taking damage activates Razor Blade effect, granting damage boost"},
			},
			{ -- Notes
				{str = "Notes", fsize = 2, clr = 3, halign = 0},
				{str = "First damage in room will be always for full heart"},
			},
		},
		AgonyBox = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Prevents next incoming damage and removes one point of charge"},
				{str = "Entering a new floor recharges one point"},
			},
			{ -- Interactions
				{str = "Interactions", fsize = 2, clr = 3, halign = 0},
				{str = "Book of Virtues: when agony box discharges, spawn a wisps that has a chance to negatate next damage after which it destroys itself",},
			},
			{ -- Trivia
				{str = "Trivia", fsize = 2, clr = 3, halign = 0},
				{str = "Agony Box is a reference to the Dune, epic science fiction novel by American author Frank Herbert."},
				{str = "Dune is set in the distant future amidst a feudal interstellar society in which various noble houses control planetary fiefs."},
				{str = "The Agony Box was a device that caused pain through 'nerve induction' without causing real harm."},
			}
		},
		Potato = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "+1 Max HP"},
			},
			{ -- Notes
				{str = "Notes", fsize = 2, clr = 3, halign = 0},
				{str = "Adds only container, without healing"},
			},
		},
		SecretLoveLetter = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Hold letter and throw it in shooting direction"},
				{str = "Letter doesn't have damage"},
				{str = "If letter touched enemy then all enemies of this type become charmed until you use Secret Love Letter on another enemy"},
				{str = "Charmed enemies saved between rooms and levels"},
				{str = "Charm bosses only for period of time"},
			},
			{ -- Notes
				{str = "Notes", fsize = 2, clr = 3, halign = 0},
				{str = "Can be used to destroy Great Gideon"},
			},
			{ -- abyss
				{str = "Abyss Locust", fsize = 2, clr = 3, halign = 0},
				{str = "A purple locust that charms enemies"},
			},
			{ -- virtues
				{str = "Wisp", fsize = 2, clr = 3, halign = 0},
				{str = "A purple wisp that apply charm to nearby enemies when destroyed"},
			},
		},
		SurrogateConception = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "After clearing boss room spawns random boss familiar"},
				{str = "Can be triggered only once per floor"},
			},
		},
		HeartTransplant = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Charges every ~2 seconds and discharges af full charge"},
				{str = "Each use grants damage, tears and speed up boost; and increases it's beat counter"},
				{str = "Higher beat counter grants better boost, but faster item recharge"},
				{str = "When used at max beat counter: fires 10 tears in a circle around the player"},
				{str = "Failed use of item decreases beat counter"},
			},
			{ -- virtues
				{str = "Wisp", fsize = 2, clr = 3, halign = 0},
				{str = "A heart shaped red wisp that can't shoot"},
				{str = "Wisps removed when entering new room"},
			},
			{ -- Notes
				{str = "Notes", fsize = 2, clr = 3, halign = 0},
				{str = "I wanted to make a character that can only shoot by using this item [personal pocket item]"},
				{str = "But idk, maybe someday"},
			},
			{ -- Trivia
				{str = "Trivia", fsize = 2, clr = 3, halign = 0},
				{str = "Heart Transplant is a reference to the game Crypt of the NecroDancer."},
				{str = "Crypt of the NecroDancer is a hardcore roguelike rhythm game."},
			}
		},
		DeadBombs = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "+5 bombs when picked up"},
				{str = "Spawn Bone Spurs for each killed enemy by explosion"},
				{str = "33% chance to spawn frinedly Bony, Pasty, Bone Fly, Big Bony, Black Bony or Revenant"},
			},
		},
		NadabBrain = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Familiar, throwed in a player shooting direction."},
				{str = "Explode, burn enemy and leave fire on contact"},
				{str = "Very low speed"},
			},
			{ -- Trivia
				{str = "Trivia", fsize = 2, clr = 3, halign = 0},
				{str = "Nadab were the oldest son of Aaron, the brother of Moses."},
				{str = "Nadab and Abihu are known for offering 'unauthorized fire' or 'profane fire', before the Lord and dying as a result."},
				{str = "Those who served as priests before the Lord were required to serve Him honorably. If they did not, the consequence was death."},
				{str = "In the case of Aaron’s sons, they dishonored the Lord by disobeying His command."},
				{str = "The 'foreign fire' they offered did not come from a sacred brazen altar."},
			},
		},
		GardenTrowel = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Spawn bone spur where you stand"},
				{str = "Can dig up dirt patches"},
			},
			{ -- virtues
				{str = "Wisp", fsize = 2, clr = 3, halign = 0},
				{str = "Spawn bone spur with a bone wisp"},
				{str = "Wisps removed when entering new room"},
				
			},
		},
		
		ElderMyth = {
			{ -- Effect
				{ str = "Effect", fsize = 2, clr = 3, halign = 0 },
				{ str = "Spawn Loop cards" },
			},
			{ -- virtues
				{ str = "Wisp", fsize = 2, clr = 3, halign = 0 },
				{ str = "Card wisps. Spawn a card when destroyed." },
			},
		},
		ForgottenGrimoire = {
			{ -- Effect
				{ str = "Effect", fsize = 2, clr = 3, halign = 0 },
				{ str = "Add 1 bone heart" },
			},
			{ -- virtues
				{ str = "Wisp", fsize = 2, clr = 3, halign = 0 },
				{ str = "Heart-like wisps" },
			},
		},
		CodexAnimarum = {
			{ -- Effect
				{ str = "Effect", fsize = 2, clr = 3, halign = 0 },
				{ str = "Spawn 1 Hungry Soul" },
			},
			{ -- virtues
				{ str = "Wisp", fsize = 2, clr = 3, halign = 0 },
				{ str = "Soul-like wisps. 50% chance to release purgatory ghost when destroyed" },
			},
		},
		RedBook = {
			{ -- Effect
				{ str = "Effect", fsize = 2, clr = 3, halign = 0 },
				{ str = "Spawn 1 red pickup" },
				{ str = "Possible pickups: red hearts, dice shards, red pills, cracked keys, red throwable bombs"},
			},
			{ -- virtues
				{ str = "Wisp", fsize = 2, clr = 3, halign = 0 },
				{ str = "Random red wisp" },
			},
		},
		CosmicEncyclopedia = {
			{ -- Effect
				{ str = "Effect", fsize = 2, clr = 3, halign = 0 },
				{ str = "Spawn 6 pickups of one type" },
				{ str = "Possible pickups: hearts, coins, keys, bombs, chests, bags, cards, pills, batteries, items" },
			},
			{ -- virtues
				{ str = "Wisp", fsize = 2, clr = 3, halign = 0 },
				{ str = "Glitched wisp with random tear effects" },
			},
		},	
		HolyHealing = {
			{ -- Effect
				{ str = "Effect", fsize = 2, clr = 3, halign = 0 },
				{ str = "Full health"},
			},
			{ -- virtues
				{ str = "Wisp", fsize = 2, clr = 3, halign = 0 },
				{ str = "Heart wisp with 20 health, can't shoot" },
			},
		},	
		AncientVolume = {
			{ -- Effect
				{ str = "Effect", fsize = 2, clr = 3, halign = 0 },
				{ str = "Grants Camo Undies effect."},
			},
			{ -- virtues
				{ str = "Wisp", fsize = 2, clr = 3, halign = 0 },
				{ str = "When wisp destroyed, grants Camo Undies effect" },
			},
		},	
		WizardBook = {
			{ -- Effect
				{ str = "Effect", fsize = 2, clr = 3, halign = 0 },
				{ str = "Spawn 2-4 random locusts" },
			},
		},
		RitualManuscripts = {
			{ -- Effect
				{ str = "Effect", fsize = 2, clr = 3, halign = 0 },
				{ str = "Add half-red and half-soul hearts" },
			},
			{ -- virtues
				{str = "Wisp", fsize = 2, clr = 3, halign = 0},
				{str = "2 heart-like wisps with 1 hp"},
			},
		},
		StitchedPapers = {
			{ -- Effect
				{ str = "Effect", fsize = 2, clr = 3, halign = 0 },
				{ str = "Each tear has a random effect in the current room" },
			},
			{ -- virtues
				{str = "Wisp", fsize = 2, clr = 3, halign = 0},
				{str = "Glitched wisp with random tear effects"},
			},
		},
		
		NirlyCodex = {
			{ -- Effect
				{ str = "Effect", fsize = 2, clr = 3, halign = 0 },
				{ str = "You can collect up to 5 cards into a Book" },
				{ str = "When used, activates all collected cards"},
				{ str = "Hold Drop button to discard all cards"},
			},
			{ -- virtues
				{str = "Wisp", fsize = 2, clr = 3, halign = 0},
				{str = "Card like wisps, if wisp kills enemy has a chance to drop random card"},
			},
		},
		AlchemicNotes = {
			{ -- Effect
				{ str = "Effect", fsize = 2, clr = 3, halign = 0 },
				{ str = "Turn all pickups in room into wisps"},
			},
			{ -- virtues
				{str = "Wisp", fsize = 2, clr = 3, halign = 0},
				{str = "Add wisps without destroying pickups"},
			},
		},
		LockedGrimoire = {
			{ -- Effect
				{ str = "Effect", fsize = 2, clr = 3, halign = 0 },
				{ str = "Consumes 1 key per use" },
				{ str = "Drops content of random chest" },
				{ str = "Possible chest rewards: nothing, 100% regular, 50% golden, 15% old, 15% wooden, 15% red, 10% mega chests" },
			},
			{ -- virtues
				{str = "Wisp", fsize = 2, clr = 3, halign = 0},
				{str = "Key-like wisp, has a chacne to drop a key when destroyed"},
			},
		},
		StoneScripture = {
			{ -- Effect
				{ str = "Effect", fsize = 2, clr = 3, halign = 0 },
				{ str = "Can be used 3 times in one room" },
				{ str = "Fully recharges when entering new room" },
				{ str = "Using the item causes ghost explosion" },
			},
			{ -- virtues
				{str = "Wisp", fsize = 2, clr = 3, halign = 0},
				{str = "Ghost-like wisps with 1 hp. When destroyed causes ghost explosion. Wisps removed when entering new room"},
			},
		},
		HuntersJournal = {
			{ -- Effect
				{ str = "Effect", fsize = 2, clr = 3, halign = 0 },
				{ str = "Spawn 2 black chargers" },
				{ str = "When charger dies - activate Black Hole effect" },
			},
			{ -- virtues
				{str = "Wisp", fsize = 2, clr = 3, halign = 0},
				{str = "Black wisps, tears have lodestone and strange attractor effects"},
			},
		},
		TomeDead = {
			{ -- Effect
				{ str = "Effect", fsize = 2, clr = 3, halign = 0 },
				{ str = "Enemies leave little ghosts, you can collect them" },
				{ str = "Every 10 collected ghosts grants 1 charge" },
				{ str = "Use the book to release Purgatory souls" },
				{ str = "The book can be used without being fully charged" },
			},
			{ -- virtues
				{str = "Wisp", fsize = 2, clr = 3, halign = 0},
				{str = "When destroyed creates ghost explosion"},
			},
			
		},
		
		TetrisDice = {
			{ -- Effect
				{ str = "Effect", fsize = 2, clr = 3, halign = 0 },
				{ str = "Rerolls items into random pool items" },
				{ str = "Rerolled items turn into ? mark items" },
			},
			{ -- virtues
				{str = "Wisp", fsize = 2, clr = 3, halign = 0},
				{str = "Dice wisp, without any special effects"},
			},
			
		},
		
		WitchPaper = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Turn back time when you die"},
				{str = "Destroys itself after triggering"},
			},
			{ -- Trivia
				{str = "Trivia", fsize = 2, clr = 3, halign = 0},
				{str = "Witch's Paper is a reference to the game Yuppie Psycho, created by Baroque Decay."},
				{str = "Yuppie Psycho is a survival horror game."},
				{str = "Set in a dystopian 90’s with shades of cyberpunk, the player will have to break into and investigate the secrets hidden deep within the heart of Sintracorp. Avoiding traps, solving puzzles, exploring, and utilizing stealth to avoid the creatures swarming the company along the way."},
			},
		},
		TornSpades = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "33% chance to spawn portal to random room after clearing room"},
				{str = "Leaving room removes portal"},
			},
			{ -- Notes
				{str = "Notes", fsize = 2, clr = 3, halign = 0},
				{str = "Increases chance for each copy of this trinket"},
			},
		},
		RedScissors = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Turn troll-bombs into red throwable bombs"},
			},
		},
		Duotine = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Replaces all future pills by Red pills while holding this trinket"},
			},
			DuotineTrivia,
		},
		LostFlower = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Give you full heart container when you get eternal heart"},
				{str = "Destroys itself when you take damage"},
				{str = "If character is the Lost activate Holy Card effect when you get eternal heart"},
			},	
			{ -- Interactions
				{str = "Interactions", fsize = 2, clr = 3, halign = 0},
				{str = "Lost Mirror: Using Lost Mirror while holding this trinket apply Holy Mantle effect"},
			},
		},
		TeaBag = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Remove poison and fart clouds near player"},
			},
			{ -- Notes
				{str = "Notes", fsize = 2, clr = 3, halign = 0},
				{str = "Increases range for each copy of this trinket"},
			},
		},
		MilkTeeth = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Enemies have a 15% chance to drop vanishing coins when they die"},
			},
			{ -- Notes
				{str = "Notes", fsize = 2, clr = 3, halign = 0},
				{str = "Increases chance for each copy of this trinket"},
			},
		},
		BobTongue = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Bombs get toxic aura, similar to Dead Tooth effect"},
			},
		},
		BinderClip = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "10% chance to get double hearts, coins, keys and bombs"},
				{str = "Pickups with option choices no longer disappear"},
			},
			{ -- Notes
				{str = "Notes", fsize = 2, clr = 3, halign = 0},
				{str = "Increases chance for each copy of this trinket"},
			},
		},
		MemoryFragment = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Spawn last 3 used cards, runes, pills at the start of next floor"},
			},
			{ -- Notes
				{str = "Notes", fsize = 2, clr = 3, halign = 0},
				{str = "spawn +1 used consumable for each copy of this trinket (Golden, Mom's Box)"},
			},
			{ -- Trivia
				{str = "Trivia", fsize = 2, clr = 3, halign = 0},
				{str = "Memory Fragment is a reference to the game Loop Hero."},
				{str = "Loop Hero is an indie deckbuilding game by Four Quarters. The Lich has thrown the world into a timeless loop and plunged its inhabitants into never ending chaos."},
				{str = "Wield an expanding deck of mystical cards to place enemies, buildings, and terrain along each unique expedition loop for the brave hero."},
			}
		},
		AbyssCart = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "If you have baby familiar when you die, remove him and revive you"},
				{str = "Sacrificable familiars will blink periodically when you have less than 1 heart"},
				{str = "Destroys itself after triggering and drops eternal heart"},
			},
			{ -- Notes
				{str = "Notes", fsize = 2, clr = 3, halign = 0},
				{str = "Increases chance of not being destroyed for each copy of this trinket"},
			},
			{ -- Trivia
				{str = "Trivia", fsize = 2, clr = 3, halign = 0},
				{str = "Cartridge? is a reference to the Made in Abyss."},
				{str = "Made in Abyss is a Japanese manga series written and illustrated by Akihito Tsukushi."},
				{str = "..."},
			}
		},
		RubikCubelet = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "33% chance to reroll items into glitched items when you take damage"},
			},
			{ -- Notes
				{str = "Notes", fsize = 2, clr = 3, halign = 0},
				{str = "Increases chance for each copy of this trinket"},
			},
		},
		TeaFungus = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Rooms are flooded"},
			},
		},
		DeadEgg = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Spawn dead bird familiar for 10 seconds when bomb explodes"},
			},
			{ -- Notes
				{str = "Notes", fsize = 2, clr = 3, halign = 0},
				{str = "+1 bird for each copy of this trinket"},
			},
		},
		Penance = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "16% chance to apply Red Cross indicator to enemies upon entering a room"},
				{str = "When marked enemies die, they shoot beams of light in 4 directions"},
			},
			{ -- Notes
				{str = "Notes", fsize = 2, clr = 3, halign = 0},
				{str = "Increases chance for each copy of this trinket"},
			},
		},
		Pompom = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Picking up red hearts can convert them into random red wisps"},
			},
		},
		XmasLetter = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "50% chance when entering room for the first time activate Fortune Cookie"},
				{str = "Leaving this trinket in devil deal turn it into Mystery Gift on next enter"},
			},
		},
		BlackPepper = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Red throwable bombs gain the bomb effects"},
			},
		},
		Cybercutlet = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Auto-reroll food items"},
				{str = "When you take damage heal 1 red heart and remove this trinket"},
			},
		},
		GildedFork = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Turn red hearts into coins"},
				{str = "Half Heart into 2 coins; Full Heart into 3 coins; Double Hearts into 6 coins"},
			},
			{ -- Notes
				{str = "Notes", fsize = 2, clr = 3, halign = 0},
				{str = "add +1 coin for each copy of this trinket (Golden, Mom's Box)"},
			},
		},
		GoldenEgg = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Turn hearts, coins, keys, bombs, pills, batteries and trinkets into their golden versions on touch"},
				{str = "66% chance to remove itself after triggering"},
			},
			{ -- Notes
				{str = "Notes", fsize = 2, clr = 3, halign = 0},
				{str = "Decrease remove chance to 33% for each copy of this trinket (Golden, Mom's Box)"},
			},
		},
		BrokenJawbone = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Spawn Forgotten's grave in secret and super secret rooms"},
				{str = "Graves can be dig up by Rune of Ehwas, We Need To Go Deeper or Garden Trowel, and spawn a random chest"},
			},
			{ -- Notes
				{str = "Notes", fsize = 2, clr = 3, halign = 0},
				{str = "+1 chest from grave for each copy of this trinket (Golden, Mom's Box)"},
			},
		},
		WarHand = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "16% chacne to replace regular bomb pickup into giga bomb pickup"},
			},
			{ -- Notes
				{str = "Notes", fsize = 2, clr = 3, halign = 0},
				{str = "+16% chance for each copy of this trinket (Golden, Mom's Box)"},
			},
		},
		
		
		OblivionCard = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Throwable eraser card. Erase enemies for current level"},
			},
			{ -- Notes
				{str = "Notes", fsize = 2, clr = 3, halign = 0},
				{str = "Can be used to destroy Great Gideon"},
			},
			LoopHeroTrivia,
		},
		BattlefieldCard = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Teleport to out of map Boss Challenge"},
			},
			LoopHeroTrivia,
		},
		TreasuryCard = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Teleport to out of map Treasury"},
			},
			LoopHeroTrivia,
		},
		BookeryCard = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Teleport to out of map Library"},
			},
			LoopHeroTrivia,
		},
		BloodGroveCard = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Teleport to out of map Curse Room"},
			},
			LoopHeroTrivia,
		},
		StormTempleCard = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Teleport to out of map Angel Room"},
			},
			LoopHeroTrivia,
		},
		ArsenalCard = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Teleport to out of map Chest Room"},
			},
			LoopHeroTrivia,
		},
		OutpostCard = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Teleport to out of map Bedroom"},
			},
			LoopHeroTrivia,
		},
		CryptCard = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Teleport to out of map Crawlspace"},
			},
			LoopHeroTrivia,
		},
		MazeMemoryCard = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Teleport to out of map room with 18 items from random pools. Only one can be taken"},
				{str = "Apply Curse of Blind for current level"},
			},
			LoopHeroTrivia,
		},
		ZeroMilestoneCard = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Spawn item which constantly changes between items of current room pool"},
			},
			LoopHeroTrivia,
		},
		Apocalypse = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Fills the whole room with red poop"},
			},
		},
		BannedCard = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Spawn 2 copies of this card"},
			},
		},
		KingChess = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Poop around you (Black poops)"},
			},
		},
		KingChessW = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Poop around you (White poops)"},
			},
		},
		GhostGem = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Spawn 4 purgatory souls"},
			},
			{ -- Trivia
				{str = "Trivia", fsize = 2, clr = 3, halign = 0},
				{str = "Ghost Gem is a reference to the game Flinthook."},
				{str = "Flinthook is a fast action-platformer with roguelike elements. Become space’s greatest pirate with your hookshot, pistol and slowmo powers!"},
			}
		},
		Trapezohedron = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Turn all trinkets into cracked keys"},
			},
		},
		SoulUnbidden = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Add items from all Item Wisps to player"},
				{str = "If player doesn't have item wisps, add one"},
			},
		},
		SoulNadabAbihu = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Fire and Explosion immunity. Fire Mind and Hot Bombs effect for current room"},
			},
		},
		Domino34 = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Reroll items and pickups on current level"},
			},
		},
		Domino25 = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Respawn and reroll enemies in current room"},
			},
		},
		Domino16 = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Spawn 6 pickups of one type"},
				{str = "Possible pickup types:"},
				{str = "- coins"},
				{str = "- keys"},
				{str = "- hearts"},
				{str = "- bombs"},
				{str = "- chests"},
				{str = "- trinkets"},
				{str = "- batteries"},
				{str = "- items"},
				{str = "- shop items"},
				{str = "- pills"},
				{str = "- bags"},
				{str = "- cards and runes"},
			},
		},
		Domino00 = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "50/50 chance to remove or double items, pickups and enemies"},
			},
			{ -- Notes
				{str = "Notes", fsize = 2, clr = 3, halign = 0},
				{str = "Doubled enemies is weakened to half"},
			},
		},
		AscenderBane = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Remove one broken heart. Add random special curse"},
			},
			SlayTheSpireTrivia,
		},
		Decay = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Turn your red hearts into rotten hearts. Apple of Sodom effect for current room"},
			},
			SlayTheSpireTrivia,
		},
		MultiCast = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Spawn 3 wisps based on your active item. Spawn regular wisps if you don't have an active item"},
			},
			SlayTheSpireTrivia,
		},
		Wish = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Mystery Gift effect"},
			},
			{ -- Notes
				{str = "Notes", fsize = 2, clr = 3, halign = 0},
				{str = "Can not be copied by Black Card"},
			},
			SlayTheSpireTrivia,
		},
		Offering = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Sacrificial Altar effect"},
			},
			SlayTheSpireTrivia,
		},
		InfiniteBlades = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Shoot 7 knives in last firing direction"},
			},
			SlayTheSpireTrivia,
		},
		Transmutation = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Reroll pickups and enemies into random pickups"},
			},
			{ -- Notes
				{str = "Notes", fsize = 2, clr = 3, halign = 0},
				{str = "Effect similar to Ace cards"},
			},
			SlayTheSpireTrivia,
		},
		RitualDagger = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Mom's Knife for current room"},
			},
			SlayTheSpireTrivia,
		},
		Fusion = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Throw a Black Hole"},
			},
			SlayTheSpireTrivia,
		},
		DeuxEx = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "+100 luck up for current room"},
			},
			SlayTheSpireTrivia,
		},
		Adrenaline = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Turn all your red hearts into batteries. Adrenaline effect for current room"},
			},
			SlayTheSpireTrivia,
		},
		Corruption = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "You can use your active item x10 times for free in current room"},
				{str = "Remove your active item on next room or when you use your active item 10 times"},
				{str = "Doesn't affect pocket active item"},
			},
			SlayTheSpireTrivia,
		},
		RedPill = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Temporary +10.8 Damage up. Damage up slowly fades away. Apply 2 layers of Wavy Cap effect"},
				{str = "Effect [Horse]", fsize = 2, clr = 3, halign = 0},
				{str = "Horse Pill - double effects"},
				
			},
			{ -- Notes
				{str = "Notes", fsize = 2, clr = 3, halign = 0},
				{str = "Added as cards. Idk how to set pill effect with color"},
			},
			DuotineTrivia,
		},
		--[[
		RedPillHorse = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Temporary +21.6 Damage up. Damage up slowly fades away. Apply 4 layers of Wavy Cap effect"},
			},
			{ -- Notes
				{str = "Notes", fsize = 2, clr = 3, halign = 0},
				{str = "Added as cards. Idk how to set pill effect with color"},
			},
			DuotineTrivia,
		},
		--]]
		KittenBomb = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Use this card or 'explode' after 3 seconds"},
				{str = "Activate Mama Mega Explosion for current room"},
				{str = "List of possible 'explode' effects if card wasn't used:"},
				{str = "- Activate Horse pill Horf effect"},
				{str = "- Activate Horse pill Explosive Diarrhea effect"},
				{str = "- Spawn 3 Epic Fetus rockets around the room"},
				{str = "- Spawn 3 Golden troll bombs around the room"},
				{str = "- Spawn 3 Giga bombs around the room"},
			},
			{ -- Notes
				{str = "Notes", fsize = 2, clr = 3, halign = 0},
				{str = "If card is in an extra pocket, it will not 'explode'"},
			},
			KittenTrivia,
		},
		KittenBomb2 = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Use this card or 'explode' after 3 seconds"},
				{str = "Spawn 3 pickup Giga bombs near player"},
				{str = "List of possible 'explode' effects if card wasn't used:"},
				{str = "- Activate Horse pill Horf effect"},
				{str = "- Activate Horse pill Explosive Diarrhea effect"},
				{str = "- Spawn 3 Epic Fetus rockets around the room"},
				{str = "- Spawn 3 Golden troll bombs around the room"},
				{str = "- Spawn 3 Giga bombs around the room"},
			},
			{ -- Notes
				{str = "Notes", fsize = 2, clr = 3, halign = 0},
				{str = "If card is in an extra pocket, it will not 'explode'"},
			},
			KittenTrivia,
		},
		KittenDefuse = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Safety Scissors effect"},
				{str = "Turn all troll bombs, giga bombs, throwable bombs into their respective bomb variants"},
			},
			KittenTrivia,
		},
		KittenDefuse2 = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Use Telekinesis"},
			},
			KittenTrivia,
		},
		KittenFuture = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Teleports you to uncleared random room"},
			},
			KittenTrivia,
		},
		KittenFuture2 = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Grants Ankh, but only if you don't have this item"},
			},
			KittenTrivia,
		},
		KittenNope = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Freezes all enemies in the room"},
			},
			KittenTrivia,
		},
		KittenNope2 = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Holy Mantle effect for current room"},
			},
			KittenTrivia,
		},
		KittenSkip = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Open all regular doors in room"},
			},
			KittenTrivia,
		},
		KittenSkip2 = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Tears get spectral and piercing effect"},
			},
			KittenTrivia,
		},
		KittenFavor = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Spawn option choice items and pickups for all items in room"},
			},
			KittenTrivia,
		},
		KittenFavor2 = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "All items in room cycle between 5 random items"},
			},
			KittenTrivia,
		},
		KittenShuffle = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Turn all items in room into glitched items"},
			},
			KittenTrivia,
		},
		KittenShuffle2 = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Trigger Missing No. effect. Randomizes your items"},
			},
			KittenTrivia,
		},
		KittenAttack = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Use Shoop da Whoop! Shoot brimstone laser"},
			},
			KittenTrivia,
		},

		KittenAttack2 = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Use Larynx at full charge. Isaac shouts, damaging and pushing away nearby enemies"},
			},
			KittenTrivia,
		},



		DeliObjectCell = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Spawn random friendly enemy"},
				{str = "The enemy is from the pool of encountered enemies in current run"},
			},
			{ -- Notes
				{str = "Notes", fsize = 2, clr = 3, halign = 0},
				{str = "While on the ground - randomly cycle between delirious pickups"},
				{str = "80% chance to not be consumed and reroll its effect"},
				{str = "Only one delirious pickups can be held at the same time"},
			},
		},
		DeliObjectBomb = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Spawn bomb with random effects"},
				{str = "Chance to spawn troll, super troll or golden troll bomb"},
			},
			{ -- Notes
				{str = "Notes", fsize = 2, clr = 3, halign = 0},
				{str = "While on the ground - randomly cycle between delirious pickups"},
				{str = "80% chance to not be consumed and reroll its effect"},
				{str = "Only one delirious pickups can be held at the same time"},
			},
		},
		DeliObjectKey = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Open nearest chest or door"},
				{str = "If room doesn't have any locked door or chests, if possible makes red room door"},
			},
			{ -- Notes
				{str = "Notes", fsize = 2, clr = 3, halign = 0},
				{str = "While on the ground - randomly cycle between delirious pickups"},
				{str = "80% chance to not be consumed and reroll its effect"},
				{str = "Only one delirious pickups can be held at the same time"},
			},
		},
		DeliObjectCard = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Random card effect"},
			},
			{ -- Notes
				{str = "Notes", fsize = 2, clr = 3, halign = 0},
				{str = "While on the ground - randomly cycle between delirious pickups"},
				{str = "80% chance to not be consumed and reroll its effect"},
				{str = "Only one delirious pickups can be held at the same time"},
			},
		},
		DeliObjectPill = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Random pill effect"},
			},
			{ -- Notes
				{str = "Notes", fsize = 2, clr = 3, halign = 0},
				{str = "While on the ground - randomly cycle between delirious pickups"},
				{str = "80% chance to not be consumed and reroll its effect"},
				{str = "Only one delirious pickups can be held at the same time"},
			},
		},
		DeliObjectRune = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Random rune or soul effect"},
			},
			{ -- Notes
				{str = "Notes", fsize = 2, clr = 3, halign = 0},
				{str = "While on the ground - randomly cycle between delirious pickups"},
				{str = "80% chance to not be consumed and reroll its effect"},
				{str = "Only one delirious pickups can be held at the same time"},
			},
		},
		DeliObjectHeart = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Add random heart directly to player"},
				{str = "Red, soul, black, eternal, rotten, golden, bone, heart container or broken"},
			},
			{ -- Notes
				{str = "Notes", fsize = 2, clr = 3, halign = 0},
				{str = "While on the ground - randomly cycle between delirious pickups"},
				{str = "80% chance to not be consumed and reroll its effect"},
				{str = "Only one delirious pickups can be held at the same time"},
			},
		},
		DeliObjectCoin = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Add random coin"},
				{str = "Penny, nickel, dime, or lucky"},
			},
			{ -- Notes
				{str = "Notes", fsize = 2, clr = 3, halign = 0},
				{str = "While on the ground - randomly cycle between delirious pickups"},
				{str = "80% chance to not be consumed and reroll its effect"},
				{str = "Only one delirious pickups can be held at the same time"},
			},
		},
		DeliObjectBattery = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Randomly charge active item"},
				{str = "2 points, full charge or overcharge"},
			},
			{ -- Notes
				{str = "Notes", fsize = 2, clr = 3, halign = 0},
				{str = "While on the ground - randomly cycle between delirious pickups"},
				{str = "80% chance to not be consumed and reroll its effect"},
				{str = "Only one delirious pickups can be held at the same time"},
			},
		},
		CemeteryCard = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Teleport to out of map Super Secret room with 4 dirt patches"},
				{str = "Spawn at room center a Garden Trowel"},
				{str = "Dirt Patches can be dig up by Rune of Ehwas, We Need To Go Deeper or Garden Trowel, and spawn a random chest"},
			},
			LoopHeroTrivia,
		},
		VillageCard = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Teleport to out of map Arcade room"},
			},
			LoopHeroTrivia,
		},
		GroveCard = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Teleport to out of map Challange room"},
				{str = "Room will contain item from treasure pool"},
			},
			LoopHeroTrivia,
		},
		WheatFieldsCard = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Teleport to out of map Chest room"},
				{str = "All pickups in room is golden"},
			},
			LoopHeroTrivia,
		},
		RuinsCard = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Teleport to out of map Secret room"},
			},
			LoopHeroTrivia,
		},
		SwampCard = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Teleport to out of map Super Secret room"},
				{str = "Room contain 3 rotten hearts and rotten beggar"},
			},
			LoopHeroTrivia,
		},
		SpiderCocoonCard = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Activates Spider Butt, Box of Spiders, Infestation! and Infestation?"},
			},
			LoopHeroTrivia,
		},
		RoadLanternCard = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Grants Spelunker Hat item wisp with 1 hp"},
			},
			LoopHeroTrivia,
		},
		VampireMansionCard = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Teleport to out of map Super Secret room"},
				{str = "Room contain 1 black heart and devil beggar"},
			},
			LoopHeroTrivia,
		},
		SmithForgeCard = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Smelt your current trinkets"},
				{str = "Teleport to out of map Super Secret room"},
				{str = "Room contains 3 trinkets"},
			},
			LoopHeroTrivia,
		},
		ChronoCrystalsCard = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Grants Broken Modem item wisp with 1 hp"},
			},
			LoopHeroTrivia,
		},
		WitchHut = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Teleport to out of map Super Secret room"},
				{str = "Room contain 9 random pills"},
			},
			LoopHeroTrivia,
		},
		BeaconCard = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Teleport to out of map Shop with 2 items and Restock machine"},
			},
			LoopHeroTrivia,
		},
		
		TemporalBeaconCard = {
			{ -- Effect
				{str = "Effect", fsize = 2, clr = 3, halign = 0},
				{str = "Teleport to out of map Member Card shop with 8 items"},
			},
			LoopHeroTrivia,
		},
	}

	Encyclopedia.AddCharacter({
		ModName = "Eclipsed",
		Name = "Unbidden",
		WikiDesc = Wiki.Unbidden,
		ID = enums.Characters.Unbidden,
	})
	Encyclopedia.AddCharacterTainted({
		ModName = "Eclipsed",
		Name = "UnbiddenB",
		Description = "The Infinite",
		WikiDesc = Wiki.UnbiddenB,
		ID = enums.Characters.UnbiddenB,
	})
	Encyclopedia.AddCharacter({
		ModName = "Eclipsed",
		Name = "Nadab",
		WikiDesc = Wiki.Nabab,
		ID = enums.Characters.Nadab,
	})
	Encyclopedia.AddCharacterTainted({
		ModName = "Eclipsed",
		Name = "Abihu",
		Description = "The Profane",
		WikiDesc = Wiki.Abihu,
		ID = enums.Characters.Abihu,
	})

	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.FloppyDisk,
		WikiDesc = Wiki.FloppyDisk,
		Pools = {
			Encyclopedia.ItemPools.POOL_ULTRA_SECRET,
		},
		UnlockFunc = function(self)
			if functions.GetCompletion("UnbiddenB", "all") < 2 then
			    self.Desc = "Earn all 12 Completion Marks on Hard mode as Tainted Unbidden."
			    return self
			end
		end,
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.FloppyDiskFull,
		WikiDesc = Wiki.FloppyDisk,
		Pools = {
			Encyclopedia.ItemPools.POOL_ULTRA_SECRET,
		},
		Hide = true,
		UnlockFunc = function(self)
			if functions.GetCompletion("UnbiddenB", "all") < 2 then
			    self.Desc = "Earn all 12 Completion Marks on Hard mode as Tainted Unbidden."
			    return self
			end
		end,
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.RedMirror,
		WikiDesc = Wiki.RedMirror,
		Pools = {
			Encyclopedia.ItemPools.POOL_TREASURE,
			Encyclopedia.ItemPools.POOL_ULTRA_SECRET,
		},
		UnlockFunc = function(self)
			if functions.GetCompletion("Unbidden", "mother") < 1 then
			    self.Desc = "Defeat Mother as Unbidden"
			    return self
			end
		end,
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.RedLotus,
		WikiDesc = Wiki.RedLotus,
		Pools = {
			Encyclopedia.ItemPools.POOL_SECRET,
			Encyclopedia.ItemPools.POOL_ULTRA_SECRET,
		},
		UnlockFunc = function(self)
			if functions.GetCompletion("Unbidden", "deli") < 1 then
			    self.Desc = "Defeat Delirium as Unbidden"
			    return self
			end
		end,
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.MidasCurse,
		WikiDesc = Wiki.MidasCurse,
		Pools = {
			Encyclopedia.ItemPools.POOL_TREASURE,
			Encyclopedia.ItemPools.POOL_CURSE,
			Encyclopedia.ItemPools.POOL_GREED_TREASURE,
			Encyclopedia.ItemPools.POOL_GREED_CURSE,
		},
		UnlockFunc = function(self)
			if functions.GetCompletion("Unbidden", "greed") < 1 then
			    self.Desc = "Defeat Ultra Greed as Unbidden"
			    return self
			end
		end,
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.RubberDuck,
		WikiDesc = Wiki.RubberDuck,
		Pools = {
			Encyclopedia.ItemPools.POOL_TREASURE,
			Encyclopedia.ItemPools.POOL_GOLDEN_CHEST,
			Encyclopedia.ItemPools.POOL_GREED_TREASURE,
		},
		UnlockFunc = function(self)
			if functions.GetCompletion("Unbidden", "bbaby") < 1 then
			    self.Desc = "Defeat ??? as Unbidden"
			    return self
			end
		end,
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.IvoryOil,
		WikiDesc = Wiki.IvoryOil,
		Pools = {
			Encyclopedia.ItemPools.POOL_ANGEL,
		},
		UnlockFunc = function(self)
			if functions.GetCompletion("Abihu", "beast") < 1 then
			    self.Desc = "Defeat The Beast as Abihu"
			    return self
			end
		end,
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.BlackKnight,
		WikiDesc = Wiki.BlackKnight,
		Pools = {
			Encyclopedia.ItemPools.POOL_DEVIL,
			Encyclopedia.ItemPools.POOL_GREED_DEVIL,
		},
		UnlockFunc = function(self)
			if functions.GetCompletion("Unbidden", "hush") < 1 then
			    self.Desc = "Defeat Hush as Unbidden"
			    return self
			end
		end,
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.WhiteKnight,
		WikiDesc = Wiki.WhiteKnight,
		Pools = {
			Encyclopedia.ItemPools.POOL_ANGEL,
			Encyclopedia.ItemPools.POOL_GREED_ANGEL,
		},
		UnlockFunc = function(self)
			if functions.GetCompletion("Unbidden", "hush") < 1 then
			    self.Desc = "Defeat Hush as Unbidden"
			    return self
			end
		end,
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.KeeperMirror,
		WikiDesc = Wiki.KeeperMirror,
		Pools = {
			Encyclopedia.ItemPools.POOL_SHOP,
			Encyclopedia.ItemPools.POOL_GREED_SHOP,
		},
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.RedBag,
		WikiDesc = Wiki.RedBag,
		Pools = {
			Encyclopedia.ItemPools.POOL_DEVIL,
			Encyclopedia.ItemPools.POOL_GREED_DEVIL,
			Encyclopedia.ItemPools.POOL_ULTRA_SECRET,
		},
		UnlockFunc = function(self)
			if functions.GetCompletion("UnbiddenB", "beast") < 1 then
			    self.Desc = "Defeat The Beast as Tainted Unbidden"
			    return self
			end
		end,
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.MeltedCandle,
		WikiDesc = Wiki.MeltedCandle,
		Pools = {
			Encyclopedia.ItemPools.POOL_TREASURE,
			Encyclopedia.ItemPools.POOL_GREED_TREASURE,
		},
		UnlockFunc = function(self)
			if functions.GetCompletion("Abihu", "mother") < 1 then
			    self.Desc = "Defeat Mother as Abihu"
			    return self
			end
		end,
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.MiniPony,
		WikiDesc = Wiki.MiniPony,
		Pools = {
			Encyclopedia.ItemPools.POOL_TREASURE,
		},
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.StrangeBox,
		WikiDesc = Wiki.StrangeBox,
		Pools = {
			Encyclopedia.ItemPools.POOL_SECRET,
			Encyclopedia.ItemPools.POOL_GREED_SECRET,
		},
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.RedButton,
		WikiDesc = Wiki.RedButton,
		Pools = {
			Encyclopedia.ItemPools.POOL_DEVIL,
			Encyclopedia.ItemPools.POOL_GREED_DEVIL,
			Encyclopedia.ItemPools.POOL_ULTRA_SECRET,
		},
		UnlockFunc = function(self)
			if functions.GetCompletion("Nadab", "rush") < 1 then
			    self.Desc = "Complete the Boss Rush as Nadab"
			    return self
			end
		end,
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.LostMirror,
		WikiDesc = Wiki.LostMirror,
		Pools = {
			Encyclopedia.ItemPools.POOL_ANGEL,
			Encyclopedia.ItemPools.POOL_SECRET,
		},
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.BleedingGrimoire,
		WikiDesc = Wiki.BleedingGrimoire,
		Pools = {
			Encyclopedia.ItemPools.POOL_DEVIL,
			Encyclopedia.ItemPools.POOL_LIBRARY,
			Encyclopedia.ItemPools.POOL_RED_CHEST,
			Encyclopedia.ItemPools.POOL_DEMON_BEGGAR,
			Encyclopedia.ItemPools.POOL_CURSE,
			Encyclopedia.ItemPools.POOL_GREED_CURSE,
			Encyclopedia.ItemPools.POOL_GREED_DEVIL,
		},
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.BlackBook,
		WikiDesc = Wiki.BlackBook,
		Pools = {
			Encyclopedia.ItemPools.POOL_DEVIL,
			Encyclopedia.ItemPools.POOL_LIBRARY,
			Encyclopedia.ItemPools.POOL_GREED_DEVIL,
		},
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.RubikDice,
		WikiDesc = Wiki.RubikDice,
		Pools = {
			Encyclopedia.ItemPools.POOL_TREASURE,
			Encyclopedia.ItemPools.POOL_GREED_TREASURE,
		},
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.RubikDiceScrambled0,
		WikiDesc = Wiki.RubikDice,
		Pools = {
			Encyclopedia.ItemPools.POOL_TREASURE,
			Encyclopedia.ItemPools.POOL_GREED_TREASURE,
		},
		Hide = true,
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.RubikDiceScrambled1,
		WikiDesc = Wiki.RubikDice,
		Pools = {
			Encyclopedia.ItemPools.POOL_TREASURE,
			Encyclopedia.ItemPools.POOL_GREED_TREASURE,
		},
		Hide = true,
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.RubikDiceScrambled2,
		WikiDesc = Wiki.RubikDice,
		Pools = {
			Encyclopedia.ItemPools.POOL_TREASURE,
			Encyclopedia.ItemPools.POOL_GREED_TREASURE,
		},
		Hide = true,
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.RubikDiceScrambled3,
		WikiDesc = Wiki.RubikDice,
		Pools = {
			Encyclopedia.ItemPools.POOL_TREASURE,
			Encyclopedia.ItemPools.POOL_GREED_TREASURE,
		},
		Hide = true,
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.RubikDiceScrambled4,
		WikiDesc = Wiki.RubikDice,
		Pools = {
			Encyclopedia.ItemPools.POOL_TREASURE,
			Encyclopedia.ItemPools.POOL_GREED_TREASURE,
		},
		Hide = true,
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.RubikDiceScrambled5,
		WikiDesc = Wiki.RubikDice,
		Pools = {
			Encyclopedia.ItemPools.POOL_TREASURE,
			Encyclopedia.ItemPools.POOL_GREED_TREASURE,
		},
		Hide = true,
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.VHSCassette,
		WikiDesc = Wiki.VHSCassette,
		Pools = {
			Encyclopedia.ItemPools.POOL_SHOP,
		},
		UnlockFunc = function(self)
			if functions.GetCompletion("Unbidden", "lamb") < 1 then
			    self.Desc = "Defeat The Lamb as Unbidden"
			    return self
			end
		end,
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.Lililith,
		WikiDesc = Wiki.Lililith,
		Pools = {
			Encyclopedia.ItemPools.POOL_DEVIL,
			Encyclopedia.ItemPools.POOL_GREED_DEVIL,
			Encyclopedia.ItemPools.POOL_ULTRA_SECRET,
			Encyclopedia.ItemPools.POOL_BABY_SHOP,
		},
		UnlockFunc = function(self)
			if functions.GetCompletion("Unbidden", "greed") < 2 then
			    self.Desc = "Defeat Ultra Greedier as Unbidden"
			    return self
			end
		end,
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.CompoBombs,
		WikiDesc = Wiki.CompoBombs,
		Pools = {
			Encyclopedia.ItemPools.POOL_TREASURE,
			Encyclopedia.ItemPools.POOL_GREED_TREASURE,
			Encyclopedia.ItemPools.POOL_ULTRA_SECRET,
			Encyclopedia.ItemPools.POOL_BOMB_BUM,
		},
		UnlockFunc = function(self)
			if functions.GetCompletion("Nadab", "beast") < 1 then
			    self.Desc = "Defeat The Beast as Nadab"
			    return self
			end
		end,
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.GravityBombs,
		WikiDesc = Wiki.GravityBombs,
		Pools = {
			Encyclopedia.ItemPools.POOL_TREASURE,
			Encyclopedia.ItemPools.POOL_GREED_TREASURE,
			Encyclopedia.ItemPools.POOL_BOMB_BUM,
		},
		UnlockFunc = function(self)
			if functions.GetCompletion("Nadab", "satan") < 1 then
			    self.Desc = "Defeat Satan as Nadab"
			    return self
			end
		end,
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.AbihuFam,
		WikiDesc = Wiki.AbihuFam,
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.NadabBody,
		WikiDesc = Wiki.NadabBody,
		Pools = {
			Encyclopedia.ItemPools.POOL_TREASURE,
		},
		UnlockFunc = function(self)
			if functions.GetCompletion("Abihu", "deli") < 1 then
			    self.Desc = "Defeat Delirium as Abihu"
			    return self
			end
		end,
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.Limb,
		WikiDesc = Wiki.Limb,
		Pools = {
			Encyclopedia.ItemPools.POOL_ANGEL,
			Encyclopedia.ItemPools.POOL_SECRET,
			Encyclopedia.ItemPools.POOL_GREED_ANGEL,
			Encyclopedia.ItemPools.POOL_GREED_SECRET,
		},
		UnlockFunc = function(self)
			if functions.GetCompletion("Unbidden", "beast") < 1 then
			    self.Desc = "Defeat The Beast as Unbidden"
			    return self
			end
		end,
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.LongElk,
		WikiDesc = Wiki.LongElk,
		Pools = {
			Encyclopedia.ItemPools.POOL_CURSE,
			Encyclopedia.ItemPools.POOL_GREED_CURSE,
		},
		UnlockFunc = function(self)
			if functions.GetCompletion("Unbidden", "satan") < 1 then
			    self.Desc = "Defeat Satan as Unbidden"
			    return self
			end
		end,
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.FrostyBombs,
		WikiDesc = Wiki.FrostyBombs,
		Pools = {
			Encyclopedia.ItemPools.POOL_TREASURE,
			Encyclopedia.ItemPools.POOL_GREED_TREASURE,
			Encyclopedia.ItemPools.POOL_BOMB_BUM,
		},
		UnlockFunc = function(self)
			if functions.GetCompletion("Nadab", "lamb") < 1 then
			    self.Desc = "Defeat The Lamb as Nadab"
			    return self
			end
		end,
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.VoidKarma,
		WikiDesc = Wiki.VoidKarma,
		Pools = {
			Encyclopedia.ItemPools.POOL_SECRET,
			Encyclopedia.ItemPools.POOL_GREED_SECRET,
		},
		UnlockFunc = function(self)
			if functions.GetCompletion("Unbidden", "isaac") < 1 then
			    self.Desc = "Defeat Isaac as Unbidden"
			    return self
			end
		end,
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.CharonObol,
		WikiDesc = Wiki.CharonObol,
		Pools = {
			Encyclopedia.ItemPools.POOL_SHOP,
			Encyclopedia.ItemPools.POOL_DEVIL,
			Encyclopedia.ItemPools.POOL_CURSE,
			Encyclopedia.ItemPools.POOL_GREED_SHOP,
			Encyclopedia.ItemPools.POOL_GREED_DEVIL,
			Encyclopedia.ItemPools.POOL_GREED_CURSE,
		},
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.Viridian,
		WikiDesc = Wiki.Viridian,
		Pools = {
			Encyclopedia.ItemPools.POOL_TREASURE,
		},
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.BookMemory,
		WikiDesc = Wiki.BookMemory,
		Pools = {
			Encyclopedia.ItemPools.POOL_LIBRARY,
		},
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.MongoCells,
		WikiDesc = Wiki.MongoCells,
		Pools = {
			Encyclopedia.ItemPools.POOL_TREASURE,
			Encyclopedia.ItemPools.POOL_GOLDEN_CHEST,
			Encyclopedia.ItemPools.POOL_GREED_SHOP,
		},
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.CosmicJam,
		WikiDesc = Wiki.CosmicJam,
		Pools = {
			Encyclopedia.ItemPools.POOL_TREASURE,
			Encyclopedia.ItemPools.POOL_GREED_SHOP,
		},
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.DMS,
		WikiDesc = Wiki.DMS,
		Pools = {
			Encyclopedia.ItemPools.POOL_DEVIL,
			Encyclopedia.ItemPools.POOL_RED_CHEST,
			Encyclopedia.ItemPools.POOL_GREED_DEVIL,
		},
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.MewGen,
		WikiDesc = Wiki.MewGen,
		Pools = {
			Encyclopedia.ItemPools.POOL_ANGEL,
			Encyclopedia.ItemPools.POOL_GREED_ANGEL,
		},
		UnlockFunc = function(self)
			if functions.GetCompletion("Challenges", "magician") < 1 then
			    self.Desc = "Complete Curse of The Magician (challenge)."
			    return self
			end
		end,
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.ElderSign,
		WikiDesc = Wiki.ElderSign,
		Pools = {
			Encyclopedia.ItemPools.POOL_SECRET,
			Encyclopedia.ItemPools.POOL_GREED_SECRET,
		},
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.Eclipse,
		WikiDesc = Wiki.Eclipse,
		Pools = {
			Encyclopedia.ItemPools.POOL_SECRET,
			Encyclopedia.ItemPools.POOL_GREED_SECRET,
			Encyclopedia.ItemPools.POOL_DEVIL,
			Encyclopedia.ItemPools.POOL_GREED_DEVIL,
		},
		UnlockFunc = function(self)
			if functions.GetCompletion("UnbiddenB", "deli") < 1 then
			    self.Desc = "Defeat Delirium as Tainted Unbidden"
			    return self
			end
		end,
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.Threshold,
		WikiDesc = Wiki.Threshold,
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.WitchPot,
		WikiDesc = Wiki.WitchPot,
		Pools = {
			Encyclopedia.ItemPools.POOL_SHOP,
			Encyclopedia.ItemPools.POOL_GREED_SHOP,
		},
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.PandoraJar,
		WikiDesc = Wiki.PandoraJar,
		Pools = {
			Encyclopedia.ItemPools.POOL_ANGEL,
			Encyclopedia.ItemPools.POOL_GREED_ANGEL,
		},
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.DiceBombs,
		WikiDesc = Wiki.DiceBombs,
		Pools = {
			Encyclopedia.ItemPools.POOL_TREASURE,
			Encyclopedia.ItemPools.POOL_GREED_TREASURE,
			Encyclopedia.ItemPools.POOL_ULTRA_SECRET,
			Encyclopedia.ItemPools.POOL_BOMB_BUM,
		},
		UnlockFunc = function(self)
			if functions.GetCompletion("Nadab", "isaac") < 1 then
			    self.Desc = "Defeat Isaac as Nadab"
			    return self
			end
		end,
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.BatteryBombs,
		WikiDesc = Wiki.BatteryBombs,
		Pools = {
			Encyclopedia.ItemPools.POOL_SHOP,
			Encyclopedia.ItemPools.POOL_GREED_SHOP,
			Encyclopedia.ItemPools.POOL_BATTERY_BUM,
			Encyclopedia.ItemPools.POOL_BOMB_BUM,
		},
		UnlockFunc = function(self)
			if functions.GetCompletion("Nadab", "greed") < 2 then
			    self.Desc = "Defeat Ultra Greedier as Nadab"
			    return self
			end
		end,
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.Pyrophilia,
		WikiDesc = Wiki.Pyrophilia,
		Pools = {
			Encyclopedia.ItemPools.POOL_TREASURE,
			Encyclopedia.ItemPools.POOL_BOMB_BUM,
		},
		UnlockFunc = function(self)
			if functions.GetCompletion("Nadab", "greed") < 1 then
			    self.Desc = "Defeat Ultra Greed as Nadab"
			    return self
			end
		end,
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.SpikedCollar,
		WikiDesc = Wiki.SpikedCollar,
		Pools = {
			Encyclopedia.ItemPools.POOL_CURSE,
			Encyclopedia.ItemPools.POOL_RED_CHEST,
			Encyclopedia.ItemPools.POOL_GREED_CURSE,
		},
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.AgonyBox,
		WikiDesc = Wiki.AgonyBox,
		Pools = {
			Encyclopedia.ItemPools.POOL_CURSE,
			Encyclopedia.ItemPools.POOL_GREED_CURSE,
		},
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.Potato,
		WikiDesc = Wiki.Potato,
		Pools = {
			Encyclopedia.ItemPools.POOL_SHOP,
			Encyclopedia.ItemPools.POOL_GREED_SHOP,
		},
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.SecretLoveLetter,
		WikiDesc = Wiki.SecretLoveLetter,
		Pools = {
			Encyclopedia.ItemPools.POOL_SECRET,
			Encyclopedia.ItemPools.POOL_GREED_SECRET,
			Encyclopedia.ItemPools.POOL_ULTRA_SECRET,
		},
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.SurrogateConception,
		WikiDesc = Wiki.SurrogateConception,
		Pools = {
			Encyclopedia.ItemPools.POOL_SECRET,
			Encyclopedia.ItemPools.POOL_GREED_SECRET,
		},
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.HeartTransplant,
		WikiDesc = Wiki.HeartTransplant,
		Pools = {
			Encyclopedia.ItemPools.POOL_TREASURE,
			Encyclopedia.ItemPools.POOL_GREED_TREASURE,
			Encyclopedia.ItemPools.POOL_ULTRA_SECRET,
		},
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.MirrorBombs,
		WikiDesc = Wiki.MirrorBombs,
		Pools = {
			Encyclopedia.ItemPools.POOL_TREASURE,
			Encyclopedia.ItemPools.POOL_GREED_TREASURE,
			Encyclopedia.ItemPools.POOL_BOMB_BUM
		},
		UnlockFunc = function(self)
			if functions.GetCompletion("Nadab", "deli") < 1 then
			    self.Desc = "Defeat Delirium as Nadab"
			    return self
			end
		end,
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.DeadBombs,
		WikiDesc = Wiki.DeadBombs,
		Pools = {
			Encyclopedia.ItemPools.POOL_SECRET,
			Encyclopedia.ItemPools.POOL_GREED_SECRET,
			Encyclopedia.ItemPools.POOL_BOMB_BUM
		},
		UnlockFunc = function(self)
			if functions.GetCompletion("Nadab", "bbaby") < 1 then
			    self.Desc = "Defeat ??? as Nadab"
			    return self
			end
		end,
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.NadabBrain,
		WikiDesc = Wiki.NadabBrain,
		Pools = {
			Encyclopedia.ItemPools.POOL_TREASURE,
			Encyclopedia.ItemPools.POOL_GOLDEN_CHEST,
			Encyclopedia.ItemPools.POOL_GREED_TREASURE,
			Encyclopedia.ItemPools.POOL_BABY_SHOP
		},
		UnlockFunc = function(self)
			if functions.GetCompletion("Abihu", "deli") < 1 then
			    self.Desc = "Defeat Delirium as Abihu"
			    return self
			end
		end,
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.GardenTrowel,
		WikiDesc = Wiki.GardenTrowel,
		Pools = {
			Encyclopedia.ItemPools.POOL_TREASURE,
			Encyclopedia.ItemPools.POOL_SHOP,
			Encyclopedia.ItemPools.POOL_GREED_TREASURE,
		},
	})
	
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.TetrisDice_full,
		WikiDesc = Wiki.TetrisDice,
		Pools = {
			Encyclopedia.ItemPools.POOL_TREASURE,
			Encyclopedia.ItemPools.POOL_GREED_TREASURE,
		},
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.TetrisDice1,
		WikiDesc = Wiki.TetrisDice,
		Pools = {
			Encyclopedia.ItemPools.POOL_TREASURE,
			Encyclopedia.ItemPools.POOL_GREED_SHOP,
		},
		Hide = true,
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.TetrisDice2,
		WikiDesc = Wiki.TetrisDice,
		Pools = {
			Encyclopedia.ItemPools.POOL_TREASURE,
			Encyclopedia.ItemPools.POOL_GREED_SHOP,
		},
		Hide = true,
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.TetrisDice3,
		WikiDesc = Wiki.TetrisDice,
		Pools = {
			Encyclopedia.ItemPools.POOL_TREASURE,
			Encyclopedia.ItemPools.POOL_GREED_SHOP,
		},
		Hide = true,
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.TetrisDice4,
		WikiDesc = Wiki.TetrisDice,
		Pools = {
			Encyclopedia.ItemPools.POOL_TREASURE,
			Encyclopedia.ItemPools.POOL_GREED_SHOP,
		},
		Hide = true,
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.TetrisDice5,
		WikiDesc = Wiki.TetrisDice,
		Pools = {
			Encyclopedia.ItemPools.POOL_TREASURE,
			Encyclopedia.ItemPools.POOL_GREED_SHOP,
		},
		Hide = true,
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.TetrisDice6,
		WikiDesc = Wiki.TetrisDice,
		Pools = {
			Encyclopedia.ItemPools.POOL_TREASURE,
			Encyclopedia.ItemPools.POOL_GREED_SHOP,
		},
		Hide = true,
	})
	
	Encyclopedia.AddTrinket({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Trinkets.WitchPaper,
		WikiDesc = Wiki.WitchPaper,
		UnlockFunc = function(self)
			if functions.GetCompletion("UnbiddenB", "isaac") < 1 and functions.GetCompletion("UnbiddenB", "bbaby") < 1 and functions.GetCompletion("UnbiddenB", "satan") < 1 and functions.GetCompletion("UnbiddenB", "lamb") < 1 then
			    self.Desc = "Defeat Isaac, ???, Satan, and The Lamb as Tainted Unbidden"
			    return self
			end
		end,
	})
	Encyclopedia.AddTrinket({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Trinkets.TornSpades,
		WikiDesc = Wiki.TornSpades,
	})
	Encyclopedia.AddTrinket({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Trinkets.RedScissors,
		WikiDesc = Wiki.RedScissors,
		UnlockFunc = function(self)
			if functions.GetCompletion("Abihu", "isaac") < 1 and functions.GetCompletion("Abihu", "bbaby") < 1 and functions.GetCompletion("Abihu", "satan") < 1 and functions.GetCompletion("Abihu", "lamb") < 1 then
			    self.Desc = "Defeat Isaac, ???, Satan, and The Lamb as Abihu"
			    return self
			end
		end,
	})
	Encyclopedia.AddTrinket({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Trinkets.Duotine,
		WikiDesc = Wiki.Duotine,
		UnlockFunc = function(self)
			if functions.GetCompletion("UnbiddenB", "mega") < 1 then
			    self.Desc = "Defeat Mega Satan as Tainted Unbidden"
			    return self
			end
		end,
	})
	Encyclopedia.AddTrinket({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Trinkets.LostFlower,
		WikiDesc = Wiki.LostFlower,
	})
	Encyclopedia.AddTrinket({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Trinkets.TeaBag,
		WikiDesc = Wiki.TeaBag,
	})
	Encyclopedia.AddTrinket({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Trinkets.MilkTeeth,
		WikiDesc = Wiki.MilkTeeth,
	})
	Encyclopedia.AddTrinket({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Trinkets.BobTongue,
		WikiDesc = Wiki.BobTongue,
		UnlockFunc = function(self)
			if functions.GetCompletion("Nadab", "mother") < 1 then
			    self.Desc = "Defeat Mother as Nadab"
			    return self
			end
		end,
	})
	Encyclopedia.AddTrinket({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Trinkets.BinderClip,
		WikiDesc = Wiki.BinderClip,
	})
	Encyclopedia.AddTrinket({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Trinkets.MemoryFragment,
		WikiDesc = Wiki.MemoryFragment,
	})
	Encyclopedia.AddTrinket({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Trinkets.AbyssCart,
		WikiDesc = Wiki.AbyssCart,
	})
	Encyclopedia.AddTrinket({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Trinkets.RubikCubelet,
		WikiDesc = Wiki.RubikCubelet,
	})
	Encyclopedia.AddTrinket({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Trinkets.TeaFungus,
		WikiDesc = Wiki.TeaFungus,
	})
	Encyclopedia.AddTrinket({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Trinkets.DeadEgg,
		WikiDesc = Wiki.DeadEgg,
	})
	Encyclopedia.AddTrinket({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Trinkets.Penance,
		WikiDesc = Wiki.Penance,
	})
	Encyclopedia.AddTrinket({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Trinkets.Pompom,
		WikiDesc = Wiki.Pompom,
	})
	Encyclopedia.AddTrinket({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Trinkets.XmasLetter,
		WikiDesc = Wiki.XmasLetter,
	})
	Encyclopedia.AddTrinket({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Trinkets.BlackPepper,
		WikiDesc = Wiki.BlackPepper,
	})
	Encyclopedia.AddTrinket({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Trinkets.Cybercutlet,
		WikiDesc = Wiki.Cybercutlet,
		UnlockFunc = function(self)
			if functions.GetCompletion("Challenges", "potato") < 1 then
			    self.Desc = "Complete When life gives you Potatoes! (challenge)."
			    return self
			end
		end,
	})
	Encyclopedia.AddTrinket({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Trinkets.GildedFork,
		WikiDesc = Wiki.GildedFork,
		UnlockFunc = function(self)
			if functions.GetCompletion("Challenges", "beatmaker") < 1 then
			    self.Desc = "Complete Beatmaker (challenge)."
			    return self
			end
		end,
	})
	Encyclopedia.AddTrinket({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Trinkets.GoldenEgg,
		WikiDesc = Wiki.GoldenEgg,
		UnlockFunc = function(self)
			if functions.GetCompletion("Challenges", "mongofamily") < 1 then
			    self.Desc = "Complete Mongo Family (challenge)."
			    return self
			end
		end,
	})
	Encyclopedia.AddTrinket({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Trinkets.BrokenJawbone,
		WikiDesc = Wiki.BrokenJawbone,
	})
	Encyclopedia.AddTrinket({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Trinkets.WarHand,
		WikiDesc = Wiki.WarHand,
	})
	
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.OblivionCard,
		WikiDesc = Wiki.OblivionCard,
		UnlockFunc = function(self)
			if functions.GetCompletion("UnbiddenB", "greed") < 2 then
			    self.Desc = "Defeat Ultra Greedier as Tainted Unbidden"
			    return self
			end
		end,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.BattlefieldCard,
		WikiDesc = Wiki.BattlefieldCard,
		UnlockFunc = function(self)
			if functions.GetCompletion("UnbiddenB", "greed")  < 2 then
			    self.Desc = "Defeat Ultra Greedier as Tainted Unbidden"
			    return self
			end
		end,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.TreasuryCard,
		WikiDesc = Wiki.TreasuryCard,
		UnlockFunc = function(self)
			if functions.GetCompletion("UnbiddenB", "greed")  < 2 then
			    self.Desc = "Defeat Ultra Greedier as Tainted Unbidden"
			    return self
			end
		end,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.BookeryCard,
		WikiDesc = Wiki.BookeryCard,
		UnlockFunc = function(self)
			if functions.GetCompletion("UnbiddenB", "greed")  < 2 then
			    self.Desc = "Defeat Ultra Greedier as Tainted Unbidden"
			    return self
			end
		end,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.BloodGroveCard,
		WikiDesc = Wiki.BloodGroveCard,
		UnlockFunc = function(self)
			if functions.GetCompletion("UnbiddenB", "greed")  < 2 then
			    self.Desc = "Defeat Ultra Greedier as Tainted Unbidden"
			    return self
			end
		end,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.StormTempleCard,
		WikiDesc = Wiki.StormTempleCard,
		UnlockFunc = function(self)
			if functions.GetCompletion("UnbiddenB", "greed")  < 2 then
			    self.Desc = "Defeat Ultra Greedier as Tainted Unbidden"
			    return self
			end
		end,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.ArsenalCard,
		WikiDesc = Wiki.ArsenalCard,
		UnlockFunc = function(self)
			if functions.GetCompletion("UnbiddenB", "greed")  < 2 then
			    self.Desc = "Defeat Ultra Greedier as Tainted Unbidden"
			    return self
			end
		end,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.OutpostCard,
		WikiDesc = Wiki.OutpostCard,
		UnlockFunc = function(self)
			if functions.GetCompletion("UnbiddenB", "greed")  < 2 then
			    self.Desc = "Defeat Ultra Greedier as Tainted Unbidden"
			    return self
			end
		end,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.CryptCard,
		WikiDesc = Wiki.CryptCard,
		UnlockFunc = function(self)
			if functions.GetCompletion("UnbiddenB", "greed")  < 2 then
			    self.Desc = "Defeat Ultra Greedier as Tainted Unbidden"
			    return self
			end
		end,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.MazeMemoryCard,
		WikiDesc = Wiki.MazeMemoryCard,
		UnlockFunc = function(self)
			if functions.GetCompletion("UnbiddenB", "greed")  < 2 then
			    self.Desc = "Defeat Ultra Greedier as Tainted Unbidden"
			    return self
			end
		end,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.ZeroMilestoneCard,
		WikiDesc = Wiki.ZeroMilestoneCard,
		UnlockFunc = function(self)
			if functions.GetCompletion("UnbiddenB", "greed")  < 2 then
			    self.Desc = "Defeat Ultra Greedier as Tainted Unbidden"
			    return self
			end
		end,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.Apocalypse,
		WikiDesc = Wiki.Apocalypse,
		UnlockFunc = function(self)
			if functions.GetCompletion("Unbidden", "rush")  < 1 then
			    self.Desc = "Complete the Boss Rush as Unbidden"
			    return self
			end
		end,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.BannedCard,
		WikiDesc = Wiki.BannedCard,
	})
	Encyclopedia.AddSpecial({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.KingChess,
		WikiDesc = Wiki.KingChess,
		UnlockFunc = function(self)
			if functions.GetCompletion("Nadab", "hush") < 1 then
			    self.Desc = "Defeat Hush as Nadab"
			    return self
			end
		end,
	})
	Encyclopedia.AddSpecial({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.KingChessW,
		WikiDesc = Wiki.KingChessW,
		UnlockFunc = function(self)
			if functions.GetCompletion("Nadab", "hush") < 1 then
			    self.Desc = "Defeat Hush as Nadab"
			    return self
			end
		end,
	})
	Encyclopedia.AddRune({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.GhostGem,
		WikiDesc = Wiki.GhostGem,
	})
	Encyclopedia.AddRune({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.Trapezohedron,
		WikiDesc = Wiki.Trapezohedron,
		UnlockFunc = function(self)
			if functions.GetCompletion("UnbiddenB", "mother") < 1 then
			    self.Desc = "Defeat Mother as Tainted Unbidden"
			    return self
			end
		end,
	})
	Encyclopedia.AddSoul({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.SoulUnbidden,
		WikiDesc = Wiki.SoulUnbidden,
		UnlockFunc = function(self)
			if functions.GetCompletion("UnbiddenB", "hush") < 1 and functions.GetCompletion("UnbiddenB", "rush") < 1 then
			    self.Desc = "Defeat Hush and Boss Rush as Tainted Unbidden"
			    return self
			end
		end,
	})
	Encyclopedia.AddSoul({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.SoulNadabAbihu,
		WikiDesc = Wiki.SoulNadabAbihu,
		UnlockFunc = function(self)
			if functions.GetCompletion("Abihu", "hush") < 1 and functions.GetCompletion("Abihu", "rush") < 1 then
			    self.Desc = "Defeat Hush and Boss Rush as Abihu"
			    return self
			end
		end,
	})
	Encyclopedia.AddSpecial({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.Domino34,
		WikiDesc = Wiki.Domino34,
		UnlockFunc = function(self)
			if functions.GetCompletion("Nadab", "mega") < 1 then
			    self.Desc = "Defeat Mega Satan as Nadab"
			    return self
			end
		end,
	})
	Encyclopedia.AddSpecial({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.Domino25,
		WikiDesc = Wiki.Domino25,
		UnlockFunc = function(self)
			if functions.GetCompletion("Nadab", "mega") < 1 then
			    self.Desc = "Defeat Mega Satan as Nadab"
			    return self
			end
		end,
	})
	Encyclopedia.AddSpecial({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.Domino16,
		WikiDesc = Wiki.Domino16,
		UnlockFunc = function(self)
			if functions.GetCompletion("Nadab", "mega") < 1 then
			    self.Desc = "Defeat Mega Satan as Nadab"
			    return self
			end
		end,
	})
	Encyclopedia.AddSpecial({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.Domino00,
		WikiDesc = Wiki.Domino00,
		UnlockFunc = function(self)
			if functions.GetCompletion("Nadab", "mega") < 1 then
			    self.Desc = "Defeat Mega Satan as Nadab"
			    return self
			end
		end,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.AscenderBane,
		WikiDesc = Wiki.AscenderBane,
		UnlockFunc = function(self)
			if functions.GetCompletion("Abihu", "greed") < 2 then
			    self.Desc = "Defeat Ultra Greedier as Abihu"
			    return self
			end
		end,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.Decay,
		WikiDesc = Wiki.Decay,
		UnlockFunc = function(self)
			if functions.GetCompletion("Abihu", "greed") < 2 then
			    self.Desc = "Defeat Ultra Greedier as Abihu"
			    return self
			end
		end,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.MultiCast,
		WikiDesc = Wiki.MultiCast,
		UnlockFunc = function(self)
			if functions.GetCompletion("Abihu", "greed") < 2 then
			    self.Desc = "Defeat Ultra Greedier as Abihu"
			    return self
			end
		end,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.Wish,
		WikiDesc = Wiki.Wish,
		UnlockFunc = function(self)
			if functions.GetCompletion("Abihu", "greed") < 2 then
			    self.Desc = "Defeat Ultra Greedier as Abihu"
			    return self
			end
		end,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.Offering,
		WikiDesc = Wiki.Offering,
		UnlockFunc = function(self)
			if functions.GetCompletion("Abihu", "greed") < 2 then
			    self.Desc = "Defeat Ultra Greedier as Abihu"
			    return self
			end
		end,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.InfiniteBlades,
		WikiDesc = Wiki.InfiniteBlades,
		UnlockFunc = function(self)
			if functions.GetCompletion("Abihu", "greed") < 2 then
			    self.Desc = "Defeat Ultra Greedier as Abihu"
			    return self
			end
		end,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.Transmutation,
		WikiDesc = Wiki.Transmutation,
		UnlockFunc = function(self)
			if functions.GetCompletion("Abihu", "greed") < 2 then
			    self.Desc = "Defeat Ultra Greedier as Abihu"
			    return self
			end
		end,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.RitualDagger,
		WikiDesc = Wiki.RitualDagger,
		UnlockFunc = function(self)
			if functions.GetCompletion("Abihu", "greed") < 2 then
			    self.Desc = "Defeat Ultra Greedier as Abihu"
			    return self
			end
		end,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.Fusion,
		WikiDesc = Wiki.Fusion,
		UnlockFunc = function(self)
			if functions.GetCompletion("Abihu", "greed") < 2 then
			    self.Desc = "Defeat Ultra Greedier as Abihu"
			    return self
			end
		end,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.DeuxEx,
		WikiDesc = Wiki.DeuxEx,
		UnlockFunc = function(self)
			if functions.GetCompletion("Abihu", "greed") < 2 then
			    self.Desc = "Defeat Ultra Greedier as Abihu"
			    return self
			end
		end,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.Adrenaline,
		WikiDesc = Wiki.Adrenaline,
		UnlockFunc = function(self)
			if functions.GetCompletion("Abihu", "greed") < 2 then
			    self.Desc = "Defeat Ultra Greedier as Abihu"
			    return self
			end
		end,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.Corruption,
		WikiDesc = Wiki.Corruption,
		UnlockFunc = function(self)
			if functions.GetCompletion("Abihu", "greed") < 2 then
			    self.Desc = "Defeat Ultra Greedier as Abihu"
			    return self
			end
		end,
	})
	Encyclopedia.AddSpecial({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.RedPill,
		WikiDesc = Wiki.RedPill,
		UnlockFunc = function(self)
			if functions.GetCompletion("UnbiddenB", "mega") < 1 then
			    self.Desc = "Defeat Mega Satan as Tainted Unbidden"
			    return self
			end
		end,
	})
	--[[
	Encyclopedia.AddSpecial({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.RedPillHorse,
		WikiDesc = Wiki.RedPillHorse,
		Hide = true,
		UnlockFunc = function(self)
			if functions.GetCompletion("UnbiddenB", "mega") < 1 then
			    self.Desc = "Defeat Mega Satan as Tainted Unbidden"
			    return self
			end
		end,
	})
	--]]
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.KittenBomb,
		WikiDesc = Wiki.KittenBomb,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.KittenBomb2,
		WikiDesc = Wiki.KittenBomb2,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.KittenDefuse,
		WikiDesc = Wiki.KittenDefuse,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.KittenDefuse2,
		WikiDesc = Wiki.KittenDefuse2,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.KittenFuture,
		WikiDesc = Wiki.KittenFuture,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.KittenFuture2,
		WikiDesc = Wiki.KittenFuture2,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.KittenNope,
		WikiDesc = Wiki.KittenNope,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.KittenNope2,
		WikiDesc = Wiki.KittenNope2,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.KittenSkip,
		WikiDesc = Wiki.KittenSkip,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.KittenSkip2,
		WikiDesc = Wiki.KittenSkip2,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.KittenFavor,
		WikiDesc = Wiki.KittenFavor,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.KittenFavor2,
		WikiDesc = Wiki.KittenFavor2,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.KittenShuffle,
		WikiDesc = Wiki.KittenShuffle,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.KittenShuffle2,
		WikiDesc = Wiki.KittenShuffle2,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.KittenAttack,
		WikiDesc = Wiki.KittenAttack,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.KittenAttack2,
		WikiDesc = Wiki.KittenAttack2,
	})
	Encyclopedia.AddDelirious({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.DeliObjectCell,
		WikiDesc = Wiki.DeliObjectCell,
		UnlockFunc = function(self)
			if functions.GetCompletion("Challenges", "lobotomy") < 1 then
			    self.Desc = "Complete Lobotomy (challenge)."
			    return self
			end
		end,
	})
	Encyclopedia.AddDelirious({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.DeliObjectBomb,
		WikiDesc = Wiki.DeliObjectBomb,
		UnlockFunc = function(self)
			if functions.GetCompletion("Challenges", "lobotomy") < 1 then
			    self.Desc = "Complete Lobotomy (challenge)."
			    return self
			end
		end,
	})
	Encyclopedia.AddDelirious({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.DeliObjectKey,
		WikiDesc = Wiki.DeliObjectKey,
		UnlockFunc = function(self)
			if functions.GetCompletion("Challenges", "lobotomy") < 1 then
			    self.Desc = "Complete Lobotomy (challenge)."
			    return self
			end
		end,
	})
	Encyclopedia.AddDelirious({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.DeliObjectCard,
		WikiDesc = Wiki.DeliObjectCard,
		UnlockFunc = function(self)
			if functions.GetCompletion("Challenges", "lobotomy") < 1 then
			    self.Desc = "Complete Lobotomy (challenge)."
			    return self
			end
		end,
	})
	Encyclopedia.AddDelirious({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.DeliObjectPill,
		WikiDesc = Wiki.DeliObjectPill,
		UnlockFunc = function(self)
			if functions.GetCompletion("Challenges", "lobotomy") < 1 then
			    self.Desc = "Complete Lobotomy (challenge)."
			    return self
			end
		end,
	})
	Encyclopedia.AddDelirious({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.DeliObjectRune,
		WikiDesc = Wiki.DeliObjectRune,
		UnlockFunc = function(self)
			if functions.GetCompletion("Challenges", "lobotomy") < 1 then
			    self.Desc = "Complete Lobotomy (challenge)."
			    return self
			end
		end,
	})
	Encyclopedia.AddDelirious({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.DeliObjectHeart,
		WikiDesc = Wiki.DeliObjectHeart,
		UnlockFunc = function(self)
			if functions.GetCompletion("Challenges", "lobotomy") < 1 then
			    self.Desc = "Complete Lobotomy (challenge)."
			    return self
			end
		end,
	})
	Encyclopedia.AddDelirious({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.DeliObjectCoin,
		WikiDesc = Wiki.DeliObjectCoin,
		UnlockFunc = function(self)
			if functions.GetCompletion("Challenges", "lobotomy") < 1 then
			    self.Desc = "Complete Lobotomy (challenge)."
			    return self
			end
		end,
	})
	Encyclopedia.AddDelirious({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.DeliObjectBattery,
		WikiDesc = Wiki.DeliObjectBattery,
		UnlockFunc = function(self)
			if functions.GetCompletion("Challenges", "lobotomy") < 1 then
			    self.Desc = "Complete Lobotomy (challenge)."
			    return self
			end
		end,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.CemeteryCard,
		WikiDesc = Wiki.CemeteryCard,
		UnlockFunc = function(self)
			if functions.GetCompletion("UnbiddenB", "greed") < 2 then
			    self.Desc = "Defeat Ultra Greedier as Tainted Unbidden"
			    return self
			end
		end,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.VillageCard,
		WikiDesc = Wiki.VillageCard,
		UnlockFunc = function(self)
			if functions.GetCompletion("UnbiddenB", "greed") < 2 then
			    self.Desc = "Defeat Ultra Greedier as Tainted Unbidden"
			    return self
			end
		end,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.GroveCard,
		WikiDesc = Wiki.GroveCard,
		UnlockFunc = function(self)
			if functions.GetCompletion("UnbiddenB", "greed") < 2 then
			    self.Desc = "Defeat Ultra Greedier as Tainted Unbidden"
			    return self
			end
		end,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.WheatFieldsCard,
		WikiDesc = Wiki.WheatFieldsCard,
		UnlockFunc = function(self)
			if functions.GetCompletion("UnbiddenB", "greed") < 2 then
			    self.Desc = "Defeat Ultra Greedier as Tainted Unbidden"
			    return self
			end
		end,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.RuinsCard,
		WikiDesc = Wiki.RuinsCard,
		UnlockFunc = function(self)
			if functions.GetCompletion("UnbiddenB", "greed") < 2 then
			    self.Desc = "Defeat Ultra Greedier as Tainted Unbidden"
			    return self
			end
		end,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.SwampCard,
		WikiDesc = Wiki.SwampCard,
		UnlockFunc = function(self)
			if functions.GetCompletion("UnbiddenB", "greed") < 2 then
			    self.Desc = "Defeat Ultra Greedier as Tainted Unbidden"
			    return self
			end
		end,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.SpiderCocoonCard,
		WikiDesc = Wiki.SpiderCocoonCard,
		UnlockFunc = function(self)
			if functions.GetCompletion("UnbiddenB", "greed") < 2 then
			    self.Desc = "Defeat Ultra Greedier as Tainted Unbidden"
			    return self
			end
		end,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.RoadLanternCard,
		WikiDesc = Wiki.RoadLanternCard,
		UnlockFunc = function(self)
			if functions.GetCompletion("UnbiddenB", "greed") < 2 then
			    self.Desc = "Defeat Ultra Greedier as Tainted Unbidden"
			    return self
			end
		end,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.VampireMansionCard,
		WikiDesc = Wiki.VampireMansionCard,
		UnlockFunc = function(self)
			if functions.GetCompletion("UnbiddenB", "greed") < 2 then
			    self.Desc = "Defeat Ultra Greedier as Tainted Unbidden"
			    return self
			end
		end,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.SmithForgeCard,
		WikiDesc = Wiki.SmithForgeCard,
		UnlockFunc = function(self)
			if functions.GetCompletion("UnbiddenB", "greed") < 2 then
			    self.Desc = "Defeat Ultra Greedier as Tainted Unbidden"
			    return self
			end
		end,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.ChronoCrystalsCard,
		WikiDesc = Wiki.ChronoCrystalsCard,
		UnlockFunc = function(self)
			if functions.GetCompletion("UnbiddenB", "greed") < 2 then
			    self.Desc = "Defeat Ultra Greedier as Tainted Unbidden"
			    return self
			end
		end,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.WitchHut,
		WikiDesc = Wiki.WitchHut,
		UnlockFunc = function(self)
			if functions.GetCompletion("UnbiddenB", "greed") < 2 then
			    self.Desc = "Defeat Ultra Greedier as Tainted Unbidden"
			    return self
			end
		end,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.BeaconCard,
		WikiDesc = Wiki.BeaconCard,
		UnlockFunc = function(self)
			if functions.GetCompletion("UnbiddenB", "greed") < 2 then
			    self.Desc = "Defeat Ultra Greedier as Tainted Unbidden"
			    return self
			end
		end,
	})
	Encyclopedia.AddCard({
		Class = "Eclipsed",
		ModName = "Eclipsed",
		ID = enums.Pickups.TemporalBeaconCard,
		WikiDesc = Wiki.TemporalBeaconCard,
		UnlockFunc = function(self)
			if functions.GetCompletion("UnbiddenB", "greed") < 2 then
			    self.Desc = "Defeat Ultra Greedier as Tainted Unbidden"
			    return self
			end
		end,
	})
		Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.HolyHealing,
		WikiDesc = Wiki.HolyHealing,
		Pools = {
			Encyclopedia.ItemPools.POOL_ANGEL,
			Encyclopedia.ItemPools.POOL_LIBRARY,
		},
	})	
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.AncientVolume,
		WikiDesc = Wiki.AncientVolume,
		Pools = {
			Encyclopedia.ItemPools.POOL_LIBRARY,
		},
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.CosmicEncyclopedia,
		WikiDesc = Wiki.CosmicEncyclopedia,
		Pools = {
			Encyclopedia.ItemPools.POOL_TREASURE,
			Encyclopedia.ItemPools.POOL_LIBRARY,
		},
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.RedBook,
		WikiDesc = Wiki.RedBook,
		Pools = {
			Encyclopedia.ItemPools.POOL_ANGEL,
			Encyclopedia.ItemPools.POOL_ULTRA_SECRET,
			Encyclopedia.ItemPools.POOL_LIBRARY,
		},
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.CodexAnimarum,
		WikiDesc = Wiki.CodexAnimarum,
		Pools = {
			Encyclopedia.ItemPools.POOL_TREASURE,
			Encyclopedia.ItemPools.POOL_LIBRARY,
		},
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.ElderMyth,
		WikiDesc = Wiki.ElderMyth,
		Pools = {
			Encyclopedia.ItemPools.POOL_SECRET,
			Encyclopedia.ItemPools.POOL_LIBRARY,
		},
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.ForgottenGrimoire,
		WikiDesc = Wiki.ForgottenGrimoire,
		Pools = {
			Encyclopedia.ItemPools.POOL_SECRET,
			Encyclopedia.ItemPools.POOL_LIBRARY,
		},
	})
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.WizardBook,
		WikiDesc = Wiki.WizardBook,
		Pools = {
			Encyclopedia.ItemPools.POOL_SHOP,
			Encyclopedia.ItemPools.POOL_LIBRARY,
		},
	})	
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.RitualManuscripts,
		WikiDesc = Wiki.RitualManuscripts,
		Pools = {
			Encyclopedia.ItemPools.POOL_ANGEL,
			Encyclopedia.ItemPools.POOL_LIBRARY,
		},
	})	
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.StitchedPapers,
		WikiDesc = Wiki.StitchedPapers,
		Pools = {
			Encyclopedia.ItemPools.POOL_SHOP,
			Encyclopedia.ItemPools.POOL_LIBRARY,
		},
	})	
	
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.NirlyCodex,
		WikiDesc = Wiki.NirlyCodex,
		Pools = {
			Encyclopedia.ItemPools.POOL_TREASURE,
			Encyclopedia.ItemPools.POOL_LIBRARY,
		},
	})
	
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.AlchemicNotes,
		WikiDesc = Wiki.AlchemicNotes,
		Pools = {
			Encyclopedia.ItemPools.POOL_TREASURE,
			Encyclopedia.ItemPools.POOL_SECRET,
			Encyclopedia.ItemPools.POOL_LIBRARY,
		},
	})
	
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.LockedGrimoire,
		WikiDesc = Wiki.LockedGrimoire,
		Pools = {
			Encyclopedia.ItemPools.POOL_TREASURE,
			Encyclopedia.ItemPools.POOL_LIBRARY,
		},
	})	
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.StoneScripture,
		WikiDesc = Wiki.StoneScripture,
		Pools = {
			Encyclopedia.ItemPools.POOL_ANGEL,
			Encyclopedia.ItemPools.POOL_LIBRARY,
		},
	})	
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.HuntersJournal,
		WikiDesc = Wiki.HuntersJournal,
		Pools = {
			Encyclopedia.ItemPools.POOL_TREASURE,
			Encyclopedia.ItemPools.POOL_LIBRARY,
		},
	})	
	
	Encyclopedia.AddItem({
		ModName = "Eclipsed",
		Class = "Eclipsed",
		ID = enums.Items.TomeDead,
		WikiDesc = Wiki.TomeDead,
		Pools = {
			Encyclopedia.ItemPools.POOL_SECRET,
			Encyclopedia.ItemPools.POOL_LIBRARY,
		},
	})	
	
	
end
