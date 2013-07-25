include('shared.lua')

DEFINE_BASECLASS( "gamemode_sandbox" )

local FactoryEntries = {}

local Air = Air or 0
local Coolant = Coolant or 0
local Power = Power or 0

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

local hps = hps or 0
local aps = aps or 0
local as = as or 0
local cs = cs or 0
local ps = ps or 0

function GM:HUDPaint()
	//Sandbox stuff.
	if self.BaseClass then
		self.BaseClass:HUDPaint()
	end
	
	local ply = LocalPlayer()
	local X = ScrW()
	local Y = ScrH()

	local health = math.Clamp(ply:Health(), 0, 100)   -- clamps the health to [0, 100] meaning it will not go above 100 or below 0
    hps = math.Approach(hps, health, 50*FrameTime())
    local hpequation = (212)*(hps/100)

	local armor = math.Clamp(ply:Armor(), 0, 100)   -- clamps the health to [0, 100] meaning it will not go above 100 or below 0
    aps = math.Approach(aps, armor, 50*FrameTime())
    local apequation = (212)*(aps/100)

	-- Left corner
	surface.SetDrawColor( 255, 255, 255, 255 ) 
	surface.SetMaterial( Material("Horizon/corner_left.png") )
	surface.DrawTexturedRect( 5, Y-133, 256, 128 )	
	--Armor
	surface.SetDrawColor( 255, 128, 0, 255 ) 
	surface.SetMaterial( Material("Horizon/grad.png") )
	surface.DrawTexturedRect( 37, Y-27, apequation, 14 )	
	-- Health
	surface.SetDrawColor( 231, 17, 21, 255 ) 
	surface.SetMaterial( Material("Horizon/grad.png") )
	surface.DrawTexturedRect( 37, Y-50, hpequation, 14 )
	-- Nickname
	draw.SimpleText( ply:Nick(), "DermaDefaultBold", 37, Y - 72, Color( 0, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
	draw.SimpleText( ply:Nick(), "DermaDefaultBold", 36, Y - 73, Color( 255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)

	-- Right corner
	local power = math.Clamp(Power, 0, 200)
    ps = math.Approach(ps, power, 50*FrameTime())
    local psequation = (212)*(ps/200)

	local air = math.Clamp(Air, 0, 200)
    as = math.Approach(as, air, 50*FrameTime())
    local asequation = (212)*(as/200)

	local coolant = math.Clamp(Coolant, 0, 200)
    cs = math.Approach(cs, coolant, 50*FrameTime())
    local csequation = (212)*(cs/200)

	surface.SetDrawColor( 255, 255, 255, 255 ) 
	surface.SetMaterial( Material("Horizon/corner_right.png") )
	surface.DrawTexturedRect( ScrW()-261, Y-133, 256, 128 )
	-- Power
	surface.SetDrawColor( 255, 205, 0, 255 ) 
	surface.SetMaterial( Material("Horizon/grad.png") )
	surface.DrawTexturedRect( ScrW()-249, Y-73, psequation, 14 )
	-- Air
	surface.SetDrawColor( 0, 204, 0, 255 ) 
	surface.SetMaterial( Material("Horizon/grad.png") )
	surface.DrawTexturedRect( ScrW()-249, Y-50, asequation, 14 )
	-- Coolant
	surface.SetDrawColor( 0, 153, 204, 255 ) 
	surface.SetMaterial( Material("Horizon/grad.png") )
	surface.DrawTexturedRect( ScrW()-249, Y-27, csequation, 14 )

	draw.SimpleText( "Energy", "PixelFont", ScrW()-41, Y - 69, Color( 255, 255, 255, 100), TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT)
	draw.SimpleText( "Air", "PixelFont", ScrW()-41, Y - 46, Color( 255, 255, 255, 100), TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT)
	draw.SimpleText( "Coolant", "PixelFont", ScrW()-41, Y - 23, Color( 255, 255, 255, 100), TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT)
	draw.SimpleText( "Health", "PixelFont", 41, Y - 46, Color( 255, 255, 255, 100), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
	draw.SimpleText( "Armor", "PixelFont", 41, Y - 23, Color( 255, 255, 255, 100), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)

end

function GM:HUDShouldDraw(name)
	if	name == 'CHudHealth' ||
		name == 'CHudBattery' ||
		name == 'CHudAmmo' ||
		name == 'CHudSecondaryAmmo'
	then
		return false
	end
	
	return true
end

net.Receive('hznSuit', function()
	Air = net.ReadUInt(8)
	Coolant = net.ReadUInt(8)
	Power = net.ReadUInt(8)
end)

--A device is turned on or off.
net.Receive('hznState', function()
	local entity = net.ReadEntity()	
	entity.Active = (net.ReadBit() == 1)
end)


--Get a state of a entity when we know about it if it was made more than a second ago.
function GM:NetworkEntityCreated( ent )
		if ( GAMEMODE:IsHznClass(ent:GetClass()) and ent:GetCreationTime() < (CurTime() - 1.0) ) then
			net.Start('hznGetState')
				net.WriteEntity(ent)
			net.SendToServer()
		end
		
		self.BaseClass:NetworkEntityCreated(ent)
end

function GM:RegisterFactoryEntry( FactoryEntry )
	FactoryEntries[FactoryEntry.DisplayName] = FactoryEntry
end

function GM:GetFactoryEntries()
	return FactoryEntries
end
