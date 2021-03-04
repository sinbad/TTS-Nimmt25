
numbersDeckGUID = "356100"
specialDeckGUID = "337158"
menuMarkerGUID = "9bc6a7"
tableCardMarkerGUID = "436d75"

function onLoad()
    self.createButton({
        click_function = "gameSetup",
        function_owner = self,
        label          = "Deal New Game",
        position       = {-3, 0, 0},
        rotation       = {0,0,0},
        rotation       = {0,180,0}, 
        height         = 350, 
        width          = 2000,
        font_size      = 250, 
        scale          = {1.5, 1.5, 1.5},
        color          = {0.5,0,0}, 
        font_color     = {1,1,1},
        
    })

    origNumbersDeck = getObjectFromGUID(numbersDeckGUID)
    origSpecialDeck = getObjectFromGUID(specialDeckGUID)
    tableCardMarker = getObjectFromGUID(tableCardMarkerGUID)
    allPlayers = {"White", "Red", "Orange", "Yellow", "Green", "Blue", "Purple", "Pink"}

    tableCardMarker.setInvisibleTo(allPlayers)

    -- Flip this boolean if you want to be able to edit the master decks
    hideMasterDeck(false)


end

function gameSetup()

    -- Clear every card from the table except the original decks
    local allObjects = getAllObjects()
    for index, object in ipairs(allObjects) do
        if not (object.guid == numbersDeckGUID or 
            object.guid == specialDeckGUID or 
            object.guid == menuMarkerGUID or
            object.guid == tableCardMarkerGUID) then
            object.destruct()
        end
    end

    -- Clone decks, this is what lets us just destroy things
    local numbersDeck = origNumbersDeck.clone({
        position     = {3, 3, 10},
        snap_to_grid = true,
    })
    local specialDeck = origSpecialDeck.clone({
        position     = {6, 3, 10},
        snap_to_grid = true,
    })

    -- Do everything with a 1 second delay to make sure we wait for previous
    delaySum = 0

    -- shuffle both at the same time
    Wait.time(function() numbersDeck.shuffle() end, delaySum)
    Wait.time(function() specialDeck.shuffle() end, delaySum)
    delaySum = delaySum + 1

    -- Deal to players
    Wait.time(function() numbersDeck.deal(12) end, delaySum)
    Wait.time(function() specialDeck.deal(3) end, delaySum)
    delaySum = delaySum + 1

    -- Order players hands BEFORE dealing specials
    Wait.time(function() 
        for _, colour in ipairs(getSeatedPlayers()) do 
            local player = Player[colour]
            print(colour .. " Hand Order")
            local cardsInHand = player.getHandObjects()
            
            local hideCardsPos = cardsInHand[1].getPosition()
            hideCardsPos.y = hideCardsPos.y - 5
            table.sort(cardsInHand, function(l, r) 
                -- special cards won't convert, sort those to end
                local lnum = tonumber(l.getName())
                local rnum = tonumber(r.getName())
                if lnum == nil and rnum == nil then -- both specials
                    return l.getName() < l.getName() -- must have stable ordering
                else
                    if lnum == nil then
                        return false -- swap when special is to the left of non-special
                    elseif rnum == nil then
                        return true
                    else
                        return lnum < rnum
                    end
                end
            end)

            -- Iterating cardsInHand is not in index order because ffs lua only has maps
            -- So iterate range and de-ref
            for i=1,#cardsInHand do
                local card = cardsInHand[i]
                card.setPosition(hideCardsPos)
            end
            for i=1,#cardsInHand do
                local card = cardsInHand[i]
                Wait.time(function()
                    card.deal(1, colour)
                    end, i*0.2)
                        
            end
        end
    end, delaySum)

    -- deal to table at same time
	Wait.time(function()
		local basePos = tableCardMarker.getPosition()
		for i=1, 4 do
			local pos = {basePos.x, basePos.y, basePos.z - i*3.46}
            numbersDeck.takeObject({
                position          = pos,
                flip              = true
            })
        end
	end, delaySum)


    -- Spawn player bags
	Wait.time(function()
        for _, colour in ipairs(getSeatedPlayers()) do 
            local player = Player[colour]
            local xform = player.getHandTransform()

            -- xform.position
            -- xform.forward
            -- xform.right

            local bagPos = xform.position + (xform.forward * 5) + (xform.right * -4)

            spawnObject({
                type              = "bag",
                position          = bagPos,
                scale             = vector(0.85, 0.85, 0.85),
                callback_function = function(obj) playerScoreBagSpawned(obj, colour) end,
                snap_to_grid      = true -- important! otherwise can't drag cards in
            })
        end
	end, delaySum)



    delaySum = delaySum + 0.2

    -- delete the remaining cloned decks, we don't need
    Wait.time(function() numbersDeck.destruct() end, delaySum)
    Wait.time(function() specialDeck.destruct() end, delaySum)
    delaySum = delaySum + 0.2

end

function onObjectEnterContainer(container, obj) 
    print("Bag enter: " .. container.getName() .. " " .. obj.getName()) 
end    

function playerScoreBagSpawned(bag, colour)
    bag.setName(colour .. "'s Scoring Bag")
    bag.setColorTint(colour)
end

function showMasterDeckClicked()
    origNumbersDeck.setInvisibleTo({})
    origSpecialDeck.setInvisibleTo({})

    if (#self.getButtons() > 1) then 
        self.removeButton(1)
    end
    self.createButton({
        click_function = "hideMasterDeckClicked",
        function_owner = self,
        label          = "Hide Master",
        position       = {-12, 0, 0},
        rotation       = {0,0,0},
        rotation       = {0,180,0}, 
        height         = 350, 
        width          = 2000,
        font_size      = 250, 
        scale          = {1.5, 1.5, 1.5},
        color          = {0.5,0.5,0}, 
        font_color     = {1,1,1},
        
    })

end

function hideMasterDeckClicked()
    hideMasterDeck(true)
end

function hideMasterDeck(allowUnhiding)
    -- Make invisible to everyone except admin (Black)
    origNumbersDeck.setInvisibleTo(allPlayers)
    origSpecialDeck.setInvisibleTo(allPlayers)

    if (#self.getButtons() > 1) then 
        self.removeButton(1)
    end
    if allowUnhiding then
        self.createButton({
            click_function = "showMasterDeckClicked",
            function_owner = self,
            label          = "Show Master",
            position       = {-12, 0, 0},
            rotation       = {0,0,0},
            rotation       = {0,180,0}, 
            height         = 350, 
            width          = 2000,
            font_size      = 250, 
            scale          = {1.5, 1.5, 1.5},
            color          = {0.5,0.5,0}, 
            font_color     = {1,1,1},    
        })
    end


end