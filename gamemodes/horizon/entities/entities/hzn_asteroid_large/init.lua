AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

--register models and materials
resource.AddFile( "models/lg_asteroid001.mdl" )
resource.AddFile( "models/lg_asteroid002.mdl" )
resource.AddFile( "models/lg_asteroid003.mdl" )
resource.AddFile( "models/med_asteroid001.mdl" )
resource.AddFile( "models/med_asteroid002.mdl" )
resource.AddFile( "models/med_asteroid003.mdl" )
resource.AddFile( "models/sm_asteroid001.mdl" )
resource.AddFile( "models/sm_asteroid002.mdl" )
resource.AddFile( "models/sm_asteroid003.mdl" )
resource.AddFile( "materials/models/asteroid.vmt" )

local models = {}
	local large = {}
		large[1] = "models/lg_asteroid001.mdl"
		large[2] = "models/lg_asteroid002.mdl"
		large[3] = "models/lg_asteroid003.mdl"
	models["large"] = large
	local medium = {}
		medium[1] = "models/med_asteroid001.mdl"
		medium[2] = "models/med_asteroid001.mdl"
		medium[3] = "models/med_asteroid003.mdl"
	models["medium"] = medium
	local small = {}
		small[1] = "models/sm_asteroid001.mdl"
		small[2] = "models/sm_asteroid001.mdl"
		small[3] = "models/sm_asteroid003.mdl"
	models["small"] = small
	
function ENT:Initialize()
	if ( self.AsteroidSize == nil ) then self.AsteroidSize = "large" end
	if ( self.isAsteroid == nil ) then self.isAsteroid = true end
	if ( self.SmallerAsteroid == nil ) then self.SmallerAsteroid = "hzn_asteroid_medium" end
	local modelList = models[self.AsteroidSize]
	self:SetModel( table.Random( modelList ) )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( ONOFF_USE )
	self:SetHealth( 1000 )
    local phys = self:GetPhysicsObject()
	if ( phys:IsValid() ) then
		phys:Wake()
		phys:SetMass( self:Health() )
	end
end

function ENT:Collision()
	local x, y, z
	local effectdata 
	for i = 1, 5, 1 do
		effectdata = EffectData()
		x = math.random() * 1000 - 500
		y = math.random() * 1000 - 500
		z = math.random() * 1000 - 500
		effectdata:SetOrigin( self:GetPos() + Vector( x, y, z ) )
		util.Effect( "explosion", effectdata )
	end		
	self:Remove()
	if self:GetClass() != self.SmallerAsteroid then
		self:AsteroidSplit( self.SmallerAsteroid , 2 )
	end
end

function ENT:AsteroidSplit( className, numSplits )
	local x
	local y
	local z
	local ent
	for i = 1 , numSplits , 1 do
		x = math.random() * 1000 - 500
		y = math.random() * 1000 - 500
		z = math.random() * 1000 - 500
		ent = ents.Create( className )
		ent:SetPos( self:GetPos() + Vector( x, y, z ) )
		ent:SetVelocity( self:GetVelocity() )
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
		phys:ApplyForceOffset( Vector( x, y, z ), Vector( 0, 0, 0 ) )
	end
end

--[[
function ENT:OnTakeDamage()
	local ent = ents.Create( self.Product )
		ent:SetPos( self:GetPos() )
		ent:Spawn()
	local phys = ent:GetPhysicsObject()
	self:GibBreakClient( Vector( 100, 100, 100 ) )
	self:Remove()
	return ent
end]]

-- function ENT:TakeDamageInfo( damageInfo )
	-- if self:Health() <= 0 then self:Collision() return end
	-- print( self:Health() )
-- end