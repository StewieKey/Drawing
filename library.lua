local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local drawings = Instance.new("Frame")
drawings.Size = UDim2.new(1, 0, 1, 0)
drawings.BackgroundTransparency = 1
drawings.Parent = Instance.new("ScreenGui")
drawings.Parent.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

Drawing = {}
Drawing.__index = Drawing
Drawing.Heartbeat = game:GetService("RunService").Heartbeat
Drawing.RainbowFrequency = 0.5

function Drawing.generateUniqueRandomString(length, existingStrings, maxAttempts)
	maxAttempts = maxAttempts or 15

	local function generateRandomString(length)
		local characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
		local result = ""

		for i = 1, length do
			local charIndex = math.random(1, #characters)
			result = result .. string.sub(characters, charIndex, charIndex)
		end

		return result
	end

	for _ = 1, maxAttempts do
		local randomString = generateRandomString(length)

		local isUnique = true
		for _, existingString in ipairs(existingStrings) do
			if randomString == existingString then
				isUnique = false
				break
			end
		end

		if isUnique then
			return randomString
		end
	end

	return generateRandomString(length)
end

function Drawing.createProperties(type)
	local self = setmetatable({}, Drawing)
	self.type = type
	self.Visible = false
	self.Color = Color3.fromRGB(255, 255, 255)
	self.Name = Drawing.generateUniqueRandomString(10, {})

	return self
end

function Drawing.getRainbowColor()
	local time = tick()
	local r = math.sin(Drawing.RainbowFrequency * time + 0) * 127 + 128
	local g = math.sin(Drawing.RainbowFrequency * time + 2) * 127 + 128
	local b = math.sin(Drawing.RainbowFrequency * time + 4) * 127 + 128
	return Color3.fromRGB(r, g, b)
end

function Drawing.hasErrors(properties, errorThrown)
	local errorAmount = 0 

	for _, property in pairs(properties) do	
		if errorThrown[property] == true then
			errorAmount = errorAmount + 1
		end
	end

	return errorAmount > 0
end

function Drawing.checkType(properties, expectedTypes, instance, errorThrown)
    for propertyName, info in pairs(expectedTypes) do
        if not table.find(properties, propertyName) then
            table.insert(properties, propertyName)
        end

        local value = instance[propertyName]
        local expectedType = info.type

        if type(value) ~= expectedType and not errorThrown[propertyName] then
            local errorMessage = string.format("Expected type %s for property '%s', got %s.",
                expectedType,
                propertyName,
                type(value))
            warn(errorMessage)

            errorThrown[propertyName] = true
        elseif type(value) == expectedType then
            errorThrown[propertyName] = false
        end
    end
end

function Drawing.drawLine()
	local Line = Drawing.createProperties("Line")

	Line.Transparency = 0
	Line.Thickness = 0
	Line.From = Vector2.new(0, 0)
	Line.To = Vector2.new(0, 0)
	Line.Visible = true
	Line.Color = Color3.fromRGB(255, 255, 255)
	Line.Rainbow = false

	local lineFrame = Instance.new("Frame")
	lineFrame.Parent = drawings
	lineFrame.BackgroundTransparency = Line.Transparency
	lineFrame.Size = UDim2.new(0, 0, 0, 0)
	lineFrame.BorderSizePixel = 0
	lineFrame.Name = Line.Name
	lineFrame.AnchorPoint = Vector2.new(.5, .5)
	lineFrame.BackgroundColor3 = Line.Color

	local errorThrown = {}	
	Line.properties = {}

	local function updateFrame(Line)
		local length = (Line.From - Line.To).Magnitude
		local position = (Line.From + Line.To) / 2

		lineFrame.Position = UDim2.new(0, position.X, 0, position.Y)
		lineFrame.Size = UDim2.new(0, length, 0, Line.Thickness)
		lineFrame.Rotation = math.deg(math.atan2(Line.To.Y - Line.From.Y, Line.To.X - Line.From.X))
		lineFrame.BackgroundColor3 = Line.Color
		lineFrame.Visible = Line.Visible
		lineFrame.BackgroundTransparency = Line.Transparency
		
		if not Line.Rainbow then
			lineFrame.BackgroundColor3 = Line.Color
		else
			lineFrame.BackgroundColor3 = Drawing.getRainbowColor()
		end
	end

	Line.UpdateConnection = Drawing.Heartbeat:Connect(function()
		local hasErrors = Drawing.hasErrors(Line.properties, errorThrown)
		
		Drawing.checkType(Line.properties, {
            Transparency = {type = "number"},
            Thickness = {type = "number"},
            From = {type = "userdata"},
            To = {type = "userdata"},
            Visible = {type = "boolean"},
            Color = {type = "userdata"},
            Rainbow = {type = "boolean"},
        }, Line, errorThrown)
		
		if not hasErrors then
			updateFrame(Line)
		end
	end)

	return Line
end

function Drawing.drawSquare()
	local Square = Drawing.createProperties("Square")

	Square.Transparency = 0
	Square.Size = Vector2.new(50, 50)
	Square.Position = Vector2.new(0, 0)
	Square.Visible = true
	Square.Color = Color3.fromRGB(255, 255, 255)
	Square.Filled = false
    Square.BorderThickness = 0
    Square.BorderColor = Color3.fromRGB(0, 0, 0)
    Square.BorderTransparency = 0
	Square.Rainbow = false

	local squareFrame = Instance.new("Frame")
	squareFrame.Parent = drawings
	squareFrame.BackgroundTransparency = Square.Transparency
	squareFrame.Size = UDim2.new(0, Square.Size.X, 0, Square.Size.Y)
	squareFrame.Position = UDim2.new(0, Square.Position.X, 0, Square.Position.Y)
	squareFrame.BorderSizePixel = 0
	squareFrame.Name = Square.Name
	squareFrame.BackgroundColor3 = Square.Color
	squareFrame.AnchorPoint = Vector2.new(.5, .5)

    local squareBorderStroke = Instance.new("UIStroke")
	squareBorderStroke.Parent = squareFrame
	squareBorderStroke.Color = Square.BorderColor
    squareBorderStroke.Enabled = Square.Visible
    squareBorderStroke.Transparency = Square.BorderTransparency
    squareBorderStroke.Thickness = Square.BorderThickness

	local errorThrown = {}
	Square.properties = {}

	local function updateFrame(Square)
		squareFrame.Position = UDim2.new(0, Square.Position.X, 0, Square.Position.Y)
		squareFrame.Size = UDim2.new(0, Square.Size.X, 0, Square.Size.Y)
		squareFrame.BackgroundColor3 = Square.Color
		squareFrame.Visible = Square.Visible
		squareFrame.BackgroundTransparency = Square.Transparency

		squareBorderStroke.Color = Square.BorderColor
		squareBorderStroke.Enabled = Square.Visible
		squareBorderStroke.Transparency = Square.BorderTransparency
        squareBorderStroke.Thickness = Square.BorderThickness

		if Square.Filled then
			squareFrame.BackgroundTransparency = 0
		else
			squareFrame.BackgroundTransparency = 1
		end

        if not Square.Rainbow then
			squareFrame.BackgroundColor3 = Square.Color
            squareBorderStroke.Color = Square.BorderColor
		else
			squareFrame.BackgroundColor3 = Drawing.getRainbowColor()
            squareBorderStroke.Color = Drawing.getRainbowColor()
		end
	end

	Square.UpdateConnection = Drawing.Heartbeat:Connect(function()
        local hasErrors = Drawing.hasErrors(Square.properties, errorThrown)

		Drawing.checkType(Square.properties, {
            Transparency = {type = "number"},
            Size = {type = "userdata"},
            Position = {type = "userdata"},
            Visible = {type = "boolean"},
            Color = {type = "userdata"},
            Filled = {type = "boolean"},
            BorderThickness = {type = "number"},
            BorderTransparency = {type = "number"},
            BorderColor = {type = "userdata"},
            Rainbow = {type = "boolean"},
        }, Square, errorThrown)
		
		if not hasErrors then
			updateFrame(Square)
		end
	end)

	return Square
end

function Drawing.new(object)
	if string.lower(object) == "line" then
		return Drawing.drawLine()
	elseif string.lower(object) == "square" then
		return Drawing.drawSquare()
	else
		error(string.format("%s does not exist in the drawing library.", object))
	end
end 

Drawing.HideDrawing = Drawing.Heartbeat:Connect(function()
	drawings.Parent.Name = Drawing.generateUniqueRandomString(20, {})
end)

Drawing.RainbowFrequency = 5

local Line = Drawing.new("Line")
Line.Transparency = 0
Line.Thickness = 1
Line.From = Vector2.new(0, 0)
Line.To = Vector2.new(0, 0)
Line.Visible = true
Line.Color = Color3.fromRGB(133, 0, 255)
Line.Rainbow = true

RunService.Heartbeat:Connect(function()
	local screenSize = workspace.CurrentCamera.ViewportSize
	local centerScreen = screenSize / 2

	Line.From = centerScreen

	local Mouse = Players.LocalPlayer:GetMouse()
	local MousePosition = Vector2.new(Mouse.X, Mouse.Y)
	
	Line.To = MousePosition
end)

local Square = Drawing.new("Square")
Square.Transparency = 0
Square.Thickness = 1
Square.Size = Vector2.new(50, 50)
Square.Position = Vector2.new(0, 0)
Square.Visible = true
Square.Color = Color3.fromRGB(133, 0, 255)
Square.Filled = false
Square.BorderColor = Color3.fromRGB(255, 255, 255)
Square.BorderTransparency = 0
Square.BorderThickness = 1
Square.Rainbow = true

RunService.Heartbeat:Connect(function()
	local Mouse = Players.LocalPlayer:GetMouse()
	local MousePosition = Vector2.new(Mouse.X, Mouse.Y)
	
	Square.Position = MousePosition
end)
