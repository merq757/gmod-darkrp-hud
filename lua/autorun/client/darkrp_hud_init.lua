--[[
	DarkRP Modern HUD - Auto Initialization
	Client-side autorun file
]]--

print("[DarkRP HUD] Loading Modern HUD System...")

-- Include configuration first
include("darkrp_hud/config.lua")

-- Include core library
include("darkrp_hud/core.lua")

print("[DarkRP HUD] System loaded successfully!")

-- Hide default DarkRP HUD
hook.Add("HUDShouldDraw", "DarkRPHUD_HideDefaultDarkRP", function(name)
	local hideElements = {
		"DarkRP_HUD",
		"DarkRP_EntityDisplay",
		"DarkRP_LocalPlayerHUD",
		"DarkRP_Hungermod",
		"DarkRP_Agenda",
	}
	
	if table.HasValue(hideElements, name) then
		return false
	end
end)

-- Initialize HUD after DarkRP is fully loaded
if DarkRP then
	-- DarkRP is already loaded
	timer.Simple(0.5, function()
		if DarkRPHUD then
			DarkRPHUD:Initialize()
			print("[DarkRP HUD] Initialized immediately (DarkRP already loaded)")
		end
	end)
else
	-- Wait for DarkRP to load
	hook.Add("DarkRPFinishedLoading", "DarkRPHUD_DelayedInit", function()
		timer.Simple(1, function()
			if DarkRPHUD then
				DarkRPHUD:Initialize()
				print("[DarkRP HUD] Initialized after DarkRP loaded")
			end
		end)
	end)
end

-- Force initialization on player spawn if not initialized yet
hook.Add("PlayerInitialSpawn", "DarkRPHUD_PlayerSpawn", function(ply)
	if ply == LocalPlayer() then
		timer.Simple(2, function()
			if DarkRPHUD and not DarkRPHUD.Initialized then
				DarkRPHUD:Initialize()
				print("[DarkRP HUD] Force initialized on player spawn")
			end
		end)
	end
end)