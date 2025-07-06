doc = io.open("example.hyp", "r")
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

    if rawValue:sub(1,1) == "\"" and rawValue:sub(-1) == "\"" then
        print(rawValue:sub(2,-2))
    else
        local numValue = tonumber(rawValue)
        if numValue ~= nil then
            print(numValue)
        else
            if variables[rawValue] == nil then
                print(" === Variable '"..varName.."' does not exist!")
            else
                print(variables[rawValue])
            end
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

function getLineType(tokens)
    if tokens[1]:lower() == "can" and tokens[3]:lower() == "be" then
        return "variable"
    elseif tokens[1]:lower() == "display" then
        return "display" -- equivalent of print
    end
end

for line in io.lines() do
    local tokens = loopTokens(line)
    local lineType = getLineType(tokens)
    if lineType == "variable" then
        eval_var(tokens)
    elseif lineType == "display" then
        eval_display(tokens)
    end
    line_count = line_count + 1
end
--for _, varName in ipairs(variable_order) do
--    print(varName, variables[varName])
--end