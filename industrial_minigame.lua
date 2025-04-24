local machine_type = "Moisture Vaporator"
local value_names = {
    "Humidity level",
    "Power output",
    "Filter saturation"
}
local duration = 60
local control_command = "operate"

local function calibrate_success(char)
    char:echoAt("&wYou gain a lot of money or something!")
end

local function calibrate_failure(char)
    char:echoAt("&wSome sort of consequence might happen here.")
end

-- Customization above this line --

local current_values = {0, 0, 0}
local target_ranges = {}
local is_active = false
local active_char = nil
local check_timer = nil
local duration_timer = nil
local elapsed_time = 0

local adjustment_impacts = {
    {3, -2, 1},
    {-1, 3, -1},
    {1, -1, 3}
}

local stop_machine
local start_machine

local function display_status(char)
    char:echoAt("&C" .. machine_type .. " Control Panel&w")
    char:echoAt("&z----------------------------------------&w")
    
    for i, name in ipairs(value_names) do
        local value = current_values[i]
        local min = target_ranges[i][1]
        local max = target_ranges[i][2]
        local status_color = "&R"
        
        if value >= min and value <= max then
            status_color = "&G"
        end
        
        local gauge = ""
        for j = 1, 20 do
            if j <= value then
                gauge = gauge .. "|"
            else
                gauge = gauge .. " "
            end
        end
        
        
        local name_padding = string.rep(" ", 19 - string.len(name))
        local display_line = "&G" .. i .. "&w. ".. name .. name_padding .. "&w[" .. status_color .. gauge .. "&w] [" .. string.format("%2d", value) .. "]"
        
        if value <= 3 then
            display_line = display_line .. " &R(!LOW!)"
        elseif value >= 17 then
            display_line = display_line .. " &R(!HIGH!)"
        end
        
        char:echoAt(display_line)
    end
    
    char:echoAt("&z----------------------------------------&w")
    char:echoAt("&CCommands: &z" .. control_command .. " &w<&C1&w-&C3&w> <&C+&w/&C-&w>")
    char:echoAt("&YWarning: Adjusting one value affects all values")
end

local function check_values()
    if not is_active then return end
    local all_in_range = true
    
    for i = 1, #current_values do
        local value = current_values[i]
        local min = target_ranges[i][1]
        local max = target_ranges[i][2]
        
        if value < min or value > max then
            all_in_range = false
            break
        end
    end
    
    if all_in_range then
        self:echo("The sputtering from the " .. string.lower(machine_type) .. " settles down as its machinery hums in harmony.")
        if active_char then
            calibrate_success(active_char)
        end
        stop_machine()
        return
    end
    
    elapsed_time = elapsed_time + 5
    
    if elapsed_time >= duration then
        if active_char then
            self:echo("&wThe " .. string.lower(machine_type) .. " sputters and dies, its inner machinery falling silent.")
            active_char:echoAt("&RYou failed to calibrate the machine in time.&w")
            if active_char then calibrate_failure(active_char) end
        end
        stop_machine()
        return
    end

    check_timer = Timer.registerTimer(5000, false, check_values)
    check_timer:start()
end

start_machine = function(char)
    if is_active then
        char:echoAt("&RThis machine is already being operated by someone else.&w")
        return
    end

    self:echo("{1} initializes the " .. string.lower(machine_type) .. ", the machinery rumbling as it starts up...", char)
    
    is_active = true
    active_char = char
    elapsed_time = 0
    
    target_ranges = {}
    for i = 1, #value_names do
        local min = math.random(5, 12)
        local max = min + math.random(2, 5)
        target_ranges[i] = {min, max}
    end
    
    for i = 1, #value_names do
        current_values[i] = math.random(3, 17)
    end
    
    char:echoAt("&CYou begin calibrating the " .. machine_type .. ".&w")
    char:echoAt("&YWarning: Adjusting one value will affect all other values!&w")
    char:echoAt("&RIf any value reaches 0 or exceeds 20, the machine will shut down!&w")
    display_status(char)
    
    check_timer = Timer.registerTimer(5000, false, check_values)
    check_timer:start()
    
    duration_timer = Timer.registerTimer(duration * 1000, false, function()
        if is_active then
            self:echo("The " .. string.lower(machine_type) .. " sputters and dies, its inner machinery falling silent.")
            if active_char then calibrate_failure(active_char) end
            stop_machine(true)
        end
    end)
    duration_timer:start()
end

stop_machine = function(from_duration)
    if not from_duration then duration_timer:cancel() end
    duration_timer = nil
    is_active = false
    active_char = nil
end

local function handle_operate(self, char, args)
    if not args or args == "" then
        if is_active and active_char ~= char then
            char:echoAt("&RThis machine is already being operated by someone else.&w")
            return
        end
        
        if not is_active then
            start_machine(char)
        else
            display_status(char)
        end
        return
    end
    
    if not is_active or active_char ~= char then
        char:echoAt("&RYou need to start the machine first with 'operate'.&w")
        return
    end
    
    local value_index, direction = args:match("(%d+)%s+([%+%-])")
    value_index = tonumber(value_index)
    
    if not value_index or value_index < 1 or value_index > #current_values then
        char:echoAt("&RInvalid value number. Use 1-" .. #current_values .. ".&w")
        return
    end
    
    local multiplier = (direction == "+") and 1 or -1
    
    for i = 1, #current_values do
        local impact = adjustment_impacts[value_index][i] * multiplier
        current_values[i] = current_values[i] + impact
        
        if current_values[i] <= 0 or current_values[i] >= 20 then
            char:echoAt("&R" .. value_names[i] .. " has reached a critical level!")
            char:echoAt("&RThe machine shuts down to prevent damage!&w")
            stop_machine()
            return
        end
    end
    
    if direction == "+" then
        char:echoAt("&wYou &Gincrease&w the " .. string.lower(value_names[value_index]) .. ", affecting all systems.&w")
    else
        char:echoAt("&wYou &Rdecrease&w the " .. string.lower(value_names[value_index]) .. ", affecting all systems.&w")
    end
    
    display_status(char)
end

self:onCommand(control_command, handle_operate)

self:onLeave(function(self, char, toRoom)
    if active_char == char then
        char:echoAt("&RYou abandon the " .. machine_type .. " calibration.&w")
        self:echo(char:getName() .. " stops operating the " .. machine_type .. ".")
        stop_machine()
    end
end)




