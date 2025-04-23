# Legends of the Jedi Lua Progs
A collection of lua progs for LotJ

## tram_system.lua
A drop-in solution for a tram/shuttle system that just requires you to set up
an array of stops and the script will handle the rest.

Automatically creates a command to view the transport status at each stop's platform,
distributes ambient echoes equally through out travel time, and allows for flexible
customization of various messages.

### Example Configuration
```lua
-- Message echoed to the tram room when the tram arrives at a stop
local arrive_message = "&wA tram screeches to a halt before the platform, the doors open and passengers begin to disembark."
-- Message echoed to the tram room when the tram departs from a stop
local depart_message = "&wThe doors close and the tram pulls away from the platform, screeching down the tracks"

-- Message echoed inside the tram when it arrives at a stop
local door_open_message = "&wYour weight shifts as the trams slows down before the doors part to allow passengers to disembark."
-- Message echoed inside the tram when it departs from a stop
local door_close_message = "&wAs the doors close and the tram pulls away from the platform, the tram subtly rumbles beneath your feet."

-- If true, create command to view transport status
local create_display_board = true 
-- Word to 'look' at to view transport status
local display_board_command = "display" 
-- Message echoed to the platform rooms when the display board is updated. If empty (""), no update message will be echoed.
local display_board_message = "&wThe digital display board beeps softly as the transport information is updated."

-- List of stops for the tram
--[[
name:           Name of the stop, used for display purposes
exit_direction: Direction of the exit from the tram room to the platform room
exit_vnum:      Vnum of the platform room
stop_time:      Time the tram spends at the stop, in seconds
travel_time:    Time it takes to travel TO this stop, in seconds
travel_echoes:  List of messages echoed inside the tram as it travels TO this stop
]]
local stops = {
    {
        name = "Residential District",
        exit_direction = "north",
        exit_vnum = 430601,
        stop_time = 30,
        travel_time = 35,
        travel_echoes = {
            "&zThe &pn&Peo&pn &zlights outside gradually darken as the tram continues its journey...", 
            "&zThe ambient light w&within the tram bright&Wens as you approach the surface..."
        },
    },
    {
        name = "Industrial District",
        exit_direction = "south",
        exit_vnum = 430602,
        stop_time = 30,
        travel_time = 20,
        travel_echoes = {
            "&WThe light within &wthe tram gr&zows dim as it descends...", 
            "&zAll light fades from the windows of the tram as it continues..."
        },
    },
    {
        name = "Entertainment District",
        exit_direction = "south",
        exit_vnum = 430603,
        stop_time = 30,
        travel_time = 20,
        travel_echoes = { 
            "&zThe darkness outside the tram is gradually replaced by the &pn&Peo&pn &zlights of the entertainment district...",
        },
    }
}
```

## slicing_minigame.lua
A minigame/quest module that requires the player to play a Wordle-like slicing
game to reap the rewards (or suffer the consequences of failure!)

### Example Configuration
```lua
-- How long the slice sequence is
local slice_length = 3
-- How many attempts the user has
local slice_attempts = 5
-- How long the user has to complete the slice sequence, in seconds
local slice_timeout = 120
-- The minimum Slicer level required to begin the minigame
local slice_minimum_level = 0
-- The name of the terminal
local slice_terminal_name = "&wCorellia Security Authority"
-- The command to start the slicing minigame
local slice_command = "bypass"
-- The time the user is locked out of the terminal after failing to slice the sequence, in seconds
local slice_lockout_time = 15

-- Primary color code for display purposes
local primary_color = "&C"
-- Secondary color code for display purposes
local secondary_color = "&z"

-- Called when the user fails to slice the sequence or times out
local slice_failed = function(char)
    char:echoAt("&RYou fail to slice the sequence!")
    --This could hurt the player, damage their equipment, alert nearby rooms, or trigger messages to planetary authorities.
end

-- Called when the user successfully slices the sequence
local slice_successful = function(char)
    char:echoAt("&GYou successfully slice the sequence!")
    --This could give the player credits, reward experience, or do things like unlock nearby doors.
end
```
