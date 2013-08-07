AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')
 
function ENT:Initialize()
	self:SetModel( "models/link_hub.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )      
	self:SetMoveType( MOVETYPE_VPHYSICS )   
	self:SetSolid( SOLID_VPHYSICS ) 
	-- gamemode stuff
	self.DeviceType = "networking"
	self.connectedDevices = {}
	-- check physics
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		return
	end
	-- remove if invalid
	self:Remove()
end

-- Add a new device to this link_hub
function ENT:AddDevice( ent )
	-- link hubs should not be connected with each other
	if ent:GetClass() == "link_hub" then return	end
	-- a device should only be connected to a single link_hub
	if ent.Link != nil then	ent.Link:RemoveDevice( ent ) end
	-- connect the device to the link_hub
	self.connectedDevices[ent] = true
	ent.Link = self
end

-- Remove a device from this link_hub
function ENT:RemoveDevice( ent )
	self.connectedDevices[ent] = false
	ent.Link = nil
	if( IsValid( ent:GetPhysicsObject() ) ) then
		constraint.RemoveConstraints( ent, "Rope" )
	end
end

-- Remove all devices from this link_hub
function ENT:ClearDevices()
	for k,v in pairs( self.connectedDevices ) do
		if v then self:RemoveDevice( k ) end
	end
end

-- Stores an amount of a resource in this network, returns the rest which could not be stored in the network
function ENT:StoreResource(resName, amount)
	for k, v in pairs( self.connectedDevices ) do
		if amount <= 0 then return 0 end
		if v and k.DeviceType == "storage" then
			amount = k:AddResource( resName, amount )
		end
	end
	return amount
end

-- Retrieves an amount of a resource from this network, returns the retrieved amount
function ENT:RetrieveResource( resName, amount )
	local rest = amount
	for k, v in pairs( self.connectedDevices ) do
		if rest == 0 then return amount end
		if v and k.DeviceType == "storage" then
			rest = k:SubtractResource( resName, rest )
		end
	end
	return (amount - rest) 
end



 