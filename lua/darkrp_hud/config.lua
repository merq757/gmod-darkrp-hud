--[[
	DarkRP Modern HUD - Configuration
]]--

DarkRPHUD = DarkRPHUD or {}
DarkRPHUD.Config = {}

-- HUD Display Settings
DarkRPHUD.Config.Enabled = true
DarkRPHUD.Config.ShowDefaultHUD = false -- Hide default GMod HUD elements

-- Visual Settings
DarkRPHUD.Config.Scale = 1.0 -- HUD Scale multiplier
DarkRPHUD.Config.Theme = {
	PrimaryColor = "#5A9EE5",
	BackgroundColor = "#1A1A1A",
	TextColor = "#ECECEC",
	DangerColor = "#E55A5A"
}

-- Update Rates (in seconds)
DarkRPHUD.Config.UpdateRate = 0.1 -- How often to update HUD data

-- Animation Settings
DarkRPHUD.Config.Animations = {
	Enabled = true,
	Speed = 0.3
}

-- Debug Mode
DarkRPHUD.Config.Debug = false

return DarkRPHUD.Config