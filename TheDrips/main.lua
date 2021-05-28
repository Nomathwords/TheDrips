local DripsMod = RegisterMod("TheDrips", 1)
local game = Game()
local MIN_FIRE_DELAY = 5
local MAX_SPEED = 2.0

local DripId = {
	SALINE = Isaac.GetItemIdByName("Saline Drip"),
	POTASSIUM = Isaac.GetItemIdByName("Potassium Drip"),
	DEWY = Isaac.GetItemIdByName("Dewy Drip"),
	HELIUM = Isaac.GetItemIdByName("Helium Drip"),
	SUSPICIOUS = Isaac.GetItemIdByName("Suspicious Drip"),
	GLUCOSE = Isaac.GetItemIdByName("Glucose Drip")
}

-- Boolean variables determining if Isaac is drippy (has any drip items)
local HasDrip = {
	Saline = false,
	Potassium = false,
	Dewy = false,
	Helium = false,
	Suspicious = false,
	Glucose = false
}

-- Stat upgrade values
local DripBonus = {
	SALINE = 3,
	SUSPICIOUS = 5,
	POTASSIUM = 0.5,
	GLUCOSE_TH = 1,
	GLUCOSE_FS = 1,
	GLUCOSE_SPEED = 0.5,
	DEWY = 5
}

-- Pill: I'm Always Angry
local ImAlwaysAngry = {
	ID = Isaac.GetPillEffectByName("I'm Always Angry"),
	BONUS_DAMAGE = 7, -- Damage increase
	BONUS_TH = 30, -- Tear height
	SCALE = Vector(1, 1), -- Size increase
	IsAngry = false -- Boolean variable determining if we have taken the pill; false to begin with
}
ImAlwaysAngry.Color = Isaac.AddPillEffectToPool(ImAlwaysAngry.ID) -- Supposed to return pill color

--Pill: Honey I Shrunk The Kid!
local HoneyIShrunkTheKid = {
	ID = Isaac.GetPillEffectByName("Honey I Shrunk The Kid!"),
	SCALE = Vector(0.75, 0.75), -- Shrink Isaac
	IsShrunk = false -- Boolean variable determining if we have taken the pill; false to begin with
}

-- Update the inventory
local function UpdateDrips(player)
	HasDrip.Saline = player:HasCollectible(DripId.SALINE)
	HasDrip.Suspicious = player:HasCollectible(DripId.SUSPICIOUS)
	HasDrip.Potassium = player:HasCollectible(DripId.POTASSIUM)
	HasDrip.Glucose = player:HasCollectible(DripId.GLUCOSE)
	HasDrip.Dewy = player:HasCollectible(DripId.DEWY)
	HasDrip.Helium = player:HasCollectible(DripId.HELIUM)
end

-- When the run starts or continues
function DripsMod:onPlayerInit(player)
	UpdateDrips(player)
end

DripsMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, DripsMod.onPlayerInit)

-- When passive effects should update
function DripsMod:onUpdate(player)
	if game:GetFrameCount() == 1 then
		
		-- Spawn items in starting room
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, DripId.SALINE,     Vector(320, 300), Vector(0,0), nil)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, DripId.SUSPICIOUS, Vector(270, 300), Vector(0,0), nil)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, DripId.POTASSIUM,  Vector(220, 300), Vector(0,0), nil)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, DripId.GLUCOSE,    Vector(370, 300), Vector(0,0), nil)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, DripId.HELIUM,     Vector(420, 300), Vector(0,0), nil)
		
		-- Add Dewy Drip to Isaac
		if player:GetName() == "Isaac" then
			player:AddCollectible(DripId.DEWY, 0, true)
		end
	end
	
	UpdateDrips(player)
	
	-- Update our Anger
	if ImAlwaysAngry.Room ~= nil and game:GetLevel():GetCurrentRoomIndex() ~= ImAlwaysAngry.Room then
	
		-- Revert pill changes
		player:SetColor(Color(1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0), 0, 0, false, false)
		player.SpriteScale = ImAlwaysAngry.NormalScale
		ImAlwaysAngry.IsAngry = false
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		player:AddCacheFlags(CacheFlag.CACHE_RANGE)
		player:EvaluateItems()
		ImAlwaysAngry.Room = nil
	end
end

DripsMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, DripsMod.onUpdate)

--When we update the cache
function DripsMod:onCache(player, cacheFlag) 

	-- Tears
	if cacheFlag == CacheFlag.CACHE_DAMAGE then
		if player:HasCollectible(DripId.SALINE) and not HasDrip.Saline then
			if player.MaxFireDelay >= MIN_FIRE_DELAY + DripBonus.SALINE then -- ensure that the fire delay is not below or equal to the cap (5) (Is 10 >= 5+3 (base tear delay))
				player.MaxFireDelay = player.MaxFireDelay - DripBonus.SALINE -- Subtract Saline's fire delay from the Max Delay (10 - 3 for Isaac)
			
			elseif player.MaxFireDelay >= MIN_FIRE_DELAY then -- Don't have an item to break the cap, and are too close to the cap to subtract (EG 7 - 3 < 5), set fire delay to the cap
				player.MaxFireDelay = MIN_FIRE_DELAY
			end
		end
	
		-- Damage
		if player:HasCollectible(DripId.SUSPICIOUS) then -- If player has Suspicious Drip
			player.Damage = player.Damage + DripBonus.SUSPICIOUS -- Give Suspicious Drip's damage up
		end
		
		if ImAlwaysAngry.IsAngry then
			player.Damage = player.Damage + ImAlwaysAngry.BONUS_DAMAGE-- Give damage after activating pill
		end
	end
	
	-- Shot Speed
	if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
		if player:HasCollectible(DripId.POTASSIUM) then -- If player has Potassium Drip
			player.ShotSpeed = player.ShotSpeed + DripBonus.POTASSIUM -- Give Potassium Drip's shotspeed up
		end
	end
	
	-- Range (not working, works in AB+, Repentance issue)
	if cacheFlag == CacheFlag.CACHE_RANGE then
		if player:HasCollectible(DripId.GLUCOSE) then -- If player has Glucose Drip
			player.TearHeight = player.TearHeight + DripBonus.GLUCOSE_TH -- Give Glucose Drip's range up
			player.TearFallingSpeed = player.TearFallingSpeed + DripBonus.GLUCOSE_FS -- Give Glucose Drip's range up
		end
		
		if ImAlwaysAngry.IsAngry then
			player.TearHeight = player.TearHeight - ImAlwaysAngry.BONUS_TH
		end
	end
		
	-- Speed
	if cacheFlag == CacheFlag.CACHE_SPEED then
		if player:HasCollectible(DripId.GLUCOSE) then -- If player has Glucose Drip
			player.MoveSpeed = player.MoveSpeed + DripBonus.GLUCOSE_SPEED -- Give Glucose Drip's speed up
		end
	end
		
	-- Luck
	if cacheFlag == CacheFlag.CACHE_LUCK then
		if player:HasCollectible(DripId.DEWY) then -- If player has Dewy Drip
			player.Luck = player.Luck + DripBonus.DEWY -- Give Dewy Drip's luck up
		end
	end
	
	-- Flight
	if cacheFlag == CacheFlag.CACHE_FLYING then
		if player:HasCollectible(DripId.HELIUM) then -- If player has Helium Drip
			player.CanFly = true -- Give the player flight
		end
	end
end

DripsMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, DripsMod.onCache)


-- I'm Always Angry Proc Code
function ImAlwaysAngry.Proc(_PillEffect)
	
	local player = game:GetPlayer(0)
	local NormalScale = player.SpriteScale
	
	player:SetColor(Color(0.0, 0.7, 0.0, 1.0, 0.0, 0.0, 0.0), 0, 0, false, false) -- (Color(Red, Green, Blue, Transparency, RedOffset, GreenOffset, BlueOffset), Duration(time), Priority(int), fadeOut(booleaen), share(boolean))
	
	if ImAlwaysAngry.IsAngry == false then -- Not taken the pill yet; save the player's DEFAULT size in case pill is taken more than once
		ImAlwaysAngry.NormalScale = player.SpriteScale -- Store the player's default size
	end
	
	ImAlwaysAngry.FormerScale = player.SpriteScale -- Set the player's last scale
	ImAlwaysAngry.IsAngry = true
	player.SpriteScale = ImAlwaysAngry.FormerScale + ImAlwaysAngry.SCALE 
	ImAlwaysAngry.Room = game:GetLevel():GetCurrentRoomIndex() -- Get current room that pill is used
	player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
	player:AddCacheFlags(CacheFlag.CACHE_RANGE)
	--player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_LEO, false)
end

DripsMod:AddCallback(ModCallbacks.MC_USE_PILL, ImAlwaysAngry.Proc, ImAlwaysAngry.ID)

-- Honey I Shrunk The Kid! Proc Code
function ImAlwaysAngry.Proc(_PillEffect)

	local player = game:GetPlayer(0)
	
	HoneyIShrunkTheKid.FormerScale = player.SpriteScale
	
	--Shrink player
	player.SpriteScale = ImAlwaysAngry.FormerScale - ImAlwaysAngry.SCALE
	
end