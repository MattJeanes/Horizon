AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')
 
function ENT:Initialize()
	self.Link = nil
	self.Active = false
	self.DeviceType = "generator"
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

function ENT:ProduceResources( FTime )
	for resName, c in pairs( self.ProducedResources ) do
		if c then
			self.Link:StoreResource( resName, self.ProducedResourceRates[resName] * FTime )
		end
	end
end

function ENT:ConsumeResources( FTime )
	for resName, c in pairs( self.ConsumedResources ) do
		if c then
			self.Link:RetrieveResource( resName, self.ConsumedResourceRates[resName] * FTime )
		end
	end
end

function ENT:RequirementsAvailable( FTime )
	local cond = true
	for resName, c in pairs( self.ConsumedResources ) do
		if c then
			local a = self.Link:RetrieveResource( resName, self.ConsumedResourceRates[resName] * FTime )
			cond = cond and (a >= self.ConsumedResourceRates[resName] * FTime )
			self.Link:StoreResource( resName, a )
		end
	end
	return cond
end

function ENT:Think()
	-- schedule next think
	local CTime = CurTime()
	local FTime = FrameTime()
	self.Entity:NextThink( CTime )
	self:netUpdate()
	-- check individual requirements
	if not self.Active or self.Link == nil then return true end
	if not self:CanOperate() then return true end
	-- check if requirements are met
	if self:RequirementsAvailable( FTime ) then
		self:ConsumeResources( FTime )
		self:ProduceResources( FTime )
		self:Execute()
		return true
	end
	self:Failed()
	return true
end

function ENT:CanOperate() return false end

function ENT:Execute() return end

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