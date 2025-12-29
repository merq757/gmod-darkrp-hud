--[[
	DarkRP Modern HUD - DHTML Implementation
	Proper way to use HTML in GMod HUD
]]--

DarkRPHUD = DarkRPHUD or {}
DarkRPHUD.DHTML = {}
DarkRPHUD.DHTML.Panel = nil

--[[
	Create DHTML panel (the RIGHT way)
]]--
function DarkRPHUD.DHTML:Create()
	if IsValid(self.Panel) then
		self.Panel:Remove()
	end
	
	local scrW, scrH = ScrW(), ScrH()
	
	-- Create DHTML panel
	self.Panel = vgui.Create("DHTML")
	self.Panel:SetPos(0, 0)
	self.Panel:SetSize(scrW, scrH)
	self.Panel:SetMouseInputEnabled(false)
	self.Panel:SetKeyboardInputEnabled(false)
	
	-- CRITICAL: Don't use SetPaintedManually, let it paint itself
	self.Panel:SetPaintedManually(false)
	
	-- Make it always on top but allow clicks to pass through
	self.Panel:SetZPos(32767)
	
	-- Override Think to keep it always visible and on top
	self.Panel.Think = function(pnl)
		if not DarkRPHUD.Config.Enabled then
			pnl:SetVisible(false)
			return
		end
		
		pnl:SetVisible(true)
		pnl:MoveToFront()
		
		-- Keep size synced with screen
		local w, h = ScrW(), ScrH()
		if pnl:GetWide() ~= w or pnl:GetTall() ~= h then
			pnl:SetSize(w, h)
		end
	end
	
	-- Load HTML
	local htmlPath = "asset://garrysmod/addons/gmod-darkrp-hud/html/hud.html"
	self.Panel:OpenURL(htmlPath)
	
	print("[DarkRP HUD] DHTML panel created (VGUI mode): " .. scrW .. "x" .. scrH)
	print("[DarkRP HUD] Loading from: " .. htmlPath)
	
	-- Send initial data
	timer.Simple(2, function()
		if IsValid(self.Panel) then
			self:UpdateData()
			print("[DarkRP HUD] Initial data sent to DHTML")
		end
	end)
end

--[[
	Update HUD data
]]--
function DarkRPHUD.DHTML:UpdateData()
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
function DarkRPHUD.DHTML:AddKill(killer, victim, weapon)
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
function DarkRPHUD.DHTML:StartUpdateLoop()
	timer.Create("DarkRPHUD_DHTML_Update", 0.1, 0, function()
		if not DarkRPHUD.Config.Enabled then return end
		self:UpdateData()
	end)
end

--[[
	Stop update loop
]]--
function DarkRPHUD.DHTML:StopUpdateLoop()
	timer.Remove("DarkRPHUD_DHTML_Update")
end

--[[
	Destroy panel
]]--
function DarkRPHUD.DHTML:Destroy()
	if IsValid(self.Panel) then
		self.Panel:Remove()
		self.Panel = nil
	end
	self:StopUpdateLoop()
end

return DarkRPHUD.DHTML