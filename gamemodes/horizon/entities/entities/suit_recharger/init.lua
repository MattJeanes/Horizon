AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')

util.PrecacheSound( "Airboat_engine_idle" )
--register models and materials
resource.AddFile( "models/suit_recharger.mdl" )
resource.AddFile( "materials/models/suit_recharger.vmt" )
 
function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self:SetModel( "models/suit_recharger.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )   
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( ONOFF_USE )
	self.Active = true
	-- resource stuff
	self:RegisterConsumedResource( "energy", 20 )
	-- check physics
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		return
	end
	-- if physics invalid, remove
	self:Remove()
end

function ENT:TransmitResources( ply )
	local a = self.Link:RetrieveResource( "air", 50)
	local e = self.Link:RetrieveResource( "energy", 50)
	local c = self.Link:RetrieveResource( "coolant", 50)
	player_manager.RunClass( ply, "TransmitResources",e, a, c)
end

function ENT:Use( activator, caller )
	if ( activator:IsPlayer() && self.Link != nil ) then
		self:TransmitResources( activator )
	end
end