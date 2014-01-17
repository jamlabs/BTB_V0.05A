-- EasyEnemy.lua
-- Type I - The Easy

require("bullet")

atl = require("libsAndSnippets/ATL")
require("libsAndSnippets/BoundingBox")

--destroyImg  = love.graphics.newImage("assets/enemy/explosion.png")

-- enemPic
standEnem    = love.graphics.newImage("assets/enemy/tutEnem.png")
stEnemHeight = standEnem:getHeight()
stEnemWidth  = standEnem:getWidth()

-- Timers for creating enemies on map
EasyEnemy = {} 
walkTimer, walkCount, countSpeed = 0, 3, .5;
function createNewEasyEnemy(x, y)
    -- r = rotation, sx = scalableX, sy = scalableY
	table.insert(EasyEnemy, { x=x, y=y, width=stEnemWidth, height=stEnemHeight, vxEnem = 50 } )
end
function enem_update(dt)
    -- Try out the movement of the Easy Enemy who just moves between two borders and doesn't react to 
	-- the players appearance even in reach of the enemy
	for ei,ev in ipairs(EasyEnemy) do
		if walkTimer >= walkCount then
			ev.x = ev.x + ev.vxEnem*dt;
			walkTimer = walkTimer + (countSpeed*dt);
		end
		if walkTimer < walkCount then
			walkTimer = walkTimer + (countSpeed*dt);
			ev.x = ev.x - ev.vxEnem*dt; 
		end
		if walkTimer >= 6 then 
			walkTimer = 0;
		end
		if ev.x > atlMap.width*atlMap.tileWidth - (ev.width+75) then 
			walkTimer = 0;
		end
	end

	-- Detect collision between bullet and enemy and bullet .. also solve it (with Snippet BoundingBox)
	-- concept: if edges overlap there's a collision to be resolved. in fact what happens here is that enemy
	-- and bullet'll be removed and the score for killing one enemy increases + 1
	for ei,ev in ipairs(EasyEnemy) do 
		for bi,bv in ipairs(bullet) do 
			if CheckCollision(ev.x,ev.y,ev.width,ev.height, bv.x,bv.y,bv.width,bv.height) then 
				table.remove(EasyEnemy, ei)
				table.remove(bullet, bi)
				xp = xp + 1
			end
		end
	end 
end
function enem_draw()
	for ei,ev in ipairs(EasyEnemy) do  
		love.graphics.draw(standEnem, ev.x, ev.y, 0, 0.99,0.99)
	end
end