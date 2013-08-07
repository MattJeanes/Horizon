AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')
 
function ENT:Initialize()
	self.Link = nil
	self.DeviceType = "storage"
	self.StorableResources = {}
	self.StoredResources = {}
	self.MaxStoredResources = {}
end

function ENT:RegisterResource( resName, maxAmount )
	if self.StorableResources[resName] then return end
	self.StorableResources[resName] = true
	self.StoredResources[resName] = 0
	self.MaxStoredResources[resName] = maxAmount
end

function ENT:DeregisterResource( resName )
	if not self.StorableResources[resName] then return end
	self.StorableResources[resName] = false
	self.StoredResources[resName] = nil
	self.MaxStoredResources[resName] = nil
end

-- returns the rest which could not be added to the tank
function ENT:AddResource( resName, amount )
	amount = math.abs( amount )
	if not self.StorableResources[resName] then return amount end
	self.StoredResources[resName] = self.StoredResources[resName] + amount
	if self.StoredResources[resName] > self.MaxStoredResources[resName] then 
		local rest = self.StoredResources[resName] - self.MaxStoredResources[resName]
		self.StoredResources[resName] = self.MaxStoredResources[resName]
		return rest
	end
	return 0
end

-- returns the rest which could not be subtracted from the tank
function ENT:SubtractResource( resName, amount )
	amount = math.abs( amount )
	if not self.StorableResources[resName] then return amount end
	self.StoredResources[resName] = self.StoredResources[resName] - amount
	if self.StoredResources[resName] < 0 then
		local rest = math.abs( self.StoredResources[resName] )
		self.StoredResources[resName] = 0
		return rest
	end
	return 0
end

function ENT:GetResourceAmount( resName )
	if not self.StorableResources[resName] then return 0 end
	return self.StoredResources[resName]
end

function ENT:SetResourceAmount( resName, amount )
	amount = math.abs( amount )
	if not self.StorableResources[resName] then return end
	if amount <= self.MaxStoredResources[resName] then
		self.StoredResources[resName] = amount
		return
	end
	self.StoredResources[resName] = self.MaxStoredResources[resName]
end

function ENT:netUpdate()
	net.Start( "netEntityInfo" )
		net.WriteEntity( self )
		net.WriteTable( self.StoredResources )
	net.Broadcast()
end