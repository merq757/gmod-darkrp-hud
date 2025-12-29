--[[
	DarkRP Modern HUD - Core Library
	Native Lua rendering
]]--

DarkRPHUD = DarkRPHUD or {}
DarkRPHUD.Version = "2.0.0"
DarkRPHUD.Initialized = false

-- Load configuration
if not DarkRPHUD.Config then
	include("darkrp_hud/config.lua")
end

-- Load drawing module
include("darkrp_hud/draw.lua")

--[[
	Initialize the HUD system
]]--
function DarkRPHUD:Initialize()
	if self.Initialized then return end
	
	print("[DarkRP HUD] Initializing v" .. self.Version .. " (Native Lua)")
	
	-- Hide default HUD elements
	if self.Config.ShowDefaultHUD == false then
		self:HideDefaultHUD()
	end
	
	self.Initialized = true
	
	print("[DarkRP HUD] Initialization complete")
end

--[[
	Hide default HUD elements
]]--
function DarkRPHUD:HideDefaultHUD()
	local hideElements = {
		"CHudHealth",
		"CHudBattery",
		"CHudAmmo",
		"CHudSecondaryAmmo",
		"CHudDamageIndicator"
	}
	
	hook.Add("HUDShouldDraw", "DarkRPHUD_HideDefault", function(name)
		if table.HasValue(hideElements, name) then
			return false
		end
	end)
end

--[[
	Render hook - Draw the HUD
]]--
hook.Add("HUDPaint", "DarkRPHUD_Paint", function()
	if not DarkRPHUD.Config.Enabled then return end
	if not DarkRPHUD.Draw then return end
	
	DarkRPHUD.Draw:Paint()
end)

--[[
	Player death hook for killfeed
]]--
hook.Add("PlayerDeath", "DarkRPHUD_Killfeed", function(victim, inflictor, attacker)
	if not DarkRPHUD.Config.Enabled then return end
	if not DarkRPHUD.Draw then return end
	
	local killerName = "World"
	local victimName = IsValid(victim) and victim:Nick() or "Unknown"
	
	if IsValid(attacker) and attacker:IsPlayer() then
		killerName = attacker:Nick()
	end
	
	DarkRPHUD.Draw:AddKill(killerName, victimName)
end)

--[[
	Initialize when player spawns
]]--
hook.Add("InitPostEntity", "DarkRPHUD_Init", function()
	timer.Simple(0.5, function()
		if not DarkRPHUD.Initialized then
			DarkRPHUD:Initialize()
		end
	end)
end)

-- Console commands
concommand.Add("darkrp_hud_reload", function()
	DarkRPHUD.Initialized = false
	include("darkrp_hud/draw.lua")
	DarkRPHUD:Initialize()
	print("[DarkRP HUD] Reloaded!")
end)

concommand.Add("darkrp_hud_toggle", function()
	DarkRPHUD.Config.Enabled = not DarkRPHUD.Config.Enabled
	print("[DarkRP HUD] " .. (DarkRPHUD.Config.Enabled and "Enabled" or "Disabled"))
end)

concommand.Add("darkrp_hud_debug", function()
	print("[DarkRP HUD] Debug Info:")
	print("  - Version: " .. DarkRPHUD.Version)
	print("  - Initialized: " .. tostring(DarkRPHUD.Initialized))
	print("  - Config Enabled: " .. tostring(DarkRPHUD.Config.Enabled))
	print("  - Draw Module: " .. tostring(DarkRPHUD.Draw ~= nil))
	print("  - Screen Size: " .. ScrW() .. "x" .. ScrH())
end)

concommand.Add("darkrp_hud_test_kill", function()
	if DarkRPHUD.Draw then
		DarkRPHUD.Draw:AddKill("ТЕСТЕР", "ЦЕЛЬ")
		print("[DarkRP HUD] Тестовое убийство добавлено")
	else
		print("[DarkRP HUD] Draw модуль не загружен!")
	end
end)

return DarkRPHUD