local game = Game()
local itemPool = game:GetItemPool()
local sfx = SFXManager()
local functions = {}
local enums = EclipsedMod.enums
local datatables = EclipsedMod.datatables

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

EclipsedMod.functions = functions