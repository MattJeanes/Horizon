AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')
--register models and materials
resource.AddFile( "models/ore_silo.mdl" )
resource.AddFile( "materials/models/ore_silo.vmt" )

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self:SetModel( "models/ore_silo.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )      
	self:SetMoveType( MOVETYPE_VPHYSICS )   
	self:SetSolid( SOLID_VPHYSICS ) 
	-- resource limits
	self:RegisterResource( "morphite", 10000 )
	self:RegisterResource( "nocxium", 10000 )
	self:RegisterResource( "isogen", 10000 )
	-- check physics
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		return
	end
	-- if physics are invalid remove entity
	self:Remove()
end