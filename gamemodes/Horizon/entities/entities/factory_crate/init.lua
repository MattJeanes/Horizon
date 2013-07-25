AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')
 
function ENT:Initialize()
	self:SetModel( "models/props_junk/wood_crate001a.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )      
	self:SetMoveType( MOVETYPE_VPHYSICS )   
	self:SetHealth(100)
end

function ENT:SetProduct( prod )
	self.Product = prod
end

function ENT:OnTakeDamage()
	local ent = ents.Create( self.Product )
		ent:SetPos( self:GetPos() )
		ent:Spawn()
	local phys = ent:GetPhysicsObject()
	self:GibBreakClient( Vector( 100, 100, 100 ) )
	self:Remove()
	return ent
end

 
function ENT:Think()
end



 