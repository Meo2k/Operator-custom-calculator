-- Environment for storing variables, functions, and operators
local variables = {}
local operators = {}

setmetatable(variables, {__index = _G}) -- Inherit default Lua functions

-- Function to parse and evaluate the expression
local function calculate(expr)
    -- Loop through all operators in the `operators` table to process
    while true do
        local found = false
        for op, func in pairs(operators) do
            local pattern = "(%d+)%s*" .. op .. "%s*(%d+)"
            local a, b = expr:match(pattern)
            if a and b then
                -- Calculate the value and replace it in the expression
                local args = {tonumber(a), tonumber(b)}
                local result = func(args)
                expr = expr:gsub(pattern, result, 1)
                found = true
                break -- Restart from the beginning to ensure proper processing
            end
        end
        -- Exit when no more operators need to be processed
        if not found then
            break
        end
    end

    -- If there are still parts of the expression, use `load` to evaluate it
    local env = setmetatable(variables, {__index = _G})
    local chunk, err = load("return " .. expr, nil, "t", env)
    if not chunk then
        error("Syntax error: " .. err)
    end
    return chunk()
end

-- Function to define a new operator
local function define_operator(operator, definition)
    -- Create a function from the definition string
    local code = "return function(arg) return " .. definition .. " end"
    local chunk, err = load(code, nil, "t", variables)
    if not chunk then
        error("Operator definition error: " .. err)
    end

    operators[operator] = chunk() -- Store the operator function
end

-- Console interface
print("Lua Calculator. Type 'exit' to quit.")
print("To define an operator: define_operator('OPERATOR', 'EXPRESSION').")
while true do
    io.write("> ")
    local input = io.read()

    if input == "exit" then
        print("Exiting the program.")
        break
    end

    -- Handle operator definition command
    if input:sub(1, 15) == "define_operator" then
        local op, def = input:match("define_operator%('(.-)',%s*'(.-)'%)")
        if op and def then
            local ok, err = pcall(define_operator, op, def)
            if ok then
                print("Operator defined successfully!")
            else
                print("Error: " .. err)
            end
        else
            print("Syntax error! Example: define_operator('@', '(arg[1] + arg[2]) * 2')")
        end
    else
        -- Process the expression
        local ok, result = pcall(calculate, input)
        if ok then
            print("Result: " .. result)
        else
            print("Error: " .. result)
        end
    end
end
