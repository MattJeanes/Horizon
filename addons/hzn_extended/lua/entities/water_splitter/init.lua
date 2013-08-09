AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')

--sound effects!
util.PrecacheSound( "apc_engine_start" )
util.PrecacheSound( "apc_engine_stop" )
--register models and materials
resource.AddFile( "models/water_splitter.mdl" )
resource.AddFile( "materials/models/water_splitter.vmt" )
 
function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self:SetModel( "models/water_splitter.mdl" )	
	self:PhysicsInit( SOLID_VPHYSICS )      
	self:SetMoveType( MOVETYPE_VPHYSICS )   
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( ONOFF_USE )
	-- resource rates
	self:RegisterConsumedResource( "energy", 60)
	self:RegisterConsumedResource( "water", 60)
	self:RegisterProducedResource( "air", 15)
	self:RegisterProducedResource( "hydrogen", 15)
	-- check physics
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		return
	end
	-- if invalid, remove
	self:Remove()
end
 
function ENT:AcceptInput( name, activator, caller )
	if name == "Use" and caller:IsPlayer() and not caller:KeyDownLast(IN_USE) then
		if self.Active then
			self:Off()
		else
			self:On()
		end	
	end
end

function ENT:On()
	self.Entity:EmitSound( "apc_engine_start" )
	self.Active = true
	self:ResetSequence(self:LookupSequence("active"))	
end

function ENT:Off()
	self.Entity:StopSound( "apc_engine_start" )
	self.Entity:EmitSound( "apc_engine_stop" )
	self.Active = false
	self:ResetSequence(self:LookupSequence("idle"))	
end

function ENT:CanOperate()
	return true
end

function ENT:Failed()
	self:Off()
end