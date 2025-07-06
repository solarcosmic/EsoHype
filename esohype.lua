--[[
 * Copyright (c) 2025 solarcosmic.
 * This project is licensed under the MIT license.
 * To view the license, see <https://opensource.org/licenses/MIT>.
]]
if arg[1] == null then print("Usage: lua esohype.lua <name>.hyp") return end
local doc = io.open(arg[1], "r")
io.input(doc)

local variables = {}
local variable_order = {}
local line_count = 1

function eval_var(tokens)
    local varName = tokens[2]
    local please = tokens[#tokens]
    local expr_tokens = {}

    if please ~= nil then
        if please:lower() ~= "please" and please:lower() ~= "pls" then
            print(" === Error on line "..line_count..": Not parsing this. Please mind your manners next time.")
            return
        end
    else
        print(" === Error on line "..line_count..": Not parsing this. Please mind your manners next time.")
        return
    end
    
    for i = 4, #tokens - 1 do
        local token = tokens[i]
        if variables[token] ~= nil then
            table.insert(expr_tokens, tostring(variables[token]))
        else
            table.insert(expr_tokens, token)
        end
    end

    local expr = table.concat(expr_tokens, " ")
    local chunk, err = load("return "..expr)
    local suc, res = pcall(chunk)

    if suc and res ~= nil then
        variables[varName] = res
    else
        print(" === Error on line "..line_count..": Invalid expression \""..expr.."\"")
        return
    end

    if not variable_order[varName] then
        table.insert(variable_order, varName)
        variable_order[varName] = true
    end
end

function eval_display(tokens)
    local rawValue = tokens[2]
    local please = tokens[3]

    if please ~= nil then
        if please:lower() ~= "please" and please:lower() ~= "pls" then
            print(" === Error on line "..line_count..": Not parsing this. Please mind your manners next time.")
            return
        end
    else
        print(" === Error on line "..line_count..": Not parsing this. Please mind your manners next time.")
        return
    end

    if rawValue:sub(1,1) == "\"" and rawValue:sub(-1) == "\"" then
        print(rawValue:sub(2,-2))
    else
        local numValue = tonumber(rawValue)
        if numValue ~= nil then
            print(numValue)
        else
            if variables[rawValue] == nil then
                print(" === Variable '"..rawValue.."' does not exist!")
            else
                print(variables[rawValue])
            end
        end
    end
end

-- https://stackoverflow.com/questions/17987618/how-to-add-a-sleep-or-wait-to-my-lua-script
function sleep(a) 
    local sec = tonumber(os.clock() + a); 
    while (os.clock() < sec) do end
end

function eval_wait(tokens)
    local wait = tokens[1]
    local seconds = tokens[3]

    if wait ~= nil and wait:lower() == "wait" and seconds:lower() == "seconds" then
        if tokens[4] == nil then
            print(" === Error on line "..line_count..": Not parsing this. Please mind your manners next time.")
            return
        end
        if tokens[4]:lower() ~= "pls" and tokens[4]:lower() ~= "please" then
            print(" === Error on line "..line_count..": Not parsing this. Please mind your manners next time.")
            return
        end
        if tonumber(tokens[2]) then
            sleep(tonumber(tokens[2]))
        else
            local varName = tokens[2]
            if variables[varName] == nil then
                print(" === Variable '"..rawValue.."' does not exist!")
                return
            end
            local varValue = variables[varName]
            local numValue = tonumber(varValue)
            if numValue then
                sleep(numValue)
            else
                print(" === Variable '"..varName.."' is not a qualified number!")
            end
        end
    end
end

function eval_repeat(tokens)
    local count = tonumber(tokens[2])
    if not count then
        if variables[tokens[2]] == nil then
            print(" === Variable '"..tokens[2].."' does not exist! EsoHype will pretend the loop isn't there and continue.")
            return
        end
        local varValue = variables[tokens[2]]
        local numValue = tonumber(varValue)
        if numValue then
            count = numValue
        else
            print(" === Variable '"..tokens[2].."' is not a qualified number!")
        end
    end
    
    local block_lines = {}
    for extra_line in io.lines() do
        local extra_tokens = loopTokens(extra_line)
        if extra_tokens[1]:lower() == "endrepeat" then
            break
        else
            table.insert(block_lines, extra_line)
        end
    end

    for i = 1, count do
        for _, block_line in ipairs(block_lines) do
            processLine(block_line)
        end
    end
end

function loopTokens(line)
    local tokens = {}
    for token in string.gmatch(line, "[^%s]+") do
        table.insert(tokens, token)
    end
    return tokens
end

local lineTypes = {
    ["variable"] = eval_var,
    ["display"] = eval_display,
    ["wait"] = eval_wait,
    ["repeat"] = eval_repeat
}

function processLine(line)
    local tokens = loopTokens(line)
    local lineType = getLineType(tokens)
    if lineType then
        local types = lineTypes[lineType]
        if types then
            types(tokens)
        else
            print(" === Error: Unknown line type while parsing: "..lineType)
        end
    end
end

function getLineType(tokens)
    if tokens[1] == nil then return end -- new line
    if tokens[1]:lower() == "can" and tokens[3]:lower() == "be" then
        return "variable"
    elseif tokens[1]:lower() == "display" then
        return "display" -- equivalent of print
    elseif tokens[1]:lower() == "wait" and tokens[3]:lower() == "seconds" then
        return "wait" -- wait seconds
    elseif tokens[1]:lower() == "repeat" then
        return "repeat"
    end
end

for line in io.lines() do
    processLine(line)
    line_count = line_count + 1
end
--for _, varName in ipairs(variable_order) do
--    print(varName, variables[varName])
--end
doc:close()