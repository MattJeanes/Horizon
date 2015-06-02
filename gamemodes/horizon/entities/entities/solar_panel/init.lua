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
	local hit
	local sun = GAMEMODE:GetSun()
	if sun then
		local ang = sun:GetSaveTable().sun_dir:Angle()
		if ang then
			local startPos = self:GetPos()
			local tracedata = {}
			tracedata.start = startPos
			tracedata.endpos = startPos + (ang:Forward()*160000)
			tracedata.filter = self
			local trace = util.TraceLine(tracedata)
			hit=trace.HitSky
		end
	else
		local startPos = Vector(0, 0, 0)
		local endPos = 	self:GetPos()
		local tracedata = {}
		tracedata.start = startPos
		tracedata.endpos = endPos
		tracedata.filter = self
		local trace = util.TraceLine(tracedata)
		hit=trace.Hit
	end

	return hit
end

function ENT:CanOperate()
	return self:ReceivesLight()
	--return true
end

function ENT:Failed()
	self:Off()
end