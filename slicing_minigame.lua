-- This can probably be reworked to live on an object prototype, but for now
-- it'll just live as a room program.

local slice_length = 3
local slice_attempts = 5
local slice_timeout = 120
local slice_minimum_level = 0
local slice_terminal_name = "&wCorellia Security Authority"
local slice_command = "bypass"
local slice_lockout_time = 15

local primary_color = "&C"
local secondary_color = "&z"

local slice_failed = function(char)
    char:echoAt("&RYou fail to slice the sequence!")
end

local slice_successful = function(char)
    char:echoAt("&GYou successfully slice the sequence!")
end

-- Customization above this line --

local slice_solution = ""
local slice_user = nil
local slice_timer = nil
local slice_inputs = {}
local print_slice_terminal
local abort_slicing

local generate_solution = function(length)
    local digits = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"}
    local solution = ""
    for i = 10, 2, -1 do
        local j = math.random(i)
        digits[i], digits[j] = digits[j], digits[i]
    end
    
    for i = 1, length do
        solution = solution .. digits[i]
    end
    
    return solution
end

local set_lockout = function(char)
    char:setVar("slice_lockout_" .. self:getVNum(), true, slice_lockout_time)
end

local handle_slice_input = function(input)
    if not input:match("^%d+$") then
        slice_user:echoAt("&RInvalid input! Memory address must contain only numerical digits (0-9).")
        return
    end

    if(string.len(input) ~= slice_length) then
        slice_user:echoAt("&RInvalid input length! Memory address must be " .. slice_length .. " digits long.")
        return
    end
    
    if(input ~= slice_solution) then
        local feedback = ""
        
        for i = 1, slice_length do
            local input_digit = input:sub(i, i)
            local solution_digit = slice_solution:sub(i, i)
            
            if input_digit == solution_digit then
                feedback = feedback .. "&G" .. input_digit
            elseif string.find(slice_solution, input_digit) then
                feedback = feedback .. "&Y" .. input_digit
            else
                feedback = feedback .. "&z" .. input_digit
            end
        end
        
        table.insert(slice_inputs, feedback)
        
        if #slice_inputs >= slice_attempts then
            slice_failed(slice_user)
            abort_slicing()
            return
        end

        print_slice_terminal(slice_user)
        
        return
    end
    
    slice_successful(slice_user)
    abort_slicing()
end

abort_slicing = function()
    slice_user = nil
    if slice_timer ~= nil then slice_timer:cancel() end
    slice_inputs = {}
    slice_solution = ""
end

print_slice_terminal = function(char)
    local min_width = 45
    local max_width = 60
    local side_padding = 8
    
    local header_width = string.len(LOTJ.stripColor(slice_terminal_name))
    local total_width = math.max(min_width, math.min(header_width + (side_padding * 2), max_width))

    local left_padding = math.floor((total_width - header_width) / 2)
    local right_padding = total_width - header_width - left_padding
    
    local terminal_line = primary_color .. "+" .. secondary_color
    terminal_line = terminal_line .. string.rep("-", total_width-2) .. "+"
    
    local header_line = primary_color .. "|" .. secondary_color  .. string.rep(" ", left_padding) .. slice_terminal_name .. string.rep(" ", right_padding)
    
    char:echoAt(terminal_line)
    char:echoAt(header_line)
    char:echoAt(terminal_line)
    char:echoAt(primary_color .. "|" .. secondary_color .. " Attempts             &w: " .. secondary_color .. #slice_inputs .. primary_color .. "/" .. secondary_color .. slice_attempts)
    char:echoAt(primary_color .. "|" .. secondary_color .. " Target memory address&w: 0x&z" ..  string.rep("?", slice_length))
    if(#slice_inputs > 0) then
        char:echoAt(primary_color .. "| " .. secondary_color .. "Address failures&w:")
        for i = 1, #slice_inputs do
            char:echoAt(primary_color .. "| &w0x" .. slice_inputs[i])
        end
    end
    char:echoAt(terminal_line)

    char:echoAt(primary_color .. "| " .. secondary_color .. "Enter memory address &w> ")
    char:echoAt("")
    char:echoAt("&zUse the &C" .. slice_command .. "&z command, followed by " .. slice_length .. " numerical digits.")
    
end

local begin_slicing = function(self, char, argument)
    if char:getVar("slice_lockout_" .. self:getVNum()) then
        char:echoAt("&RYour access to this terminal is still locked out!")
        return
    end

    if slice_user == nil then
        if(char:getLevel("slicer") < slice_minimum_level) then
            char:echoAt("You can't seem to make sense of the terminal's encrypted interface.")
            return
        end
        slice_user = char
        slice_solution = generate_solution(slice_length)
        slice_timer = Timer.registerTimer(slice_timeout * 1000, false, function()
            slice_user:echoAt("As the terminal's timeout mechanism activates, a harsh beep emits from its speakers.")
            slice_failed(char)
            abort_slicing()
        end)
        slice_timer:start()
        
    else
        if slice_user ~= char then
            char:echoAt("Someone else already using this terminal!")
            return
        end
    end
    if(string.len(argument) > 0) then
        handle_slice_input(argument)
    else
        print_slice_terminal(char)
    end

end

self:onCommand(slice_command, begin_slicing)
self:onLeave(function(self, char, toRoom)
    if slice_user == char then 
        abort_slicing() 
        self:echo("The terminal's interface flickers and shuts down as it returns to standby mode.")
    end
end)