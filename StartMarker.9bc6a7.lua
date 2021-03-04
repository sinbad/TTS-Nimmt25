
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
    delaySum = delaySum + 1
    Wait.time(function() specialDeck.deal(3) end, delaySum)
    delaySum = delaySum + 1

    -- deal to table
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

    -- Order players hands at the same time
    Wait.time(function() 
        for _, colour in ipairs(getSeatedPlayers()) do 
            local player = Player[colour]
            print(colour .. " Hand Order")
            local cardsInHand = player.getHandObjects()
            local firstCardPos = cardsInHand[1].getPosition()
            local lastCardPos = cardsInHand[#cardsInHand].getPosition()
            
            table.sort(cardsInHand, function(l, r) 
                -- special cards won't convert, sort those to end
                local lnum = tonumber(l.name)
                local rnum = tonumber(r.name)
                if lnum == nil then 
                    return false
                elseif rnum == nil then
                    return true
                else
                    return lnum < rnum
                end
            end)

            local cardInc = vector(
                (lastCardPos.x - firstCardPos.x) / (#cardsInHand - 1),
                (lastCardPos.y - firstCardPos.y) / (#cardsInHand - 1),
                (lastCardPos.z - firstCardPos.z) / (#cardsInHand - 1))
            for i, card in ipairs(cardsInHand) do
                Wait.time(function()
                    card.setPosition({0,-10,0})
                    card.deal(1, colour)
                    end, i*0.1)
                        
            end
        end
    end, delaySum)

    delaySum = delaySum + 1

    -- delete the remaining cloned decks, we don't need
    Wait.time(function() numbersDeck.destruct() end, delaySum)
    Wait.time(function() specialDeck.destruct() end, delaySum)
    delaySum = delaySum + 1

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