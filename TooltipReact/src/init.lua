local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local React = require(script.Parent.React)
local ReactRoblox = require(script.Parent.ReactRoblox)

local ScreenGui = require(script.ScreenGui)

local e = React.createElement
local createBinding = React.createBinding
local createRef = React.createRef
local subscribeToBinding = React.__subscribeToBinding
local LocalPlayer = Players.LocalPlayer :: Player?

-- I would've used function components if I wrote this now, but I'm too lazy to rewrite it.
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
	textLabel.Parent = if LocalPlayer then LocalPlayer:FindFirstChildWhichIsA("PlayerGui") else CoreGui
	local textBounds = textLabel.TextBounds
	textLabel:Destroy()

	return textBounds
end

function updateTooltip(self: TooltipComponent)
	local frame: Frame = self.frameRef:getValue()
	if not frame then return end
	local tooltip: TextLabel = self.tooltipRef:getValue()
	if not tooltip then return end

	local props: Props = self.props
	local text = if type(props.text) == "string" then props.text else props.text:getValue()

	local viewportSize = workspace.CurrentCamera.ViewportSize

	local mouse = if self.portalTarget.needsScreenGui or not self.lastInput
		then UserInputService:GetMouseLocation()
		else self.lastInput.Position

	local textBounds =
		getTextSize(text, self.fontSize, self.font, Vector2.new(viewportSize.X / 2.5, viewportSize.Y / 2.5), true)

	local xOffset = 15
	local yOffset = 18

	if mouse.X > viewportSize.X * 0.75 - textBounds.X + 10 then xOffset = -textBounds.X - 15 end
	if mouse.Y > viewportSize.Y * 0.75 - textBounds.Y - 70 then yOffset = -textBounds.Y - 18 end

	self.setText(text)
	self.setPosition(UDim2.new(mouse.X / viewportSize.X, xOffset, mouse.Y / viewportSize.Y, yOffset))
	self.setSize(UDim2.new(0, textBounds.X + 10, 0, textBounds.Y + 10))
end

type PortalTarget = {
	target: Instance,
	needsScreenGui: boolean,
}

local function getPortalTarget(reference: Instance?): PortalTarget
	if LocalPlayer == nil or LocalPlayer:FindFirstChildWhichIsA("PlayerGui") == nil then
		local hoarcekat = reference
			and (
				reference:FindFirstAncestor("Hoarcekat")
				--or reference:FindFirstAncestor("flipbook")
				or reference:FindFirstAncestor("UILabs")
			)
		if hoarcekat == nil then
			return {
				target = CoreGui,
				needsScreenGui = true,
			}
		else
			return {
				target = hoarcekat,
				needsScreenGui = false,
			}
		end
	else
		return {
			target = LocalPlayer.PlayerGui,
			needsScreenGui = true,
		}
	end
end

function TooltipContainer(self: TooltipComponent, needsScreenGui: boolean?)
	local tooltip = e("TextLabel", {
		Text = self.text,
		Font = self.font,
		TextSize = self.fontSize,
		TextWrapped = true,
		RichText = true,
		TextColor3 = Color3.new(1, 1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.5,
		Position = self.position,
		Size = self.size,
		Visible = if not (needsScreenGui == nil or needsScreenGui == true) then self.hovered else nil,
		BorderSizePixel = 0,

		ref = self.tooltipRef,
	}, {
		UICorner = e("UICorner", {
			CornerRadius = UDim.new(0, 3),
		}),
	})

	return if needsScreenGui == nil or needsScreenGui == true
		then e(ScreenGui, {
			key = "TooltipContainer",
			ScreenInsets = Enum.ScreenInsets.None,
			Enabled = self.hovered,
			ResetOnSpawn = false,
			DisplayOrder = 9999,
		}, {
			Tooltip = tooltip,
		})
		else tooltip
end

export type Props = {
	text: string | React.Binding<string>,
	font: (Font | Enum.Font)?,
	fontSize: (number | Enum.FontSize)?,
}

function TooltipComponent:init()
	self._connections = {}

	self.text, self.setText = createBinding("")
	self.position, self.setPosition = createBinding(UDim2.new(0, 0, 0, 0))
	self.size, self.setSize = createBinding(UDim2.new(0.35, 0, 0.1, 0))
	self.hovered, self.setHovered = createBinding(false)

	self.ref = createRef()
	self.frameRef = createRef()
	self.tooltipRef = createRef()

	self.font = self.props.font or Enum.Font.GothamMedium
	self.fontSize = self.props.fontSize or 14

	self.lastInput = nil

	self.tooltipRoot = ReactRoblox.createRoot(Instance.new("Folder")) :: ReactRoblox.RootType?
	self.uiRootRoot = nil :: ReactRoblox.RootType?
	self.portalTarget = nil :: PortalTarget?
end

function TooltipComponent:didMount()
	local props: Props = self.props

	local reference = self.ref:getValue() :: Instance

	local function renderTooltip()
		if self.tooltipRoot then
			self.tooltipRoot:unmount()

			self.portalTarget = getPortalTarget(reference)
			self.tooltipRoot:render(
				ReactRoblox.createPortal(
					TooltipContainer(self, self.portalTarget.needsScreenGui),
					self.portalTarget.target
				)
			)
		end
	end

	renderTooltip()
	reference.AncestryChanged:Connect(renderTooltip)

	local frame: Frame = self.frameRef:getValue()
	if not frame then return end

	if type(props.text) ~= "string" then
		local textSubscription = subscribeToBinding(props.text, function()
			if not self.hovered:getValue() then return end
			updateTooltip(self)
		end)
		table.insert(self._connections, textSubscription)
	end

	self.InputChanged = frame.InputChanged:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch
		then
			self.lastInput = input
			if not self.hovered:getValue() then return end
			updateTooltip(self)
		end
	end)
	table.insert(self._connections, self.InputChanged)

	-- Input events
	self.InputBegan = frame.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch
		then
			self.lastInput = input
			updateTooltip(self)
			self.setHovered(true)
		end
	end)
	table.insert(self._connections, self.InputBegan)

	self.InputEnded = frame.InputEnded:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch
		then
			self.lastInput = input
			self.setHovered(false)
		end
	end)
	table.insert(self._connections, self.InputEnded)

	-- Cleaning up
	self.Destroying = frame.Destroying:Connect(function()
		for _, connection in pairs(self._connections) do
			if type(connection) == "function" then
				connection()
			else
				connection:Disconnect()
			end
		end
		if self.uiRootRoot then self.uiRootRoot:unmount() end
		table.clear(self :: any)
		setmetatable(self :: any, nil)
	end)
	table.insert(self._connections, self.Destroying)
end

function TooltipComponent:willUnmount()
	for _, connection in pairs(self._connections) do
		if type(connection) == "function" then
			connection()
		else
			connection:Disconnect()
		end
	end
	if self.uiRootRoot then self.uiRootRoot:unmount() end
end

function TooltipComponent:render()
	local props: Props = self.props
	if type(props.text) == "string" then updateTooltip(self) end

	-- Frame is used for events, and Reference is used for portal target
	return e(React.Fragment, {}, {
		Frame = e("Frame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),

			ref = self.frameRef,
		}),

		Reference = e("Folder", {
			ref = self.ref,
		}),
	})
end

return TooltipComponent
