ENT.Type = "brush"
ENT.Base = "base_gmodentity"
 
ENT.PrintName		= "Horizon hzn_brush_environment"
ENT.Author			= "Bynari"

function ENT:SetupDataTables( )
	self:DTVar("Float", 0, "Gravity");
	self:DTVar("Int", 1, "Priority");
	self:DTVar("Int", 2, "Temp");
	self:DTVar("Bool",0, "Breathable");
end


