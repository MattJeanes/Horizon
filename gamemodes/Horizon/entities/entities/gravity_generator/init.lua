AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')

util.PrecacheSound( "apc_engine_start" )
util.PrecacheSound( "apc_engine_stop" )
util.PrecacheSound( "npc/turret_floor/deploy.wav" )
util.PrecacheSound( "npc/turret_floor/retract.wav" )
 
function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self:SetModel( "models/efg_basic.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )      
	self:SetMoveType( MOVETYPE_VPHYSICS )   
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( ONOFF_USE )
	-- resource stuff
	self:RegisterConsumedResource( "energy", 50 )
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
	self.Entity:EmitSound( "npc/turret_floor/deploy.wav" )
	self:GetPhysicsObject():EnableMotion(false)
	self.Active = true
	local sequence = self:LookupSequence("deploy")
	self:ResetSequence(sequence)
end

function ENT:Off()
	self.Entity:StopSound( "apc_engine_start" )
	self.Entity:EmitSound( "apc_engine_stop" )
	self.Entity:EmitSound( "npc/turret_floor/retract.wav" )
	self:GetPhysicsObject():EnableMotion(true)
	self.Active = false
	local sequence = self:LookupSequence("retract")
	self:ResetSequence(sequence)	
end


function ENT:CanOperate()
	return true
end

function ENT:Execute()
	-- TODO: set gravity of objects in self.Range
	print( "gravity_generator: functionality not yet implemented." )
end

function ENT:Failed()
	self:Off()
end

function ENT:OnRemove()
	if self.Active then
		self.Entity:StopSound( "apc_engine_start" )
		self.Entity:EmitSound( "apc_engine_stop" )
		self.Entity:EmitSound( "npc/turret_floor/retract.wav" )
	end
end