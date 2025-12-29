--[[
	DarkRP Modern HUD - Auto Initialization (FIXED)
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

-- FIXED: Better initialization logic
hook.Add("InitPostEntity", "DarkRPHUD_Initialize", function()
	timer.Simple(0.5, function()
		-- Check if LocalPlayer is valid
		local ply = LocalPlayer()
		if not IsValid(ply) then
			print("[DarkRP HUD] Waiting for player...")
			return
		end
		
		if DarkRPHUD and not DarkRPHUD.Initialized then
			DarkRPHUD:Initialize()
			print("[DarkRP HUD] Initialized via InitPostEntity")
		end
	end)
end)

-- Fallback initialization
hook.Add("HUDPaint", "DarkRPHUD_FallbackInit", function()
	if DarkRPHUD and not DarkRPHUD.Initialized then
		local ply = LocalPlayer()
		if IsValid(ply) and ply:IsPlayer() then
			DarkRPHUD:Initialize()
			print("[DarkRP HUD] Initialized via HUDPaint fallback")
			hook.Remove("HUDPaint", "DarkRPHUD_FallbackInit")
		end
	end
end)