--[[
Advanced Tiled Collider Version 0.14
Copyright (c) 2013 Minh Ngo

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]

-- [Notice]:
-- This is a slightly modified version. The following functions from Version 0.22 have been added to make sure that the player does not fall through the map [MS Win]:
-- e:setActive(bool), e:setBullet(bool), e:setBullet(bool), e:isActive(), e:isBullet()
-- Also added function to draw images: e:draw().
-- You can find the latest Version 0.22 by Minh Ngo here - link: https://github.com/markandgo/AT-Collider 
-- ~ Gaichu, 06. Aug. 2013
local floor = math.floor
local ceil  = math.ceil
local max   = math.max
local min   = math.min
-----------------------------------------------------------
-- class
local e   = 
	{
	class    = 'collider',
	isActive = true,
	isBullet = false,
	}
e.__index = e
e.new     = function(x,y,w,h,map,tileLayer)
	local t =
	{
		x           = x,
		y           = y,
		w           = w,
		h           = h,
		map         = map,
		tileLayer   = tileLayer,
	}
	return setmetatable(t,e)
end
-----------------------------------------------------------
local mw,mh,gx,gy
function e:getTileRange()
	mw,mh   = self.map.tileWidth,self.map.tileHeight
	gx,gy   = floor(self.x/mw),floor(self.y/mh)
	gx2,gy2 = ceil( (self.x+self.w)/mw )-1,ceil( (self.y+self.h)/mh )-1
	return gx,gy,gx2,gy2
end
-----------------------------------------------------------
-- collision callback, return true if tile/slope is collidable
function e:isResolvable(side,gx,gy,tile)
end
-----------------------------------------------------------
function e:rightSideResolve(gx,gy,gx2,gy2)
	local mw,mh   = self.map.tileWidth,self.map.tileHeight
	local newx    = self.x
	local tx,tile = gx2
	local tL      = self.tileLayer
	-- right sensor check
	for ty = gy,gy2 do 
		tile = tL(tx,ty)
		if tile then
			-- check if tile is a slope
			if tile.properties.horizontalHeightMap then
				local hmap = tile.properties.horizontalHeightMap
				-- use endpoints to check for collision
				-- convert endpoints of side into height index
				local ti = gy ~= ty and 1 or floor(self.y-ty*mh)+1
				local bi = gy2 ~= ty and mh or ceil(self.y+self.h-ty*mh)
				-- take the farthest position from the slope 
				local minx = min(self.x,(tx+1)*mw-self.w-hmap[ti],(tx+1)*mw-self.w-hmap[bi])
				-- if the new position is not same as the original position
				-- then we have a slope overlap
				if minx ~= self.x and self:isResolvable('right',tx,ty,tile) then
					newx = min(minx,newx)
				end
			elseif self:isResolvable('right',tx,ty,tile) then
				newx = (tx*mw)-self.w
			end
		end
	end
	self.x = newx
end
-----------------------------------------------------------
function e:leftSideResolve(gx,gy,gx2,gy2)
	local mw,mh   = self.map.tileWidth,self.map.tileHeight
	local newx    = self.x
	local tx,tile = gx
	local tL      = self.tileLayer
	for ty = gy,gy2 do 
		tile = tL(tx,ty)
		if tile then
			if tile.properties.horizontalHeightMap then
				local hmap = tile.properties.horizontalHeightMap
				local ti   = gy ~= ty and 1 or floor(self.y-ty*mh)+1
				local bi   = gy2 ~= ty and mh or ceil(self.y+self.h-ty*mh)
				local maxx = max(self.x,tx*mw+hmap[ti],tx*mw+hmap[bi])
				if maxx ~= self.x and self:isResolvable('left',tx,ty,tile) then
					newx = max(maxx,newx)
				end
			elseif self:isResolvable('left',tx,ty,tile) then
				newx = (tx+1)*mw
			end
		end
	end
	self.x = newx
end
-----------------------------------------------------------
function e:bottomSideResolve(gx,gy,gx2,gy2)
	local mw,mh   = self.map.tileWidth,self.map.tileHeight
	local newy    = self.y
	local ty,tile = gy2
	local tL      = self.tileLayer
	for tx = gx,gx2 do
		tile = tL(tx,ty)
		if tile then
			if tile.properties.verticalHeightMap then
				local hmap = tile.properties.verticalHeightMap
				local li   = gx ~= tx and 1 or floor(self.x-tx*mw)+1
				local ri   = gx2 ~= tx and mw or ceil((self.x+self.w)-tx*mw)
				local miny = min(self.y,(ty+1)*mh-self.h-hmap[li],(ty+1)*mh-self.h-hmap[ri])
				if miny ~= self.y and self:isResolvable('bottom',tx,ty,tile) then
					newy = min(miny,newy)
				end
			elseif self:isResolvable('bottom',tx,ty,tile) then
				newy = ty*mh-self.h
			end
		end
	end
	self.y = newy
end
-----------------------------------------------------------
function e:topSideResolve(gx,gy,gx2,gy2)
	local mw,mh   = self.map.tileWidth,self.map.tileHeight
	local newy    = self.y
	local ty,tile = gy
	local tL      = self.tileLayer
	for tx = gx,gx2 do
		tile = tL(tx,ty)
		if tile then
			if tile.properties.verticalHeightMap then
				local hmap = tile.properties.verticalHeightMap
				local li   = gx ~= tx and 1 or floor(self.x-tx*mw)+1
				local ri   = gx2 ~= tx and mw or ceil((self.x+self.w)-tx*mw)
				local maxy = max(self.y,ty*mh+hmap[li],ty*mh+hmap[ri])
				if maxy ~= self.y and self:isResolvable('top',tx,ty,tile) then
					newy = max(maxy,newy)
				end
			elseif self:isResolvable('top',tx,ty,tile) then
				newy = (ty+1)*mh
			end
		end
	end
	self.y = newy
end
-----------------------------------------------------------
function e:resolveX()
	local oldx          = self.x
	local gx,gy,gx2,gy2 = self:getTileRange()
	self:rightSideResolve(gx,gy,gx2,gy2)
	if oldx == self.x then self:leftSideResolve(gx,gy,gx2,gy2) end
end
-----------------------------------------------------------
function e:resolveY()
	local oldy          = self.y
	local gx,gy,gx2,gy2 = self:getTileRange()
	self:bottomSideResolve(gx,gy,gx2,gy2)
	if oldy == self.y then self:topSideResolve(gx,gy,gx2,gy2) end
end
-----------------------------------------------------------
-----------------------------------------------------------
function e:move(dx,dy)
	if not self.isActive then self.x,self.y = self.x+dx,self.y+dy return self end
	if not self.isBullet then
		self.x = self.x+dx
		self:resolveX()
		self.y = self.y+dy
		self:resolveY()
		return self
	end
	
	local mw,mh         = self.map.tileWidth,self.map.tileHeight
	local finalx,finaly = self.x+dx,self.y+dy
	local gx,gy,gx2,gy2,x,oldx,y,oldy,newx,newy,gd,least
	-----------------------------------------------------------
	-- x direction collision detection
	gx,gy,gx2,gy2 = self:getTileRange(self.x,self.y,self.w,self.h)
	
	local gd,least
	if dx >= 0 then
		least   = min
		gx,gx2  = gx2,ceil((self.x+self.w+dx)/mw)-1
		gd      = 1
	elseif dx < 0 then
		least   = max
		gx2     = floor((self.x+dx)/mw)
		gd      = -1
	end
		
	-- continuous collision detection by moving cell by cell
	for tx = gx,gx2,gd do
		if dx >= 0 then 
			self.x = least((tx+1)*mw-self.w,finalx) 
		else 
			self.x = least(tx*mw,finalx) 
		end
		newx  = self.x
		self:resolveX()
		-- if there was a collision, quit movement
		if self.x ~= newx then break end
		-- height correction so we can continue moving horizontally
		self:resolveY()
	end	
	-----------------------------------------------------------
	-- y direction collision detection
	gx,gy,gx2,gy2 = self:getTileRange(self.x,self.y,self.w,self.h)
	
	if dy >= 0 then
		least   = min
		gy,gy2  = gy2,ceil((self.y+self.h+dy)/mh)-1
		gd      = 1
	elseif dy < 0 then
		least   = max
		gy2     = floor((self.y+dy)/mh)
		gd      = -1
	end
		
	for ty = gy,gy2,gd do
		if dy >= 0 then 
			self.y = least((ty+1)*mh-self.h,finaly)
		else 
			self.y = least(ty*mh,finaly) 
		end
		newy  = self.y
		self:resolveY()
		if self.y ~= newy then break end
		self:resolveX()
	end	
end
-----------------------------------------------------------
function e:moveTo(x,y)
	self:move(x-self.x,y-self.y)
end
-----------------------------------------------------------
function e:setActive(bool)
self.isActive = bool
return self
end
-----------------------------------------------------------
function e:setBullet(bool)
self.isBullet = bool
return self
end	
-----------------------------------------------------------
function e:isActive()
return self.isActive
end
-----------------------------------------------------------
function e:isBullet()
return self.isBullet
end
-----------------------------------------------------------
function e:draw(Drawable)
	love.graphics.draw(Drawable, self.x, self.y, 0, 1, 1, 0, 0)
end
-----------------------------------------------------------
function e:drawRectangle(mode)
	love.graphics.rectangle(mode,self.x,self.y,self.w,self.h)
end
-----------------------------------------------------------
return e