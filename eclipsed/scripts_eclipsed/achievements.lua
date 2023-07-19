---from Sodom and Gomorrah + Andromeda
local mod = EclipsedMod
local game = Game()
local itemPool = game:GetItemPool()
local sfx = SFXManager()
local enums = mod.enums
local functions = mod.functions
local json = require("json")
---ACHIEVEMENT DISPLAY -----------------------------------------------
local GamePause = nil
local GamePauseAtFrame = nil
local GamePauseDuration = 0
local GameUnpauseForce = nil
local AchivementQueue = {}
local AchivementUpdate = false
local AchivementRender = false
local AchivementSprite = Sprite()
AchivementSprite:Load("gfx/ui/achievement/eclipsed_achievements.anm2", true)

local function PauseGame(frames)
	if game:GetRoom():GetBossID() ~= 54 then -- Intenionally fail on Lamb, since it breaks the Victory Lap menu super hard
		GamePauseAtFrame = GamePauseAtFrame or game:GetFrameCount()
		GamePauseDuration = GamePauseDuration + frames
		GamePause = true
		Isaac.GetPlayer():UseActiveItem(CollectibleType.COLLECTIBLE_PAUSE, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC)
	end
end

local function QueueAchievementNote(gfx, timer) -- call when achievement unlocked
	timer = timer or 62
	table.insert(AchivementQueue, {gfx, timer})
end

local function PlayAchievementNote(gfx)
	PauseGame(gfx[2])
	
	--game:GetHUD():ShowFortuneText(gfx)
	AchivementSprite:ReplaceSpritesheet(2, gfx[1])
	AchivementSprite:LoadGraphics()
	AchivementSprite:Play("Idle", true)
	AchivementUpdate = false
	AchivementRender = true
	sfx:Play(SoundEffect.SOUND_CHOIR_UNLOCK)
end

function mod:onInputAction1(_, inputHook, action)
	if inputHook == InputHook.IS_ACTION_PRESSED or inputHook == InputHook.IS_ACTION_TRIGGERED then
		if GamePause and action ~= ButtonAction.ACTION_CONSOLE then
			return false
		elseif GameUnpauseForce and action == ButtonAction.ACTION_SHOOTDOWN then
			GameUnpauseForce = false
			return true
		end
	elseif inputHook == InputHook.GET_ACTION_VALUE and GamePause and action ~= ButtonAction.ACTION_CONSOLE then
		return 0
	end
end
mod:AddCallback(ModCallbacks.MC_INPUT_ACTION, mod.onInputAction1)

function mod:onUpdate1()
	if GamePauseAtFrame and GamePauseAtFrame + GamePauseDuration < game:GetFrameCount() then
		GamePause = false
		GamePauseAtFrame = nil
		GamePauseDuration = 0
		GameUnpauseForce = true
	end
	if mod.SADTOANNOUNCETHATWERESETTINGMODDATA then
		mod.SADTOANNOUNCETHATWERESETTINGMODDATA = false
		QueueAchievementNote("gfx/ui/achievement/RESET.png", 90)
		print('[Eclipsed v.2.0] If your mod progress was lost - type `eclipsed unlock all`')
	end
	if not AchivementRender and  #AchivementQueue > 0 then
		PlayAchievementNote(AchivementQueue[1])
		table.remove(AchivementQueue, 1)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.onUpdate1)

function mod:onRenderAchive()
	if AchivementRender then
		if AchivementUpdate then AchivementSprite:Update() end
		AchivementUpdate = not AchivementUpdate
		local position = Vector(Isaac.GetScreenWidth() / 2, Isaac.GetScreenHeight() / 2)
		AchivementSprite:Render(position, Vector.Zero, Vector.Zero)
		if AchivementSprite:GetFrame() > 11 and GamePauseDuration-21 > 0 then
			AchivementSprite:SetFrame(11)
		end	
		
		if AchivementSprite:IsFinished() then AchivementRender = false end
	
	end
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.onRenderAchive)
---COMPLETION MARKS-------------------------------------------------
local LockedItems = {
	[enums.Items.DiceBombs] = {"Nadab", 1, {"isaac"}},
	[enums.Items.DeadBombs] = {"Nadab", 1, {"bbaby"}},
	[enums.Items.GravityBombs] = {"Nadab", 1, {"satan"}},
	[enums.Items.FrostyBombs] = {"Nadab", 1, {"lamb"}},
	[enums.Items.Pyrophilia] = {"Nadab", 1, {"greed"}},
	[enums.Items.BatteryBombs] = {"Nadab", 2, {"greed"}},
	[enums.Items.CompoBombs] = {"Nadab", 1, {"beast"}},
	[enums.Items.MirrorBombs] = {"Nadab", 1, {"deli"}},
	[enums.Items.RedButton] = {"Nadab", 1,{"rush"}},
	[enums.Items.MeltedCandle] = {"Abihu", 1, {"mother"}},
	[enums.Items.IvoryOil] = {"Abihu", 1, {"beast"}},
	[enums.Items.NadabBrain] = {"Abihu", 1, {"deli"}},
	[enums.Items.NadabBody] = {"Abihu", 1, {"deli"}},
	--[enums.Items.EyeKey] = {"Abihu", 2, {"all"}},
	--[enums.Items.EyeKeyClosed] = {"Abihu", 2, {"all"}},
	[enums.Items.VoidKarma] = {"Unbidden", 1, {"isaac"}},
	[enums.Items.VHSCassette] = {"Unbidden", 1, {"lamb"}},
	[enums.Items.LongElk] = {"Unbidden", 1, {"satan"}},
	[enums.Items.RubberDuck] = {"Unbidden", 1, {"bbaby"}},
	[enums.Items.BlackKnight] = {"Unbidden", 1, {"hush"}},
	[enums.Items.WhiteKnight] = {"Unbidden", 1, {"hush"}},
	[enums.Items.MidasCurse] = {"Unbidden", 1, {"greed"}},
	[enums.Items.Lililith] = {"Unbidden", 2, {"greed"}},
	[enums.Items.RedMirror] = {"Unbidden", 1, {"mother"}},
	[enums.Items.Limb] = {"Unbidden", 1, {"beast"}},
	[enums.Items.RedLotus] = {"Unbidden", 1, {"deli"}},
	[enums.Items.Eclipse] = {"Unbidden ", 1, {"deli"}},
	[enums.Items.RedBag] = {"Unbidden ", 1, {"beast"}},
	[enums.Items.ElderMyth] = {"Unbidden ", 2, {"greed"}},
	[enums.Items.FloppyDisk] = {"Unbidden ", 2, {"all"}},
	[enums.Items.FloppyDiskFull] = {"Unbidden ", 2, {"all"}},
	[enums.Items.MewGen] = {"Challenges", 1, {"magician"}},
}
local LockedTrinkets = {
	[enums.Trinkets.BobTongue] = {"Nadab", 1, {"mother"}},
	[enums.Trinkets.RedScissors] = {"Abihu", 1, {"isaac", "bbaby", "satan", "lamb"}},
	[enums.Trinkets.Duotine] = {"Unbidden ", 1, {"mega"}},
	[enums.Trinkets.WitchPaper] = {"Unbidden ", 1, {"isaac", "bbaby", "satan", "lamb"}},
	[enums.Trinkets.Cybercutlet] = {"Challenges", 1, {"potato"}},
	[enums.Trinkets.GildedFork] = {"Challenges", 1, {"beatmaker"}},
	[enums.Trinkets.GoldenEgg] = {"Challenges", 1, {"mongofamily"}},
}
local LockedCards = {
	[enums.Pickups.KingChess] = {"Nadab", 1, {"hush"}},
	[enums.Pickups.KingChessW] = {"Nadab", 1, {"hush"}},
	[enums.Pickups.Domino34] = {"Nadab", 1, {"mega"}},
	[enums.Pickups.Domino25] = {"Nadab", 1, {"mega"}},
	[enums.Pickups.Domino16] = {"Nadab", 1, {"mega"}},
	[enums.Pickups.Domino00] = {"Nadab", 1, {"mega"}},
	[enums.Pickups.SoulNadabAbihu] = {"Abihu", 1, {"rush", "hush"}},
	[enums.Pickups.AscenderBane] = {"Abihu", 2, {"greed"}},
	[enums.Pickups.Decay] = {"Abihu", 2, {"greed"}},
	[enums.Pickups.Wish] = {"Abihu", 2, {"greed"}},
	[enums.Pickups.InfiniteBlades] = {"Abihu", 2, {"greed"}},
	[enums.Pickups.Offering] = {"Abihu", 2, {"greed"}},
	[enums.Pickups.Transmutation] = {"Abihu", 2, {"greed"}},
	[enums.Pickups.Fusion] = {"Abihu", 2, {"greed"}},
	[enums.Pickups.MultiCast] = {"Abihu", 2, {"greed"}},
	[enums.Pickups.RitualDagger] = {"Abihu", 2, {"greed"}},
	[enums.Pickups.DeuxEx] = {"Abihu", 2, {"greed"}},
	[enums.Pickups.Corruption] = {"Abihu", 2, {"greed"}},
	[enums.Pickups.Adrenaline] = {"Abihu", 2, {"greed"}},
	[enums.Pickups.Apocalypse] = {"Unbidden", 1, {"rush"}},
	[enums.Pickups.Trapezohedron] = {"Unbidden ", 1, {"mother"}},
	--[enums.Pickups.RedPill] = {"Unbidden ", 1, {"mega"}},
	--[enums.Pickups.RedPillHorse] = {"Unbidden ", 1, {"mega"}},
	[enums.Pickups.SoulUnbidden] = {"Unbidden ", 1, {"rush", "hush"}},
	[enums.Pickups.OblivionCard] = {"Unbidden ", 2, {"greed"}},
	[enums.Pickups.BattlefieldCard] = {"Unbidden ", 2, {"greed"}},
	[enums.Pickups.BookeryCard] = {"Unbidden ", 2, {"greed"}},
	[enums.Pickups.TreasuryCard] = {"Unbidden ", 2, {"greed"}},
	[enums.Pickups.BloodGroveCard] = {"Unbidden ", 2, {"greed"}},
	[enums.Pickups.StormTempleCard] = {"Unbidden ", 2, {"greed"}},
	[enums.Pickups.ZeroMilestoneCard] = {"Unbidden ", 2, {"greed"}},
	[enums.Pickups.MazeMemoryCard] = {"Unbidden ", 2, {"greed"}},
	[enums.Pickups.CryptCard] = {"Unbidden ", 2, {"greed"}},
	[enums.Pickups.OutpostCard] = {"Unbidden ", 2, {"greed"}},
	[enums.Pickups.ArsenalCard] = {"Unbidden ", 2, {"greed"}},
	[enums.Pickups.DeliObjectCell] = {"Challenges", 1, {"lobotomy"}},
	[enums.Pickups.DeliObjectBomb] = {"Challenges", 1, {"lobotomy"}},
	[enums.Pickups.DeliObjectKey] = {"Challenges", 1, {"lobotomy"}},
	[enums.Pickups.DeliObjectCard] = {"Challenges", 1, {"lobotomy"}},
	[enums.Pickups.DeliObjectPill] = {"Challenges", 1, {"lobotomy"}},
	[enums.Pickups.DeliObjectRune] = {"Challenges", 1, {"lobotomy"}},
	[enums.Pickups.DeliObjectHeart] = {"Challenges", 1, {"lobotomy"}},
	[enums.Pickups.DeliObjectCoin] = {"Challenges", 1, {"lobotomy"}},
	[enums.Pickups.DeliObjectBattery] = {"Challenges", 1, {"lobotomy"}},

	[enums.Pickups.CemeteryCard] = {"Unbidden ", 2, {"greed"}},
	[enums.Pickups.VillageCard] = {"Unbidden ", 2, {"greed"}},
	[enums.Pickups.GroveCard] = {"Unbidden ", 2, {"greed"}},
	[enums.Pickups.WheatFieldsCard] = {"Unbidden ", 2, {"greed"}},
	[enums.Pickups.RuinsCard] = {"Unbidden ", 2, {"greed"}},
	[enums.Pickups.SwampCard] = {"Unbidden ", 2, {"greed"}},
	[enums.Pickups.SpiderCocoonCard] = {"Unbidden ", 2, {"greed"}},
	[enums.Pickups.RoadLanternCard] = {"Unbidden ", 2, {"greed"}},
	[enums.Pickups.VampireMansionCard] = {"Unbidden ", 2, {"greed"}},
	[enums.Pickups.SmithForgeCard] = {"Unbidden ", 2, {"greed"}},
	[enums.Pickups.ChronoCrystalsCard] = {"Unbidden ", 2, {"greed"}},
	[enums.Pickups.WitchHut] = {"Unbidden ", 2, {"greed"}},
	[enums.Pickups.BeaconCard] = {"Unbidden ", 2, {"greed"}},
	[enums.Pickups.TemporalBeaconCard] = {"Unbidden ", 2, {"greed"}},
}
local LockedPapers = {
	Nadab = {
		isaac = "gfx/ui/achievement/DiceBombs.png", bbaby = "gfx/ui/achievement/DeadBombs.png",
		satan = "gfx/ui/achievement/GravityBombs.png", lamb = "gfx/ui/achievement/FrostyBombs.png",
		rush = "gfx/ui/achievement/RedButton.png", hush = "gfx/ui/achievement/KingChess.png",
		deli = "gfx/ui/achievement/MirrorBombs.png",
		greed = "gfx/ui/achievement/Pyrophilia.png", greed2 = "gfx/ui/achievement/BatteryBombs.png",
		mother = "gfx/ui/achievement/BobTongue.png", beast = "gfx/ui/achievement/CompoBombs.png",
	},
	Abihu = {
		isaacsatan = "gfx/ui/achievement/RedScissors.png",
		hushrush = "gfx/ui/achievement/SoulNadabAbihu.png",
		deli = "gfx/ui/achievement/NadabBrainAndBody.png",
		greed2 = "gfx/ui/achievement/SlayTheSpire.png",
		mega = "gfx/ui/achievement/DominoTiles.png",
		mother = "gfx/ui/achievement/MeltedCandle.png",
		beast = "gfx/ui/achievement/IvoryOil.png",
		--all = "gfx/ui/achievement/EyeKey.png",
	},
	Unbidden = {
		isaac = "gfx/ui/achievement/VoidKarma.png", bbaby = "gfx/ui/achievement/RubberDuck.png",
		satan = "gfx/ui/achievement/LongElk.png", lamb = "gfx/ui/achievement/VHSCassette.png",
		rush = "gfx/ui/achievement/Apocalypse.png", hush = "gfx/ui/achievement/Knights.png",
		deli = "gfx/ui/achievement/RedLotus.png",
		greed = "gfx/ui/achievement/MidasCurse.png", greed2 = "gfx/ui/achievement/Lililith.png",
		mother = "gfx/ui/achievement/RedMirror.png", beast = "gfx/ui/achievement/Limb.png",
	},
	UnbiddenB = {
		isaacsatan = "gfx/ui/achievement/WitchPaper.png",
		hushrush = "gfx/ui/achievement/SoulUnbidden.png",
		deli = "gfx/ui/achievement/Eclipse.png",
		mega = "gfx/ui/achievement/DuotineAndRedPill.png",
		greed2 = "gfx/ui/achievement/LoopHero.png",
		mother = "gfx/ui/achievement/Trapezohedron.png",
		beast = "gfx/ui/achievement/RedBag.png",
		all = "gfx/ui/achievement/FloppyDisk.png",
	},
	Challenges = {
		potato = "gfx/ui/achievement/Cybercutlet.png",
		lobotomy = "gfx/ui/achievement/DeliriousBum.png",
		magician = "gfx/ui/achievement/MewGen.png",
		beatmaker = "gfx/ui/achievement/GildedFork.png",
		mongofamily = "gfx/ui/achievement/GoldenEgg.png",
		--shovel = "gfx/ui/achievement/Whispers.png",
	},
}

---Init Pool Unlocks
function mod:onInitUnlock(ppl)
	if game:GetFrameCount() == 0 then
		if mod:HasData() then
			local localtable = json.decode(mod:LoadData())
			--mod.PersistentData = localtable.PersistentData
			mod.PersistentData = {}
			mod.PersistentData.SpecialCursesAvtice = localtable.SpecialCursesAvtice
			mod.PersistentData.FloppyDiskItems = localtable.FloppyDiskItems
			mod.PersistentData.CompletionMarks = localtable.CompletionMarks
		else
			mod.PersistentData = functions.ResetPersistentData()
		end
		local modCompletion = mod.PersistentData.CompletionMarks
		if not modCompletion then return end
		---items
		if ppl:GetPlayerType() == enums.Characters.UnbiddenB or ppl:GetPlayerType() == enums.Characters.Unbidden then
			itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_SCHOOLBAG)
		end
		for item, tab in pairs(LockedItems) do
			local unlocked = true
			local checkname = tab[1] -- get name of player
			local checkvalue = tab[2] -- get completion mark value
			local checklist = tab[3] -- get mark names -> isaac, bbaby, satan, lamb etc.
			for _, mark in pairs(checklist) do -- check marks
				if modCompletion[checkname] and modCompletion[checkname][mark] < checkvalue then -- check value: if savedValue < checkvalue then
					unlocked = false
					break
				end
			end
			if not unlocked then
				itemPool:RemoveCollectible(item)
			end
		end
		---Trinkets
		for trinket, tab in pairs(LockedTrinkets) do
			local unlocked = true
			local checkname = tab[1]
			local checkvalue = tab[2]
			local checklist = tab[3]
			for _, mark in pairs(checklist) do
				if modCompletion[checkname] and modCompletion[checkname][mark] < checkvalue then
					unlocked = false
					break
				end
			end
			if not unlocked then
				itemPool:RemoveTrinket(trinket)
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.onInitUnlock)
---GET CARD--
function mod:onGetCardUnlock(rng, card, playingCards, includeRunes, onlyRunes)
	if LockedCards[card] and mod.PersistentData then
		local modCompletion = mod.PersistentData.CompletionMarks
		if not modCompletion then return end
		local unlocked = true
		local checkname = LockedCards[card][1]
		local checkvalue = LockedCards[card][2]
		local checklist = LockedCards[card][3]
		for _, mark in pairs(checklist) do
			if modCompletion[checkname] and modCompletion[checkname][mark] < checkvalue then
				unlocked = false
				break
			end
		end
		if not unlocked then
			return itemPool:GetCard(rng:GetSeed(), playingCards, includeRunes, onlyRunes)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_GET_CARD, mod.onGetCardUnlock)

---UNLOCK ----------------
local DifficultyToCompletionMap = {
	[Difficulty.DIFFICULTY_NORMAL]	 = 1,
	[Difficulty.DIFFICULTY_HARD]	 = 2,
	[Difficulty.DIFFICULTY_GREED]	 = 1,
	[Difficulty.DIFFICULTY_GREEDIER] = 2,
}

local BossID = { -- Only the relevant ones (SodomAndGomorrah)
	HEART 		= 8,
	SATAN 		= 24,
	IT_LIVES	= 25,
	ISAAC		= 39,
	BLUE_BABY	= 40,
	LAMB		= 54,
	MEGA_SATAN	= 55,
	GREED		= 62,
	HUSH		= 63,
	DELIRIUM	= 70,
	GREEDIER	= 71,
	MOTHER		= 88,
	MAUS_HEART	= 90,
	BEAST		= 100,
}

local CompletionRoomType = {
	[RoomType.ROOM_BOSSRUSH] = true,
	[RoomType.ROOM_BOSS] = true,
}

local function HasFullCompletion(myTable, charName)
	local allmarks = true
	if myTable.all < 2 then
	    for id, item in pairs(myTable) do
	       if id ~= "all" then
	           if item < 2 then
	               allmarks = false
	               break
	           end
	       end
	    end
		if allmarks then
	        myTable.all = 2
			if LockedPapers[charName].all and LockedPapers[charName].all then
				QueueAchievementNote(LockedPapers[charName].all)
			end
		end
	end
	return allmarks
end


function mod:onRoomClearUnlock()
	if game.Challenge > 0 then return end
	if game:GetVictoryLap() > 0 then return end
	local room = game:GetRoom()
	local roomtype = room:GetType()
	if not CompletionRoomType[roomtype] then return end
	if not Isaac.GetPlayer() then return end
	if not enums.Characters[Isaac.GetPlayer():GetName()] then return end
	local value = DifficultyToCompletionMap[game.Difficulty]
	local charName = Isaac.GetPlayer():GetName()
	if not mod.PersistentData.CompletionMarks then return end
	local marks = mod.PersistentData.CompletionMarks[charName]
	if not marks then return end
	if marks.all == 2 then return end
	if roomtype == RoomType.ROOM_BOSSRUSH then
		if LockedPapers[charName].hushrush and marks.hush > 0 and marks.rush == 0 then
			QueueAchievementNote(LockedPapers[charName].hushrush)
		elseif LockedPapers[charName].rush and marks.rush == 0 then
			QueueAchievementNote(LockedPapers[charName].rush)
		end
		marks.rush = math.max(marks.rush, value)
	elseif roomtype == RoomType.ROOM_BOSS then
		local boss = room:GetBossID()
		if game:GetLevel():GetStage() == LevelStage.STAGE7 then -- Void
			if boss == BossID.DELIRIUM then
				if LockedPapers[charName].deli and marks.deli == 0 then
					QueueAchievementNote(LockedPapers[charName].deli)
				end
				marks.deli = math.max(marks.deli, value)
			end
		else
			if boss == BossID.HEART or boss == BossID.IT_LIVES or boss == BossID.MAUS_HEART then
				if LockedPapers[charName].heart and marks.heart == 0 then
					QueueAchievementNote(LockedPapers[charName].heart)
				end
				marks.heart = math.max(marks.heart, value)
			elseif boss == BossID.ISAAC then
				if LockedPapers[charName].isaacsatan and marks.bbaby > 0 and marks.satan > 0 and marks.lamb > 0 and marks.isaac == 0 then
					QueueAchievementNote(LockedPapers[charName].isaacsatan)
				elseif LockedPapers[charName].isaac and marks.isaac == 0 then
					QueueAchievementNote(LockedPapers[charName].isaac)
				end
				marks.isaac = math.max(marks.isaac, value)
			elseif boss == BossID.BLUE_BABY then
				if LockedPapers[charName].isaacsatan and marks.isaac > 0 and marks.satan > 0 and marks.lamb > 0 and marks.bbaby == 0 then
					QueueAchievementNote(LockedPapers[charName].isaacsatan)
				elseif LockedPapers[charName].bbaby and marks.bbaby == 0 then
					QueueAchievementNote(LockedPapers[charName].bbaby)
				end
				marks.bbaby = math.max(marks.bbaby, value)
			elseif boss == BossID.SATAN then
				if LockedPapers[charName].isaacsatan and marks.bbaby > 0 and marks.isaac > 0 and marks.lamb > 0 and marks.satan == 0 then
					QueueAchievementNote(LockedPapers[charName].isaacsatan)
				elseif LockedPapers[charName].satan and marks.satan == 0 then
					QueueAchievementNote(LockedPapers[charName].satan)
				end
				marks.satan = math.max(marks.satan, value)
			elseif boss == BossID.LAMB then
				if LockedPapers[charName].isaacsatan and marks.bbaby > 0 and marks.satan > 0 and marks.isaac > 0 and marks.lamb == 0 then
					QueueAchievementNote(LockedPapers[charName].isaacsatan)
				elseif LockedPapers[charName].lamb and marks.lamb == 0 then
					QueueAchievementNote(LockedPapers[charName].lamb)
				end
				marks.lamb = math.max(marks.lamb, value)
			elseif boss == BossID.HUSH then
				if LockedPapers[charName].hushrush and marks.rush > 0 and marks.hush == 0 then
					QueueAchievementNote(LockedPapers[charName].hushrush)
				elseif LockedPapers[charName].hush and marks.hush == 0 then
					QueueAchievementNote(LockedPapers[charName].hush)
				end
				marks.hush = math.max(marks.hush, value)
			elseif boss == BossID.MEGA_SATAN then
				if LockedPapers[charName].mega and marks.mega == 0 then
					QueueAchievementNote(LockedPapers[charName].mega)
				end
				marks.mega = math.max(marks.mega, value)
			elseif boss == BossID.GREED or boss == BossID.GREEDIER then
				if LockedPapers[charName].greed2 and not LockedPapers[charName].greed then -- tainted chars
					QueueAchievementNote(LockedPapers[charName].greed2)
				elseif LockedPapers[charName].greed2 and LockedPapers[charName].greed then -- normal chars
					if marks.greed == 0 and value == 2 then -- if hard
						QueueAchievementNote(LockedPapers[charName].greed)
						QueueAchievementNote(LockedPapers[charName].greed2)
					elseif marks.greed == 0 and value == 1 then -- if normal
						QueueAchievementNote(LockedPapers[charName].greed)
					elseif marks.greed == 1 and value == 2 then -- if hard but normal was already completed
						QueueAchievementNote(LockedPapers[charName].greed2)
					end
				end
				marks.greed = math.max(marks.greed, value)
			elseif boss == BossID.MOTHER then
				if LockedPapers[charName].mother and marks.mother == 0 then
					QueueAchievementNote(LockedPapers[charName].mother)
				end
				marks.mother = math.max(marks.mother, value)
			end
		end
	end
	HasFullCompletion(marks, charName)
end
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, mod.onRoomClearUnlock)

--challangesInit
function mod:onTrophyCollision(_, collider) --pickup, collider, low
	if Isaac.GetChallenge() == 0 then return end
	if not collider:ToPlayer() then return end
	local modCompletion = mod.PersistentData.CompletionMarks.Challenges
	if not modCompletion then return end
	local currentChallenge = Isaac.GetChallenge()
	--if modCompletion.all == 1 then return end
	if currentChallenge == enums.Challenges.Potatoes then
		if LockedPapers.Challenges.potato and modCompletion.potato == 0 then
			modCompletion.potato = 2
			QueueAchievementNote(LockedPapers.Challenges.potato)
		end
	elseif currentChallenge == enums.Challenges.Magician then
		if LockedPapers.Challenges.magician and modCompletion.magician == 0 then
			modCompletion.magician = 2
			QueueAchievementNote(LockedPapers.Challenges.magician)
		end
	elseif currentChallenge == enums.Challenges.Lobotomy then
		if LockedPapers.Challenges.lobotomy and modCompletion.lobotomy == 0 then
			modCompletion.lobotomy = 2
			QueueAchievementNote(LockedPapers.Challenges.lobotomy)
		end
	elseif currentChallenge == enums.Challenges.Beatmaker then
		if LockedPapers.Challenges.beatmaker and modCompletion.beatmaker == 0 then
			modCompletion.beatmaker = 2
			QueueAchievementNote(LockedPapers.Challenges.beatmaker)
		end
	elseif currentChallenge == enums.Challenges.MongoFamily then
		if LockedPapers.Challenges.mongofamily and modCompletion.mongofamily == 0 then
			modCompletion.mongofamily = 2
			QueueAchievementNote(LockedPapers.Challenges.mongofamily)
		end
	end
	HasFullCompletion(modCompletion, "Challenges")
end
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, mod.onTrophyCollision, PickupVariant.PICKUP_TROPHY)

function mod:onNPCDeathAchiev(entity)
	if game:GetVictoryLap() > 0 then return end
	if game.Challenge > 0 then return end
	if entity.Variant ~= 0 then return end -- The Beast
	if not Isaac.GetPlayer() then return end
	if not enums.Characters[Isaac.GetPlayer():GetName()] then return end
	local value = DifficultyToCompletionMap[game.Difficulty]
	local charName = Isaac.GetPlayer():GetName()
	local marks = mod.PersistentData.CompletionMarks[charName]
	if marks.beast < 2 then
		if LockedPapers[charName].beast and marks.beast == 0 then
			QueueAchievementNote(LockedPapers[charName].beast)
		end
		marks.beast = math.max(marks.beast, value)
	end
	HasFullCompletion(marks, charName)
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, mod.onNPCDeathAchiev, EntityType.ENTITY_BEAST)