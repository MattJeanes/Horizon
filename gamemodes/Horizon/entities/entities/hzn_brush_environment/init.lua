AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()
	self:SetSolid( SOLID_BBOX )
	self:SetNotSolid( true )
	self:SetTrigger( true )
	self:SetNoDraw( true )
	self:DrawShadow( false )
	--self:SetModel( "models/props_c17/oildrum001.mdl" )	
	--self:PhysicsInitBox(radius)
	--self:SetMoveType( MOVETYPE_NONE )
	--self:SetCollisionBounds(
	--	Vector( -radius, -radius, -radius ),
	--	Vector( radius, radius, radius )
	--)
	return
end

function ENT:StartTouch( ent )
	if ent.isAsteroid then
		ent:Collision()
		return
	end
	GAMEMODE:SetEnvironment( ent, self)
end

function ENT:EndTouch( ent )
	-- search for new environment
	ent.CurrentEnv = nil
	for _, env in pairs( ents.FindByClass( self:GetClass() ) ) do
		env:StartTouch( ent )
	end
	if ent.CurrentEnv == nil then
		GAMEMODE:SetDefaultEnv( ent )
		return
	end
end

function ENT:Touch( ent )
	self:StartTouch( ent )
end

function ENT:KeyValue( key, value )
	key = string.lower( key )
	if( key == "pltname" )			then self.name 			= tostring( value )				end
	if( key == "pltradius" )		then self.dt.Radius		= tonumber( value )				end
	if( key == "pltgravity" )		then self.dt.Gravity	= tonumber( value )				end
	if( key == "pltbreathable" )	then self.dt.Breathable	= ( tostring(value) == "TRUE" )	end
	if( key == "pltpriority" )		then self.dt.Priority	= tonumber( value )				end
	if( key == "plttemp" ) then
		self.dt.Temp = 1
		if tostring(value) == "HOT" then
			self.dt.Temp = 3
		end
		if tostring(value) == "TEMPERATE" then
			self.dt.Temp = 2
		end
		if tostring(value) == "COLD" then
			self.dt.Temp = 1
		end
	end
	if( key == "pltminerals" ) then
		self.dt.Minerals = 0
		if tostring(value) == "MORPHITE" then
			self.dt.Minerals = 1
		end	
		if tostring(value) == "NOCXIUM" then
			self.dt.Minerals = 2
		end	
	end
end










