AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')

--register models and materials
resource.AddFile( "models/water_tank.mdl" )
resource.AddFile( "materials/models/water_tank.vmt" )
 
function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self:SetModel( "models/water_tank.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )      
	self:SetMoveType( MOVETYPE_VPHYSICS )   
	self:SetSolid( SOLID_VPHYSICS ) 
	-- resource
	self:RegisterResource( "water", 1200 )
	-- check physics
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		return
	end
	-- if the physics are invalid, remove
	self:Remove()
end