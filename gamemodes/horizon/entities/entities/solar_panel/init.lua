AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')
--register models and materials
resource.AddFile( "models/solar_panel.mdl" )
resource.AddFile( "materials/models/solar_panel.vmt" )
 
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
	local sun = GAMEMODE:GetSun()
	local tracedata = {}
		tracedata.start = self:GetPos()
		tracedata.endpos = sun:GetPos()
		tracedata.filter = { self, sun }
	local trace = util.TraceLine(tracedata)
	return not trace.Hit
end

function ENT:CanOperate()
	return self:ReceivesLight()
	--return true
end

function ENT:Failed()
	self:Off()
end