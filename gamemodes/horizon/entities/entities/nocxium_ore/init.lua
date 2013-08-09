AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')
--register models and materials
resource.AddFile( "models/nocxium_ore.mdl" )
resource.AddFile( "materials/models/nocxium_ore.vmt" )

function ENT:Initialize()
	self:SetModel( "models/nocxium_ore.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )   
	self:SetMoveType( MOVETYPE_VPHYSICS )  
	self:SetSolid( SOLID_VPHYSICS ) 
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
end
 
function ENT:Think()  
end



 