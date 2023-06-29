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
	--functions.ResetModVars()
	functions.ResetPlayerData(player)
	local holdingCard = player:GetCard(0)
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
			game:GetPlayer(0):UseActiveItem(CollectibleType.COLLECTIBLE_D12, datatables.NoAnimNoAnnounMimic)
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
		---BleedingGrimoire
		if data.eclipsed.BleedingGrimoire then
			if player:HasEntityFlags(EntityFlag.FLAG_BLEED_OUT) then
				--player:AddNullCostume(datatables.BG.Costume)
				player:AddCostume(Isaac.GetItemConfig():GetCollectible(enums.Items.BleedingGrimoire), true)
			else
				data.eclipsed.BleedingGrimoire = nil

			end
		end


		data.eclipsed.ForRoom = {}
		---StoneScripture
		if room:IsFirstVisit() and player:HasCollectible(enums.Items.StoneScripture) then
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
	local room = game:GetRoom()
	functions.ResetModVars()
	--mod.ModVars.ModdedBombas = {}

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

---NPC INIT--
function mod:onEnemyInit(enemy)
	if mod.ModVars then
		if mod.ModVars.ForLevel then
			---OblivionCard
			if mod.ModVars.ForLevel.ErasedEntities and #mod.ModVars.ForLevel.ErasedEntities >0 then
				for _, entity in ipairs(mod.ModVars.ForLevel.ErasedEntities) do
					if enemy.Type == entity[1] and enemy.Variant == entity[2] then
						Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, enemy.Position, Vector.Zero, nil):SetColor(Color(0.5,1,2),50,1, false, false)
						enemy:Remove()
						break
					end
				end
			end
		end
		---BookMemory
		if mod.ModVars.BookMemoryErasedEntities and mod.ModVars.BookMemoryErasedEntities[enemy.Type] and mod.ModVars.BookMemoryErasedEntities[enemy.Type][enemy.Variant] then
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, enemy.Position, Vector.Zero, nil):SetColor(Color(0.5,1,2),50,1, false, false)
			enemy:Remove()
			break
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
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, enemy.Position, Vector.Zero, nil):SetColor(Color(2,0,0.7),50,1, false, false)
			enemy:AddCharmed(EntityRef(mod.ModVars.SecretLoveLetterAffectedEnemies[3]), -1)
		end
	end
	if enemyData.Bleeding then
		enemyData.Bleeding = enemyData.Bleeding -1
		if enemyData.Bleeding == 0 then
			enemy:ClearEntityFlags(EntityFlag.FLAG_BLEED_OUT)
		elseif enemyData.Bleeding <= -30 then
			enemyData.Bleeding = nil
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, mod.onUpdateNPC)
function mod:onHuntersJournalChargers(charger)
	if charger:HasMortalDamage() then
		local data = charger:GetData()
		if data.BlackHoleCharger then
			data.BlackHoleCharger = nil
			local hole = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLACK_HOLE, 0, charger.Position, Vector.Zero, nil)
			hole:GetSprite():Play("Death", true)
			hole:GetSprite():SetLastFrame()
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, mod.onHuntersJournalChargers, EntityType.ENTITY_CHARGER)
--- NPC DEVOLVE --
function mod:onDevolve(entity)
	---Domino25
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
	local tearData = tear:GetData()
	local tearSprite = tear:GetSprite()
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
	tear = tear:ToTear()
	if tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer() then
		local player = tear.SpawnerEntity:ToPlayer()
		local data = player:GetData()
		local enemy = collider:ToNPC()

		if data.eclipsed.BleedingGrimoire then
			enemy:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
			enemy:GetData().Bleeding = 62
		end
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, mod.onTearCollision)
---CHAOS CARD TEAR COLLISION--
function mod:onLoveLetterCollision(tear, collider)
	tear = tear:ToTear()
	local tearData = tear:GetData()
	if not collider:ToNPC() then return end
	local player = tear.SpawnerEntity:ToPlayer()
	local enemy = collider:ToNPC()
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
					Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, entity.Position, Vector.Zero, nil):SetColor(Color(2,0,0.7),50,1, false, false)
					entity:AddCharmed(EntityRef(player), -1) -- makes the effect permanent and the enemy will follow you even to different rooms.
				end
			end
		else
			enemy:AddCharmed(EntityRef(player), 150)
		end
		return true
	elseif tearData.OblivionCard then
		tear:Remove()
		mod.ModVars.ForLevel.ErasedEntities = mod.ModVars.ForLevel.ErasedEntities or {}
		table.insert(mod.ModVars.ForLevel.ErasedEntities, {enemy.Type, enemy.Variant})
		for _, entity in pairs(Isaac.FindInRadius(player.Position, 5000, EntityPartition.ENEMY)) do
			if entity.Type == enemy.Type and entity.Variant == enemy.Variant then
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, entity.Position, Vector.Zero, nil):SetColor(Color(0.5,1,2), 50,1, false, false)
				entity:Remove()
			end
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
---PICKUP INIT--
function mod:onPostPickupInit(pickup)
	local rng = pickup:GetDropRNG()
	for playerNum = 0, game:GetNumPlayers()-1 do
		local player = game:GetPlayer(playerNum):ToPlayer()
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
				if rng:RandomFloat() < mod.ModVars.TurnGoldChance then
					functions.TurnPickupsGold(pickup:ToPickup())
					break
				end
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, mod.onPostPickupInit)
---COLLECTIBLE UPDATE--
function mod:CollectibleUpdate(pickup)
	if pickup.SubType == 0 then return end
	---ChallengePotatoes
	if Isaac.GetChallenge() == enums.Challenges.Potatoes then
		local yourOnlyFood = enums.Items.Potato
		if pickup.SubType ~= yourOnlyFood then
			pickup:ToPickup():Morph(pickup.Type, pickup.Variant, yourOnlyFood)
		end
	else
		local pickupData = pickup:GetData()
		local pool = itemPool:GetPoolForRoom(game:GetRoom():GetType(), game:GetSeeds():GetStartSeed())
		if pool == ItemPoolType.POOL_NULL then pool = ItemPoolType.POOL_TREASURE end
		---ZeroMilestoneCard
		if pickupData.ZeroMilestone and pickup.FrameCount%4 == 0 then
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
			for playerNum = 0, game:GetNumPlayers()-1 do
				local player = game:GetPlayer(playerNum):ToPlayer()
				if player:HasTrinket(enums.Trinkets.Cybercutlet) and functions.GetCurrentDimension() ~= 2 and functions.CheckItemTags(pickup.SubType, ItemConfig.TAG_FOOD) then
					if not pickupData.Cybercutleted then
						local newItem = itemPool:GetCollectible(pool, false, pickup.InitSeed)
						pickup:ToPickup():Morph(pickup.Type, pickup.Variant, newItem)
						pickupData.Cybercutleted = true
					end
				end
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, mod.CollectibleUpdate, PickupVariant.PICKUP_COLLECTIBLE)
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
---ELDER SIGN PENTAGRAM--
function mod:onElderSignPentagramEffect(pentagram)
	if pentagram:GetData().ElderSign and pentagram.SpawnerEntity then
		if pentagram.FrameCount == pentagram:GetData().ElderSign then
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PURGATORY, 1, pentagram.Position, Vector.Zero, nil):SetColor(Color(0.2,0.5,0.2), 500, 1, false, false)
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

---ACTIVE ITEM--
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
		functions.SoulExplosion(player)
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
function mod:RedBook(_, rng, player)
	local red = rng:RandomInt(#datatables.RedBag.RedPickups)+1
	Isaac.Spawn(EntityType.ENTITY_PICKUP, datatables.RedBag.RedPickups[red][1], datatables.RedBag.RedPickups[red][2], Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, player)
	if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
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
function mod:GardenTrowel(item, _, player)
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
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) and spur then
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
function mod:HeartTransplant(_, _, player)
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
	if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
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
function mod:CharonObol(_, _, player)
	if player:GetNumCoins() > 0 then
		player:AddCoins(-1)
		local soul = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HUNGRY_SOUL, 1, player.Position, Vector.Zero, player):ToEffect()
		soul:SetTimeout(360)
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
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
function mod:RubikDice(item, rng, player, useFlag)
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
	if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
		local wisp = player:AddWisp(CollectibleType.COLLECTIBLE_UNDEFINED, player.Position, false, false)
		if wisp then
			wisp = wisp:ToFamiliar()
			wisp.Color = Color(0.15,0.15,0.15,1)
			local sprite = wisp:GetSprite()
			sprite:ReplaceSpritesheet(0, "gfx/familiar/wisps/card.png")
			sprite:LoadGraphics()
		end
	end
    return false
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.BlackBook, enums.Items.BlackBook)
---BleedingGrimoire
function mod:BleedingGrimoire(_, _, player)
	local data = player:GetData()
	player:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
	--player:AddNullCostume(datatables.BG.Costume)
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
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickups.Position, Vector.Zero, nil):SetColor(datatables.RedColor, 50, 1, false, false)
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
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, enemy.Position, Vector.Zero, nil):SetColor(Color(0.5,1,2),50,1, false, false)
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



---WitchPot
function mod:WitchPot(_, rng, player)
	local chance = rng:RandomFloat()
	local pocketTrinket = player:GetTrinket(0)
	local pocketTrinket2 = player:GetTrinket(1)
	local hudText = "Cantrip!"
	local sound = SoundEffect.SOUND_SLOTSPAWN
	local hastrinkets = {}
	for gulpedTrinket = 1, TrinketType.NUM_TRINKETS do
		if player:HasTrinket(gulpedTrinket) then
			table.insert(hastrinkets, gulpedTrinket)
		end
	end
	if pocketTrinket > 0 then
		if chance <= 0.01 then
			functions.RemoveThrowTrinket(player, pocketTrinket)
			hudText = "Cantripped!"
		elseif chance <= 0.8 then
			player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, datatables.NoAnimNoAnnounMimicNoCostume)
			hudText = "Gulp!"
			sound = SoundEffect.SOUND_VAMP_GULP
		elseif chance <= 0.9 and #hastrinkets > 0 then
			local removeTrinket = hastrinkets[rng:RandomInt(#hastrinkets)+1]
			player:TryRemoveTrinket(removeTrinket)
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, removeTrinket, player.Position, RandomVector()*5, nil)
			hudText = "Spit out!"
			sound = SoundEffect.SOUND_ULTRA_GREED_SPIT
		else
			local newTrinket = rng:RandomInt(TrinketType.NUM_TRINKETS)+1
			player:TryRemoveTrinket(pocketTrinket)
			player:AddTrinket(newTrinket, true)
			hudText = "Can trip?"
			sound = SoundEffect.SOUND_BIRD_FLAP
		end
	elseif chance <= 0.33 then
		if #hastrinkets > 0 then
			local removeTrinket = hastrinkets[rng:RandomInt(#hastrinkets)+1]
			player:TryRemoveTrinket(removeTrinket)
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, removeTrinket, player.Position, RandomVector()*5, nil)
			hudText = "Spit out!"
			sound = SoundEffect.SOUND_ULTRA_GREED_SPIT
		end
	end
	if hudText == "Cantrip!" then
		player:UseActiveItem(CollectibleType.COLLECTIBLE_MOMS_BOX, datatables.NoAnimNoAnnounMimicNoCostume)
	end
	game:GetHUD():ShowItemText(hudText)
	sfx:Play(sound)
	return true
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.WitchPot, enums.Items.WitchPot)
--[[
---WhiteKnight
function mod:WhiteKnight(_, _, player)
	local discharge = false
	if not player:HasCollectible(CollectibleType.COLLECTIBLE_DOGMA) and not player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_MEGA_MUSH) then
		local data = player:GetData()
		local sprite = player:GetSprite()
		-- if animation is right tp to nearest enemy/door
		if datatables.BlackKnight.IgnoreAnimations[sprite:GetAnimation()] then
			data.Jumped = true
			player:PlayExtraAnimation("TeleportUp")
			player:SetMinDamageCooldown(datatables.BlackKnight.InvFrames) -- invincibility frames
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
		if data.KnightTarget and data.KnightTarget:Exists() then
			if datatables.BlackKnight.IgnoreAnimations[sprite:GetAnimation()] then
				if data.KnightTarget:GetSprite():IsPlaying("Blink") then
					--player:PlayExtraAnimation("BigJumpUp")
					data.Jumped = true
					player:PlayExtraAnimation("TeleportUp")
					player:SetMinDamageCooldown(datatables.BlackKnight.InvFrames) -- invincibility frames
					discharge = true
				end
			end
		end
	end
	return {ShowAnim = false, Remove = false, Discharge = discharge}
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.BlackKnight, enums.Items.BlackKnight)
--]]

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
		purgesoul:SetColor(Color(0.5,1,2), 500, 1, false, true)
		purgesoul:GetSprite():Play("Charge", true)
	end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.GhostGem, enums.Pickups.GhostGem)
---Trapezohedron
function mod:Trapezohedron()
	for _, pickups in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET)) do
		pickups:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_CRACKED_KEY)
		local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickups.Position, Vector.Zero, nil)
		effect:SetColor(datatables.RedColor, 50, 1, false, false)
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
	player:UseActiveItem(CollectibleType.COLLECTIBLE_SPIDER_BUTT, datatables.NoAnimNoAnnounMimic)
	player:UseActiveItem(CollectibleType.COLLECTIBLE_BOX_OF_SPIDERS, datatables.NoAnimNoAnnounMimic)
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
function mod:onWish(_, player, useFlag)
	if useFlag & UseFlag.USE_MIMIC == 0 then
		player:UseActiveItem(CollectibleType.COLLECTIBLE_MYSTERY_GIFT, datatables.NoAnimNoAnnounMimic)
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
function mod:MultiCast(_, player)
	--[[
	local activeItem = player:GetActiveItem(0)
	local wispColor = false
	local timedRemove = false
	local tempWisp = false
	local replaceCoreImage = false
	local noCollision = false

	if activeItem ~= 0 then
		--if activeItem == CollectibleType.COLLECTIBLE_EDENS_SOUL or activeItem == CollectibleType.COLLECTIBLE_MYSTERY_GIFT then
		--	activeItem = CollectibleType.COLLECTIBLE_FRIEND_FINDER
		if activeItem == enums.Items.FloppyDisk or activeItem == enums.Items.FloppyDiskFull or activeItem == enums.Items.VHSCassette then
			activeItem = CollectibleType.COLLECTIBLE_EDENS_SOUL -- COLLECTIBLE_FRIEND_FINDER random wisps
		elseif activeItem == enums.Items.RedMirror then
			activeItem = CollectibleType.COLLECTIBLE_RED_KEY
		elseif activeItem == enums.Items.BlackKnight or activeItem == enums.Items.WhiteKnight then
			activeItem = CollectibleType.COLLECTIBLE_PONY
			tempWisp = true
		elseif activeItem == enums.Items.MiniPony then
			activeItem = CollectibleType.COLLECTIBLE_MY_LITTLE_UNICORN
		elseif activeItem == enums.Items.LostMirror then
			activeItem = CollectibleType.COLLECTIBLE_GLASS_CANNON
		elseif activeItem == enums.Items.BlackBook then
			activeItem = CollectibleType.COLLECTIBLE_UNDEFINED
			wispColor = Color(0.15,0.15,0.15,1)
			replaceCoreImage = "gfx/familiar/wisps/card.png"
		elseif activeItem == enums.Items.RubikDice or datatables.RubikDice.ScrambledDices[activeItem] then
			activeItem = CollectibleType.COLLECTIBLE_UNDEFINED
		--elseif activeItem == enums.Items.VHSCassette then
		--	activeItem = CollectibleType.COLLECTIBLE_FRIEND_FINDER
		elseif activeItem == enums.Items.LongElk then
			activeItem = CollectibleType.COLLECTIBLE_NECRONOMICON
		elseif activeItem == enums.Items.CharonObol then
			activeItem = CollectibleType.COLLECTIBLE_IV_BAG
		elseif activeItem == enums.Items.BookMemory then
			activeItem = CollectibleType.COLLECTIBLE_ERASER
			wispColor =  Color(0.5,1,2,1,0,0,0)
		elseif activeItem == enums.Items.Threshold then
			activeItem = 1
		elseif activeItem == enums.Items.CosmicJam then
			activeItem = CollectibleType.COLLECTIBLE_LEMEGETON
		elseif activeItem == enums.Items.ElderSign then
			activeItem = CollectibleType.COLLECTIBLE_PAUSE
			timedRemove = true
		elseif activeItem == enums.Items.WitchPot then
			activeItem = CollectibleType.COLLECTIBLE_FORTUNE_COOKIE
		elseif activeItem == enums.Items.SecretLoveLetter then
			activeItem = CollectibleType.COLLECTIBLE_KIDNEY_BEAN
			wispColor = Color(1, 0.5, 0.5, 1)
		elseif activeItem == enums.Items.AgonyBox then
			activeItem = CollectibleType.COLLECTIBLE_DULL_RAZOR
			wispColor = Color(0.5, 1, 0.5, 1)
			noCollision = true
		--elseif activeItem == enums.Items.GardenTrowel then
		--	activeItem = CollectibleType.COLLECTIBLE_WE_NEED_TO_GO_DEEPER
		elseif activeItem == enums.Items.CosmicEncyclopedia then
			activeItem = CollectibleType.COLLECTIBLE_UNDEFINED
		end
	end

	--if activeItem == 0 then activeItem = 1 end
	if activeItem == CollectibleType.COLLECTIBLE_LEMEGETON then
		for _=1, datatables.MultiCast.NumWisps do
			player:UseActiveItem(activeItem, datatables.MyUseFlags_Gene)
		end
	elseif activeItem == enums.Items.RedBook then
		local rng = player:GetCollectibleRNG(activeItem)
		for _=1, datatables.MultiCast.NumWisps do
			activeItem = datatables.Pompom.WispsList[rng:RandomInt(#datatables.Pompom.WispsList)+1]
			player:AddWisp(activeItem, player.Position)
		end
	else
		for _=1, datatables.MultiCast.NumWisps do
			local wisp = player:AddWisp(activeItem, player.Position)
			if wisp then
				if timedRemove then
					wisp:GetData().RemoveAll = activeItem
				elseif tempWisp then
					wisp:GetData().TemporaryWisp = true
				end
				if wispColor then
					wisp.Color = wispColor
				end
				if replaceCoreImage then
					local sprite = wisp:GetSprite()
					sprite:ReplaceSpritesheet(0, replace_gfx)
					sprite:LoadGraphics()
				end
				if noCollision then
					wisp.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				end
			end
		end
	end
	--]]
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
		if datatables.ChestVariant[pickup.Varinat] and pickup.SubType == ChestSubType.CHEST_CLOSED then
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
