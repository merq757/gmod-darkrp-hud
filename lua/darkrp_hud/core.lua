--[[
	DarkRP Modern HUD - Core Library
	Supports both Native Lua and DHTML rendering
]]--

DarkRPHUD = DarkRPHUD or {}
DarkRPHUD.Version = "2.1.0"
DarkRPHUD.Initialized = false
DarkRPHUD.Mode = "lua" -- "lua" or "dhtml"

-- Load configuration
if not DarkRPHUD.Config then
	include("darkrp_hud/config.lua")
end

-- Load modules
include("darkrp_hud/draw.lua")
include("darkrp_hud/dhtml.lua")

--[[
	Initialize the HUD system
]]--
function DarkRPHUD:Initialize()
	if self.Initialized then return end
	
	print("[DarkRP HUD] Initializing v" .. self.Version)
	print("[DarkRP HUD] Mode: " .. string.upper(self.Mode))
	
	-- Initialize based on mode
	if self.Mode == "dhtml" then
		if self.DHTML then
			self.DHTML:Create()
			self.DHTML:StartUpdateLoop()
		end
	end
	
	-- Hide default HUD elements
	if self.Config.ShowDefaultHUD == false then
		self:HideDefaultHUD()
	end
	
	self.Initialized = true
	
	print("[DarkRP HUD] Initialization complete")
end

--[[
	Switch rendering mode
]]--
function DarkRPHUD:SetMode(mode)
	if mode ~= "lua" and mode ~= "dhtml" then
		print("[DarkRP HUD] Invalid mode: " .. tostring(mode))
		return
	end
	
	-- Cleanup old mode
	if self.Mode == "dhtml" and self.DHTML then
		self.DHTML:Destroy()
	end
	
	self.Mode = mode
	self.Initialized = false
	
	-- Initialize new mode
	self:Initialize()
	
	print("[DarkRP HUD] Switched to " .. string.upper(mode) .. " mode")
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
	Render hook - Draw the HUD (Lua mode only)
]]--
hook.Add("HUDPaint", "DarkRPHUD_Paint", function()
	if not DarkRPHUD.Config.Enabled then return end
	if DarkRPHUD.Mode ~= "lua" then return end
	if not DarkRPHUD.Draw then return end
	
	DarkRPHUD.Draw:Paint()
end)

--[[
	Player death hook for killfeed
]]--
hook.Add("PlayerDeath", "DarkRPHUD_Killfeed", function(victim, inflictor, attacker)
	if not DarkRPHUD.Config.Enabled then return end
	
	local killerName = "World"
	local victimName = IsValid(victim) and victim:Nick() or "Unknown"
	
	if IsValid(attacker) and attacker:IsPlayer() then
		killerName = attacker:Nick()
	end
	
	-- Send to appropriate module
	if DarkRPHUD.Mode == "lua" and DarkRPHUD.Draw then
		DarkRPHUD.Draw:AddKill(killerName, victimName)
	elseif DarkRPHUD.Mode == "dhtml" and DarkRPHUD.DHTML then
		DarkRPHUD.DHTML:AddKill(killerName, victimName)
	end
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
	-- Cleanup
	if DarkRPHUD.DHTML then
		DarkRPHUD.DHTML:Destroy()
	end
	
	DarkRPHUD.Initialized = false
	
	-- Reload modules
	include("darkrp_hud/draw.lua")
	include("darkrp_hud/dhtml.lua")
	
	DarkRPHUD:Initialize()
	print("[DarkRP HUD] Reloaded!")
end)

concommand.Add("darkrp_hud_toggle", function()
	DarkRPHUD.Config.Enabled = not DarkRPHUD.Config.Enabled
	print("[DarkRP HUD] " .. (DarkRPHUD.Config.Enabled and "Enabled" or "Disabled"))
end)

concommand.Add("darkrp_hud_mode", function(ply, cmd, args)
	if #args == 0 then
		print("[DarkRP HUD] Current mode: " .. string.upper(DarkRPHUD.Mode))
		print("Usage: darkrp_hud_mode <lua|dhtml>")
		return
	end
	
	local mode = string.lower(args[1])
	DarkRPHUD:SetMode(mode)
end)

concommand.Add("darkrp_hud_debug", function()
	print("[DarkRP HUD] Debug Info:")
	print("  - Version: " .. DarkRPHUD.Version)
	print("  - Mode: " .. string.upper(DarkRPHUD.Mode))
	print("  - Initialized: " .. tostring(DarkRPHUD.Initialized))
	print("  - Config Enabled: " .. tostring(DarkRPHUD.Config.Enabled))
	print("  - Draw Module: " .. tostring(DarkRPHUD.Draw ~= nil))
	print("  - DHTML Module: " .. tostring(DarkRPHUD.DHTML ~= nil))
	
	if DarkRPHUD.Mode == "dhtml" and DarkRPHUD.DHTML then
		print("  - DHTML Panel Valid: " .. tostring(IsValid(DarkRPHUD.DHTML.Panel)))
		if IsValid(DarkRPHUD.DHTML.Panel) then
			local w, h = DarkRPHUD.DHTML.Panel:GetSize()
			print("  - DHTML Panel Size: " .. w .. "x" .. h)
			print("  - DHTML Panel Visible: " .. tostring(DarkRPHUD.DHTML.Panel:IsVisible()))
		end
	end
	
	print("  - Screen Size: " .. ScrW() .. "x" .. ScrH())
	print("\nКоманды:")
	print("  - darkrp_hud_mode <lua|dhtml> - переключить режим")
	print("  - darkrp_hud_reload - перезагрузить HUD")
end)

concommand.Add("darkrp_hud_test_kill", function()
	local success = false
	
	if DarkRPHUD.Mode == "lua" and DarkRPHUD.Draw then
		DarkRPHUD.Draw:AddKill("ТЕСТЕР", "ЦЕЛЬ")
		success = true
	elseif DarkRPHUD.Mode == "dhtml" and DarkRPHUD.DHTML then
		DarkRPHUD.DHTML:AddKill("ТЕСТЕР", "ЦЕЛЬ")
		success = true
	end
	
	if success then
		print("[DarkRP HUD] Тестовое убийство добавлено (" .. DarkRPHUD.Mode .. " mode)")
	else
		print("[DarkRP HUD] Ошибка: модуль не загружен!")
	end
end)

return DarkRPHUD