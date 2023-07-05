EclipsedMod = RegisterMod("Eclipsed", 1)
local mod = EclipsedMod

local enums = include("scripts_eclipsed.enums")
local datatables = include("scripts_eclipsed.datatables")
local functions = include("scripts_eclipsed.functions")
---Mod Compat --------------------------------------------------------------------------------
include("scripts_eclipsed.compat.eid")
include("scripts_eclipsed.compat.encyclopedia")
---Achievement--------------------------------------------------------------------------------
include("scripts_eclipsed.achievements")
---Libs	--------------------------------------------------------------------------------------
mod.hiddenItemManager = include("scripts_eclipsed.lib.hidden_item_manager"):Init(mod)
mod.GrabItemCallback = include("scripts_eclipsed.lib.inventory_callbacks")
----------------------------------------------------------------------------------------------
local game = Game()
local itemPool = game:GetItemPool()
local sfx = SFXManager()
mod.LoadSaveData = false

---CUSTOM CALLBACKS--

---GravityBombs
mod.GrabItemCallback:AddCallback(mod.GrabItemCallback.InventoryCallback.POST_ADD_ITEM, function (player, _, _, touched, _)
	if not touched then --or not fromQueue then
   		player:AddGigaBombs(1)
    end
end, enums.Items.GravityBombs)
---MidasCurse
mod.GrabItemCallback:AddCallback(mod.GrabItemCallback.InventoryCallback.POST_ADD_ITEM, function (player, _, _, touched, _)
	if not touched then --or not fromQueue then
		player:GetData().eclipsed.TurnGoldChance = 1
   		player:AddGoldenHearts(3)
    end
end, enums.Items.MidasCurse)
---RubberDuck
mod.GrabItemCallback:AddCallback(mod.GrabItemCallback.InventoryCallback.POST_ADD_ITEM, function (player, _, _, touched, _)
	if not touched then --or not fromQueue then
   		local data = player:GetData()
   		data.eclipsed.DuckCurrentLuck = data.eclipsed.DuckCurrentLuck or 0
		data.eclipsed.DuckCurrentLuck = data.eclipsed.DuckCurrentLuck + 20
		functions.EvaluateDuckLuck(player, data.eclipsed.DuckCurrentLuck)
    end
end, enums.Items.RubberDuck)
---COLLECTIBLE_BIRTHRIGHT
mod.GrabItemCallback:AddCallback(mod.GrabItemCallback.InventoryCallback.POST_ADD_ITEM, function (player, item, _, touched, _)
	if not touched then --or not fromQueue then
   		local data = player:GetData()
   		local playerType = player:GetPlayerType()
   		if playerType == enums.Characters.Nadab then
   			functions.SpawnOptionItems(player.Position, player:GetCollectibleRNG(item), Random()+1)
   		elseif playerType == enums.Characters.Abihu then
			player:SetFullHearts()
   		elseif playerType == enums.Characters.Unbidden then
			if player:GetBrokenHearts() > 0 then
				player:AddBrokenHearts(-1)
				player:AddSoulHearts(2)
			end
   		elseif playerType == enums.Characters.UnbiddenB then
			data.eclipsed.ResetGame = data.eclipsed.ResetGame or 100
			if data.eclipsed.ResetGame < 100 then data.eclipsed.ResetGame = 100 end
			for slot = 0, 3 do
				if player:GetActiveItem(slot) == enums.Items.Threshold then
					player:SetActiveCharge(2*Isaac.GetItemConfig():GetCollectible(enums.Items.Threshold).MaxCharges, slot)
				end
			end
   		end
    end
end, CollectibleType.COLLECTIBLE_BIRTHRIGHT)
---MongoCells
mod.GrabItemCallback:AddCallback(mod.GrabItemCallback.InventoryCallback.POST_ADD_ITEM, function (player, _, _, touched, _)
	if not touched then --or not fromQueue then
		for itemIdx, itemHidden in pairs(datatables.MongoCells.HiddenWispEffects) do
			if player:HasCollectible(itemIdx) and not player:HasCollectible(itemHidden) then
				mod.hiddenItemManager:Add(player, itemHidden, -1, 1, "MONGO_CELLS")
			end
		end
		local tempEffects = player:GetEffects()
		for itemIdx, itemTemp in pairs(datatables.MongoCells.FamiliarEffects) do
			if player:HasCollectible(itemIdx) and not player:HasCollectible(itemTemp) then
				tempEffects:AddCollectibleEffect(itemTemp)
			end
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_SISTER_MAGGY) then
			player:UseActiveItem(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL, datatables.NoAnimNoAnnounMimicNoCostume)
		end
    end
end, enums.Items.MongoCells)

---LUAMOD
function mod:onLuamod(myMod)
	if myMod.Name == "Eclipsed" and Isaac.GetPlayer() ~= nil then
       functions.SavedSaveData()
    end
	mod.LoadSaveData = false
end
mod:AddCallback(ModCallbacks.MC_PRE_MOD_UNLOAD, mod.onLuamod)

---GAME EXIT--
function mod:onExit(isContinue)
	functions.SavedSaveData(isContinue)
end
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.onExit)

---GAME START--
function mod:onStart(isSave)
	if isSave then
		for playerNum = 0, game:GetNumPlayers()-1 do
			local player = game:GetPlayer(playerNum)
			local data = player:GetData()
			data.eclipsed = data.eclipsed or {}
			if player:GetPlayerType() == enums.Characters.Abihu or player:GetPlayerType() == enums.Characters.UnbiddenB then
				data.eclipsed.BlindCharacter = true
				functions.SetBlindfold(player, true)
			end
		end
	end
	functions.LoadedSaveData(isSave)
	---Challenges
	if Isaac.GetChallenge() > 0 then
		for playerNum = 0, game:GetNumPlayers()-1 do
			local player = game:GetPlayer(playerNum)
			if Isaac.GetChallenge() == enums.Challenges.Beatmaker then
				player:AddCollectible(enums.Items.HeartTransplant)
			elseif Isaac.GetChallenge() == enums.Challenges.MongoFamily then
				player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, false)
				player:AddCollectible(enums.Items.MongoCells)
				--elseif Isaac.GetChallenge() == enums.Challenges.ShovelNight then
				--	player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_WE_NEED_TO_GO_DEEPER, ActiveSlot.SLOT_POCKET, false)
			end
			player:RespawnFamiliars()
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.onStart)

---PLAYER INIT--
function mod:onPlayerInit(player)
	functions.ResetPlayerData(player)
	local data = player:GetData()
	local playerType = player:GetPlayerType()
	---Nadab
	if playerType == enums.Characters.Nadab then
		player:RespawnFamiliars()
		data.eclipsed.NadabCostumeEquipped = true
		player:AddNullCostume(datatables.NadabData.CostumeHead)
		if not player:HasCollectible(enums.Items.AbihuFam, true) then player:AddCollectible(enums.Items.AbihuFam) end
	else
		if data.eclipsed.NadabCostumeEquipped then
			player:TryRemoveNullCostume(datatables.NadabData.CostumeHead)
			data.eclipsed.NadabCostumeEquipped = nil
			if player:HasCollectible(enums.Items.AbihuFam, true) then player:RemoveCollectible(enums.Items.AbihuFam) end
		end
	end
	---Abihu
	if playerType == enums.Characters.Abihu then -- nadab
		data.eclipsed.BlindCharacter = true
		functions.SetBlindfold(player, true)
		if not player:HasCollectible(enums.Items.NadabBody, true) then player:AddCollectible(enums.Items.NadabBody) end
	else
		if data.eclipsed.BlindCharacter then
			data.eclipsed.BlindCharacter = nil
			functions.SetBlindfold(player, false)
		end
		if data.eclipsed.AbihuCostumeEquipped then
			player:TryRemoveNullCostume(datatables.AbihuData.CostumeHead)
			data.eclipsed.AbihuCostumeEquipped = nil
			if player:HasCollectible(enums.Items.NadabBody, true) then player:RemoveCollectible(enums.Items.NadabBody) end
		end
	end
	---UnbiddenB
	if playerType == enums.Characters.UnbiddenB then
		data.eclipsed.BlindCharacter = true
		functions.SetBlindfold(player, true)
		data.eclipsed.ResetGame = 100
		if not player:HasCollectible(enums.Items.Threshold, true) then
			player:SetPocketActiveItem(enums.Items.Threshold, ActiveSlot.SLOT_POCKET, true)
		end
	else
		if data.eclipsed.BlindCharacter then
			data.eclipsed.BlindCharacter = nil
			functions.SetBlindfold(player, false)
			if player:HasCollectible(enums.Items.Threshold, true) then player:RemoveCollectible(enums.Items.Threshold) end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.onPlayerInit)

---EVAL CACHE--
function mod:onCache(player, cacheFlag)
	player = player:ToPlayer()
	local data = player:GetData()

	if player:GetPlayerType() == enums.Characters.Nadab then
		if cacheFlag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage * 1.2
			if player:HasCollectible(CollectibleType.COLLECTIBLE_MR_MEGA) then
				player.Damage = player.Damage + (player.Damage * 0.75)
			end
		end
		if cacheFlag == CacheFlag.CACHE_FIREDELAY and player:HasCollectible(CollectibleType.COLLECTIBLE_SAD_BOMBS) then
			player.MaxFireDelay = player.MaxFireDelay -1
		end
		if cacheFlag == CacheFlag.CACHE_SPEED then
			player.MoveSpeed = player.MoveSpeed -0.35
			if player:HasCollectible(CollectibleType.COLLECTIBLE_FAST_BOMBS) and player.MoveSpeed < 1.0 then
				player.MoveSpeed = 1.0
			end
		end
		if cacheFlag == CacheFlag.CACHE_TEARFLAG and player:HasCollectible(CollectibleType.COLLECTIBLE_BOBBY_BOMB) then
			player.TearFlags = player.TearFlags | TearFlags.TEAR_HOMING
		end
	elseif player:GetPlayerType() == enums.Characters.Abihu then
		if cacheFlag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage *  1.14286
		end
		if cacheFlag == CacheFlag.CACHE_SPEED then
			player.MoveSpeed = player.MoveSpeed + 1
		end
	elseif player:GetPlayerType() == enums.Characters.Unbidden then
		if cacheFlag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage * 1.35
		end
		if cacheFlag == CacheFlag.CACHE_LUCK then
			player.Luck = player.Luck -1
		end
		if cacheFlag == CacheFlag.CACHE_TEARCOLOR then
			player.TearColor = Color(0.5,1,2) --Color(0.5,1,2,1,0,0,0)
			player.LaserColor =  Color(1,1,1,1,-0.5,0.7,1)
		end
	elseif player:GetPlayerType() == enums.Characters.UnbiddenB then
		if cacheFlag == CacheFlag.CACHE_LUCK then
			player.Luck = player.Luck -3
		end
		if cacheFlag == CacheFlag.CACHE_TEARFLAG then
			player.TearFlags = player.TearFlags | TearFlags.TEAR_WAIT | TearFlags.TEAR_CONTINUUM
		end
		if cacheFlag == CacheFlag.CACHE_TEARCOLOR then
			player.TearColor = Color(0.5,1,2)
			player.LaserColor =  Color(1,1,1,1,-0.5,0.7,1)
		end

	end

	if data.eclipsed then
		if cacheFlag == CacheFlag.CACHE_LUCK then
			if player:HasCollectible(enums.Items.RubberDuck) and data.eclipsed.DuckCurrentLuck then
				player.Luck = player.Luck + data.eclipsed.DuckCurrentLuck
			end
			if player:HasCollectible(enums.Items.VoidKarma) and data.eclipsed.KarmaStats then
				player.Luck = player.Luck + data.eclipsed.KarmaStats.Luck
			end
			if data.eclipsed.ForRoom.DeuxExLuck then
				player.Luck = player.Luck + data.eclipsed.ForRoom.DeuxExLuck
			end
			if data.eclipsed.MisfortuneLuck then
				player.Luck = player.Luck - 5
			end
		end
		if cacheFlag == CacheFlag.CACHE_DAMAGE then
			if data.eclipsed.RedPillDamageUp then
				player.Damage = player.Damage + data.eclipsed.RedPillDamageUp
			end
			if player:HasCollectible(enums.Items.RedLotus) and data.eclipsed.RedLotusDamage then -- save damage even if you removed item
				player.Damage = player.Damage + data.eclipsed.RedLotusDamage
			end
			if player:HasCollectible(enums.Items.VoidKarma) and data.eclipsed.KarmaStats then
				player.Damage = player.Damage + data.eclipsed.KarmaStats.Damage
			end
			if data.eclipsed.EclipseBoost and data.eclipsed.EclipseBoost > 0 then
			    player.Damage = player.Damage + player.Damage * (mod.ModVars.EclipseDamageBoost * data.eclipsed.EclipseBoost)
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
			if player:HasCollectible(enums.Items.MiniPony) and player.MoveSpeed < 1.5 then
				player.MoveSpeed = 1.5
			end
			if player:HasCollectible(enums.Items.VoidKarma) and data.eclipsed.KarmaStats then
				player.MoveSpeed = player.MoveSpeed + data.eclipsed.KarmaStats.Speed
			end
			if data.HeartTransplantUseCount and data.HeartTransplantUseCount > 0 then
				local speed = datatables.HeartTransplant.ChainValue[data.eclipsed.HeartTransplantUseCount][3]
				player.MoveSpeed = player.MoveSpeed + speed
			end
		end
		if cacheFlag == CacheFlag.CACHE_TEARCOLOR then
			if player:HasCollectible(enums.Items.MeltedCandle) then
				player.TearColor = Color(2, 2, 2, 1, 0.196, 0.196, 0.196)
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
			functions.CheckFamiliar(player, enums.Items.AbihuFam, enums.Familiars.AbihuFam)
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
				player:CheckFamiliar(enums.Familiars.AbihuFam, profans, RNG(), Isaac.GetItemConfig():GetCollectible(enums.Items.AbihuFam), 2)
			end
			--]]
		end
	end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.onCache)

---PLAYER TAKE DMG--
function mod:onPlayerTakeDamage(entity, _, flags) --entity, amount, flags, source, countdown
	local player = entity:ToPlayer()
	local data = player:GetData()
	local plyaerType = player:GetPlayerType()
	data.eclipsed = data.eclipsed or {}
	---Nadab
	if plyaerType == enums.Characters.Nadab and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and (
	 	flags & DamageFlag.DAMAGE_FIRE == DamageFlag.DAMAGE_FIRE or
		flags & DamageFlag.DAMAGE_EXPLOSION == DamageFlag.DAMAGE_EXPLOSION or
		flags & DamageFlag.DAMAGE_TNT == DamageFlag.DAMAGE_TNT)
	then
		return false
	---Abihu
	elseif plyaerType == enums.Characters.Abihu then
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and (
				flags & DamageFlag.DAMAGE_FIRE == DamageFlag.DAMAGE_FIRE or
				flags & DamageFlag.DAMAGE_EXPLOSION == DamageFlag.DAMAGE_EXPLOSION or
				flags & DamageFlag.DAMAGE_TNT == DamageFlag.DAMAGE_TNT)
		then
			return false
		end
		if not data.eclipsed.AbihuCostumeEquipped then
			data.eclipsed.AbihuCostumeEquipped = true
			player:AddNullCostume(datatables.AbihuData.CostumeHead)
		end
		data.eclipsed.HoldBomd = -1
	end
	---SoulNadabAbihu
	if data.eclipsed.ForRoom.SoulNadabAbihu and (
		flags & DamageFlag.DAMAGE_FIRE == DamageFlag.DAMAGE_FIRE or
		flags & DamageFlag.DAMAGE_EXPLOSION == DamageFlag.DAMAGE_EXPLOSION or
		flags & DamageFlag.DAMAGE_TNT == DamageFlag.DAMAGE_TNT)
	then
		return false
	end
	---RETURN
	if player:HasCurseMistEffect() or player:IsCoopGhost() then return end
	---AgonyBox
	if player:HasCollectible(enums.Items.AgonyBox, true) and flags & DamageFlag.DAMAGE_FAKE == 0 then
		for slot = 0, 3 do -- 0, 3
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
	---SpikedCollar
	if player:HasCollectible(enums.Items.SpikedCollar) and flags & DamageFlag.DAMAGE_FAKE == 0 and flags & DamageFlag.DAMAGE_INVINCIBLE == 0 then
		player:UseActiveItem(CollectibleType.COLLECTIBLE_RAZOR_BLADE, datatables.NoAnimNoAnnounMimicNoCostume)
		return false
	end
	---MongoCells
	if player:HasCollectible(enums.Items.MongoCells) and flags & DamageFlag.DAMAGE_NO_PENALTIES == 0 then
		local rng = player:GetCollectibleRNG(enums.Items.MongoCells)
		if player:HasCollectible(CollectibleType.COLLECTIBLE_DRY_BABY) and rng:RandomFloat() < 0.33 then
			player:UseActiveItem(CollectibleType.COLLECTIBLE_NECRONOMICON, datatables.NoAnimNoAnnounMimic)
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_FARTING_BABY) and rng:RandomFloat() < 0.33 then
			local bean = datatables.MongoCells.FartBabyBeans[rng:RandomInt(#datatables.MongoCells.FartBabyBeans)+1]
			player:UseActiveItem(bean, datatables.NoAnimNoAnnounMimicNoCostume)
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BBF) then
			game:BombExplosionEffects(player.Position, 100, player:GetBombFlags(), Color.Default, player, 1, true, false, DamageFlag.DAMAGE_EXPLOSION)
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BOBS_BRAIN) then
			game:BombExplosionEffects(player.Position, 100, player:GetBombFlags(), Color.Default, player, 1, true, false, DamageFlag.DAMAGE_EXPLOSION)
			local cloud = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SMOKE_CLOUD, 0, player.Position, Vector.Zero, player):ToEffect()
			cloud:SetTimeout(150)
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_HOLY_WATER) then
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_HOLYWATER, 0, player.Position, Vector.Zero, player):SetColor(Color(1,1,1,0), 2, 1, false, false)
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_DEPRESSION) and rng:RandomFloat() < 0.33 then
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACK_THE_SKY, 0, player.Position, Vector.Zero, player)
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_RAZOR) then
			player:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRD_CAGE) then
			player:UseActiveItem(CollectibleType.COLLECTIBLE_WAIT_WHAT, datatables.NoAnimNoAnnounMimic)
		end
	end
	---LostFlower
	if player:HasTrinket(enums.Trinkets.LostFlower) and flags & DamageFlag.DAMAGE_NO_PENALTIES == 0 and flags & DamageFlag.DAMAGE_RED_HEARTS == 0 then
		functions.RemoveThrowTrinket(player, enums.Trinkets.LostFlower)
	end
	---RubikCubelet
	if player:HasTrinket(enums.Trinkets.RubikCubelet) then
		if player:GetTrinketRNG(enums.Trinkets.RubikCubelet):RandomFloat() < 0.33 * player:GetTrinketMultiplier(enums.Trinkets.RubikCubelet) then
			functions.RerollTMTRAINER(player)
		end
	end
	---Cybercutlet
	if player:HasTrinket(enums.Trinkets.Cybercutlet) and flags & DamageFlag.DAMAGE_FAKE == 0 and flags & DamageFlag.DAMAGE_NO_PENALTIES == 0 and flags & DamageFlag.DAMAGE_RED_HEARTS == 0 then
		player:TryRemoveTrinket(enums.Trinkets.Cybercutlet)
		player:AddHearts(2)
		sfx:Play(SoundEffect.SOUND_VAMP_GULP)
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HEART, 0, Vector(player.Position.X, player.Position.Y-70), Vector.Zero, nil)
	end
	---MortalDamage
	if player:HasMortalDamage() then
		---WitchPaper
		if player:HasTrinket(enums.Trinkets.WitchPaper) then
			data.eclipsed.WitchPaper = 2
			if game:GetRoom():GetType() == RoomType.ROOM_DUNGEON and game:GetRoom():GetRoomConfigStage() == 35 then
				Isaac.ExecuteCommand("stage 13") -- reset Beast fight to Home
			end
			player:UseActiveItem(CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS, datatables.NoAnimNoAnnounMimic)
			return
		end
		---CharonObol
		if player:HasCollectible(enums.Items.CharonObol) then
			player:RemoveCollectible(enums.Items.CharonObol)
		end
		---Unbidden and UnbiddenB
		if player:GetBrokenHearts() < 11 and (plyaerType == enums.Characters.Unbidden or plyaerType == enums.Characters.UnbiddenB) then
			if game:GetRoom():GetType() == RoomType.ROOM_DUNGEON and game:GetRoom():GetRoomConfigStage() == 35 then
				data.eclipsed.BeastCounter = data.eclipsed.BeastCounter or 0
				Isaac.ExecuteCommand("stage 13")
				return
			end
			if plyaerType == enums.Characters.UnbiddenB and data.eclipsed.ResetGame then
				if 0 >= data.eclipsed.ResetGame or math.random(data.eclipsed.ResetGame) >= data.eclipsed.ResetGame then
					Isaac.ExecuteCommand("restart")
					return
				end
			end
			data.eclipsed.NoAnimReset = 2
			player:UseActiveItem(CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS, datatables.NoAnimNoAnnounMimic)
			return
		---ExtraLives
		elseif player:GetExtraLives() < 1 then
			---AbyssCart
			if player:HasTrinket(enums.Trinkets.AbyssCart) then
				if data.eclipsed.AbyssCartBlink then
					if player:HasCollectible(data.eclipsed.AbyssCartBlink[1]) then
						player:RemoveCollectible(data.eclipsed.AbyssCartBlink[1])
						player:AddCollectible(CollectibleType.COLLECTIBLE_1UP)
						local numTrinket = player:GetTrinketMultiplier(enums.Trinkets.AbyssCart)-1
						local rngTrinket = player:GetTrinketRNG(enums.Trinkets.AbyssCart)
						if rngTrinket:RandomFloat() > numTrinket * 0.5 then
							functions.RemoveThrowTrinket(player, enums.Trinkets.AbyssCart)
						end
					end
				end
			end
			---Limb
			if player:HasCollectible(enums.Items.Limb) and not data.eclipsed.ForLevel.LimbActive then
				mod.ModVars.ForLevel.LimbActive = true
				data.eclipsed.ForLevel.LimbActive = true
				player:UseCard(Card.CARD_SOUL_LAZARUS, datatables.NoAnimNoAnnounMimic)
				player:UseCard(Card.CARD_SOUL_LOST, datatables.NoAnimNoAnnounMimic)
				player:SetMinDamageCooldown(24)
				game:Darken(1, 3)
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.onPlayerTakeDamage, EntityType.ENTITY_PLAYER)

---PLAYER COLLISION--
function mod:onPlayerCollision(player, collider)
	local data = player:GetData()
	local tempEffects = player:GetEffects()
	if not collider:ToNPC() then return end
	---LongElk
	if data.eclipsed and data.eclipsed.ElkKiller and tempEffects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_MARS) and collider:ToNPC() then --collider:IsVulnerableEnemy() and collider:IsActiveEnemy() then  -- player.Velocity ~= Vector.Zero
		if functions.CheckJudasBirthright(player) then
			functions.CircleSpawn(player, 50, 0, EntityType.ENTITY_EFFECT, EffectVariant.FIRE_JET, 0)
		end
		if collider:IsBoss() then
			local colliderData = collider:GetData()
			if colliderData.ElkKillerTick then
				if game:GetFrameCount() - colliderData.ElkKillerTick >= 40 then
					colliderData.ElkKillerTick = game:GetFrameCount()
					collider:TakeDamage(400, DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(player), 0)
					sfx:Play(SoundEffect.SOUND_DEATH_CARD)
					game:ShakeScreen(10)
					player:SetMinDamageCooldown(24)
				end
			else
				colliderData.ElkKillerTick = game:GetFrameCount()
				collider:TakeDamage(400, DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(player), 0)
				sfx:Play(SoundEffect.SOUND_DEATH_CARD)
				game:ShakeScreen(10)
				player:SetMinDamageCooldown(24)
			end
		else
			game:ShakeScreen(10)
			collider:Kill()
		end
	end
	---Abihu
	if player:GetPlayerType() == enums.Characters.Abihu then
		if collider:IsActiveEnemy() and collider:IsVulnerableEnemy() then
			collider:AddBurn(EntityRef(player), 90, 2*player.Damage)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, mod.onPlayerCollision)

---PLAYER PEFFECT--
function mod:onPEffectUpdate(player)
	local level = game:GetLevel()
	local room = game:GetRoom()
	local data = player:GetData()
	local currentCurses = level:GetCurses()
	local sprite = player:GetSprite()
	local tempEffects = player:GetEffects()
	local playerType = player:GetPlayerType()
	functions.ResetModVars()
	functions.ResetPlayerData(player)
	local holdingCard = player:GetCard(0)
	---NadabBombBeggarDelay
	if data.eclipsed.BlockBeggar then
		if game:GetFrameCount() - data.eclipsed.BlockBeggar > 30 then data.eclipsed.BlockBeggar = nil end
	end
	---ResetBlind
	if data.eclipsed.ResetBlind then
		data.eclipsed.ResetBlind = data.eclipsed.ResetBlind -1
		if data.eclipsed.ResetBlind <= 0 then
			data.eclipsed.BlindCharacter = true
			functions.SetBlindfold(player, true)
			data.eclipsed.ResetBlind = nil
		end
	end
	---ExplosionCountdown
	if data.eclipsed.ExCountdown then
		data.eclipsed.ExCountdown = data.eclipsed.ExCountdown or 0
		if data.eclipsed.ExCountdown > 0 then data.eclipsed.ExCountdown = data.eclipsed.ExCountdown -1 end
		data.eclipsed.MaxExCountdown = data.eclipsed.MaxExCountdown or 30
		if player:HasTrinket(TrinketType.TRINKET_SHORT_FUSE) and data.eclipsed.MaxExCountdown > 15 then
			data.eclipsed.MaxExCountdown = 15
		elseif data.eclipsed.MaxExCountdown < 30 then
			data.eclipsed.MaxExCountdown = 30
		end
	end
	---CurseMisfortune
	if currentCurses & enums.Curses.Misfortune > 0 and not data.eclipsed.MisfortuneLuck then
		data.eclipsed.MisfortuneLuck = true
		player:AddCacheFlags(CacheFlag.CACHE_LUCK)
		player:EvaluateItems()
	elseif currentCurses & enums.Curses.Misfortune == 0 and data.eclipsed.MisfortuneLuck then
		data.eclipsed.MisfortuneLuck = nil
		player:AddCacheFlags(CacheFlag.CACHE_LUCK)
		player:EvaluateItems()
	end
	---CurseMontezuma
	if currentCurses & enums.Curses.Montezuma > 0 and not player.CanFly and game:GetFrameCount()%12 == 0 then
		local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_SLIPPERY_BROWN, 0, player.Position, Vector.Zero, nil):ToEffect()
		creep.SpriteScale = creep.SpriteScale * 0.1
	end
	---ExplodingKittens
	if datatables.ExplodingKittens.BombCards[holdingCard] then
		data.ExplodingKitten = data.ExplodingKitten or 120
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
	---Domino25
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
	---SecretLoveLetter
	if data.eclipsed.SecretLoveLetter and player:GetFireDirection() ~= Direction.NO_DIRECTION then
		if player:IsHoldingItem() then
			if player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == enums.Items.SecretLoveLetter then
				if player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY) >= Isaac.GetItemConfig():GetCollectible(enums.Items.SecretLoveLetter).MaxCharges then
					local tear = player:FireTear(player.Position, player:GetAimDirection() * 14, false, true, false, nil, 0):ToTear()
					tear.TearFlags = TearFlags.TEAR_CHARM
					tear.Color = Color(1,1,1,1,0,0,0)
					tear:ChangeVariant(TearVariant.CHAOS_CARD)
					local tearData = tear:GetData()
					tearData.SecretLoveLetter = true
					local tearSprite = tear:GetSprite()
					tearSprite:ReplaceSpritesheet(0, datatables.SecretLoveLetter.SpritePath)
					tearSprite:LoadGraphics() -- replace sprite
					sfx:Play(SoundEffect.SOUND_SHELLGAME)
				end
				if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
					local wisp = player:AddWisp(CollectibleType.COLLECTIBLE_KIDNEY_BEAN, player.Position, false, false)
					if wisp then
						wisp.Color = Color(1, 0.5, 0.5, 1)
					end
				end
				player:DischargeActiveItem(ActiveSlot.SLOT_PRIMARY)
			end
			player:AnimateCollectible(enums.Items.SecretLoveLetter, "HideItem")
		end
		data.eclipsed.SecretLoveLetter = false
	end
	---ItemWispQueue
	if data.eclipsed.WispedQueue then
		if #data.eclipsed.WispedQueue > 0 and player:IsItemQueueEmpty() and not data.eclipsed.WispedItemDelay then
			local witem = data.eclipsed.WispedQueue[1][1]
			local kill = data.eclipsed.WispedQueue[1][2]
			sfx:Play(SoundEffect.SOUND_THUMBSUP)
			player:QueueItem(Isaac.GetItemConfig():GetCollectible(witem.SubType), Isaac.GetItemConfig():GetCollectible(witem.SubType).InitCharge)
			player:AnimateCollectible(witem.SubType, "UseItem")
			if kill then
				witem:Remove()
				witem:Kill()
			end
			data.eclipsed.WispedItemDelay = 1
			table.remove(data.eclipsed.WispedQueue, 1)
		elseif player:IsItemQueueEmpty() and data.eclipsed.WispedItemDelay then -- so it would be added properly ( basically I just need at least 1 frame delay, to add item modifications)
			data.eclipsed.WispedItemDelay = nil
		elseif #data.eclipsed.WispedQueue == 0 then -- nil if it's empty
			data.eclipsed.WispedQueue = nil
			data.eclipsed.WispedItemDelay = nil
		end
	end
	---NirlyCodex
	if data.eclipsed.NirlySavedCards and data.eclipsed.UsedNirly then
		if #data.eclipsed.NirlySavedCards == 0 then
			data.eclipsed.UsedNirly = false
		else
			card = table.remove(data.eclipsed.NirlySavedCards, 1)
			player:UseCard(card, UseFlag.USE_NOANIM)
		end
	end
	---FloppyDisk
	if player:HasCollectible(enums.Items.FloppyDisk) and #mod.PersistentData.FloppyDiskItems > 0 then
		player:RemoveCollectible(enums.Items.FloppyDisk)
		player:AddCollectible(enums.Items.FloppyDiskFull)
		--elseif player:HasCollectible(enums.Items.FloppyDiskFull) and #datatables.FloppyDisk.Items == 0 then
	elseif player:HasCollectible(enums.Items.FloppyDiskFull) and #mod.PersistentData.FloppyDiskItems == 0 then
		player:RemoveCollectible(enums.Items.FloppyDiskFull)
		player:AddCollectible(enums.Items.FloppyDisk)
	end
	---Threshold
	if player:HasCollectible(enums.Items.Threshold) and game:GetFrameCount()%30 == 0 then -- every 2 seconds
		for slot = 0, 3 do
			if player:GetActiveItem(slot) == enums.Items.Threshold and player:GetActiveCharge(slot) >= Isaac.GetItemConfig():GetCollectible(enums.Items.Threshold).MaxCharges then
				--local itemWisps = Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.ITEM_WISP)
				local itemWisps = Isaac.FindInRadius(player.Position, 120, EntityPartition.FAMILIAR)
				for _, witem in pairs(itemWisps) do
					if witem.Variant == FamiliarVariant.ITEM_WISP and not functions.CheckItemType(witem.SubType) then
						if data.eclipsed.RenderThresholdItem and witem.SubType ~= data.eclipsed.RenderThresholdItem.SubType then
						end
						data.eclipsed.RenderThresholdItem = witem:ToFamiliar()
						witem:SetColor(Color(0,0,5,1), 30, 1, true, false)
						break
					end
				end
			end
		end
	end
	---NadabBody
	if player:HasCollectible(enums.Items.NadabBody, true) then
		data.eclipsed.HoldBomd = data.eclipsed.HoldBomd or -1
		if data.eclipsed.HoldBomd == 1 then
			data.eclipsed.HoldBomd = -1
		elseif data.eclipsed.HoldBomd > 0 then
			data.eclipsed.HoldBomd = data.eclipsed.HoldBomd - 1
		end
		local bombVar = BombVariant.BOMB_DECOY
		if playerType ~= enums.Characters.Abihu then
			if data.eclipsed.HoldBomd == 0 and not player:IsHoldingItem() and data.eclipsed.NadabReHold and game:GetFrameCount() - data.eclipsed.NadabReHold > 30 then
				data.eclipsed.HoldBomd = -1
				data.eclipsed.NadabReHold = nil
			end
		else
			bombVar = -1
		end
		local bomboys = 0
		local roomBombs = Isaac.FindByType(EntityType.ENTITY_BOMB, bombVar)
		---bug with bombs and encyclopedia (well)
		if Encyclopedia and (Input.IsButtonTriggered(Keyboard.KEY_C, player.ControllerIndex) or Input.IsButtonTriggered(Keyboard.KEY_F1, player.ControllerIndex)) then
			datatables.GameTimeCounter = datatables.GameTimeCounter or game.TimeCounter
			if #roomBombs > 0 then
				for _, body in pairs(roomBombs) do
					body:Remove()
				end
				datatables.GameTimeCounter = game.TimeCounter
			elseif game.TimeCounter ~= datatables.GameTimeCounter then
				datatables.GameTimeCounter = nil
			end
		end
		---GetNadabBombsCount and TryHold
		for _, body in pairs(roomBombs) do
			if body.Variant ~= BombVariant.BOMB_THROWABLE then
				if body:GetData().eclipsed and body:GetData().eclipsed.NadabBomb then
					bomboys = bomboys +1
				end
				if body.Position:Distance(player.Position) <= 30 and data.eclipsed.HoldBomd < 0 and player:TryHoldEntity(body) then
					data.eclipsed.HoldBomd = 0
					data.eclipsed.NadabReHold = game:GetFrameCount()
				end
			end
		end
		---Respawn nadab's body if it was somehow disappeared
		if bomboys < functions.GetItemsCount(player, enums.Items.NadabBody, true) then
			bomboys = functions.GetItemsCount(player, enums.Items.NadabBody, true) - bomboys
			for _=1, bomboys do
				local pos = Isaac.GetFreeNearPosition(player.Position, 35)
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pos, Vector.Zero, nil)
				local bomb = Isaac.Spawn(EntityType.ENTITY_BOMB, BombVariant.BOMB_DECOY, 0, pos, Vector.Zero, nil):ToBomb()
				bomb:GetData().eclipsed = {}
				bomb:GetData().eclipsed.NadabBomb = true
				bomb:GetSprite():ReplaceSpritesheet(0, datatables.NadabBody.SpritePath)
				bomb:GetSprite():LoadGraphics()
				bomb.Parent = player
			end
		end
		if playerType == enums.Characters.Abihu and Input.IsActionPressed(ButtonAction.ACTION_BOMB, player.ControllerIndex) then --Input.IsActionPressed(action, controllerId) IsActionTriggered
			local checkBombsNum = player:GetHearts()
			if checkBombsNum > 0 and data.eclipsed.ExCountdown == 0 then
				data.eclipsed.ExCountdown = data.eclipsed.MaxExCountdown
				if not player:HasCollectible(CollectibleType.COLLECTIBLE_PYROMANIAC) then
					player:TakeDamage(1, DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_RED_HEARTS, EntityRef(player), 1)
				end
				if player:HasCollectible(CollectibleType.COLLECTIBLE_ROCKET_IN_A_JAR) and player:GetFireDirection() ~= Direction.NO_DIRECTION then
					local bodies2 = Isaac.FindByType(EntityType.ENTITY_BOMB, BombVariant.BOMB_DECOY)
					for _, body in pairs(bodies2) do
						if body:GetData().eclipsed and body:GetData().eclipsed.NadabBomb then
							body:GetData().eclipsed.RocketBody = 30
							body.Velocity = player:GetShootingInput() * body:GetData().eclipsed.RocketBody
						end
					end
				else
					functions.FcukingBomberbody(player)
				end
			end
		end
	end
	---Nadab
	if playerType == enums.Characters.Nadab then
		functions.AbihuNadabManager(player)
		if not player:HasCurseMistEffect() and not player:IsCoopGhost() then
			---FrostyBombs
			if player:HasCollectible(enums.Items.FrostyBombs) and game:GetFrameCount() %8 == 0 then -- spawn every 8th frame
				local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL, 0, player.Position, Vector.Zero, player):ToEffect() -- PLAYER_CREEP_RED
				creep.SpriteScale = creep.SpriteScale * 0.1
			end
			---BobBladder
			if player:HasTrinket(TrinketType.TRINKET_BOBS_BLADDER) and game:GetFrameCount() %8 == 0 then -- spawn every 8th frame
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_GREEN, 0, player.Position, Vector.Zero, player)
			end
			---RingCap
			if data.eclipsed.RingCapDelay then
				data.eclipsed.RingCapDelay = data.eclipsed.RingCapDelay + 1
				if data.eclipsed.RingCapDelay > player:GetTrinketMultiplier(TrinketType.TRINKET_RING_CAP) * 10 then
					data.eclipsed.RingCapDelay = nil
				elseif data.eclipsed.RingCapDelay % 10 == 0 then
					if player:HasCollectible(enums.Items.MirrorBombs) then
						functions.NadabExplosion(player, false, functions.FlipMirrorPos(player.Position))
					end
					functions.NadabExplosion(player, false, player.Position)
				end
			end
			---EvaluateItems
			data.eclipsed.NadabMutator = data.eclipsed.NadabMutator or {}
			for itemIdx, cacheFlag in pairs(datatables.NadabData.BombMods) do
				if player:HasCollectible(itemIdx) then
					if not data.eclipsed.NadabMutator[itemIdx] then
						player:AddCacheFlags(cacheFlag)
						player:EvaluateItems()
						data.eclipsed.NadabMutator[itemIdx] = true
					end
				else
					if data.eclipsed.NadabMutator[itemIdx] then
						player:AddCacheFlags(cacheFlag)
						player:EvaluateItems()
						data.eclipsed.NadabMutator[itemIdx] = false
					end
				end
			end
			---RocketMars
			if data.eclipsed.ForRoom.RocketMars and not tempEffects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_MARS) then
				data.eclipsed.ExCountdown = data.eclipsed.MaxExCountdown
				functions.FcukingBomberman(player)
				data.eclipsed.ForRoom.RocketMars = false
			end
		end
		if Input.IsActionPressed(ButtonAction.ACTION_BOMB, player.ControllerIndex) and player:GetHearts() > 0 and data.eclipsed.ExCountdown == 0 then
			if not player:HasCurseMistEffect() and not player:IsCoopGhost() then
				if not player:HasCollectible(CollectibleType.COLLECTIBLE_PYROMANIAC) then
					player:TakeDamage(1, DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_RED_HEARTS, EntityRef(player), 1)
				end
				if player:HasCollectible(CollectibleType.COLLECTIBLE_ROCKET_IN_A_JAR) and player:GetFireDirection() ~= Direction.NO_DIRECTION then
					tempEffects:AddCollectibleEffect(CollectibleType.COLLECTIBLE_MARS, false, 1)
					data.eclipsed.ForRoom.RocketMars = true
				end
			else
				player:TakeDamage(1, DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_RED_HEARTS, EntityRef(player), 1)
			end
			if not data.eclipsed.ForRoom.RocketMars then
				data.eclipsed.ExCountdown = data.eclipsed.MaxExCountdown
				functions.FcukingBomberman(player)
			end
		end
	elseif playerType == enums.Characters.Abihu then
	---Abihu
		functions.AbihuNadabManager(player)
		---SoulState
		if tempEffects:HasNullEffect(NullItemID.ID_LOST_CURSE) then
			data.eclipsed.ForRoom.AbihuIgnites = true
			if not data.eclipsed.AbihuCostumeEquipped then
				data.eclipsed.AbihuCostumeEquipped = true
				player:AddNullCostume(datatables.AbihuData.CostumeHead)
			end
		end
		---BIRTHRIGHT
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and not data.eclipsed.AbihuCostumeEquipped then
			data.eclipsed.AbihuCostumeEquipped = true
			player:AddNullCostume(datatables.AbihuData.CostumeHead)
		end
		---Flamethrower
		data.eclipsed.AbihuDamageDelay = data.eclipsed.AbihuDamageDelay or 0
		local maxCharge = math.floor(player.MaxFireDelay) + 30
		---shoot
		if player:GetFireDirection() == Direction.NO_DIRECTION then
			if data.eclipsed.AbihuDamageDelay == maxCharge then
				sfx:Play(SoundEffect.SOUND_FLAMETHROWER_END)
				functions.ShootAbihuFlame(player, player:GetLastDirection()*player.ShotSpeed * 14, player.Damage * 4, math.floor(player.TearRange*0.1))
				data.eclipsed.AbihuDamageDelay = 0
			else
				data.eclipsed.AbihuDamageDelay = 0
			end
			-- drop bomb if you are holding it and didn't have throw delay
			-- OR
			-- remove nadab's body if you hold it long enough, it will respawn near player
			if Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex) and data.eclipsed.HoldBomd <= 0 then
				data.eclipsed.HoldActionDrop = data.eclipsed.HoldActionDrop or 0
				data.eclipsed.HoldActionDrop = data.eclipsed.HoldActionDrop + 1 -- holding drop button
				if data.eclipsed.HoldActionDrop > 30 then
					if data.eclipsed.HoldBomd == 0 then
						data.eclipsed.HoldActionDrop = 0
						data.eclipsed.ThrowVelocity = Vector.Zero
						player:ThrowHeldEntity(data.eclipsed.ThrowVelocity)
						data.eclipsed.HoldBomd = 20
					else
						data.eclipsed.HoldActionDrop = 0
						local bodies3 = Isaac.FindByType(EntityType.ENTITY_BOMB, BombVariant.BOMB_DECOY)
						if #bodies3 > 0 then
							for _, body in pairs(bodies3) do
								if body:GetData().eclipsed and body:GetData().eclipsed.NadabBomb then
									body:Kill()
									data.eclipsed.HoldActionDrop = 0
								end
							end
						end
					end
				end
			else
				data.eclipsed.HoldActionDrop = 0
			end
		else
			if data.eclipsed.HoldBomd == 0 then
				if player:HasCollectible(CollectibleType.COLLECTIBLE_ROCKET_IN_A_JAR) and not player:HasCurseMistEffect() and not player:IsCoopGhost() then data.eclipsed.RocketThrowMulti = 14 end
				local throwVelocity = player:GetShootingJoystick() or player:GetShootingInput()
				data.eclipsed.ThrowVelocity = throwVelocity*player.ShotSpeed
				player:ThrowHeldEntity(data.eclipsed.ThrowVelocity)
				data.eclipsed.HoldBomd = 20
			elseif data.eclipsed.ForRoom.AbihuIgnites or (player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and not player:HasCurseMistEffect() and not player:IsCoopGhost()) then
				if data.eclipsed.AbihuDamageDelay < maxCharge then
					data.eclipsed.AbihuDamageDelay = data.eclipsed.AbihuDamageDelay + 1
				elseif data.eclipsed.AbihuDamageDelay == maxCharge and game:GetFrameCount() % 6 == 0 then
					player:SetColor(Color(1,1,1,1, 0.2, 0.2, 0.5), 2, 1, true, false)
				end
			end
		end
	elseif player:GetPlayerType() == enums.Characters.Unbidden then
	---Unbidden
		functions.ActiveItemWispsManager(player)
		if player:GetMaxHearts() > 0 then
			local maxHearts = player:GetMaxHearts()
			player:AddMaxHearts(-maxHearts)
			player:AddSoulHearts(maxHearts)
        end
		if player:GetHearts() > 0 then
			player:AddHearts(-player:GetHearts()) -- bone hearts can
		end
		---rewind
		if data.eclipsed.NoAnimReset then
			player:AnimateTeleport(false)
            data.eclipsed.NoAnimReset = data.eclipsed.NoAnimReset - 1
			if data.eclipsed.NoAnimReset == 0 then
				data.eclipsed.NoAnimReset = nil
				player:AddBrokenHearts(1)
				if data.eclipsed.BeastCounter then
					player:AddBrokenHearts(data.eclipsed.BeastCounter)
					data.eclipsed.BeastCounter = data.eclipsed.BeastCounter + 1
				end
			end
        end
	elseif player:GetPlayerType() == enums.Characters.UnbiddenB then
	---UnbiddenB
		functions.ActiveItemWispsManager(player)
		---holyMantles
		if tempEffects:GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_HOLY_MANTLE) == data.eclipsed.UnbiddenUsedHolyCard+1 then
			if player:HasTrinket(TrinketType.TRINKET_WOODEN_CROSS) then
				data.eclipsed.ForLevel.LostWoodenCross = true
			end
			tempEffects:RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE) -- remove 1 stack of holy mantle
		end
		if player:GetEffectiveMaxHearts() > 0 then
			player:AddMaxHearts(-player:GetEffectiveMaxHearts())
        end
		if player:GetSoulHearts() > 2 and not player:HasCollectible(CollectibleType.COLLECTIBLE_ALABASTER_BOX) then
			local allsouls = player:GetSoulHearts()-2
			player:AddSoulHearts(-allsouls)
		end
		---RemoveCurses
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and level:GetCurses() > 0 then
			level:RemoveCurses(level:GetCurses())
		end
		---Reset GHG
		if data.eclipsed.NoAnimReset then
			player:AnimateTeleport(false)
			if not tempEffects:HasNullEffect(NullItemID.ID_LOST_CURSE) then
				tempEffects:AddNullEffect(NullItemID.ID_LOST_CURSE, false)
			end
			data.eclipsed.NoAnimReset = data.eclipsed.NoAnimReset - 1
			if data.eclipsed.NoAnimReset == 0 then
				data.eclipsed.BlindCharacter = true
				functions.SetBlindfold(player, true)
				data.eclipsed.LevelRewindCounter = data.eclipsed.LevelRewindCounter or 0
				data.eclipsed.ResetGame = data.eclipsed.ResetGame or 100
				data.eclipsed.ResetGame = data.eclipsed.ResetGame - 1 * data.eclipsed.LevelRewindCounter
				data.eclipsed.LevelRewindCounter = data.eclipsed.LevelRewindCounter + 1
				data.eclipsed.NoAnimReset = nil
			end
		end
		---blind --removeTears
		if (player:HasWeaponType(WeaponType.WEAPON_BOMBS) or
			player:HasWeaponType(WeaponType.WEAPON_ROCKETS) or
			player:HasWeaponType(WeaponType.WEAPON_FETUS) or
			player:HasWeaponType(WeaponType.WEAPON_SPIRIT_SWORD) or
			player:HasWeaponType(WeaponType.WEAPON_KNIFE)) and
			data.eclipsed.BlindCharacter
		then
			data.eclipsed.BlindCharacter = false
			functions.SetBlindfold(player, false)
		elseif not data.eclipsed.BlindCharacter then
			data.eclipsed.BlindCharacter = true
			functions.SetBlindfold(player, true)
		end
		-- urn of souls and nocthed axe. idk how to remove tech2 laser when you use this items.
		--(i can remove all lasers while you have weapon but it's not a proper solution)
		local weapon = player:GetActiveWeaponEntity()
		if weapon then
			if weapon:ToKnife() or weapon:ToEffect() then
				data.eclipsed.UnbiddenBDamageDelay = 0
				data.eclipsed.HoldingWeapon = true
			end
		else
			data.eclipsed.HoldingWeapon = false
		end
		---Lasers
		--not player:HasCurseMistEffect() and not player:IsCoopGhost() and
		if (player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY) or player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) or player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X)) then
			data.eclipsed.UnbiddenBDamageDelay = data.eclipsed.UnbiddenBDamageDelay or 0
			local laserDelay = data.eclipsed.UnbiddenBDamageDelay
			if laserDelay < 6 then laserDelay = 6 end
			data.eclipsed.UnbiddenBrimCircle = laserDelay
		elseif data.eclipsed.UnbiddenBrimCircle then
			data.eclipsed.UnbiddenBrimCircle = false
		end
		---Blind
		if data.eclipsed.BlindCharacter then
			---change position if you has ludo
			local auraPos = player.Position
			---CustomFiredelay
			local maxCharge = math.floor(player.MaxFireDelay) + 6

			data.eclipsed.UnbiddenBDamageDelay = data.eclipsed.UnbiddenBDamageDelay or 0
			if not data.eclipsed.UnbiddenFullCharge and not data.eclipsed.UnbiddenSemiCharge then
				if data.eclipsed.UnbiddenBDamageDelay < maxCharge then data.eclipsed.UnbiddenBDamageDelay = data.eclipsed.UnbiddenBDamageDelay + 1 end
			end
			---curse mist and coop ghost
			--[[
			if player:HasCurseMistEffect() or player:IsCoopGhost() then
				if data.UnbiddenBDamageDelay >= maxCharge then
					local tearsNum = functions.GetMultiShotNum(player)
					data.eclipsed.MultipleAura = data.eclipsed.MultipleAura or 0
					data.eclipsed.MultipleAura = data.eclipsed.MultipleAura + tearsNum
					functions.UnbiddenAura(player, auraPos)
					return
				end
			end
			--]]
			---DeadEye counter
			if player:HasCollectible(CollectibleType.COLLECTIBLE_DEAD_EYE) then
				data.eclipsed.DeadEyeCounter = data.eclipsed.DeadEyeCounter or 0
				data.eclipsed.DeadEyeMissCounter = data.eclipsed.DeadEyeMissCounter or 0
			end
			---semi-charge
			if player:HasCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK) or player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X) or player:HasCollectible(CollectibleType.COLLECTIBLE_CURSED_EYE) then
				data.eclipsed.UnbiddenSemiCharge = true
				--if data.eclipsed.UnbiddenFullCharge then data.eclipsed.UnbiddenFullCharge = false end
			---full-charge
			elseif player:HasCollectible(CollectibleType.COLLECTIBLE_MONSTROS_LUNG) or player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) then --or player:HasWeaponType(WeaponType.WEAPON_MONSTROS_LUNGS) then
				data.eclipsed.UnbiddenFullCharge = true
				if data.eclipsed.UnbiddenSemiCharge then data.eclipsed.UnbiddenSemiCharge = false end
			---no-charge
			else
				if data.eclipsed.UnbiddenFullCharge then data.eclipsed.UnbiddenFullCharge = false end
				if data.eclipsed.UnbiddenSemiCharge then data.eclipsed.UnbiddenSemiCharge = false end
			end
			---Marked
			if player:HasCollectible(CollectibleType.COLLECTIBLE_MARKED) then
				local targets = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.TARGET)
				if #targets > 0 then
					for _, target in pairs(targets) do
						if target.SpawnerEntity and target.SpawnerEntity:ToPlayer() and target.SpawnerEntity:ToPlayer():GetPlayerType() == enums.Characters.UnbiddenB then
							auraPos = target.Position
							data.eclipsed.UnbiddenMarked = true
							break
						end
					end
				elseif data.eclipsed.UnbiddenMarked then
					data.eclipsed.UnbiddenMarked = false
				end
			elseif data.eclipsed.UnbiddenMarked then
				data.eclipsed.UnbiddenMarked = nil
			end
			---Eye of Occult
			if player:HasCollectible(CollectibleType.COLLECTIBLE_EYE_OF_THE_OCCULT) then
				local targets = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.OCCULT_TARGET)
				if #targets > 0 then
					for _, target in pairs(targets) do
						if target.SpawnerEntity and target.SpawnerEntity:ToPlayer() and target.SpawnerEntity:ToPlayer():GetPlayerType() == enums.Characters.UnbiddenB then
							auraPos = target.Position
							data.eclipsed.UnbiddenOccult = true
							break
						end
					end
				elseif data.eclipsed.UnbiddenOccult then
					data.eclipsed.UnbiddenOccult = false
				end
			elseif data.eclipsed.UnbiddenOccult then
				data.eclipsed.UnbiddenOccult = nil
			end
			---Ludovico
			if player:HasCollectible(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE) then
				if Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex) then
					data.eclipsed.ludo = false
					data.eclipsed.TechLudo = false
				end
				if player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY) then
					local lasers = Isaac.FindByType(EntityType.ENTITY_LASER)
					if #lasers > 0 then
						for _, laser in pairs(lasers) do
							if laser:GetData().UnbiddenLaser then
								auraPos = laser.Position
								if not data.eclipsed.ludo and player.Position:Distance(laser.Position) > 60 then
									laser:AddVelocity((player.Position - laser.Position):Resized(player.ShotSpeed*5))
								end
							end
						end
					else
						local rrnge = player.TearRange*0.5
						if rrnge > 300 then rrnge = 300 end
						--Isaac.Spawn(EntityType.ENTITY_LASER, datatables.UnbiddenBData.TearVariant, 0, player.Position, Vector.Zero, player):ToTear()
						local laser = player:FireTechXLaser(auraPos, Vector.Zero, rrnge, player, 1):ToLaser()
						--laser:AddTearFlags(player.TearFlags)
						--laser.Variant = LaserVariant.THIN_RED
						laser:GetData().UnbiddenLaser = level:GetCurrentRoomIndex()
						laser:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
						laser:SetTimeout(-1)
						data.eclipsed.TechLudo = true
					end
				else
					local tears = Isaac.FindByType(EntityType.ENTITY_TEAR, TearVariant.MULTIDIMENSIONAL)
					if #tears > 0 and not data.eclipsed.LudoTearEnable then
						for _, tear in pairs(tears) do
							if tear:GetData().UnbiddenTear then
								auraPos = tear.Position
								if not data.eclipsed.ludo and player.Position:Distance(tear.Position) > 60 then
									tear:AddVelocity((player.Position - tear.Position):Resized(player.ShotSpeed))
								end
							end
						end
					else
						local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.MULTIDIMENSIONAL, 0, player.Position, Vector.Zero, player):ToTear()
						tear:AddTearFlags(player.TearFlags)
						tear.CollisionDamage = 0
						tear:GetData().UnbiddenTear = true
						tear.EntityCollisionClass = 0
						data.eclipsed.LudoTearEnable = false
					end
				end
			else
				if data.eclipsed.ludo then data.eclipsed.ludo = false end
				if data.eclipsed.TechLudo then data.eclipsed.TechLudo = false end
			end
			---NotShooting
			if player:GetFireDirection() == Direction.NO_DIRECTION or data.eclipsed.UnbiddenMarkedAuto then
				if data.eclipsed.UnbiddenMarkedAuto then data.eclipsed.UnbiddenMarkedAuto = nil end
				if data.eclipsed.UnbiddenBTechDot5Delay then data.eclipsed.UnbiddenBTechDot5Delay = 0 end
				if data.eclipsed.HasTech2Laser then data.eclipsed.HasTech2Laser = false end
				---semi charged attack
				if data.eclipsed.UnbiddenSemiCharge and data.eclipsed.UnbiddenBDamageDelay > 0 then
					local tearsNum = functions.GetMultiShotNum(player)
					data.eclipsed.MultipleAura = data.eclipsed.MultipleAura or 0
					local chargeCounter = math.floor((data.eclipsed.UnbiddenBDamageDelay * 100) /maxCharge)
					if player:HasCollectible(CollectibleType.COLLECTIBLE_CURSED_EYE) then
						tearsNum = tearsNum + math.floor(chargeCounter*0.04) --(1/25) -- add +1 aura activation for each 25 charge counter
					end
					if player:HasCollectible(CollectibleType.COLLECTIBLE_MONSTROS_LUNG) then
						tearsNum = tearsNum + 1+ math.floor(chargeCounter * 0.13) --(min = 1 ; max = 14) -- magic number :) monstro lung creates 14 tears when fully charged so 1 + 13/100
					end
					data.eclipsed.MultipleAura = data.eclipsed.MultipleAura + tearsNum
					local ChocolateDamageMultiplier = 1
					if player:HasCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK) then
						if player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) then
							ChocolateDamageMultiplier = chargeCounter * 0.025
							if ChocolateDamageMultiplier < 0.25 then ChocolateDamageMultiplier = 0.25 end
						else
							ChocolateDamageMultiplier = chargeCounter * 0.04
							if ChocolateDamageMultiplier < 0.1 then ChocolateDamageMultiplier = 0.1 end
						end
					end
					functions.UnbiddenAura(player, auraPos, false, ChocolateDamageMultiplier)
				---charged attack
				elseif data.eclipsed.UnbiddenFullCharge then
					if data.eclipsed.UnbiddenBDamageDelay == maxCharge then
						local tearsNum = functions.GetMultiShotNum(player)
						data.eclipsed.MultipleAura = data.eclipsed.MultipleAura or 0
						if player:HasCollectible(CollectibleType.COLLECTIBLE_MONSTROS_LUNG) then
							data.eclipsed.MultipleAura = data.eclipsed.MultipleAura + 14 + tearsNum
						end
						functions.UnbiddenAura(player, auraPos)
					else
						data.eclipsed.UnbiddenBDamageDelay = 0
					end
				--- auto attack
				elseif data.eclipsed.ludo or player:HasCollectible(CollectibleType.COLLECTIBLE_EYE_OF_THE_OCCULT) then
					if data.eclipsed.UnbiddenBDamageDelay >= maxCharge then
						local tearsNum = functions.GetMultiShotNum(player)
						data.eclipsed.MultipleAura = data.eclipsed.MultipleAura or 0
						data.eclipsed.MultipleAura = data.eclipsed.MultipleAura + tearsNum
						functions.UnbiddenAura(player, auraPos)
					end
				end
			---Shooting
			elseif player:GetFireDirection() ~= Direction.NO_DIRECTION or data.eclipsed.ludo then
				if player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_5) then
					data.eclipsed.UnbiddenBTechDot5Delay = data.eclipsed.UnbiddenBTechDot5Delay or 0
					data.eclipsed.UnbiddenBTechDot5Delay = data.eclipsed.UnbiddenBTechDot5Delay + 1
					if data.eclipsed.UnbiddenBTechDot5Delay >= maxCharge then
						functions.TechDot5Shot(player)
						data.eclipsed.UnbiddenBTechDot5Delay = 0
					end
				end
				---charged attack
				if data.eclipsed.UnbiddenFullCharge or data.eclipsed.UnbiddenSemiCharge then
					if data.eclipsed.UnbiddenBDamageDelay < maxCharge then
						data.eclipsed.UnbiddenBDamageDelay = data.eclipsed.UnbiddenBDamageDelay + 1
					elseif data.eclipsed.UnbiddenBDamageDelay == maxCharge then
						if game:GetFrameCount() % 6 == 0 then
							player:SetColor(Color(1,1,1,1, 0.2, 0.2, 0.5), 2, 1, true, false)
						end
						if data.eclipsed.UnbiddenMarked or data.eclipsed.UnbiddenOccult then
							data.eclipsed.UnbiddenMarkedAuto = true
						end
					end
				---Normal pulse
				else
					if data.UnbiddenBDamageDelay >= maxCharge then
						local tearsNum = functions.GetMultiShotNum(player)
						data.eclipsed.MultipleAura = data.eclipsed.MultipleAura or 0
						data.eclipsed.MultipleAura = data.eclipsed.MultipleAura + tearsNum
						functions.UnbiddenAura(player, auraPos)
					end
				end
				---marked
				if player:HasCollectible(CollectibleType.COLLECTIBLE_MARKED) then
					data.eclipsed.UnbiddenMarked = true
				end
				---ludovico
				if player:HasCollectible(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE) then
					data.eclipsed.ludo = true
				end
				---GodHead
				if player:HasCollectible(CollectibleType.COLLECTIBLE_GODHEAD) then
					functions.GodHeadAura(player)
				end
				---Tech2
				if player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY_2) and not data.eclipsed.HasTech2Laser then
					functions.Technology2Aura(player)
				end
			end
		end
	end
	---RETURN
	if player:HasCurseMistEffect() then return end
	if player:IsCoopGhost() then return end
	---Eclipse
	if player:HasCollectible(enums.Items.Eclipse) then
		functions.EclipseAura(player)
	end
	---TetrisDice
	functions.TetrisDiceCheks(player)
	---NirlyCodex
	if player:HasCollectible(enums.Items.NirlyCodex) and data.eclipsed.NirlySavedCards and #data.eclipsed.NirlySavedCards > 0 then
		if Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex) then
			data.eclipsed.NirlyDropTimer = data.eclipsed.NirlyDropTimer or 0
			if data.eclipsed.NirlyDropTimer == 60 then
				data.eclipsed.NirlyDropTimer = 0
				for _, card in ipairs(data.eclipsed.NirlySavedCards) do
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, card, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, nil)
				end
				data.eclipsed.NirlySavedCards ={}
			else
				data.eclipsed.NirlyDropTimer = data.eclipsed.NirlyDropTimer +1
			end
		end
	end
	---LongElk
	if player:HasCollectible(enums.Items.LongElk) then
		if data.eclipsed.ForRoom.ElkKiller then
			if not tempEffects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_MARS) then
				data.eclipsed.ForRoom.ElkKiller = false
			end
		end
		if not data.eclipsed.BoneSpurTimer then
			data.eclipsed.BoneSpurTimer = 18
		else
			if data.eclipsed.BoneSpurTimer > 0 then
				data.eclipsed.BoneSpurTimer = data.BoneSpurTimer - 1
			end
		end
		if player:GetMovementDirection() ~= -1 and not room:IsClear() and data.eclipsed.BoneSpurTimer <= 0 then
			local spur = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BONE_SPUR, 0, player.Position, Vector.Zero, player)
			if spur then
				spur:GetData().RemoveTimer = 90
			end
			data.eclipsed.BoneSpurTimer = 18
		end
	end
	---TeaFungus
	if player:HasTrinket(enums.Trinkets.TeaFungus) and not room:HasWater() and room:GetFrameCount() <= 2  then
		if room:GetFrameCount() == 1 then
			local enemies = Isaac.FindInRadius(player.Position, 5000, EntityPartition.ENEMY)
			for _, enemy in pairs(enemies) do
				if enemy:ToNPC() and enemy:IsVulnerableEnemy() and enemy:IsActiveEnemy() and not enemy:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
					enemy:AddEntityFlags(EntityFlag.FLAG_FRIENDLY)
					enemy:GetData().TeaFungused = true
				end
			end
		elseif room:GetFrameCount() == 2 then
			player:UseActiveItem(CollectibleType.COLLECTIBLE_FLUSH, datatables.NoAnimNoAnnounMimic)
			sfx:Stop(SoundEffect.SOUND_FLUSH)
			local enemies = Isaac.FindInRadius(player.Position, 5000, EntityPartition.ENEMY)
			for _, enemy in pairs(enemies) do
				if enemy:ToNPC() and enemy:IsVulnerableEnemy() and enemy:IsActiveEnemy() and enemy:GetData().TeaFungused then
					enemy:ClearEntityFlags(EntityFlag.FLAG_FRIENDLY)
					enemy:GetData().TeaFungused = nil
				end
			end
		end
	end
	---WitchPaper
	if data.eclipsed.WitchPaper then
		data.eclipsed.WitchPaper = data.eclipsed.WitchPaper - 1
		if data.eclipsed.WitchPaper <= 0 then
			data.eclipsed.WitchPaper = nil
			player:AnimateTrinket(enums.Trinkets.WitchPaper)
			player:TryRemoveTrinket(enums.Trinkets.WitchPaper)
		end
	end
	---Corruption
	if data.eclipsed.ForRoom.Corruption then
		if data.eclipsed.ForRoom.Corruption <= 0 then
			data.eclipsed.ForRoom.Corruption = nil
			player:TryRemoveNullCostume(datatables.Corruption.CostumeHead)
			local activeItem = player:GetActiveItem(ActiveSlot.SLOT_PRIMARY)
			if activeItem ~= 0 then
				player:RemoveCollectible(activeItem)
			end
		elseif player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) ~= 0 then
			local activeItem = player:GetActiveItem(ActiveSlot.SLOT_PRIMARY)
			if player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY) < Isaac.GetItemConfig():GetCollectible(activeItem).MaxCharges then
				data.eclipsed.ForRoom.Corruption = data.eclipsed.ForRoom.Corruption - 1
				player:FullCharge(ActiveSlot.SLOT_PRIMARY, true)
			end
		end
	end
	---MewGen
	if player:HasCollectible(enums.Items.MewGen) then
		data.eclipsed.MewGenTimer = data.eclipsed.MewGenTimer or game:GetFrameCount()
		data.eclipsed.CheckTimer = data.eclipsed.CheckTimer or 150
		if player:GetFireDirection() == Direction.NO_DIRECTION then
			if game:GetFrameCount() - data.eclipsed.MewGenTimer >= data.eclipsed.CheckTimer then --datatables.MewGen.ActivationTimer
				data.eclipsed.MewGenTimer = game:GetFrameCount()
				player:UseActiveItem(CollectibleType.COLLECTIBLE_TELEKINESIS, datatables.NoAnimNoAnnounMimicNoCostume)
				data.eclipsed.CheckTimer = 90
			end
		else
			data.eclipsed.MewGenTimer = game:GetFrameCount()
			data.eclipsed.CheckTimer = 150
		end
	end
	---RedPills
	if data.eclipsed.RedPillDamageUp then --and game:GetFrameCount()%2 == 0 then
		data.eclipsed.RedPillDamageUp = data.eclipsed.RedPillDamageUp - data.eclipsed.RedPillDamageDown
		data.eclipsed.RedPillDamageDown = data.eclipsed.RedPillDamageDown + 0.00001
		if data.eclipsed.RedPillDamageUp < 0 then
			data.eclipsed.RedPillDamageUp = 0
		end
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE) -- | CacheFlag.CACHE_FIREDELAY)
		player:EvaluateItems()
		if data.eclipsed.RedPillDamageUp == 0 then
			data.eclipsed.RedPillDamageUp = nil
			data.eclipsed.RedPillDamageDown = nil
		end
	end
	---RubberDuck
	if player:HasCollectible(enums.Items.RubberDuck) then
		data.eclipsed.DuckCurrentLuck = data.eclipsed.DuckCurrentLuck or 0
	else
		if data.eclipsed.DuckCurrentLuck and data.eclipsed.DuckCurrentLuck > 0 then
			functions.EvaluateDuckLuck(player, 0)
		end
	end
	---LostFlower
	if player:HasTrinket(enums.Trinkets.LostFlower) and player:GetEternalHearts() > 0 then
		player:AddEternalHearts(1)
	end
	---TomeDead
	if player:HasCollectible(enums.Items.TomeDead) then
		if player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == enums.Items.TomeDead and Input.IsActionPressed(ButtonAction.ACTION_ITEM, player.ControllerIndex) then
			if player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY) < Isaac.GetItemConfig():GetCollectible(enums.Items.TomeDead).MaxCharges and player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY) > 0 then
				player:UseActiveItem(enums.Items.TomeDead)
			end
		end
		if data.eclipsed.TomeDead then
			data.eclipsed.TomeDead = data.eclipsed.TomeDead -1
			if data.eclipsed.TomeDead <= 0 then
				data.eclipsed.TomeDead = nil
			end
		else
			data.eclipsed.CollectedSouls = data.eclipsed.CollectedSouls or 0
			if data.eclipsed.CollectedSouls >= 4 then
				for slot = 0, 3 do
					if player:GetActiveItem(slot) == enums.Items.TomeDead then
						local a_charge = player:GetActiveCharge(slot)
						local b_charge = player:GetBatteryCharge(slot)
						local max_charge = Isaac.GetItemConfig():GetCollectible(enums.Items.TomeDead).MaxCharges
						if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) then
							if a_charge + b_charge  < 2*max_charge then
								data.eclipsed.CollectedSouls = data.eclipsed.CollectedSouls - 10
								player:SetActiveCharge(a_charge + b_charge +1, slot)
								sfx:Play(SoundEffect.SOUND_BATTERYCHARGE)
							end
						else
							if a_charge < max_charge then
								data.eclipsed.CollectedSouls = data.eclipsed.CollectedSouls - 10
								player:SetActiveCharge(a_charge +1, slot)
								sfx:Play(SoundEffect.SOUND_BATTERYCHARGE)
							end
						end
						break
					end
				end
			elseif data.eclipsed.CollectedSouls < 4 then
				local lilGhosts = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.ENEMY_GHOST, 0)
				for _, lilg in pairs(lilGhosts) do
					if lilg.Position:Distance(player.Position) < 25 then
						lilg:Remove()
						sfx:Play(SoundEffect.SOUND_SOUL_PICKUP)
						data.eclipsed.CollectedSouls = data.eclipsed.CollectedSouls + 1
					end
				end
			end
		end
	end
	---HeartTransplant
	if player:HasCollectible(enums.Items.HeartTransplant) then
		if player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == enums.Items.HeartTransplant then
			local activeCharge = player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY)
			local activeMaxCharge = Isaac.GetItemConfig():GetCollectible(enums.Items.HeartTransplant).MaxCharges
			if activeCharge == activeMaxCharge then -- discharge item on full charge
				data.eclipsed.HeartTransplantDelay = data.eclipsed.HeartTransplantDelay or datatables.HeartTransplant.DischargeDelay
				data.eclipsed.HeartTransplantUseCount = data.eclipsed.HeartTransplantUseCount or 1
				local missValue = 1
				if data.eclipsed.HeartTransplantUseCount >= #datatables.HeartTransplant.ChainValue then
					missValue = 2
				end
				data.eclipsed.HeartTransplantDelay = data.eclipsed.HeartTransplantDelay - missValue
				if data.eclipsed.HeartTransplantDelay <= 0 then
					data.eclipsed.HeartTransplantActualCharge = 0
					player:DischargeActiveItem(ActiveSlot.SLOT_PRIMARY)
					functions.HeartTranslpantFunc(player)
					if data.eclipsed.HeartTransplantUseCount > 1 then
						data.eclipsed.HeartTransplantUseCount = data.eclipsed.HeartTransplantUseCount - 1
					end
					sfx:Play(SoundEffect.SOUND_HEARTBEAT, 500)
					if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
						local wisp = player:AddWisp(enums.Items.HeartTransplant, player.Position)
						if wisp then
							wisp:GetData().TemporaryWisp = true
						end
					end
				end
			else -- if item was used on not full charge
				if data.eclipsed.HeartTransplantActualCharge and data.eclipsed.HeartTransplantActualCharge > 0 and Input.IsActionPressed(ButtonAction.ACTION_ITEM, player.ControllerIndex) then
					if data.eclipsed.HeartTransplantUseCount then
						if data.eclipsed.HeartTransplantActualCharge > 1 then
							if data.eclipsed.HeartTransplantActualCharge > datatables.HeartTransplant.ChainValue[data.eclipsed.HeartTransplantUseCount][4] then
								data.eclipsed.HeartTransplantActualCharge = data.eclipsed.HeartTransplantActualCharge - datatables.HeartTransplant.ChainValue[data.eclipsed.HeartTransplantUseCount][4]
							end
						end
						player:SetActiveCharge(data.eclipsed.HeartTransplantActualCharge, ActiveSlot.SLOT_PRIMARY)
						functions.HeartTranslpantFunc(player)
					end
				else
					local charge = 1
					if data.eclipsed.HeartTransplantUseCount and data.eclipsed.HeartTransplantUseCount > 0 then
						charge = data.eclipsed.HeartTransplantUseCount
					end
					charge = datatables.HeartTransplant.ChainValue[charge][4]
					data.eclipsed.HeartTransplantActualCharge = data.eclipsed.HeartTransplantActualCharge or 0
					data.eclipsed.HeartTransplantActualCharge = data.eclipsed.HeartTransplantActualCharge + charge
					player:SetActiveCharge(data.eclipsed.HeartTransplantActualCharge, ActiveSlot.SLOT_PRIMARY)
				end
			end
		else -- if item changed (pick another item or swap)
			if data.eclipsed.HeartTransplantActualCharge then
				data.eclipsed.HeartTransplantActualCharge = 0
				functions.HeartTranslpantFunc(player)
			end
		end
	else
		if data.eclipsed.HeartTransplantActualCharge then
			data.eclipsed.HeartTransplantUseCount = nil
			data.eclipsed.HeartTransplantActualCharge = nil
			functions.HeartTranslpantFunc(player)
		end
	end
	---RubikDice
	if datatables.RubikDice.ScrambledDices[player:GetActiveItem(ActiveSlot.SLOT_PRIMARY)] then
		local scrambledice = player:GetActiveItem(ActiveSlot.SLOT_PRIMARY)
		if player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY) >= Isaac.GetItemConfig():GetCollectible(scrambledice).MaxCharges then
			player:RemoveCollectible(scrambledice)
			player:AddCollectible(enums.Items.RubikDice)
			player:SetActiveCharge(Isaac.GetItemConfig():GetCollectible(enums.Items.RubikDice).MaxCharges, ActiveSlot.SLOT_PRIMARY)
		elseif player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY) > 0 and Input.IsActionPressed(ButtonAction.ACTION_ITEM, player.ControllerIndex) then
			local rng = player:GetCollectibleRNG(scrambledice)
			local Newdice = datatables.RubikDice.ScrambledDicesList[rng:RandomInt(#datatables.RubikDice.ScrambledDicesList)+1]
			functions.RerollTMTRAINER(player, scrambledice)
			player:RemoveCollectible(scrambledice)
			player:AddCollectible(Newdice)
			player:SetActiveCharge(0, ActiveSlot.SLOT_PRIMARY)
		end
	end
	---BlackKnight
	if player:HasCollectible(enums.Items.BlackKnight, true) then
		if not data.eclipsed.HasBlackKnight then data.eclipsed.HasBlackKnight = true end
		if not data.eclipsed.ForRoom.ControlTarget then data.eclipsed.ForRoom.ControlTarget = true end
		if not player:HasEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK) then
			player:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
		end
		if data.eclipsed.ForRoom.KnightTarget and player:HasCollectible(CollectibleType.COLLECTIBLE_DOGMA) or player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_MEGA_MUSH) then
			data.eclipsed.ForRoom.KnightTarget:Remove()
			data.eclipsed.ForRoom.KnightTarget = nil
		elseif not data.eclipsed.ForRoom.KnightTarget and not player:HasCollectible(CollectibleType.COLLECTIBLE_DOGMA) and not player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_MEGA_MUSH) then
			data.eclipsed.ForRoom.KnightTarget = Isaac.Spawn(EntityType.ENTITY_EFFECT, enums.Effects.BlackKnightTarget, 0, player.Position, Vector.Zero, player):ToEffect()
			data.eclipsed.ForRoom.KnightTarget.Parent = player
		end
		if data.eclipsed.ForRoom.KnightTarget and data.eclipsed.ForRoom.KnightTarget:Exists() then
			--local targetData = data.eclipsed.ForRoom.KnightTarget:GetData()
			--local targetSprite = data.eclipsed.ForRoom.KnightTarget:GetSprite()
			if data.KnightTarget:CollidesWithGrid() and player.ControlsEnabled then
				for gridIndex = 1, room:GetGridSize() do
					if room:GetGridEntity(gridIndex) then
						local grid = room:GetGridEntity(gridIndex)
						if (data.eclipsed.ForRoom.KnightTarget.Position - grid.Position):Length() <= 40 then
							if grid.Desc.Type == GridEntityType.GRID_DOOR then
								grid = grid:ToDoor()
								if room:IsClear() then
									grid:TryUnlock(player)
								end
								if grid:IsOpen() then
									if (player.Position - grid.Position):Length() <= 40 then
										player.Position = grid.Position
										player:SetColor(Color(1, 1, 1, 0), 2, 999, false, true)
									else
										player:PlayExtraAnimation("TeleportUp")
										data.eclipsed.ForRoom.NextRoom = grid.Position
										data.eclipsed.ForRoom.Jumped = true
										data.eclipsed.ForRoom.ControlTarget = false
									end
								end
							end
						end

					end
				end
				if room:GetType() == RoomType.ROOM_DUNGEON then
					if ((data.eclipsed.ForRoom.KnightTarget.Position - Vector(110, 135)):Length() or (data.eclipsed.ForRoom.KnightTarget.Position - Vector(595, 272)):Length() or (data.eclipsed.ForRoom.KnightTarget.Position - Vector(595, 385)):Length()) <= 35 then
						player.Position = data.eclipsed.ForRoom.KnightTarget.Position
						player:SetColor(Color(1, 1, 1, 0), 2, 999, false, true)
					end
				end
			end
		end
		if data.eclipsed.ForRoom.Jumped then
			if sprite:GetAnimation() == "TeleportUp" then
				player.FireDelay = player.MaxFireDelay-1 -- it can pause some charging attacks (better way to remove tears in TearInit callback but meh)
				data.eclipsed.ForRoom.ControlTarget = false
				player.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
				player.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
				if player:IsExtraAnimationFinished() then
					if data.eclipsed.ForRoom.NextRoom then
						player.Position = data.NextRoom
						player:SetColor(Color(1, 1, 1, 0), 2, 999, false, true)
						data.eclipsed.ForRoom.NextRoom = nil
						data.eclipsed.ForRoom.ControlTarget = true
						data.eclipsed.ForRoom.Jumped = nil
					else
						player:PlayExtraAnimation("TeleportDown")
					end
				end
			elseif sprite:GetAnimation() == "TeleportDown" then
				if data.eclipsed.ForRoom.KnightTarget then
					player.Position = data.eclipsed.ForRoom.KnightTarget.Position
					data.eclipsed.ForRoom.ControlTarget = false
				end
			elseif sprite:IsFinished("TeleportDown") then

				data.eclipsed.ForRoom.Jumped = nil
				data.eclipsed.ForRoom.ControlTarget = true
				player.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
				if player.CanFly then
					player.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
				else
					player.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
				end
				functions.KnightJumpLogic(50, 125, 80 + player.Damage/2, 20, player)

			end
		end
	else
		if data.eclipsed.HasBlackKnight then
			data.eclipsed.HasBlackKnight = nil
			player:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
			player.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			if player.CanFly then
				player.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
			else
				player.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
			end
			if data.eclipsed.ForRoom.KnightTarget then
				data.eclipsed.ForRoom.KnightTarget:Remove()
			end
			data.eclipsed.ForRoom.KnightTarget = nil
		end
	end
	---WhiteKnight
	if player:HasCollectible(enums.Items.WhiteKnight, true) then
		if data.eclipsed.ForRoom.Jumped then
			if sprite:GetAnimation() == "TeleportUp" then
				player.FireDelay = player.MaxFireDelay-1
				if player:IsExtraAnimationFinished() then
					player:PlayExtraAnimation("TeleportDown")
				end
			elseif sprite:GetAnimation() == "TeleportDown" then
				local nearest = 5000
				local JumpPosition = functions.GetNearestEnemy(player.Position)
				if player.Position:Distance(JumpPosition) == 0 then
					for gridIndex = 1, room:GetGridSize() do
						local grid = room:GetGridEntity(gridIndex)
						if grid and grid:ToDoor() and grid:ToDoor():GetVariant() ~= DoorVariant.DOOR_HIDDEN then
							local newPos = Isaac.GetFreeNearPosition(room:GetGridPosition(gridIndex), 1)
							if player.Position:Distance(newPos) < nearest then
								JumpPosition = newPos
								nearest = player.Position:Distance(newPos)
							end
						end
					end
				end
				player.Position = JumpPosition
			elseif sprite:IsFinished("TeleportDown") then
				data.eclipsed.ForRoom.Jumped = nil
				functions.KnightJumpLogic(50, 125, 80 + player.Damage/2, 20, player)
			end
		end
	end
	---TeaBag
	if player:HasTrinket(enums.Trinkets.TeaBag) then
		local removeRadius = player:GetTrinketMultiplier(enums.Trinkets.TeaBag)-1
		removeRadius = removeRadius * 40
		removeRadius = removeRadius + 120
		for _, effect in pairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.SMOKE_CLOUD)) do
			if effect.Position:Distance(player.Position) < removeRadius then
				if not effect.SpawnerEntity then
					effect:Remove()
				elseif not effect.SpawnerEntity:ToPlayer() then
					effect:Remove()
				end
			end
		end
	end
	---Viridian
	if player:HasCollectible(enums.Items.Viridian) then
		if not data.eclipsed.HasItemViridian then
			data.eclipsed.HasItemViridian = true
			player.SpriteOffset = Vector(player.SpriteOffset.X, player.SpriteOffset.Y - 34)
			player:GetSprite().FlipX = true
			player.SpriteRotation = 180
		end
	else
		if data.eclipsed.HasItemViridian then
			data.eclipsed.HasItemViridian = nil
			player.SpriteOffset = Vector(player.SpriteOffset.X, player.SpriteOffset.Y + 34)
			player:GetSprite().FlipX = false
			player.SpriteRotation = 0
		end
	end
	---AbyssCart
	if player:HasTrinket(enums.Trinkets.AbyssCart) and player:IsDead() and player:GetExtraLives() == 0 then
		if player:GetHearts() < 2 and player:GetSoulHearts() < 2 and game:GetFrameCount()%15 == 0 then
			if data.eclipsed.AbyssCartBlink then
				local blinkerBabies = Isaac.FindByType(EntityType.ENTITY_FAMILIAR, data.eclipsed.AbyssCartBlink[2])
				for _, baby in pairs(blinkerBabies) do
					baby:SetColor(Color(0.3,0.3,1,1), 10, 100, true, false)
				end
			else
				for _, elems in pairs(datatables.AbyssCart.SacrificeBabies) do
					if player:HasCollectible(elems[1]) then
						data.eclipsed.AbyssCartBlink = elems
						break
					end
				end
			end
		elseif player:GetHearts() >= 2 or player:GetSoulHearts() >= 2 then
			if data.eclipsed.AbyssCartBlink then data.eclipsed.AbyssCartBlink = nil end
		end
	end
	---RedButton
	if player:HasCollectible(enums.Items.RedButton) and not room:IsClear() then
		for gridIndex = 1, room:GetGridSize() do
			local grid = room:GetGridEntity(gridIndex)
			if grid and grid:ToPressurePlate() and grid.VarData == datatables.RedButton.VarData and grid.State ~= 0 then
				mod.ModVars.ForRoom.PressCount = mod.ModVars.ForRoom.PressCount + 1
				room:RemoveGridEntity(gridIndex, 0, false)
				grid:Update()
				if mod.ModVars.ForRoom.PressCount == 64 then
					game:GetHUD():ShowFortuneText("Please,",  "don't touch the button!")
				elseif mod.ModVars.ForRoom.PressCount == 65 then
					game:GetHUD():ShowFortuneText("Push the button!!!")
				elseif mod.ModVars.ForRoom.PressCount == 66 then
					mod.ModVars.ForRoom.PressCount = 0
					Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.FART, 0, grid.Position, Vector.Zero, nil):SetColor(Color(2.5,0,0,1),-1,1, false, false)
					local Blastocyst = Isaac.Spawn(EntityType.ENTITY_BLASTOCYST_BIG, 0, 0, room:GetCenterPos(), Vector.Zero, nil) -- spawn blastocyst
					Blastocyst:SetColor(Color(0,0,0,0),3,100, false, false)
					Blastocyst:ToNPC().State = NpcState.STATE_JUMP
				else
					functions.SpawnButton(player, room) -- spawn new button
					Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, grid.Position, Vector.Zero, nil):SetColor(datatables.RedColor,-1,1, false, false)
				end
			end
		end
	end
	---MidasCurse
	if player:HasCollectible(enums.Items.MidasCurse) then
		data.eclipsed.GoldenHeartsAmount = data.eclipsed.GoldenHeartsAmount or player:GetGoldenHearts()
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE) and data.eclipsed.TurnGoldChance ~= 0.1 then -- remove curse
			data.eclipsed.TurnGoldChance = 0.1
		elseif not player:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE) and data.eclipsed.TurnGoldChance ~= 1 then
			data.eclipsed.TurnGoldChance = 1
		end
		if player:GetMovementDirection() ~= -1 and game:GetFrameCount()%8 == 0 then
			game:SpawnParticles(player.Position, EffectVariant.GOLD_PARTICLE, 1, 2, 100000, 0)
		end
		if player:GetGoldenHearts() < data.eclipsed.GoldenHeartsAmount then
			data.eclipsed.GoldenHeartsAmount = player:GetGoldenHearts()
			room:TurnGold()
			functions.GoldenGrid()
			for _, entity in pairs(Isaac.GetRoomEntities()) do
				if entity:ToNPC() then
					local enemy = entity:ToNPC()
					enemy:RemoveStatusEffects()
					enemy:AddMidasFreeze(EntityRef(player), 10000)
				elseif entity:ToPickup() and datatables.AllowedPickupVariants[entity.Variant] then
					if player:GetCollectibleRNG(enums.Items.MidasCurse):RandomFloat() < data.eclipsed.TurnGoldChance then
						functions.TurnPickupsGold(entity:ToPickup())
					end
				end
			end
		elseif player:GetGoldenHearts() > data.eclipsed.GoldenHeartsAmount then
			data.eclipsed.GoldenHeartsAmount = player:GetGoldenHearts()
		end
	else
		if data.eclipsed.GoldenHeartsAmount then
			data.eclipsed.GoldenHeartsAmount = nil
		end
	end
	---MongoCells
	if player:HasCollectible(enums.Items.MongoCells) then
		for itemIdx, itemHidden in pairs(datatables.MongoCells.HiddenWispEffects) do
			if player:HasCollectible(itemIdx) and player:HasCollectible(itemHidden, true) then
				mod.hiddenItemManager:RemoveStack(player, itemHidden, "MONGO_CELLS")
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.onPEffectUpdate)

---POST UPDATE--
function mod:onUpdate()
	if game:GetFrameCount() > 0 then
		functions.LoadedSaveData()
	end



	local level = game:GetLevel()
	local room = game:GetRoom()
	local currentCurses = level:GetCurses()
	functions.ResetModVars()
	---MazeMemory
	if mod.ModVars.MazeMemory then
		if mod.ModVars.MazeMemory[1] then
			if mod.ModVars.MazeMemory[1] > 0 then
				mod.ModVars.MazeMemory[1] = mod.ModVars.MazeMemory[1] - 1
			elseif mod.ModVars.MazeMemory[1] == 0 then
				mod.ModVars.MazeMemory[1] = mod.ModVars.MazeMemory[1] - 1
				Isaac.ExecuteCommand("goto s.treasure.0")
			elseif mod.ModVars.MazeMemory[1] < 0 then
				game:ShowHallucination(0, BackdropType.DARK_CLOSET)
				sfx:Stop(SoundEffect.SOUND_DEATH_CARD)
				mod.ModVars.MazeMemory[1] = nil
				local index = 30
				local counter = 6
				while index <= 102 do
					index = index+2
					counter = counter - 1
					if counter >= 0 then
						local pos = room:GetGridPosition(index)
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
		elseif mod.ModVars.MazeMemory[2] then
			local roomitems = 0
			local rent = room:GetEntities()
			for ient = 0, #rent-1 do
				local ent = rent:Get(ient)
				if ent and ent:ToPickup() and ent:ToPickup().Variant == 100 then
					roomitems = roomitems + 1
				end
			end
			if roomitems < mod.ModVars.MazeMemory[2] then
				mod.ModVars.MazeMemoryTransit = 25
				mod.ModVars.MazeMemory = nil
			elseif roomitems > mod.ModVars.MazeMemory[2] then
				mod.ModVars.MazeMemory[2] = roomitems
			end
		end
	end
	if mod.ModVars.MazeMemoryTransit then
		mod.ModVars.MazeMemoryTransit = mod.ModVars.MazeMemoryTransit - 1
		if mod.ModVars.MazeMemoryTransit <= 0 then
			mod.ModVars.MazeMemoryTransit = nil
			game:StartRoomTransition(level:GetStartingRoomIndex(), 1, RoomTransitionAnim.DEATH_CERTIFICATE, game:GetPlayer(0), -1)
		end
	end
	---CurseCarrion OR Apocalypse
	if currentCurses & enums.Curses.Carrion > 0 or (mod.ModVars.ForRoom.ApocalypseRoom and level:GetCurrentRoomIndex() == mod.ModVars.ForRoom.ApocalypseRoom) then
		functions.SetRedPoop()
	end
	---CurseEnvy
	if currentCurses & enums.Curses.Envy > 0 then
		local shopItems = Isaac.FindByType(EntityType.ENTITY_PICKUP)
		for _, pickup in pairs(shopItems) do
			pickup = pickup:ToPickup()
			if pickup:IsShopItem() and pickup.OptionsPickupIndex ~= mod.ModVars.EnvyCurseIndex then
				pickup.OptionsPickupIndex = mod.ModVars.EnvyCurseIndex
			end
		end
	end
	---CurseVoid
	if mod.ModVars.VoidCurseReroll then
		mod.ModVars.VoidCurseReroll = false
		for _, enemy in pairs(Isaac.FindInRadius(room:GetCenterPos(), 5000, EntityPartition.ENEMY)) do
			if enemy:ToNPC() and enemy:IsVulnerableEnemy() and enemy:IsActiveEnemy() then
				game:RerollEnemy(enemy)
				enemy:GetData().NoDevolve = true
			end
		end
	end
	---Limb
	if mod.ModVars.ForLevel.LimbActive then
		game:Darken(1, 1)
	end
	---FrostyBombs
	if mod.ModVars.SadIceBombTear and #mod.ModVars.SadIceBombTear >0 then
		for _, pos in pairs(mod.ModVars.SadIceBombTear) do
			game:SpawnParticles(pos, EffectVariant.DIAMOND_PARTICLE, 10, 5, Color(1,1,1,1,0.5,0.5,0.8)) --bombData.eclipsed.FrostyCreepColor
			for _, tear in pairs(Isaac.FindInRadius(pos, 22, EntityPartition.TEAR)) do
				if tear.FrameCount == 1 then -- other tears can get this effects if you shoot tears near bomb (idk else how to get)
					tear = tear:ToTear()
					tear:ChangeVariant(TearVariant.ICE)
					tear:AddTearFlags(TearFlags.TEAR_SLOW | TearFlags.TEAR_ICE)
				end
			end
		end
		mod.ModVars.SadIceBombTear = {}
	end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.onUpdate)

---CURSE EVAL--
function mod:onCurseEval(curseFlags)
	local newCurse = LevelCurse.CURSE_NONE
	local player = game:GetPlayer(0)
	local curseTable = {}
	---Curses
	for _, value in pairs(enums.Curses) do
		if not (value == enums.Curses.Pride and game:GetLevel():GetStage() == LevelStage.STAGE4_3) and
		not (player:GetPlayerType() == enums.Characters.UnbiddenB and datatables.UnbiidenBannedCurses[value]) then
			table.insert(curseTable, value)
		end
	end
	---CurseEnable/Disable
	if mod.PersistentData.SpecialCursesAvtice or mod.PersistentData.SpecialCursesAvtice == nil then
		if curseFlags == LevelCurse.CURSE_NONE then
			if mod.rng:RandomFloat() < datatables.CurseChance then
				newCurse = table.remove(curseTable, mod.rng:RandomInt(#curseTable)+1)
			end
		end
	end
	---ChallengeLobotomy
	if Isaac.GetChallenge() == enums.Challenges.Lobotomy then
		datatables.VoidThreshold = 1
		curseFlags = curseFlags | enums.Curses.Void
	else
		if datatables.VoidThreshold > 0.16 then
			datatables.VoidThreshold = 0.16
		end
	end
	---CurseEnvy
	mod.ModVars.EnvyCurseIndex = Random()+1
	---UnbiddenB
	if player:GetPlayerType() == enums.Characters.UnbiddenB then
		if not (player:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE) or player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)) then
			local cc_curse = table.remove(curseTable, mod.rng:RandomInt(#curseTable)+1)
			newCurse = newCurse | cc_curse
		else
			newCurse = LevelCurse.CURSE_NONE
			curseFlags = LevelCurse.CURSE_NONE
		end
	end
	return curseFlags | newCurse
end
mod:AddCallback(ModCallbacks.MC_POST_CURSE_EVAL, mod.onCurseEval)

---CLEAN AWARD--
function mod:onRoomClear(rng, pos)
	local room = game:GetRoom()
	local level = game:GetLevel()
	---CurseJamming
	if level:GetCurses() & enums.Curses.Jamming > 0 and not room:HasCurseMist() and room:GetType() ~= RoomType.ROOM_BOSS then
		if rng:RandomFloat() < 0.16 and not mod.ModVars.ForRoom.NoJamming then
			mod.ModVars.ForRoom.NoJamming = true
			game:ShowHallucination(5, 0)
			room:RespawnEnemies()
			local players = Isaac.FindByType(EntityType.ENTITY_PLAYER)
			local enterPos = Isaac.GetFreeNearPosition(room:GetDoorSlotPosition(level.EnterDoor), 40)
			for _, ppl in pairs(players) do
				ppl:ToPlayer():SetMinDamageCooldown(60)
				ppl.Position = enterPos
			end
			return true
		end
	end
	---CurseFool and KittenSkip
	if mod.ModVars.ForRoom.NoRewards then
		mod.ModVars.ForRoom.NoRewards = nil
		return true
	end
	---RedButton
	functions.RemoveRedButton(room)
	---players
	for playerNum = 0, game:GetNumPlayers()-1 do
		local player = game:GetPlayer(playerNum)
		local playerType = player:GetPlayerType()
		local data = player:GetData()
		local tempEffects = player:GetEffects()
		data.eclipsed = data.eclipsed or {}
		---Unbidden
		if playerType == enums.Characters.Unbidden then
			functions.ActiveItemWispsChargeManager(player)
		---UnbiddenB
		elseif playerType == enums.Characters.UnbiddenB then
			functions.ActiveItemWispsChargeManager(player)
			if not data.eclipsed.BeastCounter then data.eclipsed.LevelRewindCounter = 1 end
			data.eclipsed.ResetGame = data.eclipsed.ResetGame or 100
			if data.eclipsed.ResetGame < 100 then
				data.eclipsed.ResetGame = data.eclipsed.ResetGame + 0.25
			end
		end
		if not player:HasCurseMistEffect() and not player:IsCoopGhost() then
			---COLLECTIBLE_GLYPH_OF_BALANCE
			if player:HasCollectible(CollectibleType.COLLECTIBLE_GLYPH_OF_BALANCE) then
				if playerType == enums.Characters.Nadab or playerType == enums.Characters.Abihu then
					player:AddBombs(15)
					data.eclipsed.GlyphBalanceTrigger = true
				elseif playerType == enums.Characters.Unbidden then
					if player:GetBoneHearts() > 0 then
						local boneHearts = player:GetBoneHearts()*2
						player:AddHearts(boneHearts)
					end
				elseif playerType == enums.Characters.UnbiddenB then
					if not player:HasCollectible(CollectibleType.COLLECTIBLE_ALABASTER_BOX) then
						player:AddSoulHearts(24)
					end
				end
			end
			---TornSpades
			if player:HasTrinket(enums.Trinkets.TornSpades) then
				local numTrinket = player:GetTrinketMultiplier(enums.Trinkets.TornSpades)
				if rng:RandomFloat() < 0.33 * numTrinket then
					local num = 3
					local chance = rng:RandomFloat()
					if chance < 0.05 then num = 0
					elseif chance < 0.1 then num = 1
					elseif chance < 0.15 then num = 2
					end
					local portalPos = Isaac.GetFreeNearPosition(pos, 40)
					Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, portalPos, Vector.Zero, nil)
					Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PORTAL_TELEPORT, num, portalPos, Vector.Zero, nil)
				end
			end
			---SurrogateConception
			if room:GetType() == RoomType.ROOM_BOSS and player:HasCollectible(enums.Items.SurrogateConception) then
				mod.ModVars.Surrogates = mod.ModVars.Surrogates or functions.CopyDatatable(datatables.SurrogateConceptionFams)
				data.eclipsed.PersisteneEffect = data.eclipsed.PersisteneEffect or {}
				local randFam = table.remove(mod.ModVars.Surrogates, rng:RandomInt(#mod.ModVars.Surrogates)+1)
				tempEffects:AddCollectibleEffect(randFam, false, 1)
				table.insert(data.eclipsed.PersisteneEffect, randFam)
			end
			---MongoCells
			if player:HasCollectible(enums.Items.MongoCells) then
				for itemIdx, _ in pairs(datatables.MongoCells.FlyFamiliar) do
					if player:HasCollectible(itemIdx) then
						player:AddSwarmFlyOrbital(player.Position)
					end
				end
				--[[
				if player:HasCollectible(CollectibleType.COLLECTIBLE_JUICY_SACK) then
					player:AddBlueSpider(player.Position)
				end
				if player:HasCollectible(CollectibleType.COLLECTIBLE_MYSTERY_SACK) then
					player:UseActiveItem(CollectibleType.COLLECTIBLE_BOOK_OF_SIN, datatables.NoAnimNoAnnounMimic)
				end
				if player:HasCollectible(CollectibleType.COLLECTIBLE_RUNE_BAG) then
					local randCard = itemPool:GetCard(rng:GetSeed(), false, false, true)
					Isaac.Spawn(5, 300, randCard, Isaac.GetFreeNearPosition(player.Position, 1), Vector.Zero, nil)
				end
				--]]
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, mod.onRoomClear)

---NEW ROOM--
function mod:onNewRoom()
	local room = game:GetRoom()
	local level = game:GetLevel()
	local currentCurses = level:GetCurses()
	local roomType = room:GetType()
	---RESET
 	functions.ResetModVars()

	---NadabBody
	local bodies = Isaac.FindByType(EntityType.ENTITY_BOMB, BombVariant.BOMB_DECOY)
	for _, body in pairs(bodies) do
		if body.SpawnerEntity == nil or (body:GetData().eclipsed and body:GetData().eclipsed.NadabBomb) then
			body:Remove()
		end
	end
	---LoopCards
	if room:IsFirstVisit() then
		if mod.ModVars.ForRoom.OpenDoors then
			for slot = 0, DoorSlot.NUM_DOOR_SLOTS do
				local door = room:GetDoor(slot)
				if door then
					door:TryBlowOpen(true, nil)
				end
			end
		end
		if mod.ModVars.ForRoom.VampireMansion then
			Isaac.Spawn(EntityType.ENTITY_SLOT, 5, 0, Isaac.GetFreeNearPosition(room:GetCenterPos(), -40), Vector.Zero, nil)
		end
		if mod.ModVars.ForRoom.SwampCard then
			Isaac.Spawn(EntityType.ENTITY_SLOT, 18, 0, Isaac.GetFreeNearPosition(room:GetCenterPos(), -40), Vector.Zero, nil)
		end
		if mod.ModVars.ForRoom.WheatFieldsCard then
			room:TurnGold()
			for _, pickup in pairs(Isaac.GetRoomEntities()) do
				if pickup:ToPickup() then
					functions.TurnPickupsGold(pickup:ToPickup())
				end
			end
		end
		if mod.ModVars.ForRoom.GroveCard then
			room:SetAmbushDone(false)
			for _, pickup in pairs(Isaac.GetRoomEntities()) do
				if pickup:ToPickup() then
					pickup:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, 0)
					break
				end
			end
		end
		if mod.ModVars.ForRoom.CemeteryCard then
			game:ShowHallucination(0, BackdropType.DARKROOM)
			sfx:Stop(SoundEffect.SOUND_DEATH_CARD)
			for _, entity in pairs(Isaac.GetRoomEntities()) do
				if entity:ToPickup() then
					entity:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, enums.Items.GardenTrowel)
					break
				end
			end
			local position = room:GetCenterPos()
			local tleft = Isaac.GetFreeNearPosition(Vector(position.X-80,position.Y-120), 40)
			local tright = Isaac.GetFreeNearPosition(Vector(position.X+80,position.Y-120), 40)
			local bleft = Isaac.GetFreeNearPosition(Vector(position.X-80,position.Y+40), 40)
			local bright = Isaac.GetFreeNearPosition(Vector(position.X+80,position.Y+40), 40)
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DIRT_PATCH, 0, tleft, Vector.Zero, nil)
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DIRT_PATCH, 0, tright, Vector.Zero, nil)
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DIRT_PATCH, 0, bleft, Vector.Zero, nil)
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DIRT_PATCH, 0, bright, Vector.Zero, nil)
		end
	end
	mod.ModVars.ForRoom = {}
	---RETURN
	if room:HasCurseMist() then return end
	---CurseFool
	if currentCurses & enums.Curses.Fool > 0 and roomType == RoomType.ROOM_DEFAULT and not room:IsFirstVisit() then
		if mod.rng:RandomFloat() < 0.16 then
			room:RespawnEnemies()
			for slot = 0, DoorSlot.NUM_DOOR_SLOTS do
				local door = room:GetDoor(slot)
				if door then
					door:Open()
				end
			end
			room:SetClear(true)
			mod.ModVars.ForRoom.NoRewards = true
		end
	end
	---CurseVoid
	if currentCurses & enums.Curses.Void > 0 and not room:IsClear() then
		if mod.rng:RandomFloat() < datatables.VoidThreshold then
			mod.ModVars.VoidCurseReroll = true
			game:ShowHallucination(0, BackdropType.NUM_BACKDROPS)
			game:GetPlayer(0):UseActiveItem(CollectibleType.COLLECTIBLE_D12, datatables.NoAnimNoAnnounMimic)
		end
	end
	---CurseWarden
	if currentCurses & enums.Curses.Warden > 0 and roomType ~= RoomType.ROOM_BOSS then
		for slot = 0, DoorSlot.NUM_DOOR_SLOTS do
			local door = room:GetDoor(slot)
			if door and door:GetVariant() == DoorVariant.DOOR_LOCKED then
				local sprite = door.Sprite
		        sprite:Load("gfx/grid/door_16_doublelock.anm2", true)
		        sprite:Play(door:IsOpen() and "Opened" or "Closed")
		        door.Sprite = sprite
				--local pos = room:GetDoorSlotPosition(slot)
				--room:RemoveDoor(slot)
				--Isaac.GridSpawn(GridEntityType.GRID_DOOR, DoorVariant.DOOR_LOCKED_DOUBLE, pos, true)

				--[[
				if door:GetVariant() == DoorVariant.DOOR_LOCKED then
				door:SetVariant(DoorVariant.DOOR_LOCKED_DOUBLE)
				--]]
				--[[
						if isLocked
		            or containsIndex then
		                if SomethingWicked.ItemHelpers:GlobalPlayerHasTrinket(TrinketType.SOMETHINGWICKED_CURSED_KEY) or containsIndex then
		                        local roomType
		                        if SomethingWicked:UtilTableHasValue(SomethingWicked.save.runData.CurseList, door.TargetRoomIndex)
		                        or isLocked then
		                            roomType = door.TargetRoomType
		                            door:SetRoomTypes(door.CurrentRoomType, RoomType.ROOM_CURSE)
		                            door:SetLocked(false)
		                            table.insert(SomethingWicked.save.runData.CurseList, door.TargetRoomIndex)

		                        else
		                            roomType = door.CurrentRoomType
		                            door:SetRoomTypes(RoomType.ROOM_CURSE, door.TargetRoomType)
		                        end

		                        if roomType
		                        and this.DoorSprites[roomType] then
		                            local sprite = door:GetSprite()
		                            for ii = 1, 4 do
		                                sprite:ReplaceSpritesheet(ii, "gfx/grid/"..this.DoorSprites[roomType]..".png")
		                            end
		                            sprite:LoadGraphics()
		                        end

		                        break
		                    end
		                end
		            end
				--]]
			end
		end
	end
	---CurseSecrets
	if currentCurses & enums.Curses.Secrets > 0 then
		for slot = 0, DoorSlot.NUM_DOOR_SLOTS do
			local door = room:GetDoor(slot)
			if door and datatables.CurseSecretRooms[door.TargetRoomType] then
				door:SetVariant(DoorVariant.DOOR_HIDDEN)
				door:Close(true)
				door:PostInit()
			end
		end
	end
	---CurseEmperor
	if currentCurses & enums.Curses.Emperor > 0 and room:GetType() == RoomType.ROOM_BOSS and level:GetCurrentRoomIndex() > 0 and not room:IsMirrorWorld() and not level:IsAscent() and level:GetStage() ~= LevelStage.STAGE7 then
		for slot = 0, DoorSlot.NUM_DOOR_SLOTS do
			local door = room:GetDoor(slot)
			if door and door.TargetRoomType == RoomType.ROOM_DEFAULT then
				room:RemoveDoor(slot)
			end
		end
	end
	---MazeMemory
	if mod.ModVars.MazeMemory then
		for gridIndex = 1, room:GetGridSize() do
			local egrid = room:GetGridEntity(gridIndex)
			if egrid and (egrid:ToRock() or egrid:ToSpikes() or egrid:GetType() == 1) then --  or egrid:ToDoor()
				room:RemoveGridEntity(gridIndex, 0, false)
			elseif egrid and egrid:ToDoor() then
				room:RemoveDoor(egrid:ToDoor().Slot)
			end
		end
		local items = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)
		if #items > 0 then
			for _, item in pairs(items) do
				item:Remove()
			end
		end
	end
	---TemporaryWisps
	local wisps = Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.WISP)
	for _, wisp in pairs(wisps) do
		if wisp:GetData().TemporaryWisp or datatables.TemporaryWisps[wisp.SubType] then
			wisp:Remove()
			wisp:Kill()
		end
	end
	---XmasLetter
	if roomType == RoomType.ROOM_DEVIL or (roomType == RoomType.ROOM_BOSS and room:GetBossID() == 24) then --24 - satan; 55 - mega satan
		local trinkets = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, enums.Trinkets.XmasLetter)
		for _, trinket in pairs(trinkets) do
			trinket:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_MYSTERY_GIFT)
		end
		sfx:Play(SoundEffect.SOUND_SATAN_GROW, 1, 2, false, 1.7)
	end
	---players
	for playerNum = 0, game:GetNumPlayers()-1 do
		local player = game:GetPlayer(playerNum)
		local data = player:GetData()
		local playerType = player:GetPlayerType()
		local tempEffects = player:GetEffects()
		---RESET
		functions.ResetPlayerData(player)
		if data.eclipse.BlindCharacter then
			data.eclipse.ResetBlind = 1
		end
		---UnbiddenB
		if playerType == enums.Characters.UnbiddenB then
			if not tempEffects:HasNullEffect(NullItemID.ID_LOST_CURSE) then
				tempEffects:AddNullEffect(NullItemID.ID_LOST_CURSE, false, 1)
			end
			data.eclipsed.UnbiddenUsedHolyCard = 0
			if player:HasTrinket(TrinketType.TRINKET_WOODEN_CROSS) and not data.eclipsed.ForLevel.LostWoodenCross then
				data.eclipsed.UnbiddenUsedHolyCard = data.eclipsed.UnbiddenUsedHolyCard +1
			end
			if player:HasCollectible(CollectibleType.COLLECTIBLE_HOLY_MANTLE, true) then
				data.eclipsed.UnbiddenUsedHolyCard = data.eclipsed.UnbiddenUsedHolyCard +1
			end
			if player:HasCollectible(CollectibleType.COLLECTIBLE_DOGMA) then
				data.eclipsed.UnbiddenUsedHolyCard = data.eclipsed.UnbiddenUsedHolyCard +1
			end
			if player:HasCollectible(CollectibleType.COLLECTIBLE_BLANKET) and room:GetType() == RoomType.ROOM_BOSS and not room:IsClear() then
				data.eclipsed.UnbiddenUsedHolyCard = data.eclipsed.UnbiddenUsedHolyCard +1
			end
		---Abihu
		elseif playerType == enums.Characters.Abihu and not player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
			data.eclipsed.ForRoom.AbihuIgnites = false
			if data.eclipsed.AbihuCostumeEquipped then
				data.eclipsed.AbihuCostumeEquipped = false
				player:TryRemoveNullCostume(datatables.AbihuData.CostumeHead)
			end
		end
		---NadabBody
		if player:HasCollectible(enums.Items.NadabBody) then
			for _ = 1, functions.GetItemsCount(player, enums.Items.NadabBody, true) do
				local pos = Isaac.GetFreeNearPosition(player.Position, 40)
				if data.eclipsed.HoldBomd and data.eclipsed.HoldBomd >= 0 then
					data.eclipsed.HoldBomd = -1
					pos = player.Position
				end
				local bomb = Isaac.Spawn(EntityType.ENTITY_BOMB, BombVariant.BOMB_DECOY, 0, pos, Vector.Zero, nil):ToBomb()
				bomb:GetData().eclipsed = {}
				bomb:GetData().eclipsed.NadabBomb = true
				bomb:GetSprite():ReplaceSpritesheet(0, datatables.NadabBody.SpritePath)
				bomb:GetSprite():LoadGraphics()
				bomb.Parent = player
			end
		end
		---Lililith
		if data.eclipsed.ForLevel.LililithFams then
			for _, demonFam in pairs(data.eclipsed.ForLevel.LililithFams) do
				tempEffects:AddCollectibleEffect(demonFam)
			end
		end
		---SecretLoveLetter
		if data.eclipsed.SecretLoveLetter then data.eclipsed.SecretLoveLetter = false end
		---SurrogateConception
		if data.eclipsed.PersisteneEffect and #data.eclipsed.PersisteneEffect > 0 then
			for _, fam in pairs(data.eclipsed.PersisteneEffect) do
				tempEffects:AddCollectibleEffect(fam, false, 1)
			end
		end
		---CryptCard
		if data.eclipsed.ForRoom.CryptCard then
			player.Position = Vector(120, 165)
		end
		---Decay
		if data.eclipsed.ForRoom.Decay then
			functions.TrinketRemove(player, data.eclipsed.ForRoom.Decay)
		end
		---Corruption
		if data.eclipsed.ForRoom.Corruption then
			player:TryRemoveNullCostume(datatables.Corruption.CostumeHead)
			local activeItem = player:GetActiveItem(ActiveSlot.SLOT_PRIMARY)
			if activeItem ~= 0 then
				player:RemoveCollectible(activeItem)
			end
		end
		---RedPills
		if data.eclipsed.RedPillDamageUp and data.eclipsed.RedPillDamageUp > 0 then
			if not room:IsClear() then
				tempEffects:AddNullEffect(NullItemID.ID_WAVY_CAP_1, false, 1)
			end
			game:ShowHallucination(0, BackdropType.DICE)
			sfx:Stop(SoundEffect.SOUND_DEATH_CARD)
		end
		---RubberDuck
		if player:HasCollectible(enums.Items.RubberDuck) then
			if room:IsFirstVisit() then
				functions.EvaluateDuckLuck(player, data.eclipsed.DuckCurrentLuck + 1)
			elseif data.DuckCurrentLuck > 0 then
				functions.EvaluateDuckLuck(player, data.eclipsed.DuckCurrentLuck - 1)
			end
		end
		---BleedingGrimoire
		if data.eclipsed.BleedingGrimoire then
			if player:HasEntityFlags(EntityFlag.FLAG_BLEED_OUT) then
				player:AddCostume(Isaac.GetItemConfig():GetCollectible(enums.Items.BleedingGrimoire), true)
			else
				data.eclipsed.BleedingGrimoire = nil
				player:RemoveCostume(Isaac.GetItemConfig():GetCollectible(enums.Items.BleedingGrimoire))
			end
		end
		---DeuxExLuck
		if data.eclipsed.ForRoom.DeuxExLuck then
			data.eclipsed.ForRoom.DeuxExLuck = 0
			player:AddCacheFlags(CacheFlag.CACHE_LUCK)
			player:EvaluateItems()
		end
		---XmasLetter
		if room:IsFirstVisit() and player:HasTrinket(enums.Trinkets.XmasLetter) then
			local rng = player:GetTrinketRNG(enums.Trinkets.XmasLetter)
			if rng:RandomFloat() < 0.33 * player:GetTrinketMultiplier(enums.Trinkets.XmasLetter) then
				player:UseActiveItem(CollectibleType.COLLECTIBLE_FORTUNE_COOKIE, datatables.NoAnimNoAnnounMimic)
				sfx:Stop(SoundEffect.SOUND_FORTUNE_COOKIE)
			end
		end
		---Penance
		if not room:IsClear() and player:HasTrinket(enums.Trinkets.Penance) then
			local rng = player:GetTrinketRNG(enums.Trinkets.Penance)
			local enemies = Isaac.FindInRadius(room:GetCenterPos(), 5000, EntityPartition.ENEMY)
			for _, entity in pairs(enemies) do
				if entity:ToNPC() and entity:IsActiveEnemy() and entity:IsVulnerableEnemy() and not entity:GetData().PenanceRedCross and rng:RandomFloat() < 0.16 * player:GetTrinketMultiplier(enums.Trinkets.Penance) then
					entity:GetData().PenanceRedCross = player
					local redCross = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.REDEMPTION, 0, entity.Position, Vector.Zero, nil):ToEffect()
					redCross.Color = Color(1.25, 0.05, 0.15, 0.5)
					redCross:GetData().PenanceRedCrossEffect = true
					redCross.Parent = entity
				end
			end
		end
		---MongoCells
		if player:HasCollectible(enums.Items.MongoCells) and not room:IsClear() then
			for itemIdx, itemTemp in pairs(datatables.MongoCells.FamiliarEffects) do
				if player:HasCollectible(itemIdx) and not player:HasCollectible(itemTemp) then
					tempEffects:AddCollectibleEffect(itemTemp)
				end
			end
			if player:HasCollectible(CollectibleType.COLLECTIBLE_SISTER_MAGGY) then
				player:UseActiveItem(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL, datatables.NoAnimNoAnnounMimicNoCostume)
			end
			local rng = player:GetCollectibleRNG(enums.Items.MongoCells)
			if player:HasCollectible(CollectibleType.COLLECTIBLE_FRUITY_PLUM) and rng:RandomFloat() < 0.33 then
				player:UseActiveItem(CollectibleType.COLLECTIBLE_PLUM_FLUTE, datatables.NoAnimNoAnnounMimic)
			end
			if player:HasCollectible(CollectibleType.COLLECTIBLE_SPIN_TO_WIN) and rng:RandomFloat() < 0.33 then
				player:UseActiveItem(CollectibleType.COLLECTIBLE_MY_LITTLE_UNICORN, datatables.NoAnimNoAnnounMimic)
			end
			--[[
			if room:GetType() == RoomType.ROOM_BOSS and player:HasCollectible(CollectibleType.COLLECTIBLE_VANISHING_TWIN) then
				player:UseActiveItem(CollectibleType.COLLECTIBLE_MEAT_CLEAVER, datatables.NoAnimNoAnnounMimic)
			end
			--]]
		end
		---Limb
		if data.eclipsed.ForLevel.LimbActive and not tempEffects:HasNullEffect(NullItemID.ID_LOST_CURSE) then
			tempEffects:AddNullEffect(NullItemID.ID_LOST_CURSE)
		end
		---BrokenJawbone
		if room:IsFirstVisit() and player:HasTrinket(enums.Trinkets.BrokenJawbone) and (roomType == RoomType.ROOM_SECRET or roomType == RoomType.ROOM_SUPERSECRET) then
			for _ = 1, player:GetTrinketMultiplier(enums.Trinkets.BrokenJawbone) do
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DIRT_PATCH, 0, Isaac.GetFreeNearPosition(room:GetCenterPos(), 0), Vector.Zero, nil)
			end
		end
		---RedButton
		if player:HasCollectible(enums.Items.RedButton) and not room:IsClear() then
			functions.NewRoomRedButton(player, room) -- spawn new button
		end
		---BlackKnight
		--[[
		if player:HasCollectible(enums.Items.BlackKnight, true) then
			if data.eclipsed.ForRoom.KnightTarget then
				if data.eclipsed.ForRoom.KnightTarget:Exists() then data.eclipsed.ForRoom.KnightTarget:Remove() end
				data.eclipsed.ForRoom.KnightTarget = nil
			end
			player.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
			if player.CanFly then
				player.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
			else
				player.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
			end
		end
		--]]
		---IvoryOil
		if player:HasCollectible(enums.Items.IvoryOil) and room:IsFirstVisit() and not room:IsClear() then
			local chargingEffect = false
			local charge = 1
			if room:GetRoomShape() > 7 then charge = 2 end
			for slot = 0, 3 do
				local activeItem = player:GetActiveItem(slot)
				if activeItem ~= 0 and player:NeedsCharge(slot) then
					local activeCharge = player:GetActiveCharge(slot)
					local batteryCharge = player:GetBatteryCharge(slot)
					local activeMaxCharge = Isaac.GetItemConfig():GetCollectible(activeItem).MaxCharges
					local activeChargeType = Isaac.GetItemConfig():GetCollectible(activeItem).ChargeType
					if activeChargeType == ItemConfig.CHARGE_NORMAL then
						activeCharge = activeCharge + batteryCharge + charge
						if activeCharge > activeMaxCharge and not player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) then
							activeCharge = activeMaxCharge
						end
						player:SetActiveCharge(activeCharge, slot)
						chargingEffect = slot
						break
					elseif activeChargeType == ItemConfig.CHARGE_TIMED then
						charge = activeMaxCharge
						if activeCharge > activeMaxCharge then
							if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) then
								charge = 2*activeMaxCharge
							else
								charge = activeCharge
							end
						end
						player:SetActiveCharge(charge, slot)
						chargingEffect = slot
						break
					end
				end
			end
			if chargingEffect then
				data.IvoryOilBatteryEffect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BATTERY, 0, Vector(player.Position.X, player.Position.Y-70), Vector.Zero, nil)
				sfx:Play(SoundEffect.SOUND_BATTERYCHARGE)
			end
		end
		data.eclipsed.ForRoom = {}
		---StoneScripture
		if player:HasCollectible(enums.Items.StoneScripture) then
			if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) then
				data.eclipsed.ForRoom.StoneScripture = 6
			else
				data.eclipsed.ForRoom.StoneScripture = 3
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.onNewRoom)

---NEW LEVEL--
function mod:onNewLevel()
	local level = game:GetLevel()
	--local room = game:GetRoom()
	---RESET
	functions.ResetModVars()
	mod.ModVars.ForLevel = {}
	---ItemWispQueue
	local itemWisps = Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.ITEM_WISP)
	for _, fam in pairs(itemWisps) do
		if fam:GetData().AddNextFloor then
			local ppl = fam:GetData().AddNextFloor:ToPlayer()
			local data = ppl:GetData()
			data.eclipsed.WispedQueue = data.eclipsed.WispedQueue or {}
			table.insert(data.eclipsed.WispedQueue, {fam, true})
		end
	end
	---players
	for playerNum = 0, game:GetNumPlayers()-1 do
		local player = game:GetPlayer(playerNum)
		local data = player:GetData()
		local tempEffects = player:GetEffects()
		---RESET
		functions.ResetPlayerData(player)
		---UnbiddenRewind
		if data.eclipsed.BeastCounter and level:GetStage() ~= LevelStage.STAGE8 then
			data.eclipsed.BeastCounter = nil
		end
		---AgonyBox
		if player:HasCollectible(enums.Items.AgonyBox, true) then
			for slot = 0, 3 do -- 0, 3
				if player:GetActiveItem(slot) == enums.Items.AgonyBox then
					local activeMaxCharge = Isaac.GetItemConfig():GetCollectible(enums.Items.AgonyBox).MaxCharges
					local activeCharge = player:GetActiveCharge(slot)
					local batteryCharge = player:GetBatteryCharge(slot)
					local newCharge = 0
					if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) and batteryCharge < activeMaxCharge then
						newCharge = activeCharge + batteryCharge + 1
					elseif activeCharge < activeMaxCharge then
						newCharge = activeCharge + 1
					end
					if newCharge > 0 then
						player:SetActiveCharge(newCharge, slot)
						sfx:Play(SoundEffect.SOUND_ITEMRECHARGE)
					end
				end
			end
		end
		---Unbidden
		if player:GetPlayerType() == enums.Characters.Unbidden and level:GetStage() < 12 then
			local killWisp = true
			if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
				killWisp = false
			end
			functions.AddItemFromWisp(player, killWisp)
		end
		---RedLotus
		if player:HasCollectible(enums.Items.RedLotus) and player:GetBrokenHearts() > 0 then
			player:AddBrokenHearts(-1)
			data.eclipsed.RedLotusDamage = data.eclipsed.RedLotusDamage or 0
			data.eclipsed.RedLotusDamage = data.eclipsed.RedLotusDamage + (1 * functions.GetItemsCount(player, enums.Items.RedLotus))
			player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
			player:EvaluateItems()
		end
		---VoidKarma
		if player:HasCollectible(enums.Items.VoidKarma) then
			data.eclipsed.KarmaStats = data.eclipsed.KarmaStats or
					{
						["Damage"] = 0,
						["Firedelay"] = 0,
						["Shotspeed"] = 0,
						["Range"] = 0,
						["Speed"] = 0,
						["Luck"] = 0,
					}
			local multi = functions.GetItemsCount(player, enums.Items.VoidKarma)
			data.eclipsed.KarmaStats.Damage = data.eclipsed.KarmaStats.Damage + (datatables.VoidKarma.DamageUp * multi)
			data.eclipsed.KarmaStats.Firedelay = data.eclipsed.KarmaStats.Firedelay - (datatables.VoidKarma.TearsUp * multi)
			data.eclipsed.KarmaStats.Shotspeed = data.eclipsed.KarmaStats.Shotspeed + (datatables.VoidKarma.ShotSpeedUp * multi)
			data.eclipsed.KarmaStats.Range = data.eclipsed.KarmaStats.Range + (datatables.VoidKarma.RangeUp * multi)
			data.eclipsed.KarmaStats.Speed = data.eclipsed.KarmaStats.Speed + (datatables.VoidKarma.SpeedUp * multi)
			data.eclipsed.KarmaStats.Luck = data.eclipsed.KarmaStats.Luck + (datatables.VoidKarma.LuckUp * multi)
			player:AddCacheFlags(CacheFlag.CACHE_ALL)
			player:EvaluateItems()
			player:AnimateHappy()
			sfx:Play(SoundEffect.SOUND_1UP) -- play 1up sound
		end
		---Limb
		if data.eclipsed.ForLevel.LimbActive and tempEffects:HasNullEffect(NullItemID.ID_LOST_CURSE) then
			tempEffects:RemoveNullEffect(NullItemID.ID_LOST_CURSE)
		end
		---MemoryFragment
		if player:HasTrinket(enums.Trinkets.MemoryFragment) and data.eclipsed.MemoryFragment and #data.eclipsed.MemoryFragment > 0 then
			local maxim = player:GetTrinketMultiplier(enums.Trinkets.MemoryFragment) + 2 --(X + 2 = 3) - if X = 1
			if maxim > #data.eclipsed.MemoryFragment then maxim = #data.eclipsed.MemoryFragment end
			while maxim > 0 do
				maxim = maxim - 1
				local pickup = table.remove(data.eclipsed.MemoryFragment,1)
				Isaac.Spawn(EntityType.ENTITY_PICKUP, pickup[1], pickup[2], player.Position, RandomVector()*5, nil)
			end
		end
		data.eclipsed.MemoryFragment = {}
		data.eclipsed.ForLevel = {}
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.onNewLevel)

---INPUT ACTION--
function mod:onInputAction(entity, inputHook, buttonAction)
	if entity and entity:ToPlayer() and not entity:IsDead() then
		local player = entity:ToPlayer()
		local sprite = player:GetSprite()
		if player:HasCurseMistEffect() then return end
		if player:IsCoopGhost() then return end
		---Nadab and Abihu
		if buttonAction == ButtonAction.ACTION_BOMB and (player:GetPlayerType() == enums.Characters.Nadab or player:GetPlayerType() == enums.Characters.Abihu) then
			---Explode?
			return false
		end
		---BlackKnight
		if player:HasCollectible(enums.Items.BlackKnight, true) then
			if datatables.TeleportAnimations[sprite:GetAnimation()] then
				if buttonAction == ButtonAction.ACTION_BOMB or buttonAction == ButtonAction.ACTION_PILLCARD or buttonAction == ButtonAction.ACTION_ITEM then
					return false
				end
			end
			if inputHook == InputHook.GET_ACTION_VALUE then
				if not player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_MEGA_MUSH) and not player:HasCollectible(CollectibleType.COLLECTIBLE_DOGMA) then
					if buttonAction == ButtonAction.ACTION_LEFT or buttonAction == ButtonAction.ACTION_RIGHT or buttonAction == ButtonAction.ACTION_UP or buttonAction == ButtonAction.ACTION_DOWN then
						return 0
					end
				end
			end
		---WhiteKnight
		elseif player:HasCollectible(enums.Items.WhiteKnight, true) then
			if datatables.TeleportAnimations[sprite:GetAnimation()] then
				if buttonAction == ButtonAction.ACTION_BOMB or buttonAction == ButtonAction.ACTION_PILLCARD or buttonAction == ButtonAction.ACTION_ITEM then
					return false
				end
				if inputHook == InputHook.GET_ACTION_VALUE then
					if not player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_MEGA_MUSH) and not player:HasCollectible(CollectibleType.COLLECTIBLE_DOGMA) then
						if buttonAction == ButtonAction.ACTION_LEFT or buttonAction == ButtonAction.ACTION_RIGHT or buttonAction == ButtonAction.ACTION_UP or buttonAction == ButtonAction.ACTION_DOWN then
							return 0
						end
					end
				end
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_INPUT_ACTION, mod.onInputAction)

---NPC INIT--
function mod:onEnemyInit(enemy)
	if mod.ModVars then
		if mod.ModVars.ForLevel then
			---OblivionCard
			if mod.ModVars.ForLevel.ErasedEntities and #mod.ModVars.ForLevel.ErasedEntities >0 then
				for _, entity in ipairs(mod.ModVars.ForLevel.ErasedEntities) do
					if enemy.Type == entity[1] and enemy.Variant == entity[2] then
						Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, enemy.Position, Vector.Zero, nil):SetColor(Color(0.5,1,2),-1,1, false, false)
						enemy:Remove()
						break
					end
				end
			end
		end
		---BookMemory
		if mod.ModVars.BookMemoryErasedEntities and mod.ModVars.BookMemoryErasedEntities[enemy.Type] and mod.ModVars.BookMemoryErasedEntities[enemy.Type][enemy.Variant] then
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, enemy.Position, Vector.Zero, nil):SetColor(Color(0.5,1,2),-1,1, false, false)
			enemy:Remove()
			break
		end
		---DeliObjectCell and DeliriousBeggar
		if mod.ModVars.DeliriousBumCharm then
			mod.ModVars.DeliriousBumCharm = nil
			enemy:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
		end
		mod.ModVars.SavedEnable = mod.ModVars.SavedEnable or {}
		if not datatables.DeliriumBeggarBan[enemy.Type] and enemy:IsActiveEnemy() and enemy:IsVulnerableEnemy() and not enemy:IsBoss() and not mod.ModVars.SavedEnable[tostring(enemy.Type..enemy.Variant)] then
			mod.ModVars.SavedEnable[tostring(enemy.Type..enemy.Variant)] = true
			mod.ModVars.SavedEnemies = mod.ModVars.SavedEnemies or {}
			table.insert(mod.ModVars.SavedEnemies, {enemy.Type, enemy.Variant})
		end
	end
	---CursePride
	if game:GetLevel():GetCurses() & enums.Curses.Pride > 0 then
		local rng = enemy:GetDropRNG()
		if enemy:IsActiveEnemy() and enemy:IsVulnerableEnemy() and not enemy:IsBoss() and not enemy:IsChampion() and rng:RandomFloat() < 0.5 then
			local randNum = rng:RandomInt(26)
			if randNum == 6 then randNum = 25 end
			--enemy:MakeChampion(Random()+1, -1, true) -- have buggy behaviour related to enemies which can't become champion becoming champion
			enemy:Morph(enemy.Type, enemy.Variant, enemy.SubType, randNum)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, mod.onEnemyInit)
---NPC UPDATE--
function mod:onUpdateNPC(enemy)
	enemy = enemy:ToNPC()
	local enemyData = enemy:GetData()
	---SecretLoveLetter
	if enemy.FrameCount <= 1 and mod.ModVars and mod.ModVars.SecretLoveLetterAffectedEnemies and #mod.ModVars.SecretLoveLetterAffectedEnemies > 0 then
		if enemy.Type == mod.ModVars.SecretLoveLetterAffectedEnemies[1] and enemy.Variant == mod.ModVars.SecretLoveLetterAffectedEnemies[2] then
			sfx:Play(SoundEffect.SOUND_KISS_LIPS1)
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, enemy.Position, Vector.Zero, nil):SetColor(Color(2,0,0.7),-1,1, false, false)
			enemy:AddCharmed(EntityRef(mod.ModVars.SecretLoveLetterAffectedEnemies[3]), -1)
		end
	end
	---LimbLocustTouch
	if enemyData.LimbLocustTouch then
		enemyData.LimbLocustTouch = nil
		if enemy:HasMortalDamage() then
			functions.SoulExplosion(enemy.Position)
		end
	end
	---JacobLadder
	if enemyData.ArkLaserIgnore then
		enemyData.ArkLaserReset = enemyData.ArkLaserReset or 30
		enemyData.ArkLaserReset = enemyData.ArkLaserReset - 1
		if enemyData.ArkLaserReset <= 0 then
			enemyData.ArkLaserIgnore = nil
			enemyData.ArkLaserReset = nil
		end
	end
	---Euthanasia
	if enemyData.Euthanased then
		if enemy:HasMortalDamage() then
			functions.CircleSpawnX10(enemy.Position, enemyData.Euthanased, EntityType.ENTITY_TEAR, TearVariant.NEEDLE, 0)
		end
		enemyData.Euthanased = nil
	end
	---Bleeding
	if enemyData.Bleeding then
		enemyData.Bleeding = enemyData.Bleeding -1
		if enemyData.Bleeding == 0 then
			enemy:ClearEntityFlags(EntityFlag.FLAG_BLEED_OUT)
		elseif enemyData.Bleeding <= -30 then
			enemyData.Bleeding = nil
		end
	end
	---Frosted
	if enemyData.Frosted then
		enemyData.Frosted = enemyData.Frosted -1
		if enemyData.Frosted <= 0 then
			enemyData.Frosted = nil
			enemy:ClearEntityFlags(EntityFlag.FLAG_ICE)
		end
	end
	---Magnetized
	if enemyData.Magnetized then
		enemyData.Magnetized = enemyData.Magnetized -1
		if enemyData.Magnetized <= 0 then
			enemyData.Magnetized = nil
			enemy:ClearEntityFlags(EntityFlag.FLAG_MAGNETIZED)
		end
	end
	---BaitedTomato
	if enemyData.BaitedTomato then
		enemyData.BaitedTomato = enemyData.BaitedTomato -1
		if enemyData.BaitedTomato <= 0 then
			enemyData.BaitedTomato = nil
			enemy:ClearEntityFlags(EntityFlag.FLAG_BAITED)
		end
	end
	---MeltedCandle
	if enemyData.Waxed then
		if enemyData.Waxed == 92 then
			enemy:ClearEntityFlags(EntityFlag.FLAG_BURN)
		end
		enemyData.Waxed = enemyData.Waxed - 1
		if enemy:HasMortalDamage() then
			local flame = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RED_CANDLE_FLAME, 0, enemy.Position, Vector.Zero, nil):ToEffect()
			flame.CollisionDamage = 23
			flame:SetTimeout(360)
		end
		if enemyData.Waxed <= 0 then
			enemyData.Waxed = nil
		end
	end
	---DecoyTarget
	if enemyData.DecoyTarget then
		enemyData.DecoyTarget = enemyData.DecoyTarget -1
		if enemyData.DecoyTarget <= 0 then
			enemyData.DecoyTarget = nil
			enemy.Target = nil
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, mod.onUpdateNPC)
---NPC TAKE DMG--
function mod:onEnemyTakeDamage(enemy, _, flags, source)
	if not enemy:ToNPC() then return end
	if not enemy:IsVulnerableEnemy() then return end
	if not enemy:IsActiveEnemy() then return end
	local level = game:GetLevel()
	local rng = enemy:GetDropRNG()
	---CurseBishop
	if level:GetCurses() & enums.Curses.Bishop > 0 and rng:RandomFloat() < 0.16 then
		enemy:SetColor(Color(0.3,0.3,1,1), 10, 100, true, false)
		return false
	end
	if source.Entity and not source.Entity:ToPlayer() then return end
	local player = source.Entity:ToPlayer()
	if player:HasCurseMistEffect() then return end
	if player:IsCoopGhost() then return end
	---DAMAGE_LASER
	if flags & DamageFlag.DAMAGE_LASER == DamageFlag.DAMAGE_LASER then
		functions.ApplyTearEffect(player, enemy, rng)
	end
	---DAMAGE_EXPLOSION
	if flags & DamageFlag.DAMAGE_EXPLOSION == DamageFlag.DAMAGE_EXPLOSION or flags & DamageFlag.DAMAGE_TNT == DamageFlag.DAMAGE_TNT then
		for playerNum = 0, game:GetNumPlayers()-1 do
			local ppl = game:GetPlayer(playerNum)
			---Pyrophilia
			if ppl:HasCollectible(enums.Items.Pyrophilia) then
				ppl:AddHearts(1)
				sfx:Play(SoundEffect.SOUND_VAMP_GULP)
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HEART, 0, Vector(ppl.Position.X, ppl.Position.Y-70), Vector.Zero, nil)
			end
		end
	end
	---DAMAGE_FIRE
	if flags & DamageFlag.DAMAGE_FIRE == DamageFlag.DAMAGE_FIRE and source.Entity:GetData().AbihuFlame then
		local flame = source.Entity:ToEffect()
		local flameData = flame:GetData()
		local ppl = flame.Parent:ToPlayer()
		local tearFlags = ppl.TearFlags
		local duration = 152
		if flameData.Burn then enemy:AddBurn(EntityRef(ppl), duration, 2*ppl.Damage) end
		if flameData.Poison then enemy:AddPoison(EntityRef(ppl), duration, 2*ppl.Damage) end
		if flameData.Charm then enemy:AddCharmed(EntityRef(ppl), duration) end
		if flameData.Freeze then enemy:AddFreeze(EntityRef(ppl), duration) end
		if flameData.Slow then enemy:AddSlowing(EntityRef(ppl), duration, 0.5, flameData.Slow) end
		if flameData.Midas then enemy:AddMidasFreeze(EntityRef(ppl), duration) end
		if flameData.Confusion then enemy:AddConfusion(EntityRef(ppl), duration, false) end
		if flameData.Fear then enemy:AddFear(EntityRef(ppl), duration) end
		if flameData.Rift and flameData.Rift <= 0 then
			flameData.Rift = 30
			local rift = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RIFT, 0, enemy.Position, Vector.Zero, ppl):ToEffect()
			rift.CollisionDamage = ppl.Damage*0.5
			rift:SetTimeout(duration)
		end
		if flameData.Magnetize then
			enemy:AddEntityFlags(EntityFlag.FLAG_MAGNETIZED)
			enemy:GetData().Magnetized = duration
		end
		if flameData.BaitedTomato then
			enemy:AddEntityFlags(EntityFlag.FLAG_BAITED)
			enemy:GetData().BaitedTomato = duration
		end
		if flameData.Ipecac then
			game:BombExplosionEffects(enemy.Position, ppl.Damage, tearFlags, Color.Default, ppl, 1, true, false, DamageFlag.DAMAGE_EXPLOSION)
		elseif flameData.FireMind then
			local chance = 1/(10-(functions.LuckCalc(ppl.Luck, 12.86)*0.7))
			if chance > rng:RandomFloat() then
				game:BombExplosionEffects(enemy.Position, ppl.Damage, tearFlags, Color.Default, ppl, 1, true, false, DamageFlag.DAMAGE_EXPLOSION)
			end
		end
		if flameData.Explosive and flameData.Explosive > rng:RandomFloat() then
			game:BombExplosionEffects(enemy.Position, ppl.Damage, tearFlags, Color.Default, ppl, 1, true, false, DamageFlag.DAMAGE_EXPLOSION)
		end
		if flameData.Mulligan and 1/6 > rng:RandomFloat() then
			ppl:AddBlueFlies(1, enemy.Position, ppl)
		end
		if flameData.Split and flame.CollisionDamage > 1  then
			local vel1 = Vector(flame.Velocity.X, -flame.Velocity.Y)
			local vel2 = Vector(-flame.Velocity.X, flame.Velocity.Y)
			functions.ShootAbihuFlame(player, vel1, flame.CollisionDamage, math.floor(player.TearRange*0.1))
			functions.ShootAbihuFlame(player, vel2, flame.CollisionDamage, math.floor(player.TearRange*0.1))
		end
		if flameData.Belial then
			flameData.Belial = nil
			flameData.Homing = true
		end
		---MortalDamage
		if enemy:HasMortalDamage() then
			if flameData.Ice then enemy:AddEntityFlags(EntityFlag.FLAG_ICE) end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.onEnemyTakeDamage)
---NPC DEVOLVE--
function mod:onDevolve(enemy)
	---Domino25
	if enemy:GetData().NoDevolve then -- entity:HasMortalDamage()
		enemy:GetData().NoDevolve = nil
		return true
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_DEVOLVE, mod.onDevolve)
---NPC DEATH--
function mod:onNPCDeath(enemy)
	local enemyData = enemy:GetData()
	---Penance
	if enemyData.PenanceRedCross then
		local ppl = enemyData.PenanceRedCross
		local timeout = 10
		local pos = enemy.Position
		functions.PenanceShootLaser(0, timeout, pos, ppl)
		functions.PenanceShootLaser(90, timeout, pos, ppl)
		functions.PenanceShootLaser(180, timeout, pos, ppl)
		functions.PenanceShootLaser(270, timeout, pos, ppl)
		enemyData.PenanceRedCross = false
	end
	---players
	if enemy:IsActiveEnemy(true) then
		local rng = enemy:GetDropRNG()
		for playerNum = 0, game:GetNumPlayers()-1 do
			local player = game:GetPlayer(playerNum)
			if not player:HasCurseMistEffect() and not player:IsCoopGhost() then
				---TomeDead
				if player:HasCollectible(enums.Items.TomeDead) and not player:HasCollectible(CollectibleType.COLLECTIBLE_VADE_RETRO) then
					Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ENEMY_GHOST, 0, enemy.Position, Vector.Zero, player) -- subtype = 0 is rift, 1 is soul
				end
				---DMS--DeathSickle
				if player:HasCollectible(enums.Items.DMS) then
					if rng:RandomFloat() < 0.25 then
						local purgesoul = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PURGATORY, 1, enemy.Position, Vector.Zero, player):ToEffect()
						purgesoul:GetSprite():Play("Charge", true)
					end
				end
				---MilkTeeth
				if player:HasTrinket(enums.Trinkets.MilkTeeth) then
					if rng:RandomFloat() < 0.16 * player:GetTrinketMultiplier(enums.Trinkets.MilkTeeth) then
						local coin = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, enemy.Position, RandomVector()*5, nil)
						coin:ToPickup().Timeout = 75
					end
				end
			end
		end
	end
	---HuntersJournal
	if enemy.Type == EntityType.ENTITY_CHARGER then
		if enemyData.BlackHoleCharger then
			enemyData.BlackHoleCharger = nil
			local hole = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLACK_HOLE, 0, enemy.Position, Vector.Zero, nil)
			hole:GetSprite():Play("Death", true)
			hole:GetSprite():SetLastFrame()
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, mod.onNPCDeath)

---TEARS UPDATE--
function mod:onTearUpdate(tear)
	if not tear.SpawnerEntity then return end
	if not tear.SpawnerEntity:ToPlayer() then return end
	local player = tear.SpawnerEntity:ToPlayer()
	local data = player:GetData()
	local tearData = tear:GetData()
	local tearSprite = tear:GetSprite()
	---UnbiddenB
	if player:GetPlayerType() == enums.Characters.UnbiddenB then
		tear.Color = Color(0.5,1,2)
		tear.SplatColor = Color(1,1,1,1,-0.5,0.7,1)
		if tear:HasTearFlags(TearFlags.TEAR_FETUS) then
			if tear:GetData().BrimFetus then
				functions.WeaponAura(player, tear.Position, tear.FrameCount, 22, nil, true, true)
				--WeaponAura(player, auraPos, frameCount, maxCharge, range, blockLasers)
			elseif player:GetData().eclipsed and not player:GetData().eclipsed.UnbiddenBrimCircle then
				functions.WeaponAura(player, tear.Position, tear.FrameCount)
			end
		elseif tear.Variant == TearVariant.SWORD_BEAM or tear.Variant == TearVariant.TECH_SWORD_BEAM then
			functions.WeaponAura(player, tear.Position, tear.FrameCount)
		end
	end
	---UnbiddenB Ludovico
	if tearData.UnbiddenTear then
		tear.Color = Color(0.5,1,2)
		tear.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		tear.Height = -25
		tear.Velocity = player:GetShootingInput() * player.ShotSpeed * 5
		local prisms = Isaac.FindByType(3, 123)
		if #prisms > 0 then
			for _, prism in pairs(prisms) do
				if tear.Position:Distance(prism.Position) < 25 then
					--tear:Kill()
					data.eclipsed.LudoTearEnable = true
				end
			end
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY) or
		not player:HasCollectible(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE) or
		not data.eclipsed.BlindCharacter then -- or player:HasCurseMistEffect() or player:IsCoopGhost() then
			tear:Kill()
		end
	end
	---InfiniteBlades
	if tearData.KnifeTear then
		tear.Visible = true
		tear.CollisionDamage = player.Damage * 3
		if tear.FrameCount < 900 then
			tear.FallingAcceleration = 0
			tear.FallingSpeed = 0
		end
		if tearData.InitAngle then
			tearSprite.Rotation = tearData.InitAngle:GetAngleDegrees() - 45
			tearData.AngleSaved = tearSprite.Rotation
			tearData.InitAngle = nil
		else
			tearSprite.Rotation = tearData.AngleSaved
		end
		if  tearSprite.Rotation <= -180 then
			tearSprite.Rotation = -90
			tearSprite.FlipX = true
		elseif tearSprite.Rotation >= 135 then
			tearSprite.Rotation = -45
			tearSprite.FlipX = true
		elseif tearSprite.Rotation >= 90 then
			tearSprite.Rotation = 0
			tearSprite.FlipX = true
		end
		if not game:GetRoom():IsPositionInRoom(tear.Position, -100) then
			tear:Remove()
		end
	end
	---KittenSkip2
	if data.eclipsed.ForRoom.KittenSkip2 then
		tear:AddTearFlags(TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_PIERCING)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, mod.onTearUpdate)
---TEARS COLLISION--
function mod:onTearCollision(tear, collider)
	functions.CheckApplyTearEffect(tear, collider)
end
mod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, mod.onTearCollision)
---CHAOS CARD TEAR COLLISION--
function mod:onLoveLetterCollision(tear, collider)
	tear = tear:ToTear()
	local tearData = tear:GetData()
	if not collider:ToNPC() then return end
	local player = tear.SpawnerEntity:ToPlayer()
	local enemy = collider:ToNPC()
	---SecretLoveLetter
	if tearData.SecretLoveLetter and collider:IsActiveEnemy() and collider:IsVulnerableEnemy() and not collider:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
		tear:Remove()
		sfx:Play(SoundEffect.SOUND_KISS_LIPS1)
		if not enemy:IsBoss() and not datatables.SecretLoveLetter.BannedEnemies[enemy.Type] then
			functions.ResetModVars()
			mod.ModVars.SecretLoveLetterAffectedEnemies = mod.ModVars.SecretLoveLetterAffectedEnemies or {}
			mod.ModVars.SecretLoveLetterAffectedEnemies[1] = enemy.Type
			mod.ModVars.SecretLoveLetterAffectedEnemies[2] = enemy.Variant
			mod.ModVars.SecretLoveLetterAffectedEnemies[3] = player
			for _, entity in pairs(Isaac.FindInRadius(player.Position, 5000, EntityPartition.ENEMY)) do
				if entity.Type == enemy.Type and entity.Variant == enemy.Variant then
					Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, entity.Position, Vector.Zero, nil):SetColor(Color(2,0,0.7),-1,1, false, false)
					entity:AddCharmed(EntityRef(player), -1) -- makes the effect permanent and the enemy will follow you even to different rooms.
				end
			end
		else
			enemy:AddCharmed(EntityRef(player), 150)
		end
		return true
	---OblivionCard
	elseif tearData.OblivionCard then
		tear:Remove()
		mod.ModVars.ForLevel.ErasedEntities = mod.ModVars.ForLevel.ErasedEntities or {}
		table.insert(mod.ModVars.ForLevel.ErasedEntities, {enemy.Type, enemy.Variant})
		for _, entity in pairs(Isaac.FindInRadius(player.Position, 5000, EntityPartition.ENEMY)) do
			if entity.Type == enemy.Type and entity.Variant == enemy.Variant then
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, entity.Position, Vector.Zero, nil):SetColor(Color(0.5,1,2), -1,1, false, false)
				entity:Remove()
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, mod.onLoveLetterCollision, TearVariant.CHAOS_CARD)

---LASER UPDATE--
function mod:onLaserUpdate(laser)
	if not laser.SpawnerEntity then return end
	if not laser.SpawnerEntity:ToPlayer() then return end
	local player = laser.SpawnerEntity:ToPlayer()
	local data = player:GetData()
	local laserData = laser:GetData()
	if laserData.ArkLaserNext and laserData.ArkLaserNext.maxArk > 0 then
		local enemies = Isaac.FindInRadius(laserData.ArkLaserNext.pos, laserData.ArkLaserNext.range, EntityPartition.ENEMY)
		for _, enemy in pairs(enemies) do
			if enemy:ToNPC() and enemy:IsVulnerableEnemy() and enemy:IsActiveEnemy() then
				local enemyData = enemy:GetData()
				if not enemyData.ArkLaserIgnore or (enemyData.ArkLaserIgnore and enemyData.ArkLaserIgnore < 4) then
					local newLaser = Isaac.Spawn(EntityType.ENTITY_LASER, LaserVariant.ELECTRIC, 0, enemy.Position, Vector.Zero, player):ToLaser()
					newLaser.CollisionDamage = 0
					enemyData.ArkLaserIgnore = enemyData.ArkLaserIgnore or 0
					enemyData.ArkLaserIgnore = enemyData.ArkLaserIgnore +1
					local distance = enemy.Position:Distance(laserData.ArkLaserNext.pos)
					newLaser:SetTimeout(5)
					newLaser:SetMaxDistance(distance)
					local pos = enemy.Position - laserData.ArkLaserNext.pos
					newLaser.Angle = pos:GetAngleDegrees()
					newLaser.Mass = 0
					newLaser:GetData().ArkLaserNext = {pos = enemy.Position, range = laserData.ArkLaserNext.range, maxArk = laserData.ArkLaserNext.maxArk -1}
					enemy:TakeDamage(player.Damage/2, DamageFlag.DAMAGE_LASER, EntityRef(newLaser), 1)
					break
				end
			end
		end
	end
	if player:GetPlayerType() ~= enums.Characters.UnbiddenB then return end
	data.eclipsed = data.eclipsed or {}
	if laser.SubType ~= LaserSubType.LASER_SUBTYPE_RING_FOLLOW_PARENT then
		laser.Color = Color(1,1,1,1,-0.5,0.7,1)
	end
	if laserData.UnbiddenLaser then
		laser:SetTimeout(5)
		local range = player.TearRange*0.25
		range = functions.AuraRange(range)
		laser.Radius = range
		laser.Velocity = player:GetShootingInput() * player.ShotSpeed * 5
		if laserData.UnbiddenLaser ~= game:GetLevel():GetCurrentRoomIndex() then
			laserData.UnbiddenLaser = game:GetLevel():GetCurrentRoomIndex()
			data.eclipsed.ludo = false
		end
		data.eclipsed.TechLudo = data.eclipsed.TechLudo or true
		if not (player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY) and player:HasCollectible(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE) and data.eclipsed.BlindCharacter) then
			laser:Kill()
			data.eclipsed.TechLudo = false
			return
		end
	elseif laserData.UnbiddenTech2Laser then
		if laserData.EnavleVisible and laserData.EnavleVisible > 0 then
			laserData.EnavleVisible = laserData.EnavleVisible -1
		elseif not laser.Visible then
			laser.Visible = true
		end
		if laserData.UnbiddenTech2Laser ~= game:GetLevel():GetCurrentRoomIndex() then
			laserData.UnbiddenTech2Laser = game:GetLevel():GetCurrentRoomIndex()
			laser.Visible = false
			laserData.EnavleVisible = 5
		end
		laser.Position = player.Position
		if player:GetFireDirection() ~= Direction.NO_DIRECTION then
			laser:SetTimeout(3)
		end
	elseif laserData.UnbiddenBrimLaser and laser.Timeout < 4 and player:HasCollectible(CollectibleType.COLLECTIBLE_C_SECTION) and player:HasWeaponType(WeaponType.WEAPON_BRIMSTONE) then
		local fetusTear = player:FireTear(laser.Position, RandomVector()*player.ShotSpeed*14, false, false, false, player, 1):ToTear()
		fetusTear:ChangeVariant(TearVariant.FETUS)
		fetusTear:AddTearFlags(TearFlags.TEAR_FETUS)
		fetusTear:GetData().BrimFetus = true
		local tearSprite = fetusTear:GetSprite()
		tearSprite:ReplaceSpritesheet(0, "gfx/characters/costumes_unbidden/fetus_tears.png")
		tearSprite:LoadGraphics()
	end
end
mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, mod.onLaserUpdate)

---KNIFE UPDATE--
function mod:onKnifeUpdate(knife)
	if not knife.SpawnerEntity then return end
	if not knife.SpawnerEntity:ToPlayer() then return end
	local player = knife.SpawnerEntity:ToPlayer()
	if player:GetPlayerType() ~= enums.Characters.UnbiddenB then return end
	local data = player:GetData()
	if not data.eclipsed then return end
	local range = player.TearRange*0.5
	range = functions.AuraRange(range)
	functions.WeaponAura(player, knife.Position, knife.FrameCount, data.eclipsed.UnbiddenBDamageDelay, range)
	--local function WeaponAura(player, auraPos, frameCount, maxCharge, range, blockLasers)
end
mod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, mod.onKnifeUpdate)
---KNIFE COLLISION--
function mod:onKnifeCollision(knife, collider)
	functions.CheckApplyTearEffect(knife, collider)
end
mod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, mod.onKnifeCollision)
---PROJECTILES INIT--
function mod:onProjectileInit(projectile)
	if not projectile.SpawnerEntity then return end
	local currentCurses = game:GetLevel():GetCurses()
	---ChallengeMagician
	if Isaac.GetChallenge() == enums.Challenges.Magician then
		projectile:AddProjectileFlags(ProjectileFlags.SMART)
	---CurseMagician
	elseif currentCurses & enums.Curses.Magician > 0 and projectile:GetDropRNG():RandomFloat() <= 0.25 and not projectile.SpawnerEntity:IsBoss() then
		projectile:AddProjectileFlags(ProjectileFlags.SMART)
	end
	---CursePoverty
	if currentCurses & enums.Curses.Poverty > 0 then
		projectile:AddProjectileFlags(ProjectileFlags.GREED)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_INIT, mod.onProjectileInit)

---BOMB UPDATE--
function mod:onBombUpdate(bomb)
	if game:GetRoom():HasCurseMist() then return end
	---CurseBell
	if game:GetLevel():GetCurses() & enums.Curses.Bell > 0 and datatables.BellCurse[bomb.Variant] and bomb.FrameCount <= 1 then
		bomb:Remove()
		Isaac.Spawn(bomb.Type, BombVariant.BOMB_GOLDENTROLL, 0, bomb.Position, bomb.Velocity, bomb.SpawnerEntity)
		return
	end
	local bombSprite = bomb:GetSprite()
	---RedScissors
	if bombSprite:IsPlaying("Pulse") and datatables.RedScissors[bomb.Variant] and bombSprite:GetFrame() >= 58 then
		for playerNum = 0, game:GetNumPlayers()-1 do
			local player = game:GetPlayer(playerNum)
			if player:HasTrinket(enums.Trinkets.RedScissors) then
				if datatables.TrollBombs[bomb.Variant] then
					functions.RedBombReplace(bomb)
				elseif bomb.Variant == BombVariant.BOMB_GIGA and bombSprite:GetFrame() >= 86 then
					if not bomb.SpawnerEntity then
						functions.RedBombReplace(bomb)
					elseif not bomb.SpawnerEntity:ToPlayer() then
						functions.RedBombReplace(bomb)
					end
				end
			end
		end
	end
	---Return troll bomb
	if datatables.TrollBombs[bomb.Variant] then return end
	local bombData = bomb:GetData()
	bombData.eclipsed = bombData.eclipsed or {}
	---Return NadabBody
	if bombData.eclipsed.NadabBomb then return end
	---UnbiddenB Dr.Fetus
	if bomb.IsFetus and bomb.SpawnerEntity and bomb.SpawnerEntity:ToPlayer() and bomb.SpawnerEntity:ToPlayer():GetPlayerType() == enums.Characters.UnbiddenB then
		local ppl = bomb.SpawnerEntity:ToPlayer()
		functions.WeaponAura(ppl, bomb.Position, bomb.FrameCount, 20)
	end
	---BombData
	local roomIndex = game:GetLevel():GetCurrentRoomIndex()
	local rng = bomb:GetDropRNG()
	local bombSeed = rng:GetSeed()
	mod.ModVars.ForLevel.ModdedBombs = mod.ModVars.ForLevel.ModdedBombs or {}
	---BOMB INIT
	if bomb.FrameCount == 1 and bomb.SpawnerEntity and bomb.SpawnerEntity:ToPlayer() then
		local player = bomb.SpawnerEntity:ToPlayer()
		local data = player:GetData()
		local luck = player.Luck/100
		if luck < 0 then luck = 0 end
		if not (bomb.Variant == BombVariant.BOMB_THROWABLE and not player:HasTrinket(enums.Trinkets.BlackPepper)) then -- apply effect to throwables
			mod.ModVars.ForLevel.ModdedBombs[roomIndex] = mod.ModVars.ForLevel.ModdedBombs[roomIndex] or {}
			if not bombData.eclipsed.Mirror then
				for _, cacheData in pairs(mod.ModVars.ForLevel.ModdedBombs[roomIndex]) do -- get bomb.index table items
					if cacheData.Seed == bombSeed then
						bombData.eclipsed = cacheData.eclipsed
					end
				end
			end
			---MirrorBombs
			if bombData.eclipsed.Mirror and not bomb.Parent then
				bomb:Remove()
			end
			---NANCY_BOMBS
			if player:HasCollectible(CollectibleType.COLLECTIBLE_NANCY_BOMBS) then
				if bombData.eclipsed.DiceBombs == nil and bomb:GetDropRNG():RandomFloat() < 0.05 then functions.InitDiceyBomb(bomb) end
				if bombData.eclipsed.GravityBombs == nil and bomb:GetDropRNG():RandomFloat() < 0.1 then functions.InitGravityBomb(bomb) end
				if bombData.eclipsed.FrostyBombs == nil and bomb:GetDropRNG():RandomFloat() < 0.1 then functions.InitFrostyBomb(bomb) end
				if bombData.eclipsed.BatteryBombs == nil and bomb:GetDropRNG():RandomFloat() < 0.1 then functions.InitBatteryBomb(bomb) end
				if bombData.eclipsed.DeadBombs == nil and bomb:GetDropRNG():RandomFloat() < 0.1 then functions.InitDeadBomb(bomb) end
			end
			---DR. FETUS
			if bomb.IsFetus then
				if bombData.eclipsed.DiceBombs ~= false and bomb:GetDropRNG():RandomFloat() < 0.25 then functions.InitDiceyBomb(bomb) end
				if bombData.eclipsed.GravityBombs ~= false and bomb:GetDropRNG():RandomFloat() < 0.25 then functions.InitGravityBomb(bomb) end
				if bombData.eclipsed.FrostyBombs ~= false and bomb:GetDropRNG():RandomFloat() < 0.25 then functions.InitFrostyBomb(bomb) end
				if bombData.eclipsed.BatteryBombs ~= false and bomb:GetDropRNG():RandomFloat() < 0.25 then functions.InitBatteryBomb(bomb) end
				if bombData.eclipsed.DeadBombs ~= false and bomb:GetDropRNG():RandomFloat() < 0.25 then functions.InitDeadBomb(bomb) end
			end
			---SoulNadabAbihu
			if data.eclipsed.ForRoom.SoulNadabAbihu then
				bomb:AddTearFlags(TearFlags.TEAR_BURN)
			end
			---BobTongue
			if player:HasTrinket(enums.Trinkets.BobTongue) then
				bombData.eclipsed.BobTongue = true
				local fartRingEffect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.FART_RING, 0, bomb.Position, Vector.Zero, bomb):ToEffect()
				fartRingEffect:GetData().BobTongue = true
				fartRingEffect.Parent = bomb
				local numTrinket = player:GetTrinketMultiplier(enums.Trinkets.BobTongue)-1
				fartRingEffect.SpriteScale = fartRingEffect.SpriteScale * (0.8 + numTrinket*0.2)
			end
			---DeadEgg
			if player:HasTrinket(enums.Trinkets.DeadEgg) then
				bombData.eclipsed.DeadEgg = player:GetTrinketMultiplier(enums.Trinkets.DeadEgg)
			end
			---CompoBombs
			if player:HasCollectible(enums.Items.CompoBombs) and not datatables.BannedBombs[bomb.Variant] and bombData.eclipsed.CompoBombs ~= false then
				bombData.eclipsed.CompoBombs = true
			end
			---MirrorBombs
			if player:HasCollectible(enums.Items.MirrorBombs) and not bombData.Mirror ~= false then
				local flipPos = functions.FlipMirrorPos(bomb.Position)
				local mirrorBomb = Isaac.Spawn(bomb.Type, bomb.Variant, bomb.SubType, flipPos, bomb.Velocity, player):ToBomb()
				local mirrorBombData = mirrorBomb:GetData()
				mirrorBombData.eclipsed = {}
				local mirrorBombSprite = mirrorBomb:GetSprite()
				mirrorBombSprite:Play("Pulse", true)
				mirrorBomb:AddTearFlags(bomb.Flags)
				mirrorBomb.Parent = bomb
				if mirrorBomb.Variant == BombVariant.BOMB_ROCKET_GIGA or mirrorBomb.Variant == BombVariant.BOMB_ROCKET then
					mirrorBombData.eclipsed.RocketMirror = player:GetShootingInput()  -- -rotVec
					mirrorBombSprite.Rotation = mirrorBombData.eclipsed.RocketMirror:GetAngleDegrees()
				end
				if bomb.IsFetus then mirrorBomb.IsFetus = true end
				functions.SetBombEXCountdown(player, mirrorBomb)

				mirrorBomb:SetColor(Color(1, 1, 1, 0.5), -1, 1, false, false)
				mirrorBomb.FlipX = true
				mirrorBomb.EntityCollisionClass = 0
				mirrorBombData.eclipsed.Mirror = true
			end
			---DiceBombs
			if player:HasCollectible(enums.Items.DiceBombs) and bombData.eclipsed.DiceBombs ~= false then -- if nil or true
				functions.InitDiceyBomb(bomb)
			end
			---GravityBombs
			if player:HasCollectible(enums.Items.GravityBombs) and bombData.eclipsed.GravityBombs ~= false then -- if nil or true
				functions.InitGravityBomb(bomb)
			end
			---FrostyBombs
			if player:HasCollectible(enums.Items.FrostyBombs) and bombData.eclipsed.FrostyBombs ~= false then -- if nil or true
				functions.InitFrostyBomb(bomb)
			end
			---ChargedBombs
			if player:HasCollectible(enums.Items.BatteryBombs) and bombData.eclipsed.BatteryBombs ~= false then -- if nil or true
				functions.InitBatteryBomb(bomb)
			end
			---DeadBombs
			if player:HasCollectible(enums.Items.BatteryBombs) and bombData.eclipsed.DeadBombs ~= false then -- if nil or true
				functions.InitDeadBomb(bomb)
			end
		end
	end
	---MirrorBombs
	if bombData.eclipsed.Mirror then
		bomb:SetColor(Color(1, 1, 1, 0.5), -1, 1, false, false)
		bomb.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		bomb.FlipX = true
		if bombData.eclipsed.RocketMirror then
			bombSprite.Rotation = bombData.eclipsed.RocketMirror:GetAngleDegrees()
		end
		if bomb.Parent then
			local flipPos = functions.FlipMirrorPos(bomb.Parent.Position)
			bomb.Position = flipPos
		else
			bomb:SetExplosionCountdown(0)
		end
	end
	---FrostyBombs
	if bombData.eclipsed.FrostyBombs and bomb.FrameCount%8 == 0 then -- spawn every 8th frame
		local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, bombData.eclipsed.CreepVariant, 0, bomb.Position, Vector.Zero, bomb):ToEffect()
		creep.SpriteScale = creep.SpriteScale * 0.1
		if bombData.eclipsed.FrostyCreepColor then
			creep:SetColor(bombData.eclipsed.FrostyCreepColor, 200, 1, false, false)
		end
	end
	---Explode
	if bombSprite:IsPlaying('Explode') then
		local radius = functions.GetBombRadiusFromDamage(bomb.ExplosionDamage)
		---DiceBombs
		if bombData.eclipsed.DiceBombs then
			functions.DiceyReroll(rng, bomb.Position, radius)
		end
		---DeadBombs
		if bombData.eclipsed.DeadBombs then
			functions.BonnyBlast(rng, bomb.Position, radius, bomb.SpawnerEntity)
		end
		---BatteryBombs
		if bombData.eclipsed.BatteryBombs then
			functions.ChargedBlast(bomb.Position, radius, bomb.ExplosionDamage, bomb.SpawnerEntity)
		end
		---CompoBombs
		if bombData.eclipsed.CompoBombs then
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_THROWABLEBOMB, 0, bomb.Position, RandomVector()*3, nil)
		end
		---DeadEgg
		if bombData.eclipsed.DeadEgg then
			functions.DeadEggEffect(bombData.eclipsed.DeadEgg, bomb.Position, 180)
		end
		---FrostyBombs
		if bombData.eclipsed.FrostyBombs and bomb:HasTearFlags(TearFlags.TEAR_SAD_BOMB) then
			mod.ModVars.SadIceBombTear = mod.ModVars.SadIceBombTear or {}
			table.insert(mod.ModVars.SadIceBombTear, bomb.Position)
		end

	end
	---BombTracing
	if bomb.FrameCount > 0 and not datatables.NoBombTrace[bomb.Variant] and bomb.SpawnerEntity and bomb.SpawnerEntity:ToPlayer() then
		mod.ModVars.ForLevel.ModdedBombs[roomIndex] = mod.ModVars.ForLevel.ModdedBombs[roomIndex] or {}
		if bombSprite:IsPlaying('Explode') then
			mod.ModVars.ForLevel.ModdedBombs[roomIndex][bomb.Index] = nil
		else
			mod.ModVars.ForLevel.ModdedBombs[roomIndex][bomb.Index] = {
				Seed = bombSeed,
				eclipsed = bombData.eclipsed
			}
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, mod.onBombUpdate)

---NadabBomb UPDATE--
function mod:NadabBombUpdate(bomb)
	if not bomb.Parent then return end
	local player = bomb.Parent:ToPlayer()
	local bombData = bomb:GetData()
	bombData.eclipsed = bombData.eclipsed or {}
	if not bombData.eclipsed.NadabBomb then return end
	bomb:SetExplosionCountdown(1)
	---RingCap
	if bombData.eclipsed.RingCapDelay then
		bombData.eclipsed.RingCapDelay = bombData.eclipsed.RingCapDelay +1
		if bombData.eclipsed.RingCapDelay > player:GetTrinketMultiplier(TrinketType.TRINKET_RING_CAP) * 10 then
			bombData.eclipsed.RingCapDelay = nil
		elseif bombData.eclipsed.RingCapDelay % 10 == 0 then
			if player:HasCollectible(enums.Items.MirrorBombs) then
				functions.BodyExplosion(player, false, functions.FlipMirrorPos(bomb.Position))
			end
			functions.BodyExplosion(player, false, bomb.Position)
		end
	end
	---PressurePlate
	local grid = game:GetRoom():GetGridEntityFromPos(bomb.Position)
	if grid then
		if grid:ToPressurePlate() and grid:GetVariant() < 2 and grid.State == 0 then
			grid.State = 3
			grid:ToPressurePlate():Reward()
			grid:GetSprite():Play("On")
			grid:Update()
		end
	end
	---HeldByPlayer
	if bomb:HasEntityFlags(EntityFlag.FLAG_HELD) then
		bombData.eclipsed.Thrown = 60
	else
	---BlockTears
		local enemyTears = Isaac.FindInRadius(bomb.Position, 20, EntityPartition.BULLET)
		for _, enemyTear in pairs(enemyTears) do
			enemyTear:Kill()
		end
	end
	---ThrownByPlayer
	if bombData.eclipsed.Thrown then
		bombData.eclipsed.Thrown = bombData.eclipsed.Thrown - 1
		if bombData.eclipsed.Thrown <= 0 then
			bombData.eclipsed.Thrown = nil
		end
		bomb.CollisionDamage = player.Damage
		if player:GetEffects():HasNullEffect(NullItemID.ID_LOST_CURSE) and not bombData.eclipsed.PlayerIsSoul then
			bombData.eclipsed.PlayerIsSoul = true
		elseif bombData.PlayerIsSoul then
			bombData.eclipsed.PlayerIsSoul = false
		end
		local data = player:GetData()
		data.eclipsed = data.eclipsed or {}
		if data.eclipsed.RocketThrowMulti then
			bomb:AddVelocity(data.eclipsed.ThrowVelocity*data.eclipsed.RocketThrowMulti)
			data.eclipsed.RocketThrowMulti = nil
		end
		if bomb:CollidesWithGrid() and data.eclipsed.ThrowVelocity then
			local pos = bomb.Position + 40*(data.eclipsed.ThrowVelocity:Normalized())
			functions.NadabBodyDamageGrid(bomb.Position)
			functions.NadabBodyDamageGrid(pos)
		end
	end
	---FollowEnemies
	if player:HasCollectible(CollectibleType.COLLECTIBLE_BOBBY_BOMB) then
		local nearestNPC = functions.GetNearestEnemy(bomb.Position, 120)
		if nearestNPC:Distance(bomb.Position) > 10 then
			bomb:AddVelocity((nearestNPC - bomb.Position):Resized(1))
		end
	elseif player:HasCollectible(CollectibleType.COLLECTIBLE_STICKY_BOMBS) then
		local nearestNPC = functions.GetNearestEnemy(bomb.Position, 30)
		if nearestNPC:Distance(bomb.Position) > 10 then
			bomb.Velocity = (nearestNPC - bomb.Position):Resized(5)
		end
	end
	---FrostyBombs
	if player:HasCollectible(enums.Items.FrostyBombs) and game:GetFrameCount() %8 == 0 then -- spawn every 8th frame
		local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL, 0, bomb.Position, Vector.Zero, bomb):ToEffect() -- PLAYER_CREEP_RED
		creep.SpriteScale = creep.SpriteScale * 0.1
	end
	---BobBladder
	if player:HasTrinket(TrinketType.TRINKET_BOBS_BLADDER) and game:GetFrameCount() %8 == 0 then -- spawn every 8th frame
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_GREEN, 0, bomb.Position, Vector.Zero, bomb)
	end
	---RocketDash
	if bombData.eclipsed.RocketBody then
		bombData.eclipsed.RocketBody = bombData.eclipsed.RocketBody - 1
		if bomb:CollidesWithGrid(player) or bombData.eclipsed.RocketBody < 0 then
			functions.FcukingBomberbody(player, bomb)
			bombData.eclipsed.RocketBody = false
		end
	end

end
mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, mod.NadabBombUpdate, BombVariant.BOMB_DECOY)
---NadabBomb COLLISION--
function mod:NadabBombCollision(bomb, collider)
	if not bomb.Parent then return end
	if not collider:ToNPC() then return end
	if not collider:IsActiveEnemy() then return end
	if not collider:IsVulnerableEnemy() then return end
	collider = collider:ToNPC()
	if collider:HasEntityFlags(EntityFlag.FLAG_CHARM) then return end
	local bombData = bomb:GetData()
	bombData.eclipsed = bombData.eclipsed or {}
	if not bombData.eclipsed.NadabBomb then return end
	if (collider:IsActiveEnemy() and collider:IsVulnerableEnemy()) or collider.Type == EntityType.ENTITY_FIREPLACE then
		bomb.Velocity = -bomb.Velocity * 0.5
		functions.FcukingBomberbody(bomb.Parent:ToPlayer(), bomb)
		if bombData.eclipsed.Thrown then bombData.eclipsed.Thrown = nil end
		if bombData.eclipsed.RocketBody then bombData.eclipsed.RocketBody = nil end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, mod.NadabBombCollision, FamiliarVariant.BOMB_DECOY)

---BONE SPUR UPDATE--
function mod:onVertebraeUpdate(fam)
	local famData = fam:GetData()
	if famData.RemoveTimer then
		famData.RemoveTimer = famData.RemoveTimer - 1
		if famData.RemoveTimer <= 0 then
			fam:Kill()
		end
	end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, mod.onVertebraeUpdate,  FamiliarVariant.BONE_SPUR)
---WISP UPDATE--
function mod:onModWispsUpdate(wisp)
	if not wisp:HasMortalDamage() then return end
	local wispData = wisp:GetData()
	local rng = wisp:GetDropRNG()
	if wispData.RemoveAll then
		local sameWisps = Isaac.FindByType(wisp.Type, wisp.Variant, wisp.SubType)
		for _, wisp2 in pairs(sameWisps) do
			if wisp2:GetData().RemoveAll == wispData.RemoveAll then
				wisp2:Kill()
			end
		end
		return
	end
	if wisp.SubType == enums.Items.CodexAnimarum and rng:RandomFloat() > 0.5 then
		functions.SoulExplosion(wisp.Position)
	elseif wisp.SubType == enums.Items.StoneScripture or wisp.SubType == enums.Items.TomeDead then
		functions.SoulExplosion(wisp.Position)
	elseif wisp.SubType == enums.Items.LockedGrimoire and rng:RandomFloat() < 0.25 then
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, KeySubType.KEY_NORMAL, wisp.Position, Vector.Zero, nil)
	elseif wisp.SubType == enums.Items.HuntersJournal then
		local charger = Isaac.Spawn(EntityType.ENTITY_CHARGER, 0, 1, wisp.Position, Vector.Zero, wisp)
		charger:SetColor(Color(0,0,2), -1, 1, false, true)
		charger:AddCharmed(EntityRef(wisp), -1)
		charger:GetData().BlackHoleCharger = true
	elseif wisp.SubType == enums.Items.ElderMyth and rng:RandomFloat() < 0.25 then
		local card = datatables.ElderMythCardPool[rng:RandomInt(#datatables.ElderMythCardPool)+1]
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, card, wisp.Position, Vector.Zero, nil)
	elseif wisp.SpawnerEntity and wisp.SpawnerEntity:ToPlayer() then
		local ppl = wisp.SpawnerEntity:ToPlayer()
		if wisp.SubType == enums.Items.AncientVolume then
			ppl:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_CAMO_UNDIES)
		elseif wisp.SubType == enums.Items.WizardBook then
			local locust = rng:RandomInt(5)+1
			Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, locust, ppl.Position, Vector.Zero, ppl)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, mod.onModWispsUpdate, FamiliarVariant.WISP)
---ABYSS LOCUST COLLISION--
function mod:onAbyssLocustCollision(fam, collider)
	if fam.SpawnerEntity and fam.SpawnerEntity:ToPlayer() and collider:ToNPC() and collider:IsActiveEnemy() and collider:IsVulnerableEnemy() then
		local rng = fam:GetDropRNG()
		local entity = collider:ToNPC()
		local player = fam.SpawnerEntity:ToPlayer()
		if fam.SubType == enums.Items.BlackBook and rng:RandomFloat() <= 0.2 then
			functions.BlackBookEffects(player, entity, rng)
		elseif fam.SubType == enums.Items.MeltedCandle and rng:RandomFloat() <= 0.2 and not entity:GetData().Waxed then
			entity:AddFreeze(EntityRef(player), 92)
			if entity:HasEntityFlags(EntityFlag.FLAG_FREEZE) then
				entity:AddEntityFlags(EntityFlag.FLAG_BURN)
				entity:GetData().Waxed = 92
				entity:SetColor(datatables.MeltedCandle.TearColor, 92, 100, false, false)
			end
		elseif fam.SubType == enums.Items.Limb then
			entity:GetData().LimbLocustTouch = true
		elseif fam.SubType == enums.Items.Lililith and rng:RandomFloat() <= 0.2 then
			player:AddBlueFlies(1, player.Position, entity)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, mod.onAbyssLocustCollision, FamiliarVariant.ABYSS_LOCUST)
---NadabBrain INIT--
function mod:onNadabBrainInit(familiar)
	familiar:GetSprite():Play("FloatDown")
	familiar:AddToFollowers()
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, mod.onNadabBrainInit, enums.Familiars.NadabBrain)
---NadabBrain COLLISION--
function mod:onNadabBrainCollision(familiar, collider)
	local famData = familiar:GetData()
	if famData.IsFloating then
		if collider:ToNPC() and collider:IsActiveEnemy() and collider:IsVulnerableEnemy() and not collider:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
			local player = familiar.Player:ToPlayer()
			collider:TakeDamage(familiar.CollisionDamage, DamageFlag.DAMAGE_COUNTDOWN, EntityRef(familiar), 1)
			functions.BrainExplosion(player, familiar)
			familiar.CollisionDamage = 0
			familiar.Visible = false
			famData.ResetFam = 300
			familiar:RemoveFromFollowers()
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, mod.onNadabBrainCollision, enums.Familiars.NadabBrain)
---NadabBrain UPDATE--
function mod:onNadabBrainUpdate(familiar)
	local player = familiar.Player
	local famData = familiar:GetData()
	if familiar.Velocity.x ~= 0 then
		familiar.FlipX = familiar.Velocity.X < 0
	end
	if not familiar.Visible then
		famData.ResetFam = famData.ResetFam -1
		if famData.ResetFam <= 0 then
			familiar.Visible = true
			famData.ResetFam = nil
			familiar:AddToFollowers()
		end
		return
	end
	if famData.IsFloating then
		familiar.GridCollisionClass = GridCollisionClass.COLLISION_OBJECT and GridCollisionClass.COLLISION_WALL
		familiar.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
		if famData.Collided then
			famData.Collided = famData.Collided -1
			if famData.Collided <= 0 then
				famData.Collided = nil
				famData.IsFloating = false
			end
		elseif familiar:CollidesWithGrid() then
			local room = game:GetRoom()
			room:DamageGrid(room:GetGridIndex(familiar.Position), 1)
			familiar.Velocity = Vector.Zero
			familiar.CollisionDamage = 0
			famData.Collided = 30
		end
	else
		familiar:FollowParent()
		familiar.CollisionDamage = 0
		local pparent = familiar:GetLastParent()
		if player:GetFireDirection() ~= Direction.NO_DIRECTION and pparent and pparent.Variant ~= enums.Familiars.NadabBrain then
			familiar:RemoveFromFollowers()
			local newVector = player:GetShootingInput()
			newVector = newVector + player:GetTearMovementInheritance(newVector)
			familiar.Velocity = newVector:Normalize() * 3.75
			famData.IsFloating = true
			if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) and familiar.CollisionDamage < 7 then
				familiar.CollisionDamage = 7
			else
				familiar.CollisionDamage = 3.5
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, mod.onNadabBrainUpdate, enums.Familiars.NadabBrain)
---Lililith INIT--
function mod:onLililithInit(familiar)
	familiar:GetSprite():Play("FloatDown")
	familiar:AddToFollowers()
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, mod.onLililithInit, enums.Familiars.Lililith)
---Lililith UPDATE--
function mod:onLililithUpdate(familiar)
	local player = familiar.Player
	local data = player:GetData()
	local tempEffects = player:GetEffects()
	local famSprite = familiar:GetSprite()
	local rng = familiar:GetDropRNG()
	familiar:FollowParent()
	if famSprite:IsFinished("Spawn") then
		local demon = datatables.LililithDemonSpawn[rng:RandomInt(#datatables.LililithDemonSpawn)+1]
		tempEffects:AddCollectibleEffect(demon)
		table.insert(data.eclipsed.ForLevel.LililithFams, demon)
		famSprite:Play("FloatDown")
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) and familiar.RoomClearCount == 6 then
		familiar.RoomClearCount = 0
		famSprite:Play("Spawn")
	elseif familiar.RoomClearCount == 7 and rng:RandomFloat() > 0.5 then
		familiar.RoomClearCount = 0
		famSprite:Play("Spawn")
	elseif familiar.RoomClearCount >= 8 then
		familiar.RoomClearCount = 0
		famSprite:Play("Spawn")
	end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, mod.onLililithUpdate, enums.Familiars.Lililith)
---RedBag INIT--
function mod:onRedBagInit(familiar)
	familiar:GetSprite():Play("FloatDown")
	familiar:AddToFollowers()
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, mod.onRedBagInit, enums.Familiars.RedBag)
---RedBag UPDATE--
function mod:onRedBagUpdate(familiar)
	local famSprite = familiar:GetSprite()
	local rng = familiar:GetDropRNG()
	local player = familiar.Player
	familiar:FollowParent()
	if famSprite:IsFinished("Spawn") then
		famSprite:Play("FloatDown")
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, familiar.Position, Vector.Zero, nil):SetColor(datatables.RedColor, -1, 1, false, false)
		if familiar.Keys == 0 then
			Isaac.GridSpawn(GridEntityType.GRID_POOP, 1, familiar.Position, false)
			familiar.Coins = 1
		else
			local pickup = datatables.RedBag.RedPickups[familiar.Keys]
			Isaac.Spawn(EntityType.ENTITY_PICKUP, pickup[1], pickup[2], familiar.Position, Vector.Zero, nil)
			familiar.Coins = pickup[3]
			if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) and familiar.Coins >1 then
				familiar.Coins = familiar.Coins - 1
			end
		end
	end
	if familiar.RoomClearCount >= familiar.Coins then
		familiar.RoomClearCount = 0
		famSprite:Play("Spawn")
		familiar.Keys = rng:RandomInt(#datatables.RedBag.RedPickups)+1
		if not player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) and rng:RandomFloat() < 0.05 then
			familiar.Keys = 0
		end
	end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, mod.onRedBagUpdate, enums.Familiars.RedBag)
---AbihuFam INIT--
function mod:onAbihuFamInit(familiar)
	local famData = familiar:GetData()
	famData.CollisionTime = 0
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, mod.onAbihuFamInit, enums.Familiars.AbihuFam)
---AbihuFam TAKE DMG--
function mod:onAbihuFamTakeDamage(familiar, _, _, source)
	if familiar.Variant ~= enums.Familiars.AbihuFam then return end
	local entity = source.Entity
	if not entity then return end
	if not entity:ToNPC() and not entity:IsVulnerableEnemy() and not entity:IsActiveEnemy() then return end
	familiar = familiar:ToFamiliar()
	local famData = familiar:GetData()
	famData.CollisionTime = famData.CollisionTime or 0
	if famData.CollisionTime == 0 then
		local player = familiar.Player
		entity:AddBurn(EntityRef(player), 62, 2*player.Damage)
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
			functions.CircleSpawn(entity, 50, 0, EntityType.ENTITY_EFFECT, EffectVariant.FIRE_JET, 0)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.onAbihuFamTakeDamage, EntityType.ENTITY_FAMILIAR)
---AbihuFam UPDATE--
function mod:onAbihuFamUpdate(familiar)
	local famData = familiar:GetData()
	if familiar.Velocity.x ~= 0 then
		familiar.FlipX = familiar.Velocity.X < 0
	end
	if famData.CollisionTime then
		if famData.CollisionTime > 0 then
			famData.CollisionTime = famData.CollisionTime - 1
		end
	end
	local enemies = Isaac.FindInRadius(familiar.Position, 150, EntityPartition.ENEMY)
	for _, enemy in pairs(enemies) do
		if enemy:ToNPC() then
			local enemyData = enemy:GetData()
			if not enemyData.DecoyTarget and enemy.Target and enemy.Target:ToPlayer() then
				enemy.Target = familiar
				enemyData.DecoyTarget = 180
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, mod.onAbihuFamUpdate, enums.Familiars.AbihuFam)
---ItemWispDeath
function mod:ItemWispDeath(entity)
	if entity.Variant ~= FamiliarVariant.ITEM_WISP then return end
	if not entity.SpawnerEntity then return end
	if not entity.SpawnerEntity:ToPlayer() then return end
	local player = entity.SpawnerEntity:ToPlayer()
	if player:GetPlayerType() ~= enums.Characters.UnbiddenB then return end
	local data = player:GetData()
	data.eclipsed = data.eclipsed or {}
	data.eclipsed.ResetGame = data.eclipsed.ResetGame or 100
	if data.eclipsed.ResetGame < 100 then
		data.eclipsed.ResetGame = data.eclipsed.ResetGame + 5
		if data.eclipsed.ResetGame > 100 then
			data.eclipsed.ResetGame = 100
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, mod.ItemWispDeath, EntityType.ENTITY_FAMILIAR)

---BEGGAR SPAWN--
function mod:onEntSpawn(entType, entVar)
	if entType ~= EntityType.ENTITY_SLOT then return end
	if Isaac.GetChallenge() == enums.Challenges.MongoFamily then return {entType, enums.Slots.MongoBeggar, 0} end
	if entVar == 4 then --datatables.ReplaceBeggarVariants[var] then

		--functions.LoadedSaveData()
		--if myrng:RandomFloat() <= datatables.GlitchBeggar.ReplaceChance then
		--	return {entType, enums.Slots.GlitchBeggar, 0, seed}
		--else

		if mod.PersistentData.CompletionMarks.Challenges.lobotomy > 0 and mod.rng:RandomFloat() <= 0.05 then
			return {entType, enums.Slots.DeliriumBeggar, 0}
		elseif mod.rng:RandomFloat() <= 0.05 then
			return {entType, enums.Slots.MongoBeggar, 0}
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, mod.onEntSpawn)
---BEGGAR UPDATE--
function mod:peffectUpdateBeggars(player)
	local level = game:GetLevel()
	local mongoBeggars = Isaac.FindByType(EntityType.ENTITY_SLOT, enums.Slots.MongoBeggar)
	local deliriumBeggars = Isaac.FindByType(EntityType.ENTITY_SLOT, enums.Slots.DeliriumBeggar)
	---Delirious Beggars --requires coin, drop - charmed monsters or delirious pickups. prize - charmed Boss. if killed - delirious pickups
	if #deliriumBeggars > 0 then
		for _, beggar in pairs(deliriumBeggars) do
			local sprite = beggar:GetSprite()
			local rng = beggar:GetDropRNG()
			local randNum = rng:RandomFloat()
			local beggarData = beggar:GetData()
			beggar.SplatColor = Color(2,2,2,1,5,5,5)
			beggarData.PityCounter = beggarData.PityCounter or 0
			if sprite:IsFinished("PayNothing") then sprite:Play("Idle")	end
			if sprite:IsFinished("PayPrize") then sprite:Play("Prize") end
			if sprite:IsFinished("Prize") then
				sfx:Play(SoundEffect.SOUND_SLOTSPAWN)
				local spawnpos = Isaac.GetFreeNearPosition(beggar.Position, 40)
				if randNum <= 0.05 then -- spawn boss
					sprite:Play("Teleport")
					mod.ModVars.DeliriousBumCharm = true
					player:UseActiveItem(CollectibleType.COLLECTIBLE_DELIRIOUS, datatables.NoAnimNoAnnounMimicNoCostume)
					level:SetStateFlag(LevelStateFlag.STATE_BUM_LEFT, true)
				else -- spawn delirious pickup or spawn charmed enemy
					sprite:Play("Idle")
					if randNum <= 0.25 then
						Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, datatables.DeliObject.Variants[rng:RandomInt(#datatables.DeliObject.Variants)+1], beggar.Position, RandomVector()*5, nil)
					else
						mod.ModVars.SavedEnemies = mod.ModVars.SavedEnemies or {EntityType.ENTITY_GAPER, 0}
						local savedOnes = mod.ModVars.SavedEnemies[rng:RandomInt(#mod.ModVars.SavedEnemies)+1]
						local npc = Isaac.Spawn(savedOnes[1], savedOnes[2], 0, spawnpos, Vector.Zero, player):ToNPC()
						npc:AddCharmed(EntityRef(player), -1)
					end
				end
			end
			if sprite:IsFinished("Teleport") then
				beggar:Remove()
			else
				if beggar.Position:Distance(player.Position) <= 25 then -- 20 distance where you definitely touch beggar
					if sprite:IsPlaying("Idle") and player:GetNumCoins() > 0 then
						player:AddCoins(-1)
						sfx:Play(SoundEffect.SOUND_SCAMPER)
						if beggarData.PityCounter >= 6 or rng:RandomFloat() < 0.2 then
							sprite:Play("PayPrize")
							beggarData.PityCounter = 0
						else
							sprite:Play("PayNothing")
							beggarData.PityCounter = beggarData.PityCounter + 1
						end
					end
				end
				if functions.BeggarWasBombed(beggar, true) then
					game:ShowHallucination(5, BackdropType.NUM_BACKDROPS)
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, datatables.DeliObject.Variants[rng:RandomInt(#datatables.DeliObject.Variants)+1], beggar.Position, RandomVector()*5, nil)
				end
			end
		end
	end
	---Mongo Beggar --requires coin, drop - familiars for level. prize - mongo baby. max 6 familiars per room interaction (leave and reenter room hack?)
	if #mongoBeggars > 0 then
		for _, beggar in pairs(mongoBeggars) do
			local sprite = beggar:GetSprite()
			local rng = beggar:GetDropRNG()
			local randNum = rng:RandomFloat()
			local beggarData = beggar:GetData()
			beggarData.PityCounter = beggarData.PityCounter or 0
			beggarData.PrizeCounter = beggarData.PrizeCounter or 0
			if sprite:IsFinished("PayNothing") then sprite:Play("Idle")	end
			if sprite:IsFinished("PayPrize") then sprite:Play("Prize") end

			if sprite:IsFinished("Prize") then
				sfx:Play(SoundEffect.SOUND_SLOTSPAWN)
				if randNum <= 0.05 then --Spawn item
					local spawnpos = Isaac.GetFreeNearPosition(beggar.Position, 35)
					sprite:Play("Teleport")
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_MONGO_BABY, spawnpos, Vector.Zero, nil)
					level:SetStateFlag(LevelStateFlag.STATE_BUM_LEFT, true)
				else
					player:UseActiveItem(CollectibleType.COLLECTIBLE_MONSTER_MANUAL, datatables.NoAnimNoAnnounMimicNoCostume)
					if sfx:IsPlaying(SoundEffect.SOUND_SATAN_GROW) then sfx:Stop(SoundEffect.SOUND_SATAN_GROW) end -- stop devil laughs
					beggarData.PrizeCounter = beggarData.PrizeCounter + 1
					if beggarData.PrizeCounter >= 6 then
						sprite:Play("Teleport")
						level:SetStateFlag(LevelStateFlag.STATE_BUM_LEFT, true)
					else
						sprite:Play("Idle")
					end
				end
			end
			if sprite:IsFinished("Teleport") then
				beggar:Remove()
			else
				if beggar.Position:Distance(player.Position) <= 25 then
					if sprite:IsPlaying("Idle") and player:GetNumCoins() > 0 then
						player:AddCoins(-1)
						sfx:Play(SoundEffect.SOUND_SCAMPER)
						if beggarData.PityCounter >= 6 or rng:RandomFloat() < 0.2 then
							sprite:Play("PayPrize")
							beggarData.PityCounter = 0
						else
							sprite:Play("PayNothing")
							beggarData.PityCounter = beggarData.PityCounter + 1
						end
					end
				end
				functions.BeggarWasBombed(beggar)
			end
		end
	end

	---Glithced Baggar --cycle random pickups. prize - glitched item (tmtrainer), guaranteed after 10 pickups
	---Bookworm Beggar --requires 5 coins, prize - random book, 33% chance to leave after prize
	---Dungeon Beggar --requires 1 coin, drop - random event, if bombed - teleports you to random room
	---Ghost Beggar --requires hearts, drop - soul stones, prize - ghost themed item. if bombed - turn into soul (apply white fireplace effect)
	---Pandora Beggar --free interactions, add random curse and item wisps, leaves after 3 interactions, if bombed add 3 curses and 3 item wisps
	---Rich Beggar -- requires 5 coins, drop - random beggar, prize - random bum
	--[[
	local glitchBeggars = Isaac.FindByType(EntityType.ENTITY_SLOT, enums.Slots.GlitchBeggar)
	if #glitchBeggars > 0 then
		for _, beggar in pairs(glitchBeggars) do
			local sprite = beggar:GetSprite()
			local rng = beggar:GetDropRNG()
			local beggarData = beggar:GetData()

			beggarData.PickupRotateTimeout = beggarData.PickupRotateTimeout or datatables.GlitchBeggar.PickupRotateTimeout --0
			beggarData.PityCounter = beggarData.PityCounter or 0

			if datatables.GlitchBeggar.RandomPickupCheck[sprite:GetAnimation()] then
				beggarData.PickupRotateTimeout = beggarData.PickupRotateTimeout + 1
				if beggarData.PickupRotateTimeout >= datatables.GlitchBeggar.PickupRotateTimeout then
					sprite:Play("ChangePickup")
					beggarData.PickupRotateTimeout = 0
				end
			end

			if sprite:IsFinished("PayNothing") or sprite:IsFinished("ChangePickup") then
				local randNum = rng:RandomInt(#datatables.GlitchBeggar.RandomPickup)+1
				sprite:Play(datatables.GlitchBeggar.RandomPickup[randNum])
			end
			if sprite:IsFinished("PayPrize") then sprite:Play("Prize") end

			if sprite:IsFinished("Prize") then
				local pos = Isaac.GetFreeNearPosition(beggar.Position, 35)
				sprite:Play("Teleport")
				player:AddCollectible(CollectibleType.COLLECTIBLE_TMTRAINER)
				functions.DebugSpawn(100, 0, pos)
				player:RemoveCollectible(CollectibleType.COLLECTIBLE_TMTRAINER) -- remove tmtrainer
				level:SetStateFlag(LevelStateFlag.STATE_BUM_LEFT, true)
			end

			if sprite:IsFinished("Teleport") then
				beggar:Remove()
			else
				if beggar.Position:Distance(player.Position) <= 20 then --(beggar.Position - player.Position):Length() <= 20 then
					if sprite:IsPlaying("Idle") then
						if player:GetNumCoins() > 0 then
							player:AddCoins(-1)
							GlitchBeggarState(beggarData, sprite, rng)
						end
					elseif sprite:IsPlaying("IdleBomb") then
						if player:GetNumBombs() > 0 then
							player:AddBombs(-1)
							GlitchBeggarState(beggarData, sprite, rng)
						end
					elseif sprite:IsPlaying("IdleKey") then
						if player:GetNumKeys() > 0 then
							player:AddKeys(-1)
							GlitchBeggarState(beggarData, sprite, rng)
						end
					elseif sprite:IsPlaying("IdleHeart") then
						player:TakeDamage(1, DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_IV_BAG, EntityRef(player), 1)
						GlitchBeggarState(beggarData, sprite, rng)
					end
				end
				functions.BeggarWasBombed(beggar)
			end
		end
	end
	--]]
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.peffectUpdateBeggars)


---COLLECTIBLE INIT--
function mod:onCollectiblepInit(pickup)
	if mod.ModVars and mod.ModVars.ForLevel then
		---ZeroMilestoneCard
		if mod.ModVars.ForLevel.ZeroMilestoneItems then
			local rng = pickup:GetDropRNG()
			local seedItem = tostring(rng:GetSeed())
			for cache_seed, _ in pairs(mod.ModVars.ForLevel.ZeroMilestoneItems) do
				if cache_seed == seedItem then
					pickup:GetData().ZeroMilestoneItem = true
				end
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, mod.onCollectiblepInit, PickupVariant.PICKUP_COLLECTIBLE)
---COLLECTIBLE UPDATE--
function mod:CollectibleUpdate(pickup)
	if pickup.SubType == 0 then return end
	if functions.CheckItemTags(pickup.SubType, ItemConfig.TAG_QUEST) then return end
	if functions.GetCurrentDimension() == 2 then return end
	local level = game:GetLevel()
	if level:GetCurrentRoomIndex() == GridRooms.ROOM_GENESIS_IDX then return end
	---ChallengePotatoes
	if Isaac.GetChallenge() == enums.Challenges.Potatoes then
		local yourOnlyFood = enums.Items.Potato
		if pickup.SubType ~= yourOnlyFood then
			pickup:ToPickup():Morph(pickup.Type, pickup.Variant, yourOnlyFood)
		end
	else
		local pool = itemPool:GetPoolForRoom(game:GetRoom():GetType(), game:GetSeeds():GetStartSeed())
		if pool == ItemPoolType.POOL_NULL then pool = ItemPoolType.POOL_TREASURE end
		---ZeroMilestoneCard
		if pickup:GetData().ZeroMilestone and pickup.FrameCount%4 == 0 then
			local seedItem = tostring(pickup:GetDropRNG():GetSeed())
			mod.ModVars.ForLevel.ZeroMilestoneItems[seedItem] = nil
			local newItem = itemPool:GetCollectible(pool, false, pickup.InitSeed)
			pickup:Morph(pickup.Type, pickup.Variant, newItem)
			pickup:AppearFast()
			pickup.Wait = 0
			pickup:GetData().ZeroMilestone = true
			seedItem = tostring(pickup:GetDropRNG():GetSeed())
			mod.ModVars.ForLevel.ZeroMilestoneItems[seedItem] = true
		else
			---players
			for playerNum = 0, game:GetNumPlayers()-1 do
				local player = game:GetPlayer(playerNum):ToPlayer()
				---Cybercutlet
				if player:HasTrinket(enums.Trinkets.Cybercutlet) and functions.CheckItemTags(pickup.SubType, ItemConfig.TAG_FOOD) and not pickup:GetData().Cybercutleted then
					local newItem = itemPool:GetCollectible(pool, false, pickup.InitSeed)
					pickup:ToPickup():Morph(pickup.Type, pickup.Variant, newItem)
					pickup:GetData().Cybercutleted = true
				end
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, mod.CollectibleUpdate, PickupVariant.PICKUP_COLLECTIBLE)
---COLLECTIBLE COLLISION--
function mod:CollectibleCollision(pickup, collider) --return true - ignore collision
	if pickup.SubType == 0 then return end
	if pickup:IsShopItem() then return end
	if functions.CheckItemTags(pickup.SubType, ItemConfig.TAG_QUEST) then return end
	if functions.GetCurrentDimension() == 2 then return end
	local level = game:GetLevel()
	if level:GetCurrentRoomIndex() == GridRooms.ROOM_GENESIS_IDX then return end
	if not collider:ToPlayer() then return end
	local player = collider:ToPlayer()
	if player:HasCurseMistEffect() then return end
	if player:IsCoopGhost() then return end
	local data = player:GetData()
	if not data.eclipsed then return end
	local rng = pickup:GetDropRNG()
	local room = game:GetRoom()
	---MidasCurse
	if player:HasCollectible(enums.Items.MidasCurse) and functions.CheckItemTags(pickup.SubType, ItemConfig.TAG_FOOD) and data.eclipsed.TurnGoldChance == 1 then
		pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_GOLDEN)
		for _ = 1, 14 do
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 0, pickup.Position,  RandomVector()*5, nil)
		end
	end
	if room:GetType() == RoomType.ROOM_CHALLENGE then return end
	if room:GetType() == RoomType.ROOM_BOSSRUSH	 then return end
	---Unbidden or UnbiddenB
	if pickup.Wait <= 0 and (player:GetPlayerType() == enums.Characters.UnbiddenB or player:GetPlayerType() == enums.Characters.Unbidden) then
		local wispIt = true
		if HeavensCall and functions.HeavensCall(room, level) then
			if pickup:GetData().Price then
				player:AddBrokenHearts(pickup:GetData().Price.BROKEN)
			end
		end
		if pickup.SubType == CollectibleType.COLLECTIBLE_SCHOOLBAG then
			return false
		end
		if pickup:IsShopItem() then
			if pickup.Price >= 0 then -- shop item
				if player:GetNumCoins() >= pickup.Price then
					player:AddCoins(-pickup.Price)
				else
					wispIt = false
				end
			else -- deal item
				if player:GetPlayerType() == enums.Characters.Unbidden then
					if pickup.Price > -5 then
						if player:GetSoulHearts()/2 > 3 then
							player:AddSoulHearts(-6)
						else
							player:AddSoulHearts(1-player:GetSoulHearts())
							player:AddBrokenHearts(1)
						end
					end
				elseif player:GetPlayerType() == enums.Characters.UnbiddenB then
					if pickup.Price ~= -1000 then
						data.eclipsed.ResetGame = data.eclipsed.ResetGame or 100
						data.eclipsed.ResetGame = data.eclipsed.ResetGame - 15
					end
				end
			end
		end

		if wispIt then
			if pickup.SubType == 0 or pickup.SubType == CollectibleType.COLLECTIBLE_BIRTHRIGHT then
				return
			else
				local wisp = player:AddItemWisp(pickup.SubType, pickup.Position, true)
				if wisp then
					wisp = wisp:ToFamiliar()
					wisp.HitPoints = 6
					sfx:Play(SoundEffect.SOUND_SOUL_PICKUP)
					pickup.Touched = true
					pickup:Remove()
					return false
				end
				return
			end
		end

	---curseDesolation
	elseif level:GetCurses() & enums.Curses.Desolation > 0 and rng:RandomFloat() < 0.5 and not functions.CheckItemType(pickup.SubType) then
		if HeavensCall and functions.HeavensCall(room, level) then
			return
		end
		pickup:Remove()
		local wispItem = player:AddItemWisp(pickup.SubType, pickup.Position):ToFamiliar()
		wispItem:GetData().AddNextFloor = player
		sfx:Play(SoundEffect.SOUND_SOUL_PICKUP)
		return false
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, mod.CollectibleCollision, PickupVariant.PICKUP_COLLECTIBLE)

---PICKUP INIT--
function mod:onPostPickupInit(pickup)
	local rng = pickup:GetDropRNG()
	for playerNum = 0, game:GetNumPlayers()-1 do
		local player = game:GetPlayer(playerNum):ToPlayer()
		local data = player:GetData()
		if not player:HasCurseMistEffect() and not player:IsCoopGhost() then
			---BinderClip
			if player:HasTrinket(enums.Trinkets.BinderClip) then
				if datatables.BinderClipDuplicate[pickup.Variant] and pickup.SubType == 1 and 0.16 * player:GetTrinketMultiplier(enums.Trinkets.BinderClip) > rng:RandomFloat() then
					pickup:Morph(pickup.Type, pickup.Variant, datatables.BinderClipDuplicate[pickup.Variant])
				end
			end
			---WarHand
			if player:HasTrinket(enums.Trinkets.WarHand) and not pickup:IsShopItem() and pickup.Variant == PickupVariant.PICKUP_BOMB and 0.16 * player:GetTrinketMultiplier(enums.Trinkets.WarHand) > rng:RandomFloat() then
				if pickup.SubType == BombSubType.BOMB_NORMAL then
					pickup:Morph(pickup.Type, pickup.Variant, BombSubType.BOMB_GIGA)
				elseif pickup.SubType == BombSubType.BOMB_DOUBLEPACK then
					pickup:Morph(pickup.Type, pickup.Variant, BombSubType.BOMB_GIGA)
					Isaac.Spawn(pickup.Type, pickup.Variant, BombSubType.BOMB_GIGA, pickup.Position, RandomVector(), nil)
				end
			end
			---Duotine
			if pickup.Variant == PickupVariant.PICKUP_PILL then
				if player:HasTrinket(enums.Trinkets.Duotine) then
					local newSub = enums.Pickups.RedPill
					if pickup.SubType >= PillColor.PILL_GIANT_FLAG then newSub = enums.Pickups.RedPillHorse end
					pickup:Morph(pickup.Type, PickupVariant.PICKUP_TAROTCARD, newSub)
				end
			end
			---MidasCurse
			if player:HasCollectible(enums.Items.MidasCurse) then
				if rng:RandomFloat() < data.eclipsed.TurnGoldChance then
					functions.TurnPickupsGold(pickup:ToPickup())
					break
				end
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, mod.onPostPickupInit)
---PICKUP COLLISION--
function mod:PickupCollision(pickup, collider)
	if datatables.NotAllowedPickupVariants[pickup.Variant] then return end
	if not collider:ToPlayer() then return end
	local player = collider:ToPlayer()
	if player:HasCurseMistEffect() then return end
	if player:IsCoopGhost() then return end
	local rng = pickup:GetDropRNG()
	---BinderClip
	if player:HasTrinket(enums.Trinkets.BinderClip) and pickup.OptionsPickupIndex ~= 0 then
		pickup.OptionsPickupIndex = 0
	end
	---GoldenEgg
	if player:HasTrinket(enums.Trinkets.GoldenEgg) then
		local turnGold = false
		if pickup.Variant == PickupVariant.PICKUP_HEART and pickup.SubType ~= HeartSubType.HEART_GOLDEN then
			if pickup.SubType == HeartSubType.HEART_ROTTEN then
				player:AddBlueFlies(2, player.Position, nil)
			end
			turnGold = HeartSubType.HEART_GOLDEN
		elseif pickup.Variant == PickupVariant.PICKUP_COIN and pickup.SubType ~= CoinSubType.COIN_GOLDEN then
			if pickup.SubType == CoinSubType.COIN_LUCKYPENNY then
				player:DonateLuck(1)
			end
			turnGold = CoinSubType.COIN_GOLDEN
		elseif pickup.Variant == PickupVariant.PICKUP_KEY and pickup.SubType ~= KeySubType.KEY_GOLDEN then
			if pickup.SubType == KeySubType.KEY_CHARGED then
				Isaac.Spawn(pickup.Type,  PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_GOLDEN, Isaac.GetFreeNearPosition(pickup.Position, 1), Vector.Zero, nil)
			end
			turnGold = KeySubType.KEY_GOLDEN
		elseif pickup.Variant == PickupVariant.PICKUP_BOMB and pickup.SubType ~= BombSubType.BOMB_GOLDEN then
			if pickup.SubType == BombSubType.BOMB_GIGA then
				player:AddGigaBombs(1)
			end
			turnGold = BombSubType.BOMB_GOLDEN
		elseif pickup.Variant == PickupVariant.PICKUP_PILL and pickup.SubType ~= PillColor.PILL_GOLD then
			turnGold = PillColor.PILL_GOLD
			if pickup.SubType >= PillColor.PILL_GIANT_FLAG then
				turnGold = PillColor.PILL_GOLD | PillColor.PILL_GIANT_FLAG
			end
		elseif pickup.Variant == PickupVariant.PICKUP_LIL_BATTERY and pickup.SubType ~= BatterySubType.BATTERY_GOLDEN then
			turnGold = BatterySubType.BATTERY_GOLDEN
		elseif pickup.Variant == PickupVariant.PICKUP_TRINKET and pickup.SubType < TrinketType.TRINKET_GOLDEN_FLAG then
			turnGold = pickup.SubType + TrinketType.TRINKET_GOLDEN_FLAG
		end
		if turnGold then
			pickup:Morph(pickup.Type, pickup.Variant, turnGold)
			if rng:RandomFloat() > 0.33 * player:GetTrinketMultiplier(enums.Trinkets.GoldenEgg) then
				player:TryRemoveTrinket(enums.Trinkets.GoldenEgg)
			end
		end
		return true
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, mod.PickupCollision)

---BOMB PICKUP COLLISION--
function mod:BombPickupCollision(pickup, collider)
	if not collider:ToPlayer() then return end
	local player = collider:ToPlayer()
	if player:HasCurseMistEffect() then return end
	if player:IsCoopGhost() then return end
	local playerType = player:GetPlayerType()
	if playerType ~= enums.Characters.Nadab then return end
	if playerType ~= enums.Characters.Abihu then return end
	if player:HasGoldenBomb() and pickup.SubType == BombSubType.BOMB_GOLDEN then
		player:AddGoldenHearts(1)
	elseif player:HasFullHearts() and (pickup.SubType == BombSubType.BOMB_NORMAL or pickup.SubType == BombSubType.BOMB_DOUBLEPACK) then
		return false
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, mod.BombPickupCollision)

---TRINKET UPDATE--
function mod:TrinketUpdate(trinket)
	local dataTrinket = trinket:GetData()
	if dataTrinket.RemoveThrowTrinket then
		trinket.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		trinket.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
		if trinket.Timeout == 1 and trinket.SubType == enums.Trinkets.AbyssCart then
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_ETERNAL, trinket.Position, trinket.Velocity, nil)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, mod.TrinketUpdate, PickupVariant.PICKUP_TRINKET)

---HEART COLLISION--
function mod:HeartCollision(pickup, collider) --return true - ignore collision
	if not collider:ToPlayer() then return end
	local player = collider:ToPlayer()
	if player:HasCurseMistEffect() then return end
	if player:IsCoopGhost() then return end
	local pickupData = pickup:GetData()
	local rng = pickup:GetDropRNG()
	---Unbidden
	if player:GetPlayerType() == enums.Characters.Unbidden and player:GetBoneHearts() > 0 then -- (player:CanPickRedHearts() or player:CanPickRottenHearts()) then
		player:SetFullHearts()
		return false
	end
	---Remove
	if pickupData.Remove then
		pickup:Remove()
		return true
	---Pompom
	elseif player:HasTrinket(enums.Trinkets.Pompom) then
		local numTrinket = player:GetTrinketMultiplier(enums.Trinkets.Pompom)
		if rng:RandomFloat() < 0.5 * numTrinket then
			if pickup.SubType == HeartSubType.HEART_HALF then
				numTrinket = numTrinket
			elseif pickup.SubType == HeartSubType.HEART_FULL or pickup.SubType == HeartSubType.HEART_SCARED or pickup.SubType == HeartSubType.HEART_ROTTEN then
				numTrinket = numTrinket + 1
			elseif pickup.SubType == HeartSubType.HEART_DOUBLEPACK then
				numTrinket = numTrinket + 3
			else
				return
			end
			for _ = 1, numTrinket do
				local wisp = datatables.Pompom.WispsList[rng:RandomInt(#datatables.Pompom.WispsList)+1]
				player:AddWisp(wisp, pickup.Position, true)
			end
			pickup:Remove()
			sfx:Play(SoundEffect.SOUND_SOUL_PICKUP)
			pickup:GetData().Remove = true
			return true
		end
	---GildedFork
	elseif player:HasTrinket(enums.Trinkets.GildedFork) then
		local numTrinket = player:GetTrinketMultiplier(enums.Trinkets.GildedFork)
		if pickup.SubType == HeartSubType.HEART_HALF then
			numTrinket = 1 + numTrinket
		elseif pickup.SubType == HeartSubType.HEART_FULL or pickup.SubType == HeartSubType.HEART_SCARED or pickup.SubType == HeartSubType.HEART_ROTTEN then
			numTrinket = 2 + numTrinket
		elseif pickup.SubType == HeartSubType.HEART_DOUBLEPACK then
			numTrinket = 5 + numTrinket
		else
			return nil
		end
		for _ = 1, numTrinket do
			Isaac.Spawn(EntityType.ENTITY_PICKUP,  PickupVariant.PICKUP_COIN, 1, pickup.Position, RandomVector()*5, nil)
		end
		pickup:Remove()
		sfx:Play(SoundEffect.SOUND_CASH_REGISTER)
		pickup:GetData().Remove = true
		return true
	end
	---LostFlower
	if player:HasTrinket(enums.Trinkets.LostFlower) and pickup.SubType == HeartSubType.HEART_ETERNAL then
		--local playerType = player:GetPlayerType()
		--if playerType == PlayerType.PLAYER_THELOST or playerType == PlayerType.PLAYER_THELOST_B or player:GetPlayerType() == enums.Characters.UnbiddenB then  -- if player is Lost/T.Lost
		local tempEffects = player:GetEffects()
		if tempEffects:HasNullEffect(NullItemID.ID_LOST_CURSE) then
			player:UseCard(Card.CARD_HOLY,  datatables.NoAnimNoAnnounMimic)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, mod.HeartCollision, PickupVariant.PICKUP_HEART)

---PILL INIT--
function mod:PillInit(pickup)
	for playerNum = 0, game:GetNumPlayers()-1 do
		local player = game:GetPlayer(playerNum)
		if not player:HasCurseMistEffect() and not player:IsCoopGhost() then
			---Duotine
			if player:HasTrinket(enums.Trinkets.Duotine) then
				local newSub = enums.Pickups.RedPill
				if pickup.SubType >= PillColor.PILL_GIANT_FLAG then newSub = enums.Pickups.RedPillHorse end
				pickup:Morph(5, 300, newSub)
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, mod.PillInit, PickupVariant.PICKUP_PILL)

---CARD UPDATE--
function mod:CardUpdate(pickup)
	---DeliObject
	if datatables.DeliObject.CheckGetCard[pickup.SubType] then
		local rng = pickup:GetDropRNG()
		local pickupData = pickup:GetData()
		pickupData.CycleTimer = pickupData.CycleTimer or rng:RandomInt(300) + 150
		pickupData.CycleTimer = pickupData.CycleTimer - 1
		if pickupData.CycleTimer <= 0 then
			local newDeli = datatables.DeliObject.Variants[rng:RandomInt(#datatables.DeliObject.Variants)+1]
			if newDeli ~= pickup.SubType then
				pickup:ToPickup():Morph(pickup.Type, pickup.Variant, newDeli, true)
				pickup:GetData().CycleTimer = rng:RandomInt(300) + 150
				game:ShowHallucination(5, BackdropType.NUM_BACKDROPS)
				sfx:Stop(SoundEffect.SOUND_DEATH_CARD)
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, mod.CardUpdate, PickupVariant.PICKUP_TAROTCARD)
---CARD COLLISION--
function mod:CardCollision(pickup, collider)
	if not collider:ToPlayer() then return end
	local player = collider:ToPlayer()
	if player:HasCurseMistEffect() then return end
	if player:IsCoopGhost() then return end
	local data = player:GetData()
	---DeliObject
	if datatables.DeliObject.CheckGetCard[pickup.SubType] then
		for slot = 0, 3 do
			if datatables.DeliObject.CheckGetCard[player:GetCard(slot)] then
				pickup:Remove()
				player:SetCard(slot, pickup.SubType)
				sfx:Play(SoundEffect.SOUND_EDEN_GLITCH)
				game:ShowHallucination(5, BackdropType.NUM_BACKDROPS)
				sfx:Stop(SoundEffect.SOUND_DEATH_CARD)
				return true
			end
		end
	end
	---NirlyCodex
	if player:HasCollectible(enums.Items.NirlyCodex, true) then
		local cardType = Isaac.GetItemConfig():GetCard(pickup.SubType).CardType
		data.eclipsed.NirlySavedCards = data.eclipsed.NirlySavedCards or {}
		if datatables.CardTypes[cardType] and #data.eclipsed.NirlySavedCards < 5 then
			table.insert(data.eclipsed.NirlySavedCards, pickup.SubType)
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, nil):SetColor(Color(1,0,1),-1,1, false, false)
			pickup:Remove()
			return false
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, mod.CardCollision, PickupVariant.PICKUP_TAROTCARD)

---GET CARD--
function mod:onGetCard(rng, card) --, playingCards, includeRunes, onlyRunes)
	if (card == enums.Pickups.BannedCard and rng:RandomFloat() < 0.98) or card == enums.Pickups.RedPill or card == enums.Pickups.RedPillHorse then
		return enums.Pickups.DeliObjectCell
	end
end
mod:AddCallback(ModCallbacks.MC_GET_CARD, mod.onGetCard)

---Unbidden Target Mark--
function mod:onTargetEffectUpdate(effect)
	if effect.FrameCount == 1 and effect.SpawnerEntity and effect.SpawnerEntity:ToPlayer() and effect.SpawnerEntity:ToPlayer():GetPlayerType() == enums.Characters.UnbiddenB then
		effect.Color = Color(0.5,1,2)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.onTargetEffectUpdate, EffectVariant.TARGET)
---Unbidden Rockets--
function mod:onEpicFetusEffectUpdate(effect)
	if effect.SpawnerEntity and effect.SpawnerEntity:ToPlayer() and effect.SpawnerEntity:ToPlayer():GetPlayerType() == enums.Characters.UnbiddenB then
		local player = effect.SpawnerEntity:ToPlayer()
		local range = player.TearRange*0.5
		range = functions.AuraRange(range)
		functions.WeaponAura(player, effect.Position, effect.FrameCount, nil, range)
		--WeaponAura(player, auraPos, frameCount, maxCharge, range, blockLasers)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.onEpicFetusEffectUpdate, EffectVariant.ROCKET)
---AbihuFlame
function mod:onAbihuFlame(flame)
	local flameData = flame:GetData()
	if not flameData.AbihuFlame then return end
	if not flame.Parent then return end
	local player = flame.Parent:ToPlayer()
	---homing
	if flameData.Homing then
		local nearestNPC = functions.GetNearestEnemy(flame.Position, 150)
		flame:AddVelocity((nearestNPC - flame.Position):Resized(2))
	end
	---wait
	if flameData.Wait then
		if player.GetFireDirection == Direction.NO_DIRECTION then
			flame.Velocity = Vector.Zero
			return
		else
			flame.Velocity = flameData.Wait
			flameData.Wait = nil
		end
	end
	---boomerang
	if flameData.Boomerang then
		if flameData.Boomerang <= 0 then
			flame:AddVelocity((player.Position - flame.Position):Resized(1))
			if flameData.PrevVelocity then flameData.PrevVelocity = nil end
		else
			flameData.Boomerang = flameData.Boomerang -1
		end
	end
	if flameData.Split and flame:CollidesWithGrid() and flame.CollisionDamage > 1 then
		local vel1 = Vector(flame.Velocity.X, -flame.Velocity.Y)
		local vel2 = Vector(-flame.Velocity.X, flame.Velocity.Y)
		functions.ShootAbihuFlame(player, vel1, flame.CollisionDamage, math.floor(player.TearRange*0.1))
		functions.ShootAbihuFlame(player, vel2, flame.CollisionDamage, math.floor(player.TearRange*0.1))
	end

	---rift
	if flameData.Rift and flameData.Rift > 0 then
		flameData.Rift = flameData.Rift -1
	end
	if flame.FrameCount > 1 then return end
	functions.AbihuFlameInit(player, flame)
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.onAbihuFlame, EffectVariant.BLUE_FLAME)
---Penance cross--
function mod:onRedCrossEffect(effect)
	if effect:GetData().PenanceRedCrossEffect then
		if not effect.Parent then
			effect:Remove()
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.onRedCrossEffect, EffectVariant.REDEMPTION)
---Dead egg bird--
function mod:onDeadEggEffect(effect)
	if effect:GetData().DeadEgg and effect.Timeout <= 0 then
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, effect.Position, Vector.Zero, nil):SetColor(Color(0,0,0,1),-1,1, false, false)
		effect:Remove()
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.onDeadEggEffect, EffectVariant.DEAD_BIRD)
---Bob's Tongue fart ring--
function mod:onFartRingEffect(effect)
	if effect:GetData().BobTongue then
		if not effect.Parent then
			effect:Remove()
		else
			effect:FollowParent(effect.Parent)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.onFartRingEffect, EffectVariant.FART_RING)
---Black hole bombs--
function mod:onGravityHoleUpdate(hole)
	local room = game:GetRoom()
	local holeData = hole:GetData()
	local holeSprite = hole:GetSprite()
	if holeData.Gravity and hole.SubType == 0 then
		if hole and hole.Parent then
			if hole.Parent:ToBomb() then
				hole.Position = Vector(hole.Parent.Position.X+2.5, hole.Parent.Position.Y-6)
			else
				if game:GetFrameCount() %8 == 0 then
					for _, enemy in pairs(Isaac.FindInRadius(hole.Position, 15, EntityPartition.ENEMY)) do
						if enemy:IsVulnerableEnemy() and enemy:IsActiveEnemy() then
							enemy:TakeDamage(hole.Parent:ToPlayer().Damage, DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(hole), 0)
						end
					end
				end
				if hole.Timeout == 0 then
					hole.Parent = nil
					return nil
				end
			end
			if holeData.GravityForce < 15 then
				holeData.GravityForce = holeData.GravityForce + 0.5
			end
			if holeData.GravityRange < 2500 then
				holeData.GravityRange = holeData.GravityRange + 15
			end
			if holeData.GravityGridRange < 200 then
				holeData.GravityGridRange = holeData.GravityGridRange + 2.5
			end
			game:Darken(1, 1)
			game:UpdateStrangeAttractor(hole.Position, holeData.GravityForce, holeData.GravityRange)
			for gindex=1, room:GetGridSize() do -- destroy grid entities near black hole bombs
				local grid = room:GetGridEntity(gindex)
				if grid then
					if grid:ToRock() or grid:ToPoop() then
						if hole.Position:Distance(grid.Position) < holeData.GravityGridRange and grid.State < 2 then
							game:SpawnParticles(grid.Position, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 1, 5, 100000, 5)
						end
						if hole.Position:Distance(grid.Position) < holeData.GravityGridRange then
							grid:Destroy()
						end
					end
				end
			end
			if holeSprite:IsFinished("Open") and not holeSprite:IsPlaying("Close") then
				holeSprite:Play("Idle", true)
			end
			if not sfx:IsPlaying(SoundEffect.SOUND_BLOOD_LASER_LARGE) then
				sfx:Play(SoundEffect.SOUND_BLOOD_LASER_LARGE,1,2,false,0.2,0)
			end
		else
			if holeSprite:IsFinished("Close") then
				hole:Remove()
				sfx:Stop(SoundEffect.SOUND_BLOOD_LASER_LARGE)
			end
			if not holeSprite:IsPlaying("Close") then
				holeSprite:Play("Close", true)
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.onGravityHoleUpdate, enums.Effects.BlackHoleBombsEffect)
---BLACK KNIGHT TARGET--
function mod:onBlackKnightTargetEffect(target)
	local ready = false
	local player = target.Parent:ToPlayer()
	local targetSprite = target:GetSprite()
	target.DepthOffset = -100
	if not target.GridCollisionClass == EntityGridCollisionClass.GRIDCOLL_WALLS then
		target.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
	end
	if player:GetData().eclipsed.ForRoom.ControlTarget then
		target.Velocity = player:GetMovementInput() * player.MoveSpeed
	end
	if player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == enums.Items.BlackKnight and player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY) >= Isaac.GetItemConfig():GetCollectible(enums.Items.BlackKnight).MaxCharges then
		ready = true
	end
	local grid = game:GetRoom():GetGridEntityFromPos(target.Position)
	if grid and not player.CanFly then
		if grid.Desc.Type == GridEntityType.GRID_PIT and grid.Desc.State ~= 1 then
			ready = false
		end
	end
	if ready and not targetSprite:IsPlaying("Blink") then
		targetSprite:Play("Blink")
	else
		targetSprite:Play("Idle")
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.onBlackKnightTargetEffect, enums.Effects.BlackKnightTarget)
---MOONLIGHTER TARGET--
function mod:onKeeperMirrorTargetEffect(target)
	local player = target.Parent:ToPlayer()
	target.DepthOffset = -100
	if not target.GridCollisionClass == EntityGridCollisionClass.GRIDCOLL_WALLS then
		target.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
	end
	target.Velocity = player:GetShootingInput() * player.ShotSpeed * 0.7
	--if target.Velocity.X == 0 and target.Velocity.Y == 0 then --Length
	if target.Velocity:Length() == 0 then
		local pickups = Isaac.FindInRadius(target.Position, 10, EntityPartition.PICKUP)
		for _, pickup in pairs(pickups) do
			if pickup:ToPickup() then
				pickup = pickup:ToPickup()
				if not pickup:IsShopItem() and datatables.AllowedPickupVariants[pickup.Variant] then
					pickup:Remove()
					--print(pickup.Price)
					for _ = 1, pickup.Price do
						Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, pickup.Position, RandomVector()*5, nil)
					end
					Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, nil):SetColor(Color(0,1.5,1.3), -1, 1, false, false)
					sfx:Play(SoundEffect.SOUND_CASH_REGISTER)
					target:Remove()
					return
				end
			end
		end
	end
	if target.Timeout <= 1 then
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, target.Position, Vector.Zero, nil)
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, target.Position, Vector.Zero, nil):SetColor(Color(0,1.5,1.3), -1, 1, false, false)
		sfx:Play(SoundEffect.SOUND_CASH_REGISTER)
		target:Remove()
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.onKeeperMirrorTargetEffect, enums.Effects.KeeperMirrorTarget)
---ELDER SIGN PENTAGRAM--
function mod:onElderSignPentagramEffect(pentagram)
	if pentagram:GetData().ElderSign and pentagram.SpawnerEntity then
		if pentagram.FrameCount == pentagram:GetData().ElderSign then
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PURGATORY, 1, pentagram.Position, Vector.Zero, nil):SetColor(Color(0.2,0.5,0.2), -1, 1, false, false)
		end
		local enemies = Isaac.FindInRadius(pentagram.Position, 50, EntityPartition.ENEMY)
		for _, enemy in pairs(enemies) do
			if enemy:ToNPC() and enemy:IsVulnerableEnemy() and enemy:IsActiveEnemy() then
				if functions.CheckJudasBirthright(pentagram.SpawnerEntity) then
					enemy:AddBurn(EntityRef(pentagram.SpawnerEntity), 1, 2*pentagram.SpawnerEntity:ToPlayer().Damage)
					enemy:GetData().Waxed = 1
				end
				enemy:AddFreeze(EntityRef(pentagram.SpawnerEntity), 1)
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.onElderSignPentagramEffect, EffectVariant.HERETIC_PENTAGRAM)

---RENDER--
function mod:onUnbiddenTextRender() --pickup, collider, low
	local player = Isaac.GetPlayer(0)
	local data = player:GetData()
	---CurseIcons
	functions.CurseIconRender()
	---UnbiddenB
	if player:GetPlayerType() == enums.Characters.UnbiddenB and data.eclipsed then
		data.eclipsed.ResetGame = data.eclipsed.ResetGame or 100
		data.eclipsed.LevelRewindCounter = data.eclipsed.LevelRewindCounter or 1
		local pos = Vector(75, 30) + Options.HUDOffset*Vector(24, 12)
		datatables.HourglassIcon:Render(pos)
		datatables.HourglassText:DrawString(math.floor(data.eclipsed.ResetGame).. "%", 85 + Options.HUDOffset * 24 , 5 + Options.HUDOffset *10, KColor(1 ,1 ,1 ,1), 0, true)
		if data.eclipsed.LevelRewindCounter > 1 then
			datatables.HourglassText:DrawString("-"..math.floor(data.eclipsed.LevelRewindCounter).. "%", 110 + Options.HUDOffset * 24 , 5 + Options.HUDOffset *10, KColor(1 ,1 ,1 ,1), 0, true)
		end
	end
	---players
	for playerNum = 0, game:GetNumPlayers()-1 do
		player = game:GetPlayer(playerNum)
		data = player:GetData()
		local activeItem = player:GetActiveItem(ActiveSlot.SLOT_PRIMARY)
		---NirlyCodex
		if player:HasCollectible(enums.Items.NirlyCodex) and data.eclipsed.NirlySavedCards and #data.eclipsed.NirlySavedCards > 0 then
			local offset = 0.2
			local scale = 0.5
			local color = 0
			local posYOffset = 90
			if Input.IsActionPressed(ButtonAction.ACTION_MAP, player.ControllerIndex) then
				offset = 1
				scale = 1
				color = 1
				posYOffset = 130
			end
			datatables.TextFont:DrawStringScaled("Nirly's Collection:", 15 + Options.HUDOffset * 24 , Isaac.GetScreenHeight()-posYOffset -1 * scale + Options.HUDOffset *10, scale, scale, KColor(1 ,1 ,1 ,offset), 0, true)
			for index, card in pairs(data.eclipsed.NirlySavedCards) do
				local cardConf = Isaac.GetItemConfig():GetCard(card)
				local card_name = cardConf.Name
				datatables.TextFont:DrawStringScaled(card_name, 15 + Options.HUDOffset * 24 , Isaac.GetScreenHeight()-90 + index * 10 * scale + Options.HUDOffset *10, scale, scale, KColor(1 ,1 ,1 ,offset), 0, true)
			end
		end
		---Corruption
		if data.eclipsed.ForRoom.Corruption then
			functions.ActiveItemText(data.eclipsed.ForRoom.Corruption, 3, 22, KColor(1 ,0 ,1 ,1))
		end
		---StoneScripture, NirlyCodex, TomeDead
		if activeItem > 0 then
			if activeItem == enums.Items.StoneScripture then
				local uses = 3
				if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) then
					uses = 6
				end
				data.eclipsed.ForRoom.StoneScripture = data.eclipsed.ForRoom.StoneScripture or uses
				functions.ActiveItemText(data.eclipsed.ForRoom.StoneScripture)
			elseif activeItem == enums.Items.NirlyCodex then
				if data.eclipsed.NirlySavedCards and #data.eclipsed.NirlySavedCards > 0 then
					functions.ActiveItemText(#data.eclipsed.NirlySavedCards)
				end
			elseif activeItem == enums.Items.TomeDead then
				if data.eclipsed.CollectedSouls then
					functions.ActiveItemText(data.eclipsed.CollectedSouls, 26, 26)
				end
			elseif activeItem == enums.Items.HeartTransplant then
				if data.eclipsed.HeartTransplantUseCount then
					functions.ActiveItemText(data.eclipsed.HeartTransplantUseCount)
				end
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.PostRender)
---RENDER PLAYER--
function mod:onPlayerRender(player) --renderOffset
	local data = player:GetData()
	if data.eclipsed and not player:IsDead() then
		---Threshold
		if data.eclipsed.RenderThresholdItem then
			local posX = 0
			local posY = -38
			local pos = Isaac.WorldToScreen(player.Position)
			local vecX = pos.X + (player.SpriteScale.X * posX)
			local vecY = pos.Y + (player.SpriteScale.Y * posY)
			pos = Vector(vecX, vecY)
			local alpha = 0.35
			if game:GetFrameCount()%3 ~= 0 then alpha = 0.25 end
			local wisp = data.eclipsed.RenderThresholdItem.SubType
			local gfxName = Isaac.GetItemConfig():GetCollectible(wisp).GfxFileName
			local itemSprite = Sprite()
			itemSprite:Load("gfx/005.100_Collectible.anm2", true)
			itemSprite:ReplaceSpritesheet(1, gfxName)
			itemSprite:LoadGraphics()
			itemSprite.Scale = Vector.One * 0.8
			itemSprite:SetFrame("Idle", 8)
			itemSprite.Color = Color(1,1,1,alpha)
			itemSprite:Render(pos)
		end
		---ChargeBars
		if Options.ChargeBars then
			local playerType = player:GetPlayerType()
			if playerType == enums.Characters.UnbiddenB and (data.eclipsed.UnbiddenFullCharge or data.eclipsed.UnbiddenSemiCharge) and data.eclipsed.BlindCharacter and not data.eclipsed.HoldingWeapon then -- and not data.TechLudo
				functions.RenderChargeManager(player, data.eclipsed.UnbiddenBDamageDelay, datatables.UnbiddenBData.ChargeBar, (6 + math.floor(player.MaxFireDelay)))
			elseif playerType == enums.Characters.Abihu and (player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) or data.eclipsed.ForRoom.AbihuIgnites) then
				functions.RenderChargeManager(player, data.eclipsed.AbihuDamageDelay, datatables.AbihuData.ChargeBar, (30 + math.floor(player.MaxFireDelay)))
			end
			if player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == enums.Items.HeartTransplant and data.eclipsed.HeartTransplantActualCharge and data.eclipsed.HeartTransplantActualCharge > 0 then
				functions.RenderChargeManager(player, data.eclipsed.HeartTransplantActualCharge, datatables.HeartTransplant.ChargeBar, Isaac.GetItemConfig():GetCollectible(enums.Items.HeartTransplant).MaxCharges, 0, -42)
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, mod.onPlayerRender)

---ACTIVE ITEM--

---TriggerBookOfVirtues and Abihu drop Nadab's Body
function mod:TriggerBookOfVirtues(item, _, player, useFlag, activeSlot)
	if datatables.ActiveItemWisps[item] and useFlag & UseFlag.USE_MIMIC == 0 and player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
		local wisp = player:AddWisp(datatables.ActiveItemWisps[item], player.Position)
		if wisp then
			local wispData = wisp:GetData()
			local sprite = wisp:GetSprite()
			if item == enums.Items.ElderSign then
				wispData.RemoveAll = item
			elseif item == enums.Items.BlackBook then
				wisp.Color = Color(0.15,0.15,0.15)
				sprite:ReplaceSpritesheet(0, "gfx/familiar/wisps/card.png")
				sprite:LoadGraphics()
			elseif item == enums.Items.BookMemory then
				wisp.Color =  Color(0.5,1,2)
			elseif Isaac.GetItemConfig():GetCollectible(item).ChargeType == ItemConfig.CHARGE_TIMED then
				wispData.TemporaryWisp = true
			end
		end
	end
	local playerType = player:GetPlayerType()
	local data = player:GetData()
	if playerType == enums.Characters.Abihu and useFlag & UseFlag.USE_NOANIM == 0 then
		data.eclipsed.HoldBomd = -1
	elseif (playerType == enums.Characters.Unbidden or playerType == enums.Characters.Unbidden) and useFlag & useFlag & UseFlag.USE_MIMIC == 0 and activeSlot == ActiveSlot.SLOT_PRIMARY then
		data.eclipsed.CurrentHeldItem = item
	end
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.TriggerBookOfVirtues)
---NadabAbihuDetonator--
function mod:NadabAbihuDetonator(_, _, player)
	---Nadab
	local data = player:GetData()
	data.eclipsed = data.eclipsed or {}
	if player:GetPlayerType() == enums.Characters.Nadab then
		data.eclipsed.ExCountdown = data.eclipsed.ExCountdown or 0
		if data.eclipsed.ExCountdown == 0 then
			data.eclipsed.ExCountdown = 30
			functions.FcukingBomberman(player)
		end
	end
	---NadabBody
	if player:HasCollectible(enums.Items.NadabBody) then
		data.eclipsed.ExCountdown = data.eclipsed.ExCountdown or 0
		if data.eclipsed.ExCountdown == 0 then
			data.eclipsed.ExCountdown = 30
			local bodies = Isaac.FindByType(EntityType.ENTITY_BOMB, BombVariant.BOMB_DECOY)
			for _, body in pairs(bodies) do
				if body:GetData().eclipsed and body:GetData().eclipsed.NadabBomb then
					functions.FcukingBomberbody(player)
				end
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.NadabAbihuDetonator, CollectibleType.COLLECTIBLE_REMOTE_DETONATOR)
---UnbiddenHourglass
function mod:UnbiddenHourglass(_, _, player)
	local data = player:GetData()
	if data.eclipsed.BlindCharacter then
		data.eclipsed.ResetBlind = 60 -- reset blindfold after 60 frames
	end
	if data.eclipsed.ForLevel.LostWoodenCross then data.eclipsed.ForLevel.LostWoodenCross = nil end
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.UnbiddenHourglass, CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS)
---UnbiddenPlanC
function mod:UnbiddenPlanC(_, _, player)
	if player:GetPlayerType() == enums.Characters.UnbiddenB then
		player:GetData().eclipsed.ResetGame = 0
	elseif player:GetPlayerType() == enums.Characters.Unbidden then
		player:AddBrokenHearts(11 - player:GetBrokenHearts())
	end
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.UnbiddenPlanC, CollectibleType.COLLECTIBLE_PLAN_C)
---RedPillPlacebo
function mod:RedPillPlacebo(_, _, player)
	local pill = player:GetCard(0)
	if pill == enums.Pickups.RedPill or pill == enums.Pickups.RedPillHorse then
		player:UseCard(pill, UseFlag.USE_MIMIC)
	end
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.RedPillPlacebo, CollectibleType.COLLECTIBLE_PLACEBO)
---LostFlowerPrayerCard
function mod:LostFlowerPrayerCard(_, _, player)
	if player:HasTrinket(enums.Trinkets.LostFlower) then
		--local playerType = player:GetPlayerType()
		local tempEffects = player:GetEffects()
		if tempEffects:HasNullEffect(NullItemID.ID_LOST_CURSE) then
			--if playerType == PlayerType.PLAYER_THELOST or playerType == PlayerType.PLAYER_THELOST_B or player:GetPlayerType() == enums.Characters.UnbiddenB then
			player:UseCard(Card.CARD_HOLY,  datatables.NoAnimNoAnnounMimic)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.LostFlowerPrayerCard, CollectibleType.COLLECTIBLE_PRAYER_CARD)

---Threshold--
function mod:Threshold(_, _, player)
	local data = player:GetData()
	if data.eclipsed.RenderThresholdItem then
		data.eclipsed.WispedQueue = data.eclipsed.WispedQueue or {}
		table.insert(data.eclipsed.WispedQueue, {data.eclipsed.RenderThresholdItem, true})
		data.eclipsed.RenderThresholdItem = nil
		return false
	end
	--if functions.AddItemFromWisp(player, true) then return false end
	player:UseCard(Card.RUNE_BLACK, datatables.NoAnimNoAnnounMimic)
	return true
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.Threshold, enums.Items.Threshold)
---Floppy Disk Empty
function mod:onFloppyDisk(_, _, player)
	functions.StorePlayerItems(player)
	return {ShowAnim = true, Remove = true, Discharge = true}
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.onFloppyDisk, enums.Items.FloppyDisk)
---Floppy Disk Full
function mod:onFloppyDiskFull(_, _, player)
	functions.ReplacePlayerItems(player)
	game:ShowHallucination(5, 0)
	sfx:Stop(SoundEffect.SOUND_DEATH_CARD)
	return {ShowAnim = true, Remove = true, Discharge = true}
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.onFloppyDiskFull, enums.Items.FloppyDiskFull)
---KeeperMirror
function mod:KeeperMirror(_, _, player) --item, rng, player, useFlag, activeSlot, customVarData
	local target = Isaac.Spawn(EntityType.ENTITY_EFFECT, enums.Effects.KeeperMirrorTarget, 0, player.Position, Vector.Zero, player):ToEffect()
	target.Parent = player
	target:SetTimeout(80)
	target:GetSprite():Play("Blink")
	return true
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.KeeperMirror, enums.Items.KeeperMirror)
---SecretLoveLetter
function mod:SecretLoveLetter(item, _, player, useFlag)
	if useFlag & UseFlag.USE_CARBATTERY == 0 then
		local data = player:GetData()
		player:AnimateCollectible(item, player:IsHoldingItem() and "HideItem" or "LiftItem")
		if data.eclipsed.SecretLoveLetter then
			data.eclipsed.SecretLoveLetter = false
		else
			data.eclipsed.SecretLoveLetter = true
		end
	end
	return {ShowAnim = false, Remove = false, Discharge = false}
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.SecretLoveLetter, enums.Items.SecretLoveLetter)
---NirlyCodex
function mod:NirlyCodex(_, _, player)
	local data = player:GetData()
	if data.eclipsed.NirlySavedCards and #data.eclipsed.NirlySavedCards > 0 then
		data.eclipsed.UsedNirly = true
		return true
	end
	return false
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.NirlyCodex, enums.Items.NirlyCodex)
---LongElk
function mod:onLongElk(_, _, player)
	local data = player:GetData()
	data.eclipsed.ForRoom.ElkKiller = true
	local tempEffects = player:GetEffects()
	tempEffects:AddCollectibleEffect(CollectibleType.COLLECTIBLE_MARS, false, 1)
	return false
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.onLongElk, enums.Items.LongElk)
---HuntersJournal
function mod:HuntersJournal(_, _, player)
	for _ = 1, 2 do
		local charger = Isaac.Spawn(EntityType.ENTITY_CHARGER, 0, 1, player.Position, Vector.Zero, player)
		charger:SetColor(Color(0,0,2), -1, 1, false, true)
		charger:AddCharmed(EntityRef(player), -1)
		charger:GetData().BlackHoleCharger = true
	end
	return true
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.HuntersJournal, enums.Items.HuntersJournal)
---TetrisDice
function mod:TetrisDice(_, _, player)
	local items = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)
	player:AddCollectible(CollectibleType.COLLECTIBLE_CHAOS, 0, false)
	for _, item in pairs(items) do
		if item.SubType == 0 then
			local newItem = itemPool:GetCollectible(0, true)
			item:Morph(item.Type, item.Variant, newItem)
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, item.Position, Vector.Zero, nil)
		end
	end
	player:RemoveCollectible(CollectibleType.COLLECTIBLE_CHAOS)
	return true
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.TetrisDice, enums.Items.TetrisDice_full)
---LockedGrimoire
function mod:LockedGrimoire(_, rng, player)
	if player:GetNumKeys() > 0 then
		player:AddKeys(-1)
		local randomChest = datatables.LockedGrimoireChests[rng:RandomInt(#datatables.LockedGrimoireChests)+1]
		if randomChest[2] > rng:RandomFloat() then
			local reward = randomChest[1]
			local chest = Isaac.Spawn(EntityType.ENTITY_PICKUP, reward, 0, Isaac.GetFreeNearPosition(player.Position, 10), Vector.Zero, nil)
			if chest then
				chest = chest:ToPickup()
				chest.Visible = false
				chest:TryOpenChest(player)
			end
		end
		return true
	end
	return false
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.LockedGrimoire, enums.Items.LockedGrimoire)
---TomeDead
function mod:TomeDead(item, _, player, useFlag, activeSlot, customVarData)
	player:GetData().eclipsed.TomeDead = 30
	local counter = player:GetActiveCharge(activeSlot)
	if useFlag == UseFlag.USE_CUSTOMVARDATA then
		counter = customVarData
	end
	for _ = 1, counter do
		local purgesoul = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PURGATORY, 1, player.Position, Vector.Zero, player):ToEffect()
		purgesoul:GetSprite():Play("Charge", true)
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
			player:AddWisp(item, player.Position, true)
		end
	end
	return true
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.TomeDead, enums.Items.TomeDead)
---StoneScripture
function mod:StoneScripture(item, _, player)
	local data = player:GetData()
	local uses = 3
	if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) then
		uses = 6
	end
	data.eclipsed.ForRoom.StoneScripture = data.eclipsed.ForRoom.StoneScripture or uses
	if data.eclipsed.ForRoom.StoneScripture > 0 then
		data.eclipsed.ForRoom.StoneScripture = data.eclipsed.ForRoom.StoneScripture -1
		functions.SoulExplosion(player.Position)
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
			player:AddWisp(item, player.Position, true)
		end
		return true
	end
	return false
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.StoneScripture, enums.Items.StoneScripture)
---AlchemicNotes
function mod:AlchemicNotes(_, rng, player)
	local kill = true
	if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
		kill = false
	end
	local pickups = Isaac.FindByType(EntityType.ENTITY_PICKUP)
	for _, pickup in pairs(pickups) do
		pickup = pickup:ToPickup()
		if datatables.AlchemicNotesPickups[pickup.Variant] and not pickup:IsShopItem() then
			if kill then
				pickup:Remove()
			end
			local wispy = 1
			local num = 1
			if pickup.Variant == PickupVariant.PICKUP_COIN and not pickup.SubType == CoinSubType.COIN_STICKYNICKEL then
				wispy = 555 --nickel or dime (golden razor)
				if pickup.SubType == CoinSubType.COIN_PENNY then
					wispy = 295 --
				elseif pickup.SubType == CoinSubType.COIN_LUCKYPENNY then
					wispy = 719
				elseif pickup.SubType == CoinSubType.COIN_GOLDEN then
					wispy = 349
				elseif pickup.SubType == CoinSubType.COIN_DOUBLEPACK then
					num = 2
				end
			elseif pickup.Variant == PickupVariant.PICKUP_BOMB then
				wispy = 37
				if rng:RandomFloat() < 0.5 then
					wispy = 65 -- pause
				end
				if pickup.SubType == BombSubType.BOMB_GOLDEN then
					wispy = 483
				elseif pickup.SubType == BombSubType.BOMB_DOUBLEPACK then
					num = 2
				elseif pickup.SubType == BombSubType.BOMB_GIGA then
					wispy = 37
					num = 4
				end
			elseif pickup.Variant == PickupVariant.PICKUP_KEY then
				wispy = 175 --623
				if rng:RandomFloat() < 0.15 then
					wispy = 580
				end
				if pickup.SubType == KeySubType.KEY_DOUBLEPACK then
					num = 2
				elseif pickup.SubType == KeySubType.KEY_GOLDEN then
					wispy = 175
				end
				--580 - red key
			elseif pickup.Variant == PickupVariant.PICKUP_PILL then
				wispy = 102
			elseif pickup.Variant == PickupVariant.PICKUP_LIL_BATTERY then
				wispy = 65540 --red laser wisp
				if rng:RandomFloat() < 0.5 then
					wispy = 478 -- pause
				end
			elseif pickup.Variant == PickupVariant.PICKUP_HEART then
				wispy = 45
				if pickup.SubType == HeartSubType.HEART_ETERNAL then
					wispy = 146
				elseif pickup.SubType == HeartSubType.HEART_DOUBLEPACK then
					num = 2
				elseif pickup.SubType == HeartSubType.HEART_ROTTEN then
					wispy = 639
				elseif pickup.SubType == HeartSubType.HEART_SOUL or pickup.SubType == HeartSubType.HEART_HALF_SOUL then
					wispy = 133
				elseif pickup.SubType == HeartSubType.HEART_BLENDED then
					wispy = enums.Items.RitualManuscripts
					num = 2
				elseif pickup.SubType == HeartSubType.HEART_BONE then
					wispy = enums.Items.ForgottenGrimoire
				elseif pickup.SubType == HeartSubType.HEART_BLACK then
					wispy = 35
				end
			elseif pickup.Variant == PickupVariant.PICKUP_TAROTCARD then
				local cardType = Isaac.GetItemConfig():GetCard(pickup.SubType).CardType
				wispy = 286
				if cardType == ItemConfig.CARDTYPE_RUNE or cardType == 6 then
					wispy = 263
				elseif pickup.SubType == Card.CARD_CRACKED_KEY then
					wispy = 580
				end
			elseif pickup.Variant == PickupVariant.PICKUP_THROWABLEBOMB then
				wispy = 40 -- dynamite
			end
			for _ = 1, num do
				player:AddWisp(wispy, pickup.Position, true)
			end
		end
	end
	return false
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.AlchemicNotes, enums.Items.AlchemicNotes)
---StitchedPapers
function mod:StitchedPapers(_, _, player)
	local tempEffects = player:GetEffects()
	tempEffects:AddCollectibleEffect(CollectibleType.COLLECTIBLE_FRUIT_CAKE, false)
	return true
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.StitchedPapers, enums.Items.StitchedPapers)
---RitualManuscripts
function mod:RitualManuscripts(_, _, player)
	player:AddHearts(1)
	player:AddSoulHearts(1)
	return true
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.RitualManuscripts, enums.Items.RitualManuscripts)
---WizardBook
function mod:WizardBook(_, rng, player)
	local num = rng:RandomInt(3)+2
	for _ = 1, num do
		local locust = rng:RandomInt(5)+1
		Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, locust, player.Position, Vector.Zero, player)
	end
	return true
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.WizardBook, enums.Items.WizardBook)
---HolyHealing
function mod:HolyHealing(_, _, player)
	local tempEffects = player:GetEffects()
	if tempEffects:HasNullEffect(NullItemID.ID_LOST_CURSE) then
		player:UseCard(Card.CARD_HOLY, datatables.NoAnimNoAnnounMimic)
	elseif player:GetEffectiveMaxHearts() == 0 then
		player:AddSoulHearts(6)
	else
		player:SetFullHearts()
	end
	return true
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.HolyHealing, enums.Items.HolyHealing)
---AncientVolume
function mod:AncientVolume(_, _, player)
	local tempEffects = player:GetEffects()
	tempEffects:AddCollectibleEffect(CollectibleType.COLLECTIBLE_CAMO_UNDIES, true)
	return true
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.AncientVolume, enums.Items.AncientVolume)
---CosmicEncyclopedia
function mod:CosmicEncyclopedia(_, rng, player)
	local pos = player.Position
	functions.Domino16Items(rng, pos)
	return true
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.CosmicEncyclopedia, enums.Items.CosmicEncyclopedia)
---RedBook
function mod:RedBook(_, rng, player, useFlag)
	local red = rng:RandomInt(#datatables.RedBag.RedPickups)+1
	Isaac.Spawn(EntityType.ENTITY_PICKUP, datatables.RedBag.RedPickups[red][1], datatables.RedBag.RedPickups[red][2], Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, player)
	if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) and useFlag & UseFlag.USE_MIMIC == 0 then
		local wisp = datatables.Pompom.WispsList[rng:RandomInt(#datatables.Pompom.WispsList)+1]
		player:AddWisp(wisp, player.Position, true)
	end
	return true
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.RedBook, enums.Items.RedBook)
---CodexAnimarum
function mod:CodexAnimarum(_, _, player)
	local soul = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HUNGRY_SOUL, 1, player.Position, Vector.Zero, player):ToEffect()
	soul:SetTimeout(360)
	return true
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.CodexAnimarum, enums.Items.CodexAnimarum)
---ForgottenGrimoire
function mod:ForgottenGrimoire(_, _, player)
	if player:CanPickBoneHearts() then
		player:AddBoneHearts(1)
	end
	return true
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.ForgottenGrimoire, enums.Items.ForgottenGrimoire)
---ElderMyth
function mod:ElderMyth(_, rng, player)
	local card = datatables.ElderMythCardPool[rng:RandomInt(#datatables.ElderMythCardPool)+1]
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, card, Isaac.GetFreeNearPosition(player.Position, 20), Vector.Zero, player)
	return true
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.ElderMyth, enums.Items.ElderMyth)
---GardenTrowel
function mod:GardenTrowel(item, _, player, useFlag)
	local dirtPatches = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.DIRT_PATCH, 0)
	local spawnSpur = true
	for _, dirt in pairs(dirtPatches) do
		if player.Position:Distance(dirt.Position) < 25 and dirt:GetSprite():GetAnimation() == "Idle" then
			player:UseActiveItem(CollectibleType.COLLECTIBLE_WE_NEED_TO_GO_DEEPER, datatables.NoAnimNoAnnounMimic)
			spawnSpur = false
			break
		end
	end
	if spawnSpur then
		local spur = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BONE_SPUR, 0, player.Position, Vector.Zero, player)
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) and spur and useFlag & UseFlag.USE_MIMIC == 0 then
			local wisp = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.WISP, item, spur.Position, Vector.Zero, spur)
			if wisp then
				wisp.Parent = spur
				wisp:GetData().TemporaryWisp = true
			end
		end
	end
	return true
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.GardenTrowel, enums.Items.GardenTrowel)
---HeartTransplant
function mod:HeartTransplant(_, _, player, useFlag)
	local data = player:GetData()
	data.eclipsed.HeartTransplantUseCount = data.eclipsed.HeartTransplantUseCount or 0
	if data.eclipsed.HeartTransplantUseCount < #datatables.HeartTransplant.ChainValue then
		data.eclipsed.HeartTransplantUseCount = data.eclipsed.HeartTransplantUseCount + 1
		---ChallengeBeatmaker
		if Isaac.GetChallenge() == enums.Challenges.Beatmaker then
			player:UseActiveItem(CollectibleType.COLLECTIBLE_TAMMYS_HEAD, datatables.NoAnimNoAnnounMimic)
		end
	else
		player:UseActiveItem(CollectibleType.COLLECTIBLE_TAMMYS_HEAD, datatables.NoAnimNoAnnounMimic)
	end
	data.eclipsed.HeartTransplantActualCharge = -15 * datatables.HeartTransplant.ChainValue[data.eclipsed.HeartTransplantUseCount][4]
	player:SetActiveCharge(data.eclipsed.HeartTransplantActualCharge, ActiveSlot.SLOT_PRIMARY)
	functions.HeartTranslpantFunc(player)
	sfx:Play(SoundEffect.SOUND_HEARTBEAT, 500)
	if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) and useFlag & UseFlag.USE_MIMIC == 0 then
		local wisp = player:AddWisp(enums.Items.HeartTransplant, player.Position)
		if wisp then -- if wisp was spawned
			wisp:GetData().TemporaryWisp = true
		end
	end
	return false
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.HeartTransplant, enums.Items.HeartTransplant)
---ElderSign
function mod:ElderSign(_, _, player)
	local pentagram = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HERETIC_PENTAGRAM, 0, player.Position, Vector.Zero, player):ToEffect()
	pentagram.SpriteScale = pentagram.SpriteScale * 60/100
	pentagram.Color = Color(0,1,0,1)
	pentagram:GetData().ElderSign = 20
    return true
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.ElderSign, enums.Items.ElderSign)
---CosmicJam
function mod:CosmicJam(_, _, player)
	local items = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)
	for _, item in pairs(items) do
		if item.SubType ~= 0 and not functions.CheckItemTags(item.SubType, ItemConfig.TAG_QUEST) then
			player:AddItemWisp(item.SubType, item.Position, true)
		end
	end
	sfx:Play(SoundEffect.SOUND_SOUL_PICKUP)
    return true
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.CosmicJam, enums.Items.CosmicJam)
---CharonObol
function mod:CharonObol(_, _, player, useFlag)
	if player:GetNumCoins() > 0 then
		player:AddCoins(-1)
		local soul = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HUNGRY_SOUL, 1, player.Position, Vector.Zero, player):ToEffect()
		soul:SetTimeout(360)
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) and useFlag & UseFlag.USE_MIMIC == 0 then
			player:AddWisp(CollectibleType.COLLECTIBLE_IV_BAG, player.Position, false, false)
		end
		return true
	end
    return false
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.CharonObol, enums.Items.CharonObol)
---VHSCassette
function mod:VHSCassette(_, rng, player)
	--local VHSTable = functions.CopyDatatable(datatables.tableVHS)
	local level = game:GetLevel()
	local stage = level:GetStage()
	local newStage = rng:RandomInt(#datatables.tableVHS)+1
	if level:IsAscent() or level:IsPreAscent() then
		newStage = 13
	elseif not game:IsGreedMode() and stage < 12 then
		if newStage <= stage then newStage = stage+1 end
		local randStageType = 1
		if newStage ~= 9 then randStageType = rng:RandomInt(#datatables.tableVHS[newStage])+1 end
		newStage = datatables.tableVHS[newStage][randStageType]
		--VHSTable
	end
	functions.useVHS(newStage)
	for _ = 1, datatables.countVHS do
		functions.Domino16Items(rng, player.Position)
	end
	return  {ShowAnim = true, Remove = true, Discharge = true}
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.VHSCassette, enums.Items.VHSCassette)
---RubikDice
function mod:RubikDice(item, rng, player)
	if item == enums.Items.RubikDice then
		player:UseActiveItem(CollectibleType.COLLECTIBLE_D6, datatables.NoAnimNoAnnounMimic)
		player:RemoveCollectible(item)
		local Newdice = datatables.RubikDice.ScrambledDicesList[rng:RandomInt(#datatables.RubikDice.ScrambledDicesList)+1]
		player:AddCollectible(Newdice)
		return true
	elseif datatables.RubikDice.ScrambledDices[item] then
		functions.RerollTMTRAINER(player)
		return true
	end
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.RubikDice)
---BlackBook
function mod:BlackBook(_, rng, player)
	local enemies = Isaac.FindInRadius(player.Position, 5000, EntityPartition.ENEMY)
	for _, enemy in pairs(enemies) do
		if enemy:ToNPC() and enemy:IsVulnerableEnemy() and enemy:IsActiveEnemy() then
			functions.BlackBookEffects(player, enemy:ToNPC(), rng)
		end
	end
    return false
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.BlackBook, enums.Items.BlackBook)
---BleedingGrimoire
function mod:BleedingGrimoire(_, _, player)
	local data = player:GetData()
	player:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
	data.eclipsed.BleedingGrimoire = true
	return true
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.BleedingGrimoire, enums.Items.BleedingGrimoire)
---LostMirror
function mod:LostMirror(_, _, player)
	local tempEffects = player:GetEffects()
	tempEffects:AddNullEffect(NullItemID.ID_LOST_CURSE, true)
	if player:HasTrinket(enums.Trinkets.LostFlower) then
		player:UseCard(Card.CARD_HOLY, datatables.NoAnimNoAnnounMimic)
	end
	return true
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.LostMirror, enums.Items.LostMirror)
---StrangeBox
function mod:StrangeBox(_, rng)
	local savedOptions = {}
	for _, pickup in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP)) do
		pickup = pickup:ToPickup()
		if pickup.OptionsPickupIndex == 0 then -- if pickup don't have option index
			pickup.OptionsPickupIndex = rng:RandomInt(Random())+1 -- get random number
		end
		if savedOptions[pickup.OptionsPickupIndex] == nil then
			savedOptions[pickup.OptionsPickupIndex] = true
			if pickup:IsShopItem() then
				local optionPickup = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_SHOPITEM, 0, Isaac.GetFreeNearPosition(pickup.Position, 20), Vector.Zero, nil)
				optionPickup:ToPickup().OptionsPickupIndex = pickup.OptionsPickupIndex -- spawn another collectible and set option index
			elseif pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE and pickup.SubType ~= 0 then -- if pickup is collectible item
				local optionPickup = Isaac.Spawn(pickup.Type, pickup.Variant, CollectibleType.COLLECTIBLE_NULL, Isaac.GetFreeNearPosition(pickup.Position, 20), Vector.Zero, nil)
				optionPickup:ToPickup().OptionsPickupIndex = pickup.OptionsPickupIndex -- spawn another collectible and set option index
			elseif not datatables.NotAllowedPickupVariants[pickup.Variant] then
				local optionPickup = Isaac.Spawn(EntityType.ENTITY_PICKUP, 0, 0, Isaac.GetFreeNearPosition(pickup.Position, 20), Vector.Zero, nil)
				optionPickup:ToPickup().OptionsPickupIndex = pickup.OptionsPickupIndex -- spawn another collectible and set option index
			end
		end
	end
	return true
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.StrangeBox, enums.Items.StrangeBox)
---MiniPony
function mod:MiniPony(_, _, player)
	player:UseActiveItem(CollectibleType.COLLECTIBLE_MY_LITTLE_UNICORN, datatables.NoAnimNoAnnounMimic)
	return false
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.MiniPony, enums.Items.MiniPony)
---KeeperMirror
function mod:KeeperMirror(item, _, player)
	local data = player:GetData()
	data.KeeperMirror = Isaac.Spawn(1000, enums.Effects.KeeperMirrorTarget, 0, player.Position, Vector.Zero, player):ToEffect()
	data.KeeperMirror.Parent = player
	data.KeeperMirror:SetTimeout(90)
	player:AnimateCollectible(item)
	return false
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.KeeperMirror, enums.Items.KeeperMirror)
---RedMirror
function mod:RedMirror(_, _, player)
	local nearest = 5000
	local trinkets = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET)
	if #trinkets > 0 then
		local pickups = trinkets[1]
		for _, trinket in pairs(trinkets) do
			if player.Position:Distance(trinket.Position) < nearest then
				pickups = trinket
				nearest = player.Position:Distance(trinket.Position)
			end
		end
		pickups:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_CRACKED_KEY)
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickups.Position, Vector.Zero, nil):SetColor(datatables.RedColor, -1, 1, false, false)
	end
	return true
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.RedMirror, enums.Items.RedMirror)
---BookMemory
function mod:BookMemory(_, _, player)
	local entities = Isaac.FindInRadius(player.Position, 5000, EntityPartition.ENEMY)
	local removed = false
	for _, enemy in pairs(entities) do
		if enemy:ToNPC() and not enemy:IsBoss() then
			mod.ModVars.BookMemoryErasedEntities = mod.ModVars.BookMemoryErasedEntities or {}
			mod.ModVars.BookMemoryErasedEntities[enemy.Type] = mod.ModVars.BookMemoryErasedEntities[enemy.Type] or {}
			if not mod.ModVars.BookMemoryErasedEntities[enemy.Type][enemy.Variant] then
				mod.ModVars.BookMemoryErasedEntities[enemy.Type][enemy.Variant] = true
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, enemy.Position, Vector.Zero, nil):SetColor(Color(0.5,1,2),-1,1, false, false)
				enemy:Remove()
				removed = true
			end
		end
	end
	if removed then
		player:AddBrokenHearts(1)
	end
	sfx:Play(SoundEffect.SOUND_DEVILROOM_DEAL)
	return true
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.BookMemory, enums.Items.BookMemory)
---AgonyBox
function mod:AgonyBox()
	return {ShowAnim = false, Remove = false, Discharge = false}
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.AgonyBox, enums.Items.AgonyBox)
---PandoraJar
function mod:PandoraJar(item, rng, player)
	local wisp
	if mod.ModVars.ForLevel.PandoraJarGift and mod.ModVars.ForLevel.PandoraJarGift == 1 then
		game:GetHUD():ShowItemText("Elpis!")
		player:UseActiveItem(CollectibleType.COLLECTIBLE_MYSTERY_GIFT, datatables.NoAnimNoAnnounMimic)
		wisp = player:AddWisp(CollectibleType.COLLECTIBLE_MYSTERY_GIFT, player.Position, true)
		mod.ModVars.ForLevel.PandoraJarGift = 2
		return {ShowAnim = true, Remove = true, Discharge = true}
	else
		wisp = player:AddWisp(item, player.Position, true)
	end
	if wisp then
		sfx:Play(SoundEffect.SOUND_CANDLE_LIGHT)
		if not player:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE) and not mod.ModVars.ForLevel.PandoraJarGift then
			local randNum = rng:RandomFloat()
			if randNum <= 0.33 then
				local PandoraCurses = functions.PandoraJarManager()
				if #PandoraCurses > 0 then
					local addCurse = PandoraCurses[rng:RandomInt(#PandoraCurses)+1]
					game:GetHUD():ShowItemText(enums.CurseText[addCurse])
					game:GetLevel():AddCurse(addCurse, false)
				else
					mod.ModVars.ForLevel.PandoraJarGift = 1
				end
			end
		end
	end
	return true
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.PandoraJar, enums.Items.PandoraJar)
---WitchPot
function mod:WitchPot(_, rng, player)
	local chance = rng:RandomFloat()
	local pocketTrinket = player:GetTrinket(0)
	local hudText = "Cantrip!"
	local sound = SoundEffect.SOUND_SLOTSPAWN
	local hastrinkets = {}
	for gulpedTrinket = 1, TrinketType.NUM_TRINKETS do
		if player:HasTrinket(gulpedTrinket) then
			table.insert(hastrinkets, gulpedTrinket)
		end
	end
	--if you have trinket
	--1% to remove trinket
	--90% to smelt
	--10% to spit out smelted trinket
	--if you don't have trinket
	--16% to spit out
	--84% to spawn new trinket
	if pocketTrinket > 0 then
		if chance <= 0.01 then
			functions.RemoveThrowTrinket(player, pocketTrinket)
			hudText = "Cantripped!"
		elseif chance <= 0.1 and #hastrinkets > 0 then
			local removeTrinket = hastrinkets[rng:RandomInt(#hastrinkets)+1]
			player:TryRemoveTrinket(removeTrinket)
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, removeTrinket, player.Position, RandomVector()*5, nil)
			hudText = "Spit out!"
			sound = SoundEffect.SOUND_ULTRA_GREED_SPIT
		else
			player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, datatables.NoAnimNoAnnounMimicNoCostume)
			hudText = "Gulp!"
			sound = SoundEffect.SOUND_VAMP_GULP
		--[[
		else
			local newTrinket = rng:RandomInt(TrinketType.NUM_TRINKETS)+1
			player:TryRemoveTrinket(pocketTrinket)
			player:AddTrinket(newTrinket, true)
			hudText = "Can trip?"
			sound = SoundEffect.SOUND_BIRD_FLAP
			--]]
		end
	elseif chance <= 0.16 and #hastrinkets > 0 then
		local removeTrinket = hastrinkets[rng:RandomInt(#hastrinkets)+1]
		player:TryRemoveTrinket(removeTrinket)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, removeTrinket, player.Position, RandomVector()*5, nil)
		hudText = "Spit out!"
		sound = SoundEffect.SOUND_ULTRA_GREED_SPIT
	end
	if hudText == "Cantrip!" then
		player:UseActiveItem(CollectibleType.COLLECTIBLE_MOMS_BOX, datatables.NoAnimNoAnnounMimicNoCostume)
	end
	game:GetHUD():ShowItemText(hudText)
	sfx:Play(sound)
	return true
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.WitchPot, enums.Items.WitchPot)
---WhiteKnight
function mod:WhiteKnight(_, _, player)
	local discharge = false
	if not player:HasCollectible(CollectibleType.COLLECTIBLE_DOGMA) and not player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_MEGA_MUSH) then
		local data = player:GetData()
		local sprite = player:GetSprite()
		if datatables.IgnoreAnimations[sprite:GetAnimation()] then
			data.eclipsed.ForRoom.Jumped = true
			player:PlayExtraAnimation("TeleportUp")
			player:SetMinDamageCooldown(120)
			discharge = true
		end
	end
	return {ShowAnim = false, Remove = false, Discharge = discharge}
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.WhiteKnight, enums.Items.WhiteKnight)
---BlackKnight
function mod:BlackKnight(_, _, player)
	local discharge = false
	if not player:HasCollectible(CollectibleType.COLLECTIBLE_DOGMA) and not player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_MEGA_MUSH) then
		local data = player:GetData()
		local sprite = player:GetSprite()
		if data.eclipsed.ForRoom.KnightTarget and datatables.IgnoreAnimations[sprite:GetAnimation()] and data.eclipsed.ForRoom.KnightTarget:GetSprite():IsPlaying("Blink") then
			data.eclipsed.ForRoom.Jumped = true
			player:PlayExtraAnimation("TeleportUp")
			player:SetMinDamageCooldown(120)
			discharge = true
		end
	end
	return {ShowAnim = false, Remove = false, Discharge = discharge}
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.BlackKnight, enums.Items.BlackKnight)

---CARD USE--

---MemoryFragment
function mod:onBookMemoryCard(card, player, useFlag)
	if useFlag & UseFlag.USE_MIMIC == 0 then
		local data = player:GetData()
		data.eclipsed.MemoryFragment = data.eclipsed.MemoryFragment or {}
		table.insert(data.eclipsed.MemoryFragment, {300, card})
	end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.onBookMemoryCard)
function mod:onBookMemoryPill(pillEffect, player, useFlag)
	if useFlag & UseFlag.USE_MIMIC == 0 then
		local data = player:GetData()
		data.eclipsed.MemoryFragment = data.eclipsed.MemoryFragment or {}
		for pillColor=1, PillColor.NUM_PILLS do
			if itemPool:GetPillEffect(pillColor) == pillEffect then
				table.insert(data.eclipsed.MemoryFragment, {70, pillColor})
				break
			elseif pillColor == PillColor.NUM_PILLS then
				table.insert(data.eclipsed.MemoryFragment, {70, PillColor.PILL_GOLD})
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_USE_PILL, mod.onBookMemoryPill)
---NadabAbihu2ofClubs
function mod:NadabAbihu2ofClubs(_, player)
	if player:GetPlayerType() == enums.Characters.Nadab or player:GetPlayerType() == enums.Characters.Abihu then
		player:AddBombs(-2)
		player:UseCard(Card.CARD_HEARTS_2, datatables.NoAnimNoAnnounMimic)
	end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.NadabAbihu2ofClubs, Card.CARD_CLUBS_2)
---NadabAbihuBombsAreKey
function mod:NadabAbihuBombsAreKey(_, player)
	if player:GetPlayerType() == enums.Characters.Nadab or player:GetPlayerType() == enums.Characters.Abihu then
		local player_keys = player:GetNumKeys()
		local player_hearts = player:GetHearts()
		player:AddHearts(player_keys-player_hearts)
        player:AddKeys(player_hearts-player_keys)
	end
end
mod:AddCallback(ModCallbacks.MC_USE_PILL, mod.NadabAbihuBombsAreKey, PillEffect.PILLEFFECT_BOMBS_ARE_KEYS)
---UnbiddenHolyCard
function mod:UnbiddenHolyCard(_, player)
	if player:GetPlayerType() == enums.Characters.UnbiddenB then
		local data = player:GetData()
		data.eclipsed.UnbiddenUsedHolyCard = data.eclipsed.UnbiddenUsedHolyCard or 0
		data.eclipsed.UnbiddenUsedHolyCard = data.eclipsed.UnbiddenUsedHolyCard + 1
	end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.UnbiddenHolyCard, Card.CARD_HOLY)
---UnbiddenSoulLost
function mod:UnbiddenSoulLost(_, player)
	if player:GetPlayerType() == enums.Characters.UnbiddenB then
		local data = player:GetData()
		data.eclipsed.UnbiddenUsedHolyCard = data.eclipsed.UnbiddenUsedHolyCard or 0
		data.eclipsed.UnbiddenUsedHolyCard = data.eclipsed.UnbiddenUsedHolyCard + 1
	end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.UnbiddenSoulLost, Card.CARD_SOUL_LOST)

---RedPill
function mod:RedPill(_, player)
	functions.RedPillManager(player, 10.8, 1)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.RedPill, enums.Pickups.RedPill)
---RedPillHorse
function mod:RedPillHorse(_, player)
	functions.RedPillManager(player, 21.6, 2)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.RedPillHorse, enums.Pickups.RedPillHorse)
---Apocalypse
function mod:Apocalypse()
	mod.ModVars.ForRoom.ApocalypseRoom = game:GetLevel():GetCurrentRoomIndex()
	game:GetRoom():SetCardAgainstHumanity()
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.Apocalypse, enums.Pickups.Apocalypse)
---BannedCard
function mod:BannedCard(card, player)
	for _ = 1, 2 do
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, card, player.Position, RandomVector()*3, nil)
	end
	game:GetHUD():ShowFortuneText("POT OF GREED ALLOWS ME","TO DRAW TWO MORE CARDS!")
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.BannedCard, enums.Pickups.BannedCard)
---SoulUnbidden
function mod:SoulUnbidden(_, player)
	if #Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.ITEM_WISP)> 0 then
		functions.AddItemFromWisp(player, false)
	else
		player:UseActiveItem(CollectibleType.COLLECTIBLE_LEMEGETON, datatables.NoAnimNoAnnounMimic)
	end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.SoulUnbidden, enums.Pickups.SoulUnbidden)
---SoulNadabAbihu
function mod:SoulNadabAbihu(_, player)
	local data = player:GetData()
	data.eclipsed.ForRoom.SoulNadabAbihu = true
	local tempEffects = player:GetEffects()
	tempEffects:AddCollectibleEffect(CollectibleType.COLLECTIBLE_FIRE_MIND)
	tempEffects:AddCollectibleEffect(CollectibleType.COLLECTIBLE_HOT_BOMBS)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.SoulNadabAbihu, enums.Pickups.SoulNadabAbihu)
---GhostGem
function mod:GhostGem(_, player)
	for _ = 1, 4 do
		local purgesoul = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PURGATORY, 1, player.Position, Vector.Zero, player):ToEffect()
		purgesoul:SetColor(Color(0.5,1,2), -1, 1, false, true)
		purgesoul:GetSprite():Play("Charge", true)
	end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.GhostGem, enums.Pickups.GhostGem)
---Trapezohedron
function mod:Trapezohedron()
	for _, pickups in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET)) do
		pickups:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_CRACKED_KEY)
		local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickups.Position, Vector.Zero, nil)
		effect:SetColor(datatables.RedColor, -1, 1, false, false)
	end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.Trapezohedron, enums.Pickups.Trapezohedron)
---KingChess
function mod:KingChess(_, player)
	functions.MyGridSpawn(player, 40, GridEntityType.GRID_POOP, 5, true)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.KingChess, enums.Pickups.KingChess)
---KingChessW
function mod:KingChessW(_, player)
	functions.SquareSpawn(player, 40, 0, EntityType.ENTITY_POOP, 11, 0)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.KingChessW, enums.Pickups.KingChessW)
---OblivionCard
function mod:OblivionCard(_, player)
	local vec = player:GetMovementVector()
	if vec:Length() == 0 then
		vec = player:GetLastDirection()
	end
	local tearCard = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.CHAOS_CARD, 0, player.Position, vec * 14, player):ToTear()
	local tearCardSprite = tearCard:GetSprite()
	tearCard:GetData().OblivionCard = true
	tearCardSprite:ReplaceSpritesheet(0, datatables.OblivionCard.SpritePath)
	tearCardSprite:LoadGraphics()
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.OblivionCard, enums.Pickups.OblivionCard)
---BattlefieldCard
function mod:BattlefieldCard(card, player)
	local rng = player:GetCardRNG(card)
	local data = player:GetData()
	data.UsedBattleFieldCard = true
	Isaac.ExecuteCommand("goto s.challenge." .. rng:RandomInt(8)+16) -- boss
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.BattlefieldCard, enums.Pickups.BattlefieldCard)
---TreasuryCard
function mod:TreasuryCard(card, player)
	local rng = player:GetCardRNG(card)
	Isaac.ExecuteCommand("goto s.treasure." .. rng:RandomInt(56))
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.TreasuryCard, enums.Pickups.TreasuryCard)
---BookeryCard
function mod:BookeryCard(card, player)
	local rng = player:GetCardRNG(card)
	Isaac.ExecuteCommand("goto s.library." .. rng:RandomInt(18))
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.BookeryCard, enums.Pickups.BookeryCard)
---BloodGroveCard
function mod:BloodGroveCard(card, player)
	local rng = player:GetCardRNG(card)
	local num = rng:RandomInt(10)+31 --voodoo head curse rooms
	Isaac.ExecuteCommand("goto s.curse." .. num)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.BloodGroveCard, enums.Pickups.BloodGroveCard)
---StormTempleCard
function mod:StormTempleCard(card, player)
	local rng = player:GetCardRNG(card)
	Isaac.ExecuteCommand("goto s.angel." .. rng:RandomInt(22))
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.StormTempleCard, enums.Pickups.StormTempleCard)
---ArsenalCard
function mod:ArsenalCard(card, player)
	local rng = player:GetCardRNG(card)
	Isaac.ExecuteCommand("goto s.chest." .. rng:RandomInt(49))
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.ArsenalCard, enums.Pickups.ArsenalCard)
---OutpostCard
function mod:OutpostCard(card, player)
	local rng = player:GetCardRNG(card)
	if rng:RandomFloat() > 0.5 then
		Isaac.ExecuteCommand("goto s.isaacs." .. rng:RandomInt(30))
	else
		Isaac.ExecuteCommand("goto s.barren." .. rng:RandomInt(29))
	end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.OutpostCard, enums.Pickups.OutpostCard)
---CryptCard
function mod:CryptCard(card, player)
	local data = player:GetData()
	local level = game:GetLevel()
	local roomDesc = level:GetCurrentRoomDesc()
	local rng = player:GetCardRNG(card)
	local num = rng:RandomInt(11)+2
	if roomDesc.Variant == 1 then
		num = 1
	elseif num == 13 then
		num = 0
	end
	data.eclipsed.ForRoom.CryptCard = true -- used to relocate player position, cause clip to error room
	Isaac.ExecuteCommand("goto s.itemdungeon." .. num)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.CryptCard, enums.Pickups.CryptCard)
---MazeMemoryCard
function mod:MazeMemoryCard(_, player, useFlag)
	if useFlag & UseFlag.USE_MIMIC == 0 then
		local level = game:GetLevel()
		if not player:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE) then
			level:AddCurse(LevelCurse.CURSE_OF_BLIND, false)
		end
		game:StartRoomTransition(level:GetCurrentRoomIndex(), 1, RoomTransitionAnim.DEATH_CERTIFICATE, player, -1)
		mod.ModVars.MazeMemory = {20, 18}
	end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.MazeMemoryCard, enums.Pickups.MazeMemoryCard)
---ZeroMilestoneCard
function mod:ZeroMilestoneCard()
	local pos = Isaac.GetFreeNearPosition(game:GetRoom():GetCenterPos(), 0)
	local pickup = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, enums.Items.BookMemory, pos, Vector.Zero, nil):ToPickup()
	pickup:GetData().ZeroMilestone = true
	mod.ModVars.ForLevel.ZeroMilestoneItems = mod.ModVars.ForLevel.ZeroMilestoneItems or {}
	local seedItem = tostring(pickup:GetDropRNG():GetSeed())
	mod.ModVars.ForLevel.ZeroMilestoneItems[seedItem] = true
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.ZeroMilestoneCard, enums.Pickups.ZeroMilestoneCard)
---CemeteryCard
function mod:CemeteryCard()
	mod.ModVars.ForRoom.CemeteryCard = true
	mod.ModVars.ForRoom.OpenDoors = true
	Isaac.ExecuteCommand("goto s.supersecret.6")
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.CemeteryCard, enums.Pickups.CemeteryCard)
---VillageCard
function mod:VillageCard(card, player)
	local rng = player:GetCardRNG(card)
	Isaac.ExecuteCommand("goto s.arcade." .. rng:RandomInt(52))
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.VillageCard, enums.Pickups.VillageCard)
---GroveCard
function mod:GroveCard(card, player)
	local rng = player:GetCardRNG(card)
	mod.ModVars.ForRoom.GroveCard = true
	Isaac.ExecuteCommand("goto s.challenge." .. rng:RandomInt(5))
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.GroveCard, enums.Pickups.GroveCard)
---WheatFieldsCard
function mod:WheatFieldsCard()
	mod.ModVars.ForRoom.WheatFieldsCard = true
	Isaac.ExecuteCommand("goto s.chest.31") --Nine random pickups.
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.WheatFieldsCard, enums.Pickups.WheatFieldsCard)
---SwampCard
function mod:SwampCard()
	mod.ModVars.ForRoom.OpenDoors = true
	mod.ModVars.ForRoom.SwampCard = true
	Isaac.ExecuteCommand("goto s.supersecret.23")
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.SwampCard, enums.Pickups.SwampCard)
---RuinsCard
function mod:RuinsCard(card, player)
	local rng = player:GetCardRNG(card)
	mod.ModVars.ForRoom.OpenDoors = true
	Isaac.ExecuteCommand("goto s.secret." .. rng:RandomInt(39))
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.RuinsCard, enums.Pickups.RuinsCard)
---SpiderCocoonCard
function mod:SpiderCocoonCard(card, player)
	--player:UseActiveItem(CollectibleType.COLLECTIBLE_SPIDER_BUTT, datatables.NoAnimNoAnnounMimic)
	--player:UseActiveItem(CollectibleType.COLLECTIBLE_BOX_OF_SPIDERS, datatables.NoAnimNoAnnounMimic)
	player:UsePill(PillEffect.PILLEFFECT_INFESTED_EXCLAMATION, 0, datatables.NoAnimNoAnnounMimic | UseFlag.USE_NOHUD)
	player:UsePill(PillEffect.PILLEFFECT_INFESTED_QUESTION, 0, datatables.NoAnimNoAnnounMimic | UseFlag.USE_NOHUD)
	player:AnimateCard(card)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.SpiderCocoonCard, enums.Pickups.SpiderCocoonCard)
---VampireMansionCard
function mod:VampireMansionCard()
	mod.ModVars.ForRoom.VampireMansion = true
	mod.ModVars.ForRoom.OpenDoors = true
	Isaac.ExecuteCommand("goto s.supersecret.6")
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.VampireMansionCard, enums.Pickups.VampireMansionCard)
---RoadLanternCard
function mod:RoadLanternCard(_, player)
	local itemwisp = player:AddItemWisp(CollectibleType.COLLECTIBLE_SPELUNKER_HAT, player.Position, true)
	if itemwisp then
		itemwisp.HitPoints = 1
	end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.RoadLanternCard, enums.Pickups.RoadLanternCard)
---SmithForgeCard
function mod:SmithForgeCard(_, player)
	player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, datatables.NoAnimNoAnnounMimic)
	Isaac.ExecuteCommand("goto s.chest.12")
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.SmithForgeCard, enums.Pickups.SmithForgeCard)
---ChronoCrystalsCard
function mod:ChronoCrystalsCard(_, player)
	local itemwisp = player:AddItemWisp(CollectibleType.COLLECTIBLE_BROKEN_MODEM, player.Position, true)
	if itemwisp then
		itemwisp.HitPoints = 1
	end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.ChronoCrystalsCard, enums.Pickups.ChronoCrystalsCard)
---WitchHut
function mod:WitchHut()
	mod.ModVars.ForRoom.OpenDoors = true
	Isaac.ExecuteCommand("goto s.supersecret.19")
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.WitchHut, enums.Pickups.WitchHut)
---BeaconCard
function mod:BeaconCard()
	Isaac.ExecuteCommand("goto s.shop.14")
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.BeaconCard, enums.Pickups.BeaconCard)
---TemporalBeaconCard
function mod:TemporalBeaconCard()
	Isaac.ExecuteCommand("goto s.shop.11")
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.TemporalBeaconCard, enums.Pickups.TemporalBeaconCard)
---AscenderBane
function mod:AscenderBane(card, player)
	if not player:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE) then
		local rng = player:GetCardRNG(card)
		local level = game:GetLevel()
		local ascenderCurseList = functions.PandoraJarManager()
		if #ascenderCurseList > 0 then
			local addCurse = ascenderCurseList[rng:RandomInt(#ascenderCurseList)+1]
			game:GetHUD():ShowFortuneText(enums.CurseText[addCurse])
			level:AddCurse(addCurse, false) --(shitty isaac modding)
		end
	end
	if player:GetBrokenHearts() > 0 then
		player:AddBrokenHearts(-1)
	end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.AscenderBane, enums.Pickups.AscenderBane)
---Wish
function mod:onWish(card, player, useFlag)
	if useFlag & UseFlag.USE_MIMIC == 0 then
		if player:GetCardRNG(card) > 0.5 then
			player:UseActiveItem(CollectibleType.COLLECTIBLE_MYSTERY_GIFT, datatables.NoAnimNoAnnounMimic)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.Wish, enums.Pickups.Wish)
---Offering
function mod:Offering(_, player)
	player:UseActiveItem(CollectibleType.COLLECTIBLE_SACRIFICIAL_ALTAR, datatables.NoAnimNoAnnounMimic)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.Offering, enums.Pickups.Offering)
---InfiniteBlades
function mod:InfiniteBlades(card, player)
	local rotationOffset = player:GetLastDirection()
	local newV = player:GetLastDirection()
	local rng = player:GetCardRNG(card)
	for _ = 1, 7 do
		local randX = rng:RandomInt(80) * (rng:RandomInt(3)-1)
		local randY = rng:RandomInt(80) * (rng:RandomInt(3)-1)
		local pos = Vector(player.Position.X + randX, player.Position.Y + randY)
		local knife = player:FireTear(pos, newV, false, true, false, nil, 3):ToTear()
		knife:AddTearFlags(TearFlags.TEAR_PIERCING | TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_ACCELERATE | TearFlags.TEAR_CONTINUUM)
		knife.Visible = false
		local knifeData = knife:GetData()
		knifeData.KnifeTear = true
		knifeData.InitAngle = rotationOffset
		local knifeSprite = knife:GetSprite()
		knifeSprite:ReplaceSpritesheet(0, datatables.InfiniteBlades.newSpritePath)
		knifeSprite:LoadGraphics()
	end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.InfiniteBlades, enums.Pickups.InfiniteBlades)
---Transmutation
function mod:Transmutation(_, player)
	player:UseCard(Card.CARD_ACE_OF_SPADES, datatables.NoAnimNoAnnounMimic)
	player:UseActiveItem(CollectibleType.COLLECTIBLE_D20, datatables.NoAnimNoAnnounMimic)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.Transmutation, enums.Pickups.Transmutation)
---RitualDagger
function mod:RitualDagger(_, player)
	local tempEffects = player:GetEffects()
	tempEffects:AddCollectibleEffect(CollectibleType.COLLECTIBLE_MOMS_KNIFE)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.RitualDagger, enums.Pickups.RitualDagger)
---Fusion
function mod:Fusion(_, player)
	player:UseActiveItem(CollectibleType.COLLECTIBLE_BLACK_HOLE, datatables.NoAnimNoAnnounMimic)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.Fusion, enums.Pickups.Fusion)
---DeuxEx
function mod:DeuxEx(_, player)
	local data = player:GetData()
	data.eclipsed.ForRoom.DeuxExLuck = data.eclipsed.ForRoom.DeuxExLuck or 0
	data.eclipsed.ForRoom.DeuxExLuck = data.eclipsed.ForRoom.DeuxExLuck + 100
	player:AddCacheFlags(CacheFlag.CACHE_LUCK)
	player:EvaluateItems()
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.DeuxEx, enums.Pickups.DeuxEx)
---Adrenaline
function mod:Adrenaline(_, player)
	local tempEffects = player:GetEffects()
	tempEffects:AddCollectibleEffect(CollectibleType.COLLECTIBLE_ADRENALINE)
	local redHearts = player:GetHearts()
	if player:GetBlackHearts() > 0 or player:GetBoneHearts() > 0 or player:GetSoulHearts() > 0 then
		functions.AdrenalineManager(player, redHearts, 0)
	elseif redHearts > 1 then
		functions.AdrenalineManager(player, redHearts, 2)
	end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.Adrenaline, enums.Pickups.Adrenaline)
---Decay
function mod:Decay(_, player)
	local redHearts = player:GetHearts()
	local data = player:GetData()
	if redHearts > 0 then
		player:AddHearts(-redHearts)
		player:AddRottenHearts(redHearts)
	end
	if not data.eclipsed.ForRoom.Decay then
		data.eclipsed.ForRoom.Decay = TrinketType.TRINKET_APPLE_OF_SODOM
		functions.TrinketAdd(player, data.eclipsed.ForRoom.Decay)
	end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.Decay, enums.Pickups.Decay)
---Corruption
function mod:Corruption(_, player)
	local data = player:GetData()
	data.eclipsed.ForRoom.Corruption = 10
	player:AddNullCostume(datatables.Corruption.CostumeHead)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.Corruption, enums.Pickups.Corruption)
---MultiCast
function mod:MultiCast(card, player)
	local rng = player:GetCardRNG(card)
	local item = player:GetActiveItem(0)
	local wispColor = false
	local wispTemporary = false
	local wispRemoveAll = false
	local wispImage = false
	local noCollision = false

	if Isaac.GetItemConfig():GetCollectible(item).ChargeType == ItemConfig.CHARGE_TIMED then
		wispTemporary = true
	end
	if item == enums.Items.CharonObol then
		item = CollectibleType.COLLECTIBLE_IV_BAG
	elseif item == enums.Items.CosmicJam then
		item = CollectibleType.COLLECTIBLE_LEMEGETON
	elseif item == enums.Items.SecretLoveLetter then
		item = CollectibleType.COLLECTIBLE_KIDNEY_BEAN
		wispColor = Color(1, 0.5, 0.5)
	elseif item == enums.Items.ElderSign then
		wispRemoveAll = item
	elseif item == enums.Items.BlackBook then
		wispColor = Color(0.15,0.15,0.15)
		wispImage = "gfx/familiar/wisps/card.png"
	elseif item == enums.Items.AgonyBox then
		item = CollectibleType.COLLECTIBLE_DULL_RAZOR
		wispColor = Color(0.5, 1, 0.5, 1)
		noCollision = true
	elseif datatables.ActiveItemWisps[item] then
		item = datatables.ActiveItemWisps[item]
		if item == enums.Items.BookMemory then
			wispColor =  Color(0.5,1,2)
		end
	end
	if item == CollectibleType.COLLECTIBLE_LEMEGETON then
		for _ = 1, 3 do
			player:UseActiveItem(item, datatables.NoAnimNoAnnounMimic)
		end
	elseif item == enums.Items.RedBook then
		for _ = 1, 3 do
			item = datatables.Pompom.WispsList[rng:RandomInt(#datatables.Pompom.WispsList)+1]
			player:AddWisp(item, player.Position)
		end
	else
		for _ = 1, 3 do
			local wisp = player:AddWisp(item, player.Position)
			if wisp then
				local wispData = wisp:GetData()
				if wispTemporary then
					wispData.TemporaryWisp = true
				end
				if wispRemoveAll then
					wispData.RemoveAll = wispRemoveAll
				end
				if wispColor then
					wisp.Color = wispColor
				end
				if wispImage then
					local sprite = wisp:GetSprite()
					sprite:ReplaceSpritesheet(0, wispImage)
					sprite:LoadGraphics()
				end
				if noCollision then
					wisp.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				end
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.MultiCast, enums.Pickups.MultiCast)

---DeliObjectCell
function mod:DeliObjectCell(card, player)
	local rng = player:GetCardRNG(card)
	functions.DeliObjectSave(player, rng)
	if mod.ModVars.SavedEnemies and #mod.ModVars.SavedEnemies > 0 then
		local pos = Isaac.GetFreeNearPosition(player.Position, 40)
		local enemy = mod.ModVars.SavedEnemies[rng:RandomInt(#mod.ModVars.SavedEnemies)+1]
		local npc = Isaac.Spawn(enemy[1], enemy[2], 0, pos, Vector.Zero, nil):ToNPC()
		npc:AddCharmed(EntityRef(player), -1)
	end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.DeliObjectCell, enums.Pickups.DeliObjectCell)
---DeliObjectBomb
function mod:DeliObjectBomb(card, player)
	local rng = player:GetCardRNG(card)
	functions.DeliObjectSave(player, rng)
	local bombVar = BombVariant.BOMB_NORMAL
	local randNum = rng:RandomInt(4)
	if rng:RandomFloat() < 0.1 then
		if randNum == 1 then
			bombVar = BombVariant.BOMB_SUPERTROLL
		elseif randNum == 2 then
			bombVar = BombVariant.BOMB_GOLDENTROLL
		else
			bombVar = BombVariant.BOMB_TROLL
		end
		Isaac.Spawn(EntityType.ENTITY_BOMB, bombVar, 0, player.Position, Vector.Zero, nil)
	else
		local bombFlags = TearFlags.TEAR_NORMAL
		for _ = 0, randNum do
			bombFlags = bombFlags | datatables.DeliObject.BombFlags[rng:RandomInt(#datatables.DeliObject.BombFlags)+1]
		end
		local bomb = Isaac.Spawn(EntityType.ENTITY_BOMB, BombVariant.BOMB_NORMAL, 0, player.Position, Vector.Zero, player):ToBomb()
		bomb:AddTearFlags(bombFlags)
	end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.DeliObjectBomb, enums.Pickups.DeliObjectBomb)
---DeliObjectKey
function mod:DeliObjectKey(card, player)
	local rng = player:GetCardRNG(card)
	functions.DeliObjectSave(player, rng)
	local room = game:GetRoom()
	local level = game:GetLevel()
	for _, pickup in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP)) do
		if datatables.ChestVariant[pickup.Variant] and pickup.SubType == ChestSubType.CHEST_CLOSED then
			pickup:ToPickup():TryOpenChest()
		end
	end
	for slot = 0, DoorSlot.NUM_DOOR_SLOTS do
		local door = room:GetDoor(slot)
		if door and door:IsLocked() then
			door:TryUnlock(player, true)
		elseif door == nil and room:IsDoorSlotAllowed(slot) then
			level:MakeRedRoomDoor(level:GetCurrentRoomIndex(), slot)
		end
	end
	sfx:Play(SoundEffect.SOUND_UNLOCK00)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.DeliObjectKey, enums.Pickups.DeliObjectKey)
---DeliObjectCard
function mod:DeliObjectCard(card, player)
	local rng = player:GetCardRNG(card)
	functions.DeliObjectSave(player, rng)
	local randCard = itemPool:GetCard(rng:GetSeed(), true, false, false)
	player:UseCard(randCard, UseFlag.USE_NOANIM | UseFlag.USE_MIMIC)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.DeliObjectCard, enums.Pickups.DeliObjectCard)
---DeliObjectPill
function mod:DeliObjectPill(card, player)
	local rng = player:GetCardRNG(card)
	functions.DeliObjectSave(player, rng)
	local randPill = rng:RandomInt(PillEffect.NUM_PILL_EFFECTS)
	player:UsePill(randPill, 0, UseFlag.USE_NOANIM | UseFlag.USE_MIMIC)
	player:AnimateCard(card)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.DeliObjectPill, enums.Pickups.DeliObjectPill)
---DeliObjectRune
function mod:DeliObjectRune(card, player)
	local rng = player:GetCardRNG(card)
	functions.DeliObjectSave(player, rng)
	local randCard = itemPool:GetCard(rng:GetSeed(), false, false, true)
	player:UseCard(randCard, UseFlag.USE_NOANIM | UseFlag.USE_MIMIC)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.DeliObjectRune, enums.Pickups.DeliObjectRune)
---DeliObjectHeart
function mod:DeliObjectHeart(card, player)
	local rng = player:GetCardRNG(card)
	functions.DeliObjectSave(player, rng)
	local randNum = rng:RandomInt(9)
	local sound = SoundEffect.SOUND_VAMP_GULP
	if randNum == 1 then
		player:AddHearts(2)
	elseif randNum == 2 then
		player:AddBlackHearts(2)
		sound = SoundEffect.SOUND_HOLY
	elseif randNum == 3 then
		player:AddBoneHearts(1)
		sound = SoundEffect.SOUND_BONE_HEART
	elseif randNum == 4 then
		player:AddBrokenHearts(1)
		sound = SoundEffect.SOUND_POISON_HURT
	elseif randNum == 5 then
		player:AddEternalHearts(1)
		sound = SoundEffect.SOUND_SUPERHOLY
	elseif randNum == 6 then
		player:AddMaxHearts(2)
		sound = SoundEffect.SOUND_1UP
	elseif randNum == 7 then
		player:AddRottenHearts(1)
		sound = SoundEffect.SOUND_ROTTEN_HEART
	elseif randNum == 8 then
		player:AddSoulHearts(2)
		sound = SoundEffect.SOUND_HOLY
	else
		player:AddGoldenHearts(1)
		sound = SoundEffect.SOUND_GOLD_HEART
	end
	sfx:Play(sound)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.DeliObjectHeart, enums.Pickups.DeliObjectHeart)
---DeliObjectCoin
function mod:DeliObjectCoin(card, player)
	local rng = player:GetCardRNG(card)
	functions.DeliObjectSave(player, rng)
	local randNum = rng:RandomInt(5)
	local num = 1
	local sound = SoundEffect.SOUND_PENNYPICKUP
	if randNum == 1 then
		num = 2
	elseif randNum == 2 then
		num = 5
		sound = SoundEffect.SOUND_NICKELPICKUP
	elseif randNum == 3 then
		num = 10
		sound = SoundEffect.SOUND_DIMEPICKUP
	elseif randNum == 4 then
		num = 1
		sound = SoundEffect.SOUND_LUCKYPICKUP
		player:DonateLuck (1)
	end
	player:AddCoins(num)
	sfx:Play(sound)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.DeliObjectCoin, enums.Pickups.DeliObjectCoin)
---DeliObjectBattery
function mod:DeliObjectBattery(card, player)
	local rng = player:GetCardRNG(card)
	functions.DeliObjectSave(player, rng)
	local charge = rng:RandomInt(12)+1
	for slot = 0, 3 do
		local activeItem = player:GetActiveItem(slot)
		if activeItem ~= 0 then
			charge = charge + player:GetActiveCharge(slot) + player:GetBatteryCharge(slot)
			player:SetActiveCharge(charge, slot)
		end
	end
	Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BATTERY, 0, Vector(player.Position.X, player.Position.Y-70), Vector.Zero, nil) --i'm too lazy to adjust right position with spritescale (и так сойдет!)
	sfx:Play(SoundEffect.SOUND_BATTERYCHARGE)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.DeliObjectBattery, enums.Pickups.DeliObjectBattery)

---Domino34
function mod:Domino34(card, player)
	local rng = player:GetCardRNG(card)
	game:RerollLevelCollectibles()
	game:RerollLevelPickups(rng:GetSeed())
	player:UseCard(Card.CARD_DICE_SHARD, datatables.NoAnimNoAnnounMimic)
	game:ShakeScreen(10)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.Domino34, enums.Pickups.Domino34)
---Domino00
function mod:Domino00(card, player)
	local rng = player:GetCardRNG(card)
	local pickups = Isaac.FindByType(EntityType.ENTITY_PICKUP)
	if rng:RandomFloat() < 0.5 then
		if #pickups > 0 then
			for _, pickup in pairs(pickups) do
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, nil)
				pickup:Remove()
			end
		end
		local enemies = Isaac.FindInRadius(player.Position, 5000, EntityPartition.ENEMY)
		if #enemies > 0 then
			for _, enemy in pairs(enemies) do
				if enemy:ToNPC() then
					enemy:Kill()
				end
			end
		end
	else
		if #pickups > 0 then
			for _, pickup in pairs(pickups) do
				if pickup.SubType ~= 0 then
					Isaac.Spawn(pickup.Type, pickup.Variant, pickup.SubType, Isaac.GetFreeNearPosition(pickup.Position, 40), Vector.Zero, nil)
				end
			end
		end
		player:UseActiveItem(CollectibleType.COLLECTIBLE_MEAT_CLEAVER, datatables.MyUseFlags_Gene)
	end
	game:ShakeScreen(10)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.Domino00, enums.Pickups.Domino00)
---Domino25
function mod:Domino25(_, player)
	local room = game:GetRoom()
	local data = player:GetData()
	data.eclipsed.Domino25 = 3
	room:RespawnEnemies()
	game:ShakeScreen(10)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.Domino25, enums.Pickups.Domino25)
---Domino16
function mod:Domino16(card, player)
	local rng = player:GetCardRNG(card)
	functions.Domino16Items(rng, player.Position)
	game:ShakeScreen(10)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.Domino16, enums.Pickups.Domino16)

---KittenBomb
function mod:KittenBomb(_, player)
	game:GetRoom():MamaMegaExplosion(player.Position)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.KittenBomb, enums.Pickups.KittenBomb)
---KittenBomb2
function mod:KittenBomb2(_, player)
	for _ = 1, 3 do
		local randPos = game:GetRoom():FindFreePickupSpawnPosition(player.Position)
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, randPos, Vector.Zero, nil)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_GIGA, randPos, Vector.Zero, player)
	end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.KittenBomb2, enums.Pickups.KittenBomb2)
---KittenDefuse
function mod:KittenDefuse()
	local trollbombs = Isaac.FindByType(EntityType.ENTITY_BOMB)
	for _, trollbomb in pairs(trollbombs) do
		if datatables.DefuseCardBombs[trollbomb.Variant] then
			local newBomb = datatables.DefuseCardBombs[trollbomb.Variant]
			trollbomb:Remove()
			Isaac.Spawn(newBomb[1], newBomb[2], newBomb[3], trollbomb.Position, trollbomb.Velocity, nil)
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, trollbomb.Position, Vector.Zero, nil)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.KittenDefuse, enums.Pickups.KittenDefuse)
---KittenDefuse2
function mod:KittenDefuse2(_, player)
	player:UseActiveItem(CollectibleType.COLLECTIBLE_TELEKINESIS, datatables.NoAnimNoAnnounMimic)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.KittenDefuse2, enums.Pickups.KittenDefuse2)
---KittenFuture
function mod:KittenFuture(_, player)
	player:UseActiveItem(CollectibleType.COLLECTIBLE_TELEPORT_2, datatables.NoAnimNoAnnounMimic)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.KittenFuture, enums.Pickups.KittenFuture)
---KittenFuture2
function mod:KittenFuture2(_, player)
	if not player:HasCollectible(CollectibleType.COLLECTIBLE_ANKH) then
		player:AddCollectible(CollectibleType.COLLECTIBLE_ANKH)
	end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.KittenFuture2, enums.Pickups.KittenFuture2)
---KittenNope
function mod:KittenNope(_, player)
	player:UseActiveItem(CollectibleType.COLLECTIBLE_PAUSE, datatables.NoAnimNoAnnounMimic)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.KittenNope, enums.Pickups.KittenNope)
---KittenNope2
function mod:KittenNope2(_, player)
	local tempEffects = player:GetEffects()
	tempEffects:AddCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE, true, 1)
	if player:GetPlayerType() == enums.Characters.UnbiddenB then
		local data = player:GetData()
		data.eclipsed.UnbiddenUsedHolyCard = data.eclipsed.UnbiddenUsedHolyCard or 0
		data.eclipsed.UnbiddenUsedHolyCard = data.eclipsed.UnbiddenUsedHolyCard + 1
	end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.KittenNope2, enums.Pickups.KittenNope2)
---KittenSkip
function mod:KittenSkip()
	local room = game:GetRoom()
	if room:GetType() ~= RoomType.ROOM_BOSS and not room:IsClear() then
		for slot = 0, DoorSlot.NUM_DOOR_SLOTS do
			local door = room:GetDoor(slot)
			if door then
				door:Open()
			end
		end
		mod.ModVars.ForRoom.NoRewards = true
	end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.KittenSkip, enums.Pickups.KittenSkip)
---KittenSkip2
function mod:KittenSkip2(_, player)
	local data = player:GetData()
	data.eclipsed.ForRoom.KittenSkip2 = true
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.KittenSkip2, enums.Pickups.KittenSkip2)
---KittenFavor
function mod:KittenFavor(_, player)
	player:UseActiveItem(enums.Items.StrangeBox, datatables.NoAnimNoAnnounMimic)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.KittenFavor, enums.Pickups.KittenFavor)
---KittenFavor2
function mod:KittenFavor2(_, player)
	for _ = 1, 4 do
		player:UseCard(Card.CARD_SOUL_ISAAC, datatables.NoAnimNoAnnounMimic)
	end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.KittenFavor2, enums.Pickups.KittenFavor2)
---KittenShuffle
function mod:KittenShuffle(_, player)
	player:AddCollectible(CollectibleType.COLLECTIBLE_TMTRAINER)
	player:UseActiveItem(CollectibleType.COLLECTIBLE_D6, datatables.NoAnimNoAnnounMimic)
	player:RemoveCollectible(CollectibleType.COLLECTIBLE_TMTRAINER)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.KittenShuffle, enums.Pickups.KittenShuffle)
---KittenShuffle2
function mod:KittenShuffle2(_, player)
	player:AddCollectible(CollectibleType.COLLECTIBLE_MISSING_NO)
	player:RemoveCollectible(CollectibleType.COLLECTIBLE_MISSING_NO)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.KittenShuffle2, enums.Pickups.KittenShuffle2)
---KittenAttack
function mod:KittenAttack(_, player)
	player:UseActiveItem(CollectibleType.COLLECTIBLE_SHOOP_DA_WHOOP, datatables.NoAnimNoAnnounMimic)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.KittenAttack, enums.Pickups.KittenAttack)
---KittenAttack2
function mod:KittenAttack2(_, player)
	player:UseActiveItem(CollectibleType.COLLECTIBLE_LARYNX, datatables.NoAnimNoAnnounMimic | UseFlag.USE_CUSTOMVARDATA, -1, 6)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.KittenAttack2, enums.Pickups.KittenAttack2)



--- WIP
---bomb gagger
--[[

--enums.Items.Gagger = Isaac.GetItemIdByName("Little Gagger")
datatables.Gagger = {}
datatables.Gagger.Variant = Isaac.GetEntityVariantByName("lilGagger") -- spawn giga bomb every 7 room
datatables.Gagger.GenAfterRoom = 7

--Gagger
function EclipsedMod:onGaggerInit(fam)
	fam:GetSprite():Play("FloatDown")
	fam:AddToFollowers()
end
EclipsedMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, EclipsedMod.onGaggerInit, datatables.Gagger.Variant)
--Gagger loop update
function EclipsedMod:onGaggerUpdate(fam)
	local player = fam.Player -- get player
	local famData = fam:GetData() -- get fam data
	local famSprite = fam:GetSprite()
	functions.CheckForParent(fam)
	fam:FollowParent()

	if fam.RoomClearCount >= datatables.Gagger.GenAfterRoom then
		fam.RoomClearCount = 0
		famSprite:Play("Spawn")
	end

	if famSprite:IsFinished("Spawn") then
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_GIGA, fam.Position, Vector.Zero, fam)
		famSprite:Play("AfterSpawn")
	end

	if famSprite:IsFinished("AfterSpawn") then
		famSprite:Play("FloatDown") --"AfterSpawn"
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, EclipsedMod.onGaggerUpdate, datatables.Gagger.Variant)

function EclipsedMod:onCache3(player, cacheFlag)
	player = player:ToPlayer()
	-- bombgagger
	if cacheFlag == CacheFlag.CACHE_FAMILIARS then
		local gaggers = functions.GetItemsCount(player, enums.Items.Gagger)
		player:CheckFamiliar(datatables.Gagger.Variant, gaggers, RNG(), Isaac.GetItemConfig():GetCollectible(enums.Items.Gagger))
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, EclipsedMod.onCache3)
--]]
---wax hearts
--[[
datatables.WaxHearts = {}
datatables.WaxHearts.SubType = 5757 -- wax heart subtype from entities2.xml
datatables.WaxHearts.Range = 90
datatables.WaxHearts.ReplaceChance = 0.05 -- chance to replace full and soul hearts
datatables.WaxHearts.HeartsUI = Sprite()
datatables.WaxHearts.HeartsUI:Load("gfx/ui/oc_ui_hearts.anm2", true)

function EclipsedMod:onPlayerTakeDamage(entity, _, flags) --entity, amount, flags, source, countdown
	--- wax hearts damage logic
	local player = entity:ToPlayer()
	local data = player:GetData()

	if data.WaxHeartsCount then
		if data.WaxHeartsCount > 0 then
			if (flags & DamageFlag.DAMAGE_FIRE ~= 0) or (flags & DamageFlag.DAMAGE_EXPLOSION ~= 0) then
				return false
			else
				data.WaxHeartsCount = data.WaxHeartsCount - 1
				local enemies = Isaac.FindInRadius(player.Position, datatables.WaxHearts.Range, EntityPartition.ENEMY)
				if #enemies > 0 then
					for _, enemy in pairs(enemies) do
						if enemy:IsVulnerableEnemy() and enemy:IsActiveEnemy() then
							enemy:AddFreeze(EntityRef(player), datatables.MeltedCandle.FrameCount) --has a chance to not apply (bosses for example), that's why must check it
							if enemy:HasEntityFlags(EntityFlag.FLAG_FREEZE) then
								enemy:AddEntityFlags(EntityFlag.FLAG_BURN)
								enemy:GetData().Waxed = datatables.MeltedCandle.FrameCount
								enemy:SetColor(datatables.MeltedCandle.TearColor, datatables.MeltedCandle.FrameCount, 100, false, false)
							end
						end
					end
				end
			end
		else
			data.WaxHeartsCount = nil
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, EclipsedMod.onPlayerTakeDamage, EntityType.ENTITY_PLAYER)

function EclipsedMod:onPostWaxHeartInit(pickup)
	local rng = pickup:GetDropRNG()
	if pickup.SubType == HeartSubType.HEART_FULL or pickup.SubType == HeartSubType.HEART_SOUL then
		if rng:RandomFloat() <= datatables.WaxHearts.ReplaceChance then
			pickup:Morph(pickup.Type, pickup.Variant, datatables.WaxHearts.SubType)
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, EclipsedMod.onPostWaxHeartInit, PickupVariant.PICKUP_HEART)

function EclipsedMod:onWaxHeartCollision(pickup, collider) --pickup, collider, low
	if pickup.SubType == datatables.WaxHearts.SubType and collider:ToPlayer() then
		local player = collider:ToPlayer()
		local data = player:GetData()
		data.WaxHeartsCount = data.WaxHeartsCount or 0
		if data.WaxHeartsCount < 12 then
			pickup:GetSprite():Play("Collect", true)
			pickup:Die()
			data.WaxHeartsCount = data.WaxHeartsCount + 1
			sfx:Play(SoundEffect.SOUND_SOUL_PICKUP)
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, EclipsedMod.onWaxHeartCollision, PickupVariant.PICKUP_HEART)

function EclipsedMod:onRenderWaxHeart() --pickup, collider, low
	--for playerNum = 0, game:GetNumPlayers()-1 do
	--local player = Isaac.GetPlayer(playerNum)
	local player = Isaac.GetPlayer(0)
	local data = player:GetData()
	local level = game:GetLevel()
	if level:GetCurses() & LevelCurse.CURSE_OF_THE_UNKNOWN == 0 and data.WaxHeartsCount and data.WaxHeartsCount > 0 then
		--local pos = Vector(Isaac.GetScreenWidth(),Isaac.GetScreenHeight()) - Vector(10, 12) - (Options.HUDOffset*Vector(16, 6))
		local pos = Vector.Zero + Vector(68, 23) + (Options.HUDOffset*Vector(16, 6))
		--Vector(68, 23)
		datatables.WaxHearts.HeartsUI:Play(data.WaxHeartsCount, true)
		datatables.WaxHearts.HeartsUI:Render(pos)
		datatables.WaxHearts.HeartsUI:Update()
	end
	--end
end
EclipsedMod:AddCallback(ModCallbacks.MC_POST_RENDER, EclipsedMod.onRenderWaxHeart)
--]]
---Glitch Beggar
--[[
enums.Slots.GlitchBeggar = Isaac.GetEntityVariantByName("Glitch Beggar")
datatables.GlitchBeggar = {}
datatables.GlitchBeggar.ReplaceChance = 0.01
datatables.GlitchBeggar.PityCounter = 10
datatables.GlitchBeggar.ActivateChance = 0.05
datatables.GlitchBeggar.PickupRotateTimeout = 300

datatables.GlitchBeggar.RandomPickup = {
	"Idle", --IdleCoin
	"IdleBomb",
	"IdleKey",
	"IdleHeart"
}
datatables.GlitchBeggar.RandomPickupCheck = {
	["Idle"] = true, --IdleCoin
	["IdleBomb"] = true,
	["IdleKey"] = true,
	["IdleHeart"] = true
}
local function GlitchBeggarState(beggarData, sprite, rng)
	sfx:Play(SoundEffect.SOUND_SCAMPER)
	if beggarData.PityCounter >= datatables.GlitchBeggar.PityCounter or rng:RandomFloat() < datatables.GlitchBeggar.ActivateChance then
		sprite:Play("PayPrize")
	else
		sprite:Play("PayNothing")
		beggarData.PityCounter = beggarData.PityCounter + 1
	end
end
--]]

---//////////////////////////////////////////////////////////
print('[Eclipsed v.2.0] Type `eclipsed` or `eclipsed help`')