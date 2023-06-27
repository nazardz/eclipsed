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
local modRNG = RNG()

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

--[[
---LUAMOD--
function mod:onLuamod(myMod)
	if myMod.Name == "Eclipsed" and Isaac.GetPlayer() ~= nil then
        local savetable = {}
		savetable.PersistentData = mod.PersistentData
		savetable.ModVars = mod.ModVars
		savetable.eclipsed = {}
		savetable.HiddenItemWisps = hiddenItemManager:GetSaveData()
		for playerNum = 0, game:GetNumPlayers()-1 do
			local player = game:GetPlayer(playerNum)
			local data = player:GetData()
			local idx = functions.GetPlayerIndex(player)
			savetable.eclipsed[idx] = data.eclipsed
		end
		mod:SaveData(json.encode(savetable))
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_MOD_UNLOAD, mod.onLuamod)
--]]

---GAME EXIT--
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

---GAME START--
function mod:onStart(isSave)	
	--if isSave then  -- reset blind Abihu and UnbiddenB
	modRNG:SetSeed(game:GetSeeds():GetStartSeed(), RECOMMENDED_SHIFT_IDX)
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
					if player:HasCollectible(enums.Items.Lililith) and data.eclipsed.LililithFams then
						for _, demonFam in pairs(data.eclipsed.LililithFams) do
							tempEffects:AddCollectibleEffect(demonFam)
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

---EVAL CACHE--
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

			functions.CheckFamiliar(player, enums.Items.AbihuFam, enums.Familiars.AbihuFam, 2)
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
	---SpikedCollar
	if player:HasCollectible(enums.Items.SpikedCollar) and flags & DamageFlag.DAMAGE_FAKE == 0 and flags & DamageFlag.DAMAGE_INVINCIBLE == 0 then
		player:UseActiveItem(CollectibleType.COLLECTIBLE_RAZOR_BLADE, datatables.NoAnimNoAnnounMimicNoCostume)
		return false
	end
	---MongoCells
	if player:HasCollectible(enums.Items.MongoCells) and flags & DamageFlag.DAMAGE_NO_PENALTIES == 0 then
		local rng = player:GetCollectibleRNG(enums.Items.MongoCells)
		if player:HasCollectible(CollectibleType.COLLECTIBLE_DRY_BABY) and rng:RandomFloat() < 0.33 then
			player:UseActiveItem(CollectibleType.COLLECTIBLE_NECRONOMICON, datatables.NoAnimNoAnnounMimicNoCostume)
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
			player:UseActiveItem(CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS, datatables.NoAnimNoAnnounMimicNoCostume)
		end
		---CharonObol
		if player:HasCollectible(enums.Items.CharonObol) then
			player:RemoveCollectible(enums.Items.CharonObol)
		end
		---ExtraLives
		if player:GetExtraLives() < 1 then
			---AbyssCart
			if player:HasTrinket(enums.Trinkets.AbyssCart) then
				for _, elems in pairs(datatables.AbyssCart.SacrificeBabies) do
					if player:HasCollectible(elems[1]) then
						player:RemoveCollectible(elems[1])
						player:AddCollectible(CollectibleType.COLLECTIBLE_1UP)
						local numTrinket = player:GetTrinketMultiplier(enums.Trinkets.AbyssCart)-1
						local rngTrinket = player:GetTrinketRNG(enums.Trinkets.AbyssCart)
						if rngTrinket:RandomFloat() > numTrinket * 0.5 then
							functions.RemoveThrowTrinket(player, enums.Trinkets.LostFlower)
						end
						break
					end
				end
			end
			---Limb
			if player:HasCollectible(enums.Items.Limb) and not data.eclipsed.LimbActive then
				mod.ModVars.LimbActive = true
				data.eclipsed.LimbActive = true
				player:UseCard(Card.CARD_SOUL_LAZARUS, datatables.NoAnimNoAnnounMimicNoCostume)
				player:UseCard(Card.CARD_SOUL_LOST, datatables.NoAnimNoAnnounMimicNoCostume)
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
	--functions.ResetModVars()
	functions.ResetPlayerData(player)
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
	---RETURN
	if player:HasCurseMistEffect() then return end
	if player:IsCoopGhost() then return end
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
	----TeaFungus
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
			player:UseActiveItem(CollectibleType.COLLECTIBLE_FLUSH, datatables.NoAnimNoAnnounMimicNoCostume)
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



	---MongoCells
	--code
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.onPEffectUpdate)

---POST UPDATE--
function mod:onUpdate()
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
	if mod.ModVars.LimbActive then
		game:Darken(1, 1)
	end
	--[[
	---players
	for playerNum = 0, game:GetNumPlayers()-1 do
		local player = game:GetPlayer(playerNum):ToPlayer()
		local data = player:GetData()

		if player:IsDead() then
			---AbyssCart
			if player:HasTrinket(enums.Trinkets.AbyssCart) and player:GetExtraLives() <= 0 then
				for _, elems in pairs(datatables.AbyssCart.SacrificeBabies) do
					if player:HasCollectible(elems[1]) then
						player:RemoveCollectible(elems[1])
						player:AddCollectible(CollectibleType.COLLECTIBLE_1UP)
						local numTrinket = player:GetTrinketMultiplier(enums.Trinkets.AbyssCart)-1
						local rngTrinket = player:GetTrinketRNG(enums.Trinkets.AbyssCart)
						if rngTrinket:RandomFloat() > numTrinket * 0.5 then
							functions.RemoveThrowTrinket(player, enums.Trinkets.LostFlower)
						end
						break
					end
				end
			end
		end
	end
	--]]
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
			if modRNG:RandomFloat() < datatables.CurseChance then
				newCurse = table.remove(curseTable, modRNG:RandomInt(#curseTable)+1)
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
	mod.ModVars.EnvyCurseIndex = mod.ModVars.EnvyCurseIndex or Random()+1
	---TUnbidden
	if player:GetPlayerType() == enums.Characters.UnbiddenB then
		if not (player:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE) or player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)) then
			local cc_curse = table.remove(curseTable, modRNG:RandomInt(#curseTable)+1)
			newCurse = newCurse | cc_curse
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
		if room:GetType() ~= RoomType.ROOM_BOSS then
			return true
		end
	end
	---RedButton
	functions.RemoveRedButton(room)
	---players
	for playerNum = 0, game:GetNumPlayers()-1 do
		local player = game:GetPlayer(playerNum)
		local playerType = player:GetPlayerType()
		local data = player:GetData()
		local tempEffects = player:GetEffects()
		---TUnbidden
		if playerType == enums.Characters.UnbiddenB then
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
	mod.ModVars.PreRoomState = room:IsClear()
	mod.ModVars.ForRoom = {}
	---RETURN
	if room:HasCurseMist() then return end
	---CurseFool
	if currentCurses & enums.Curses.Fool > 0 and roomType == RoomType.ROOM_DEFAULT and not room:IsFirstVisit() then
		if modRNG:RandomFloat() < 0.16 then
			room:RespawnEnemies()
			for slot = 0, DoorSlot.NUM_DOOR_SLOTS do
				local door = room:GetDoor(slot)
				if door and datatables.CurseSecretRooms[door.TargetRoomType] then
					door:Open()
				end
			end
			room:SetClear(true)
			mod.ModVars.ForRoom.NoRewards = true
		end
	end
	---CurseVoid
	if currentCurses & enums.Curses.Void > 0 and not room:IsClear() then
		if modRNG:RandomFloat() < datatables.VoidThreshold then
			mod.ModVars.VoidCurseReroll = true
			game:ShowHallucination(0, BackdropType.NUM_BACKDROPS)
			game:GetPlayer(0):UseActiveItem(CollectibleType.COLLECTIBLE_D12, datatables.NoAnimNoAnnounMimicNoCostume)
		end
	end
	---CurseWarden
	if currentCurses & enums.Curses.Warden > 0 and roomType ~= RoomType.ROOM_BOSS then
		for slot = 0, DoorSlot.NUM_DOOR_SLOTS do
			local door = room:GetDoor(slot)
			if door and door:GetVariant() == DoorVariant.DOOR_LOCKED then
				local pos = room:GetDoorSlotPosition(slot)
				room:RemoveDoor(slot)
				Isaac.GridSpawn(GridEntityType.GRID_DOOR, DoorVariant.DOOR_LOCKED_DOUBLE, pos, true)
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
		local tempEffects = player:GetEffects()
		---RESET
		functions.ResetPlayerData(player)
		---Lililith
		if data.eclipsed.LililithFams then
			for _, demonFam in pairs(data.eclipsed.LililithFams) do
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
		---LoopCards
		if data.eclipsed.ForRoom.OpenDoors then
			player:UseCard(Card.CARD_GET_OUT_OF_JAIL, datatables.NoAnimNoAnnounMimicNoCostume)
			sfx:Stop(SoundEffect.SOUND_GOLDENKEY)
		end

		data.eclipsed.ForRoom = {}
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.onNewRoom)

---NEW LEVEL--
function mod:onNewLevel()
	local level = game:GetLevel()
	local room = game:GetRoom()
	functions.ResetModVars()
	--mod.ModVars.ModdedBombas = {}
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
			for slot = 0, 2 do -- 0, 3
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
		if player:GetPlayerType() == enums.Characters.Unbidden then
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
		if data.eclipsed.LimbActive then
			data.eclipsed.LimbActive = nil
			if tempEffects:HasNullEffect(NullItemID.ID_LOST_CURSE) then
				tempEffects:RemoveNullEffect(NullItemID.ID_LOST_CURSE, 2)
			end
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
		---Lililith
		data.eclipsed.LililithFams = {}
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.onNewLevel)

---NPC UPDATE--
function mod:onUpdateNPC(enemy)
	enemy = enemy:ToNPC()
	--local enemyData = enemy:GetData()
	if enemy.FrameCount <= 1 and mod.ModVars and mod.ModVars.SecretLoveLetterAffectedEnemies and #mod.ModVars.SecretLoveLetterAffectedEnemies > 0 then
		if enemy.Type == mod.ModVars.SecretLoveLetterAffectedEnemies[1] and enemy.Variant == mod.ModVars.SecretLoveLetterAffectedEnemies[2] then
			sfx:Play(SoundEffect.SOUND_KISS_LIPS1)
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, enemy.Position, Vector.Zero, nil):SetColor(Color(2,0,0.7),50,1, false, false)
			enemy:AddCharmed(EntityRef(mod.ModVars.SecretLoveLetterAffectedEnemies[3]), -1)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, mod.onUpdateNPC)

--- NPC DEVOLVE --
function mod:onDevolve(entity)
	if entity:GetData().NoDevolve then -- entity:HasMortalDamage()
		entity:GetData().NoDevolve = nil
		return true
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_DEVOLVE, mod.onDevolve)

---TEARS UPDATE--
function mod:onTearUpdate(tear)
	if not tear.SpawnerEntity then return end
	if not tear.SpawnerEntity:ToPlayer() then return end
	local player = tear.SpawnerEntity:ToPlayer()
	local data = player:GetData()


	---KittenSkip2
	if data.eclipsed.ForRoom.KittenSkip2 then
		tear:AddTearFlags(TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_PIERCING)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, mod.onTearUpdate)
---SECRET LOVE LETTER TEAR COLLISION--
function mod:onLoveLetterCollision(tear, collider)
	tear = tear:ToTear()
	local tearData = tear:GetData()
	if tearData.SecretLoveLetter then
		if collider:ToNPC() and collider:IsActiveEnemy() and collider:IsVulnerableEnemy() and not collider:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
			tear:Remove()
			local player = tear.SpawnerEntity:ToPlayer()
			local enemy = collider:ToNPC()
			sfx:Play(SoundEffect.SOUND_KISS_LIPS1)
			if not enemy:IsBoss() and not datatables.SecretLoveLetter.BannedEnemies[enemy.Type] then
				functions.ResetModVars()
				mod.ModVars.SecretLoveLetterAffectedEnemies = mod.ModVars.SecretLoveLetterAffectedEnemies or {}
				mod.ModVars.SecretLoveLetterAffectedEnemies[1] = enemy.Type
				mod.ModVars.SecretLoveLetterAffectedEnemies[2] = enemy.Variant
				mod.ModVars.SecretLoveLetterAffectedEnemies[3] = player
				for _, entity in pairs(Isaac.FindInRadius(player.Position, 5000, EntityPartition.ENEMY)) do
					if entity.Type == enemy.Type and entity.Variant == enemy.Variant then
						Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, entity.Position, Vector.Zero, nil):SetColor(Color(2,0,0.7),50,1, false, false)
						entity:AddCharmed(EntityRef(player), -1) -- makes the effect permanent and the enemy will follow you even to different rooms.
					end
				end
			else
				enemy:AddCharmed(EntityRef(player), 150)
			end
			return true
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, mod.onLoveLetterCollision, TearVariant.CHAOS_CARD)

---Lililith INIT--
function mod:onLililithInit(fam)
	fam:GetSprite():Play("FloatDown")
	fam:AddToFollowers()
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, mod.onLililithInit, datatables.Lililith.Variant)
---Lililith UPDATE--
function mod:onLililithUpdate(fam)
	local player = fam.Player
	local data = player:GetData()
	local tempEffects = player:GetEffects()
	local famSprite = fam:GetSprite()
	local rng = fam:GetDropRNG()
	--functions.CheckForParent(fam)
	fam:FollowParent()
	if famSprite:IsFinished("Spawn") then
		local demon = datatables.LililithDemonSpawn[rng:RandomInt(#datatables.LililithDemonSpawn)+1]
		tempEffects:AddCollectibleEffect(demon)
		table.insert(data.eclipsed.LililithFams, demon)
		famSprite:Play("FloatDown")
	end
	if fam.RoomClearCount == 7 and rng:RandomFloat() > 0.5 then
		fam.RoomClearCount = 0
		famSprite:Play("Spawn")
	elseif fam.RoomClearCount >= 8 then
		fam.RoomClearCount = 0
		famSprite:Play("Spawn")
	end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, mod.onLililithUpdate, datatables.Lililith.Variant)



---TRINKET UPDATE--
function mod:onTrinketUpdate(trinket)
	local dataTrinket = trinket:GetData()
	if dataTrinket.RemoveThrowTrinket then
		trinket.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		trinket.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, mod.onTrinketUpdate, PickupVariant.PICKUP_TRINKET)
---CARD COLLISION--
function mod:onCardsCollision(pickup, collider)
	if collider:ToPlayer() then
		local player = collider:ToPlayer()
		local data = player:GetData()
		if player:HasCurseMistEffect() then return end
		if player:IsCoopGhost() then return end
		if player:HasCollectible(enums.Items.NirlyCodex, true) then
			local cardType = Isaac.GetItemConfig():GetCard(pickup.SubType).CardType
			data.eclipsed.NirlySavedCards = data.eclipsed.NirlySavedCards or {}
			if datatables.CardTypes[cardType] and #data.eclipsed.NirlySavedCards < 5 then
				table.insert(data.eclipsed.NirlySavedCards, pickup.SubType)
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, nil):SetColor(Color(1,0,1),50,1, false, false)
				pickup:Remove()
				return false
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, mod.onCardsCollision, PickupVariant.PICKUP_TAROTCARD)

---MOONLIGHTER TARGET--
function mod:onKeeperMirrorTargetEffect(target)
	local player = target.Parent:ToPlayer()
	target.DepthOffset = -100
	if not target.GridCollisionClass == EntityGridCollisionClass.GRIDCOLL_WALLS then
		target.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
	end
	target.Velocity = player:GetShootingInput() * player.ShotSpeed * 0.7
	if target.Velocity.X == 0 and target.Velocity.Y == 0 then
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
					Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, nil):SetColor(Color(0,1.5,1.3), 50, 1, false, false)
					sfx:Play(SoundEffect.SOUND_CASH_REGISTER)
					target:Remove()
					return
				end
			end
		end
	end
	if target.Timeout <= 1 then
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, target.Position, Vector.Zero, nil)
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, target.Position, Vector.Zero, nil):SetColor(Color(0,1.5,1.3), 50, 1, false, false)
		sfx:Play(SoundEffect.SOUND_CASH_REGISTER)
		target:Remove()
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.onKeeperMirrorTargetEffect, enums.Effects.KeeperMirrorTarget)

---PILL INIT--
function mod:onPostPillInit(pickup)
	for playerNum = 0, game:GetNumPlayers()-1 do
		local player = game:GetPlayer(playerNum)
		if not player:HasCurseMistEffect() and not player:IsCoopGhost() then
			if player:HasTrinket(enums.Trinkets.Duotine) then
				local newSub = enums.Pickups.RedPill
				if pickup.SubType >= PillColor.PILL_GIANT_FLAG then newSub = enums.Pickups.RedPillHorse end
				pickup:Morph(5, 300, newSub, true, false, true)
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, mod.onPostPillInit, PickupVariant.PICKUP_PILL)
---GET CARD--
function mod:onGetCard(_, card) --, playingCards, includeRunes, onlyRunes)
	if card == enums.Pickups.RedPill or card == enums.Pickups.RedPillHorse then
		return enums.Pickups.DeliObjectCell
	end
end
mod:AddCallback(ModCallbacks.MC_GET_CARD, mod.onGetCard)


---RENDER--
function mod:onUnbiddenTextRender() --pickup, collider, low
	local player = Isaac.GetPlayer(0)
	local data = player:GetData()
	---CurseIcons
	functions.CurseIconRender()
	---TUnbidden
	if player:GetPlayerType() == enums.Characters.UnbiddenB then
		--
	end
	---players
	for playerNum = 0, game:GetNumPlayers()-1 do
		player = game:GetPlayer(playerNum)
		data = player:GetData()
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
			datatables.TextFont:DrawString("x" .. data.eclipsed.ForRoom.Corruption, 3 + Options.HUDOffset * 24 , 22 + Options.HUDOffset *10, KColor(1 ,0 ,1 ,1), 0, true)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.PostRender)

---ACTIVE ITEM--
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
---RedPill
function mod:RedPill(_, player) -- card, player, useflag
	functions.RedPillManager(player, 10.8, 1)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.RedPill, enums.Pickups.RedPill)
---RedPillHorse
function mod:RedPillHorse(_, player) -- card, player, useflag
	functions.RedPillManager(player, 21.6, 2)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.RedPillHorse, enums.Pickups.RedPillHorse)
------Apocalypse
function mod:Apocalypse()
	mod.ModVars.ForRoom.ApocalypseRoom = game:GetLevel():GetCurrentRoomIndex()
	game:GetRoom():SetCardAgainstHumanity()
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.Apocalypse, enums.Pickups.Apocalypse)

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

---WitchHut
function mod:WitchHut(_, player, _) -- card, player, useflag
	local data = player:GetData()
	data.eclipsed.ForRoom.OpenDoors = true
	Isaac.ExecuteCommand("goto s.supersecret.19") -- 9 random pills
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

---Decay
function mod:Decay(_, player) -- card, player, useflag
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

---Domino25
function mod:Domino25(_, player)
	local room = game:GetRoom()
	local data = player:GetData()
	data.eclipsed.Domino25 = 3
	room:RespawnEnemies()
	game:ShakeScreen(10)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.Domino25, enums.Pickups.Domino25)

---KittenSkip
function mod:KittenSkip()
	local room = game:GetRoom()
	if room:GetType() ~= RoomType.ROOM_BOSS and not room:IsClear() then
		for gridIndex = 1, room:GetGridSize() do -- get room size
			local grid = room:GetGridEntity(gridIndex)
			if grid and grid:ToDoor() then
				grid:ToDoor():Open()
			end
		end
		mod.ModVars.ForRoom.NoRewards = true
	end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.KittenSkip, enums.Pickups.KittenSkip)
---KittenSkip2
function EclipsedMod:KittenSkip2(_, player) -- card, player, useflag
	local data = player:GetData()
	data.eclipsed.ForRoom.KittenSkip2 = true
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.KittenSkip2, enums.Pickups.KittenSkip2)
---KittenShuffle2
function mod:onKittenShuffle2(_, player)
	player:AddCollectible(CollectibleType.COLLECTIBLE_MISSING_NO)
	--local data = player:GetData()
	--data.eclipsed.KittenShuffle2 = 1
	player:RemoveCollectible(CollectibleType.COLLECTIBLE_MISSING_NO)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.onKittenShuffle2, enums.Pickups.KittenShuffle2)