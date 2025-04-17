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

--- Tram customization above this line ---

local tram_vnum = self:getVNum()
local tram_room = Room.getFromVNum(tram_vnum)
local current_stop = 1
local tram_initialized = false
local tram_traveling = false

local travel_to_stop
local arrive_at_stop

local function next_stop_index()
    if current_stop == #stops then return 1 else return current_stop + 1 end
end

local function display_board(room, char, argument)
    char:echoAt("&w[&z::::: &CT&wransport &CS&wtatus &CB&woard &z:::::&w]")
    if not tram_traveling then
        char:echoAt("&zNOW BOARDING&w: &c" .. stops[current_stop].name)
        char:echoAt("&zNEXT STOP&w: &c" .. stops[next_stop_index()].name)
    else
        char:echoAt("&zEN ROUTE TO&w: &c" .. stops[current_stop].name)
    end
end

local function update_display_board()
    if not create_display_board then return end
    if display_board_message == "" then return end

    for _, stop in ipairs(stops) do
        local platform_room = Room.getFromVNum(stop.exit_vnum)
        platform_room:echo(display_board_message)
    end
end

local function create_display_boards()
    if not create_display_board then return end
    for _, stop in ipairs(stops) do
        local platform_room = Room.getFromVNum(stop.exit_vnum)
        platform_room:onLook(display_board_command, display_board)
        platform_room:onLook("", function(self, ch)
            ch:echoAt("&zA nearby &c".. display_board_command .."&z shows the tram's status.")
        end)
    end
end

travel_to_stop = function(from_stop, to_stop)
    local depart_platform = Room.getFromVNum(from_stop.exit_vnum)
    local arrive_platform = Room.getFromVNum(to_stop.exit_vnum)

    tram_traveling = true
    update_display_board()

    tram_room:getExit(from_stop.exit_direction):delete(true)
    depart_platform:echo(depart_message)
    tram_room:echo(door_close_message)

    local padding_start = 5 
    local padding_end = 5
    local usable_time = to_stop.travel_time - padding_start - padding_end
    
    if #to_stop.travel_echoes == 1 then
        local echo_time = padding_start + (usable_time / 2)
        Timer.registerTimer(echo_time * 1000, false, function()
            tram_room:echo(to_stop.travel_echoes[1])
        end):start()
    elseif #to_stop.travel_echoes > 1 then
        local num_intervals = #to_stop.travel_echoes - 1
        local echo_interval = usable_time / num_intervals
        
        for i, echo_text in ipairs(to_stop.travel_echoes) do
            local echo_time = padding_start + ((i - 1) * echo_interval)
            Timer.registerTimer(echo_time * 1000, false, function()
                tram_room:echo(echo_text)
            end):start()
        end
    end
    
    Timer.registerTimer(to_stop.travel_time * 1000, false, function()
        arrive_at_stop(to_stop)
    end):start()
end

arrive_at_stop = function(stop)
    local platform_room = Room.getFromVNum(stop.exit_vnum)
    Exit.create(tram_room, stop.exit_direction, platform_room)
    platform_room:echo(arrive_message)
    tram_room:echo(door_open_message)
    tram_traveling = false
    update_display_board()

    local stop_timer = Timer.registerTimer(stop.stop_time * 1000, false, function()
        current_stop = next_stop_index()
        travel_to_stop(stop, stops[current_stop])
    end):start()
end

local function transport_init()
    if tram_initialized then return end

    for room_exit in self:exits() do
        room_exit:delete(true)
    end

    arrive_at_stop(stops[current_stop])
    if create_display_board then create_display_boards() end
    tram_initialized = true
    
end

transport_init()
