AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')
	
function ENT:Initialize()
	self.AsteroidSize = "medium"
	self.isAsteroid = true
	self.SmallerAsteroid = "isogen_ore"
	self.BaseClass.Initialize( self )
end