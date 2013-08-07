AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')

util.PrecacheSound( "d3_citadel.weapon_zapper_beam_loop2" )
 
function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self:SetModel( "models/mining_laser.mdl" )	
	self:PhysicsInit( SOLID_VPHYSICS )      
	self:SetMoveType( MOVETYPE_VPHYSICS )   
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( ONOFF_USE )
	-- gamemode stuff
	self.TargetPos = Vector(0, 0, 0)
	-- resource stuff
	self:RegisterConsumedResource( "energy", 60 )
	-- check physics
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		return
	end
	-- if invalid remove
	self:Remove()
end

function ENT:On()
	self.Active = true
	self:EmitSound( "d3_citadel.weapon_zapper_beam_loop2" )
end

function ENT:Off()
	self.Active = false
	self:StopSound( "d3_citadel.weapon_zapper_beam_loop2" )
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

function ENT:CanOperate()
	return true
end

function ENT:Execute()
	-- retrace laser
	local pos = self:GetPos()
	local tracedata = {}
		tracedata.start = pos
		tracedata.endpos = self:LocalToWorld(Vector(0, 0, 2000))
		tracedata.filter = self
	local trace = util.TraceLine(tracedata)		
	self.TargetPos = self:WorldToLocal(trace.HitPos)
	if trace.Hit then
		local effectData = EffectData()
		effectData:SetStart(trace.HitPos)
		effectData:SetOrigin(trace.HitPos)
		effectData:SetScale( 1 )
		util.Effect( "StunstickImpact", effectData )
		if trace.Entity.isAsteroid then
			trace.Entity.Health = trace.Entity.Health - 1
			if trace.Entity.Health < 1 then trace.Entity:AsteroidSplit( 2 ) end
		end
	end
end

function ENT:Failed() 
	self:Off()
end