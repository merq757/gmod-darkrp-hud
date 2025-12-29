--[[
	DarkRP Modern HUD - Core Library
	Main HUD system with DHTML panel integration
]]--

DarkRPHUD = DarkRPHUD or {}
DarkRPHUD.Version = "1.0.2"
DarkRPHUD.Panel = nil
DarkRPHUD.Initialized = false

-- Load configuration
if not DarkRPHUD.Config then
	include("darkrp_hud/config.lua")
end

--[[
	Initialize the HUD system
]]--
function DarkRPHUD:Initialize()
	if self.Initialized then return end
	
	print("[DarkRP HUD] Initializing v" .. self.Version)
	
	-- Create DHTML panel
	self:CreatePanel()
	
	-- Start update loop
	self:StartUpdateLoop()
	
	-- Hide default HUD elements
	if self.Config.ShowDefaultHUD == false then
		self:HideDefaultHUD()
	end
	
	self.Initialized = true
	
	print("[DarkRP HUD] Initialization complete")
end

--[[
	Create DHTML panel for HUD
]]--
function DarkRPHUD:CreatePanel()
	if IsValid(self.Panel) then
		self.Panel:Remove()
	end
	
	local scrW, scrH = ScrW(), ScrH()
	
	-- Create DHTML panel
	self.Panel = vgui.Create("DHTML")
	self.Panel:SetPos(0, 0)
	self.Panel:SetSize(scrW, scrH)
	self.Panel:SetAllowLua(true)
	self.Panel:SetMouseInputEnabled(false)
	self.Panel:SetKeyboardInputEnabled(false)
	
	-- Load HTML
	local htmlPath = "asset://garrysmod/addons/gmod-darkrp-hud/html/hud.html"
	self.Panel:OpenURL(htmlPath)
	
	print("[DarkRP HUD] Panel created: " .. scrW .. "x" .. scrH)
	print("[DarkRP HUD] Loading HTML from: " .. htmlPath)
	
	-- Send initial data after HTML loads
	timer.Simple(2, function()
		if IsValid(self.Panel) then
			self:UpdateData()
			print("[DarkRP HUD] Initial data sent")
		end
	end)
end

--[[
	Update HUD data
]]--
function DarkRPHUD:UpdateData()
	if not IsValid(self.Panel) then return end
	
	local ply = LocalPlayer()
	if not IsValid(ply) then return end
	
	-- Check if DarkRP is available
	local hasDarkRP = DarkRP and type(ply.getDarkRPVar) == "function"
	
	local data = {
		health = ply:Health(),
		maxHealth = ply:GetMaxHealth(),
		armor = ply:Armor(),
		money = hasDarkRP and (ply:getDarkRPVar("money") or 0) or 0,
		job = hasDarkRP and (ply:getDarkRPVar("job") or "Гражданин") or "Гражданин",
		salary = hasDarkRP and (ply:getDarkRPVar("salary") or 50) or 50,
		ammo = 0,
		ammoReserve = 0
	}
	
	-- Get weapon ammo
	local weapon = ply:GetActiveWeapon()
	if IsValid(weapon) then
		data.ammo = weapon:Clip1() or 0
		data.ammoReserve = ply:GetAmmoCount(weapon:GetPrimaryAmmoType()) or 0
	end
	
	-- Send data to HTML panel
	local jsonData = util.TableToJSON(data)
	self.Panel:Call("updateHUD(" .. jsonData .. ")")
end

--[[
	Add kill to killfeed
]]--
function DarkRPHUD:AddKill(killer, victim, weapon)
	if not IsValid(self.Panel) then return end
	
	local killData = util.TableToJSON({
		killer = killer or "Unknown",
		victim = victim or "Unknown",
		weapon = weapon or ""
	})
	
	self.Panel:Call("addKill(" .. killData .. ")")
end

--[[
	Start update loop
]]--
function DarkRPHUD:StartUpdateLoop()
	timer.Create("DarkRPHUD_Update", self.Config.UpdateRate, 0, function()
		if not self.Config.Enabled then return end
		self:UpdateData()
	end)
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
	Render hook - Draw the HUD panel every frame
]]--
hook.Add("HUDPaint", "DarkRPHUD_Paint", function()
	if not DarkRPHUD.Config.Enabled then return end
	
	-- Create panel if it doesn't exist
	if not IsValid(DarkRPHUD.Panel) then
		DarkRPHUD:CreatePanel()
		return
	end
	
	-- Draw the DHTML panel manually
	local scrW, scrH = ScrW(), ScrH()
	
	-- Method 1: Try PaintManual
	DarkRPHUD.Panel:SetPaintedManually(true)
	DarkRPHUD.Panel:SetPos(0, 0)
	DarkRPHUD.Panel:SetSize(scrW, scrH)
	DarkRPHUD.Panel:PaintManual()
end)

--[[
	Player death hook for killfeed
]]--
hook.Add("PlayerDeath", "DarkRPHUD_Killfeed", function(victim, inflictor, attacker)
	if not DarkRPHUD.Config.Enabled then return end
	
	local killerName = "World"
	local victimName = IsValid(victim) and victim:Nick() or "Unknown"
	local weaponName = ""
	
	if IsValid(attacker) and attacker:IsPlayer() then
		killerName = attacker:Nick()
		
		if IsValid(inflictor) and inflictor:IsWeapon() then
			weaponName = inflictor:GetClass()
		end
	end
	
	DarkRPHUD:AddKill(killerName, victimName, weaponName)
end)

--[[
	Initialize when player spawns
]]--
hook.Add("InitPostEntity", "DarkRPHUD_Init", function()
	timer.Simple(1, function()
		if not DarkRPHUD.Initialized then
			DarkRPHUD:Initialize()
		end
	end)
end)

-- Console commands
concommand.Add("darkrp_hud_reload", function()
	if IsValid(DarkRPHUD.Panel) then
		DarkRPHUD.Panel:Remove()
	end
	DarkRPHUD.Initialized = false
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
	print("  - Panel Valid: " .. tostring(IsValid(DarkRPHUD.Panel)))
	print("  - Config Enabled: " .. tostring(DarkRPHUD.Config.Enabled))
	
	if IsValid(DarkRPHUD.Panel) then
		local x, y = DarkRPHUD.Panel:GetPos()
		local w, h = DarkRPHUD.Panel:GetSize()
		print("  - Panel Position: " .. x .. ", " .. y)
		print("  - Panel Size: " .. w .. "x" .. h)
		print("  - Screen Size: " .. ScrW() .. "x" .. ScrH())
		print("  - Panel Visible: " .. tostring(DarkRPHUD.Panel:IsVisible()))
		print("  - Panel Alpha: " .. DarkRPHUD.Panel:GetAlpha())
		
		-- Try to trigger a manual update
		DarkRPHUD:UpdateData()
		print("  - Sent test data to panel")
	end
end)

concommand.Add("darkrp_hud_test_kill", function()
	if IsValid(DarkRPHUD.Panel) then
		DarkRPHUD:AddKill("TEST_KILLER", "TEST_VICTIM", "weapon_test")
		print("[DarkRP HUD] Test kill added to killfeed")
	else
		print("[DarkRP HUD] Panel not valid!")
	end
end)

return DarkRPHUD