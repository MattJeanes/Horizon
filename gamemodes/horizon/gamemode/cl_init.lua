include('shared.lua')

DEFINE_BASECLASS( "gamemode_sandbox" )

surface.CreateFont( "PixelFont", {
	font		= "Arial",
	size 		= 16,
	weight 		= 0,
	blursize 	= 0,
	scanlines 	= 0,
	antialias 	= false,
	underline 	= false,
	italic 		= false,
	strikeout 	= false,
	symbol 		= false,
	rotary 		= false,
	shadow 		= false,
	additive 	= false,
	outline 	= false
} )

local FactoryEntries = {}

local TextColor = Color( 255, 255, 255, 255)
local BarMaterial = Material("horizon/bar.png")
local Font = "PixelFont"

local panel_w = 256
local panel_h = 32
local offset = 8
local bar_w = panel_w - ( 2 * offset )
local bar_h = panel_h / 2

-- available suit resources
local SuitValues = {}
	SuitValues['coolant'] = {}
		SuitValues['coolant'].DisplayName = "Coolant"
		SuitValues['coolant'].DisplayColor = Color( 0, 150, 200, 255 )
		SuitValues['coolant'].Amount = 0
		SuitValues['coolant'].MaxAmount = 200
	SuitValues['air'] = {}
		SuitValues['air'].DisplayName = "Air"
		SuitValues['air'].DisplayColor = Color( 0, 200, 0, 255 )
		SuitValues['air'].Amount = 0
		SuitValues['air'].MaxAmount = 200
	SuitValues['energy'] = {}
		SuitValues['energy'].DisplayName = "Energy"
		SuitValues['energy'].DisplayColor = Color( 255, 200, 0, 255 )
		SuitValues['energy'].Amount = 0
		SuitValues['energy'].MaxAmount = 200

-- available player resources
local PlayerValues = {}
	PlayerValues['armor'] = {}
		PlayerValues['armor'].DisplayName = "Armor"
		PlayerValues['armor'].DisplayColor = Color( 255, 128, 0, 255 )
		PlayerValues['armor'].Amount = 0
		PlayerValues['armor'].MaxAmount = 100
	PlayerValues['health'] = {}
		PlayerValues['health'].DisplayName = "Health"
		PlayerValues['health'].DisplayColor = Color( 230, 16, 24, 255 )
		PlayerValues['health'].Amount = 100
		PlayerValues['health'].MaxAmount = 100

-- TODO: modify hznSuit to transmit a table instead?
net.Receive('hznSuit', function()
	SuitValues['air'].Amount = net.ReadUInt(8)
	SuitValues['coolant'].Amount = net.ReadUInt(8)
	SuitValues['energy'].Amount = net.ReadUInt(8)
end)

-- HUD related methods

function GM:HUDPaint()
	if self.BaseClass then self.BaseClass:HUDPaint() end
	-- update player values
	local ply = LocalPlayer()
	PlayerValues['health'].Amount = ply:Health()
	PlayerValues['armor'].Amount = ply:Armor()
	-- draw tables
	self:DrawTable( offset, ScrH() - offset, PlayerValues )
	self:DrawTable( ScrW() - offset - panel_w, ScrH() - offset, SuitValues )
	return
end

--	(x,y) point to bottom left corner
function GM:DrawTable( x, y, tab )
	local bar_x = x + offset
	surface.SetMaterial( BarMaterial )
	local c = 1
	for _, info in pairs( tab ) do
		-- background bar
		surface.SetDrawColor( 128, 128, 128, 255 )
		local panel_y = y - ( c * panel_h )
		surface.DrawTexturedRect( x, panel_y, panel_w, panel_h )
		-- foreground bar
		surface.SetDrawColor( info.DisplayColor )
		local bar_y = panel_y + ( bar_h / 2 )
		local ratio = info.Amount / info.MaxAmount
		surface.DrawRect( bar_x, bar_y , ratio * bar_w, bar_h )
		-- text
		local txt = info.DisplayName .. ": " .. info.Amount .. "/" .. info.MaxAmount
		draw.SimpleText( txt, Font, bar_x + offset, bar_y, TextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
		c = c + 1
	end
end

function GM:HUDShouldDraw(name)
	return not ( name == 'CHudHealth' || name == 'CHudBattery' || name == 'CHudAmmo' ||	name == 'CHudSecondaryAmmo' )
end

-- Factory / Replicator related fields

function GM:RegisterFactoryEntry( FactoryEntry )
	FactoryEntries[FactoryEntry.DisplayName] = FactoryEntry
end

function GM:GetFactoryEntries()
	return FactoryEntries
end