local Ent = FindMetaTable('Entity')
local Ply = FindMetaTable('Player')

//It may be better to just replace this with DTVars.

//Make a cache to avoid duplicate broadcasts.
local stateCache = stateCache or {}

//Turn item on with true and off by false.
function Ent:SetState(onoff)
	local index = self:EntIndex()
	if stateCache[index] == onoff then return end
	
	stateCache[index] = onoff
	
	net.Start('hznState')
		net.WriteEntity(self)
		net.WriteBit(onoff)
	net.Broadcast()
end

//Send entity state on request.
//We use this to get states when a client find out about a entity. When it enters the player PVS
local function SendState(lng, ply)

	local ent = net.ReadEntity()
	if !IsValid(ent) or !GAMEMODE:IsHznClass(ent:GetClass()) then return end
	
	net.Start('hznState')
		net.WriteEntity(ent)
		net.WriteBit((stateCache[ent:EntIndex()] == true))
	net.Send(ply)
end
net.Receive('hznGetState', SendState)

local function RemoveFromCache(ent)
	if stateCache[ent:EntIndex()] != nil then
		stateCache[ent:EntIndex()] = nil
	end
end
hook.Add('EntityRemoved', 'hznRemoveCache', RemoveFromCache)

--Add net messages.
util.AddNetworkString('hznSuit')
util.AddNetworkString('hznState')
util.AddNetworkString('hznGetState')
--
util.AddNetworkString('netEntityInfo')