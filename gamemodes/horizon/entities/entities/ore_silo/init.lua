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

function ENT:StartTouch( hitEnt )
	if not hitEnt:IsValid() then return end
	
	if hitEnt:GetClass() == "mineral_crate" then
		local leftover = hitEnt.StoredResources["morphite"] - (self.MaxStoredResources["morphite"] - self.StoredResources["morphite"])
		self:AddResource( "morphite", hitEnt.StoredResources["morphite"] )
		hitEnt:SetResourceAmount( "morphite", leftover>0 and leftover or 0 )
		
		local leftover = hitEnt.StoredResources["nocxium"] - (self.MaxStoredResources["nocxium"] - self.StoredResources["nocxium"])
		self:AddResource( "nocxium", hitEnt.StoredResources["nocxium"] )
		hitEnt:SetResourceAmount( "nocxium", leftover>0 and leftover or 0 )
		
		local leftover = hitEnt.StoredResources["isogen"] - (self.MaxStoredResources["isogen"] - self.StoredResources["isogen"])
		self:AddResource( "isogen", hitEnt.StoredResources["isogen"] )
		hitEnt:SetResourceAmount( "isogen", leftover>0 and leftover or 0 )
		
		self:EmitSound( "cavernrock.impacthard" )
	end
	
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