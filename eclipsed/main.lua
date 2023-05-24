EclipsedMod = RegisterMod("Eclipsed", 1)
local json = require("json")
local enums = require("scripts_eclipsed.enums")
local functions = require("scripts_eclipsed.functions")
local datatables = require("scripts_eclipsed.datatables")

local game = Game()
local itemPool = game:GetItemPool()
local sfx = SFXManager()
local RECOMMENDED_SHIFT_IDX = 35
local myrng = RNG()
local UnbiddenHourglassIcon = Sprite()
local glowing_icon = Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS).GfxFileName
UnbiddenHourglassIcon:Load("gfx/005.100_Collectible.anm2", true)
UnbiddenHourglassIcon:ReplaceSpritesheet(1, glowing_icon)
UnbiddenHourglassIcon:LoadGraphics()
UnbiddenHourglassIcon.Scale = Vector(0.8, 0.8)
UnbiddenHourglassIcon:SetFrame("Idle", 8)
local UnbiddenHourglassFont = Font()
UnbiddenHourglassFont:Load("font/pftempestasevencondensed.fnt")
local NirlyCardsFont = Font()
NirlyCardsFont:Load("font/pftempestasevencondensed.fnt")
local StoneFont = Font()
StoneFont:Load("font/pftempestasevencondensed.fnt")

--- GAME EXIT --
function EclipsedMod:onExit(isContinue)
	if isContinue then
		local savetable = functions.modDataLoad()
		savetable.OblivionCardErasedEntities = datatables.OblivionCardErasedEntities
		savetable.LobotomyErasedEntities = datatables.LobotomyErasedEntities
		savetable.MidasCurseTurnGoldChance = datatables.MidasCurse.TurnGoldChance
		savetable.SecretLoveLetterAffectedEnemies = datatables.SecretLoveLetterAffectedEnemies
		savetable.DeliriumBeggarData = {}
		savetable.DeliriumBeggarData.Enemies = datatables.DeliriumBeggarEnemies
		savetable.DeliriumBeggarData.Enable = datatables.DeliriumBeggarEnable
		savetable.PandoraJarGift = datatables.PandoraJarGift
		savetable.ModdedBombas = datatables.ModdedBombas
		savetable.TetrisItems = datatables.TetrisItems
		savetable.ZeroMilestoneItems = datatables.ZeroMilestoneItems
		savetable.SurrogateConceptionFams = datatables.SurrogateConceptionFams
		savetable.UnbiddenResetGameChance = {}
		savetable.DemonSpawn = {} -- datatables.Lililith.DemonSpawn
		savetable.MidasCurseActive = {}
		savetable.DuckCurrentLuck = {}
		savetable.RedPillDamageUp = {}
		savetable.UsedBG = {}
		savetable.LimbActive = {}
		savetable.StateDamaged = {}
		savetable.RedLotusDamage = {}
		savetable.KarmaStats = {}
		savetable.MemoryFragment = {}
		savetable.NirlySavedCards = {}
		savetable.LostWoodenCross = {}

		
		--savetable.WaxHeartsCount = {}

		for playerNum = 0, game:GetNumPlayers()-1 do
			local player = game:GetPlayer(playerNum)
			local data = player:GetData()
			local idx = functions.getPlayerIndex(player)
			
			if data.UnbiddenResetGameChance then
				savetable.UnbiddenResetGameChance[idx] = {data.UnbiddenResetGameChance, data.LevelRewindCounter }
			end
			
			if data.LililithDemonSpawn then
				savetable.DemonSpawn[idx] = data.LililithDemonSpawn
			end
			if player:HasCollectible(enums.Items.MidasCurse) then
				savetable.MidasCurseActive[idx] = data.GoldenHeartsAmount
			end
			if player:HasCollectible(enums.Items.RubberDuck) then
				savetable.DuckCurrentLuck[idx] = data.DuckCurrentLuck
			end
			if data.RedPillDamageUp then
				savetable.RedPillDamageUp[idx] = {data.RedPillDamageUp, data.RedPillDamageDown}
			end
			if data.UsedBG then
				savetable.UsedBG[idx] = data.UsedBG
			end
			if data.LimbActive then
				savetable.LimbActive[idx] = data.LimbActive
			end
			if data.StateDamaged then
				savetable.StateDamaged[idx] = data.StateDamaged
			end
			if data.RedLotusDamage then
				savetable.RedLotusDamage[idx] = data.RedLotusDamage
			end
			if data.KarmaStats then
				savetable.KarmaStats[idx] = data.KarmaStats
			end
			if data.MemoryFragment then
				savetable.MemoryFragment[idx] = data.MemoryFragment
			end

			if data.NirlySavedCards then
				savetable.NirlySavedCards[idx] = data.NirlySavedCards
			end	
			
			if data.LostWoodenCross then
				savetable.LostWoodenCross[idx] = data.LostWoodenCross
			end

			--[[
			if data.WaxHeartsCount then
				savetable.WaxHeartsCount[idx] = data.WaxHeartsCount
			end
			--]]
			
		end
		functions.modDataSave(savetable)
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, EclipsedMod.onExit)
--- GAME START --
function EclipsedMod:onStart(isSave)
	--- load mod save data; if debug, spawn mod items
	
	if isSave then
		for playerNum = 0, game:GetNumPlayers()-1 do
			local player = game:GetPlayer(playerNum)
			local data = player:GetData()
			if player:GetPlayerType() == enums.Characters.Abihu then
				data.BlindAbihu = true
				functions.SetBlindfold(player, true)
			elseif player:GetPlayerType() == enums.Characters.UnbiddenB then
				data.BlindUnbidden = true
				functions.SetBlindfold(player, true)
			end
		end
		if EclipsedMod:HasData() then -- continue game
			local localtable = json.decode(EclipsedMod:LoadData())
			datatables.OblivionCardErasedEntities = localtable.OblivionCardErasedEntities
			datatables.LobotomyErasedEntities = localtable.LobotomyErasedEntities
			datatables.MidasCurse.TurnGoldChance = localtable.MidasCurseTurnGoldChance
			datatables.SecretLoveLetterAffectedEnemies = localtable.SecretLoveLetterAffectedEnemies
			--if localtable.ModdedBombas then
			datatables.ModdedBombas = localtable.ModdedBombas
			datatables.TetrisItems = localtable.TetrisItems	
			datatables.ZeroMilestoneItems = localtable.ZeroMilestoneItems

			--end
			if localtable.DeliriumBeggarData then
				datatables.DeliriumBeggarEnable = localtable.DeliriumBeggarData.Enable
				datatables.DeliriumBeggarEnemies = localtable.DeliriumBeggarData.Enemies
			end
			datatables.SurrogateConceptionFams = localtable.SurrogateConceptionFams
		else
			functions.InitCall()
		end
	else --if not isSave then -- new game
		functions.InitCall()
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, EclipsedMod.onStart)
--- PLAYER INIT --
function EclipsedMod:onPlayerInit(player)
	local data = player:GetData()
	local idx = functions.getPlayerIndex(player)
	local toPlayers = #Isaac.FindByType(EntityType.ENTITY_PLAYER)

	if toPlayers == 0 then
		myrng:SetSeed(game:GetSeeds():GetStartSeed(), RECOMMENDED_SHIFT_IDX)
	end

	if EclipsedMod:HasData() then
		local localtable = json.decode(EclipsedMod:LoadData())

		if player:HasCollectible(enums.Items.Lililith) then
			data.LililithDemonSpawn = localtable.DemonSpawn[idx] -- datatables.Lililith.DemonSpawn
		end

		if player:HasCollectible(enums.Items.MidasCurse) then
			data.GoldenHeartsAmount = localtable.MidasCurseActive[idx]
		end
		if player:HasCollectible(enums.Items.RubberDuck) then
			functions.EvaluateDuckLuck(player, localtable.DuckCurrentLuck[idx])
		end

		if localtable.RedPillDamageUp then
			if localtable.RedPillDamageUp[idx] then
				data.RedPillDamageUp = localtable.RedPillDamageUp[idx][1]
				data.RedPillDamageDown = localtable.RedPillDamageUp[idx][2]
				player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
				player:EvaluateItems()
			end
		end

		if localtable.UsedBG then
			data.UsedBG = localtable.UsedBG[idx]
		end
		if localtable.LimbActive then
			data.LimbActive = localtable.LimbActive[idx]
		end

		
		
		if localtable.StateDamaged then
			data.StateDamaged = localtable.StateDamaged[idx]
		end
		if localtable.RedLotusDamage then
			data.RedLotusDamage = localtable.RedLotusDamage[idx]
		end
		if localtable.KarmaStats then
			data.KarmaStats = localtable.KarmaStats[idx]
		end
		if localtable.PandoraJarGift then
			datatables.PandoraJarGift = localtable.PandoraJarGift
		end
		if localtable.MemoryFragment then
			data.MemoryFragment = localtable.MemoryFragment[idx]
		end
		
		if localtable.UnbiddenResetGameChance and localtable.UnbiddenResetGameChance[idx] then
			data.UnbiddenResetGameChance = localtable.UnbiddenResetGameChance[idx][1]
			data.LevelRewindCounter = localtable.UnbiddenResetGameChance[idx][2]
		end
		if localtable.NirlySavedCards then
			data.NirlySavedCards = localtable.NirlySavedCards[idx]
		end	
		if localtable.LostWoodenCross then
			data.LostWoodenCross = localtable.LostWoodenCross[idx]
		end

		--[[
		if localtable.WaxHeartsCount then
			data.WaxHeartsCount = localtable.WaxHeartsCount[idx]
		end
		--]]
	end

	--if Isaac.GetChallenge() == enums.Challenges.ShovelNight and game:GetFrameCount() == 0 then
	--	Isaac.ExecuteCommand("stage 11")
	--	--Isaac.ExecuteCommand("goto d.10")
	--end
end
EclipsedMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, EclipsedMod.onPlayerInit)

---Render
function EclipsedMod:onRenderCurse()
	--- curse icons render
	functions.CurseIconRender()
end
EclipsedMod:AddCallback(ModCallbacks.MC_POST_RENDER, EclipsedMod.onRenderCurse)

--- EVAL_CACHE --
function EclipsedMod:onCache(player, cacheFlag)
	player = player:ToPlayer()
	local data = player:GetData()
	--local level = game:GetLevel()

	if cacheFlag == CacheFlag.CACHE_LUCK then
		if player:HasCollectible(enums.Items.RubberDuck) and data.DuckCurrentLuck then
			player.Luck = player.Luck + data.DuckCurrentLuck
		end
		if player:HasCollectible(enums.Items.VoidKarma) and data.KarmaStats then
			player.Luck = player.Luck + data.KarmaStats.Luck
		end
		if data.DeuxExLuck then
			player.Luck = player.Luck + data.DeuxExLuck
		end
		if data.MisfortuneLuck then
			player.Luck = player.Luck + datatables.MisfortuneLuck
		end
	end
	if cacheFlag == CacheFlag.CACHE_DAMAGE then
		if data.RedPillDamageUp then
			player.Damage = player.Damage + data.RedPillDamageUp
		end
		if data.RedLotusDamage then -- save damage even if you removed item
			player.Damage = player.Damage + data.RedLotusDamage
		end
		if player:HasCollectible(enums.Items.VoidKarma) and data.KarmaStats then
			player.Damage = player.Damage + data.KarmaStats.Damage
		end
		if data.EclipseBoost and data.EclipseBoost > 0 then
	        player.Damage = player.Damage + player.Damage * (datatables.Eclipse.DamageBoost * data.EclipseBoost)
	    end
		if data.HeartTransplantUseCount and data.HeartTransplantUseCount > 0 then
			local damageMulti = datatables.HeartTransplant.ChainValue[data.HeartTransplantUseCount][1]
			player.Damage = player.Damage + player.Damage * damageMulti
		end
	end
	if cacheFlag == CacheFlag.CACHE_FIREDELAY then
		if player:HasCollectible(enums.Items.VoidKarma) and data.KarmaStats then
			local stat_cache = player.MaxFireDelay + data.KarmaStats.Firedelay
			if player.MaxFireDelay > 5 then
				stat_cache = 5 
			end
			if player.MaxFireDelay > 1 then
				player.MaxFireDelay = stat_cache
			end
		end
		if data.HeartTransplantUseCount and data.HeartTransplantUseCount > 0 then
			local tearsUP = datatables.HeartTransplant.ChainValue[data.HeartTransplantUseCount][2]
			player.MaxFireDelay = player.MaxFireDelay + tearsUP
		end
	end
	if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
		if player:HasCollectible(enums.Items.VoidKarma) and data.KarmaStats then
			player.ShotSpeed = player.ShotSpeed + data.KarmaStats.Shotspeed
		end
	end
	if cacheFlag == CacheFlag.CACHE_RANGE then
		if player:HasCollectible(enums.Items.VoidKarma) and data.KarmaStats then
			player.TearRange = player.TearRange + data.KarmaStats.Range
		end
	end
	if cacheFlag == CacheFlag.CACHE_SPEED then
		if player:HasCollectible(enums.Items.MiniPony) then --and player.MoveSpeed < datatables.MiniPony.MoveSpeed then
			player.MoveSpeed = datatables.MiniPony.MoveSpeed
		end
		if player:HasCollectible(enums.Items.VoidKarma) and data.KarmaStats then
			player.MoveSpeed = player.MoveSpeed + data.KarmaStats.Speed
		end
		if data.HeartTransplantUseCount and data.HeartTransplantUseCount > 0 then
			local speed = datatables.HeartTransplant.ChainValue[data.HeartTransplantUseCount][3]
			player.MoveSpeed = player.MoveSpeed + speed
		end
	end
	if cacheFlag == CacheFlag.CACHE_FAMILIARS then
		-- red bags
		local bags = functions.GetItemsCount(player, enums.Items.RedBag)
		if bags > 0 then
			player:CheckFamiliar(datatables.RedBag.Variant, bags, RNG(), Isaac.GetItemConfig():GetCollectible(enums.Items.RedBag))
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
end
EclipsedMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, EclipsedMod.onCache)
--- PLAYER TAKE DMG --
function EclipsedMod:onPlayerTakeDamage(entity, _, flags) --entity, amount, flags, source, countdown
	local player = entity:ToPlayer()
	local data = player:GetData()
	local tempEffects = player:GetEffects()

	if player:HasCurseMistEffect() or player:IsCoopGhost() then return end

	--- soul of nadab and abihu
	if data.UsedSoulNadabAbihu and (
			flags & DamageFlag.DAMAGE_FIRE == DamageFlag.DAMAGE_FIRE or
			flags & DamageFlag.DAMAGE_EXPLOSION == DamageFlag.DAMAGE_EXPLOSION or
			flags & DamageFlag.DAMAGE_TNT == DamageFlag.DAMAGE_TNT
	) then
		return false
	end
	
	--- agony box
	if player:HasCollectible(enums.Items.AgonyBox, true) and flags & DamageFlag.DAMAGE_FAKE == 0 then
		for slot = 0, 2 do
			if player:GetActiveItem(slot) == enums.Items.AgonyBox then
				local activeCharge = player:GetActiveCharge(slot) -- item charge
				local batteryCharge = player:GetBatteryCharge(slot) -- extra charge (battery item)
				local newCharge = batteryCharge + activeCharge - 1
				if activeCharge > 0 then -- batteryCharge > 0
					player:SetActiveCharge(newCharge, slot)
					sfx:Play(SoundEffect.SOUND_BATTERYDISCHARGE)
					player:SetMinDamageCooldown(120)

					if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
						local wisp = player:AddWisp(CollectibleType.COLLECTIBLE_DULL_RAZOR, player.Position, true, false)
						if wisp then
							wisp.Color = Color(0.5, 1, 0.5, 1)
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
		player:UseActiveItem(CollectibleType.COLLECTIBLE_RAZOR_BLADE, datatables.MyUseFlags_Gene | UseFlag.USE_NOCOSTUME)
		return false
	end
	
	--- mongo cells
	if player:HasCollectible(enums.Items.MongoCells) and flags & DamageFlag.DAMAGE_NO_PENALTIES == 0 then
		local rng = player:GetCollectibleRNG(enums.Items.MongoCells)
		if player:HasCollectible(CollectibleType.COLLECTIBLE_DRY_BABY) or tempEffects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_DRY_BABY) then
			if rng:RandomFloat() < datatables.MongoCells.DryBabyChance then
				player:UseActiveItem(CollectibleType.COLLECTIBLE_NECRONOMICON, datatables.MyUseFlags_Gene)
			end
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_FARTING_BABY) or tempEffects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_FARTING_BABY) then
			if rng:RandomFloat() < datatables.MongoCells.DryBabyChance then
				local bean = datatables.MongoCells.FartBabyBeans[rng:RandomInt(#datatables.MongoCells.FartBabyBeans)+1]
				player:UseActiveItem(bean, datatables.MyUseFlags_Gene)
			end
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BBF) or tempEffects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_BBF) then
			game:BombExplosionEffects(player.Position, datatables.MongoCells.BBFDamage, player:GetBombFlags(), Color.Default, player, 1, true, false, DamageFlag.DAMAGE_EXPLOSION)
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BOBS_BRAIN) or tempEffects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_BOBS_BRAIN) then
			game:BombExplosionEffects(player.Position, datatables.MongoCells.BBFDamage, player:GetBombFlags(), Color.Default, player, 1, true, false, DamageFlag.DAMAGE_EXPLOSION)
			local cloud = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SMOKE_CLOUD, 0, player.Position, Vector.Zero, player):ToEffect()
			cloud:SetTimeout(150)
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_HOLY_WATER) or tempEffects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_WATER) then
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_HOLYWATER, 0, player.Position, Vector.Zero, player):SetColor(Color(1,1,1,0), 5, 1, false, false)
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_DEPRESSION) or tempEffects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_DEPRESSION) then
			if rng:RandomFloat() < datatables.MongoCells.DepressionLightChance then
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACK_THE_SKY, 0, player.Position, Vector.Zero, player)
			end
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_RAZOR) or tempEffects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_MOMS_RAZOR) then
			player:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
		end
	end
	--- lost flower
	if player:HasTrinket(enums.Trinkets.LostFlower) then -- remove lost flower if get hit
		if (flags & DamageFlag.DAMAGE_NO_PENALTIES == 0) and (flags & DamageFlag.DAMAGE_RED_HEARTS == 0) then
			functions.RemoveThrowTrinket(player, enums.Trinkets.LostFlower, datatables.TrinketDespawnTimer )
		end
	end
	--- RubikCubelet: TMTRAINER + D6
	if player:HasTrinket(enums.Trinkets.RubikCubelet) then
		local numTrinket = player:GetTrinketMultiplier(enums.Trinkets.RubikCubelet)
		if player:GetTrinketRNG(enums.Trinkets.RubikCubelet):RandomFloat() < datatables.RubikCubelet.TriggerChance * numTrinket then
			functions.RerollTMTRAINER(player)
		end
	end
	
	--- cybercutlet - remove itself
	if player:HasTrinket(enums.Trinkets.Cybercutlet) then
		if (flags & DamageFlag.DAMAGE_NO_PENALTIES == 0) and (flags & DamageFlag.DAMAGE_RED_HEARTS == 0) then
			player:TryRemoveTrinket(enums.Trinkets.Cybercutlet)
			player:AddHearts(2)
			sfx:Play(SoundEffect.SOUND_VAMP_GULP)
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HEART, 0, Vector(player.Position.X, player.Position.Y-70), Vector.Zero, nil):ToEffect()
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, EclipsedMod.onPlayerTakeDamage, EntityType.ENTITY_PLAYER)
--- PLAYER PEFFECT --
function EclipsedMod:onPEffectUpdate(player)
	local level = game:GetLevel()
	local room = game:GetRoom()
	local data = player:GetData()
	local sprite = player:GetSprite()
	local tempEffects = player:GetEffects()
	
	if data.UsedKittenShuffle2 then
		data.UsedKittenShuffle2 = data.UsedKittenShuffle2 - 1
		if data.UsedKittenShuffle2 <= 0 then
			player:RemoveCollectible(CollectibleType.COLLECTIBLE_MISSING_NO)
			data.UsedKittenShuffle2 = nil
		end
	end
	
	if level:GetCurses() & enums.Curses.Misfortune > 0 and not data.MisfortuneLuck then
		data.MisfortuneLuck = true
		player:AddCacheFlags(CacheFlag.CACHE_LUCK)
		player:EvaluateItems()
	elseif level:GetCurses() & enums.Curses.Misfortune == 0 and data.MisfortuneLuck then
		data.MisfortuneLuck = nil
		player:AddCacheFlags(CacheFlag.CACHE_LUCK)
		player:EvaluateItems()
	end

	if level:GetCurses() & enums.Curses.Montezuma > 0 and not player.CanFly and game:GetFrameCount()%10 == 0 then
		local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_SLIPPERY_BROWN, 0, player.Position, Vector.Zero, nil):ToEffect()
		creep.SpriteScale = creep.SpriteScale * 0.1
	end

	---exploding kitten
	---so I decide to give some safe space where it wouldn't explode if you have extra card pocket
	local holdingCard = player:GetCard(0)
	if datatables.ExplodingKittens.BombKards[holdingCard] then
		data.ExplodingKitten = data.ExplodingKitten or datatables.ExplodingKittens.ActivationTimer
		data.ExplodingKitten = data.ExplodingKitten - 1
		
		if data.ExplodingKitten <= 0 then
			--player:UseCard(holdingCard, 0)
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

	--moonlighter mirror
	if data.KeeperMirror then
		local up = Input.IsActionPressed(ButtonAction.ACTION_SHOOTUP, player.ControllerIndex)
		local down = Input.IsActionPressed(ButtonAction.ACTION_SHOOTDOWN, player.ControllerIndex)
		local left = Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT, player.ControllerIndex)
		local right = Input.IsActionPressed(ButtonAction.ACTION_SHOOTRIGHT, player.ControllerIndex)
		local isMoving = (down or right or left or up)
		if data.KeeperMirror.Timeout > 0 and data.KeeperMirror:Exists() and not player:IsCoopGhost() then
			local targetData = data.KeeperMirror:GetData()
			if not targetData.MovementVector then targetData.MovementVector = Vector.Zero end
			if not (left or right) then targetData.MovementVector.X = 0 end
			if not (up or down) then targetData.MovementVector.Y = 0 end
			if left and not right then targetData.MovementVector.X = -1
			elseif right then targetData.MovementVector.X = 1 end
			if up and not down then targetData.MovementVector.Y = -1
			elseif down then targetData.MovementVector.Y = 1 end
			if room:IsMirrorWorld() then targetData.MovementVector.X = targetData.MovementVector.X * -1 end
			if not isMoving then
				local radiusTable = Isaac.FindInRadius(data.KeeperMirror.Position, datatables.KeeperMirror.TargetRadius, EntityPartition.PICKUP)
				if #radiusTable > 0 then
					if data.KeeperMirror.Timeout <= datatables.KeeperMirror.TargetTimeout then
						local coins = 0
						for _, pickup in pairs(radiusTable) do
							if pickup:ToPickup() then
								pickup = pickup:ToPickup()
								coins = functions.SellItems(pickup, player)
								if coins ~= 0 then
									if coins > 0 then
										for _ = 1, coins do
											local randVector = RandomVector()*5
											Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, pickup.Position, randVector, player)
										end
									end
									pickup:Remove()
									Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, nil):SetColor(Color(0,1.5,1.3,1,0,0,0), 50, 1, false, false)
									sfx:Play(SoundEffect.SOUND_CASH_REGISTER)
									data.KeeperMirror:Remove()
									data.KeeperMirror = nil
									break
								end
							end
						end
					end
				end
			else
				data.KeeperMirror.Velocity = data.KeeperMirror.Velocity + functions.UnitVector(targetData.MovementVector):Resized(player.MoveSpeed + 2)
			end
		else
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, data.KeeperMirror.Position, Vector.Zero, player)
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, data.KeeperMirror.Position, Vector.Zero, nil):SetColor(Color(0,1.5,1.3,1,0,0,0), 50, 1, false, false)
			sfx:Play(SoundEffect.SOUND_CASH_REGISTER)
			data.KeeperMirror:Remove()
			data.KeeperMirror = nil
		end
	end

	--domino 25
	if data.Domino25Used then
		data.Domino25Used = data.Domino25Used - 1
		if data.Domino25Used <= 0 then
			for _, enemy in pairs(Isaac.FindInRadius(room:GetCenterPos(), 5000, EntityPartition.ENEMY)) do
				if enemy:IsVulnerableEnemy() and enemy:IsActiveEnemy() then
					game:RerollEnemy(enemy)
				end
			end
			data.Domino25Used = nil
		end
	end
	---maze of memory
	if data.MazeMemoryUsed then
		if data.MazeMemoryUsed[1] then
			if data.MazeMemoryUsed[1] > 0 then
				data.MazeMemoryUsed[1] = data.MazeMemoryUsed[1] - 1
			elseif data.MazeMemoryUsed[1] == 0 then
				data.MazeMemoryUsed[1] = data.MazeMemoryUsed[1] - 1
				Isaac.ExecuteCommand("goto s.treasure.0")
			elseif data.MazeMemoryUsed[1] < 0 then
				game:ShowHallucination(0, BackdropType.DARK_CLOSET)
				if sfx:IsPlaying(SoundEffect.SOUND_DEATH_CARD) then
					sfx:Stop(SoundEffect.SOUND_DEATH_CARD)
				end
				data.MazeMemoryUsed[1] = nil

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
		elseif data.MazeMemoryUsed[2] then
			local roomitems = 0
			local rent = room:GetEntities()
			for ient = 0, #rent-1 do
				local ent = rent:Get(ient)
				if ent and ent:ToPickup() and ent:ToPickup().Variant == 100 then
					roomitems = roomitems + 1
				end
			end
			if roomitems < data.MazeMemoryUsed[2] then
				data.Transit = 25
				data.MazeMemoryUsed = nil
			elseif roomitems > data.MazeMemoryUsed[2] then
				data.MazeMemoryUsed[2] = roomitems
			end
		end
	end
	if data.Transit then
		data.Transit = data.Transit - 1
		if data.Transit <= 0 then
			data.Transit = nil
			game:StartRoomTransition(level:GetStartingRoomIndex(), 1, RoomTransitionAnim.DEATH_CERTIFICATE, player, -1)
		end
	end

	--- secret love letter
	if data.UsedSecretLoveLetter and player:GetFireDirection() ~= Direction.NO_DIRECTION then -- player:GetAimDirection():Length() > 0.3 (if marked)
		if player:IsHoldingItem() then 
			if player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == enums.Items.SecretLoveLetter then
				if player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY) >= Isaac.GetItemConfig():GetCollectible(enums.Items.SecretLoveLetter).MaxCharges then
					local tear = player:FireTear(player.Position, player:GetAimDirection() * 14, false, true, false, nil, 0):ToTear()
					tear.TearFlags = TearFlags.TEAR_CHARM
					tear.Color = Color(1,1,1,1,0,0,0)
					tear:ChangeVariant(datatables.SecretLoveLetter.TearVariant) --datatables.SecretLoveLetter.TearVariant)
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
		data.UsedSecretLoveLetter = false
	end

	--- item wisp add item
	if data.WispedQueue then
		if #data.WispedQueue > 0 and player:IsItemQueueEmpty() and not data.WispedItemDelay then
			local witem = data.WispedQueue[1][1]
			local kill = data.WispedQueue[1][2]
			sfx:Play(SoundEffect.SOUND_THUMBSUP)
			player:QueueItem(Isaac.GetItemConfig():GetCollectible(witem.SubType), Isaac.GetItemConfig():GetCollectible(witem.SubType).InitCharge)
			player:AnimateCollectible(witem.SubType, "UseItem") -- queueItem works with "UseItem" animation YEY!
			if kill then
				witem:Remove()
				witem:Kill()
			end
			data.WispedItemDelay = 1
			table.remove(data.WispedQueue, 1)
		elseif player:IsItemQueueEmpty() and data.WispedItemDelay then -- so it would be added properly ( basically I just need at least 1 frame delay, to add item modifications)
			data.WispedItemDelay = nil
		elseif #data.WispedQueue == 0 then -- nil if it's empty
			data.WispedQueue = nil
			data.WispedItemDelay = nil
		end
	end
	
	if data.NirlySavedCards and data.UsedNirly then
		if #data.NirlySavedCards == 0 then
			data.UsedNirly = false
		else
			card = table.remove(data.NirlySavedCards, 1) 
			player:UseCard(card, UseFlag.USE_NOANIM)
		end
	end
	

	
	
	if not player:HasCurseMistEffect() and not player:IsCoopGhost() then
		
		functions.CheckPickupAbuse(player)
		
		functions.TetrisDiceCheks(player)
		
		-- nirly's codex
		if player:HasCollectible(enums.Items.NirlyCodex) and data.NirlySavedCards and #data.NirlySavedCards > 0 then
			
			if Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex) then
				data.NirlyDropTimer = data.NirlyDropTimer or 0
				
				if data.NirlyDropTimer == 60 then
					data.NirlyDropTimer = 0
					for _, card in ipairs(data.NirlySavedCards) do
						functions.DebugSpawn(PickupVariant.PICKUP_TAROTCARD, card, player.Position)			
					end
					data.NirlySavedCards ={}
				else
					data.NirlyDropTimer = data.NirlyDropTimer +1
				end
			end
		end
		
		--- abyss cartridge
		if player:HasTrinket(enums.Trinkets.AbyssCart) then
			if player:GetHearts() < 2 and player:GetSoulHearts() < 2 and game:GetFrameCount()%15 == 0 then
				data.AbyssCartBlink = data.AbyssCartBlink or nil
				if data.AbyssCartBlink then
					local blinkerBabies = Isaac.FindByType(EntityType.ENTITY_FAMILIAR, data.AbyssCartBlink)
					if #blinkerBabies > 0 then
						for _, baby in pairs(blinkerBabies) do
							baby:SetColor(Color(0.3,0.3,1,1), 10, 100, true, false)
						end
					end
				else
					for _, elems in pairs(datatables.AbyssCart.SacrificeBabies) do
						if player:HasCollectible(elems[1]) then
							data.AbyssCartBlink = elems[2]
							break
						end
					end
				end
			elseif player:GetHearts() >= 2 or player:GetSoulHearts() >= 2 then
				if data.AbyssCartBlink then data.AbyssCartBlink = nil end
			end
		end
		--- mongo cells
		if player:HasCollectible(enums.Items.MongoCells) then
			--data.MongoFamiliarEffects = data.MongoFamiliarEffects or {}
			for _, subTable in pairs(datatables.MongoCells.FamiliarEffects) do
				-- check if I have familiar and item (real or temp), then add temp item
				if player:HasCollectible(subTable[1]) and not (player:HasCollectible(subTable[2]) or tempEffects:HasCollectibleEffect(subTable[2])) then --not data.MongoFamiliarEffects[indexName] and
					local babyItem = subTable[1]
					local effectItem = subTable[2]
					local min = subTable[3] or 0
					--print(functions.GetItemsCount(player, babyItem), min)
					if functions.GetItemsCount(player, babyItem) > min then
						--data.MongoFamiliarEffects[indexName] = subTable
						tempEffects:AddCollectibleEffect(effectItem, true)
					end
				-- check if I don't have familiar or have real item, then remove temp item
				elseif (not player:HasCollectible(subTable[1]) or player:HasCollectible(subTable[2], true)) then -- data.MongoFamiliarEffects[indexName] and
					--data.MongoFamiliarEffects[indexName] = false
					local effectItem = subTable[2]
					tempEffects:RemoveCollectibleEffect(effectItem)
				end
			end

			for _, subTable in pairs(datatables.MongoCells.HiddenWispEffects) do
				-- check if I have familiar and item (real or temp), then add item wisp
				if player:HasCollectible(subTable[1]) and not player:HasCollectible(subTable[2]) then
					--local babyItem = subTable[1]
					local effectItem = subTable[2]
					local itemWisp = player:AddItemWisp(effectItem, Vector.Zero, true)
					itemWisp:RemoveFromOrbit()
					itemWisp:AddEntityFlags(EntityFlag.FLAG_NO_REWARD)
					itemWisp:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
					-- mongo cells
					itemWisp.Visible = false
					itemWisp.Position = Vector.Zero
					itemWisp.Velocity = Vector.Zero
					itemWisp.CollisionDamage = 0
					itemWisp.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
					itemWisp.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
					itemWisp:GetData().MongoWisp = true
				-- check if I don't have familiar or have real item, then remove item wisp
				elseif (not player:HasCollectible(subTable[1]) or player:HasCollectible(subTable[2], true)) then
					local effectItem = subTable[2]
					local itemWisps = Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.ITEM_WISP, effectItem)
			        if #itemWisps > 0 then
			             for _, itemWisp in pairs(itemWisps) do
			                if itemWisp.SubType and itemWisp:GetData().MongoWisp then
				                itemWisp:Remove()
								itemWisp:Kill()
					            break
					        end
			             end
			        end
				end
			end
		end

		--- lililith
		if player:HasCollectible(enums.Items.Lililith) then
			data.LililithDemonSpawn = data.LililithDemonSpawn or datatables.LililithDemonSpawn
		end
		--- Mew-Gen
		if player:HasCollectible(enums.Items.MewGen) then
			functions.MewGenManager(player)
		end
		
		
		
		-- void karma
		if player:HasCollectible(enums.Items.VoidKarma) and level:GetStateFlag(LevelStateFlag.STATE_DAMAGED) and not data.StateDamaged then
			data.StateDamaged = 1 -- used as stat multiplier. without damage == 2
		end
		-- corruption
		if data.CorruptionIsActive then 
			
			if data.CorruptionIsActive <= 0 then
				data.CorruptionIsActive = nil
				player:TryRemoveNullCostume(datatables.Corruption.CostumeHead)
				local activeItem = player:GetActiveItem(ActiveSlot.SLOT_PRIMARY)
				if activeItem ~= 0 then
					player:RemoveCollectible(activeItem)
				end
			end
			
			if player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) ~= 0 then
			
				local activeItem = player:GetActiveItem(ActiveSlot.SLOT_PRIMARY)
				if player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY) < Isaac.GetItemConfig():GetCollectible(activeItem).MaxCharges then
					data.CorruptionIsActive = data.CorruptionIsActive - 1
					player:FullCharge(ActiveSlot.SLOT_PRIMARY, false)
				end
			end
			
			
		end
		-- frosty tears for ice cube bombs / attractor tears for black hole bombs
		for _, bomb in pairs(Isaac.FindByType(4)) do -- bombs == 4
			bomb = bomb:ToBomb()
			if bomb:GetSprite():GetAnimation() == "Explode" then -- not datatables.MirrorBombs.Ban[bomb.Variant]
				local radius = functions.GetBombRadiusFromDamage(bomb.ExplosionDamage)
				if bomb:GetData().Dicey then
					functions.DiceyReroll(player:GetCollectibleRNG(enums.Items.DiceBombs), bomb.Position, radius)
				end
				if bomb:GetData().Bonny then
					functions.BonnyBlast(player:GetCollectibleRNG(enums.Items.DeadBombs), bomb.Position, radius, player)
				end
				if player:HasCollectible(enums.Items.Pyrophilia) then
					for _, enemy in pairs(Isaac.FindInRadius(bomb.Position, radius, EntityPartition.ENEMY)) do
						if enemy:IsVulnerableEnemy() and enemy:IsActiveEnemy() then
							player:AddHearts(1)
							sfx:Play(SoundEffect.SOUND_VAMP_GULP)
							Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HEART, 0, Vector(player.Position.X, player.Position.Y-70), Vector.Zero, nil):ToEffect()
							--local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HEART, 0, Vector(player.Position.X, player.Position.Y-70), Vector.Zero, nil):ToEffect()
							--effect:SetTimeout(3)
							break
						end
					end
				end
				if bomb:GetData().Charged then
					functions.ChargedBlast(bomb.Position, radius, bomb.ExplosionDamage, bomb.SpawnerEntity)
				end
				if bomb:GetData().DeadEgg then
					functions.DeadEggEffect(player, bomb.Position, datatables.DeadEgg.Timeout)
				end
				--spawn particle
				if bomb:GetData().Frosty then
					game:SpawnParticles(bomb.Position, EffectVariant.DIAMOND_PARTICLE, 10, 5, Color(1,1,1,1,0.5,0.5,0.8))-- poofColor --ROCK_PARTICLE
				end
				if bomb:HasTearFlags(TearFlags.TEAR_SAD_BOMB) then
					for _, tear in pairs(Isaac.FindInRadius(bomb.Position, 22, EntityPartition.TEAR)) do
						if tear.FrameCount == 1 then -- other tears can get this effects if you shoot tears near bomb (idk else how to get)
							tear = tear:ToTear()
							if bomb:GetData().Frosty then
								tear:ChangeVariant(TearVariant.ICE)
								tear:AddTearFlags(TearFlags.TEAR_SLOW | TearFlags.TEAR_ICE)
							end
						end
					end
				end
			end
		end

		--long elk
		if player:HasCollectible(enums.Items.LongElk) then
			if not data.HasLongElk then
				data.HasLongElk = true
				player:AddNullCostume(datatables.LongElk.Costume)
				player:AddCacheFlags(CacheFlag.CACHE_FLYING)
				player:EvaluateItems()
			end

			if data.ElkKiller then
				if not tempEffects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_MARS) then
					data.ElkKiller = false
				end
			end

			if not data.BoneSpurTimer then
				data.BoneSpurTimer = datatables.LongElk.BoneSpurTimer
			else
				if  data.BoneSpurTimer > 0 then
					data.BoneSpurTimer = data.BoneSpurTimer - 1
				end
			end
			if player:GetMovementDirection() ~= -1 and not room:IsClear() and data.BoneSpurTimer <= 0 then
				Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BONE_SPUR, 0, player.Position, Vector.Zero, player):ToFamiliar():GetData().RemoveTimer = datatables.LongElk.BoneSpurTimer * datatables.LongElk.NumSpur
				data.BoneSpurTimer = datatables.LongElk.BoneSpurTimer
			end
		else
			if data.HasLongElk then
				data.HasLongElk = nil
				player:TryRemoveNullCostume(datatables.LongElk.Costume)
				player:AddCacheFlags(CacheFlag.CACHE_FLYING)
				player:EvaluateItems()
			end
		end
		--mini-pony
		if player:HasCollectible(enums.Items.MiniPony) then
			if not data.HasMiniPony then
				data.HasMiniPony = true
				--player:AddCacheFlags(CacheFlag.CACHE_SIZE)
				player:AddCacheFlags(CacheFlag.CACHE_FLYING)
				player:AddCacheFlags(CacheFlag.CACHE_SPEED)
				player:AddNullCostume(datatables.MiniPony.Costume)
				player:EvaluateItems()
			end
			if player.MoveSpeed < datatables.MiniPony.MoveSpeed then
				player:AddCacheFlags(CacheFlag.CACHE_SPEED)
				player:EvaluateItems()
			end
		else
			if data.HasMiniPony then
				data.HasMiniPony = nil
				player:TryRemoveNullCostume(datatables.MiniPony.Costume)
				player:AddCacheFlags(CacheFlag.CACHE_FLYING)
				player:AddCacheFlags(CacheFlag.CACHE_SPEED)
				player:EvaluateItems()
			end
		end
		--- duotine
		if player:HasTrinket(enums.Trinkets.Duotine) then
			for slot = 0, 3 do
				local pill = player:GetPill(slot)
				if pill > 0 then
					if pill & PillColor.PILL_GIANT_FLAG == PillColor.PILL_GIANT_FLAG then
						player:SetCard(slot, enums.Pickups.RedPillHorse)
					else
						player:SetCard(slot, enums.Pickups.RedPill)
					end
				end
			end
		end

		---red pills
		if data.RedPillDamageUp then --and game:GetFrameCount()%2 == 0 then
			data.RedPillDamageUp = data.RedPillDamageUp - data.RedPillDamageDown
			data.RedPillDamageDown = data.RedPillDamageDown + datatables.RedPills.DamageDownTick
			if data.RedPillDamageUp < 0 then
				data.RedPillDamageUp = 0
			end
			player:AddCacheFlags(CacheFlag.CACHE_DAMAGE) -- | CacheFlag.CACHE_FIREDELAY)
			player:EvaluateItems()
			if data.RedPillDamageUp == 0 then
				data.RedPillDamageUp = nil
				data.RedPillDamageDown = nil
			end
		end

		---MidasCurse
		if player:HasCollectible(enums.Items.MidasCurse) then

			if not data.GoldenHeartsAmount then data.GoldenHeartsAmount = player:GetGoldenHearts() end

			if player:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE) and datatables.MidasCurse.TurnGoldChance ~= datatables.MidasCurse.MinGold then -- remove curse
				datatables.MidasCurse.TurnGoldChance = datatables.MidasCurse.MinGold
			elseif not player:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE) and datatables.MidasCurse.TurnGoldChance ~= datatables.MidasCurse.MaxGold then
				datatables.MidasCurse.TurnGoldChance = datatables.MidasCurse.MaxGold
			end
			-- golden particles
			if player:GetMovementDirection() ~= -1 then
				game:SpawnParticles(player.Position, EffectVariant.GOLD_PARTICLE, 1, 2, _, 0)
			end
			if player:GetGoldenHearts() < data.GoldenHeartsAmount then
				local rngMidasCurse = player:GetCollectibleRNG(enums.Items.MidasCurse)
				data.GoldenHeartsAmount = player:GetGoldenHearts()
				room:TurnGold() -- turn room gold (ultra greed death)
				functions.GoldenGrid(rngMidasCurse) -- golden poops
				for _, entity in pairs(Isaac.GetRoomEntities()) do
					if entity:ToNPC() then
						local enemy = entity:ToNPC()
						enemy:RemoveStatusEffects()
						enemy:AddMidasFreeze(EntityRef(player), datatables.MidasCurse.FreezeTime)
					end
					if entity.Type == EntityType.ENTITY_PICKUP then
						if rngMidasCurse:RandomFloat() < datatables.MidasCurse.TurnGoldChance then
							functions.TurnPickupsGold(entity:ToPickup())
						end
					end
				end
			elseif player:GetGoldenHearts() > data.GoldenHeartsAmount then
				data.GoldenHeartsAmount = player:GetGoldenHearts()
			end
		else
			if data.GoldenHeartsAmount and data.GoldenHeartsAmount > 0 then
				data.GoldenHeartsAmount = 0
			end
		end
		---Duckling
		if player:HasCollectible(enums.Items.RubberDuck) then
			data.DuckCurrentLuck = data.DuckCurrentLuck or 0
		else
			if data.DuckCurrentLuck and data.DuckCurrentLuck > 0 then
				-- data.DuckCurrentLuck = 0
				functions.EvaluateDuckLuck(player, 0)
			end
		end
		---WitchPaper
		if data.WitchPaper then
			data.WitchPaper = data.WitchPaper - 1
			if data.WitchPaper <= 0 then
				data.WitchPaper = nil
				player:AnimateTrinket(enums.Trinkets.WitchPaper)
				player:TryRemoveTrinket(enums.Trinkets.WitchPaper)
			end
		end
		--- COPY from Edith mod ------------
		--- BlackKnight
		if player:HasCollectible(enums.Items.BlackKnight, true) then
			if not data.HasBlackKnight then
				data.HasBlackKnight = true
				player:AddNullCostume(datatables.BlackKnight.Costume)
			end
			if data.ControlTarget == nil then data.ControlTarget = true end
			if not player:HasEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK) then
				player:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
			end
			-- get movement action
			local up = Input.IsActionPressed(ButtonAction.ACTION_UP, player.ControllerIndex)
			local down = Input.IsActionPressed(ButtonAction.ACTION_DOWN, player.ControllerIndex)
			local left = Input.IsActionPressed(ButtonAction.ACTION_LEFT, player.ControllerIndex)
			local right = Input.IsActionPressed(ButtonAction.ACTION_RIGHT, player.ControllerIndex)
			local isMoving = (down or right or left or up)
			if not data.ControlTarget then isMoving = false end
			-- spawn target mark
			if isMoving and not data.KnightTarget and not player:HasCollectible(CollectibleType.COLLECTIBLE_DOGMA) and not player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_MEGA_MUSH) and not player:IsCoopGhost() then
				if data.ControlTarget then
					data.KnightTarget = Isaac.Spawn(1000, datatables.BlackKnight.Target, 0, player.Position, Vector.Zero, player):ToEffect()
					data.KnightTarget.Parent = player
					data.KnightTarget.SpawnerEntity = player
				end
			end
			if data.KnightTarget and data.KnightTarget:Exists() then
				if player:HasCollectible(CollectibleType.COLLECTIBLE_DOGMA) or player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_MEGA_MUSH) or player:IsCoopGhost() then
					data.KnightTarget:Remove()
					data.KnightTarget = nil
				end
				local targetData = data.KnightTarget:GetData()
				local targetSprite = data.KnightTarget:GetSprite()
				if not targetData.MovementVector then targetData.MovementVector = Vector.Zero end
				if not (left or right) then targetData.MovementVector.X = 0 end
				if not (up or down) then targetData.MovementVector.Y = 0 end
				if left and not right then targetData.MovementVector.X = -1
				elseif right then targetData.MovementVector.X = 1 end
				if up and not down then targetData.MovementVector.Y = -1
				elseif down then targetData.MovementVector.Y = 1 end
				if room:IsMirrorWorld() then targetData.MovementVector.X = targetData.MovementVector.X * -1 end
				if isMoving and data.KnightTarget:CollidesWithGrid() and player.ControlsEnabled then
					for gridIndex = 1, room:GetGridSize() do
						if room:GetGridEntity(gridIndex) then
							local grid = room:GetGridEntity(gridIndex)
							if (data.KnightTarget.Position - grid.Position):Length() <= datatables.BlackKnight.DoorRadius then
								if grid.Desc.Type == GridEntityType.GRID_DOOR then
									grid = grid:ToDoor()
									if room:IsClear() then
										grid:TryUnlock(player)
									end
									if grid:IsOpen() then
										if (player.Position - grid.Position):Length() <= datatables.BlackKnight.DoorRadius then
											player.Position = grid.Position
											player:SetColor(Color(1, 1, 1, 0, 0, 0, 0), 1, 999, false, true)
										else
											player:PlayExtraAnimation("TeleportUp")
											data.NextRoom = grid.Position
											data.Jumped = true
											data.ControlTarget = false
										end
									end
								end
							end
						end
					end
					if room:GetType() == RoomType.ROOM_DUNGEON then
						if ((data.KnightTarget.Position - Vector(110, 135)):Length() or (data.KnightTarget.Position - Vector(595, 272)):Length() or (data.KnightTarget.Position - Vector(595, 385)):Length()) <= 35 then
							player.Position = data.KnightTarget.Position + functions.UnitVector(data.KnightTarget.Velocity):Resized(25)
							player:SetColor(Color(1, 1, 1, 0, 0, 0, 0), 2, 999, false, true)
						end
					end
				end
				if isMoving then
					data.KnightTarget.Velocity = data.KnightTarget.Velocity + functions.UnitVector(targetData.MovementVector):Resized(player.MoveSpeed + 2)
					targetSprite:Play("Idle")
				end
			end
			if data.Jumped and sprite:GetAnimation() == "TeleportUp" then
				player.FireDelay = player.MaxFireDelay-1 -- it can pause some charging attacks (better way to remove tears in TearInit callback but meh)
				data.ControlTarget = false
				player.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
				player.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
				if player:IsExtraAnimationFinished() then
					if data.NextRoom then
						player.Position = data.NextRoom
						player:SetColor(Color(1, 1, 1, 0, 0, 0, 0), 1, 999, false, true)
						data.NextRoom = nil
						data.ControlTarget = true
						data.Jumped = nil
					else
						player:PlayExtraAnimation("TeleportDown")
					end
				end
			end
			if data.Jumped and sprite:GetAnimation() == "TeleportDown" then
				if data.KnightTarget then
					player.Position = data.KnightTarget.Position
					data.ControlTarget = false
				end
			end
			if data.Jumped and sprite:IsFinished("TeleportDown") then
				data.Jumped = nil
				data.ControlTarget = true
				player.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
				if player.CanFly then
					player.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
				else
					player.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
				end
				for _, entity in pairs(Isaac.GetRoomEntities()) do
					--EntityType.ENTITY_HOST
					--EntityType.ENTITY_MOBILE_HOST
					--EntityType.ENTITY_FLOATING_HOST
					if entity:IsVulnerableEnemy() and entity:IsActiveEnemy() then
						if entity.Position:Distance(player.Position) > datatables.BlackKnight.BlastRadius and entity.Position:Distance(player.Position) <= datatables.BlackKnight.BlastRadius*2.5 then
							entity.Velocity = (entity.Position - player.Position):Resized(datatables.BlackKnight.BlastKnockback*(2/3))
						end
					elseif entity.Type == EntityType.ENTITY_PICKUP and entity.Position:Distance(player.Position) <= datatables.BlackKnight.PickupDistance then
						entity = entity:ToPickup()
						if datatables.BlackKnight.ChestVariant[entity.Variant] and entity.SubType ~= 0 then
							if entity.Variant == PickupVariant.PICKUP_BOMBCHEST then
								entity:TryOpenChest()
							end
							entity.Position = player.Position
							entity.Velocity = Vector.Zero
						else
							entity.Position = player.Position
							entity.Velocity = Vector.Zero
						end
					end
				end
				functions.BlastDamage(datatables.BlackKnight.BlastRadius, datatables.BlackKnight.BlastDamage + player.Damage/2, datatables.BlackKnight.BlastKnockback, player)
				local gridEntity = room:GetGridEntityFromPos(player.Position)
				if gridEntity then
					if gridEntity.Desc.Type == GridEntityType.GRID_PIT and gridEntity.Desc.State ~= 1 then
						if room:HasLava() then
							local splash = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BIG_SPLASH, 0, player.Position, Vector.Zero, player):ToEffect()
							splash.Color = Color(1.2, 0.8, 0.1, 1, 0, 0, 0)
							splash.SpriteScale = Vector(0.75, 0.75)
						elseif room:HasWaterPits() or room:HasWater() then
							local splash = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BIG_SPLASH, 0, player.Position, Vector.Zero, player):ToEffect()
							splash.SpriteScale = Vector(0.75, 0.75)
						end
					end
				elseif room:HasWater() then
					--sfx:Play(SoundEffect.SOUND_WATERSPLASH, 1, 0, false, 1, 0)
					local splash = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BIG_SPLASH, 0, player.Position, Vector.Zero, player):ToEffect()
					splash.SpriteScale = Vector(0.75, 0.75)
				else
					sfx:Play(SoundEffect.SOUND_STONE_IMPACT, 1, 0, false, 1, 0)
					--game:SpawnParticles(player.Position, EffectVariant.TOOTH_PARTICLE, 3, 2, _, 0)
				end
				game:ShakeScreen(10)
				player.Velocity = Vector.Zero
			end
		else
			if data.HasBlackKnight then
				player:TryRemoveNullCostume(datatables.BlackKnight.Costume)
				data.HasBlackKnight = false
				player:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
				if data.KnightTarget then
					data.KnightTarget:Remove()
				end
				data.KnightTarget = nil
			end
		end

		--red button
		if player:HasCollectible(enums.Items.RedButton) then
			if datatables.RedButton.Blastocyst then
				datatables.RedButton.Blastocyst.Visible = true
				datatables.RedButton.Blastocyst = false
			end
			if not datatables.PreRoomState then -- if room is not cleared
				for gridIndex = 1, room:GetGridSize() do -- get room size
					local grid = room:GetGridEntity(gridIndex)
					if grid then -- if grid ~= nil then
						if grid.VarData == datatables.RedButton.VarData then -- check button
							if grid.State ~= 0 then
								datatables.RedButton.PressCount = datatables.RedButton.PressCount + 1 -- button was pressed, increment 1
								room:RemoveGridEntity(gridIndex, 0, false) -- remove pressed button
								grid:Update()


								if datatables.RedButton.PressCount == datatables.RedButton.Limit - 2 then
									game:GetHUD():ShowFortuneText("Please,",  "don't touch the button!")
								elseif  datatables.RedButton.PressCount == datatables.RedButton.Limit - 1 then
									game:GetHUD():ShowFortuneText("Push the button!!!")
								end


								if datatables.RedButton.PressCount >= datatables.RedButton.Limit then -- get limit, no more buttons for this room


									datatables.RedButton.PressCount = 0 -- set press counter to 0
									local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.FART, 0, grid.Position, Vector.Zero, nil)
									effect:SetColor(Color(2.5,0,0,1,0,0,0),50,1, false, false) -- poof effect
									datatables.RedButton.Blastocyst = Isaac.Spawn(EntityType.ENTITY_BLASTOCYST_BIG, 0, 0, room:GetCenterPos(), Vector.Zero, nil) -- spawn blastocyst
									datatables.RedButton.Blastocyst.Visible = false
									datatables.RedButton.Blastocyst:ToNPC().State = NpcState.STATE_JUMP
								else
									functions.SpawnButton(player, room) -- spawn new button
									local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, grid.Position, Vector.Zero, nil)
									effect:SetColor(datatables.RedColor,50,1, false, false) -- poof effect
								end
							end
						end
					end
				end
			end
		end

		--- lost flower
		if player:HasTrinket(enums.Trinkets.LostFlower) and player:GetEternalHearts() > 0 then -- if you get eternal heart, add another one
			player:AddEternalHearts(1)
		end
		
		-- tome of the dead
		if player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == enums.Items.TomeDead and Input.IsActionPressed(ButtonAction.ACTION_ITEM, player.ControllerIndex) then
			if player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY) < Isaac.GetItemConfig():GetCollectible(enums.Items.TomeDead).MaxCharges and player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY) > 0 then
				if functions.UseTomeDeadSouls(player, enums.Items.TomeDead, player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY)) then
					player:AnimateCollectible(enums.Items.TomeDead, "UseItem")
				end
				player:SetActiveCharge(0, ActiveSlot.SLOT_PRIMARY)
			end
		end
		
		
		--- rubik's dice
		if datatables.RubikDice.ScrambledDices[player:GetActiveItem(ActiveSlot.SLOT_PRIMARY)] then -- if player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == enums.Items.RubikDiceScrambled0 then
			local scrambledice = player:GetActiveItem(ActiveSlot.SLOT_PRIMARY)
			if player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY) >= Isaac.GetItemConfig():GetCollectible(scrambledice).MaxCharges then
				--player:RemoveCollectible(scrambledice) -- scrambledice
				player:AddCollectible(enums.Items.RubikDice)
				player:SetActiveCharge(3, ActiveSlot.SLOT_PRIMARY)
			elseif player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY) > 0 and Input.IsActionPressed(ButtonAction.ACTION_ITEM, player.ControllerIndex) then
				local rng = player:GetCollectibleRNG(scrambledice)
				local Newdice = datatables.RubikDice.ScrambledDicesList[rng:RandomInt(#datatables.RubikDice.ScrambledDicesList)+1]
				functions.RerollTMTRAINER(player, scrambledice)
				--player:RemoveCollectible(scrambledice) -- scrambledice
				player:AddCollectible(Newdice) --Newdice
				player:SetActiveCharge(0, ActiveSlot.SLOT_PRIMARY)
			end
		end
		--- tea bag
		if player:HasTrinket(enums.Trinkets.TeaBag) then
			--TrinketType.TRINKET_GOLDEN_FLAG
			--pickup.SubType < 32768
			local removeRadius = datatables.TeaBag.Radius
			local numTrinket = player:GetTrinketMultiplier(enums.Trinkets.TeaBag)
			--if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX) then numTrinket = numTrinket + 1 end
			removeRadius = removeRadius * numTrinket
			for _, effect in pairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.SMOKE_CLOUD)) do
				if effect.Position:Distance(player.Position) < removeRadius then
					if not effect.SpawnerType then
						effect:Remove()
					elseif effect.SpawnerType ~= EntityType.ENTITY_PLAYER then
						effect:Remove()
					end
				end
			end
		end
		--- COPY from Edith mod ------------
		--- white knight
		if player:HasCollectible(enums.Items.WhiteKnight, true) then
			if not data.HasWhiteKnight then
				data.HasWhiteKnight = true
				player:AddNullCostume(datatables.WhiteKnight.Costume)
			end
			if data.Jumped and sprite:GetAnimation() == "TeleportUp" then
				player.FireDelay = player.MaxFireDelay-1 -- it can pause some charging attacks (better way to remove tears in TearInit callback but meh)

				player.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
				player.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE

				if player:IsExtraAnimationFinished() then
					player:PlayExtraAnimation("TeleportDown")
				end
			end
			if data.Jumped and sprite:GetAnimation() == "TeleportDown" then
				local nearest = 5000
				local JumpPosition = functions.GetNearestEnemy(player.Position)
				if player.Position:Distance(JumpPosition) == 0 then
					for gridIndex = 1, room:GetGridSize() do
						if room:GetGridEntity(gridIndex) then
							if room:GetGridEntity(gridIndex):ToDoor() then
								if room:GetGridEntity(gridIndex):ToDoor():GetVariant() ~= 7 then
									local newPos = Isaac.GetFreeNearPosition(room:GetGridPosition(gridIndex), 1)
									if player.Position:Distance(newPos) < nearest then
										JumpPosition = newPos
										nearest = player.Position:Distance(newPos)
									end
								end
							end
						end
					end
				end
				player.Position = JumpPosition
			end
			if data.Jumped and sprite:IsFinished("TeleportDown") then
				data.Jumped = nil
				--data.JumpPosition = nil

				player.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
				if player.CanFly then
					player.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
				else
					player.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
				end
				for _, entity in pairs(Isaac.GetRoomEntities()) do
					--EntityType.ENTITY_HOST
					--EntityType.ENTITY_MOBILE_HOST
					--EntityType.ENTITY_FLOATING_HOST
					if entity:IsVulnerableEnemy() and entity:IsActiveEnemy() then
						if entity.Position:Distance(player.Position) > datatables.BlackKnight.BlastRadius and entity.Position:Distance(player.Position) <= datatables.BlackKnight.BlastRadius*2.5 then
							entity.Velocity = (entity.Position - player.Position):Resized(datatables.BlackKnight.BlastKnockback*(2/3))
						end
					elseif entity.Type == EntityType.ENTITY_PICKUP and entity.Position:Distance(player.Position) <= datatables.BlackKnight.PickupDistance then
						entity = entity:ToPickup()
						if datatables.BlackKnight.ChestVariant[entity.Variant] and entity.SubType ~= 0 then
							if entity.Variant == PickupVariant.PICKUP_BOMBCHEST then
								entity:TryOpenChest()
							end
							entity.Position = player.Position
							entity.Velocity = Vector.Zero
						else
							entity.Position = player.Position
							entity.Velocity = Vector.Zero
						end
					end
				end
				functions.BlastDamage(datatables.BlackKnight.BlastRadius, datatables.BlackKnight.BlastDamage + player.Damage/2, datatables.BlackKnight.BlastKnockback, player)
				local gridEntity = room:GetGridEntityFromPos(player.Position)
				if gridEntity then
					if gridEntity.Desc.Type == GridEntityType.GRID_PIT and gridEntity.Desc.State ~= 1 then
						if room:HasLava() then
							local splash = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BIG_SPLASH, 0, player.Position, Vector.Zero, player):ToEffect()
							splash.Color = Color(1.2, 0.8, 0.1, 1, 0, 0, 0)
							splash.SpriteScale = Vector(0.75, 0.75)
						elseif room:HasWaterPits() or room:HasWater() then
							local splash = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BIG_SPLASH, 0, player.Position, Vector.Zero, player):ToEffect()
							splash.SpriteScale = Vector(0.75, 0.75)
						end
					end
				elseif room:HasWater() then
					--sfx:Play(SoundEffect.SOUND_WATERSPLASH, 1, 0, false, 1, 0)
					local splash = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BIG_SPLASH, 0, player.Position, Vector.Zero, player):ToEffect()
					splash.SpriteScale = Vector(0.75, 0.75)
				else
					sfx:Play(SoundEffect.SOUND_STONE_IMPACT, 1, 0, false, 1, 0)
					--game:SpawnParticles(player.Position, EffectVariant.TOOTH_PARTICLE, 3, 2, _, 0)
				end
				game:ShakeScreen(10)
				player.Velocity = Vector.Zero
				--player.ControlsEnabled = true
			end
		else
			if data.HasWhiteKnight then
				player:TryRemoveNullCostume(datatables.WhiteKnight.Costume)
				data.HasWhiteKnight = false
			end
		end
		--- red scissors
		if player:HasTrinket(enums.Trinkets.RedScissors) then
			if not datatables.RedScissorsMod then
				datatables.RedScissorsMod = true
			end
		else
			if datatables.RedScissorsMod then
				datatables.RedScissorsMod = false
			end
		end

		--- viridian
		if player:HasCollectible(enums.Items.Viridian) then
			if not data.HasItemViridian then
				data.HasItemViridian = true
				player.SpriteOffset = Vector(player.SpriteOffset.X, player.SpriteOffset.Y - datatables.Viridian.FlipOffsetY)
				player:GetSprite().FlipX = true

				player.SpriteRotation = 180 -- 180 degree rotation
			end
		else
			if data.HasItemViridian then
				data.HasItemViridian = nil
				player.SpriteOffset = Vector(player.SpriteOffset.X, player.SpriteOffset.Y + datatables.Viridian.FlipOffsetY)
				player.SpriteRotation = 0
				player:GetSprite().FlipX = false
				--player:GetSprite():Update()
			end
		end
		--- brain queue (better holy water mod)
		local brains = Isaac.FindByType(EntityType.ENTITY_FAMILIAR, datatables.NadabBrain.Variant)
		if #brains > 0 then
			local nadabBrainAmount = functions.GetItemsCount(player, enums.Items.NadabBrain)
			local highest --= nil
			for _, fam in pairs(brains) do
				local famData = fam:GetData()
				famData.IsHighest = false
				if fam.Visible then
					if nadabBrainAmount == 1 or highest == nil then
						highest = fam
						famData.IsHighest = true
					else
						if highest.FrameCount < fam.FrameCount then
							highest:GetData().IsHighest = false
							famData.IsHighest = true
							highest = fam
						end
					end
				end
			end
		end
		---Heart Transplant
		if player:HasCollectible(enums.Items.HeartTransplant) then
			if player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == enums.Items.HeartTransplant then
				local activeCharge = player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY)
				local activeMaxCharge = Isaac.GetItemConfig():GetCollectible(enums.Items.HeartTransplant).MaxCharges
				
				if activeCharge == activeMaxCharge then -- discharge item on full charge
					
					data.HeartTransplantDelay = data.HeartTransplantDelay or datatables.HeartTransplant.DischargeDelay
					data.HeartTransplantUseCount = data.HeartTransplantUseCount or 1
					local missValue = 1
					if data.HeartTransplantUseCount >= #datatables.HeartTransplant.ChainValue then
						missValue = 2
					end
					data.HeartTransplantDelay = data.HeartTransplantDelay - missValue
					if data.HeartTransplantDelay <= 0 then
						data.HeartTransplantActualCharge = 0
						player:DischargeActiveItem(ActiveSlot.SLOT_PRIMARY)
						functions.HeartTranslpantFunc(player)
						if data.HeartTransplantUseCount > 1 then
							data.HeartTransplantUseCount = data.HeartTransplantUseCount - 1
						end
						sfx:Play(SoundEffect.SOUND_HEARTBEAT, 500)
						if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
							local wisp = player:AddWisp(enums.Items.HeartTransplant, player.Position)
							if wisp then
								wisp:GetData().TemporaryWisp = true
							end
						end
						
					end
				else
					-- if item was used on not full charge
					if data.HeartTransplantActualCharge and data.HeartTransplantActualCharge > 0 and Input.IsActionPressed(ButtonAction.ACTION_ITEM, player.ControllerIndex) then
						if data.HeartTransplantUseCount then
							if data.HeartTransplantActualCharge > 1 then
								if data.HeartTransplantActualCharge > datatables.HeartTransplant.ChainValue[data.HeartTransplantUseCount][4] then 
									data.HeartTransplantActualCharge = data.HeartTransplantActualCharge - datatables.HeartTransplant.ChainValue[data.HeartTransplantUseCount][4]
								end
							end
							player:SetActiveCharge(data.HeartTransplantActualCharge, ActiveSlot.SLOT_PRIMARY)
							functions.HeartTranslpantFunc(player)
						end
					else
						local charge = 1
						if data.HeartTransplantUseCount and data.HeartTransplantUseCount > 0 then
							charge = data.HeartTransplantUseCount
						end
						charge = datatables.HeartTransplant.ChainValue[charge][4]
						data.HeartTransplantActualCharge = data.HeartTransplantActualCharge or 0
						data.HeartTransplantActualCharge = data.HeartTransplantActualCharge + charge
						player:SetActiveCharge(data.HeartTransplantActualCharge, ActiveSlot.SLOT_PRIMARY)
					end
				end
			else -- if item changed (pick another item or swap)
				if data.HeartTransplantActualCharge then
					data.HeartTransplantActualCharge = 0
					functions.HeartTranslpantFunc(player)
				end
			end
		else
			if data.HeartTransplantActualCharge then
				data.HeartTransplantUseCount = nil
				data.HeartTransplantActualCharge = nil
				functions.HeartTranslpantFunc(player)
			end
		end
		
		
		--[[
		if player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == enums.Items.TomeDead and Input.IsActionPressed(ButtonAction.ACTION_ITEM, player.ControllerIndex) then
			if player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY) < Isaac.GetItemConfig():GetCollectible(scrambledice).MaxCharges and player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY) > 0 then
				if functions.UseTomeDeadSouls(player, enums.Items.TomeDead, player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY)) then
					player:AnimateCollectible(enums.Items.TomeDead, "UseItem")
				end
				player:SetActiveCharge(0, ActiveSlot.SLOT_PRIMARY)
			end
		end
		--]]
		if data.usedTome then
			data.usedTome = data.usedTome -1
			if data.usedTome <= 0 then
				data.usedTome = nil
			end
		end
		
		
		-- tome of the dead
		if player:HasCollectible(enums.Items.TomeDead) and not data.usedTome then
			
			data.CollectedSouls = data.CollectedSouls or 0
			if data.CollectedSouls >= 10 then
				
				for slot = 0, 2 do
					if player:GetActiveItem(slot) == enums.Items.TomeDead then
						
						local a_charge = player:GetActiveCharge(slot)
						local b_charge = player:GetBatteryCharge(slot)
						local max_charge = Isaac.GetItemConfig():GetCollectible(enums.Items.TomeDead).MaxCharges
						
						if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) then
							if a_charge + b_charge  < 2*max_charge then
								data.CollectedSouls = data.CollectedSouls - 10
								player:SetActiveCharge(a_charge + b_charge +1, slot)
								sfx:Play(SoundEffect.SOUND_BATTERYCHARGE)
							end
						else
							if a_charge < max_charge then
								data.CollectedSouls = data.CollectedSouls - 10
								player:SetActiveCharge(a_charge +1, slot)
								sfx:Play(SoundEffect.SOUND_BATTERYCHARGE)
							end
						end
						break
					end
				end
			end
			
			if data.CollectedSouls < 10 then
				local lilGhosts = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.ENEMY_GHOST, 0)
				if #lilGhosts > 0 then
					for _, lilg in pairs(lilGhosts) do
						if lilg.Position:Distance(player.Position) < 25 then
							lilg:Remove()
							sfx:Play(SoundEffect.SOUND_SOUL_PICKUP)
							data.CollectedSouls = data.CollectedSouls + 1
						end
					end
				end
			end
		end		
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, EclipsedMod.onPEffectUpdate)
--- PLAYER COLLISION --
function EclipsedMod:onPlayerCollision(player, collider)
	local data = player:GetData()
	local tempEffects = player:GetEffects()

	--- long elk
	if data.ElkKiller and tempEffects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_MARS) and collider:ToNPC() then --collider:IsVulnerableEnemy() and collider:IsActiveEnemy() then  -- player.Velocity ~= Vector.Zero
		if functions.CheckJudasBirthright(player) then
			functions.CircleSpawn(player, 50, 0, EntityType.ENTITY_EFFECT, EffectVariant.FIRE_JET, 0)
		end
		if not collider:IsVulnerableEnemy() then
			game:ShakeScreen(10)
			collider:Kill()
		else
			if collider:GetData().ElkKillerTick then
				if game:GetFrameCount() - collider:GetData().ElkKillerTick >= datatables.LongElk.TeleDelay then
					collider:GetData().ElkKillerTick = nil
				end
			else
				--data.ElkKiller = false
				collider:GetData().ElkKillerTick = game:GetFrameCount()
				collider:TakeDamage(datatables.LongElk.Damage, DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(player), 0)
				sfx:Play(SoundEffect.SOUND_DEATH_CARD)
				--sfx:Play(SoundEffect.SOUND_DEATH_CARD, 1, 2, false, 1, 0) --sfx:Play(ID, Volume, FrameDelay, Loop, Pitch, Pan)
				game:ShakeScreen(10)
				player:SetMinDamageCooldown(datatables.LongElk.InvFrames)
			end
		end
	end

	--- abihu
	if player:GetPlayerType() == enums.Characters.Abihu then
		if collider:ToNPC() then
			collider:AddBurn(EntityRef(player), 100, 2*player.Damage)
		end
	end

end
EclipsedMod:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, EclipsedMod.onPlayerCollision)
--- POST UPDATE --
function EclipsedMod:onUpdate()
	local level = game:GetLevel()
	local room = game:GetRoom()
	
	
	
	--Apocalypse card
	if datatables.Apocalypse.Room then
		if level:GetCurrentRoomIndex() == datatables.Apocalypse.Room then -- meh. bad solution. but anyway. poop created in this room will be red (it will run in loop, until you leave current room. Why? Cause poop doesn't spawn immediately)
			for gridIndex = 1, room:GetGridSize() do -- get room size
				local grid = room:GetGridEntity(gridIndex)
				if grid then
					if grid:ToPoop() then
						if grid:GetVariant() == 0 then
							grid:SetVariant(1)
							grid:Init(datatables.Apocalypse.RNG:RandomInt(Random())+1)
							grid:PostInit()
							grid:Update()
						end
					end
				end
			end
		end
	end

	if level:GetCurses() & enums.Curses.Carrion > 0 then
		for gridIndex = 1, room:GetGridSize() do -- get room size
			local grid = room:GetGridEntity(gridIndex)
			if grid and grid:ToPoop() and grid:GetVariant() == 0 then

				grid:SetVariant(1)
				grid:Init(grid:GetRNG():RandomInt(Random())+1)
				grid:PostInit()
				grid:Update()
			end
		end
	end

	if level:GetCurses() & enums.Curses.Envy > 0 then
		local shopItems = Isaac.FindInRadius(room:GetCenterPos(), 5000, EntityPartition.PICKUP)
		if #shopItems > 0 then
			if datatables.EnvyCurseIndex == nil then
				datatables.EnvyCurseIndex = myrng:RandomInt(Random())+1
			end
			for _, pickup in pairs(shopItems) do
				if pickup.Type ~= EntityType.ENTITY_SLOT then
					pickup = pickup:ToPickup()
					if pickup:IsShopItem() and pickup.OptionsPickupIndex ~= datatables.EnvyCurseIndex then
						pickup.OptionsPickupIndex = datatables.EnvyCurseIndex
					end
				end
			end
		end
	end

	--curse void reroll countdown
	if not room:HasCurseMist() then
		if datatables.VoidCurseReroll then
			datatables.VoidCurseReroll = datatables.VoidCurseReroll - 1
			if datatables.VoidCurseReroll <= 0 then
				for _, enemy in pairs(Isaac.FindInRadius(room:GetCenterPos(), 5000, EntityPartition.ENEMY)) do
					if enemy:IsVulnerableEnemy() and enemy:IsActiveEnemy() then
						game:RerollEnemy(enemy)
						enemy:GetData().VoidCurseNoDevolve = true
					end
				end
				datatables.VoidCurseReroll = nil
			end
		end
	end

	--player
	for playerNum = 0, game:GetNumPlayers()-1 do
		local player = game:GetPlayer(playerNum):ToPlayer()
		local data = player:GetData()
		--local tempEffects = player:GetEffects()
		--local pType = player:GetPlayerType()

		--FloppyDisk
		--if player:HasCollectible(enums.Items.FloppyDisk) and #datatables.FloppyDisk.Items > 0 then
		local savetable = functions.modDataLoad()
		if player:HasCollectible(enums.Items.FloppyDisk) and #savetable.FloppyDiskItems > 0 then
			player:RemoveCollectible(enums.Items.FloppyDisk)
			player:AddCollectible(enums.Items.FloppyDiskFull)
			--elseif player:HasCollectible(enums.Items.FloppyDiskFull) and #datatables.FloppyDisk.Items == 0 then
		elseif player:HasCollectible(enums.Items.FloppyDiskFull) and #savetable.FloppyDiskItems == 0 then
			player:RemoveCollectible(enums.Items.FloppyDiskFull)
			player:AddCollectible(enums.Items.FloppyDisk)
		end

		if not player:HasCurseMistEffect() and not player:IsCoopGhost() then
			-- tea fungus
			if player:HasTrinket(enums.Trinkets.TeaFungus) and not room:HasWater() and not room:IsClear() and room:GetFrameCount() <= 2  then
				if room:GetFrameCount() == 1 then
					local enemies = Isaac.FindInRadius(player.Position, 5000, EntityPartition.ENEMY)
					if #enemies > 0 then -- prevent turning enemies into poop
						for _, enemy in pairs(enemies) do
							if enemy:IsVulnerableEnemy() and enemy:IsActiveEnemy() and not enemy:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
								enemy:AddEntityFlags(EntityFlag.FLAG_FRIENDLY)
								enemy:GetData().TeaFungused = true
							end
						end
					end
				elseif room:GetFrameCount() == 2 then
					player:UseActiveItem(CollectibleType.COLLECTIBLE_FLUSH, datatables.MyUseFlags_Gene)
					if sfx:IsPlaying(SoundEffect.SOUND_FLUSH) then
						sfx:Stop(SoundEffect.SOUND_FLUSH)
					end
					--elseif room:GetFrameCount() == 3 then
					local enemies = Isaac.FindInRadius(player.Position, 5000, EntityPartition.ENEMY)
					if #enemies > 0 then
						for _, enemy in pairs(enemies) do
							if enemy:IsVulnerableEnemy() and enemy:IsActiveEnemy() and enemy:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) and enemy:GetData().TeaFungused then
								enemy:ClearEntityFlags(EntityFlag.FLAG_FRIENDLY)
								enemy:GetData().TeaFungused = nil
							end
						end
					end
				end
			end

			--- abyss cartridge
			if player:HasTrinket(enums.Trinkets.AbyssCart) and player:IsDead() and player:GetExtraLives() == 0 then
				for _, elems in pairs(datatables.AbyssCart.SacrificeBabies) do
					if player:HasCollectible(elems[1]) then
						player:RemoveCollectible(elems[1])
						player:AddCollectible(CollectibleType.COLLECTIBLE_1UP)
						--tempEffects:AddCollectibleEffect(CollectibleType.COLLECTIBLE_1UP)
						local numTrinket = player:GetTrinketMultiplier(enums.Trinkets.AbyssCart)-1
						local rngTrinket = player:GetTrinketRNG(enums.Trinkets.AbyssCart)
						if rngTrinket:RandomFloat() > numTrinket * datatables.AbyssCart.NoRemoveChance then
							functions.RemoveThrowTrinket(player, enums.Trinkets.AbyssCart, datatables.TrinketDespawnTimer)
						end
						break
					end
				end
			end

			-- player dead
			if player:IsDead() then --and not player:WillPlayerRevive() then
				--witch paper
				if player:HasTrinket(enums.Trinkets.WitchPaper) then
					data.WitchPaper = 2
					if game:GetRoom():GetType() == RoomType.ROOM_DUNGEON and game:GetRoom():GetRoomConfigStage() == 35 then 
						Isaac.ExecuteCommand("stage 13")
					end
					--Isaac.ExecuteCommand("rewind")
					player:UseActiveItem(CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS, datatables.MyUseFlags_Gene)
				end
			end

			-- limb
			if data.LimbActive then --- make it so this effect saved until next floor and if you don't get any health kill you
				game:Darken(1, 1)
			end

			if player:IsDead() then
				if player:GetExtraLives() == 0 and player:HasCollectible(enums.Items.Limb) and not data.LimbActive then -- and player:GetBrokenHearts() < 12 then -- and not player:WillPlayerRevive()
					player:UseCard(Card.CARD_SOUL_LAZARUS, datatables.MyUseFlags_Gene)
					player:SetMinDamageCooldown(datatables.Limb.InvFrames)
					data.LimbActive = true
					player:UseCard(Card.CARD_SOUL_LOST, datatables.MyUseFlags_Gene)
					game:Darken(1, 3)
				end
				if player:HasCollectible(enums.Items.CharonObol) then
					player:RemoveCollectible(enums.Items.CharonObol)
				end
			end
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_POST_UPDATE, EclipsedMod.onUpdate)

--- NEW LEVEL --
function EclipsedMod:onNewLevel()
	local level = game:GetLevel()
	local room = game:GetRoom()
	datatables.OblivionCardErasedEntities = {}
	
	if #Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.ITEM_WISP)> 0 then
		for _, fam in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR)) do
			if fam:GetData().AddNextFloor then
				local ppl = fam:GetData().AddNextFloor:ToPlayer()
				local data = ppl:GetData()
				data.WispedQueue = data.WispedQueue or {}
				table.insert(data.WispedQueue, {fam, true})
			end
		end
	end
	
	if datatables.PandoraJarGift then
		datatables.PandoraJarGift = nil
	end
	

	if datatables.ModdedBombas then datatables.ModdedBombas = {} end
	if datatables.TetrisItems then datatables.TetrisItems = nil end
	if datatables.ZeroMilestoneItems then datatables.ZeroMilestoneItems = nil end

	-- player
	for playerNum = 0, game:GetNumPlayers()-1 do
		local player = game:GetPlayer(playerNum)
		local data = player:GetData()
		local tempEffects = player:GetEffects()

		--surrogate conception
		--if data.SurrogateBirth then data.SurrogateBirth = nil end
		if data.BeastCounter and level:GetStage() ~= LevelStage.STAGE8 then
			data.BeastCounter = nil
		end
		if data.LostWoodenCross then data.LostWoodenCross = nil end
		
		--- agony box
		if player:HasCollectible(enums.Items.AgonyBox, true) then
			for slot = 0, 2 do
				if player:GetActiveItem(slot) == enums.Items.AgonyBox then
					local activeMaxCharge = Isaac.GetItemConfig():GetCollectible(enums.Items.AgonyBox).MaxCharges -- max charge of item
					local activeCharge = player:GetActiveCharge(slot) -- item charge
					local batteryCharge = player:GetBatteryCharge(slot) -- extra charge (battery item)
					local newCharge = 0
					if activeCharge == activeMaxCharge and player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) and batteryCharge < activeMaxCharge then -- battery charge
						newCharge = activeCharge + batteryCharge + 1
					elseif activeCharge < activeMaxCharge then
						newCharge = activeCharge + 1
					end
					if newCharge > 0 then
						player:SetActiveCharge(newCharge, slot)
						if not sfx:IsPlaying(SoundEffect.SOUND_ITEMRECHARGE) then
							sfx:Play(SoundEffect.SOUND_ITEMRECHARGE)
						end
					end
				end
			end
		end

		--lililith
		if data.LililithDemonSpawn then
			for i = 1, #data.LililithDemonSpawn do -- remove all item effects
				data.LililithDemonSpawn[i][3] = 0
			end
		end

		-- unbidden
		if player:GetPlayerType() == enums.Characters.Unbidden then
			local killWisp = true
			if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
				killWisp = false
			end
			functions.AddItemFromWisp(player, killWisp)
		end
		
		
		--[[
		if player:GetPlayerType() == enums.Characters.UnbiddenB then
			if not data.BeastCounter then
				data.LevelRewindCounter = 1
			end
		end	
		--]]

		-- memory fragment
		if player:HasTrinket(enums.Trinkets.MemoryFragment) and data.MemoryFragment and #data.MemoryFragment > 0 then
			local maxim = player:GetTrinketMultiplier(enums.Trinkets.MemoryFragment) + 2 --(X + 2 = 3) - if X = 1
			local count = 1
			for i = #data.MemoryFragment, 1, -1 do
				if count <= maxim then
					functions.DebugSpawn(data.MemoryFragment[i][1], data.MemoryFragment[i][2], room:GetRandomPosition(1))
					count = count +1
				end
			end
		end
		if data.MemoryFragment then data.MemoryFragment = {} end
		
		-- limb
		if data.LimbActive then
			if tempEffects:HasNullEffect(NullItemID.ID_LOST_CURSE) then
				tempEffects:RemoveNullEffect(NullItemID.ID_LOST_CURSE, 2)
			end
			data.LimbActive = false
		end

		--red lotus
		if player:HasCollectible(enums.Items.RedLotus) and player:GetBrokenHearts() > 0 then
			player:AddBrokenHearts(-1)
			--if not data.RedLotusDamage then data.RedLotusDamage = 0 end
			data.RedLotusDamage = data.RedLotusDamage or 0
			local numRedLotus = functions.GetItemsCount(player, enums.Items.RedLotus)
			data.RedLotusDamage = data.RedLotusDamage + (datatables.RedLotus.DamageUp * numRedLotus)
			player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
			player:EvaluateItems()
		end
		if player:HasCollectible(enums.Items.VoidKarma) then
			if not data.KarmaStats then
				data.KarmaStats = {
				["Damage"] = 0,
				["Firedelay"] = 0,
				["Shotspeed"] = 0,
				["Range"] = 0,
				["Speed"] = 0,
				["Luck"] = 0,
				}
			end
			local multi = 2
			if data.StateDamaged then
				multi = data.StateDamaged
				data.StateDamaged = nil
			end
			multi = multi * functions.GetItemsCount(player, enums.Items.VoidKarma)
			data.KarmaStats.Damage = data.KarmaStats.Damage + (datatables.VoidKarma.DamageUp * multi)
			--local firedelay_cache = data.KarmaStats.Firedelay
			--if player.MaxFireDelay > 5 then
			data.KarmaStats.Firedelay = data.KarmaStats.Firedelay - (datatables.VoidKarma.TearsUp * multi)
			--else
			--	data.KarmaStats.Firedelay = player.MaxFireDelay - data.KarmaStats.Firedelay
			--end
			data.KarmaStats.Shotspeed = data.KarmaStats.Shotspeed + (datatables.VoidKarma.ShotSpeedUp * multi)
			data.KarmaStats.Range = data.KarmaStats.Range + (datatables.VoidKarma.RangeUp * multi)
			data.KarmaStats.Speed = data.KarmaStats.Speed + (datatables.VoidKarma.SpeedUp * multi)
			data.KarmaStats.Luck = data.KarmaStats.Luck + (datatables.VoidKarma.LuckUp * multi)
			player:AddCacheFlags(datatables.VoidKarma.EvaCache)
			player:EvaluateItems()
			player:AnimateHappy()
			sfx:Play(SoundEffect.SOUND_1UP) -- play 1up sound
		end
		-- reset modded bombas table
		

	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, EclipsedMod.onNewLevel)

--- NEW ROOM --
function EclipsedMod:onNewRoom()
	local room = game:GetRoom()
 	local level = game:GetLevel()
	if datatables.NoJamming then datatables.NoJamming = nil end
	datatables.PreRoomState = room:IsClear()
	if not room:HasCurseMist() then
		
		local wisps = Isaac.FindInRadius(room:GetCenterPos(), 5000, EntityPartition.FAMILIAR)
		if #wisps > 0 then
			for _, wisp in pairs(wisps) do
				if wisp.Variant == FamiliarVariant.WISP and (wisp:GetData().TemporaryWisp or datatables.TemporaryWisps[wisp.SubType]) then
					wisp:Remove()
					wisp:Kill()
				end
			end	
		end
		
		if room:GetType() == RoomType.ROOM_DEVIL or (room:GetType() == RoomType.ROOM_BOSS and room:GetBossID() == 24) then --24 - satan; 55 - mega satan
			local trinkets = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, enums.Trinkets.XmasLetter)
			if #trinkets > 0 then
				for _, trinket in pairs(trinkets) do
					trinket:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_MYSTERY_GIFT)
				end
				sfx:Play(SoundEffect.SOUND_SATAN_GROW, 1, 2, false, 1.7)
			end
		end
		--curses
		--enums.Curses.Warden
		if room:GetType() ~= RoomType.ROOM_BOSS and level:GetCurses() & enums.Curses.Warden > 0 then
			for gridIndex = 1, room:GetGridSize() do -- get room size
				local grid = room:GetGridEntity(gridIndex)
				if grid and grid:ToDoor() then -- and grid:GetVariant() == DoorVariant.DOOR_LOCKED then -- and grid.State == 1 then
					local door = grid:ToDoor()
					if door:GetVariant() == DoorVariant.DOOR_LOCKED then
						--local doorPos = room:GetDoorSlotPosition(door.Slot)
						door:SetVariant(DoorVariant.DOOR_LOCKED_DOUBLE)
						--door.ExtraVisible = true
						-- so the issue is ExtraSprite not loading. I tried LoadGrapihics and etc. with sprite, but no luck
						-- well We need fuction similar to door:SetLocked(true) or :Bar()
						--door:SetLocked(true)
					end
				end
			end
		end

		-- secrets curse
		if level:GetCurses() & enums.Curses.Secrets > 0 then --and (room:GetType() ~= RoomType.ROOM_SECRET or room:GetType() ~= RoomType.ROOM_SUPERSECRET) then
			for gridIndex = 1, room:GetGridSize() do -- get room size
				local grid = room:GetGridEntity(gridIndex)
				if grid and grid:ToDoor() and (grid:ToDoor().TargetRoomType == RoomType.ROOM_SECRET or grid:ToDoor().TargetRoomType == RoomType.ROOM_SUPERSECRET) then
					grid:ToDoor():SetVariant(DoorVariant.DOOR_HIDDEN)
					grid:ToDoor():Close(true)
					grid:PostInit()
				end
			end
		end

		-- fool curse
		if level:GetCurses() & enums.Curses.Fool > 0 and room:GetType() == RoomType.ROOM_DEFAULT then
			if not room:IsFirstVisit() and myrng:RandomFloat() < datatables.FoolThreshold then
				room:RespawnEnemies()
				for gridIndex = 1, room:GetGridSize() do -- get room size
					local grid = room:GetGridEntity(gridIndex)
					if grid and grid:ToDoor()  then
						grid:ToDoor():Open()
					end
				end
				room:SetClear(true)
				datatables.FoolCurseNoRewards = true
				--datatables.FoolCurseActive = 2
			end
		end
		--Void curse
		if level:GetCurses() & enums.Curses.Void > 0 and not room:IsClear() then
			if myrng:RandomFloat() < datatables.VoidThreshold then
				datatables.VoidCurseReroll = 0
				game:ShowHallucination(0, BackdropType.NUM_BACKDROPS)
				game:GetPlayer(0):UseActiveItem(CollectibleType.COLLECTIBLE_D12, datatables.MyUseFlags_Gene)
			end
		end
		-- curse Emperor
		if level:GetCurses() & enums.Curses.Emperor > 0 and level:GetCurrentRoomIndex() > 0 and not room:IsMirrorWorld() and not level:IsAscent() and room:GetType() == RoomType.ROOM_BOSS and level:GetStage() ~= LevelStage.STAGE7 then
			for slot = 0, DoorSlot.NUM_DOOR_SLOTS do
				if room:GetDoor(slot) and room:GetDoor(slot):ToDoor().TargetRoomType == RoomType.ROOM_DEFAULT then
					room:RemoveDoor(slot)
				end
			end
		end
	end
	-- Apocalypse card
	if datatables.Apocalypse.Room then
		datatables.Apocalypse.Room = nil
		datatables.Apocalypse.RNG = nil
	end

	--player
	for playerNum = 0, game:GetNumPlayers()-1 do
		local player = game:GetPlayer(playerNum)
		local data = player:GetData()
		local tempEffects = player:GetEffects()
		
		if data.UsedKittenSkip2 then data.UsedKittenSkip2 = nil end
		if data.UsedSecretLoveLetter then data.UsedSecretLoveLetter = false end

		--ancestral crypt
		if data.CryptUsed then
			player.Position = Vector(120, 165)
			data.CryptUsed = nil
		end
		-- maze memory
		if data.MazeMemoryUsed then
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
		-- decay
		if data.DecayLevel then
			functions.TrinketRemove(player, TrinketType.TRINKET_APPLE_OF_SODOM)
			data.DecayLevel = nil
		end
		-- Corruption
		if data.CorruptionIsActive then
			data.CorruptionIsActive = nil
			player:TryRemoveNullCostume(datatables.Corruption.CostumeHead)
			local activeItem = player:GetActiveItem(ActiveSlot.SLOT_PRIMARY)
			if activeItem ~= 0 then
				player:RemoveCollectible(activeItem)
			end
		end
		-- soul nadab and abihu
		if data.UsedSoulNadabAbihu then
			data.UsedSoulNadabAbihu = nil
		end
		-- deus ex card
		if data.DeuxExLuck then
			data.DeuxExLuck = nil
			player:AddCacheFlags(CacheFlag.CACHE_LUCK) -- remove luck effect
			player:EvaluateItems()
		end
		-- long elk
		if data.ElkKiller then data.ElkKiller = false end
		-- bleeding grimoire
		if data.UsedBG then
			if not player:HasEntityFlags(EntityFlag.FLAG_BLEED_OUT) then
				player:TryRemoveNullCostume(datatables.BG.Costume)
				data.UsedBG = false
			end
		end
		
		if room:IsFirstVisit() then
		
			if data.UsedLoopCard and (room:GetType() == RoomType.ROOM_SECRET or room:GetType() == RoomType.ROOM_SUPERSECRET) then
				data.UsedLoopCard = nil
				--player:UseActiveItem(CollectibleType.COLLECTIBLE_DADS_KEY, datatables.MyUseFlags_Gene)
				player:UseCard(Card.CARD_GET_OUT_OF_JAIL, datatables.MyUseFlags_Gene)
				if sfx:IsPlaying(SoundEffect.SOUND_GOLDENKEY) then
					sfx:Stop(SoundEffect.SOUND_GOLDENKEY)
				end
				
			end
			
			if room:GetType() == RoomType.ROOM_CHEST then
				if data.UsedWheatFieldsCard then
					data.UsedWheatFieldsCard = nil
					room:TurnGold()
					for _, entity in pairs(Isaac.GetRoomEntities()) do
						if entity.Type == EntityType.ENTITY_PICKUP then
							functions.TurnPickupsGold(entity:ToPickup())
						end
					end
				end
			elseif room:GetType() == RoomType.ROOM_CHALLENGE then
				if data.UsedGroveCard then
					room:SetAmbushDone(false)
					data.UsedGroveCard = nil
					for _, entity in pairs(Isaac.GetRoomEntities()) do
						if entity.Type == EntityType.ENTITY_PICKUP then
							entity:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, 0)
							break
						end
					end
				elseif data.UsedBattleFieldCard then
					data.UsedBattleFieldCard = nil
					room:SetAmbushDone(false)
				end
			elseif room:GetType() == RoomType.ROOM_SUPERSECRET then
				if data.UsedVampireMansionCard then
					data.UsedVampireMansionCard = nil
					Isaac.Spawn(6, 5, 0, Isaac.GetFreeNearPosition(room:GetCenterPos(), 40), Vector.Zero, nil)
				elseif data.UsedSwampCard then
					data.UsedSwampCard = nil
					Isaac.Spawn(6, 18, 0, Isaac.GetFreeNearPosition(room:GetCenterPos(), 40), Vector.Zero, nil)
				elseif data.UsedCemeteryCard then
					data.UsedCemeteryCard = nil
					game:ShowHallucination(0, BackdropType.DARKROOM)
					if sfx:IsPlaying(SoundEffect.SOUND_DEATH_CARD) then
						sfx:Stop(SoundEffect.SOUND_DEATH_CARD)
					end
					for _, entity in pairs(Isaac.GetRoomEntities()) do
						if entity.Type == EntityType.ENTITY_PICKUP then
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
		end
		
		
		if not player:HasCurseMistEffect() and not player:IsCoopGhost() then
		
			if player:GetPlayerType() == enums.Characters.UnbiddenB then
				
				data.UnbiddenUsedHolyCard = 0
				local holyMantles = tempEffects:GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_HOLY_MANTLE)
				
				if player:HasTrinket(TrinketType.TRINKET_WOODEN_CROSS) and not data.LostWoodenCross then
					data.UnbiddenUsedHolyCard = data.UnbiddenUsedHolyCard +1
				end
				
				if player:HasCollectible(CollectibleType.COLLECTIBLE_HOLY_MANTLE, true) then
					data.UnbiddenUsedHolyCard = data.UnbiddenUsedHolyCard +1
				end
				if player:HasCollectible(CollectibleType.COLLECTIBLE_DOGMA) then
					data.UnbiddenUsedHolyCard = data.UnbiddenUsedHolyCard +1
				end	
				if player:HasCollectible(CollectibleType.COLLECTIBLE_BLANKET) and room:GetType() == RoomType.ROOM_BOSS and not room:IsClear() then
					data.UnbiddenUsedHolyCard = data.UnbiddenUsedHolyCard +1
				end
				
				
				--print(holyMantles, data.UnbiddenUsedHolyCard) 
				--[[
				if holyMantles == data.UnbiddenUsedHolyCard then
					tempEffects:RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE)
				end
				--]]
				
			end
			
			if room:IsFirstVisit() and player:HasCollectible(enums.Items.StoneScripture) then
				
				if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) then 
					data.UsedStoneScripture = 6 
				else
					data.UsedStoneScripture = 3
				end
				
			end

			
				
			if room:IsFirstVisit() and player:HasTrinket(enums.Trinkets.BrokenJawbone) and (room:GetType() == RoomType.ROOM_SECRET or room:GetType() == RoomType.ROOM_SUPERSECRET) then
				for _ = 1, player:GetTrinketMultiplier(enums.Trinkets.BrokenJawbone) do
					Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DIRT_PATCH, 0, Isaac.GetFreeNearPosition(room:GetCenterPos(), 0), Vector.Zero, nil)
				end
			end			
				
			--xmax letter
			if room:IsFirstVisit() and player:HasTrinket(enums.Trinkets.XmasLetter) then
				if player:GetTrinketRNG(enums.Trinkets.XmasLetter):RandomFloat() <= datatables.XmasLetter.Chance * player:GetTrinketMultiplier(enums.Trinkets.XmasLetter) then
					player:UseActiveItem(CollectibleType.COLLECTIBLE_FORTUNE_COOKIE, datatables.MyUseFlags_Gene)
					if sfx:IsPlaying(SoundEffect.SOUND_FORTUNE_COOKIE) then
						sfx:Stop(SoundEffect.SOUND_FORTUNE_COOKIE)
					end
				end
			end
			--penance
			if not room:IsClear() and player:HasTrinket(enums.Trinkets.Penance) then
				local rngTrinket = player:GetTrinketRNG(enums.Trinkets.Penance)
				local numTrinket = player:GetTrinketMultiplier(enums.Trinkets.Penance)
				for _, entity in pairs(Isaac.GetRoomEntities()) do
					if entity:ToNPC() and entity:IsActiveEnemy() and entity:IsVulnerableEnemy() and not entity:GetData().PenanceRedCross and rngTrinket:RandomFloat() < datatables.Penance.Chance * numTrinket then
						entity:GetData().PenanceRedCross = player
						local redCross = Isaac.Spawn(EntityType.ENTITY_EFFECT, datatables.Penance.Effect, 0, entity.Position, Vector.Zero, nil):ToEffect()
						redCross.Color = datatables.Penance.Color
						redCross:GetData().PenanceRedCrossEffect = true
						redCross.Parent = entity
					end
				end
			end
			--surrogate conception
			if data.SurrogateFams and #data.SurrogateFams > 0 then
				for _, fam in pairs(data.SurrogateFams) do
					tempEffects:AddCollectibleEffect(fam, false, 1)
				end
			end
			--lililith
			functions.LililithReset() -- update items
			-- limb
			if data.LimbActive then
				tempEffects:AddNullEffect(NullItemID.ID_LOST_CURSE, true, 1)
			end
			--red button
			if player:HasCollectible(enums.Items.RedButton) and not datatables.PreRoomState then
				functions.NewRoomRedButton(player, room) -- spawn new button
			end
			--red pill
			if data.RedPillDamageUp then
				if not room:IsClear() then
					tempEffects:AddNullEffect(NullItemID.ID_WAVY_CAP_1, false, 1)
				end
				game:ShowHallucination(0, BackdropType.DICE)
				--if sfx:IsPlaying(SoundEffect.SOUND_DEATH_CARD) then
				sfx:Stop(SoundEffect.SOUND_DEATH_CARD)
				--end
			end
			--BlackKnight
			if player:HasCollectible(enums.Items.BlackKnight, true) then
				if data.KnightTarget then
					if data.KnightTarget:Exists() then data.KnightTarget:Remove() end
					data.KnightTarget = nil
				end
				player.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
				if player.CanFly then
					player.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
				else
					player.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
				end
			end
			--duckling
			if player:HasCollectible(enums.Items.RubberDuck) then
				if room:IsFirstVisit() then
					functions.EvaluateDuckLuck(player, data.DuckCurrentLuck + 1)
				elseif data.DuckCurrentLuck > 0 then -- luck down while you have temp.luck
					functions.EvaluateDuckLuck(player, data.DuckCurrentLuck - 1)
				end
			end
			--ivory
			if data.IvoryOilBatteryEffect then -- or Render it
				if data.IvoryOilBatteryEffect:Exists() then
					data.IvoryOilBatteryEffect.Position = Vector(player.Position.X, player.Position.Y-70)
				else
					data.IvoryOilBatteryEffect = nil
				end
			end
			if player:HasCollectible(enums.Items.IvoryOil) and room:IsFirstVisit() and not room:IsClear() then
				local chargingEffect = false -- leave it as nil
				for slot = 0, 2 do
					if player:GetActiveItem(slot) ~= 0 then --and chargingActive then
						local charge = 1
						if room:GetRoomShape() > 7 then charge = 2 end
						local activeItem = player:GetActiveItem(slot) -- active item on given slot
						local activeCharge = player:GetActiveCharge(slot) -- item charge
						local batteryCharge = player:GetBatteryCharge(slot) -- extra charge (battery item)
						local activeMaxCharge = Isaac.GetItemConfig():GetCollectible(activeItem).MaxCharges -- max charge of item
						local activeChargeType = Isaac.GetItemConfig():GetCollectible(activeItem).ChargeType -- get charge type (normal, timed, special)
						if activeChargeType == 0 then -- if normal
							if player:NeedsCharge(slot) then
								if activeCharge >= activeMaxCharge and batteryCharge < activeMaxCharge then
									batteryCharge = batteryCharge + charge
									player:SetActiveCharge(batteryCharge+activeCharge, slot)
								else
									activeCharge = activeCharge + charge
									player:SetActiveCharge(activeCharge, slot)
								end
								chargingEffect = slot
								break
							elseif activeCharge >= activeMaxCharge and batteryCharge < activeMaxCharge then
								batteryCharge = batteryCharge + charge
								player:SetActiveCharge(batteryCharge+activeCharge, slot)
								chargingEffect = slot
								break
							end
						elseif activeChargeType == 1 then -- if timed
							if player:NeedsCharge(slot) then
								if activeCharge >= activeMaxCharge and batteryCharge < activeMaxCharge then
									player:SetActiveCharge(2*activeMaxCharge, slot)
								else
									player:SetActiveCharge(activeMaxCharge, slot)
								end
								chargingEffect = slot
								break
							elseif activeCharge >= activeMaxCharge and batteryCharge < activeMaxCharge then
								player:SetActiveCharge(2*activeMaxCharge, slot)
								chargingEffect = slot
								break
							end
						end

					end
				end
				if chargingEffect then
					data.IvoryOilBatteryEffect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BATTERY, 0, Vector(player.Position.X, player.Position.Y-70), Vector.Zero, nil)
					sfx:Play(SoundEffect.SOUND_BATTERYCHARGE, 1, 0, false, 1, 0)
				end
			end
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, EclipsedMod.onNewRoom)
--- CLEAN AWARD --
function EclipsedMod:onRoomClear() --rng, spawnPosition
	local room = game:GetRoom()
	local level = game:GetLevel()
	--red button
	functions.RemoveRedButton(room)
	-- jamming curse
	if room:GetType() ~= RoomType.ROOM_BOSS then
		if level:GetCurses() & enums.Curses.Jamming > 0 and not room:HasCurseMist() then --room:GetType() ~= RoomType.ROOM_BOSSRUSH
			if myrng:RandomFloat() < datatables.JammingThreshold and not datatables.NoJamming then
				game:ShowHallucination(5, 0)
				room:RespawnEnemies()
				datatables.NoJamming = true
				for _, ppl in pairs(Isaac.FindInRadius(room:GetCenterPos(), 5000, EntityPartition.PLAYER)) do
					ppl:ToPlayer():SetMinDamageCooldown(60)
					--ppl.Position = Isaac.GetFreeNearPosition(room:GetDoorSlotPosition(level.EnterDoor), 20) --and/or teleport to enter door
				end
				return true
			end
		end
	end

	if datatables.FoolCurseNoRewards then
		datatables.FoolCurseNoRewards = nil
		if room:GetType() ~= RoomType.ROOM_BOSS then
			return true
		end
	end

	---players
	for playerNum = 0, game:GetNumPlayers()-1 do
		local player = game:GetPlayer(playerNum)
		local playerType = player:GetPlayerType()
		local data = player:GetData()
		local tempEffects = player:GetEffects()
		--queen of spades
		
		if player:GetPlayerType() == enums.Characters.UnbiddenB then
			if not data.BeastCounter then data.LevelRewindCounter = 1 end
		end	
		
		if not player:HasCurseMistEffect() and not player:IsCoopGhost() then

			if player:HasCollectible(CollectibleType.COLLECTIBLE_GLYPH_OF_BALANCE) then
				if playerType == enums.Characters.Nadab or playerType == enums.Characters.Abihu then
					player:AddBombs(15)
					data.GlyphBalanceTrigger = true
				elseif playerType == enums.Characters.Unbidden then
					if player:GetBoneHearts() > 0 then
						local boneHearts = player:GetBoneHearts()*2
						player:AddHearts(boneHearts)
					end
				elseif playerType == enums.Characters.UnbiddenB then
					if not player:HasCollectible(CollectibleType.COLLECTIBLE_ALABASTER_BOX) then
						player:AddSoulHearts(24)
					end
					--data.GlyphBalanceTrigger = true
				end
			end

			if player:HasTrinket(enums.Trinkets.QueenSpades) then
				local rng = player:GetTrinketRNG(enums.Trinkets.QueenSpades)
				local numTrinket = player:GetTrinketMultiplier(enums.Trinkets.QueenSpades)
				if rng:RandomFloat() < datatables.QueenSpades.Chance * numTrinket then
					local num = 3
					local chance = rng:RandomFloat()
					if chance < 0.05 then num = 0 
					elseif chance < 0.1 then num = 1
					elseif chance < 0.15 then num = 2
					end
					local pos = Isaac.GetFreeNearPosition(room:GetCenterPos(), 50)
					Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pos, Vector.Zero, nil)
					Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PORTAL_TELEPORT, num, pos, Vector.Zero, nil)
				end
			end

			if room:GetType() == RoomType.ROOM_BOSS and player:HasCollectible(enums.Items.SurrogateConception) then -- and not data.SurrogateBirth then
				data.SurrogateFams = data.SurrogateFams or {}
				--data.SurrogateBirth = true
				local rng = player:GetCollectibleRNG(enums.Items.SurrogateConception)
				local randFam = table.remove(datatables.SurrogateConceptionFams, rng:RandomInt(#datatables.SurrogateConceptionFams)+1)
				tempEffects:AddCollectibleEffect(randFam, false, 1)
				table.insert(data.SurrogateFams, randFam)
			end
			
			if player:GetPlayerType() == enums.Characters.UnbiddenB then
				data.UnbiddenResetGameChance = data.UnbiddenResetGameChance or 100
				if data.UnbiddenResetGameChance < 100 then
					data.UnbiddenResetGameChance = data.UnbiddenResetGameChance + 0.25
				end
			end
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, EclipsedMod.onRoomClear)
--- CURSE EVAL --
function EclipsedMod:onCurseEval(curseFlags)
	local newCurse = LevelCurse.CURSE_NONE
	local player = game:GetPlayer(0)
	local curseTable = {}
	for _, value in pairs(enums.Curses) do
		if not (value == enums.Curses.Pride and game:GetLevel():GetStage() == LevelStage.STAGE4_3) and
		not (player:GetPlayerType() == enums.Characters.UnbiddenB and datatables.UnbiidenBannedCurses[value]) then
			table.insert(curseTable, value)
		end
		
	end
	
	local savetable = functions.modDataLoad()
	local SpecialCursesAvtice = savetable.SpecialCursesAvtice
	if SpecialCursesAvtice == true or SpecialCursesAvtice == nil then
		if curseFlags == LevelCurse.CURSE_NONE then
			if myrng:RandomFloat() < datatables.CurseChance then
				newCurse = table.remove(curseTable, myrng:RandomInt(#curseTable)+1)
			end
		end
	end

	if Isaac.GetChallenge() == enums.Challenges.Lobotomy then
		datatables.VoidThreshold = 1
		curseFlags = curseFlags | enums.Curses.Void
	else
		if datatables.VoidThreshold > 0.15 then
			datatables.VoidThreshold = 0.15
		end
	end

	
	if player:GetPlayerType() == enums.Characters.UnbiddenB then
		if not (player:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE) or player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)) then
			local cc_curse = table.remove(curseTable, myrng:RandomInt(#curseTable)+1)
			newCurse = newCurse | cc_curse
		end
	end

	return curseFlags | newCurse
end

EclipsedMod:AddCallback(ModCallbacks.MC_POST_CURSE_EVAL, EclipsedMod.onCurseEval)
--- NPC DEVOLVE --
function EclipsedMod:onDevolve(entity)
	if entity:GetData().VoidCurseNoDevolve or entity:HasMortalDamage() then -- prevent enemies from rerolling when die
		entity:GetData().VoidCurseNoDevolve = nil
		return true
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_PRE_ENTITY_DEVOLVE, EclipsedMod.onDevolve)
--- NPC UPDATE --
function EclipsedMod:onUpdateNPC(entityNPC)
	entityNPC = entityNPC:ToNPC()
	local eData = entityNPC:GetData()
	
	-- secret love letter
	if entityNPC.FrameCount <= 1 and datatables.SecretLoveLetterAffectedEnemies and #datatables.SecretLoveLetterAffectedEnemies > 0 then
		
		if entityNPC.Type == datatables.SecretLoveLetterAffectedEnemies[1] and entityNPC.Variant == datatables.SecretLoveLetterAffectedEnemies[2] then
			sfx:Play(SoundEffect.SOUND_KISS_LIPS1)
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, entityNPC.Position, Vector.Zero, nil):SetColor(datatables.PinkColor,50,1, false, false) --:ToEffect()
			--entityNPC:AddEntityFlags(EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_CHARM|  EntityFlag.FLAG_PERSISTENT)
			entityNPC:AddCharmed(EntityRef(datatables.SecretLoveLetterAffectedEnemies[3]), -1)
		end
	end
	
	if eData then 
		if eData.LimbLocustTouch then
			if entityNPC:HasMortalDamage() then
				local purgesoul = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PURGATORY, 1, entityNPC.Position, Vector.Zero, nil):ToEffect() -- subtype = 0 is rift, 1 is soul
				purgesoul:GetSprite():Play("Charge", true)
			end
			eData.LimbLocustTouch = false
		end
		
		-- bleeding grimoire
		if eData.BG then
			eData.BG = eData.BG - 1
			if eData.BG == 0 and entityNPC:HasEntityFlags(EntityFlag.FLAG_BLEED_OUT) then
				entityNPC:ClearEntityFlags(EntityFlag.FLAG_BLEED_OUT)
			elseif eData.BG <= -25 then
				eData.BG = nil
			end
		end

		if eData.Frosted then
			eData.Frosted = eData.Frosted - 1
			if eData.Frosted == 0 then
				eData.Frosted = nil
				if entityNPC:HasEntityFlags(EntityFlag.FLAG_ICE) then
					entityNPC:ClearEntityFlags(EntityFlag.FLAG_ICE)
				end
			end
		end

		-- unbidden backstab aura
		if eData.BackStabbed then
			eData.BackStabbed = eData.BackStabbed - 1
			if eData.BackStabbed == 0 then
				eData.BackStabbed = nil
				if entityNPC:HasEntityFlags(EntityFlag.FLAG_BLEED_OUT) then
					entityNPC:ClearEntityFlags(EntityFlag.FLAG_BLEED_OUT)
				end
			end
		end
		if eData.Magnetized then
			eData.Magnetized = eData.Magnetized - 1
			if eData.Magnetized == 0 then
				eData.Magnetized = nil
				if entityNPC:HasEntityFlags(EntityFlag.FLAG_MAGNETIZED) then
					entityNPC:ClearEntityFlags(EntityFlag.FLAG_MAGNETIZED)
				end
			end
		end

		if eData.BaitedTomato then
			eData.BaitedTomato = eData.BaitedTomato - 1
			if eData.BaitedTomato == 0 then
				eData.BaitedTomato = nil
				entityNPC:ClearEntityFlags(EntityFlag.FLAG_BAITED)
			end
		end
		-- melted candle waxed
		if eData.Waxed then
			if eData.Waxed == datatables.MeltedCandle.FrameCount then entityNPC:ClearEntityFlags(EntityFlag.FLAG_BURN) end
			eData.Waxed = eData.Waxed - 1
			if entityNPC:HasMortalDamage() then
				local flame = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RED_CANDLE_FLAME, 0, entityNPC.Position, Vector.Zero, nil):ToEffect()
				flame.CollisionDamage = 23
				flame:SetTimeout(360)
			end
			if eData.Waxed <= 0 then eData.Waxed = nil end
		end
		-- penance
		if entityNPC:HasMortalDamage() and eData.PenanceRedCross then
			local ppl = eData.PenanceRedCross
			local timeout = datatables.Penance.Timeout
			functions.PenanceShootLaser(0, timeout, entityNPC.Position, ppl)
			functions.PenanceShootLaser(90, timeout, entityNPC.Position, ppl)
			functions.PenanceShootLaser(180, timeout, entityNPC.Position, ppl)
			functions.PenanceShootLaser(270, timeout, entityNPC.Position, ppl)
			eData.PenanceRedCross = false
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, EclipsedMod.onUpdateNPC)



--- NPC INIT --

function EclipsedMod:onEnemyInit(entity)
	local level = game:GetLevel()
	local room = game:GetRoom()
	entity = entity:ToNPC()
	-- oblivion card
	if datatables.OblivionCard and datatables.OblivionCardErasedEntities and #datatables.OblivionCardErasedEntities ~= 0 then
		for _, enemy in ipairs(datatables.OblivionCardErasedEntities) do
			if entity.Type == enemy[1] and entity.Variant == enemy[2] then
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, entity.Position, Vector.Zero, nil):SetColor(datatables.OblivionCard.PoofColor,50,1, false, false) --:ToEffect()
				entity:Remove()
				break
			end
		end
	end
	-- soul unbidden
	if datatables.Lobotomy and datatables.LobotomyErasedEntities and #datatables.LobotomyErasedEntities ~= 0 then
		for _, enemy in ipairs(datatables.LobotomyErasedEntities) do
			if entity.Type == enemy[1] and entity.Variant == enemy[2] then
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, entity.Position, Vector.Zero, nil):SetColor(datatables.OblivionCard.PoofColor,50,1, false, false) --:ToEffect()
				entity:Remove()
				break
			end
		end
	end

	-- delirious bum / cell
	if datatables.DeliriousBumCharm then
		entity:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
		datatables.DeliriousBumCharm = nil
    end
	datatables.datatables = datatables.DeliriumBeggarEnable or {}
	if not datatables.DeliriumBeggarBan[entity.Type] and entity:IsActiveEnemy() and entity:IsVulnerableEnemy() and not entity:IsBoss() and datatables.DeliriumBeggarEnable and not datatables.DeliriumBeggarEnable[tostring(entity.Type..entity.Variant)] then
		datatables.DeliriumBeggarEnable[tostring(entity.Type..entity.Variant)] = true
		datatables.DeliriumBeggarEnemies = datatables.DeliriumBeggarEnemies or {}
		table.insert(datatables.DeliriumBeggarEnemies, {entity.Type, entity.Variant})
	end

	if not room:HasCurseMist() then
		-- curse of Pride
		if level:GetCurses() & enums.Curses.Pride > 0  then
			if entity:IsActiveEnemy() and entity:IsVulnerableEnemy() and not entity:IsBoss() and not entity:IsChampion() and entity:GetDropRNG():RandomFloat() < datatables.PrideThreshold then
				
				local randNum = entity:GetDropRNG():RandomInt(26)
				if randNum == 6 then randNum = 25 end
				--entity:MakeChampion(Random()+1, -1, true) -- have buggy behaviour related to enemies which can't become champion becoming champion
				entity:Morph(entity.Type, entity.Variant, entity.SubType, randNum)
			end
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, EclipsedMod.onEnemyInit)
--- NPC DEATH --
function EclipsedMod:onNPCDeath(enemy)
	--local eData = enemy:GetData()
	if enemy:IsActiveEnemy(true) then
	--if not enemy:IsVulnerableEnemy() then
		for playerNum = 0, game:GetNumPlayers()-1 do
			local player = game:GetPlayer(playerNum)

			if not player:HasCurseMistEffect() and not player:IsCoopGhost() then
				
				if player:HasCollectible(enums.Items.TomeDead) and not player:HasCollectible(CollectibleType.COLLECTIBLE_VADE_RETRO) then
					local lilSoul = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ENEMY_GHOST, 0, enemy.Position, Vector.Zero, player):ToEffect() -- subtype = 0 is rift, 1 is soul
				end
				
				if player:HasCollectible(enums.Items.DMS) then
					local rng = player:GetCollectibleRNG(enums.Items.DMS)
					if rng:RandomFloat() < datatables.DMS.Chance then
						local purgesoul = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PURGATORY, 1, enemy.Position, Vector.Zero, player):ToEffect() -- subtype = 0 is rift, 1 is soul
						purgesoul:GetSprite():Play("Charge", true) -- set animation (skip appearing from rift)
						--purgesoul.Color = Color(0.1,0.1,0.1,1)
					end
				end

				if player:HasTrinket(enums.Trinkets.MilkTeeth) then
					local rng = player:GetTrinketRNG(enums.Trinkets.MilkTeeth)
					local numTrinket = player:GetTrinketMultiplier(enums.Trinkets.MilkTeeth)
					--if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX) then numTrinket = numTrinket + 1 end
					if rng:RandomFloat() < datatables.MilkTeeth.CoinChance * numTrinket then
						local randVector = RandomVector()*5
						local coin = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 1, enemy.Position, randVector, nil)
						coin:GetData().MilkTeethDespawn = datatables.MilkTeeth.CoinDespawnTimer --= 35
					end
				end
			end
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, EclipsedMod.onNPCDeath)
--- NPC TAKE DMG --
function EclipsedMod:onLaserDamage(entity, _, flags, source)
	local level = game:GetLevel()

	if level:GetCurses() & enums.Curses.Bishop > 0 and not entity:IsBoss() and entity:IsVulnerableEnemy() and entity:IsActiveEnemy() and entity:GetDropRNG():RandomFloat() < datatables.BishopThreshold then
		entity:SetColor(Color(0.3,0.3,1,1), 10, 100, true, false)
		return false
	end

	if flags & DamageFlag.DAMAGE_LASER == DamageFlag.DAMAGE_LASER and entity:IsVulnerableEnemy() and entity:IsActiveEnemy() and source.Entity and source.Entity:ToPlayer() then
		local player = source.Entity:ToPlayer()
		local data = player:GetData()
		if not player:HasCurseMistEffect() and not player:IsCoopGhost() then
			if player:HasCollectible(enums.Items.MeltedCandle) and not entity:GetData().Waxed then
				local rng = player:GetCollectibleRNG(enums.Items.MeltedCandle)
				if rng:RandomFloat() + player.Luck/100 >= datatables.MeltedCandle.TearChance then
					entity:AddFreeze(EntityRef(player), datatables.MeltedCandle.FrameCount)
					if entity:HasEntityFlags(EntityFlag.FLAG_FREEZE) then
						--entity:AddBurn(EntityRef(player), 1, player.Damage) -- the issue is Freeze stops framecount of entity, so it won't call NPC_UPDATE.
						entity:AddEntityFlags(EntityFlag.FLAG_BURN)          -- the burn timer doesn't update, so just add burn until npc have freeze
						entity:GetData().Waxed = datatables.MeltedCandle.FrameCount
						entity:SetColor(datatables.MeltedCandle.TearColor, datatables.MeltedCandle.FrameCount, 100, false, false)
					end
				end
			end
		end
		if data.UsedBG then -- and not entity:GetData().BG then --and player:HasEntityFlags(EntityFlag.FLAG_BLEED_OUT) then
			entity:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
			entity:GetData().BG = datatables.BG.FrameCount
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, EclipsedMod.onLaserDamage)
--- KNIFE COLLISION --
function EclipsedMod:onKnifeCollision(knife, collider) -- low
	if knife.SpawnerEntity then
		if knife.SpawnerEntity:ToPlayer() and collider:IsVulnerableEnemy() then
			local player = knife.SpawnerEntity:ToPlayer()
			local data = player:GetData()
			local entity = collider:ToNPC()
			--local eData = entity:GetData()
			if not player:HasCurseMistEffect() and not player:IsCoopGhost() then
				if player:HasCollectible(enums.Items.MeltedCandle) and not entity:GetData().Waxed then
					local rng = player:GetCollectibleRNG(enums.Items.MeltedCandle)
					if rng:RandomFloat() + player.Luck/100 >= datatables.MeltedCandle.TearChance then
						entity:AddFreeze(EntityRef(player), datatables.MeltedCandle.FrameCount)
						if entity:HasEntityFlags(EntityFlag.FLAG_FREEZE) then
							--entity:AddBurn(EntityRef(player), 1, player.Damage) -- the issue is Freeze stops framecount of entity, so it won't call NPC_UPDATE.
							entity:AddEntityFlags(EntityFlag.FLAG_BURN)          -- the burn timer doesn't update
							entity:GetData().Waxed = datatables.MeltedCandle.FrameCount
							entity:SetColor(datatables.MeltedCandle.TearColor, datatables.MeltedCandle.FrameCount, 100, false, false)
						end
					end
				end
			end
			-- bleeding grimoire
			if data.UsedBG then -- and not entity:GetData().BG then --and player:HasEntityFlags(EntityFlag.FLAG_BLEED_OUT) then
				entity:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
				entity:GetData().BG = datatables.BG.FrameCount
			end
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_PRE_KNIFE_COLLISION, EclipsedMod.onKnifeCollision) --KnifeSubType
--- TEARS UPDATE --
function EclipsedMod:onTearUpdate(tear)
	if not tear.SpawnerEntity then return end
	if not tear.SpawnerEntity:ToPlayer() then return end
	local tearData = tear:GetData()
	local tearSprite = tear:GetSprite()
	local room = game:GetRoom()
	local player = tear.SpawnerEntity:ToPlayer()
	local data = player:GetData()
	if tearData then
	if tearData.UnbiddenTear then
		tear.Color = datatables.UnbiddenBData.Stats.TEAR_COLOR
		tear.EntityCollisionClass = 0
		tear.Height = -25
		tear.Velocity = player:GetShootingInput() * player.ShotSpeed * 5
		--[[
		tearData.LastIter = tearData.LastIter or 0
		tearData.NewHeight = tearData.NewHeight or -25
		tearData.iterat = tearData.iterat or 1
		tear.Height = -30.5 + tearData.LastIter * 0.5
		if tearData.LastIter >= player:GetData().UnbiddenBDamageDelay then
			tearData.iterat = -1
		elseif tearData.LastIter <= 0 then
			tearData.iterat = 1
		end
		tearData.LastIter = tearData.LastIter + tearData.iterat
		--]]
		--[[
		if room:IsPositionInRoom(tear.Position, -100) then
			tear.Velocity = player:GetShootingInput() * player.ShotSpeed * 5
		else
			local bottom = room:GetBottomRightPos()
			local top = room:GetTopLeftPos()
			local newX = tear.Position.X
			local newY = tear.Position.Y
			--[
			if tear:HasTearFlags(TearFlags.TEAR_CONTINUUM) then
				if newX < top.X then
					newX = top.X
				elseif newX > bottom.X then
					newX = bottom.X
				end
				if newY < top.Y then
					newY = top.Y
				elseif newY > bottom.Y then
					newY = bottom.Y
				end
			else
			--]
			if not tear:HasTearFlags(TearFlags.TEAR_CONTINUUM) then
				tear.Velocity = Vector.Zero
				if newX < top.X then
					newX = newX + 10
				elseif newX > bottom.X then
					newX = newX -10
				end
				if newY < top.Y then
					newY = newY +10
				elseif newY > bottom.Y then
					newY = newY -10
				end
			end
			tear.Position = Vector(newX, newY)
		end
		--]]

		local prisms = Isaac.FindByType(3, 123)
		if #prisms > 0 then
			for _, prism in pairs(prisms) do
				if tear.Position:Distance(prism.Position) < 25 then
					--tear:Kill()
					data.LudoTearEnable = true
				end
			end
		end

		if player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY) or not player:HasCollectible(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE) or not data.BlindUnbidden then -- or player:HasCurseMistEffect() or player:IsCoopGhost() then
			tear:Kill()
		end
	elseif tearData.KnifeTear then
		tear.Visible = true
		tear.FallingAcceleration = 0
		tear.FallingSpeed = 0
		--tear.Velocity = tearData.InitVelocity
		tear.CollisionDamage = player.Damage * datatables.InfiniteBlades.DamageMulti
		--if tear.FrameCount == 1 then
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
		--end
		if not room:IsPositionInRoom(tear.Position, -100) then
			tear:Remove()
		end
	end
	end
	
	if data.UsedKittenSkip2 then
		tear:AddTearFlags(TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_PIERCING)
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, EclipsedMod.onTearUpdate)
--- TEARS COLLISION --
function EclipsedMod:onTearCollision(tear, collider) --tear, collider, low
	tear = tear:ToTear()
	--local tearData = tear:GetData()
	if tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer() then
		if collider:IsVulnerableEnemy() then
			local player = tear.SpawnerEntity:ToPlayer()
			local data = player:GetData()
			local entity = collider:ToNPC()
			--local eData = entity:GetData()
			if not player:HasCurseMistEffect() and not player:IsCoopGhost() then
				if player:HasCollectible(enums.Items.MeltedCandle) and not entity:GetData().Waxed then
					local rng = player:GetCollectibleRNG(enums.Items.MeltedCandle)
					if rng:RandomFloat() + player.Luck/100 >= datatables.MeltedCandle.TearChance then
						entity:AddFreeze(EntityRef(player), datatables.MeltedCandle.FrameCount)
						if entity:HasEntityFlags(EntityFlag.FLAG_FREEZE) then
							--entity:AddBurn(EntityRef(player), 1, 2*player.Damage) -- the issue is Freeze stops framecount of entity, so it won't call NPC_UPDATE.
							entity:AddEntityFlags(EntityFlag.FLAG_BURN )
							entity:GetData().Waxed = datatables.MeltedCandle.FrameCount
							entity:SetColor(datatables.MeltedCandle.TearColor, datatables.MeltedCandle.FrameCount, 100, false, false)
						end
					end
				end
			end
			if data.UsedBG then -- and not entity:GetData().BG then --and player:HasEntityFlags(EntityFlag.FLAG_BLEED_OUT) then
				entity:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
				entity:GetData().BG = datatables.BG.FrameCount
			end
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, EclipsedMod.onTearCollision)
--- OBLIVION CARD TEAR COLLISION --
function EclipsedMod:onTearOblivionCardCollision(tear, collider) --tear, collider, low
	tear = tear:ToTear()
	local tearData = tear:GetData()
	-- oblivion card
	if tearData.OblivionTear then
		if collider:ToNPC() then
			local player = tear.SpawnerEntity:ToPlayer()
			--local data = player:GetData()
			local enemy = collider:ToNPC()
			datatables.OblivionCardErasedEntities = datatables.OblivionCardErasedEntities or {}
			table.insert(datatables.OblivionCardErasedEntities, {enemy.Type, enemy.Variant})
			for _, entity in pairs(Isaac.FindInRadius(player.Position, 5000, EntityPartition.ENEMY)) do -- get monsters in room
				if entity.Type == enemy.Type and entity.Variant == enemy.Variant then
					Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, entity.Position, Vector.Zero, nil):SetColor(datatables.OblivionCard.PoofColor,50,1, false, false)
					entity:Remove()
				end
			end
			tear:Remove()
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, EclipsedMod.onTearOblivionCardCollision, TearVariant.CHAOS_CARD) -- datatables.OblivionCard.TearVariant)
--- OBLIVION CARD TEAR INIT --
function EclipsedMod:onOblivionTearInit(tear) -- card, player, useflag
	if functions.MongoHiddenWisp(tear) then
		return true
	elseif tear.SpawnerEntity:ToPlayer() then
		local player = tear.SpawnerEntity:ToPlayer()
		local data = player:GetData()
		-- oblivion card
		if data.UsedOblivionCard then
			--tear:ChangeVariant(datatables.OblivionCard.TearVariant)
			data.UsedOblivionCard = nil
			local tearData = tear:GetData()
			tearData.OblivionTear = true
			local sprite = tear:GetSprite()
			sprite:ReplaceSpritesheet(0, datatables.OblivionCard.SpritePath)
			sprite:LoadGraphics() -- replace sprite
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, EclipsedMod.onOblivionTearInit, TearVariant.CHAOS_CARD) --datatables.OblivionCard.TearVariant)

--- SECRET LOVE LETTER TEAR COLLISION --
function EclipsedMod:onLoveLetterCollision(tear, collider) --tear, collider, low
	tear = tear:ToTear()
	local tearData = tear:GetData()
	if tearData.SecretLoveLetter then
		if collider:ToNPC() and collider:IsActiveEnemy() and collider:IsVulnerableEnemy() and not collider:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
			tear:ChangeVariant(TearVariant.BLUE)
			tear:Remove()
			local player = tear.SpawnerEntity:ToPlayer()
			local enemy = collider:ToNPC()
			sfx:Play(SoundEffect.SOUND_KISS_LIPS1)

			if not enemy:IsBoss() and not datatables.SecretLoveLetter.BannedEnemies[enemy.Type] then
				datatables.SecretLoveLetterAffectedEnemies = datatables.SecretLoveLetterAffectedEnemies or {}
				datatables.SecretLoveLetterAffectedEnemies[1] = enemy.Type
				datatables.SecretLoveLetterAffectedEnemies[2] = enemy.Variant
				datatables.SecretLoveLetterAffectedEnemies[3] = player
				--table.insert(datatables.SecretLoveLetterAffectedEnemies, {enemy.Type, enemy.Variant})
				for _, entity in pairs(Isaac.FindInRadius(player.Position, 5000, EntityPartition.ENEMY)) do -- get monsters in room
					if entity.Type == enemy.Type and entity.Variant == enemy.Variant then
						Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, entity.Position, Vector.Zero, nil):SetColor(datatables.PinkColor,50,1, false, false)
						--entity:AddEntityFlags(EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_CHARM | EntityFlag.FLAG_PERSISTENT)
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
EclipsedMod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, EclipsedMod.onLoveLetterCollision, datatables.SecretLoveLetter.TearVariant)

--- PROJECTILES INIT --
function EclipsedMod:onProjectileInit(projectile)
	local level = game:GetLevel()
	local room = game:GetRoom()
	if not room:HasCurseMist() and projectile.SpawnerEntity then
		if Isaac.GetChallenge() == enums.Challenges.Magician or level:GetCurses() & enums.Curses.Magician > 0 and projectile:GetDropRNG():RandomFloat() <= datatables.MagicianThreshold then
			if not projectile.SpawnerEntity:IsBoss() and Isaac.GetChallenge() ~= enums.Challenges.Magician then
				projectile:AddProjectileFlags(ProjectileFlags.SMART)
			end
		end
		if level:GetCurses() & enums.Curses.Poverty > 0 then
			projectile:AddProjectileFlags(ProjectileFlags.GREED)
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_INIT, EclipsedMod.onProjectileInit)
--- INPUT ACTIONS --
function EclipsedMod:onInputAction(entity, inputHook, buttonAction)
	if entity and entity.Type == EntityType.ENTITY_PLAYER and not entity:IsDead() then
		local player = entity:ToPlayer()
		local sprite = player:GetSprite()
		--- COPY from Edith mod ------------
		if not player:HasCurseMistEffect() and not player:IsCoopGhost() then
			if player:HasCollectible(enums.Items.BlackKnight, true) then
				--if sprite:GetAnimation() == "BigJumpUp" or sprite:GetAnimation() == "BigJumpDown" then
				if datatables.BlackKnight.TeleportAnimations[sprite:GetAnimation()] then
					if buttonAction == ButtonAction.ACTION_BOMB or buttonAction == ButtonAction.ACTION_PILLCARD or buttonAction == ButtonAction.ACTION_ITEM then
						return false
					end
				end
				-- block movement
				if inputHook == 2 then
					if not player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_MEGA_MUSH) and not player:HasCollectible(CollectibleType.COLLECTIBLE_DOGMA) and not player:IsCoopGhost() then
						if buttonAction == ButtonAction.ACTION_LEFT or buttonAction == ButtonAction.ACTION_RIGHT or buttonAction == ButtonAction.ACTION_UP or buttonAction == ButtonAction.ACTION_DOWN then
							return 0
						end
					end
				end
			end
			if player:HasCollectible(enums.Items.WhiteKnight, true) then
				if datatables.BlackKnight.TeleportAnimations[sprite:GetAnimation()] then
					if buttonAction == ButtonAction.ACTION_BOMB or buttonAction == ButtonAction.ACTION_PILLCARD or buttonAction == ButtonAction.ACTION_ITEM then
						return false
					end
					if inputHook == 2 then
						if not player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_MEGA_MUSH) and not player:HasCollectible(CollectibleType.COLLECTIBLE_DOGMA) and not player:IsCoopGhost() then
							if buttonAction == ButtonAction.ACTION_LEFT or buttonAction == ButtonAction.ACTION_RIGHT or buttonAction == ButtonAction.ACTION_UP or buttonAction == ButtonAction.ACTION_DOWN then
								return 0
							end
						end
					end
				end
			end
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_INPUT_ACTION, EclipsedMod.onInputAction)
--- PILL INIT --
function EclipsedMod:onPostPillInit(pickup) -- pickup
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
EclipsedMod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, EclipsedMod.onPostPillInit, PickupVariant.PICKUP_PILL)
--- PICKUP INIT --
function EclipsedMod:onPostPickupInit(pickup)
	for playerNum = 0, game:GetNumPlayers()-1 do
		local player = game:GetPlayer(playerNum):ToPlayer()
		if not player:HasCurseMistEffect() and not player:IsCoopGhost() then
			local rng = pickup:GetDropRNG()
			
			if pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE then 
				if datatables.TetrisItems then 
					for cache_seed, cache_data in pairs(datatables.TetrisItems) do
						local seedItem = tostring(rng:GetSeed())
						if cache_seed == seedItem then
							local sprite = pickup:GetSprite()
							sprite:ReplaceSpritesheet(1, datatables.TetrisDicesQuestionMark)
							sprite:LoadGraphics()
						end
					end
				end
				if datatables.ZeroMilestoneItems then 
					for cache_seed, cache_data in pairs(datatables.ZeroMilestoneItems) do
						local seedItem = tostring(rng:GetSeed())
						if cache_seed == seedItem then
							pickup:GetData().ZeroMilestoneItem = true
						end
					end
				end
			end
			
			-- binder clip
			if player:HasTrinket(enums.Trinkets.BinderClip) then
				local numTrinket = player:GetTrinketMultiplier(enums.Trinkets.BinderClip)
				if datatables.BinderClip.DoublerChance * numTrinket > rng:RandomFloat() then
					local newSub = pickup.SubType
					if pickup.Variant == PickupVariant.PICKUP_HEART and newSub == HeartSubType.HEART_FULL then
						newSub = HeartSubType.HEART_DOUBLEPACK
					elseif pickup.Variant == PickupVariant.PICKUP_COIN and newSub == CoinSubType.COIN_PENNY then
						newSub = CoinSubType.COIN_DOUBLEPACK
					elseif pickup.Variant == PickupVariant.PICKUP_KEY and newSub == KeySubType.KEY_NORMAL then
						newSub = KeySubType.KEY_DOUBLEPACK
					elseif pickup.Variant == PickupVariant.PICKUP_BOMB and newSub == BombSubType.BOMB_NORMAL then
						newSub = BombSubType.BOMB_DOUBLEPACK
					end
					if newSub ~= pickup.SubType then
						pickup:Morph(pickup.Type, pickup.Variant, newSub, true, false, true)
					end
				end
			end
			
			if player:HasTrinket(enums.Trinkets.WarHand) and pickup.Variant == PickupVariant.PICKUP_BOMB then
				local numTrinket = player:GetTrinketMultiplier(enums.Trinkets.WarHand)
				if datatables.WarHandChance * numTrinket > rng:RandomFloat() then
					if pickup.SubType == BombSubType.BOMB_NORMAL then
						pickup:Morph(pickup.Type, pickup.Variant, BombSubType.BOMB_GIGA, true, false, true)
					elseif pickup.SubType == BombSubType.BOMB_DOUBLEPACK then
						pickup:Morph(pickup.Type, pickup.Variant, BombSubType.BOMB_GIGA, true, false, true)
						Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_GIGA, pickup.Position, Vector.Zero, nil)
					end
				end
			end
			
			--local data = player:GetData()
			-- if player has midas curse, turn all pickups into golden -> check chance
			if player:HasCollectible(enums.Items.MidasCurse) then
				if rng:RandomFloat() < datatables.MidasCurse.TurnGoldChance then
					functions.TurnPickupsGold(pickup:ToPickup())
					break
				end
			end
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, EclipsedMod.onPostPickupInit)
--- COIN UPDATE --
function EclipsedMod:onCoinUpdate(pickup)
	local pickupData = pickup:GetData()
	if pickupData.MilkTeethDespawn then
		pickupData.MilkTeethDespawn = pickupData.MilkTeethDespawn - 1
		if pickupData.MilkTeethDespawn <= 0 then
			pickup:Remove()
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, nil)
		elseif pickupData.MilkTeethDespawn <= 50 then
			pickup:SetColor(Color(1,1,1,math.sin(pickupData.MilkTeethDespawn*2),0,0,0),1,1,false,false)
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, EclipsedMod.onCoinUpdate, PickupVariant.PICKUP_COIN)
--- CARD UPDATE --
function EclipsedMod:DeliriousPickupsUpdate(pickup)
	if datatables.DeliObject.CheckGetCard[pickup.SubType] then
		local rng = pickup:GetDropRNG()
		local dataDeli = pickup:GetData()
		dataDeli.CycleTimer = dataDeli.CycleTimer or rng:RandomInt(datatables.DeliObject.CycleTimer) + datatables.DeliObject.CycleTimer
		dataDeli.CycleTimer = dataDeli.CycleTimer - 1
		if dataDeli.CycleTimer <= 0 then
			local newDeli = datatables.DeliObject.Variants[rng:RandomInt(#datatables.DeliObject.Variants)+1]
			if newDeli ~= pickup.SubType then
				pickup:ToPickup():Morph(pickup.Type, pickup.Variant, newDeli, true, false, true)
				dataDeli.CycleTimer = rng:RandomInt(datatables.DeliObject.CycleTimer) + datatables.DeliObject.CycleTimer
				--Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, nil).Color = Color(5,5,5,1)
				game:ShowHallucination(5, BackdropType.NUM_BACKDROPS)
			end
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, EclipsedMod.DeliriousPickupsUpdate, PickupVariant.PICKUP_TAROTCARD)
--- COLLECTIBLE UPDATE --
function EclipsedMod:CollectibleUpdate(pickup)
	if pickup.SubType ~= 0 then
		
		if Isaac.GetChallenge() == enums.Challenges.Potatoes then
			local yourOnlyFood = enums.Items.Potato
			if pickup.SubType ~= yourOnlyFood then
				pickup:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, yourOnlyFood, true, true, false)
			end
		else
			local player = Isaac.GetPlayer(0) -- so it would reroll only if main player has this trinket
			local data = pickup:GetData()
			local room = game:GetRoom()
			local roomType = room:GetType()
			local game_seed = game:GetSeeds():GetStartSeed()
			local pool = itemPool:GetPoolForRoom(roomType, game_seed)
			local roomIndex = game:GetLevel():GetCurrentRoomIndex()
			if pool == ItemPoolType.POOL_NULL then
				pool = ItemPoolType.POOL_TREASURE
			end
			
			if data.ZeroMilestoneItem and pickup.FrameCount%4 == 0 then
				datatables.ZeroMilestoneItems = datatables.ZeroMilestoneItems or {}
				local seedItem = tostring(pickup:GetDropRNG():GetSeed()) 
				datatables.ZeroMilestoneItems[seedItem] = nil
				local newItem = itemPool:GetCollectible(pool, false, pickup.InitSeed)
				pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, newItem, true, false, true)
				--pickup:AppearFast()
				pickup.Wait = 0
				pickup:GetData().ZeroMilestoneItem = true
				seedItem = tostring(pickup:GetDropRNG():GetSeed()) 
				datatables.ZeroMilestoneItems[seedItem] = true
				
			elseif player:HasTrinket(enums.Trinkets.Cybercutlet) and functions.GetCurrentDimension() ~= 2 and functions.CheckItemTags(pickup.SubType, ItemConfig.TAG_FOOD) then
				if not data.Cybercutlet then
					local newItem = itemPool:GetCollectible(pool, false, pickup.InitSeed)
					pickup:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, newItem, true, false, true)
					data.Cybercutlet = true
				else
					pickup:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, enums.Items.Potato, true, true, false)
				end
			end
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, EclipsedMod.CollectibleUpdate, PickupVariant.PICKUP_COLLECTIBLE)
--- COLLECTIBLE COLLISION --
function EclipsedMod:onItemCollision(pickup, collider)
	if collider:ToPlayer() then
		local player = collider:ToPlayer()
		if not player:HasCurseMistEffect() and not player:IsCoopGhost() then
			local room = game:GetRoom()
			local level = game:GetLevel()
			if level:GetCurses() & enums.Curses.Desolation > 0 and player:GetPlayerType() ~= enums.Characters.UnbiddenB and player:GetPlayerType() ~= enums.Characters.Unbidden and pickup:GetDropRNG():RandomFloat() < datatables.DesolationThreshold and pickup.SubType ~= 0 and functions.GetCurrentDimension() ~= 2 and level:GetCurrentRoomIndex() ~= GridRooms.ROOM_GENESIS_IDX  and room:GetType() ~= RoomType.ROOM_BOSSRUSH and not pickup:IsShopItem() and not functions.CheckItemTags(pickup.SubType, ItemConfig.TAG_QUEST) and not functions.CheckItemType(pickup.SubType) then

				if HeavensCall and functions.HeavensCall(room, level) then
					return
				end

				pickup:Remove()
				local wispItem = player:AddItemWisp(pickup.SubType, pickup.Position):ToFamiliar()
				wispItem:GetData().AddNextFloor = player

				sfx:Play(SoundEffect.SOUND_SOUL_PICKUP)
				return false
			end

			if functions.CheckItemTags(pickup.SubType, ItemConfig.TAG_FOOD) then
				if player:HasCollectible(enums.Items.MidasCurse) and datatables.MidasCurse.TurnGoldChance == datatables.MidasCurse.MaxGold then
					pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_GOLDEN)
					local rngMidasCurse = player:GetCollectibleRNG(enums.Items.MidasCurse)
					local coinNum = rngMidasCurse:RandomInt(8)+1 -- random number from 1 to 8
					for _ = 1, coinNum do
						local randVector = RandomVector()*coinNum
						Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 0, pickup.Position, randVector, player)
						--local coin = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 0, pickup.Position, randVector, player) --anyway turns into golden coin
					end
				end
			end

		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, EclipsedMod.onItemCollision, PickupVariant.PICKUP_COLLECTIBLE)
--- CARD COLLISION ---
function EclipsedMod:onCardsCollision(pickup, collider, _) --add --PickupVariant.PICKUP_SHOPITEM
	if collider:ToPlayer() then
		local player = collider:ToPlayer()
		local data = player:GetData()
		if not player:HasCurseMistEffect() and not player:IsCoopGhost() then
			if player:HasCollectible(enums.Items.NirlyCodex) then
				local cardType = Isaac.GetItemConfig():GetCard(pickup.SubType).CardType
				data.NirlySavedCards = data.NirlySavedCards or {}
				if datatables.NirlyOK[cardType] and #data.NirlySavedCards < datatables.NirlyCap then
				 	table.insert(data.NirlySavedCards, pickup.SubType)
					Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, nil):SetColor(Color(1,0,1) ,50,1, false, false)
					pickup:Remove()
					return false
				end
			end
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, EclipsedMod.onCardsCollision, PickupVariant.PICKUP_TAROTCARD)

--- PICKUP COLLISION --
function EclipsedMod:onItemCollision(pickup, collider, _) --add --PickupVariant.PICKUP_SHOPITEM
	if collider:ToPlayer() then
		local player = collider:ToPlayer()
		if not player:HasCurseMistEffect() and not player:IsCoopGhost() then
			if player:HasTrinket(enums.Trinkets.BinderClip) and pickup.Variant ~= PickupVariant.PICKUP_COLLECTIBLE and pickup.OptionsPickupIndex ~= 0 then
				pickup.OptionsPickupIndex = 0
			end
			
			if player:HasTrinket(enums.Trinkets.GoldenEgg) then
				
				local turnGold = nil
				
				if pickup.Variant == PickupVariant.PICKUP_HEART and pickup.SubType ~= HeartSubType.HEART_GOLDEN and pickup.SubType ~= HeartSubType.HEART_ETERNAL and pickup.SubType ~= HeartSubType.HEART_BONE then
				
					if pickup.SubType == HeartSubType.HEART_DOUBLEPACK then
						player:AddHearts(2)
					elseif pickup.SubType == HeartSubType.HEART_ROTTEN then
						player:AddBlueFlies(2, layer.Position, nil)
					end
					
					turnGold = HeartSubType.HEART_GOLDEN
				elseif pickup.Variant == PickupVariant.PICKUP_COIN and pickup.SubType ~= CoinSubType.COIN_GOLDEN then
				
					if pickup.SubType == CoinSubType.COIN_DOUBLEPACK then
						player:AddCoins(1)
					elseif pickup.SubType == CoinSubType.COIN_NICKEL then
						player:AddCoins(4)
					elseif pickup.SubType == CoinSubType.COIN_DIME then
						player:AddCoins(9)
					elseif pickup.SubType == CoinSubType.COIN_LUCKYPENNY then
						player:DonateLuck(1)
					end
				
					turnGold = CoinSubType.COIN_GOLDEN
				elseif pickup.Variant == PickupVariant.PICKUP_KEY and pickup.SubType ~= KeySubType.KEY_GOLDEN then
					if pickup.SubType == KeySubType.KEY_DOUBLEPACK then
						player:AddKeys(1)
					elseif pickup.SubType == KeySubType.KEY_CHARGED then
						Isaac.Spawn(pickup.Type,  PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_GOLDEN, pickup.Position, Vector.Zero, nil)
					end
					turnGold = KeySubType.KEY_GOLDEN
				elseif pickup.Variant == PickupVariant.PICKUP_BOMB and pickup.SubType ~= BombSubType.BOMB_GOLDEN then	
					
					if pickup.SubType == BombSubType.BOMB_DOUBLEPACK then
						player:AddBombs(1)
					elseif pickup.SubType == BombSubType.BOMB_GIGA then
						player:AddGigaBombs(1)
					end
					
					turnGold = BombSubType.BOMB_GOLDEN
				elseif pickup.Variant == PickupVariant.PICKUP_PILL and pickup.SubType ~= PillColor.PILL_GOLD then
					turnGold = PillColor.PILL_GOLD
				elseif pickup.Variant == PickupVariant.PICKUP_LIL_BATTERY and pickup.SubType ~= BatterySubType.BATTERY_GOLDEN then
					
					if pickup.SubType == BatterySubType.BATTERY_MEGA then
						for slot = 0, 2 do
							if player:GetActiveItem(slot) ~= 0 then
								local activeMaxCharge = Isaac.GetItemConfig():GetCollectible(player:GetActiveItem(slot)).MaxCharges
								--Isaac.GetItemConfig():GetCollectible(activeItem).ChargeType
								player:SetActiveCharge(2*activeMaxCharge, slot)
							end
						end
					end					
					
					turnGold = BatterySubType.BATTERY_GOLDEN
				elseif pickup.Variant == PickupVariant.PICKUP_TRINKET and pickup.SubType < TrinketType.TRINKET_GOLDEN_FLAG then
					turnGold = pickup.SubType + TrinketType.TRINKET_GOLDEN_FLAG
				end
				
				if turnGold then 
					pickup:Morph(pickup.Type, pickup.Variant, turnGold)
					local rngChance = player:GetTrinketRNG(enums.Trinkets.GoldenEgg):RandomFloat()
					local removeChance = datatables.GoldenEggChance * player:GetTrinketMultiplier(enums.Trinkets.GoldenEgg)
					if removeChance < rngChance then
						player:TryRemoveTrinket(enums.Trinkets.GoldenEgg)
					end
				end
			end			
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, EclipsedMod.onItemCollision)
--- HEART COLLISION --
function EclipsedMod:onHeartCollision(pickup, collider)
	if collider:ToPlayer() then
		local player = collider:ToPlayer()
		if not player:HasCurseMistEffect() and not player:IsCoopGhost() then
			if player:HasTrinket(enums.Trinkets.LostFlower) then
				local playerType = player:GetPlayerType()
				if playerType == PlayerType.PLAYER_THELOST or playerType == PlayerType.PLAYER_THELOST_B or player:GetPlayerType() == enums.Characters.UnbiddenB then  -- if player is Lost/T.Lost
					if pickup.SubType == HeartSubType.HEART_ETERNAL then
						player:UseCard(Card.CARD_HOLY,  datatables.MyUseFlags_Gene) -- give holy card effect
					end
				end
			end
			
			if pickup:GetData().Pomped then
				pickup:Remove()
				return true

			elseif player:HasTrinket(enums.Trinkets.Pompom) then
				local rng = player:GetTrinketRNG(enums.Trinkets.Pompom)
				local numTrinket = player:GetTrinketMultiplier(enums.Trinkets.Pompom) -- 1
				if rng:RandomFloat() < datatables.Pompom.Chance * numTrinket then --and player:GetHearts() == player:GetEffectiveMaxHearts()

					if pickup.SubType == HeartSubType.HEART_HALF then
						numTrinket = numTrinket
					elseif pickup.SubType == HeartSubType.HEART_FULL or pickup.SubType == HeartSubType.HEART_SCARED or pickup.SubType == HeartSubType.HEART_ROTTEN then
						numTrinket = numTrinket + 1
					elseif pickup.SubType == HeartSubType.HEART_DOUBLEPACK then
						numTrinket = numTrinket + 3
					else
						return nil
					end

					for _ = 1, numTrinket do
						local wisp = datatables.Pompom.WispsList[rng:RandomInt(#datatables.Pompom.WispsList)+1]
						player:AddWisp(wisp, pickup.Position, true)
					end
					pickup:Remove()
					sfx:Play(SoundEffect.SOUND_SOUL_PICKUP)
					pickup:GetData().Pomped = true
					return true

				end
			
			elseif player:HasTrinket(enums.Trinkets.GildedFork) then
				local rng = player:GetTrinketRNG(enums.Trinkets.GildedFork)
				local numTrinket = player:GetTrinketMultiplier(enums.Trinkets.GildedFork) -- 1
				
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
				pickup:GetData().Pomped = true
				return true
			end
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, EclipsedMod.onHeartCollision, PickupVariant.PICKUP_HEART)
--- BOMB COLLISION --
function EclipsedMod:onBombPickupCollision(pickup, collider)
	if collider:ToPlayer() then
		local player = collider:ToPlayer()
		if (player:GetPlayerType() == enums.Characters.Nadab or player:GetPlayerType() == enums.Characters.Abihu) then
			if player:HasGoldenBomb() and pickup.SubType == BombSubType.BOMB_GOLDEN then
				player:AddGoldenHearts(1)
			elseif player:HasFullHearts() and (pickup.SubType == BombSubType.BOMB_NORMAL or pickup.SubType == BombSubType.BOMB_DOUBLEPACK) then
				return false
			end
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, EclipsedMod.onBombPickupCollision, PickupVariant.PICKUP_BOMB)
--- CARD COLLISION --
function EclipsedMod:onDellCollision(pickup, collider) --pickup, collider, low
	if datatables.DeliObject.CheckGetCard[pickup.SubType] and collider:ToPlayer() then
		local player = collider:ToPlayer()
		for slot = 0, 3 do
			if datatables.DeliObject.CheckGetCard[player:GetCard(slot)] then
				pickup:Remove()
				player:SetCard(slot, pickup.SubType) --datatables.DeliObject.Variants[rng:RandomInt(#datatables.DeliObject.Variants)+1])
				sfx:Play(SoundEffect.SOUND_EDEN_GLITCH, 1, 0, false, 1, 0)
				game:ShowHallucination(5, BackdropType.NUM_BACKDROPS)
				--Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, nil).Color = Color(5,5,5,1)
				return true
			end
		end
		--end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, EclipsedMod.onDellCollision, PickupVariant.PICKUP_TAROTCARD)
--- TRINKET UPDATE --
function EclipsedMod:onTrinketUpdate(trinket)
	local dataTrinket = trinket:GetData()
	-- destroy trinket
	if dataTrinket.DespawnTimer then
		trinket.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		trinket.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
		if dataTrinket.DespawnTimer > 25 then -- just decrease timer
			dataTrinket.DespawnTimer = dataTrinket.DespawnTimer - 1
		elseif dataTrinket.DespawnTimer > 5 then -- start fading
			dataTrinket.DespawnTimer = dataTrinket.DespawnTimer - 1
			trinket:SetColor(Color(1, 1, 1, math.sin(dataTrinket.DespawnTimer*2), 0, 0, 0), 1, 1, false, false)
		else -- remove it
			trinket:Remove()
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, trinket.Position, Vector.Zero, nil) -- poof effect
			if trinket.SubType == enums.Trinkets.AbyssCart then -- abyss cartridge spawn eternal heart
				functions.DebugSpawn(PickupVariant.PICKUP_HEART, HeartSubType.HEART_ETERNAL, trinket.Position)
			end
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, EclipsedMod.onTrinketUpdate, PickupVariant.PICKUP_TRINKET)
--- GET CARD --
function EclipsedMod:onGetCard(rng, card) --, includePlayingCards, includeRunes, onlyRunes)
	if card == enums.Pickups.BannedCard then
		if rng:RandomFloat() > datatables.BannedCard.Chance then
			return enums.Pickups.DeliObjectCell
		end
	elseif card == enums.Pickups.RedPill or card == enums.Pickups.RedPillHorse then
		return enums.Pickups.DeliObjectCell
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_GET_CARD, EclipsedMod.onGetCard)
--- BOMB UPDATE --
function EclipsedMod:onBombUpdate(bomb)
	local bombSprite = bomb:GetSprite()
	local bombData = bomb:GetData()
	local level = game:GetLevel()
	local roomIndex = level:GetCurrentRoomIndex()
	local room = game:GetRoom()
	local bombSeed = bomb:GetDropRNG():GetSeed() -- ptr hash not gonna work cause it's game logic my ass
	
	if not room:HasCurseMist() then
		-- curse of bell
		if level:GetCurses() & enums.Curses.Bell > 0 and datatables.BellCurse[bomb.Variant] and bomb.FrameCount == 1 then
			bomb:Remove()
			Isaac.Spawn(bomb.Type, BombVariant.BOMB_GOLDENTROLL, 0, bomb.Position, bomb.Velocity, bomb.SpawnerEntity)
		end
		-- bomb init
		if bomb.FrameCount == 1 then
			if bomb.SpawnerEntity and bomb.SpawnerEntity:ToPlayer() then
				local player = bomb.SpawnerEntity:ToPlayer()
				local playerData = player:GetData()
				
				if not (bomb.Variant == BombVariant.BOMB_THROWABLE and not player:HasTrinket(enums.Trinkets.BlackPepper)) then -- apply effect to throwable

					if not datatables.ModdedBombas then datatables.ModdedBombas = {} end
					datatables.ModdedBombas[roomIndex] = datatables.ModdedBombas[roomIndex] or {}
					
					if not bombData.Mirror then
						--datatables.ModdedBombas[roomIndex][bomb.Index] = datatables.ModdedBombas[roomIndex][bomb.Index] or {}
						--if datatables.ModdedBombas[roomIndex] then--[bomb.index] then
						for _, cacheData in pairs(datatables.ModdedBombas[roomIndex]) do -- get bomb.index table items
							--local cacheData = cacheBomb
							if cacheData.Seed == bombSeed then
							--if cacheData.Position:Distance(bomb.Position) == 0 then
								if cacheData.Gravity then bombData.Gravity = true else bombData.Gravity = false end
								if cacheData.Compo then bombData.Compo = true else bombData.Compo = false end
								if cacheData.Mirror then bombData.Mirror = true else bombData.Mirror = false end
								if cacheData.Frosty then bombData.Frosty = true else bombData.Frosty = false end
								if cacheData.DeadEgg then bombData.DeadEgg = true else bombData.DeadEgg = false end
								if cacheData.Dicey then bombData.Dicey = true else bombData.Dicey = false end
								if cacheData.BobTongue then bombData.BobTongue = true else bombData.BobTongue = false end
								if cacheData.Charged then bombData.Charged = true else bombData.Charged = false end
								if cacheData.Bonny then bombData.Bonny = true else bombData.Bonny = false end
							end
						end
					end
					
					--if bombData.Mirror and not bomb.Parent then
					if bombData.Mirror and (not bomb.Parent or bomb.FrameCount == 0) then -- or (bomb.Variant == BombVariant.BOMB_THROWABLE) then -- don't make it elseif cause you need to check it 2 times (you = me from future)
						bomb:Remove() -- remove mirror bombs when entering room where you placed bomb. else it would be duplicated
					end
					
					if playerData.UsedSoulNadabAbihu then
						bomb:AddTearFlags(TearFlags.TEAR_BURN)
					end
					
					if player:HasCollectible(CollectibleType.COLLECTIBLE_NANCY_BOMBS) then
						if bombData.Dicey == nil and bomb:GetDropRNG():RandomFloat() < datatables.DiceBombs.NancyChance then
							functions.InitDiceyBomb(bomb, bombData)
						end
						if bombData.Gravity == nil and bomb:GetDropRNG():RandomFloat() < datatables.GravityBombs.NancyChance then
							functions.InitGravityBomb(bomb, bombData)
						end
						if bombData.Frosty == nil and bomb:GetDropRNG():RandomFloat() < datatables.FrostyBombs.NancyChance then
							functions.InitFrostyBomb(bomb, bombData)
						end
						if bombData.Charged == nil and bomb:GetDropRNG():RandomFloat() < datatables.BatteryBombs.NancyChance then
							functions.InitBatteryBomb(bomb, bombData)
						end
						if bombData.Bonny == nil and bomb:GetDropRNG():RandomFloat() < datatables.DeadBombs.NancyChance then
							functions.InitDeadBomb(bomb, bombData)
						end
					end
					
					-- bob's tongue
					if player:HasTrinket(enums.Trinkets.BobTongue) then
						bombData.BobTongue = true
						local fartRingEffect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.FART_RING, 0, bomb.Position, Vector.Zero, bomb):ToEffect()
						fartRingEffect:GetData().BobTongue = true
						fartRingEffect.Parent = bomb
						local numTrinket = player:GetTrinketMultiplier(enums.Trinkets.BobTongue)-1
						fartRingEffect.SpriteScale = fartRingEffect.SpriteScale * (0.8 + numTrinket*0.2)
					end
					
					-- dead egg
					if player:HasTrinket(enums.Trinkets.DeadEgg) then
						bombData.DeadEgg = true
					end

					--compo
					if player:HasCollectible(enums.Items.CompoBombs) and not datatables.CompoBombs.Baned[bomb.Variant] and bombData.Compo ~= false then
						bombData.Compo = true
						local redBomb = Isaac.Spawn(EntityType.ENTITY_BOMB, BombVariant.BOMB_THROWABLE, 0, bomb.Position, bomb.Velocity, player):ToBomb()
						redBomb.Parent = bomb
						redBomb:GetData().RedBomb = true
						redBomb.EntityCollisionClass = 0
						redBomb.FlipX = true
						--set explosion countdown
						if bomb.IsFetus and bomb.FrameCount == 0 then
							bomb:SetExplosionCountdown(datatables.CompoBombs.FetusCountdown)
						else
							functions.SetBombEXCountdown(player, redBomb)
						end
						if bomb.IsFetus then redBomb.IsFetus = true end
					end
					
					-- charged
					if player:HasCollectible(enums.Items.BatteryBombs) and not datatables.BatteryBombs.Ban[bomb.Variant] and bombData.Charged ~= false then
						local initTrue = true
						if bomb.FrameCount == 1 and bomb.IsFetus and bomb:GetDropRNG():RandomFloat() > datatables.BatteryBombs.FetusChance + player.Luck/100 then
							initTrue = false
							--scatter bombs from dr.fetus has chance to not get parent bomb effects. it sucks
						end
						if initTrue then
							functions.InitBatteryBomb(bomb, bombData)
						end
					end

					-- bonny
					if player:HasCollectible(enums.Items.DeadBombs) and not datatables.DeadBombs.Ban[bomb.Variant] and bombData.Bonny ~= false then
						local initTrue = true
						if bomb.FrameCount == 1 and bomb.IsFetus and bomb:GetDropRNG():RandomFloat() > datatables.DeadBombs.FetusChance + player.Luck/100 then
							initTrue = false
						end
						if initTrue then
							functions.InitDeadBomb(bomb, bombData)
						end
					end

					-- dicey
					if player:HasCollectible(enums.Items.DiceBombs) and not datatables.DiceBombs.Ban[bomb.Variant] and bombData.Dicey ~= false then
						local initTrue = true
						if bomb.FrameCount == 1 and bomb.IsFetus and bomb:GetDropRNG():RandomFloat() > datatables.DiceBombs.FetusChance + player.Luck/100 then
							initTrue = false
						end
						if initTrue then
							functions.InitDiceyBomb(bomb, bombData)
						end
					end
					
					-- gravity
					if player:HasCollectible(enums.Items.GravityBombs) and not datatables.GravityBombs.Ban[bomb.Variant] and bombData.Gravity ~= false then -- it can be nill or true
						local initTrue = true
						if bomb.FrameCount == 1 and bomb.IsFetus and bomb:GetDropRNG():RandomFloat() > datatables.GravityBombs.FetusChance + player.Luck/100 then
							initTrue = false
						end
						if initTrue then
							functions.InitGravityBomb(bomb, bombData)
						end
					end
					
					-- frosty
					if player:HasCollectible(enums.Items.FrostyBombs) and not datatables.FrostyBombs.Ban[bomb.Variant] and bombData.Frosty ~= false then -- nil or true
						local initTrue = true
						if bomb.FrameCount == 1 and bomb.IsFetus and bomb:GetDropRNG():RandomFloat() > datatables.FrostyBombs.FetusChance + player.Luck/100 then
							initTrue = false
						end
						if initTrue then
							functions.InitFrostyBomb(bomb, bombData)
						end
					end
					
					-- mirror
					if player:HasCollectible(enums.Items.MirrorBombs) and not datatables.MirrorBombs.Ban[bomb.Variant] and not bombData.Mirror then
						local flipPos = functions.FlipMirrorPos(bomb.Position)
						local mirrorBomb = Isaac.Spawn(bomb.Type, bomb.Variant, bomb.SubType, flipPos, bomb.Velocity, player):ToBomb()
						local mirrorBombData = mirrorBomb:GetData()
						local mirrorBombSprite = mirrorBomb:GetSprite()
						mirrorBombSprite:Play("Pulse", true)
						--mirrorBombSprite.FlipX = true
						--mirrorBombSprite.FlipY = true
						mirrorBomb:AddTearFlags(bomb.Flags)
						mirrorBomb.Parent = bomb
						-- rotate in right pos
						if mirrorBomb.Variant == BombVariant.BOMB_ROCKET_GIGA or mirrorBomb.Variant == BombVariant.BOMB_ROCKET then
							mirrorBombData.RocketMirror = player:GetShootingInput()  -- -rotVec
							mirrorBombSprite.Rotation = mirrorBombData.RocketMirror:GetAngleDegrees()
						end
						if bomb.IsFetus then mirrorBomb.IsFetus = true end

						--set explosion countdown
						functions.SetBombEXCountdown(player, mirrorBomb)

						mirrorBomb:SetColor(Color(1, 1, 1, 0.5, 0, 0, 0), 100, 1, false, false)
						mirrorBomb.FlipX = true
						mirrorBomb.EntityCollisionClass = 0
						mirrorBomb:AddTearFlags(bomb.Flags)
						mirrorBombData.Mirror = true
					end
				end
			end
		end
		
		-- mirror bombs
		if bombData.Mirror then
			bomb:SetColor(Color(1, 1, 1, 0.5, 0, 0, 0), 100, 1, false, false)
			bomb.EntityCollisionClass = 0 -- EntityCollisionClass.ENTCOLL_NONE
			bomb.FlipX = true
			if bombData.RocketMirror then
				bombSprite.Rotation = bombData.RocketMirror:GetAngleDegrees()
			end
			if bomb.Parent then
				local flipPos = functions.FlipMirrorPos(bomb.Parent.Position)
				bomb.Position = flipPos
			else
				bomb:SetExplosionCountdown(0)
				--bomb:Remove()
			end
		end
		
		--compo bombs
		if bombData.RedBomb then
			if bomb.Parent then
				bomb.EntityCollisionClass = 0 -- EntityCollisionClass.ENTCOLL_NONE
				local flip = true
				local diff = datatables.CompoBombs.DimensionX
				if bomb.Parent:GetData().Mirror then diff = -datatables.CompoBombs.DimensionX flip = false end -- mirror bombs check
				bomb.FlipX = flip
				bomb.Position = Vector(bomb.Parent.Position.X + diff, bomb.Parent.Position.Y)
			else
				bomb:Remove()
			end
		end
		
		-- frost bombs
		-- add ice particles after explosion:   EffectVariant.DIAMOND_PARTICLE or EffectVariant.ROCK_PARTICLE
		if bombData.Frosty then
			--local player = bomb.SpawnerEntity:ToPlayer()
			if bomb.FrameCount%8 == 0 then -- spawn every 8th frame
				local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, bombData.CreepVariant, 0, bomb.Position, Vector.Zero, bomb):ToEffect() -- PLAYER_CREEP_RED
				--creep.Size = 0.1
				creep.SpriteScale = creep.SpriteScale * 0.1
				if bombData.FrostyCreepColor then
					creep:SetColor(bombData.FrostyCreepColor, 200, 1, false, false)
				end
			end
		end

		--red scissors
		if datatables.RedScissorsMod and datatables.RedScissors.TrollBombs[bomb.Variant] then -- if player has red scissors and bombs is trollbombs
			if not bombData.ReplaceFrame then
				bombData.ReplaceFrame = datatables.RedScissors.NormalReplaceFrame  -- replace bomb at given frame
				if bomb.Variant == BombVariant.BOMB_GIGA then
					if bomb.SpawnerType == EntityType.ENTITY_PLAYER then -- don't replace giga bombs placed by any player
						bombData.ReplaceFrame = nil
					else
						bombData.ReplaceFrame = datatables.RedScissors.GigaReplaceFrame -- replace bomb at given frame
					end
				end
			else
				if bombSprite:IsPlaying("Pulse") and bombSprite:GetFrame() >= bombData.ReplaceFrame then -- replace on given frame of sprite animation
					functions.RedBombReplace(bomb)
				end
			end
		end
		
		-- bomb tracing (silly )
		if bomb.FrameCount > 0 and datatables.ModdedBombas and not datatables.NoBombTrace[bomb.Variant] and not bombData.bomby and bomb.SpawnerEntity and bomb.SpawnerEntity:ToPlayer() then
			if bombSprite:IsPlaying('Explode') then
				datatables.ModdedBombas[roomIndex][bomb.Index] = nil
			else --if bomb.FrameCount > 0 then --and  -- trace bombs so you wont apply bomb effect on earlier placed bombs (such as placing bomb and leaving room, picking mod bomb item and then reentering room)
				datatables.ModdedBombas[roomIndex][bomb.Index] = {
					Seed = bombSeed,
					--Position = bomb.Position,
					Gravity = bombData.Gravity,
					Compo = bombData.Compo,
					Mirror = bombData.Mirror,
					Frosty = bombData.Frosty,
					DeadEgg = bombData.DeadEgg,
					Dicey = bombData.Dicey,
					BobTongue = bombData.BobTongue,
					Charged = bombData.Charged,
					Bonny = bombData.Bonny,
				}
			end
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, EclipsedMod.onBombUpdate)



--- EFFECT UPDATE --penance
function EclipsedMod:onRedCrossEffect(effect)
	if effect:GetData().PenanceRedCrossEffect then
		if not effect.Parent then
			effect:Remove()
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, EclipsedMod.onRedCrossEffect, datatables.Penance.Effect)
--- EFFECT UPDATE --dead egg
function EclipsedMod:onDeadEggEffect(effect)
	local data = effect:GetData()
	if data.DeadEgg and effect.Timeout == 0 then
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, effect.Position, Vector.Zero, nil):SetColor(Color(0,0,0,1,0,0,0),60,1, false, false)
		effect:Remove()
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, EclipsedMod.onDeadEggEffect, EffectVariant.DEAD_BIRD)
--- EFFECT UPDATE --bob's tongue
function EclipsedMod:onFartRingEffect(fart_ring)
	if fart_ring:GetData().BobTongue then
		if not fart_ring.Parent then
			fart_ring:Remove()
		else
			fart_ring:FollowParent(fart_ring.Parent)
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, EclipsedMod.onFartRingEffect, EffectVariant.FART_RING)
--- EFFECT UPDATE --black hole bombs
function EclipsedMod:onGravityHoleUpdate(hole)
	local room = game:GetRoom()
	local holeData = hole:GetData()
	local holeSprite = hole:GetSprite()
	if holeData.Gravity and hole.SubType == 0 then
		if hole and hole.Parent then
			--gravity bombs
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

			if holeData.GravityForce < datatables.GravityBombs.MaxForce then
				holeData.GravityForce = holeData.GravityForce + datatables.GravityBombs.IterForce
			end
			if holeData.GravityRange < datatables.GravityBombs.MaxRange then
				holeData.GravityRange = holeData.GravityRange + datatables.GravityBombs.IterRange
			end
			if holeData.GravityGridRange < datatables.GravityBombs.MaxGrid then
				holeData.GravityGridRange = holeData.GravityGridRange + datatables.GravityBombs.IterGrid
			end
			game:Darken(1, 1)
			game:UpdateStrangeAttractor(hole.Position, holeData.GravityForce, holeData.GravityRange)
			for gindex=1, room:GetGridSize() do -- destroy grid entities near black hole bombs
				local grid = room:GetGridEntity(gindex)
				if grid then
					if grid:ToRock() or grid:ToPoop() then
						if hole.Position:Distance(grid.Position) < holeData.GravityGridRange and grid.State < 2 then
							game:SpawnParticles(grid.Position, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 1, 5, _, 5)
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
				sfx:Play(SoundEffect.SOUND_BLOOD_LASER_LARGE,_,_,_,0.2,0)
			end
		else --else
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
EclipsedMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, EclipsedMod.onGravityHoleUpdate,  datatables.GravityBombs.BlackHoleEffect) -- idk why it triggers when I use ingame black hole item (when using Fusion card)
--- EFFECT UPDATE --moonlighter
function EclipsedMod:onKeeperMirrorTargetEffect(target)
	--local player = target.Parent:ToPlayer()
	local targetSprite = target:GetSprite()
	target.Velocity = target.Velocity * 0.7
	target.DepthOffset = -100
	if target.GridCollisionClass ~= EntityGridCollisionClass.GRIDCOLL_WALLS then
		target.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
	end
	targetSprite:Play("Blink")
end
EclipsedMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, EclipsedMod.onKeeperMirrorTargetEffect, datatables.KeeperMirror.Target)
--- EFFECT UPDATE --black/white knight
function EclipsedMod:onBlackKnightTargetEffect(target)
	--- COPY from Edith mod ------------
	local ready = false
	local player = target.Parent:ToPlayer()
	--local data = player:GetData()
	local room = game:GetRoom()
	local tSprite = target:GetSprite()
	target.Velocity = target.Velocity * 0.7
	target.DepthOffset = -100
	if target.GridCollisionClass ~= EntityGridCollisionClass.GRIDCOLL_WALLS then
		target.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
	end
	if player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == enums.Items.BlackKnight then
		if player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY) >= Isaac.GetItemConfig():GetCollectible(enums.Items.BlackKnight).MaxCharges then
			ready = true
		end
	end
	local gridEntity = room:GetGridEntityFromPos(target.Position)
	if gridEntity and not player.CanFly then
		if gridEntity.Desc.Type == GridEntityType.GRID_PIT and gridEntity.Desc.State ~= 1 then
			ready = false
		end
	end
	if ready and not tSprite:IsPlaying("Blink") then
		tSprite:Play("Blink")
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, EclipsedMod.onBlackKnightTargetEffect ,datatables.BlackKnight.Target)
--- EFFECT UPDATE --Elder Sign
function EclipsedMod:onElderSignPentagramUpdate(pentagram)
	if pentagram:GetData().ElderSign and pentagram.SpawnerEntity then
		if pentagram.FrameCount == pentagram:GetData().ElderSign then
			local purgesoul = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PURGATORY, 1, pentagram.Position, Vector.Zero, player):ToEffect() -- subtype = 0 is rift, 1 is soul
			purgesoul.Color = Color(0.2,0.5,0.2,1)
		end
		-- get enemies in range
		local enemies = Isaac.FindInRadius(pentagram.Position, datatables.ElderSign.AuraRange-10, EntityPartition.ENEMY)
		if #enemies > 0 then
			for _, enemy in pairs(enemies) do
				if enemy:IsVulnerableEnemy() and enemy:IsActiveEnemy() then
					if functions.CheckJudasBirthright(pentagram.SpawnerEntity) then
						enemy:AddBurn(EntityRef(pentagram.SpawnerEntity), 1, 2*pentagram.SpawnerEntity:ToPlayer().Damage)
						enemy:GetData().Waxed = 1
					end
					enemy:AddFreeze(EntityRef(pentagram.SpawnerEntity), 1)
				end
			end
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, EclipsedMod.onElderSignPentagramUpdate, datatables.ElderSign.Pentagram)




--- FAMILIAR UPDATE --wisps
function EclipsedMod:onModWispsUpdate(wisp)
	local wispData = wisp:GetData()
	if wisp:HasMortalDamage() then
		local rng = wisp:GetDropRNG()
		if wispData.RemoveAll then
			local sameWisps = Isaac.FindByType(wisp.Type, wisp.Variant, wisp.SubType)
			if #sameWisps > 0 then
				for _, wisp2 in pairs(sameWisps) do
					if wisp2:GetData().RemoveAll == wispData.RemoveAll then
						wisp2:Kill()
					end
				end
			end
		end
		
		if wisp.SubType == enums.Items.CodexAnimarum then
			if datatables.CodexAnimarumWispChance > rng:RandomFloat() then
				functions.SoulExplosion(wisp)
				--local purgesoul = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PURGATORY, 1, wisp.Position, Vector.Zero, wisp):ToEffect() -- subtype = 0 is rift, 1 is soul
		 		-- set animation (skip appearing from rift)
				--purgesoul:GetSprite():Play("Charge", true)
			end
		elseif wisp.SubType == enums.Items.AncientVolume then
			if wisp.SpawnerEntity and wisp.SpawnerEntity:ToPlayer() then
				local ppl = wisp.SpawnerEntity:ToPlayer()
				ppl:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_CAMO_UNDIES, true)
			end
		elseif wisp.SubType == enums.Items.WizardBook then
			if wisp.SpawnerEntity and wisp.SpawnerEntity:ToPlayer() then
				local ppl = wisp.SpawnerEntity:ToPlayer()
				local locust = rng:RandomInt(5)+1
				Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, locust, ppl.Position, Vector.Zero, ppl)
			end	
		elseif wisp.SubType == enums.Items.LockedGrimoire then
			if datatables.LockedGrimoireWispChance > rng:RandomFloat() then
				functions.DebugSpawn(PickupVariant.PICKUP_KEY, KeySubType.KEY_NORMAL, wisp.Position)
			end
		elseif wisp.SubType == enums.Items.StoneScripture then
			functions.SoulExplosion(wisp)
		elseif wisp.SubType == enums.Items.HuntersJournal then
			local charger = Isaac.Spawn(EntityType.ENTITY_CHARGER, 0, 1, wisp.Position, Vector.Zero, wisp)
			charger:SetColor(Color(0,0,2), -1, 1, false, true)
			charger:AddCharmed(EntityRef(wisp), -1)
			charger:GetData().BlackHoleCharger = true
		elseif wisp.SubType == enums.Items.TomeDead then
			functions.SoulExplosion(wisp)
		elseif wisp.SubType == enums.Items.ElderMyth then
			if datatables.LockedGrimoireWispChance > rng:RandomFloat() then
				local card = datatables.ElderMythCardPool[rng:RandomInt(#datatables.ElderMythCardPool)+1]
				functions.DebugSpawn(PickupVariant.PICKUP_TAROTCARD, card, wisp.Position)
			end
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, EclipsedMod.onModWispsUpdate, FamiliarVariant.WISP)
--- FAMILIAR UPDATE --long elk
function EclipsedMod:onVertebraeUpdate(fam)
	local famData = fam:GetData() -- get fam data
	if famData.RemoveTimer then
		famData.RemoveTimer = famData.RemoveTimer - 1
		if famData.RemoveTimer <= 0 then
			fam:Kill()
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, EclipsedMod.onVertebraeUpdate,  FamiliarVariant.BONE_SPUR)
--- FAMILIAR INIT --nadab brain
function EclipsedMod:onNadabBrainInit(fam)
	fam:AddToFollowers()
end
EclipsedMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, EclipsedMod.onNadabBrainInit, datatables.NadabBrain.Variant)
--- FAMILIAR COLLISION --nadab brain
function EclipsedMod:onNadabBrainCollision(fam, collider)
	local famData = fam:GetData()
	if famData.IsFloating and collider:ToNPC() then
		if collider.Type == EntityType.ENTITY_FIREPLACE then
			collider:TakeDamage(fam.CollisionDamage, DamageFlag.DAMAGE_COUNTDOWN, EntityRef(fam), 1)
			fam.CollisionDamage = 0
			fam.Velocity = Vector.Zero
			famData.Collided = true
		elseif collider:IsActiveEnemy() and collider:IsVulnerableEnemy() and not collider:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
			fam:GetSprite():Play('Idle', true) -- "drop"
			fam.CollisionDamage = 0
			fam.Velocity = Vector.Zero
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, EclipsedMod.onNadabBrainCollision, datatables.NadabBrain.Variant)
--- FAMILIAR UPDATE --nadab brain
function EclipsedMod:OnNadabBrainUpdate(fam)
	local player = fam.Player -- get player
	local sprite = fam:GetSprite() -- get sprite
	local famData = fam:GetData() -- get data

	fam.GridCollisionClass = GridCollisionClass.COLLISION_OBJECT and GridCollisionClass.COLLISION_WALL
	fam.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
	fam.CollisionDamage = 0

	-- flip by x
	if fam.Velocity.x ~= 0 then
		fam.FlipX = fam.Velocity.X < 0
	end

	if not sprite:IsPlaying('Idle') and not sprite:IsPlaying('Appear') and not sprite:IsPlaying('Float') and fam.Visible then
		sprite:Play('Float', true)
	end

	if famData.IsFloating then
		--famData.IsHighest = nil
		fam.CollisionDamage = datatables.NadabBrain.CollisionDamage
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
			fam.CollisionDamage = datatables.NadabBrain.CollisionDamage * 2
		end

		if sprite:IsPlaying('Idle') then
			famData.IsFloating = false
			fam.Visible = false
			famData.Framecount = game:GetFrameCount()
			functions.BrainExplosion(player, fam)
		end

		-- reset at new room
		if game:GetRoom():GetFrameCount() == 0 then
			functions.NadabBrainReset(fam)
		end

		-- collide with grid/wall??
		if fam:CollidesWithGrid() then
			local room = game:GetRoom()
			room:DamageGrid(room:GetGridIndex(fam.Position), 1)
			fam.Velocity = Vector.Zero
		    fam.CollisionDamage = 0
			famData.Collided = true
			--functions.NadabBrainReset(fam)
		end
		if famData.Collided and fam:IsFrame(30, 5) then
			functions.NadabBrainReset(fam)
        end
	else
		fam:FollowParent()
		-- idle
		if (famData.Framecount ~= nil and famData.Framecount + datatables.NadabBrain.Respawn <= game:GetFrameCount()) or famData.IsFloating == nil then
			sprite:Play('Appear', true)
			if famData.IsHighest == nil then
				famData.IsHighest = false
			end
			functions.NadabBrainReset(fam)
			--famData.IsFloating = false
			--famData.isReady = false
			--famData.Collided = false
			--fam.CollisionDamage = 0
			--functions.CheckForParent(fam)

			fam.Visible = true
			fam.Velocity = Vector.Zero
			famData.Framecount = nil
		end

		-- is ready to fire
		if famData.isReady and player:GetFireDirection() ~= Direction.NO_DIRECTION and famData.IsHighest then
			fam.Velocity = functions.GetVelocity(player) * datatables.NadabBrain.Speed
			local child = fam.Child
            local parent = fam.Parent
            if child ~= nil then
                child.Parent = fam.Parent
            end
            if parent ~= nil then
                parent.Child = fam.Child
            end
			famData.IsFloating = true
		else
			local parent = fam.Parent or player
			local distance = parent.Position:Distance(fam.Position)
			famData.isReady = false
			if not famData.isReady and distance <= datatables.NadabBrain.MaxDistance and fam:IsFrame(30, 5) then
				famData.isReady = true
			end
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, EclipsedMod.OnNadabBrainUpdate, datatables.NadabBrain.Variant)
--- FAMILIAR INIT --lililith
function EclipsedMod:onLililithInit(fam)
	fam:GetSprite():Play("FloatDown")
	fam:AddToFollowers()
end
EclipsedMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, EclipsedMod.onLililithInit, datatables.Lililith.Variant)
--- FAMILIAR UPDATE --lililith
function EclipsedMod:onLililithUpdate(fam)
	local player = fam.Player -- get player
	local data = player:GetData()
	local tempEffects = player:GetEffects()
	local famData = fam:GetData() -- get fam data
	local famSprite = fam:GetSprite()
	functions.CheckForParent(fam)
	fam:FollowParent()

	if famSprite:IsFinished("Spawn") and famData.GenIndex then
		tempEffects:AddCollectibleEffect(data.LililithDemonSpawn[famData.GenIndex][1], false, 1)
		data.LililithDemonSpawn[famData.GenIndex][3] = data.LililithDemonSpawn[famData.GenIndex][3] + 1
		famSprite:Play("FloatDown")
		famData.GenIndex = nil
	end

	if fam.RoomClearCount >= datatables.Lililith.GenAfterRoom then
		fam.RoomClearCount = 0
		local rng = player:GetCollectibleRNG(enums.Items.Lililith)
		famData.GenIndex = rng:RandomInt(#data.LililithDemonSpawn)+1
		famSprite:Play("Spawn")
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, EclipsedMod.onLililithUpdate, datatables.Lililith.Variant)
--- FAMILIAR INIT --red bag
function EclipsedMod:onRedBagInit(fam)
	fam:GetSprite():Play("FloatDown")
	fam:GetData().GenAfterRoom = datatables.RedBag.GenAfterRoom
	fam:AddToFollowers()
end
EclipsedMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, EclipsedMod.onRedBagInit, datatables.RedBag.Variant)
--- FAMILIAR UPDATE --red bag
function EclipsedMod:onRedBagUpdate(fam)
	local player = fam.Player -- get player
	local famData = fam:GetData() -- get fam data
	local famSprite = fam:GetSprite()
	functions.CheckForParent(fam)
	fam:FollowParent()
	famData.GenAfterRoom = famData.GenAfterRoom or datatables.RedBag.GenAfterRoom

	if fam.RoomClearCount >= fam:GetData().GenAfterRoom then
		fam.RoomClearCount = 0
		local rng = player:GetCollectibleRNG(enums.Items.RedBag)
		famSprite:Play("Spawn")
		if rng:RandomFloat() < datatables.RedBag.RedPoopChance then
			famData.GenIndex = 0 -- red poop
		else
			famData.GenIndex = rng:RandomInt(#datatables.RedBag.RedPickups)+1
		end
	end

	if famSprite:IsFinished("Spawn") and famData.GenIndex then
		famSprite:Play("FloatDown")
		local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, fam.Position, Vector.Zero, nil)
		effect:SetColor(datatables.RedColor, 60, 1, false, false)
		if famData.GenIndex == 0 then
			Isaac.GridSpawn(GridEntityType.GRID_POOP, 1, fam.Position, false)
			famData.GenAfterRoom = datatables.RedBag.GenAfterRoom
		else
			Isaac.Spawn(EntityType.ENTITY_PICKUP, datatables.RedBag.RedPickups[famData.GenIndex][1], datatables.RedBag.RedPickups[famData.GenIndex][2], fam.Position, Vector.Zero, nil)
			famData.GenAfterRoom = datatables.RedBag.RedPickups[famData.GenIndex][3]
		end
		famData.GenIndex = nil
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, EclipsedMod.onRedBagUpdate, datatables.RedBag.Variant)
--- FAMILIAR INIT --abihu
function EclipsedMod:onAbihuFamInit(fam)
	if fam.SubType == datatables.AbihuFam.Subtype then
		fam:GetData().CollisionTime = 0
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, EclipsedMod.onAbihuFamInit, datatables.AbihuFam.Variant)
--- FAMILIAR UPDATE --abihu
function EclipsedMod:onAbihuFamUpdate(fam)
	--local player = fam.Player
	local famData = fam:GetData()
	if fam.SubType > 1 then -- else he will move only if enemies near him
		fam.SubType = 0
	end
	if famData.CollisionTime then
		if famData.CollisionTime > 0 then
			famData.CollisionTime = famData.CollisionTime - 1
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, EclipsedMod.onAbihuFamUpdate, datatables.AbihuFam.Variant)
--- FAMILIAR TAKE DMG --abihu
function EclipsedMod:onFamiliarTakeDamage(entity, _, damageFlag, source, _) --entity, amount, flags, source, countdown
	-- abihu fam take dmg
	if entity.Variant == datatables.AbihuFam.Variant then
		entity = entity:ToFamiliar()
		local famData = entity:GetData()
		if famData.CollisionTime then
			if famData.CollisionTime == 0 then
				local player = entity.Player
				famData.CollisionTime = datatables.AbihuFam.CollisionTime
				if damageFlag & DamageFlag.DAMAGE_TNT == 0 and source.Entity then -- idk but tries to add burn to tnt
					source.Entity:AddBurn(EntityRef(player), datatables.AbihuFam.BurnTime, 2*player.Damage)
				end
				if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
					functions.CircleSpawn(entity, datatables.AbihuFam.SpawnRadius, 0, EntityType.ENTITY_EFFECT, EffectVariant.FIRE_JET, 0)
				end
			end
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, EclipsedMod.onFamiliarTakeDamage, EntityType.ENTITY_FAMILIAR)
--- black book abyss locust
function EclipsedMod:onAbyssBlackBookCollision(fam, collider)
	if fam.SpawnerEntity and fam.SpawnerEntity:ToPlayer() and collider:ToNPC() and collider:IsActiveEnemy() and collider:IsVulnerableEnemy() then
		local rng = fam:GetDropRNG()
		local entity = collider:ToNPC()
		local player = fam.SpawnerEntity:ToPlayer()
		
		if fam.SubType == enums.Items.BlackBook and rng:RandomFloat() <= 0.2 then
			functions.BlackBookEffects(player, entity, rng)
		elseif fam.SubType == enums.Items.MeltedCandle and rng:RandomFloat() <= 0.5 and not entity:GetData().Waxed then
			entity:AddFreeze(EntityRef(player), datatables.MeltedCandle.FrameCount)
			if entity:HasEntityFlags(EntityFlag.FLAG_FREEZE) then
				--entity:AddBurn(EntityRef(player), 1, 2*player.Damage) -- the issue is Freeze stops framecount of entity, so it won't call NPC_UPDATE.
				entity:AddEntityFlags(EntityFlag.FLAG_BURN )
				entity:GetData().Waxed = datatables.MeltedCandle.FrameCount
				entity:SetColor(datatables.MeltedCandle.TearColor, datatables.MeltedCandle.FrameCount, 100, false, false)
			end
		elseif fam.SubType == enums.Items.Limb then
			entity:GetData().LimbLocustTouch = true
		elseif fam.SubType == enums.Items.Lililith and rng:RandomFloat() <= 0.2 then
			player:AddBlueFlies(1, player.Position, entity)
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, EclipsedMod.onAbyssBlackBookCollision, FamiliarVariant.ABYSS_LOCUST)
---USE ITEM---
do
-- book of virtues
function EclipsedMod:onAnyItem(item, _, player, useFlag) --item, rng, player, useFlag, activeSlot, customVarData
	if datatables.ActiveItemWisps[item] and player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) and useFlag & datatables.MyUseFlags_Gene ~= datatables.MyUseFlags_Gene then
		local wisp = player:AddWisp(datatables.ActiveItemWisps[item], player.Position, true, false)
		if wisp then
			if item == enums.Items.ElderSign then
				wisp:ToFamiliar():GetData().RemoveAll = item
			elseif Isaac.GetItemConfig():GetCollectible(item).ChargeType == 1 then
				wisp:ToFamiliar():GetData().TemporaryWisp = true
			end
		end
	end
	
	if item == CollectibleType.COLLECTIBLE_PLAN_C then
		if player:GetPlayerType() == enums.Characters.UnbiddenB then
			local data = player:GetData()
			data.UnbiddenResetGameChance = 0 
		elseif player:GetPlayerType() == enums.Characters.Unbidden then
			player:AddBrokenHearts(11)
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_ITEM, EclipsedMod.onAnyItem)
-- glowing hourglass removes blindfold, so this function resets blindfold
function EclipsedMod:onGlowingHourglassUse(_, _, player) --item, rng, player, useFlag, activeSlot, customVarData
	local data = player:GetData()
	if data.BlindAbihu or data.BlindUnbidden then
		data.ResetBlind = 60 -- reset blindfold after 60 frames
	end
	if data.LostWoodenCross then data.LostWoodenCross = nil end
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_ITEM, EclipsedMod.onGlowingHourglassUse, CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS)
---love letter
function EclipsedMod:onSecretLoveLetter(item, _, player, useFlag) --item, rng, player, useFlag, activeSlot, customVarData
	if useFlag & UseFlag.USE_CARBATTERY == 0 then
		local data = player:GetData()
		player:AnimateCollectible(item, player:IsHoldingItem() and "HideItem" or "LiftItem")
		if data.UsedSecretLoveLetter then
			data.UsedSecretLoveLetter = false
			--sfx:Play(SoundEffect.SOUND_PAPER_OUT)
		else
			data.UsedSecretLoveLetter = true
			--sfx:Play(SoundEffect.SOUND_PAPER_IN)
		end
	end
	return {ShowAnim = false, Remove = false, Discharge = false}
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_ITEM, EclipsedMod.onSecretLoveLetter, enums.Items.SecretLoveLetter)
---Agony Box
function EclipsedMod:onAgonyBox() --item, rng, player, useFlag, activeSlot, customVarData
	return {ShowAnim = false, Remove = false, Discharge = false}
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_ITEM, EclipsedMod.onAgonyBox, enums.Items.AgonyBox)
---Pandora's Jar
function EclipsedMod:onPandoraJar(item, rng, player)
	local wisp
	if datatables.PandoraJarGift and datatables.PandoraJarGift == 1 then
		game:GetHUD():ShowFortuneText("Elpis!")
		player:UseActiveItem(CollectibleType.COLLECTIBLE_MYSTERY_GIFT, datatables.MyUseFlags_Gene)
		wisp = player:AddWisp(CollectibleType.COLLECTIBLE_MYSTERY_GIFT, player.Position, true)
		datatables.PandoraJarGift = 2
		return {ShowAnim = true, Remove = true, Discharge = true}
	else
		wisp = player:AddWisp(item, player.Position, true)
	end
	if wisp then
		sfx:Play(471)
		if not player:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE) and not datatables.PandoraJarGift then
			local randNum = rng:RandomFloat()
			if randNum <= datatables.PandoraJar.CurseChance then
				local level = game:GetLevel()
				datatables.PandoraJar.Curses = functions.PandoraJarManager()
				if #datatables.PandoraJar.Curses > 0 then
					local addCurse = datatables.PandoraJar.Curses[rng:RandomInt(#datatables.PandoraJar.Curses)+1]
					game:GetHUD():ShowFortuneText(enums.CurseText[addCurse])
					level:AddCurse(addCurse, false)
				else
					datatables.PandoraJarGift = 1
				end
			end
		end
	end
	return true
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_ITEM, EclipsedMod.onPandoraJar, enums.Items.PandoraJar)
---Witch's Pot
function EclipsedMod:onWitchPot(_, rng, player) --item, rng, player, useFlag, activeSlot, customVarData
	local chance = rng:RandomFloat()
	local pocketTrinket = player:GetTrinket(0)
	local pocketTrinket2 = player:GetTrinket(1)
	local hudText = "Cantrip!"

	if pocketTrinket ~= 0 then
		if chance <= datatables.WitchPot.KillThreshold then
			functions.RemoveThrowTrinket(player, pocketTrinket, datatables.TrinketDespawnTimer)
			hudText = "Cantripped!"
			sfx:Play(SoundEffect.SOUND_SLOTSPAWN)
		elseif chance <= datatables.WitchPot.GulpThreshold then
			player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, datatables.MyUseFlags_Gene)
			hudText = "Gulp!"
			sfx:Play(SoundEffect.SOUND_VAMP_GULP)
		elseif chance <= datatables.WitchPot.SpitThreshold then
			local hastrinkets = {}
			for gulpedTrinket = 1, TrinketType.NUM_TRINKETS do
				if player:HasTrinket(gulpedTrinket, false) and gulpedTrinket ~= pocketTrinket and gulpedTrinket ~= pocketTrinket2 then
					table.insert(hastrinkets, gulpedTrinket)
				end
			end
			if #hastrinkets > 0 then
				local removeTrinket = hastrinkets[rng:RandomInt(#hastrinkets)+1]
				player:TryRemoveTrinket(removeTrinket)
				functions.DebugSpawn(PickupVariant.PICKUP_TRINKET, removeTrinket, player.Position, 0, RandomVector()*5)
				hudText = "Spit out!"
				sfx:Play(SoundEffect.SOUND_ULTRA_GREED_SPIT)
			end
		else
			local newTrinket = rng:RandomInt(TrinketType.NUM_TRINKETS)+1
			player:TryRemoveTrinket(pocketTrinket)
			player:AddTrinket(newTrinket, true)
			hudText = "Can trip?"
			sfx:Play(SoundEffect.SOUND_BIRD_FLAP)
		end
	else
		if chance <= datatables.WitchPot.SpitChance then
			local hastrinkets = {}
			for gulpedTrinket = 1, 205 do --TrinketType.NUM_TRINKETS do
				if player:HasTrinket(gulpedTrinket, false) then
					table.insert(hastrinkets, gulpedTrinket)
				end
			end
			if #hastrinkets > 0 then
				local removeTrinket = hastrinkets[rng:RandomInt(#hastrinkets)+1]
				player:TryRemoveTrinket(removeTrinket)
				functions.DebugSpawn(PickupVariant.PICKUP_TRINKET, removeTrinket, player.Position, 0, RandomVector()*5)
				hudText = "Spit out!"
				sfx:Play(SoundEffect.SOUND_ULTRA_GREED_SPIT)
			end
		end
	end

	if hudText == "Cantrip!" then
		player:UseActiveItem(CollectibleType.COLLECTIBLE_MOMS_BOX, datatables.MyUseFlags_Gene)
		sfx:Play(SoundEffect.SOUND_SLOTSPAWN)
	end

	--game:GetHUD():ShowFortuneText(hudText)
	return true
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_ITEM, EclipsedMod.onWitchPot, enums.Items.WitchPot)
---book of memories
function EclipsedMod:onBookMemoryItem(_, _, player) --item, rng, player, useFlag, activeSlot, customVarData
	local entities = Isaac.FindInRadius(player.Position, 5000, EntityPartition.ENEMY)
	if #entities > 0 then
		for _, entity in pairs(Isaac.FindInRadius(player.Position, 5000, EntityPartition.ENEMY)) do
			if not entity:IsBoss() and entity.Type ~= EntityType.ENTITY_FIREPLACE then
				datatables.LobotomyErasedEntities = datatables.LobotomyErasedEntities or {}
				table.insert(datatables.LobotomyErasedEntities, {entity.Type, entity.Variant})
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, entity.Position, Vector.Zero, nil):SetColor(datatables.OblivionCard.PoofColor,50,1, false, false)
				entity:Remove()
			end
		end
		sfx:Play(316)
		player:AddBrokenHearts(1)
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
			local wisp = player:AddWisp(CollectibleType.COLLECTIBLE_ERASER, player.Position, false, false)
			if wisp and wisp:ToFamiliar() then
				wisp.Color = Color(0.5,1,2,1,0,0,0)
				wisp.SplatColor = Color(0.5,1,2,1,0,0,0)
			end
		end

		return true
	end
	return {ShowAnim = false, Remove = false, Discharge = false}
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_ITEM, EclipsedMod.onBookMemoryItem, enums.Items.BookMemory)
---Floppy Disk Empty
function EclipsedMod:onFloppyDisk(_, _, player) --item, rng, player, useFlag, activeSlot, customVarData
	functions.StorePlayerItems(player) -- save player items in table
	return {ShowAnim = true, Remove = true, Discharge = true} -- remove this item after use
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_ITEM, EclipsedMod.onFloppyDisk, enums.Items.FloppyDisk)
---Floppy Disk Full
function EclipsedMod:onFloppyDiskFull(_, _, player) --item, rng, player, useFlag, activeSlot, customVarData
	--- player use floppy disk
	functions.ReplacePlayerItems(player) -- replace player items
	game:ShowHallucination(5, 0)
	if sfx:IsPlaying(SoundEffect.SOUND_DEATH_CARD) then
		sfx:Stop(SoundEffect.SOUND_DEATH_CARD)
	end
	return {ShowAnim = true, Remove = true, Discharge = true} -- remove this item after use
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_ITEM, EclipsedMod.onFloppyDiskFull, enums.Items.FloppyDiskFull)
---Red Mirror
function EclipsedMod:onRedMirror(_, _, player) --item, rng, player, useFlag, activeSlot, customVarData
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
		pickups:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_CRACKED_KEY, false, false, false) -- morph first one into cracked key
		local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickups.Position, Vector.Zero, nil)
		effect:SetColor(datatables.RedColor, 50, 1, false, false) -- red poof effect
	end
	return true -- show use animation
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_ITEM, EclipsedMod.onRedMirror, enums.Items.RedMirror)
---BlackKnight
function EclipsedMod:onBlackKnight(_, _, player) --item, rng, player, useFlag, activeSlot, customVarData
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
EclipsedMod:AddCallback(ModCallbacks.MC_USE_ITEM, EclipsedMod.onBlackKnight, enums.Items.BlackKnight)
---KeeperMirror
function EclipsedMod:onKeeperMirror(item, _, player) --item, rng, player, useFlag, activeSlot, customVarData
	local data = player:GetData()
	--data.KeeperMirror = true
	data.KeeperMirror = Isaac.Spawn(1000, datatables.KeeperMirror.Target, 0, player.Position, Vector.Zero, player):ToEffect()
	data.KeeperMirror.Parent = player
	data.KeeperMirror:SetTimeout(datatables.KeeperMirror.TargetTimeout)
	--player:GetSprite():Play("PickupWalkDown", true)
	player:AnimateCollectible(item)
	return false
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_ITEM, EclipsedMod.onKeeperMirror, enums.Items.KeeperMirror)
---pony
function EclipsedMod:onMiniPony(_, _, player) --item, rng, player, useFlag, activeSlot, customVarData
	player:UseActiveItem(CollectibleType.COLLECTIBLE_MY_LITTLE_UNICORN, datatables.MyUseFlags_Gene)
	return false
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_ITEM, EclipsedMod.onMiniPony, enums.Items.MiniPony)
---strange box
function EclipsedMod:onStrangeBox(_, rng, _) --item, rng, player, useFlag, activeSlot, customVarData
	--- player use strange box
	local savedOptions = {}
	for _, pickup in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP)) do
		pickup = pickup:ToPickup()
		if pickup.OptionsPickupIndex == 0 then -- if pickup don't have option index
			pickup.OptionsPickupIndex = rng:RandomInt(Random())+1 -- get random number
		end
		if savedOptions[pickup.OptionsPickupIndex] == nil then
			savedOptions[pickup.OptionsPickupIndex] = true
			if pickup:IsShopItem() then
				local optionPickup = Isaac.Spawn(EntityType.ENTITY_PICKUP,  PickupVariant.PICKUP_SHOPITEM, 0, Isaac.GetFreeNearPosition(pickup.Position, 0), Vector.Zero, nil)
				optionPickup:ToPickup().OptionsPickupIndex = pickup.OptionsPickupIndex -- spawn another collectible and set option index
			elseif pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE and pickup.SubType ~= 0 then -- if pickup is collectible item
				local optionPickup = Isaac.Spawn(pickup.Type, pickup.Variant, CollectibleType.COLLECTIBLE_NULL, Isaac.GetFreeNearPosition(pickup.Position, 40), Vector.Zero, nil)
				optionPickup:ToPickup().OptionsPickupIndex = pickup.OptionsPickupIndex -- spawn another collectible and set option index
			else
				for _, variant in pairs(datatables.StrangeBox.Variants) do
					if pickup.Variant == variant then
						local optionType = EntityType.ENTITY_PICKUP
						local optionVariant = 0 --datatables.StrangeBox.Variants[rng:RandomInt(#datatables.StrangeBox.Variants)+1]
						local optionSubtype = 0 -- idk if it would be random
						local optionPickup = Isaac.Spawn(optionType, optionVariant, optionSubtype, Isaac.GetFreeNearPosition(pickup.Position, 0), Vector.Zero, nil)
						optionPickup:ToPickup().OptionsPickupIndex = pickup.OptionsPickupIndex -- spawn another collectible and set option index
					end
				end
			end
		end
	end
	return true --{ShowAnim = true, Remove = false, Discharge = true}
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_ITEM, EclipsedMod.onStrangeBox, enums.Items.StrangeBox)
---lost mirror
function EclipsedMod:onLostMirror(_, _, player) --item, rng, player, useFlag, activeSlot, customVarData
	--player:ChangePlayerType(10)
	--- player use lost mirror
	local tempEffects = player:GetEffects()
	tempEffects:AddNullEffect(NullItemID.ID_LOST_CURSE, true, 1)
 	--player:UseCard(Card.CARD_HOLY, datatables.MyUseFlags_Gene)
	if player:HasTrinket(enums.Trinkets.LostFlower) then
		player:UseCard(Card.CARD_HOLY, datatables.MyUseFlags_Gene)
	end
	return true
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_ITEM, EclipsedMod.onLostMirror, enums.Items.LostMirror)
---lost flower + prayer card
function EclipsedMod:onPrayerCard(_, _, player) --item, rng, player, useFlag, activeSlot, customVarData
	--- player use prayer card
	--- lost flower
	--if you lost/t.lost for getting eternal heart give holy card effect
	if player:HasTrinket(enums.Trinkets.LostFlower) then -- if player has lost flower trinket
		local playerType = player:GetPlayerType()
		if playerType == PlayerType.PLAYER_THELOST or playerType == PlayerType.PLAYER_THELOST_B or player:GetPlayerType() == enums.Characters.UnbiddenB then
			player:UseCard(Card.CARD_HOLY,  datatables.MyUseFlags_Gene)
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_ITEM, EclipsedMod.onPrayerCard, CollectibleType.COLLECTIBLE_PRAYER_CARD)
---bleeding grimoire
function EclipsedMod:onBleedingGrimoire(_, _, player)
	local data = player:GetData()
	player:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
	player:AddNullCostume(datatables.BG.Costume)
	data.UsedBG = true
	return true
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_ITEM, EclipsedMod.onBleedingGrimoire, enums.Items.BleedingGrimoire)
---black book
function EclipsedMod:onBlackBook(_, rng, player) --item, rng, player, useFlag, activeSlot, customVarData
	local enemies = Isaac.FindInRadius(player.Position, 5000, EntityPartition.ENEMY)
	if #enemies > 0 then
		for _, entity in pairs(enemies) do
			if entity:ToNPC() then
				functions.BlackBookEffects(player, entity:ToNPC(), rng)
			end
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
	return true
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_ITEM, EclipsedMod.onBlackBook, enums.Items.BlackBook)
---scrambled rubik's dice
function EclipsedMod:onRubikDiceScrambled(item, _, player) --item, rng, player, useFlag, activeSlot, customVarData
	for _, Scrambledice in pairs(datatables.RubikDice.ScrambledDicesList) do
		if item == Scrambledice then
			--- player use rubik's dice
			functions.RerollTMTRAINER(player)
			return true
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_ITEM, EclipsedMod.onRubikDiceScrambled) -- called for all items
---rubik's dice
function EclipsedMod:onRubikDice(item, rng, player, useFlag) --item, rng, player, useFlag, activeSlot, customVarData
	--- player use rubik's dice
	player:UseActiveItem(CollectibleType.COLLECTIBLE_D6, datatables.MyUseFlags_Gene)
	if useFlag & UseFlag.USE_OWNED == UseFlag.USE_OWNED then --and rng:RandomFloat() < datatables.RubikDice.GlitchReroll then -- and  (useFlag & UseFlag.USE_MIMIC == 0) then
		player:RemoveCollectible(item)
		local Newdice = datatables.RubikDice.ScrambledDicesList[rng:RandomInt(#datatables.RubikDice.ScrambledDicesList)+1]
		player:AddCollectible(Newdice) --Newdice / enums.Items.RubikDiceScrambled
	end
	return true
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_ITEM, EclipsedMod.onRubikDice, enums.Items.RubikDice)
---vhs cassette
function EclipsedMod:onVHSCassette(_, rng, player) --item, rng, player, useFlag, activeSlot, customVarData
	functions.useVHS(rng)
	functions.ResetVHS()
	for _ = 1, datatables.countVHS do
		functions.Domino16Items(rng, player.Position)
	end
	return  {ShowAnim = true, Remove = true, Discharge = true}
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_ITEM, EclipsedMod.onVHSCassette, enums.Items.VHSCassette)
---long elk
function EclipsedMod:onLongElk(_, _, player) --item, rng, player, useFlag, activeSlot, customVarData
	local data = player:GetData()
	data.ElkKiller = true
	--player:UseActiveItem(CollectibleType.COLLECTIBLE_PONY, datatables.MyUseFlags_Gene)
	local tempEffects = player:GetEffects()
	tempEffects:AddCollectibleEffect(CollectibleType.COLLECTIBLE_MARS, false, 1)
	-- set player color or add some indicator
	return false
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_ITEM, EclipsedMod.onLongElk, enums.Items.LongElk)
---WhiteKnight
function EclipsedMod:onWhiteKnight(_, _, player) --item, rng, player, useFlag, activeSlot, customVarData
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
		-- do not show use animation
	end
	return {ShowAnim = false, Remove = false, Discharge = discharge}
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_ITEM, EclipsedMod.onWhiteKnight, enums.Items.WhiteKnight)
---charon's obol
function EclipsedMod:onCharonObol(_, _, player) --item, rng, player, useFlag, activeSlot, customVarData
	-- spawn soul if you have coins
	if player:GetNumCoins() > 0 then
		player:AddCoins(-1)
		-- take 1 coin and spawn
		local soul = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HUNGRY_SOUL, 1, player.Position, Vector.Zero, player):ToEffect()
		soul:SetTimeout(datatables.CharonObol.Timeout)

		if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
			player:AddWisp(CollectibleType.COLLECTIBLE_IV_BAG, player.Position, false, false)
		end

		return true
	end
	return false
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_ITEM, EclipsedMod.onCharonObol, enums.Items.CharonObol)
---Red Pill Placebo
function EclipsedMod:onRedPillPlacebo(_, _, player) --item, rng, player, useFlag, activeSlot, customVarData
	local pill = player:GetCard(0)
	if pill == enums.Pickups.RedPill or pill == enums.Pickups.RedPillHorse then
		player:UseCard(pill, UseFlag.USE_MIMIC)
	end
	--return {ShowAnim = true, Remove = false, Discharge = true}
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_ITEM, EclipsedMod.onRedPillPlacebo, CollectibleType.COLLECTIBLE_PLACEBO)
---Space Jam
function EclipsedMod:onCosmicJam(_, _, player) --item, rng, player, useFlag, activeSlot, customVarData
	local items = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)
	if #items > 0 then
		--sfx:Play(SoundEffect.SOUND_SOUL_PICKUP)
		for _, item in pairs(items) do
			if item.SubType ~= 0 and not functions.CheckItemTags(item.SubType, ItemConfig.TAG_QUEST) then
				sfx:Play(SoundEffect.SOUND_SOUL_PICKUP)
				player:AddItemWisp(item.SubType, item.Position, true)
			end
		end
	end
	return true
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_ITEM, EclipsedMod.onCosmicJam, enums.Items.CosmicJam)
---Elder Sign
function EclipsedMod:onUseElderSign(_, _, player)
    local pentagram = Isaac.Spawn(EntityType.ENTITY_EFFECT, datatables.ElderSign.Pentagram, 0, player.Position, Vector.Zero, player):ToEffect()
	pentagram.SpriteScale = pentagram.SpriteScale * datatables.ElderSign.AuraRange/100
	pentagram.Color = Color(0,1,0,1)
	pentagram:GetData().ElderSign = datatables.ElderSign.Timeout
    return true
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_ITEM, EclipsedMod.onUseElderSign, enums.Items.ElderSign)
end
---Heart Transplant
function EclipsedMod:onHeartTransplant(_, _, player) --item, rng, player, useFlag, activeSlot, customVarData
	local data = player:GetData()
	data.HeartTransplantUseCount = data.HeartTransplantUseCount or 0 -- get use counter
	if data.HeartTransplantUseCount < #datatables.HeartTransplant.ChainValue then -- increment use count
		data.HeartTransplantUseCount = data.HeartTransplantUseCount + 1
		if Isaac.GetChallenge() == enums.Challenges.Beatmaker then
			player:UseActiveItem(CollectibleType.COLLECTIBLE_TAMMYS_HEAD, datatables.MyUseFlags_Gene)
		end
	else --if data.HeartTransplantUseCount == #datatables.HeartTransplant.ChainValue then -- if use count is max
		player:UseActiveItem(CollectibleType.COLLECTIBLE_TAMMYS_HEAD, datatables.MyUseFlags_Gene)
	end
	-- set charge to negative, so using it don't trigger not full charge use
	data.HeartTransplantActualCharge = -15 * datatables.HeartTransplant.ChainValue[data.HeartTransplantUseCount][4]
	player:SetActiveCharge(data.HeartTransplantActualCharge, ActiveSlot.SLOT_PRIMARY)

	functions.HeartTranslpantFunc(player) -- delay = nil; evaluate cache
	sfx:Play(SoundEffect.SOUND_HEARTBEAT, 500)  -- play heartbeat sound

	if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then -- spawn wisp
		local wisp = player:AddWisp(enums.Items.HeartTransplant, player.Position)
		if wisp then -- if wisp was spawned
			wisp:GetData().TemporaryWisp = true
		end
	end
	return false
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_ITEM, EclipsedMod.onHeartTransplant, enums.Items.HeartTransplant)

---garden Trowel
function EclipsedMod:onGardenTrowel(item, _, player) --item, rng, player, useFlag, activeSlot, customVarData
	local dirtPatches = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.DIRT_PATCH, 0)
	local spawnSpur = true
	if #dirtPatches > 0 then
		for _, dirt in pairs(dirtPatches) do
			if player.Position:Distance(dirt.Position) < 25 and dirt:GetSprite():GetAnimation() == "Idle" then
				player:UseActiveItem(CollectibleType.COLLECTIBLE_WE_NEED_TO_GO_DEEPER, datatables.MyUseFlags_Gene)
				spawnSpur = false
			end
		end
	end
	if spawnSpur then
		local spur = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BONE_SPUR, 0, player.Position, Vector.Zero, player)
		--[
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) and spur then
			local wisp = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.WISP, item, spur.Position, Vector.Zero, spur)
			if wisp then
				wisp.Parent = spur
				wisp:GetData().TemporaryWisp = true
			end
		end
		--]
	end
	return false
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_ITEM, EclipsedMod.onGardenTrowel, enums.Items.GardenTrowel)

---elder myth
function EclipsedMod:onElderMyth(_, rng, player) --item, rng, player, useFlag, activeSlot, customVarData

	local card = datatables.ElderMythCardPool[rng:RandomInt(#datatables.ElderMythCardPool)+1]
	Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, card, Isaac.GetFreeNearPosition(player.Position, 20), Vector.Zero, player)

	return true
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_ITEM, EclipsedMod.onElderMyth, enums.Items.ElderMyth)

---forgotten grimoire
function EclipsedMod:onForgottenGrimoire(_, _, player) --item, rng, player, useFlag, activeSlot, customVarData
	if player:CanPickBoneHearts() then
		player:AddBoneHearts(1)
	end
	return true
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_ITEM, EclipsedMod.onForgottenGrimoire, enums.Items.ForgottenGrimoire)

---codex animarum
function EclipsedMod:onCodexAnimarum(_, _, player) --item, rng, player, useFlag, activeSlot, customVarData
	local soul = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HUNGRY_SOUL, 1, player.Position, Vector.Zero, player):ToEffect()
	soul:SetTimeout(datatables.CharonObol.Timeout)
	return true
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_ITEM, EclipsedMod.onCodexAnimarum, enums.Items.CodexAnimarum)

---red book
function EclipsedMod:onRedBook(_, rng, player) --item, rng, player, useFlag, activeSlot, customVarData
	
	red = rng:RandomInt(#datatables.RedBag.RedPickups)+1
	Isaac.Spawn(EntityType.ENTITY_PICKUP, datatables.RedBag.RedPickups[red][1], datatables.RedBag.RedPickups[red][2], Isaac.GetFreeNearPosition(player.Position, 20), Vector.Zero, player)
	
	if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
		local wisp = datatables.Pompom.WispsList[rng:RandomInt(#datatables.Pompom.WispsList)+1]
		player:AddWisp(wisp, player.Position, true)
	end
	
	return true
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_ITEM, EclipsedMod.onRedBook, enums.Items.RedBook)

---cosmic encyclopedia
function EclipsedMod:onCosmicEncyclopedia(_, rng, player) --item, rng, player, useFlag, activeSlot, customVarData
	local pos = player.Position
	functions.Domino16Items(rng, pos)
	return true
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_ITEM, EclipsedMod.onCosmicEncyclopedia, enums.Items.CosmicEncyclopedia)

---ancient sacred volume
function EclipsedMod:onAncientVolume(_, _, player) --item, rng, player, useFlag, activeSlot, customVarData
	local tempEffects = player:GetEffects()
	tempEffects:AddCollectibleEffect(CollectibleType.COLLECTIBLE_CAMO_UNDIES, true)
	return true
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_ITEM, EclipsedMod.onAncientVolume, enums.Items.AncientVolume)

---HolyHealing
function EclipsedMod:onHolyHealing(_, _, player) --item, rng, player, useFlag, activeSlot, customVarData
	--if player:CanPickRedHearts() then
	player:SetFullHearts()
	--end
	return true
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_ITEM, EclipsedMod.onHolyHealing, enums.Items.HolyHealing)

---wizard's book
function EclipsedMod:onWizardBook(_, rng, player) --item, rng, player, useFlag, activeSlot, customVarData
	local num = rng:RandomInt(3)+2
	for _ = 1, num do
		local locust = rng:RandomInt(5)+1
		Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, locust, player.Position, Vector.Zero, player)
	end
	return true
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_ITEM, EclipsedMod.onWizardBook, enums.Items.WizardBook)

---ritual manuscript
function EclipsedMod:onRitualManuscripts(_, _, player) --item, rng, player, useFlag, activeSlot, customVarData
	player:AddHearts(1)
	player:AddSoulHearts(1)
	return true
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_ITEM, EclipsedMod.onRitualManuscripts, enums.Items.RitualManuscripts)

---stitched papers
function EclipsedMod:onStitchedPapers(_, _, player) --item, rng, player, useFlag, activeSlot, customVarData
	local tempEffects = player:GetEffects()
	tempEffects:AddCollectibleEffect(CollectibleType.COLLECTIBLE_FRUIT_CAKE, false)
	return true
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_ITEM, EclipsedMod.onStitchedPapers, enums.Items.StitchedPapers)

---nirly's codex
function EclipsedMod:onNirlyCodex(_, _, player) --item, rng, player, useFlag, activeSlot, customVarData
	local data = player:GetData()
	if data.NirlySavedCards and #data.NirlySavedCards > 0 then
		data.UsedNirly = true
		return true
	end
	return false
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_ITEM, EclipsedMod.onNirlyCodex, enums.Items.NirlyCodex)


---alchemic notes
function EclipsedMod:onAlchemicNotes(_, rng, player) --item, rng, player, useFlag, activeSlot, customVarData
	
	local kill = true
	if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
		kill = false
	end
	
	local pickups = Isaac.FindByType(EntityType.ENTITY_PICKUP)
	
	if #pickups > 0 then
	
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
					if cardType == 2 or cardType == 6 then
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
	end
	return true
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_ITEM, EclipsedMod.onAlchemicNotes, enums.Items.AlchemicNotes)


---Stone Scripture
function EclipsedMod:onStoneScripture(item, _, player) --item, rng, player, useFlag, activeSlot, customVarData
	local data = player:GetData()
	local uses = 3
	if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) then 
		uses = 6 
	end
	data.UsedStoneScripture = data.UsedStoneScripture or uses
	
	if data.UsedStoneScripture > 0 then
		data.UsedStoneScripture = data.UsedStoneScripture - 1
		functions.SoulExplosion(player)
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
			--player:TriggerBookOfVirtues(item, 1)
			player:AddWisp(item, player.Position, true)
		end
		return true
	end
	return false
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_ITEM, EclipsedMod.onStoneScripture, enums.Items.StoneScripture)

---tome of the dead
function EclipsedMod:onTomeDead(item, _, player, _, activeSlot) --item, rng, player, useFlag, activeSlot, customVarData 
	--charges = Isaac.GetItemConfig():GetCollectible(item).MaxCharges
	player:GetData().usedTome = 30
	functions.UseTomeDeadSouls(player, item, player:GetActiveCharge(activeSlot))
	return true
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_ITEM, EclipsedMod.onTomeDead, enums.Items.TomeDead)

---locked grimoire
function EclipsedMod:onLockedGrimoire(_, rng, player) --item, rng, player, useFlag, activeSlot, customVarData
	
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
EclipsedMod:AddCallback(ModCallbacks.MC_USE_ITEM, EclipsedMod.onLockedGrimoire, enums.Items.LockedGrimoire)

-- tetris dice
function EclipsedMod:onTetrisDiceFull(item, _, player) --item, rng, player, useFlag, activeSlot, customVarData
	player:AddCollectible(CollectibleType.COLLECTIBLE_CHAOS, 0, false)
	player:UseActiveItem(CollectibleType.COLLECTIBLE_D6, datatables.MyUseFlags_Gene) -- D6 effect
	player:RemoveCollectible(CollectibleType.COLLECTIBLE_CHAOS) -- remove tmtrainer
	local items = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)
	if #items > 0 then
		datatables.TetrisItems = datatables.TetrisItems or {}
		for _, pickup in pairs(items) do
			local sprite = pickup:GetSprite()
			sprite:ReplaceSpritesheet(1, datatables.TetrisDicesQuestionMark)
			sprite:LoadGraphics()
			local seedItem = tostring(pickup:GetDropRNG():GetSeed()) 
			datatables.TetrisItems[seedItem] = true
		end
	end
	return true
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_ITEM, EclipsedMod.onTetrisDiceFull, enums.Items.TetrisDice_full)

--Hunter's Journal
function EclipsedMod:onHuntersJournal(_, _, player) --item, rng, player, useFlag, activeSlot, customVarData
	
	for _ = 1, 2 do
		local charger = Isaac.Spawn(EntityType.ENTITY_CHARGER, 0, 1, player.Position, Vector.Zero, player)
		charger:SetColor(Color(0,0,2), -1, 1, false, true)
		charger:AddCharmed(EntityRef(player), -1)
		charger:GetData().BlackHoleCharger = true
	end
	
	return true
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_ITEM, EclipsedMod.onHuntersJournal, enums.Items.HuntersJournal)

function EclipsedMod:onHuntersJournalChargers(charger)
	
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
EclipsedMod:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, EclipsedMod.onHuntersJournalChargers, EntityType.ENTITY_CHARGER)
---USE CARD/PILL---
do
---Apocalypse card
function EclipsedMod:onApocalypse(card, player) -- card, player, useflag
	-- fill the room with poop and turn them into red poop
	local room = game:GetRoom()
	local level = game:GetLevel()
	datatables.Apocalypse.Room = level:GetCurrentRoomIndex()
	datatables.Apocalypse.RNG = player:GetCardRNG(card)
	room:SetCardAgainstHumanity()
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onApocalypse, enums.Pickups.Apocalypse)
---oblivion card
function EclipsedMod:onOblivionCard(_, player) -- card, player, useflag
	-- throw chaos card and replace it with oblivion card (MC_POST_TEAR_INIT)
	local data = player:GetData()
	data.UsedOblivionCard = true
	player:UseCard(Card.CARD_CHAOS, datatables.MyUseFlags_Gene)
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onOblivionCard, enums.Pickups.OblivionCard)
---King Chess black
function EclipsedMod:onKingChess(_, player) -- card, player, useflag
	-- spawn black poops
	--functions.SquareSpawn(player, 40, 0, EntityType.ENTITY_POOP, 15, 0)
	functions.MyGridSpawn(player, 40, GridEntityType.GRID_POOP, 5, true)
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onKingChess, enums.Pickups.KingChess)
---King Chess white
function EclipsedMod:onKingChessW(_, player) -- card, player, useflag
	-- spawn white/stone poops
	functions.SquareSpawn(player, 40, 0, EntityType.ENTITY_POOP, 11, 0)
	--functions.MyGridSpawn(player, 40, GridEntityType.GRID_POOP, 6, true) --rng:RandomInt(7)
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onKingChessW, enums.Pickups.KingChessW)
---Trapezohedron
function EclipsedMod:onTrapezohedron() -- card, player, useflag
	-- turn all trinkets in room into cracked keys
	for _, pickups in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET)) do -- get all trinkets in room
		pickups:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_CRACKED_KEY, false, false, false) -- morph all trinkets into cracked keys
		local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickups.Position, Vector.Zero, nil)
		effect:SetColor(datatables.RedColor, 50, 1, false, false) -- red poof effect
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onTrapezohedron, enums.Pickups.Trapezohedron)
---red pill
function EclipsedMod:onRedPill(_, player) -- card, player, useflag
	functions.RedPillManager(player, datatables.RedPills.DamageUp, datatables.RedPills.WavyCap)
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onRedPill, enums.Pickups.RedPill)
---red pill horse
function EclipsedMod:onRedPillHorse(_, player) -- card, player, useflag
	functions.RedPillManager(player, datatables.RedPills.HorseDamageUp, datatables.RedPills.HorseWavyCap)
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onRedPillHorse, enums.Pickups.RedPillHorse)
---domino 3|4
function EclipsedMod:onDomino34(card, player) -- card, player, useflag
	-- reroll items and pickups on floor
	local rng = player:GetCardRNG(card)
	game:RerollLevelCollectibles()
	game:RerollLevelPickups(rng:GetSeed())
	player:UseCard(Card.CARD_DICE_SHARD, datatables.MyUseFlags_Gene)
	game:ShakeScreen(10)
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onDomino34, enums.Pickups.Domino34)
---domino 2|5
function EclipsedMod:onDomino25(_, player) -- card, player, useflag
	-- respawn and reroll enemies
	local room = game:GetRoom()
	local data = player:GetData()
	-- after 3 frames reroll enemies
	data.Domino25Used = 3
	room:RespawnEnemies()
	game:ShakeScreen(10)
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onDomino25, enums.Pickups.Domino25)
---domino 0|0 -- Crooked penny?
function EclipsedMod:onDomino00(card, player) -- card, player, useflag
	local rng = player:GetCardRNG(card)
	local pickups = Isaac.FindByType(EntityType.ENTITY_PICKUP)

	--- kill/remove
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
				if not enemy:IsBoss() then --false
					enemy:Kill()
					--enemy:Remove()
				end
			end
		end
	--- double
	else
		if #pickups > 0 then
			for _, pickup in pairs(pickups) do
				local doubleIt = true
				if pickup.SubType == 0 then
					if pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE then
						doubleIt = false
					elseif datatables.BlackKnight.ChestVariant[pickup.Variant] then
						doubleIt = false
					end
				end
				if doubleIt then
					Isaac.Spawn(pickup.Type, pickup.Variant, pickup.SubType, Isaac.GetFreeNearPosition(pickup.Position, 40), Vector.Zero, nil)
				end
			end
		end
		player:UseActiveItem(CollectibleType.COLLECTIBLE_MEAT_CLEAVER, datatables.MyUseFlags_Gene)
	end
	game:ShakeScreen(10)
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onDomino00, enums.Pickups.Domino00)
---Soul of Unbidden
function EclipsedMod:onSoulUnbidden(_, player) -- card, player, useflag
	if #Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.ITEM_WISP)> 0 then
		functions.AddItemFromWisp(player, false)
	else
		player:UseActiveItem(CollectibleType.COLLECTIBLE_LEMEGETON, datatables.MyUseFlags_Gene)
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onSoulUnbidden, enums.Pickups.SoulUnbidden)
---Soul of NadabAbihu
function EclipsedMod:onSoulNadabAbihu(_, player) -- card, player, useflag
	local data = player:GetData()
	-- add fire tears and explosion immunity
	data.UsedSoulNadabAbihu = true  -- use check in MC_ENTITY_TAKE_DMG for explosion
	local tempEffects = player:GetEffects()
	tempEffects:AddCollectibleEffect(CollectibleType.COLLECTIBLE_FIRE_MIND, false, 1)
	-- hot bombs - just for costume. it doesn't give any actual effect
	tempEffects:AddCollectibleEffect(CollectibleType.COLLECTIBLE_HOT_BOMBS, true, 1)
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onSoulNadabAbihu, enums.Pickups.SoulNadabAbihu)
---ascender bane
function EclipsedMod:onAscenderBane(card, player) -- card, player, useflag
	--- remove 1 broken heart and add curse
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
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onAscenderBane, enums.Pickups.AscenderBane)
---multi-cast
function EclipsedMod:onMultiCast(_, player) -- card, player, useflag
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
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onMultiCast, enums.Pickups.MultiCast)
---wish
function EclipsedMod:onWish(_, player, useFlag) -- card, player, useflag
	if useFlag & UseFlag.USE_MIMIC == 0 then
		player:UseActiveItem(CollectibleType.COLLECTIBLE_MYSTERY_GIFT, datatables.MyUseFlags_Gene)
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onWish, enums.Pickups.Wish)
---offering
function EclipsedMod:onOffering(_, player) -- card, player, useflag
	player:UseActiveItem(CollectibleType.COLLECTIBLE_SACRIFICIAL_ALTAR, datatables.MyUseFlags_Gene)
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onOffering, enums.Pickups.Offering)
---infinite blades card
function EclipsedMod:onInfiniteBlades(card, player) -- card, player, useflag
	local rotationOffset = player:GetLastDirection() -- player:GetMovementInput()
	local newV = player:GetLastDirection()
	local rng = player:GetCardRNG(card)
	for _ = 1, datatables.InfiniteBlades.MaxNumber do
		local randX = rng:RandomInt(80) * (rng:RandomInt(3)-1)
		local randY = rng:RandomInt(80) * (rng:RandomInt(3)-1)

		local pos = Vector(player.Position.X + randX, player.Position.Y + randY)
		local knife = player:FireTear(pos, newV, false, true, false, nil, datatables.InfiniteBlades.DamageMulti):ToTear()
		knife:AddTearFlags(TearFlags.TEAR_PIERCING | TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_ACCELERATE)
		knife.Visible = false

		local knifeData = knife:GetData()
		knifeData.KnifeTear = true
		knifeData.InitAngle = rotationOffset

		local knifeSprite = knife:GetSprite()
		knifeSprite:ReplaceSpritesheet(0, datatables.InfiniteBlades.newSpritePath)
		knifeSprite:LoadGraphics()
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onInfiniteBlades, enums.Pickups.InfiniteBlades)
---transmutation card
function EclipsedMod:onTransmutation(_, player) -- card, player, useflag
	--- reroll enemies and pickups
	player:UseCard(Card.CARD_ACE_OF_SPADES, datatables.MyUseFlags_Gene)
	player:UseActiveItem(CollectibleType.COLLECTIBLE_D20, datatables.MyUseFlags_Gene)
	--player:UseCard(Card.CARD_DICE_SHARD, datatables.MyUseFlags_Gene)
	--player:UseActiveItem(CollectibleType.COLLECTIBLE_D100, datatables.MyUseFlags_Gene)
	--player:UseActiveItem(CollectibleType.COLLECTIBLE_CLICKER, datatables.MyUseFlags_Gene)
	--game:ShowHallucination(0, BackdropType.NUM_BACKDROPS)
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onTransmutation, enums.Pickups.Transmutation)
---ritual dagger card
function EclipsedMod:onRitualDagger(_, player) -- card, player, useflag
	--- add mom's knife for room
	local tempEffects = player:GetEffects()
	tempEffects:AddCollectibleEffect(CollectibleType.COLLECTIBLE_MOMS_KNIFE, true, 1)
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onRitualDagger, enums.Pickups.RitualDagger)
---fusion card
function EclipsedMod:onFusion(_, player) -- card, player, useflag
	--- throw a black hole
	player:UseActiveItem(CollectibleType.COLLECTIBLE_BLACK_HOLE, datatables.MyUseFlags_Gene)
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onFusion, enums.Pickups.Fusion)
---deus ex card
function EclipsedMod:onDeuxEx(_, player) -- card, player, useflag
	--- add 100 luck
	---OR effects based on room type? (refuses to elaborate)
	local data = player:GetData()
	data.DeuxExLuck = data.DeuxExLuck or 0
	data.DeuxExLuck = data.DeuxExLuck + datatables.DeuxEx.LuckUp
	player:AddCacheFlags(CacheFlag.CACHE_LUCK)
	player:EvaluateItems()
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onDeuxEx, enums.Pickups.DeuxEx)
---adrenaline card
function EclipsedMod:onAdrenaline(_, player) -- card, player, useflag
	--- add Adrenaline item effect for current room
	local tempEffects = player:GetEffects()
	tempEffects:AddCollectibleEffect(CollectibleType.COLLECTIBLE_ADRENALINE, true, 1) -- check if it works
	-- get red hearts amount
	local redHearts = player:GetHearts()
	-- loop if player has more than 1 full heart container
	if player:GetBlackHearts() > 0 or player:GetBoneHearts() > 0 or player:GetSoulHearts() > 0 then
		functions.AdrenalineManager(player, redHearts, 0)
	elseif redHearts > 1 then
		functions.AdrenalineManager(player, redHearts, 2) -- 0
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onAdrenaline, enums.Pickups.Adrenaline)
---corruption card
function EclipsedMod:onCorruption(_, player) -- card, player, useflag
	--- unlimited use of current active item in room, item will be removed on entering next room
	local data = player:GetData()
	-- set that corruption was used
	data.CorruptionIsActive = 10
	player:AddNullCostume(datatables.Corruption.CostumeHead)
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onCorruption, enums.Pickups.Corruption)
---GhostGem
function EclipsedMod:onGhostGem(_, player) -- card, player, useflag
	-- loop in soul numbers
	for _ = 1, datatables.GhostGem.NumSouls do
		-- spawn purgatory soul
		local purgesoul = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PURGATORY, 1, player.Position, Vector.Zero, player):ToEffect() -- subtype = 0 is rift, 1 is soul
 		-- change it's color
		purgesoul:SetColor(datatables.OblivionCard.PoofColor, 500, 1, false, true)
 		-- set animation (skip appearing from rift)
		purgesoul:GetSprite():Play("Charge", true)
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onGhostGem, enums.Pickups.GhostGem)
---battlefield
function EclipsedMod:onBattlefieldCard(card, player, _) -- card, player, useflag
	local rng = player:GetCardRNG(card)
	local data = player:GetData()
	data.UsedBattleFieldCard = true
	Isaac.ExecuteCommand("goto s.challenge." .. rng:RandomInt(8)+16)  --0 .. 15 - normal; 16 .. 24 - boss
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onBattlefieldCard, enums.Pickups.BattlefieldCard)
---treasury
function EclipsedMod:onTreasuryCard(card, player, _) -- card, player, useflag
	local rng = player:GetCardRNG(card)
	Isaac.ExecuteCommand("goto s.treasure." .. rng:RandomInt(56))
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onTreasuryCard, enums.Pickups.TreasuryCard)
---bookery
function EclipsedMod:onBookeryCard(card, player, _) -- card, player, useflag
	local rng = player:GetCardRNG(card)
	Isaac.ExecuteCommand("goto s.library." .. rng:RandomInt(18))
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onBookeryCard, enums.Pickups.BookeryCard)
---blood grove
function EclipsedMod:onBloodGroveCard(card, player) -- card, player, useflag
	local rng = player:GetCardRNG(card)
	local num = rng:RandomInt(10)+31 -- 0 .. 30 / 31 .. 40 for voodoo head
	Isaac.ExecuteCommand("goto s.curse." .. num)
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onBloodGroveCard, enums.Pickups.BloodGroveCard)
---storm temple
function EclipsedMod:onStormTempleCard(card, player) -- card, player, useflag
	local rng = player:GetCardRNG(card)
	Isaac.ExecuteCommand("goto s.angel." .. rng:RandomInt(22))
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onStormTempleCard, enums.Pickups.StormTempleCard)
---arsenal
function EclipsedMod:onArsenalCard(card, player) -- card, player, useflag
	local rng = player:GetCardRNG(card)
	Isaac.ExecuteCommand("goto s.chest." .. rng:RandomInt(49))
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onArsenalCard, enums.Pickups.ArsenalCard)
---outport
function EclipsedMod:onOutpostCard(card, player) -- card, player, useflag
	local rng = player:GetCardRNG(card)
	if rng:RandomFloat() > 0.5 then
		Isaac.ExecuteCommand("goto s.isaacs." .. rng:RandomInt(30))
	else
		Isaac.ExecuteCommand("goto s.barren." .. rng:RandomInt(29))
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onOutpostCard, enums.Pickups.OutpostCard)
---ancestral crypt
function EclipsedMod:onCryptCard(card, player) -- card, player, useflag
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
	data.CryptUsed = true -- used to relocate player position, cause clip to error room
	Isaac.ExecuteCommand("goto s.itemdungeon." .. num)
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onCryptCard, enums.Pickups.CryptCard)
---maze of memory
function EclipsedMod:onMazeMemoryCard(_, player, useFlag) -- card, player, useflag
	if useFlag & UseFlag.USE_MIMIC == 0 then
		local level = game:GetLevel()
		if not player:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE) then
			level:AddCurse(LevelCurse.CURSE_OF_BLIND, false)
		end
		local data = player:GetData()
		game:StartRoomTransition(level:GetCurrentRoomIndex(), 1, RoomTransitionAnim.DEATH_CERTIFICATE, player, -1)
		data.MazeMemoryUsed = {20, 18}
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onMazeMemoryCard, enums.Pickups.MazeMemoryCard)
---zero stone
function EclipsedMod:onZeroMilestoneCard() -- card, player, useflag
	-- Reworked
	local pos = Isaac.GetFreeNearPosition(game:GetRoom():GetCenterPos(), 0)
	local pickup = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, enums.Items.BookMemory, pos, Vector.Zero, nil):ToPickup()
	pickup:GetData().ZeroMilestoneItem = true
	
	datatables.ZeroMilestoneItems = datatables.ZeroMilestoneItems or {}
	local seedItem = tostring(pickup:GetDropRNG():GetSeed()) 
	datatables.ZeroMilestoneItems[seedItem] = true
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onZeroMilestoneCard, enums.Pickups.ZeroMilestoneCard)
---pot of greed
function EclipsedMod:onBannedCard(card, player) -- card, player, useflag
	for _ = 1, datatables.BannedCard.NumCards do
		Isaac.Spawn(5, 300, card, player.Position, RandomVector()*3, nil)
	end
	game:GetHUD():ShowFortuneText("POT OF GREED ALLOWS ME","TO DRAW TWO MORE CARDS!")
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onBannedCard, enums.Pickups.BannedCard)
---Decay
function EclipsedMod:onDecay(_, player) -- card, player, useflag
	local redHearts = player:GetHearts()
	local data = player:GetData()

	if redHearts > 0 then
		player:AddHearts(-redHearts)
		player:AddRottenHearts(redHearts)
	end
	data.DecayLevel = data.DecayLevel or true
	functions.TrinketRemoveAdd(player, TrinketType.TRINKET_APPLE_OF_SODOM)
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onDecay, enums.Pickups.Decay)



---Domino16
function EclipsedMod:onDomino16(card, player) -- card, player, useflag
	local rng = player:GetCardRNG(card)
	local pos = player.Position
	functions.Domino16Items(rng, pos)
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onDomino16, enums.Pickups.Domino16)
end
---Delirious Pickups
function EclipsedMod:useDeliObject(card, player) -- card, player, useFlag
	if datatables.DeliObject.CheckGetCard[card] then
		local rng = player:GetCardRNG(card)
		if rng:RandomFloat() >= datatables.DeliObject.Chance then
			functions.DebugSpawn(300, datatables.DeliObject.Variants[rng:RandomInt(#datatables.DeliObject.Variants)+1], player.Position)

			--[[
				print(slot, player:GetCard(slot), player:GetPill(slot), player:GetActiveItem(itemslot))
				if player:GetCard(slot) == 0 and player:GetPill(slot) == 0 and player:GetActiveItem(itemslot) == 0 then 
					player:SetCard(slot, datatables.DeliObject.Variants[rng:RandomInt(#datatables.DeliObject.Variants)+1])
			
			end
			--]]
		end
		--- cell
		if card == enums.Pickups.DeliObjectCell then
			if datatables.DeliriumBeggarEnemies and #datatables.DeliriumBeggarEnemies > 0 then
				local spawnpos = Isaac.GetFreeNearPosition(player.Position, 35)
				datatables.DeliriumBeggarEnemies = datatables.DeliriumBeggarEnemies or {EntityType.ENTITY_GAPER, 0}
				local savedOnes = datatables.DeliriumBeggarEnemies[rng:RandomInt(#datatables.DeliriumBeggarEnemies)+1]
				local npc = Isaac.Spawn(savedOnes[1], savedOnes[2], 0, spawnpos, Vector.Zero, player):ToNPC()
				npc:AddCharmed(EntityRef(player), -1)
			end
		--- bomb
		elseif card == enums.Pickups.DeliObjectBomb then
			local bombVar = BombVariant.BOMB_NORMAL
			local randNum = rng:RandomInt(4) -- 0 ~ 3
			if rng:RandomFloat() < datatables.DeliObject.TrollCBombChance then
				if randNum == 1 then
					bombVar = BombVariant.BOMB_SUPERTROLL
				elseif randNum == 2 then
					bombVar = BombVariant.BOMB_GOLDENTROLL
				else
					bombVar = BombVariant.BOMB_TROLL
				end
				Isaac.Spawn(EntityType.ENTITY_BOMB, bombVar, 0, player.Position, Vector.Zero, nil):ToBomb()
			else
				local bombFlags = TearFlags.TEAR_NORMAL
				for _ = 0, randNum do
					bombFlags = bombFlags | datatables.DeliObject.BombFlags[rng:RandomInt(#datatables.DeliObject.BombFlags)+1]
				end

				local bomb = Isaac.Spawn(EntityType.ENTITY_BOMB, BombVariant.BOMB_NORMAL, 0, player.Position, Vector.Zero, player):ToBomb()
				bomb:AddTearFlags(bombFlags)
			end
		--- key
		elseif card == enums.Pickups.DeliObjectKey then
			local nearestChest = 5000
			local nearestDoor = 5000
			local room = game:GetRoom()
			local door
			local chest
			local pickups = Isaac.FindInRadius(player.Position, 5000, EntityPartition.PICKUP)
			if #pickups > 0 then
				for _, pickup in pairs(pickups) do
					if pickup.Type == EntityType.ENTITY_PICKUP then
						if pickup.Variant == PickupVariant.PICKUP_ETERNALCHEST or pickup.Variant == PickupVariant.PICKUP_MEGACHEST or pickup.Variant == PickupVariant.PICKUP_LOCKEDCHEST then
							if player.Position:Distance(pickup.Position) < nearestChest and pickup.SubType > 0 then
								nearestChest = player.Position:Distance(pickup.Position)
								chest = pickup
							end
						end
					end
				end
			end
			for slot = 0, DoorSlot.NUM_DOOR_SLOTS do
				if room:GetDoor(slot) then
					local grid = room:GetDoor(slot)
					local doorVar = grid:GetVariant()
					if doorVar == DoorVariant.DOOR_LOCKED or doorVar == DoorVariant.DOOR_LOCKED_DOUBLE then
						if player.Position:Distance(grid.Position) < nearestDoor then
							nearestDoor = player.Position:Distance(grid.Position)
							door = grid
						end
					end
				end
			end
			if nearestChest < nearestDoor and chest then
				chest:ToPickup():TryOpenChest()
				sfx:Play(SoundEffect.SOUND_UNLOCK00, 1, 0, false, 1, 0)
			elseif nearestDoor <= nearestChest and door then
				door:TryUnlock(player, true)
				sfx:Play(SoundEffect.SOUND_UNLOCK00, 1, 0, false, 1, 0)
			else
				local level= game:GetLevel()
				for slot = 0, DoorSlot.NUM_DOOR_SLOTS do
					if level:MakeRedRoomDoor(level:GetCurrentRoomIndex(), slot) then break end
				end
			end
		--- card
		elseif card == enums.Pickups.DeliObjectCard then
			local randCard = itemPool:GetCard(rng:GetSeed(), true, false, false)
			player:UseCard(randCard, datatables.MyUseFlags_Deli)
		--- pill
		elseif card == enums.Pickups.DeliObjectPill then
			local randPill = rng:RandomInt(PillEffect.NUM_PILL_EFFECTS)
			player:UsePill(randPill, 0, datatables.MyUseFlags_Deli)
			player:AnimateCard(card)
		--- rune
		elseif card == enums.Pickups.DeliObjectRune then
			local randCard = itemPool:GetCard(rng:GetSeed(), false, false, true)
			player:UseCard(randCard, datatables.MyUseFlags_Deli)
		--- heart
		elseif card == enums.Pickups.DeliObjectHeart then
			local randNum = rng:RandomInt(9)
			if randNum == 1 then
				player:AddHearts(2)
				sfx:Play(SoundEffect.SOUND_VAMP_GULP, 1, 0, false, 1, 0)
			elseif randNum == 2 then
				player:AddBlackHearts(2)
				sfx:Play(SoundEffect.SOUND_HOLY, 1, 0, false, 1, 0)
			elseif randNum == 3 then
				player:AddBoneHearts(1)
				sfx:Play(SoundEffect.SOUND_BONE_HEART, 1, 0, false, 1, 0)
			elseif randNum == 4 then
				player:AddBrokenHearts(1)
				sfx:Play(SoundEffect.SOUND_POISON_HURT, 1, 0, false, 1, 0)
			elseif randNum == 5 then
				player:AddEternalHearts(1)
				sfx:Play(SoundEffect.SOUND_SUPERHOLY, 1, 0, false, 1, 0)
			elseif randNum == 6 then
				player:AddMaxHearts(2)
				sfx:Play(SoundEffect.SOUND_1UP, 1, 0, false, 1, 0)
			elseif randNum == 7 then
				player:AddRottenHearts(1)
				sfx:Play(SoundEffect.SOUND_ROTTEN_HEART, 1, 0, false, 1, 0)
			elseif randNum == 8 then
				player:AddSoulHearts(2)
				sfx:Play(SoundEffect.SOUND_HOLY, 1, 0, false, 1, 0)
			else
				player:AddGoldenHearts(1)
				sfx:Play(SoundEffect.SOUND_GOLD_HEART, 1, 0, false, 1, 0)
			end
		--- coin
		elseif card == enums.Pickups.DeliObjectCoin then
			local randNum = rng:RandomInt(4)
			if randNum == 1 then
				player:AddCoins (1)
				sfx:Play(SoundEffect.SOUND_PENNYPICKUP, 1, 0, false, 1, 0)
			elseif randNum == 2 then
				player:AddCoins (5)
				sfx:Play(SoundEffect.SOUND_NICKELPICKUP, 1, 0, false, 1, 0)
			elseif randNum == 3 then
				player:AddCoins (10)
				sfx:Play(SoundEffect.SOUND_DIMEPICKUP, 1, 0, false, 1, 0)
			else
				player:AddCoins (1)
				player:DonateLuck (1)
				sfx:Play(SoundEffect.SOUND_LUCKYPICKUP, 1, 0, false, 1, 0)
			end
		--- battery
		elseif card == enums.Pickups.DeliObjectBattery then
			local randNum = rng:RandomInt(3) -- 0 is 2 charges, 1 is full charge, 2 - overcharge
			local charge = 2 -- if randNum = 0
			local overCharge = false
			if randNum == 2 or player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) then overCharge = true end
			for slot = 0, 3 do
				local activeItem = player:GetActiveItem(slot)
				if activeItem ~= 0 then
					if randNum > 1 then
						charge = Isaac.GetItemConfig():GetCollectible(activeItem).MaxCharges
					end
					if overCharge and player:GetBatteryCharge(slot) < charge then
						player:SetActiveCharge(charge*2, slot)
						Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BATTERY, 0, Vector(player.Position.X, player.Position.Y-70), Vector.Zero, nil)
						sfx:Play(SoundEffect.SOUND_BATTERYCHARGE, 1, 0, false, 1, 0)
						break
					elseif player:GetActiveCharge(slot) < charge then
						player:SetActiveCharge(charge, slot)
						Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BATTERY, 0, Vector(player.Position.X, player.Position.Y-70), Vector.Zero, nil) --i'm too lazy to adjust right position with spritescale (и так сойдет!)
						sfx:Play(SoundEffect.SOUND_BATTERYCHARGE, 1, 0, false, 1, 0)
						break
					end
				end
			end
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.useDeliObject)

function EclipsedMod:onExplodingKitten(_, player) -- card, player, useflag
	local room = game:GetRoom()
	room:MamaMegaExplosion(player.Position)
	--Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.MAMA_MEGA_EXPLOSION, 0, player.Position, Vector.Zero, player)
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onExplodingKitten, enums.Pickups.KittenBomb)

function EclipsedMod:onExplodingKitten2(_, player) -- card, player, useflag
	local room = game:GetRoom()
	for _ = 1, 3 do
		local randPos = room:FindFreePickupSpawnPosition(player.Position)
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, randPos, Vector.Zero, nil)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_GIGA, randPos, Vector.Zero, player)
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onExplodingKitten2, enums.Pickups.KittenBomb2)

function EclipsedMod:onKittenDefuse() -- card, player, useflag
	local trollbombs = Isaac.FindByType(EntityType.ENTITY_BOMB)
	if #trollbombs > 0 then
		for _, trollbomb in pairs(trollbombs) do
			if datatables.DefuseCardBombs[trollbomb.Variant] then
				local newBomb = datatables.DefuseCardBombs[trollbomb.Variant]
				trollbomb:Remove()
				Isaac.Spawn(newBomb[1], newBomb[2], newBomb[3], trollbomb.Position, trollbomb.Velocity, nil)
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, trollbomb.Position, Vector.Zero, nil)
			end
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onKittenDefuse, enums.Pickups.KittenDefuse)

function EclipsedMod:onKittenDefuse2(_, player) -- card, player, useflag
	player:UseActiveItem(CollectibleType.COLLECTIBLE_TELEKINESIS, datatables.MyUseFlags_Gene)
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onKittenDefuse2, enums.Pickups.KittenDefuse2)

function EclipsedMod:onKittenFuture(_, player) -- card, player, useflag
	player:UseActiveItem(CollectibleType.COLLECTIBLE_TELEPORT_2, datatables.MyUseFlags_Gene)
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onKittenFuture, enums.Pickups.KittenFuture)

function EclipsedMod:onKittenFuture2(_, player) -- card, player, useflag
	if not player:HasCollectible(CollectibleType.COLLECTIBLE_ANKH) then
		player:AddCollectible(CollectibleType.COLLECTIBLE_ANKH)
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onKittenFuture2, enums.Pickups.KittenFuture2)

function EclipsedMod:onKittenNope(_, player) -- card, player, useflag
	player:UseActiveItem(CollectibleType.COLLECTIBLE_PAUSE, datatables.MyUseFlags_Gene)
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onKittenNope, enums.Pickups.KittenNope)

function EclipsedMod:onKittenNope2(_, player) -- card, player, useflag
	local tempEffects = player:GetEffects()
	tempEffects:AddCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE, true, 1)
	if player:GetPlayerType() == enums.Characters.UnbiddenB then
		local data = player:GetData()
		data.UnbiddenUsedHolyCard = data.UnbiddenUsedHolyCard or 0
		data.UnbiddenUsedHolyCard = data.UnbiddenUsedHolyCard + 1
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onKittenNope2, enums.Pickups.KittenNope2)

function EclipsedMod:onKittenSkip() -- card, player, useflag
	local room = game:GetRoom()
	if room:GetType() ~= RoomType.ROOM_BOSS and not room:IsClear() then
		for gridIndex = 1, room:GetGridSize() do -- get room size
			local grid = room:GetGridEntity(gridIndex)
			if grid and grid:ToDoor() then
				grid:ToDoor():Open()
			end
		end
		datatables.FoolCurseNoRewards = true
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onKittenSkip, enums.Pickups.KittenSkip)

function EclipsedMod:onKittenSkip2(_, player) -- card, player, useflag
	local data = player:GetData()
	data.UsedKittenSkip2 = true
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onKittenSkip2, enums.Pickups.KittenSkip2)

function EclipsedMod:onKittenFavor(_, player) -- card, player, useflag
	player:UseActiveItem(enums.Items.StrangeBox, datatables.MyUseFlags_Gene)
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onKittenFavor, enums.Pickups.KittenFavor)

function EclipsedMod:onKittenFavor2(_, player) -- card, player, useflag
	for i = 1, 5 do
		player:UseCard(Card.CARD_SOUL_ISAAC, datatables.MyUseFlags_Gene)
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onKittenFavor2, enums.Pickups.KittenFavor2)

function EclipsedMod:onKittenShuffle(_, player) -- card, player, useflag
	player:AddCollectible(CollectibleType.COLLECTIBLE_TMTRAINER)
	player:UseActiveItem(CollectibleType.COLLECTIBLE_D6, datatables.MyUseFlags_Gene) -- D6 effect
	player:RemoveCollectible(CollectibleType.COLLECTIBLE_TMTRAINER)
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onKittenShuffle, enums.Pickups.KittenShuffle)

function EclipsedMod:onKittenShuffle2(_, player) -- card, player, useflag
	player:AddCollectible(CollectibleType.COLLECTIBLE_MISSING_NO)
	local data = player:GetData()
	data.UsedKittenShuffle2 = 1
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onKittenShuffle2, enums.Pickups.KittenShuffle2)

function EclipsedMod:onKittenAttack(_, player) -- card, player, useflag
	player:UseActiveItem(CollectibleType.COLLECTIBLE_SHOOP_DA_WHOOP, datatables.MyUseFlags_Gene)
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onKittenAttack, enums.Pickups.KittenAttack)

function EclipsedMod:onKittenAttack2(_, player) -- card, player, useflag
	player:UseActiveItem(CollectibleType.COLLECTIBLE_LARYNX, datatables.MyUseFlags_Gene | UseFlag.USE_CUSTOMVARDATA, -1, 12)
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onKittenAttack2, enums.Pickups.KittenAttack2)


-- memory fragment
function EclipsedMod:onBookMemoryCard(card, player, useFlag) -- card, player, useFlag
	if useFlag & UseFlag.USE_MIMIC == 0 then
		local data = player:GetData()
		if not data.MemoryFragment then data.MemoryFragment = {} end
		table.insert(data.MemoryFragment, {300, card})
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onBookMemoryCard)

function EclipsedMod:onBookMemoryPill(pillEffect, player, useFlag) --pillEffect, player, flags
	if useFlag & UseFlag.USE_MIMIC == 0 then
		local data = player:GetData()
		if not data.MemoryFragment then data.MemoryFragment = {} end
		for pillColor=1, PillColor.NUM_PILLS do
			if itemPool:GetPillEffect(pillColor) == pillEffect then
				table.insert(data.MemoryFragment, {70, pillColor})
				break
			elseif pillColor == PillColor.NUM_PILLS then
				table.insert(data.MemoryFragment, {70, PillColor.PILL_GOLD})
			end
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_PILL, EclipsedMod.onBookMemoryPill)


---cemetery
function EclipsedMod:onCemeteryCard(_, player, _) -- card, player, useflag
	local data = player:GetData()
	data.UsedCemeteryCard = true
	data.UsedLoopCard = true
	Isaac.ExecuteCommand("goto s.supersecret.6")
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onCemeteryCard, enums.Pickups.CemeteryCard)

---village
function EclipsedMod:onVillageCard(card, player, _) -- card, player, useflag
	local rng = player:GetCardRNG(card)
	Isaac.ExecuteCommand("goto s.arcade." .. rng:RandomInt(52))
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onVillageCard, enums.Pickups.VillageCard)

---grove
function EclipsedMod:onGroveCard(card, player, _) -- card, player, useflag
	local rng = player:GetCardRNG(card)
	local data = player:GetData()
	data.UsedGroveCard = true
	Isaac.ExecuteCommand("goto s.challenge." .. rng:RandomInt(5)) -- The item will be from the Treasure Room pool.
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onGroveCard, enums.Pickups.GroveCard)

---wheat fields
function EclipsedMod:onWheatFieldsCard(card, player, _) -- card, player, useflag
	local data = player:GetData()
	data.UsedWheatFieldsCard = true
	Isaac.ExecuteCommand("goto s.chest.31") --Nine random pickups.
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onWheatFieldsCard, enums.Pickups.WheatFieldsCard)

---swamp
function EclipsedMod:onSwampCard(_, player, _) -- card, player, useflag
	local data = player:GetData()
	data.UsedSwampCard = true
	data.UsedLoopCard = true
	Isaac.ExecuteCommand("goto s.supersecret.23") -- corpse backdrop/ spawn rotten hearts and rotten beggar
	
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onSwampCard, enums.Pickups.SwampCard)

---ruins
function EclipsedMod:onRuinsCard(card, player, _) -- card, player, useflag
	local rng = player:GetCardRNG(card)
	local data = player:GetData()
	data.UsedLoopCard = true
	Isaac.ExecuteCommand("goto s.secret." .. rng:RandomInt(39)) --
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onRuinsCard, enums.Pickups.RuinsCard)

---spider cocoon
function EclipsedMod:onSpiderCocoonCard(card, player, _) -- card, player, useflag
	player:UseActiveItem(CollectibleType.COLLECTIBLE_SPIDER_BUTT, datatables.MyUseFlags_Gene)
	player:UseActiveItem(CollectibleType.COLLECTIBLE_BOX_OF_SPIDERS, datatables.MyUseFlags_Gene)
	player:UsePill(PillEffect.PILLEFFECT_INFESTED_EXCLAMATION, 0, datatables.MyUseFlags_Deli)
	player:UsePill(PillEffect.PILLEFFECT_INFESTED_QUESTION, 0, datatables.MyUseFlags_Deli)
	player:AnimateCard(card)
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onSpiderCocoonCard, enums.Pickups.SpiderCocoonCard)

---vampire mansion
function EclipsedMod:onVampireMansionCard(_, player, _) -- card, player, useflag
	local data = player:GetData()
	data.UsedVampireMansionCard = true
	data.UsedLoopCard = true
	Isaac.ExecuteCommand("goto s.supersecret.6") -- library backdrop/ spawn black heart and devil beggar
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onVampireMansionCard, enums.Pickups.VampireMansionCard)

---road lantern
function EclipsedMod:onRoadLanternCard(_, player) -- card, player, useflag
	local itemwisp = player:AddItemWisp(CollectibleType.COLLECTIBLE_SPELUNKER_HAT, player.Position, true)
	if itemwisp then
		itemwisp.HitPoints = 1
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onRoadLanternCard, enums.Pickups.RoadLanternCard)

---smith's forge
function EclipsedMod:onSmithForgeCard(_, player, _) -- card, player, useflag
	player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, datatables.MyUseFlags_Gene)
	Isaac.ExecuteCommand("goto s.chest.12") -- Three trinkets.
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onSmithForgeCard, enums.Pickups.SmithForgeCard)

---chrono crystals
function EclipsedMod:onChronoCrystalsCard(_, player) -- card, player, useflag
	local itemwisp = player:AddItemWisp(CollectibleType.COLLECTIBLE_BROKEN_MODEM, player.Position, true)
	if itemwisp then
		itemwisp.HitPoints = 1
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onChronoCrystalsCard, enums.Pickups.ChronoCrystalsCard)

--- witch hut
function EclipsedMod:onWitchHut(_, player, _) -- card, player, useflag
	local data = player:GetData()
	data.UsedLoopCard = true
	Isaac.ExecuteCommand("goto s.supersecret.19") -- 9 random pills
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onWitchHut, enums.Pickups.WitchHut)

--- beacon
function EclipsedMod:onBeaconCard(card, player, _) -- card, player, useflag
	Isaac.ExecuteCommand("goto s.shop.14") -- shop
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onBeaconCard, enums.Pickups.BeaconCard)

--- temporal beacon
function EclipsedMod:onTemporalBeaconCard(card, player, _) -- card, player, useflag
	Isaac.ExecuteCommand("goto s.shop.11") -- angel shops
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onTemporalBeaconCard, enums.Pickups.TemporalBeaconCard)

---################################################################################################

local function ExplosionEffect(player, bombPos, bombDamage, bombFlags, damageSource)
	local data = player:GetData()
	local radius = functions.GetBombRadiusFromDamage(bombDamage)
	local bombRadiusMult = 1
	if damageSource == nil then damageSource = true end
	if player:HasCollectible(enums.Items.FrostyBombs) then
		bombFlags = bombFlags | TearFlags.TEAR_SLOW | TearFlags.TEAR_ICE
		if bombFlags & TearFlags.TEAR_SAD_BOMB == TearFlags.TEAR_SAD_BOMB then
			data.SadIceBombTear = data.SadIceBombTear or {}
			local timer = 1
			local pos = bombPos
			table.insert(data.SadIceBombTear, {timer, pos})
		end
	end

	if bombFlags & TearFlags.TEAR_STICKY == TearFlags.TEAR_STICKY then
		for _, entity in pairs(Isaac.FindInRadius(bombPos, datatables.NadabData.StickySpiderRadius, EntityPartition.ENEMY)) do
			if entity:IsVulnerableEnemy() and entity:IsActiveEnemy() then
				entity:AddEntityFlags(EntityFlag.FLAG_SPAWN_STICKY_SPIDERS)
			end
		end
	end
	
	game:BombExplosionEffects(bombPos, bombDamage, bombFlags, Color.Default, player, bombRadiusMult, true, damageSource, DamageFlag.DAMAGE_EXPLOSION)

	if player:HasCollectible(enums.Items.CompoBombs) then
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_THROWABLEBOMB, 0,  Isaac.GetFreeNearPosition(bombPos, 1), Vector.Zero, player):ToPickup()
	end

	if player:HasCollectible(CollectibleType.COLLECTIBLE_BOBS_CURSE) then
		local cloud = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SMOKE_CLOUD, 0, bombPos, Vector.Zero, player):ToEffect()
		cloud:SetTimeout(150)
	end

	if bombFlags & TearFlags.TEAR_GHOST_BOMB == TearFlags.TEAR_GHOST_BOMB then
		local soul = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HUNGRY_SOUL, 1, bombPos, Vector.Zero, player):ToEffect()
		soul:SetTimeout(360)
	end

	if bombFlags & TearFlags.TEAR_SCATTER_BOMB == TearFlags.TEAR_SCATTER_BOMB then
		local num = myrng:RandomInt(2)+4 -- (0 ~ 1) + 4 = 4 ~ 5
		for _ = 1, num do
			player:AddMinisaac(bombPos, true)
		end
	end

	if player:HasTrinket(enums.Trinkets.BobTongue) then
		local fartRingEffect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.FART_RING, 0, bombPos, Vector.Zero, nil):ToEffect()
		fartRingEffect:SetTimeout(30)
	end

	functions.DeadEggEffect(player, bombPos, datatables.DeadEgg.Timeout)

	if player:HasCollectible(enums.Items.GravityBombs) then
		local holeEffect = Isaac.Spawn(EntityType.ENTITY_EFFECT, datatables.GravityBombs.BlackHoleEffect, 0, bombPos, Vector.Zero, nil):ToEffect()
		holeEffect:SetTimeout(60)
		local holeData = holeEffect:GetData()
		holeEffect.Parent = player
		holeEffect.DepthOffset = -100
		holeData.Gravity = true
		holeData.GravityForce = datatables.GravityBombs.AttractorForce
		holeData.GravityRange = datatables.GravityBombs.AttractorRange
		holeData.GravityGridRange = datatables.GravityBombs.AttractorGridRange
	end

	if player:HasCollectible(enums.Items.DiceBombs) then
		functions.DiceyReroll(player:GetCollectibleRNG(enums.Items.DiceBombs), bombPos, radius)
	end

	if player:HasCollectible(enums.Items.BatteryBombs) then
		functions.ChargedBlast(bombPos, radius, bombDamage, player)
	end

	if player:HasCollectible(enums.Items.DeadBombs) then
		functions.BonnyBlast(player:GetCollectibleRNG(enums.Items.DeadBombs), bombPos, radius, player)
	end

	if player:HasCollectible(enums.Items.Pyrophilia) then
		for _, enemy in pairs(Isaac.FindInRadius(bombPos, radius, EntityPartition.ENEMY)) do
			if enemy:IsVulnerableEnemy() and enemy:IsActiveEnemy() then
				player:AddHearts(1)
				sfx:Play(SoundEffect.SOUND_VAMP_GULP)
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HEART, 0, Vector(player.Position.X, player.Position.Y-70), Vector.Zero, nil)
				break
			end
		end
	end
end


datatables.NadabBody = {}
datatables.NadabBody.SpritePath = "gfx/familiar/nadabbody.png"
datatables.NadabBody.RocketVol = 30
---Nadab's Body
local function BodyExplosion(player, useGiga, bombPos, damageSource)
	local data = player:GetData()
	local bombFlags = player:GetBombFlags()
	local bombDamage = player.Damage * 15
	if player:HasCollectible(CollectibleType.COLLECTIBLE_MR_MEGA) then
		bombDamage = player.Damage * 25
	end
	if data.GigaBombs then
		if data.GigaBombs > 0 then
			if useGiga then
				data.GigaBombs = data.GigaBombs - 1
			end
			bombFlags = bombFlags | TearFlags.TEAR_GIGA_BOMB
			bombDamage = player.Damage * 75
		end
	end
	ExplosionEffect(player, bombPos, bombDamage, bombFlags, damageSource)
end

local function FcukingBomberbody(player, body)
	if body then
		local damageSource = true
		if body:GetData().PlayerIsSoul then
			damageSource = false
		end
		if player:HasCollectible(enums.Items.MirrorBombs) then
			if body:GetData().bomby then
				BodyExplosion(player, false, functions.FlipMirrorPos(body.Position), damageSource)
			end
		end
		if body:GetData().bomby then
			if player:HasTrinket(TrinketType.TRINKET_RING_CAP) then
				body:GetData().RingCapDelay = 0 
			end
			BodyExplosion(player, true, body.Position, damageSource)
		end
	else
		local bodies = Isaac.FindByType(EntityType.ENTITY_BOMB, BombVariant.BOMB_DECOY)
		if player:HasCollectible(enums.Items.MirrorBombs) then
			for _, bomb in pairs(bodies) do
				if bomb:GetData().bomby then
					BodyExplosion(player, false, functions.FlipMirrorPos(bomb.Position))
				end
			end
		end
		for _, bomb in pairs(bodies) do
			if bomb:GetData().bomby then
				if player:HasTrinket(TrinketType.TRINKET_RING_CAP) then
					bomb:GetData().RingCapDelay = 0 
				end
				BodyExplosion(player, true, bomb.Position)
			end
		end
	end
end
---Nadab's Body
local function NadabBodyDamageGrid(position)
	local room = game:GetRoom()
	local griden = room:GetGridEntityFromPos(position)
	if griden and (griden:ToPoop() or griden:ToTNT()) then
		griden:Hurt(1)
	end
end
--new room
---Nadab's Body
function EclipsedMod:onNewRoom3()
	---Nadab's Body
	if #Isaac.FindByType(EntityType.ENTITY_BOMB, BombVariant.BOMB_DECOY) > 0 then
		local bodies = Isaac.FindByType(EntityType.ENTITY_BOMB, BombVariant.BOMB_DECOY)
		for _, body in pairs(bodies) do
			if body.SpawnerEntity == nil or body:GetData().bomby then
				body:Remove()
			end
		end
	end

	--player
	for playerNum = 0, game:GetNumPlayers()-1 do
		local player = game:GetPlayer(playerNum)
		local data = player:GetData()
		if player:GetPlayerType() == enums.Characters.Abihu then
			data.AbihuIgnites = false
			if data.AbihuCostumeEquipped then
				data.AbihuCostumeEquipped = false
				--player:AddNullCostume(datatables.AbihuData.CostumeHead)
				player:TryRemoveNullCostume(datatables.AbihuData.CostumeHead)
			end
		end
		
		if player:GetPlayerType() == enums.Characters.UnbiddenB then
			local tempEffects = player:GetEffects()
			--print(tempEffects:HasNullEffect(NullItemID.ID_LOST_B))
			if not tempEffects:HasNullEffect(NullItemID.ID_LOST_CURSE) then
				tempEffects:AddNullEffect(NullItemID.ID_LOST_CURSE, false, 1)
			end
		end
		
		if data.BlindAbihu then
			--print(data.BlindAbihu, data.BlindUnbidden, data.ResetBlind)
			data.ResetBlind = 1 -- reset blindfold after 60 frames
		end
		
		--print(player:HasCollectible(enums.Items.NadabBody, t))
		if functions.GetItemsCount(player, enums.Items.NadabBody, true) > 0 then
			for _=1, functions.GetItemsCount(player, enums.Items.NadabBody, true) do
				local pos = Isaac.GetFreeNearPosition(player.Position, 25)
				if data.HoldBomd and data.HoldBomd >= 0 then
					data.HoldBomd = -1
					pos = player.Position
				end
				local bomb = Isaac.Spawn(EntityType.ENTITY_BOMB, BombVariant.BOMB_DECOY, 0, pos, Vector.Zero, nil):ToBomb()
				--bomb:AddTearFlags(player:GetBombFlags())
				bomb:GetData().bomby = true
				bomb:GetSprite():ReplaceSpritesheet(0, datatables.NadabBody.SpritePath)
				bomb:GetSprite():LoadGraphics()
				bomb.Parent = player
			end
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, EclipsedMod.onNewRoom3)
---Nadab's Body
function EclipsedMod:onBombNadabUpdate(bomb)
	---bomb updates
	local bombData = bomb:GetData()
	local room = game:GetRoom()
	if bombData.bomby and bomb.Parent then

		local player = bomb.Parent:ToPlayer()
		bomb:SetExplosionCountdown(1) -- so it doesn't explode
		
		--ring cap explosion
		if bombData.RingCapDelay then
			bombData.RingCapDelay = bombData.RingCapDelay + 1
			if bombData.RingCapDelay > player:GetTrinketMultiplier(TrinketType.TRINKET_RING_CAP) * datatables.NadabData.RingCapFrameCount then
				bombData.RingCapDelay = nil
			elseif bombData.RingCapDelay % datatables.NadabData.RingCapFrameCount == 0 then
				if player:HasCollectible(enums.Items.MirrorBombs) then
					BodyExplosion(player, false, functions.FlipMirrorPos(bomb.Position))
				end
				BodyExplosion(player, false, bomb.Position)
			end
		end
		
		-- get grid
		local grid = room:GetGridEntityFromPos(bomb.Position)
		if grid then
			-- if it's pressure plate, not grid mode plate and wasn't pressed
			if grid:ToPressurePlate() and grid:GetVariant() < 2 and grid.State == 0 then
				grid.State = 3
				grid:ToPressurePlate():Reward()
				grid:GetSprite():Play("On")
				grid:Update()
			-- else if it's out of room or inside a pit + wasn't thrown and [player can't fly(?)]
			--elseif (not room:IsPositionInRoom(bomb.Position, 0) or grid:ToPit()) and not bombData.Thrown then -- and not player.CanFly then
			--	bomb:Kill()
			--	return
			end
		end

		-- if it's held by player,
		if bomb:HasEntityFlags(EntityFlag.FLAG_HELD) then
			bombData.Thrown = 60

		else
			-- block tears only while not held
			local enemyTears = Isaac.FindInRadius(bomb.Position, 20, EntityPartition.BULLET)
			if #enemyTears > 0 then
				for _, enemyTear in pairs(enemyTears) do
					enemyTear:Kill()
				end
			end
		end

		-- was thrown
		if bombData.Thrown then
			bombData.Thrown = bombData.Thrown - 1
			if bombData.Thrown <= 0 then
				bombData.Thrown = nil
			end
			
			bomb.CollisionDamage = player.Damage

			if player:GetEffects():HasNullEffect(NullItemID.ID_LOST_CURSE) then
				bombData.PlayerIsSoul = true
			elseif bombData.PlayerIsSoul then
				bombData.PlayerIsSoul = false
			end

			if player:GetData().RocketThrowMulti then
				bomb:AddVelocity(player:GetData().ThrowVelocity*player:GetData().RocketThrowMulti)
				player:GetData().RocketThrowMulti = nil
			end
			if bomb:CollidesWithGrid() and player:GetData().ThrowVelocity then
				local pos = bomb.Position + 40*(player:GetData().ThrowVelocity:Normalized())
				NadabBodyDamageGrid(bomb.Position)
				NadabBodyDamageGrid(pos)
			end
		end
		
		-- follow enemies
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BOBBY_BOMB) then
			local raddis = 90
			local nearestNPC = functions.GetNearestEnemy(bomb.Position, raddis)
			if nearestNPC:Distance(bomb.Position) > 10 then
				bomb:AddVelocity((nearestNPC - bomb.Position):Resized(1))
			end
		elseif player:HasCollectible(CollectibleType.COLLECTIBLE_STICKY_BOMBS) then 
			--bomb:AddTearFlags(TearFlags.TEAR_STICKY)
			local raddis = 30
			local nearestNPC = functions.GetNearestEnemy(bomb.Position, raddis)
			if nearestNPC:Distance(bomb.Position) > 10 then
				bomb.Velocity = (nearestNPC - bomb.Position):Resized(5)
				--bomb.Velocity = Vector.Zero
			end
		end
		-- leave creep
		if player:HasCollectible(enums.Items.FrostyBombs) and game:GetFrameCount() %8 == 0 then -- spawn every 8th frame
			local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL, 0, bomb.Position, Vector.Zero, player):ToEffect() -- PLAYER_CREEP_RED
			creep.SpriteScale = creep.SpriteScale * 0.1
		end

		-- bob's bladder
		if player:HasTrinket(TrinketType.TRINKET_BOBS_BLADDER) and game:GetFrameCount() %8 == 0 then -- spawn every 8th frame
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_GREEN, 0, bomb.Position, Vector.Zero, player)
		end

		-- do some rocket dash before explosion
		if bombData.RocketBody then
			bombData.RocketBody = bombData.RocketBody - 1
			if bomb:CollidesWithGrid(player) then
				FcukingBomberbody(player, bomb)
				bombData.RocketBody = false

			elseif bombData.RocketBody < 0 then
				FcukingBomberbody(player, bomb)
				bombData.RocketBody = false
			end
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, EclipsedMod.onBombNadabUpdate, BombVariant.BOMB_DECOY)
---Nadab's Body
function EclipsedMod:onBombCollision(bomb, collider)
	local bombData = bomb:GetData()
	if bombData.bomby and collider:ToNPC() then
		collider = collider:ToNPC()
		if not collider:HasEntityFlags(EntityFlag.FLAG_CHARM) then
			if bombData.Thrown then
				if (collider:IsActiveEnemy() and collider:IsVulnerableEnemy()) or collider.Type == EntityType.ENTITY_FIREPLACE then
					bomb.Velocity = -bomb.Velocity * 0.5
					FcukingBomberbody(bomb.Parent:ToPlayer(), bomb)
					bombData.Thrown = nil
				end
			end
			if bombData.RocketBody then
				if (collider:IsActiveEnemy() and collider:IsVulnerableEnemy()) or collider.Type == EntityType.ENTITY_FIREPLACE then
					--bomb.Velocity = bomb.Parent:ToPlayer():GetShootingInput() *5 --bomb.Velocity
					bomb.Velocity = -bomb.Velocity * 0.5
					FcukingBomberbody(bomb.Parent:ToPlayer(), bomb)
					bombData.RocketBody = false
				end
			end
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_PRE_BOMB_COLLISION, EclipsedMod.onBombCollision, BombVariant.BOMB_DECOY)

-------------------------------------------------------------------------------------------
--Nadab
local function NadabExplosion(player, useGiga, bombPos)
	local data = player:GetData()
	local bombFlags = player:GetBombFlags()
	local bombDamage = 100
	if player:HasCollectible(CollectibleType.COLLECTIBLE_MR_MEGA) then
		bombDamage = 185
	end
	if data.GigaBombs then
		if data.GigaBombs > 0 then
			if useGiga then
				data.GigaBombs = data.GigaBombs - 1
			end
			bombFlags = bombFlags | TearFlags.TEAR_GIGA_BOMB
			bombDamage = 300
		end
	end
	ExplosionEffect(player, bombPos, bombDamage, bombFlags)
end

local function NadabEvaluateStats(player,item, cacheFlag, dataCheck)
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

local function FcukingBomberman(player)
	--NadabExplosion(player, useGiga, useMirror) -- useGiga: removes 1 giga bomb; useMirror: flips position
	if player:HasCollectible(enums.Items.MirrorBombs) then

		NadabExplosion(player, false, functions.FlipMirrorPos(player.Position))
	end
	if player:HasTrinket(TrinketType.TRINKET_RING_CAP) then
		player:GetData().RingCapDelay = 0-- player:GetTrinketMultiplier(TrinketType.TRINKET_RING_CAP) * datatables.NadabData.RingCapFrameCount
	end
	NadabExplosion(player, true, player.Position)
end

local function BombHeartConverter(player)
	local data = player:GetData()
	local bombs = player:GetNumBombs()
	if data.BeggarPay then
		if bombs == 0 and player:GetHearts() > 0 then
			player:AddBombs(1)
			player:TakeDamage(1, DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_RED_HEARTS, EntityRef(player), 1)
			data.BeggarPay = false
			data.BlockBeggar = game:GetFrameCount()
		end
	elseif data.GlyphBalanceTrigger then
		data.GlyphBalanceTrigger = false
		if bombs > 0 then
			player:AddBombs(-bombs)
		end
	else
		if bombs > 0 then
			if player:GetNumGigaBombs() > 0 then
				data.GigaBombs = data.GigaBombs or 0
				data.GigaBombs = data.GigaBombs + player:GetNumGigaBombs()
			end
			player:AddBombs(-bombs)
			player:AddHearts(bombs)
		end
	end
end

local function BombGoldenHearts(player)
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

local function BombBeggarInteraction(player)
	--- Nadab & Abihu bomb beggar interaction
	local data = player:GetData()
	local bombegs = Isaac.FindByType(EntityType.ENTITY_SLOT, 9) -- bombBeggar
	if #bombegs > 0 then
		local enablePay = false
		for _, beggar in pairs(bombegs) do
			local bsprite = beggar:GetSprite()
			if beggar.Position:Distance(player.Position) <= 20 and datatables.NadabData.BombBeggarSprites[bsprite:GetAnimation()] then
				enablePay = true
				break
			end
		end
		if enablePay then
			data.BeggarPay = true
		else
			data.BeggarPay = false
		end
	end
end

local function AbihuNadabManager(player)
	local data = player:GetData()
	if player:GetHearts() > 0 and not data.BlockBeggar then
		BombBeggarInteraction(player)
	end
	BombGoldenHearts(player)
	BombHeartConverter(player)

end

local function ExplosionCountdownManager(player)
	local data = player:GetData()
	data.ExCountdown = data.ExCountdown or 0
	if data.ExCountdown > 0 then data.ExCountdown = data.ExCountdown - 1 end

	--short fuse OR explosion countdown
	if player:HasTrinket(TrinketType.TRINKET_SHORT_FUSE) then
		if datatables.NadabData.ExplosionCountdown > 15 then
			datatables.NadabData.ExplosionCountdown = 15
		end
	else
		if datatables.NadabData.ExplosionCountdown < 30 then
			datatables.NadabData.ExplosionCountdown = 30
		end
	end
end


-- get num aura multiplier
local function GetMultiShotNum(player)
	local Aura2020 = functions.GetItemsCount(player, CollectibleType.COLLECTIBLE_20_20)
	local AuraInnerEye = functions.GetItemsCount(player, CollectibleType.COLLECTIBLE_INNER_EYE)
	local AuraMutantSpider = functions.GetItemsCount(player,  CollectibleType.COLLECTIBLE_MUTANT_SPIDER)
	local AuraWiz = functions.GetItemsCount(player, CollectibleType.COLLECTIBLE_THE_WIZ)
	local AuraEclipse = functions.GetItemsCount(player, enums.Items.Eclipse)
	
	local tearsNum = Aura2020 + AuraWiz + AuraEclipse
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

--Unbidden Aura
local function AuraGridEffect(ppl, auraPos)
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
					griden:Hurt(1)
				end
			end
		end
	end
	return gridList
end

local function AuraEnemies(ppl, auraPos, enemies, damage)
	local data = ppl:GetData()
	local rng = myrng
	for _, enemy in pairs(enemies) do
		local knockback = ppl.ShotSpeed * datatables.UnbiddenBData.Knockback
		local tearFlags = ppl.TearFlags

		if ppl:HasCollectible(CollectibleType.COLLECTIBLE_EUTHANASIA) then
			rng = ppl:GetCollectibleRNG(CollectibleType.COLLECTIBLE_EUTHANASIA)
			local chance = 0.0333 + ppl.Luck/69.2
			if chance > 0.25 then chance = 0.25 end
			if chance > rng:RandomFloat() then
				local needle = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.NEEDLE, 0, enemy.Position, Vector.Zero, ppl):ToTear() --25
				needle:SetColor(Color(0,0,0,0), 100, 100, false, true)
				needle.Visible = false
				needle.FallingSpeed = 5
				needle.CollisionDamage = ppl.Damage * 3
				if not enemy:IsBoss() and enemy:ToNPC() then
					enemy:Kill()
				end
			end
		end

		if ppl:HasCollectible(CollectibleType.COLLECTIBLE_TERRA) then
			rng = ppl:GetCollectibleRNG(CollectibleType.COLLECTIBLE_TERRA)
			local terradmg = 2 * rng:RandomFloat()
			if terradmg < 0.5 then terradmg = 0.5 end
			if terradmg > 2 then terradmg = 2 end
			damage = damage * terradmg
			if terradmg < 1 then terradmg = 1 end
			knockback = knockback * terradmg
		end

		if ppl:HasCollectible(CollectibleType.COLLECTIBLE_LUMP_OF_COAL) then
			damage =  damage + enemy.Position:Distance(auraPos)/100
		end

		if ppl:HasCollectible(CollectibleType.COLLECTIBLE_PROPTOSIS) then
			damage =  damage - enemy.Position:Distance(auraPos)/100
		end

		if enemy:IsVulnerableEnemy() and enemy:IsActiveEnemy() then
			if ppl:HasCollectible(CollectibleType.COLLECTIBLE_HEAD_OF_THE_KEEPER) then
				rng = ppl:GetCollectibleRNG(CollectibleType.COLLECTIBLE_HEAD_OF_THE_KEEPER)
				if 0.05 > rng:RandomFloat() then
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, enemy.Position, RandomVector()*3, ppl)
					--local coin = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, enemy.Position, RandomVector()*3, ppl):ToPickup() --25
				end
			end

			if ppl:HasCollectible(CollectibleType.COLLECTIBLE_LITTLE_HORN) then
				rng = ppl:GetCollectibleRNG(CollectibleType.COLLECTIBLE_LITTLE_HORN)
				local chance = 0.05 + ppl.Luck/100
				if chance > 0.2 then chance = 0.2 end
				if chance > rng:RandomFloat() then
					local horn = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.BLUE, 0, enemy.Position, Vector.Zero, ppl):ToTear() --25
					horn:AddTearFlags(TearFlags.TEAR_HORN)
					horn.CollisionDamage = 0
					horn.Visible = false
					horn:SetColor(Color(0,0,0,0), 100, 100, false, true)
					horn.FallingSpeed =  5
				end
			end

			if ppl:HasCollectible(CollectibleType.COLLECTIBLE_JACOBS_LADDER) then
				local electro = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.BLUE, 0, enemy.Position, Vector.Zero, ppl):ToTear() --25
				electro:AddTearFlags(TearFlags.TEAR_JACOBS)
				electro:SetColor(Color(0,0,0,0), 100, 100, false, true)
				electro.Visible = false
				electro.CollisionDamage = 0
				electro.FallingSpeed =  5
			end

			if ppl:HasCollectible(CollectibleType.COLLECTIBLE_LODESTONE) then
				rng = ppl:GetCollectibleRNG(CollectibleType.COLLECTIBLE_LODESTONE)
				local chance = 0.1667 + ppl.Luck/6
				if chance > rng:RandomFloat() then
					local magnet = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.METALLIC, 0, enemy.Position, Vector.Zero, ppl):ToTear() --25
					magnet:AddTearFlags(TearFlags.TEAR_MAGNETIZE)
					magnet:SetColor(Color(0,0,0,0), 100, 100, false, true)
					magnet.Visible = false
					magnet.CollisionDamage = 0
					magnet.FallingSpeed = 5
				end
			end

			if ppl:HasCollectible(CollectibleType.COLLECTIBLE_OCULAR_RIFT) then
				rng = ppl:GetCollectibleRNG(CollectibleType.COLLECTIBLE_OCULAR_RIFT)
				local chance = 0.05 + ppl.Luck/50
				if chance > 0.25 then chance = 0.25 end
				if chance > rng:RandomFloat() then
					local rift = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.BLUE, 0, enemy.Position, Vector.Zero, ppl):ToTear() --25
					rift:AddTearFlags(TearFlags.TEAR_RIFT)
					rift:SetColor(Color(0,0,0,0), 100, 100, false, false)
					rift.Visible = false
					rift.CollisionDamage = ppl.Damage
					rift.FallingSpeed = 5
					damage = 0
					break
				end
			end

			if ppl:HasCollectible(enums.Items.MeltedCandle) and not enemy:GetData().Waxed then
				rng = ppl:GetCollectibleRNG(enums.Items.MeltedCandle)
				if rng:RandomFloat() + ppl.Luck/100 >= datatables.MeltedCandle.TearChance then --  0.8
					enemy:AddFreeze(EntityRef(ppl), datatables.MeltedCandle.FrameCount)
					if enemy:HasEntityFlags(EntityFlag.FLAG_FREEZE) then
						--entity:AddBurn(EntityRef(ppl), 1, 2*ppl.Damage) -- the issue is Freeze stops framecount of entity, so it won't call NPC_UPDATE.
						enemy:AddEntityFlags(EntityFlag.FLAG_BURN)          -- the burn timer doesn't update
						enemy:GetData().Waxed = datatables.MeltedCandle.FrameCount
						enemy:SetColor(datatables.MeltedCandle.TearColor, datatables.MeltedCandle.FrameCount, 100, false, false)
					end
				end
			end

			if tearFlags & TearFlags.TEAR_BURN == TearFlags.TEAR_BURN then
				enemy:AddBurn(EntityRef(ppl), 52, 2*ppl.Damage)
			end
			if ppl:HasCollectible(CollectibleType.COLLECTIBLE_FIRE_MIND) and 0.33 + ppl.Luck/20 > ppl:GetCollectibleRNG(CollectibleType.COLLECTIBLE_FIRE_MIND):RandomFloat() then
				game:BombExplosionEffects(enemy.Position, ppl.Damage, TearFlags.TEAR_BURN, Color.Default, ppl, 1, true, false, DamageFlag.DAMAGE_EXPLOSION)
			end

			if tearFlags & TearFlags.TEAR_CHARM == TearFlags.TEAR_CHARM then -- or ppl:HasCollectible(CollectibleType.COLLECTIBLE_SPIDER_BITE) then
				enemy:AddCharmed(EntityRef(ppl), 52)
			elseif ppl:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_EYESHADOW) and 0.1 + ppl.Luck / 30 > ppl:GetCollectibleRNG(CollectibleType.COLLECTIBLE_MOMS_EYESHADOW):RandomFloat() then
				enemy:AddCharmed(EntityRef(ppl), 52)
			end

			if ppl:HasCollectible(CollectibleType.COLLECTIBLE_GLAUCOMA) and 0.05 > ppl:GetCollectibleRNG(CollectibleType.COLLECTIBLE_GLAUCOMA):RandomFloat() then
				enemy:AddEntityFlags(EntityFlag.FLAG_CONFUSION)
			elseif tearFlags & TearFlags.TEAR_CONFUSION == TearFlags.TEAR_CONFUSION then -- or ppl:HasCollectible(CollectibleType.COLLECTIBLE_SPIDER_BITE) then
				enemy:AddConfusion(EntityRef(ppl), 52, false)
			elseif ppl:HasCollectible(CollectibleType.COLLECTIBLE_KNOCKOUT_DROPS) and 0.1 + ppl.Luck/10 > ppl:GetCollectibleRNG(CollectibleType.COLLECTIBLE_KNOCKOUT_DROPS):RandomFloat() then
				enemy:AddConfusion(EntityRef(ppl), 42, false)
				enemy:AddVelocity((enemy.Position - auraPos):Resized(knockback))
				enemy:AddEntityFlags(EntityFlag.FLAG_KNOCKED_BACK)
				enemy:AddEntityFlags(EntityFlag.FLAG_APPLY_IMPACT_DAMAGE)
			elseif ppl:HasCollectible(CollectibleType.COLLECTIBLE_IRON_BAR) and 0.1 + ppl.Luck / 30 > ppl:GetCollectibleRNG(CollectibleType.COLLECTIBLE_IRON_BAR):RandomFloat() then
				enemy:AddConfusion(EntityRef(ppl), 52, false)
			end

			if tearFlags & TearFlags.TEAR_FEAR == TearFlags.TEAR_FEAR then -- or ppl:HasCollectible(CollectibleType.COLLECTIBLE_SPIDER_BITE) then
				enemy:AddFear(EntityRef(ppl), 52)
			elseif ppl:HasCollectible(CollectibleType.COLLECTIBLE_DARK_MATTER) and 0.1 + ppl.Luck / 25 > ppl:GetCollectibleRNG(CollectibleType.COLLECTIBLE_GLAUCOMA):RandomFloat() then
				enemy:AddFear(EntityRef(ppl), 52)
			elseif ppl:HasCollectible(CollectibleType.COLLECTIBLE_ABADDON) and 0.15 + ppl.Luck/100 > ppl:GetCollectibleRNG(CollectibleType.COLLECTIBLE_ABADDON):RandomFloat() then
				enemy:AddFear(EntityRef(ppl), 52)
			elseif ppl:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_PERFUME) and 0.15 + ppl.Luck/100 > ppl:GetCollectibleRNG(CollectibleType.COLLECTIBLE_MOMS_PERFUME):RandomFloat() then
				enemy:AddFear(EntityRef(ppl), 52)
			end

			if tearFlags & TearFlags.TEAR_FREEZE == TearFlags.TEAR_FREEZE then
				enemy:AddFreeze(EntityRef(ppl), 52)
			elseif ppl:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_CONTACTS) then
				local chance = 0.2 + ppl.Luck/66
				if chance > 0.5 then chance = 0.5 end
				if 0.2 + ppl.Luck/66  > ppl:GetCollectibleRNG(CollectibleType.COLLECTIBLE_MOMS_CONTACTS):RandomFloat() then
					enemy:AddFreeze(EntityRef(ppl), 52)
				end
			end

			if tearFlags & TearFlags.TEAR_MIDAS == TearFlags.TEAR_MIDAS then
				enemy:AddMidasFreeze(EntityRef(ppl), 52)
			elseif ppl:HasCollectible(CollectibleType.COLLECTIBLE_EYE_OF_GREED) and data.EyeGreedCounter and data.EyeGreedCounter == 20 then
				ppl:AddCoins(-1)
				enemy:AddMidasFreeze(EntityRef(ppl), 102)
				if ppl:GetNumCoins() > 0 then
					damage = 1.5*damage + 10
				end
			end

			if tearFlags & TearFlags.TEAR_POISON == TearFlags.TEAR_POISON then -- > 0
				enemy:AddPoison(EntityRef(ppl), 52, 2*ppl.Damage) -- Scorpio
			elseif ppl:HasCollectible(CollectibleType.COLLECTIBLE_SCORPIO) then
				enemy:AddPoison(EntityRef(ppl), 52, 2*ppl.Damage)
			elseif ppl:HasCollectible(CollectibleType.COLLECTIBLE_COMMON_COLD) and 0.25 + ppl.Luck/16 > ppl:GetCollectibleRNG(CollectibleType.COLLECTIBLE_COMMON_COLD):RandomFloat() then
				enemy:AddPoison(EntityRef(ppl), 52, 2*ppl.Damage)
			elseif ppl:HasCollectible(CollectibleType.COLLECTIBLE_SERPENTS_KISS) and 0.15 + ppl.Luck/15 > ppl:GetCollectibleRNG(CollectibleType.COLLECTIBLE_SERPENTS_KISS):RandomFloat() then
				enemy:AddPoison(EntityRef(ppl), 52, 2*ppl.Damage)
			elseif ppl:HasTrinket(TrinketType.TRINKET_PINKY_EYE) and 0.1 + ppl.Luck/20 > ppl:GetTrinketRNG(TrinketType.TRINKET_PINKY_EYE):RandomFloat() then
				enemy:AddPoison(EntityRef(ppl), 52, 2*ppl.Damage)
			end

			if ppl:HasCollectible(CollectibleType.COLLECTIBLE_IPECAC) or (ppl:HasTrinket(TrinketType.TRINKET_TORN_CARD) and data.TornCardCounter and data.TornCardCounter == 15) then
				game:BombExplosionEffects(enemy.Position, 40, TearFlags.TEAR_POISON, Color.Default, ppl, 1, true, false, DamageFlag.DAMAGE_EXPLOSION)
			end

			--if tearFlags & TearFlags.TEAR_SHRINK == TearFlags.TEAR_SHRINK then
			--	enemy:AddShrink(EntityRef(ppl), 102)
			--elseif
			if ppl:HasCollectible(CollectibleType.COLLECTIBLE_GODS_FLESH) and  0.1 > ppl:GetCollectibleRNG(CollectibleType.COLLECTIBLE_GODS_FLESH):RandomFloat() then
				enemy:AddShrink(EntityRef(ppl), 102)
			end

			if tearFlags & TearFlags.TEAR_SLOW == TearFlags.TEAR_SLOW then -- or ppl:HasCollectible(CollectibleType.COLLECTIBLE_SPIDER_BITE) then
				enemy:AddSlowing(EntityRef(ppl), 52, 0.5, Color(2,2,2,1,0.196,0.196,0.196))
			elseif ppl:HasCollectible(CollectibleType.COLLECTIBLE_SPIDER_BITE) and  0.25 + ppl.Luck/20 > ppl:GetCollectibleRNG(CollectibleType.COLLECTIBLE_SPIDER_BITE):RandomFloat() then
				enemy:AddSlowing(EntityRef(ppl), 52, 0.5, Color(2,2,2,1,0.196,0.196,0.196))
			elseif ppl:HasCollectible(CollectibleType.COLLECTIBLE_BALL_OF_TAR) and 0.25 + ppl.Luck/24 > ppl:GetCollectibleRNG(CollectibleType.COLLECTIBLE_BALL_OF_TAR):RandomFloat() then
				enemy:AddSlowing(EntityRef(ppl), 52, 0.5, Color(0.15, 0.15, 0.15, 1, 0, 0, 0))
			elseif ppl:HasTrinket(TrinketType.TRINKET_CHEWED_PEN) and 0.1 + ppl.Luck/20 > ppl:GetTrinketRNG(TrinketType.TRINKET_CHEWED_PEN):RandomFloat() then
				enemy:AddSlowing(EntityRef(ppl), 52, 0.5, Color(0.15, 0.15, 0.15, 1, 0, 0, 0))
			end

			if data.UsedBG then
				enemy:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
				enemy:GetData().BackStabbed = 52
			elseif ppl:HasCollectible(CollectibleType.COLLECTIBLE_BACKSTABBER) and 0.25 > ppl:GetCollectibleRNG(CollectibleType.COLLECTIBLE_BACKSTABBER):RandomFloat() then
				enemy:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
				enemy:GetData().BackStabbed = 52
			end

			if ppl:HasCollectible(CollectibleType.COLLECTIBLE_URANUS) and not enemy:HasEntityFlags(EntityFlag.FLAG_ICE) then-- and enemy:HasMortalDamage() then
				enemy:AddEntityFlags(EntityFlag.FLAG_ICE)
			end

			if ppl:HasCollectible(CollectibleType.COLLECTIBLE_ROTTEN_TOMATO) and 16.67 + ppl.Luck/0.06  > ppl:GetCollectibleRNG(CollectibleType.COLLECTIBLE_ROTTEN_TOMATO):RandomFloat() then
				enemy:AddEntityFlags(EntityFlag.FLAG_BAITED)
				enemy:GetData().BaitedTomato = 102
			end

			if ppl:HasCollectible(CollectibleType.COLLECTIBLE_PLAYDOUGH_COOKIE) then
				rng = ppl:GetCollectibleRNG(CollectibleType.COLLECTIBLE_PLAYDOUGH_COOKIE)
				local index = rng:RandomInt(10) -- 0 is None
				if index == 1 then
					enemy:AddPoison(EntityRef(ppl), 52, 2*ppl.Damage)
				elseif index == 2 then
					enemy:AddFear(EntityRef(ppl), 52)
				elseif index == 3 then
					enemy:AddShrink(EntityRef(ppl), 52)
				elseif index == 4 then
					enemy:AddSlowing(EntityRef(ppl), 52, 0.5, Color(2,2,2,1,0.196,0.196,0.196))
					if not enemy:HasEntityFlags(EntityFlag.FLAG_ICE) then enemy:AddEntityFlags(EntityFlag.FLAG_ICE) end
				elseif index == 5 then
					enemy:AddCharmed(EntityRef(ppl), 52)
				elseif index == 6 then
					enemy:AddBurn(EntityRef(ppl), 52, 2*ppl.Damage)
					if 0.33 + ppl.Luck/20 > rng:RandomFloat() then
						game:BombExplosionEffects(enemy.Position, ppl.Damage, TearFlags.TEAR_BURN, Color.Default, ppl, 1, true, false, DamageFlag.DAMAGE_EXPLOSION)
					end
				elseif index == 7 then
					enemy:AddFreeze(EntityRef(ppl), 52)
				elseif index == 8 then
					enemy:AddEntityFlags(EntityFlag.FLAG_BAITED)
					enemy:GetData().BaitedTomato = 102
				elseif index == 9 then
					enemy:AddConfusion(EntityRef(ppl), 52, false)
				end
			end

			if ppl:HasCollectible(CollectibleType.COLLECTIBLE_MYSTERIOUS_LIQUID) then
				local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_GREEN, 0, enemy.Position, Vector.Zero, ppl):ToEffect() --25
				creep.CollisionDamage = 1
			end

			if ppl:HasCollectible(CollectibleType.COLLECTIBLE_MULLIGAN) then
				rng = ppl:GetCollectibleRNG(CollectibleType.COLLECTIBLE_MULLIGAN)
				if 1/6 > rng:RandomFloat() then
					ppl:AddBlueFlies(1, ppl.Position, enemy)
				end
			end

			if ppl:HasCollectible(CollectibleType.COLLECTIBLE_EXPLOSIVO) then
				rng = ppl:GetCollectibleRNG(CollectibleType.COLLECTIBLE_EXPLOSIVO)
				if 0.25 > rng:RandomFloat() then
					local expo = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.EXPLOSIVO, 0, enemy.Position, Vector.Zero, ppl):ToTear() --25
					expo:AddTearFlags(TearFlags.TEAR_STICKY)
					expo.CollisionDamage = damage
					expo.FallingSpeed = 5
				end
			end

			if ppl:HasCollectible(CollectibleType.COLLECTIBLE_MUCORMYCOSIS) then
				rng = ppl:GetCollectibleRNG(CollectibleType.COLLECTIBLE_MUCORMYCOSIS)
				if 0.25 > rng:RandomFloat() then
					local myco = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.SPORE, 0, enemy.Position, Vector.Zero, ppl):ToTear() --25
					myco:AddTearFlags(TearFlags.TEAR_SPORE)
					myco.CollisionDamage = damage
					myco.FallingSpeed = 5
				end
			end

			if ppl:HasCollectible(CollectibleType.COLLECTIBLE_SINUS_INFECTION) then
				if 0.2 > ppl:GetCollectibleRNG(CollectibleType.COLLECTIBLE_SINUS_INFECTION):RandomFloat() then
					local booger = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.BOOGER, 0, enemy.Position, Vector.Zero, ppl):ToTear() --25
					if ppl:HasTrinket(TrinketType.TRINKET_NOSE_GOBLIN) and 0.5 > ppl:GetCollectibleRNG(CollectibleType.COLLECTIBLE_SINUS_INFECTION):RandomFloat() then
						booger:AddTearFlags(TearFlags.TEAR_HOMING)
					end
					booger:AddTearFlags(TearFlags.TEAR_BOOGER)
					booger.CollisionDamage = damage
					booger.FallingSpeed = 5
				end
			elseif ppl:HasTrinket(TrinketType.TRINKET_NOSE_GOBLIN) then
				if 0.1 > ppl:GetTrinketRNG(TrinketType.TRINKET_NOSE_GOBLIN):RandomFloat() then
					local booger = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.BOOGER, 0, enemy.Position, Vector.Zero, ppl):ToTear() --25
					booger:AddTearFlags(TearFlags.TEAR_BOOGER | TearFlags.TEAR_HOMING)
					booger.CollisionDamage = damage
					booger.FallingSpeed = 5
				end
			end

			if ppl:HasCollectible(CollectibleType.COLLECTIBLE_PARASITOID) then
				rng = ppl:GetCollectibleRNG(CollectibleType.COLLECTIBLE_PARASITOID)
				local chance = 0.15 + ppl.Luck/14
				if chance > 0.5 then chance = 0.5 end
				if chance > rng:RandomFloat() then
					local egg = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.EGG, 0,  enemy.Position, Vector.Zero, ppl):ToTear() --25
					egg:AddTearFlags(TearFlags.TEAR_EGG)
					egg.CollisionDamage = damage
					egg.FallingSpeed = 5
				end
			end

			enemy:TakeDamage(damage, 0, EntityRef(ppl), 1)
			
			if data.MultipleAura then
				
				for _ = 0, data.MultipleAura do
					enemy:TakeDamage(damage, 0, EntityRef(ppl), 1)
				end
				data.MultipleAura = nil
			end
			
			enemy:AddVelocity((enemy.Position - auraPos):Resized(knockback))
		else
			if enemy:ToBomb() then -- trollbomb
				if ppl:HasCollectible(CollectibleType.COLLECTIBLE_KNOCKOUT_DROPS) and 0.1 + ppl.Luck/10 > ppl:GetCollectibleRNG(CollectibleType.COLLECTIBLE_KNOCKOUT_DROPS):RandomFloat() then
					knockback = 2*knockback
				end
				enemy:AddVelocity((enemy.Position - auraPos):Resized(knockback))
			elseif enemy.Type == 292 or enemy.Type == 33 then -- TNT or Fireplace
				enemy:TakeDamage(damage, 0, EntityRef(ppl), 1)
			end
		end -- vulnerable and active
	end -- for
end

local function AuraInit(ppl, effect, scale, damage)
	local range = ppl.TearRange*scale
	if range > 520 then range = 520 end
	if range < 60 then range = 60 end
	effect.SpriteScale = effect.SpriteScale * range/100 --effect.SpriteScale * ((ppl.TearRange - scale*ppl.TearRange)/200)
	effect.Color = datatables.UnbiddenBData.Stats.LASER_COLOR
	local auraPos = effect.Position

	if ppl:HasCollectible(CollectibleType.COLLECTIBLE_LOST_CONTACT) then
		local bullets = Isaac.FindInRadius(auraPos, range, EntityPartition.BULLET)
		if #bullets > 0 then
			for _, bullet in pairs(bullets) do
				if bullet:ToProjectile() then
					bullet:Kill()
				end
			end
		end
	end

	local enemies = Isaac.FindInRadius(auraPos, range, EntityPartition.ENEMY)
	--if #enemies == 0 then
	if #enemies > 0 then
		AuraEnemies(ppl, auraPos, enemies, damage)
	end
end

local function AuraCriketPatterSpawn(player, pos, radius, velocity, entityType, entityVariant, entitySubtype)
	local point = radius*math.cos(math.rad(45))
	local scale = 0.25
	local ul = Isaac.Spawn(entityType, entityVariant, entitySubtype, Vector(pos.X+point, pos.Y+point), Vector(velocity, velocity), player):ToEffect() -- up left
	local dl = Isaac.Spawn(entityType, entityVariant, entitySubtype, Vector(pos.X+point, pos.Y-point), Vector(velocity, -velocity), player):ToEffect() -- down left
	local ur = Isaac.Spawn(entityType, entityVariant, entitySubtype, Vector(pos.X-point, pos.Y+point), Vector(-velocity, velocity), player):ToEffect() -- up right
	local dr = Isaac.Spawn(entityType, entityVariant, entitySubtype, Vector(pos.X-point, pos.Y-point), Vector(-velocity, -velocity), player):ToEffect() -- down right
	AuraInit(player, ul, scale, player.Damage/2)
	AuraInit(player, dl, scale, player.Damage/2)
	AuraInit(player, ur, scale, player.Damage/2)
	AuraInit(player, dr, scale, player.Damage/2)
end

local function AuraLokiHornsPatterSpawn(player, pos, radius, velocity, entityType, entityVariant, entitySubtype)
	local scale = 0.25
	local ul = Isaac.Spawn(entityType, entityVariant, entitySubtype, Vector(pos.X, pos.Y+radius), Vector(0, velocity), player):ToEffect()--up
	local dl = Isaac.Spawn(entityType, entityVariant, entitySubtype, Vector(pos.X, pos.Y-radius), Vector(0, -velocity), player):ToEffect() --down
	local ur = Isaac.Spawn(entityType, entityVariant, entitySubtype, Vector(pos.X+radius, pos.Y), Vector(velocity, 0), player):ToEffect()--right
	local dr = Isaac.Spawn(entityType, entityVariant, entitySubtype, Vector(pos.X-radius, pos.Y), Vector(-velocity, 0), player):ToEffect() --left
	AuraInit(player, ul, scale, player.Damage/2)
	AuraInit(player, dl, scale, player.Damage/2)
	AuraInit(player, ur, scale, player.Damage/2)
	AuraInit(player, dr, scale, player.Damage/2)
end



local function UnbiddenAura(player, auraPos, delayOff, damageMulti, range, blockLasers)
	local room = game:GetRoom()
	local data = player:GetData()
	local rng = myrng
	range = range or player.TearRange*0.5
	--print(range, player.TearRange)
	if range > 520 then range = 520 end
	if range < 60 then range = 60 end
	damageMulti = damageMulti or 1
	--damage = damage or player.Damage
	
	if data.UnbiddenBrimCircle and not blockLasers then
		--local data = player:GetData()
		local laser = player:FireTechXLaser(auraPos, Vector.Zero, range, player, damageMulti):ToLaser()
		laser.Color = datatables.UnbiddenBData.Stats.LASER_COLOR
		laser:SetTimeout(data.UnbiddenBrimCircle)
		--if math.floor(player.MaxFireDelay) + datatables.UnbiddenBData.DamageDelay -
		local newRange = (data.UnbiddenBDamageDelay)/(math.floor(player.MaxFireDelay) + datatables.UnbiddenBData.DamageDelay)
		if newRange < 0.25 then newRange = 0.25 end

		--laser.CollisionDamage = player.Damage * damageMulti
		laser:GetData().CollisionDamage = player.Damage * damageMulti

		laser.Radius = range*newRange
		laser:GetData().UnbiddenBrimLaser = data.UnbiddenBrimCircle-1
		
		if not delayOff then
			data.UnbiddenBDamageDelay = 0 --
		end
		
		return
	end

	if not delayOff then
		data.UnbiddenBDamageDelay = 0 --
	end

	local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HALO, 8, auraPos, Vector.Zero, player):ToEffect()
	effect.Color =  datatables.UnbiddenBData.Stats.LASER_COLOR
	effect.SpriteScale = effect.SpriteScale * range/100
	
	if datatables.UnbiddenBData.DamageDelay + math.floor(player.MaxFireDelay) > 8 then
		--sfx:Play(321, 1, 2, false, 10)
		sfx:Play(SoundEffect.SOUND_HEARTBEAT,0.5,2,false,3)
	end

	if player:HasCollectible(CollectibleType.COLLECTIBLE_LOST_CONTACT) then
		local bullets = Isaac.FindInRadius(auraPos, range, EntityPartition.BULLET)
		if #bullets > 0 then
			for _, bullet in pairs(bullets) do
				if bullet:ToProjectile() then
					bullet:Kill()
				end
			end
		end
	end

	if player:HasCollectible(CollectibleType.COLLECTIBLE_LARGE_ZIT) and 0.25 > player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_LARGE_ZIT):RandomFloat() then
		player:DoZitEffect(player:GetLastDirection())
	end

	if player:HasCollectible(CollectibleType.COLLECTIBLE_EYE_OF_GREED) then
		--if not data.EyeGreedCounter then data.EyeGreedCounter = 0 end
		data.EyeGreedCounter = data.EyeGreedCounter or 0
		if data.EyeGreedCounter >= 20 then
			data.EyeGreedCounter = 0
		end
		data.EyeGreedCounter = data.EyeGreedCounter + 1
	end

	local gridList = AuraGridEffect(player, auraPos)

	if player:HasTrinket(TrinketType.TRINKET_TORN_CARD) then
		--if not data.TornCardCounter then data.TornCardCounter = 0 end
		data.TornCardCounter = data.TornCardCounter or 0
		if data.TornCardCounter >= 15 then data.TornCardCounter = 0 end
		data.TornCardCounter = data.TornCardCounter + 1
	end

	if player:HasCollectible(CollectibleType.COLLECTIBLE_HOLY_LIGHT) then
		rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_HOLY_LIGHT)
		local chance = 0.1 + player.Luck/22.5
		if chance > 0.5 then chance = 0.5 end
		if chance > rng:RandomFloat() then
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACK_THE_SKY, 0, gridList[rng:RandomInt(#gridList)+1], Vector.Zero, player):ToEffect()
		end
	end

	if player:HasCollectible(CollectibleType.COLLECTIBLE_CRICKETS_BODY) then
		AuraCriketPatterSpawn(player, auraPos, range, 0, EntityType.ENTITY_EFFECT, EffectVariant.HALO, 8)
	end

	if player:HasCollectible(CollectibleType.COLLECTIBLE_LOKIS_HORNS) then
		rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_LOKIS_HORNS)
		local chance = 0.25 + player.Luck/20
		if chance > rng:RandomFloat() then
			AuraLokiHornsPatterSpawn(player, auraPos, range, 0, EntityType.ENTITY_EFFECT, EffectVariant.HALO, 8)
		end
	end

	if player:HasCollectible(CollectibleType.COLLECTIBLE_EYE_SORE) then
		rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_EYE_SORE)
		local numSore = rng:RandomInt(4)
		for _ = 1, numSore do
			local eaura = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HALO, 8, room:GetRandomPosition(1), Vector.Zero, player):ToEffect()
			--eaura.Color = datatables.UnbiddenBData.Stats.LASER_COLOR
			AuraInit(player, eaura, 0.5, player.Damage)
		end
	end

	if player:HasCollectible(CollectibleType.COLLECTIBLE_HAEMOLACRIA) then
		rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_HAEMOLACRIA)
		local numAura = rng:RandomInt(6)+6
		for _ = 1, numAura do
			local haemscale = rng:RandomFloat()
			if haemscale < 0.5 then
				haemscale = 0.5
			elseif haemscale > 0.8333 then
				haemscale = 0.8333
			end
			local haura = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HALO, 8, room:GetRandomPosition(1), Vector.Zero, player):ToEffect()
			--haura.Color = datatables.UnbiddenBData.Stats.LASER_COLOR
			AuraInit(player, haura, haemscale, player.Damage * haemscale)
		end
	end

	if player:HasCollectible(CollectibleType.COLLECTIBLE_ANTI_GRAVITY) then
		local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.MULTIDIMENSIONAL, 0, gridList[rng:RandomInt(#gridList)+1], Vector.Zero, player):ToTear()
		tear:AddTearFlags(player.TearFlags)
		tear.CollisionDamage = player.Damage
		tear.FallingSpeed = 5

		if player:HasCollectible(CollectibleType.COLLECTIBLE_COMPOUND_FRACTURE) then
			--tear:AddTearFlags(TearFlags.TEAR_BONE)
			--tear.Variant = TearVariant.BONE
			--tear:ChangeVariant(TearVariant.BONE)
			tear.Velocity =  player:GetLastDirection() * player.ShotSpeed * 10
			tear.FallingSpeed = 0
		end

		if player:HasTrinket(TrinketType.TRINKET_BLACK_TOOTH) then
			rng = player:GetTrinketRNG(TrinketType.TRINKET_BLACK_TOOTH)
			if 0.1 + player.Luck/36 > rng:RandomFloat() then
				tear:AddTearFlags(TearFlags.TEAR_POISON)
				tear:ChangeVariant(TearVariant.BLACK_TOOTH)
				tear.CollisionDamage = player.Damage * 2
			end
		end

		if player:HasCollectible(CollectibleType.COLLECTIBLE_TOUGH_LOVE) then
			rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_TOUGH_LOVE)
			local chance = 0.1 + player.Luck/10
			if chance > rng:RandomFloat() then
				tear:ChangeVariant(TearVariant.TOOTH)
				tear.CollisionDamage = player.Damage * 4
			end
		end

		if player:HasCollectible(CollectibleType.COLLECTIBLE_APPLE) then
			rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_APPLE)
			local chance = 0.0666 + player.Luck/15
			if chance > rng:RandomFloat() then
				tear.Variant = TearVariant.RAZOR
				tear.Velocity =  player:GetLastDirection() * player.ShotSpeed * 10
				tear.CollisionDamage = player.Damage * 4
			end
		end
	end
	local enemies = Isaac.FindInRadius(auraPos, range, EntityPartition.ENEMY)
	if #enemies == 0 then
		if player:HasCollectible(CollectibleType.COLLECTIBLE_DEAD_EYE) then
			if data.DeadEyeMissCounter < 3 then
				data.DeadEyeMissCounter = data.DeadEyeMissCounter + 1
			end
		end
	elseif #enemies > 0 then
		local damage = player.Damage * damageMulti
		if player:HasCollectible(CollectibleType.COLLECTIBLE_DEAD_EYE) then
			if data.DeadEyeCounter < 4 then
				data.DeadEyeMissCounter = 0
				data.DeadEyeCounter = data.DeadEyeCounter + 1
			end
			local DeadEyeMissChance = 0
			if data.DeadEyeMissCounter > 0 then
				DeadEyeMissChance = 0.5 -- if > 3
				if data.DeadEyeMissCounter == 1 then
					DeadEyeMissChance = 0.2
				elseif data.DeadEyeMissCounter == 2 then
					DeadEyeMissChance = 0.33
				end
			end
			if DeadEyeMissChance > player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_DEAD_EYE):RandomFloat() then
				data.DeadEyeCounter = 0
			end
			damage = player.Damage + player.Damage*(data.DeadEyeCounter/4)
		end
		for _, enemy in pairs(enemies) do
			if player:HasCollectible(CollectibleType.COLLECTIBLE_PARASITE) then
				if damage/2 > 1 then
					local paura = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HALO, 8, enemy.Position, Vector.Zero, nil):ToEffect()
					--paura.Color = datatables.UnbiddenBData.Stats.LASER_COLOR
					AuraInit(player, paura, 0.25, damage*0.5) -- damage
				end
			end
		end
		
		AuraEnemies(player, auraPos, enemies, damage)		
	end
end

local function GodHeadAura(player)
	local pos = player.Position
	local glowa = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HALO, 2, pos, Vector.Zero, player):ToEffect()
	local range = player.TearRange*0.33--0.16
	if range > 300 then range = 300 end
	if range < 60 then range = 60 end
	glowa.SpriteScale = glowa.SpriteScale * range/100 --glowa.SpriteScale * (player.TearRange - player.TearRange/1.5)/200
	glowa.Color = datatables.OblivionCard.PoofColor --Color(0,0,0,1)
	local enemies = Isaac.FindInRadius(pos, range, EntityPartition.ENEMY)
	if #enemies > 0 then
		for _, enemy in pairs(enemies) do
			if enemy:IsVulnerableEnemy() and enemy:IsActiveEnemy() then -- and game:GetFrameCount()%10 == 0 then
				enemy:TakeDamage(2, 0, EntityRef(player), 1)
				--enemy:AddVelocity((enemy.Position - pos):Resized(16))
			end
		end
	end
end

local function TechDot5Shot(player)
	local range = player.TearRange/2
	if range > 300 then range = 300 end
	if range < 60 then range = 60 end
	local laser = player:FireTechXLaser(player.Position, Vector.Zero, range, player, 1):ToLaser()
	--local laser = player:FireTechLaser(player.Position, LaserOffset.LASER_TECH5_OFFSET, player:GetShootingInput(), false, false, player, 1)
	laser:ClearTearFlags(laser.TearFlags)
	laser:GetData().UnbiddenTechDot5Laser = true
	laser.Timeout = player:GetData().UnbiddenBDamageDelay
	--laser:SetColor(datatables.UnbiddenBData.Stats.LASER_COLOR, 5000, 100, true, false)
end

local function WeaponAura(player, auraPos, frameCount, maxCharge, range, blockLasers, delayOff)
	delayOff = delayOff or nil
	range = range or player.TearRange*0.33
	if range > 300 then range = 300 end
	if range < 60 then range = 60 end
	frameCount = frameCount or game:GetFrameCount()
	maxCharge = maxCharge or datatables.UnbiddenBData.DamageDelay + math.floor(player.MaxFireDelay)
	if maxCharge == 0 then maxCharge = datatables.UnbiddenBData.DamageDelay end
	if frameCount%maxCharge == 0 then
		local tearsNum = GetMultiShotNum(player)
		for _ = 0, tearsNum do -- start from 0. cause you must have at least 1 multiplier
			--UnbiddenAura(player, auraPos) -- idk why knife is attacks 2 times (updates 2 times?)
			UnbiddenAura(player, auraPos, delayOff, nil, range, blockLasers)
		end
	end
end

local function Technology2Aura(player)
	local range = player.TearRange*0.33
	if range > 300 then range = 300 end
	if range < 60 then range = 60 end
	local laser = player:FireTechXLaser(player.Position, Vector.Zero, range, player, 0.13):ToLaser()
	laser:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
	laser:GetData().UnbiddenTech2Laser = game:GetLevel():GetCurrentRoomIndex()
	laser:GetData().EnavleVisible = 0
	player:GetData().HasTech2Laser = true
end

function EclipsedMod:onLaserUpdate(laser) -- low
	local laserData = laser:GetData()
	if laser.SpawnerEntity and laser.SpawnerEntity:ToPlayer() and laser.SpawnerEntity:ToPlayer():GetPlayerType() == enums.Characters.UnbiddenB then
		local player = laser.SpawnerEntity:ToPlayer()
		local data = player:GetData()
		if laser.SubType ~=  LaserSubType.LASER_SUBTYPE_RING_FOLLOW_PARENT then
			laser.Color = datatables.UnbiddenBData.Stats.LASER_COLOR
		end
		
		if laserData.UnbiddenLaser then
			
			laser:SetTimeout(5)
			local range = player.TearRange*0.25
			if range > 300 then range = 300 end
			if range < 60 then range = 60 end
			laser.Radius = range
			laser.Velocity = player:GetShootingInput() * player.ShotSpeed * 5

			if laserData.UnbiddenLaser ~= game:GetLevel():GetCurrentRoomIndex() then
				laserData.UnbiddenLaser = game:GetLevel():GetCurrentRoomIndex()
				data.ludo = false
			end


			if not data.TechLudo then data.TechLudo = true end
			--data.UnbiddenBDamageDelay = 0

			if not player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY) or not player:HasCollectible(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE) or not data.BlindUnbidden then
				laser:Kill()
				data.TechLudo = false
			end


		elseif laserData.UnbiddenTech2Laser then
			if laserData.EnavleVisible > 0 then
				laserData.EnavleVisible = laserData.EnavleVisible -1
			else
				laser.Visible = true
			end

			if laserData.UnbiddenTech2Laser ~= game:GetLevel():GetCurrentRoomIndex() then
				laserData.UnbiddenTech2Laser = game:GetLevel():GetCurrentRoomIndex()
				laser.Visible = false
				laserData.EnavleVisible = 5
			end

			laser.Position = player.Position

			if player:GetFireDirection() ~= -1 then --
				laser:SetTimeout(3)
			end

		--elseif laserData.UnbiddenTechDot5Laser then
		elseif laserData.UnbiddenBrimLaser then
			
			if laser.Timeout < 4 and player:HasCollectible(CollectibleType.COLLECTIBLE_C_SECTION) and player:HasWeaponType(WeaponType.WEAPON_BRIMSTONE) then
				local fetusTear = player:FireTear(laser.Position, RandomVector()*player.ShotSpeed*14, false, false, false, player, 1):ToTear()
				fetusTear:ChangeVariant(TearVariant.FETUS)
				fetusTear:AddTearFlags(TearFlags.TEAR_FETUS)
				fetusTear:GetData().BrimFetus = true
				local tearSprite = fetusTear:GetSprite()
				tearSprite:ReplaceSpritesheet(0, "gfx/characters/costumes_unbidden/fetus_tears.png")
				tearSprite:LoadGraphics()
			end
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, EclipsedMod.onLaserUpdate )

---KNIFE
function EclipsedMod:onKnifeUpdate(knife, _) -- low
	if knife.SpawnerEntity and knife.SpawnerEntity:ToPlayer() then
		local player = knife.SpawnerEntity:ToPlayer()
		local data = player:GetData()
		if player:GetPlayerType() == enums.Characters.UnbiddenB then
			local range = player.TearRange*0.5
			if range > 300 then range = 300 end
			if range < 60 then range = 60 end
			WeaponAura(player, knife.Position, knife.FrameCount, data.UnbiddenBDamageDelay, range)
			--local function WeaponAura(player, auraPos, frameCount, maxCharge, range, blockLasers)
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_PRE_KNIFE_COLLISION, EclipsedMod.onKnifeUpdate) --KnifeSubType --MC_POST_KNIFE_UPDATE

---FETUS BOMB
function EclipsedMod:onFetusBombUpdate(bomb) -- low
	if bomb.IsFetus and bomb.SpawnerEntity and bomb.SpawnerEntity:ToPlayer() then
		local player = bomb.SpawnerEntity:ToPlayer()
		if player:GetPlayerType() == enums.Characters.UnbiddenB then
			WeaponAura(player, bomb.Position, bomb.FrameCount, 20) -- +7 bomb explodes on 40 frame
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, EclipsedMod.onFetusBombUpdate)

---FETUS TEAR
function EclipsedMod:onTearUpdate(tear)
	if tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer() and tear.SpawnerEntity:ToPlayer():GetPlayerType() == enums.Characters.UnbiddenB then
		local player = tear.SpawnerEntity:ToPlayer()
		tear.Color = datatables.UnbiddenBData.Stats.TEAR_COLOR
		tear.SplatColor = datatables.UnbiddenBData.Stats.LASER_COLOR
		if tear:HasTearFlags(TearFlags.TEAR_FETUS) then
			if tear:GetData().BrimFetus then
				WeaponAura(player, tear.Position, tear.FrameCount, 22, nil, true, true)
				--WeaponAura(player, auraPos, frameCount, maxCharge, range, blockLasers)
			elseif not player:GetData().UnbiddenBrimCircle then
				WeaponAura(player, tear.Position, tear.FrameCount)
			end
		elseif tear.Variant == TearVariant.SWORD_BEAM or tear.Variant == TearVariant.TECH_SWORD_BEAM then
			WeaponAura(player, tear.Position, tear.FrameCount)
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, EclipsedMod.onTearUpdate)

---Target Mark
function EclipsedMod:onTargetEffectUpdate(effect)
	if effect.FrameCount == 1 and effect.SpawnerEntity and effect.SpawnerEntity:ToPlayer() and effect.SpawnerEntity:ToPlayer():GetPlayerType() == enums.Characters.UnbiddenB then
		effect.Color = datatables.UnbiddenBData.Stats.TEAR_COLOR
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, EclipsedMod.onTargetEffectUpdate, EffectVariant.TARGET)

---Rocket
function EclipsedMod:onEpicFetusEffectUpdate(effect)
	if effect:GetData().KittenRocket and effect.FrameCount == 1 then
		effect.Visible = true
	elseif effect.SpawnerEntity and effect.SpawnerEntity:ToPlayer() and effect.SpawnerEntity:ToPlayer():GetPlayerType() == enums.Characters.UnbiddenB then
		local player = effect.SpawnerEntity:ToPlayer()
		--effect.Color = datatables.UnbiddenBData.Stats.TEAR_COLOR
		local range = player.TearRange*0.5
		if range > 300 then range = 300 end
		if range < 60 then range = 60 end
		WeaponAura(player, effect.Position, effect.FrameCount, nil, range) -- true
		--WeaponAura(player, auraPos, frameCount, maxCharge, range, blockLasers)
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, EclipsedMod.onEpicFetusEffectUpdate, EffectVariant.ROCKET)


---Eclipse
local function EclipseAura(player)
	local data = player:GetData()
	data.EclipseDamageDelay = data.EclipseDamageDelay or 0
	if data.EclipseDamageDelay < datatables.Eclipse.DamageDelay + math.floor(player.MaxFireDelay) then --  math.floor(player.MaxFireDelay)
		data.EclipseDamageDelay = data.EclipseDamageDelay + 1 
	end
	-- damage boosts count (work only with Curse of Darkness)
	data.EclipseBoost = data.EclipseBoost or 0
	if data.EclipseBoost > 0 and game:GetLevel():GetCurses() & LevelCurse.CURSE_OF_DARKNESS == 0 then
		data.EclipseBoost = 0
	end

	if game:GetLevel():GetCurses() & LevelCurse.CURSE_OF_DARKNESS > 0 then
		if not data.EclipseBoost or data.EclipseBoost ~= functions.GetItemsCount(player, enums.Items.Eclipse) then
			data.EclipseBoost = functions.GetItemsCount(player, enums.Items.Eclipse)
			player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
			player:EvaluateItems()
		end
	elseif data.EclipseBoost then
		data.EclipseBoost = nil
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		player:EvaluateItems()
	end

	if player:GetPlayerType() ~= enums.Characters.UnbiddenB and player:GetFireDirection() ~= -1 and data.EclipseDamageDelay >= datatables.Eclipse.DamageDelay + math.floor(player.MaxFireDelay) then --  
		data.EclipseDamageDelay = 0
		UnbiddenAura(player, player.Position, true)
	end
end

-- active item use
function EclipsedMod:onAnyItem2(item, _, player, useFlag, activeSlot)
	local data = player:GetData()
	if activeSlot == ActiveSlot.SLOT_PRIMARY and useFlag & datatables.MyUseFlags_Gene == 0 and (player:GetPlayerType() == enums.Characters.Unbidden or player:GetPlayerType() == enums.Characters.UnbiddenB) then
		data.UnbiddenCurrentHeldItem = item
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_ITEM, EclipsedMod.onAnyItem2)


--[ holy card use
function EclipsedMod:onHolyCard(card, player)
	if player:GetPlayerType() == enums.Characters.UnbiddenB then
		local data = player:GetData()
		data.UnbiddenUsedHolyCard = data.UnbiddenUsedHolyCard or 0
		data.UnbiddenUsedHolyCard = data.UnbiddenUsedHolyCard + 1
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onHolyCard, Card.CARD_HOLY)

-- soul lost use
function EclipsedMod:onSoulLost(card, player, useFlag)
	if player:GetPlayerType() == enums.Characters.UnbiddenB and useFlag & datatables.MyUseFlags_Gene ~= datatables.MyUseFlags_Gene then
		local data = player:GetData()
		data.UnbiddenUsedHolyCard = data.UnbiddenUsedHolyCard or 0
		data.UnbiddenUsedHolyCard = data.UnbiddenUsedHolyCard + 1
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.onSoulLost, Card.CARD_SOUL_LOST)

function EclipsedMod:onPEffectUpdate3(player)
	local level = game:GetLevel()
	local data = player:GetData()
	local tempEffects = player:GetEffects()

	if game:GetFrameCount() == 1 then 
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

	if data.BlockBeggar then
		if game:GetFrameCount() - data.BlockBeggar > 30 then data.BlockBeggar = nil end
	end

	if data.SadIceBombTear and #data.SadIceBombTear > 0 then
		local iceTab = {}
		for key, tab in pairs(data.SadIceBombTear) do
			tab[1] = tab[1] - 1
			if tab[1] == 0 then
				table.insert(iceTab, {key, tab[2]})
			end
		end
		if #iceTab> 0 then
			for i = #iceTab, 1, -1 do
				for _, tear in pairs(Isaac.FindInRadius(iceTab[i][2], 22, EntityPartition.TEAR)) do
					if tear.FrameCount == 1 then -- other tears can get this effects if you shoot tears near bomb (idk else how to get)
						tear = tear:ToTear()
						tear:ChangeVariant(TearVariant.ICE)
						tear:AddTearFlags(TearFlags.TEAR_SLOW | TearFlags.TEAR_ICE)
					end
				end
				table.remove(data.SadIceBombTear, iceTab[i][1])
			end
		end
	end

	---Nadab's Body
	if player:HasCollectible(enums.Items.NadabBody, true) then
		if player:GetPlayerType() ~= enums.Characters.Abihu then

			if data.HoldBomd == 0 and not player:IsHoldingItem() and data.NadabReHold and game:GetFrameCount() - data.NadabReHold > 30 then
				data.HoldBomd = -1
				data.NadabReHold = nil
			end

			-- holding bomb
			data.HoldBomd = data.HoldBomd or -1
			if data.HoldBomd == 1 then
				data.HoldBomd = -1
			elseif data.HoldBomd > 0 then
				data.HoldBomd = data.HoldBomd - 1
			end
		end

		if player:GetPlayerType() ~= enums.Characters.Nadab then
			ExplosionCountdownManager(player)
		end

		local bomboys = 0 -- nadab's body count
		local bombVar = BombVariant.BOMB_DECOY
		if player:GetPlayerType() == enums.Characters.Abihu then bombVar = -1 end
		local roombombs = Isaac.FindByType(EntityType.ENTITY_BOMB, bombVar) --, BombVariant.BOMB_DECOY)
		if #roombombs > 0 then
			
			for _, body in pairs(roombombs) do
				if body.Variant ~= BombVariant.BOMB_THROWABLE then
					if body:GetData().bomby then
						bomboys = bomboys +1
					end
					
					-- check if abihu can hold bomb
					--if player:GetPlayerType() == enums.Characters.Abihu then
					if body.Position:Distance(player.Position) <= 30 and data.HoldBomd < 0 then
						if player:TryHoldEntity(body) then
							data.HoldBomd = 0
							data.NadabReHold = game:GetFrameCount()
							if body:GetData().bomby then
								data.AbihuHoldNadab = true
							end
						end
					end
				end
			end
		end
		
		-- respawn nadab's body if it was somehow disappeared	
		if bomboys < functions.GetItemsCount(player, enums.Items.NadabBody, true) then
			bomboys = functions.GetItemsCount(player, enums.Items.NadabBody, true) - bomboys
			for _=1, bomboys do
				local pos = Isaac.GetFreeNearPosition(player.Position, 25)
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pos, Vector.Zero, nil)
				local bomb = Isaac.Spawn(EntityType.ENTITY_BOMB, BombVariant.BOMB_DECOY, 0, pos, Vector.Zero, nil):ToBomb()
				bomb:GetData().bomby = true
				bomb:GetSprite():ReplaceSpritesheet(0, datatables.NadabBody.SpritePath)
				bomb:GetSprite():LoadGraphics()
				bomb.Parent = player
			end
		end
		
		-- bug with bombs and encyclopedia (well)
		if Encyclopedia and (Input.IsButtonTriggered(Keyboard.KEY_C, player.ControllerIndex) or Input.IsButtonTriggered(Keyboard.KEY_F1, player.ControllerIndex)) then
			datatables.GameTimeCounter = datatables.GameTimeCounter or game.TimeCounter
			if #roombombs > 0 then
				for _, body in pairs(roombombs) do
					body:Remove()
				end
				datatables.GameTimeCounter = game.TimeCounter
			elseif game.TimeCounter ~= datatables.GameTimeCounter then
				datatables.GameTimeCounter = nil
			end
		end

		if Input.IsActionPressed(ButtonAction.ACTION_BOMB, player.ControllerIndex) and player:GetPlayerType() == enums.Characters.Abihu then --Input.IsActionPressed(action, controllerId) IsActionTriggered
			local checkBombsNum = player:GetHearts()
			if checkBombsNum > 0 and data.ExCountdown == 0 then --  and not player:HasCollectible(CollectibleType.COLLECTIBLE_BLOOD_BOMBS) -- and player:GetNumBombs() > 0 then
				if player:HasCollectible(CollectibleType.COLLECTIBLE_ROCKET_IN_A_JAR) then
					if player:GetFireDirection() == -1 then
						data.ExCountdown = datatables.NadabData.ExplosionCountdown
						if not player:HasCollectible(CollectibleType.COLLECTIBLE_PYROMANIAC) then
							player:TakeDamage(1, DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_RED_HEARTS, EntityRef(player), 1)
						end
						FcukingBomberbody(player)
					else
						if not player:HasCollectible(CollectibleType.COLLECTIBLE_PYROMANIAC) then
							player:TakeDamage(1, DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_RED_HEARTS, EntityRef(player), 1) -- take dmg first to apply MARS dash
						end
						data.ExCountdown = datatables.NadabData.ExplosionCountdown
						local bodies2 = Isaac.FindByType(EntityType.ENTITY_BOMB, BombVariant.BOMB_DECOY)
						for _, body in pairs(bodies2) do
							if body:GetData().bomby then
								body:GetData().RocketBody = datatables.NadabBody.RocketVol
								body.Velocity = player:GetShootingInput() * body:GetData().RocketBody
							end
						end
					end
				else
					data.ExCountdown = datatables.NadabData.ExplosionCountdown
					if not player:HasCollectible(CollectibleType.COLLECTIBLE_PYROMANIAC) then
						player:TakeDamage(1, DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_RED_HEARTS, EntityRef(player), 1)
					end
					FcukingBomberbody(player)
				end
			end
		end
	end

	if player:GetPlayerType() == enums.Characters.Nadab then
		AbihuNadabManager(player)
		ExplosionCountdownManager(player)
		--ice cube bombs
		if player:HasCollectible(enums.Items.FrostyBombs) and game:GetFrameCount() %8 == 0 then -- spawn every 8th frame
			local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL, 0, player.Position, Vector.Zero, player):ToEffect() -- PLAYER_CREEP_RED
			creep.SpriteScale = creep.SpriteScale * 0.1
		end

		--bob's bladder
		if player:HasTrinket(TrinketType.TRINKET_BOBS_BLADDER) and game:GetFrameCount() %8 == 0 then -- spawn every 8th frame
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_GREEN, 0, player.Position, Vector.Zero, player)
		end

		--ring cap explosion
		if data.RingCapDelay then
			data.RingCapDelay = data.RingCapDelay + 1
			if data.RingCapDelay > player:GetTrinketMultiplier(TrinketType.TRINKET_RING_CAP) * datatables.NadabData.RingCapFrameCount then
				data.RingCapDelay = nil
			elseif data.RingCapDelay % datatables.NadabData.RingCapFrameCount == 0 then
				if player:HasCollectible(enums.Items.MirrorBombs) then
					NadabExplosion(player, false, functions.FlipMirrorPos(player.Position))
				end
				NadabExplosion(player, false, player.Position)
			end
		end

		--some bomb modifications
		data.HasFastBombs = NadabEvaluateStats(player, CollectibleType.COLLECTIBLE_FAST_BOMBS, CacheFlag.CACHE_SPEED, data.HasFastBombs)
		data.HasSadBombs = NadabEvaluateStats(player, CollectibleType.COLLECTIBLE_SAD_BOMBS, CacheFlag.CACHE_FIREDELAY, data.HasSadBombs)
		data.HasMegaBombs = NadabEvaluateStats(player, CollectibleType.COLLECTIBLE_MR_MEGA, CacheFlag.CACHE_DAMAGE, data.HasMegaBombs)
		data.HasSmartBombs = NadabEvaluateStats(player, CollectibleType.COLLECTIBLE_BOBBY_BOMB, CacheFlag.CACHE_TEARFLAG, data.HasSmartBombs)

		-- rocket in a jar
		if data.RocketMars then
			if not tempEffects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_MARS) then
				data.ExCountdown = datatables.NadabData.ExplosionCountdown
				FcukingBomberman(player)
				data.RocketMars = false
			end
		end

		-- explosion
		if Input.IsActionPressed(ButtonAction.ACTION_BOMB, player.ControllerIndex) then
			if player:GetHearts() > 0 and data.ExCountdown == 0 then
				if player:HasCollectible(CollectibleType.COLLECTIBLE_ROCKET_IN_A_JAR) then
					if player:GetMovementDirection() ~= -1 then
						if not player:HasCollectible(CollectibleType.COLLECTIBLE_PYROMANIAC) then
							player:TakeDamage(1, DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_RED_HEARTS, EntityRef(player), 1)
						end
						-- take dmg first to apply MARS dash
						tempEffects:AddCollectibleEffect(CollectibleType.COLLECTIBLE_MARS, false, 1)
						data.RocketMars = true
					else
						data.ExCountdown = datatables.NadabData.ExplosionCountdown
						if not player:HasCollectible(CollectibleType.COLLECTIBLE_PYROMANIAC) then
							player:TakeDamage(1, DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_RED_HEARTS, EntityRef(player), 1)
						end
						FcukingBomberman(player)
					end
				else
					data.ExCountdown = datatables.NadabData.ExplosionCountdown
					if not player:HasCollectible(CollectibleType.COLLECTIBLE_PYROMANIAC) then
						player:TakeDamage(1, DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_RED_HEARTS, EntityRef(player), 1)
					end
					FcukingBomberman(player)
				end
			end
		end

	end

	if player:GetPlayerType() == enums.Characters.Abihu then
		-- must be still able to move ludovico, knife ?
		-- charge fire and shoot it (similar to candle)

		--[[
		if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE) and data.BlindAbihu then
			if data.BlindAbihu then
				data.BlindAbihu = nil
				functions.SetBlindfold(player, false)
			end
			functions.SetBlindfold(player, false)
		end
		--]]
		--data.AbihuIgnites = true

		if tempEffects:HasNullEffect(NullItemID.ID_LOST_CURSE) then
			data.AbihuIgnites = true
			if not data.AbihuCostumeEquipped then
				data.AbihuCostumeEquipped = true
				player:AddNullCostume(datatables.AbihuData.CostumeHead)
			end
		end

		AbihuNadabManager(player)

		-- holding bomb
		if not data.HoldBomd then data.HoldBomd = -1 end
		if data.HoldBomd == 1 then
			data.HoldBomd = -1
		elseif data.HoldBomd > 0 then
			data.HoldBomd = data.HoldBomd - 1
		end

		-- flamethrower
		data.AbihuDamageDelay = data.AbihuDamageDelay or 0
		local maxCharge =  math.floor(player.MaxFireDelay) + datatables.AbihuData.DamageDelay

		--data.AbihuCostumeEquipped = true
		--player:AddNullCostume(datatables.AbihuData.CostumeHead)

		-- if "shooting" / shoot inputs is pressed
		if player:GetFireDirection() == -1 then -- or data.AbihuIgnites
			if data.AbihuDamageDelay == maxCharge then
				local spid = math.floor(player.ShotSpeed * 14)
				sfx:Play(536)
				local flame = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLUE_FLAME, 0, player.Position, player:GetLastDirection()*spid, player):ToEffect()
				flame:SetTimeout(math.floor(player.TearRange*0.1))
				flame.CollisionDamage = player.Damage * 4
				flame:GetData().AbihuFlame = true
				flame.Parent = player
				data.AbihuDamageDelay = 0
			else
				data.AbihuDamageDelay = 0
			end

			-- drop bomb if you are holding it and didn't have throw delay
			-- OR
			-- remove nadab's body if you hold it long enough, it will respawn near player
			if Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex) and data.HoldBomd <= 0 then
				-- holding drop button
				data.HoldActionDrop = data.HoldActionDrop or 0
				data.HoldActionDrop = data.HoldActionDrop + 1 -- holding drop button
				if data.HoldActionDrop > 30 then
					if data.HoldBomd == 0 then
						data.HoldActionDrop = 0
						data.ThrowVelocity = Vector.Zero
						player:ThrowHeldEntity(data.ThrowVelocity)
						data.HoldBomd = datatables.AbihuData.HoldBombDelay
						if data.AbihuHoldNadab then data.AbihuHoldNadab = nil end
					else --if data.HoldBomd == - 1 then
						data.HoldActionDrop = 0
						local bodies3 = Isaac.FindByType(EntityType.ENTITY_BOMB, BombVariant.BOMB_DECOY)
						if #bodies3 > 0 then
							for _, body in pairs(bodies3) do
								if body:GetData().bomby then
									body:Kill()
									data.HoldActionDrop = 0
								end
							end
						end
					end
				end
			else
				data.HoldActionDrop = 0
			end
		else
			if data.HoldBomd == 0 then
				if player:HasCollectible(CollectibleType.COLLECTIBLE_ROCKET_IN_A_JAR) then data.RocketThrowMulti = 14 end
				local throwVelocity = player:GetShootingJoystick() or player:GetShootingInput()
				data.ThrowVelocity = throwVelocity*player.ShotSpeed
				player:ThrowHeldEntity(data.ThrowVelocity)
				data.HoldBomd = datatables.AbihuData.HoldBombDelay
				if data.AbihuHoldNadab then data.AbihuHoldNadab = nil end
			elseif player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) or data.AbihuIgnites then
				if data.AbihuDamageDelay < maxCharge then
					data.AbihuDamageDelay = data.AbihuDamageDelay + 1
				elseif data.AbihuDamageDelay == maxCharge then
					if game:GetFrameCount() % 6 == 0 then
						player:SetColor(Color(1,1,1,1, 0.2, 0.2, 0.5), 2, 1, true, false)
					end
				end
			end
		end

		--birthright
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
			if not data.AbihuCostumeEquipped then
				data.AbihuCostumeEquipped = true
				player:AddNullCostume(datatables.AbihuData.CostumeHead)
			end
		end

		--glowing
		if data.ResetBlind then
			data.ResetBlind = data.ResetBlind -1
			if data.ResetBlind <= 0 then
				data.BlindAbihu = true
				functions.SetBlindfold(player, true)
				data.ResetBlind = nil
			end
		end
	end
	
	if game:GetFrameCount()%30 == 0 then
		for slot = 0, 3 do
			if player:GetActiveItem(slot) == enums.Items.Threshold then
				if player:GetActiveCharge(slot) >=  Isaac.GetItemConfig():GetCollectible(enums.Items.Threshold).MaxCharges then
					local itemWisps = Isaac.FindInRadius(player.Position, datatables.UnbiddenData.RadiusWisp, EntityPartition.FAMILIAR)
					if #itemWisps > 0 then
						for _, witem in pairs(itemWisps) do
							if witem.Variant == FamiliarVariant.ITEM_WISP and not functions.CheckItemType(witem.SubType) then
								witem:SetColor(Color(0,0,5,1), 30, 1, true, false)
								break
							end
						end
					end
				end
			end
		end
	end
	
	if player:GetPlayerType() == enums.Characters.Unbidden or player:GetPlayerType() == enums.Characters.UnbiddenB then 
		local currentItem = player:GetActiveItem(ActiveSlot.SLOT_PRIMARY)
		local UnbiidenCahceActiveWisps = {}
		local wipsCounter = 0
		data.UnbiddenActiveWisps = data.UnbiddenActiveWisps or {} -- table where save active items
		local itemWisps = Isaac.FindInRadius(player.Position, datatables.UnbiddenData.RadiusWisp, EntityPartition.FAMILIAR)
		if #itemWisps > 0 then
			for _, witem in pairs(itemWisps) do
				if witem.Variant == FamiliarVariant.ITEM_WISP and functions.CheckItemType(witem.SubType) then
					wipsCounter = wipsCounter + 1
					if not data.UnbiddenActiveWisps[witem.SubType] then
						local initCharge = Isaac.GetItemConfig():GetCollectible(witem.SubType).InitCharge
						local firstPick = true
						local varData = 0
						UnbiidenCahceActiveWisps[witem.SubType] = {initCharge = initCharge, firstPick = firstPick, varData = varData}
					elseif data.UnbiddenActiveWisps[witem.SubType] then
						local cacheItemData = data.UnbiddenActiveWisps[witem.SubType]
						--local initCharge = cacheItemData.initCharge
						--local firstPick = cacheItemData.firstPick
						--local varData = cacheItemData.varData
						UnbiidenCahceActiveWisps[witem.SubType] =  data.UnbiddenActiveWisps[witem.SubType] -- {initCharge = initCharge, firstPick = firstPick, varData = varData}
					end
				end
			end
		end

		if wipsCounter > 0 then
			--print(wipsCounter)
			if currentItem == 0 or currentItem == CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES then
				if data.UnbiddenCurrentHeldItem then
					for _, witem in pairs(itemWisps) do
						if data.UnbiddenCurrentHeldItem == witem.SubType then
							witem:Remove()
							witem:Kill()
							data.UnbiddenCurrentHeldItem = nil
							break
						end
					end
					data.UnbiddenCurrentHeldItem = nil
				else
					--add active item from wisps table
					for itemIndex, itemData in pairs(UnbiidenCahceActiveWisps) do
						player:AddCollectible(itemIndex, itemData.initCharge, itemData.firstPick, ActiveSlot.SLOT_PRIMARY, itemData.varData)
						break
					end
				end
			else
				--if wipsCounter > 1 then
				if not data.UnbiddenBSwapActiveWisp then
					if Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex) then
						data.UnbiddenBSwapActiveWisp = true
						--swap items in activeWisps table -- player:SwapActiveItems() --void
						local fondue = false
						for item = currentItem+1, Isaac.GetItemConfig():GetCollectibles().Size - 1 do
							if UnbiidenCahceActiveWisps[item] then--
								--print(item, currentItem, UnbiidenCahceActiveWisps[item],  UnbiidenCahceActiveWisps[currentItem])
								local initCharge = player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY)
								local firstPick = false
								local varData = player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY)
								UnbiidenCahceActiveWisps[currentItem] = {initCharge = initCharge, firstPick = firstPick, varData = varData}
								player:RemoveCollectible(currentItem)
								local itemData = UnbiidenCahceActiveWisps[item]
								
								player:AddCollectible(item, itemData.initCharge, itemData.firstPick, ActiveSlot.SLOT_PRIMARY, itemData.varData)
								fondue = true
								break
							end
						end
						
						if not fondue then
							for item = 1, currentItem-1 do
								if UnbiidenCahceActiveWisps[item] then--
									--print(item, currentItem, UnbiidenCahceActiveWisps[item],  UnbiidenCahceActiveWisps[currentItem])
									local initCharge = player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY)
									local firstPick = false
									local varData = player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY)
									UnbiidenCahceActiveWisps[currentItem] = {initCharge = initCharge, firstPick = firstPick, varData = varData}
									player:RemoveCollectible(currentItem)
									local itemData = UnbiidenCahceActiveWisps[item]
									player:AddCollectible(item, itemData.initCharge, itemData.firstPick, ActiveSlot.SLOT_PRIMARY, itemData.varData)
									fondue = true
									break
								end
							end
						end
					end
				else
					if not Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex) then
						data.UnbiddenBSwapActiveWisp = false
					end
				end
				--end
			end

			-- save to next loop update
			for itemIndex, itemData in pairs(UnbiidenCahceActiveWisps) do
				data.UnbiddenActiveWisps[itemIndex] = itemData
			end
		end
	end
	
	if player:GetPlayerType() == enums.Characters.Unbidden then

		if player:GetMaxHearts() > 0 then
			local maxHearts = player:GetMaxHearts()
			player:AddMaxHearts(-maxHearts)
			player:AddSoulHearts(maxHearts)
        end

		if player:GetHearts() > 0 then
			player:AddHearts(-player:GetHearts())
		end
		
		if data.NoAnimReset then
			--player:UseCard(Card.CARD_SOUL_LAZARUS, datatables.MyUseFlags_Gene)
			player:AnimateTeleport(false)
            data.NoAnimReset = data.NoAnimReset - 1
			if data.NoAnimReset == 0 then
				data.NoAnimReset = nil
				player:AddBrokenHearts(1)
				if data.BeastCounter then
					player:AddBrokenHearts(data.BeastCounter)
					data.BeastCounter = data.BeastCounter + 1
				end
			end
        end
	end

	if player:GetPlayerType() == enums.Characters.UnbiddenB then
			
		local holyMantles = tempEffects:GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_HOLY_MANTLE)
		
		if holyMantles == data.UnbiddenUsedHolyCard+1 then
			if player:HasTrinket(TrinketType.TRINKET_WOODEN_CROSS) then
				data.LostWoodenCross = true
			end
			tempEffects:RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE)
		end
		
		
		if player:GetEffectiveMaxHearts() > 0 then
			local maxHearts = player:GetEffectiveMaxHearts()
			player:AddMaxHearts(-maxHearts)
        end

		if player:GetSoulHearts() > 2 and not player:HasCollectible(CollectibleType.COLLECTIBLE_ALABASTER_BOX) then
			local allsouls = player:GetSoulHearts()-2
			player:AddSoulHearts(-allsouls)
		end
		
		if player:HasWeaponType(WeaponType.WEAPON_BOMBS) or
			player:HasWeaponType(WeaponType.WEAPON_ROCKETS) or
			player:HasWeaponType(WeaponType.WEAPON_FETUS) or
			player:HasWeaponType(WeaponType.WEAPON_SPIRIT_SWORD) or
			player:HasWeaponType(WeaponType.WEAPON_KNIFE) then

			if data.BlindUnbidden then
				data.BlindUnbidden = false
				functions.SetBlindfold(player, false)
			end
		elseif not data.BlindUnbidden then
			data.BlindUnbidden = true
			functions.SetBlindfold(player, true)
		end

		-- urn of souls and nocthed axe. idk how to remove tech2 laser when you use this items.
		--(i can remove all lasers while you have weapon but it's not a proper solution)
		local weapon = player:GetActiveWeaponEntity()
		if weapon then
			if (weapon:ToKnife() or weapon:ToEffect()) then
				data.UnbiddenBDamageDelay = 0
				data.HoldingWeapon = true
			end
		else
			data.HoldingWeapon = false
		end

		if player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY) or player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) or player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X) then --
			data.UnbiddenBDamageDelay = data.UnbiddenBDamageDelay or 0
			local laserDelay = data.UnbiddenBDamageDelay
			if laserDelay < datatables.UnbiddenBData.DamageDelay then laserDelay = datatables.UnbiddenBData.DamageDelay end
			data.UnbiddenBrimCircle = laserDelay
			--data.UnbiddenBrimCircleRange = data.UnbiddenBDamageDelay
		elseif data.UnbiddenBrimCircle then
			data.UnbiddenBrimCircle = false
		end

		if data.BlindUnbidden then

			-- change position if you has ludo
			local auraPos = player.Position

			if player:HasCollectible(CollectibleType.COLLECTIBLE_DEAD_EYE) then
				data.DeadEyeCounter = data.DeadEyeCounter or 0
				data.DeadEyeMissCounter = data.DeadEyeMissCounter or 0
			end
			--if player:HasCollectible(CollectibleType.COLLECTIBLE_MARKED) or
			if player:HasCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK) or player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X) or player:HasCollectible(CollectibleType.COLLECTIBLE_CURSED_EYE) then -- semi-charge
				data.UnbiddenSemiCharge = true
			elseif player:HasCollectible(CollectibleType.COLLECTIBLE_MONSTROS_LUNG) or player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) then --or player:HasWeaponType(WeaponType.WEAPON_MONSTROS_LUNGS) then
				data.UnbiddenFullCharge = true
				if data.UnbiddenSemiCharge then data.UnbiddenSemiCharge = false end
			else
				if data.UnbiddenFullCharge then data.UnbiddenFullCharge = false end
				if data.UnbiddenSemiCharge then data.UnbiddenSemiCharge = false end
			end


			if player:HasCollectible(CollectibleType.COLLECTIBLE_MARKED) then
				local targets = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.TARGET)
				if #targets > 0 then
					for _, target in pairs(targets) do
						if target.SpawnerEntity and target.SpawnerEntity:ToPlayer() and target.SpawnerEntity:ToPlayer():GetPlayerType() == enums.Characters.UnbiddenB then
							auraPos = target.Position
							--target.Color = datatables.UnbiddenBData.Stats.TEAR_COLOR
							data.UnbiddenMarked = true
						end
					end
				else
					data.UnbiddenMarked = false
				end
			else
				if data.UnbiddenMarked then data.UnbiddenMarked = nil end
			end

			if player:HasCollectible(CollectibleType.COLLECTIBLE_EYE_OF_THE_OCCULT) then
				local targets = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.OCCULT_TARGET)
				if #targets > 0 then
					for _, target in pairs(targets) do
						if target.SpawnerEntity and target.SpawnerEntity:ToPlayer() and target.SpawnerEntity:ToPlayer():GetPlayerType() == enums.Characters.UnbiddenB then
							auraPos = target.Position
							data.UnbiddenOccult = true
						end
					end
				else
					data.UnbiddenOccult = false
				end
			else
				if data.UnbiddenOccult then data.UnbiddenOccult = nil end
			end

			-- ludovico tear
			if player:HasCollectible(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE) then
				if Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex) then
					data.ludo = false
					data.TechLudo = false
				end
				
				if player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY) then
					local lasers = Isaac.FindByType(EntityType.ENTITY_LASER)
					if #lasers > 0 then
						for _, laser in pairs(lasers) do
							if laser:GetData().UnbiddenLaser then
								auraPos = laser.Position
								if not data.ludo and player.Position:Distance(laser.Position) > 60 then
									laser:AddVelocity((player.Position - laser.Position):Resized(player.ShotSpeed*5))
								end
							end
						end
					else
						local rrnge = player.TearRange*0.5
						if rrnge > 300 then rrnge = 300 end
						local laser = player:FireTechXLaser(auraPos, Vector.Zero, rrnge, player, 1):ToLaser()--Isaac.Spawn(EntityType.ENTITY_LASER, datatables.UnbiddenBData.TearVariant, 0, player.Position, Vector.Zero, player):ToTear()
						--laser:AddTearFlags(player.TearFlags)
						--laser.Variant = LaserVariant.THIN_RED
						laser:GetData().UnbiddenLaser = level:GetCurrentRoomIndex()
						laser:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
						laser:SetTimeout(30)
						data.TechLudo = true
					end
				else
					local tears = Isaac.FindByType(EntityType.ENTITY_TEAR, datatables.UnbiddenBData.TearVariant)
					if #tears > 0 and not data.LudoTearEnable then
						for _, tear in pairs(tears) do
							if tear:GetData().UnbiddenTear then
								auraPos = tear.Position
								if not data.ludo and player.Position:Distance(tear.Position) > 60 then
									tear:AddVelocity((player.Position - tear.Position):Resized(player.ShotSpeed))
								end
							end
						end
					else
						local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, datatables.UnbiddenBData.TearVariant, 0, player.Position, Vector.Zero, player):ToTear()
						tear:AddTearFlags(player.TearFlags)
						tear.CollisionDamage = 0
						tear:GetData().UnbiddenTear = true
						tear.EntityCollisionClass = 0
						data.LudoTearEnable = false
					end
				end
			else
				if data.ludo then data.ludo = false end
				if data.TechLudo then data.TechLudo = false end
			end

			--firedelay analog
			data.UnbiddenBDamageDelay = data.UnbiddenBDamageDelay or 0
			local maxCharge = math.floor(player.MaxFireDelay) + datatables.UnbiddenBData.DamageDelay
			if not data.UnbiddenFullCharge and not data.UnbiddenSemiCharge then
				if data.UnbiddenBDamageDelay < maxCharge then data.UnbiddenBDamageDelay = data.UnbiddenBDamageDelay + 1 end
			end

			-- create multiply aura with X delayed frame (multishot analog)
			--[[
			if data.MultipleAura and game:GetFrameCount()%2 == 0 then
				if data.MultipleAura > 0 then
					UnbiddenAura(player, auraPos, true)
					data.MultipleAura = data.MultipleAura - 1
				else
					data.MultipleAura = nil
				end
			end
			--]]

			-- if not shooting
			if player:GetFireDirection() == -1 or data.UnbiddenMarkedAuto then
				if data.UnbiddenMarkedAuto then data.UnbiddenMarkedAuto = nil end
				if data.UnbiddenBTechDot5Delay then data.UnbiddenBTechDot5Delay = 0 end
				if data.HasTech2Laser then data.HasTech2Laser = false end

				if data.UnbiddenSemiCharge and data.UnbiddenBDamageDelay > 0 then
					--if data.UnbiddenBDamageDelay > 0.15*maxCharge then
						--local damageMultiplier = player.Damage
						local tearsNum = GetMultiShotNum(player)
						data.MultipleAura = data.MultipleAura or 0
						local chargeCounter = math.floor((data.UnbiddenBDamageDelay * 100) /maxCharge)
						if player:HasCollectible(CollectibleType.COLLECTIBLE_CURSED_EYE) then
							tearsNum = tearsNum + math.floor(chargeCounter*0.04) --(1/25) -- add +1 aura activation for each 25 charge counter
						end
						if player:HasCollectible(CollectibleType.COLLECTIBLE_MONSTROS_LUNG) then
							tearsNum = tearsNum + 1+ math.floor(chargeCounter * 0.13) --(min = 1 ; max = 14) -- magic number :) monstro lung creates 14 tears when fully charged so 1 + 13/100
						end
						data.MultipleAura = data.MultipleAura + tearsNum

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
						UnbiddenAura(player, auraPos, false, ChocolateDamageMultiplier)
					--else
					--	data.UnbiddenBDamageDelay = 0
					--end
				elseif data.UnbiddenFullCharge then
					if data.UnbiddenBDamageDelay == maxCharge then
						local tearsNum = GetMultiShotNum(player)
						data.MultipleAura = data.MultipleAura or 0
						if player:HasCollectible(CollectibleType.COLLECTIBLE_MONSTROS_LUNG) then
							data.MultipleAura = data.MultipleAura + 14 + tearsNum
						end

						UnbiddenAura(player, auraPos)
					else
						data.UnbiddenBDamageDelay = 0
					end
				--else -- DO NOT TOUCH... checking it inside UnbiddenAura function (there it stops MultipleAura from charging)
				--  data.UnbiddenBDamageDelay = 0
				elseif data.ludo or player:HasCollectible(CollectibleType.COLLECTIBLE_EYE_OF_THE_OCCULT) then -- auto attack
					if data.UnbiddenBDamageDelay >= maxCharge then

						local tearsNum = GetMultiShotNum(player)
						data.MultipleAura = data.MultipleAura or 0
						data.MultipleAura = data.MultipleAura + tearsNum
						UnbiddenAura(player, auraPos)

					end
				end
			--if shooting
			elseif player:GetFireDirection() ~= -1 or data.ludo then
				if player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_5) then
					data.UnbiddenBTechDot5Delay = data.UnbiddenBTechDot5Delay or 0
					data.UnbiddenBTechDot5Delay = data.UnbiddenBTechDot5Delay + 1
					if data.UnbiddenBTechDot5Delay >= maxCharge then --data.BlindUnbidden
						TechDot5Shot(player)
						data.UnbiddenBTechDot5Delay = 0
					end
				end
				-- if player has monstro's lung charge attack
				if data.UnbiddenFullCharge or data.UnbiddenSemiCharge then

					if data.UnbiddenBDamageDelay < maxCharge then
						data.UnbiddenBDamageDelay = data.UnbiddenBDamageDelay + 1
					elseif data.UnbiddenBDamageDelay == maxCharge then
						if game:GetFrameCount() % 6 == 0 then
							player:SetColor(Color(1,1,1,1, 0.2, 0.2, 0.5), 2, 1, true, false)
						end
						if data.UnbiddenMarked or data.UnbiddenOccult then
							data.UnbiddenMarkedAuto = true
						end
					end
				else
					-- normal aura + multiply attacks
					if data.UnbiddenBDamageDelay >= maxCharge then

						local tearsNum = GetMultiShotNum(player)
						data.MultipleAura = data.MultipleAura or 0
						data.MultipleAura = data.MultipleAura + tearsNum
						UnbiddenAura(player, auraPos)

					end
				end

				if player:HasCollectible(CollectibleType.COLLECTIBLE_MARKED) then
					data.UnbiddenMarked = true
				end

				--ludovico tech (create controllable tear, which auto-creates aura)
				if player:HasCollectible(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE) then
					data.ludo = true

				end

				-- GodHead (ceate aura around you while shoot pressed)
				if player:HasCollectible(CollectibleType.COLLECTIBLE_GODHEAD) then
					GodHeadAura(player)
				end

				-- Tech 2 (ceate laser circle around you while shoot pressed)
				if player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY_2) and not data.HasTech2Laser then
					Technology2Aura(player)
				end

			end
		end

		if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and level:GetCurses() > 0 then
			level:RemoveCurses(level:GetCurses())
		end
		
		if data.NoAnimReset then
			player:AnimateTeleport(false)
			if not tempEffects:HasNullEffect(NullItemID.ID_LOST_CURSE) then
				tempEffects:AddNullEffect(NullItemID.ID_LOST_CURSE, false, 1)
			end
			data.NoAnimReset = data.NoAnimReset - 1
			if data.NoAnimReset == 0 then
				data.BlindUnbidden = true
				functions.SetBlindfold(player, true)
				data.LevelRewindCounter = data.LevelRewindCounter or 0
				data.UnbiddenResetGameChance = data.UnbiddenResetGameChance or 100
				data.UnbiddenResetGameChance = data.UnbiddenResetGameChance - 1 * data.LevelRewindCounter
				data.LevelRewindCounter = data.LevelRewindCounter + 1
				data.NoAnimReset = nil
			end
		end

		--glowing
		if data.ResetBlind then
			data.ResetBlind = data.ResetBlind -1
			if data.ResetBlind <= 0 then
				data.BlindUnbidden = true
				functions.SetBlindfold(player, true)
				data.ResetBlind = nil
			end
		end
	end

	if not player:HasCurseMistEffect() and not player:IsCoopGhost() then
		--- Eclipsed
		if player:HasCollectible(enums.Items.Eclipse) then
			EclipseAura(player)
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, EclipsedMod.onPEffectUpdate3)

function EclipsedMod:onUpdate2()
	--- Unbidden time rewind ability. don't trigger if you have more than 11 broken hearts a
	for playerNum = 0, game:GetNumPlayers()-1 do
		local player = game:GetPlayer(playerNum):ToPlayer()
		local data = player:GetData()
		if player:GetPlayerType() == enums.Characters.UnbiddenB and not player:HasCollectible(enums.Items.Threshold) and player:CanAddCollectible(enums.Items.Threshold) and not player:HasCurseMistEffect() and not player:IsCoopGhost() then
			player:SetPocketActiveItem(enums.Items.Threshold, ActiveSlot.SLOT_POCKET, false)
		end
		
		if player:IsDead() and not player:HasTrinket(enums.Trinkets.WitchPaper) and player:GetBrokenHearts() < 11 then
			if player:GetPlayerType() == enums.Characters.Unbidden or player:GetPlayerType() == enums.Characters.UnbiddenB then
				--if not data.usedPlanC then
				--player:UseCard(Card.CARD_SOUL_LAZARUS, datatables.MyUseFlags_Gene)	
				if game:GetRoom():GetType() == RoomType.ROOM_DUNGEON and game:GetRoom():GetRoomConfigStage() == 35 then 
					if player:GetPlayerType() == enums.Characters.Unbidden or player:GetPlayerType() == enums.Characters.UnbiddenB then
						data.BeastCounter = data.BeastCounter or 0
					end
					Isaac.ExecuteCommand("stage 13")		
				end
				if player:GetPlayerType() == enums.Characters.UnbiddenB then 
					data.UnbiddenResetGameChance = data.UnbiddenResetGameChance or 100
					if data.UnbiddenResetGameChance <= 0 then -- myrng:RandomFloat() <= 0.01 then 
						Isaac.ExecuteCommand("restart")
					end
				end

				data.NoAnimReset = 2
				player:UseActiveItem(CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS, datatables.MyUseFlags_Gene)
					
				--end
			end
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_POST_UPDATE, EclipsedMod.onUpdate2)


function EclipsedMod:onItemWispDeath(entity) 
	if entity.Variant == FamiliarVariant.ITEM_WISP then
		if entity.SpawnerEntity and entity.SpawnerEntity:ToPlayer() then
			local player = entity.SpawnerEntity:ToPlayer()
			local data = player:GetData()
			if player:GetPlayerType() == enums.Characters.UnbiddenB then
				data.UnbiddenResetGameChance = data.UnbiddenResetGameChance or 100
				if data.UnbiddenResetGameChance < 100 then
					data.UnbiddenResetGameChance = data.UnbiddenResetGameChance + 1
					if data.UnbiddenResetGameChance > 100 then
						data.UnbiddenResetGameChance = 100
					end
				end
			end
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, EclipsedMod.onItemWispDeath, EntityType.ENTITY_FAMILIAR)

function EclipsedMod:onInputAction(entity, _, buttonAction) -- entity, inputHook, buttonAction
	--- Disable bomb placing ability for Nadab & Abihu
	if entity and entity.Type == EntityType.ENTITY_PLAYER and not entity:IsDead() then
		local player = entity:ToPlayer()
		if (player:GetPlayerType() == enums.Characters.Nadab or player:GetPlayerType() == enums.Characters.Abihu) and buttonAction == ButtonAction.ACTION_BOMB then
			return false
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_INPUT_ACTION, EclipsedMod.onInputAction)

function EclipsedMod:onPlayerInit(player)
	--- mod chars Init
	local data = player:GetData()
	--local idx = functions.getPlayerIndex(player)

	if player:GetPlayerType() == enums.Characters.Nadab then -- nadab
		data.NadabCostumeEquipped = true
		player:AddNullCostume(datatables.NadabData.CostumeHead)
		if not player:HasCollectible(enums.Items.AbihuFam) then player:AddCollectible(enums.Items.AbihuFam, 0, true) end
	else
		if data.NadabCostumeEquipped then
			player:TryRemoveNullCostume(datatables.NadabData.CostumeHead)
			data.NadabCostumeEquipped = nil
			if player:HasCollectible(enums.Items.AbihuFam) then player:RemoveCollectible(enums.Items.AbihuFam) end
		end
	end

	if player:GetPlayerType() == enums.Characters.Abihu then -- nadab
		data.BlindAbihu = true
		functions.SetBlindfold(player, true)
		--data.AbihuCostumeEquipped = true
		--player:AddNullCostume(datatables.AbihuData.CostumeHead)
		if not player:HasCollectible(enums.Items.NadabBody) then player:AddCollectible(enums.Items.NadabBody) end
	else
		if data.BlindAbihu then
			data.BlindAbihu = nil
			functions.SetBlindfold(player, false)
		end
		if data.AbihuCostumeEquipped then
			player:TryRemoveNullCostume(datatables.AbihuData.CostumeHead)
			data.AbihuCostumeEquipped = nil
			if player:HasCollectible(enums.Items.NadabBody) then player:RemoveCollectible(enums.Items.NadabBody) end
		end
	end

	if player:GetPlayerType() == enums.Characters.UnbiddenB then
		data.UnbiddenBCostumeEquipped = true
		--player:AddNullCostume(datatables.UnbiddenBData.CostumeHead)
		data.BlindUnbidden = true
		functions.SetBlindfold(player, true)
		data.UnbiddenResetGameChance = data.UnbiddenResetGameChance or 100
	else
		if data.BlindUnbidden then
			data.BlindUnbidden = nil
			functions.SetBlindfold(player, false)
			if player:HasCollectible(enums.Items.Threshold) then player:RemoveCollectible(enums.Items.Threshold) end
		end
		if data.UnbiddenBCostumeEquipped then
			--player:TryRemoveNullCostume(datatables.UnbiddenBData.CostumeHead)
			data.UnbiddenBCostumeEquipped = nil
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, EclipsedMod.onPlayerInit)

function EclipsedMod:onCache4(player, cacheFlag)
	--- char stats
	player = player:ToPlayer()
	--local data = player:GetData()
	if player:GetPlayerType() == enums.Characters.Nadab then
		if cacheFlag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage * datatables.NadabData.Stats.DAMAGE
			if player:HasCollectible(CollectibleType.COLLECTIBLE_MR_MEGA) then
				player.Damage = player.Damage + player.Damage * datatables.NadabData.MrMegaDmgMultiplier
			end
		end
		if cacheFlag == CacheFlag.CACHE_FIREDELAY and player:HasCollectible(CollectibleType.COLLECTIBLE_SAD_BOMBS) then
			player.MaxFireDelay = player.MaxFireDelay + datatables.NadabData.SadBombsFiredelay
		end
		if cacheFlag == CacheFlag.CACHE_SPEED then
			player.MoveSpeed = player.MoveSpeed + datatables.NadabData.Stats.SPEED
			if player:HasCollectible(CollectibleType.COLLECTIBLE_FAST_BOMBS) and player.MoveSpeed < 1.0 then
				player.MoveSpeed = 1.0
			end
		end
		if cacheFlag == CacheFlag.CACHE_TEARFLAG and player:HasCollectible(CollectibleType.COLLECTIBLE_BOBBY_BOMB) then
			player.TearFlags = player.TearFlags | TearFlags.TEAR_HOMING
		end
	end

	if player:GetPlayerType() == enums.Characters.Abihu then
		if cacheFlag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage * datatables.AbihuData.Stats.DAMAGE
		end
		if cacheFlag == CacheFlag.CACHE_SPEED then
			player.MoveSpeed = player.MoveSpeed + datatables.AbihuData.Stats.SPEED
		end
	end

	if player:GetPlayerType() == enums.Characters.Unbidden then
		if cacheFlag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage * datatables.UnbiddenData.Stats.DAMAGE
		end
		if cacheFlag == CacheFlag.CACHE_LUCK then
			player.Luck = player.Luck + datatables.UnbiddenData.Stats.LUCK
		end
		if cacheFlag == CacheFlag.CACHE_TEARCOLOR then
			player.TearColor = datatables.UnbiddenBData.Stats.TEAR_COLOR --Color(0.5,1,2,1,0,0,0)
			player.LaserColor =  datatables.UnbiddenBData.Stats.LASER_COLOR
		end
	end

	if player:GetPlayerType() == enums.Characters.UnbiddenB then
		if cacheFlag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage * datatables.UnbiddenBData.Stats.DAMAGE
		end
		if cacheFlag == CacheFlag.CACHE_LUCK then
			player.Luck = player.Luck + datatables.UnbiddenBData.Stats.LUCK
		end
		if cacheFlag == CacheFlag.CACHE_TEARFLAG then
			player.TearFlags = player.TearFlags | datatables.UnbiddenBData.Stats.TRAR_FLAG

		end
		if cacheFlag == CacheFlag.CACHE_TEARCOLOR then
			player.TearColor = datatables.UnbiddenBData.Stats.TEAR_COLOR --Color(0.5,1,2,1,0,0,0)
			player.LaserColor =  datatables.UnbiddenBData.Stats.LASER_COLOR
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, EclipsedMod.onCache4)

function EclipsedMod:OnDetonatorUse(_,_, player) --item, rng, player
	---Nadab
	local data = player:GetData()
	if player:GetPlayerType() == enums.Characters.Nadab then
		data.ExCountdown = data.ExCountdown or 0
		if data.ExCountdown == 0 then
			data.ExCountdown = datatables.NadabData.ExplosionCountdown
			FcukingBomberman(player)
		end
	end
	---Nadab's Body
	if player:HasCollectible(enums.Items.NadabBody) then
		data.ExCountdown = data.ExCountdown or 0
		if data.ExCountdown == 0 then
			data.ExCountdown = datatables.NadabData.ExplosionCountdown
			local bodies = Isaac.FindByType(EntityType.ENTITY_BOMB, BombVariant.BOMB_DECOY)
			for _, body in pairs(bodies) do
				if body:GetData().bomby then
					FcukingBomberbody(player)
				end
			end
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_ITEM, EclipsedMod.OnDetonatorUse, CollectibleType.COLLECTIBLE_REMOTE_DETONATOR)

function EclipsedMod:use2ofClubs(_, player) -- card, player
	--- Nadab & Abihu replace 2ofClubs effect by 2ofHearts
	if player:GetPlayerType() == enums.Characters.Nadab or player:GetPlayerType() == enums.Characters.Abihu then
		player:AddBombs(-2)
		player:UseCard(Card.CARD_HEARTS_2, datatables.MyUseFlags_Gene)
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_CARD, EclipsedMod.use2ofClubs, Card.CARD_CLUBS_2)

function EclipsedMod:onBombsAreKey(_, player) -- pill, player
	--- Nadab & Abihu BombsAreKeys pill effect shifts hearts and keys
	if player:GetPlayerType() == enums.Characters.Nadab or player:GetPlayerType() == enums.Characters.Abihu then
		local player_keys = player:GetNumKeys()
		local player_hearts = player:GetHearts()
		player:AddHearts(player_keys-player_hearts)
        player:AddKeys(player_hearts-player_keys)
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_PILL, EclipsedMod.onBombsAreKey, PillEffect.PILLEFFECT_BOMBS_ARE_KEYS)

--- Threshold
function EclipsedMod:onThreshold(_, _, player)
	--- unbidden personal item: add item wisp or black rune
	if functions.AddItemFromWisp(player, true, true) then 
		local data = player:GetData()
		if player:GetPlayerType() == enums.Characters.UnbiddenB and not player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then 
			data.UnbiddenResetGameChance = data.UnbiddenResetGameChance or 100
			data.UnbiddenResetGameChance = data.UnbiddenResetGameChance -1 
		end
		return false 
	end
	player:UseCard(Card.RUNE_BLACK, datatables.MyUseFlags_Gene)
	return true
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_ITEM, EclipsedMod.onThreshold, enums.Items.Threshold)

function EclipsedMod:onItemCollision2(pickup, collider)
	--- unbidden item collision
	local level = game:GetLevel()
	local room = game:GetRoom()
	if pickup.Wait <= 0 and collider:ToPlayer() and functions.GetCurrentDimension() ~= 2 and level:GetCurrentRoomIndex() ~= GridRooms.ROOM_GENESIS_IDX and room:GetType() ~= RoomType.ROOM_BOSSRUSH and room:GetType() ~= RoomType.ROOM_CHALLENGE then --
		local player = collider:ToPlayer()
		if player:GetPlayerType() == enums.Characters.Unbidden or player:GetPlayerType() == enums.Characters.UnbiddenB then
			local wispIt = true
			
			if HeavensCall and functions.HeavensCall(room, level) then
				if pickup:GetData().Price then
					local brokens = pickup:GetData().Price.BROKEN
					player:AddBrokenHearts(brokens)
				end
			end
			
			if pickup.SubType == CollectibleType.COLLECTIBLE_SCHOOLBAG then
				return false
			end
			
			--[[
			if pickup.OptionsPickupIndex ~= 0 then
				local pickupOptionIndex = pickup.OptionsPickupIndex
				local choicePicups = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)
				
				if #choicePicups > 0 then
					for _, pkp in pairs(choicePicups) do
						pkp = pkp:ToPickup()
						if pkp.SubType ~= pickup.SubType and pkp.OptionsPickupIndex == pickupOptionIndex then
							pkp:Remove()
							for _ =1, 3 do
								player:AddWisp(pkp.SubType, pkp.Position)
							end
						end
					end
				end
				--[[
				if player:GetPlayerType() == enums.Characters.Unbidden then
					print('a')
				elseif player:GetPlayerType() == enums.Characters.UnbiddenB then
					local data = player:GetData()
					--data.LevelRewindCounter = data.LevelRewindCounter or 0
					--data.UnbiddenResetGameChance = data.UnbiddenResetGameChance or 100
					--data.UnbiddenResetGameChance = data.UnbiddenResetGameChance - datatables.UnbiddenBData.OptionPrice
				end
				--]
			end
			--]]
			
			if pickup:IsShopItem() then
				if pickup.Price >= 0 then
					if player:GetNumCoins() >= pickup.Price then
						player:AddCoins(-pickup.Price)
					else
						wispIt = false
					end
				else
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
							local data = player:GetData()
							data.UnbiddenResetGameChance = data.UnbiddenResetGameChance or 100
							data.UnbiddenResetGameChance = data.UnbiddenResetGameChance - datatables.UnbiddenBData.DevilPrice
						end
					end
				end
			end
			
			
			if wispIt then --or pickup.SubType == CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES
				if pickup.SubType == 0  or functions.CheckItemTags(pickup.SubType, ItemConfig.TAG_QUEST) or pickup.SubType == CollectibleType.COLLECTIBLE_BIRTHRIGHT then
					return
				else
					local wisp = player:AddItemWisp(pickup.SubType, pickup.Position, true)

					if wisp then
						wisp = wisp:ToFamiliar()
						wisp.HitPoints = datatables.UnbiddenData.WispHP
						sfx:Play(SoundEffect.SOUND_SOUL_PICKUP)
						--pickup.SubType = 0
						--pickup:Update()
						pickup:Remove()
						return false
					end
					return
				end
			end
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, EclipsedMod.onItemCollision2, PickupVariant.PICKUP_COLLECTIBLE)


function EclipsedMod:onHeartCollision2(pickup, collider, _)
	--- unbidden collision with hearts, if he has bone hearts
	if collider:ToPlayer() and collider:ToPlayer():GetPlayerType() == enums.Characters.Unbidden then 
		local player = collider:ToPlayer()
		if (player:CanPickRedHearts() or player:CanPickRottenHearts()) then
			if pickup.SubType == HeartSubType.HEART_BLENDED then
				player:SetFullHearts()
			elseif (pickup.SubType == HeartSubType.HEART_FULL or pickup.SubType == HeartSubType.HEART_HALF or pickup.SubType == HeartSubType.HEART_DOUBLEPACK or pickup.SubType == HeartSubType.HEART_SCARED or pickup.SubType == HeartSubType.HEART_BLENDED or pickup.SubType == HeartSubType.HEART_ROTTEN) then
				return false
			end
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, EclipsedMod.onHeartCollision2, PickupVariant.PICKUP_HEART)


function functions.ActiveItemText(text)
	StoneFont:DrawString("x" .. text, 30 + Options.HUDOffset * 24 , Options.HUDOffset *10, KColor(1 ,1 ,1 ,1), 0, true)
end


-- UI update
function EclipsedMod:onUnbiddenTextRender() --pickup, collider, low
	local player = Isaac.GetPlayer(0)
	local data = player:GetData()
	--local level = game:GetLevel()
	if player:GetPlayerType() == enums.Characters.UnbiddenB then
		
		--[[
		data.UnbiddenUsedHolyCard = data.UnbiddenUsedHolyCard or 0
		Isaac.RenderText('counter '..data.UnbiddenUsedHolyCard, 160 + Options.HUDOffset * 24 , 50 + Options.HUDOffset *10, 1 ,1 ,1 ,1 )
		Isaac.RenderText('mantles '..player:GetEffects():GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_HOLY_MANTLE), 160 + Options.HUDOffset * 24 , 60 + Options.HUDOffset *10, 1 ,1 ,1 ,1 )
		--]]
		
		data.UnbiddenResetGameChance = data.UnbiddenResetGameChance or 100
		data.LevelRewindCounter = data.LevelRewindCounter or 1
		local pos = Vector(70, 30) + Options.HUDOffset*Vector(24, 12)
		UnbiddenHourglassIcon:Render(pos)
		UnbiddenHourglassFont:DrawString(data.UnbiddenResetGameChance.. "%", 82 + Options.HUDOffset * 24 , 5 + Options.HUDOffset *10, KColor(1 ,1 ,1 ,1), 0, true)
		if data.LevelRewindCounter > 1 then
			UnbiddenHourglassFont:DrawString("-"..data.LevelRewindCounter.. "%", 120 + Options.HUDOffset * 24 , 5 + Options.HUDOffset *10, KColor(1 ,1 ,1 ,1), 0, true)
		end
		--Isaac.RenderText(data.UnbiddenResetGameChance.. "%", 82 + Options.HUDOffset * 24 , 5 + Options.HUDOffset *10, 1 ,1 ,1 ,1 )
	end
	
	for playerNum = 0, game:GetNumPlayers()-1 do
		local player = game:GetPlayer(playerNum)
		data = player:GetData()
		
		
		if data.CorruptionIsActive then
			StoneFont:DrawString("x" .. data.CorruptionIsActive, 3 + Options.HUDOffset * 24 , 22 + Options.HUDOffset *10, KColor(1 ,0 ,1 ,1), 0, true)
		end
		
		
		if player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == enums.Items.StoneScripture then 
			local uses = 3
			if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) then 
				uses = 6 
			end
			
			data.UsedStoneScripture = data.UsedStoneScripture or uses
			functions.ActiveItemText(data.UsedStoneScripture)
		elseif player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == enums.Items.NirlyCodex then 
			if data.NirlySavedCards and #data.NirlySavedCards > 0 then
				functions.ActiveItemText(#data.NirlySavedCards)
			end
		elseif player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == enums.Items.TomeDead then 
			--data.CollectedSouls = data.CollectedSouls or 0
			if data.CollectedSouls then
				StoneFont:DrawString("x" .. data.CollectedSouls, 26 + Options.HUDOffset * 24 , 26 + Options.HUDOffset *10, KColor(1 ,1 ,1 ,1), 0, true)
			end	
			
		end
		
		
		if player:HasCollectible(enums.Items.NirlyCodex) and data.NirlySavedCards and #data.NirlySavedCards > 0 then
			local offset = 0.2
			local scale = 0.5
			local color = 0
			--local step_x = 0
			if Input.IsActionPressed(ButtonAction.ACTION_MAP, player.ControllerIndex) then
				offset = 1
				scale = 1
				color = 1
				--step_x = 8
			end
			
			local pos = Vector(Isaac.GetScreenWidth(),Isaac.GetScreenHeight()) - Vector(10, 12) - (Options.HUDOffset*Vector(16, 6))
			
			NirlyCardsFont:DrawStringScaled("Nirly's Collection:", 15 + Options.HUDOffset * 24 , Isaac.GetScreenHeight()-90 -1 * scale + Options.HUDOffset *10, scale, scale, KColor(1 ,1 ,1 ,offset), 0, true)
			UnbiddenHourglassIcon.Scale = Vector(0.5,0.5)
			for index, card in pairs(data.NirlySavedCards) do
				local cardConf = Isaac.GetItemConfig():GetCard(card)
				local card_name = cardConf.Name
				NirlyCardsFont:DrawStringScaled(card_name, 15 + Options.HUDOffset * 24 , Isaac.GetScreenHeight()-90 + index * 10 * scale + Options.HUDOffset *10, scale, scale, KColor(1 ,1 ,1 ,offset), 0, true)
			end
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_POST_RENDER, EclipsedMod.onUnbiddenTextRender)
--]]


function EclipsedMod:onPlayerRender(player) --renderOffset
	--- render abihu and unbidden charge bar
	local data = player:GetData()
	if Options.ChargeBars and not player:IsDead() then
		if player:GetPlayerType() == enums.Characters.UnbiddenB and (data.UnbiddenFullCharge or data.UnbiddenSemiCharge) and data.BlindUnbidden and not data.HoldingWeapon then -- and not data.TechLudo
			functions.RenderChargeManager(player, data.UnbiddenBDamageDelay, datatables.UnbiddenBData.ChargeBar, (datatables.UnbiddenBData.DamageDelay + math.floor(player.MaxFireDelay)))
		elseif player:GetPlayerType() == enums.Characters.Abihu and (player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) or data.AbihuIgnites) then
			functions.RenderChargeManager(player, data.AbihuDamageDelay, datatables.AbihuData.ChargeBar, (datatables.AbihuData.DamageDelay + math.floor(player.MaxFireDelay)))
		end
		if player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == enums.Items.HeartTransplant and data.HeartTransplantActualCharge and data.HeartTransplantActualCharge > 0 then
			functions.RenderChargeManager(player, data.HeartTransplantActualCharge, datatables.HeartTransplant.ChargeBar,
			Isaac.GetItemConfig():GetCollectible(enums.Items.HeartTransplant).MaxCharges, 0, -42)
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, EclipsedMod.onPlayerRender)

function EclipsedMod:onPlayerTakeDamage(entity, _, flags) --entity, amount, flags, source, countdown
	--- abihu drops nadab when you take damage, so set holding to -1
	local player = entity:ToPlayer()
	if player:GetPlayerType() == enums.Characters.Nadab and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and (flags & DamageFlag.DAMAGE_FIRE == DamageFlag.DAMAGE_FIRE or flags & DamageFlag.DAMAGE_EXPLOSION == DamageFlag.DAMAGE_EXPLOSION or flags & DamageFlag.DAMAGE_TNT == DamageFlag.DAMAGE_TNT) then
		return false
	elseif player:GetPlayerType() == enums.Characters.Abihu then
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and (flags & DamageFlag.DAMAGE_FIRE == DamageFlag.DAMAGE_FIRE or flags & DamageFlag.DAMAGE_EXPLOSION == DamageFlag.DAMAGE_EXPLOSION or flags & DamageFlag.DAMAGE_TNT == DamageFlag.DAMAGE_TNT) then
			return false
		end
		local data = entity:GetData()
		data.AbihuIgnites = true
		if not data.AbihuCostumeEquipped then
			data.AbihuCostumeEquipped = true
			player:AddNullCostume(datatables.AbihuData.CostumeHead)
		end
		data.HoldBomd = -1
	--elseif player:GetPlayerType() == enums.Characters.UnbiddenB then
		
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, EclipsedMod.onPlayerTakeDamage, EntityType.ENTITY_PLAYER)

function EclipsedMod:onItemUse(_, _, player)
	--- abihu drops nadab when you use item, so set holding to -1
	if player:GetPlayerType() == enums.Characters.Abihu then
		local data = player:GetData()
		data.HoldBomd = -1
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_USE_ITEM, EclipsedMod.onItemUse)

--- WIP
function EclipsedMod:onAbihuFlame(flame)
	if flame:GetData().AbihuFlame and flame.Parent then
		local flameData = flame:GetData()
		local player = flame.Parent:ToPlayer()
		local tearFlags = player.TearFlags

		if flame.FrameCount == 1 then
			if tearFlags & TearFlags.TEAR_BURN == TearFlags.TEAR_BURN or player:HasCollectible(CollectibleType.COLLECTIBLE_FIRE_MIND) then
				flame.Color = Color(-1,-1,-1,1,1,1,1)
				flameData.Burn = flameData.Burn or true
			end
			if tearFlags & TearFlags.TEAR_POISON == TearFlags.TEAR_POISON or player:HasCollectible(CollectibleType.COLLECTIBLE_COMMON_COLD) or player:HasCollectible(CollectibleType.COLLECTIBLE_IPECAC) or player:HasCollectible(CollectibleType.COLLECTIBLE_COMMON_COLD) then
				flame.Color = Color(0, 1, 0, 1, 0,1,0)
				flameData.Poison = flameData.Poison or true
			end
			if tearFlags & TearFlags.TEAR_SLOW == TearFlags.TEAR_SLOW or player:HasCollectible(CollectibleType.COLLECTIBLE_SPIDER_BITE) then
				flame.Color = Color(1,1,1,1,0.5,0.5,0.5)
				flameData.Slow = flameData.Slow or Color(2,2,2,1,0.196,0.196,0.196)
			elseif player:HasCollectible(CollectibleType.COLLECTIBLE_BALL_OF_TAR) then
				--flame.Color = Color(-1,-1,-1,1,1,1,1)
				flameData.Slow = flameData.Slow or Color(0.15, 0.15, 0.15, 1, 0, 0, 0)
			end
			if tearFlags & TearFlags.TEAR_MIDAS == TearFlags.TEAR_MIDAS or player:HasCollectible(CollectibleType.COLLECTIBLE_MIDAS_TOUCH) then
				flame.Color = Color(2, 1, 0, 1, 2,1,0)
				flameData.Midas = flameData.Midas or true
			end
			if tearFlags & TearFlags.TEAR_FEAR == TearFlags.TEAR_FEAR or player:HasCollectible(CollectibleType.COLLECTIBLE_ABADDON) or player:HasCollectible(CollectibleType.COLLECTIBLE_DARK_MATTER) or player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_PERFUME) then
				flame.Color = Color(-10, -10, -10, 1, 1, 1, 1)
				flameData.Fear = flameData.Fear or true
			end
			if tearFlags & TearFlags.TEAR_CHARM == TearFlags.TEAR_CHARM or player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_EYESHADOW) then
				flame.Color = Color(0.4, 0.15, 0.38, 1, 1, 0.1, 0.3)
				flameData.Charm = flameData.Charm or true
			end
			if tearFlags & TearFlags.TEAR_CONFUSION == TearFlags.TEAR_CONFUSION  or player:HasCollectible(CollectibleType.COLLECTIBLE_IRON_BAR) or player:HasCollectible(CollectibleType.COLLECTIBLE_GLAUCOMA) or player:HasCollectible(CollectibleType.COLLECTIBLE_KNOCKOUT_DROPS) then
				
				flameData.Confusion = flameData.Confusion or true
			end
			if tearFlags & TearFlags.TEAR_FREEZE == TearFlags.TEAR_FREEZE or player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_CONTACTS) then
				flame.Color = Color(0, 0, 0, 1, 0.5, 0.5, 0.5)
				flameData.Freeze = flameData.Freeze or true
			end
			if tearFlags & TearFlags.TEAR_ICE == TearFlags.TEAR_ICE or player:HasCollectible(CollectibleType.COLLECTIBLE_URANUS) then
				flame.Color = Color(1, 1, 1, 1, 0, 0, 0)
				flameData.Ice = flameData.Ice or true
			end
			if tearFlags & TearFlags.TEAR_BAIT == TearFlags.TEAR_BAIT or player:HasCollectible(CollectibleType.COLLECTIBLE_ROTTEN_TOMATO) then
				flame.Color = Color(0.7, 0.14, 0.1, 1, 1, 0, 0)
				flameData.Baited = flameData.Baited or true
			end
			if tearFlags & TearFlags.TEAR_MAGNETIZE == TearFlags.TEAR_MAGNETIZE or player:HasCollectible(CollectibleType.COLLECTIBLE_LODESTONE) then
				flameData.Magnetize = flameData.Magnetize or true
			end
			if tearFlags & TearFlags.TEAR_RIFT == TearFlags.TEAR_RIFT or player:HasCollectible(CollectibleType.COLLECTIBLE_OCULAR_RIFT) then
				flame.Color = Color(-2, -2, -2, 1, 1, 1, 1)
				flameData.Rift = flameData.Rift or true
			end

			--[[
			if tearFlags & TearFlags.TEAR_BOOMERANG == TearFlags.TEAR_BOOMERANG then
				flameData.Boomerang = flameData.Boomerang or true
			end
			if tearFlags & TearFlags.TEAR_MULLIGAN == TearFlags.TEAR_MULLIGAN then
				flameData.Mulligan = flameData.Mulligan or true
			end
			if tearFlags & TearFlags.TEAR_WAIT == TearFlags.TEAR_WAIT then
				flameData.Wait = flameData.Wait or true
			end
			if tearFlags & TearFlags.TEAR_SPLIT == TearFlags.TEAR_SPLIT then
				flame.Color = Color(0.9, 0.3, 0.08, 1)
				flameData.Split = flameData.Split or true
			end
			if tearFlags & TearFlags.TEAR_QUADSPLIT == TearFlags.TEAR_QUADSPLIT then
				flameData.Quadsplit = flameData.Quadsplit or true
			end
			if tearFlags & TearFlags.TEAR_SPECTRAL == TearFlags.TEAR_SPECTRAL then
				flameData.Spectral = flameData.Spectral or true
			end
			--]]
			if tearFlags & TearFlags.TEAR_HOMING == TearFlags.TEAR_HOMING then
				flame.Color = Color(0.4, 0.15, 0.38, 1, 1, 0.1, 1)
				flameData.Homing = flameData.Homing or true
			end
		end
		if flameData.Homing then
			local nearestNPC = functions.GetNearestEnemy(flame.Position, 120)
			flame:AddVelocity((nearestNPC - flame.Position):Resized(1.3))
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, EclipsedMod.onAbihuFlame, EffectVariant.BLUE_FLAME)

function EclipsedMod:onAbihuFlameDamage(entity, _, _, source, _)
	if entity:IsVulnerableEnemy() and entity:IsActiveEnemy() and source.Entity and source.Entity:ToEffect() then
		local flame = source.Entity:ToEffect()
		if flame.Variant == EffectVariant.BLUE_FLAME and flame:GetData().AbihuFlame then
			local ppl = flame.Parent:ToPlayer()
			local flameData = flame:GetData()
			local duration = 52
			if flameData.Burn then entity:AddBurn(EntityRef(ppl), duration, 2*ppl.Damage) end
			if flameData.Poison then entity:AddPoison(EntityRef(ppl), duration, 2*ppl.Damage) end
			if flameData.Charm then entity:AddCharmed(EntityRef(ppl), duration) end
			if flameData.Freeze then entity:AddFreeze(EntityRef(ppl), duration) end
			if flameData.Slow then entity:AddSlowing(EntityRef(ppl), duration, 0.5, flameData.Slow) end
			if flameData.Midas then entity:AddMidasFreeze(EntityRef(ppl), duration) end
			if flameData.Confusion then entity:AddConfusion(EntityRef(ppl), duration, false) end
			if flameData.Fear then entity:AddFear(EntityRef(ppl), duration) end
			if flameData.Rift then
				flameData.Rift = false
				local rift = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RIFT, 0, entity.Position, Vector.Zero, ppl):ToEffect()
				rift:SetTimeout(60)
			end
			if flameData.Magnetize then
				entity:AddEntityFlags(EntityFlag.FLAG_MAGNETIZED)
				entity:GetData().Magnetized = duration
			end
			if flameData.Baited then
				entity:AddEntityFlags(EntityFlag.FLAG_BAITED)
				entity:GetData().BaitedTomato = duration
			end
			if entity:HasMortalDamage() then
				if flameData.Ice then entity:AddEntityFlags(EntityFlag.FLAG_ICE) end
			end
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, EclipsedMod.onAbihuFlameDamage)
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
--- SLOT / BEGGARS SPAWN--
function EclipsedMod:onEntSpawn(entType, var, _, _, _, _, seed)
	if Isaac.GetChallenge() == enums.Challenges.MongoFamily and entType == EntityType.ENTITY_SLOT then
		return {entType, enums.Slots.MongoBeggar, 0}
	elseif entType == EntityType.ENTITY_SLOT and var == 4 then --datatables.ReplaceBeggarVariants[var] then
		local rng = RNG()
		rng:SetSeed(seed, RECOMMENDED_SHIFT_IDX)
		--if myrng:RandomFloat() <= datatables.GlitchBeggar.ReplaceChance then
		--	return {entType, enums.Slots.GlitchBeggar, 0, seed}
		--else
		local savetable = functions.modDataLoad()
		if savetable.CompletionMarks.Challenges.lobotomy > 0 and rng:RandomFloat() <= datatables.DeliriumBeggar.ReplaceChance then
			return {entType, enums.Slots.DeliriumBeggar, 0}
		elseif rng:RandomFloat() <= datatables.MongoBeggar.ReplaceChance then
			return {entType, enums.Slots.MongoBeggar, 0}
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, EclipsedMod.onEntSpawn)
--- SLOT / BEGGARS LOGIC --
function EclipsedMod:peffectUpdateBeggars(player)
	local level = game:GetLevel()
	local mongoBeggars = Isaac.FindByType(EntityType.ENTITY_SLOT, enums.Slots.MongoBeggar)
	local deliriumBeggars = Isaac.FindByType(EntityType.ENTITY_SLOT, enums.Slots.DeliriumBeggar)
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
			if sprite:IsFinished("Prize") then -- give reward
				sfx:Play(SoundEffect.SOUND_SLOTSPAWN)
				local spawnpos = Isaac.GetFreeNearPosition(beggar.Position, 35)
				if randNum <= datatables.MongoBeggar.PrizeChance then --Spawn Boss
					sprite:Play("Teleport")
					datatables.DeliriousBumCharm = player
					player:UseActiveItem(CollectibleType.COLLECTIBLE_DELIRIOUS, datatables.MyUseFlags_Gene)
					level:SetStateFlag(LevelStateFlag.STATE_BUM_LEFT, true)
				else -- spawn delirious pickup or spawn charmed enemy
					sprite:Play("Idle")
					if randNum <= datatables.DeliriumBeggar.DeliPickupChance then
						functions.DebugSpawn(300, datatables.DeliObject.Variants[rng:RandomInt(#datatables.DeliObject.Variants)+1], spawnpos)
					else
						datatables.DeliriumBeggarEnemies = datatables.DeliriumBeggarEnemies or {EntityType.ENTITY_GAPER, 0}
						local savedOnes = datatables.DeliriumBeggarEnemies[rng:RandomInt(#datatables.DeliriumBeggarEnemies)+1]
						local npc = Isaac.Spawn(savedOnes[1], savedOnes[2], 0, spawnpos, Vector.Zero, player):ToNPC()
						npc:AddCharmed(EntityRef(player), -1)
					end
				end
			end

			if sprite:IsFinished("Teleport") then
				beggar:Remove()
			else
				if beggar.Position:Distance(player.Position) <= 20 then -- 20 distance where you definitely touch beggar
					if sprite:IsPlaying("Idle") and player:GetNumCoins() > 0 then
						player:AddCoins(-1)
						sfx:Play(SoundEffect.SOUND_SCAMPER)
						if beggarData.PityCounter >= datatables.DeliriumBeggar.PityCounter or rng:RandomFloat() < datatables.DeliriumBeggar.ActivateChance then
							sprite:Play("PayPrize")
							beggarData.PityCounter = 0
						else
							sprite:Play("PayNothing")
							beggarData.PityCounter = beggarData.PityCounter + 1
						end
					end
				end
				if functions.BeggarWasBombed(beggar, true) then
					beggar:Remove()
					game:ShowHallucination(5, BackdropType.NUM_BACKDROPS)
					functions.DebugSpawn(300, datatables.DeliObject.Variants[rng:RandomInt(#datatables.DeliObject.Variants)+1], beggar.Position, 0, RandomVector()*5)
				end
			end
		end
	end
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
				if randNum <= datatables.MongoBeggar.PrizeChance then --Spawn item
					local spawnpos = Isaac.GetFreeNearPosition(beggar.Position, 35)
					sprite:Play("Teleport")
					functions.DebugSpawn(100, CollectibleType.COLLECTIBLE_MONGO_BABY, spawnpos)
					level:SetStateFlag(LevelStateFlag.STATE_BUM_LEFT, true)
				else
					player:UseActiveItem(CollectibleType.COLLECTIBLE_MONSTER_MANUAL, datatables.MyUseFlags_Gene)
					if sfx:IsPlaying(SoundEffect.SOUND_SATAN_GROW) then sfx:Stop(SoundEffect.SOUND_SATAN_GROW) end -- stop devil laughs
					beggarData.PrizeCounter = beggarData.PrizeCounter + 1
					if beggarData.PrizeCounter >= datatables.MongoBeggar.PrizeCounter then
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
				if beggar.Position:Distance(player.Position) <= 20 then -- 20 distance where you definitely touch beggar
					if sprite:IsPlaying("Idle") and player:GetNumCoins() > 0 then
						player:AddCoins(-1)
						sfx:Play(SoundEffect.SOUND_SCAMPER)
						if beggarData.PityCounter >= datatables.MongoBeggar.PityCounter or rng:RandomFloat() < datatables.MongoBeggar.ActivateChance then
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
end
EclipsedMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, EclipsedMod.peffectUpdateBeggars)

---UNLOCKS
---ACHIEVEMENT DISPLAY (from Sodom and Gomorrah)
local GamePause = nil
local GamePauseAtFrame = nil
local GamePauseDuration = 0
local GameUnpauseForce = nil
local AchivementQueue = {}
local AchivementUpdate = false
local AchivementRender = false
local AchivementSprite = Sprite()
AchivementSprite:Load("gfx/ui/achievement/eclipsed_achievements.anm2", true)

local function PauseGame(frames)
	if game:GetRoom():GetBossID() ~= 54 then -- Intenionally fail on Lamb, since it breaks the Victory Lap menu super hard
		GamePauseAtFrame = GamePauseAtFrame or game:GetFrameCount()
		GamePauseDuration = GamePauseDuration + frames
		GamePause = true
		Isaac.GetPlayer():UseActiveItem(CollectibleType.COLLECTIBLE_PAUSE, datatables.MyUseFlags_Gene)
	end
end

local function QueueAchievementNote(gfx) -- call when achievement unlocked
	table.insert(AchivementQueue, gfx)
end

local function PlayAchievementNote(gfx)
	PauseGame(41)
	--game:GetHUD():ShowFortuneText(gfx)
	AchivementSprite:ReplaceSpritesheet(2, gfx)
	AchivementSprite:LoadGraphics()
	AchivementSprite:Play("Idle", true)
	AchivementUpdate = false
	AchivementRender = true
	sfx:Play(SoundEffect.SOUND_CHOIR_UNLOCK)
end

function EclipsedMod:onInputAction1(_, inputHook, action)
	if inputHook == InputHook.IS_ACTION_PRESSED or inputHook == InputHook.IS_ACTION_TRIGGERED then
		if GamePause and action ~= ButtonAction.ACTION_CONSOLE then
			return false
		elseif GameUnpauseForce and action == ButtonAction.ACTION_SHOOTDOWN then
			GameUnpauseForce = false
			return true
		end
	elseif inputHook == InputHook.GET_ACTION_VALUE and GamePause and action ~= ButtonAction.ACTION_CONSOLE then
		return 0
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_INPUT_ACTION, EclipsedMod.onInputAction1)

function EclipsedMod:onUpdate1()
	if GamePauseAtFrame and GamePauseAtFrame + GamePauseDuration < game:GetFrameCount() then
		GamePause = false
		GamePauseAtFrame = nil
		GamePauseDuration = 0
		GameUnpauseForce = true
	end
	if not AchivementRender and  #AchivementQueue > 0 then
		PlayAchievementNote(AchivementQueue[1])
		table.remove(AchivementQueue, 1)
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_POST_UPDATE, EclipsedMod.onUpdate1)

function EclipsedMod:onRender()
	if AchivementRender then
		if AchivementUpdate then AchivementSprite:Update() end
		AchivementUpdate = not AchivementUpdate
		local position = Vector(Isaac.GetScreenWidth() / 2, Isaac.GetScreenHeight() / 2)
		AchivementSprite:Render(position, Vector.Zero, Vector.Zero)
		if AchivementSprite:IsFinished() then AchivementRender = false end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_POST_RENDER, EclipsedMod.onRender)

---COMPLETION MARKS (from Andromeda)
local LockedItems = {
	[enums.Items.DiceBombs] = {"Nadab", 1, {"isaac"}},
	[enums.Items.DeadBombs] = {"Nadab", 1, {"bbaby"}},
	[enums.Items.GravityBombs] = {"Nadab", 1, {"satan"}},
	[enums.Items.FrostyBombs] = {"Nadab", 1, {"lamb"}},
	[enums.Items.Pyrophilia] = {"Nadab", 1, {"greed"}},
	[enums.Items.BatteryBombs] = {"Nadab", 2, {"greed"}},
	[enums.Items.CompoBombs] = {"Nadab", 1, {"beast"}},
	[enums.Items.MirrorBombs] = {"Nadab", 1, {"deli"}},
	[enums.Items.RedButton] = {"Nadab", 1,{"rush"}},
	[enums.Items.MeltedCandle] = {"Abihu", 1, {"mother"}},
	[enums.Items.IvoryOil] = {"Abihu", 1, {"beast"}},
	[enums.Items.NadabBrain] = {"Abihu", 1, {"deli"}},
	[enums.Items.NadabBody] = {"Abihu", 1, {"deli"}},
	--[enums.Items.EyeKey] = {"Abihu", 2, {"all"}},
	--[enums.Items.EyeKeyClosed] = {"Abihu", 2, {"all"}},
	[enums.Items.VoidKarma] = {"Unbidden", 1, {"isaac"}},
	[enums.Items.VHSCassette] = {"Unbidden", 1, {"lamb"}},
	[enums.Items.LongElk] = {"Unbidden", 1, {"satan"}},
	[enums.Items.RubberDuck] = {"Unbidden", 1, {"bbaby"}},
	[enums.Items.BlackKnight] = {"Unbidden", 1, {"hush"}},
	[enums.Items.WhiteKnight] = {"Unbidden", 1, {"hush"}},
	[enums.Items.MidasCurse] = {"Unbidden", 1, {"greed"}},
	[enums.Items.Lililith] = {"Unbidden", 2, {"greed"}},
	[enums.Items.RedMirror] = {"Unbidden", 1, {"mother"}},
	[enums.Items.Limb] = {"Unbidden", 1, {"beast"}},
	[enums.Items.RedLotus] = {"Unbidden", 1, {"deli"}},
	[enums.Items.Eclipse] = {"UnbiddenB", 1, {"deli"}},
	[enums.Items.RedBag] = {"UnbiddenB", 1, {"beast"}},
	[enums.Items.FloppyDisk] = {"UnbiddenB", 2, {"all"}},
	[enums.Items.FloppyDiskFull] = {"UnbiddenB", 2, {"all"}},
	[enums.Items.MewGen] = {"Challenges", 1, {"magician"}},
	--[enums.Items.LastWill] = {"Challenges", 1, {"shovel"}},
}

local LockedTrinkets = {
	[enums.Trinkets.BobTongue] = {"Nadab", 1, {"mother"}},
	[enums.Trinkets.RedScissors] = {"Abihu", 1, {"isaac", "bbaby", "satan", "lamb"}},
	[enums.Trinkets.Duotine] = {"UnbiddenB", 1, {"mega"}},
	[enums.Trinkets.WitchPaper] = {"UnbiddenB", 1, {"isaac", "bbaby", "satan", "lamb"}},
	[enums.Trinkets.Cybercutlet] = {"Challenges", 1, {"potato"}},
	[enums.Trinkets.GildedFork] = {"Challenges", 1, {"beatmaker"}},
	[enums.Trinkets.GoldenEgg] = {"Challenges", 1, {"mongofamily"}},
}

local LockedCards = {
	[enums.Pickups.KingChess] = {"Nadab", 1, {"hush"}},
	[enums.Pickups.KingChessW] = {"Nadab", 1, {"hush"}},
	[enums.Pickups.Domino34] = {"Nadab", 1, {"mega"}},
	[enums.Pickups.Domino25] = {"Nadab", 1, {"mega"}},
	[enums.Pickups.Domino16] = {"Nadab", 1, {"mega"}},
	[enums.Pickups.Domino00] = {"Nadab", 1, {"mega"}},
	[enums.Pickups.SoulNadabAbihu] = {"Abihu", 1, {"rush", "hush"}},
	[enums.Pickups.AscenderBane] = {"Abihu", 2, {"greed"}},
	[enums.Pickups.Decay] = {"Abihu", 2, {"greed"}},
	[enums.Pickups.Wish] = {"Abihu", 2, {"greed"}},
	[enums.Pickups.InfiniteBlades] = {"Abihu", 2, {"greed"}},
	[enums.Pickups.Offering] = {"Abihu", 2, {"greed"}},
	[enums.Pickups.Transmutation] = {"Abihu", 2, {"greed"}},
	[enums.Pickups.Fusion] = {"Abihu", 2, {"greed"}},
	[enums.Pickups.MultiCast] = {"Abihu", 2, {"greed"}},
	[enums.Pickups.RitualDagger] = {"Abihu", 2, {"greed"}},
	[enums.Pickups.DeuxEx] = {"Abihu", 2, {"greed"}},
	[enums.Pickups.Corruption] = {"Abihu", 2, {"greed"}},
	[enums.Pickups.Adrenaline] = {"Abihu", 2, {"greed"}},
	[enums.Pickups.Apocalypse] = {"Unbidden", 1, {"rush"}},
	[enums.Pickups.Trapezohedron] = {"UnbiddenB", 1, {"mother"}},
	[enums.Pickups.RedPill] = {"UnbiddenB", 1, {"mega"}},
	[enums.Pickups.RedPillHorse] = {"UnbiddenB", 1, {"mega"}},
	[enums.Pickups.SoulUnbidden] = {"UnbiddenB", 1, {"rush", "hush"}},
	[enums.Pickups.OblivionCard] = {"UnbiddenB", 2, {"greed"}},
	[enums.Pickups.BattlefieldCard] = {"UnbiddenB", 2, {"greed"}},
	[enums.Pickups.BookeryCard] = {"UnbiddenB", 2, {"greed"}},
	[enums.Pickups.TreasuryCard] = {"UnbiddenB", 2, {"greed"}},
	[enums.Pickups.BloodGroveCard] = {"UnbiddenB", 2, {"greed"}},
	[enums.Pickups.StormTempleCard] = {"UnbiddenB", 2, {"greed"}},
	[enums.Pickups.ZeroMilestoneCard] = {"UnbiddenB", 2, {"greed"}},
	[enums.Pickups.MazeMemoryCard] = {"UnbiddenB", 2, {"greed"}},
	[enums.Pickups.CryptCard] = {"UnbiddenB", 2, {"greed"}},
	[enums.Pickups.OutpostCard] = {"UnbiddenB", 2, {"greed"}},
	[enums.Pickups.ArsenalCard] = {"UnbiddenB", 2, {"greed"}},
	[enums.Pickups.DeliObjectCell] = {"Challenges", 1, {"lobotomy"}},
	[enums.Pickups.DeliObjectBomb] = {"Challenges", 1, {"lobotomy"}},
	[enums.Pickups.DeliObjectKey] = {"Challenges", 1, {"lobotomy"}},
	[enums.Pickups.DeliObjectCard] = {"Challenges", 1, {"lobotomy"}},
	[enums.Pickups.DeliObjectPill] = {"Challenges", 1, {"lobotomy"}},
	[enums.Pickups.DeliObjectRune] = {"Challenges", 1, {"lobotomy"}},
	[enums.Pickups.DeliObjectHeart] = {"Challenges", 1, {"lobotomy"}},
	[enums.Pickups.DeliObjectCoin] = {"Challenges", 1, {"lobotomy"}},
	[enums.Pickups.DeliObjectBattery] = {"Challenges", 1, {"lobotomy"}},
	
	[enums.Pickups.CemeteryCard] = {"UnbiddenB", 2, {"greed"}},
	[enums.Pickups.VillageCard] = {"UnbiddenB", 2, {"greed"}},
	[enums.Pickups.GroveCard] = {"UnbiddenB", 2, {"greed"}},
	[enums.Pickups.WheatFieldsCard] = {"UnbiddenB", 2, {"greed"}},
	[enums.Pickups.RuinsCard] = {"UnbiddenB", 2, {"greed"}},
	[enums.Pickups.SwampCard] = {"UnbiddenB", 2, {"greed"}},
	[enums.Pickups.SpiderCocoonCard] = {"UnbiddenB", 2, {"greed"}},
	[enums.Pickups.RoadLanternCard] = {"UnbiddenB", 2, {"greed"}},
	[enums.Pickups.VampireMansionCard] = {"UnbiddenB", 2, {"greed"}},
	[enums.Pickups.SmithForgeCard] = {"UnbiddenB", 2, {"greed"}},
	[enums.Pickups.ChronoCrystalsCard] = {"UnbiddenB", 2, {"greed"}},
	[enums.Pickups.WitchHut] = {"UnbiddenB", 2, {"greed"}},
	[enums.Pickups.BeaconCard] = {"UnbiddenB", 2, {"greed"}},
	[enums.Pickups.TemporalBeaconCard] = {"UnbiddenB", 2, {"greed"}},
}

local LockedPapers = {
	Nadab = {
		isaac = "gfx/ui/achievement/DiceBombs.png", bbaby = "gfx/ui/achievement/DeadBombs.png",
		satan = "gfx/ui/achievement/GravityBombs.png", lamb = "gfx/ui/achievement/FrostyBombs.png",
		rush = "gfx/ui/achievement/RedButton.png", hush = "gfx/ui/achievement/KingChess.png",
		deli = "gfx/ui/achievement/MirrorBombs.png",
		greed = "gfx/ui/achievement/Pyrophilia.png", greed2 = "gfx/ui/achievement/BatteryBombs.png",
		mother = "gfx/ui/achievement/BobTongue.png", beast = "gfx/ui/achievement/CompoBombs.png",
	},
	Abihu = {
		isaacsatan = "gfx/ui/achievement/RedScissors.png",
		hushrush = "gfx/ui/achievement/SoulNadabAbihu.png",
		deli = "gfx/ui/achievement/NadabBrainAndBody.png",
		greed2 = "gfx/ui/achievement/SlayTheSpire.png",
		mega = "gfx/ui/achievement/DominoTiles.png",
		mother = "gfx/ui/achievement/MeltedCandle.png",
		beast = "gfx/ui/achievement/IvoryOil.png",
		--all = "gfx/ui/achievement/EyeKey.png",
	},
	Unbidden = {
		isaac = "gfx/ui/achievement/VoidKarma.png", bbaby = "gfx/ui/achievement/RubberDuck.png",
		satan = "gfx/ui/achievement/LongElk.png", lamb = "gfx/ui/achievement/VHSCassette.png",
		rush = "gfx/ui/achievement/Apocalypse.png", hush = "gfx/ui/achievement/Knights.png",
		deli = "gfx/ui/achievement/RedLotus.png",
		greed = "gfx/ui/achievement/MidasCurse.png", greed2 = "gfx/ui/achievement/Lililith.png",
		mother = "gfx/ui/achievement/RedMirror.png", beast = "gfx/ui/achievement/Limb.png",
	},
	UnbiddenB = {
		isaacsatan = "gfx/ui/achievement/WitchPaper.png",
		hushrush = "gfx/ui/achievement/SoulUnbidden.png",
		deli = "gfx/ui/achievement/Eclipse.png",
		mega = "gfx/ui/achievement/DuotineAndRedPill.png",
		greed2 = "gfx/ui/achievement/LoopHero.png",
		mother = "gfx/ui/achievement/Trapezohedron.png",
		beast = "gfx/ui/achievement/RedBag.png",
		all = "gfx/ui/achievement/FloppyDisk.png",
	},
	Challenges = {
		potato = "gfx/ui/achievement/Cybercutlet.png",
		lobotomy = "gfx/ui/achievement/DeliriousBum.png",
		magician = "gfx/ui/achievement/MewGen.png",
		beatmaker = "gfx/ui/achievement/GildedFork.png",
		mongofamily = "gfx/ui/achievement/GoldenEgg.png",
		--shovel = "gfx/ui/achievement/Whispers.png",
	},
}

--- Init Pool Unlock check
function EclipsedMod:onInitUnlocks(ppl)
	if game:GetFrameCount() == 0 then

		local savetable = functions.modDataLoad()
		local modCompletion = savetable.CompletionMarks

		-- item
		if ppl:GetPlayerType() == enums.Characters.UnbiddenB or ppl:GetPlayerType() == enums.Characters.Unbidden then
			itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_SCHOOLBAG)
		
		end
		
		for item, tab in pairs(LockedItems) do
			local unlocked = true
			local checkname = tab[1] -- get name of player
			local checkvalue = tab[2] -- get completion mark value
			local checklist = tab[3] -- get mark names -> isaac, bbaby, satan, lamb etc.

			for _, mark in pairs(checklist) do -- check marks
				if not modCompletion[checkname][mark] then 
					modCompletion[checkname][mark] = 0 
					functions.modDataSave(savetable)
				end
				if modCompletion[checkname][mark] < checkvalue then -- check value: if savedValue < checkvalue then
					unlocked = false
					break
				end
			end

			if not unlocked then
				itemPool:RemoveCollectible(item)
			end
		end

		--trinket
		for trinket, tab in pairs(LockedTrinkets) do
			local unlocked = true
			local checkname = tab[1]
			local checkvalue = tab[2]
			local checklist = tab[3]
			for _, mark in pairs(checklist) do
				if not modCompletion[checkname][mark] then 
					modCompletion[checkname][mark] = 0 
					functions.modDataSave(savetable)
				end
				if modCompletion[checkname][mark] < checkvalue then
					unlocked = false
					break
				end
			end
			if not unlocked then
				itemPool:RemoveTrinket(trinket)
			end
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, EclipsedMod.onInitUnlocks)

function EclipsedMod:onPostPickupInit2(pickup) -- SodomAndGomorrah
	-- safe check if mod was loaded
	--if savetable == {} then modDataLoad() end
	--local modCompletion = savetable.CompletionMarks
	local savetable = functions.modDataLoad()
	local modCompletion = savetable.CompletionMarks
	-- if all marks isn't completed
	--if modCompletion.Nadab.all < 2 or modCompletion.Abihu.all < 2 or modCompletion.Unbidden.all < 2 or modCompletion.UnbiddenB.all < 2 or modCompletion.Challenges.all < 1 then
		local newItem = pickup.SubType
		--[[
		if pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE and LockedItems[newItem] then
			local unlocked = true
			local checkname = LockedItems[newItem][1] -- get name of player
			local checkvalue = LockedItems[newItem][2] -- get completion mark value
			local checklist = LockedItems[newItem][3] -- get mark names -> isaac, bbaby, satan, lamb etc.
			for _, mark in pairs(checklist) do -- check marks
				if not modCompletion[checkname][mark] then 
					modCompletion[checkname][mark] = 0 
					functions.modDataSave(savetable)
				end
				if modCompletion[checkname][mark] < checkvalue then -- check value: if savedValue < checkvalue then
					unlocked = false
					break
				end
			end
			if not unlocked then
				local room = game:GetRoom()
				local roomType = room:GetType()
				local seed = game:GetSeeds():GetStartSeed()
				local pool = itemPool:GetPoolForRoom(roomType, seed)
				
				if pool == ItemPoolType.POOL_NULL then
					pool = ItemPoolType.POOL_TREASURE
				end
				itemPool:RemoveCollectible(newItem)
				newItem = itemPool:GetCollectible(pool, true, pickup.InitSeed)
			end
		elseif pickup.Variant == PickupVariant.PICKUP_TRINKET and LockedTrinkets[newItem] then
			local isGolden = false
			if newItem > TrinketType.TRINKET_GOLDEN_FLAG then
				newItem = newItem - TrinketType.TRINKET_GOLDEN_FLAG
				isGolden = true
			end
			local unlocked = true
			local checkname = LockedTrinkets[newItem][1]
			local checkvalue = LockedTrinkets[newItem][2]
			local checklist = LockedTrinkets[newItem][3]
			for _, mark in pairs(checklist) do
				if not modCompletion[checkname][mark] then 
					modCompletion[checkname][mark] = 0 
					functions.modDataSave(savetable)
				end
				if modCompletion[checkname][mark] < checkvalue then
					unlocked = false
					break
				end
			end
			if not unlocked then
				itemPool:RemoveTrinket(newItem)
				newItem = itemPool:GetTrinket(false)
				if isGolden then
					newItem = newItem + TrinketType.TRINKET_GOLDEN_FLAG
				end
			end
		else
		--]]
		if pickup.Variant == PickupVariant.PICKUP_TAROTCARD and LockedCards[newItem] then
			local unlocked = true
			local checkname = LockedCards[newItem][1]
			local checkvalue = LockedCards[newItem][2]
			local checklist = LockedCards[newItem][3]
			for _, mark in pairs(checklist) do
				if not modCompletion[checkname][mark] then 
					modCompletion[checkname][mark] = 0 
					functions.modDataSave(savetable)
				end
				if modCompletion[checkname][mark] < checkvalue then
					unlocked = false
					break
				end
			end
			if not unlocked then
				newItem = itemPool:GetCard(pickup.InitSeed, false, true, true)
			end
		end
		if newItem ~= pickup.SubType then
			pickup:Morph(pickup.Type, pickup.Variant, newItem, true, false, true)
		end
	--end
end
EclipsedMod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, EclipsedMod.onPostPickupInit2)

local DifficultyToCompletionMap = {
	[Difficulty.DIFFICULTY_NORMAL]	 = 1,
	[Difficulty.DIFFICULTY_HARD]	 = 2,
	[Difficulty.DIFFICULTY_GREED]	 = 1,
	[Difficulty.DIFFICULTY_GREEDIER] = 2,
}

local BossID = { -- Only the relevant ones (SodomAndGomorrah)
	HEART 		= 8,
	SATAN 		= 24,
	IT_LIVES	= 25,
	ISAAC		= 39,
	BLUE_BABY	= 40,
	LAMB		= 54,
	MEGA_SATAN	= 55,
	GREED		= 62,
	HUSH		= 63,
	DELIRIUM	= 70,
	GREEDIER	= 71,
	MOTHER		= 88,
	MAUS_HEART	= 90,
	BEAST		= 100,
}

local CompletionRoomType = {
	[RoomType.ROOM_BOSSRUSH] = true,
	[RoomType.ROOM_BOSS] = true,
}

local function HasFullCompletion(myTable, charName)
	local allmarks = true
	if myTable.all < 2 then
	    for id, item in pairs(myTable) do
	       if id ~= "all" then
	           if item < 2 then
	               allmarks = false
	               break
	           end
	       end
	    end
		if allmarks then
	        myTable.all = 2
			if LockedPapers[charName].all and LockedPapers[charName].all then
				QueueAchievementNote(LockedPapers[charName].all)
			end
		end
	end
	return allmarks
end

function EclipsedMod:onRoomClear3()
	if game.Challenge == 0 and game:GetVictoryLap() == 0 and CompletionRoomType[game:GetRoom():GetType()] and Isaac.GetPlayer() and enums.Characters[Isaac.GetPlayer():GetName()] then
		local room = game:GetRoom()
		local roomtype = room:GetType()
		local value = DifficultyToCompletionMap[game.Difficulty]
		local savetable = functions.modDataLoad()
		local charName = Isaac.GetPlayer():GetName()
		local marks = savetable.CompletionMarks[charName]
		if marks.all < 2 then
			if roomtype == RoomType.ROOM_BOSSRUSH then
				if LockedPapers[charName].hushrush and marks.hush > 0 and marks.rush == 0 then
					QueueAchievementNote(LockedPapers[charName].hushrush)
				elseif LockedPapers[charName].rush and marks.rush == 0 then
					QueueAchievementNote(LockedPapers[charName].rush)
				end
				marks.rush = math.max(marks.rush, value)
			elseif roomtype == RoomType.ROOM_BOSS then
				local boss = room:GetBossID()
				if game:GetLevel():GetStage() == LevelStage.STAGE7 then -- Void
					if boss == BossID.DELIRIUM then
						if LockedPapers[charName].deli and marks.deli == 0 then
							QueueAchievementNote(LockedPapers[charName].deli)
						end
						marks.deli = math.max(marks.deli, value)
					end
				else
					if boss == BossID.HEART or boss == BossID.IT_LIVES or boss == BossID.MAUS_HEART then
						if LockedPapers[charName].heart and marks.heart == 0 then
							QueueAchievementNote(LockedPapers[charName].heart)
						end
						marks.heart = math.max(marks.heart, value)
					elseif boss == BossID.ISAAC then
						if LockedPapers[charName].isaacsatan and marks.bbaby > 0 and marks.satan > 0 and marks.lamb > 0 and marks.isaac == 0 then
							QueueAchievementNote(LockedPapers[charName].isaacsatan)
						elseif LockedPapers[charName].isaac and marks.isaac == 0 then
							QueueAchievementNote(LockedPapers[charName].isaac)
						end
						marks.isaac = math.max(marks.isaac, value)
					elseif boss == BossID.BLUE_BABY then
						if LockedPapers[charName].isaacsatan and marks.isaac > 0 and marks.satan > 0 and marks.lamb > 0 and marks.bbaby == 0 then
							QueueAchievementNote(LockedPapers[charName].isaacsatan)
						elseif LockedPapers[charName].bbaby and marks.bbaby == 0 then
							QueueAchievementNote(LockedPapers[charName].bbaby)
						end
						marks.bbaby = math.max(marks.bbaby, value)
					elseif boss == BossID.SATAN then
						if LockedPapers[charName].isaacsatan and marks.bbaby > 0 and marks.isaac > 0 and marks.lamb > 0 and marks.satan == 0 then
							QueueAchievementNote(LockedPapers[charName].isaacsatan)
						elseif LockedPapers[charName].satan and marks.satan == 0 then
							QueueAchievementNote(LockedPapers[charName].satan)
						end
						marks.satan = math.max(marks.satan, value)
					elseif boss == BossID.LAMB then
						if LockedPapers[charName].isaacsatan and marks.bbaby > 0 and marks.satan > 0 and marks.isaac > 0 and marks.lamb == 0 then
							QueueAchievementNote(LockedPapers[charName].isaacsatan)
						elseif LockedPapers[charName].lamb and marks.lamb == 0 then
							QueueAchievementNote(LockedPapers[charName].lamb)
						end
						marks.lamb = math.max(marks.lamb, value)
					elseif boss == BossID.HUSH then
						if LockedPapers[charName].hushrush and marks.rush > 0 and marks.hush == 0 then
							QueueAchievementNote(LockedPapers[charName].hushrush)
						elseif LockedPapers[charName].hush and marks.hush == 0 then
							QueueAchievementNote(LockedPapers[charName].hush)
						end
						marks.hush = math.max(marks.hush, value)
					elseif boss == BossID.MEGA_SATAN then
						if LockedPapers[charName].mega and marks.mega == 0 then
							QueueAchievementNote(LockedPapers[charName].mega)
						end
						marks.mega = math.max(marks.mega, value)
					elseif boss == BossID.GREED or boss == BossID.GREEDIER then
						if LockedPapers[charName].greed2 and not LockedPapers[charName].greed then -- tainted chars
							QueueAchievementNote(LockedPapers[charName].greed2)
						elseif LockedPapers[charName].greed2 and LockedPapers[charName].greed then -- normal chars
							if marks.greed == 0 and value == 2 then -- if hard
								QueueAchievementNote(LockedPapers[charName].greed)
								QueueAchievementNote(LockedPapers[charName].greed2)
							elseif marks.greed == 0 and value == 1 then -- if normal
								QueueAchievementNote(LockedPapers[charName].greed)
							elseif marks.greed == 1 and value == 2 then -- if hard but normal was already completed
								QueueAchievementNote(LockedPapers[charName].greed2)
							end
						end
						marks.greed = math.max(marks.greed, value)
					elseif boss == BossID.MOTHER then
						if LockedPapers[charName].mother and marks.mother == 0 then
							QueueAchievementNote(LockedPapers[charName].mother)
						end
						marks.mother = math.max(marks.mother, value)
					end
				end
			end
			HasFullCompletion(marks, charName)
			functions.modDataSave(savetable)
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, EclipsedMod.onRoomClear3)

--challangesInit
function EclipsedMod:onTrophyCollision(_, collider) --pickup, collider, low
	if Isaac.GetChallenge() > 0 then
		local savetable = functions.modDataLoad()
		local modCompletion = savetable.CompletionMarks.Challenges
		local currentChallenge = Isaac.GetChallenge()
		if collider:ToPlayer() then --and modCompletion.all < 1 then
			if currentChallenge == enums.Challenges.Potatoes then
				if LockedPapers.Challenges.potato and modCompletion.potato == 0 then
					modCompletion.potato = 2
					QueueAchievementNote(LockedPapers.Challenges.potato)
				end
			elseif currentChallenge == enums.Challenges.Magician then
				if LockedPapers.Challenges.magician and modCompletion.magician == 0 then
					modCompletion.magician = 2
					QueueAchievementNote(LockedPapers.Challenges.magician)
				end
			elseif currentChallenge == enums.Challenges.Lobotomy then
				if LockedPapers.Challenges.lobotomy and modCompletion.lobotomy == 0 then
					modCompletion.lobotomy = 2
					QueueAchievementNote(LockedPapers.Challenges.lobotomy)
				end
			elseif currentChallenge == enums.Challenges.Beatmaker then
				if LockedPapers.Challenges.beatmaker and modCompletion.beatmaker == 0 then
					modCompletion.beatmaker = 2
					QueueAchievementNote(LockedPapers.Challenges.beatmaker)
				end
			elseif currentChallenge == enums.Challenges.MongoFamily then
				if LockedPapers.Challenges.mongofamily and modCompletion.mongofamily == 0 then
					modCompletion.mongofamily = 2
					QueueAchievementNote(LockedPapers.Challenges.mongofamily)
				end
			--elseif currentChallenge == enums.Challenges.ShovelNight then
			--	if LockedPapers.Challenges.shovel and modCompletion.shovel == 0 then
			--		modCompletion.shovel = 2
			--		QueueAchievementNote(LockedPapers.Challenges.shovel)
			--	end
			end
			HasFullCompletion(modCompletion, "Challenges")
			functions.modDataSave(savetable)
		end
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, EclipsedMod.onTrophyCollision, PickupVariant.PICKUP_TROPHY)

function EclipsedMod:onNPCDeath3(entity)
	if game:GetVictoryLap() > 0 then return end
	if game.Challenge > 0 then return end
	if entity.Variant ~= 0 then return end -- The Beast
	local value = DifficultyToCompletionMap[game.Difficulty]
	
	if Isaac.GetPlayer() and enums.Characters[Isaac.GetPlayer():GetName()] then
		local savetable = functions.modDataLoad()
		local charName = Isaac.GetPlayer():GetName()
		local marks = savetable.CompletionMarks[charName]
		
		if marks.beast < 2 then
			if LockedPapers[charName].beast and marks.beast == 0 then
				QueueAchievementNote(LockedPapers[charName].beast)
			end
			marks.beast = math.max(marks.beast, value)
		end
		HasFullCompletion(marks, charName)
		functions.modDataSave(savetable)
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, EclipsedMod.onNPCDeath3, EntityType.ENTITY_BEAST)
---EXECUTE CMD

---EXECUTE COMMAND---
function EclipsedMod:onExecuteCommand(command, args)
	--- console commands ---
	if command == "eclipsed" then
		local savetable = functions.modDataLoad()
		if args == "help" or args == "" then
			print('disabled unlocks and curses by default')
			print('eclipsed curse [curse number | name] -> enable/disable mod curses')
			print('eclipsed curse -> list of curses')
			print('eclipsed reset challenge [all | magic | lobotomy | potato | beatmaker | mongofamily]') -- | shovel
			print('eclipsed unlock challenge [all | magic | lobotomy | potato | beatmaker | mongofamily]') --| shovel
			print('eclipsed reset [all | nadab | abihu | unbid | tunbid] [heart | isaac | bbaby | satan | lamb | rush | hush | deli | megas | greed | mother | beast]')
			print('eclipsed unlock [all | nadab | abihu | unbid | tunbid] [heart | isaac | bbaby | satan | lamb | rush | hush | deli | megas | greed | mother | beast]')
			print("example: [eclipsed reset nadab rush] -> reset completion on Boss Rush")
			print("example: [eclipsed unlock] OR [eclipsed unlock all] -> unlocks everything on all characters")
			--print("UnbiddenB familiars aura attack - not implemented (fate rewards, incubus, splinker, twisted pair?)") they somehow works; guess it's ok
		elseif args == "curse" then
			print('eclipsed curse [curse number or name] -> enable/disable mod curses')
			print("eclipsed curse [1 | void]")
			print("eclipsed curse [2 | jam | jamming]")
			print("eclipsed curse [3 | emperor]")
			print("eclipsed curse [4 | mage | magician]")
			print("eclipsed curse [5 | pride]")
			print("eclipsed curse [6 | bell]")
			print("eclipsed curse [7 | envy]")
			print("eclipsed curse [8 | carrion]")
			print("eclipsed curse [9 | bishop]")
			print("eclipsed curse [10 | montezuma | zuma]")
			print("eclipsed curse [11 | misfortune]")
			print("eclipsed curse [12 | poverty]")
			print("eclipsed curse [13 | fool]")
			print("eclipsed curse [14 | secret | secrets]")
			print("eclipsed curse [15 | warden]")
			print("eclipsed curse [16 | desolation | wisp]")
		elseif args == "curse enable" then	
			print("eclipsed curses enabled")
			savetable.SpecialCursesAvtice = true
		elseif args == "curse disable" then		
			print("eclipsed curses disabled")
			savetable.SpecialCursesAvtice = false
		elseif args == "curse 1" or args == "curse void" then
			functions.AddModCurse(enums.Curses.Void)
			print("Curse of the Void! - 16% chance to reroll enemies and grid upon entering room")
			print("eclipsed curse [1 | void]")
		elseif args == "curse 2" or args == "curse jam" or args == "curse jamming" then
			functions.AddModCurse(enums.Curses.Jamming)
			print("Curse of the Jamming! - 16% chance to respawn enemies after clearing room")
			print("eclipsed curse [2 | jam | jamming]")
		elseif args == "curse 3" or args == "curse emperor" then
			functions.AddModCurse(enums.Curses.Emperor)
			print("Curse of the Emperor! - remove exit door from boss room (similar to mom boss room)")
			print("eclipsed curse [3 | emperor]")
		elseif args == "curse 4" or args == "curse mage" or args == "curse magician" then
			functions.AddModCurse(enums.Curses.Magician)
			print("Curse of the Magician! - 25% chance to shoot homing enemy tear (except boss)")
			print("eclipsed curse [4 | mage | magician]")
		elseif args == "curse 5" or args == "curse pride" then
			functions.AddModCurse(enums.Curses.Pride)
			print("Curse of the Pride! - 50% chance to enemies become champion (except boss)")
			print("eclipsed curse [5 | pride]")
		elseif args == "curse 6" or args == "curse bell" then
			functions.AddModCurse(enums.Curses.Bell)
			print("Curse of the Bell! - all troll bombs is golden")
			print("eclipsed curse [6 | bell]")
		elseif args == "curse 7" or args == "curse envy" then
			functions.AddModCurse(enums.Curses.Envy)
			print("Curse of the Envy! - other shop items disappear when you buy one [shop, black market, member card, devil deal, angel shop]")
			print("eclipsed curse [7 | envy]")
		elseif args == "curse 8" or args == "curse carrion" then
			functions.AddModCurse(enums.Curses.Carrion)
			print("Curse of Carrion! - turn normal poops into red")
			print("eclipsed curse [8 | carrion]")
		elseif args == "curse 9" or args == "curse bishop" then
			functions.AddModCurse(enums.Curses.Bishop)
			print("Curse of the Bishop! - 16% chance to damage immunity. enemy will flash blue")
			print("eclipsed curse [9 | bishop]")
		elseif args == "curse 10" or args == "curse zuma" or args == "curse montezuma" then
			functions.AddModCurse(enums.Curses.Montezuma)
			print("Curse of Montezuma! - slippery floor, works only in uncleared rooms")
			print("eclipsed curse [10 | montezuma | zuma]")
		elseif args == "curse 11" or args == "curse misfortune" then
			functions.AddModCurse(enums.Curses.Misfortune)
			print("Curse of Misfortune! - -5 luck while curse is applyed")
			print("eclipsed curse [11 | misfortune]")
		elseif args == "curse 12" or args == "curse poverty" then
			functions.AddModCurse(enums.Curses.Poverty)
			print("Curse of Poverty! - greedy enemy tears. drop your coins when enemy tear hit you")
			print("eclipsed curse [12 | poverty]")
		elseif args == "curse 13" or args == "curse fool" then
			functions.AddModCurse(enums.Curses.Fool)
			print("Curse of the Fool! - 16% chance to respawn enemies in cleared rooms (except boss room), don't close doors")
			print("eclipsed curse [13 | fool]")
		elseif args == "curse 14" or args == "curse secret" or args == "curse secrets" then
			functions.AddModCurse(enums.Curses.Secrets)
			print("Curse of Secrets! - hide secret/supersecret room doors when reentering room")
			print("eclipsed curse [14 | secret | secrets]")
		elseif args == "curse 15" or args == "curse warden" then
			functions.AddModCurse(enums.Curses.Warden)
			print("Curse of the Warden! - all locked doors need 2 keys")
			print("Visual bug with door not applying chains on first door encounter. Door stil require 2 keys")
			print("eclipsed curse [15 | warden]")
		elseif args == "curse 16" or args == "curse wisp" or args == "curse desolation" then
			functions.AddModCurse(enums.Curses.Desolation)
			print("Curse of the Desolation! - 16% chance to turn item into Item Wisp when touched. Add wisped item on next floor")
			print("eclipsed curse [16 | desolation | wisp]")
		elseif args == "reset" or args == "reset all" then
		    savetable.CompletionMarks.Nadab = datatables.completionInit
			savetable.CompletionMarks.Abihu = datatables.completionInit
			savetable.CompletionMarks.Unbidden = datatables.completionInit
			savetable.CompletionMarks.UnbiddenB = datatables.completionInit
			savetable.CompletionMarks.Challenges = datatables.challengesInit
			print("reset all")
		elseif args == "reset challenge" or args == "reset challenge all" then
			savetable.CompletionMarks.Challenges = datatables.challengesInit
			print("reset all challenges")
		elseif args == "reset potato" or args == "reset challenge potato" then
			savetable.CompletionMarks.Challenges.potato = 0
			print("reset potato challenge")
		elseif args == "reset lobotomy" or args == "reset challenge lobotomy" then
			savetable.CompletionMarks.Challenges.lobotomy = 0
			print("reset lobotomy challenge")
		elseif args == "reset magician" or args == "reset challenge magician" then
			savetable.CompletionMarks.Challenges.magician = 0
			print("reset magician challenge")
		elseif args == "reset beatmaker" or args == "reset challenge beatmaker" then
			savetable.CompletionMarks.Challenges.beatmaker = 0
			print("reset beatmaker challenge")
		elseif args == "reset mongofamily" or args == "reset challenge mongofamily" then
			savetable.CompletionMarks.Challenges.mongofamily = 0
			print("reset mongofamily challenge")
		--elseif args == "unlock shovel" or args == "unlock challenge shovel" then
		--	savetable.CompletionMarks.Challenges.shovel = 0
		--	print("unlock shovel challenge")
		elseif args == "reset nadab" or args == "reset nadab all" then
			savetable.CompletionMarks.Nadab = datatables.completionInit
		    print("ok")
		elseif args == "reset nadab heart" then
			savetable.CompletionMarks.Nadab.heart = 0
		    print("ok")
		elseif args == "reset nadab isaac" then
			savetable.CompletionMarks.Nadab.isaac = 0
		    print("ok")
		elseif args == "reset nadab bbaby" then
			savetable.CompletionMarks.Nadab.bbaby = 0
		    print("ok")
		elseif args == "reset nadab satan" then
			savetable.CompletionMarks.Nadab.satan = 0
		    print("ok")
		elseif args == "reset nadab lamb" then
			savetable.CompletionMarks.Nadab.lamb = 0
		    print("ok")
		elseif args == "reset nadab rush" then
			savetable.CompletionMarks.Nadab.rush = 0
		    print("ok")
		elseif args == "reset nadab hush" then
			savetable.CompletionMarks.Nadab.hush = 0
		    print("ok")
		elseif args == "reset nadab deli" then
			savetable.CompletionMarks.Nadab.deli = 0
		    print("ok")
		elseif args == "reset nadab mega" then
			savetable.CompletionMarks.Nadab.mega = 0
		    print("ok")
		elseif args == "reset nadab greed" then
			savetable.CompletionMarks.Nadab.greed = 0
		    print("ok")
		elseif args == "reset nadab mother" then
			savetable.CompletionMarks.Nadab.mother = 0
		    print("ok")
		elseif args == "reset nadab beast" then
			savetable.CompletionMarks.Nadab.beast = 0
		    print("ok")
		elseif args == "reset abihu" or args == "reset abihu all" then
			savetable.CompletionMarks.Abihu = datatables.completionInit
			print("ok")
		elseif args == "reset abihu heart" then
			savetable.CompletionMarks.Abihu.heart = 0
		    print("ok")
		elseif args == "reset abihu isaac" then
			savetable.CompletionMarks.Abihu.isaac = 0
		    print("ok")
		elseif args == "reset abihu bbaby" then
			savetable.CompletionMarks.Abihu.bbaby = 0
		    print("ok")
		elseif args == "reset abihu satan" then
			savetable.CompletionMarks.Abihu.satan = 0
		    print("ok")
		elseif args == "reset abihu lamb" then
			savetable.CompletionMarks.Abihu.lamb = 0
		    print("ok")
		elseif args == "reset abihu rush" then
			savetable.CompletionMarks.Abihu.rush = 0
		    print("ok")
		elseif args == "reset abihu hush" then
			savetable.CompletionMarks.Abihu.hush = 0
		    print("ok")
		elseif args == "reset abihu deli" then
			savetable.CompletionMarks.Abihu.deli = 0
		    print("ok")
		elseif args == "reset abihu mega" then
			savetable.CompletionMarks.Abihu.mega = 0
		    print("ok")
		elseif args == "reset abihu greed" then
			savetable.CompletionMarks.Abihu.greed = 0
		    print("ok")
		elseif args == "reset abihu mother" then
			savetable.CompletionMarks.Abihu.mother = 0
		    print("ok")
		elseif args == "reset abihu beast" then
			savetable.CompletionMarks.Abihu.beast = 0
		    print("ok")
		elseif args == "reset unbid" or args == "reset unbid all" then
			savetable.CompletionMarks.Unbidden = datatables.completionInit
			print("ok")
		elseif args == "reset unbid heart" then
			savetable.CompletionMarks.Unbidden.heart = 0
		    print("ok")
		elseif args == "reset unbid isaac" then
			savetable.CompletionMarks.Unbidden.isaac = 0
		    print("ok")
		elseif args == "reset unbid bbaby" then
			savetable.CompletionMarks.Unbidden.bbaby = 0
		    print("ok")
		elseif args == "reset unbid satan" then
			savetable.CompletionMarks.Unbidden.satan = 0
		    print("ok")
		elseif args == "reset unbid lamb" then
			savetable.CompletionMarks.Unbidden.lamb = 0
		    print("ok")
		elseif args == "reset unbid rush" then
			savetable.CompletionMarks.Unbidden.rush = 0
		    print("ok")
		elseif args == "reset unbid hush" then
			savetable.CompletionMarks.Unbidden.hush = 0
		    print("ok")
		elseif args == "reset unbid deli" then
			savetable.CompletionMarks.Unbidden.deli = 0
		    print("ok")
		elseif args == "reset unbid mega" then
			savetable.CompletionMarks.Unbidden.mega = 0
		    print("ok")
		elseif args == "reset unbid greed" then
			savetable.CompletionMarks.Unbidden.greed = 0
		    print("ok")
		elseif args == "reset unbid mother" then
			savetable.CompletionMarks.Unbidden.mother = 0
		    print("ok")
		elseif args == "reset unbid beast" then
			savetable.CompletionMarks.Unbidden.beast = 0
		    print("ok")
		elseif args == "reset tunbid" or args == "reset tunbid all" then
			savetable.CompletionMarks.UnbiddenB = datatables.completionInit
			print("ok")
		elseif args == "reset tunbid heart" then
			savetable.CompletionMarks.UnbiddenB.heart = 0
		    print("ok")
		elseif args == "reset tunbid isaac" then
			savetable.CompletionMarks.UnbiddenB.isaac = 0
		    print("ok")
		elseif args == "reset tunbid bbaby" then
			savetable.CompletionMarks.UnbiddenB.bbaby = 0
		    print("ok")
		elseif args == "reset tunbid satan" then
			savetable.CompletionMarks.UnbiddenB.satan = 0
		    print("ok")
		elseif args == "reset tunbid lamb" then
			savetable.CompletionMarks.UnbiddenB.lamb = 0
		    print("ok")
		elseif args == "reset tunbid rush" then
			savetable.CompletionMarks.UnbiddenB.rush = 0
		    print("ok")
		elseif args == "reset tunbid hush" then
			savetable.CompletionMarks.UnbiddenB.hush = 0
		    print("ok")
		elseif args == "reset tunbid deli" then
			savetable.CompletionMarks.UnbiddenB.deli = 0
		    print("ok")
		elseif args == "reset tunbid mega" then
			savetable.CompletionMarks.UnbiddenB.mega = 0
		    print("ok")
		elseif args == "reset tunbid greed" then
			savetable.CompletionMarks.UnbiddenB.greed = 0
		    print("ok")
		elseif args == "reset tunbid mother" then
			savetable.CompletionMarks.UnbiddenB.mother = 0
		    print("ok")
		elseif args == "reset tunbid beast" then
			savetable.CompletionMarks.UnbiddenB.beast = 0
		    print("ok")
		elseif args == "unlock" or args == "unlock all" then

			savetable.CompletionMarks.Nadab = datatables.completionFull
			savetable.CompletionMarks.Abihu = datatables.completionFull
			savetable.CompletionMarks.Unbidden = datatables.completionFull
			savetable.CompletionMarks.UnbiddenB = datatables.completionFull
			savetable.CompletionMarks.Challenges = datatables.challengesFull
		    print("unlocked all")
		elseif args == "unlock challenge" or args == "unlock challenge all" then
			savetable.CompletionMarks.Challenges = datatables.challengesFull
			print("unlock all challenges")
		elseif args == "unlock potato" or args == "unlock challenge potato" then
			savetable.CompletionMarks.Challenges.potato = 2
			print("reset potato challenge")
		elseif args == "unlock lobotomy" or args == "unlock challenge lobotomy" then
			savetable.CompletionMarks.Challenges.lobotomy = 2
			print("unlock lobotomy challenge")
		elseif args == "unlock magician" or args == "unlock challenge magician" then
			savetable.CompletionMarks.Challenges.magician = 2
			print("unlock magician challenge")
		elseif args == "unlock beatmaker" or args == "unlock challenge beatmaker" then
			savetable.CompletionMarks.Challenges.beatmaker = 2
			print("unlock beatmaker challenge")
		elseif args == "unlock mongofamily" or args == "unlock challenge mongofamily" then
			savetable.CompletionMarks.Challenges.mongofamily = 2
			print("unlock mongofamily challenge")
		--elseif args == "unlock shovel" or args == "unlock challenge shovel" then
		--	savetable.CompletionMarks.Challenges.shovel = 2
		--	print("unlock shovel challenge")
		elseif args == "unlock nadab" or args == "unlock nadab all" then
			savetable.CompletionMarks.Nadab = datatables.completionFull
		    print("ok")
		elseif args == "unlock nadab heart" then
			savetable.CompletionMarks.Nadab.heart = 2
		    print("ok")
		elseif args == "unlock nadab isaac" then
			savetable.CompletionMarks.Nadab.isaac = 2
		    print("ok")
		elseif args == "unlock nadab bbaby" then
			savetable.CompletionMarks.Nadab.bbaby = 2
		    print("ok")
		elseif args == "unlock nadab satan" then
			savetable.CompletionMarks.Nadab.satan = 2
		    print("ok")
		elseif args == "unlock nadab lamb" then
			savetable.CompletionMarks.Nadab.lamb = 2
		    print("ok")
		elseif args == "unlock nadab rush" then
			savetable.CompletionMarks.Nadab.rush = 2
		    print("ok")
		elseif args == "unlock nadab hush" then
			savetable.CompletionMarks.Nadab.hush = 2
		    print("ok")
		elseif args == "unlock nadab deli" then
			savetable.CompletionMarks.Nadab.deli = 2
		    print("ok")
		elseif args == "unlock nadab mega" then
			savetable.CompletionMarks.Nadab.mega = 2
		    print("ok")
		elseif args == "unlock nadab greed" then
			savetable.CompletionMarks.Nadab.greed = 2
		    print("ok")
		elseif args == "unlock nadab mother" then
			savetable.CompletionMarks.Nadab.mother = 2
		    print("ok")
		elseif args == "unlock nadab beast" then
			savetable.CompletionMarks.Nadab.beast = 2
		    print("ok")
		elseif args == "unlock abihu" or args == "unlock abihu all" then
			savetable.CompletionMarks.Abihu = datatables.completionFull
			print("ok")
		elseif args == "unlock abihu heart" then
			savetable.CompletionMarks.Abihu.heart = 2
		    print("ok")
		elseif args == "unlock abihu isaac" then
			savetable.CompletionMarks.Abihu.isaac = 2
		    print("ok")
		elseif args == "unlock abihu bbaby" then
			savetable.CompletionMarks.Abihu.bbaby = 2
		    print("ok")
		elseif args == "unlock abihu satan" then
			savetable.CompletionMarks.Abihu.satan = 2
		    print("ok")
		elseif args == "unlock abihu lamb" then
			savetable.CompletionMarks.Abihu.lamb = 2
		    print("ok")
		elseif args == "unlock abihu rush" then
			savetable.CompletionMarks.Abihu.rush = 2
		    print("ok")
		elseif args == "unlock abihu hush" then
			savetable.CompletionMarks.Abihu.hush = 2
		    print("ok")
		elseif args == "unlock abihu deli" then
			savetable.CompletionMarks.Abihu.deli = 2
		    print("ok")
		elseif args == "unlock abihu mega" then
			savetable.CompletionMarks.Abihu.mega = 2
		    print("ok")
		elseif args == "unlock abihu greed" then
			savetable.CompletionMarks.Abihu.greed = 2
		    print("ok")
		elseif args == "unlock abihu mother" then
			savetable.CompletionMarks.Abihu.mother = 2
		    print("ok")
		elseif args == "unlock abihu beast" then
			savetable.CompletionMarks.Abihu.beast = 2
		    print("ok")
		elseif args == "unlock unbid" or args == "unlock unbid all" then
			savetable.CompletionMarks.Unbidden = datatables.completionFull
			print("ok")
		elseif args == "unlock unbid heart" then
			savetable.CompletionMarks.Unbidden.heart = 2
		    print("ok")
		elseif args == "unlock unbid isaac" then
			savetable.CompletionMarks.Unbidden.isaac = 2
		    print("ok")
		elseif args == "unlock unbid bbaby" then
			savetable.CompletionMarks.Unbidden.bbaby = 2
		    print("ok")
		elseif args == "unlock unbid satan" then
			savetable.CompletionMarks.Unbidden.satan = 2
		    print("ok")
		elseif args == "unlock unbid lamb" then
			savetable.CompletionMarks.Unbidden.lamb = 2
		    print("ok")
		elseif args == "unlock unbid rush" then
			savetable.CompletionMarks.Unbidden.rush = 2
		    print("ok")
		elseif args == "unlock unbid hush" then
			savetable.CompletionMarks.Unbidden.hush = 2
		    print("ok")
		elseif args == "unlock unbid deli" then
			savetable.CompletionMarks.Unbidden.deli = 2
		    print("ok")
		elseif args == "unlock unbid mega" then
			savetable.CompletionMarks.Unbidden.mega = 2
		    print("ok")
		elseif args == "unlock unbid greed" then
			savetable.CompletionMarks.Unbidden.greed = 2
		    print("ok")
		elseif args == "unlock unbid mother" then
			savetable.CompletionMarks.Unbidden.mother = 2
		    print("ok")
		elseif args == "unlock unbid beast" then
			savetable.CompletionMarks.Unbidden.beast = 2
		    print("ok")
		elseif args == "unlock tunbid" or args == "unlock tunbid all" then
			savetable.CompletionMarks.UnbiddenB = datatables.completionFull
			print("ok")
		elseif args == "unlock tunbid heart" then
			savetable.CompletionMarks.UnbiddenB.heart = 2
		    print("ok")
		elseif args == "unlock tunbid isaac" then
			savetable.CompletionMarks.UnbiddenB.isaac = 2
		    print("ok")
		elseif args == "unlock tunbid bbaby" then
			savetable.CompletionMarks.UnbiddenB.bbaby = 2
		    print("ok")
		elseif args == "unlock tunbid satan" then
			savetable.CompletionMarks.UnbiddenB.satan = 2
		    print("ok")
		elseif args == "unlock tunbid lamb" then
			savetable.CompletionMarks.UnbiddenB.lamb = 2
		    print("ok")
		elseif args == "unlock tunbid rush" then
			savetable.CompletionMarks.UnbiddenB.rush = 2
		    print("ok")
		elseif args == "unlock tunbid hush" then
			savetable.CompletionMarks.UnbiddenB.hush = 2
		    print("ok")
		elseif args == "unlock tunbid deli" then
			savetable.CompletionMarks.UnbiddenB.deli = 2
		    print("ok")
		elseif args == "unlock tunbid mega" then
			savetable.CompletionMarks.UnbiddenB.mega = 2
		    print("ok")
		elseif args == "unlock tunbid greed" then
			savetable.CompletionMarks.UnbiddenB.greed = 2
		    print("ok")
		elseif args == "unlock tunbid mother" then
			savetable.CompletionMarks.UnbiddenB.mother = 2
		    print("ok")
		elseif args == "unlock tunbid beast" then
			savetable.CompletionMarks.UnbiddenB.beast = 2
		    print("ok")
		end
		functions.modDataSave(savetable)
	end
end
EclipsedMod:AddCallback(ModCallbacks.MC_EXECUTE_CMD, EclipsedMod.onExecuteCommand)
---Mod Compat
require("scripts_eclipsed.compat.eid")
require("scripts_eclipsed.compat.encyclopedia")
---//////////////////////////////////////////////////////////
print('[Eclipsed v.1.1] Type `eclipsed` or `eclipsed help`')