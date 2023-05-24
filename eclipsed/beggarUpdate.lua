Beggars Update:


Ghost Beggar - take 1 coin, can drop rune or soulstone, prize is ghostly item, can die if shoot tears

Bookworm Beggar - take 5 coins, prize is a random book 

Glitched Beggar - take 1 random pickup, shown in tablet, each interactios has a chance to drop any item

Dungeon Beggar - take 1 coin, activate random pressure plate effect or drop dice shard, prize dice items

	
	<entity anm2path="bookworm_beggar.anm2"
		baseHP="0" boss="0" champion="0"
		collisionDamage="0"
		collisionMass="3"
		collisionRadius="12"
		friction="1"
		id="6"
		name="Bookworm Beggar"
		numGridCollisionPoints="24"
		shadowSize="15"
		stageHP="0"
		variant="594">
		<gibs amount="6" blood="1" bone="1" eye="1" gut="1" large="0" />
    </entity>
    <entity anm2path="dungeon_beggar.anm2"
		baseHP="0" boss="0" champion="0"
		collisionDamage="0"
		collisionMass="3"
		collisionRadius="12"
		friction="1"
		id="6"
		name="Dice Beggar"
		numGridCollisionPoints="24"
		shadowSize="15"
		stageHP="0"
		variant="595">
		<gibs amount="6" blood="1" bone="1" eye="1" gut="1" large="0" />
    </entity>
    <entity anm2path="ghost_beggar.anm2"
		baseHP="0" boss="0" champion="0"
		collisionDamage="0"
		collisionMass="3"
		collisionRadius="12"
		friction="1"
		id="6"
		name="Ghost Beggar"
		numGridCollisionPoints="24"
		shadowSize="15"
		stageHP="0"
		variant="596">
		<gibs amount="6" blood="1" bone="1" eye="1" gut="1" large="0" />
    </entity>
	
	---AddEntityFlag(EntityFlag.FLAG_NO_DEATH_TRIGGER, )
	
	enums.Slots.BookwormBeggar = Isaac.GetEntityVariantByName("Delirious Bum")
	enums.Slots.DungeonBeggar = Isaac.GetEntityVariantByName("Dice Beggar")
	enums.Slots.GhostBeggar = Isaac.GetEntityVariantByName("Ghost Beggar")
	
	
	 datatables.BeggarReplaceChance = 0.1
	
	datatables.Bookworm = {}
	datatables.Bookworm.PrizeChance = 0.5
	datatables.Bookworm.ActivateChance = 0.33
	
	
	
	
	reset it
	datatables.DungeonBeggar.ItemPool 
	
	
	
	-- somewhere at the start of the game
	local beggartable = {
		enums.Slots.MongoBeggar,
	}
	local savetable = functions.modDataLoad()
	if savetable.CompletionMarks.Challenges.lobotomy > 0 then
		table.insert(beggartable, enums.Slots.DeliriumBeggar)
	end
	
	
	
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
			
			if rng:RandomFloat() <= datatables.BeggarReplaceChance then
				local newBeggar = beggartable[rng:RandomInt(#beggartable)+1]
				return {entType, newBeggar, 0}
			end
			
			

			end
		end
	end
	EclipsedMod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, EclipsedMod.onEntSpawn)
	
	
	local bookwormBeggars = Isaac.FindByType(EntityType.ENTITY_SLOT, enums.Slots.BookwormBeggar)
	if #bookwormBeggars > 0 then
		for _, beggar in pairs(bookwormBeggars) do
			local sprite = beggar:GetSprite()
			local rng = beggar:GetDropRNG()
			local randNum = rng:RandomFloat()

			if sprite:IsFinished("PayNothing") then sprite:Play("Idle")	end
			if sprite:IsFinished("PayPrize") then sprite:Play("Prize") end

			if sprite:IsFinished("Prize") then
				sfx:Play(SoundEffect.SOUND_SLOTSPAWN)
				local spawnpos = Isaac.GetFreeNearPosition(beggar.Position, 35)
				
				local bookItem = itemPool:GetCollectible(ItemPoolType.POOL_LIBRARY, true)
				functions.DebugSpawn(100, bookItem, spawnpos)
				
				if randNum <= datatables.Bookworm.PrizeChance  then
					sprite:Play("Teleport")
					level:SetStateFlag(LevelStateFlag.STATE_BUM_LEFT, true)
				else
					sprite:Play("Idle")
				end
			end

			if sprite:IsFinished("Teleport") then
				beggar:Remove()
			else
				if beggar.Position:Distance(player.Position) <= 20 then -- 20 distance where you definitely touch beggar
					if sprite:IsPlaying("Idle") and player:GetNumCoins() >= 5 then
						player:AddCoins(-5)
						sfx:Play(SoundEffect.SOUND_SCAMPER)
						if rng:RandomFloat() < datatables.Bookworm.ActivateChance then
							sprite:Play("PayPrize")
						else
							sprite:Play("PayNothing")
						end
					end
				end
				functions.BeggarWasBombed(beggar)
			end
		end
	end
	
	local dungeonBeggar = Isaac.FindByType(EntityType.ENTITY_SLOT, enums.Slots.DungeonBeggar)
	if #dungeonBeggar > 0 then
		for _, beggar in pairs(dungeonBeggar) do
			local sprite = beggar:GetSprite()
			local rng = beggar:GetDropRNG()
			local randNum = rng:RandomFloat()

			if sprite:IsFinished("PayNothing") then sprite:Play("Idle")	end
			if sprite:IsFinished("PayPrize") then sprite:Play("Prize") end

			if sprite:IsFinished("Prize") then
				sfx:Play(SoundEffect.SOUND_SLOTSPAWN)
				
				
				
				if randNum <= datatables.DungeonBeggar.PrizeChance then
					if #datatables.DungeonBeggar.ItemPool > 0 then
						local spawnpos = Isaac.GetFreeNearPosition(beggar.Position, 35)
						local num = rng:RandomInt(#datatables.DungeonBeggar.ItemPool)+1
						local diceItem = table.remove(datatables.DungeonBeggar.ItemPool, num)
						functions.DebugSpawn(100, diceItem, spawnpos)
					else
						for _ = 1, 3 do
							functions.DebugSpawn(300, Card.CARD_DICE_SHARD, beggar.Position, 0, RandomVector()*5)
						end
					end	
					sprite:Play("Teleport")
					level:SetStateFlag(LevelStateFlag.STATE_BUM_LEFT, true)
				else
					
				
					sprite:Play("Idle")
				end
			end

			if sprite:IsFinished("Teleport") then
				beggar:Remove()
			else
				if beggar.Position:Distance(player.Position) <= 20 then -- 20 distance where you definitely touch beggar
					if sprite:IsPlaying("Idle") and player:GetNumCoins() >= 5 then
						player:AddCoins(-1)
						sfx:Play(SoundEffect.SOUND_SCAMPER)
						if rng:RandomFloat() < datatables.DungeonBeggar.ActivateChance then
							sprite:Play("PayPrize")
						else
							sprite:Play("PayNothing")
						end
					end
				end
				functions.BeggarWasBombed(beggar)
			end
		end
	end

