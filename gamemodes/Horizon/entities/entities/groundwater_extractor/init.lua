AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')

--sound effects!
util.PrecacheSound( "Airboat_engine_idle" )
util.PrecacheSound( "Airboat_engine_stop" )
util.PrecacheSound( "apc_engine_start" )
 
function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self:SetModel( "models/groundwater_extractor.mdl" )	
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
	-- if physcics invalid, remove
	self:Remove()
end

function ENT:GroundCheck()
	local pos = self:GetPos()
	local tracedata = {}
	tracedata.start = pos
	tracedata.endpos = (pos + Vector(0,0,-10) )
	tracedata.filter = self
	return util.TraceLine( tracedata ).HitWorld
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
end

function ENT:Off()
	self.Entity:StopSound( "Airboat_engine_idle" )
	self.Entity:EmitSound( "Airboat_engine_stop" )
	self.Entity:StopSound( "apc_engine_start" )
	self.Active = false
	self:SetState(false)
end

function ENT:CanOperate()
	if ( self.CurrentEnv != nil and self:GroundCheck()) then
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