-- taken from https://blog.boyned.com/articles/things-i-learned-using-react/
local React = require(script.Parent.Parent.React)
local Sift = require(script.Parent.Parent.Sift)

local e = React.createElement
local join = Sift.Dictionary.join

export type Props = {
	native: { [any]: any }?,
	children: React.ReactNode?,
}

local function Pane(props: Props)
	return e(
		"Frame",
		join({
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
		}, props.native or {}),
		props.children
	)
end

return Pane
