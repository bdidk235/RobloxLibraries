local React = require(script.Parent.Parent.React)
local Sift = require(script.Parent.Parent.Sift)

local e = React.createElement
local join = Sift.Dictionary.join

export type Props = React.ElementProps<ScreenGui>

local function ScreenGui(props: Props)
	return e(
		"ScreenGui",
		join({
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			ResetOnSpawn = false,
		}, props or {}),
		props.children
	)
end

return ScreenGui
