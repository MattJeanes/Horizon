AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')
 
function ENT:Initialize()
	self.Link = nil
	self.Active = false
	self.DeviceType = "generator"
	self.LastThink = 0
	self.ThinkRate = 1
	-- consumed resources
	self.ConsumedResources = {}
	self.ConsumedResourceRates = {}
	-- produced resources
	self.ProducedResources = {}
	self.ProducedResourceRates = {}
end

function ENT:RegisterConsumedResource( resName, rate )
	if self.ConsumedResources[resName] then return end
	self.ConsumedResources[resName] = true
	self.ConsumedResourceRates[resName] = rate
end

function ENT:DeregisterConsumedResource( resName )
	if not self.ConsumedResources[resName] then return end
	self.ConsumedResources[resName] = false
	self.ConsumedResourceRates[resName] = nil
end

function ENT:RegisterProducedResource( resName, rate )
	if self.ProducedResources[resName] then return end
	self.ProducedResources[resName] = true
	self.ProducedResourceRates[resName] = rate
end

function ENT:DeregisterProducedResource( resName )
	if not self.ProducedResources[resName] then return end
	self.ProducedResources[resName] = false
	self.ProducedResourceRates[resName] = nil
end

function ENT:RequirementsAvailable()
	local cond = true
	for resName, c in pairs( self.ConsumedResources ) do
		if c then
			local a = self.Link:RetrieveResource( resName, self.ConsumedResourceRates[resName] )
			cond = cond and (a >= self.ConsumedResourceRates[resName])
			self.Link:StoreResource( resName, a )
		end
	end
	return cond
end

function ENT:ConsumeResources()
	for resName, c in pairs( self.ConsumedResources ) do
		if c then
			self.Link:RetrieveResource( resName, self.ConsumedResourceRates[resName] )
		end
	end
end

function ENT:ProduceResources()
	for resName, c in pairs( self.ProducedResources ) do
		if c then
			self.Link:StoreResource( resName, self.ProducedResourceRates[resName] )
		end
	end
end

function ENT:Think()
	-- schedule next think
	local CTime = CurTime()
	self.Entity:NextThink( CTime )
	if self.LastThink + self.ThinkRate > CTime then return end
	self.LastThink = CTime
	self:netUpdate()
	-- check individual requirements
	if not self.Active or self.Link == nil then return end
	if not self:CanOperate() then return end
	-- check if requirements are met
	if self:RequirementsAvailable() then
		self:ConsumeResources()
		self:ProduceResources()
		return
	end
	self:Failed()
end

function ENT:netUpdate() end

function ENT:CanOperate() end

function ENT:Failed() end

function ENT:netUpdate()
	local tab = {}
	tab[ "active" ] = self.Active
	table.Merge( tab, self.ConsumedResourceRates)
	table.Merge( tab, self.ProducedResourceRates)
	net.Start( "netEntityInfo" )
		net.WriteEntity( self )
		net.WriteTable( tab )
	net.Broadcast()
end

 