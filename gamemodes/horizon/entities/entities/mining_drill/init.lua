AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

--sound effects!
util.PrecacheSound( "trainyard.train_move" )
util.PrecacheSound( "trainyard.train_idle" )
util.PrecacheSound( "trainyard.train_brake" )
--register models and materials
resource.AddFile( "models/mining_drill.mdl" )
resource.AddFile( "materials/models/mining_drill.vmt" )
 
function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self:SetModel( "models/mining_drill.mdl" )	
	self:PhysicsInit( SOLID_VPHYSICS )      
	self:SetMoveType( MOVETYPE_VPHYSICS )   
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( ONOFF_USE )
	-- resource stuff
	self:RegisterConsumedResource( "energy", 60)
	self.LastResourceDrop = 0
	self.ResourceRate = 5
	--animation timing stuff
	self.AnimTime = 0
	self.Duration = 0
	self.Activating = false
	-- check physics
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		return
	end	
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
	self.Entity:EmitSound( "trainyard.train_move" )
	self.Entity:EmitSound( "trainyard.train_idle" )
	self.Active = true
	local sequence = self:LookupSequence("start")
	self.Activating = true
	self.Duration = self:SequenceDuration(sequence)
	self.AnimTime = CurTime()
	self:ResetSequence(sequence)
end

function ENT:Idle()
	local sequence = self:LookupSequence("active")
	self:ResetSequence(sequence)
	self.Activating = false
end

function ENT:Off()
	self.Entity:StopSound( "trainyard.train_move" )
	self.Entity:StopSound( "trainyard.train_idle" )
	self.Entity:EmitSound( "trainyard.train_brake" )
	self.Active = false
	local sequence = self:LookupSequence("stop")
	self:ResetSequence(sequence)	
end

function ENT:SpawnOre()
	-- determine type of ore
	local ent
	if self.CurrentEnv.dt.Minerals == 2 then
		ent = ents.Create("nocxium_ore")
	end
	if self.CurrentEnv.dt.Minerals == 1 then
		ent = ents.Create("morphite_ore")
	end
	if ent == nil then return end
	-- determine position
	local x = math.random() * 128 - 64
	local y = math.random() * 128 - 64
	ent:SetPos( self:GetPos() + Vector(x, y, 16) )
	ent:Spawn()
	-- check physics
	local phys = ent:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		return
	end	
	ent:Remove()
	return
end

function ENT:CanOperate()
	local tracedata = {}
		tracedata.start = self:GetPos()
		tracedata.endpos = ( self:GetPos() + Vector(0,0,-25) )
		tracedata.filter = self
	local trace = util.TraceLine( tracedata )
	if self.CurrentEnv == nil or not trace.HitWorld then
		self:Off()
		return false
	end
	return true
end

function ENT:Execute()
	-- used for startup animation sequence
	if self.Activating then
		if ( ( self.AnimTime + self.Duration ) < CurTime() ) then return end
		self:Idle()
		return
	end
	-- check rates
	if self.LastResourceDrop + self.ResourceRate < CurTime() then
		self:SpawnOre()
		self.LastResourceDrop = CurTime()
		return
	end
end

function ENT:Failed()
	self:Off()
end

function ENT:OnRemove()
	if self.Active then
		self.Entity:StopSound( "trainyard.train_move" )
		self.Entity:StopSound( "trainyard.train_idle" )
		self.Entity:EmitSound( "trainyard.train_brake" )
	end
end