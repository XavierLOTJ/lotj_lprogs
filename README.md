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