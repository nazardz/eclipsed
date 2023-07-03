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


---################################################################################################

datatables.NadabBody = {}
datatables.NadabBody.SpritePath = "gfx/familiar/nadabbody.png"
datatables.NadabBody.RocketVol = 30

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
	--effect.Color = datatables.UnbiddenBData.Stats.LASER_COLOR
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
	--effect.Color =  datatables.UnbiddenBData.Stats.LASER_COLOR
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



function EclipsedMod:onPEffectUpdate3(player)
	local level = game:GetLevel()
	local data = player:GetData()
	local tempEffects = player:GetEffects()


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