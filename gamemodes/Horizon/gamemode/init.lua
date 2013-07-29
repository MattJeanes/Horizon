AddCSLuaFile( 'shared.lua' )
AddCSLuaFile( 'cl_init.lua' )

include('shared.lua')
include('sv_resources.lua')
include('sv_networking.lua')

DEFINE_BASECLASS( "gamemode_sandbox" )

---------------------------------------------------------------------------------
local temps = {}
	temps[1] = "cold"
	temps[2] = "temperate"
	temps[3] = "hot" 
local LastAsteroidSpawn = 0
local LastThink = 0
local ThinkRate = 1
local FactoryEntries = {}
---------------------------------------------------------------------------------

-- Sets the default environment for an entity ( default environment = space )
function GM:SetDefaultEnv( ent )
	ent.CurrentEnv = nil
	-- for players
	if ent:IsPlayer() then
		self:AdjustGravity( ent, 0.00001 )
		return
	end
	self:AdjustGravity( ent, 0 )
end

-- Sets the environment of the given entity to the new environment if its priority is higher
function GM:SetEnvironment( entity, newEnv )
	if entity.CurrentEnv == nil then
		entity.CurrentEnv = newEnv
		self:AdjustGravity(entity, newEnv.dt.Gravity)
		return
	end
	if newEnv.dt.Priority <= entity.CurrentEnv.dt.Priority then
		entity.CurrentEnv = newEnv
		self:AdjustGravity(entity, newEnv.dt.Gravity)
		return
	end
end

-- Adjusts the gravity of an entity according to the environment it is in
function GM:AdjustGravity( ent, gravity )
	-- adjust gravity in case the entity is a player
	ent:SetGravity( gravity )
	local gravityOn = (gravity != 0)
	local phys
	-- adjust gravity on a ragdoll entity
	for i = 0, (ent:GetPhysicsObjectCount() - 1), 1 do
		phys = ent:GetPhysicsObjectNum( i )
		if phys:IsValid() then
			phys:EnableGravity( gravityOn )
			phys:EnableDrag( gravityOn )
		end
	end
	-- adjust gravity on a physics entity
	if ( ent:IsValid() ) then
		phys = ent:GetPhysicsObject()
		if not phys:IsValid() then return end
		phys:EnableGravity( gravityOn )
		phys:EnableDrag( gravityOn )
	end
end

-- Sun entity never changes so no need to update.
function GM:GetSun()
	if self.Sun != nil then return self.Sun end
	self.Sun = table.GetFirstValue( ents.FindByClass( "env_sun" ) )
	if self.Sun == nil then
		self.Sun = ents.Create( "env_sun" )
		self.Sun:Spawn()
		self.Sun:Activate()
	end
	return self.Sun
end

-- Initialise the gamemode after the map was loaded
function GM:InitPostEntity()
	for _, entity in pairs( ents.GetAll() ) do
		self:SetDefaultEnv( entity )	
	end
	-- Initialise the sun
	self:GetSun()
end

-- Reset suit values
function GM:PlayerSpawn( ply )
	self.BaseClass:PlayerSpawn( ply )
	player_manager.SetPlayerClass( ply, "player_horizon" )
	player_manager.RunClass(ply, "netUpdate", ply)
end

-- Hurts the given player
function GM:HurtPlayer( ply, dmg )
	if ply:IsValid() then
		ply:SetHealth( ply:Health() - dmg )				
		ply:EmitSound("buttons/combine_button3.wav")
		if ply:Health() < 1 then ply:Kill() end
	end
end

-- Generates a random position in a cube
function GM:GetMapCoords( maxdist )
	-- generate coordinates inside of a cube
	local x = ( math.random() * 2 - 1 ) * maxdist
	local y = ( math.random() * 2 - 1 ) * maxdist
	local z = ( math.random() * 2 - 1 ) * maxdist
	return Vector( x, y, z )
end

-- Returns one of three asteroid classnames
function GM:ChooseAsteroidType()
	local rand = math.random()
	if ( rand <= 0.49 ) then 
		return "hzn_asteroid_large"
	end
	return "hzn_asteroid_medium"
end

-- Tries to spawns an asteroid of random type in a random (free) location
function GM:SpawnAsteroid()
	local ent = ents.Create(self:ChooseAsteroidType())
	--local ent = ents.Create( "hzn_asteroid_large" )
	local coords = self:GetMapCoords( 15000 )
	local tries = 0
	while table.Count( ents.FindInSphere(coords, 500) ) > 0  and tries < 5 do
		tries = tries + 1
		coords = self:GetMapCoords( 15000 )
	end
	if tries == 5 then
		ent:Remove()
		return
	end
	ent:SetPos( coords )
	ent:Spawn()
	local phys = ent:GetPhysicsObject()
	-- remove the entity if its physics object is invalid
	if not phys:IsValid() then
		ent:Remove()
		return
	end
	self:SetDefaultEnv( ent )
	phys:ApplyForceCenter( self:GetMapCoords( 3000 ) )
	phys:ApplyForceOffset( self:GetMapCoords( 50 ), Vector( 0, 0, 0 ) )	
	return
end

-- Called after an entity was created
function GM:OnEntityCreated( ent )
	self.BaseClass:OnEntityCreated( ent )
	if IsValid( ent ) and ent.CurrentEnv == nil then
		self:SetDefaultEnv( ent )
	end
end

-- Checks if the player should take damage or not
function GM:PlayerThink( ply )
	if not ply:Alive() then return end
	local dmg = 0
	local env = ply.CurrentEnv
	if env == nil then
		if ply.SuitAir > 0		then ply.SuitAir		= ply.SuitAir - 1	else dmg = dmg + 10 end
		if ply.SuitPower > 0	then ply.SuitPower		= ply.SuitPower - 1 else dmg = dmg + 5 end
	else
		-- Update air reserves
		if not env.dt.Breathable then			
			if ply.SuitAir > 0 then ply.SuitAir = ply.SuitAir - 1 else dmg = dmg + 10 end
		end
		-- Update coolant reserves
		if temps[env.dt.Temp] == temps[3] then
			if ply.SuitCoolant > 0 then	ply.SuitCoolant = ply.SuitCoolant - 1 else dmg = dmg + 5 end
		end
		-- Update power reserves
		if temps[env.dt.Temp] == temps[1] then
			if ply.SuitPower > 0 then ply.SuitPower = ply.SuitPower - 1	else dmg = dmg + 5 end
		end
	end
	if dmg > 0 then
		self:HurtPlayer( ply, dmg )
	end
end

-- Called every gamemode tick
function GM:Tick()
	local CurrentTime = CurTime()
	-- check if its time for the next think
	if (CurrentTime - LastThink) < ThinkRate then
		return
	else
		LastThink = CurrentTime
	end
	-- Asteroid timer
	if ( CurrentTime - LastAsteroidSpawn ) > ( math.random() * ( 500 - 300 ) ) + 300 then
		self:SpawnAsteroid()
		LastAsteroidSpawn = CurrentTime
	end
	-- Think on players
	for _, ply in pairs( player.GetAll() ) do
		if ply:IsValid() and ply:IsPlayer() then 
			self:PlayerThink( ply )
		end
	end
end

-- Returns a list of items available in the factory
function GM:GetFactoryEntries()
	return FactoryEntries
end

-- Registers an item with the gamemode so that factories can produce it.
function GM:RegisterFactoryEntry( FactoryEntry )
	FactoryEntries[FactoryEntry.DisplayName] = FactoryEntry
end