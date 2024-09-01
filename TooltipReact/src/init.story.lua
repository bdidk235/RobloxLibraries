local React = require(script.Parent.Parent.React)
local ReactRoblox = require(script.Parent.Parent.ReactRoblox)

local Tooltip = require(script.Parent)

local e = React.createElement
local useBinding = React.useState
local useEffect = React.useEffect
local createRoot = ReactRoblox.createRoot

-- If it's too big and it can go off screen
local RANDOMIZE_CHARACTERS = true
local RANDOMIZE_CHARACTERS_LENGTH = 300

local function storyElement()
	local text, setText = useBinding("So basic, yet so useful!")

	useEffect(function()
		if RANDOMIZE_CHARACTERS then
			local randomizeCharactersCorotine = coroutine.create(function()
				while true do
					local newText = ""
					for _ = 1, RANDOMIZE_CHARACTERS_LENGTH do
						newText ..= string.char(math.random(65, 90))
						if math.random(1, 7) == 1 then
							newText ..= " "
						end
					end
					setText(newText)
					task.wait(0.1)
				end
			end)
			coroutine.resume(randomizeCharactersCorotine)
			return function()
				coroutine.close(randomizeCharactersCorotine)
				randomizeCharactersCorotine = nil
			end
		end
		return function() end
	end, {})

	return e(Tooltip, {
		text = text,
	})
end

return function(rootObject: ScreenGui)
	local root = createRoot(rootObject)
	root:render(e(storyElement))

	return function()
		root:unmount()
	end
end
