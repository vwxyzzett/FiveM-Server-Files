Config                            = {}
Config.DrawDistance               = 100.0
Config.MarkerColor                = { r = 120, g = 120, b = 240 }
Config.EnablePlayerManagement     = false -- enables the actual car dealer job. You'll need esx_addonaccount, esx_billing and esx_society
Config.EnableOwnedVehicles        = true
Config.EnableSocietyOwnedVehicles = false -- use with EnablePlayerManagement disabled, or else it wont have any effects
Config.ResellPercentage           = 50

Config.Locale                     = 'fr'

Config.LicenseEnable = false -- require people to own drivers license when buying vehicles? Only applies if EnablePlayerManagement is disabled. Requires esx_license

-- looks like this: 'LLL NNN'
-- The maximum plate length is 8 chars (including spaces & symbols), don't go past it!
Config.PlateLetters  = 3
Config.PlateNumbersStart  = 2
Config.PlateNumbersEnd  = 3
Config.PlateUseSpace = false

Config.Zones = {

	ShopEntering = {
		Pos   = { x = -47.15, y = -1081.89, z = 26.66 },
		Size  = { x = 1.0, y = 1.0, z = 1.0 },
		Type  = 20
	},

	ShopInside = {
		Pos     = { x = -50.63, y = -1077.64, z = 26.88 },
		Size    = { x = 1.5, y = 1.5, z = 1.0 },
		Heading = 71.0,
		Type    = -1
	},

	ShopOutside = {
		Pos     = { x = -50.63, y = -1077.64, z = 26.88 },
		Size    = { x = 1.5, y = 1.5, z = 1.0 },
		Heading = 71.0,
		Type    = -1
	},

	BossActions = {
		Pos   = { x = -32.065, y = -1114.277, z = 25.422 },
		Size  = { x = 1.5, y = 1.5, z = 1.0 },
		Type  = -1
	},

	GiveBackVehicle = {
		Pos   = { x = -18.227, y = -1078.558, z = 50.675 },
		Size  = { x = 3.0, y = 3.0, z = 1.0 },
		Type  = -1
	},

	ResellVehicle = {
		Pos   = { x = -44.630, y = -1080.738, z = 50.683 },
		Size  = { x = 3.0, y = 3.0, z = 1.0 },
		Type  = -1
	}

}
