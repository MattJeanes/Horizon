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
	-- resources
	self:RegisterConsumedResource( "energy", 20 )
	self.Range = 256
	-- check if physics are valid
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		return
	end
	-- remove if invalid
	self:Remove()
end

function ENT:On()
	self.Entity:EmitSound( "apc_engine_start" )
	self.Entity:EmitSound( "npc/turret_floor/deploy.wav" )
	self.Active = true
	self:SetState(true)
	local sequence = self:LookupSequence("deploy")
	self:ResetSequence(sequence)
end

function ENT:Off()
	self.Entity:StopSound( "apc_engine_start" )
	self.Entity:EmitSound( "apc_engine_stop" )
	self.Entity:EmitSound( "npc/turret_floor/retract.wav" )
	self.Active = false
	self:SetState(false)
	local sequence = self:LookupSequence("retract")
	self:ResetSequence(sequence)	
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
	local e = self.Link:RetrieveResource( "energy" , 20)
	local a = self.Link:RetrieveResource( "air" , 20)
	local c = self.Link:RetrieveResource( "coolant" , 20)
	-- Distribute available resources to players
	local entsInRange = ents.FindInSphere(self:GetPos(), self.Range)
	local NumPlayers = 0
	for _, ent in pairs ( entsInRange ) do	
		if ent:IsPlayer() then
			NumPlayers = NumPlayers + 1
		end		
	end
	e = e / NumPlayers
	a = a / NumPlayers
	c = c / NumPlayers
	for _, ent in pairs ( entsInRange ) do	
		if ent:IsPlayer() then
			player_manager.RunClass( ent, "TransmitResources", e, a, c)
		end		
	end
end

function ENT:Failed()
	self:Off()
end 