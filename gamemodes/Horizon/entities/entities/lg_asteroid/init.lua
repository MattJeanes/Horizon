AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')
 
function ENT:Initialize()
	modelChoice = math.random(1, 3)
	if modelChoice == 1 then asteroidModel = "models/lg_asteroid001.mdl" end
	if modelChoice == 2 then asteroidModel = "models/lg_asteroid002.mdl" end
	if modelChoice == 3 then asteroidModel = "models/lg_asteroid003.mdl" end
	self:SetModel( asteroidModel )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( ONOFF_USE )
	self.isAsteroid = true
	self.Health = 6000	
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
	self.Entity:Remove();
	self:AsteroidSplit( 2 )
end

function ENT:AsteroidSplit( numSplits )
	local x
	local y
	local z
	local ent
	for i = 1 , numSplits , 1 do
		x = math.random() * 1000 - 500
		y = math.random() * 1000 - 500
		z = math.random() * 1000 - 500
		ent = ents.Create( "med_asteroid" )
		ent:SetPos(self:GetPos() + Vector(x, y, z))
		ent:Spawn()
		GAMEMODE:SetDefaultEnv(ent)
		x = math.random() * 200 - 100
		y = math.random() * 200 - 100
		z = math.random() * 200 - 100
		local phys = ent:GetPhysicsObject()
		phys:ApplyForceCenter( Vector( x, y, z ) )	 
		x = math.random() * 4 - 2
		y = math.random() * 4 - 2
		z = math.random() * 4 - 2
		phys:ApplyForceOffset(Vector( x, y, z ),Vector(0,0,0) )
	end
end