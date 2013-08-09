AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')

--sound effects!
util.PrecacheSound( "Airboat_engine_idle" )
util.PrecacheSound( "Airboat_engine_stop" )
util.PrecacheSound( "apc_engine_start" )
--register models and materials
resource.AddFile( "models/hydrogen_coolant.mdl" )
resource.AddFile( "materials/models/hydrogen_coolant.vmt" )

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self:SetModel( "models/hydrogen_coolant.mdl" )	
	self:PhysicsInit( SOLID_VPHYSICS )      
	self:SetMoveType( MOVETYPE_VPHYSICS )   
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( ONOFF_USE )
	-- resource stuff
	self:RegisterConsumedResource( "energy", 60)
	self:RegisterConsumedResource( "hydrogen", 15)
	self:RegisterProducedResource( "coolant", 60)
	-- check physics
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		return
	end
	-- if invalid remove
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
	self.Entity:EmitSound( "Airboat_engine_idle" )
	self.Active = true
end

function ENT:Off()
	self.Entity:StopSound( "Airboat_engine_idle" )
	self.Entity:EmitSound( "Airboat_engine_stop" )
	self.Entity:StopSound( "apc_engine_start" )
	self.Active = false
end

function ENT:CanOperate()
	return true
end

function ENT:Failed()
	self:Off()
end