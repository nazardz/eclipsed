local mod = EclipsedMod
local game = Game()
local json = require("json")
local itemPool = game:GetItemPool()
local sfx = SFXManager()
local functions = {}
local enums = mod.enums
local datatables = mod.datatables
local RECOMMENDED_SHIFT_IDX = 35

function functions.GetCompletion(name, mark)
	if mod.PersistentData.CompletionMarks[name][mark] then
		return mod.PersistentData.CompletionMarks[name][mark]
	else
		return 0
	end
end

function functions.GetIcon(filename, pos, alpha)
	local itemSprite = Sprite()
	itemSprite:Load("gfx/005.100_Collectible.anm2", true)
	itemSprite:ReplaceSpritesheet(1, filename)
	itemSprite:LoadGraphics()
	itemSprite.Scale = Vector.One * 0.8
	itemSprite:SetFrame("Idle", 8)
	itemSprite.Color = Color(1,1,1,alpha)
	itemSprite:Render(pos)
	return itemSprite
end

function functions.GetPlayerIndex(player) -- ded#8894 Algorithm
	--- get player index. used to SAVE/LOAD mod data
	local collectible = 1 -- sad onion
	local playerType = player:GetPlayerType()
	if playerType == PlayerType.PLAYER_LAZARUS2_B then
		collectible = 2
	end
	local seed = player:GetCollectibleRNG(collectible):GetSeed()
	return tostring(seed)
end

function functions.LoadedSaveData(isSave)
	--print(mod.LoadSaveData, isSave)
	if not mod.LoadSaveData then
		functions.ChekModRNG()
		mod.LoadSaveData = true
		isSave = isSave or true
		if mod:HasData() then
			local localtable = json.decode(mod:LoadData())
			mod.PersistentData = localtable.PersistentData
			if not mod.PersistentData then
				mod.PersistentData = {}
				mod.PersistentData.SpecialCursesAvtice = localtable.SpecialCursesAvtice
				mod.PersistentData.FloppyDiskItems = localtable.FloppyDiskItems
				mod.PersistentData.CompletionMarks = localtable.CompletionMarks
				if mod.PersistentData.SpecialCursesAvtice == nil then
					mod.SADTOANNOUNCETHATWERESETTINGMODDATA = true
					mod.PersistentData = functions.ResetPersistentData()
				end
			end
			--mod.PersistentData = {}
			--mod.PersistentData.SpecialCursesAvtice = localtable.SpecialCursesAvtice
			--mod.PersistentData.FloppyDiskItems = localtable.FloppyDiskItems
			--mod.PersistentData.CompletionMarks = localtable.CompletionMarks

			if isSave then
				mod.hiddenItemManager:LoadData(localtable.HiddenItemWisps)
				if localtable.ModVars and not mod.ResetModVars then
					mod.ModVars = localtable.ModVars
				end
				if localtable.eclipsed then
					for playerNum = 0, game:GetNumPlayers()-1 do
						local player = game:GetPlayer(playerNum)
						local data = player:GetData()
						local idx = functions.GetPlayerIndex(player)
						local tempEffects = player:GetEffects()
						functions.ResetPlayerData(player)
						if localtable.eclipsed[idx] then
							data.eclipsed = localtable.eclipsed[idx]
						end
						---Lililith
						if player:HasCollectible(enums.Items.Lililith) and data.eclipsed.ForLevel.LililithFams then
							for _, demonFam in pairs(data.eclipsed.ForLevel.LililithFams) do
								tempEffects:AddCollectibleEffect(demonFam)
							end
						end
						---RubberDuck
						if player:HasCollectible(enums.Items.RubberDuck) then
							functions.EvaluateDuckLuck(player, data.eclipsed.DuckCurrentLuck)
						end
						---RedPills
						if data.eclipsed.RedPillDamageUp and data.eclipsed.RedPillDamageUp > 0 then
							player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
							tempEffects:AddNullEffect(NullItemID.ID_WAVY_CAP_1, false, 1)
							game:ShowHallucination(0, BackdropType.DICE)
							sfx:Stop(SoundEffect.SOUND_DEATH_CARD)
						end
						player:EvaluateItems()
					end
				end
			end
		else
			mod.PersistentData = functions.ResetPersistentData()
		end
	end
end

function functions.SavedSaveData(isContinue)
	isContinue = isContinue or true
	local savetable = {}
	savetable.PersistentData = mod.PersistentData 
	-- cause otherwise it would delete old eclipsed savedata
	-- savetable.SpecialCursesAvtice = mod.PersistentData.SpecialCursesAvtice
	-- savetable.FloppyDiskItems = mod.PersistentData.FloppyDiskItems
	-- savetable.CompletionMarks = mod.PersistentData.CompletionMarks
	if isContinue then
		savetable.ModVars = mod.ModVars
		savetable.eclipsed = {}
		savetable.HiddenItemWisps = mod.hiddenItemManager:GetSaveData()
		for playerNum = 0, game:GetNumPlayers()-1 do
			local player = game:GetPlayer(playerNum)
			local data = player:GetData()
			local idx = functions.GetPlayerIndex(player)
			savetable.eclipsed[idx] = data.eclipsed
		end
	end
	mod:SaveData(json.encode(savetable))
end

function functions.ResetModVars(reset)
	if reset then
		mod.ModVars = {}
		mod.ModVars.ForRoom = {}
		mod.ModVars.ForLevel = {}
		return 
	else
	if not mod.ModVars then mod.ModVars = {} end
	if not mod.ModVars.ForRoom then mod.ModVars.ForRoom = {} end
	if not mod.ModVars.ForLevel then mod.ModVars.ForLevel = {} end
	end
end

function functions.ChekModRNG()
	if not mod.rng then
		mod.rng = RNG()
		mod.rng:SetSeed(game:GetSeeds():GetStartSeed(), RECOMMENDED_SHIFT_IDX)
	end
end

function functions.CheckInRange(myNum, min, max)
	--- check if number in given range: max >= myNum >= min
	return myNum >= min and myNum <= max
end

function functions.CopyDatatable(Oldtable)
	local myTable = {}
	for k,v in pairs(Oldtable) do
		myTable[k] = v
	end
	return myTable
end

--- Written by Zamiel, technique created by im_tem, tweaked
function functions.SetBlindfold(player, enabled)
	---Blindfold
    local challenge = Isaac.GetChallenge()
    if enabled then
        game.Challenge = Challenge.CHALLENGE_SOLAR_SYSTEM
        player:UpdateCanShoot()
        game.Challenge = challenge
        player:TryRemoveNullCostume(NullItemID.ID_BLINDFOLD)
    else
        game.Challenge = Challenge.CHALLENGE_NULL
        player:UpdateCanShoot()
        game.Challenge = challenge
    end
	--print(player:GetName(), enabled)
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
	data.eclipsed = data.eclipsed or {}
	data.eclipsed.ForRoom = data.eclipsed.ForRoom or {}
	data.eclipsed.ForLevel = data.eclipsed.ForLevel or {}
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

function functions.CircleSpawnX10(pos, spawner, entityType, entityVariant, entitySubtype)
	local velocity = spawner.ShotSpeed * 5
	local velMult = 0.9
	Isaac.Spawn(entityType, entityVariant, entitySubtype, pos, Vector(velocity, 0)*1.1, spawner) --right
	Isaac.Spawn(entityType, entityVariant, entitySubtype, pos, Vector(-velocity, 0)*1.1, spawner) --left
	Isaac.Spawn(entityType, entityVariant, entitySubtype, pos, Vector(velocity, velocity*0.72)*velMult, spawner)
	Isaac.Spawn(entityType, entityVariant, entitySubtype, pos, Vector(velocity, -velocity*0.72)*velMult, spawner)
	Isaac.Spawn(entityType, entityVariant, entitySubtype, pos, Vector(-velocity, velocity*0.72)*velMult, spawner)
	Isaac.Spawn(entityType, entityVariant, entitySubtype, pos, Vector(-velocity, -velocity*0.72)*velMult, spawner)
	Isaac.Spawn(entityType, entityVariant, entitySubtype, pos, Vector(velocity*0.36, velocity)*1.036, spawner)
	Isaac.Spawn(entityType, entityVariant, entitySubtype, pos, Vector(velocity*0.36, -velocity)*1.036, spawner)
	Isaac.Spawn(entityType, entityVariant, entitySubtype, pos, Vector(-velocity*0.36, velocity)*1.036, spawner)
	Isaac.Spawn(entityType, entityVariant, entitySubtype, pos, Vector(-velocity*0.36, -velocity)*1.036, spawner)
end

function functions.CircleSpawnX10Flame(pos, spawner)
	local velocity = spawner.ShotSpeed * 5
	local velMult = 0.9
	local timeout = 15
	local damage = spawner.Damage
	local flame = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLUE_FLAME, 0, pos, Vector(velocity, 0)*1.1, spawner):ToEffect() --right
	flame.CollisionDamage = damage
	flame:SetTimeout(timeout)
	flame = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLUE_FLAME, 0, pos, Vector(-velocity, 0)*1.1, spawner):ToEffect() --left
	flame.CollisionDamage = damage
	flame:SetTimeout(timeout)
	flame = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLUE_FLAME, 0, pos, Vector(velocity, velocity*0.72)*velMult, spawner):ToEffect()
	flame.CollisionDamage = damage
	flame:SetTimeout(timeout)
	flame = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLUE_FLAME, 0, pos, Vector(velocity, -velocity*0.72)*velMult, spawner):ToEffect()
	flame.CollisionDamage = damage
	flame:SetTimeout(timeout)
	flame = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLUE_FLAME, 0, pos, Vector(-velocity, velocity*0.72)*velMult, spawner):ToEffect()
	flame.CollisionDamage = damage
	flame:SetTimeout(timeout)
	flame = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLUE_FLAME, 0, pos, Vector(-velocity, -velocity*0.72)*velMult, spawner):ToEffect()
	flame.CollisionDamage = damage
	flame:SetTimeout(timeout)
	flame = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLUE_FLAME, 0, pos, Vector(velocity*0.36, velocity)*1.036, spawner):ToEffect()
	flame.CollisionDamage = damage
	flame:SetTimeout(timeout)
	flame = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLUE_FLAME, 0, pos, Vector(velocity*0.36, -velocity)*1.036, spawner):ToEffect()
	flame.CollisionDamage = damage
	flame:SetTimeout(timeout)
	flame = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLUE_FLAME, 0, pos, Vector(-velocity*0.36, velocity)*1.036, spawner):ToEffect()
	flame.CollisionDamage = damage
	flame:SetTimeout(timeout)
	flame = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLUE_FLAME, 0, pos, Vector(-velocity*0.36, -velocity)*1.036, spawner):ToEffect()
	flame.CollisionDamage = damage
	flame:SetTimeout(timeout)
end

function functions.CheckApplyTearEffect(tear, enemy)
	if not enemy:ToNPC() then return end
	if not enemy:IsVulnerableEnemy() then return end
	if not enemy:IsActiveEnemy() then return end
	if not tear.SpawnerEntity then return end
	if not tear.SpawnerEntity:ToPlayer() then return end
	local player = tear.SpawnerEntity:ToPlayer()
	if player:HasCurseMistEffect() then return end
	if player:IsCoopGhost() then return end
	enemy = enemy:ToNPC()
	local rng = tear:GetDropRNG()
	functions.ApplyTearEffect(player, enemy, rng)
end

function functions.ApplyTearEffect(player, enemy, rng)
	local data = player:GetData()
	local enemyData = enemy:GetData()
	---MeltedCandle
	if player:HasCollectible(enums.Items.MeltedCandle) and not enemyData.Waxed then
		local chance = 1/(5-(functions.LuckCalc(player.Luck, 20)*0.15))
		if chance > rng:RandomFloat() then
			enemy:AddFreeze(EntityRef(player), 92)
			if enemy:HasEntityFlags(EntityFlag.FLAG_FREEZE) then
				--entity:AddBurn(EntityRef(player), 1, player.Damage) -- the issue is Freeze stops framecount of entity, so it won't call NPC_UPDATE.
				enemy:AddEntityFlags(EntityFlag.FLAG_BURN)
				enemyData.Waxed = 92
				enemy:SetColor(datatables.MeltedCandle.TearColor, 92, 100, false, false)
			end
		end
	end
	---BleedingGrimoire
	if data.eclipsed.BleedingGrimoire then
		enemy:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
		enemyData.Bleeding = 62
	end
end

function functions.PenanceShootLaser(angle, timeout, pos, ppl)
	--- penance
	local laser = Isaac.Spawn(EntityType.ENTITY_LASER, 5, 0, pos, Vector.Zero, ppl):ToLaser()
	laser.Color = Color(1.25, 0.05, 0.15, 0.5)
	laser:SetTimeout(timeout)
	laser.Angle = angle
end



function functions.ResetPersistentData()
	local ResetData = {}
	ResetData.SpecialCursesAvtice = false
	ResetData.FloppyDiskItems = {}
	ResetData.CompletionMarks= {}
	ResetData.CompletionMarks.Nadab = datatables.completionInit
	ResetData.CompletionMarks.Abihu = datatables.completionInit
	ResetData.CompletionMarks.Unbidden = datatables.completionInit
	ResetData.CompletionMarks.UnbiddenB = datatables.completionInit
	ResetData.CompletionMarks.Challenges = datatables.challengesInit

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
	for _, curse in pairs(mod.enums.Curses) do
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
			local gfx = mod.enums.CurseIconsList[curse]
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
	player:UseActiveItem(CollectibleType.COLLECTIBLE_D6, datatables.NoAnimNoAnnounMimic) -- D6 effect
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

function functions.HeavensCall(room, level)
	if room:GetType() == RoomType.ROOM_DICE and functions.CheckInRange(level:GetCurrentRoomIndex(), 8500, 8510) then
		return true
	elseif room:GetType() == RoomType.ROOM_DEVIL and functions.CheckInRange(level:GetCurrentRoomDesc().Data.Variant, 85, 89 ) then
		return true
	end
	return false
end

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

function functions.SetBombEXCountdown(player, bomb)
	bomb:SetExplosionCountdown(44)
	if player:HasTrinket(TrinketType.TRINKET_SHORT_FUSE) then
		bomb:SetExplosionCountdown(20)
	elseif bomb.Parent:ToBomb().IsFetus then
		bomb:SetExplosionCountdown(30)
	end
	if bomb.Parent:ToBomb().IsFetus and player:HasTrinket(TrinketType.TRINKET_SHORT_FUSE) then
		bomb:SetExplosionCountdown(15) -- short fuse shortens countdown to half
	end
end

function functions.RedBombReplace(bomb)
	--- replace bomb by throwable bomb
	bomb:Remove()
	if bomb.Variant == BombVariant.BOMB_GIGA then
		for _ = 1, 5 do
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_THROWABLEBOMB, 0, bomb.Position, RandomVector()*5, nil)
		end
	else
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_THROWABLEBOMB, 0, bomb.Position, bomb.Velocity, nil)
	end
	Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, bomb.Position, Vector.Zero, nil):SetColor(datatables.RedColor, -1, 1, false, false)
end

function functions.LuckCalc(luck, top, bottom)
	top = top or 100
	luck = math.min(luck, top)
	if bottom then
		luck = math.max(luck, bottom)
	end
	return luck
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
	return false
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
	mod.ModVars.ForRoom.PressCount = 0
	if room:IsFirstVisit() then -- if room visited first time
		functions.SpawnButton(player, room) -- spawn new button
	else --if not room:IsClear() then
		functions.RemoveRedButton(room) -- remove button if there is left any button (ex: if you teleported while room is uncleared)
		functions.SpawnButton(player, room)
	end
end

function functions.ExplodingKittenCurse(player, card)
	--- exploding kittens
	local room = game:GetRoom()
	local rng = player:GetCardRNG(card)
	local randChance = rng:RandomFloat()
	if randChance <= 0.2 then
		player:UsePill(PillEffect.PILLEFFECT_HORF, PillColor.PILL_GIANT_FLAG, datatables.NoAnimNoAnnounMimic | UseFlag.USE_NOHUD)
	elseif randChance <= 0.4 then
		player:UsePill(PillEffect.PILLEFFECT_EXPLOSIVE_DIARRHEA, 0, datatables.NoAnimNoAnnounMimic | UseFlag.USE_NOHUD)
	elseif randChance <= 0.6 then
		for _ = 1, 3 do
			local randPos = room:GetRandomPosition(0)
			local epic = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ROCKET, 0, randPos, Vector.Zero, player)
			if epic then
				epic:SetColor(Color(0,0,0,0),2,1, false, false)
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
	else
		for _ = 1, 3 do
			local randPos = room:GetRandomPosition(0)
			randPos = room:FindFreePickupSpawnPosition(randPos)
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, randPos, Vector.Zero, nil)
			Isaac.Spawn(EntityType.ENTITY_BOMB, BombVariant.BOMB_GOLDENTROLL, 0, randPos, Vector.Zero, player)
		end
	end
end


---Midas Curse
function functions.GoldenGrid()
	--- turn grid into golden (poop n' rocks)
	local room = game:GetRoom()
	for i=1, room:GetGridSize() do
		local grid = room:GetGridEntity(i)
		if grid and grid:ToPoop() and grid:GetVariant() ~= 3 and grid.State == 0 then
			grid:SetVariant(3) -- 3 is golden poop
			grid:Init(Random()+1)
			grid:PostInit()
			grid:Update()
		end
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

---Red Pill
function functions.RedPillManager(player, newDamage, wavyNum)
	local data = player:GetData()
	game:ShowHallucination(5, BackdropType.DICE)
	sfx:Stop(SoundEffect.SOUND_DEATH_CARD)
	data.eclipsed.RedPillDamageDown = 0.00001
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
		sfx:Play(SoundEffect.SOUND_BOSS2_DIVE)
	else
		sfx:Play(SoundEffect.SOUND_STONE_IMPACT)
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

function functions.DeadEggEffect(numTrinket, pos, timeout)
	--- spawn dead bird
	for _ = 1, numTrinket do
		local birdy = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DEAD_BIRD, 0, pos, Vector.Zero, nil):ToEffect()
		birdy:SetColor(Color(0,0,0,1,0,0,0),timeout,1, false, false) -- set black
		birdy:SetTimeout(timeout)
		birdy.SpriteScale = Vector.One *0.7
		birdy:GetData().DeadEgg = true
	end
end

function functions.ExplosionEffect(player, bombPos, bombDamage, bombFlags, damageSource)
	--local data = player:GetData()
	local radius = functions.GetBombRadiusFromDamage(bombDamage)
	local bombRadiusMult = 1
	if damageSource == nil then damageSource = true end
	---FrostyBombs
	if player:HasCollectible(enums.Items.FrostyBombs) then
		bombFlags = bombFlags | TearFlags.TEAR_SLOW | TearFlags.TEAR_ICE
		if bombFlags & TearFlags.TEAR_SAD_BOMB == TearFlags.TEAR_SAD_BOMB then
			mod.ModVars.SadIceBombTear = mod.ModVars.SadIceBombTear or {}
			table.insert(mod.ModVars.SadIceBombTear, bombPos)
		end
	end
	---StickyBombs
	if bombFlags & TearFlags.TEAR_STICKY == TearFlags.TEAR_STICKY then
		for _, entity in pairs(Isaac.FindInRadius(bombPos, 30, EntityPartition.ENEMY)) do
			if entity:ToNPC() and entity:IsVulnerableEnemy() and entity:IsActiveEnemy() then
				entity:AddEntityFlags(EntityFlag.FLAG_SPAWN_STICKY_SPIDERS)
			end
		end
	end
	---BombExplosionEffects
	game:BombExplosionEffects(bombPos, bombDamage, bombFlags, Color.Default, player, bombRadiusMult, true, damageSource, DamageFlag.DAMAGE_EXPLOSION)
	---CompoBombs
	if player:HasCollectible(enums.Items.CompoBombs) then
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_THROWABLEBOMB, 0,  Isaac.GetFreeNearPosition(bombPos, 1), Vector.Zero, player)
	end
	---BobCurse
	if player:HasCollectible(CollectibleType.COLLECTIBLE_BOBS_CURSE) then
		local cloud = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SMOKE_CLOUD, 0, bombPos, Vector.Zero, player):ToEffect()
		cloud:SetTimeout(150)
	end
	---GhostBombs
	if bombFlags & TearFlags.TEAR_GHOST_BOMB == TearFlags.TEAR_GHOST_BOMB then
		local soul = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HUNGRY_SOUL, 1, bombPos, Vector.Zero, player):ToEffect()
		soul:SetTimeout(360)
	end
	---ScatterBombs
	if bombFlags & TearFlags.TEAR_SCATTER_BOMB == TearFlags.TEAR_SCATTER_BOMB then
		local num = mod.rng:RandomInt(2)+4 -- (0 ~ 1) + 4 = 4 ~ 5
		for _ = 1, num do
			player:AddMinisaac(bombPos, true)
		end
	end
	---BobTongue
	if player:HasTrinket(enums.Trinkets.BobTongue) then
		local fartRingEffect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.FART_RING, 0, bombPos, Vector.Zero, nil):ToEffect()
		fartRingEffect:SetTimeout(30)
	end
	---DeadEgg
	if player:HasTrinket(enums.Trinkets.DeadEgg) then
		functions.DeadEggEffect(player:GetTrinketMultiplier(enums.Trinkets.DeadEgg), bombPos, 150)
	end
	---GravityBombs
	if player:HasCollectible(enums.Items.GravityBombs) then
		local holeEffect = Isaac.Spawn(EntityType.ENTITY_EFFECT, enums.Effects.BlackHoleBombsEffect, 0, bombPos, Vector.Zero, nil):ToEffect()
		holeEffect:SetTimeout(60)
		local holeData = holeEffect:GetData()
		holeEffect.Parent = player
		holeEffect.DepthOffset = -100
		holeData.Gravity = true
		holeData.GravityForce = 50
		holeData.GravityRange = 250
		holeData.GravityGridRange = 5
	end
	---DiceBombs
	if player:HasCollectible(enums.Items.DiceBombs) then
		functions.DiceyReroll(player:GetCollectibleRNG(enums.Items.DiceBombs), bombPos, radius)
	end
	---BatteryBombs
	if player:HasCollectible(enums.Items.BatteryBombs) then
		functions.ChargedBlast(bombPos, radius, bombDamage, player)
	end
	---DeadBombs
	if player:HasCollectible(enums.Items.DeadBombs) then
		functions.BonnyBlast(player:GetCollectibleRNG(enums.Items.DeadBombs), bombPos, radius, player)
	end
end

function functions.BodyExplosion(player, useGiga, bombPos, damageSource)
	local data = player:GetData()
	local bombFlags = player:GetBombFlags()
	local bombDamage = player.Damage * 15
	if player:HasCollectible(CollectibleType.COLLECTIBLE_MR_MEGA) then
		bombDamage = player.Damage * 25
	end
	if data.eclipsed.GigaBombs then
		if data.eclipsed.GigaBombs > 0 then
			if useGiga then
				data.eclipsed.GigaBombs = data.eclipsed.GigaBombs - 1
			end
			bombFlags = bombFlags | TearFlags.TEAR_GIGA_BOMB
			bombDamage = player.Damage * 75
		end
	end
	functions.ExplosionEffect(player, bombPos, bombDamage, bombFlags, damageSource)
end

function functions.FcukingBomberbody(player, body)
	if body then
		local bombData = body:GetData()
		local damageSource = true
		bombData.eclipsed = bombData.eclipsed or {}
		if bombData.eclipsed.PlayerIsSoul then
			damageSource = false
		end
		if player:HasCollectible(enums.Items.MirrorBombs) then
			if bombData.eclipsed.NadabBomb then
				functions.BodyExplosion(player, false, functions.FlipMirrorPos(body.Position), damageSource)
			end
		end
		if bombData.eclipsed.NadabBomb then
			if player:HasTrinket(TrinketType.TRINKET_RING_CAP) then
				bombData.eclipsed.RingCapDelay = 0
			end
			functions.BodyExplosion(player, true, body.Position, damageSource)
		end
	else
		local bodies = Isaac.FindByType(EntityType.ENTITY_BOMB, BombVariant.BOMB_DECOY)
		if player:HasCollectible(enums.Items.MirrorBombs) then
			for _, bomb in pairs(bodies) do
				local bombData = bomb:GetData()
				bombData.eclipsed = bombData.eclipsed or {}
				if bombData.eclipsed.NadabBomb then
					functions.BodyExplosion(player, false, functions.FlipMirrorPos(bomb.Position))
				end
			end
		end
		for _, bomb in pairs(bodies) do
			local bombData = bomb:GetData()
			bombData.eclipsed = bombData.eclipsed or {}
			if bombData.eclipsed.NadabBomb then
				if player:HasTrinket(TrinketType.TRINKET_RING_CAP) then
					bombData.eclipsed.RingCapDelay = 0
				end
				functions.BodyExplosion(player, true, bomb.Position)
			end
		end
	end
end

function functions.NadabBodyDamageGrid(position)
	local room = game:GetRoom()
	local griden = room:GetGridEntityFromPos(position)
	if griden and (griden:ToPoop() or griden:ToTNT()) then
		griden:Hurt(10)
	end
end


function functions.BombHeartConverter(player)
	local data = player:GetData()
	local bombs = player:GetNumBombs()
	if data.eclipsed.BeggarPay then
		if bombs == 0 and player:GetHearts() > 0 then
			player:AddBombs(1)
			player:TakeDamage(1, DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_RED_HEARTS, EntityRef(player), 1)
			data.eclipsed.BeggarPay = false
			data.eclipsed.BlockBeggar = game:GetFrameCount()
		end
	elseif data.eclipsed.GlyphBalanceTrigger then
		data.eclipsed.GlyphBalanceTrigger = false
		if bombs > 0 then
			player:AddBombs(-bombs)
		end
	else
		if bombs > 0 then
			if player:GetNumGigaBombs() > 0 then
				data.eclipsed.GigaBombs = data.eclipsed.GigaBombs or 0
				data.eclipsed.GigaBombs = data.eclipsed.GigaBombs + player:GetNumGigaBombs()
			end
			player:AddBombs(-bombs)
			player:AddHearts(bombs)
		end
	end
end

function functions.BombGoldenHearts(player)
	if player:HasGoldenBomb() then
		if not player:HasCollectible(CollectibleType.COLLECTIBLE_MAMA_MEGA) then
			player:RemoveGoldenBomb()
			player:AddGoldenHearts(1)
		end
	else
		if player:GetGoldenHearts() > 0 and player:HasCollectible(CollectibleType.COLLECTIBLE_MAMA_MEGA) then
			player:AddGoldenHearts(-1)
			player:AddGoldenBomb()
		end
	end
end

function functions.BombBeggarInteraction(player)
	--- Nadab & Abihu bomb beggar interaction
	local data = player:GetData()
	local bombegs = Isaac.FindByType(EntityType.ENTITY_SLOT, 9) -- bombBeggar

	local enablePay = false
	for _, beggar in pairs(bombegs) do
		local bsprite = beggar:GetSprite()
		if beggar.Position:Distance(player.Position) <= 20 and datatables.NadabData.BombBeggarSprites[bsprite:GetAnimation()] then
			enablePay = true
			break
		end
	end
	if enablePay then
		data.eclipsed.BeggarPay = true
	else
		data.eclipsed.BeggarPay = false
	end

end

function functions.AbihuNadabManager(player)
	local data = player:GetData()
	if player:GetHearts() > 0 and not data.eclipsed.BlockBeggar then
		functions.BombBeggarInteraction(player)
	end
	functions.BombGoldenHearts(player)
	functions.BombHeartConverter(player)
end

function functions.NadabEvaluateStats(player,item, cacheFlag, dataCheck)
	if player:HasCollectible(item) then
		if not dataCheck then
			dataCheck = true
			player:AddCacheFlags(cacheFlag)
			player:EvaluateItems()
		end
	else
		if dataCheck then
			dataCheck = false
			player:AddCacheFlags(cacheFlag)
			player:EvaluateItems()
		end
	end
	return dataCheck
end

function functions.NadabExplosion(player, useGiga, bombPos)
	local data = player:GetData()
	local bombFlags = player:GetBombFlags()
	local bombDamage = 100
	if player:HasCollectible(CollectibleType.COLLECTIBLE_MR_MEGA) then
		bombDamage = 185
	end
	if data.eclipsed.GigaBombs and data.eclipsed.GigaBombs > 0 then
		if useGiga then
			data.eclipsed.GigaBombs = data.eclipsed.GigaBombs - 1
		end
		bombFlags = bombFlags | TearFlags.TEAR_GIGA_BOMB
		bombDamage = 300
	end
	functions.ExplosionEffect(player, bombPos, bombDamage, bombFlags)
end

function functions.FcukingBomberman(player)
	if player:HasCollectible(enums.Items.MirrorBombs) then
		functions.NadabExplosion(player, false, functions.FlipMirrorPos(player.Position))
	end
	if player:HasTrinket(TrinketType.TRINKET_RING_CAP) then
		player:GetData().eclipsed.RingCapDelay = 0
	end
	functions.NadabExplosion(player, true, player.Position)
end

function functions.ActiveItemWispsChargeManager(player)
	local data = player:GetData()
	if not data.eclipsed.UnbiddenActiveWisps then return end
	local currentItem = player:GetActiveItem(ActiveSlot.SLOT_PRIMARY)
	if game:GetRoom():GetRoomShape() > 7 then charge = 2 end
	for itemIndex, itemData in pairs(data.eclipsed.UnbiddenActiveWisps) do
		if itemIndex ~= currentItem then
			local charge = 1
			local activeMaxCharge = Isaac.GetItemConfig():GetCollectible(itemIndex).MaxCharges
			local activeChargeType = Isaac.GetItemConfig():GetCollectible(itemIndex).ChargeType
			if activeChargeType == ItemConfig.CHARGE_NORMAL then
				charge = charge + itemData.initCharge
				if not player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) then
					if itemData.initCharge > activeMaxCharge then
						charge = itemData.initCharge
					elseif charge > activeMaxCharge  then 
						charge = activeMaxCharge
					end
				end
				data.eclipsed.UnbiddenActiveWisps[itemIndex] = {initCharge = charge, firstPick = false, varData = charge}
			elseif activeChargeType == ItemConfig.CHARGE_TIMED then
				if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) then
					charge = 2 * activeMaxCharge
				elseif itemData.initCharge > activeMaxCharge then
					charge = itemData.initCharge
				else
					charge = activeMaxCharge
				end
				data.eclipsed.UnbiddenActiveWisps[itemIndex] = {initCharge = charge, firstPick = false, varData = charge}
			--else
			--	print('special', itemIndex)
			end
			
			
			--[[
			if activeChargeType == ItemConfig.CHARGE_NORMAL then
				if itemData.initCharge >= activeMaxCharge then
					if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) then
						charge = charge + itemData.initCharge
					else
						charge = itemData.initCharge
					end
				else
					charge = charge + itemData.initCharge
					if charge > activeMaxCharge then
						if not player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) then
							charge = activeMaxCharge
						end
					end
				end
				data.eclipsed.UnbiddenActiveWisps[itemIndex] = {initCharge = charge, firstPick = false, varData = charge}
			elseif activeChargeType == ItemConfig.CHARGE_TIMED then
				charge = activeMaxCharge
				if itemData.initCharge > activeMaxCharge then
					if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) then
						charge = 2*charge
					else
						charge = itemData.initCharge
					end
				end
				data.eclipsed.UnbiddenActiveWisps[itemIndex] = {initCharge = charge, firstPick = false, varData = charge}
			--else
			--	print('special', itemIndex)
			end
			--]]
		end
	end
end

function functions.ActiveItemWispsManager(player)
	local data = player:GetData()
	local currentItem = player:GetActiveItem(ActiveSlot.SLOT_PRIMARY)
	local UnbiidenCahce = {}
	local wipsCounter = 0
	data.eclipsed.UnbiddenActiveWisps = data.eclipsed.UnbiddenActiveWisps or {} -- table
	local itemWisps = Isaac.FindInRadius(player.Position, 120, EntityPartition.FAMILIAR)
	---Add wisp into table
	for _, witem in pairs(itemWisps) do
		if witem.Variant == FamiliarVariant.ITEM_WISP and functions.CheckItemType(witem.SubType) then
			wipsCounter = wipsCounter + 1
			if not data.eclipsed.UnbiddenActiveWisps[witem.SubType] then
				local initCharge = Isaac.GetItemConfig():GetCollectible(witem.SubType).InitCharge
				local firstPick = true
				UnbiidenCahce[witem.SubType] = {initCharge = initCharge, firstPick = firstPick, varData = 0}
			else
				UnbiidenCahce[witem.SubType] =  data.eclipsed.UnbiddenActiveWisps[witem.SubType]
			end
		end
	end
	---ActiveWispLogic
	if wipsCounter > 0 then
		if currentItem == 0 or currentItem == CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES then
			if data.eclipsed.CurrentHeldItem then
				for _, witem in pairs(itemWisps) do
					if data.eclipsed.CurrentHeldItem == witem.SubType then
						witem:Remove()
						witem:Kill()
						data.eclipsed.CurrentHeldItem = nil
						break
					end
				end
				data.eclipsed.CurrentHeldItem = nil
			else
				for itemIndex, itemData in pairs(UnbiidenCahce) do
					player:AddCollectible(itemIndex, itemData.initCharge, itemData.firstPick, ActiveSlot.SLOT_PRIMARY, itemData.varData)
					break
				end
			end
		else
			if data.eclipsed.UnbiddenBSwapActiveWisp and not Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex) then
				data.eclipsed.UnbiddenBSwapActiveWisp = false
			elseif not data.eclipsed.UnbiddenBSwapActiveWisp and Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex) then
				data.eclipsed.UnbiddenBSwapActiveWisp = true
				---swap items in activeWisps table
				local fondue = false
				for item = currentItem+1, Isaac.GetItemConfig():GetCollectibles().Size - 1 do -- loop from current item to end
					if UnbiidenCahce[item] then
						local charge = player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY) + player:GetBatteryCharge(ActiveSlot.SLOT_PRIMARY)
						UnbiidenCahce[currentItem] = {initCharge = charge, firstPick = false, varData = charge}
						player:RemoveCollectible(currentItem)
						local itemData = UnbiidenCahce[item]
						player:AddCollectible(item, itemData.initCharge, itemData.firstPick, ActiveSlot.SLOT_PRIMARY, itemData.varData)
						fondue = true
						break
					end
				end
				if not fondue then
					for item = 1, currentItem-1 do -- loop from start to current item
						if UnbiidenCahce[item] then
							local charge = player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY) + player:GetBatteryCharge(ActiveSlot.SLOT_PRIMARY)
							UnbiidenCahce[currentItem] = {initCharge = charge, firstPick = false, varData = charge}
							player:RemoveCollectible(currentItem)
							local itemData = UnbiidenCahce[item]
							player:AddCollectible(item, itemData.initCharge, itemData.firstPick, ActiveSlot.SLOT_PRIMARY, itemData.varData)
							break
						end
					end
				end
			end
		end
	end

	---SaveNextLoop
	for itemIndex, itemData in pairs(UnbiidenCahce) do
		data.eclipsed.UnbiddenActiveWisps[itemIndex] = itemData
	end
end

function functions.GetMultiShotNum(player, getAura)
	getAura = getAura or true
	local Aura2020 = functions.GetItemsCount(player, CollectibleType.COLLECTIBLE_20_20)
	local AuraInnerEye = functions.GetItemsCount(player, CollectibleType.COLLECTIBLE_INNER_EYE)
	local AuraMutantSpider = functions.GetItemsCount(player,  CollectibleType.COLLECTIBLE_MUTANT_SPIDER)
	local AuraWiz = functions.GetItemsCount(player, CollectibleType.COLLECTIBLE_THE_WIZ)
	local tearsNum = Aura2020 + AuraWiz
	if getAura then
		local AuraEclipse = functions.GetItemsCount(player, enums.Items.Eclipse)
		tearsNum = tearsNum + AuraEclipse
	end
	if AuraInnerEye > 0 then
		if tearsNum > 0 then AuraInnerEye = AuraInnerEye - 1 end
		tearsNum = tearsNum + AuraInnerEye
	end
	if AuraMutantSpider > 0 then
		if AuraMutantSpider > 1 then AuraMutantSpider = 2*(AuraMutantSpider) end
		tearsNum = tearsNum + AuraMutantSpider + 1
	end
	return tearsNum
end

function functions.AuraRange(range, top, bottom)
	top = top or 300
	bottom = bottom or 60
	if range > top then range = top end
	if range < bottom then range = bottom end
	return range
end

function functions.AuraGridEffect(ppl, auraPos)
	local room = game:GetRoom()
	local iterOffset = ppl.TearRange/80
	if iterOffset%2 ~= 0 then iterOffset = iterOffset +1 end
	iterOffset = math.floor(iterOffset/2)
	local gridTable = {}
	local gridList = {}
	local nulPos = room:GetGridPosition(room:GetGridIndex(auraPos))
	for xx = -40*iterOffset, 40*iterOffset, 40 do
		for yy = -40*iterOffset, 40*iterOffset, 40 do
			gridTable[room:GetGridIndex(Vector(nulPos.X + xx, nulPos.Y + yy))] = true
			table.insert(gridList, Vector(auraPos.X + xx, auraPos.Y + yy))
		end
	end
	for gindex = 0, room:GetGridSize() do
		if ppl:HasCollectible(CollectibleType.COLLECTIBLE_TERRA) then
			if gridTable[gindex] then
				local griden = room:GetGridEntity(gindex)
				if griden and (griden:ToRock() or griden:ToPoop() or griden:ToTNT() or griden:ToDoor()) then
					griden:Destroy(false)
				end
			end
		elseif ppl:HasCollectible(CollectibleType.COLLECTIBLE_SULFURIC_ACID) then
			local rng = ppl:GetCollectibleRNG(CollectibleType.COLLECTIBLE_SULFURIC_ACID)
			if gridTable[gindex] and 0.25 > rng:RandomFloat() then
				local griden = room:GetGridEntity(gindex)
				if griden and (griden:ToRock() or griden:ToPoop() or griden:ToTNT() or (griden:ToDoor() and griden:GetVariant() == DoorVariant.DOOR_HIDDEN)) then
					griden:Destroy(false)
				end
			end
		else
			if gridTable[gindex] then
				local griden = room:GetGridEntity(gindex)
				if griden and (griden:ToPoop() or griden:ToTNT()) then
					griden:Hurt(10)
				end
			end
		end
	end
	return gridList
end

function functions.AuraEnemies(ppl, auraPos, enemies, damage, range)
	local data = ppl:GetData()
	for _, enemy in pairs(enemies) do
		local enemyData = enemy:GetData()
		local rng = enemy:GetDropRNG()
		local knockback = ppl.ShotSpeed * 2
		local tearFlags = ppl.TearFlags
		---Terra
		if ppl:HasCollectible(CollectibleType.COLLECTIBLE_TERRA) then
			local terradmg = 2 * rng:RandomFloat()
			if terradmg < 0.5 then terradmg = 0.5 end
			if terradmg > 2 then terradmg = 2 end
			damage = damage * terradmg
			if terradmg < 1 then terradmg = 1 end
			knockback = knockback * terradmg
		end
		---Lump of Coal
		if ppl:HasCollectible(CollectibleType.COLLECTIBLE_LUMP_OF_COAL) then
			damage =  damage + enemy.Position:Distance(auraPos)/100
		end
		---Proptosis
		if ppl:HasCollectible(CollectibleType.COLLECTIBLE_PROPTOSIS) then
			damage =  damage - enemy.Position:Distance(auraPos)/100
		end
		---bombs, fireplaces and tnt
		if enemy:ToBomb() then
			if ppl:HasCollectible(CollectibleType.COLLECTIBLE_KNOCKOUT_DROPS) then
				local chance = 1/(10-functions.LuckCalc(ppl.Luck, 9))
				if chance > rng:RandomFloat() then
					knockback = 2*knockback
				end
			end
			enemy:AddVelocity((enemy.Position - auraPos):Resized(knockback))
		elseif enemy.Type == 292 or enemy.Type == 33 then -- TNT or Fireplace
			enemy:TakeDamage(damage, 0, EntityRef(ppl), 1)
		end
		---Except shopkeeper and fireplace
		if enemy:IsActiveEnemy() then
			---Euthanasia
			if ppl:HasCollectible(CollectibleType.COLLECTIBLE_EUTHANASIA) then
				local chance = 1/(30-(functions.LuckCalc(ppl.Luck, 13)*2))
				if chance > rng:RandomFloat() then
					enemyData.Euthanased = ppl
					if enemy:IsBoss() then
						enemy:TakeDamage(ppl.Damage*3, DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(ppl), 1)
					elseif enemy:ToNPC() then
						enemy:Kill()
						functions.CircleSpawnX10(enemy.Position, ppl, EntityType.ENTITY_TEAR, TearVariant.NEEDLE, 0)
					end
				end
			end
			---Little Horn
			if ppl:HasCollectible(CollectibleType.COLLECTIBLE_LITTLE_HORN) then
				local chance = 1/(20-functions.LuckCalc(ppl.Luck, 15))
				if chance > rng:RandomFloat() then
					local hand = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BIG_HORN_HAND, 0, enemy.Position, Vector.Zero, ppl):ToEffect()
					hand.Target = enemy
				end
			end
			---Parasitoid
			if ppl:HasCollectible(CollectibleType.COLLECTIBLE_PARASITOID) then
				local chance = 1/(7-functions.LuckCalc(ppl.Luck, 5))
				if chance > rng:RandomFloat() then
					local egg = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.EGG, 0,  enemy.Position, Vector.Zero, ppl):ToTear()
					egg:AddTearFlags(TearFlags.TEAR_EGG)
					egg.CollisionDamage =  ppl.Damage
					egg.FallingSpeed = 100
				end
			end
		end
		---Can be damaged
		if enemy:IsVulnerableEnemy() then
			---Head of the Keeper
			if ppl:HasCollectible(CollectibleType.COLLECTIBLE_HEAD_OF_THE_KEEPER) then
				if 0.05 > rng:RandomFloat() then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, enemy.Position, RandomVector()*3, nil)
				end
			end
			---Jacob Ladder
			if ppl:HasCollectible(CollectibleType.COLLECTIBLE_JACOBS_LADDER) then
				local laser = Isaac.Spawn(EntityType.ENTITY_LASER, LaserVariant.ELECTRIC, 0, enemy.Position, Vector.Zero, ppl):ToLaser()
				laser.CollisionDamage = 0--damage/2
				enemyData.ArkLaserIgnore = 4
				local distance = enemy.Position:Distance(auraPos)
				laser:SetTimeout(5)
				laser:SetMaxDistance(distance)
				local pos = auraPos - enemy.Position
				laser.Angle = pos:GetAngleDegrees()
				laser.Mass = 0
				laser:GetData().ArkLaserNext = {pos = enemy.Position, range = range, maxArk = 4, parent = ppl, child = enemy}
				enemy:TakeDamage(ppl.Damage/2, DamageFlag.DAMAGE_LASER, EntityRef(laser), 1)
			end
			---Lodestone
			if ppl:HasCollectible(CollectibleType.COLLECTIBLE_LODESTONE) then
				local chance = 1/(6-functions.LuckCalc(ppl.Luck, 5))
				if chance > rng:RandomFloat() then
					local magnet = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.METALLIC, 0, enemy.Position, Vector.Zero, ppl):ToTear()
					magnet:AddTearFlags(TearFlags.TEAR_MAGNETIZE)
					magnet:SetColor(Color(0,0,0,0), -1, 100, false, true)
					magnet.Visible = false
					magnet.CollisionDamage = 0
					magnet.FallingSpeed = 100
				end
			end
			---Ocular Rift
			if ppl:HasCollectible(CollectibleType.COLLECTIBLE_OCULAR_RIFT) then
				local chance = 1/(20-functions.LuckCalc(ppl.Luck, 15))
				if chance > rng:RandomFloat() then
					local rift = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RIFT, 0, enemy.Position, Vector.Zero, ppl):ToEffect()
					rift.CollisionDamage = ppl.Damage*0.5
					rift:SetTimeout(62)
				end
			end
			---Melted Candle
			if ppl:HasCollectible(enums.Items.MeltedCandle) and not enemyData.Waxed then
				local chance = 1/(5-(functions.LuckCalc(ppl.Luck, 20)*0.15))
				if chance > rng:RandomFloat() then
					enemy:AddFreeze(EntityRef(ppl), 92)
					if enemy:HasEntityFlags(EntityFlag.FLAG_FREEZE) then
						enemy:AddEntityFlags(EntityFlag.FLAG_BURN)
						enemy:AddEntityFlags(EntityFlag.FLAG_BURN)
						enemyData.Waxed = 92
						enemy:SetColor(datatables.MeltedCandle.TearColor, 92, 100, false, false)
					end
				end
			end
			---Burn
			if tearFlags & TearFlags.TEAR_BURN == TearFlags.TEAR_BURN then
				enemy:AddBurn(EntityRef(ppl), 62, 2*ppl.Damage)
			end
			---Fire Mind
			if ppl:HasCollectible(CollectibleType.COLLECTIBLE_FIRE_MIND) then
				local chance = 1/(10-(functions.LuckCalc(ppl.Luck, 12.86)*0.7))
				if chance > rng:RandomFloat() then
					game:BombExplosionEffects(enemy.Position, ppl.Damage, TearFlags.TEAR_BURN, Color.Default, ppl, 1, true, false, DamageFlag.DAMAGE_EXPLOSION)
				end
			end
			---Charm
			if tearFlags & TearFlags.TEAR_CHARM == TearFlags.TEAR_CHARM then
				enemy:AddCharmed(EntityRef(ppl), 62)
			---Moms Eyeshadow
			elseif ppl:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_EYESHADOW) then
				local chance = 1/(10-(functions.LuckCalc(ppl.Luck, 27)/3))
				if chance > rng:RandomFloat() then
					enemy:AddCharmed(EntityRef(ppl), 62)
				end
			end
			---Gloucoma
			if ppl:HasCollectible(CollectibleType.COLLECTIBLE_GLAUCOMA) and 0.05 > rng:RandomFloat() then
				enemy:AddEntityFlags(EntityFlag.FLAG_CONFUSION)
			---Confusion
			elseif tearFlags & TearFlags.TEAR_CONFUSION == TearFlags.TEAR_CONFUSION then
				enemy:AddConfusion(EntityRef(ppl), 62, false)
			---Knockout drops
			elseif ppl:HasCollectible(CollectibleType.COLLECTIBLE_KNOCKOUT_DROPS) then
				local chance = 1/(10-functions.LuckCalc(ppl.Luck, 9))
				if chance > rng:RandomFloat() then
					enemy:AddConfusion(EntityRef(ppl), 62, false)
					knockback = 2*knockback
					enemy:AddEntityFlags(EntityFlag.FLAG_KNOCKED_BACK)
					enemy:AddEntityFlags(EntityFlag.FLAG_APPLY_IMPACT_DAMAGE)
				end
			---Iron Bar
			elseif ppl:HasCollectible(CollectibleType.COLLECTIBLE_IRON_BAR) then
				local chance = 1/(10-(functions.LuckCalc(ppl.Luck, 27)/3))
				if chance > rng:RandomFloat() then
					enemy:AddConfusion(EntityRef(ppl), 62, false)
				end
			end
			---Fear
			if tearFlags & TearFlags.TEAR_FEAR == TearFlags.TEAR_FEAR then
				enemy:AddFear(EntityRef(ppl), 62)
			---Dark Matter
			elseif ppl:HasCollectible(CollectibleType.COLLECTIBLE_DARK_MATTER) then
				local chance = 1/(3-(functions.LuckCalc(ppl.Luck, 20)/10))
				if chance > rng:RandomFloat() then
					enemy:AddFear(EntityRef(ppl), 62)
				end
			---Abaddon--Mom Perfume
			elseif ppl:HasCollectible(CollectibleType.COLLECTIBLE_ABADDON) or ppl:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_PERFUME) then
				local chance = 15/(100-functions.LuckCalc(ppl.Luck, 85))
				if chance > rng:RandomFloat() then
					enemy:AddFear(EntityRef(ppl), 62)
				end
			end
			---Freeze - Stone
			if tearFlags & TearFlags.TEAR_FREEZE == TearFlags.TEAR_FREEZE then
				enemy:AddFreeze(EntityRef(ppl), 62)
			---Mom Contacts
			elseif ppl:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_CONTACTS) then
				local chance = 1/(5-(functions.LuckCalc(ppl.Luck, 20)*0.15))
				if chance > rng:RandomFloat() then
					enemy:AddFreeze(EntityRef(ppl), 62)
				end
			end
			---Freeze - Gold
			if tearFlags & TearFlags.TEAR_MIDAS == TearFlags.TEAR_MIDAS then
				enemy:AddMidasFreeze(EntityRef(ppl), 62)
			---Eye of Greed
			elseif ppl:HasCollectible(CollectibleType.COLLECTIBLE_EYE_OF_GREED) and data.eclipsed.EyeGreedCounter and data.eclipsed.EyeGreedCounter == 20 then
				ppl:AddCoins(-1)
				enemy:AddMidasFreeze(EntityRef(ppl), 102)
				if ppl:GetNumCoins() > 0 then
					damage = 1.5*damage + 10
				end
			end
			---Freeze - Ice
			if (tearFlags & TearFlags.TEAR_ICE == TearFlags.TEAR_ICE or ppl:HasCollectible(CollectibleType.COLLECTIBLE_URANUS)) and not enemy:HasEntityFlags(EntityFlag.FLAG_ICE) then
				enemy:AddEntityFlags(EntityFlag.FLAG_ICE)
			end
			---TearPoison
			if tearFlags & TearFlags.TEAR_POISON == TearFlags.TEAR_POISON or ppl:HasCollectible(CollectibleType.COLLECTIBLE_SCORPIO) then
				enemy:AddPoison(EntityRef(ppl), 62, 2*ppl.Damage)
			elseif ppl:HasCollectible(CollectibleType.COLLECTIBLE_COMMON_COLD) then
				local chance = 1/(4-(functions.LuckCalc(ppl.Luck, 12)*0.25))
				if chance > rng:RandomFloat() then
					enemy:AddPoison(EntityRef(ppl), 62, 2*ppl.Damage)
				end
			elseif ppl:HasCollectible(CollectibleType.COLLECTIBLE_SERPENTS_KISS) then
				if 0.15 > rng:RandomFloat() then
					enemy:AddPoison(EntityRef(ppl), 62, 2*ppl.Damage)
				end
			elseif ppl:HasTrinket(TrinketType.TRINKET_PINKY_EYE) then
				local chance = 1/(10-(functions.LuckCalc(ppl.Luck, 18)*0.5))
				if chance > rng:RandomFloat() then
					enemy:AddPoison(EntityRef(ppl), 62, 2*ppl.Damage)
				end
			end
			---Poison Explosion
			if ppl:HasCollectible(CollectibleType.COLLECTIBLE_IPECAC) or (ppl:HasTrinket(TrinketType.TRINKET_TORN_CARD) and data.eclipsed.TornCardCounter and data.eclipsed.TornCardCounter == 15) then
				game:BombExplosionEffects(enemy.Position, 40, TearFlags.TEAR_POISON, Color.Default, ppl, 1, true, false, DamageFlag.DAMAGE_EXPLOSION)
			end
			---God Flesh
			if ppl:HasCollectible(CollectibleType.COLLECTIBLE_GODS_FLESH) then
				if 0.1 > rng:RandomFloat() then
					enemy:AddShrink(EntityRef(ppl), 152)
				end
			end
			---Slow
			if tearFlags & TearFlags.TEAR_SLOW == TearFlags.TEAR_SLOW then
				enemy:AddSlowing(EntityRef(ppl), 62, 0.5, Color(2,2,2,1,0.196,0.196,0.196))
			---Spider Bite
			elseif ppl:HasCollectible(CollectibleType.COLLECTIBLE_SPIDER_BITE) then
				local chance = 1/(4-(functions.LuckCalc(ppl.Luck, 15)/5))
				if chance > rng:RandomFloat() then
					enemy:AddSlowing(EntityRef(ppl), 77, 0.5, Color(2,2,2,1,0.196,0.196,0.196))
				end
			---Ball of Tar --Chewed Pen
			elseif ppl:HasCollectible(CollectibleType.COLLECTIBLE_BALL_OF_TAR) or ppl:HasTrinket(TrinketType.TRINKET_CHEWED_PEN) then
				local chance = 1/(10-(functions.LuckCalc(ppl.Luck, 18)*0.5))
				if chance > rng:RandomFloat() then
					enemy:AddSlowing(EntityRef(ppl), 52, 0.5, Color(0.15, 0.15, 0.15))
				end
			end
			---BleedingGrimoire
			if data.eclipsed.BleedingGrimoire then
				enemy:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
				enemyData.Bleeding = 62
			---Backstabber
			elseif ppl:HasCollectible(CollectibleType.COLLECTIBLE_BACKSTABBER) then
				if 0.25 > rng:RandomFloat() then
					enemy:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
					enemyData.Bleeding = 152
				end
			end
			---Rotten Tomato
			if ppl:HasCollectible(CollectibleType.COLLECTIBLE_ROTTEN_TOMATO) then
				local chance = 1/(6-functions.LuckCalc(ppl.Luck, 5))
				if chance > rng:RandomFloat() then
					enemy:AddEntityFlags(EntityFlag.FLAG_BAITED)
					enemyData.BaitedTomato = 122
				end
			end
			---Rainbow Cookie
			if ppl:HasCollectible(CollectibleType.COLLECTIBLE_PLAYDOUGH_COOKIE) then
				local index = rng:RandomInt(10)
				if index == 1 then
					enemy:AddPoison(EntityRef(ppl), 62, 2*ppl.Damage)
				elseif index == 2 then
					enemy:AddFear(EntityRef(ppl), 62)
				elseif index == 3 then
					enemy:AddShrink(EntityRef(ppl), 62)
				elseif index == 4 then
					enemy:AddSlowing(EntityRef(ppl), 62, 0.5, Color(2,2,2,1,0.196,0.196,0.196))
					if not enemy:HasEntityFlags(EntityFlag.FLAG_ICE) then enemy:AddEntityFlags(EntityFlag.FLAG_ICE) end
				elseif index == 5 then
					enemy:AddCharmed(EntityRef(ppl), 62)
				elseif index == 6 then
					enemy:AddBurn(EntityRef(ppl), 62, 2*ppl.Damage)
					local chance = 1/(10-(functions.LuckCalc(ppl.Luck, 12.86)*0.7))
					if chance > rng:RandomFloat() then
						game:BombExplosionEffects(enemy.Position, ppl.Damage, TearFlags.TEAR_BURN, Color.Default, ppl, 1, true, false, DamageFlag.DAMAGE_EXPLOSION)
					end
				elseif index == 7 then
					enemy:AddFreeze(EntityRef(ppl), 62)
				elseif index == 8 then
					enemy:AddEntityFlags(EntityFlag.FLAG_BAITED)
					enemy:GetData().BaitedTomato = 122
				elseif index == 9 then
					enemy:AddConfusion(EntityRef(ppl), 62, false)
				end
			end
			---Mysterious Liquid
			if ppl:HasCollectible(CollectibleType.COLLECTIBLE_MYSTERIOUS_LIQUID) then
				local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_GREEN, 0, enemy.Position, Vector.Zero, ppl):ToEffect()
				creep.CollisionDamage = 1
				creep:SetTimeout(60)
			end
			---Mulligan
			if ppl:HasCollectible(CollectibleType.COLLECTIBLE_MULLIGAN) then
				if 1/6 > rng:RandomFloat() then
					ppl:AddBlueFlies(1, enemy.Position, ppl)
				end
			end
			---Explosivo
			if ppl:HasCollectible(CollectibleType.COLLECTIBLE_EXPLOSIVO) then
				if 0.25 > rng:RandomFloat() then
					local expo = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.EXPLOSIVO, 0, enemy.Position, Vector.Zero, ppl):ToTear()
					expo:AddTearFlags(TearFlags.TEAR_STICKY)
					expo.CollisionDamage = ppl.Damage
					expo.FallingSpeed = 100
				end
			end
			---Mucormycosis
			if ppl:HasCollectible(CollectibleType.COLLECTIBLE_MUCORMYCOSIS) then
				if 0.25 > rng:RandomFloat() then
					local myco = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.SPORE, 0, enemy.Position, Vector.Zero, ppl):ToTear()
					myco:AddTearFlags(TearFlags.TEAR_SPORE)
					myco.CollisionDamage = ppl.Damage
					myco.FallingSpeed = 5
				end
			end
			---Sinus Infection
			if ppl:HasCollectible(CollectibleType.COLLECTIBLE_SINUS_INFECTION) then
				if 0.2 > rng:RandomFloat() then
					local booger = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.BOOGER, 0, enemy.Position, Vector.Zero, ppl):ToTear()
					if ppl:HasTrinket(TrinketType.TRINKET_NOSE_GOBLIN) and 0.5 > rng:RandomFloat() then
						booger:AddTearFlags(TearFlags.TEAR_HOMING)
					end
					booger:AddTearFlags(TearFlags.TEAR_BOOGER)
					booger.CollisionDamage = ppl.Damage
					booger.FallingSpeed = 100

				end
			---Nose Goblin
			elseif ppl:HasTrinket(TrinketType.TRINKET_NOSE_GOBLIN) then
				if 0.1 > rng:RandomFloat() then
					local booger = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.BOOGER, 0, enemy.Position, Vector.Zero, ppl):ToTear()
					booger:AddTearFlags(TearFlags.TEAR_BOOGER | TearFlags.TEAR_HOMING)
					booger.CollisionDamage = ppl.Damage
					booger.FallingSpeed = 100
				end
			end
			---Damage enemy
			enemy:TakeDamage(damage, 0, EntityRef(ppl), 1)
			enemy:AddVelocity((enemy.Position - auraPos):Resized(knockback))
			if data.eclipsed.MultipleAura then
				for _ = 1, data.eclipsed.MultipleAura do
					enemy:TakeDamage(damage, 0, EntityRef(ppl), 1)
				end
				data.eclipsed.MultipleAura = nil
			end
		end
	end
end

function functions.AuraInit(ppl, effect, scale, damage)
	local range = ppl.TearRange*scale
	range = functions.AuraRange(range, 520)
	effect.SpriteScale = effect.SpriteScale * range/100
	effect:SetTimeout(90)
	local auraPos = effect.Position
	---Lost Contact
	if ppl:HasCollectible(CollectibleType.COLLECTIBLE_LOST_CONTACT) then
		local bullets = Isaac.FindInRadius(auraPos, range, EntityPartition.BULLET)
		for _, bullet in pairs(bullets) do
			if bullet:ToProjectile() then
				bullet:Kill()
			end
		end
	end
	local enemies = Isaac.FindInRadius(auraPos, range, EntityPartition.ENEMY)
	if #enemies > 0 then
		functions.AuraEnemies(ppl, auraPos, enemies, damage, range)
	end
end

function functions.AuraCriketPatterSpawn(player, pos, radius)
	local velocity = 0
	local entityType = EntityType.ENTITY_EFFECT
	local entityVariant = EffectVariant.HALO
	local entitySubtype = 8
	local point = radius*math.cos(math.rad(45))
	local scale = 0.25
	local ul = Isaac.Spawn(entityType, entityVariant, entitySubtype, Vector(pos.X+point, pos.Y+point), Vector(velocity, velocity), player):ToEffect() -- up left
	local dl = Isaac.Spawn(entityType, entityVariant, entitySubtype, Vector(pos.X+point, pos.Y-point), Vector(velocity, -velocity), player):ToEffect() -- down left
	local ur = Isaac.Spawn(entityType, entityVariant, entitySubtype, Vector(pos.X-point, pos.Y+point), Vector(-velocity, velocity), player):ToEffect() -- up right
	local dr = Isaac.Spawn(entityType, entityVariant, entitySubtype, Vector(pos.X-point, pos.Y-point), Vector(-velocity, -velocity), player):ToEffect() -- down right
	functions.AuraInit(player, ul, scale, player.Damage/2)
	functions.AuraInit(player, dl, scale, player.Damage/2)
	functions.AuraInit(player, ur, scale, player.Damage/2)
	functions.AuraInit(player, dr, scale, player.Damage/2)
end

function functions.AuraLokiHornsPatterSpawn(player, pos, radius)
	local velocity = 0
	local entityType = EntityType.ENTITY_EFFECT
	local entityVariant = EffectVariant.HALO
	local entitySubtype = 8
	local scale = 0.25
	local ul = Isaac.Spawn(entityType, entityVariant, entitySubtype, Vector(pos.X, pos.Y+radius), Vector(0, velocity), player):ToEffect()--up
	local dl = Isaac.Spawn(entityType, entityVariant, entitySubtype, Vector(pos.X, pos.Y-radius), Vector(0, -velocity), player):ToEffect() --down
	local ur = Isaac.Spawn(entityType, entityVariant, entitySubtype, Vector(pos.X+radius, pos.Y), Vector(velocity, 0), player):ToEffect()--right
	local dr = Isaac.Spawn(entityType, entityVariant, entitySubtype, Vector(pos.X-radius, pos.Y), Vector(-velocity, 0), player):ToEffect() --left
	functions.AuraInit(player, ul, scale, player.Damage/2)
	functions.AuraInit(player, dl, scale, player.Damage/2)
	functions.AuraInit(player, ur, scale, player.Damage/2)
	functions.AuraInit(player, dr, scale, player.Damage/2)
end

function functions.UnbiddenAura(player, auraPos, delayOff, damageMulti, range, blockLasers)
	local room = game:GetRoom()
	local data = player:GetData()
	range = range or player.TearRange*0.5
	range = functions.AuraRange(range, 520)
	damageMulti = damageMulti or 1
	---if it's laser
	if data.eclipsed.UnbiddenBrimCircle and not blockLasers then
		local laser = player:FireTechXLaser(auraPos, Vector.Zero, range, player, damageMulti):ToLaser()
		laser.Color = Color(1,1,1,1,-0.5,0.7,1)
		laser:SetTimeout(data.eclipsed.UnbiddenBrimCircle)
		local newRange = (data.eclipsed.UnbiddenBDamageDelay)/(math.floor(player.MaxFireDelay) + 6)
		if newRange < 0.25 then newRange = 0.25 end
		laser:GetData().CollisionDamage = player.Damage * damageMulti
		laser.Radius = range*newRange
		laser:GetData().UnbiddenBrimLaser = data.eclipsed.UnbiddenBrimCircle-1
		if not delayOff then
			data.eclipsed.UnbiddenBDamageDelay = 0
		end
		return
	end
	---delay between pulses
	if not delayOff then
		data.eclipsed.UnbiddenBDamageDelay = 0
	end
	---Halo pulse
	local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HALO, 8, auraPos, Vector.Zero, player):ToEffect()
	effect:SetTimeout(90)
	effect.SpriteScale = effect.SpriteScale * range/100
	---play heartbeat
	if 6 + math.floor(player.MaxFireDelay) > 8 then
		sfx:Play(SoundEffect.SOUND_HEARTBEAT,0.5,2,false,3)
	end
	---Lost Contact
	if player:HasCollectible(CollectibleType.COLLECTIBLE_LOST_CONTACT) then
		local bullets = Isaac.FindInRadius(auraPos, range, EntityPartition.BULLET)
		for _, bullet in pairs(bullets) do
			if bullet:ToProjectile() then
				bullet:Kill()
			end
		end
	end
	---Large Zit
	if player:HasCollectible(CollectibleType.COLLECTIBLE_LARGE_ZIT) and 0.25 > player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_LARGE_ZIT):RandomFloat() then
		player:DoZitEffect(player:GetLastDirection())
	end
	---eye of greed
	if player:HasCollectible(CollectibleType.COLLECTIBLE_EYE_OF_GREED) then
		data.eclipsed.EyeGreedCounter = data.eclipsed.EyeGreedCounter or 0
		if data.eclipsed.EyeGreedCounter >= 20 then
			data.eclipsed.EyeGreedCounter = 0
		end
		data.eclipsed.EyeGreedCounter = data.eclipsed.EyeGreedCounter + 1
	end
	---grid damage
	local gridList = functions.AuraGridEffect(player, auraPos)
	---Torn Card
	if player:HasTrinket(TrinketType.TRINKET_TORN_CARD) then
		data.eclipsed.TornCardCounter = data.eclipsed.TornCardCounter or 0
		if data.eclipsed.TornCardCounter >= 15 then data.eclipsed.TornCardCounter = 0 end
		data.eclipsed.TornCardCounter = data.eclipsed.TornCardCounter + 1
	end
	---Holy light
	if player:HasCollectible(CollectibleType.COLLECTIBLE_HOLY_LIGHT) then
		local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_HOLY_LIGHT)
		local chance = 1/(10-(functions.LuckCalc(player.Luck, 8.89)*0.9))
		if chance > rng:RandomFloat() then
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACK_THE_SKY, 0, gridList[rng:RandomInt(#gridList)+1], Vector.Zero, player):ToEffect()
		end
	end
	---Cricket Body
	if player:HasCollectible(CollectibleType.COLLECTIBLE_CRICKETS_BODY) then
		functions.AuraCriketPatterSpawn(player, auraPos, range)
	end
	---Loki Horns
	if player:HasCollectible(CollectibleType.COLLECTIBLE_LOKIS_HORNS) then
		local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_LOKIS_HORNS)
		local chance = 0.25 + (player.Luck/20)
		if chance > rng:RandomFloat() then
			functions.AuraLokiHornsPatterSpawn(player, auraPos, range)
		end
	end
	---Eye Sore
	if player:HasCollectible(CollectibleType.COLLECTIBLE_EYE_SORE) then
		local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_EYE_SORE)
		local numSore = rng:RandomInt(4)
		for _ = 1, numSore do
			local escale = rng:RandomFloat()
			if escale < 0.15 then
				escale = 0.15
			elseif escale > 0.5 then
				escale = 0.5
			end
			local eaura = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HALO, 8, room:GetRandomPosition(1), Vector.Zero, player):ToEffect()
			eaura:SetTimeout(90)
			functions.AuraInit(player, eaura, escale, player.Damage)
		end
	end
	---Haemolacria
	if player:HasCollectible(CollectibleType.COLLECTIBLE_HAEMOLACRIA) then
		local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_HAEMOLACRIA)
		local numAura = rng:RandomInt(6)+6
		for _ = 1, numAura do
			local hscale = rng:RandomFloat()
			if hscale < 0.5 then
				hscale = 0.5
			elseif hscale > 0.8333 then
				hscale = 0.8333
			end
			local haura = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HALO, 8, room:GetRandomPosition(1), Vector.Zero, player):ToEffect()
			haura:SetTimeout(90)
			functions.AuraInit(player, haura, hscale, player.Damage * hscale)
		end
	end
	---Anti-gravity
	if player:HasCollectible(CollectibleType.COLLECTIBLE_ANTI_GRAVITY) then
		local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_ANTI_GRAVITY)
		--local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.MULTIDIMENSIONAL, 0, gridList[rng:RandomInt(#gridList)+1], Vector.Zero, player):ToTear()
		player:FireTear(gridList[rng:RandomInt(#gridList)+1], player:GetLastDirection() * player.ShotSpeed * 5, true, true, false, player, damageMulti)
	end
	---enemies
	local enemies = Isaac.FindInRadius(auraPos, range, EntityPartition.ENEMY)
	if #enemies == 0 then
		---Dead eye
		if player:HasCollectible(CollectibleType.COLLECTIBLE_DEAD_EYE) then
			if data.eclipsed.DeadEyeMissCounter < 3 then
				data.eclipsed.DeadEyeMissCounter = data.eclipsed.DeadEyeMissCounter + 1
			end
		end
	elseif #enemies > 0 then
		local damage = player.Damage * damageMulti
		---Dead eye
		if player:HasCollectible(CollectibleType.COLLECTIBLE_DEAD_EYE) then
			if data.eclipsed.DeadEyeCounter < 4 then
				data.eclipsed.DeadEyeMissCounter = 0
				data.eclipsed.DeadEyeCounter = data.eclipsed.DeadEyeCounter + 1
			end
			local DeadEyeMissChance = 0
			if data.eclipsed.DeadEyeMissCounter > 0 then
				DeadEyeMissChance = 0.5 -- if > 3
				if data.eclipsed.DeadEyeMissCounter == 1 then
					DeadEyeMissChance = 0.2
				elseif data.eclipsed.DeadEyeMissCounter == 2 then
					DeadEyeMissChance = 0.33
				end
			end
			if DeadEyeMissChance > player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_DEAD_EYE):RandomFloat() then
				data.eclipsed.DeadEyeCounter = 0
			end
			damage = player.Damage + player.Damage*(data.eclipsed.DeadEyeCounter/4)
		end
		---Eye Belial
		if player:HasCollectible(CollectibleType.COLLECTIBLE_EYE_OF_BELIAL) then
			local baura = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HALO, 8, player.Position, Vector.Zero, player):ToEffect()
			baura:SetTimeout(90)
			functions.AuraInit(player, baura, 1.3, damage*2)
		end
		for _, enemy in pairs(enemies) do
			---parasite
			if player:HasCollectible(CollectibleType.COLLECTIBLE_PARASITE) then
				if damage*0.5 > 1 then
					local paura = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HALO, 8, enemy.Position, Vector.Zero, player):ToEffect()
					paura:SetTimeout(90)
					functions.AuraInit(player, paura, 0.5, damage*0.5) -- damage
				end
			end
		end
		functions.AuraEnemies(player, auraPos, enemies, damage, range)
	end
end

function functions.TechDot5Shot(player)
	local range = player.TearRange/2
	range = functions.AuraRange(range)
	local laser = player:FireTechXLaser(player.Position, Vector.Zero, range, player, 1):ToLaser()
	--local laser = player:FireTechLaser(player.Position, LaserOffset.LASER_TECH5_OFFSET, player:GetShootingInput(), false, false, player, 1)
	laser:ClearTearFlags(laser.TearFlags)
	laser:GetData().UnbiddenTechDot5Laser = true
	laser.Timeout = player:GetData().eclipsed.UnbiddenBDamageDelay
end

function functions.Technology2Aura(player)
	local range = player.TearRange*0.33
	range = functions.AuraRange(range)
	local laser = player:FireTechXLaser(player.Position, Vector.Zero, range, player, 0.13):ToLaser()
	laser:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
	laser:GetData().UnbiddenTech2Laser = game:GetLevel():GetCurrentRoomIndex()
	laser:GetData().EnavleVisible = 0
	player:GetData().eclipsed.HasTech2Laser = true
end

function functions.GodHeadAura(player)
	local pos = player.Position
	local glowa = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HALO, 2, pos, Vector.Zero, player):ToEffect()
	glowa:SetTimeout(90)
	local range = player.TearRange*0.33--0.16
	range = functions.AuraRange(range)
	glowa.SpriteScale = glowa.SpriteScale * range/100
	glowa.Color = Color(0.5,1,2)
	local enemies = Isaac.FindInRadius(pos, range, EntityPartition.ENEMY)
	for _, enemy in pairs(enemies) do
		if enemy:IsVulnerableEnemy() and enemy:IsActiveEnemy() then
			enemy:TakeDamage(2, 0, EntityRef(player), 1)
		end
	end
end

function functions.WeaponAura(player, auraPos, frameCount, maxCharge, range, blockLasers, delayOff)
	delayOff = delayOff or nil
	range = range or player.TearRange*0.33
	range = functions.AuraRange(range)
	frameCount = frameCount or game:GetFrameCount()
	maxCharge = maxCharge or 30 + math.floor(player.MaxFireDelay)
	if maxCharge <= 0 then maxCharge = 30 end
	if frameCount%maxCharge == 0 then
		local tearsNum = functions.GetMultiShotNum(player)
		for _ = 0, tearsNum do -- start from 0. cause you must have at least 1 multiplier
			-- idk why knife is attacks 2 times (updates 2 times?)
			functions.UnbiddenAura(player, auraPos, delayOff, nil, range, blockLasers)
		end
	end
end

---Eclipse
function functions.EclipseAura(player)
	local data = player:GetData()
	data.eclipsed = data.eclipsed or {}
	data.eclipsed.EclipseDamageDelay = data.eclipsed.EclipseDamageDelay or 0
	if data.eclipsed.EclipseDamageDelay < 6 + math.floor(player.MaxFireDelay) then --  math.floor(player.MaxFireDelay)
		data.eclipsed.EclipseDamageDelay = data.eclipsed.EclipseDamageDelay + 1
	end
	---damage boosts count (Curse of Darkness)
	data.eclipsed.EclipseBoost = data.eclipsed.EclipseBoost or 0
	if data.eclipsed.EclipseBoost > 0 and game:GetLevel():GetCurses() & LevelCurse.CURSE_OF_DARKNESS == 0 then
		data.eclipsed.EclipseBoost = 0
	end
	if game:GetLevel():GetCurses() & LevelCurse.CURSE_OF_DARKNESS > 0 then
		if not data.eclipsed.EclipseBoost or data.eclipsed.EclipseBoost ~= functions.GetItemsCount(player, enums.Items.Eclipse) then
			data.eclipsed.EclipseBoost = functions.GetItemsCount(player, enums.Items.Eclipse)
			player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
			player:EvaluateItems()
		end
	elseif data.EclipseBoost then
		data.eclipsed.EclipseBoost = nil
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		player:EvaluateItems()
	end
	---do pulse
	if player:GetPlayerType() ~= enums.Characters.UnbiddenB and player:GetFireDirection() ~= -1 and data.eclipsed.EclipseDamageDelay >= 6 + math.floor(player.MaxFireDelay) then --
		data.eclipsed.EclipseDamageDelay = 0
		functions.UnbiddenAura(player, player.Position, true)
	end
end

---AbihuFlameShoot
function functions.ShootAbihuFlame(player, velocity, damage, timeout, pos, stop)
	pos = pos or player.Position
	timeout = timeout or math.floor(player.TearRange/4)
	velocity = velocity + player:GetTearMovementInheritance(velocity)
	damage = damage or player.Damage*3
	local flame = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLUE_FLAME, 0, pos, velocity, player):ToEffect()
	flame:SetTimeout(timeout)
	flame:GetSprite():ReplaceSpritesheet(0, "resources-dlc3/gfx/effects/effect_005_fire_white.png")
	flame:GetSprite():LoadGraphics()
	flame:SetColor(Color(1,1,1,0), 1, 100, false, false)
	flame.CollisionDamage = damage
	flame:GetData().AbihuFlame = true
	flame:GetData().Stop = stop
	flame.Parent = player
	return flame
end

---AbihuSplit
function functions.AbihuSplit(flame, ppl)
	local flameData = flame:GetData()
	if flameData.Stop then return end
	flameData.Stop = true
	local timeout = flame.Timeout
	local damage = flame.CollisionDamage/2
	if flameData.LudovicoFire then timeout = math.floor(ppl.TearRange/4) end
	if flameData.Split and flameData.Quadsplit then
		flameData.SplitRest = game:GetFrameCount()
		mod.functions.ShootAbihuFlame(ppl, flame.Velocity:Rotated(135), damage, timeout, flame.Position, true)
		mod.functions.ShootAbihuFlame(ppl, flame.Velocity:Rotated(-135), damage, timeout, flame.Position, true)
		mod.functions.ShootAbihuFlame(ppl, flame.Velocity:Rotated(90), damage, timeout, flame.Position, true)
		mod.functions.ShootAbihuFlame(ppl, flame.Velocity:Rotated(-90), damage, timeout, flame.Position, true)
		mod.functions.ShootAbihuFlame(ppl, flame.Velocity:Rotated(45), damage, timeout, flame.Position, true)
		mod.functions.ShootAbihuFlame(ppl, flame.Velocity:Rotated(-45), damage, timeout, flame.Position, true)
	elseif flameData.Quadsplit then
		flameData.SplitRest = game:GetFrameCount()
		mod.functions.ShootAbihuFlame(ppl, flame.Velocity:Rotated(135), damage, timeout, flame.Position, true)
		mod.functions.ShootAbihuFlame(ppl, flame.Velocity:Rotated(-135), damage, timeout, flame.Position, true)
		mod.functions.ShootAbihuFlame(ppl, flame.Velocity:Rotated(45), damage, timeout, flame.Position, true)
		mod.functions.ShootAbihuFlame(ppl, flame.Velocity:Rotated(-45), damage, timeout, flame.Position, true)
	elseif flameData.Split and flame.CollisionDamage > 1 then
		flameData.SplitRest = game:GetFrameCount()
		mod.functions.ShootAbihuFlame(ppl, flame.Velocity:Rotated(90), damage, timeout, flame.Position, true)
		mod.functions.ShootAbihuFlame(ppl, flame.Velocity:Rotated(-90), damage, timeout, flame.Position, true)
	end 
end

		

---AbihuFlameInit
function functions.AbihuFlameInit(player, flame)
	local flameData = flame:GetData()
	local tearFlags = player.TearFlags
	---Burn
	if tearFlags & TearFlags.TEAR_BURN == TearFlags.TEAR_BURN or player:HasCollectible(CollectibleType.COLLECTIBLE_FIRE_MIND) then
		flame.Color = Color(-1,-1,-1,1,1,1,1)
		flameData.Burn = true
	end
	---Poison
	if tearFlags & TearFlags.TEAR_POISON == TearFlags.TEAR_POISON or player:HasCollectible(CollectibleType.COLLECTIBLE_COMMON_COLD) or player:HasCollectible(CollectibleType.COLLECTIBLE_IPECAC) or player:HasCollectible(CollectibleType.COLLECTIBLE_SERPENTS_KISS) then
		flame.Color = Color(0, 1, 0, 1, 0,1,0)
		flameData.Poison = true
	end
	---Explosive
	if player:HasCollectible(CollectibleType.COLLECTIBLE_IPECAC) then
		flameData.Ipecac = 0
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_FIRE_MIND) then
		flameData.FireMind = 13
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_EXPLOSIVO) then
		flameData.Explosive = 0.25
	end
	---Slow white
	if tearFlags & TearFlags.TEAR_SLOW == TearFlags.TEAR_SLOW or player:HasCollectible(CollectibleType.COLLECTIBLE_SPIDER_BITE) then
		flame.Color = Color(1,1,1,1,0.5,0.5,0.5)
		flameData.Slow = Color(2,2,2,1,0.196,0.196,0.196)
	---Slow black
	elseif player:HasCollectible(CollectibleType.COLLECTIBLE_BALL_OF_TAR) then
		--flame.Color = Color(-1,-1,-1,1,1,1,1)
		flameData.Slow = Color(0.15, 0.15, 0.15, 1, 0, 0, 0)
	end
	---midas
	if tearFlags & TearFlags.TEAR_MIDAS == TearFlags.TEAR_MIDAS or player:HasCollectible(CollectibleType.COLLECTIBLE_MIDAS_TOUCH) then
		flame.Color = Color(2, 1, 0, 1, 2,1,0)
		flameData.Midas = true
	end
	---fear
	if tearFlags & TearFlags.TEAR_FEAR == TearFlags.TEAR_FEAR or player:HasCollectible(CollectibleType.COLLECTIBLE_ABADDON) or player:HasCollectible(CollectibleType.COLLECTIBLE_DARK_MATTER) or player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_PERFUME) then
		flame.Color = Color(-10, -10, -10, 1, 1, 1, 1)
		flameData.Fear = true
	end
	---charm
	if tearFlags & TearFlags.TEAR_CHARM == TearFlags.TEAR_CHARM or player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_EYESHADOW) then
		flame.Color = Color(0.4, 0.15, 0.38, 1, 1, 0.1, 0.3)
		flameData.Charm = true
	end
	---confusion
	if tearFlags & TearFlags.TEAR_CONFUSION == TearFlags.TEAR_CONFUSION  or player:HasCollectible(CollectibleType.COLLECTIBLE_IRON_BAR) or player:HasCollectible(CollectibleType.COLLECTIBLE_GLAUCOMA) or player:HasCollectible(CollectibleType.COLLECTIBLE_KNOCKOUT_DROPS) then
		flameData.Confusion = true
	end
	---freeze
	if tearFlags & TearFlags.TEAR_FREEZE == TearFlags.TEAR_FREEZE or player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_CONTACTS) then
		flame.Color = Color(0, 0, 0, 1, 0.5, 0.5, 0.5)
		flameData.Freeze = true
	end
	---ice
	if tearFlags & TearFlags.TEAR_ICE == TearFlags.TEAR_ICE or player:HasCollectible(CollectibleType.COLLECTIBLE_URANUS) then
		flame.Color = Color(1, 1, 1, 1, 0, 0, 0)
		flameData.Ice = true
	end
	---bait
	if tearFlags & TearFlags.TEAR_BAIT == TearFlags.TEAR_BAIT or player:HasCollectible(CollectibleType.COLLECTIBLE_ROTTEN_TOMATO) then
		flame.Color = Color(0.7, 0.14, 0.1, 1, 1, 0, 0)
		flameData.BaitedTomato = true
	end
	---magnetize
	if tearFlags & TearFlags.TEAR_MAGNETIZE == TearFlags.TEAR_MAGNETIZE or player:HasCollectible(CollectibleType.COLLECTIBLE_LODESTONE) then
		flameData.Magnetize = true
	end
	---rift
	if tearFlags & TearFlags.TEAR_RIFT == TearFlags.TEAR_RIFT or player:HasCollectible(CollectibleType.COLLECTIBLE_OCULAR_RIFT) then
		flame.Color = Color(-2, -2, -2, 1, 1, 1, 1)
		flameData.Rift = 0
	end
	---boomerang
	if tearFlags & TearFlags.TEAR_BOOMERANG == TearFlags.TEAR_BOOMERANG then
		flameData.Boomerang = 5 -- 5 frames
	end
	---mulligan
	if tearFlags & TearFlags.TEAR_MULLIGAN == TearFlags.TEAR_MULLIGAN or player:HasCollectible(CollectibleType.COLLECTIBLE_MULLIGAN) then
		flameData.Mulligan = true
	end
	---split
	if tearFlags & TearFlags.TEAR_SPLIT == TearFlags.TEAR_SPLIT then
		flame.Color = Color(0.9, 0.3, 0.08, 1)
		flameData.Split = true
	end
	---quadsplit
	if tearFlags & TearFlags.TEAR_QUADSPLIT == TearFlags.TEAR_QUADSPLIT then
		flameData.Quadsplit = true
	end
	---spectral
	if tearFlags & TearFlags.TEAR_SPECTRAL == TearFlags.TEAR_SPECTRAL then
		flameData.Spectral = true
		flame.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
	end
	---Eye of Belial
	if player:HasCollectible(CollectibleType.COLLECTIBLE_EYE_OF_BELIAL) then
		flame.Color = Color(1.5,0,0)
		flameData.Belial = true
	end
	---homing
	if tearFlags & TearFlags.TEAR_HOMING == TearFlags.TEAR_HOMING then
		flame.Color = Color(0.4, 0.15, 0.38, 1, 1, 0.1, 1)
		flameData.Homing = true
	end
end

---BeggarRemoveRewards
function functions.RemoveRecentRewards(pos) --ff reheated (stolen)
    for _, pickup in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP)) do
        if pickup.FrameCount <= 1 and pickup.SpawnerType == 0
        and pickup.Position:DistanceSquared(pos) <= 400 then
            pickup:Remove()
        end
    end
    for _, trollbomb in ipairs(Isaac.FindByType(EntityType.ENTITY_BOMB)) do
        if (trollbomb.Variant == 3 or trollbomb.Variant == 4)
        and trollbomb.FrameCount <= 1 and trollbomb.SpawnerType == 0
        and trollbomb.Position:DistanceSquared(pos) <= 400 then
            trollbomb:Remove()
        end
    end
end

function functions.BeggarWasBombed(beggar, removeRewards)
	--- beggar bombing
	local level = game:GetLevel()
	local explosions = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.BOMB_EXPLOSION)
	local mamaMega = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.MAMA_MEGA_EXPLOSION)
	removeRewards = removeRewards or false
	if #mamaMega > 0 then
		beggar:Kill()
		beggar:Remove()
		if removeRewards then
			functions.RemoveRecentRewards(beggar.Position)
		end
		level:SetStateFlag(LevelStateFlag.STATE_BUM_KILLED, true)
		return true
	elseif #explosions > 0 then
		for _, explos in pairs(explosions) do
			if explos:GetSprite():GetFrame() < 3 then
				if explos.Position:Distance(beggar.Position) <= 90 * explos.SpriteScale.X then
					beggar:Kill()
					beggar:Remove()
					if removeRewards then
						functions.RemoveRecentRewards(beggar.Position)
					end
					level:SetStateFlag(LevelStateFlag.STATE_BUM_KILLED, true)
					return true
				end
			end
		end
	end
	return false
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



---Gravity Bombs
function functions.InitGravityBomb(bomb)
	--- apply effect of black hole bomb
	local bombData = bomb:GetData()
	bombData.eclipsed = bombData.eclipsed or {}
	bombData.eclipsed.GravityBombs = true
	--bomb:AddTearFlags(TearFlags.TEAR_ATTRACTOR | TearFlags.TEAR_MAGNETIZE)
	bomb:AddEntityFlags(EntityFlag.FLAG_MAGNETIZED) -- else it wouldn't attract tears
	bomb:AddTearFlags(TearFlags.TEAR_RIFT)
	local holeEffect = Isaac.Spawn(EntityType.ENTITY_EFFECT, enums.Effects.BlackHoleBombsEffect, 0, bomb.Position, Vector.Zero, nil):ToEffect()
	local holeData = holeEffect:GetData()
	holeEffect.Parent = bomb
	holeEffect.DepthOffset = -100
	holeEffect.Color = Color(0,0,0,1,0,0,0) -- set black color
	holeData.Gravity = true
	holeData.GravityForce = 50
	holeData.GravityRange = 250
	holeData.GravityGridRange = 5
end
---Frost Bombs
function functions.InitFrostyBomb(bomb)
	--- apply effect of ice cube bomb
	local bombData = bomb:GetData()
	bombData.eclipsed = bombData.eclipsed or {}
	bombData.eclipsed.FrostyBombs = true
	--bomb:AddEntityFlags(EntityFlag.FLAG_ICE)  --useless to add
	bomb:AddTearFlags(TearFlags.TEAR_SLOW | TearFlags.TEAR_ICE)
	bombData.eclipsed.CreepVariant = EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL

	if bomb:HasTearFlags(TearFlags.TEAR_GLITTER_BOMB) then
		bombData.eclipsed.FrostyCreepColor = datatables.PinkColor
	elseif bomb:HasTearFlags(TearFlags.TEAR_BLOOD_BOMB) then
		bombData.eclipsed.CreepVariant = EffectVariant.PLAYER_CREEP_RED
	elseif bomb:HasTearFlags(TearFlags.TEAR_STICKY) then
		bombData.eclipsed.CreepVariant = EffectVariant.PLAYER_CREEP_WHITE
	elseif bomb:HasTearFlags(TearFlags.TEAR_BUTT_BOMB) then
		bombData.eclipsed.CreepVariant = EffectVariant.CREEP_SLIPPERY_BROWN
	elseif bomb:HasTearFlags(TearFlags.TEAR_POISON) then
		bombData.eclipsed.CreepVariant = EffectVariant.PLAYER_CREEP_GREEN
	end
end
---Dice Bombs
function functions.InitDiceyBomb(bomb)
	local bombData = bomb:GetData()
	bombData.eclipsed = bombData.eclipsed or {}
	bombData.eclipsed.DiceBombs = true
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
					if rng:RandomFloat() < 0.66 then
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
function functions.InitBatteryBomb(bomb)
	local bombData = bomb:GetData()
	bombData.eclipsed = bombData.eclipsed or {}
	bombData.eclipsed.BatteryBombs = true
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

	local charge = 2
	if  damage >= 175.0 then
		charge = 12
	elseif damage >= 100 then
		charge = 6
	end

	for _, player in pairs(players) do
		player = player:ToPlayer()
		local chargingEffect = false -- leave it as nil
		for slot = 0, 2 do
			if player:GetActiveItem(slot) ~= 0 then --and chargingActive then
				local activeItem = player:GetActiveItem(slot) -- active item on given slot
				local activeCharge = player:GetActiveCharge(slot) -- item charge
				local batteryCharge = player:GetBatteryCharge(slot) -- extra charge (battery item)
				local activeMaxCharge = Isaac.GetItemConfig():GetCollectible(activeItem).MaxCharges
				local activeChargeType = Isaac.GetItemConfig():GetCollectible(activeItem).ChargeType
				if activeChargeType == ItemConfig.CHARGE_NORMAL then
					charge = charge + activeCharge
					if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) then
						charge = charge + activeCharge + batteryCharge
					else
						if charge > activeMaxCharge then
							charge = activeMaxCharge
						end
					end
					player:SetActiveCharge(charge, slot)
					chargingEffect = slot
					break
				elseif activeChargeType == ItemConfig.CHARGE_TIMED then
					charge = activeMaxCharge
					if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) then
						charge = 2 * charge
					end
					player:SetActiveCharge(charge, slot)
					chargingEffect = slot
					break
				--else
				--	print('special', activeItem)
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
function functions.InitDeadBomb(bomb)
	local bombData = bomb:GetData()
	bombData.eclipsed = bombData.eclipsed or {}
	bombData.eclipsed.DeadBombs = true
	bomb:AddTearFlags(TearFlags.TEAR_BONE)
end
function functions.BonnyBlast(rng, bombPos, radius, player)
	local enemies = Isaac.FindInRadius(bombPos, radius, EntityPartition.ENEMY)
	if #enemies > 0 then
		for _, enemy in pairs(enemies) do
			if enemy:ToNPC() and enemy:IsVulnerableEnemy() and enemy:IsActiveEnemy() and enemy:HasMortalDamage() then
				if rng:RandomFloat() < 0.16 then
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

EclipsedMod.functions = functions