--[[
	DarkRP Modern HUD - Native Drawing
	Pure Lua rendering without HTML
]]--

DarkRPHUD = DarkRPHUD or {}
DarkRPHUD.Draw = {}

-- Colors
local COLOR_PRIMARY = Color(90, 158, 229)
local COLOR_BG = Color(26, 26, 26, 240)
local COLOR_TEXT = Color(236, 236, 236)
local COLOR_GRAY = Color(154, 154, 154)
local COLOR_DANGER = Color(229, 90, 90)
local COLOR_BLACK = Color(0, 0, 0, 150)

-- Fonts
surface.CreateFont("DRP_Huge", {
	font = "Arial",
	size = 56,
	weight = 900,
	italic = true
})

surface.CreateFont("DRP_Large", {
	font = "Arial",
	size = 48,
	weight = 900,
	italic = true
})

surface.CreateFont("DRP_Medium", {
	font = "Arial",
	size = 36,
	weight = 900,
	italic = true
})

surface.CreateFont("DRP_Normal", {
	font = "Arial",
	size = 18,
	weight = 900,
	italic = true
})

surface.CreateFont("DRP_Small", {
	font = "Arial",
	size = 14,
	weight = 700
})

surface.CreateFont("DRP_Tiny", {
	font = "Arial",
	size = 10,
	weight = 900
})

--[[
	Draw rounded box with border
]]--
local function DrawBox(x, y, w, h, bg, border)
	draw.RoundedBox(0, x, y, w, h, bg)
	if border then
		surface.SetDrawColor(border)
		surface.DrawOutlinedRect(x, y, w, h)
	end
end

--[[
	Draw progress bar
]]--
local function DrawBar(x, y, w, h, percent, color)
	-- Background
	draw.RoundedBox(0, x, y, w, h, COLOR_BLACK)
	
	-- Fill
	local fillW = w * (percent / 100)
	draw.RoundedBox(0, x, y, fillW, h, color)
end

--[[
	Draw Health & Armor (Bottom Left)
]]--
function DarkRPHUD.Draw:Vitals(ply)
	local scrW, scrH = ScrW(), ScrH()
	local x, y = 40, scrH - 200
	local w, h = 400, 160
	
	-- Background
	DrawBox(x, y, w, h, COLOR_BG, Color(255, 255, 255, 10))
	
	-- Health Section
	local health = ply:Health()
	local maxHealth = ply:GetMaxHealth()
	local healthPercent = math.Clamp((health / maxHealth) * 100, 0, 100)
	local healthColor = healthPercent < 25 and COLOR_DANGER or COLOR_TEXT
	
	-- Health label
	draw.SimpleText("HEALTH_CORE", "DRP_Tiny", x + 20, y + 15, COLOR_GRAY, TEXT_ALIGN_LEFT)
	
	-- Health value
	draw.SimpleText(math.floor(healthPercent), "DRP_Large", x + w - 80, y + 10, healthColor, TEXT_ALIGN_RIGHT)
	draw.SimpleText("%", "DRP_Small", x + w - 75, y + 35, Color(255, 255, 255, 80), TEXT_ALIGN_LEFT)
	
	-- Health bar
	DrawBar(x + 20, y + 70, w - 180, 6, healthPercent, healthColor)
	
	-- Armor Section
	local armor = ply:Armor()
	
	-- Armor label
	draw.SimpleText("SHIELD", "DRP_Tiny", x + 20, y + 95, COLOR_PRIMARY, TEXT_ALIGN_LEFT)
	
	-- Armor value
	draw.SimpleText(math.floor(armor), "DRP_Normal", x + w - 80, y + 90, COLOR_PRIMARY, TEXT_ALIGN_RIGHT)
	
	-- Armor bar
	DrawBar(x + 20, y + 120, w - 180, 4, armor, COLOR_PRIMARY)
end

--[[
	Draw Money (Bottom Left)
]]--
function DarkRPHUD.Draw:Money(ply)
	local scrW, scrH = ScrW(), ScrH()
	local x, y = 40, scrH - 380
	local w, h = 300, 80
	
	local hasDarkRP = DarkRP and type(ply.getDarkRPVar) == "function"
	local money = hasDarkRP and (ply:getDarkRPVar("money") or 0) or 0
	
	-- Background with left border
	DrawBox(x, y, w, h, COLOR_BG)
	draw.RoundedBox(0, x, y, 6, h, COLOR_PRIMARY)
	
	-- Label
	draw.SimpleText("CASH_ASSETS", "DRP_Tiny", x + 20, y + 15, Color(255, 255, 255, 100), TEXT_ALIGN_LEFT)
	
	-- Money symbol
	draw.SimpleText("$", "DRP_Normal", x + 20, y + 35, COLOR_PRIMARY, TEXT_ALIGN_LEFT)
	
	-- Money amount
	draw.SimpleText(string.Comma(money), "DRP_Medium", x + 45, y + 30, COLOR_TEXT, TEXT_ALIGN_LEFT)
end

--[[
	Draw Job (Bottom Left)
]]--
function DarkRPHUD.Draw:Job(ply)
	local scrW, scrH = ScrW(), ScrH()
	local x, y = 40, scrH - 480
	local w, h = 400, 80
	
	local hasDarkRP = DarkRP and type(ply.getDarkRPVar) == "function"
	local job = hasDarkRP and (ply:getDarkRPVar("job") or "Гражданин") or "Гражданин"
	local salary = hasDarkRP and (ply:getDarkRPVar("salary") or 50) or 50
	
	-- Tag
	local tagW, tagH = 120, 16
	draw.RoundedBox(0, x, y, tagW, tagH, COLOR_PRIMARY)
	draw.SimpleText("ID_PROFILE", "DRP_Tiny", x + tagW/2, y + 3, COLOR_BLACK, TEXT_ALIGN_CENTER)
	
	-- Divider line
	draw.RoundedBox(0, x + tagW + 8, y + 7, w - tagW - 8, 1, Color(255, 255, 255, 25))
	
	-- Job card
	DrawBox(x, y + 20, w, 55, COLOR_BG, Color(255, 255, 255, 10))
	
	-- Job label
	draw.SimpleText("Current_Role", "DRP_Tiny", x + 15, y + 28, COLOR_GRAY, TEXT_ALIGN_LEFT)
	
	-- Job name
	draw.SimpleText(string.upper(job), "DRP_Normal", x + 15, y + 42, COLOR_PRIMARY, TEXT_ALIGN_LEFT)
	
	-- Salary label
	draw.SimpleText("Paycheck", "DRP_Tiny", x + w - 15, y + 28, COLOR_GRAY, TEXT_ALIGN_RIGHT)
	
	-- Salary value
	draw.SimpleText("$" .. salary, "DRP_Small", x + w - 15, y + 50, COLOR_TEXT, TEXT_ALIGN_RIGHT)
end

--[[
	Draw Ammo (Bottom Right)
]]--
function DarkRPHUD.Draw:Ammo(ply)
	local scrW, scrH = ScrW(), ScrH()
	local w, h = 220, 100
	local x, y = scrW - w - 40, scrH - 140
	
	local weapon = ply:GetActiveWeapon()
	if not IsValid(weapon) then return end
	
	local ammo = weapon:Clip1() or 0
	local reserve = ply:GetAmmoCount(weapon:GetPrimaryAmmoType()) or 0
	
	if ammo < 0 then return end
	
	-- Background with right border
	DrawBox(x, y, w, h, COLOR_BG)
	draw.RoundedBox(0, x + w - 6, y, 6, h, COLOR_TEXT)
	
	-- Label
	draw.SimpleText("Ammo_Inventory", "DRP_Tiny", x + w - 15, y + 15, COLOR_GRAY, TEXT_ALIGN_RIGHT)
	
	-- Current ammo
	local ammoColor = ammo <= 5 and COLOR_DANGER or COLOR_TEXT
	draw.SimpleText(ammo, "DRP_Huge", x + w - 130, y + 25, ammoColor, TEXT_ALIGN_RIGHT)
	
	-- Divider
	draw.RoundedBox(0, x + w - 115, y + 45, 1, 40, Color(255, 255, 255, 25))
	
	-- Reserve label
	draw.SimpleText("RESERVE", "DRP_Tiny", x + w - 15, y + 45, Color(255, 255, 255, 128), TEXT_ALIGN_RIGHT)
	
	-- Reserve ammo
	local reserveColor = reserve <= 20 and COLOR_DANGER or Color(255, 255, 255, 128)
	draw.SimpleText(reserve, "DRP_Small", x + w - 15, y + 65, reserveColor, TEXT_ALIGN_RIGHT)
end

--[[
	Draw Killfeed (Top Right)
]]--
DarkRPHUD.Draw.Kills = {}

function DarkRPHUD.Draw:AddKill(killer, victim)
	table.insert(self.Kills, 1, {
		killer = killer,
		victim = victim,
		time = CurTime()
	})
	
	-- Keep only last 5
	while #self.Kills > 5 do
		table.remove(self.Kills)
	end
end

function DarkRPHUD.Draw:Killfeed()
	local scrW, scrH = ScrW(), ScrH()
	local x, y = scrW - 380, 40
	
	-- Title
	draw.SimpleText("KINETIC_FEED", "DRP_Tiny", x + 370, y, Color(90, 158, 229, 128), TEXT_ALIGN_RIGHT)
	
	-- Draw kills
	local offsetY = y + 25
	for i, kill in ipairs(self.Kills) do
		local age = CurTime() - kill.time
		if age > 5 then continue end
		
		local alpha = math.Clamp(255 - (age * 50), 0, 255)
		local w, h = 350, 28
		
		-- Background
		DrawBox(x, offsetY, w, h, Color(26, 26, 26, alpha * 0.7))
		
		-- Right border
		draw.RoundedBox(0, x + w - 4, offsetY, 4, h, Color(90, 158, 229, alpha))
		
		-- Killer name (blue bg)
		local killerW = 100
		draw.RoundedBox(0, x, offsetY, killerW, h, Color(90, 158, 229, alpha))
		draw.SimpleText(string.upper(kill.killer), "DRP_Tiny", x + killerW/2, offsetY + 9, Color(26, 26, 26, alpha), TEXT_ALIGN_CENTER)
		
		-- Action text
		draw.SimpleText("ELIMINATED", "DRP_Tiny", x + killerW + 15, offsetY + 9, Color(154, 154, 154, alpha * 0.7), TEXT_ALIGN_LEFT)
		
		-- Victim name
		draw.SimpleText(string.upper(kill.victim), "DRP_Small", x + w - 15, offsetY + 7, Color(236, 236, 236, alpha), TEXT_ALIGN_RIGHT)
		
		offsetY = offsetY + h + 8
	end
end

--[[
	Main Draw Function
]]--
function DarkRPHUD.Draw:Paint()
	local ply = LocalPlayer()
	if not IsValid(ply) then return end
	
	-- Draw all components
	self:Vitals(ply)
	self:Money(ply)
	self:Job(ply)
	self:Ammo(ply)
	self:Killfeed()
end

return DarkRPHUD.Draw