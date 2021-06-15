StartDebug()
local DripsMod = RegisterMod("TheDrips", 1)
local game = Game()
local MIN_FIRE_DELAY = 5
local MAX_SPEED = 2.0

local ItemId = {
	GREEN_CANDLE = Isaac.GetItemIdByName("Green Candle"),
	ORANGE_CANDLE = Isaac.GetItemIdByName("Orange Candle"),
	PINK_CANDLE = Isaac.GetItemIdByName("Pink Candle"),
	SALINE = Isaac.GetItemIdByName("Saline Drip"),
	POTASSIUM = Isaac.GetItemIdByName("Potassium Drip"),
	DEWY = Isaac.GetItemIdByName("Dewy Drip"),
	HELIUM = Isaac.GetItemIdByName("Helium Drip"),
	SUSPICIOUS = Isaac.GetItemIdByName("Suspicious Drip"),
	GLUCOSE = Isaac.GetItemIdByName("Glucose Drip")
}

-- Boolean variables determining if Isaac has an item
local HasItem = {
	Saline = false,
	Potassium = false,
	Dewy = false,
	Helium = false,
	Suspicious = false,
	Glucose = false
}

-- Drip item stat upgrade values
local PassiveBonus = {
	SALINE = 3,
	SUSPICIOUS = 1.5,
	POTASSIUM = 0.5,
	GLUCOSE_TH = 1,
	GLUCOSE_FS = 1,
	GLUCOSE_SPEED = 0.5,
	DEWY = 3
}

-- Pill: I'm Always Angry
local ImAlwaysAngry = {
	ID = Isaac.GetPillEffectByName("I'm Always Angry"),
	BONUS_DAMAGE = 0, -- Damage increase
	BONUS_TH = 30, -- Tear height
	SCALE = Vector(1.5, 1.5), -- Size increase
	IsAngry = false -- Boolean variable determining if we have taken the pill; false to begin with
}

ImAlwaysAngry.Color = Isaac.AddPillEffectToPool(ImAlwaysAngry.ID) -- Supposed to return pill color

--Pill: Honey I Shrunk The Kid!
local HoneyIShrunkTheKid = {
	ID = Isaac.GetPillEffectByName("Honey, I Shrunk The Kid"),
	SCALE = Vector(0.25, 0.25), -- Shrink Isaac
	IsShrunk = false -- Boolean variable determining if we have taken the pill; false to begin with
}

-- Update the inventory
local function UpdateItems(player)
	HasItem.GreenCandle = player:HasCollectible(ItemId.GREEN_CANDLE)
	HasItem.OrangeCandle = player:HasCollectible(ItemId.ORANGE_CANDLE)
	HasItem.PinkCandle = player:HasCollectible(ItemId.PINK_CANDLE)
	HasItem.Saline = player:HasCollectible(ItemId.SALINE)
	HasItem.Suspicious = player:HasCollectible(ItemId.SUSPICIOUS)
	HasItem.Potassium = player:HasCollectible(ItemId.POTASSIUM)
	HasItem.Glucose = player:HasCollectible(ItemId.GLUCOSE)
	HasItem.Dewy = player:HasCollectible(ItemId.DEWY)
	HasItem.Helium = player:HasCollectible(ItemId.HELIUM)
end

-- When the run starts or continues
function DripsMod:onPlayerInit(player)
	UpdateItems(player)
end

DripsMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, DripsMod.onPlayerInit)

-- When passive effects should update
function DripsMod:onUpdate(player)

-- Beginning of run initialization
	if game:GetFrameCount() == 1 then
		
		--Spawn items in starting room
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, ItemId.SALINE,     Vector(320, 300), Vector(0,0), nil)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, ItemId.SUSPICIOUS, Vector(270, 300), Vector(0,0), nil)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, ItemId.POTASSIUM,  Vector(220, 300), Vector(0,0), nil)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, ItemId.GLUCOSE,    Vector(370, 300), Vector(0,0), nil)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, ItemId.HELIUM,     Vector(420, 300), Vector(0,0), nil)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, ItemId.GREEN_CANDLE, Vector(220, 200), Vector(0,0), nil)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, ItemId.ORANGE_CANDLE, Vector(320, 200), Vector(0,0), nil)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, ItemId.PINK_CANDLE, Vector(420, 200), Vector(0,0), nil)
		
	
		-- Add Dewy Drip to Isaac
		if player:GetName() == "Isaac" then
			player:AddCollectible(ItemId.DEWY, 0, true)
		end
		
		DripsMod.HasGreenCandle = false
		DripsMod.HasOrangeCandle = false
		DripsMod.HasPinkCandle = false
	end
	
	-- Green Candle functionality
	for playerNum = 1, Game():GetNumPlayers() do
		local player = Game():GetPlayer(playerNum)
		if player:HasCollectible(ItemId.GREEN_CANDLE) then
			if not DripsMod.HasGreenCandle then -- Initial pickup
				player:AddSoulHearts(2)
				DripsMod.HasGreenCandle = true
			end
			
			for i, entity in pairs(Isaac.GetRoomEntities()) do -- Loop to continuously poison enemies
				if entity:IsVulnerableEnemy() and math.random(500) == 1 then
					entity:AddPoison(EntityRef(player), 100, 3.5) -- 100 = duration, 3.5 = Isaac's base tear damage
				end
			end
		end
		
		--Orange Candle functionality
		if player:HasCollectible(ItemId.ORANGE_CANDLE) then
			if not DripsMod.HasOrangeCandle then -- Initial pickup
				player:AddBlackHearts(2)
				DripsMod.HasOrangeCandle = true
			end
			
			for i, entity in pairs(Isaac.GetRoomEntities()) do -- Loop to continuously poison enemies
				if entity:IsVulnerableEnemy() and math.random(500) == 1 then
					entity:AddBurn(EntityRef(player), 100, 3.5) -- 100 = duration, 3.5 = Isaac's base tear damage
				end
			end
		end

		-- Pink Candle functionality
		if player:HasCollectible(ItemId.PINK_CANDLE) then
			if not DripsMod.HasPinkCandle then -- Initial pickup
				player:AddHearts(2)
				DripsMod.HasPinkCandle = true
			end
			
			for i, entity in pairs(Isaac.GetRoomEntities()) do -- Loop to continuously poison enemies
				if entity:IsVulnerableEnemy() and math.random(500) == 1 then
					entity:AddCharmed(EntityRef(player), 100) -- 100 = duration, 3.5 = Isaac's base tear damage
				end
			end
		end 
	end
	
	-- Update our Anger
	if ImAlwaysAngry.Room ~= nil and game:GetLevel():GetCurrentRoomIndex() ~= ImAlwaysAngry.Room then

		-- Revert pill changes
		player:SetColor(Color(1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0), 0, 0, false, false)
		ImAlwaysAngry.IsAngry = false
		player.SpriteScale = ImAlwaysAngry.FormerScale
		ImAlwaysAngry.BONUS_DAMAGE = 0
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		player:AddCacheFlags(CacheFlag.CACHE_RANGE)
		player:EvaluateItems()
		ImAlwaysAngry.Room = nil
	end

	-- Unshrink Isaac!
	if HoneyIShrunkTheKid.Room ~= nil and game:GetLevel():GetCurrentRoomIndex() ~= HoneyIShrunkTheKid.Room then

		-- Revert pill changes
		HoneyIShrunkTheKid.IsShrunk = false
		player.SpriteScale = HoneyIShrunkTheKid.FormerScale
		player:AddCacheFlags(CacheFlag.CACHE_SPEED)
		player:EvaluateItems()
		HoneyIShrunkTheKid.Room = nil
	end

	UpdateItems(player)
end

DripsMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, DripsMod.onUpdate)

-- I'm Always Angry Proc Code
function ImAlwaysAngry.Proc(_PillEffect)

	local player = game:GetPlayer(0)
	ImAlwaysAngry.Room = game:GetLevel():GetCurrentRoomIndex() -- Get current room that pill is used

	if ImAlwaysAngry.IsAngry == false then
		ImAlwaysAngry.BONUS_DAMAGE = ImAlwaysAngry.BONUS_DAMAGE + 3
		ImAlwaysAngry.FormerScale = player.SpriteScale
		player:SetColor(Color(0.0, 0.7, 0.0, 1.0, 0.0, 0.0, 0.0), 0, 0, false, false) -- (Color(Red, Green, Blue, Transparency, RedOffset, GreenOffset, BlueOffset), Duration(time), Priority(int), fadeOut(booleaen), share(boolean))
		--player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_LEO, false)
	end
	
	ImAlwaysAngry.BONUS_DAMAGE = ImAlwaysAngry.BONUS_DAMAGE + 0.5
	
	player.SpriteScale = player.SpriteScale + ImAlwaysAngry.SCALE -- Make Isaac Hulk out
	player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
	player:AddCacheFlags(CacheFlag.CACHE_RANGE) -- Not working currently
	ImAlwaysAngry.IsAngry = true
end 

DripsMod:AddCallback(ModCallbacks.MC_USE_PILL, ImAlwaysAngry.Proc, ImAlwaysAngry.ID)

-- Honey, I Shrunk The Kid Proc Code
function HoneyIShrunkTheKid.Proc(PillEffect)

	local player = game:GetPlayer(0)
	HoneyIShrunkTheKid.Room = game:GetLevel():GetCurrentRoomIndex() -- Get current room that pill is used (always do this first!)
	
	if HoneyIShrunkTheKid.IsShrunk == false then -- Not taken the pill yet; save the player's DEFAULT size in case pill is taken more than once
		HoneyIShrunkTheKid.FormerScale = player.SpriteScale -- Store the player's default size
		player.SpriteScale = HoneyIShrunkTheKid.SCALE
	end
	
	player:AddCacheFlags(CacheFlag.CACHE_SPEED)
	
	--Shrink player
	--player.SpriteScale = player.SpriteScale - HoneyIShrunkTheKid.SCALE
	
	HoneyIShrunkTheKid.IsShrunk = true
end 

DripsMod:AddCallback(ModCallbacks.MC_USE_PILL, HoneyIShrunkTheKid.Proc, HoneyIShrunkTheKid.ID)

--When we update the cache
function DripsMod:onCache(player, cacheFlag) 

	-- Tears
	if cacheFlag == CacheFlag.CACHE_DAMAGE then
		if player:HasCollectible(ItemId.SALINE) and not HasItem.Saline then
			if player.MaxFireDelay >= MIN_FIRE_DELAY + PassiveBonus.SALINE then -- ensure that the fire delay is not below or equal to the cap (5) (Is 10 >= 5+3 (base tear delay))
				player.MaxFireDelay = player.MaxFireDelay - PassiveBonus.SALINE -- Subtract Saline's fire delay from the Max Delay (10 - 3 for Isaac)
			
			elseif player.MaxFireDelay >= MIN_FIRE_DELAY then -- Don't have an item to break the cap, and are too close to the cap to subtract (EG 7 - 3 < 5), set fire delay to the cap
				player.MaxFireDelay = MIN_FIRE_DELAY
			end
		end
	
		-- Damage
		if player:HasCollectible(ItemId.SUSPICIOUS) then -- If player has Suspicious Drip
			player.Damage = player.Damage + PassiveBonus.SUSPICIOUS -- Give Suspicious Drip's damage up
		end
		
		if ImAlwaysAngry.IsAngry == true then
			player.Damage = player.Damage + ImAlwaysAngry.BONUS_DAMAGE-- Give damage after activating pill
		end
	end
	
	-- Shot Speed
	if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
		if player:HasCollectible(ItemId.POTASSIUM) then -- If player has Potassium Drip
			player.ShotSpeed = player.ShotSpeed + PassiveBonus.POTASSIUM -- Give Potassium Drip's shotspeed up
		end
	end
	
	-- Range (not working, works in AB+, Repentance issue)
	if cacheFlag == CacheFlag.CACHE_RANGE then
		if player:HasCollectible(ItemId.GLUCOSE) then -- If player has Glucose Drip
			player.TearHeight = player.TearHeight + PassiveBonus.GLUCOSE_TH -- Give Glucose Drip's range up
			player.TearFallingSpeed = player.TearFallingSpeed + PassiveBonus.GLUCOSE_FS -- Give Glucose Drip's range up
		end
		
		if ImAlwaysAngry.IsAngry then
			player.TearHeight = player.TearHeight - ImAlwaysAngry.BONUS_TH
		end
	end

	-- Speed
	if cacheFlag == CacheFlag.CACHE_SPEED then
		if player:HasCollectible(ItemId.GLUCOSE) then -- If player has Glucose Drip
			player.MoveSpeed = player.MoveSpeed + PassiveBonus.GLUCOSE_SPEED -- Give Glucose Drip's speed up
		end
		
		if HoneyIShrunkTheKid.IsShrunk then
			player.MoveSpeed = MAX_SPEED
		end
	end
		
	-- Luck
	if cacheFlag == CacheFlag.CACHE_LUCK then
		if player:HasCollectible(ItemId.DEWY) then -- If player has Dewy Drip
			player.Luck = player.Luck + PassiveBonus.DEWY -- Give Dewy Drip's luck up
		end
	end
	
	-- Flight
	if cacheFlag == CacheFlag.CACHE_FLYING then
		if player:HasCollectible(ItemId.HELIUM) then -- If player has Helium Drip
			player.CanFly = true -- Give the player flight
		end
	end
end

DripsMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, DripsMod.onCache)