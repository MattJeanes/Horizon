AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize( self )
	local radius = self.dt.Radius;
	self:SetModel( "models/props_c17/oildrum001.mdl" )	
	self:PhysicsInitSphere(radius)
	self:SetMoveType( MOVETYPE_NONE )
	self:SetCollisionBounds(
		Vector( -radius, -radius, -radius ),
		Vector( radius, radius, radius )
	)
end

function ENT:StartTouch( ent )
	currentDist = ent:GetPos():Distance(self:GetPos())
	if ( currentDist > self.dt.Radius ) then
		return
	end
	self.BaseClass.StartTouch( self, ent )
end

function ENT:EndTouch( ent )
	currentDist = ent:GetPos():Distance(self:GetPos())
	if ( currentDist > self.dt.Radius ) then
		self.BaseClass.EndTouch( self, ent )
	end
end

function ENT:Touch( ent )
	self:StartTouch( ent )
end