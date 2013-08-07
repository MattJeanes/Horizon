AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')

-- Remove devices from link hubs if they were connected
function ENT:OnRemove()
	if self:GetClass() == "link_hub" then self:ClearDevices() end
	if self.Link != nil then self.Link:RemoveDevice( self ) end
end

function ENT:Think()
	self:netUpdate()
	return
end

-- updates status baloons
function ENT:netUpdate()
	net.Start( "netEntityInfo" )
		net.WriteEntity( self )
		net.WriteTable( {} )
	net.Broadcast()
end