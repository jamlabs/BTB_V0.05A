-- bossShot.lua
local atl = require("libsAndSnippets/ATL")
atlMap = atl.Loader.load("Maps/level0.tmx")
local bulletImg = love.graphics.newImage("assets/bullet.png")--not the actual bullet, but important for the sizes
local buW, buH  = bulletImg:getWidth(), bulletImg:getHeight()
local shotMusic = love.audio.newSource("sfx/laser.ogg"); -- sfx for lasers of miniBoss
shotMusic:setLooping(false);

bossShot2 = false 
bossBullet = {}
function createBossBullet(x,y, BbulletDir)
	table.insert(bossBullet, { x=x, y=y, width=buW-2.5, height=buH-2.5, BbulletDir = BbulletDir, vxBbu = 200 } )
	shotMusic:play();
	shotMusic:setLooping(false);
end
function bossBullet_update(dt)
	-- we need to split it or after the turret is dead the bullets won't move further 
	for Bbi,Bbv in ipairs(bossBullet) do
			if Bbv.BbulletDir == "clockwise" then  
				-- movement of the bullet to the right with velocity of Bu (overriding xPos(bu))
				Bbv.x = Bbv.x + (Bbv.vxBbu*dt) 
			elseif Bbv.BbulletDir == "anticlockwise" then
				Bbv.x = Bbv.x - (Bbv.vxBbu*dt)
			end
	end
	for Bbi,Bbv in ipairs(bossBullet) do 
		for ei,ev in ipairs(RedBoss) do 
			if Bbv.BbulletDir == "clockwise" then 
				if Bbv.x > atlMap.width*atlMap.tileWidth + (-1)*buW then
					for i=1,1 do  
						table.remove(bossBullet, Bbi)
					end
				elseif Bbv.x > ev.x + 750 then 
					for i=1,1 do
					table.remove(bossBullet, Bbi)
					end
				end
			end
			if Bbv.BbulletDir == "anticlockwise" then 
				if Bbv.x <  ev.x - (750 + buW) then
					for i=1,1 do
						table.remove(bossBullet,Bbi)
					end
				elseif Bbv.x < (atlMap.width*atlMap.tileWidth-atlMap.width*atlMap.tileWidth) + buW then 
					for i=1,1 do
						table.remove(bossBullet,Bbi)
					end
				end
			end
		end 
	end
end
function bossBullet_draw()
	for Bbi,Bbv in ipairs(bossBullet) do
		love.graphics.setColor(0,0,255); --blue lasers
		if Bbv.BbulletDir == "clockwise" then 
			love.graphics.rectangle("fill", Bbv.x+Bbv.width-40, Bbv.y+25, 20, 5);
		elseif Bbv.BbulletDir == "anticlockwise" then 
			love.graphics.rectangle("fill", Bbv.x-15, Bbv.y+25, 20, 5);
		end
		love.graphics.setColor(255,255,255);
    end
end