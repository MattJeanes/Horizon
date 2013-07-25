AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')

--sound effects!
util.PrecacheSound( "Airboat_engine_idle" )
util.PrecacheSound( "Airboat_engine_stop" )
util.PrecacheSound( "apc_engine_start" )
 
function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self:SetModel( "models/water_pump.mdl" )	
	self:PhysicsInit( SOLID_VPHYSICS )      
	self:SetMoveType( MOVETYPE_VPHYSICS )   
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( ONOFF_USE )
	-- resource stuff
	self:RegisterConsumedResource( "energy", 60)
	self:RegisterProducedResource( "water", 15)
	-- check physics
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		return
	end
	-- if physics invalid, remove
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
	self:SetState(true)
	self:ResetSequence(self:LookupSequence("active"))	
end

function ENT:Off()
	self.Entity:StopSound( "Airboat_engine_idle" )
	self.Entity:EmitSound( "Airboat_engine_stop" )
	self.Entity:StopSound( "apc_engine_start" )
	self.Active = false
	self:SetState(false)
	self:ResetSequence(self:LookupSequence("idle"))	
end

function ENT:CanOperate()
	if self:WaterLevel() > 0 then
		return true
	end
	self:Off()
	return false
end

function ENT:Failed()
	self:Off()
end

function ENT:OnRemove()
	if self.Active then
		self.Entity:StopSound( "Airboat_engine_idle" )
		self.Entity:EmitSound( "Airboat_engine_stop" )
		self.Entity:StopSound( "apc_engine_start" )
	end
end