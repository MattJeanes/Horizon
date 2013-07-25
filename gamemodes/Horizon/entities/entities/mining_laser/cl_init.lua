include('shared.lua')

local Laser = Material( "cable/redlaser" )

ENT.RenderGroup = RENDERGROUP_BOTH;

function ENT:Draw()
	self:DrawModel()
	if self.Active == nil then self.Active = false end
	if self.targetPos == nil then self.targetPos = Vector(0, 0, 100) end
	local Vector1 = self:LocalToWorld( Vector( 0, 0, -10 ) )
	local Vector2 = self:LocalToWorld( self.targetPos )
	render.SetMaterial( Laser )
	self:SetRenderBoundsWS( Vector1, Vector2 )
	if self.Active then
		render.DrawBeam( Vector1, Vector2, 5, 1, 1, Color( 255, 255, 255, 255 ) ) 
	end
end