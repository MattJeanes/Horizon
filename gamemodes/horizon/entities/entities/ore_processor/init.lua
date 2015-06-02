AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')

--register models and materials
resource.AddFile( "models/ore_processor.mdl" )
resource.AddFile( "materials/models/ore_processor.vmt" )
 
function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self:SetModel( "models/ore_processor.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )      
	self:SetMoveType( MOVETYPE_VPHYSICS )   
	self:SetSolid( SOLID_VPHYSICS ) 
	-- resource
	self:RegisterResource( "hydrogen", 1200 )
	-- check physics
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		return
	end
	-- if the physics are invalid, remove
	self:Remove()
end 