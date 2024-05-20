-- taken from https://bin.boyned.com/mehulimuwa.lua
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local React = require(script.Parent.Parent.React)
local ReactRoblox = require(script.Parent.Parent.ReactRoblox)

local Pane = require(script.Parent.Pane)

local e = React.createElement
local LocalPlayer = Players.LocalPlayer :: Player?

type PortalTarget = {
	target: Instance,
	needsScreenGui: boolean,
}

local function getPortalTarget(reference: Instance?): PortalTarget
	if LocalPlayer == nil or LocalPlayer:FindFirstChildWhichIsA("PlayerGui") == nil then
		local hoarcekat = reference
			and (reference:FindFirstAncestor("Hoarcekat") or reference:FindFirstAncestor("flipbook"))
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

export type Props = {
	displayOrder: number?,
	screenInsets: Enum.ScreenInsets?,
	placeDirectly: boolean?,
	enabled: boolean?,

	children: React.ReactNode,
}

local function PlayerGuiPortal(props: Props)
	local portalTarget: PortalTarget?, setPortalTarget = React.useState(nil :: PortalTarget?)
	local ref = React.useRef(nil :: Folder?)

	React.useEffect(function()
		setPortalTarget(getPortalTarget(ref.current))

		return function()
			setPortalTarget(nil)
		end
	end, {})

	return e(React.Fragment, {}, {
		PlayerGuiPortal = portalTarget and ReactRoblox.createPortal(
			if props.placeDirectly
				then props.children
				elseif portalTarget.needsScreenGui then e("ScreenGui", {
					DisplayOrder = props.displayOrder,
					ScreenInsets = props.screenInsets,
					Enabled = props.enabled,
					ResetOnSpawn = false,
					ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
				}, props.children)
				else e(Pane, {
					native = {
						ZIndex = props.displayOrder,
						Visible = props.enabled,
					},
				}, props.children),
			portalTarget.target
		),

		Reference = e("Folder", {
			ref = ref,
		}),
	})
end

return PlayerGuiPortal
