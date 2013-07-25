AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')
 
function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self:SetModel( "models/solar_panel.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )      
	self:SetMoveType( MOVETYPE_VPHYSICS )   
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( ONOFF_USE )
	self.Active = true
	-- resource stuff
	self:RegisterProducedResource( "energy", 20)
	-- check physics
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		return
	end
	-- if invalid, remove
	self:Remove()
end

function ENT:ReceivesLight()
	local tracedata = {}
	tracedata.start = GAMEMODE:GetSun():GetPos()
	tracedata.endpos = self:GetPos()
	tracedata.filter = self
	local trace = util.TraceLine(tracedata)
	if trace.Hit then return (trace.Entity:GetClass() == "solar_panel")	end
	return false
end

function ENT:CanOperate()
	--return self:ReceivesLight()
	return true
end

function ENT:Failed()
	self:Off()
end