AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')

util.PrecacheSound( "apc_engine_start" )
util.PrecacheSound( "apc_engine_stop" )
util.PrecacheSound( "npc/turret_floor/deploy.wav" )
util.PrecacheSound( "npc/turret_floor/retract.wav" )
--register models and materials
resource.AddFile( "models/efg_basic.mdl" )
resource.AddFile( "materials/models/efg_basic.vmt" )
 
function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self:SetModel( "models/efg_basic.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )      
	self:SetMoveType( MOVETYPE_VPHYSICS )   
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( ONOFF_USE )
	-- resource stuff
	self:RegisterConsumedResource( "energy", 50 )
	self.Range = 512
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
	--
	self.GravEnv = ents.Create( "hzn_environment" )
	self.GravEnv:SetParent( self )
	self.GravEnv:SetPos( self:GetPos() )
	self.GravEnv.dt.Priority = 0
	self.GravEnv.dt.Gravity = 1
	self.GravEnv.dt.Radius = 256
	self.GravEnv.dt.Breathable = false
	self.GravEnv.dt.Temp = 1
	self.GravEnv.dt.Minerals = 0
	self.GravEnv:Spawn()
end

function ENT:Off()
	self.Entity:StopSound( "apc_engine_start" )
	self.Entity:EmitSound( "apc_engine_stop" )
	self.Entity:EmitSound( "npc/turret_floor/retract.wav" )
	self:GetPhysicsObject():EnableMotion(true)
	self.Active = false
	local sequence = self:LookupSequence("retract")
	self:ResetSequence(sequence)	
	--
	self.GravEnv:Remove()
	self.GravEnv = nil
end

function ENT:CanOperate()
	return true
end

function ENT:Execute()
	if self.CurrentEnv == nil or self.CurrentEnv.dt == nil then
		self.GravEnv.dt.Breathable = false
		self.GravEnv.dt.Temp = 0
	else
		self.GravEnv.dt.Breathable = self.CurrentEnv.dt.Breathable
		self.GravEnv.dt.Temp = self.CurrentEnv.dt.Temp
	end
	self.GravEnv:SetPos( self:GetPos() )
end

function ENT:Failed()
	self:Off()
end

function ENT:OnRemove()
	self:Off()
	-- if self.Active then
		-- self.Entity:StopSound( "apc_engine_start" )
		-- self.Entity:EmitSound( "apc_engine_stop" )
		-- self.Entity:EmitSound( "npc/turret_floor/retract.wav" )
	-- end
end