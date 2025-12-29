--[[
	DarkRP Modern HUD - Core Library
	Main HUD system with DHTML panel integration
]]--

DarkRPHUD = DarkRPHUD or {}
DarkRPHUD.Version = "1.0.0"
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
	
	if self.Config.Debug then
		print("[DarkRP HUD] Initializing v" .. self.Version)
	end
	
	-- Create DHTML panel
	self:CreatePanel()
	
	-- Start update loop
	self:StartUpdateLoop()
	
	-- Hide default HUD elements
	if self.Config.ShowDefaultHUD == false then
		self:HideDefaultHUD()
	end
	
	self.Initialized = true
	
	if self.Config.Debug then
		print("[DarkRP HUD] Initialization complete")
	end
end

--[[
	Create DHTML panel for HUD
]]--
function DarkRPHUD:CreatePanel()
	if IsValid(self.Panel) then
		self.Panel:Remove()
	end
	
	local scrW, scrH = ScrW(), ScrH()
	
	self.Panel = vgui.Create("DHTML")
	self.Panel:SetPos(0, 0)
	self.Panel:SetSize(scrW, scrH)
	self.Panel:SetAllowLua(true)
	self.Panel:SetMouseInputEnabled(false)
	self.Panel:SetKeyboardInputEnabled(false)
	
	-- Load HUD HTML
	self.Panel:OpenURL("asset://garrysmod/html/hud.html")
	
	if self.Config.Debug then
		print("[DarkRP HUD] Panel created: " .. scrW .. "x" .. scrH)
	end
end

--[[
	Update HUD data
]]--
function DarkRPHUD:UpdateData()
	if not IsValid(self.Panel) then return end
	
	local ply = LocalPlayer()
	if not IsValid(ply) then return end
	
	local data = {
		health = ply:Health(),
		maxHealth = ply:GetMaxHealth(),
		armor = ply:Armor(),
		money = ply:getDarkRPVar("money") or 0,
		job = ply:getDarkRPVar("job") or "Гражданин",
		salary = ply:getDarkRPVar("salary") or 50,
		ammo = 0,
		ammoReserve = 0
	}
	
	-- Get weapon ammo
	local weapon = ply:GetActiveWeapon()
	if IsValid(weapon) then
		data.ammo = weapon:Clip1()
		data.ammoReserve = ply:GetAmmoCount(weapon:GetPrimaryAmmoType())
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
	Render hook
]]--
hook.Add("HUDPaint", "DarkRPHUD_Paint", function()
	if not DarkRPHUD.Config.Enabled then return end
	if not IsValid(DarkRPHUD.Panel) then
		DarkRPHUD:CreatePanel()
	end
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
		DarkRPHUD:Initialize()
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

return DarkRPHUD