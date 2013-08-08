include('shared.lua')

DEFINE_BASECLASS( "gamemode_sandbox" )

local font_size = 24

surface.CreateFont( "PixelFont", {
	--font 		= "04b03",
	font		= "Arial",
	size 		= font_size,
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

local TextColor = Color( 255, 255, 255, 100)
local BarMaterial = Material("Horizon/grad.png")

-- available resources
local SuitValues = {}
	SuitValues['coolant'] = {}
		SuitValues['coolant'].DisplayName = "Coolant"
		SuitValues['coolant'].DisplayFont = "PixelFont"
		SuitValues['coolant'].DisplayColor = Color( 0, 153, 204, 255 )
		SuitValues['coolant'].Amount = 0
		SuitValues['coolant'].MaxAmount = 200
	SuitValues['air'] = {}
		SuitValues['air'].DisplayName = "Air"
		SuitValues['air'].DisplayFont = "PixelFont"
		SuitValues['air'].DisplayColor = Color( 0, 204, 0, 255 )
		SuitValues['air'].Amount = 0
		SuitValues['air'].MaxAmount = 200
	SuitValues['energy'] = {}
		SuitValues['energy'].DisplayName = "Energy"
		SuitValues['energy'].DisplayFont = "PixelFont"
		SuitValues['energy'].DisplayColor = Color( 255, 205, 0, 255 )
		SuitValues['energy'].Amount = 0
		SuitValues['energy'].MaxAmount = 200
--
local PlayerValues = {}
	PlayerValues['armor'] = {}
		PlayerValues['armor'].DisplayName = "Armor"
		PlayerValues['armor'].DisplayFont = "PixelFont"
		PlayerValues['armor'].DisplayColor = Color( 255, 128, 0, 255 )
		PlayerValues['armor'].Amount = 0
		PlayerValues['armor'].MaxAmount = 100
	PlayerValues['health'] = {}
		PlayerValues['health'].DisplayName = "Health"
		PlayerValues['health'].DisplayFont = "PixelFont"
		PlayerValues['health'].DisplayColor = Color( 231, 17, 21, 255 )
		PlayerValues['health'].Amount = 100
		PlayerValues['health'].MaxAmount = 100
--

-- Draws a bar at the given coordinates
function GM:DrawBar( x, y, w, h, info )
	surface.SetDrawColor( info.DisplayColor ) 
	surface.SetMaterial( BarMaterial )
	local ratio = math.Clamp( info.Amount, 0, info.MaxAmount ) / info.MaxAmount
	surface.DrawTexturedRect( x, y, w * ratio, h )
	local x_offset = 8
	local y_offset = 8
	draw.SimpleText( info.DisplayName, info.DisplayFont, x + x_offset, y + y_offset, TextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)	
end

-- Draws the given table at position (x,y)
function GM:DrawPanel( x, y, w, h, tab )
	surface.SetDrawColor( 128, 128, 128, 255 ) 
	surface.SetMaterial( BarMaterial )
	surface.DrawTexturedRect( x, y, w, h )
	local x_offset = 8
	local y_offset = 8
	local step_size = h / table.Count( tab )
	-- determine starting pos of list
	local start_y = y + h - step_size
	for k, v in pairs( tab ) do
		self:DrawBar( x + x_offset, start_y, w - 2 * x_offset, step_size - 2 * y_offset, v )
		start_y = start_y - (step_size - 2 * y_offset)
	end
end

function GM:HUDPaint()
	-- Sandbox stuff.
	if self.BaseClass then self.BaseClass:HUDPaint() end
	-- update player values
	local ply = LocalPlayer()
	PlayerValues['health'].Amount = ply:Health()
	PlayerValues['armor'].Amount = ply:Armor()
	-- how much space to leave out
	local x_offset = 8
	local y_offset = 8
	self:DrawTable( x_offset, ScrH() - y_offset, TEXT_ALIGN_LEFT, PlayerValues )
	self:DrawTable( ScrW() - x_offset, ScrH() - y_offset, TEXT_ALIGN_RIGHT, SuitValues )
	return
end

--
--	(x,y) point to bottom left corner
--
function GM:DrawTable( x, y, align, tab )
	local x_offset = 8
	if align == TEXT_ALIGN_RIGHT then x_offset = -x_offset end
	local y_offset = font_size
	-- start printing entries to screen
	local c = 1
	for k, info in pairs( tab ) do
		draw.SimpleText( info.DisplayName .. ": " .. info.Amount .. "/" .. info.MaxAmount, info.DisplayFont, x + x_offset, y - ( c * y_offset ), TextColor, align, align)
		c = c + 1
	end
end

function GM:HUDShouldDraw(name)
	return not ( name == 'CHudHealth' || name == 'CHudBattery' || name == 'CHudAmmo' ||	name == 'CHudSecondaryAmmo' )
end

-- TODO: modify hznSuit to transmit a table instead?
net.Receive('hznSuit', function()
	SuitValues['air'].Amount = net.ReadUInt(8)
	SuitValues['coolant'].Amount = net.ReadUInt(8)
	SuitValues['energy'].Amount = net.ReadUInt(8)
end)

-- Factory / Replicator related fields

function GM:RegisterFactoryEntry( FactoryEntry )
	FactoryEntries[FactoryEntry.DisplayName] = FactoryEntry
end

function GM:GetFactoryEntries()
	return FactoryEntries
end