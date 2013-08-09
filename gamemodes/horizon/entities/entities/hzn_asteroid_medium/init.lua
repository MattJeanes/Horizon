AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')
resource.AddFile( "models/med_asteroid001.mdl" )
resource.AddFile( "models/med_asteroid002.mdl" )
resource.AddFile( "models/med_asteroid003.mdl" )
resource.AddFile( "models/sm_asteroid001.mdl" )
resource.AddFile( "models/sm_asteroid002.mdl" )
resource.AddFile( "models/sm_asteroid003.mdl" )
resource.AddFile( "materials/models/asteroid.vmt" )
	
function ENT:Initialize()
	self.AsteroidSize = "medium"
	self.isAsteroid = true
	self.SmallerAsteroid = "isogen_ore"
	self.BaseClass.Initialize( self )
end