--[[
	DarkRP Modern HUD - Core Library
	Main HUD system with DHTML panel integration
]]--

DarkRPHUD = DarkRPHUD or {}
DarkRPHUD.Version = "1.4.0"
DarkRPHUD.Panel = nil
DarkRPHUD.Initialized = false
DarkRPHUD.TestMode = false

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
	self.Panel:SetPaintedManually(true) -- Critical: we'll paint it manually
	
	-- Load HTML
	local htmlPath = "asset://garrysmod/addons/gmod-darkrp-hud/html/hud.html"
	self.Panel:OpenURL(htmlPath)
	
	print("[DarkRP HUD] DHTML panel created: " .. scrW .. "x" .. scrH)
	print("[DarkRP HUD] Loading from: " .. htmlPath)
	
	-- Send initial data after a delay
	timer.Simple(2, function()
		if IsValid(self.Panel) then
			self:UpdateData()
			print("[DarkRP HUD] Initial data sent to HTML")
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
	Draw simple test HUD (without HTML)
]]--
local function DrawTestHUD()
	local ply = LocalPlayer()
	if not IsValid(ply) then return end
	
	local scrW, scrH = ScrW(), ScrH()
	
	-- Draw background
	draw.RoundedBox(8, 20, scrH - 200, 300, 180, Color(26, 26, 26, 240))
	
	-- Title
	draw.SimpleText("DarkRP HUD - TEST MODE", "DermaLarge", 30, scrH - 190, Color(90, 158, 229), TEXT_ALIGN_LEFT)
	
	-- Health
	draw.SimpleText("Здоровье: " .. ply:Health(), "DermaDefault", 30, scrH - 160, Color(236, 236, 236), TEXT_ALIGN_LEFT)
	
	-- Armor
	draw.SimpleText("Броня: " .. ply:Armor(), "DermaDefault", 30, scrH - 140, Color(90, 158, 229), TEXT_ALIGN_LEFT)
	
	-- Weapon
	local weapon = ply:GetActiveWeapon()
	if IsValid(weapon) then
		local ammo = weapon:Clip1() or 0
		local reserve = ply:GetAmmoCount(weapon:GetPrimaryAmmoType()) or 0
		draw.SimpleText("Патроны: " .. ammo .. " / " .. reserve, "DermaDefault", 30, scrH - 120, Color(236, 236, 236), TEXT_ALIGN_LEFT)
	end
	
	-- DarkRP info
	if DarkRP and type(ply.getDarkRPVar) == "function" then
		local job = ply:getDarkRPVar("job") or "Гражданин"
		local money = ply:getDarkRPVar("money") or 0
		draw.SimpleText("Работа: " .. job, "DermaDefault", 30, scrH - 100, Color(236, 236, 236), TEXT_ALIGN_LEFT)
		draw.SimpleText("Деньги: $" .. money, "DermaDefault", 30, scrH - 80, Color(90, 158, 229), TEXT_ALIGN_LEFT)
	end
	
	draw.SimpleText("Введите 'darkrp_hud_testmode' чтобы выключить", "DermaDefault", 30, scrH - 50, Color(150, 150, 150), TEXT_ALIGN_LEFT)
end

--[[
	Render hook - Draw the HUD
]]--
hook.Add("HUDPaint", "DarkRPHUD_Paint", function()
	if not DarkRPHUD.Config.Enabled then return end
	
	-- Test mode - draw simple HUD
	if DarkRPHUD.TestMode then
		DrawTestHUD()
		return
	end
	
	-- Create panel if it doesn't exist
	if not IsValid(DarkRPHUD.Panel) then
		DarkRPHUD:CreatePanel()
		return
	end
	
	-- Paint DHTML panel manually
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

concommand.Add("darkrp_hud_testmode", function()
	DarkRPHUD.TestMode = not DarkRPHUD.TestMode
	print("[DarkRP HUD] Test Mode: " .. (DarkRPHUD.TestMode and "ON (simple HUD)" or "OFF (HTML HUD)"))
end)

concommand.Add("darkrp_hud_debug", function()
	print("[DarkRP HUD] Debug Info:")
	print("  - Version: " .. DarkRPHUD.Version)
	print("  - Initialized: " .. tostring(DarkRPHUD.Initialized))
	print("  - Panel Valid: " .. tostring(IsValid(DarkRPHUD.Panel)))
	print("  - Config Enabled: " .. tostring(DarkRPHUD.Config.Enabled))
	print("  - Test Mode: " .. tostring(DarkRPHUD.TestMode))
	print("  - Screen Size: " .. ScrW() .. "x" .. ScrH())
	
	if IsValid(DarkRPHUD.Panel) then
		local x, y = DarkRPHUD.Panel:GetPos()
		local w, h = DarkRPHUD.Panel:GetSize()
		print("  - Panel Position: " .. x .. ", " .. y)
		print("  - Panel Size: " .. w .. "x" .. h)
		print("  - Panel Painted Manually: " .. tostring(DarkRPHUD.Panel:IsPaintedManually()))
		
		-- Send test data
		DarkRPHUD:UpdateData()
		print("  - Test data sent")
	end
	
	print("\nКоманды:")
	print("  - darkrp_hud_testmode - переключить простой HUD")
	print("  - darkrp_hud_reload - перезагрузить HTML HUD")
end)

concommand.Add("darkrp_hud_test_kill", function()
	if IsValid(DarkRPHUD.Panel) then
		DarkRPHUD:AddKill("ТЕСТЕР", "ЦЕЛЬ", "weapon_test")
		print("[DarkRP HUD] Тестовое убийство добавлено")
	else
		print("[DarkRP HUD] Панель не создана!")
	end
end)

return DarkRPHUD