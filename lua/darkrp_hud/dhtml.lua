--[[
	DarkRP Modern HUD - DHTML Implementation
	Fixed version with proper initialization
]]--

DarkRPHUD = DarkRPHUD or {}
DarkRPHUD.DHTML = {}
DarkRPHUD.DHTML.Panel = nil

--[[
	Create DHTML panel (FIXED)
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
	
	-- Let VGUI paint it automatically
	self.Panel:SetPaintedManually(false)
	
	-- Make it always on top
	self.Panel:SetZPos(32767)
	
	-- Override Think to keep it visible
	self.Panel.Think = function(pnl)
		if not DarkRPHUD or not DarkRPHUD.Config or not DarkRPHUD.Config.Enabled then
			pnl:SetVisible(false)
			return
		end
		
		pnl:SetVisible(true)
		pnl:MoveToFront()
		
		-- Keep size synced
		local w, h = ScrW(), ScrH()
		if pnl:GetWide() ~= w or pnl:GetTall() ~= h then
			pnl:SetSize(w, h)
		end
	end
	
	-- CRITICAL FIX: Correct path without 'addons/' prefix
	-- GMod automatically searches in addon folders
	local htmlPath = "asset://garrysmod/html/hud.html"
	
	-- Try to load HTML
	local success = pcall(function()
		self.Panel:OpenURL(htmlPath)
	end)
	
	if not success then
		print("[DarkRP HUD] ERROR: Failed to load HTML!")
		print("[DarkRP HUD] Try using: darkrp_hud_mode lua")
		return
	end
	
	print("[DarkRP HUD] DHTML panel created: " .. scrW .. "x" .. scrH)
	print("[DarkRP HUD] Loading: " .. htmlPath)
	
	-- Send initial data after HTML loads
	timer.Simple(1, function()
		if IsValid(self.Panel) then
			self:UpdateData()
			print("[DarkRP HUD] Initial data sent")
		end
	end)
end

--[[
	Update HUD data (FIXED with LocalPlayer check)
]]--
function DarkRPHUD.DHTML:UpdateData()
	if not IsValid(self.Panel) then return end
	
	-- CRITICAL FIX: Check LocalPlayer() exists
	local ply = LocalPlayer()
	if not IsValid(ply) or not ply:IsPlayer() then return end
	
	-- Check DarkRP availability
	local hasDarkRP = DarkRP and type(ply.getDarkRPVar) == "function"
	
	local data = {
		health = math.max(0, ply:Health()),
		maxHealth = ply:GetMaxHealth(),
		armor = math.max(0, ply:Armor()),
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
	
	-- Send to HTML panel
	local success, jsonData = pcall(util.TableToJSON, data)
	if success then
		self.Panel:Call("updateHUD(" .. jsonData .. ")")
	end
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
		if not IsValid(self.Panel) then return end
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
	Destroy panel safely
]]--
function DarkRPHUD.DHTML:Destroy()
	self:StopUpdateLoop()
	
	if IsValid(self.Panel) then
		self.Panel:Remove()
		self.Panel = nil
	end
end

return DarkRPHUD.DHTML