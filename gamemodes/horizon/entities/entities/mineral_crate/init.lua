AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')

util.PrecacheSound( "cavernrock.impacthard" )
--register models and materials
resource.AddFile( "models/mineral_crate.mdl" )
resource.AddFile( "materials/models/mineral_crate.vmt" )
 
function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self:SetModel( "models/mineral_crate.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )      
	self:SetMoveType( MOVETYPE_VPHYSICS )   
	self:SetSolid( SOLID_VPHYSICS ) 
	--resource limits etc
	self:RegisterResource( "morphite", 500 )
	self:RegisterResource( "nocxium", 500 )
	self:RegisterResource( "isogen", 500 )
	-- check physics
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		return
	end
	-- if the physics are invalid remove the crate
	self:Remove()
end

function ENT:StartTouch( hitEnt )
	if not hitEnt:IsValid() then return end
	if ( hitEnt:GetClass() == "morphite_ore" and self.StoredResources["morphite"] < self.MaxStoredResources["morphite"]) then
		hitEnt:Remove()
		self.Entity:EmitSound( "cavernrock.impacthard" )
		self:AddResource( "morphite", 10 )
		return
	end
	if ( hitEnt:GetClass() == "nocxium_ore" and self.StoredResources["nocxium"] < self.MaxStoredResources["nocxium"]) then
		hitEnt:Remove()			
		self.Entity:EmitSound( "cavernrock.impacthard" )
		self:AddResource( "nocxium", 10 )
		return
	end
	-- since small asteroids will explode if they touch an hzn_environment, this resource needs to be mined in space
	if ( hitEnt:GetClass() == "isogen_ore" and self.StoredResources["isogen"] < self.MaxStoredResources["isogen"]) then
		hitEnt:Remove()			
		self.Entity:EmitSound( "cavernrock.impacthard" )
		self:AddResource( "isogen", 10 )
		return
	end
end