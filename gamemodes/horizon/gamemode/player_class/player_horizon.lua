AddCSLuaFile()

DEFINE_BASECLASS( "player_sandbox" )

local PLAYER = {} 

-- Suit values
PLAYER.MaxSuitPower			= 200
PLAYER.SuitPower 			= 10
PLAYER.MaxSuitAir			= 200
PLAYER.SuitAir				= 10
PLAYER.MaxSuitCoolant		= 200
PLAYER.SuitCoolant			= 10
-- Environment values
PLAYER.CurrentEnv = nil

-- Called when the class object is created (shared)
function PLAYER:Init()
	BaseClass:Init()
	self.Player.SuitPower		= PLAYER.SuitPower
	self.Player.SuitAir			= PLAYER.SuitAir
	self.Player.SuitCoolant		= PLAYER.SuitCoolant
	self.Player.SuitAirLast		= 0
	self.Player.SuitCoolantLast	= 0
	self.Player.SuitPowerLast	= 0
	self.Player.CurrentEnv		= PLAYER.CurrentEnv
	self.Player.Habitable		= PLAYER.Habitable
end

function PLAYER:TransmitResources( energy, air, coolant )
	self.Player.SuitAir = self.Player.SuitAir + math.abs( air )
	self.Player.SuitPower = self.Player.SuitPower + math.abs( energy )
	self.Player.SuitCoolant = self.Player.SuitCoolant + math.abs( coolant )
	if self.Player.SuitAir > self.MaxSuitAir then self.Player.SuitAir = self.MaxSuitAir end
	if self.Player.SuitPower > self.MaxSuitPower then self.Player.SuitPower = self.MaxSuitPower end
	if self.Player.SuitCoolant > self.MaxSuitCoolant then self.Player.SuitCoolant = self.MaxSuitCoolant end
end

-- Set up the network table accessors
function PLAYER:SetupDataTables()
	BaseClass:SetupDataTables( self )
end

-- Set up the players loadout
function PLAYER:Loadout()
	BaseClass:Loadout()
end

-- Called when the player spawns
function PLAYER:Spawn()
	BaseClass:Spawn()
end

function PLAYER:netUpdate( ply )
	net.Start('hznSuit')
		net.WriteUInt( ply.SuitAir, 8 )
		net.WriteUInt( ply.SuitCoolant, 8 )
		net.WriteUInt( ply.SuitPower, 8 )
	net.Send( ply )
end

-- Clientside only
function PLAYER:CalcView( view ) end		-- Setup the player's view
function PLAYER:CreateMove( cmd ) end		-- Creates the user command on the client
function PLAYER:ShouldDrawLocal() end		-- Return true if we should draw the local player

-- Shared
function PLAYER:StartMove( cmd, mv ) end	-- Copies from the user command to the move
function PLAYER:Move( mv ) end				-- Runs the move (can run multiple times for the same client)
function PLAYER:FinishMove( mv ) end		-- Copy the results of the move back to the Player

-- Desc: Called before the viewmodel is being drawn (clientside)
-- Arg1: Entity|viewmodel|The viewmodel
-- Arg2: Entity|weapon|The weapon
function PLAYER:PreDrawViewModel( vm, weapon )
end

-- Desc: Called after the viewmodel has been drawn (clientside)
-- Arg1: Entity|viewmodel|The viewmodel
-- Arg2: Entity|weapon|The weapon
function PLAYER:PostDrawViewModel( vm, weapon )
	if ( weapon.UseHands || !weapon:IsScripted() ) then
		local hands = self.Player:GetHands()
		if ( IsValid( hands ) ) then
			hands:DrawModel()
		end
	end
end

-- Desc: Called when the player changes their weapon to another one causing their viewmodel model to change
-- Arg1: Entity|viewmodel|The viewmodel that is changing
-- Arg2: string|old|The old model
-- Arg3: string|new|The new model
function PLAYER:ViewModelChanged( vm, old, new )
end

player_manager.RegisterClass( "player_horizon", PLAYER, "player_sandbox" )