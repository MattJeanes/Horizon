AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')

--sound effects!
util.PrecacheSound( "k_lab.ambient_powergenerators" )
util.PrecacheSound( "ambient/machines/thumper_startup1.wav" )
 
function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self:SetModel( "models/fusion_reactor.mdl" )	
	self:PhysicsInit( SOLID_VPHYSICS )      
	self:SetMoveType( MOVETYPE_VPHYSICS )   
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( ONOFF_USE )
	-- resource stuff
	self:RegisterConsumedResource( "hydrogen" , 15)
	self:RegisterConsumedResource( "coolant" , 15)
	self:RegisterProducedResource( "energy" , 1000)
	-- check physics
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		return
	end
	-- else remove
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
	self.Entity:EmitSound( "k_lab.ambient_powergenerators" )
	self.Entity:EmitSound( "ambient/machines/thumper_startup1.wav" )
	self.Active = true
end

function ENT:Off()
	self.Entity:StopSound( "k_lab.ambient_powergenerators" )
	self.Active = false
end

function ENT:CanOperate()
	if self.Link == nil then
		self:Off()
		return false
	end
	return true
end

function ENT:Failed()
	self:Off()
end