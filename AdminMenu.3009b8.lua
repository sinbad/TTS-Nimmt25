-- build admin menu

adminMarkerGUID = "3009b8"
numbersDeckGUID = "356100"
specialDeckGUID = "337158"
tableCardMarkerGUID = "436d75"
allPlayers = {"White", "Red", "Orange", "Yellow", "Green", "Blue", "Purple", "Pink", "Grey"}


function onLoad()
    self.createButton({
        click_function = "newManualDecks",
        function_owner = self,
        label          = "New Manual Decks",
        position       = {0, 0.25, 0},
        rotation       = {0,0,0},
        rotation       = {0,180,0}, 
        height         = 350, 
        width          = 2200,
        font_size      = 250, 
        scale          = {3, 3, 3},
        color          = {0,0,0}, 
        hover_color    = {0.3, 0.3, 0.3},
        font_color     = {1,1,1},
        
    })

    origNumbersDeck = getObjectFromGUID(numbersDeckGUID)
    origSpecialDeck = getObjectFromGUID(specialDeckGUID)
    tableCardMarker = getObjectFromGUID(tableCardMarkerGUID)

    -- hide self from all but admin
    self.setInvisibleTo(allPlayers)


    -- hide master decks to everyone else
    hideMasters()


end

function newManualDecks()
    -- This is a backup routine to create manual decks we can play with if necessary
    local numbersDeck = origNumbersDeck.clone({
        position     = {0, 3, 0},
        snap_to_grid = true,
    })
    local specialDeck = origSpecialDeck.clone({
        position     = {3, 3, 0},
        snap_to_grid = true,
    })

end

function hideMasters()
    -- Make invisible to everyone except admin (Black)
    origNumbersDeck.setInvisibleTo(allPlayers)
    origSpecialDeck.setInvisibleTo(allPlayers)
    tableCardMarker.setInvisibleTo(allPlayers)

end

function showMastersClicked()
    origNumbersDeck.setInvisibleTo({})
    origSpecialDeck.setInvisibleTo({})
    tableCardMarker.setInvisibleTo({})

    if (#self.getButtons() > 1) then 
        self.removeButton(1)
    end
    self.createButton({
        click_function = "hideMastersClicked",
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