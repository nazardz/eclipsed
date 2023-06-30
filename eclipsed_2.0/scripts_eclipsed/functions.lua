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
	if not mod.ModVars.ForLevel then mod.ModVars.ForLevel = {} end
end

function functions.CopyDatatable(Oldtable)
	local myTable = {}
	for k,v in pairs(Oldtable) do
		myTable[k] = v
	end
	return myTable
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

function functions.useVHS(newLevel)
	Isaac.ExecuteCommand("stage " .. newLevel)
	game:ShowHallucination(5, 0)
	sfx:Stop(SoundEffect.SOUND_DEATH_CARD)
	sfx:Play(SoundEffect.SOUND_STATIC)
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
		if datatables.TetrisDicesCheckEmpty[item] and charges == 0 then
			player:RemoveCollectible(item)
			player:AddCollectible(enums.Items.TetrisDice1)
		elseif datatables.TetrisDicesCheck[item] and charges >= datatables.TetrisDicesCheck[item] then
			local nextitem = datatables.TetrisDicesCheck[item]
			if nextitem < Isaac.GetItemConfig():GetCollectible(enums.Items.TetrisDice_full ).MaxCharges then
				nextitem = datatables.TetrisDices[nextitem]
				player:RemoveCollectible(item)
				player:AddCollectible(nextitem, charges+bat_charges)
			else
				player:RemoveCollectible(item)
				player:AddCollectible(enums.Items.TetrisDice_full, charges+bat_charges)
			end
			break
		end
	end
end

function functions.ActiveItemText(text, xOff, yOff, kcolor)
	text = text or "x" .. text
	xOff = xOff or 30
	yOff = yOff or 0
	kcolor = kcolor or KColor(1 ,1 ,1 ,1)
	datatables.TextFont:DrawString(text, xOff + Options.HUDOffset * 24 , yOff + Options.HUDOffset *10, kcolor, 0, true)
end

function functions.SoulExplosion(pos)
	local level = game:GetLevel()
	local damageMulti = level:GetAbsoluteStage()
	if level:IsAscent() then
		damageMulti = 13
	end
	local ghostExplosion = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ENEMY_GHOST, 2, pos, Vector.Zero, nil):ToEffect()
	ghostExplosion.CollisionDamage = 7 + (damageMulti-1)*0.5
	sfx:Play(SoundEffect.SOUND_DEMON_HIT)
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

function functions.CheckItemTags(ItemID, Tag)
	--- check item tag
	if ItemID > 0 then
		local itemConfigItem = Isaac.GetItemConfig():GetCollectible(ItemID)
		return itemConfigItem.Tags & Tag == Tag
	end
	return false
end

function functions.AdrenalineManager(player, redHearts, num)
	--- turn your hearts into batteries
	local j = 0
	while redHearts > num do
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_NORMAL, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
		redHearts = redHearts-2
		j = j+2 -- for each 2 hearts
	end
	player:AddHearts(-j)
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

function functions.DeliObjectSave(player, rng)
	if rng:RandomFloat() <= 0.33 then
		local newCard = datatables.DeliObject.Variants[rng:RandomInt(#datatables.DeliObject.Variants)+1]
		player:AddCard(newCard)
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

---TurnGold
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
	elseif datatables.NoGoldenChest[pickup.Variant] and pickup.SubType == ChestSubType.CHEST_CLOSED then
		isChest = PickupVariant.PICKUP_LOCKEDCHEST
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

function functions.Domino16Items(rng, pos)
	local chestTable = {50,51,52,53,54,55,56,57,58,60,360}
	local varTable = {10,20,30,40,41,50,69,70,90,100,150,300,350}
	local var = varTable[rng:RandomInt(#varTable)+1]
	local finalVar = var
	for _ = 1, 6 do
		if var == 50 then
			finalVar = chestTable[rng:RandomInt(#chestTable)+1]
		end
		Isaac.Spawn(EntityType.ENTITY_PICKUP, finalVar, 0, Isaac.GetFreeNearPosition(pos, 40), Vector.Zero, nil)
	end
end

function functions.HeartTranslpantFunc(player)
	--- heart transplant
	local data = player:GetData()
	data.eclipsed.HeartTransplantDelay = nil
	player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_SPEED)
	player:EvaluateItems()
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

function functions.KnightJumpLogic(radiusMin, radiusMax, damage, knockback, player)
	--- crush when land
	local room = game:GetRoom()
	for _, entity in pairs(Isaac.GetRoomEntities()) do
		if entity:ToNPC() and entity:IsVulnerableEnemy() and entity:IsActiveEnemy() then
			if entity.Position:Distance(player.Position) <= radiusMin then
				entity:TakeDamage(damage, DamageFlag.DAMAGE_EXPLOSION | DamageFlag.DAMAGE_CRUSH, EntityRef(player), 0)
				entity.Velocity = (entity.Position - player.Position):Resized(20)
			elseif entity.Position:Distance(player.Position) <radiusMax then
				entity.Velocity = (entity.Position - player.Position):Resized(20)
			end
		elseif entity.Position:Distance(player.Position) <= radiusMin then
			if entity.Type == EntityType.ENTITY_FIREPLACE and entity.Variant ~= 4 then -- 4 is white fireplace
				entity:Die()
			elseif entity.Type == EntityType.ENTITY_MOVABLE_TNT then
				entity:Die()
			elseif ((entity.Type == EntityType.ENTITY_FAMILIAR and entity.Variant == FamiliarVariant.CUBE_BABY) or (entity.Type == EntityType.ENTITY_BOMB)) then
				entity.Velocity = (entity.Position - player.Position):Resized(knockback)
			elseif (entity.Type == EntityType.ENTITY_SHOPKEEPER and not entity:GetData().EID_Pathfinder) or datatables.StonEnemies[entity.Type] then
				entity:Kill()
			elseif entity:ToPickup() and not datatables.NotAllowedPickupVariants[entity.Variant] then
				if entity.Variant == PickupVariant.PICKUP_BOMBCHEST then
					entity:ToPickup():TryOpenChest()
				end
				entity.Position = player.Position
				entity.Velocity = Vector.Zero
			end
		end
	end
	for gridIndex = 1, room:GetGridSize() do
		if room:GetGridEntity(gridIndex) then
			local grid = room:GetGridEntity(gridIndex)
			if (player.Position - grid.Position):Length() <= radiusMin then
				if grid.Desc.Type ~= GridEntityType.GRID_DOOR and grid.Desc.Variant ~= GridEntityType.GRID_DECORATION then
					grid:Destroy()
				end
			end
		end
	end
	local grid = room:GetGridEntityFromPos(player.Position)
	if grid then
		if grid.Desc.Type == GridEntityType.GRID_PIT and grid.Desc.State ~= 1 then
			if room:HasLava() then
				local splash = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BIG_SPLASH, 0, player.Position, Vector.Zero, nil):ToEffect()
				splash.Color = Color(1.2, 0.8, 0.1, 1, 0, 0, 0)
				splash.SpriteScale = Vector(0.75, 0.75)
			elseif room:HasWaterPits() or room:HasWater() then
				local splash = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BIG_SPLASH, 0, player.Position, Vector.Zero, nil):ToEffect()
				splash.SpriteScale = Vector(0.75, 0.75)
			end
		end
	elseif room:HasWater() then
		local splash = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BIG_SPLASH, 0, player.Position, Vector.Zero, nil):ToEffect()
		splash.SpriteScale = Vector(0.75, 0.75)
	else
		sfx:Play(SoundEffect.SOUND_STONE_IMPACT, 1, 0, false, 1, 0)
	end
	game:ShakeScreen(10)
	player.Velocity = Vector.Zero
end

function functions.GetNearestEnemy(basePos, distance)
	--- get near enemy's position, else return basePos position
	local finalPosition = basePos
	distance = distance or 5000
	local nearest = distance
	local enemies = Isaac.FindInRadius(basePos, distance, EntityPartition.ENEMY)
	if #enemies > 0 then
		for _, enemy in pairs(enemies) do
			if not enemy:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) and enemy:IsVulnerableEnemy() and enemy:IsActiveEnemy() and basePos:Distance(enemy.Position) < nearest then
                nearest = basePos:Distance(enemy.Position)
				finalPosition = enemy.Position
            end
		end
	end
	return finalPosition
end

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

EclipsedMod.functions = functions