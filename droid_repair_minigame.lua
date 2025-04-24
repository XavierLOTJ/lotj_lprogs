local repair_command = "calibrate"
local repair_timeout = 65
local repair_minimum_level = 10
local droid_types = {
    "Astromech",
    "Protocol",
    "Medical",
    "Security"
}
local bits_length = 8

local function repair_success(char)
    char:echoAt("&zYou gained some money and fame and stuff!")
end

local function repair_failure(char)
    char:echoAt("&zYou get zapped by the droid, I guess.")
end

-- Customization above this line --

local current_bits = {}
local target_bits = {}
local repair_user = nil
local repair_timer = nil
local moves_made = 0
local repair_attempts = 0


local function flip_bits(position)
    current_bits[position] = current_bits[position] == 0 and 1 or 0
    
    if position > 1 then
        current_bits[position - 1] = current_bits[position - 1] == 0 and 1 or 0
    end
    
    if position < bits_length then
        current_bits[position + 1] = current_bits[position + 1] == 0 and 1 or 0
    end
end

local function generate_puzzle()
    current_bits = {}
    target_bits = {}
    
    for i = 1, bits_length do
        target_bits[i] = math.random(0, 1)
        current_bits[i] = target_bits[i]
    end
    
    local num_scramble_moves = math.random(5, 10)
    for i = 1, num_scramble_moves do
        local position = math.random(1, bits_length)
        flip_bits(position)
    end
    
    repair_attempts = num_scramble_moves
end

local function check_solution()
    for i = 1, bits_length do
        if current_bits[i] ~= target_bits[i] then
            return false
        end
    end
    return true
end

local function display_puzzle(char)
    local droid_type = droid_types[math.random(#droid_types)]
    
    char:echoAt("&C" .. droid_type .. " Droid Memory Calibration")
    char:echoAt("&z----------------------------------------")
    
    local position_line = "         "
    for i = 1, bits_length do
        position_line = position_line .. " &Y" .. i .. " "
    end
    char:echoAt(position_line)
    
    local current_line = "&wCURRENT&z: "
    local target_line = "&wTARGET&z:  "
    local status_line = "         "
    
    for i = 1, bits_length do
        current_line = current_line .. "&w[&z" .. current_bits[i] .. "&w]"
        target_line = target_line .. "&w[&z" .. target_bits[i] .. "&w]"
        
        status_line = status_line .. (current_bits[i] == target_bits[i] and " &GO " or " &RX ")
    end
    
    char:echoAt(current_line)
    char:echoAt(target_line)
    char:echoAt(status_line)
    
    local aligned = 0
    for i = 1, bits_length do
        if current_bits[i] == target_bits[i] then
            aligned = aligned + 1
        end
    end
    
    local percentage = math.floor((aligned / bits_length) * 100)
    char:echoAt("&zALIGNMENT: " .. percentage .. "%")
    char:echoAt("&zMOVES MADE: " .. moves_made .. "/" .. repair_attempts)
    char:echoAt("")
    char:echoAt("&CUse '" .. repair_command .. " <position>' to flip a bit.")
    char:echoAt("&Y(Flipping a bit also flips adjacent bits)")
end

local function begin_repair(self, char, argument)
    if repair_user == nil then
        if(char:getLevel("engineering") < repair_minimum_level) then
            char:echoAt("You don't quite understand the droid's memory calibration interface.")
            return
        end
        repair_user = char
        generate_puzzle()
        moves_made = 0
        
        repair_timer = Timer.registerTimer(repair_timeout * 1000, false, function()
            char:echoAt("&RYou've run out of time to calibrate the droid!")
            repair_failure(char)
            repair_user = nil
        end)
        repair_timer:start()
        
        char:echoAt("&CYou begin calibrating the droid's memory systems...")
        display_puzzle(char)
        return
    end
    
    if repair_user ~= char then
        char:echoAt("&RSomeone else is already calibrating this droid!")
        return
    end
    
    if not argument or argument == "" then
        display_puzzle(char)
        return
    end
    
    local position = tonumber(argument)
    if not position or position < 1 or position > bits_length then
        char:echoAt("&RInvalid position! Please specify a number between 1 and " .. bits_length .. ".")
        return
    end
    
    flip_bits(position)
    moves_made = moves_made + 1
    
    if check_solution() then
        char:echoAt("&GYou successfully calibrate the droid's memory banks!")
        repair_success(char)
        repair_timer:cancel()
        repair_user = nil
        return
    end
    
    if moves_made >= repair_attempts then
        char:echoAt("&RYou fail to properly calibrate the droid's memory banks!")
        repair_failure(char)
        repair_timer:cancel()
        repair_user = nil
        return
    end
    
    display_puzzle(char)
end

self:onCommand(repair_command, begin_repair)

self:onLeave(function(self, char, toRoom)
    if repair_user == char then
        repair_timer:cancel()
        repair_user = nil
        self:echo("The droid's calibration interface powers down.")
    end
end)
