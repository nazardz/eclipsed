--[[
local function CustomStrawman(PlayerType, ParentPlayer)
    PlayerType=PlayerType or 0
	ParentPlayer = ParentPlayer or Isaac.GetPlayer(0)
    local ControllerIndex=ParentPlayer.ControllerIndex
    local LastPlayerIndex=game:GetNumPlayers()-1
    if LastPlayerIndex>=63 then return nil else
        Isaac.ExecuteCommand('addplayer '..PlayerType..' '..ControllerIndex)
        local Strawman=Isaac.GetPlayer(LastPlayerIndex+1)
        Strawman.Parent=ParentPlayer
        game:GetHUD():AssignPlayerHUDs()
        return Strawman
    end
end

--]]

--[[

function mod:onFamInit()

end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, mod.onFamInit, mod.Eyekey.FamVariant)

function mod:onFamUpdate()

end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, mod.onFamUpdate, mod.Eyekey.FamVariant)

--[[

	<familiar id=\"51\" quality=\"2\" craftquality=\"3\" description=\"Giga bomb generator\" gfx=\"lilgagger.png\" name=\"Lil Gagger\" cache=\"familiars\" />

	<active id=\"50\" quality=\"1\" craftquality=\"3\" description=\"Chest friend\" gfx=\"Eyekey.png\" name=\"Eyekey\" maxcharges=\"1\" cache=\"familiars\" tags=\"uniquefamiliar\"/>

	<!-- FAMILIARS -->
	<entity
		anm2path=\"Chester.anm2\"
		baseHP=\"0\"
		boss=\"0\"
		champion=\"0\"
		collisionDamage=\"0\"
		collisionMass=\"0\"
		collisionRadius=\"13\"
		friction=\"1\"
		id=\"3\"
		name=\"Chester\"
		numGridCollisionPoints=\"12\"
		shadowSize=\"11\"
		stageHP=\"0\"
		variant=\"91285\">
       	 <gibs amount=\"0\" blood=\"0\" bone=\"0\" eye=\"0\" gut=\"0\" large=\"0\" />
	</entity>

	-- VARIANT
	<entity anm2path=\"SpaceTear.anm2\" baseHP=\"0\" boss=\"0\" champion=\"0\" collisionDamage=\"0\" collisionMass=\"8\" collisionRadius=\"7\" friction=\"1\" id=\"2\" name=\"Unbidden Space Tear\" numGridCollisionPoints=\"8\" shadowSize=\"8\" stageHP=\"0\" >
        <gibs amount=\"0\" blood=\"0\" bone=\"0\" eye=\"0\" gut=\"0\" large=\"0\" />
    </entity>

	-- SUBTYPE
	<entity anm2path=\"WaxHeart.anm2\" baseHP=\"0\" boss=\"0\" champion=\"0\" collisionDamage=\"0\" collisionMass=\"3\" collisionRadius=\"12\" friction=\"1\" id=\"5\" name=\"Wax Heart\" numGridCollisionPoints=\"24\" shadowSize=\"17\" stageHP=\"0\" variant=\"10\">
	    <gibs amount=\"0\" blood=\"0\" bone=\"0\" eye=\"0\" gut=\"0\" large=\"0\" />
	</entity>
--]]