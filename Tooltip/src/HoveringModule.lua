--#selene: allow(if_same_then_else)
local HoveringModule = {}

--- Local functions
local function typeOrClassName(instance: Instance)
	if typeof(instance) == "Instance" then
		return instance.ClassName
	else
		return typeof(instance)
	end
end

----------------

function HoveringModule.new(guiObject: GuiObject)
	-- Checking for errors
	assert(guiObject, "Argument 1 missing or nil")
	assert(guiObject:IsA("GuiObject"), `Expected a GuiObject, got a {typeOrClassName(guiObject)}`)
	
	-- If gui object is a TextBox, then add a hover detection to prevnet confusion
	if guiObject:IsA("TextBox") then
		local newObject = Instance.new("Frame")
		newObject.Name = "HoverDetectionFrame"
		newObject.BackgroundTransparency = 1
		newObject.BorderSizePixel = 1
		newObject.Size = UDim2.new(1,0,1,0)
		newObject.Position = UDim2.new(0,0,0,0)
		newObject:SetAttribute("HoveringModuleInstances", true)
		newObject.Parent = guiObject
		guiObject = newObject
	end
	
	-- Adding events
	local hoverEvent = Instance.new("BindableEvent")
	local hoverendEvent = Instance.new("BindableEvent")
	
	-- Adding the table
	local hoveringTable = {
		HoverStarted = hoverEvent.Event,
		HoverEnded = hoverendEvent.Event
	}
	
	-- Hovering detection, checks for mouse movement or a mobile touch (only way for mobile hovering)
	guiObject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			hoverEvent:Fire()
		elseif input.UserInputType == Enum.UserInputType.Touch  then
			hoverEvent:Fire()
		end
	end)
	
	-- Same thing as last time, but detects if it ended.
	guiObject.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			hoverendEvent:Fire()
		elseif input.UserInputType == Enum.UserInputType.Touch  then
			hoverendEvent:Fire()
		end
	end)
	
	return hoveringTable
end

return HoveringModule
