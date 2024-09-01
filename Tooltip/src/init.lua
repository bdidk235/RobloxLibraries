local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer :: Player?

local HoveringModule = require(script.HoveringModule)

type Impl = {
	__index: Impl,
	new: (
		object: GuiObject,
		text: string,
		font: (Font | Enum.Font)?,
		fontSize: (number | Enum.FontSize)?
	) -> Tooltip,
	Show: (self: Tooltip) -> Tooltip,
	Hide: (self: Tooltip) -> Tooltip,
	SetText: (self: Tooltip, text: string) -> Tooltip,
	Disconnect: (self: Tooltip) -> (),
	Destroy: (self: Tooltip) -> (),
	_CreateGui: (guiTarget: GuiTarget?) -> ScreenGui,
}

type Proto = {
	Object: GuiObject,
	Text: string,
	Font: (Font | Enum.Font)?,
	FontSize: (number | Enum.FontSize)?,
	Gui: ScreenGui,
	_Hovering: {
		HoverStarted: BindableEvent,
		HoverEnded: BindableEvent,
	},
	_MoveConnection: RBXScriptConnection,
	_LeaveConnection: RBXScriptConnection,
}

local Tooltip: Impl = {} :: Impl
Tooltip.__index = Tooltip

export type Tooltip = typeof(setmetatable({} :: Proto, {} :: Impl))

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

type GuiTarget = {
	target: Instance,
	needsScreenGui: boolean,
}

local function getGuiTarget(reference: Instance?): GuiTarget
	if LocalPlayer == nil or LocalPlayer:FindFirstChildWhichIsA("PlayerGui") == nil then
		local hoarcekat = reference
			and (
				reference:FindFirstAncestor("Hoarcekat")
				or reference:FindFirstAncestor("flipbook")
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

function Tooltip.new(object: GuiObject, text: string, font: (Font | Enum.Font)?, fontSize: (number | Enum.FontSize)?)
	local self = setmetatable({} :: Proto, Tooltip)
	local hovering = HoveringModule.new(object)

	self.Object = object
	self.Text = text
	self.Font = font or Enum.Font.GothamMedium
	self.FontSize = fontSize or 14

	local guiTarget = getGuiTarget(object)

	self.Gui = Tooltip._CreateGui(guiTarget)

	self._Hovering = hovering
	self._MoveConnection = object.MouseMoved:Connect(function()
		self:Show()
	end)
	self._LeaveConnection = hovering.HoverEnded:Connect(function()
		self:Hide()
	end)

	return self
end

function Tooltip:Show()
	local tooltip = self.Gui:FindFirstChildOfClass("TextLabel")
	local selectedObject = self.Gui:FindFirstChildOfClass("ObjectValue")
	assert(tooltip and tooltip:IsA("TextLabel"), "No Tooltip found!")

	local mouse = UserInputService:GetMouseLocation()
	local viewportSize = workspace.CurrentCamera.ViewportSize

	local textBounds =
		getTextSize(self.Text, self.FontSize, self.Font, Vector2.new(viewportSize.X / 3, viewportSize.Y / 3), true)

	local xOffset = 15
	local yOffset = 18

	if mouse.X > viewportSize.X * 0.95 - textBounds.X + 10 then xOffset = -textBounds.X - 15 end
	if mouse.Y > viewportSize.Y * 0.95 - textBounds.Y - 70 then yOffset = -textBounds.Y - 18 end

	tooltip.Text = self.Text
	tooltip.Font = self.Font
	tooltip.TextSize = self.FontSize

	tooltip.Position = UDim2.new(mouse.X / viewportSize.X, xOffset, mouse.Y / viewportSize.Y, yOffset)
	tooltip.Size = UDim2.new(0, textBounds.X + 10, 0, textBounds.Y + 10)

	tooltip.Visible = true
	if selectedObject and typeof(self.Object) == "Instance" then selectedObject.Value = self.Object end
	return self
end

function Tooltip:Hide()
	local tooltip = self.Gui:FindFirstChildOfClass("TextLabel")
	local selectedObject = self.Gui:FindFirstChildOfClass("ObjectValue")
	assert(tooltip and tooltip:IsA("TextLabel"), "No Tooltip found!")

	if not selectedObject or selectedObject.Value == self.Object then
		tooltip.Visible = false
		if selectedObject then selectedObject.Value = nil end
	end
	return self
end

function Tooltip:SetText(text: string)
	local tooltip = self.Gui:FindFirstChildOfClass("TextLabel")
	local selectedObject = self.Gui:FindFirstChildOfClass("ObjectValue")
	assert(tooltip and tooltip:IsA("TextLabel"), "No Tooltip found!")

	self.Text = text
	if selectedObject and self.Object == selectedObject.Value then self:Show() end
	return self
end

function Tooltip:Disconnect(): ()
	if self._MoveConnection then self._MoveConnection:Disconnect() end
	if self._LeaveConnection then self._LeaveConnection:Disconnect() end
	table.clear(self :: any)
end
Tooltip.Destroy = Tooltip.Disconnect

function Tooltip._CreateGui(guiTarget: GuiTarget?): ScreenGui
	local guiParent = guiTarget and guiTarget.target or LocalPlayer.PlayerGui
	local oldGui = guiParent:FindFirstChild("TooltipGui")
	if oldGui and oldGui:IsA("ScreenGui") then
		return oldGui
	elseif oldGui then
		oldGui:Destroy()
	end

	local gui = Instance.new("ScreenGui")
	gui.Name = "TooltipGui"
	gui.DisplayOrder = 10
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local tooltip = Instance.new("TextLabel")
	tooltip.Name = "Tooltip"
	tooltip.BackgroundTransparency = 0.5
	tooltip.BackgroundColor3 = Color3.new(0, 0, 0)
	tooltip.TextColor3 = Color3.new(1, 1, 1)
	tooltip.BorderSizePixel = 0
	tooltip.Visible = false
	tooltip.Size = UDim2.new(0.35, 0, 0.1, 0)
	tooltip.RichText = true
	tooltip.Text = "Tooltip"
	tooltip.Font = Enum.Font.GothamMedium
	tooltip.TextSize = 14
	tooltip.TextWrapped = true

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 3)

	local selectedObject = Instance.new("ObjectValue")
	selectedObject.Name = "SelectedObject"

	uiCorner.Parent = tooltip
	tooltip.Parent = gui
	selectedObject.Parent = gui
	gui.Parent = guiParent

	return gui
end

return {
	new = Tooltip.new,
}
