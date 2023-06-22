EclipsedMod = RegisterMod("Eclipsed", 1)
local mod = EclipsedMod
local json = require("json")
include("scripts_eclipsed.enums")
include("scripts_eclipsed.datatables")
include("scripts_eclipsed.functions")
---Mod Compat --------------------------------------------------------------------------------
include("scripts_eclipsed.compat.eid")
include("scripts_eclipsed.compat.encyclopedia")
---Libs	--------------------------------------------------------------------------------------
local hiddenItemManager = include("scripts_eclipsed.lib.hidden_item_manager"):Init(mod)
mod.GrabItemCallback = include("scripts_eclipsed.lib.inventory_callbacks")
----------------------------------------------------------------------------------------------

local game = Game()
local itemPool = game:GetItemPool()
local sfx = SFXManager()
local RECOMMENDED_SHIFT_IDX = 35


--- CUSTOM CALLBACKS 

---datatables
local datatables = {}

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


datatables.HourglassIcon = Sprite()
datatables.HourglassPic = Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS).GfxFileName
datatables.HourglassIcon:Load("gfx/005.100_Collectible.anm2", true)
datatables.HourglassIcon:ReplaceSpritesheet(1, datatables.HourglassPic)
datatables.HourglassIcon:LoadGraphics()
datatables.HourglassIcon.Scale = Vector.One * 0.8
datatables.HourglassIcon:SetFrame("Idle", 8)

datatables.HourglassText = Font()
datatables.HourglassText:Load("font/pftempestasevencondensed.fnt")

datatables.SpecialCursesAvtice = true
datatables.RedColor = Color(1.5,0,0,1,0,0,0)
datatables.PinkColor = Color(2,0,0.7,1,0,0,0)





EclipsedMod.datatables = datatables



--- fucntions
local game = Game()
local functions = {}

function functions.getPlayerIndex(player) -- ded#8894 Algorithm
	--- get player index. used to SAVE/LOAD mod data
	local collectible = 1 -- sad onion
	local playerType = player:GetPlayerType()
	if playerType == PlayerType.PLAYER_LAZARUS2_B then
		collectible = 2
	end
	local seed = player:GetCollectibleRNG(collectible):GetSeed()
	return tostring(seed)
end

function functions.ResetPersistentData()
	local ResetData = {}
	ResetData.SpecialCursesAvtice = false
	ResetData.FloppyDiskItems = {}
	ResetData.CompletionMarks= {}
	ResetData.CompletionMarks.Nadab = EclipsedMod.datatables.completionInit
	ResetData.CompletionMarks.Abihu = EclipsedMod.datatables.completionInit
	ResetData.CompletionMarks.Unbidden = EclipsedMod.datatables.completionInit
	ResetData.CompletionMarks.UnbiddenB = EclipsedMod.datatables.completionInit
	ResetData.CompletionMarks.Challenges = EclipsedMod.datatables.challengesInit

	return ResetData
end

function functions.GetItemsCount(player, item, trueItems)
	trueItems = trueItems or false
	return player:GetCollectibleNum(item, trueItems)+player:GetEffects():GetCollectibleEffectNum(item)
end

function functions.GetCurrentModCurses()
	--- get curses on current level
	local currentCurses = game:GetLevel():GetCurses()
	local curseTable = {}
	for _, curse in pairs(EclipsedMod.enums.Curses) do
		if currentCurses & curse == curse and curse ~= 0 then
			table.insert(curseTable, curse)
		end
	end
	return curseTable
end

function functions.CurseIconRender()
	--- curse icons render
	local sprites = {}
	local currentCurses = functions.GetCurrentModCurses()
	if #currentCurses > 0 then
		for i, curse in pairs(currentCurses) do
			local topRight = Options.HUDOffset*Vector(24, 12)
			local gfx = EclipsedMod.enums.CurseIconsList[curse]
			local vecX = 148 + EclipsedMod.datatables.CURSE_SPRITE_SCALE * math.floor((i - 1) % EclipsedMod.datatables.CURSE_COLUMNS )
			local vecY = 12 + EclipsedMod.datatables.CURSE_SPRITE_SCALE * math.floor((i - 1) / EclipsedMod.datatables.CURSE_COLUMNS )
			local pos =  Vector(vecX , vecY) + topRight
			EclipsedMod.datatables.CurseIcons:Render(pos, Vector.Zero, Vector.Zero)
			EclipsedMod.datatables.CurseIcons:ReplaceSpritesheet(0, gfx)
			EclipsedMod.datatables.CurseIcons:LoadGraphics()
			EclipsedMod.datatables.CurseIcons:Update()
			table.insert(sprites, EclipsedMod.datatables.CurseIcons)
			sprites[i].Color = Color(1,1,1, EclipsedMod.datatables.CurseIconOpacity)
			EclipsedMod.datatables.CurseIcons:Play("Idle")
		end
	end
end


function functions.EvaluateDuckLuck(player, luck)
	local data = player:GetData()
	data.eclipsed.DuckCurrentLuck = luck
	player:AddCacheFlags(CacheFlag.CACHE_LUCK)
	player:EvaluateItems()
end


EclipsedMod.functions = functions


--- GAME EXIT
function mod:onExit(isContinue)
	local savetable = {}
	savetable.PersistentData = mod.PersistentData
	if isContinue then
		savetable.ModVars = mod.ModVars
		savetable.eclipsed = {}
		savetable.HiddenItemWisps = hiddenItemManager:GetSaveData()
		for playerNum = 0, game:GetNumPlayers()-1 do
			local player = game:GetPlayer(playerNum)
			local data = player:GetData()
			local idx = mod.functions.GetPlayerIndex(player)
			savetable.eclipsed[idx] = data.eclipsed
		end
	end
	mod:SaveData(json.encode(savetable))
end
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.onExit)

--- GAME START
function mod:onStart(isSave)	
	--if isSave then  -- reset blind Abihu and UnbiddenB
	if mod:HasData() then
		local localtable = json.decode(mod:LoadData())
		mod.PersistentData = localtable.PersistentData
		if isSave then
			hiddenItemManager:LoadData(localtable.HiddenItemWisps)
			if localtable.ModVars then
				mod.ModVars = localtable.ModVars
			end
			if localtable.eclipsed then
				for playerNum = 0, game:GetNumPlayers()-1 do
					local player = game:GetPlayer(playerNum)
					local data = player:GetData()
					local idx = mod.functions.GetPlayerIndex(player)
					local tempEffects = player:GetEffects()
					if localtable.eclipsed[idx] then
						data.eclipsed = localtable.eclipsed[idx]
					end
					-- add Lililith effects into data.eclipsed.ForLevelEffects item and count
					if data.eclipsed.ForLevelEffects then
						for _, tempEffect in pairs(data.eclipsed.ForLevelEffects) do
							tempEffects:AddCollectibleEffect(tempEffect[1], false, tempEffect[2])
						end
					end
					if player:HasCollectible(mod.enums.Items.RubberDuck) then
						mod.functions.EvaluateDuckLuck(player, data.eclipsed.DuckCurrentLuck)
					end
					if data.eclipsed.RedPillDamageUp then
						player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
					end
					player:EvaluateItems()
				end
			end
		end
	else
		mod.PersistentData = mod.functions.ResetPersistentData()	
	end
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.onStart)

--- RENDER
function mod:onRender()
	mod.functions.CurseIconRender()
	
	--local player = Isaac.GetPlayer(0)
	--local data = player:GetData()
	
	
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.onRender)


--- EVAL CACHE
function mod:onCache(player, cacheFlag)
	player = player:ToPlayer()
	local data = player:GetData()
	
	if mod.ModVars then
		if cacheFlag == CacheFlag.CACHE_LUCK then
			if data.ModVars.MisfortuneLuck then
				player.Luck = player.Luck + mod.datatables.MisfortuneLuck
			end
		end
	end	
	
	if data.eclipsed then
		if cacheFlag == CacheFlag.CACHE_LUCK then
			if player:HasCollectible(mod.enums.Items.RubberDuck) and data.eclipsed.DuckCurrentLuck then
				player.Luck = player.Luck + data.eclipsed.DuckCurrentLuck
			end
			if player:HasCollectible(mod.enums.Items.VoidKarma) and data.eclipsed.KarmaStats then
				player.Luck = player.Luck + data.eclipsed.KarmaStats.Luck
			end
			if data.eclipsed.DeuxExLuck then
				player.Luck = player.Luck + data.eclipsed.DeuxExLuck
			end
		end
		if cacheFlag == CacheFlag.CACHE_DAMAGE then
			if data.eclipsed.RedPillDamageUp then
				player.Damage = player.Damage + data.eclipsed.RedPillDamageUp
			end
			if data.eclipsed.RedLotusDamage then -- save damage even if you removed item
				player.Damage = player.Damage + data.eclipsed.RedLotusDamage
			end
			if player:HasCollectible(mod.enums.Items.VoidKarma) and data.eclipsed.KarmaStats then
				player.Damage = player.Damage + data.eclipsed.KarmaStats.Damage
			end
			if data.eclipsed.EclipseBoost and data.eclipsed.EclipseBoost > 0 then
			    player.Damage = player.Damage + player.Damage * (mod.datatables.Eclipse.DamageBoost * data.eclipsed.EclipseBoost)
			end
			if data.eclipsed.HeartTransplantUseCount and data.eclipsed.HeartTransplantUseCount > 0 then
				local damageMulti = mod.datatables.HeartTransplant.ChainValue[data.eclipsed.HeartTransplantUseCount][1]
				player.Damage = player.Damage + player.Damage * damageMulti
			end
		end
		if cacheFlag == CacheFlag.CACHE_FIREDELAY then
			if player:HasCollectible(mod.enums.Items.VoidKarma) and data.eclipsed.KarmaStats then
				local stat_cache = player.MaxFireDelay + data.eclipsed.KarmaStats.Firedelay
				if player.MaxFireDelay > 5 then
					stat_cache = 5 
				end
				if player.MaxFireDelay > 1 then
					player.MaxFireDelay = stat_cache
				end
			end
			if data.eclipsed.HeartTransplantUseCount and data.eclipsed.HeartTransplantUseCount > 0 then
				local tearsUP = mod.datatables.HeartTransplant.ChainValue[data.eclipsed.HeartTransplantUseCount][2]
				player.MaxFireDelay = player.MaxFireDelay + tearsUP
			end
		end
		if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
			if player:HasCollectible(mod.enums.Items.VoidKarma) and data.eclipsed.KarmaStats then
				player.ShotSpeed = player.ShotSpeed + data.eclipsed.KarmaStats.Shotspeed
			end
		end
		if cacheFlag == CacheFlag.CACHE_RANGE then
			if player:HasCollectible(mod.enums.Items.VoidKarma) and data.eclipsed.KarmaStats then
				player.TearRange = player.TearRange + data.eclipsed.KarmaStats.Range
			end
		end
		if cacheFlag == CacheFlag.CACHE_SPEED then
			if player:HasCollectible(enums.Items.MiniPony) then --and player.MoveSpeed < datatables.MiniPony.MoveSpeed then
				player.MoveSpeed = mod.datatables.MiniPony.MoveSpeed
			end
			if player:HasCollectible(mod.enums.Items.VoidKarma) and data.KarmaStats then
				player.MoveSpeed = player.MoveSpeed + data.eclipsed.KarmaStats.Speed
			end
			if data.HeartTransplantUseCount and data.HeartTransplantUseCount > 0 then
				local speed = mod.datatables.HeartTransplant.ChainValue[data.eclipsed.HeartTransplantUseCount][3]
				player.MoveSpeed = player.MoveSpeed + speed
			end
		end
		if cacheFlag == CacheFlag.CACHE_TEARCOLOR then
			if player:HasCollectible(mod.enums.Items.MeltedCandle) then
				player.TearColor = mod.datatables.MeltedCandle.TearColor
			end
		end
		if cacheFlag == CacheFlag.CACHE_FLYING then
			if player:HasCollectible(mod.enums.Items.MiniPony) or player:HasCollectible(mod.enums.Items.LongElk) or player:HasCollectible(mod.enums.Items.Viridian) or player:HasCollectible(mod.enums.Items.MewGen) then
				player.CanFly = true
			end
		end
		if cacheFlag == CacheFlag.CACHE_FAMILIARS then
			
			local bags = mod.functions.GetItemsCount(player, mod.enums.Items.RedBag)
			if bags > 0 then
				player:CheckFamiliar(mod.datatables.RedBag.Variant, bags, RNG(), Isaac.GetItemConfig():GetCollectible(mod.enums.Items.RedBag))
			end
			-- lililiths
			local lililiths = functions.GetItemsCount(player, enums.Items.Lililith)
			if lililiths > 0 then
				player:CheckFamiliar(datatables.Lililith.Variant, lililiths, RNG(), Isaac.GetItemConfig():GetCollectible(enums.Items.Lililith))
			end
			
			-- abihu familiars
			local profans = functions.GetItemsCount(player, enums.Items.AbihuFam)
			local punches = functions.GetItemsCount(player, CollectibleType.COLLECTIBLE_PUNCHING_BAG)
			if profans > 0 then
				if punches > 0 then
					local entities2 = Isaac.FindByType(EntityType.ENTITY_FAMILIAR, datatables.AbihuFam.Variant, _, true, false)
					for _, punch in pairs(entities2) do
						punch:Remove()
					end
					player:CheckFamiliar(datatables.AbihuFam.Variant, punches, RNG(), Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_PUNCHING_BAG), 0)
				end
				player:CheckFamiliar(datatables.AbihuFam.Variant, profans, RNG(), Isaac.GetItemConfig():GetCollectible(enums.Items.AbihuFam), datatables.AbihuFam.Subtype)
			end
			
			-- nadab brain
			local brains = functions.GetItemsCount(player, enums.Items.NadabBrain)
			if brains > 0 then
				player:CheckFamiliar(datatables.NadabBrain.Variant, brains, RNG(), Isaac.GetItemConfig():GetCollectible(enums.Items.NadabBrain))
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.onCache)









