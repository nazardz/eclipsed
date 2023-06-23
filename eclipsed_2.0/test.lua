EclipsedMod = RegisterMod("Eclipsed", 1)
local mod = EclipsedMod
local json = require("json")
local enums = include("scripts_eclipsed.enums")
local datatables = include("scripts_eclipsed.datatables")
local functions = include("scripts_eclipsed.functions")
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
			local idx = functions.GetPlayerIndex(player)
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
					local idx = functions.GetPlayerIndex(player)
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
					if player:HasCollectible(enums.Items.RubberDuck) then
						functions.EvaluateDuckLuck(player, data.eclipsed.DuckCurrentLuck)
					end
					if data.eclipsed.RedPillDamageUp then
						player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
					end
					player:EvaluateItems()
				end
			end
		end
	else
		mod.PersistentData = functions.ResetPersistentData()
	end
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.onStart)

--- RENDER
function mod:onRender()
	functions.CurseIconRender()
	
	--local player = Isaac.GetPlayer(0)
	--local data = player:GetData()
	
	
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.onRender)


--- EVAL CACHE
function mod:onCache(player, cacheFlag)
	player = player:ToPlayer()
	local data = player:GetData()
	if data.eclipsed then
		if cacheFlag == CacheFlag.CACHE_LUCK then
			if player:HasCollectible(enums.Items.RubberDuck) and data.eclipsed.DuckCurrentLuck then
				player.Luck = player.Luck + data.eclipsed.DuckCurrentLuck
			end
			if player:HasCollectible(enums.Items.VoidKarma) and data.eclipsed.KarmaStats then
				player.Luck = player.Luck + data.eclipsed.KarmaStats.Luck
			end
			if data.eclipsed.DeuxExLuck then
				player.Luck = player.Luck + data.eclipsed.DeuxExLuck
			end
			if data.eclipsed.MisfortuneLuck then
				player.Luck = player.Luck + datatables.MisfortuneLuck
			end
		end
		if cacheFlag == CacheFlag.CACHE_DAMAGE then
			if data.eclipsed.RedPillDamageUp then
				player.Damage = player.Damage + data.eclipsed.RedPillDamageUp
			end
			if data.eclipsed.RedLotusDamage then -- save damage even if you removed item
				player.Damage = player.Damage + data.eclipsed.RedLotusDamage
			end
			if player:HasCollectible(enums.Items.VoidKarma) and data.eclipsed.KarmaStats then
				player.Damage = player.Damage + data.eclipsed.KarmaStats.Damage
			end
			if data.eclipsed.EclipseBoost and data.eclipsed.EclipseBoost > 0 then
			    player.Damage = player.Damage + player.Damage * (ModVard.EclipseDamageBoost * data.eclipsed.EclipseBoost)
			end
			if data.eclipsed.HeartTransplantUseCount and data.eclipsed.HeartTransplantUseCount > 0 then
				local damageMulti = datatables.HeartTransplant.ChainValue[data.eclipsed.HeartTransplantUseCount][1]
				player.Damage = player.Damage + player.Damage * damageMulti
			end
		end
		if cacheFlag == CacheFlag.CACHE_FIREDELAY then
			if player:HasCollectible(enums.Items.VoidKarma) and data.eclipsed.KarmaStats then
				local stat_cache = player.MaxFireDelay + data.eclipsed.KarmaStats.Firedelay
				if player.MaxFireDelay > 5 then
					stat_cache = 5 
				end
				if player.MaxFireDelay > 1 then
					player.MaxFireDelay = stat_cache
				end
			end
			if data.eclipsed.HeartTransplantUseCount and data.eclipsed.HeartTransplantUseCount > 0 then
				local tearsUP = datatables.HeartTransplant.ChainValue[data.eclipsed.HeartTransplantUseCount][2]
				player.MaxFireDelay = player.MaxFireDelay + tearsUP
			end
		end
		if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
			if player:HasCollectible(enums.Items.VoidKarma) and data.eclipsed.KarmaStats then
				player.ShotSpeed = player.ShotSpeed + data.eclipsed.KarmaStats.Shotspeed
			end
		end
		if cacheFlag == CacheFlag.CACHE_RANGE then
			if player:HasCollectible(enums.Items.VoidKarma) and data.eclipsed.KarmaStats then
				player.TearRange = player.TearRange + data.eclipsed.KarmaStats.Range
			end
		end
		if cacheFlag == CacheFlag.CACHE_SPEED then
			if player:HasCollectible(enums.Items.MiniPony) and player.MoveSpeed < datatables.MiniPony.MoveSpeed then
				player.MoveSpeed = datatables.MiniPony.MoveSpeed
			end
			if player:HasCollectible(enums.Items.VoidKarma) and data.KarmaStats then
				player.MoveSpeed = player.MoveSpeed + data.eclipsed.KarmaStats.Speed
			end
			if data.HeartTransplantUseCount and data.HeartTransplantUseCount > 0 then
				local speed = datatables.HeartTransplant.ChainValue[data.eclipsed.HeartTransplantUseCount][3]
				player.MoveSpeed = player.MoveSpeed + speed
			end
		end
		if cacheFlag == CacheFlag.CACHE_TEARCOLOR then
			if player:HasCollectible(enums.Items.MeltedCandle) then
				player.TearColor = datatables.MeltedCandle.TearColor
			end
		end
		if cacheFlag == CacheFlag.CACHE_FLYING then
			if player:HasCollectible(enums.Items.MiniPony) or player:HasCollectible(enums.Items.LongElk) or player:HasCollectible(enums.Items.Viridian) or player:HasCollectible(enums.Items.MewGen) then
				player.CanFly = true
			end
		end
		if cacheFlag == CacheFlag.CACHE_FAMILIARS then
			functions.CheckFamiliar(player, enums.Items.RedBag, enums.Familiars.RedBag)
			functions.CheckFamiliar(player, enums.Items.Lililith, enums.Familiars.Lililith)
			functions.CheckFamiliar(player, enums.Items.NadabBrain, enums.Familiars.NadabBrain)

			functions.CheckFamiliar(player, enums.Items.AbihuFam, enums.Familiars.AbihuFam, datatables.AbihuFam.Subtype)
			--[[ abihu familiars
			local profans = functions.GetItemsCount(player, enums.Items.AbihuFam)
			local punches = functions.GetItemsCount(player, CollectibleType.COLLECTIBLE_PUNCHING_BAG)
			if profans > 0 then
				if punches > 0 then
					local entities2 = Isaac.FindByType(EntityType.ENTITY_FAMILIAR, enums.Familiars.AbihuFam, _, true, false)
					for _, punch in pairs(entities2) do
						punch:Remove()
					end
					player:CheckFamiliar(enums.Familiars.AbihuFam, punches, RNG(), Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_PUNCHING_BAG), 0)
				end
				player:CheckFamiliar(enums.Familiars.AbihuFam, profans, RNG(), Isaac.GetItemConfig():GetCollectible(enums.Items.AbihuFam), datatables.AbihuFam.Subtype)
			end
			--]]
		end
	end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.onCache)

--- PLAYER TAKE DMG
function mod:onPlayerTakeDamage(entity, _, flags) --entity, amount, flags, source, countdown
	local player = entity:ToPlayer()
	local data = player:GetData()
	local tempEffects = player:GetEffects()
	--- soul of nadab and abihu
	if data.eclipsed.ForRoom.SoulNadabAbihu and (
		flags & DamageFlag.DAMAGE_FIRE == DamageFlag.DAMAGE_FIRE or
		flags & DamageFlag.DAMAGE_EXPLOSION == DamageFlag.DAMAGE_EXPLOSION or
		flags & DamageFlag.DAMAGE_TNT == DamageFlag.DAMAGE_TNT)
	then
		return false
	end

	if player:HasCurseMistEffect() or player:IsCoopGhost() then return end
	--- agony box
	if player:HasCollectible(enums.Items.AgonyBox, true) and flags & DamageFlag.DAMAGE_FAKE == 0 then
		for slot = 0, 2 do -- 0, 3
			if player:GetActiveItem(slot) == enums.Items.AgonyBox then
				local activeCharge = player:GetActiveCharge(slot) -- item charge
				local batteryCharge = player:GetBatteryCharge(slot) -- extra charge (battery item)
				local newCharge = batteryCharge + activeCharge - 1
				if activeCharge > 0 then
					player:SetActiveCharge(newCharge, slot)
					sfx:Play(SoundEffect.SOUND_BATTERYDISCHARGE)
					player:SetMinDamageCooldown(120) -- 4 seconds
					if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
						local wisp = player:AddWisp(CollectibleType.COLLECTIBLE_DULL_RAZOR, player.Position, true, false)
						if wisp then
							wisp.Color = Color(0.5, 1, 0.5)
							wisp.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
						end
					end
					return false
				end
			end
		end
	end
	--- spike collar
	if player:HasCollectible(enums.Items.SpikedCollar) and flags & DamageFlag.DAMAGE_FAKE == 0 and flags & DamageFlag.DAMAGE_INVINCIBLE == 0 then
		player:UseActiveItem(CollectibleType.COLLECTIBLE_RAZOR_BLADE, datatables.NoAnimNoAnnounMimicNoCostume)
		return false
	end
	-- mongo baby
	if player:HasCollectible(enums.Items.MongoCells) and flags & DamageFlag.DAMAGE_NO_PENALTIES == 0 then
		local rng = player:GetCollectibleRNG(enums.Items.MongoCells)
		if player:HasCollectible(CollectibleType.COLLECTIBLE_DRY_BABY) and rng:RandomFloat() < datatables.MongoCells.OnHurtChance then
			player:UseActiveItem(CollectibleType.COLLECTIBLE_NECRONOMICON, datatables.NoAnimNoAnnounMimicNoCostume)
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_FARTING_BABY) and rng:RandomFloat() < datatables.MongoCells.OnHurtChance then
			local bean = datatables.MongoCells.FartBabyBeans[rng:RandomInt(#datatables.MongoCells.FartBabyBeans)+1]
			player:UseActiveItem(bean, datatables.NoAnimNoAnnounMimicNoCostume)
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BBF) then
			game:BombExplosionEffects(player.Position, datatables.MongoCells.ExplosionDamage, player:GetBombFlags(), Color.Default, player, 1, true, false, DamageFlag.DAMAGE_EXPLOSION)
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BOBS_BRAIN) then
			game:BombExplosionEffects(player.Position, datatables.MongoCells.ExplosionDamage, player:GetBombFlags(), Color.Default, player, 1, true, false, DamageFlag.DAMAGE_EXPLOSION)
			local cloud = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SMOKE_CLOUD, 0, player.Position, Vector.Zero, player):ToEffect()
			cloud:SetTimeout(150)
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_HOLY_WATER) then
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_HOLYWATER, 0, player.Position, Vector.Zero, player):SetColor(Color(1,1,1,0), 2, 1, false, false)
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_DEPRESSION) and rng:RandomFloat() < datatables.MongoCells.OnHurtChance then
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACK_THE_SKY, 0, player.Position, Vector.Zero, player)
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_RAZOR) then
			player:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
		end
	end
	-- lost flower
	if player:HasTrinket(enums.Trinkets.LostFlower) and flags & DamageFlag.DAMAGE_NO_PENALTIES == 0 and flags & DamageFlag.DAMAGE_RED_HEARTS == 0 then
		functions.RemoveThrowTrinket(player, enums.Trinkets.LostFlower)
	end
	--- Rubik Cubelet
	if player:HasTrinket(enums.Trinkets.RubikCubelet) then
		local numTrinket = player:GetTrinketMultiplier(enums.Trinkets.RubikCubelet)
		if player:GetTrinketRNG(enums.Trinkets.RubikCubelet):RandomFloat() < datatables.RubikCubelet.TriggerChance * numTrinket then
			functions.RerollTMTRAINER(player)
		end
	end
	--- Cyber Cutlet
	if player:HasTrinket(enums.Trinkets.Cybercutlet) and flags & DamageFlag.DAMAGE_FAKE == 0 and flags & DamageFlag.DAMAGE_NO_PENALTIES == 0 and flags & DamageFlag.DAMAGE_RED_HEARTS == 0 then
		player:TryRemoveTrinket(enums.Trinkets.Cybercutlet)
		player:AddHearts(2)
		sfx:Play(SoundEffect.SOUND_VAMP_GULP)
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HEART, 0, Vector(player.Position.X, player.Position.Y-70), Vector.Zero, nil)
	end
end

--- PLAYER PEFFECT --
function mod:onPEffectUpdate(player)
	local level = game:GetLevel()
	local room = game:GetRoom()
	local data = player:GetData()
	local currentCurses = level:GetCurses()
	local sprite = player:GetSprite()
	local tempEffects = player:GetEffects()
	if not mod.ModVars then mod.ModVars = {} end
	if not data.eclipsed then data.eclipsed = {} end
	if not data.eclipsed.ForRoom then data.eclipsed.ForRoom = {} end
	if not data.eclipsed.ForLevel then data.eclipsed.ForLevel = {} end
	if not data.eclipsed.ForLevelEffects then data.eclipsed.ForLevelEffects = {} end

	local holdingCard = player:GetCard(0)

	--[[ Kitten Shuffle
	if data.eclipsed.KittenShuffle2 then
		data.eclipsed.KittenShuffle2 = data.eclipsed.KittenShuffle2 - 1
		if data.eclipsed.KittenShuffle2 <= 0 then
			player:RemoveCollectible(CollectibleType.COLLECTIBLE_MISSING_NO)
			data.eclipsed.KittenShuffle2 = nil
		end
	end
	--]]

	-- curse Misfortune
	if currentCurses & enums.Curses.Misfortune > 0 and not data.eclipsed.MisfortuneLuck then
		data.eclipsed.MisfortuneLuck = true
		player:AddCacheFlags(CacheFlag.CACHE_LUCK)
		player:EvaluateItems()
	elseif currentCurses & enums.Curses.Misfortune == 0 and data.eclipsed.MisfortuneLuck then
		data.eclipsed.MisfortuneLuck = nil
		player:AddCacheFlags(CacheFlag.CACHE_LUCK)
		player:EvaluateItems()
	end

	-- curse Montezums
	if currentCurses & enums.Curses.Montezuma > 0 and not player.CanFly and game:GetFrameCount()%12 == 0 then
		local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_SLIPPERY_BROWN, 0, player.Position, Vector.Zero, nil):ToEffect()
		creep.SpriteScale = creep.SpriteScale * 0.1
	end

	-- exploding kitten
	if datatables.ExplodingKittens.BombKards[holdingCard] then
		data.ExplodingKitten = data.ExplodingKitten or datatables.ExplodingKittens.ActivationTimer
		data.ExplodingKitten = data.ExplodingKitten - 1
		if data.ExplodingKitten <= 0 then
			functions.ExplodingKittenCurse(player, holdingCard)
			player:AnimateCard(holdingCard)
			player:SetCard(0, 0)
			data.ExplodingKitten = nil
			game:GetHUD():ShowItemText("!!!")
		elseif data.ExplodingKitten%30 == 0 then
			local text = math.floor(data.ExplodingKitten/30)
			game:GetHUD():ShowItemText(tostring(text))
		end
	elseif data.ExplodingKitten then
		data.ExplodingKitten = nil
	end

	-- domino 25
	if data.eclipsed.Domino25 then
		data.eclipsed.Domino25 = data.eclipsed.Domino25 - 1
		if data.eclipsed.Domino25 <= 0 then
			local enemies = Isaac.FindInRadius(room:GetCenterPos(), 5000, EntityPartition.ENEMY)
			for _, enemy in pairs(enemies) do
				if enemy:IsVulnerableEnemy() and enemy:IsActiveEnemy() then
					game:RerollEnemy(enemy)
				end
			end
			data.eclipsed.Domino25 = nil
		end
	end

	---maze of memory
	if data.eclipsed.MazeMemory then
		if data.eclipsed.MazeMemory[1] then
			if data.eclipsed.MazeMemory[1] > 0 then
				data.eclipsed.MazeMemory[1] = data.eclipsed.MazeMemory[1] - 1
			elseif data.eclipsed.MazeMemory[1] == 0 then
				data.eclipsed.MazeMemory[1] = data.eclipsed.MazeMemory[1] - 1
				Isaac.ExecuteCommand("goto s.treasure.0")
			elseif data.eclipsed.MazeMemory[1] < 0 then
				game:ShowHallucination(0, BackdropType.DARK_CLOSET)
				if sfx:IsPlaying(SoundEffect.SOUND_DEATH_CARD) then
					sfx:Stop(SoundEffect.SOUND_DEATH_CARD)
				end
				data.eclipsed.MazeMemory[1] = nil

				local index = 30
				local counter = 6
				--itemPool:ResetRoomBlacklist()

				while index <= 102 do
					index = index+2
					counter = counter - 1
					if counter >= 0 then
						local pos = room:GetGridPosition(index)
						--local item = 0
						local rng = RNG()
						rng:SetSeed(Random(), 1)
						local pool = rng:RandomInt(ItemPoolType.NUM_ITEMPOOLS)
						local item = itemPool:GetCollectible(pool, false, Random(), 0)
						Isaac.Spawn(5, 100, item, pos, Vector.Zero, nil):ToPickup().OptionsPickupIndex = 88888
					else
						index = index + 16
						counter = 6
					end
				end
			end
		elseif data.eclipsed.MazeMemory[2] then
			local roomitems = 0
			local rent = room:GetEntities()
			for ient = 0, #rent-1 do
				local ent = rent:Get(ient)
				if ent and ent:ToPickup() and ent:ToPickup().Variant == 100 then
					roomitems = roomitems + 1
				end
			end
			if roomitems < data.eclipsed.MazeMemory[2] then
				data.eclipsed.MazeMemoryTransit = 25
				data.eclipsed.MazeMemory = nil
			elseif roomitems > data.eclipsed.MazeMemory[2] then
				data.eclipsed.MazeMemory[2] = roomitems
			end
		end
	end
	if data.eclipsed.MazeMemoryTransit then
		data.eclipsed.MazeMemoryTransit = data.eclipsed.MazeMemoryTransit - 1
		if data.eclipsed.MazeMemoryTransit <= 0 then
			data.eclipsed.MazeMemoryTransit = nil
			game:StartRoomTransition(level:GetStartingRoomIndex(), 1, RoomTransitionAnim.DEATH_CERTIFICATE, player, -1)
		end
	end



end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.onPEffectUpdate)

--- POST UPDATE --
function mod:onUpdate()
	local level = game:GetLevel()
	local room = game:GetRoom()
	if not mod.ModVars then mod.ModVars = {} end

end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.onUpdate)

--- NEW ROOM --
function mod:onNewRoom()
	local room = game:GetRoom()
 	local level = game:GetLevel()
 	if mod.ModVars then
		mod.ModVars.PreRoomState = room:IsClear()
 		mod.ModVars.ForRoom = {}
 	end
	if room:HasCurseMist() then return end


end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.onNewRoom)

-- TRINKET UPDATE
function mod:onTrinketUpdate(trinket)
	local dataTrinket = trinket:GetData()
	if dataTrinket.RemoveThrowTrinket then
		trinket.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		trinket.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, mod.onTrinketUpdate, PickupVariant.PICKUP_TRINKET)

--- MOONLIGHTER TARGET
function mod:onKeeperMirrorTargetEffect(target)
	local targetSprite = target:GetSprite()
	local player = target.Parent:ToPlayer
	target.DepthOffset = -100
	if not target.GridCollisionClass == EntityGridCollisionClass.GRIDCOLL_WALLS then
		target.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
	end
	target.Velocity = player:GetShootingInput() * player.ShotSpeed * 0.7
	if target.Velocity.X == 0 and target.Velocity.Y == 0 then
		local pickups = Isaac.FindInRadius(target.Position, datatables.KeeperMirror.TargetRadius, EntityPartition.PICKUP)
		for _, pickup in pairs(pickups) do
			if pickup:ToPickup() then
				pickup = pickup:ToPickup()
				if not pickup:IsShopItem() and datatables.AllowedPickupVariants[pickup.Variant] then
					pickup:Remove()
					--print(pickup.Price)
					for _ = 1, pickup.Price do
						Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, pickup.Position, RandomVector()*5, nil)
					end
					Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, nil):SetColor(datatables.KeeperMirror.PoofColor, 50, 1, false, false)
					sfx:Play(SoundEffect.SOUND_CASH_REGISTER)
					target:Remove()
					break
				end
			end
		end
	end
	if target.Timeout <= 1 then
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, pickup.Position, Vector.Zero, nil)
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, nil):SetColor(datatables.KeeperMirror.PoofColor, 50, 1, false, false)
		sfx:Play(SoundEffect.SOUND_CASH_REGISTER)
		target:Remove()
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.onKeeperMirrorTargetEffect, datatables.KeeperMirror.Target)



-- ACTIVE ITEM
---KeeperMirror
function mod:KeeperMirror(item, _, player) --item, rng, player, useFlag, activeSlot, customVarData
	local target = Isaac.Spawn(EntityType.ENTITY_EFFECT, datatables.KeeperMirror.Target, 0, player.Position, Vector.Zero, player):ToEffect()
	target.Parent = player
	target:SetTimeout(datatables.KeeperMirror.TargetTimeout)
	target:GetSprite():Play("Blink")
	return true
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.KeeperMirror, enums.Items.KeeperMirror)



-- CARD USE
-- kitten shuffle
function mod:onKittenShuffle2(_, player) -- card, player, useflag
	player:AddCollectible(CollectibleType.COLLECTIBLE_MISSING_NO)
	--local data = player:GetData()
	--data.eclipsed.KittenShuffle2 = 1
	player:RemoveCollectible(CollectibleType.COLLECTIBLE_MISSING_NO)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.onKittenShuffle2, enums.Pickups.KittenShuffle2)

-- domino 2|5
function mod:Domino25(_, player) -- card, player, useflag
	local room = game:GetRoom()
	local data = player:GetData()
	data.eclipsed.Domino25 = 3
	room:RespawnEnemies()
	game:ShakeScreen(10)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.Domino25, enums.Pickups.Domino25)

-- maze of memory
function mod:MazeMemoryCard(_, player, useFlag) -- card, player, useflag
	if useFlag & UseFlag.USE_MIMIC == 0 then
		local level = game:GetLevel()
		if not player:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE) then
			level:AddCurse(LevelCurse.CURSE_OF_BLIND, false)
		end
		local data = player:GetData()
		game:StartRoomTransition(level:GetCurrentRoomIndex(), 1, RoomTransitionAnim.DEATH_CERTIFICATE, player, -1)
		data.eclipsed.MazeMemory = {20, 18}
	end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.MazeMemoryCard, enums.Pickups.MazeMemoryCard)