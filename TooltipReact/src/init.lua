local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local React = require(script.Parent.React)
local ReactRoblox = require(script.Parent.ReactRoblox)

local PlayerGuiPortal = require(script.PlayerGuiPortal)

local e = React.createElement
local createBinding = React.createBinding
local createRef = React.createRef
local subscribeToBinding = React.__subscribeToBinding
local LocalPlayer = Players.LocalPlayer

local TooltipComponent = React.Component:extend("Tooltip")
type TooltipComponent = typeof(TooltipComponent)

-- Get TextSize but with RichText support!
function getTextSize(text: string, textSize: number, font: Font | Enum.Font, frameSize: Vector2, richText: boolean?)
	local textLabel = Instance.new("TextLabel")
	textLabel.Text = text
	textLabel.TextSize = textSize
	if typeof(font) == "Font" then
		textLabel.FontFace = font
	else
		textLabel.Font = font
	end
	textLabel.Position = UDim2.new(2, 0, 2, 0)
	textLabel.Size = UDim2.new(0, frameSize.X, 0, frameSize.Y)
	textLabel.TextWrapped = true
	textLabel.RichText = richText or false
	textLabel.Parent = LocalPlayer.PlayerGui
	local textBounds = textLabel.TextBounds
	textLabel:Destroy()

	return textBounds
end

function updateTooltip(self: TooltipComponent)
	if not self.hovered then return end
	local frame: Frame = self.frameRef:getValue()
	if not frame then return end
	local tooltip: TextLabel = self.tooltipRef:getValue()
	if not tooltip then return end

	local props: Props = self.props
	local text = if type(props.text) == "string" then props.text else props.text:getValue()

	local viewportSize = workspace.CurrentCamera.ViewportSize

	local mouse = UserInputService:GetMouseLocation()
	local textBounds = getTextSize(text, self.fontSize, self.font, Vector2.new(viewportSize.X / 2, viewportSize.Y / 2), true)

	local xOffset = 15
	local yOffset = 18

	if mouse.X > viewportSize.X * 0.95 - textBounds.X + 10 then xOffset = -textBounds.X - 15 end

	if mouse.Y > viewportSize.Y * 0.95 - textBounds.Y - 70 then yOffset = -textBounds.Y - 18 end

	self.setPosition(UDim2.new(mouse.X / viewportSize.X, xOffset, mouse.Y / viewportSize.Y, yOffset))
	self.setSize(UDim2.new(0, textBounds.X + 10, 0, textBounds.Y + 10))
end

function TooltipContainer(self: TooltipComponent)
	return e(
		PlayerGuiPortal,
		{
			screenInsets = Enum.ScreenInsets.None,
			enabled = self.hovered,
			displayOrder = 9999,
		} :: PlayerGuiPortal.Props,
		{
			Tooltip = e("TextLabel", {
				Text = self.props.text,
				Font = self.font,
				TextSize = self.fontSize,
				TextWrapped = true,
				RichText = true,
				TextColor3 = Color3.new(1, 1, 1),
				BackgroundColor3 = Color3.new(0, 0, 0),
				BackgroundTransparency = 0.5,
				Position = self.position,
				Size = self.size,
				BorderSizePixel = 0,

				ref = self.tooltipRef,
			}, {
				UICorner = e("UICorner", {
					CornerRadius = UDim.new(0, 3),
				}),
			}),
		}
	)
end

export type Props = {
	text: string | React.Binding<string>,
	font: (Font | Enum.Font)?,
	fontSize: (number | Enum.FontSize)?,
}

function TooltipComponent:init()
	self._connections = {}

	self.position, self.setPosition = createBinding(UDim2.new(0, 0, 0, 0))
	self.size, self.setSize = createBinding(UDim2.new(0.35, 0, 0.1, 0))
	self.hovered, self.setHovered = createBinding(false)

	self.frameRef = createRef()
	self.tooltipRef = createRef()

	self.font = self.props.font or Enum.Font.GothamMedium
	self.fontSize = self.props.fontSize or 14

	self.uiRootRoot = nil :: ReactRoblox.RootType?
end

function TooltipComponent:didMount()
	local props: Props = self.props

	do
		local container = LocalPlayer:WaitForChild("PlayerGui")
		assert(container, "Cannot wait for PlayerGui.")

		self.uiRootRoot = ReactRoblox.createRoot(Instance.new("Folder"))
		assert(self.uiRootRoot, "")
		self.uiRootRoot:render(ReactRoblox.createPortal(TooltipContainer(self), container))
	end

	local frame: Frame = self.frameRef:getValue()
	if not frame then return end

	if type(props.text) ~= "string" then
		subscribeToBinding(props.text, function()
			if not self.hovered:getValue() then return end
			updateTooltip(self)
		end)
	end

	self.MouseMoved = frame.MouseMoved:Connect(function()
		updateTooltip(self)
	end)
	table.insert(self._connections, self.MouseMoved)

	-- Input events
	self.InputBegan = frame.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch
		then
			self.setHovered(true)
			updateTooltip(self)
		end
	end)
	table.insert(self._connections, self.InputBegan)

	self.InputEnded = frame.InputEnded:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch
		then
			self.setHovered(false)
		end
	end)
	table.insert(self._connections, self.InputEnded)

	-- Cleaning up
	self.Destroying = frame.Destroying:Connect(function()
		for _, connection in pairs(self._connections) do
			connection:Disconnect()
		end
		if self.uiRootRoot then self.uiRootRoot:unmount() end
		table.clear(self :: any)
		setmetatable(self :: any, nil)
	end)
	table.insert(self._connections, self.Destroying)
end

function TooltipComponent:willUnmount()
	for _, connection in pairs(self._connections) do
		connection:Disconnect()
	end
	if self.uiRootRoot then self.uiRootRoot:unmount() end
end

function TooltipComponent:render()
	-- This frame is used for events
	return e("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),

		ref = self.frameRef,
	})
end

return TooltipComponent
