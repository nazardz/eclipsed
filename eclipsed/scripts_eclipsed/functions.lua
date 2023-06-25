if not EclipsedMod then return end

local game = Game()
local itemPool = game:GetItemPool()
local sfx = SFXManager()

local json = require("json")
local enums = require("scripts_eclipsed.enums")
local datatables = require("scripts_eclipsed.datatables")

local functions = {}

function functions.InitCall()
	--- init call on new game start
	datatables.OblivionCardErasedEntities = {}
	datatables.LobotomyErasedEntities = {}
	datatables.SecretLoveLetterAffectedEnemies = {}
	datatables.LililithDemonSpawn = { -- familiars that can be spawned by lililith
	{CollectibleType.COLLECTIBLE_DEMON_BABY, FamiliarVariant.DEMON_BABY, 0}, -- item. familiar. count
	{CollectibleType.COLLECTIBLE_LIL_BRIMSTONE, FamiliarVariant.LIL_BRIMSTONE, 0},
	{CollectibleType.COLLECTIBLE_LIL_ABADDON, FamiliarVariant.LIL_ABADDON, 0},
	{CollectibleType.COLLECTIBLE_INCUBUS, FamiliarVariant.INCUBUS, 0},
	{CollectibleType.COLLECTIBLE_SUCCUBUS, FamiliarVariant.SUCCUBUS, 0},
	{CollectibleType.COLLECTIBLE_LEECH, FamiliarVariant.LEECH, 0},
	{CollectibleType.COLLECTIBLE_TWISTED_PAIR, FamiliarVariant.TWISTED_BABY, 0},
	}
	
	datatables.DeliriumBeggarEnemies = {
		{EntityType.ENTITY_GAPER, 0}
	}
	datatables.DeliriumBeggarEnable = {
		[tostring(EntityType.ENTITY_GAPER..0)] = true
	}
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
end


function functions.modDataLoad()
	local savetable = {}
	if EclipsedMod:HasData() then
		savetable = json.decode(EclipsedMod:LoadData())
		--savetable.FloppyDiskItems = localtable.FloppyDiskItems
		--savetable.CompletionMarks = localtable.CompletionMarks
	else
		savetable.SpecialCursesAvtice = true
		savetable.FloppyDiskItems = {}
		savetable.CompletionMarks = {}
		savetable.CompletionMarks.Nadab = datatables.completionInit
		savetable.CompletionMarks.Abihu = datatables.completionInit
		savetable.CompletionMarks.Unbidden = datatables.completionInit
		savetable.CompletionMarks.UnbiddenB = datatables.completionInit
		savetable.CompletionMarks.Challenges = datatables.challengesInit
	end
	return savetable
end

function functions.modDataSave(savetable)
	EclipsedMod:SaveData(json.encode(savetable))
end

function functions.GetCompletion(name, mark)
	local savetable = functions.modDataLoad()
	if savetable.CompletionMarks[name][mark] then
		return savetable.CompletionMarks[name][mark]
	else
		return 0 
	end
end

---debug console add mod curse
function functions.AddModCurse(curse)
	local level = game:GetLevel()
	if level:GetCurses() & curse > 0 then
		level:RemoveCurses(curse)
		print("curse Disabled")
	else
		level:AddCurse(curse, false)
		game:GetHUD():ShowFortuneText(enums.CurseText[curse])
		print("curse Enabled")
	end
end


function functions.RenderChargeManager(player, chargeData, chargeSprite, chargeInitDelay, posX, posY)
	--- chars charge bar render
	posX = posX or -12
	posY = posY or -38

	local pos = Isaac.WorldToScreen(player.Position)
	--please dear modders use SpriteScale. cause Size - doesn't reliable param
	local vecX = pos.X + (player.SpriteScale.X * posX)
	local vecY = pos.Y + (player.SpriteScale.Y * posY)
	pos = Vector(vecX, vecY)

	if chargeSprite:IsFinished("Disappear") and player:GetFireDirection() ~= -1 then
		chargeSprite:SetFrame("Charging", 0)
	end
	if chargeData > 0 then
		local chargeCounter = math.floor((chargeData * 100) / chargeInitDelay) -- %100
		chargeSprite:Render(pos)
		if chargeCounter < 100 then
			chargeSprite:SetFrame("Charging", chargeCounter)
		elseif chargeCounter == 100 then
			if chargeSprite:GetAnimation() == "Charging" then
				chargeSprite:Play("StartCharged")
			elseif chargeSprite:IsFinished("StartCharged") then
				chargeSprite:Play("Charged")
			end
		end
		chargeSprite:Update()
	else
		if chargeSprite:IsPlaying("Disappear") then
			chargeSprite:Render(pos)
			chargeSprite:Update()
		else
			chargeSprite:Render(pos)
			chargeSprite:Play("Disappear")
			chargeSprite:Update()
		end
	end
end

function functions.GetCurrentDimension() -- KingBobson Algorithm: (get room dimension)
	--- get current dimension of room
	local level = game:GetLevel()
	local roomIndex = level:GetCurrentRoomIndex()
	local currentRoomDesc = level:GetCurrentRoomDesc()
	local currentRoomHash = GetPtrHash(currentRoomDesc)
	for dimension = 0, 2 do -- -1 current dim. 0 - normal dim. 1 - secondary dim (downpoor, mines). 2 - death certificate dim
		local dimensionRoomDesc = level:GetRoomByIdx(roomIndex, dimension)
		local dimensionRoomHash = GetPtrHash(dimensionRoomDesc)
		if (dimensionRoomHash == currentRoomHash) then
			return dimension
		end
	end
	return nil
end

function functions.CheckForParent(fam)
	--- check familiar parents and child
    local child = fam.Child
    local parent = fam.Parent
    if parent ~= nil then
        parent.Child = fam
    end
    if child ~= nil then
        child.Parent = fam
    end
end

function functions.GetItemsCount(player, item, trueItems)
	trueItems = trueItems or false
	--- get number of items
	return player:GetCollectibleNum(item, trueItems)+player:GetEffects():GetCollectibleEffectNum(item)
end

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

function functions.CheckItemType(ItemID, itemType)
	--- check item type
	itemType = itemType or ItemType.ITEM_ACTIVE
	if ItemID > 0 then
		local itemConfigItem = Isaac.GetItemConfig():GetCollectible(ItemID)
		return itemConfigItem.Type == itemType
	end
	return false
end


function functions.CheckItemTags(ItemID, Tag)
	--- check item tag
	if ItemID > 0 then
		local itemConfigItem = Isaac.GetItemConfig():GetCollectible(ItemID)
		return itemConfigItem.Tags & Tag == Tag
	end
	return false
end

function functions.CheckInRange(myNum, min, max)
	--- check if number in given range: max >= myNum >= min
	return myNum >= min and myNum <= max
end

function functions.WhatSoundIsIt()
	--- get sound effect id
	for id=1, SoundEffect.NUM_SOUND_EFFECTS do
		if sfx:IsPlaying(id) then print(id) end
	end
end

function functions.DebugSpawn(var, subtype, position, marg, velocity)
	--- spawn pickup near given position
	velocity = velocity or Vector.Zero
	marg = marg or 0
	position = position or game:GetRoom():GetCenterPos()
	Isaac.Spawn(EntityType.ENTITY_PICKUP, var, subtype, Isaac.GetFreeNearPosition(position, marg), velocity, nil)
end

function functions.TrinketRemoveAdd(player, newTrinket)
	--- gulp given trinket
	local t0 = player:GetTrinket(0) -- 0 - first slot
	local t1 = player:GetTrinket(1) -- 1 - second slot
	if t1 ~= 0 then
		player:TryRemoveTrinket(t1)
	end
	if t0 ~= 0 then
		player:TryRemoveTrinket(t0)
	end
	player:AddTrinket(newTrinket)
	player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC)
	if t1 ~= 0 then
		player:AddTrinket(t1, false)
	end
	if t0 ~= 0 then
		player:AddTrinket(t0, false)
	end
end

function functions.TrinketRemove(player, newTrinket)
	--- remove given gulped trinket
	local t0 = player:GetTrinket(0) -- 0 - first slot
	local t1 = player:GetTrinket(1)  -- 1 - second slot
	if t1 ~= 0 then
		player:TryRemoveTrinket(t1)
	end
	if t0 ~= 0 then
		player:TryRemoveTrinket(t0)
	end
	player:TryRemoveTrinket(newTrinket)
	if t1 ~= 0 then
		player:AddTrinket(t1, false)
	end
	if t0 ~= 0 then
		player:AddTrinket(t0, false)
	end
end

function functions.RemoveThrowTrinket(player, trinket, timer)
	--- init throw trinket (A+ trinket imitation)
	local randomVector = RandomVector()*5 --RandomVector() - Returns a random vector with length 1. Multiply this vector by a number for larger random vectors.
	local throwTrinket = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, trinket, player.Position, randomVector, player):ToPickup()
	local dataTrinket = throwTrinket:GetData()
	dataTrinket.DespawnTimer = timer
	player:TryRemoveTrinket(trinket)
end

function functions.UnitVector(vector) -- EDITH repentance mod
	--- idk what it does.
	return vector/math.sqrt(vector.X*vector.X + vector.Y*vector.Y)
end

function functions.GetCurrentModCurses()
	--- get curses on current level
	local currentCurses = game:GetLevel():GetCurses()
	local curseTable = {}
	for _, curse in pairs(enums.Curses) do
		if currentCurses & curse == curse and curse ~= 0 then
			table.insert(curseTable, curse)
		end
	end
	return curseTable
end

function functions.PandoraJarManager()
	--- get no curses
	local currentCurses = game:GetLevel():GetCurses()
	local curseTable = {}
	for _, curse in pairs(enums.Curses) do
		if currentCurses & curse == 0 then
			table.insert(curseTable, curse)
		end
	end
	return curseTable
end

function functions.GetScreenSize() --Made by Kilburn
    local room = game:GetRoom()
    local pos = room:WorldToScreenPosition(Vector(0,0)) - room:GetRenderScrollOffset() - game.ScreenShakeOffset
    local rx = pos.X + 60 * 26 / 40
    local ry = pos.Y + 140 * (26 / 40)
    return Vector(rx*2 + 13*26, ry*2 + 7*26)
end

function functions.EvaluateDuckLuck(player, luck)
	--- evaluate luck cache
	local data = player:GetData()
	data.DuckCurrentLuck = luck
	player:AddCacheFlags(CacheFlag.CACHE_LUCK)
	player:EvaluateItems()
end

function functions.CheckPickupAbuse(player) --From Xalum (I guess)--
	local data = player:GetData()
	local queuedItem = player.QueuedItem
	data.EclipsedHeldItem = queuedItem.Item or data.EclipsedHeldItem
	--if data.EclipsedHeldItem.Item:IsCollectible() and (not queuedItem.Item or (data.EclipsedHeldItem and data.EclipsedHeldItem.ID ~= queuedItem.Item.ID)) then
	if not (not queuedItem.Item and data.EclipsedHeldItem and data.EclipsedHeldItem:IsCollectible()) then return end
	local itemId = data.EclipsedHeldItem.ID
	local touched = data.EclipsedHeldItem.Touched
	data.EclipsedHeldItem = nil
	if datatables.QueueItemsCheck[itemId] and not touched then
		local rng = player:GetCollectibleRNG(itemId)
		if itemId == enums.Items.GravityBombs then
			player:AddGigaBombs(datatables.GravityBombs.GigaBombs)
		elseif itemId == enums.Items.MidasCurse then
			player:AddGoldenHearts(3)
		elseif itemId == enums.Items.RubberDuck then
			data.DuckCurrentLuck = data.DuckCurrentLuck or 0
			data.DuckCurrentLuck = data.DuckCurrentLuck + datatables.RubberDuck.MaxLuck
			functions.EvaluateDuckLuck(player, data.DuckCurrentLuck)
		elseif itemId == CollectibleType.COLLECTIBLE_BIRTHRIGHT then
			if player:GetPlayerType() == enums.Characters.Nadab then
				functions.SpawnOptionItems(ItemPoolType.POOL_BOMB_BUM, rng:RandomInt(Random())+1, player.Position)
			elseif player:GetPlayerType() == enums.Characters.Abihu then
				player:SetFullHearts()
			elseif player:GetPlayerType() == enums.Characters.Unbidden then
				--local broken = player:GetBrokenHearts()
				--print(player:GetBrokenHearts())
				if player:GetBrokenHearts() > 0 then
					player:AddBrokenHearts(-1)
					player:AddSoulHearts(2)
				end
			elseif player:GetPlayerType() == enums.Characters.UnbiddenB then
				data.UnbiddenResetGameChance = data.UnbiddenResetGameChance or 100
				if data.UnbiddenResetGameChance < 100 then data.UnbiddenResetGameChance = 100 end
				if player:GetActiveItem(ActiveSlot.SLOT_POCKET) == enums.Items.Threshold then
					player:SetActiveCharge(2*Isaac.GetItemConfig():GetCollectible(enums.Items.Threshold).MaxCharges)
				end
			end
		end
	end
end

function functions.AddItemFromWisp(player, kill, stop)
		--- add actual item from item wisp
		stop = stop or false
		local itemWisps = Isaac.FindInRadius(player.Position, datatables.UnbiddenData.RadiusWisp, EntityPartition.FAMILIAR)
		if #itemWisps > 0 then
			for _, witem in pairs(itemWisps) do
				if witem.Variant == FamiliarVariant.ITEM_WISP and not functions.CheckItemType(witem.SubType) then -- and not witem:GetData().MongoWisp then
					player:GetData().WispedQueue = player:GetData().WispedQueue or {}
					table.insert(player:GetData().WispedQueue, {witem, kill})
					if stop then
						return witem.SubType
					end
				end
			end
		end
		return
	end

--[[
function functions.AddItemFromWisp(player, kill, stop)
	--- add actual item from item wisp
	stop = stop or false
	local itemWisps = Isaac.FindInRadius(player.Position, datatables.UnbiddenData.RadiusWisp, EntityPartition.FAMILIAR)
	if #itemWisps > 0 then
		for _, witem in pairs(itemWisps) do
			if witem.Variant == FamiliarVariant.ITEM_WISP then -- and not witem:GetData().MongoWisp then
				player:GetData().WispedQueue = player:GetData().WispedQueue or {}
				table.insert(player:GetData().WispedQueue, {witem, kill})
				if stop then
					return witem.SubType
				end
			end
		end
	end
	return
end
--]]

function functions.MongoHiddenWisp(tear)
	--- hidden wisp effect
	if tear.SpawnerEntity and tear.SpawnerEntity.Type == EntityType.ENTITY_FAMILIAR and tear.SpawnerEntity.Variant == FamiliarVariant.ITEM_WISP then
		if tear.SpawnerEntity:GetData().MongoWisp then
			tear:Remove()
			return true
		end
	end
end

--- Written by Zamiel, technique created by im_tem
function functions.SetBlindfold(player, enabled) --modifyCostume
	---Blindfold
	local character = player:GetPlayerType()
	local challenge = Isaac.GetChallenge()
	if enabled then
		game.Challenge = Challenge.CHALLENGE_SOLAR_SYSTEM -- This challenge has a blindfold
		player:ChangePlayerType(character)
		game.Challenge = challenge
		player:TryRemoveNullCostume(NullItemID.ID_BLINDFOLD)
	else
		game.Challenge = Challenge.CHALLENGE_NULL
		player:ChangePlayerType(character)
		game.Challenge = challenge
		player:TryRemoveNullCostume(NullItemID.ID_BLINDFOLD)
	end
end

function functions.GetBombRadiusFromDamage(damage)
	--- get bomb damage radius
	if damage >= 175.0  then
		return 110.0
	else
		if damage < 100 then
			return 50.0
		elseif damage <= 140.0 then
			return 75.0
		else
			return 90.0
		end
	end
end

function functions.MyGridSpawn(spawner, radius, entityType, entityVariant, forced)
	--- spawn grid in 3x3
	local room = game:GetRoom()
	local nulPos = room:GetGridPosition(room:GetGridIndex(spawner.Position))
	forced = forced or false
	Isaac.GridSpawn(entityType, entityVariant, Vector(nulPos.X, nulPos.Y+radius), forced) --up
	Isaac.GridSpawn(entityType, entityVariant, Vector(nulPos.X, nulPos.Y-radius), forced) --down
	Isaac.GridSpawn(entityType, entityVariant, Vector(nulPos.X+radius, nulPos.Y), forced) --right
	Isaac.GridSpawn(entityType, entityVariant, Vector(nulPos.X-radius, nulPos.Y), forced) --left
	Isaac.GridSpawn(entityType, entityVariant, Vector(nulPos.X+radius, nulPos.Y+radius), forced) -- up left
	Isaac.GridSpawn(entityType, entityVariant, Vector(nulPos.X+radius, nulPos.Y-radius), forced) -- down left
	Isaac.GridSpawn(entityType, entityVariant, Vector(nulPos.X-radius, nulPos.Y+radius), forced) -- up right
	Isaac.GridSpawn(entityType, entityVariant, Vector(nulPos.X-radius, nulPos.Y-radius), forced) -- down right
end

function functions.CircleSpawn(spawner, radius, velocity, entityType, entityVariant, entitySubtype)
	--- spawn entity in circle
	local point = radius*math.cos(math.rad(45)) -- 45 degree angle
	Isaac.Spawn(entityType, entityVariant, entitySubtype, Vector(spawner.Position.X, spawner.Position.Y+radius), Vector(0, velocity), spawner).Visible = true --up
	Isaac.Spawn(entityType, entityVariant, entitySubtype, Vector(spawner.Position.X, spawner.Position.Y-radius), Vector(0, -velocity), spawner) --down
	Isaac.Spawn(entityType, entityVariant, entitySubtype, Vector(spawner.Position.X+radius, spawner.Position.Y), Vector(velocity, 0), spawner) --right
	Isaac.Spawn(entityType, entityVariant, entitySubtype, Vector(spawner.Position.X-radius, spawner.Position.Y), Vector(-velocity, 0), spawner) --left
	Isaac.Spawn(entityType, entityVariant, entitySubtype, Vector(spawner.Position.X+point, spawner.Position.Y+point), Vector(velocity, velocity), spawner) -- up left
	Isaac.Spawn(entityType, entityVariant, entitySubtype, Vector(spawner.Position.X+point, spawner.Position.Y-point), Vector(velocity, -velocity), spawner) -- down left
	Isaac.Spawn(entityType, entityVariant, entitySubtype, Vector(spawner.Position.X-point, spawner.Position.Y+point), Vector(-velocity, velocity), spawner) -- up right
	Isaac.Spawn(entityType, entityVariant, entitySubtype, Vector(spawner.Position.X-point, spawner.Position.Y-point), Vector(-velocity, -velocity), spawner) -- down right
end

function functions.SquareSpawn(spawner, radius, velocity, entityType, entityVariant, entitySubtype)
	--- spawn entity in 3x3
	local point = radius
	Isaac.Spawn(entityType, entityVariant, entitySubtype, Vector(spawner.Position.X, spawner.Position.Y+radius), Vector(0, velocity), spawner).Visible = true --up
	Isaac.Spawn(entityType, entityVariant, entitySubtype, Vector(spawner.Position.X, spawner.Position.Y-radius), Vector(0, -velocity), spawner) --down
	Isaac.Spawn(entityType, entityVariant, entitySubtype, Vector(spawner.Position.X+radius, spawner.Position.Y), Vector(velocity, 0), spawner) --right
	Isaac.Spawn(entityType, entityVariant, entitySubtype, Vector(spawner.Position.X-radius, spawner.Position.Y), Vector(-velocity, 0), spawner) --left
	Isaac.Spawn(entityType, entityVariant, entitySubtype, Vector(spawner.Position.X+point, spawner.Position.Y+point), Vector(velocity, velocity), spawner) -- up left
	Isaac.Spawn(entityType, entityVariant, entitySubtype, Vector(spawner.Position.X+point, spawner.Position.Y-point), Vector(velocity, -velocity), spawner) -- down left
	Isaac.Spawn(entityType, entityVariant, entitySubtype, Vector(spawner.Position.X-point, spawner.Position.Y+point), Vector(-velocity, velocity), spawner) -- up right
	Isaac.Spawn(entityType, entityVariant, entitySubtype, Vector(spawner.Position.X-point, spawner.Position.Y-point), Vector(-velocity, -velocity), spawner) -- down right
end

---Mirror Bombs
function functions.FlipMirrorPos(pos)
	--- reflected position for given entity
	local room = game:GetRoom()
	local roomCenter = room:GetCenterPos()
	local newX = 0
	local newY = 0
	local offset = 0 -- I know that I can just leave it as "local offset" with nil value
	-- L shaped rooms
	if room:IsLShapedRoom() then
		roomCenter = Vector(580,420) -- get 2x2 room center
	end
	-- X
	if pos.X < roomCenter.X then -- dimension X
		offset = roomCenter.X - pos.X
		newX = roomCenter.X + offset
	else
		offset = pos.X - roomCenter.X
		newX = roomCenter.X - offset
	end
	-- Y
	if pos.Y < roomCenter.Y then -- dimension Y
		offset = roomCenter.Y - pos.Y
		newY = roomCenter.Y + offset
	else
		offset = pos.Y - roomCenter.Y
		newY = roomCenter.Y - offset
	end
	return Vector(newX, newY)
end

local LockedItems = {
	[enums.Items.DiceBombs] = {1, "isaac"},
	[enums.Items.DeadBombs] = { 1, "bbaby"},
	[enums.Items.GravityBombs] = { 1, "satan"},
	[enums.Items.FrostyBombs] = { 1, "lamb"},
	[enums.Items.Pyrophilia] = { 1, "greed"},
	[enums.Items.BatteryBombs] = { 2, "greed"},
	[enums.Items.CompoBombs] = { 1, "beast"},
	[enums.Items.MirrorBombs] = { 1, "deli"},
}

-- spawn item in position with option index
function functions.SpawnMyItem(poolType, position, optionIndex)
	--- spawn item in position with option index
	optionIndex = optionIndex or 0
	local newItem = itemPool:GetCollectible(poolType)
	
	local savetable = functions.modDataLoad()
	local modCompletion = savetable.CompletionMarks
	-- if all marks isn't completed
	if modCompletion.Nadab.all < 2 and LockedItems[newItem] then
		local checkvalue = LockedItems[newItem][1] -- get completion mark value
		local mark = LockedItems[newItem][2] -- get mark names -> isaac, bbaby, satan, lamb etc.
		if modCompletion.Nadab[mark] < checkvalue then -- check value: if savedValue < checkvalue then
			itemPool:RemoveCollectible(newItem)
			newItem = itemPool:GetCollectible(ItemPoolType.POOL_BOMB_BUM, true)
		end
	end
	local item = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, newItem, position, Vector.Zero, nil):ToPickup()
	item.OptionsPickupIndex = optionIndex
end
-- set spawn 3 items with option index
function functions.SpawnOptionItems(itemPoolType, optionIndex, position)
	--- spawn 3 items
	position = position or game:GetRoom():GetCenterPos()
	local leftPosition = Isaac.GetFreeNearPosition(Vector(position.X-80,position.Y), 40) -- rework to get room center?
	local centPosition = Isaac.GetFreeNearPosition(position, 40)
	local righPosition = Isaac.GetFreeNearPosition(Vector(position.X+80,position.Y), 40) -- cause grid size is 40x40
	functions.SpawnMyItem(itemPoolType, leftPosition, optionIndex)
	functions.SpawnMyItem(itemPoolType, centPosition, optionIndex)
	functions.SpawnMyItem(itemPoolType, righPosition, optionIndex)
end

function functions.PenanceShootLaser(angle, timeout, pos, ppl)
	--- penance
	local laser = Isaac.Spawn(EntityType.ENTITY_LASER, datatables.Penance.LaserVariant, 0, pos, Vector.Zero, ppl):ToLaser()
	laser.Color = datatables.Penance.Color
	laser:SetTimeout(timeout)
	laser.Angle = angle
end

function functions.AdrenalineManager(player, redHearts, num)
	--- turn your hearts into batteries
	local j = 0
	while redHearts > num do
		functions.DebugSpawn(PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_NORMAL, player.Position)
		redHearts = redHearts-2
		j = j+2 -- for each 2 hearts
	end
	player:AddHearts(-j)
end

function functions.DeadEggEffect(player, pos, timeout)
	--- spawn dead bird
	if player:HasTrinket(enums.Trinkets.DeadEgg) then
		local numTrinket = player:GetTrinketMultiplier(enums.Trinkets.DeadEgg)
		for _ = 1, numTrinket do
			local birdy = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DEAD_BIRD, 0, pos, Vector.Zero, nil):ToEffect()
			birdy:SetColor(Color(0,0,0,1,0,0,0),timeout,1, false, false) -- set black
			birdy:SetTimeout(timeout)
			birdy.SpriteScale = Vector.One *0.7
			birdy:GetData().DeadEgg = true
		end
	end
end

function functions.CheckJudasBirthright(ppl)
	--- check if player is judas and has birthright
	ppl = ppl:ToPlayer()
	local pplType = ppl:GetPlayerType()
	if not (pplType == PlayerType.PLAYER_JUDAS or pplType == PlayerType.PLAYER_BLACKJUDAS) then return false end
	--if not ppl:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL) then print('2') return false end
	if not ppl:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then return false end
	return true
end


function functions.BeggarWasBombed(beggar, dontKill)
	--- beggar bombing
	local level = game:GetLevel()
	local explosions = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.BOMB_EXPLOSION)
	local mamaMega = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.MAMA_MEGA_EXPLOSION)
	dontKill = dontKill or false
	if #mamaMega > 0 then
		if not dontKill then
			beggar:Kill()
			beggar:Remove()
		end
		level:SetStateFlag(LevelStateFlag.STATE_BUM_KILLED, true)
		return true
	elseif #explosions > 0 then
		for _, explos in pairs(explosions) do
			local frame = explos:GetSprite():GetFrame()
			if frame < 3 then
				if explos.Position:Distance(beggar.Position) <= 90 * explos.SpriteScale.X then
					if not dontKill then
						beggar:Kill()
						beggar:Remove()
					end
					level:SetStateFlag(LevelStateFlag.STATE_BUM_KILLED, true)
					return true
				end
			end
		end
	end
	return false
end


function functions.BlackBookEffects(player, entity, rng)
	--- black book
	if entity:IsActiveEnemy() and entity:IsVulnerableEnemy() and not entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
		local index = rng:RandomInt(#datatables.BlackBook.EffectFlags)+1
		if index == 1 then
			entity:AddFreeze(EntityRef(player), datatables.BlackBook.EffectFlags[index][3])
		elseif index == 2 then -- poison
			entity:AddPoison(EntityRef(player), datatables.BlackBook.EffectFlags[index][3], 2*player.Damage)
		elseif index == 3 then -- slow
			entity:AddSlowing(EntityRef(player), datatables.BlackBook.EffectFlags[index][3], 0.5, datatables.BlackBook.EffectFlags[index][2])
		elseif index == 4 then -- charm
			entity:AddCharmed(EntityRef(player), datatables.BlackBook.EffectFlags[index][3])
		elseif index == 5 then -- confusion
			entity:AddConfusion(EntityRef(player), datatables.BlackBook.EffectFlags[index][3], false)
		elseif index == 6 then -- midas freeze
			entity:AddMidasFreeze(EntityRef(player), datatables.BlackBook.EffectFlags[index][3])
		elseif index == 7 then -- fear
			entity:AddFear(EntityRef(player),datatables.BlackBook.EffectFlags[index][3])
		elseif index == 8 then -- burn
			entity:AddBurn(EntityRef(player), datatables.BlackBook.EffectFlags[index][3], 2*player.Damage)
		elseif index == 9 then -- shrink
			entity:AddShrink(EntityRef(player), datatables.BlackBook.EffectFlags[index][3])
		elseif index == 10 then -- bleed
			entity:AddEntityFlags(datatables.BlackBook.EffectFlags[index][1])
			entity:SetColor(datatables.BlackBook.EffectFlags[index][2], datatables.BlackBook.EffectFlags[index][3], 1, false, false)
			entity:GetData().BackStabbed = datatables.BlackBook.EffectFlags[index][3]
		elseif index == 11 then -- ice
			entity:AddEntityFlags(datatables.BlackBook.EffectFlags[index][1])
			entity:SetColor(datatables.BlackBook.EffectFlags[index][2], datatables.BlackBook.EffectFlags[index][3], 1, false, false)
			entity:GetData().Frosted =datatables.BlackBook.EffectFlags[index][3]
		elseif index == 12 then -- magnet
			entity:AddEntityFlags(datatables.BlackBook.EffectFlags[index][1])
			entity:SetColor(datatables.BlackBook.EffectFlags[index][2], datatables.BlackBook.EffectFlags[index][3], 1, false, false)
			entity:GetData().Magnetized = datatables.BlackBook.EffectFlags[index][3]
		elseif index == 13 then -- baited
			entity:AddEntityFlags(datatables.BlackBook.EffectFlags[index][1])
			entity:SetColor(datatables.BlackBook.EffectFlags[index][2], datatables.BlackBook.EffectFlags[index][3], 1, false, false)
			entity:GetData().BaitedTomato = datatables.BlackBook.EffectFlags[index][3]
		end
	end
end

function functions.ExplodingKittenCurse(player, card)
	--- exploding kittens
	local room = game:GetRoom()
	local rng = player:GetCardRNG(card)
	local randChance = rng:RandomFloat()

	if randChance <= 0.2 then
		player:UsePill(PillEffect.PILLEFFECT_HORF, PillColor.PILL_GIANT_FLAG, datatables.MyUseFlags_Gene)
	elseif randChance <= 0.4 then
		player:UsePill(PillEffect.PILLEFFECT_EXPLOSIVE_DIARRHEA, 0, datatables.MyUseFlags_Gene)
	elseif randChance <= 0.6 then
		for _ = 1, 3 do
			local randPos = room:GetRandomPosition(0)
			--randPos = room:FindFreePickupSpawnPosition(randPos)
			local epic = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ROCKET, 0, randPos, Vector.Zero, player)
			if epic then
				epic:GetData().KittenRocket = true
				epic.Visible = false
				epic:ToEffect():SetTimeout(40)
			end
		end
	elseif randChance <= 0.8 then
		for _ = 1, 3 do
			local randPos = room:GetRandomPosition(0)
			randPos = room:FindFreePickupSpawnPosition(randPos)
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, randPos, Vector.Zero, nil)
			Isaac.Spawn(EntityType.ENTITY_BOMB, BombVariant.BOMB_GIGA, 0, randPos, Vector.Zero, player)
		end
	else --if randChance <= 0.9 then
		for _ = 1, 3 do
			local randPos = room:GetRandomPosition(0)
			randPos = room:FindFreePickupSpawnPosition(randPos)
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, randPos, Vector.Zero, nil)
			Isaac.Spawn(EntityType.ENTITY_BOMB, BombVariant.BOMB_GOLDENTROLL, 0, randPos, Vector.Zero, player)
		end
	end
end

function functions.HeartTranslpantFunc(player)
	--- heart transplant
	local data = player:GetData()
	data.HeartTransplantDelay = nil
	player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_SPEED)
	player:EvaluateItems()
end

function functions.SellItems(pickup, player)
	--- price of items to sell
	local num = 0
	if pickup:IsShopItem() then return 0 end
	pickup = pickup:ToPickup()
	if pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE then
		if pickup.SubType ~= 0 then num = datatables.KeeperMirror.Collectible end
		if pickup.SubType == CollectibleType.COLLECTIBLE_R_KEY then num = datatables.KeeperMirror.RKey end
	elseif pickup.Variant == PickupVariant.PICKUP_HEART then
		if pickup.SubType == HeartSubType.HEART_GOLDEN then
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_GOLDEN, pickup.Position, Vector.Zero, player)
			return -1
		end
		num = datatables.KeeperMirror.NormalPickup
		if pickup.SubType == HeartSubType.HEART_FULL then num = datatables.KeeperMirror.RedHeart end
		if pickup.SubType == HeartSubType.HEART_HALF then num = datatables.KeeperMirror.HalfHeart end
		if pickup.SubType == HeartSubType.HEART_DOUBLEPACK then num = datatables.KeeperMirror.DoubleHeart end
		if pickup.SubType == HeartSubType.HEART_HALF_SOUL then num = datatables.KeeperMirror.HalfHeart end
	elseif pickup.Variant == PickupVariant.PICKUP_KEY then
		if pickup.SubType == KeySubType.KEY_GOLDEN then
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_GOLDEN, pickup.Position, Vector.Zero, player)
			return -1
		end
		num = datatables.KeeperMirror.NormalPickup
		if pickup.SubType == KeySubType.KEY_DOUBLEPACK then num = datatables.KeeperMirror.DoublePickup end
		if pickup.SubType == KeySubType.KEY_CHARGED then num = datatables.KeeperMirror.NormalPickup end
	elseif pickup.Variant == PickupVariant.PICKUP_BOMB then
		if pickup.SubType ~= BombSubType.BOMB_TROLL or pickup.SubType ~= BombSubType.BOMB_SUPERTROLL or pickup.SubType ~= BombSubType.BOMB_GOLDENTROLL then
			if pickup.SubType == BombSubType.BOMB_GOLDEN then
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_GOLDEN, pickup.Position, Vector.Zero, player)
				return -1
			end
			num = datatables.KeeperMirror.NormalPickup
			if pickup.SubType == BombSubType.BOMB_DOUBLEPACK or pickup.SubType == BombSubType.BOMB_GIGA then
				num = datatables.KeeperMirror.DoublePickup
			end
		end
	elseif pickup.Variant == PickupVariant.PICKUP_THROWABLEBOMB or pickup.Variant == PickupVariant.PICKUP_POOP then
		num = datatables.KeeperMirror.NormalPickup
	elseif pickup.Variant == PickupVariant.PICKUP_GRAB_BAG then
		num = datatables.KeeperMirror.GrabBag
	elseif pickup.Variant == PickupVariant.PICKUP_PILL then
		if pickup.SubType == PillColor.PILL_GOLD then Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_GOLDEN, pickup.Position, Vector.Zero, player)
			return -1
		end
		num = datatables.KeeperMirror.NormalPickup
		if pickup.SubType >= PillColor.PILL_GIANT_FLAG then num = datatables.KeeperMirror.GiantPill end
	elseif pickup.Variant == PickupVariant.PICKUP_LIL_BATTERY then
		if pickup.SubType == BatterySubType.BATTERY_GOLDEN then
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_GOLDEN, pickup.Position, Vector.Zero, player)
			return -1
		end
		num = datatables.KeeperMirror.NormalPickup
		if pickup.SubType >= BatterySubType.BATTERY_MICRO then num = datatables.KeeperMirror.MicroBattery end
		if pickup.SubType >= BatterySubType.BATTERY_MEGA then num = datatables.KeeperMirror.MegaBattery end
	elseif pickup.Variant == PickupVariant.PICKUP_TAROTCARD then
		num = datatables.KeeperMirror.NormalPickup
	elseif pickup.Variant == PickupVariant.PICKUP_TRINKET then
		if pickup.SubType >= TrinketType.TRINKET_GOLDEN_FLAG then
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_GOLDEN, pickup.Position, Vector.Zero, player)
			return -1
		end
		num = datatables.KeeperMirror.NormalPickup
	end
	return num
end

function functions.RedBombReplace(bomb)
	--- replace bomb by throwable bomb
	bomb:Remove()
	if bomb.Variant == BombVariant.BOMB_GIGA then
		for _ = 1, datatables.RedScissors.GigaBombsSplitNum do
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_THROWABLEBOMB, 0, bomb.Position, RandomVector()*5, nil)
		end
	else
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_THROWABLEBOMB, 0, bomb.Position, bomb.Velocity, nil)
	end
	local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, bomb.Position, Vector.Zero, nil)
	effect:SetColor(datatables.RedColor, 50, 1, false, false)
end

function functions.LililithReset()
	--- reset lililith
	if #Isaac.FindByType(EntityType.ENTITY_FAMILIAR, datatables.Lililith.Variant) > 0 then
		for _, fam in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, datatables.Lililith.Variant)) do
			fam = fam:ToFamiliar()
			local player = fam.Player:ToPlayer()
			local data = player:GetData()
			local tempEffects = player:GetEffects()
			if data.LililithDemonSpawn then
				for i = 1, #data.LililithDemonSpawn do
					if data.LililithDemonSpawn[i][3] > 0 then
						tempEffects:AddCollectibleEffect(data.LililithDemonSpawn[i][1], false, data.LililithDemonSpawn[i][3])
					end
				end
			end
		end
	end
end

function functions.SetBombEXCountdown(player, bomb)
	--- set bomb countdown
	bomb:SetExplosionCountdown(datatables.CompoBombs.BasicCountdown)
	if player:HasTrinket(TrinketType.TRINKET_SHORT_FUSE) then
		bomb:SetExplosionCountdown(datatables.CompoBombs.ShortCountdown)
	elseif bomb.Parent:ToBomb().IsFetus then
		bomb:SetExplosionCountdown(datatables.CompoBombs.FetusCountdown)
	end
	if bomb.Parent:ToBomb().IsFetus and player:HasTrinket(TrinketType.TRINKET_SHORT_FUSE) then
		bomb:SetExplosionCountdown(datatables.CompoBombs.FetusCountdown/2) -- short fuse shortens countdown to half
	end
end

function functions.GetNearestEnemy(basePos, distance)
	--- get near enemy's position, else return basePos position
	local finalPosition = basePos
	distance = distance or 5000
	local nearest = distance
	local enemies = Isaac.FindInRadius(basePos, distance, EntityPartition.ENEMY)
	if #enemies > 0 then
		for _, enemy in pairs(enemies) do
			if not enemy:HasEntityFlags(EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_CHARM) and enemy:IsVulnerableEnemy() and enemy:IsActiveEnemy() and basePos:Distance(enemy.Position) < nearest then
                nearest = basePos:Distance(enemy.Position)
				finalPosition = enemy.Position
            end
		end
	end
	return finalPosition
end

function functions.RerollTMTRAINER(player, item)
	--- reroll to glitched item
	player = player:ToPlayer()
	player:AddCollectible(CollectibleType.COLLECTIBLE_TMTRAINER)
	player:UseActiveItem(CollectibleType.COLLECTIBLE_D6, datatables.MyUseFlags_Gene) -- D6 effect
	player:RemoveCollectible(CollectibleType.COLLECTIBLE_TMTRAINER) -- remove tmtrainer
	if item then
		player:AnimateCollectible(item, "UseItem")
	end
end

function functions.BlastDamage(radius, damage, knockback, player) -- player:GetCollectibleRNG(enums.Items.BlackKnight)
	--- crush when land
	local room = game:GetRoom()
	for _, entity in pairs(Isaac.GetRoomEntities()) do
		if entity.Position:Distance(player.Position) <= radius then
			if entity:IsVulnerableEnemy() and entity:IsActiveEnemy() then
				entity:TakeDamage(damage, DamageFlag.DAMAGE_EXPLOSION | DamageFlag.DAMAGE_CRUSH, EntityRef(player), 0)
				entity.Velocity = (entity.Position - player.Position):Resized(knockback)
			elseif entity.Type == EntityType.ENTITY_FIREPLACE and entity.Variant ~= 4 then -- 4 is white fireplace
				entity:Die()
			elseif entity.Type == EntityType.ENTITY_MOVABLE_TNT then
				entity:Die()
			elseif ((entity.Type == EntityType.ENTITY_FAMILIAR and entity.Variant == FamiliarVariant.CUBE_BABY) or (entity.Type == EntityType.ENTITY_BOMB)) then
				entity.Velocity = (entity.Position - player.Position):Resized(knockback)
			elseif (entity.Type == EntityType.ENTITY_SHOPKEEPER and not entity:GetData().EID_Pathfinder) or datatables.BlackKnight.StonEnemies[entity.Type] then
				entity:Kill()
			end
		end
	end
	for gridIndex = 1, room:GetGridSize() do
		if room:GetGridEntity(gridIndex) then
			local grid = room:GetGridEntity(gridIndex)
			if (player.Position - grid.Position):Length() <= radius then
				if grid.Desc.Type ~= GridEntityType.GRID_DOOR then
					grid:Destroy()
				else
					if grid.Desc.Variant ~= GridEntityType.GRID_DECORATION or grid.Desc.State ~= 1 then
						grid:Destroy()
					end
				end
			end
		end
	end
end

function functions.MewGenManager(player)
	local data = player:GetData()
	data.MewGenTimer = data.MewGenTimer or game:GetFrameCount()
	data.CheckTimer = data.CheckTimer or datatables.MewGen.ActivationTimer
	if player:GetFireDirection() == Direction.NO_DIRECTION then
		if game:GetFrameCount() - data.MewGenTimer >= data.CheckTimer then --datatables.MewGen.ActivationTimer
			data.MewGenTimer = game:GetFrameCount()
			player:UseActiveItem(CollectibleType.COLLECTIBLE_TELEKINESIS, datatables.MyUseFlags_Gene)
			data.CheckTimer = datatables.MewGen.RechargeTimer
		end
	else
		data.MewGenTimer = game:GetFrameCount()
		data.CheckTimer = datatables.MewGen.ActivationTimer
	end
end

---Red Pill
function functions.RedPillManager(player, newDamage, wavyNum)
	local data = player:GetData()
	game:ShowHallucination(5, BackdropType.DICE)
	if sfx:IsPlaying(SoundEffect.SOUND_DEATH_CARD) then
		sfx:Stop(SoundEffect.SOUND_DEATH_CARD)
	end
	--reset DamageDown
	data.RedPillDamageDown = datatables.RedPills.DamageDown
	--wavy cap effect
	for _ = 1, wavyNum do
		player:UseActiveItem(CollectibleType.COLLECTIBLE_WAVY_CAP, datatables.MyUseFlags_Gene)
	end
	if sfx:IsPlaying(SoundEffect.SOUND_VAMP_GULP) then
		sfx:Stop(SoundEffect.SOUND_VAMP_GULP)
	end
	data.RedPillDamageUp = data.RedPillDamageUp or 0
	data.RedPillDamageUp = data.RedPillDamageUp + newDamage
	player:AddCacheFlags(CacheFlag.CACHE_DAMAGE) -- | CacheFlag.CACHE_FIREDELAY)
	player:EvaluateItems()
end

---Midas Curse
function functions.GoldenGrid(rng)
	--- turn grid into golden (poop n' rocks)
	local room = game:GetRoom()
	for i=1, room:GetGridSize() do
		local grid = room:GetGridEntity(i)
		if grid then
			if grid:ToPoop() then  -- turn all poops
				if grid:GetType() == GridEntityType.GRID_POOP and grid:GetVariant() ~= 3 and grid.State == 0 then
					grid:SetVariant(3) -- 3 is golden poop
					grid:Init(rng:RandomInt(Random())+1)
					grid:PostInit()
					grid:Update()
				end
			end
		end
	end
end
function functions.TurnPickupsGold(pickup) -- midas
	--- morph pickup into their golden versions
	local isChest = false
	local newSubType = pickup.SubType
	if pickup.Variant == PickupVariant.PICKUP_BOMB then
		if pickup.SubType ~= BombSubType.BOMB_GOLDENTROLL and pickup.SubType ~= BombSubType.BOMB_GOLDEN then
			if pickup.SubType == BombSubType.BOMB_TROLL or pickup.SubType == BombSubType.BOMB_SUPERTROLL then
				newSubType = BombSubType.BOMB_GOLDENTROLL
			else
				newSubType = BombSubType.BOMB_GOLDEN
			end
		end
	elseif pickup.Variant == PickupVariant.PICKUP_HEART and pickup.SubType ~= HeartSubType.HEART_GOLDEN then
		newSubType = HeartSubType.HEART_GOLDEN
	elseif pickup.Variant == PickupVariant.PICKUP_COIN and pickup.SubType ~= CoinSubType.COIN_GOLDEN then
		newSubType = CoinSubType.COIN_GOLDEN
	elseif pickup.Variant == PickupVariant.PICKUP_KEY and pickup.SubType ~= KeySubType.KEY_GOLDEN then
		newSubType = KeySubType.KEY_GOLDEN
	elseif pickup.Variant == PickupVariant.PICKUP_CHEST or pickup.Variant == PickupVariant.PICKUP_BOMBCHEST or pickup.Variant == PickupVariant.PICKUP_SPIKEDCHEST or pickup.Variant == PickupVariant.PICKUP_ETERNALCHEST or pickup.Variant == PickupVariant.PICKUP_MIMICCHEST or pickup.Variant == PickupVariant.PICKUP_OLDCHEST or pickup.Variant == PickupVariant.PICKUP_WOODENCHEST or pickup.Variant == PickupVariant.PICKUP_HAUNTEDCHEST or pickup.Variant == PickupVariant.PICKUP_REDCHEST then
		if pickup.SubType == 1 then
			isChest = PickupVariant.PICKUP_LOCKEDCHEST
		end
	elseif pickup.Variant == PickupVariant.PICKUP_PILL and pickup.SubType ~= PillColor.PILL_GOLD then
		newSubType = PillColor.PILL_GOLD
	elseif pickup.Variant == PickupVariant.PICKUP_LIL_BATTERY and pickup.SubType ~= BatterySubType.BATTERY_GOLDEN then
		newSubType = BatterySubType.BATTERY_GOLDEN
	elseif pickup.Variant == PickupVariant.PICKUP_TRINKET and pickup.SubType < 32768 then -- TrinketType.TRINKET_GOLDEN_FLAG
		newSubType = pickup.SubType + 32768
	end
	if newSubType ~= pickup.SubType  then
		pickup:ToPickup():Morph(pickup.Type, pickup.Variant, newSubType, true)
	elseif isChest then
		pickup:ToPickup():Morph(pickup.Type, isChest, 0, true)
	end
end

---Red Button
function functions.RemoveRedButton(room)
	--- remove pressure plate spawned by red button
	for gridIndex = 1, room:GetGridSize() do -- get room size
		local grid = room:GetGridEntity(gridIndex)
		if grid then -- check if there is any grid
			if grid.VarData == datatables.RedButton.VarData then -- check if button is spawned by red button
				room:RemoveGridEntity(gridIndex, 0, false) -- remove it
				grid:Update()
				local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, grid.Position, Vector.Zero, nil)
				effect:SetColor(datatables.RedColor, 50, 1, false, false) -- spawn poof effect
			end
		end
	end
end
function functions.SpawnButton(player, room)
	--- spawn new pressure plate
	local pos -- new position for button
	local subtype = 4 -- empty button, do nothing
	local spawned = false -- check for button spawn
	local rng = player:GetCollectibleRNG(enums.Items.RedButton) -- get rng
	local randNum = rng:RandomFloat()  --RandomInt(100) --+ player.Luck -- get random int to decide what type of button to spawn
	local killChance = randNum + player.Luck/100
	if killChance < 0.02 then killChance = 0.02 end
	if killChance >= datatables.RedButton.KillButtonChance then
		subtype = 9 -- killer button
	elseif randNum >= datatables.RedButton.EventButtonChance then
		subtype = 1 -- event button (spawn monsters, spawn items and etc.)
	end
	while not spawned do  -- don't spawn button under player -- possible bug: can spawns button under player when entering room
		pos = Isaac.GetFreeNearPosition(Isaac.GetRandomPosition(), 0.0) -- get random position
		spawned = true
		if pos == player.Position or room:GetGridEntityFromPos(pos) ~= nil then -- if button position is not player position
			spawned = false
		end
	end
	local button = Isaac.GridSpawn(GridEntityType.GRID_PRESSURE_PLATE, subtype, pos, false) -- spawn new button
	if button ~= nil then -- sometimes it didn't spawn
		button.VarData = datatables.RedButton.VarData
		local mySprite = button:GetSprite()  -- replace sprite to red button
		mySprite:ReplaceSpritesheet(0, datatables.RedButton.SpritePath)
		mySprite:LoadGraphics() -- replace sprite
	end
end
function functions.NewRoomRedButton(player, room)
	--- check for new room, spawn or remove pressure plate; (remove button when re-enter the `teleported_from_room`)
	datatables.RedButton.PressCount = 0
	if room:IsFirstVisit() then -- if room visited first time
		functions.SpawnButton(player, room) -- spawn new button
	else --if not room:IsClear() then
		functions.RemoveRedButton(room) -- remove button if there is left any button (ex: if you teleported while room is uncleared)
		functions.SpawnButton(player, room)
	end
end

---Nadab's Brain
function functions.BrainExplosion(player, fam)
	local bombDamage = 100 -- normal bomb damage
	local bombRadiusMult = 1
	if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
		bombDamage = 185 -- mr.mega bomb damage
		game:ShakeScreen(10)
	end
	local bombFlags = TearFlags.TEAR_BURN | player:GetBombFlags()
	game:BombExplosionEffects(fam.Position, bombDamage, bombFlags, Color.Default, fam, bombRadiusMult, true, false, DamageFlag.DAMAGE_EXPLOSION)
end
function functions.GetVelocity(player)
	local newVector = player:GetShootingInput()
	local newVelocity = newVector + player:GetTearMovementInheritance(newVector)
	newVelocity:Normalize()
	return newVelocity
end
function functions.NadabBrainReset(fam)
    local famData = fam:GetData()
    fam.CollisionDamage = 0
    functions.CheckForParent(fam)
    famData.IsFloating = false
    famData.isReady = false
    famData.Collided = false
end

---Gravity Bombs
function functions.InitGravityBomb(bomb, bombData)
	--- apply effect of black hole bomb
	bombData.Gravity = true
	--bomb:AddTearFlags(TearFlags.TEAR_ATTRACTOR | TearFlags.TEAR_MAGNETIZE)
	bomb:AddEntityFlags(EntityFlag.FLAG_MAGNETIZED) -- else it wouldn't attract tears
	bomb:AddTearFlags(TearFlags.TEAR_RIFT)
	local holeEffect = Isaac.Spawn(EntityType.ENTITY_EFFECT, datatables.GravityBombs.BlackHoleEffect, 0, bomb.Position, Vector.Zero, nil):ToEffect()
	local holeData = holeEffect:GetData()
	holeEffect.Parent = bomb
	holeEffect.DepthOffset = -100
	holeEffect.Color = Color(0,0,0,1,0,0,0) -- set black color
	holeData.Gravity = true
	holeData.GravityForce = datatables.GravityBombs.AttractorForce
	holeData.GravityRange = datatables.GravityBombs.AttractorRange
	holeData.GravityGridRange = datatables.GravityBombs.AttractorGridRange
end
---Frost Bombs
function functions.InitFrostyBomb(bomb, bombData)
	--- apply effect of ice cube bomb
	bombData.Frosty = true
	--bomb:AddEntityFlags(EntityFlag.FLAG_ICE)  --useless to add
	bomb:AddTearFlags(datatables.FrostyBombs.Flags)
	bombData.CreepVariant = EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL

	if bomb:HasTearFlags(TearFlags.TEAR_GLITTER_BOMB) then
		bombData.FrostyCreepColor = datatables.PinkColor
	elseif bomb:HasTearFlags(TearFlags.TEAR_BLOOD_BOMB) then
		bombData.CreepVariant = EffectVariant.PLAYER_CREEP_RED
	elseif bomb:HasTearFlags(TearFlags.TEAR_STICKY) then
		bombData.CreepVariant = EffectVariant.PLAYER_CREEP_WHITE
	elseif bomb:HasTearFlags(TearFlags.TEAR_BUTT_BOMB) then
		bombData.CreepVariant = EffectVariant.CREEP_SLIPPERY_BROWN
	elseif bomb:HasTearFlags(TearFlags.TEAR_POISON) then
		bombData.CreepVariant = EffectVariant.PLAYER_CREEP_GREEN
	end
end
---Dice Bombs
function functions.InitDiceyBomb(bomb, bombData)
	bombData.Dicey = true
	bomb:AddTearFlags(TearFlags.TEAR_REROLL_ENEMY)
end
function functions.DiceyReroll(rng, bombPos, radius)
	local pickups = Isaac.FindInRadius(bombPos, radius, EntityPartition.PICKUP)
	for _, pickup in pairs(pickups) do
		if pickup.Type ~= EntityType.ENTITY_SLOT then
			pickup = pickup:ToPickup()
			if pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE then
				if pickup.SubType ~= 0 then
					local rng = pickup:GetDropRNG()
					if rng < 0.66 then
						local pool = itemPool:GetPoolForRoom(game:GetRoom():GetType(), game:GetRoom():GetAwardSeed())
						local newItem = itemPool:GetCollectible(pool, true)
						pickup:Morph(pickup.Type, pickup.Variant, newItem, true)
						Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, nil).Color = datatables.RedColor
					else
						pickup:Remove()
						Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, nil).Color = datatables.RedColor
					end
				end
			else
				local reroll = true
				if pickup.Variant == PickupVariant.PICKUP_CHEST or pickup.Variant == PickupVariant.PICKUP_BOMBCHEST or pickup.Variant == PickupVariant.PICKUP_SPIKEDCHEST or pickup.Variant == PickupVariant.PICKUP_ETERNALCHEST or pickup.Variant == PickupVariant.PICKUP_MIMICCHEST or pickup.Variant == PickupVariant.PICKUP_OLDCHEST or pickup.Variant == PickupVariant.PICKUP_WOODENCHEST or pickup.Variant == PickupVariant.PICKUP_HAUNTEDCHEST or pickup.Variant == PickupVariant.PICKUP_REDCHEST then
					if pickup.SubType == 0 then
						reroll = false
					end
				end
				if reroll then
					local var = datatables.DiceBombs.PickupsTable [rng:RandomInt(#datatables.DiceBombs.PickupsTable )+1]
					if var == PickupVariant.PICKUP_CHEST then --and pickup.SubType == 0 then -- if chest
						var = datatables.DiceBombs.ChestsTable[rng:RandomInt(#datatables.DiceBombs.ChestsTable)+1]
					end

					pickup:Morph(pickup.Type, var, 0, true)
					Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, nil).Color = datatables.RedColor
				end
			end
		end
	end
end
---Batter Bombs
function functions.InitBatteryBomb(bomb, bombData)
	bombData.Charged = true
	bomb:AddTearFlags(TearFlags.TEAR_JACOBS)
end
function functions.ChargedBlast(bombPos, radius, damage, spawner)
	-- shoot lasers
	if spawner and spawner:ToPlayer() then
		local player = spawner:ToPlayer()
		for i = 1, 5 do
			local laser = player:FireTechLaser(bombPos, 0, RandomVector(), true, false, nil, 1):ToLaser()
			laser.Variant = LaserVariant.ELECTRIC
			laser.Color = Color(1, 1, 0.5, 1, 2, 1, 0)
			--laser:SetMaxDistance(radius)
		end
	end

	local players = Isaac.FindInRadius(bombPos, radius, EntityPartition.PLAYER)
	if #players == 0 then return end

	local init_charge = 2
	if  damage >= 175.0 then
		init_charge = 4
	elseif damage >= 100 then
		init_charge = 3
	end

	for _, player in pairs(players) do
		player = player:ToPlayer()
		local chargingEffect = false -- leave it as nil
		for slot = 0, 2 do
			if player:GetActiveItem(slot) ~= 0 then --and chargingActive then

				local activeItem = player:GetActiveItem(slot) -- active item on given slot
				local activeCharge = player:GetActiveCharge(slot) -- item charge
				local batteryCharge = player:GetBatteryCharge(slot) -- extra charge (battery item)
				local activeMaxCharge = Isaac.GetItemConfig():GetCollectible(activeItem).MaxCharges -- max charge of item
				local activeChargeType = Isaac.GetItemConfig():GetCollectible(activeItem).ChargeType -- get charge type (normal, timed, special)
				--print(activeChargeType)
				local charge = 2
				if init_charge == 4 then
					charge = activeMaxCharge *2
				elseif init_charge == 3 then
					charge = activeMaxCharge
				end
				if activeChargeType == 0 then -- if normal
					if player:NeedsCharge(slot) then
						if activeCharge >= activeMaxCharge and player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) and batteryCharge < activeMaxCharge then
							batteryCharge = batteryCharge + charge
							player:SetActiveCharge(batteryCharge+activeCharge, slot)
						else
							if activeMaxCharge - activeCharge == 1 then charge = 1 end
							activeCharge = activeCharge + charge
							player:SetActiveCharge(activeCharge, slot)
						end
						chargingEffect = slot
						break
					elseif activeCharge >= activeMaxCharge and player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) and batteryCharge < activeMaxCharge then
						batteryCharge = batteryCharge + charge
						player:SetActiveCharge(batteryCharge+activeCharge, slot)
						chargingEffect = slot
						break
					end
				elseif activeChargeType == 1 then -- if timed
					if player:NeedsCharge(slot) then
						if activeCharge >= activeMaxCharge and player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) and batteryCharge < activeMaxCharge then
							player:SetActiveCharge(2*activeMaxCharge, slot)
						else
							player:SetActiveCharge(activeMaxCharge, slot)
						end
						chargingEffect = slot
						break
					elseif activeCharge >= activeMaxCharge and player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) and batteryCharge < activeMaxCharge then
						player:SetActiveCharge(2*activeMaxCharge, slot)
						chargingEffect = slot
						break
					end
				end

			end
		end
		if chargingEffect then
			player:GetData().IvoryOilBatteryEffect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BATTERY, 0, Vector(player.Position.X, player.Position.Y-70), Vector.Zero, nil)
			sfx:Play(SoundEffect.SOUND_BATTERYCHARGE, 1, 0, false, 1, 0)
		end
	end
end
---dead bombs
function functions.InitDeadBomb(bomb, bombData)
	bombData.Bonny = true
	bomb:AddTearFlags(TearFlags.TEAR_BONE)
end
function functions.BonnyBlast(rng, bombPos, radius, player)
	local enemies = Isaac.FindInRadius(bombPos, radius, EntityPartition.ENEMY)
	if #enemies > 0 then
		for _, enemy in pairs(enemies) do
			if enemy:ToNPC() and enemy:IsVulnerableEnemy() and enemy:IsActiveEnemy() and enemy:HasMortalDamage() then
				if rng:RandomFloat() < datatables.DeadBombs.ChanceBony then
					local boneChance = rng:RandomFloat()
					local boneType = EntityType.ENTITY_REVENANT -- revenant -- 0.3
					local boneVariant = 0
					if boneChance < 0.5 then -- bony -- 0.5
						boneType = EntityType.ENTITY_BONY
					elseif boneChance < 0.65 then -- bone worm --0.15
						--boneType = EntityType.ENTITY_BONE_WORM
						boneType = EntityType.ENTITY_NEEDLE
						boneVariant = 1
					elseif boneChance < 0.77 then -- bone fly --0.12
						boneType = EntityType.ENTITY_BOOMFLY
						boneVariant = 4
					elseif boneChance < 0.87 then -- big bony --0.1
						boneType = EntityType.ENTITY_BIG_BONY
					elseif boneChance < 0.97 then -- black bony --0.1
						boneType = EntityType.ENTITY_BLACK_BONY
					end
					local boney = Isaac.Spawn(boneType, boneVariant, 0, enemy.Position, Vector.Zero, player):ToNPC()
					boney:AddCharmed(EntityRef(player), -1)
				else
					Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BONE_ORBITAL, 0, enemy.Position, Vector.Zero, player) --(enemy.Position - bombPos):Resized(5)
				end
			end
		end
	end
end

function functions.CurseIconRender()
	--- curse icons render
	local sprites = {}
	local currentCurses = functions.GetCurrentModCurses()
	if #currentCurses > 0 then
		for i, curse in pairs(currentCurses) do
			local topRight = Options.HUDOffset*Vector(24, 12)
			local gfx = enums.CurseIconsList[curse]
			local vecX = 148 + datatables.CURSE_SPRITE_SCALE * math.floor((i - 1) % datatables.CURSE_COLUMNS )
			local vecY = 12 + datatables.CURSE_SPRITE_SCALE * math.floor((i - 1) / datatables.CURSE_COLUMNS )
			local pos =  Vector(vecX , vecY) + topRight
	
			
			datatables.CurseIcons:Render(pos, Vector.Zero, Vector.Zero)
			datatables.CurseIcons:ReplaceSpritesheet(0, gfx)
			datatables.CurseIcons:LoadGraphics()
			datatables.CurseIcons:Update()
			table.insert(sprites, datatables.CurseIcons)
			sprites[i].Color = Color(1,1,1, datatables.CurseIconOpacity)
			datatables.CurseIcons:Play("Idle")
		end
	end
end

---Floppy Disk
function functions.StorePlayerItems(player)
	--- store player items in savetable; FD is full
	local savetable = functions.modDataLoad()
	local allItems = Isaac.GetItemConfig():GetCollectibles().Size - 1 -- get all items in the game + mod items
	for id = 1, allItems do
		--ItemConfig.Config.IsValidCollectible(id) do not save modded items
		if player:HasCollectible(id) then -- and not itemConfig:HasTags(ItemConfig.TAG_QUEST) then -- itemConfig:HasTags(itemConfig.Tags & ItemConfig.TAG_QUEST)
			for _ = 1, player:GetCollectibleNum(id, true) do -- store number of items player have
				table.insert(savetable.FloppyDiskItems, id)
			end
		end
	end
	functions.modDataSave(savetable)
end
function functions.ReplacePlayerItems(player) -- remove and replace items
	--- remove current items and replace them by items in savetable; FD is empty
	local savetable = functions.modDataLoad()
	local allItems = Isaac.GetItemConfig():GetCollectibles().Size - 1 -- get all items in the game + mod items
	for id = 1, allItems do
		if player:HasCollectible(id) and not functions.CheckItemTags(id, ItemConfig.TAG_QUEST) then
			for _ = 1, player:GetCollectibleNum(id, true) do -- remove number of items player have
				player:RemoveCollectible(id)
			end
		end
	end
	for _, itemID in pairs(savetable.FloppyDiskItems) do
		if itemID <= allItems then -- (I guess it can give you wrong items by stored id, if you add/remove mods after saving mod data)
			player:AddCollectible(itemID) -- give items from saved table
		else -- if saved item id is higher than current number of all items in the game
			if datatables.FloppyDisk.MissingNo then
				player:AddCollectible(CollectibleType.COLLECTIBLE_MISSING_NO) -- give you missing no...
			end
		end
	end
	savetable.FloppyDiskItems = {}
	functions.modDataSave(savetable)
end

function functions.Domino16Items(rng, pos)
	local chestTable = {50,51,52,53,54,55,56,57,58,60}
	local varTable = {10, 20, 30, 40, 41, 50, 69, 70, 90, 100, 150, 300, 350}
	local var = varTable[rng:RandomInt(#varTable)+1]
	local finalVar = var
	for _ = 1, 6 do
		if var == 50 then
			finalVar = chestTable[rng:RandomInt(#chestTable)+1]
		end
		--local item = 0
		--elseif var == 70 then
		--  subtype = itemPool:GetPillEffect(itemPool:GetPill(rng:GetSeed()))
		--elseif var == 100 then
		--	subtype = itemPool:GetCollectible(itemPool:GetLastPool())
		--elseif var == 300 then
		--  subtype = itemPool:GetCard(rng:GetSeed(), true, true, false)
		--elseif var == 350 then
		--  subtype = itemPool:GetTrinket()
		--end
		functions.DebugSpawn(finalVar, 0, Isaac.GetFreeNearPosition(pos, 40)) -- 0
	end
end

function functions.ResetVHS()
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
end

function functions.useVHS(rng)
	local level = game:GetLevel()
	local stage = level:GetStage()
	--if datatables.tableVHS then
	if level:IsAscent() then
		Isaac.ExecuteCommand("stage 13")
	elseif not game:IsGreedMode() and stage < 12 then
		local newStage = rng:RandomInt(12)+1
		if newStage <= stage then newStage = stage+1 end
		local randStageType = 1
		if newStage ~= 9 then randStageType = rng:RandomInt(#datatables.tableVHS[newStage])+1 end
		newStage = "stage " .. datatables.tableVHS[newStage][randStageType]
		datatables.tableVHS = nil
		Isaac.ExecuteCommand(newStage)
	end
	--end
	game:ShowHallucination(5, 0)
	if sfx:IsPlaying(SoundEffect.SOUND_DEATH_CARD) then
		sfx:Stop(SoundEffect.SOUND_DEATH_CARD)
	end
	sfx:Play(SoundEffect.SOUND_STATIC)
	
end

function functions.HeavensCall(room, level)
	if room:GetType() == RoomType.ROOM_DICE and functions.CheckInRange(level:GetCurrentRoomIndex(), 8500, 8510) then
		return true
	elseif room:GetType() == RoomType.ROOM_DEVIL and functions.CheckInRange(level:GetCurrentRoomDesc().Data.Variant, 85, 89 ) then
		return true
	end
	return false
end

function functions.AddHiddenWisp(player, item)
	---add hidden wisp effect
	local itemWisp = player:AddItemWisp(item, Vector.Zero, true)
	itemWisp:RemoveFromOrbit()
	itemWisp:AddEntityFlags(EntityFlag.FLAG_NO_REWARD)
	itemWisp:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	itemWisp.Visible = false
	itemWisp.Position = Vector.Zero
	itemWisp.Velocity = Vector.Zero
	itemWisp.CollisionDamage = 0
	itemWisp.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
	itemWisp.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
	itemWisp:GetData().TemporaryWisp = true
end

function functions.RemoveHiddenWisp(dataCheck)
	if dataCheck then
		local itemWisps = Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.ITEM_WISP, dataCheck)
		for _, itemWisp in pairs(itemWisps) do
			if itemWisp:GetData().TemporaryWisp then
				itemWisp:Remove()
				itemWisp:Kill()
			end
		end
		dataCheck = nil
	end
	return nil
end

function functions.SoulExplosion(spawner)
	local ghostExplosion = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ENEMY_GHOST, 2, spawner.Position, Vector.Zero, spawner):ToEffect()
	ghostExplosion.CollisionDamage = 7
	sfx:Play(SoundEffect.SOUND_DEMON_HIT)
end

function functions.UseTomeDeadSouls(player, item, counter)
	--counter = counter or Isaac.GetItemConfig():GetCollectible(item).MaxCharges
	for _ = 1, counter do
		local purgesoul = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PURGATORY, 1, player.Position, Vector.Zero, player):ToEffect()
		purgesoul:GetSprite():Play("Charge", true)
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
			player:AddWisp(item, player.Position, true)
		end
	end
	return true
end

function functions.TetrisDiceCheks(player)	
	for slot = 0, 2 do
		local item = player:GetActiveItem(slot)
		local charges = player:GetActiveCharge(slot)
		local bat_charges = player:GetBatteryCharge(slot)
		if item == enums.Items.TetrisDice_full and charges == 0 then
			player:AddCollectible(enums.Items.TetrisDice1)
		elseif datatables.TetrisDicesCheck[item] and charges >= datatables.TetrisDicesCheck[item] then
			local nextitem = datatables.TetrisDicesCheck[item]
			if nextitem < Isaac.GetItemConfig():GetCollectible(enums.Items.TetrisDice_full ).MaxCharges then
				nextitem = datatables.TetrisDices[nextitem]
				player:AddCollectible(nextitem, charges+bat_charges)
			else
				player:AddCollectible(enums.Items.TetrisDice_full, charges+bat_charges)
			end
			break
		end
	end
end

return functions