--[[
 * Copyright (c) 2025 solarcosmic.
 * This project is licensed under the MIT license.
 * To view the license, see <https://opensource.org/licenses/MIT>.
]]
if arg[1] == nil then print("Usage: lua esohype.lua <name>.hyp") return end
local doc = io.open(arg[1], "r")
if doc == nil then print(" === Error: Invalid file. Please check to make sure the file is correct. Usage: lua esohype.lua <name>.hyp") return end
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

    local is_single_token = (#tokens - 4 + 1) == 1
    local token = tokens[4]

    if is_single_token then
        if variables[token] ~= nil then
            variables[varName] = variables[token]
        else
            local num = tonumber(token)
            if num ~= nil then
                variables[varName] = num
            else
                -- It's a literal string
                variables[varName] = token
            end
        end
    else
        for i = 4, #tokens - 1 do
            local t = tokens[i]
            if variables[t] ~= nil then
                table.insert(expr_tokens, tostring(variables[t]))
            else
                table.insert(expr_tokens, t)
            end
        end

        local expr = table.concat(expr_tokens, " ")
        local chunk, err = load("return " .. expr)
        if not chunk then
            print(" === Error on line "..line_count..": Invalid expression \""..expr.."\"")
            return
        end
        local ok, result = pcall(chunk)
        if not ok or result == nil then
            print(" === Error on line "..line_count..": Invalid expression \""..expr.."\"")
            return
        end
        variables[varName] = result
    end

    if not variable_order[varName] then
        table.insert(variable_order, varName)
        variable_order[varName] = true
    end
end

function eval_display(tokens, local_vars)
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
        return
    end

    local val = nil

    if local_vars and local_vars[rawValue] ~= nil then
        val = local_vars[rawValue]
    elseif variables[rawValue] ~= nil then
        val = variables[rawValue]
    end

    if val ~= nil then
        print(val)
    else
        local numValue = tonumber(rawValue)
        if numValue ~= nil then
            print(numValue)
        else
            print(" === Variable '"..rawValue.."' does not exist!")
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

local functions = {}
local function_block_lines = {}
function eval_function(tokens)
    local fn_name = tokens[2]
    local fn_params = {}
    for i = 4, #tokens do
        table.insert(fn_params, tokens[i-1]) -- remove "pls" argument
    end
    function_block_lines = {}
    for extra_line in io.lines() do
        local extra_tokens = loopTokens(extra_line)
        if extra_tokens[1]:lower() == "endfunk" then
            break
        else
            table.insert(function_block_lines, extra_line)
        end
    end
    functions[fn_name] = {
        params = fn_params,
        body = function_block_lines
    }
end

function eval_function_call(tokens)
    local fn_name = tokens[2]
    local args = {}
    for i = 3, #tokens do
        table.insert(args, tokens[i-1]) -- remove "pls" argument
    end
    local local_vars = {}
    for i, v in ipairs(functions[fn_name]["params"]) do
        local argt = args[i+1]
        if argt ~= nil then
            if argt:sub(1,1) == "\"" and argt:sub(-1) == "\"" then
                local_vars[v] = argt:sub(2,-2)
            elseif variables[argt] ~= nil then
                argt = variables[argt]
            else
                local numValue = tonumber(rawValue)
                if numValue ~= nil then
                    argt = numValue
                end
            end
            variables[v] = argt
        end
    end
    for w, x in ipairs(functions[fn_name]["body"]) do
        processLine(x, local_vars)
    end
    --for _, item in pairs(function_block_lines) do
    --    processLine(item)
    --end
end

function loopTokens(line)
    local tokens = {}
    local pos = 1
    local len = #line
    while pos <= len do
        local quoted_start, quoted_end, quoted_content = string.find(line, '^"([^"]*)"', pos)
        if quoted_start == pos then
            table.insert(tokens, '"' .. quoted_content .. '"')
            pos = quoted_end + 1
        else
            local word_start, word_end = string.find(line, '^[^%s"]+', pos)
            if word_start == pos then
                table.insert(tokens, string.sub(line, word_start, word_end))
                pos = word_end + 1
            else
                local ws_start, ws_end = string.find(line, '^%s+', pos)
                if ws_start == pos then
                    pos = ws_end + 1
                else
                    pos = pos + 1
                end
            end
        end
    end
    return tokens
end

local lineTypes = {
    ["variable"] = eval_var,
    ["display"] = eval_display,
    ["wait"] = eval_wait,
    ["repeat"] = eval_repeat,
    ["function"] = eval_function,
    ["call"] = eval_function_call,
}

function processLine(line, local_vars)
    local tokens = loopTokens(line)
    local lineType = getLineType(tokens)
    if lineType then
        local fn = lineTypes[lineType]
        if fn then
            fn(tokens, local_vars)
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
    elseif tokens[1]:lower() == "funk" then
        return "function"
    elseif tokens[1]:lower() == "call" then
        return "call"
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