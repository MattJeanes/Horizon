AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" ) 
include('shared.lua')
 
function ENT:Initialize()
	modelChoice = math.random(1, 3)
	if modelChoice == 1 then asteroidModel = "models/sm_asteroid001.mdl" end
	if modelChoice == 2 then asteroidModel = "models/sm_asteroid002.mdl" end
	if modelChoice == 3 then asteroidModel = "models/sm_asteroid003.mdl" end
	self:SetModel( asteroidModel )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( ONOFF_USE )	
	self.isAsteroid = true
	self.Health = 1000
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMass( 100 )
	end
end

function ENT:Collision()	
	local x
	local y
	local z
	local effectdata 
	for i = 1, 10, 1 do
		effectdata = EffectData()
		x = math.random() * 1000 - 500
		y = math.random() * 1000 - 500
		z = math.random() * 1000 - 500
		effectdata:SetOrigin( self:GetPos() + Vector(x, y, z) )
		util.Effect( "explosion", effectdata )
	end		
	self.Entity:Remove()
	self:SpawnResource( "nocxium_ore", 10 )
end

function ENT:SpawnResource( className, amount )
	for i = 1, amount, 1 do
		ent = ents.Create( className )
		ent:SetPos( self:GetPos() )
		ent:Spawn()
		GAMEMODE:SetDefaultEnv( ent )
	end
end