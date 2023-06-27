local mod = EclipsedMod
local game = Game()
local itemPool = game:GetItemPool()
local sfx = SFXManager()
local functions = {}
local enums = EclipsedMod.enums
local datatables = EclipsedMod.datatables

function functions.ResetModVars()
	if not mod.ModVars then mod.ModVars = {} end
	if not mod.ModVars.ForRoom then mod.ModVars.ForRoom = {} end
end

function functions.CopyDatatable(Oldtable)
	local myTable = {}
	for k,v in pairs(Oldtable) do
		myTable[k] = v
	end
	return myTable
end

function functions.ResetPlayerData(player)
	local data = player:GetData()
	if not data.eclipsed then data.eclipsed = {} end
	if not data.eclipsed.ForRoom then data.eclipsed.ForRoom = {} end
	if not data.eclipsed.ForLevel then data.eclipsed.ForLevel = {} end
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

function functions.CheckFamiliar(player, item, familiar, subtype)
	local count = functions.GetItemsCount(player, item, false)
	if count > 0 then
		subtype = subtype or 0
		local rng = RNG()
		rng:SetSeed(game:GetSeeds():GetStartSeed(), 35)
		player:CheckFamiliar(familiar, count, rng, Isaac.GetItemConfig():GetCollectible(item), subtype)
	end
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

function functions.TrinketAdd(player, newTrinket)
	--- gulp given trinket
	local t0 = player:GetTrinket(0) -- 0 - first slot
	local t1 = player:GetTrinket(1) -- 1 - second slot
	if t1 ~= 0 then player:TryRemoveTrinket(t1) end
	if t0 ~= 0 then player:TryRemoveTrinket(t0) end
	player:AddTrinket(newTrinket)
	player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, datatables.NoAnimNoAnnounMimic)
	if t1 ~= 0 then player:AddTrinket(t1, false) end
	if t0 ~= 0 then player:AddTrinket(t0, false) end
end

function functions.TrinketRemove(player, newTrinket)
	--- remove given gulped trinket
	local t0 = player:GetTrinket(0) -- 0 - first slot
	local t1 = player:GetTrinket(1)  -- 1 - second slot
	if t1 ~= 0 then player:TryRemoveTrinket(t1) end
	if t0 ~= 0 then player:TryRemoveTrinket(t0) end
	player:TryRemoveTrinket(newTrinket)
	if t1 ~= 0 then player:AddTrinket(t1, false) end
	if t0 ~= 0 then player:AddTrinket(t0, false) end
end

function functions.RemoveThrowTrinket(player, trinket)
	--- init throw trinket (A+ trinket imitation)
	local throwTrinket = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, trinket, player.Position, RandomVector()*5, player):ToPickup()
	local dataTrinket = throwTrinket:GetData()
	dataTrinket.RemoveThrowTrinket = true
	throwTrinket.Timeout = 40
	player:TryRemoveTrinket(trinket)
end

function functions.RerollTMTRAINER(player, item)
	--- reroll to glitched item
	player = player:ToPlayer()
	player:AddCollectible(CollectibleType.COLLECTIBLE_TMTRAINER)
	player:UseActiveItem(CollectibleType.COLLECTIBLE_D6, EclipsedMod.datatables.NoAnimNoAnnounMimic) -- D6 effect
	player:RemoveCollectible(CollectibleType.COLLECTIBLE_TMTRAINER) -- remove tmtrainer
	if item then
		player:AnimateCollectible(item, "UseItem")
	end
end

function functions.SpawnItem(itemPoolType, position, optionIndex)
	local newItem = itemPool:GetCollectible(itemPoolType, false)
	newItem = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, newItem, position, Vector.Zero, nil):ToPickup()
	newItem.OptionsPickupIndex = optionIndex
end

function functions.SpawnOptionItems(position, rng, optionIndex)
	--- spawn 3 items
	local leftPosition = Isaac.GetFreeNearPosition(Vector(position.X-80,position.Y), 40) -- rework to get room center?
	local centPosition = Isaac.GetFreeNearPosition(position, 40)
	local righPosition = Isaac.GetFreeNearPosition(Vector(position.X+80,position.Y), 40) -- cause grid size is 40x40
	functions.SpawnItem(rng:RandomInt(ItemPoolType.POOL_BOMB_BUM), leftPosition, optionIndex)
	functions.SpawnItem(rng:RandomInt(ItemPoolType.POOL_BOMB_BUM), centPosition, optionIndex)
	functions.SpawnItem(rng:RandomInt(ItemPoolType.POOL_BOMB_BUM), righPosition, optionIndex)
end


function functions.TetrisDiceCheks(player)
	for slot = 0, 3 do
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

function functions.CheckJudasBirthright(ppl)
	--- check if player is judas and has birthright
	ppl = ppl:ToPlayer()
	local pplType = ppl:GetPlayerType()
	if not (pplType == PlayerType.PLAYER_JUDAS or pplType == PlayerType.PLAYER_BLACKJUDAS) then return false end
	if not ppl:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then return false end
	return true
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

function functions.SetRedPoop()
	local room = game:GetRoom()
	for gridIndex = 1, room:GetGridSize() do -- get room size
		local grid = room:GetGridEntity(gridIndex)
		if grid and grid:ToPoop() and grid:GetVariant() == 0 then
			grid:SetVariant(1)
			grid:Init(Random()+1)
			grid:PostInit()
			grid:Update()
		end
	end
end

---Floppy Disk
function functions.StorePlayerItems(player)
	local allItems = Isaac.GetItemConfig():GetCollectibles().Size - 1
	for id = 1, allItems do
		if player:HasCollectible(id) then
			for _ = 1, player:GetCollectibleNum(id, true) do
				table.insert(mod.PersistentData.FloppyDiskItems, id)
			end
		end
	end
end
function functions.ReplacePlayerItems(player)
	local allItems = Isaac.GetItemConfig():GetCollectibles().Size - 1
	for id = 1, allItems do
		if player:HasCollectible(id) and not functions.CheckItemTags(id, ItemConfig.TAG_QUEST) then
			for _ = 1, player:GetCollectibleNum(id, true) do
				player:RemoveCollectible(id)
			end
		end
	end
	for _, itemID in pairs(mod.PersistentData.FloppyDiskItems) do
		if itemID <= allItems then -- (I guess it can give you wrong items by stored id, if you add/remove mods after saving mod data)
			player:AddCollectible(itemID)
		else
			player:AddCollectible(CollectibleType.COLLECTIBLE_MISSING_NO) -- give you missing no...
		end
	end
	mod.PersistentData.FloppyDiskItems = {}
end

function functions.AddItemFromWisp(player, kill, stop)
	--- add actual item from item wisp
	local data = player:GetData()
	stop = stop or false
	local itemWisps = Isaac.FindInRadius(player.Position, 120, EntityPartition.FAMILIAR)
	if #itemWisps > 0 then
		for _, witem in pairs(itemWisps) do
			if witem.Variant == FamiliarVariant.ITEM_WISP and not functions.CheckItemType(witem.SubType) then -- and not witem:GetData().MongoWisp then
				data.eclipsed.WispedQueue = data.eclipsed.WispedQueue or {}
				table.insert(data.eclipsed.WispedQueue, {witem, kill})
				if stop then
					return witem.SubType
				end
			end
		end
	end
	return
end

---RedButton
function functions.RemoveRedButton(room)
	--- remove pressure plate spawned by red button
	for gridIndex = 1, room:GetGridSize() do -- get room size
		local grid = room:GetGridEntity(gridIndex)
		if grid and grid.VarData == datatables.RedButton.VarData then -- check if button is spawned by red button
			room:RemoveGridEntity(gridIndex, 0, false) -- remove it
			grid:Update()
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, grid.Position, Vector.Zero, nil):SetColor(datatables.RedColor, 50, 1, false, false)
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
	if killChance >= 0.98 then
		subtype = 9 -- killer button
	elseif randNum >= 0.5 then
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

---Red Pill
function functions.RedPillManager(player, newDamage, wavyNum)
	local data = player:GetData()
	game:ShowHallucination(5, BackdropType.DICE)
	sfx:Stop(SoundEffect.SOUND_DEATH_CARD)
	data.eclipsed.RedPillDamageDown = datatables.RedPills.DamageDown
	for _ = 1, wavyNum do
		player:UseActiveItem(CollectibleType.COLLECTIBLE_WAVY_CAP, datatables.NoAnimNoAnnounMimic)
	end
	sfx:Stop(SoundEffect.SOUND_VAMP_GULP)
	data.eclipsed.RedPillDamageUp = data.eclipsed.RedPillDamageUp or 0
	data.eclipsed.RedPillDamageUp = data.eclipsed.RedPillDamageUp + newDamage
	player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
	player:EvaluateItems()
end

EclipsedMod.functions = functions