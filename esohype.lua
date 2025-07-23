--[[
 * Copyright (c) 2025 solarcosmic.
 * This project is licensed under the MIT license.
 * To view the license, see <https://opensource.org/licenses/MIT>.
]]
local doc
local isExec = false
local all_lines = {}
if arg[1] == nil then
    print("Lua binary usage: lua esohype.lua <name>.hyp | Executable usage: esohype <name>.hyp")
    print("")
    print("Welcome to EsoHype!")
    print("Please enter the name of the script you would like to use.")
    print("Please make sure that your script is in the **same** directory as EsoHype, or make sure EsoHype is in the top directory.")
    print("To access files in folders, you can do example/script_name.hyp, otherwise do script_name.hyp.");
    print("Enter script name:")
    while true do
        input_result = io.read()
        if input_result then
            doc = io.open(input_result, "r")
            if doc == nil then
                print(" === Error: Invalid file. Please check to make sure the file is correct.")
            else
                isExec = true
                for line in doc:lines() do
                    table.insert(all_lines, line)
                end
                doc:close()
                print("=== EXECUTING SCRIPT ===")
                break
            end
        end
    end
else
    doc = io.open(arg[1], "r")
    for line in doc:lines() do
        table.insert(all_lines, line)
    end
    doc:close()
end

if doc == nil then print(" === Error: Invalid file. Please check to make sure the file is correct. Usage: lua esohype.lua <name>.hyp") return end
--io.input(doc)

local variables = {}
local variable_order = {}
local line_count = 1

function polite_check(tokens, expect_index)
    local word = tokens[expect_index]
    if word then
        if word:lower() == "please" or word:lower() == "pls" then
            return true
        end
    else
        return false
    end
    return false
end

function eval_var(tokens)
    local varName = tokens[2]
    local expr_tokens = {}
    local as_index = nil
    local input_index = nil
    local input_result = nil
    for i = 4, #tokens do
        if tokens[i] and tokens[i]:lower() == "as" then
            as_index = i
            break
        end
    end
    if tokens[4] and tokens[4]:lower() == "input" then
        input_result = io.read()
        if as_index then
            local to_convert = tokens[as_index + 1]
            if to_convert then
                if to_convert:lower() == "number" then
                    input_result = tonumber(input_result)
                    if not input_result then
                        print(" -!- Warn: Could not convert '"..varName.."' to a number, the result will be null.")
                    end
                elseif to_convert:lower() == "string" then
                    input_result = tostring(input_result)
                    if not input_result then
                        print(" -!- Warn: Could not convert '"..varName.."' to a string, the result will be null.")
                    end
                end
            end
        end
        variables[varName] = input_result
        return
    end
    if as_index then
        if input_result then return end
        local conversion_type = tokens[as_index+1] and tokens[as_index+1]:lower()
        local expr_tokens_raw = {}
        for i = 4, as_index-1 do
            table.insert(expr_tokens_raw, tokens[i])
        end
        local expr_str = table.concat(expr_tokens_raw, " ")
        local chunk, err = load("return "..expr_str, "expr", "t", {math=math})
        if not chunk then
            print(" === Error on line "..line_count..": Invalid expression \""..expr_str.."\"")
            return
        end
        local ok, result = pcall(chunk)
        if not ok or result == nil then
            print(" === Error on line "..line_count..": Invalid expression \""..expr_str.."\"")
            return
        end
        if conversion_type == "string" then
            result = tostring(result)
        elseif conversion_type == "number" then
            result = tonumber(result)
            if not result then
                print(" === Error on line "..line_count..": Cannot convert to number.")
                return
            end
        end
        variables[varName] = result
    else
        if input_result then return end
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
            local chunk, err = load("return "..expr, "expr", "t", {math=math})
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
    end

    if not variable_order[varName] then
        table.insert(variable_order, varName)
        variable_order[varName] = true
    end
end

function eval_display(tokens, local_vars)
    local rawValue = tokens[2]
    local please = tokens[3]

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
        return true
    else
        local numValue = tonumber(rawValue)
        if numValue ~= nil then
            print(numValue)
            return true
        else
            print(" === Error: Variable '"..rawValue.."' does not exist!")
            return false
        end
    end
    return false
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
                return true
            else
                print(" === Variable '"..varName.."' is not a qualified number!")
            end
        end
    end
    return false
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
    for extra_line in doc:lines() do
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
    for extra_line in doc:lines() do
        local extra_tokens = loopTokens(extra_line)
        if extra_tokens[1] and extra_tokens[1]:lower() == "endfunk" then
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

function eval_repeat_indefinitely(tokens)
    local block_lines = {}
    for extra_line in doc:lines() do
        local extra_tokens = loopTokens(extra_line)
        if extra_tokens[1]:lower() == "endrepeat" then
            break
        else
            table.insert(block_lines, extra_line)
        end
    end

    while true do
        for _, block_line in ipairs(block_lines) do
            processLine(block_line)
        end
    end
end

function collect_if_block(lines, start_idx)
    local block_lines = {}
    local nesting = 1
    local idx = start_idx
    while idx <= #lines do
        local line = lines[idx]
        local tokens = loopTokens(line)
        if tokens[1] and tokens[1]:lower() == "if" then
            nesting = nesting + 1
        elseif tokens[1] and tokens[1]:lower() == "endif" then
            nesting = nesting - 1
            if nesting == 0 then
                return block_lines, idx
            end
        end
        table.insert(block_lines, line)
        idx = idx + 1
    end
    return block_lines, idx
end

function eval_if(lines, idx, tokens, local_vars)
    local please = tokens[#tokens]
    local condition_tokens = {}
    for i = 2, #tokens-1 do
        local t = tokens[i]
        if local_vars and local_vars[t] ~= nil then
            table.insert(condition_tokens, tostring(local_vars[t]))
        elseif variables[t] ~= nil then
            table.insert(condition_tokens, tostring(variables[t]))
        else
            table.insert(condition_tokens, t)
        end
    end
    local condexpr = table.concat(condition_tokens, " ")
    local chunk, err = load("return "..condexpr, "expr", "t", {math=math})
    if not chunk then
        print(" === Error on line "..line_count..": Invalid condition expression \""..condexpr.."\"")
        return idx + 1
    end
    local success, result = pcall(chunk)
    if not success then
        print(" === Error on line "..line_count..": Failed to evaluate condition \""..condexpr.."\"")
        return idx + 1
    end
    local condition_true = result and true or false
    local block_lines, next_idx = collect_if_block(lines, idx + 1)
    if condition_true then
        local block_idx = 1
        while block_idx <= #block_lines do
            block_idx = processLine(block_lines, block_idx, local_vars)
        end
    end
    return next_idx + 1
end

function loopTokens(line) -- i don't know what i'm reading anymore
    local tokens = {}
    if line == nil then return tokens end
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
    ["repeat_indefinitely"] = eval_repeat_indefinitely,
    ["if"] = eval_if
}

function processLine(lines, idx, local_vars)
    local line = lines[idx]
    local in_quotes = false
    local clean_line = ""
    for i = 1, #line do
        local c = line:sub(i,i)
        if c == '"' then
            in_quotes = not in_quotes
        elseif c == '#' and not in_quotes then
            break
        end
        clean_line = clean_line .. c
    end
    local trimmed = clean_line:match("^%s*(.-)%s*$")
    if trimmed == "" then return idx + 1 end
    local tokens = loopTokens(trimmed)
    if not polite_check(tokens, #tokens) then
        print(" === Error on line "..line_count..": Not parsing this. Please mind your manners next time.")
        return idx + 1
    end
    local lineType = getLineType(tokens)
    if lineType == "if" then
        return eval_if(lines, idx, tokens, local_vars)
    elseif lineType then
        local fn = lineTypes[lineType]
        if fn then
            fn(tokens, local_vars)
        else
            print(" === Error: Unknown line type while parsing: "..lineType)
        end
    end
    return idx + 1
end

function getLineType(tokens)
    if tokens[1] == nil then return end -- new line
    if tokens[1]:lower() == "can" and tokens[3]:lower() == "be" then
        return "variable"
    elseif tokens[1]:lower() == "display" then
        return "display" -- equivalent of print
    elseif tokens[1]:lower() == "wait" and tokens[3]:lower() == "seconds" then
        return "wait" -- wait seconds
    elseif tokens[3] ~= nil and tokens[1]:lower() == "repeat" and tokens[3]:lower() == "times" then
        return "repeat"
    elseif tokens[1]:lower() == "repeat" then
        return "repeat_indefinitely"
    elseif tokens[1]:lower() == "funk" then
        return "function"
    elseif tokens[1]:lower() == "call" then
        return "call"
    elseif tokens[1]:lower() == "if" then
        return "if"
    end
end

local current_line = 1
while current_line <= #all_lines do
    current_line = processLine(all_lines, current_line)
    line_count = line_count + 1
end
--for _, varName in ipairs(variable_order) do
--    print(varName, variables[varName])
--end
--doc:close()
if isExec == true then
    print("=== SCRIPT END, PRESS ENTER/RETURN TO EXIT ===")
    io.read()
end