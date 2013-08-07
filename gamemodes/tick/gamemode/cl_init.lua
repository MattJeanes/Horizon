include('shared.lua')

DEFINE_BASECLASS( "gamemode_sandbox" )

surface.CreateFont( "PixelFont", {
	font 		= "04b03",
	size 		= 8,
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

local x_size = 256
local y_size = 128
local x_offset = 5
local y_offset = 5
local TextColor = Color( 255, 255, 255, 100)
local BarMaterial = Material("Horizon/grad.png")
local border_size = 22
local bar_height = 14

function GM:HUDPaint()
	-- Sandbox stuff.
	if self.BaseClass then
		self.BaseClass:HUDPaint()
	end
	
	local ply = LocalPlayer()
	local X = ScrW()
	local Y = ScrH()
	PlayerValues['health'].Amount = ply:Health()
	PlayerValues['armor'].Amount = ply:Armor()
	-- Left corner
	local x_pos = x_offset
	local y_pos = Y - ( y_size + y_offset )
	surface.SetDrawColor( 255, 255, 255, 255 ) 
	surface.SetMaterial( Material("Horizon/corner_left.png") )
	surface.DrawTexturedRect( x_pos, y_pos, x_size, y_size )
	--
	local c = 0
	local bar_xpos = 37
	-- loop
	for k, v in pairs( PlayerValues ) do
		surface.SetDrawColor( v.DisplayColor ) 
		surface.SetMaterial( BarMaterial )
		c = c + 1
		local bar_ypos = (y_pos + y_size) - ( c * 22 )
		local ratio = math.Clamp( v.Amount, 0, v.MaxAmount ) / v.MaxAmount
		local bar_length = ( x_size - border_size * 2 ) * ratio
		surface.DrawTexturedRect( bar_xpos, bar_ypos, bar_length, bar_height )
		draw.SimpleText( v.DisplayName, v.DisplayFont, border_size * 2, Y - border_size * c, TextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
	end
	-- Nickname
	draw.SimpleText( ply:Nick(), "DermaDefaultBold", 37, Y - 72, Color( 0, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
	draw.SimpleText( ply:Nick(), "DermaDefaultBold", 36, Y - 73, Color( 255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)

	-- Right corner
	surface.SetDrawColor( 255, 255, 255, 255 ) 
	surface.SetMaterial( Material("Horizon/corner_right.png") )
	local x_pos = X - ( x_size + x_offset )
	local y_pos = Y - ( y_size + y_offset )
	surface.DrawTexturedRect( x_pos, y_pos, x_size, y_size )
	--
	local bar_xpos = x_pos + 12
	local c = 0
	for k, v in pairs( SuitValues ) do
		surface.SetDrawColor( v.DisplayColor ) 
		surface.SetMaterial( BarMaterial )
		c = c + 1
		local ratio = math.Clamp( v.Amount, 0, v.MaxAmount ) / v.MaxAmount
		local bar_length = ( x_size - border_size * 2 ) * ratio
		local bar_ypos = ( y_pos + y_size ) - ( c * 23 )
		surface.DrawTexturedRect( bar_xpos, bar_ypos, bar_length, bar_height )
		draw.SimpleText( v.DisplayName, v.DisplayFont, X - ( x_offset + border_size * 2), bar_ypos + 3, TextColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT)
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